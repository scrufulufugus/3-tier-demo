from typing import Annotated
from pydantic import (
    AnyHttpUrl,
    BaseModel,
    EmailStr,
    NonNegativeInt,
    PositiveInt,
    StringConstraints
)

ProductName = Annotated[str, StringConstraints(min_length=1, max_length=40)]
ProductDescription = Annotated[str, StringConstraints(min_length=1, max_length=200)]
UserName = Annotated[str, StringConstraints(pattern=r'^\w{3,20}$')]
PhoneNumber = Annotated[str, StringConstraints(pattern=r'^(\+\d{2})?\d{10}$')]
Password = Annotated[str, StringConstraints(min_length=6, max_length=40)]

class BaseProduct(BaseModel):
    title: ProductName
    description: ProductDescription
    price: PositiveInt
    stock: NonNegativeInt
    image: AnyHttpUrl

class Product(BaseProduct):
    prod_id: PositiveInt

class ProductEdit(BaseModel):
    title: ProductName | None = None
    description: ProductDescription | None = None
    price: PositiveInt | None = None
    stock: NonNegativeInt | None = None
    image: AnyHttpUrl | None = None

class BaseUserNoPass(BaseModel):
    username: UserName
    email: EmailStr
    phone: PhoneNumber
    address: str
    isAdmin: bool

class BaseUser(BaseUserNoPass):
    password: Password

class UserNoPass(BaseUserNoPass):
    user_id: PositiveInt

class User(UserNoPass, BaseUser):
    pass

class UserEdit(BaseModel):
    email: EmailStr | None = None
    password: Password | None = None
    phone: PhoneNumber | None = None
    address: str | None = None

class BaseTransaction(BaseModel):
    user_id: PositiveInt
    prod_id: PositiveInt
    count: PositiveInt = 1

class Transaction(BaseTransaction):
    trans_id: PositiveInt
    total: int

class PurchaseRecord(BaseModel):
    success: bool
    fail_at: PositiveInt | None = None
    products: list[PositiveInt]
    message: str
    total: int
