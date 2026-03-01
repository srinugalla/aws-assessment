import os, json, time, uuid
import boto3

ddb = boto3.resource("dynamodb")
sns = boto3.client("sns")

TABLE = os.environ["DDB_TABLE"]
TOPIC_ARN = os.environ["SNS_TOPIC_ARN"]
EMAIL = os.environ["EMAIL"]
REPO = os.environ["REPO"]
REGION = os.environ.get("AWS_REGION", "unknown")

def handler(event, context):
    # log into dynamodb
    item = {
        "id": str(uuid.uuid4()),
        "ts": int(time.time()),
        "path": (event.get("rawPath") or event.get("path") or "/greet"),
        "region": REGION,
    }
    ddb.Table(TABLE).put_item(Item=item)

    msg = {
        "email": EMAIL,
        "source": "Lambda",
        "region": REGION,
        "repo": REPO
    }
    sns.publish(TopicArn=TOPIC_ARN, Message=json.dumps(msg))

    return {
        "statusCode": 200,
        "headers": {"content-type": "application/json"},
        "body": json.dumps({"region": REGION})
    }
