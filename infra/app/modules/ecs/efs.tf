resource "aws_efs_file_system" "efs_volume" {


  tags = {
    Name = "ECS-EFS-FS"
  }

}


resource "aws_efs_mount_target" "ecs_temp_space_az0" {

  for_each = toset(data.aws_subnets.private.ids)

  file_system_id = aws_efs_file_system.efs_volume.id
  subnet_id      = each.value

  security_groups = [aws_security_group.ingress_for_efs.id]
}

# resource "aws_efs_access_point" "default" {
#   file_system_id = aws_efs_file_system.efs_volume.id

#   # root_directory {
#   #   creation_info {
#   #     owner_gid   = 0
#   #     owner_uid   = 0
#   #     permissions = 755
#   #   }
#   #   path = "/ollama-models"
#   # }
# }
