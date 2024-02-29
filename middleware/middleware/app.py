from typing import Annotated

from fastapi import FastAPI, HTTPException, Depends
from fastapi.security import OAuth2PasswordBearer, OAuth2PasswordRequestForm
from pydantic import BaseModel

app = FastAPI()

oauth2_scheme = OAuth2PasswordBearer(tokenUrl="token", auto_error=False)

# Data Models
class Product(BaseModel):
    id: int
    title: str
    description: str
    price: float
    stock: int | None = None
    image: str

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

def get_current_user(token: Annotated[str|None, Depends(oauth2_scheme)]) -> User|None:
    if token == None: # Anonymous authentication
        return None
    user_dict = get_user(token)
    if user_dict != None:
        return User(**user_dict)
    raise HTTPException(status_code=401, detail="Invalid Token")


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

    return {"access_token": user.username, "token_type": "bearer"}


# GET /products
@app.get("/products")
async def get_products():
    return products

# POST /products
@app.post("/products")
async def create_product(product: Product):
    products.append(product.dict())
    return products[-1]

# GET /products/{id}
@app.get("/products/{id}")
async def get_product(id: int):
    for product in products:
        if product["id"] == id:
            return product
    raise HTTPException(status_code=404, detail="Product not found")

# POST /products/{id}
@app.post("/products/{id}")
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
@app.delete("/products/{id}")
async def delete_product(id: int):
    for index, product in enumerate(products):
        if product["id"] == id:
            products.pop(index)
            return {"Data": "Deleted"}
    raise HTTPException(status_code=404, detail="Product not found")

# POST /login
@app.post("/login")
async def login(username: str, password: str):
    for user in users:
        if user['username'] == username and user['password'] == password:
            return user
    raise HTTPException(status_code=401, detail="Invalid Credentials")

# GET /users/{id} (optional)
# POST /users/{id} (optional)
# DELETE /users/{id} (optional)
# PUT /buy
