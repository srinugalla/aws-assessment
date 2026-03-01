import os
import sys
import time
import requests
import concurrent.futures
import boto3

PRIMARY = os.environ["API_URL_PRIMARY"]
SECONDARY = os.environ["API_URL_SECONDARY"]
CLIENT_ID = os.environ["COGNITO_CLIENT_ID"]
USERNAME = os.environ["COGNITO_USERNAME"]
PASSWORD = os.environ["COGNITO_PASSWORD"]

def get_token():
    client = boto3.client("cognito-idp", region_name="us-east-1")
    resp = client.initiate_auth(
        ClientId=CLIENT_ID,
        AuthFlow="USER_PASSWORD_AUTH",
        AuthParameters={
            "USERNAME": USERNAME,
            "PASSWORD": PASSWORD,
        },
    )
    return resp["AuthenticationResult"]["IdToken"]

def call_endpoint(base_url, token):
    headers = {"Authorization": f"Bearer {token}"}
    r1 = requests.get(f"{base_url}/greet", headers=headers)
    r1.raise_for_status()
    r2 = requests.post(f"{base_url}/dispatch", headers=headers)
    r2.raise_for_status()
    return r1.json(), r2.json()

def test_region(base_url, expected_region, token):
    start = time.time()
    greet, dispatch = call_endpoint(base_url, token)
    duration = time.time() - start

    assert greet["region"] == expected_region
    assert dispatch["region"] == expected_region

    print(f"[OK] {expected_region} in {duration:.3f}s")

def main():
    token = get_token()

    with concurrent.futures.ThreadPoolExecutor() as executor:
        futures = [
            executor.submit(test_region, PRIMARY, "us-east-1", token),
            executor.submit(test_region, SECONDARY, "eu-west-1", token),
        ]
        for f in futures:
            f.result()

    print("All tests passed.")
    sys.exit(0)

if __name__ == "__main__":
    main()