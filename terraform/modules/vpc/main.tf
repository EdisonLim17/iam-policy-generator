resource "aws_vpc" "main-vpc" {
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

resource "aws_subnet" "public-web-subnet-a" {
    vpc_id            = aws_vpc.main-vpc.id
    cidr_block        = cidrsubnet(var.vpc_cidr_block, 4, 1)
    availability_zone = var.availability_zones[0]
    map_public_ip_on_launch = true

    tags = {
        Name = "${var.vpc_name}-public-web-subnet-a"
    }
}

resource "aws_subnet" "public-web-subnet-b" {
    vpc_id            = aws_vpc.main-vpc.id
    cidr_block        = cidrsubnet(var.vpc_cidr_block, 4, 2)
    availability_zone = var.availability_zones[1]
    map_public_ip_on_launch = true

    tags = {
        Name = "${var.vpc_name}-public-web-subnet-b"
    }
}

resource "aws_subnet" "private-app-subnet-a" {
    vpc_id            = aws_vpc.main-vpc.id
    cidr_block        = cidrsubnet(var.vpc_cidr_block, 4, 3)
    availability_zone = var.availability_zones[0]
    map_public_ip_on_launch = false

    tags = {
        Name = "${var.vpc_name}-private-app-subnet-a"
    }
}

resource "aws_subnet" "private-app-subnet-b" {
    vpc_id            = aws_vpc.main-vpc.id
    cidr_block        = cidrsubnet(var.vpc_cidr_block, 4, 4)
    availability_zone = var.availability_zones[1]
    map_public_ip_on_launch = false

    tags = {
        Name = "${var.vpc_name}-private-app-subnet-b"
    }
}

resource "aws_subnet" "private-db-subnet-a" {
    vpc_id            = aws_vpc.main-vpc.id
    cidr_block        = cidrsubnet(var.vpc_cidr_block, 4, 5)
    availability_zone = var.availability_zones[0]
    map_public_ip_on_launch = false

    tags = {
        Name = "${var.vpc_name}-private-db-subnet-a"
    }
}

resource "aws_subnet" "private-db-subnet-b" {
    vpc_id            = aws_vpc.main-vpc.id
    cidr_block        = cidrsubnet(var.vpc_cidr_block, 4, 6)
    availability_zone = var.availability_zones[1]
    map_public_ip_on_launch = false

    tags = {
        Name = "${var.vpc_name}-private-db-subnet-b"
    }
}