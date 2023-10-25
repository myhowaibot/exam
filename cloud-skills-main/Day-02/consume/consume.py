from json import loads  
from kafka import KafkaConsumer 
from botocore.exceptions import ClientError
import boto3
import logging 
import os
import urllib.request
from dotenv import load_dotenv
load_dotenv()

sasl_mechanism = 'SCRAM-SHA-256'
security_protocol = 'SASL_PLAINTEXT'

my_consumer = KafkaConsumer(  
    'data',  
     bootstrap_servers = ['kafka'],  
     auto_offset_reset = 'earliest',  
     enable_auto_commit = True,  
     group_id = 'my-group',
     sasl_plain_username = "user1",
     sasl_plain_password = "wgOzuXKZXq",
     security_protocol = security_protocol,
     sasl_mechanism = sasl_mechanism,  
     value_deserializer = lambda x : loads(x.decode('utf-8'))  
     )

# Connecting to S3 Storage
logging.basicConfig(level=logging.INFO)

s3_resource = boto3.resource(
    's3',
    endpoint_url='https://jabe.s3.ir-thr-at1.arvanstorage.ir',
    aws_access_key_id=os.getenv("access_key"),
    aws_secret_access_key=os.getenv("secret_key")
)


count = 0

#Consuming messages in message-queue
for msg in my_consumer:
    urllib.request.urlretrieve(msg.value, f"avatars/{count}")
    try:
        bucket = s3_resource.Bucket('jabe')
        file_path = f'avatars/{count}'
        object_name = f'{count}'    
        with open(file_path, "rb") as file:
            bucket.put_object(
                ACL='private',
                Body=file,
                Key=object_name
            )
    except ClientError as e:
        logging.error(e)

    count += 1