from flask import Flask, render_template, request, redirect, url_for
import mysql.connector
import re

app = Flask(__name__)

@app.route('/register', methods=['POST', 'GET'])
def register():
    mesage = ''
    if request.method == 'POST' and 'name' in request.form and 'password' in request.form and 'email' in request.form :
        userName = request.form['name']
        password = request.form['password']
        email = request.form['email']
        cnx = mysql.connector.connect(user='admin', host='192.168.1.108', password='Skills53', port='3306', database='dataset')
        cursor = cnx.cursor()
        cursor.execute('SELECT * FROM tbl_usr WHERE name = %s', (userName,))
        account = cursor.fetchone()
        if account:
            mesage = 'Account already exists !'
        elif not re.match(r'[^@]+@[^@]+\.[^@]+', email):
            mesage = 'Invalid email address !'
        elif not userName or not password or not email:
            mesage = 'Please fill out the form !'
        else:
            cursor.execute('INSERT INTO tbl_usr VALUES (%s, %s, %s)', (userName, email, password))
            mesage = 'You have successfully registered !'
            cnx.commit()
            cursor.close()
            cnx.close()
    elif request.method == 'POST':
        mesage = 'Please fill out the form !'
    return render_template('register.html', mesage = mesage)

if __name__ == "__main__":
    app.run(host="0.0.0.0", debug=True)

