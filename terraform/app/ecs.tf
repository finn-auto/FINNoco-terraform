resource "aws_ecs_cluster" "noco_cluster" {
  name = "${local.application}-${var.env}-noco-cluster"

  setting {
    name  = "containerInsights"
    value = "enabled"
  }
  
  tags = "${local.tags}"
}

resource "aws_ecs_task_definition" "noco_task" {
  family                   = "${local.application}-${var.env}-noco-task" # Naming our first task
  container_definitions    = <<DEFINITION
  [
    {
      "name": "${local.application}-${var.env}-noco-task",
      "image": "finnauto/nocodb:${var.noco_image_version}",
      "essential": true,
      "portMappings": [
        {
          "containerPort": 8080,
          "hostPort": 8080
        }
      ],
      "memory": ${var.nc_nodejs_max_memory},
      "cpu": 1024,
      "environment": [
        {
          "name": "NC_DB",
          "value": "pg://${module.aurora.rds_cluster_endpoint}:5432?u=db_user&p=${random_password.db_password.result}&d=database"
        },
        {
          "name": "NC_AUTH_JWT_SECRET",
          "value": "${var.nc_auth_jwt_secret}"
        },
        {
          "name": "NODE_OPTIONS",
          "value": "--max-old-space-size=${floor(var.nc_nodejs_max_memory * 0.9)}"
        },
        {
          "name": "NC_PUBLIC_URL",
          "value": "https://${aws_route53_record.server1-record.name}"
        },
        {
          "name": "NC_REDIS_URL",
          "value": "redis://${module.redis.host}:${module.redis.port}"
        }
      ]
    }
  ]
  DEFINITION
  requires_compatibilities = ["FARGATE"] # Stating that we are using ECS Fargate
  network_mode             = "awsvpc"    # Using awsvpc as our network mode as this is required for Fargate
  memory                   = 24576         # Specifying the memory our container requires
  cpu                      = 4096         # Specifying the CPU our container requires
  execution_role_arn       = "${aws_iam_role.ecs_task.arn}"
  tags        = local.tags
}

resource "aws_ecs_service" "noco_service" {
  name            = "${local.application}-${var.env}-noco-service"
  cluster         = aws_ecs_cluster.noco_cluster.id
  task_definition = aws_ecs_task_definition.noco_task.arn
  desired_count   = var.desired_ecs_task_count
  launch_type      = "FARGATE"
  platform_version = "1.4.0" 

  load_balancer {
    target_group_arn = "${aws_lb_target_group.noco_ecs_target_group.arn}" # Referencing our target group
    container_name   = "${aws_ecs_task_definition.noco_task.family}"
    container_port   = 8080 # Specifying the container port
  }
  network_configuration {
    assign_public_ip = false
    security_groups  = [aws_security_group.sg_ecs.id]
    subnets          = module.vpc.private_subnets
  }
  tags        = local.tags
}

data "aws_iam_policy_document" "ecs_task_assume_role" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["ecs-tasks.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "ecs_task" {
  name               = "${local.application}-${var.env}-ecs-task-role"
  assume_role_policy = "${data.aws_iam_policy_document.ecs_task_assume_role.json}"
  tags        = local.tags
}

data "aws_iam_policy_document" "ecs_task" {
  statement {
    actions = [
      "ecr:GetAuthorizationToken",
      "ecr:BatchCheckLayerAvailability",
      "ecr:GetDownloadUrlForLayer",
      "ecr:BatchGetImage",
      "logs:CreateLogStream",
      "logs:PutLogEvents",
    ]

    resources = ["*"]
  }

  statement {
    sid = "ReadWriteNocoS3Bucket"

    actions = [
      "s3:*",
    ]

    resources = [
      "${aws_s3_bucket.s3-bucket.arn}",
      "${aws_s3_bucket.s3-bucket.arn}/*",
    ]
  }
}

resource "aws_iam_role_policy" "ecs_task" {
  role   = "${aws_iam_role.ecs_task.id}"
  name   = "${local.application}-${var.env}-ecs-task"
  policy = "${data.aws_iam_policy_document.ecs_task.json}"
}

resource "aws_security_group" "sg_ecs" {
  name   = "${local.application}-postgres-${var.env}-sg-ecs"
  vpc_id = module.vpc.vpc_id

  tags = local.tags
}

resource "aws_security_group_rule" "inbound_sg_app_lb" {
  security_group_id           = aws_security_group.sg_ecs.id
  source_security_group_id    = aws_security_group.sg_app_lb.id
  type                        = "ingress"
  protocol                    = "tcp"
  from_port                   = 8080
  to_port                     = 8080
}

resource "aws_security_group_rule" "outbound_sg_app_lb" {
  security_group_id = aws_security_group.sg_ecs.id
  type        = "egress"
  from_port   = 0
  to_port     = 0
  protocol    = -1
  cidr_blocks = ["0.0.0.0/0"]
}