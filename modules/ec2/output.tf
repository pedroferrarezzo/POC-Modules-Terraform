output "instance_id" {
    value = aws_instance.this-count[0].id
}

output "public_ip" {
    value = aws_instance.this-count[0].public_ip
}

output "regex_ec2" {
    value = length(regexall("^[a-z0-9]+-(aula|live)+-(fiap|alura)+-[0-9]+-(prod|stage|dev)", var.instance_name))
}