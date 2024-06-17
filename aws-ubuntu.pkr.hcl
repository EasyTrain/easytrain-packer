packer {
  required_plugins {
    amazon = {
      version = ">= 1.2.8"
      source  = "github.com/hashicorp/amazon"
    }
  }
}

source "amazon-ebs" "easytrain-ubuntu" {
  profile       = "easytrain"
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
    owners      = ["099720109477"]
  }

  ssh_username = "ubuntu"
}

build {
  name = "ubuntu:noble"
  sources = [
    "source.amazon-ebs.easytrain-ubuntu"
  ]

  provisioner "shell" {
    inline = [
      "sleep 10",
      "sudo apt update -y",
      "echo installing OpenJDK",
      "sudo apt install openjdk-21-jre -y",
    ]
  }

  provisioner "shell" {
    script = "postgres-setup.sh"
  }

  provisioner "shell" {
    inline = [
      "mkdir /home/ubuntu/app"
    ]
  }

  provisioner "file" {
    source      = "/home/jacques-navarro/Documents/easytrain/application"
    destination = "/home/ubuntu/app"
  }

  provisioner "shell" {
    inline = [
      "echo Packaging Java application...",
      "cd /home/ubuntu/app/application",
      "./mvnw clean package -DskipTests -U"
    ]
  }

  provisioner "file" {
    source      = "easytrain.service"
    destination = "/home/ubuntu/"
  }

  provisioner "shell" {
    inline = [
      "echo Moving easytrain.service to /etc/systemd/system",
      "sudo mv /home/ubuntu/easytrain.service /etc/systemd/system/"
    ]
  }

  provisioner "shell" {
    inline = [
      "echo Enable easytrain.service...",
    "sudo systemctl enable easytrain.service"]
  }

}