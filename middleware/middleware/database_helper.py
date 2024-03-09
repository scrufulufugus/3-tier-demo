import argparse
import random
import os
from .database import Database
from .models import *

def product_generator(n):
    for index in range(1, n+1):
        yield {
            "title": f"Item {index}",
            "description": f"Description of item {index}",
            "price": round(index * random.random() * 10,2),
            "stock": index * random.randrange(1,100),
            "image": 'https://via.placeholder.com/150'
        }

products = list(product_generator(40))

products.append({
    "title": "None",
    "description": "Out of stock item",
    "price": 100.00,
    "stock": 0,
    "image": 'https://via.placeholder.com/150'
})

products.append({
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

def db_helper():
    parser = argparse.ArgumentParser(description="Middleware DB init")
    parser.add_argument("filename", type=argparse.FileType('w'), default="middleware.db", help="Filename to write to, defaults to middleware.db")
    args = parser.parse_args()

    try:
        os.remove(args.filename.name)
    except FileNotFoundError:
        pass

    with Database(args.filename.name) as db:
        for user in users:
            db.append_user(User(**user))
        for product in products:
            db.append_product(ProductBase(**product))

if __name__ == '__main__':
    db_helper()
