
from sqlalchemy import create_engine
import pandas as pd
import os
from dotenv import load_dotenv

load_dotenv()

DATABASE_URL = f"postgresql://{os.getenv('DB_USER')}:{os.getenv('DB_PASSWORD')}@{os.getenv('DB_HOST')}:{os.getenv('DB_PORT')}/{os.getenv('DB_NAME')}"
engine = create_engine(DATABASE_URL)


def load_view(view_name: str) -> pd.DataFrame:
    query = f"SELECT * FROM {view_name}"
    return pd.read_sql(query, engine)

def basic_overview(df, name: str):
    print(f"\n==={name}===")
    print(df.shape)
    print(df.head())
    print(df.info())
    print(df.describe())

def assign_f_score(orders):
    if orders == 1:
        return 1  # Jednorazowy klient (najniższa ocena)
    elif orders == 2:
        return 3  # Klient powracający
    else:
        return 5  # Loyal/Power user (3 i więcej zamówień)