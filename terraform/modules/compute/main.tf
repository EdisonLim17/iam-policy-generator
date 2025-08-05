# Launch template for FastAPI backend app servers
resource "aws_launch_template" "fastapi_backend_app_server_lt" {
  name_prefix   = var.fastapi_backend_app_server_lt_name
  image_id      = data.aws_ssm_parameter.amazon_linux_2023_ami.value  # Latest Amazon Linux 2023 AMI
  instance_type = var.fastapi_backend_app_server_instance_type

  # Attach IAM instance profile for permissions (e.g., Secrets Manager access)
  iam_instance_profile {
    name = aws_iam_instance_profile.fastapi_backend_app_server_instance_profile.name
  }

  # Configure network interface without public IP, attach security group
  network_interfaces {
    associate_public_ip_address = false
    security_groups             = [aws_security_group.fastapi_backend_app_server_sg.id]
  }

  # Provide user data script to initialize instances
  user_data = base64encode(file("${path.module}/../../../app/start.sh"))

  lifecycle {
    create_before_destroy = true
  }
}

# Fetch the latest Amazon Linux 2023 AMI ID from SSM Parameter Store
data "aws_ssm_parameter" "amazon_linux_2023_ami" {
  name = "/aws/service/ami-amazon-linux-latest/al2023-ami-kernel-default-x86_64"
}

# Auto Scaling Group to manage FastAPI backend instances
resource "aws_autoscaling_group" "fastapi_backend_app_server_asg" {
  launch_template {
    id      = aws_launch_template.fastapi_backend_app_server_lt.id
    version = "$Latest"
  }

  min_size             = 2
  max_size             = 4
  desired_capacity     = 2
  vpc_zone_identifier  = [var.private_app_subnet_a_id, var.private_app_subnet_b_id]
  health_check_type    = "ELB"
  health_check_grace_period = 300

  target_group_arns = [var.fastapi_backend_app_server_tg_arn]

  depends_on = [aws_launch_template.fastapi_backend_app_server_lt]
}

# Auto Scaling policy to scale based on average CPU utilization (~80%)
resource "aws_autoscaling_policy" "fastapi_backend_app_server_target_tracking_policy" {
  name        = "target-tracking-policy"
  policy_type = "TargetTrackingScaling"

  target_tracking_configuration {
    target_value = 80.0

    predefined_metric_specification {
      predefined_metric_type = "ASGAverageCPUUtilization"
    }
  }

  autoscaling_group_name = aws_autoscaling_group.fastapi_backend_app_server_asg.name
}

# Security group for backend app servers
resource "aws_security_group" "fastapi_backend_app_server_sg" {
  name        = "app_server_sg"
  description = "Security group for the backend application server"
  vpc_id      = var.main_vpc_id

  ingress {
    from_port       = 8000
    to_port         = 8000
    protocol        = "tcp"
    security_groups = [var.alb_sg_id] # Allow traffic from ALB security group only
    description     = "Allow HTTP traffic from ALB"
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"] # Allow all outbound traffic
    description = "Allow all outbound traffic"
  }
}

# IAM role for EC2 instances to assume, allowing access to Secrets Manager and SSM
resource "aws_iam_role" "fastapi_backend_app_server_role" {
  name = "fastapi_backend_app_server_role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action    = "sts:AssumeRole"
      Effect    = "Allow"
      Principal = { Service = "ec2.amazonaws.com" }
    }]
  })

  description = "Allows EC2 instances to assume role"
}

# IAM policy granting Secrets Manager read permissions for relevant secrets
resource "aws_iam_policy" "secrets_manager_access_policy" {
  name        = "secrets_manager_policy"
  description = "Policy allowing access to relevant secrets in Secrets Manager"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect   = "Allow"
      Action   = [
        "secretsmanager:GetSecretValue",
        "secretsmanager:DescribeSecret"
      ]
      Resource = [
        "arn:aws:secretsmanager:us-east-1:415730361496:secret:openai/iam-policy-generator-api-key-vbsXNA",
        "arn:aws:secretsmanager:us-east-1:415730361496:secret:rds/iam-policy-generator-credentials-output-*",
        "arn:aws:secretsmanager:us-east-1:415730361496:secret:google/iam-policy-generator-oauth-credentials-KWyDPD",
        "arn:aws:secretsmanager:us-east-1:415730361496:secret:jwt/iam-policy-generator-secret-*"
      ]
    }]
  })
}

# Attach Secrets Manager policy to backend app server IAM role
resource "aws_iam_role_policy_attachment" "fastapi_backend_app_server_secrets_manager_policy_attachment" {
  role       = aws_iam_role.fastapi_backend_app_server_role.name
  policy_arn = aws_iam_policy.secrets_manager_access_policy.arn
}

# Attach AWS managed SSM policy to allow EC2 instances to interact with SSM
resource "aws_iam_role_policy_attachment" "fastapi_backend_app_server_ssm_policy_attachment" {
  role       = aws_iam_role.fastapi_backend_app_server_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}

# IAM instance profile to link the IAM role to EC2 instances
resource "aws_iam_instance_profile" "fastapi_backend_app_server_instance_profile" {
  name = "fastapi_backend_app_server_instance_profile"
  role = aws_iam_role.fastapi_backend_app_server_role.name

  lifecycle {
    create_before_destroy = true
  }
}
