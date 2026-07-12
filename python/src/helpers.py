from sqlalchemy import create_engine
import pandas as pd
import os
from dotenv import load_dotenv

# Database connection based on credentials stored in the .env file
load_dotenv()

DATABASE_URL = f"postgresql://{os.getenv('DB_USER')}:{os.getenv('DB_PASSWORD')}@{os.getenv('DB_HOST')}:{os.getenv('DB_PORT')}/{os.getenv('DB_NAME')}"
engine = create_engine(DATABASE_URL)

# Data load function
def load_view(view_name: str) -> pd.DataFrame:
    query = f"SELECT * FROM {view_name}"
    return pd.read_sql(query, engine)

# Function for basic overview for each view loaded from SQL
def basic_overview(df, name: str):
    print(f"\n==={name}===")
    print(df.shape)
    print(df.head())
    df.info()
    print(df.describe())
