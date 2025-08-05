# Application Load Balancer (ALB) for FastAPI backend application servers
resource "aws_lb" "fastapi_backend_app_server_alb" {
  name               = var.fastapi_backend_app_server_lb_name
  internal           = false                      # Internet-facing ALB
  load_balancer_type = "application"              # Application Load Balancer type
  security_groups    = [aws_security_group.alb_sg.id]
  subnets            = [var.public_web_subnet_a_id, var.public_web_subnet_b_id]

  enable_deletion_protection = false               # Disable deletion protection
}

# Target group for backend app servers listening on port 8000 (HTTP)
resource "aws_lb_target_group" "fastapi_backend_app_server_tg" {
  name     = "${var.fastapi_backend_app_server_lb_name}-tg"
  port     = 8000
  protocol = "HTTP"
  vpc_id   = var.main_vpc_id

  health_check {
    path                = "/health"              # Health check endpoint
    interval            = 30                      # Interval between health checks in seconds
    timeout             = 5                       # Timeout for each health check
    healthy_threshold   = 3                       # Number of successful checks before healthy
    unhealthy_threshold = 3                       # Number of failed checks before unhealthy
  }
}

# Listener on port 80 to redirect HTTP traffic to HTTPS (port 443)
resource "aws_lb_listener" "fastapi_backend_app_server_listener_http_redirect" {
  load_balancer_arn = aws_lb.fastapi_backend_app_server_alb.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type = "redirect"
    redirect {
      port        = "443"
      protocol    = "HTTPS"
      status_code = "HTTP_301"                   # Permanent redirect
    }
  }
}

# Listener on port 443 to serve HTTPS traffic
resource "aws_lb_listener" "fastapi_backend_app_server_listener" {
  load_balancer_arn = aws_lb.fastapi_backend_app_server_alb.arn
  port              = 443
  protocol          = "HTTPS"

  ssl_policy      = "ELBSecurityPolicy-TLS13-1-2-Res-2021-06"  # Enforce modern TLS policy
  certificate_arn = var.fastapi_backend_app_cert_arn           # ACM certificate ARN

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.fastapi_backend_app_server_tg.arn
  }
}

# Security group for the ALB allowing inbound HTTP/HTTPS traffic and all outbound traffic
resource "aws_security_group" "alb_sg" {
  name        = "alb_sg"
  description = "Security group for the alb"
  vpc_id      = var.main_vpc_id

  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    description = "Allow inbound HTTPS traffic"
  }

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    description = "Allow inbound HTTP traffic for redirect"
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
    description = "Allow all outbound traffic"
  }
}
