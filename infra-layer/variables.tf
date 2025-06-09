variable "region" {
  default = "eu-north-1"
}

variable "azs" {
  type    = list(string)
  default = ["eu-north-1a", "eu-north-1b", "eu-north-1c"]
}

variable "environment_identifier" {}