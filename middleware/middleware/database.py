from typing import Tuple
from sqlitedict import SqliteDict
from .models import *

class TransactionError(RuntimeError):
  """ Raised when a transaction fails """
  pass

class Database:
    def __init__(self, db_path):
        # TODO: Disable autocommit
        self.db = {}
        for table in ('users', 'products', 'transactions'):
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
    def transactions(self):
        return self.db['transactions']

    def get_user_by_name(self, username: str) -> User|None:
        for user_id, user in self.db['users'].items():
            if user['username'] == username:
                return User(**user, user_id=user_id)
        return None

    def _append(self, table: str, data: dict) -> Tuple[int, dict]:
        last_id = 0
        for key in self.db[table].keys():
            if int(key) > last_id:
                last_id = int(key)
        self.db[table][last_id+1] = data
        return last_id+1, data

    def append_user(self, user: BaseUser) -> User:
        append_dict = dict(user)
        user_id, user_dict = self._append('users', append_dict)
        return User(**user_dict, user_id=user_id)

    def append_product(self, product: BaseProduct) -> Product:
        append_dict = dict(product)
        prod_id, product_dict = self._append('products', append_dict)
        return Product(**product_dict, prod_id=prod_id)

    def append_transaction(self, trans: BaseTransaction) -> Transaction:
        append_dict = dict(trans)
        product = self.products[trans.prod_id]
        append_dict['total'] = product["price"] * trans.count
        trans_id, trans_dict = self._append('transactions', append_dict)
        return Transaction(**trans_dict, trans_id=trans_id)

    def update_user(self, user_id: int, edit: UserEdit) -> User:
        current_user = self.db['users'][user_id]
        for key, value in dict(edit).items():
            if value:
                current_user[key] = value
        self.db['users'][user_id] = current_user
        return User(**current_user, user_id=user_id)

    def update_product(self, prod_id: int, edit: ProductEdit) -> Product:
        current_product = self.db['products'][prod_id]
        for key, value in dict(edit).items():
            if value:
                current_product[key] = value
        self.db['products'][prod_id] = current_product
        return Product(**current_product, prod_id=prod_id)

    def purchase(self, user_id: int, prod_id: int, count: int) -> Transaction:
        product = self.products[prod_id]
        if product["stock"] < count:
            raise TransactionError("Insufficient stock")
        self.update_product(prod_id, ProductEdit(stock=product['stock']-count))
        trans = self.append_transaction(BaseTransaction(
            user_id=user_id,
            prod_id=prod_id,
            count = count
        ))
        return trans

    def revert_transaction(self, trans_id: int) -> Transaction:
        to_revert = self.transactions[trans_id]
        to_revert['count'] *= -1
        return self.append_transaction(BaseTransaction(**to_revert))

    def close(self):
        for table in self.db:
            self.db[table].close()
