import requests
import random
import os
from pprint import pprint
from time import sleep
from .config import settings
from .database import Database
from .models import *

image_endpoint = "https://picsum.photos/600/400"
text_endpoint = "https://random-data-api.com/api/v3/projects/cc54d00a-8050-4f34-85ac-082cf96b535f"

def product_generator(n):
    response = {}
    for index in range(1, n+1):
        print("Generating product", index, "of", n, "products.")
        image_response = requests.get(image_endpoint).url
        if index - 1 % 10 == 0:
            try:
                response = requests.get(text_endpoint).json()
            except requests.exceptions.JSONDecodeError:
                print("Rate limited, waiting for 5 seconds")
                sleep(5)
                continue
        yield {
            "title": response["items"][index % 10]['title'],
            "description": response["items"][index % 10]['description'],
            "price": index * random.randrange(1,100) * 100 + random.choice([0, 50, 99, 69]),
            "stock": index * random.randrange(1,100),
            "image": image_response
        }

users = [
    {
        "username": "admin",
        "email": "admin@example.com",
        "password": "password123",
        "phone": "1234567890",
        "address": "123, Tester Street",
        "isAdmin": True
    },
    {
        "username": "user1",
        "email": "user@example.org",
        "password": "password321",
        "phone": "9876543210",
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
            pprint(user)
            db.append_user(BaseUser(**user))
        for product in product_generator(40):
            pprint(product)
            db.append_product(BaseProduct(**product))

if __name__ == '__main__':
    db_helper()
