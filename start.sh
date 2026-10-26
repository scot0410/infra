#!/bin/zsh

echo "=========== INITIALIZING LOCALSTACK RESOURCES ==========="
docker-compose up

echo "=========== CREATING INFRASTRUCTURE RESOURCES ==========="
terraform init
terraform plan
terraform apply -auto-approve
echo "=========== COMPLETE ==========="

