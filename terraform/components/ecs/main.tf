locals {
  name        = "complete-ecs"
  environment = "dev"

  # This is the convention we use to know what belongs to each other
  ec2_resources_name = "${local.name}-${local.environment}"
}

data "aws_availability_zones" "available" {
  state = "available"
}


module "ecs" {
  source  = "terraform-aws-modules/ecs/aws"
  version = "3.4.0"

  name = local.name

  container_insights = true

  capacity_providers = ["FARGATE", "FARGATE_SPOT"]

  default_capacity_provider_strategy = [
    {
      capacity_provider = "FARGATE_SPOT"
    }
  ]
  tags = {
    Environment = "Development"
  }
}

module "hello_world" {
  source = "./service-hello-world"
  cluster_id = module.ecs.ecs_cluster_id
}
