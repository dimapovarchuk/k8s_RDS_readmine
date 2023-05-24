
variable "access_key" {
  default = "~/.ssh/aws_access_key"
}
variable "secret_key" {
  default = "~/.ssh/aws_secret_key"
}

variable "zone" {
  default = "us-east-1b"
}
variable "user_name" {
  default = "ubuntu"
}


variable "ssh_public_key" {
  default = "~/.ssh/public-aws"
}
variable "ssh_private_key" {
  default = "~/.ssh/my-aws-keys.pem"
}

//Database
variable "db_adapter" {
  default ="postgresql"
}
variable "db_name" {
  default ="db.name.secret"
}
variable "db_user_name" {
  default ="db.username.secret"
}
variable "db_password" {
  default ="db.pass.secret"
}

variable "secret_key_redmine" {
  default ="session.key.secret"
}

