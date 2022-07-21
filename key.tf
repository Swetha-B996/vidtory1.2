resource "aws_key_pair" "pickey" {
  key_name   = "pickey"
  public_key = file(var.PATH_TO_PUBLIC_KEY)
}
