# resource "aws_launch_template" "my_first_template" {
#     name = "my_first_template"
#     image_id = "ami-0c618421e207909d0"

#     # ami-0bb067f06d08ad2fb - recommended from com
#     instance_type = "t3.micro"

#     key_name = aws_key_pair.gen_key_pair.key_name

#     user_data = filebase64("user-data.sh")

#     network_interfaces {
#       associate_public_ip_address = true
#       security_groups = [aws_security_group.ec2_security_group.id]
#     }


#     tag_specifications {
#      resource_type = "instance"

#       tags = {
#         Name = "test"
#       }
#   }
# }


# resource "aws_autoscaling_group" "first_asg" {
#   desired_capacity   = 1
#   max_size           = 1
#   min_size           = 1
#   vpc_zone_identifier = data.aws_subnets.public.ids

#   launch_template {
#     id      = aws_launch_template.my_first_template.id
#     version = "$Latest"
#   }

# }


# resource "aws_security_group" "ec2_security_group" {
#   name        = "${var.app_name}-ec2-sg"
#   description = "HTTP traffic"
#   vpc_id      = data.aws_vpc.this.id


#    # Enable ssh external server connection:
#   ingress {
#     from_port   = 22
#     to_port     = 22
#     protocol    = "tcp"
#     cidr_blocks = ["0.0.0.0/0"]
#   }

#   ingress {
#     from_port   = 80
#     to_port     = 80
#     protocol    = "TCP"
#     cidr_blocks = ["0.0.0.0/0"]
#   }
#   egress {
#     from_port   = 0
#     to_port     = 0
#     protocol    = "-1"
#     cidr_blocks = ["0.0.0.0/0"]
#   }
# }





# resource "aws_lb_target_group" "asg_tg" {
#   name = "${var.app_name}-alb-asg-tg"

#   # Port might not be needed here "Port on which targets receive traffic,
#   # unless overridden when registering a specific target"
#   port        = 80
#   protocol    = "HTTP"
#   target_type = "instance"
#   vpc_id      = data.aws_vpc.this.id

#   health_check {
#     enabled  = true
#     path     = "/"
#     interval = 30
#   }

#   depends_on = [aws_alb.this]

# }

# resource "aws_alb" "this" {
#   name               = "${var.app_name}-asg-alb"
#   internal           = false
#   load_balancer_type = "application"

#   subnets = data.aws_subnets.public.ids

#   security_groups = [
#     aws_security_group.ec2_security_group.id,
#   ]
# }

# resource "aws_alb_listener" "this_listener" {
#   load_balancer_arn = aws_alb.this.arn
#   port              = 80
#   protocol          = "HTTP"

#   # Redirects to https, so people can't request via http
#   default_action {
#     type = "forward"
#     target_group_arn = aws_lb_target_group.asg_tg.arn
#   }
# }


# # Create a new ALB Target Group attachment
# resource "aws_autoscaling_attachment" "example" {
#   autoscaling_group_name = aws_autoscaling_group.first_asg.id
#   lb_target_group_arn    = aws_lb_target_group.asg_tg.arn
# }



# # Dont really need this cna use ec2 connect
# # Automatically generated key 'gen_tls_pk':
# resource "tls_private_key" "gen_tls_pk" {
#   algorithm = "RSA"
#   rsa_bits  = 4096
# }

# # Automatically generated key_pair 'gen_key_pair':
# resource "aws_key_pair" "gen_key_pair" {
#   key_name   = "ec2_key_pair"
#   public_key = tls_private_key.gen_tls_pk.public_key_openssh
# }

# # Saves a local file
# resource "local_file" "gen_key_pair" {
#   content  = tls_private_key.gen_tls_pk.private_key_pem
#   filename = "ec2_key_pair.pem"
# }
