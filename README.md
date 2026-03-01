---

# AWS Multi-Region Serverless Assessment

## Overview

This project implements a multi-region serverless architecture using Terraform across:

* **Primary:** `us-east-1`
* **Secondary:** `eu-west-1`

The system includes:

* Amazon API Gateway (HTTP API)
* AWS Lambda (Greeter + Dispatcher)
* Amazon Cognito (Authentication)
* Amazon DynamoDB (Logging)
* Amazon ECS Fargate (Task execution)
* Amazon SNS (Verification publishing)
* IAM least-privilege roles

Infrastructure is fully defined using Terraform.

---

## Architecture

### Flow

1. User authenticates via Cognito.
2. User calls:

   * `GET /greet`
   * `POST /dispatch`
3. `/greet`:

   * Logs request to DynamoDB
   * Publishes SNS verification message (source: Lambda)
4. `/dispatch`:

   * Triggers ECS Fargate task
   * ECS publishes SNS verification message (source: ECS)

Both regions operate independently but publish verification messages to the required SNS topic in **us-east-1**.

---

## Regions

| Region    | Purpose   |
| --------- | --------- |
| us-east-1 | Primary   |
| eu-west-1 | Secondary |

SNS publishes to:

```
arn:aws:sns:us-east-1:637226132752:Candidate-Verification-Topic
```

---

## SNS Payload Format

Lambda publishes:

```json
{
  "email": "srinu.galla@gmail.com",
  "source": "Lambda",
  "region": "us-east-1 or eu-west-1",
  "repo": "https://github.com/srinugalla/aws-assessment"
}
```

ECS publishes:

```json
{
  "email": "srinu.galla@gmail.com",
  "source": "ECS",
  "region": "us-east-1 or eu-west-1",
  "repo": "https://github.com/srinugalla/aws-assessment"
}
```

---

## Project Structure

```
terraform/
  main.tf
  providers.tf
  variables.tf
  terraform.tfvars
  modules/
    auth_cognito/
    regional_stack/

test/
  run_tests.py
  requirements.txt

.github/workflows/
  deploy.yml
```

---

## Terraform Usage

### Initialize

```bash
cd terraform
terraform init
```

### Validate

```bash
terraform fmt -recursive
terraform validate
```

### Plan

```bash
terraform plan
```

### Apply

```bash
terraform apply
```

### Destroy

```bash
terraform destroy
```

---

## Testing

The test script validates:

* Cognito authentication
* `/greet` returns correct region
* `/dispatch` triggers ECS
* Both regions respond correctly
* Latency measurement

### Run Tests

After `terraform apply`:

```bash
cd terraform
export COGNITO_CLIENT_ID=$(terraform output -raw cognito_user_pool_client_id)
export API_URL_PRIMARY=$(terraform output -raw api_base_url_primary)
export API_URL_SECONDARY=$(terraform output -raw api_base_url_secondary)
export COGNITO_USERNAME="srinu.galla@gmail.com"
export COGNITO_PASSWORD="<your-password>"

cd ../test
python3 -m venv .venv
source .venv/bin/activate
pip install -r requirements.txt
python run_tests.py
```

---

## CI/CD

GitHub Actions pipeline includes:

* Terraform fmt check
* Terraform validate
* Security scan (tfsec)
* Terraform plan
* Test execution placeholder

No AWS credentials are required in CI (per assessment requirement).

---

## Design Decisions

* Explicit SNS region (`us-east-1`) to meet verification requirement
* Separate regional stacks
* Environment-driven Lambda configuration
* IAM least privilege for ECS and Lambda
* Infrastructure as Code with modular Terraform
* Clean teardown supported (`terraform destroy`)

---

## Cleanup

All resources can be removed using:

```bash
terraform destroy
```

---

## Author

GitHub: [https://github.com/srinugalla](https://github.com/srinugalla)
Email: [srinu.galla@gmail.com](mailto:srinu.galla@gmail.com)
---