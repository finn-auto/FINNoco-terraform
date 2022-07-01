module "alb" {
  source             = "terraform-aws-modules/alb/aws"
  version            = "~> 6.0"
  name               = "${var.subdomain}-alb"
  load_balancer_type = "application"

  vpc_id          = module.vpc.vpc_id
  subnets         = module.vpc.public_subnets
  security_groups = [aws_security_group.sg_app_lb.id]
  idle_timeout    = 60
  tags = local.tags
}

resource "aws_security_group" "sg_app_lb" {
  name   = "${local.application}-${var.env}-sg_app_lb"
  vpc_id = module.vpc.vpc_id

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = -1
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = local.tags
}

resource "aws_lb_target_group" "noco_ecs_target_group" {
  name                 = "${local.application}-${var.env}-lb-target"
  port                 = 80
  protocol             = "HTTP"
  vpc_id               = "${module.vpc.vpc_id}"
  target_type          = "ip"
  deregistration_delay = "60"
  health_check {
    interval = 300
    matcher = "200,301,302"
    path = "/"
  }
  stickiness {
    type    = "lb_cookie"
    enabled = "false"
  }
  tags = local.tags
}

resource "aws_lb_listener" "http_noco_listner" {
  load_balancer_arn = "${module.alb.lb_arn}"
  port              = 80
  protocol          = "HTTP"
  default_action {
    type = "redirect"

    redirect {
      port        = "443"
      protocol    = "HTTPS"
      status_code = "HTTP_301"
    }
  }
}

resource "aws_lb_listener" "https_noco_listner" {
  load_balancer_arn = "${module.alb.lb_arn}"
  port              = 443
  protocol          = "HTTPS"
  certificate_arn   = module.acm.acm_certificate_arn
  default_action {
    type             = "forward"
    target_group_arn = "${aws_lb_target_group.noco_ecs_target_group.arn}"
  }
}