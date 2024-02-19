locals {
  ami = "ami-0780837dd83465d73"
  timestamp = formatdate("YYYY-MM-DD hh:mm ZZZ", timestamp())
}


resource "aws_instance" "app_server" {

    ami           = local.ami
    instance_type = var.aws_instance_type

    key_name               = aws_key_pair.gen_key_pair.key_name
    vpc_security_group_ids = [aws_security_group.renamed_security_group.id]


    user_data = "${file("scripts/setup.sh")}"

    tags = {
      Name = "Langchain demo"
    }

    # depends_on = [ aws_s3_bucket.example ]
    # run script on machine making tf apply command
    provisioner "local-exec" {
      working_dir = ".."
      command = "echo ${var.msg}"
    }

    # run script on machine provisioned
    # provisioner "remote-exec" {
    #   scripts = ["scripts/remote_exec.sh"]

    #   connection {
    #     type = "ssh"
    #     user = "ec2-user"
    #     private_key = tls_private_key.gen_tls_pk.private_key_pem
    #     host = self.public_dns
    #   }
    # }
    # copy files (takes a while)
    provisioner "file" {
      source = "../../langchain_demo_app/app"
      destination = "app/"

      connection {
        type = "ssh"
        user = "ec2-user"
        private_key = tls_private_key.gen_tls_pk.private_key_pem
        host = self.public_dns
      }
    }
}



# Automatically generated key 'gen_tls_pk':
resource "tls_private_key" "gen_tls_pk" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

# Automatically generated key_pair 'gen_key_pair':
resource "aws_key_pair" "gen_key_pair" {
  key_name   = var.key_pair_name
  public_key = tls_private_key.gen_tls_pk.public_key_openssh
}

# Saves a local file
resource "local_file" "gen_key_pair" {
  content  = tls_private_key.gen_tls_pk.private_key_pem
  filename = var.key_file
}

resource "aws_security_group" "renamed_security_group" {
  name  = "extl-secgroup"

  # Enable ssh external server connection:
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  dynamic "egress" {
    for_each = [22, 80]
    content {
      from_port   = egress.value
      to_port     = egress.value
      protocol    = "tcp"
      cidr_blocks = ["0.0.0.0/0"]
    }
  }
}


output "instance_public_dns" {
  value = aws_instance.app_server.public_dns
}