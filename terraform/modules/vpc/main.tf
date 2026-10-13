resource "aws_vpc" "this" {
  cidr_block           = var.vpc_cidr
  instance_tenancy     = "default"
  enable_dns_hostnames = true
  enable_dns_support   = true

  tags = {
    Name = "main-vpc"
  }
}

resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.this.id

  tags = {
    Name = "main-igw"
  }
}

resource "aws_subnet" "public" {
  for_each = {
    "public-subnet-1" = {
      cidr_block        = var.public_subnet1_cidr
      availability_zone = var.aws_az_1
    }
    public-subnet-2 = {
      cidr_block        = var.public_subnet2_cidr
      availability_zone = var.aws_az_2
    }
  }

  vpc_id                  = aws_vpc.this.id
  cidr_block              = each.value.cidr_block
  availability_zone       = each.value.availability_zone
  map_public_ip_on_launch = false

  tags = {
    Name = each.key
    Tier = "public"
  }
}

resource "aws_subnet" "private" {
  for_each = {
    "private-subnet-1" = {
      cidr_block        = var.private_subnet1_cidr
      availability_zone = var.aws_az_1
    }
    "private-subnet-2" = {
      cidr_block        = var.private_subnet2_cidr
      availability_zone = var.aws_az_2
    }
  }

  vpc_id            = aws_vpc.this.id
  cidr_block        = each.value.cidr_block
  availability_zone = each.value.availability_zone

  tags = {
    Name = each.key
    Tier = "private"
  }
}

resource "aws_eip" "nat" {
  for_each = aws_subnet.public

  domain = "vpc"

  tags = {
    Name = "nat-eip-${each.key}"
  }
}


resource "aws_nat_gateway" "this" {
  for_each = aws_subnet.public

  allocation_id = aws_eip.nat[each.key].id
  subnet_id     = each.value.id

  tags = {
    Name = "nat-${each.key}"
  }

  depends_on = [aws_internet_gateway.igw]
}



resource "aws_route_table" "public" {
  vpc_id = aws_vpc.this.id

  route {
    cidr_block = var.internet_cidr
    gateway_id = aws_internet_gateway.igw.id
  }
  tags = {
    Name = "public-rt"
  }
}

resource "aws_route_table" "private" {
  for_each = {
    "private-subnet-1" = "public-subnet-1"
    "private-subnet-2" = "public-subnet-2"
  }

  vpc_id = aws_vpc.this.id

  route {
    cidr_block     = var.internet_cidr
    nat_gateway_id = aws_nat_gateway.this[each.value].id
  }

  tags = {
    Name = "private-rt-${each.key}"
  }
}


resource "aws_route_table_association" "public" {
  for_each = aws_subnet.public

  subnet_id      = each.value.id
  route_table_id = aws_route_table.public.id
}

resource "aws_route_table_association" "private" {
  for_each = aws_subnet.private

  subnet_id      = each.value.id
  route_table_id = aws_route_table.private[each.key].id
}