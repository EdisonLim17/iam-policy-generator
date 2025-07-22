resource "aws_launch_template" "fastapi_backend_app_server_lt" {
    name_prefix = var.fastapi_backend_app_server_lt_name
    image_id      = data.aws_ssm_parameter.amazon_linux_2023_ami.value
    instance_type = var.fastapi_backend_app_server_instance_type

    iam_instance_profile {
        name = aws_iam_role.fastapi_backend_app_server_role.name
    }

    network_interfaces {
        associate_public_ip_address = false
        security_groups             = [aws_security_group.fastapi_backend_app_server_sg.id]
    }

    user_data = file("${path.module}/../../../app/start.sh")

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

resource "aws_iam_role" "fastapi_backend_app_server_role" {
    name = "fastapi_backend_app_server_role"

    assume_role_policy = jsonencode({
        Version = "2012-10-17"
        Statement = [
            {
                Action = "sts:AssumeRole"
                Effect = "Allow"
                Principal = {
                    Service = "ec2.amazonaws.com"
                }
            }
        ]
    })
    description = "Allows EC2 instances to assume role"
}

resource "aws_iam_policy" "secrets_manager_access_policy" {
    name        = "secrets_manager_policy"
    description = "Policy allowing access to openai_api_key secret in Secrets Manager"
    
    policy = jsonencode({
        Version = "2012-10-17"
        Statement = [
            {
                Effect = "Allow"
                Action = [
                    "secretsmanager:GetSecretValue",
                    "secretsmanager:DescribeSecret"
                ]
                Resource = "arn:aws:secretsmanager:us-east-1:415730361496:secret:openai/iam-policy-generator-api-key-vbsXNA"
            }
        ]
    })
}

resource "aws_iam_role_policy_attachment" "fastapi_backend_app_server_secrets_manager_policy_attachment" {
    role       = aws_iam_role.fastapi_backend_app_server_role.name
    policy_arn = aws_iam_policy.secrets_manager_access_policy.arn
}