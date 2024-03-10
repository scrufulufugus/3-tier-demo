from typing import Annotated
from fastapi import FastAPI, HTTPException, Depends
from fastapi.security import OAuth2PasswordBearer, OAuth2PasswordRequestForm
from .config import settings
from .database import Database, TransactionError
from .models import *

app = FastAPI()

oauth2_scheme = OAuth2PasswordBearer(tokenUrl="token", auto_error=False)

db = Database(settings.database)

# TODO: Make this work will colons in username or password
def token_to_user(token: str) -> User|None:
    split = token.split(':')
    if len(split) != 2:
      return None
    user = db.get_user_by_name(split[0])
    if user is not None and user.password == split[1]:
        return user
    return None


def get_current_user(token: Annotated[str|None, Depends(oauth2_scheme)]) -> User|None:
    if token == None: # Anonymous authentication
        return None
    user = token_to_user(token)
    if user != None:
        return user
    raise HTTPException(status_code=401, detail="Invalid Token")


@app.get("/")
async def root(user: Annotated[User|None, Depends(get_current_user)]):
    if not user:
        return {"message": "Hello World"}
    return {"message": f"Hello {user.username}"}


# Return a token for a given (user, pass)
@app.post("/token")
async def login(form_data: Annotated[OAuth2PasswordRequestForm, Depends()]):
    user = db.get_user_by_name(form_data.username)
    if not user:
        raise HTTPException(status_code=401, detail="Invalid credentials")
    if not form_data.password == user.password:
        raise HTTPException(status_code=401, detail="Invalid credentials")

    return {"access_token": f"{user.username}:{user.password}", "token_type": "bearer"}


# GET /products
@app.get("/products")
async def get_products(user: Annotated[User|None, Depends(get_current_user)]) -> list[int]:
    if user and user.isAdmin:
        return sorted(map(int, db.products.keys()))

    # Return only products with stock
    return sorted([int(k) for k, v in db.products.items() if v["stock"] > 0])


# POST /products
@app.post("/product")
async def create_product(user: Annotated[User|None, Depends(get_current_user)], product: BaseProduct) -> Product:
    if not user:
        raise HTTPException(status_code=401, detail="Invalid credentials")
    if not user.isAdmin:
        raise HTTPException(status_code=403, detail="Invalid credentials")
    return db.append_product(product)

# GET /products/{id}
@app.get("/product/{prod_id}")
async def get_product(user: Annotated[User|None, Depends(get_current_user)], prod_id: int) -> Product:
    product = db.products.get(prod_id)
    if product:
        _prod = Product(**product, prod_id=prod_id)
        if not user or not user.isAdmin:
            if product["stock"] > 0:
                # Hide stock if not authenticated
                _prod.stock = 0
            else:
                # Don't show out of stock items to non-admins
                raise HTTPException(status_code=404, detail="Product not found")
        return _prod
    raise HTTPException(status_code=404, detail="Product not found")

# TODO: Make this a patch route
# POST /products/{id}
@app.post("/product/{prod_id}")
async def update_product(user: Annotated[User|None, Depends(get_current_user)], prod_id: int, product: BaseProduct) -> Product:
    if not user:
        raise HTTPException(status_code=401, detail="Invalid credentials")
    if not user.isAdmin:
        raise HTTPException(status_code=403, detail="Invalid credentials")
    if db.products.get(prod_id):
        edit = ProductEdit(**dict(product))
        return db.update_product(prod_id, edit)
    raise HTTPException(status_code=404, detail="Product not found")

# DELETE /products/{id}
@app.delete("/product/{prod_id}")
async def delete_product(user: Annotated[User|None, Depends(get_current_user)], prod_id: int):
    if not user:
        raise HTTPException(status_code=401, detail="Invalid credentials")
    if not user.isAdmin:
        raise HTTPException(status_code=403, detail="Invalid credentials")
    try:
        db.products.pop(prod_id)
    except KeyError:
        raise HTTPException(status_code=404, detail="Product not found")

# GET /user/{id} (optional)
@app.get("/user/{user_id}")
async def get_user(user_id: int, user: Annotated[User|None, Depends(get_current_user)]) -> UserNoPass:
    if not user:
        raise HTTPException(status_code=401, detail="Invalid credentials")
    if user.user_id != user_id and not user.isAdmin:
        raise HTTPException(status_code=403, detail="Invalid credentials")
    try:
        return User(**db.users[user_id], user_id=user_id)
    except KeyError:
        raise HTTPException(status_code=404, detail="User not found")

# PATCH /user/{id}
@app.patch("/user/{user_id}")
async def update_user(user_id: int, user: Annotated[User|None, Depends(get_current_user)], changes: UserEdit) -> UserNoPass:
    if not user:
        raise HTTPException(status_code=401, detail="Invalid credentials")
    if user.user_id != user_id and not user.isAdmin:
        raise HTTPException(status_code=403, detail="Invalid credentials")
    try:
        return db.update_user(user_id, changes)
    except KeyError:
        raise HTTPException(status_code=404, detail="User not found")

# POST /user/{id} (optional)
# DELETE /user/{id} (optional)

# GET /user/me
@app.get("/me")
async def read_users_me(user: Annotated[User|None, Depends(get_current_user)]) -> UserNoPass:
    if not user:
        raise HTTPException(status_code=401, detail="Invalid credentials")
    return user

# GET /user/me
@app.patch("/me")
async def update_users_me(user: Annotated[User|None, Depends(get_current_user)], changes: UserEdit) -> UserNoPass:
    if not user:
        raise HTTPException(status_code=401, detail="Invalid credentials")
    return await update_user(user.user_id, user, changes)

# POST /purchase
@app.post("/purchase")
async def purchase(user: Annotated[User|None, Depends(get_current_user)], product_ids: list[int]) -> PurchaseRecord:
    if not user:
        raise HTTPException(status_code=401, detail="Invalid credentials")
    if not product_ids or len(product_ids) == 0:
        raise HTTPException(status_code=400, detail="No products in cart")

    to_buy = {}
    for prod_id in product_ids:
        if not db.products.get(prod_id):
            return PurchaseRecord(
                fail_at = prod_id,
                success = False,
                products = product_ids,
                message = "Transaction failed. Product not found",
                total = 0
            )
        if to_buy.get(prod_id) == None:
            to_buy[prod_id] = 0
        to_buy[prod_id] += 1

    transactions: list[Transaction] = []
    for prod_id, count in to_buy.items():
        try:
            trans = db.purchase(user.user_id, prod_id, count)
            print("Transaction:", trans)
            transactions.append(trans)
        except TransactionError as e:
            for trans in transactions:
                db.revert_transaction(trans.trans_id)
            return PurchaseRecord(
                fail_at = prod_id,
                success = False,
                products = product_ids,
                message = str(e),
                total = 0
            )

    total = sum([trans.total for trans in transactions])
    return PurchaseRecord(
        success = True,
        products = product_ids,
        message = f"Transaction successful. Total: ${total*0.01:.2f}",
        total = total
    )
