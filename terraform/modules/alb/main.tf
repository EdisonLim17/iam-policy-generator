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
    port     = 80
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
    ssl_policy = "ELBSecurityPolicy-2021-06"
    #certificate_arn = aws_acm_certificate.fastapi_backend_app_server_cert.arn

    default_action {
        type             = "forward"
        target_group_arn = aws_lb_target_group.fastapi_backend_app_server_tg.arn
    }
}

# resource "aws_acm_certificate" "fastapi_backend_app_server_cert" {
#     domain_name       = var.domain_name
#     validation_method = "DNS"

#     lifecycle {
#         create_before_destroy = true
#     }
# }

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
}