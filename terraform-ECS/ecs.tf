resource "aws_ecs_cluster" "app_cluster" {
  name = "app-cluster"
}
data "aws_caller_identity" "current" {}

# Create IAM Role for ECS Task
resource "aws_iam_role" "ecs_task_execution_role" {
  name = "ecsTaskExecutionRole2"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect = "Allow"
      Principal = {
        Service = "ecs-tasks.amazonaws.com"
      }
      Action = "sts:AssumeRole"
    }]
  })
}

# Attach policy for pulling from ECR
resource "aws_iam_role_policy_attachment" "ecs_task_execution_role_policy" {
  role       = aws_iam_role.ecs_task_execution_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}


resource "aws_ecs_task_definition" "app_task" {
  family                   = "app-task"
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu                      = "512"
  memory                   = "1024"
  execution_role_arn       = aws_iam_role.ecs_task_execution_role.arn

  container_definitions = jsonencode([
    {
      name      = "flask-backend"
      image     = "${data.aws_caller_identity.current.account_id}.dkr.ecr.us-east-1.amazonaws.com/flask-backend:latest"
      essential = true
      portMappings = [
        { containerPort = 5000, hostPort = 5000 }
      ]
    },
    {
      name      = "express-frontend"
      image     = "${data.aws_caller_identity.current.account_id}.dkr.ecr.us-east-1.amazonaws.com/express-frontend:latest"
      essential = true
      portMappings = [
        { containerPort = 3000, hostPort = 3000 }
      ]
    }
  ])
}

resource "aws_ecs_service" "app_service" {
  name            = "app-service"
  cluster         = aws_ecs_cluster.app_cluster.id
  task_definition = aws_ecs_task_definition.app_task.arn
  desired_count   = 1
  launch_type     = "FARGATE"

  network_configuration {
    subnets         = [aws_subnet.public1.id]
    security_groups = [aws_security_group.ecs_sg.id]
    assign_public_ip = true
  }

    # Attach service to ALB target group
  load_balancer {
    target_group_arn = aws_lb_target_group.app_tg.arn
    container_name   = "express-frontend"  # Must match container definition name
    container_port   = 3000                # Must match container port
  }

  depends_on = [aws_lb_listener.app_listener] # optional, ensures ALB listener exists first

}
