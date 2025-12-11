import os
import json
import time
import uuid
from typing import List, Optional
from fastapi import FastAPI, HTTPException
from pydantic import BaseModel
import boto3

# Environment variables
SQS_URL = os.getenv("SQS_URL")
DYNAMODB_TABLE = os.getenv("DYNAMODB_TABLE", "chat-service-messages")
AWS_REGION = os.getenv("AWS_REGION", "eu-west-1")

sqs = boto3.client("sqs", region_name=AWS_REGION)
dynamodb = boto3.resource("dynamodb", region_name=AWS_REGION)

app = FastAPI(title="Chat Service")

class MessageIn(BaseModel):
    user: Optional[str] = "anonymous"
    text: str

class MessageOut(BaseModel):
    id: str
    user: str
    text: str
    timestamp: int

@app.get("/")
async def root():
    return {"status": "ok", "service": "chat-api"}

# POST -> SQS
@app.post("/messages", status_code=201)
async def create_message(msg: MessageIn):
    if not SQS_URL:
        raise HTTPException(status_code=500, detail="SQS_URL not configured")

    message = {
        "id": str(uuid.uuid4()),
        "user": msg.user,
        "text": msg.text,
        "timestamp": int(time.time())
    }

    try:
        sqs.send_message(
            QueueUrl=SQS_URL,
            MessageBody=json.dumps(message)
        )
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))

    return {"message_id": message["id"], "status": "queued"}

# GET -> DynamoDB
@app.get("/messages", response_model=List[MessageOut])
async def get_messages(limit: int = 50):
    table = dynamodb.Table(DYNAMODB_TABLE)
    resp = table.scan(Limit=limit)
    items = resp.get("Items", [])
    items_sorted = sorted(items, key=lambda x: x["timestamp"], reverse=True)
    return items_sorted[:limit]
