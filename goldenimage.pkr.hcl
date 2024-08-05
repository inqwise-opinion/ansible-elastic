// packer build -var 'tag=1.27.0' .
// packer build .
// packer build  .
packer {
  required_plugins {
    amazon = {
      version = ">= 1.2.2" # preferably "~> 1.2.0" for latest patch version
      source = "github.com/hashicorp/amazon"
    }
  }
}

locals {
  timestamp = formatdate("YYYYMMDDhhmm", timestamp())
}

source "amazon-ebs" "amazon_linux2023" {
  force_deregister      = true
  force_delete_snapshot = true
  ami_name              = "${var.app}-${var.tag}"
  ami_description       = "Image of ${var.app} version ${var.tag}"
  instance_type         = "t4g.medium"
  region                = "il-central-1"
  #ami_regions           = ["us-west-2"]
  encrypt_boot          = false
  profile               = "${var.aws_profile}"
  iam_instance_profile  = "PackerRole"
  ssh_username = "ec2-user"
  security_group_id = "sg-0e11a618872a5a387"
  subnet_id = "subnet-0f46c97c53ea11e2e"
  associate_public_ip_address = true
  spot_price            = "auto"
  
  metadata_options {
    instance_metadata_tags = "enabled"
    http_endpoint               = "enabled"
    http_put_response_hop_limit = "1"
    http_tokens                 = "required"
  }

  source_ami_filter {
    filters = {
      name                = "al2023-*-kernel-6.1-arm64"
      root-device-type    = "ebs"
      virtualization-type = "hvm"
    }
    most_recent = true
    owners      = ["amazon"]
  }
  
  run_tags = {
    Name      = "${var.app}-${var.tag}-packer"
    app       = "${var.app}"
    version   = "${var.tag}"
    timestamp = "${local.timestamp}"
    playbook_name = "ansible-${var.app}"
  }

  tags = {
    Name      = "${var.app}-${var.tag}"
    app       = "${var.app}"
    version   = "${var.tag}"
    timestamp = "${local.timestamp}"
    playbook_name = "ansible-elastic"
  }
}

build {
  name = "packer"
  sources = [
    "source.amazon-ebs.amazon_linux2023"
  ]

  provisioner "shell" {
    inline = [
      "curl -s https://raw.githubusercontent.com/inqwise/ansible-automation-toolkit/default/goldenimage_script.sh | bash -s --"
    ]
  }

  post-processor "manifest" {
    output     = "manifest.json"
    strip_path = true
  }
}
