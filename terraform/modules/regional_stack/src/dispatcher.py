import os, json
import boto3

ecs = boto3.client("ecs")
REGION = os.environ.get("AWS_REGION", "unknown")

CLUSTER_ARN = os.environ["ECS_CLUSTER_ARN"]
TASK_DEF_ARN = os.environ["ECS_TASK_DEF_ARN"]
SUBNETS = os.environ["ECS_SUBNETS"].split(",")
SG = os.environ["ECS_SG"]

def handler(event, context):
    ecs.run_task(
        cluster=CLUSTER_ARN,
        taskDefinition=TASK_DEF_ARN,
        launchType="FARGATE",
        networkConfiguration={
            "awsvpcConfiguration": {
                "subnets": SUBNETS,
                "securityGroups": [SG],
                "assignPublicIp": "ENABLED"
            }
        }
    )

    return {
        "statusCode": 200,
        "headers": {"content-type": "application/json"},
        "body": json.dumps({"region": REGION, "started": True})
    }
