from sqlitedict import SqliteDict
from .models import *

# TODO: Temp Dependencies
import random
from copy import deepcopy

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

records = []

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

def append_product(product: ProductBase):
    product_dict = dict(product)
    product_dict["id"] = products[-1]["id"]+1
    products.append(product_dict)
    return Product(**product_dict)

def append_record(record: BaseRecord):
    record_dict = dict(record)
    record_dict["id"] = len(records)+1
    records.append(record_dict)
    return PurchaseRecord(**record_dict)
