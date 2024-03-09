from typing import Annotated
from fastapi import FastAPI, HTTPException, Depends
from fastapi.security import OAuth2PasswordBearer, OAuth2PasswordRequestForm
from .config import settings
from .database import Database
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
        return list(db.products.keys())

    # Return only products with stock
    return [k for k, v in db.products.items() if v["stock"] > 0]


# POST /products
@app.post("/product")
async def create_product(user: Annotated[User|None, Depends(get_current_user)], product: ProductBase) -> Product:
    if not user:
        raise HTTPException(status_code=401, detail="Invalid credentials")
    if not user.isAdmin:
        raise HTTPException(status_code=403, detail="Invalid credentials")
    return db.append_product(product)

# GET /products/{id}
@app.get("/product/{id}")
async def get_product(user: Annotated[User|None, Depends(get_current_user)], id: int) -> Product:
    product = db.products.get(id)
    if product:
        _prod = Product(**product)
        if not user or not user.isAdmin:
            if product["stock"] > 0:
                # Hide stock if not authenticated
                _prod.stock = None
            else:
                # Don't show out of stock items to non-admins
                raise HTTPException(status_code=404, detail="Product not found")
        return _prod
    raise HTTPException(status_code=404, detail="Product not found")

# POST /products/{id}
@app.post("/product/{id}")
async def update_product(user: Annotated[User|None, Depends(get_current_user)], id: int, product: ProductBase) -> Product:
    if not user:
        raise HTTPException(status_code=401, detail="Invalid credentials")
    if not user.isAdmin:
        raise HTTPException(status_code=403, detail="Invalid credentials")
    if db.products.get(id):
        return db.update_product(Product(id=id, **dict(product)))
    raise HTTPException(status_code=404, detail="Product not found")

# DELETE /products/{id}
@app.delete("/product/{id}")
async def delete_product(user: Annotated[User|None, Depends(get_current_user)], id: int):
    if not user:
        raise HTTPException(status_code=401, detail="Invalid credentials")
    if not user.isAdmin:
        raise HTTPException(status_code=403, detail="Invalid credentials")
    try:
        db.products.pop(id)
    except KeyError:
        raise HTTPException(status_code=404, detail="Product not found")

# GET /user/{id} (optional)

# PATCH /user/{id}
@app.patch("/user/{id}")
async def update_user(id: int, user: Annotated[User|None, Depends(get_current_user)], changes: OptionalUser) -> BaseUser:
    if not user:
        raise HTTPException(status_code=401, detail="Invalid credentials")
    if user.id != id and not user.isAdmin:
        raise HTTPException(status_code=403, detail="Invalid credentials")
    try:
        return db.update_user(id, changes)
    except KeyError:
        raise HTTPException(status_code=404, detail="User not found")

# POST /user/{id} (optional)
# DELETE /user/{id} (optional)

# GET /user/me
@app.get("/me")
async def read_users_me(user: Annotated[User|None, Depends(get_current_user)]) -> BaseUser:
    if not user:
        raise HTTPException(status_code=401, detail="Invalid credentials")
    return user

# GET /user/me
@app.patch("/me")
async def update_users_me(user: Annotated[User|None, Depends(get_current_user)], changes: OptionalUser) -> BaseUser:
    if not user:
        raise HTTPException(status_code=401, detail="Invalid credentials")
    return await update_user(user.id, user, changes)

# POST /purchase
@app.post("/purchase")
async def purchase(user: Annotated[User|None, Depends(get_current_user)], product_ids: list[int]) -> BaseRecord:
    if not user:
        raise HTTPException(status_code=401, detail="Invalid credentials")
    if not product_ids or len(product_ids) == 0:
        raise HTTPException(status_code=400, detail="No products in cart")

    total = 0
    to_buy = {}
    for id in product_ids:
        product = db.products.get(id)
        if not product:
            return BaseRecord(
                fail_at = id,
                success = False,
                products = product_ids,
                message = "Transaction failed: Product not found",
                total = 0
            )
        if not to_buy.get(id):
            to_buy[id] = product
        to_buy[id]["stock"] -= 1
        if to_buy[id]["stock"] < 0:
            return BaseRecord(
                fail_at = id,
                success = False,
                products = product_ids,
                message = "Transaction failed: Product low on stock",
                total = 0
            )
        total += product["price"]

    for id in product_ids:
        db.buy_product(id)

    result = BaseRecord(
        success = True,
        products = product_ids,
        message = f"Transaction successful. Total: ${round(total,2)}",
        total = total
    )
    return db.append_record(result)
