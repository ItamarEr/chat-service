import json
import boto3
import os
import time
import uuid

# Init DynamoDB client
dynamodb = boto3.resource("dynamodb")
table = dynamodb.Table(os.getenv("DYNAMODB_TABLE"))

def lambda_handler(event, context):
    """
    Triggered by SQS. Processes each message and stores it in DynamoDB.
    """

    for record in event["Records"]:
        body = json.loads(record["body"])

        item = {
            "id": body.get("id", str(uuid.uuid4())),
            "user": body.get("user", "unknown"),
            "text": body.get("text", ""),
            "timestamp": body.get("timestamp", int(time.time()))
        }

        table.put_item(Item=item)

    return {"status": "ok", "processed": len(event["Records"])}
