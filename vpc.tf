# Internet VPC
resource "aws_vpc" "power" {
  cidr_block           = "192.168.0.0/16"
  instance_tenancy     = "default"
  enable_dns_support   = "true"
  enable_dns_hostnames = "true"
  enable_classiclink   = "false"
  tags = {
    Name = "power"
  }
}

# Subnets
resource "aws_subnet" "pictory-public-1" {
  vpc_id                  = aws_vpc.power.id
  cidr_block              = "192.168.1.0/24"
  map_public_ip_on_launch = "true"
  availability_zone       = "us-west-2a"

  tags = {
    Name = "pictory-public-1"
  }
}

resource "aws_subnet" "pictory-public-2" {
  vpc_id                  = aws_vpc.power.id
  cidr_block              = "192.168.2.0/24"
  map_public_ip_on_launch = "true"
  availability_zone       = "us-west-2b"

  tags = {
    Name = "pictory-public-2"
  }
}

resource "aws_subnet" "pictory-private-1" {
  vpc_id                  = aws_vpc.power.id
  cidr_block              = "192.168.4.0/24"
  map_public_ip_on_launch = "false"
  availability_zone       = "us-west-2a"

  tags = {
    Name = "pictory-private-1"
  }
}

resource "aws_subnet" "pictory-private-2" {
  vpc_id                  = aws_vpc.power.id
  cidr_block              = "192.168.5.0/24"
  map_public_ip_on_launch = "false"
  availability_zone       = "us-west-2b"

  tags = {
    Name = "pictory-private-2"
  }
}

# Internet GW
resource "aws_internet_gateway" "pictory-gw" {
  vpc_id = aws_vpc.power.id

  tags = {
    Name = "pgw"
  }
}

#Attaching Elastic Ip
resource "aws_eip" "picelip" {
  vpc      = true
  tags = {
    Name = "Pic Elastic Ip"
  }
}
#Attaching  Public NAT
resource "aws_nat_gateway" "picnat" {
 allocation_id = aws_eip.picelip.id
 subnet_id     = aws_subnet.pictory-public-1.id

  tags = {
   Name = "gw NAT"
  }

  #To ensure proper ordering, it is recommended to add an explicit dependencyon the Internet Gateway for the VPC.
  #depends_on = [aws_eip.picelip]
}

# Internet route tables
resource "aws_route_table" "pictory-public-route" {
  vpc_id = aws_vpc.power.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.pictory-gw.id
  }

  tags = {
    Name = "pictory-public-rt"
  }
}

# NAT route tables
resource "aws_route_table" "pictory-nat-route" {
  vpc_id = aws_vpc.power.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_nat_gateway.picnat.id
  }

  tags = {
    Name = "pictory-nat-rt"
  }
}

# route associations public
resource "aws_route_table_association" "pic-private-1-a" {
  subnet_id      = aws_subnet.pictory-private-1.id
  route_table_id = aws_route_table.pictory-nat-route.id
}

resource "aws_route_table_association" "pic-private-2-a" {
  subnet_id      = aws_subnet.pictory-private-2.id
  route_table_id = aws_route_table.pictory-nat-route.id
}
resource "aws_route_table_association" "pic-public-1-a" {
  subnet_id      = aws_subnet.pictory-public-1.id
  route_table_id = aws_route_table.pictory-public-route.id
}

