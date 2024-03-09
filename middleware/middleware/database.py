from sqlitedict import SqliteDict
from .models import *

class Database:
    def __init__(self, db_path):
        # TODO: Disable autocommit
        self.db = {}
        for table in ('users', 'products', 'records'):
            self.db[table] = SqliteDict(filename=db_path, tablename=table, autocommit=True)

    def __enter__(self):
        for table in self.db:
            self.db[table].__enter__()
        return self

    def __exit__(self, *exc_info):
        self.close()

    @property
    def products(self):
        return self.db['products']

    @property
    def users(self):
        return self.db['users']

    @property
    def records(self):
        return self.db['records']

    def get_user_by_name(self, username):
        for user in self.db['users'].values():
            if user['username'] == username:
                return User(**user)
        return None

    def _append(self, table: str, data):
        last_id = 0
        for key in self.db[table].keys():
            if int(key) > last_id:
                last_id = int(key)
        data["id"] = last_id+1
        self.db[table][data["id"]] = data
        return data

    def append_user(self, user: User):
        user_dict = dict(user)
        user_dict = self._append('users', user_dict)
        return User(**user_dict)

    def append_product(self, product: ProductBase):
        product_dict = dict(product)
        product_dict = self._append('products', product_dict)
        return Product(**product_dict)

    def append_record(self, record: BaseRecord):
        record_dict = dict(record)
        record_dict = self._append('records', record_dict)
        return PurchaseRecord(**record_dict)

    def update_user(self, id: int, user: OptionalUser):
        current_user = self.db['users'][id]
        for key, value in dict(user).items():
            if value:
                current_user[key] = value
        self.db['users'][id] = current_user
        return User(**current_user)

    def update_product(self, product: Product):
        product_dict = dict(product)
        self.db['products'][product_dict["id"]] = product_dict
        return Product(**product_dict)

    def buy_product(self, id: int, amount: int = 1):
        product = self.db['products'][id]
        if product["stock"] < amount:
            return False
        product["stock"] -= amount
        self.db['products'][id] = product
        return True

    def close(self):
        for table in self.db:
            self.db[table].close()
