from typing import Annotated

from fastapi import FastAPI, HTTPException, Depends
from fastapi.security import OAuth2PasswordBearer, OAuth2PasswordRequestForm
from pydantic import BaseModel
from pydantic.json_schema import SkipJsonSchema

# TODO: Temp Dependencies
import random
from copy import deepcopy

app = FastAPI()

oauth2_scheme = OAuth2PasswordBearer(tokenUrl="token", auto_error=False)

# Data Models
class ProductBase(BaseModel):
    title: str
    description: str
    price: float
    stock: int | None = None
    image: str

class Product(ProductBase):
    id: int

class BaseUser(BaseModel):
    id: int
    username: str
    email: str
    phone: str
    address: str
    isAdmin: bool

class User(BaseUser):
    password: str

class OptionalUser(User):
    id: SkipJsonSchema[None] = None
    username: SkipJsonSchema[None] = None
    email: str | None = None
    password: str | None = None
    phone: str | None = None
    address: str | None = None
    isAdmin: SkipJsonSchema[None] = None

class PurchaseRecord(BaseModel):
    id: int
    success: bool
    fail_prod: int | None = None
    products: list[int]
    message: str

# TODO: Replace with database

def product_generator(n):
    for index in range(1, n+1):
        yield {
            "id": index,
            "title": f"Item {index}",
            "description": f"Description of item {index}",
            "price": round(index * random.random() * 10,2),
            "stock": index * random.randrange(1,100),
            "image": 'https://via.placeholder.com/150'
        }

products = list(product_generator(40))

products.append({
    "id": 41,
    "title": "None",
    "description": "Out of stock item",
    "price": 100.00,
    "stock": 0,
    "image": 'https://via.placeholder.com/150'
})

products.append({
    "id": 42,
    "title": "One",
    "description": "One in stock item",
    "price": 100.00,
    "stock": 1,
    "image": 'https://via.placeholder.com/150'
})

users = [
    {
        "id": 1,
        "username": "tester",
        "email": "test@example.com",
        "password": "password123",
        "phone": "1234567890",
        "address": "123, Test Street",
        "isAdmin": True
    },
    {
        "id": 2,
        "username": "testee",
        "email": "testee@example.com",
        "password": "password321",
        "phone": "1234567890",
        "address": "123, Testee Street",
        "isAdmin": False
    }
]

def get_user(username):
    for user in users:
        if user['username'] == username:
            return deepcopy(user)
    return None

def get_product_by_id(id):
    for product in products:
        if product['id'] == id:
            return deepcopy(product)
    return None


def token_to_user(token: str) -> User|None:
    split = token.split(':')
    if len(split) != 2:
      return None
    user_dict = get_user(split[0])
    if user_dict is not None and user_dict["password"] == split[1]:
        return User(**user_dict)
    return None


def get_current_user(token: Annotated[str|None, Depends(oauth2_scheme)]) -> User|None:
    if token == None: # Anonymous authentication
        return None
    user = token_to_user(token)
    if user != None:
        return user
    raise HTTPException(status_code=401, detail="Invalid Token")

def append_product(product: ProductBase):
    product_dict = dict(product)
    product_dict["id"] = len(products)+1
    products.append(product_dict)
    return Product(**product_dict)

@app.get("/")
async def root(user: Annotated[User|None, Depends(get_current_user)]):
    if not user:
        return {"message": "Hello World"}
    return {"message": f"Hello {user.username}"}


# Return a token for a given (user, pass)
@app.post("/token")
async def login(form_data: Annotated[OAuth2PasswordRequestForm, Depends()]):
    user_dict = get_user(form_data.username)
    if not user_dict:
        raise HTTPException(status_code=401, detail="Invalid credentials")
    user = User(**user_dict)
    if not form_data.password == user.password:
        raise HTTPException(status_code=401, detail="Invalid credentials")

    return {"access_token": f"{user.username}:{user.password}", "token_type": "bearer"}


# GET /products
@app.get("/products")
async def get_products(user: Annotated[User|None, Depends(get_current_user)]) -> list[int]:
    if user and user.isAdmin:
        return [x['id'] for x in products]

    # Return only products with stock
    return [x['id'] for x in products if x['stock'] > 0]


# POST /products
@app.post("/product")
async def create_product(user: Annotated[User|None, Depends(get_current_user)], product: ProductBase) -> Product:
    if not user:
        raise HTTPException(status_code=401, detail="Invalid credentials")
    if not user.isAdmin:
        raise HTTPException(status_code=403, detail="Invalid credentials")
    return append_product(product)

# GET /products/{id}
@app.get("/product/{id}")
async def get_product(user: Annotated[User|None, Depends(get_current_user)], id: int) -> Product:
    product = get_product_by_id(id)
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
async def update_product(id: int, product: Product) -> Product:
    for p in products:
        if p["id"] == id:
            p["title"] = product.title
            p["description"] = product.description
            p["price"] = product.price
            p["stock"] = product.stock
            p["image"] = product.image
            return Product(**p)
    raise HTTPException(status_code=404, detail="Product not found")

# DELETE /products/{id}
@app.delete("/product/{id}")
async def delete_product(id: int):
    for index, product in enumerate(products):
        if product["id"] == id:
            products.pop(index)
            return {"Data": "Deleted"}
    raise HTTPException(status_code=404, detail="Product not found")

# GET /user/{id} (optional)

# PATCH /user/{id}
@app.patch("/user/{id}")
async def update_user(id: int, user: Annotated[User|None, Depends(get_current_user)], changes: OptionalUser) -> BaseUser:
    if not user:
        raise HTTPException(status_code=401, detail="Invalid credentials")
    if user.id != id and not user.isAdmin:
        raise HTTPException(status_code=403, detail="Invalid credentials")
    for u in users:
        if u["id"] == id:
            for key, value in changes.model_dump().items():
                if value:
                    u[key] = value
            return BaseUser(**u)
    raise HTTPException(status_code=404, detail="User not found")

# POST /user/{id} (optional)
# DELETE /user/{id} (optional)

# GET /user/me
@app.get("/user/me")
async def read_users_me(user: Annotated[User|None, Depends(get_current_user)]) -> BaseUser:
    if not user:
        raise HTTPException(status_code=401, detail="Invalid credentials")
    return user

# GET /user/me
@app.patch("/user/me")
async def update_users_me(user: Annotated[User|None, Depends(get_current_user)], changes: OptionalUser) -> BaseUser:
    if not user:
        raise HTTPException(status_code=401, detail="Invalid credentials")
    return await update_user(user.id, user, changes)

# POST /purchase
@app.post("/purchase")
async def purchase(user: Annotated[User|None, Depends(get_current_user)], product_ids: list[int]) -> PurchaseRecord:
    if not user:
        raise HTTPException(status_code=401, detail="Invalid credentials")
    if not product_ids:
        raise HTTPException(status_code=400, detail="No products in cart")

    # FIXME: Track stock changes
    total = 0
    for id in product_ids:
        product = get_product_by_id(id)
        if not product:
            return PurchaseRecord(
                id = 1,
                fail_prod = id,
                success = False,
                products = product_ids,
                message = "Transaction failed: Product not found"
            )
        if product["stock"] == 0:
            return PurchaseRecord(
                id = 1,
                fail_prod = id,
                success = False,
                products = product_ids,
                message = "Transaction failed: Product out of stock"
            )
        total += product["price"]

    for id in product_ids:
        for product in products:
            if product["id"] == id:
                product["stock"] -= 1
                continue

    return PurchaseRecord(
        id = 1,
        success = True,
        products = product_ids,
        message = f"Transaction successful. Total: {round(total,2)}"
    )
