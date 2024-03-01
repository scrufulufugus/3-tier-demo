from typing import Annotated

from fastapi import FastAPI, HTTPException, Depends
from fastapi.security import OAuth2PasswordBearer, OAuth2PasswordRequestForm
from pydantic import BaseModel

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

class ProductList(BaseModel):
    products: list[Product]

class User(BaseModel):
    id: int
    username: str
    email: str
    password: str
    phone: int
    address: str
    isAdmin: bool | None = None

# TODO: Replace with database
products = [
    {
        "id": 1,
        "title": "Phone",
        "description": "New phone",
        "price": 1000,
        "stock": 10,
        "image": "phone.jpg"
    },
    {
        "id": 2,
        "title": "Laptop",
        "description": "New laptop",
        "price": 2000,
        "stock": 20,
        "image": "laptop.jpg"
    }
]

users = [
    {
        "id": 1,
        "username": "tester",
        "email": "test@example.com",
        "password": "password123",
        "phone": 1234567890,
        "address": "123, Test Street",
        "isAdmin": True
    },
    {
        "id": 2,
        "username": "testee",
        "email": "testee@example.com",
        "password": "password321",
        "phone": 1234567890,
        "address": "123, Testee Street",
        "isAdmin": False
    }
]

def get_user(username):
    for user in users:
        if user['username'] == username:
            return user
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
        raise HTTPException(status_code=400, detail="Invalid credentials")
    user = User(**user_dict)
    if not form_data.password == user.password:
        raise HTTPException(status_code=400, detail="Invalid credentials")

    return {"access_token": f"{user.username}:{user.password}", "token_type": "bearer"}


# GET /products
@app.get("/products")
async def get_products(user: Annotated[User|None, Depends(get_current_user)]):
    product_list = ProductList(products=[Product(**x) for x in products])
    if user and user.isAdmin:
        return product_list

    # Hide stock if not authenticated
    for p in product_list.products:
        p.stock = 0
    return product_list

# POST /products
@app.post("/product")
async def create_product(user: Annotated[User|None, Depends(get_current_user)], product: ProductBase):
    if not user:
        raise HTTPException(status_code=400, detail="Invalid credentials")
    if not user.isAdmin:
        raise HTTPException(status_code=400, detail="Invalid credentials")
    return append_product(product)

# GET /products/{id}
@app.get("/product/{id}")
async def get_product(id: int):
    for product in products:
        if product["id"] == id:
            return product
    raise HTTPException(status_code=404, detail="Product not found")

# POST /products/{id}
@app.post("/product/{id}")
async def update_product(id: int, product: Product):
    for p in products:
        if p["id"] == id:
            p["title"] = product.title
            p["description"] = product.description
            p["price"] = product.price
            p["stock"] = product.stock
            p["image"] = product.image
            return p
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
# POST /user/{id} (optional)
# DELETE /user/{id} (optional)
# PUT /buy
