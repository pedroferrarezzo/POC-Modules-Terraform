resource "aws_instance" "this-count" {
    count = 2
    ami = var.ami
    instance_type = var.instance_type
    tags = {
        Name = var.instance_name
    }
}

resource "aws_instance" "this-loop" {
    for_each = toset(["t3.medium","t3.micro"]) # também poderiamos usar uma variável list ou map
    ami = var.ami
    instance_type = each.key
    tags = {
        Name = var.instance_name
    }
}