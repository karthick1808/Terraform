provider "aws" {
  region = "ap-south-1"
}
resource "tls_private_key" "generated" {
  algorithm = "RSA"
}
resource "local_file" "private_key_pem" {
  content  = tls_private_key.generated.private_key_pem
  filename = "MyAWSKey.pem"
}

data "aws_ami" "ubuntu" {
  most_recent = true
  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-focal-20.04-amd64-server-*"]
  }
  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
  owners = ["099720109477"] # Canonical
}

resource "aws_instance" "web" {
  ami           = data.aws_ami.ubuntu.id
  instance_type = "t2.micro"
  subnet_id     = "subnet-0adb769213c3b9495"
  key_name      = "MyAWSKey"
  connection {
    user        = "ubuntu"
    private_key = tls_private_key.generated.private_key_pem
    host        = self.public_ip
  }
  provisioner "local-exec" {
    command = "chmod 600 ${local_file.private_key_pem.filename}"
  }
  provisioner "remote-exec" {
    inline = [
      "sudo rm -rf /tmp",
      "sudo git clone https://github.com/hashicorp/demo-terraform-101 /tmp",
      "sudo sh /tmp/assets/setup-web.sh",
    ]
  }
  lifecycle {
    ignore_changes = [security_groups]
  }

  security_groups             = ["sg-0f8054f1305fff807"]
  associate_public_ip_address = true
  tags = {
    Name = "Terraform Deploy"
  }
}

resource "aws_key_pair" "deployer" {
  key_name   = "MyAWSKey"
  public_key = tls_private_key.generated.public_key_openssh
  lifecycle {
    ignore_changes = [key_name]
  }
}

resource "aws_security_group" "allow_ssh" {
  name        = "allow_ssh"
  description = "Allow TLS inbound traffic"
  vpc_id      = "vpc-076db3707c243e669"

  ingress {
    description      = "TLS from VPC"
    from_port        = 22
    to_port          = 80
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  tags = {
    Name = "allow_ssh"
  }
}

resource "aws_instance" "ubuntu" {
  ami           = data.aws_ami.ubuntu.id
  instance_type = "t2.micro"
  subnet_id     = "subnet-0adb769213c3b9495"
  key_name      = "MyAWSKey"
  connection {
    user        = "ubuntu"
    private_key = tls_private_key.generated.private_key_pem
    host        = self.public_ip
  }
  provisioner "local-exec" {
    command = "chmod 600 ${local_file.private_key_pem.filename}"
  }
  provisioner "remote-exec" {
    inline = [
      "sudo rm -rf /tmp",
      "sudo git clone https://github.com/hashicorp/demo-terraform-101 /tmp",
      "sudo sh /tmp/assets/setup-web.sh",
    ]
  }
  lifecycle {
    ignore_changes = [security_groups]
  }

  security_groups             = ["sg-0f8054f1305fff807"]
  associate_public_ip_address = true
  tags = {
    Name = "Terraform Deploy"
  }
}