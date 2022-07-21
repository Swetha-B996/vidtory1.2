data "aws_ami" "ubuntu" {
  most_recent = true

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-focal-20.04-amd64-server-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  owners = ["099720109477"] # Canonical
}
# ---------------------------------------------------------------------------------------------------------------------
# CREATE THE AUTO SCALING GROUP
# ---------------------------------------------------------------------------------------------------------------------
resource "aws_autoscaling_group" "pic-autoscale" {
  name                  = "pic-as"

  launch_configuration = "${aws_launch_configuration.pic-launch.name}"
  
  vpc_zone_identifier = [aws_subnet.pictory-private-1.id, aws_subnet.pictory-private-2.id]

  min_size = 2
  
  max_size = 4
  
  target_group_arns = ["${aws_lb_target_group.lbtg.arn}"]

  wait_for_capacity_timeout = "5m"

  tag {
    key                 = "Name"
    value               = "insta-up"
    propagate_at_launch = true
  }
}


# ---------------------------------------------------------------------------------------------------------------------
# CREATE A LAUNCH CONFIGURATION THAT DEFINES EACH EC2 INSTANCE IN THE ASG
# ---------------------------------------------------------------------------------------------------------------------
resource "aws_launch_configuration" "pic-launch" {
  
  name          = "pic_config"
  image_id      = data.aws_ami.ubuntu.id
  instance_type = "t2.micro"
  security_groups = [aws_security_group.pic-allow-ssh.id ]
  key_name      = aws_key_pair.pickey.key_name
  user_data = <<-EOF
#!/bin/bash
sudo apt -get update
sudo apt install -y apache2
sudo systemctl status apache2
sudo systemctl start apache2
sudo chown -R $USER:$USER /var/www/html
sudo echo "<html><body><h1> Hello Pictory Team <h1></body></html>" > /var/www/html/index.html
EOF

# This device contains homePath
  ebs_block_device {
    device_name           = "/dev/xvdb"
    volume_size           = 8
    volume_type           = "gp2"
#    encrypted             = true
    delete_on_termination = true
  }

#   ebs_block_device {
#     device_name           = "/dev/xvdc"
#     volume_size           = 8
#     volume_type           = "gp2"
# #    encrypted             = true
#     delete_on_termination = true
#   }

  lifecycle {
    create_before_destroy = true
  }
}