//Begin by initializing Terraform configuration with the terraform block. This block sets up the necessary details regarding the providers that will be used in the configuration. In this case, the AWS provider is required.
terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

//Setting up the AWS provider with the provider block.I specified the region in which the resources will be created.
provider "aws" {
  region = "eu-west-1"
}

//Create a VPC using the aws_vpc resource.Specify a CIDR block for the VPC, as well as the Name tag with the value Terraform VPC.
resource "aws_vpc" "demo_vpc" {
  cidr_block = "10.0.0.0/16"

  tags = {
    Name = "Terraform VPC"
  }
}

//Creating two subnets within this VPC using the aws_subnet resource.And Making sure to reference the VPC ID and setting an appropriate CIDR block for each subnet.
resource "aws_subnet" "public_subnet" {
  vpc_id     = aws_vpc.demo_vpc.id
  cidr_block = "10.0.0.0/24"
}

resource "aws_subnet" "private_subnet" {
  vpc_id     = aws_vpc.demo_vpc.id
  cidr_block = "10.0.1.0/24"
}

//Creating an Internet gateway and attaching it to the VPC with the aws_internet_gateway resource.
resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.demo_vpc.id
}

//Creating a route table for the public subnet using the aws_route_table resource. This table will direct all traffic (0.0.0.0/0) to the Internet gateway.
resource "aws_route_table" "public_rtb" {
  vpc_id = aws_vpc.demo_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }
}

//Associating the route table with the public subnet using the aws_route_table_association resource.
resource "aws_route_table_association" "public_subnet" {
  subnet_id      = aws_subnet.public_subnet.id
  route_table_id = aws_route_table.public_rtb.id
}
