from pydantic import BaseModel
from pydantic.json_schema import SkipJsonSchema

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

class BaseRecord(BaseModel):
    success: bool
    fail_at: int | None = None
    products: list[int]
    message: str
    total: float

class PurchaseRecord(BaseRecord):
    id: int
