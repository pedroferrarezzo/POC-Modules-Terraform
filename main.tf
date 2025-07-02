module "ec2" {
  source        = "./modules/ec2"
  ami           = data.aws_ami.ubuntu.id
  instance_name = var.ec2_name
}

module "s3" {
  source        = "./modules/s3"
  instance_name = var.s3_name
  providers = {
    aws.sp = aws.sp
  }
}