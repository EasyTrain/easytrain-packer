packer {
  required_plugins {
    amazon = {
      version = ">= 1.2.8"
      source  = "github.com/hashicorp/amazon"
    }
  }
}

source "amazon-ebs" "ubuntu" {
  ami_name      = "aws-ubuntu-easytrain"
  instance_type = "t2.micro"
  region        = "eu-central-1"

  source_ami_filter {
    filters = {
      name                = "ubuntu/images/*ubuntu-noble-24.04-amd64-server-*"
      root-device-type    = "ebs"
      virtualization-type = "hvm"
    }

    most_recent = true
    owners      = ["622229127833"]
  }

  ssh_username = "ubuntu"
}

build {
  name = "ubuntu:noble"
  sources = [
    "source.amazon-ebs.ubuntu-noble"
  ]

  provisioner "shell" {
    inline = [
      "sleep 10",
      "sudo apt update -y",
      "echo installing OpenJDK",
      "sudo apt install openjdk-21-jre -y",
    ]
  }
}