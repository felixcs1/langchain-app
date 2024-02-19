
variable "instance_name" {
  type = string
  default = "LangChain Demo"
}


variable "aws_instance_type" {
  default = "t2.micro"
  description = "Size of instance"
}


variable "key_pair_name" {
    type = string
    default = "my_aws_key"
}

variable "key_file" {
    type = string
    default = "scripts/my_aws_key.pem"
}

variable "msg" {
  type = string
  default = "hello world"
}

