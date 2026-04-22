import psycopg2
from psycopg2.extras import RealDictCursor
import os

# Docker içinde DB_HOST='db', lokalde 'localhost'
DB_HOST = os.getenv("DB_HOST", "localhost")

def get_db_connection():
    conn = psycopg2.connect(
        host=DB_HOST,
        database="pursoot_db",
        user="yapdilse",
        password="12345"
    )
    return conn

# Veriyi JSON (Dictionary) olarak çekmek için yardımcı fonksiyon
def query_db(query, args=(), one=False):
    conn = get_db_connection()
    cur = conn.cursor(cursor_factory=RealDictCursor)
    cur.execute(query, args)
    rv = cur.fetchall()
    conn.commit()
    cur.close()
    conn.close()
    return (rv[0] if rv else None) if one else rv