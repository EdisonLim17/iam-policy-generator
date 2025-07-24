resource "aws_lb" "fastapi_backend_app_server_alb" {
    name               = var.fastapi_backend_app_server_lb_name
    internal           = false
    load_balancer_type = "application"
    security_groups    = [aws_security_group.alb_sg.id]
    subnets            = [var.public_web_subnet_a_id, var.public_web_subnet_b_id]

    enable_deletion_protection = false
}

resource "aws_lb_target_group" "fastapi_backend_app_server_tg" {
    name     = "${var.fastapi_backend_app_server_lb_name}-tg"
    port     = 8000
    protocol = "HTTP"
    vpc_id   = var.main_vpc_id

    health_check {
        path                = "/health"
        interval            = 30
        timeout             = 5
        healthy_threshold  = 3
        unhealthy_threshold = 3
    }
}

resource "aws_lb_listener" "fastapi_backend_app_server_listener_http_redirect" {
    load_balancer_arn = aws_lb.fastapi_backend_app_server_alb.arn
    port              = 80
    protocol          = "HTTP"

    default_action {
        type             = "redirect"
        redirect {
            port        = "443"
            protocol    = "HTTPS"
            status_code = "HTTP_301"
        }
    }
}

resource "aws_lb_listener" "fastapi_backend_app_server_listener" {
    load_balancer_arn = aws_lb.fastapi_backend_app_server_alb.arn
    port              = 443
    protocol          = "HTTPS"

    ssl_policy = "ELBSecurityPolicy-TLS13-1-2-Res-2021-06"
    certificate_arn = var.fastapi_backend_app_cert_arn

    default_action {
        type             = "forward"
        target_group_arn = aws_lb_target_group.fastapi_backend_app_server_tg.arn
    }
}

resource "aws_security_group" "alb_sg" {
    name        = "alb_sg"
    description = "Security group for the alb"
    vpc_id      = var.main_vpc_id

    ingress {
        from_port   = 443
        to_port     = 443
        protocol    = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
        description = "Allow HTTPS traffic"
    }

    ingress {
        from_port   = 80
        to_port     = 80
        protocol    = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
        description = "Allow HTTP traffic for redirect"
    }

    egress {
        from_port   = 0
        to_port     = 0
        protocol    = "-1"
        cidr_blocks = ["0.0.0.0/0"]
        description = "Allow all outbound traffic"
    }
}