provider "aws" {
  region = "ap-south-1"
}

resource "aws_vpc" "tf_vpc" {
  cidr_block       = "10.0.0.0/16"
  instance_tenancy = "default"

  tags = {
    Name = "tf_vpc"
  }
}

resource "aws_internet_gateway" "tf_igw" {
  vpc_id = aws_vpc.tf_vpc.id

  tags = {
    Name = "tf_igw"
  }
}


resource "aws_subnet" "tf_subnet_public" {
  vpc_id     = aws_vpc.tf_vpc.id
  cidr_block = "10.0.1.0/24"
  availability_zone = "ap-south-1a"

  tags = {
    Name = "tf_subnet_public"
  }
}

resource "aws_subnet" "tf_subnet_private" {
  vpc_id     = aws_vpc.tf_vpc.id
  cidr_block = "10.0.2.0/24"
  availability_zone = "ap-south-1a"

  tags = {
    Name = "tf_subnet_private"
  }
}

resource "aws_route_table" "tf_route_table_public" {
  vpc_id = aws_vpc.tf_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.tf_igw.id
  }

  tags = {
    Name = "tf_route_table_public"
  }
}

resource "aws_route_table" "tf_route_table_private" {
  vpc_id = aws_vpc.tf_vpc.id

  tags = {
    Name = "tf_route_table_private"
  }
}

resource "aws_route_table_association" "tf_rta" {
  subnet_id      = aws_subnet.tf_subnet_public.id
  route_table_id = aws_route_table.tf_route_table_public.id
}

resource "aws_route_table_association" "tf_rta_1" {
  subnet_id      = aws_subnet.tf_subnet_private.id
  route_table_id = aws_route_table.tf_route_table_private.id
}

resource "aws_security_group" "tf_security_group" {
  name        = "allow_tls"
  description = "Allow TLS inbound traffic and all outbound traffic"
  vpc_id      = aws_vpc.tf_vpc.id

  tags = {
    Name = "tf_security_group"
  }
}

resource "aws_vpc_security_group_ingress_rule" "allow_tls_ipv4" {
  security_group_id = aws_security_group.tf_security_group.id
  cidr_ipv4         = "0.0.0.0/0"
  from_port         = 0
  ip_protocol       = "tcp"
  to_port           = 65535
}

resource "aws_vpc_security_group_egress_rule" "allow_all_traffic_ipv4" {
  security_group_id = aws_security_group.tf_security_group.id
  cidr_ipv4         = "0.0.0.0/0"
  ip_protocol       = "-1" # semantically equivalent to all ports
}