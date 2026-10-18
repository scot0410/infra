#!/bin/zsh

echo "=========== INITIALIZING LOCALSTACK RESOURCES ==========="
localstack start

echo "=========== CREATING INFRASTRUCTURE RESOURCES ==========="
terraform init
terraform plan
terraform apply -auto-approve
echo "=========== COMPLETE ==========="

