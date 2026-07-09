
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


def get_rfm_segment(row: pd.Series) -> str:
    """
    Exhaustive RFM segmentation logic for Olist.
    Guarantees 100% coverage with NO unclassified rows.
    """
    if pd.isna(row['R_Score']) or pd.isna(row['F_Score']) or pd.isna(row['M_Score']):
        return 'Unknown / Missing Data'

    r = int(row['R_Score'])
    f = int(row['F_Score'])
    m = int(row['M_Score'])

    # =========================================================================
    # KATEGORIA A: POWER USERS (F_Score = 5, czyli 3 i więcej zamówień)
    # =========================================================================
    if f == 5:
        if r >= 4:
            return 'Champions'  # Kupują najczęściej, najwięcej i niedawno
        elif r == 3:
            return 'Loyal Customers'  # Stali, powracający klienci w zawieszeniu
        else:
            return 'At Risk Loyalists'  # Dawne filary przychodu, od dawna brak zakupu

    # =========================================================================
    # KATEGORIA B: REPEAT CUSTOMERS (F_Score = 3, czyli dokładnie 2 zamówienia)
    # =========================================================================
    elif f == 3:
        if r >= 4:
            return 'Promising Loyalists'  # Zrobili drugi zakup niedawno, rokują na Champions
        elif r == 3:
            return 'Need Attention'  # Kupili 2 razy, ale aktywność spada
        else:
            return 'About to Sleep'  # Kupili 2 razy, ale bardzo dawno temu

    # =========================================================================
    # KATEGORIA C: ONE-TIMERS (F_Score = 1, czyli 1 zamówienie - większość bazy!)
    # =========================================================================
    else:
        # 1. Świeże zakupy (R: 4 lub 5)
        if r >= 4:
            if m >= 4:
                return 'High-Value Newcomers'  # Kupili raz, niedawno, ale za wielką kasę
            else:
                return 'Recent One-Timers'  # Typowi nowi klienci z małym koszykiem

        # 2. Średni staż od zakupu (R: 3)
        elif r == 3:
            if m >= 4:
                return 'Potential Spenders'  # Jeden duży zakup jakiś czas temu
            else:
                return 'Average One-Timers'  # Przeciętny, jednorazowy klient

        # 3. Dawne zakupy / Uśpieni (R: 1 lub 2)
        else:
            if m >= 4:
                return "Can't Lose Them"  # Zostawili mnóstwo kasy, ale rok temu. Trzeba ich ratować!
            else:
                return 'Hibernating / Lost'  # Kupili raz, tanio, dawno temu. Najmniej wartościowi.


def assign_customer_segments(df: pd.DataFrame) -> pd.DataFrame:
    df_copy = df.copy()
    df_copy['Segment'] = df_copy.apply(get_rfm_segment, axis=1)
    return df_copy