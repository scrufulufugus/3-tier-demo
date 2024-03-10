from pydantic import BaseModel
from pydantic.json_schema import SkipJsonSchema

class BaseProduct(BaseModel):
    title: str
    description: str
    price: int
    stock: int
    image: str

class Product(BaseProduct):
    prod_id: int

class ProductEdit(BaseModel):
    title: str | None = None
    description: str | None = None
    price: int | None = None
    stock: int | None = None
    image: str | None = None

class BaseUserNoPass(BaseModel):
    username: str
    email: str
    phone: str
    address: str
    isAdmin: bool

class BaseUser(BaseUserNoPass):
    password: str

class UserNoPass(BaseUserNoPass):
    user_id: int

class User(UserNoPass, BaseUser):
  pass

class UserEdit(BaseModel):
    email: str | None = None
    password: str | None = None
    phone: str | None = None
    address: str | None = None

class BaseTransaction(BaseModel):
    user_id: int
    prod_id: int
    count: int = 1

class Transaction(BaseTransaction):
    trans_id: int
    total: int

class PurchaseRecord(BaseModel):
    success: bool
    fail_at: int | None = None
    products: list[int]
    message: str
    total: int
