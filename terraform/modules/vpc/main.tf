resource "aws_vpc" "main_vpc" {
    cidr_block = var.vpc_cidr_block
    
    tags = {
        Name = var.vpc_name
    }
    
    enable_dns_support = true
    enable_dns_hostnames = true
    
    lifecycle {
        create_before_destroy = true
    }
}

resource "aws_subnet" "public_web_subnet_a" {
    vpc_id            = aws_vpc.main_vpc.id
    cidr_block        = cidrsubnet(var.vpc_cidr_block, 4, 1)
    availability_zone = var.availability_zones[0]
    map_public_ip_on_launch = true

    tags = {
        Name = var.public_web_subnet_a_name
    }
}

resource "aws_subnet" "public_web_subnet_b" {
    vpc_id            = aws_vpc.main_vpc.id
    cidr_block        = cidrsubnet(var.vpc_cidr_block, 4, 2)
    availability_zone = var.availability_zones[1]
    map_public_ip_on_launch = true

    tags = {
        Name = var.public_web_subnet_b_name
    }
}

resource "aws_subnet" "private_app_subnet_a" {
    vpc_id            = aws_vpc.main_vpc.id
    cidr_block        = cidrsubnet(var.vpc_cidr_block, 4, 3)
    availability_zone = var.availability_zones[0]
    map_public_ip_on_launch = false

    tags = {
        Name = var.private_app_subnet_a_name
    }
}

resource "aws_subnet" "private_app_subnet_b" {
    vpc_id            = aws_vpc.main_vpc.id
    cidr_block        = cidrsubnet(var.vpc_cidr_block, 4, 4)
    availability_zone = var.availability_zones[1]
    map_public_ip_on_launch = false

    tags = {
        Name = var.private_app_subnet_b_name
    }
}

resource "aws_subnet" "private_db_subnet_a" {
    vpc_id            = aws_vpc.main_vpc.id
    cidr_block        = cidrsubnet(var.vpc_cidr_block, 4, 5)
    availability_zone = var.availability_zones[0]
    map_public_ip_on_launch = false

    tags = {
        Name = var.private_db_subnet_a_name
    }
}

resource "aws_subnet" "private_db_subnet_b" {
    vpc_id            = aws_vpc.main_vpc.id
    cidr_block        = cidrsubnet(var.vpc_cidr_block, 4, 6)
    availability_zone = var.availability_zones[1]
    map_public_ip_on_launch = false

    tags = {
        Name = var.private_db_subnet_b_name
    }
}

resource "aws_nat_gateway" "public_web_subnet_a_nat_gateway" {
    allocation_id = aws_eip.public_web_subnet_a_nat_eip.id
    subnet_id     = aws_subnet.public_web_subnet_a.id

    depends_on = [aws_internet_gateway.igw]

    tags = {
        Name = var.public_web_subnet_a_nat_gateway_name
    }
}

resource "aws_eip" "public_web_subnet_a_nat_eip" {
    tags = {
        Name = var.public_web_subnet_a_nat_eip_name
    }
}

resource "aws_nat_gateway" "public_web_subnet_b_nat_gateway" {
    allocation_id = aws_eip.public_web_subnet_b_nat_eip.id
    subnet_id     = aws_subnet.public_web_subnet_b.id

    depends_on = [aws_internet_gateway.igw]

    tags = {
        Name = var.public_web_subnet_b_nat_gateway_name
    }
}

resource "aws_eip" "public_web_subnet_b_nat_eip" {
    tags = {
        Name = var.public_web_subnet_b_nat_eip_name
    }
}

resource "aws_internet_gateway" "igw" {
    vpc_id = aws_vpc.main_vpc.id

    tags = {
        Name = var.igw_name
    }
}

resource "aws_route_table" "public_route_table" {
    vpc_id = aws_vpc.main_vpc.id

    route {
        cidr_block = "0.0.0.0/0"
        gateway_id = aws_internet_gateway.igw.id
    }

    tags = {
        Name = var.public_route_table_name
    }
}

resource "aws_route_table_association" "public_web_subnet_a_association" {
    subnet_id      = aws_subnet.public_web_subnet_a.id
    route_table_id = aws_route_table.public_route_table.id
}

resource "aws_route_table_association" "public_web_subnet_b_association" {
    subnet_id      = aws_subnet.public_web_subnet_b.id
    route_table_id = aws_route_table.public_route_table.id
}

resource "aws_route_table" "private_app_subnet_a_route_table" {
    vpc_id = aws_vpc.main_vpc.id

    route {
        cidr_block = "0.0.0.0/0"
        nat_gateway_id = aws_nat_gateway.public_web_subnet_a_nat_gateway.id
    }

    tags = {
        Name = var.private_app_subnet_a_route_table_name
    }
}

resource "aws_route_table_association" "private_app_subnet_a_association" {
    subnet_id      = aws_subnet.private_app_subnet_a.id
    route_table_id = aws_route_table.private_app_subnet_a_route_table.id
}

resource "aws_route_table" "private_app_subnet_b_route_table" {
    vpc_id = aws_vpc.main_vpc.id

    route {
        cidr_block = "0.0.0.0/0"
        nat_gateway_id = aws_nat_gateway.public_web_subnet_b_nat_gateway.id
    }

    tags = {
        Name = var.private_app_subnet_b_route_table_name
    }
}

resource "aws_route_table_association" "private_app_subnet_b_association" {
    subnet_id      = aws_subnet.private_app_subnet_b.id
    route_table_id = aws_route_table.private_app_subnet_b_route_table.id
}

resource "aws_route_table" "private_db_subnet_a_route_table" {
    vpc_id = aws_vpc.main_vpc.id

    tags = {
        Name = var.private_db_subnet_a_route_table_name
    }
}

resource "aws_route_table_association" "private_db_subnet_a_association" {
    subnet_id      = aws_subnet.private_db_subnet_a.id
    route_table_id = aws_route_table.private_db_subnet_a_route_table.id
}

resource "aws_route_table" "private_db_subnet_b_route_table" {
    vpc_id = aws_vpc.main_vpc.id

    tags = {
        Name = var.private_db_subnet_b_route_table_name
    }
}

resource "aws_route_table_association" "private_db_subnet_b_association" {
    subnet_id      = aws_subnet.private_db_subnet_b.id
    route_table_id = aws_route_table.private_db_subnet_b_route_table.id
}