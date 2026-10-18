variable "my_api_key" {
  type        = string
  description = "The secret API key pulled from the infra repo env"
  sensitive   = true # Prevents Terraform from leaking the key in logs
}