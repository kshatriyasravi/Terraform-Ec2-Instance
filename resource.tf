# Here we are trying to define the resource for the EC2 instance.
# To define the ec2-instance we need to deifine few things like:
# 1. AMI ID (Amazon Machine Image)
# 2. Instance Type (t2.micro, t2.small, t2.medium etc)
# 3. Key Name (SSH key and pem file)
# 4. vpc (cidr,ip-address-range)
# 5. subnet (Public or Private)
# 6. security group for the instance
# 7. internet gateway & Load balancer (ELB & ALB)
# 8. routing table (route53 & route)
# 9. tags (Name, Environment, Owner etc)

# Here you have created a vpc
resource "aws_vpc" "vpc_instance" {
  cidr_block           = "10.0.0.0/16" # Here we are defining the cidr block for the VPC like ip address 
  enable_dns_hostnames = true
  enable_dns_support   = true
  tags = {
    Name = "terraform-vpc"
  }
}

# Here you have created a public subnet & Private subnet and connected to vpc
# Punlic subnet is used to connect the instance to the internet via IGW (Internet Gateway)
# Allows instances in the VPC to connect to the internet.
#Example : Public subent used in the web server, where the instance can connect to the internet
# Webserver real time examples are like: Apache, Nginx, Tomcat etc
resource "aws_subnet" "public-subnet" {
  vpc_id     = aws_vpc.vpc_instance.id # Here we are connecting the vpc to this subnet
  cidr_block = "10.0.1.0/24"           # Here we are defining the cidr block for the subnet like ip address 
}

# Private subnet is used to connect the instance to the internet via NAT Gateway
# Allows instances in the VPC to connect to the internet.
#Example : Private subent used in the database server, where the instance can't connect to the internet
# Database server real time examples are like: MySQL, Oracle, SQL Server etc
resource "aws_subnet" "private_subnet" {
  vpc_id     = aws_vpc.vpc_instance.id
  cidr_block = "10.0.2.0/24" # Here we are defining the cidr block for the subnet like ip address  
}

# This is an internet gateway were it's used to connect the VPC to the internet.
# Allows instances in the VPC to connect to the internet.
resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.vpc_instance.id # Here we are tagging the IGW to the VPC
  tags = {
    Name = "terraform-igw"
  }
}

# This is a route table were it's used to route the traffic from the VPC to the internet.
# Directs traffic within the VPC and to the internet via the IGW.
resource "aws_route_table" "route_table" {
  vpc_id = aws_vpc.vpc_instance.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id # Here we are connecting the route table to the IGW
  }
  tags = {
    Name = "terraform-route-table"
  }
}
# This is a route table association were it's used to associate the route table to the subnet.
resource "aws_route_table_association" "route_table_association_public_subnet" {
  subnet_id      = aws_subnet.public-subnet.id
  route_table_id = aws_route_table.route_table.id
}

# Here we are defining the instance details like AMI, Instance type, Key name, security_group
resource "aws_instance" "terraform_instance" {
  ami           = "ami-12345678" # Replace with a valid AMI ID
  instance_type = "t2.micro"     # Replace with desired instance type
  tags = {
    Name = "terraform-instance"
  }
  security_groups = [aws_security_group.terraform_security_instance.name] # Here we are connecting the security group to the instance
}

# Here we are defining the security group for the instance, so that we can allow the traffic at instance level
resource "aws_security_group" "terraform_security_instance" {
  name        = "terraform-sg"
  description = "Allow couple of rules for access "
  vpc_id      = aws_vpc.vpc_instance.id

  # Rule 1. Allow all inbound traffic on port 22 (SSH) (incoming traffic)
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    description = "Allow SSH from anywhere"
  }

  # Rule 2 Allow all http traffic from internet (incoming traffic)
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    description = "Allow HTTP from anywhere"
  }

  # Rule 3 Allow Internal communication to the instance (incoming traffic)
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["10.0.0.0/16"]
    description = "Allow internal communication with in the vpc to the instance"
  }

  # Rule 4 Allow all outbound traffic from the instance (outgoing traffic)
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "terraform-sg"
  }
}

# Load Balancer
resource "aws_lb" "application_load_balancer" {
  name               = "my-alb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.terraform_security_instance.id]
  subnets            = [aws_subnet.public-subnet.id]

  enable_deletion_protection = false

  tags = {
    Name = "my-alb"
  }
}

# Target Group for the Load Balancer
resource "aws_lb_target_group" "target_group" {
  name     = "my-targets"
  port     = 80
  protocol = "HTTP"
  vpc_id   = aws_vpc.vpc_instance.id

  health_check {
    path                = "/"
    interval            = 30
    timeout             = 5
    healthy_threshold   = 2
    unhealthy_threshold = 2
  }
}

# Listener for the Load Balancer
resource "aws_lb_listener" "listener" {
  load_balancer_arn = aws_lb.application_load_balancer.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.target_group.arn
  }
}
