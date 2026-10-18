# =====================================================================
# Collect secrets for EKS / Fargate Cron
# =====================================================================
resource "aws_secretsmanager_secret" "api_key" {
  name = "events/api-key"
  description = "API key injected via Terraform"
}

resource "aws_secretsmanager_secret_version" "api_key_value" {
  secret_id = aws_secretsmanager_secret.api_key.id
  secret_string = jsonencode({
    API_KEY = var.my_api_key
  })
}