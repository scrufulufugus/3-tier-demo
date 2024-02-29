import uvicorn
from typing import Annotated

from fastapi import FastAPI, HTTPException, Depends
from fastapi.security import OAuth2PasswordBearer
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
    User(id=1, username="tester", email="test@example.com", password="password123", phone=1234567890, address="123, Test Street", isAdmin=True),
    User(id=2, username="testee", email="testee@example.com", password="password321", phone=1234567890, address="123, Testee Street", isAdmin=False),
]

def get_current_user(token: Annotated[str, Depends(oauth2_scheme)]):
    for user in users:
        if user.username == token:
            return user
    raise HTTPException(status_code=401, detail="Invalid Token")


@app.get("/")
async def root(User: Annotated[User, Depends(get_current_user)]):
    if user != None:
        return {"message": f"Hello {user.username}"}
    else:
        return {"message": "Hello World"}

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
        if user.username == username and user.password == password:
            return user
    raise HTTPException(status_code=401, detail="Invalid Credentials")

# GET /users/{id} (optional)
# POST /users/{id} (optional)
# DELETE /users/{id} (optional)
# PUT /buy

def main():
    uvicorn.run("middleware.app:app", host="0.0.0.0", port=8000, reload=True)

if __name__ == '__main__':
    main()
