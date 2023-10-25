from flask import Flask
import redis

r = redis.Redis(host='172.20.0.32', port=6374, db=0)
data = r.get('skill53:index')

app = Flask(__name__)

@app.route('/')
def index():
    return data

if __name__ == '__main__':
    app.run(host='0.0.0.0', port=5000)