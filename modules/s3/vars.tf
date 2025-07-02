variable "instance_name" {
    description = "nome definido para instancia"

    validation {
    condition = can(regex("^[a-z0-9]+-(aula|live)+-(fiap|alura)+-[0-9]+-(prod|stage|dev)$", var.instance_name))
    error_message = "O nome da instância deve seguir o padrão: [a-z0-9]-(aula|live)-(fiap|alura)-[0-9]-(prod|stage|dev). Exemplo: app-aula-fiap-01-prod"
  }
}

variable "bucket_configs" {
  description = "Variável map de configurações do bucket"
  type = map(string)
  default = {
    "true"  = "private"
    "false" = "public-read"
  }
}