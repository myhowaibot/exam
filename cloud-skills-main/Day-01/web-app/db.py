import mysql.connector
import os
from dotenv import load_dotenv
load_dotenv()

def connect_db(db):
    mydb = mysql.connector.connect(
        host=os.getenv("host"),
        user=os.getenv("user"),
        password=os.getenv("password"),
        database=db
    )
    return mydb

    