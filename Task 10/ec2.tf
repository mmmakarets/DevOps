provider "aws" {
  region = "eu-central-1"
}

data "aws_vpc" "lab12_mmmakarets_vpc" {
  default = true
}

data "aws_subnet_ids" "all" {
  vpc_id = data.aws_vpc.lab12_mmmakarets_vpc.id
}

data "aws_ami" "amazon_linux" {
  most_recent = true

  owners = ["amazon"]

  filter {
    name = "name"

    values = [
      "amzn-ami-hvm-*-x86_64-gp2",
    ]
  }

  filter {
    name = "owner-alias"

    values = [
      "amazon",
    ]
  }
}

resource "aws_security_group" "lab12_mmmakarets" {
  name        = "lab12_mmmakarets"
  description = "lab12_mmmakarets"
  vpc_id      = data.aws_vpc.lab12_mmmakarets_vpc.id

  ingress {
    description = "http"
    from_port   = 80
    to_port     = 80
    protocol    = "TCP"
    cidr_blocks = [ "0.0.0.0/0" ]
  }

  ingress {
    description = "ssh"
    from_port   = 22
    to_port     = 22
    protocol    = "TCP"
    cidr_blocks = [ "0.0.0.0/0" ]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = [ "0.0.0.0/0" ]
  }

  tags = {
    Name = "allow HTTP"
  }
}

resource "aws_network_interface" "this" {
  count     = 1
  subnet_id = tolist(data.aws_subnet_ids.all.ids)[count.index]
}

module "ec2_cluster" {
  source = "terraform-aws-modules/ec2-instance/aws"


  name                        = "lab12-mmmakarets"
  ami                         = data.aws_ami.amazon_linux.id
  instance_type               = "t2.micro"
  subnet_id                   = tolist(data.aws_subnet_ids.all.ids)[0]
  vpc_security_group_ids      = [aws_security_group.lab12_mmmakarets.id]
  associate_public_ip_address = true


  root_block_device = [
    {
      volume_type = "gp2"
      volume_size = 8
    }
  ]
  user_data = <<-EOF
    #!/bin/bash
    set -ex
    sudo yum update -y
    sudo amazon-linux-extras install docker -y
    sudo service docker start
    sudo usermod -a -G docker ec2-user
    sudo curl -L https://github.com/docker/compose/releases/download/1.25.4/docker-compose-$(uname -s)-$(uname -m) -o /usr/local/bin/docker-compose
    sudo chmod +x /usr/local/bin/docker-compose
    sudo docker network create wordpress-net
    sudo docker run -d --name=mysql --network=wordpress-net -e MYSQL_ROOT_PASSWORD=Admin1234% -e MYSQL_DATABASE=wordpress -e MYSQL_USER=wp_user -e MYSQL_PASSWORD=Passw04d mmmakarets/mmmakarets-mysql:1.0.4
    sudo docker run -d --name=wordpress --network=wordpress-net  -e WORDPRESS_DB_HOST=mysql -e WORDPRESS_DB_USER=wp_user -e WORDPRESS_DB_PASSWORD=Passw04d -e WORDPRESS_DB_NAME=wordpress -p 80:80 mmmakarets/mmmakarets-wordpress:1.0.5
  EOF
}