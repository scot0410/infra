#!/bin/bash
set -e

echo "🚀 Starting LocalStack via CLI..."
localstack start -d
localstack wait -t 30

echo "⚙️  Deploying serverless architecture layer with Terraform..."
cd "$(dirname "$0")/../terraform"
terraform init
terraform apply -auto-approve

echo "⛵ Helm and K8s hooks ready for processing local platform resources."
echo "🎯 Infrastructure bootstrap script executed cleanly!"