variable "vpc_name" {
  type    = string
  default = "felix-vpc-custom"
}

variable "public_subnet_cidrs" {
  type        = list(string)
  description = "Public Subnet CIDR values"
  default     = ["10.0.1.0/24", "10.0.2.0/24", "10.0.3.0/24"]
}

variable "private_subnet_cidrs" {
  type        = list(string)
  description = "Private Subnet CIDR values"
  default     = ["10.0.4.0/24", "10.0.5.0/24", "10.0.6.0/24"]
}

variable "azs" {
  type        = list(string)
  description = "Availability Zones"
  default     = ["eu-west-2a", "eu-west-2b", "eu-west-2c"]
}

variable "enable_nat_gateway" {
  type = bool
}


# Create a main route table for traffic within the VPC. This route table implicity
# Associated with all subnets in the VPC
resource "aws_vpc" "main" {
  cidr_block = "10.0.0.0/16"

  # This was needed to mount EFS to ECS tasks. For e.g it resolved the "Failed to resolve "fs-xxxxxxxxxxx.e...."
  # error on this page https://repost.aws/knowledge-center/fargate-unable-to-mount-efs
  enable_dns_hostnames = true

  tags = {
    Name = var.vpc_name
  }
}

resource "aws_subnet" "public_subnets" {
  count             = length(var.public_subnet_cidrs)
  vpc_id            = aws_vpc.main.id
  cidr_block        = element(var.public_subnet_cidrs, count.index)
  availability_zone = element(var.azs, count.index)

  tags = {
    Name   = "Public Subnet ${count.index + 1}"
    Public = "true"
  }
}

resource "aws_subnet" "private_subnets" {
  count             = length(var.private_subnet_cidrs)
  vpc_id            = aws_vpc.main.id
  cidr_block        = element(var.private_subnet_cidrs, count.index)
  availability_zone = element(var.azs, count.index)

  tags = {
    Name    = "Private Subnet ${count.index + 1}"
    Private = "true"
  }
}


# Subnet is only public when it is associated with an internet gateway
resource "aws_internet_gateway" "gw" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name = "Project VPC IG"
  }
}

# Specify route to internet gateway
resource "aws_route_table" "second_rt" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.gw.id
  }

  tags = {
    Name = "Route Table for IG"
  }
}


# Subnet is only public when it is associated with an internet gateway
# Creating this removes the implicit association of public subnets with
# the main route table
resource "aws_route_table_association" "public_subnet_asso" {
  count          = length(var.public_subnet_cidrs)
  subnet_id      = element(aws_subnet.public_subnets[*].id, count.index)
  route_table_id = aws_route_table.second_rt.id
}


# Creating an Elastic IP for the NAT Gateway
resource "aws_eip" "nat_gateway_eip" {
  count  = var.enable_nat_gateway ? length(var.public_subnet_cidrs) : 0
  domain = "vpc"
}


# Creating the NAT Gateway
resource "aws_nat_gateway" "nat_gateway" {
  count         = var.enable_nat_gateway ? length(var.public_subnet_cidrs) : 0
  allocation_id = element(aws_eip.nat_gateway_eip[*].id, count.index)
  subnet_id     = element(aws_subnet.public_subnets[*].id, count.index)

  tags = {
    Name = "${var.vpc_name}-nat-gw-${element(var.azs, count.index)}"
  }
}

# Creating the Route Table for the NAT Gateway
resource "aws_route_table" "nat_gateway_rt" {
  count  = var.enable_nat_gateway ? length(var.public_subnet_cidrs) : 0
  vpc_id = aws_vpc.main.id
  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.nat_gateway[count.index].id
  }

  tags = {
    Name = "${var.vpc_name}-rt-for-nat-gw-${element(var.azs, count.index)}"
  }
}

resource "aws_route_table_association" "private_subnet_asso" {
  count          = var.enable_nat_gateway ? length(var.private_subnet_cidrs) : 0
  subnet_id      = element(aws_subnet.private_subnets[*].id, count.index)
  route_table_id = element(aws_route_table.nat_gateway_rt[*].id, count.index)
}

output "vpc_name" {
  value = var.vpc_name
}


# Use 3rd party module to build VPC easily
# data "aws_availability_zones" "available_zones" {
#   state = "available"
# }

# variable "vpc_module_name" {
#   type    = string
#   default = "felix-vpc"
# }
# module "vpc" {
#   source = "terraform-aws-modules/vpc/aws"

#   name = var.vpc_module_name
#   cidr = "10.0.0.0/16"

#   # For multiple AZs (slower to deploy)
#   azs             = data.aws_availability_zones.available_zones.names
#   private_subnets = ["10.0.1.0/24", "10.0.2.0/24", "10.0.3.0/24"]
#   public_subnets  = ["10.0.101.0/24", "10.0.102.0/24", "10.0.103.0/24"]

#   enable_nat_gateway = true
#   enable_vpn_gateway = false # Not sure what this is so turn off


#   # used to pick up in data resources
#   private_subnet_tags = {
#     Private = "true"
#   }

#   public_subnet_tags = {
#     Public = "true"
#   }

#   tags = {
#     Terraform = "true"
#   }
# }

# output "vpc_id" {
#   value = module.vpc.vpc_id
# }
