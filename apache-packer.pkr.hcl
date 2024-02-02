packer {
  required_plugins {
    amazon = {
      version = "~> 1.3"
      source  = "github.com/hashicorp/amazon"
    }
    ansible = {
      version = "~> 1.1"
      source  = "github.com/hashicorp/ansible"
    }
  }
}

variable "associate_public_ip_address" {
  type    = string
  default = "true"
}
variable "base_ami" {
  type    = string
  default = "ami-007855ac798b5175e"
}
variable "instance_type" {
  type    = string
  default = "t2.micro"
}
variable "region" {
  type    = string
  default = "us-east-1"
}
variable "app_name" {
  type    = string
  default = "WebApp"
}
variable "ssh_username" {
  type    = string
  default = "ubuntu"
}

locals {
  timestamp = formatdate("DD_MM_YYYY-hh_mm", timestamp())
}

source "amazon-ebs" "static-web-ami" {
  ami_name                    = "${var.app_name}-${local.timestamp}"
  associate_public_ip_address = "${var.associate_public_ip_address}"
  instance_type               = "${var.instance_type}"
  region                      = "${var.region}"
  source_ami                  = "${var.base_ami}"
  ssh_username                = "${var.ssh_username}"

  iam_instance_profile        = "LabInstanceProfile"

  tags = {
    Name = "${var.app_name}"
  }
}

variable "httpd_port" {
  type    = string
  default = "80" # Port par défaut pour HTTPD, remplacez-le par le port souhaité
}

build {
  sources = ["source.amazon-ebs.static-web-ami"]
  provisioner "ansible" {
    playbook_file = "./repo/play.yml" # Assurez-vous que le chemin est correct
    extra_arguments = ["-e", "httpd_port=${var.httpd_port}"]
    use_proxy = false
  }
}