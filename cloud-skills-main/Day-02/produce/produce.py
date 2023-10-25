from flask import Flask, request
from kafka import KafkaProducer
from json import dumps
import ssl

sasl_mechanism = 'SCRAM-SHA-256'
security_protocol = 'SASL_PLAINTEXT'

app = Flask(__name__)

my_producer = KafkaProducer(bootstrap_servers = ['kafka'],
                         sasl_plain_username = "user1",
                         sasl_plain_password = "wgOzuXKZXq",
                         security_protocol = security_protocol,
                         sasl_mechanism = sasl_mechanism,
                         value_serializer = lambda x:dumps(x).encode('utf-8'))


@app.route("/download", methods=["POST"])
def download_url():
    data = request.get_json()
    link = data["link"]
    
    my_producer.send('data', value=link)
    return {}

if __name__ == "__main__":
    app.run(debug=True, host="0.0.0.0")

