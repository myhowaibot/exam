from flask import Flask, request, send_file
from db import connect_db
import urllib.request

app = Flask(__name__)

# DB
db = connect_db("my_database")
cursor = db.cursor()

@app.route("/users", methods=["POST"])
def add_user():
    data = request.get_json()

    username = data["username"]
    email = data["email"]
    avatar = data["avatar"]

    try:
        cursor.execute("CREATE TABLE emp (ID INT AUTO_INCREMENT, username VARCHAR(255), email VARCHAR(255), avatar TEXT, PRIMARY KEY (ID))")
    except:
        pass
    cursor.execute(f"INSERT INTO emp (username, email, avatar) VALUES ('{username}', '{email}', '{avatar}')")
    db.commit()

    cursor.execute(f"SELECT ID FROM emp WHERE username = '{username}'")
    user_id = cursor.fetchall()[0][0]

    urllib.request.urlretrieve(f"{avatar}", f"avatars/{user_id}")
    return {"user_id": user_id}

@app.route("/users/<user_id>", methods=["GET"])
def get_usr(user_id):
    cursor.execute(f"SELECT username, email FROM emp WHERE ID = '{user_id}'")
    username, email = cursor.fetchall()[0]

    return {"username": username, "email": email}

@app.route("/avatar/<user_id>")
def get_avatar(user_id):
   filepath = f"./avatars/{user_id}"
   return send_file(filepath, mimetype='image/gif')

if __name__ == "__main__":
    app.run(debug=True, host="0.0.0.0")


    
