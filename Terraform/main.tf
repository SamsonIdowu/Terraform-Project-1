provider "aws" {
    region = "us-east-1"  
}


variable vpc_cidr_bloc {}
variable subnet_cidr_block {}
variable avail_zone {}
variable env_prefix {}
variable myip_address {}
variable allowed_ip_addresses {}
variable public_key {}
variable private_key {}
variable script {}
variable Dockerfile {}
variable app {}


// vpc configuration
resource "aws_vpc" "DevOps-Lab" {
  cidr_block = var.vpc_cidr_bloc
  tags = {
    Name = "${var.env_prefix}-vpc"
  }
}

// subnet configuration
resource "aws_subnet" "DevOps-Lab-Subnet" {
  vpc_id     = aws_vpc.DevOps-Lab.id
  cidr_block = var.subnet_cidr_block
  availability_zone = var.avail_zone
  tags = {
    Name = "${var.env_prefix}-subnet"
  }
}

// route table configuration
resource "aws_default_route_table" "DevOps-Lab-route-table" {
  default_route_table_id =  aws_vpc.DevOps-Lab.default_route_table_id
  
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.DevOps-Lab-igw.id
  }
  tags = {
    Name = "${var.env_prefix}-routetable"
  }
}

// internet gateway configuration
resource "aws_internet_gateway" "DevOps-Lab-igw" {
  vpc_id     = aws_vpc.DevOps-Lab.id
  tags = {
    Name = "${var.env_prefix}-igw"
  }
}

// network security group configuration
resource "aws_default_security_group" "default-sg" {
  vpc_id     = aws_vpc.DevOps-Lab.id
  ingress {
    protocol = "tcp"
    from_port = 80
    to_port = 80
    cidr_blocks = [ "${var.allowed_ip_addresses}" ]
  }
  ingress {
    protocol = "tcp"
    from_port = 22
    to_port = 22
    cidr_blocks = [ "${var.myip_address}" ]
  }
  egress {
    protocol = "-1"
    from_port = 0
    to_port = 0
    cidr_blocks = [ "0.0.0.0/0" ]
    prefix_list_ids = []
  }
  tags = {
    Name = "${var.env_prefix}-default-sg"
  }
}

// source for latest ubuntu ami 
data "aws_ami" "latest-ubuntu-ami" {
  most_recent = true
  owners = ["amazon"]
  filter {
    name = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-jammy-22.04-amd64-server-*"]
  } 
}

// output ami id on stdout
output "aws_ami_id" {
    value = data.aws_ami.latest-ubuntu-ami.id
  }

// EC2 instance configuration
resource "aws_instance" "testifi-vm" {
  ami = data.aws_ami.latest-ubuntu-ami.id
  instance_type = "t2.micro"

  vpc_security_group_ids = [ aws_default_security_group.default-sg.id ]
  subnet_id = aws_subnet.DevOps-Lab-Subnet.id
  availability_zone = var.avail_zone
  associate_public_ip_address = true
  key_name = aws_key_pair.ssh-key.key_name
  tags = {
    Name = "${var.env_prefix}-server"
  }
}

// deploying the application using docker over ssh
resource "null_resource" "docker_app_exec" {    
    connection {
    type = "ssh"
    host = aws_instance.testifi-vm.public_ip
    user = "ubuntu"
    private_key = file(var.private_key)
    }
  
  // copying the container provisioning script to the newly provisioned EC2
  provisioner "file" {
    source      = "${var.script}"
    destination = "/tmp/script.sh"
  }

  // copying the dockerfile to the newly provisioned EC2
  provisioner "file" {
    source      = "${var.Dockerfile}"
    destination = "Dockerfile"
  }
  
  // copying the html app to the newly provisioned EC2
  provisioner "file" {
    source      = "${var.app}"
    destination = "index.html"
  }

  // making the script file to executable and executing on newly provisioned EC2
  provisioner "remote-exec" {
    inline = [
      "sudo chmod +x /tmp/script.sh",
      "/tmp/script.sh args"
    ]
  }

  depends_on = [ aws_instance.testifi-vm ]

}

// outputs public ip address in stdout
output "ec2_public_ip" {
  value = aws_instance.testifi-vm.public_ip
}

// ssh-key pair config
resource "aws_key_pair" "ssh-key" {
  key_name = "server-ssh-key"
  public_key = file(var.public_key)
}