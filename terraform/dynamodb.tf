# =====================================================================
# DATABASE LAYER
# =====================================================================
resource "aws_dynamodb_table" "recalls_table" {
  name         = "product-recalls"
  billing_mode = "PAY_PER_REQUEST"
  hash_key     = "recall_id"

  # Tells DynamoDB that the only required schema element is the String ID
  attribute {
    name = "recall_id"
    type = "S"
  }
}