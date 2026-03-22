from sqlalchemy import create_engine
from config.settings import DB_CONFIG
from config.log_config import *
import pandas as pd

CSV_TO_TABLE = {
    "users.csv": "stg.users_raw",
    "products.csv": "stg.products_raw",
    "orders.csv": "stg.orders_raw",
    "order_items.csv": "stg.order_items_raw",
    "reviews.csv": "stg.reviews_raw",
    "events.csv": "stg.events_raw",
}

def load_to_stg(csv_path: str, table_name: str, conn):
    logger.info(f"Loading {csv_path} to {table_name}")
    df = pd.read_csv(csv_path)
    try:
        df.to_sql(name=table_name.split('.')[1],
                schema=table_name.split('.')[0],
                con=conn,
                index=False,
                if_exists='replace')
        logger.info(f"Inserted {len(df)} rows into {table_name}")
    except Exception as e:
        logger.error(f"Error inserted rows into {table_name}")
        logger.error(f"{e}")

def main():
    # Подключение к БД
    engine = create_engine(
        f"postgresql+psycopg2://{DB_CONFIG['user']}:{DB_CONFIG['password']}"
        f"@{DB_CONFIG['host']}:{DB_CONFIG['port']}/{DB_CONFIG['dbname']}",
        pool_pre_ping=True)
    
    # Загрузка данных из csv в staging слой БД
    try:
        # транзакци с автокоммитом
        with engine.begin() as conn:
            logger.info("Connection successful!")
            for csv_file, table in CSV_TO_TABLE.items():
                load_to_stg(f"ecommerce_dataset/{csv_file}", table, conn)
    except Exception as e:
        logger.error(f"ERROR: {e}")

    logger.info("All CSV files loaded into staging")
    engine.dispose()

main()