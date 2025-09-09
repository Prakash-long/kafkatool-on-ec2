provider "aws" {
  region = var.region
}

# -----------------------------
# VPC + Subnet + IGW + Route Table
# -----------------------------
resource "aws_vpc" "kafka_vpc" {
  cidr_block = "10.0.0.0/16"
  tags       = { Name = "kafka-vpc" }
}

resource "aws_internet_gateway" "kafka_igw" {
  vpc_id = aws_vpc.kafka_vpc.id
  tags   = { Name = "kafka-igw" }
}

resource "aws_subnet" "kafka_subnet" {
  vpc_id                   = aws_vpc.kafka_vpc.id
  cidr_block               = "10.0.1.0/24"
  availability_zone        = "${var.region}a"
  map_public_ip_on_launch  = true
  tags = { Name = "kafka-subnet" }
}

resource "aws_route_table" "kafka_rt" {
  vpc_id = aws_vpc.kafka_vpc.id
  tags   = { Name = "kafka-rt" }
}

resource "aws_route_table_association" "kafka_rta" {
  subnet_id      = aws_subnet.kafka_subnet.id
  route_table_id = aws_route_table.kafka_rt.id
}

resource "aws_route" "kafka_internet_route" {
  route_table_id         = aws_route_table.kafka_rt.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.kafka_igw.id
}

# -----------------------------
# Security Group
# -----------------------------
resource "aws_security_group" "kafka_sg" {
  name   = "kafka-sg"
  vpc_id = aws_vpc.kafka_vpc.id

  # SSH from your IP
  ingress {
    description = "SSH from my IP"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = [var.my_ip]
  }

  # Kafka Broker Port
  ingress {
    description = "Kafka Broker"
    from_port   = 9092
    to_port     = 9092
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Kafka Controller Port
  ingress {
    description = "Kafka Controller"
    from_port   = 9093
    to_port     = 9093
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Outbound
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = { Name = "kafka-sg" }
}

# -----------------------------
# Key Pair
# -----------------------------
resource "aws_key_pair" "deployer" {
  key_name   = "test3"
  public_key = file(var.key_pub_path)
}

# -----------------------------
# Kafka EC2 Instances
# -----------------------------
resource "aws_instance" "kafka" {
  count                       = var.kafka_instance_count
  ami                         = var.ami
  instance_type               = var.instance_type
  subnet_id                   = aws_subnet.kafka_subnet.id
  vpc_security_group_ids      = [aws_security_group.kafka_sg.id]
  key_name                    = aws_key_pair.deployer.key_name
  associate_public_ip_address = true

  tags = {
    Name = "kafka-${count.index + 1}"
  }
}
