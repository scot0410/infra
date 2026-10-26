# Infra 
This repo contains the infra for the Lumina app. 

The following services are in use:

Loci Local Stack
- Amazon EventBridge 
- SQS
- AWS Lambda
- Dynamo DB

# Quickstart
1. Start local AWS services
```shell
docker-compose up
```
1. Run `./start.sh` to start localstack and init terraform plan.
2. Navigate to loci logs -> http://localhost:4500/console/aws

## Architecture

┌──────────────────────┐      Triggers      ┌───────────────────┐      Fetches Data      ┌──────────────────┐
│ Amazon EventBridge   │ ─────────────────> │ Producer Lambda   │ ─────────────────────> │   External API   │
│ (Serverless Cron)    │                    │ (Python/Boto3)    │                        └──────────────────┘
└──────────────────────┘                    └───────────────────┘
│
│ Pushes Messages
▼
┌──────────────────────┐   Auto-Invokes    ┌───────────────────┐
│   Consumer Lambda    │ <──────────────── │    Amazon SQS     │
│ (Saves to DynamoDB)  │                   │ (Serverless Queue)│
└──────────────────────┘                   └───────────────────┘
│
│ table.put_item()
▼
┌──────────────────────┐
│   Amazon DynamoDB    │
│ (NoSQL Cloud DB)     │
└──────────────────────┘

localstack status

curl http://localhost:4566/_localstack/health

# 1. Download the custom provider modules onto your laptop
cd terraform
terraform init

# 2. Review the dry-run resource generation map
terraform plan

# 3. Compile your Python loop and build out your ProductRecalls schema!
terraform apply -auto-approve

# 4. Check resources
`aws dynamodb list-tables`
`aws dynamodb describe-table --table-name product-recalls"`
`aws lambda list-functions`
`aws events list-event-buses`
`aws events list-rules --event-bus-name app-event-bus`
`aws events list-targets-by-rule --rule route-spring-events-to-lambda --event-bus-name app-event-bus`

# 5. Logs
`docker logs -f localstack`
`awslocal logs tail /aws/lambda/eventbridge-ingest-lambda --follow`

# 6. Testing
```shell
awslocal events put-events --entries '[
  {
    "EventBusName": "app-event-bus",
    "Source": "events",
    "DetailType": "test-alert",
    "Detail": "{\"message\": \"Hello from LocalStack!\"}"
  }
]'
```


what i need: 
1. push image to ECR
2. run container in ECS (Fargate for compute)
   3. ECS needs putEvents config
3. let containerized app push messages to sqs 
   4. SQS needs push events to sqs config