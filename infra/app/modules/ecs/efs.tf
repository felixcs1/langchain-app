resource "aws_efs_file_system" "efs_volume" {


  tags = {
    Name = "ECS-EFS-FS"
  }

}

resource "aws_efs_mount_target" "ecs_temp_space_az0" {

  for_each = toset(data.private_subnets.ids)

  file_system_id = aws_efs_file_system.efs_volume.id
  subnet_id      = each.value

  security_groups = [aws_security_group.ingress_for_efs.id]
}
