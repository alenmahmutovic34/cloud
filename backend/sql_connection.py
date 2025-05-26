import datetime
import mysql.connector
import os

__cnx = None

def get_sql_connection():
    print("Opening mysql connection")
    global __cnx
    
    if __cnx is None:
        # Čitanje environment varijabli ili korištenje default vrijednosti
        db_host = os.environ.get('DB_HOST', 'db')
        db_user = os.environ.get('DB_USER', 'root')
        db_password = os.environ.get('DB_PASSWORD', 'Test@123')
        db_name = os.environ.get('DB_NAME', 'grocery_store')
        
        # Dodaj retry logiku za stabilnije povezivanje
        retry_count = 0
        max_retries = 5
        
        while retry_count < max_retries:
            try:
                __cnx = mysql.connector.connect(
                    host=db_host,
                    user=db_user,
                    password=db_password,
                    database=db_name,
                    auth_plugin='mysql_native_password'
                )
                break
            except mysql.connector.Error as err:
                print(f"Error connecting to MySQL: {err}")
                retry_count += 1
                if retry_count >= max_retries:
                    raise
                print(f"Retrying connection ({retry_count}/{max_retries})...")
                import time
                time.sleep(3)
    
    return __cnx
