import psycopg2
from sqlalchemy import create_engine
from config.settings import DB_CONFIG
from config.log_config import *

def db_connection():
    try:
        # пытаемся подключиться к базе данных
        engine = create_engine(f"postgresql+psycopg2://{DB_CONFIG['user']}:{DB_CONFIG['password']}"
                            f"@{DB_CONFIG['host']}:{DB_CONFIG['port']}/{DB_CONFIG['dbname']}",
                            pool_pre_ping=True
                            )
        logger.info('Correct connection to db')
        return engine
    except Exception as e:
        # в случае сбоя подключения будет выведено сообщение
        logger.error(f'Failed to connect to DB: {e}')