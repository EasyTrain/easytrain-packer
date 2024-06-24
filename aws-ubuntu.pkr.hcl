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
      "sudo apt install openjdk-21-jdk -y",
    ]
  }

  provisioner "shell" {
    script = "postgres-setup.sh"
  }

  provisioner "shell" {
    script = "insert-stations.sh"
  }

  provisioner "file" {
    source      = "pg_hba.conf"
    destination = "/home/ubuntu/"
  }

  provisioner "shell" {
    inline = [
      "mkdir -p /home/ubuntu/app",
      # allow remote access to server, required for pg admin
      "sudo sed -i '60s/localhost/*/' /etc/postgresql/16/main/postgresql.conf",
      "sudo chown postgres:postgres pg_hba.conf",
      "sudo cp /home/ubuntu/pg_hba.conf /etc/postgresql/16/main/pg_hba.conf"
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
      "sudo chmod +x easytrain.service",
      "sudo chown root:root easytrain.service",
      "sudo mv /home/ubuntu/easytrain.service /etc/systemd/system/"
    ]
  }

  provisioner "shell" {
    inline = [
      "echo Enable easytrain.service...",
      "sudo systemctl enable easytrain.service",
      "sudo systemctl start easytrain.service"
    ]
  }

  provisioner "file" {
    source      = "/home/jacques-navarro/Documents/easytrain/api-payments"
    destination = "/home/ubuntu/app"
  }

  provisioner "shell" {
    inline = [
      "echo Packaging API-Payments application...",
      "cd /home/ubuntu/app/api-payments",
      "./mvnw clean package -DskipTest -U"
    ]
  }

  provisioner "file" {
    source      = "api-payments.service"
    destination = "/home/ubuntu/"
  }

  provisioner "shell" {
    inline = [
      "echo Moving api-payments.service to /etc/systemd/system",
      "sudo chmod +x api-payments.service",
      "sudo chown root:root api-payments.service",
      "sudo mv /home/ubuntu/api-payments.service /etc/systemd/system/"
    ]
  }

  provisioner "shell" {
    inline = [
      "echo Enable api-payments.service...",
      "sudo systemctl enable api-payments.service",
      "sudo systemctl start api-payments.service"
    ]
  }

}
