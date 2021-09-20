resource "aws_security_group" "sg77789" {
  name        = var.sgname
  description = "Security group for nodes"

  ingress = [
    {
      description      = "This is for HTTP"
      from_port        = 80
      to_port          = 80
      protocol         = "tcp"
      cidr_blocks      = ["0.0.0.0/0"]
      ipv6_cidr_blocks = ["::/0"]
      prefix_list_ids = []
      security_groups = []
      self = true
    },
   
    {
      description      = "This is for Jenkins"
      from_port        = 8080
      to_port          = 8080
      protocol         = "tcp"
      cidr_blocks      = ["0.0.0.0/0"]
      ipv6_cidr_blocks = ["::/0"]
      prefix_list_ids = []
      security_groups = []
      self = true
    },

    {
      description      = "This is for SSH"
      from_port        = 22
      to_port          = 22
      protocol         = "tcp"
      cidr_blocks      = ["0.0.0.0/0"]
      ipv6_cidr_blocks = ["::/0"]
      prefix_list_ids = []
      security_groups = []
      self = true
    }
  ]

  egress = [
    {
      description = "This is Egress"
      from_port        = 0
      to_port          = 0
      protocol         = "-1"
      cidr_blocks      = ["0.0.0.0/0"]
      ipv6_cidr_blocks = ["::/0"]
      prefix_list_ids = []
      security_groups = []
      self = true
    }
  ]

  tags = {
    Name = "Security Group"
  }
}



resource "aws_instance" "node1" {
  ami           = var.redhatami
  instance_type = var.instancetype
  security_groups = [ var.sgname ]
  key_name        = "rohit"
  user_data = <<-EOF
		#!/bin/bash
		sudo useradd user1; echo -e "singhsaini\nsinghsaini" | passwd user1
		sudo echo "user1 ALL=(ALL) NOPASSWD: ALL" >> /etc/sudoers
		sudo sed -i 's/PasswordAuthentication no/PasswordAuthentication yes/g' /etc/ssh/sshd_config
		sudo systemctl restart sshd
               EOF
  
tags = {
    Name = var.node1
  }
 
 provisioner "local-exec" {
    command = "echo ' ' > hosts"
  }

 provisioner "local-exec" {
    command = "echo Redhat ${self.public_ip} >> hosts"
  }
}


resource "aws_instance" "node2" {
  ami           = var.ubuntuami
  instance_type = var.instancetype
  security_groups = [ var.sgname ]
  key_name        = "rohit"
  user_data = <<-EOF
		#!/bin/bash
		sudo useradd user1; echo -e "singhsaini\nsinghsaini" | passwd user1
		sudo echo "user1 ALL=(ALL) NOPASSWD: ALL" >> /etc/sudoers
		sudo sed -i 's/PasswordAuthentication no/PasswordAuthentication yes/g' /etc/ssh/sshd_config
		sudo systemctl restart sshd
               EOF

tags = {
    Name = var.node2
  }

  provisioner "local-exec" {
    command = "echo Ubuntu ${self.public_ip} >> hosts"
  }
}



resource "null_resource" "nullremote1" {
depends_on = [aws_instance.node2]
connection {
 type     = "ssh"
 user     = var.ansibleuser
 password = var.ansiblepass
 host     = var.ansibleIP
}

#copying the ip.txt file to the Ansible control node from local system

provisioner "file" {
    source      = "hosts"
    destination = "/home/user1/hosts"
       }
}