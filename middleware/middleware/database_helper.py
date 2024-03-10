import argparse
import random
import os
from .config import settings
from .database import Database
from .models import *

def product_generator(n):
    for index in range(1, n+1):
        yield {
            "title": f"Item {index}",
            "description": f"Description of item {index}",
            "price": index * random.randrange(1,100) * 100 + random.choice([0, 50, 99, 69]),
            "stock": index * random.randrange(1,100),
            "image": 'https://via.placeholder.com/150'
        }

products = list(product_generator(40))

products.append({
    "title": "None",
    "description": "Out of stock item",
    "price": 10000,
    "stock": 0,
    "image": 'https://via.placeholder.com/150'
})

products.append({
    "title": "One",
    "description": "One in stock item",
    "price": 10000,
    "stock": 1,
    "image": 'https://via.placeholder.com/150'
})

users = [
    {
        "username": "tester",
        "email": "test@example.com",
        "password": "password123",
        "phone": "1234567890",
        "address": "123, Test Street",
        "isAdmin": True
    },
    {
        "username": "testee",
        "email": "testee@example.com",
        "password": "password321",
        "phone": "1234567890",
        "address": "123, Testee Street",
        "isAdmin": False
    }
]

def db_helper():
    try:
        os.remove(settings.database)
    except FileNotFoundError:
        pass

    with Database(settings.database) as db:
        for user in users:
            db.append_user(BaseUser(**user))
        for product in products:
            db.append_product(BaseProduct(**product))

if __name__ == '__main__':
    db_helper()
