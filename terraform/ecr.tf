# =====================================================================
# CONTAINER REGISTRY (ECR)
# =====================================================================
resource "aws_ecr_repository" "health_hazard_events_repo" {
  name                 = "health-hazard-events"
  image_tag_mutability = "MUTABLE"

  image_scanning_configuration {
    scan_on_push = true
  }
}