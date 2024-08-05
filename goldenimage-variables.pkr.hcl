variable "base_path" {
    type = string
    default = "s3://bootstrap-opinion-stg/playbooks"
}

variable "tag" {
  type    = string
  default = "latest"
}

variable "app" {
  type    = string
  default = "elastic"
}

variable "extra" {
  default = {
    private_domain = "opinion-stg.local"
  }
}

variable "aws_profile" {
  default = "opinion-stg"
}