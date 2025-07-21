resource "aws_launch_template" "fastapi_backend_app_server_lt" {
    name_prefix = var.fastapi_backend_app_server_lt_name
    image_id      = data.aws_ssm_parameter.amazon_linux_2023_ami.value
    instance_type = var.fastapi_backend_app_server_instance_type

    network_interfaces {
        associate_public_ip_address = false
        security_groups             = [aws_security_group.fastapi_backend_app_server_sg.id]
    }

    lifecycle {
        create_before_destroy = true
    }
}

#fetches the latest Amazon Linux 2023 AMI
data "aws_ssm_parameter" "amazon_linux_2023_ami" {
    name = "/aws/service/ami-amazon-linux-latest/al2023-ami-kernel-default-x86_64"
}

resource "aws_autoscaling_group" "fastapi_backend_app_server_asg" {
    launch_template {
        id      = aws_launch_template.fastapi_backend_app_server_lt.id
        version = "$Latest"
    }

    min_size           = 2
    max_size           = 4
    desired_capacity   = 2
    vpc_zone_identifier = [var.private_app_subnet_a_id, var.private_app_subnet_b_id]
    health_check_type  = "ELB"
    health_check_grace_period = 300

    target_group_arns = [var.fastapi_backend_app_server_tg_arn]

    depends_on = [aws_launch_template.fastapi_backend_app_server_lt]
}

resource "aws_autoscaling_policy" "fastapi_backend_app_server_target_tracking_policy" {
    name                   = "target-tracking-policy"
    policy_type           = "TargetTrackingScaling"
    target_tracking_configuration {
        target_value       = 80.0
        predefined_metric_specification {
            predefined_metric_type = "ASGAverageCPUUtilization"
        }
    }
    autoscaling_group_name = aws_autoscaling_group.fastapi_backend_app_server_asg.name
}

resource "aws_security_group" "fastapi_backend_app_server_sg" {
    name        = "app_server_sg"
    description = "Security group for the backend application server"
    vpc_id      = var.main_vpc_id

    ingress {
        from_port   = 80
        to_port     = 80
        protocol    = "tcp"
        security_groups = [var.alb_sg_id]
        description = "Allow HTTP traffic from ALB"
    }
}