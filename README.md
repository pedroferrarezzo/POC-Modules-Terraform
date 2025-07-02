# ⚡ POC Modules Terraform

<div align="center">

[![Terraform](https://img.shields.io/badge/Terraform-1.5+-623CE4?style=for-the-badge&logo=terraform&logoColor=white)](https://www.terraform.io/)
[![AWS](https://img.shields.io/badge/AWS-Provider-FF9900?style=for-the-badge&logo=amazon-aws&logoColor=white)](https://aws.amazon.com/)
[![License](https://img.shields.io/badge/License-MIT-green.svg?style=for-the-badge)](LICENSE)

</div>

Projeto de demonstração (POC) para implementação de infraestrutura como código utilizando módulos Terraform na AWS, desenvolvido como parte de estudos práticos de DevOps e Cloud Computing.

<div align="center">
  <a href="#visao-geral">Visão Geral</a> •
  <a href="#arquitetura">Arquitetura</a> •
  <a href="#tecnologias">Tecnologias</a> •
  <a href="#estrutura-modulos">Estrutura dos Módulos</a> •
  <a href="#instalacao-e-uso">Instalação e Uso</a> •
  <a href="#estrutura-do-projeto">Estrutura do Projeto</a> •
  <a href="#configuracao">Configuração</a> •
  <a href="#recursos-provisionados">Recursos Provisionados</a> •
  <a href="#resolucao-de-problemas">Resolução de Problemas</a> •
  <a href="#contribuicao-e-licenca">Contribuição e Licença</a>
</div>

<h2 id="visao-geral">📋 Visão Geral</h2>

Este projeto demonstra a implementação de infraestrutura na AWS utilizando Terraform com uma abordagem modular. O sistema provisiona recursos de computação (EC2) e armazenamento (S3) em diferentes regiões AWS, seguindo boas práticas de Infrastructure as Code (IaC).

### Principais recursos

- **Provisionamento Multi-Regional**: Recursos distribuídos entre us-east-1 e sa-east-1
- **Arquitetura Modular**: Módulos reutilizáveis para EC2 e S3
- **Múltiplos Providers**: Configuração para diferentes regiões AWS
- **Validação de Nomenclatura**: Padrões de naming enforçados via validação
- **Diferentes Estratégias de Deploy**: Uso de count e for_each para criação de recursos

<h2 id="arquitetura">🏗️ Arquitetura</h2>

<details>
<summary>Expandir para mais detalhes</summary>

### Diagrama de Arquitetura

```mermaid
graph TB
    subgraph "Terraform Root Module"
        ROOT[main.tf]
        VARS[vars.tf]
        PROVIDERS[provider.tf]
        LOCALS[locals.tf]
        DATA[data.tf]
        TFVARS[terraform.tfvars]
    end

    subgraph "AWS us-east-1"
        EC2_1[EC2 Instance 1]
        EC2_2[EC2 Instance 2]
        EC2_LOOP_1[EC2 t3.medium]
        EC2_LOOP_2[EC2 t3.micro]
    end

    subgraph "AWS sa-east-1"
        S3_1[S3 Bucket - Force Destroy: true]
        S3_2[S3 Bucket - Force Destroy: false]
        ACL_1[S3 ACL - private]
        ACL_2[S3 ACL - public-read]
    end

    subgraph "Modules"
        EC2_MODULE[modules/ec2/]
        S3_MODULE[modules/s3/]
    end

    ROOT --> EC2_MODULE
    ROOT --> S3_MODULE
    
    EC2_MODULE --> EC2_1
    EC2_MODULE --> EC2_2
    EC2_MODULE --> EC2_LOOP_1
    EC2_MODULE --> EC2_LOOP_2
    
    S3_MODULE --> S3_1
    S3_MODULE --> S3_2
    S3_MODULE --> ACL_1
    S3_MODULE --> ACL_2

    DATA --> EC2_MODULE
    PROVIDERS --> EC2_MODULE
    PROVIDERS --> S3_MODULE
    LOCALS --> PROVIDERS
    TFVARS --> VARS
```

### Estrutura de Providers

O projeto utiliza dois providers AWS configurados para diferentes regiões:

- **Provider Default**: us-east-1 (para recursos EC2)
- **Provider SP (São Paulo)**: sa-east-1 (para recursos S3)

### Estratégias de Provisionamento

1. **Count-based**: Criação de múltiplas instâncias EC2 idênticas
2. **For_each-based**: Criação de recursos com diferentes configurações baseadas em conjuntos/mapas

</details>

<h2 id="tecnologias">🔧 Tecnologias</h2>

<details>
<summary>Expandir para mais detalhes</summary>

### Infraestrutura como Código

- **Terraform ~> 1.5**: Ferramenta principal de IaC
- **AWS Provider ~> 5.0**: Provider oficial da AWS para Terraform
- **HCL (HashiCorp Configuration Language)**: Linguagem de configuração

### Provedores de Nuvem

- **Amazon Web Services (AWS)**: Plataforma de nuvem
  - **EC2**: Elastic Compute Cloud para instâncias virtuais
  - **S3**: Simple Storage Service para armazenamento de objetos
  - **AMI**: Amazon Machine Images (Ubuntu 22.04 LTS)

### Recursos AWS Utilizados

- **aws_instance**: Instâncias de computação EC2
- **aws_s3_bucket**: Buckets de armazenamento S3
- **aws_s3_bucket_acl**: Controle de acesso aos buckets
- **aws_s3_bucket_ownership_controls**: Controles de propriedade
- **aws_ami**: Imagens de máquina virtual (data source)

</details>

<h2 id="estrutura-modulos">🏗️ Estrutura dos Módulos</h2>

<details>
<summary>Expandir para mais detalhes</summary>

### Módulo EC2 (`modules/ec2/`)

Responsável pela criação de instâncias EC2 com diferentes estratégias:

**Recursos Criados:**
- 2 instâncias EC2 usando `count` (configuração idêntica)
- 2 instâncias EC2 usando `for_each` com tipos diferentes (t3.medium, t3.micro)

**Inputs:**
- `ami`: ID da AMI a ser utilizada
- `instance_type`: Tipo da instância (padrão: t2.micro)
- `instance_name`: Nome para as instâncias

**Features:**
- Suporte a múltiplas estratégias de criação
- Tags automáticas com nome configurável
- Flexibilidade de tipos de instância

### Módulo S3 (`modules/s3/`)

Responsável pela criação de buckets S3 com diferentes configurações:

**Recursos Criados:**
- Buckets S3 com configurações variadas via `for_each`
- ACLs configuráveis (private/public-read)
- Controles de propriedade automáticos

**Inputs:**
- `instance_name`: Nome do bucket (com validação de padrão)
- `bucket_configs`: Mapa de configurações (force_destroy + ACL)

**Features:**
- Validação rigorosa de nomenclatura
- Configuração flexível via mapas
- Provider específico para região sa-east-1
- Controles de propriedade e ACL automáticos

### Validação de Nomenclatura

O módulo S3 implementa validação rigorosa seguindo o padrão:
```
^[a-z0-9]+-(aula|live)-(fiap|alura)-[0-9]+(prod|stage|dev)$
```

Exemplos válidos:
- `s3-aula-fiap-1-dev`
- `app-live-alura-01-prod`
- `web-aula-fiap-2-stage`

</details>

<h2 id="instalacao-e-uso">🚀 Instalação e Uso</h2>

<details>
<summary>Expandir para mais detalhes</summary>

### Pré-requisitos

- **Terraform**: Versão 1.5 ou superior
- **AWS CLI**: Configurado com credenciais válidas
- **Conta AWS**: Com permissões para criar recursos EC2 e S3
- **Bucket S3**: Para armazenar o estado remoto do Terraform (backend)

### Configuração das Credenciais AWS

```bash

# 1. Configuração manual do arquivo credentials
# Edite o arquivo ~/.aws/credentials (Linux/Mac) ou %USERPROFILE%\.aws\credentials (Windows)
[default]
aws_access_key_id=ACCESS_KEY
aws_secret_access_key=SECRET_ACCESS_KEY
aws_session_token=SESSION_TOKEN

# 2: AWS CLI
aws configure

# Para verificar a configuração atual
# (Quais credenciais e configurações a AWS CLI está usando no momento)
aws configure list
# (Usa o serviço STS (Security Token Service) da AWS para mostrar quem você é no contexto das credenciais ativas)
aws sts get-caller-identity
```

### Instalação e Execução

```bash
# 1. Clone o repositório
git clone <repository-url>
cd POC-Modules-Terraform

# 2. Configure o backend S3 (se necessário)
# Edite o arquivo backend.tf com suas configurações específicas

# 3. Inicialize o Terraform
terraform init

# 4. Valide a configuração
terraform validate

# 5. Revise o plano de execução
terraform plan

# 6. Aplique as mudanças
terraform apply

# 7. Para destruir os recursos (quando necessário)
terraform destroy
```

### Comandos Úteis

```bash
# Formatação automática dos arquivos
terraform fmt

# Visualização gráfica da infraestrutura
terraform graph | dot -Tsvg > graph.svg

# Listagem do estado atual
terraform state list

# Verificação de drift na infraestrutura
# (Quando o estado real da infraestrutura fica diferente do que está definido no código)
terraform plan -detailed-exitcode

# Import de recursos existentes
# (Traz um recurso existente para o controle do Terraform, sem recriá-lo)
terraform import aws_instance.example i-1234567890abcdef0
```

### Customização via terraform.tfvars

Edite o arquivo `terraform.tfvars` para personalizar os recursos:

```hcl
ec2_name = "minha-ec2-aula-fiap-1-prod"
s3_name  = "meu-s3-live-alura-1-dev"
```

</details>

<h2 id="estrutura-do-projeto">📁 Estrutura do Projeto</h2>

<details>
<summary>Expandir para mais detalhes</summary>

```
POC-Modules-Terraform/
│
├── main.tf                    # Configuração principal - chamada dos módulos
├── vars.tf                    # Definição das variáveis do projeto
├── locals.tf                  # Valores locais e configurações estáticas
├── provider.tf                # Configuração dos providers AWS
├── data.tf                    # Data sources (AMI Ubuntu)
├── backend.tf                 # Configuração do backend S3 remoto do Terraform
├── terraform.tfvars           # Valores das variáveis
├── LICENSE                    # Licença do projeto
├── README.md                  # Documentação principal
│
└── modules/                   # Diretório dos módulos
    ├── ec2/                   # Módulo para instâncias EC2
    │   ├── main.tf            # Recursos EC2 (count e for_each)
    │   ├── vars.tf            # Variáveis do módulo EC2
    │   ├── output.tf          # Outputs do módulo EC2
    │   └── provider.tf        # Provider configuration (se necessário)
    │
    └── s3/                    # Módulo para buckets S3
        ├── main.tf            # Recursos S3 com configurações via for_each
        ├── vars.tf            # Variáveis do módulo S3 (com validação)
        ├── output.tf          # Outputs do módulo S3
        └── provider.tf        # Configuração específica do provider
```

### Descrição dos Arquivos Principais

#### Root Module

- **`main.tf`**: Orquestra a chamada dos módulos com as configurações necessárias
- **`vars.tf`**: Define as variáveis de entrada do projeto
- **`locals.tf`**: Contém valores estáticos como regiões AWS
- **`provider.tf`**: Configura os providers AWS para diferentes regiões
- **`data.tf`**: Define data sources, como a busca da AMI Ubuntu mais recente
- **`terraform.tfvars`**: Arquivo de valores das variáveis (não deve ser commitado em produção)

#### Módulo EC2

- **`main.tf`**: Implementa diferentes estratégias de criação de instâncias
- **`vars.tf`**: Define inputs do módulo com valores padrão
- **`output.tf`**: Exporta informações das instâncias criadas

#### Módulo S3

- **`main.tf`**: Cria buckets com configurações flexíveis via mapas
- **`vars.tf`**: Inclui validação rigorosa de nomenclatura
- **`output.tf`**: Exporta informações dos buckets criados

</details>

<h2 id="configuracao">⚙️ Configuração</h2>

<details>
<summary>Expandir para mais detalhes</summary>

### Variáveis de Ambiente

O projeto utiliza as seguintes configurações:

#### Regiões AWS (locals.tf)
```hcl
locals {
  region_sp      = "sa-east-1"  # São Paulo
  region_default = "us-east-1"  # N. Virginia
}
```

#### Variáveis Principais (vars.tf)
```hcl
variable "ec2_name" {
  description = "Nome para as instâncias EC2"
  type = string
}

variable "s3_name" {
  description = "Nome para os buckets S3"
  type = string
}
```

### Configurações dos Módulos

#### EC2 Module Configuration
```hcl
# Tipos de instância utilizados
instance_types = ["t2.micro", "t3.medium", "t3.micro"]

# Estratégias de criação
count_instances = 2  # Número de instâncias idênticas
```

#### S3 Module Configuration
```hcl
# Configurações padrão dos buckets
bucket_configs = {
  "true"  = "private"      # force_destroy = true, ACL = private
  "false" = "public-read"  # force_destroy = false, ACL = public-read
}
```

### Data Sources

#### AMI Ubuntu
```hcl
data "aws_ami" "ubuntu" {
  most_recent = true
  
  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-jammy-22.04-amd64-server-*"]
  }
  
  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
  
  owners = ["099720109477"] # Canonical
}
```

### Personalização Avançada

Para modificar o comportamento dos módulos, você pode:

1. **Alterar tipos de instância EC2**:
   ```hcl
   # Em modules/ec2/main.tf
   for_each = toset(["t3.small", "t3.large"])  # Modificar tipos
   ```

2. **Modificar configurações S3**:
   ```hcl
   # Em modules/s3/vars.tf
   default = {
     "true"  = "private"
     "false" = "public-read"
     "versioning" = "private"  # Adicionar nova configuração
   }
   ```

3. **Adicionar novas regiões**:
   ```hcl
   # Em locals.tf
   locals {
     region_sp      = "sa-east-1"
     region_default = "us-east-1"
     region_eu      = "eu-west-1"  # Nova região
   }
   ```

### Configuração Detalhada de Credenciais AWS

#### Métodos de Autenticação

O Terraform AWS Provider procura credenciais na seguinte ordem de prioridade:

1. **Variáveis de ambiente**
2. **Arquivo de credenciais AWS (~/.aws/credentials)**
3. **Arquivo de configuração AWS (~/.aws/config)**
4. **Perfis IAM (EC2 Instance Profile)**
5. **Roles IAM (assumidos automaticamente)**

#### Estrutura dos Arquivos de Credenciais

**Arquivo ~/.aws/credentials (Linux/Mac) ou %USERPROFILE%\.aws\credentials (Windows):**
```ini
[default]
aws_access_key_id = AKIAIOSFODNN7EXAMPLE
aws_secret_access_key = wJalrXUtnFEMI/K7MDENG/bPxRfiCYEXAMPLEKEY

[dev-profile]
aws_access_key_id = AKIAI44QH8DHBEXAMPLE
aws_secret_access_key = je7MtGbClwBF/2Zp9Utk/h3yCo8nvbEXAMPLEKEY

[prod-profile]
aws_access_key_id = AKIAI44QH8DHBEXAMPLE
aws_secret_access_key = je7MtGbClwBF/2Zp9Utk/h3yCo8nvbEXAMPLEKEY
```

**Arquivo ~/.aws/config (Linux/Mac) ou %USERPROFILE%\.aws\config (Windows):**
```ini
[default]
region = us-east-1
output = json

[profile dev-profile]
region = sa-east-1
output = table

[profile prod-profile]
region = us-east-1
output = json
role_arn = arn:aws:iam::123456789012:role/ProductionRole
source_profile = default
```

#### Usando Perfis Específicos

Para usar um perfil específico com este projeto:

```bash
# Definir perfil via variável de ambiente
export AWS_PROFILE=dev-profile

# Ou especificar no provider (provider.tf)
provider "aws" {
  profile = "dev-profile"
  region  = "us-east-1"
}

# Verificar qual perfil está sendo usado
aws configure list
aws sts get-caller-identity
```

#### Validação de Credenciais

Sempre valide suas credenciais antes de executar o Terraform:

```bash
# Verificar identidade atual
aws sts get-caller-identity

# Listar perfis configurados
aws configure list-profiles

# Testar acesso aos serviços necessários
aws ec2 describe-regions --region us-east-1
aws s3 ls --region sa-east-1
```

### Configuração do Backend

O projeto está configurado para utilizar um bucket S3 como backend remoto do Terraform, proporcionando:

- **Estado Compartilhado**: Permite que múltiplos desenvolvedores trabalhem no mesmo projeto
- **Versionamento**: Histórico de mudanças no estado da infraestrutura  
- **Bloqueio de Estado**: Previne alterações concorrentes via DynamoDB
- **Segurança**: Estado armazenado de forma segura na AWS

#### Configuração no backend.tf
```hcl
terraform {
  backend "s3" {
    bucket = "terraform-state-bucket-name"
    key    = "poc-modules/terraform.tfstate"
    region = "us-east-1"
    
    # Opcional: DynamoDB para bloqueio de estado
    dynamodb_table = "terraform-state-lock"
    encrypt        = true
  }
}
```

> **Importante**: O bucket S3 para o backend deve ser criado manualmente antes da primeira execução do `terraform init`

</details>

<h2 id="recursos-provisionados">☁️ Recursos Provisionados</h2>

<details>
<summary>Expandir para mais detalhes</summary>

### Instâncias EC2 (us-east-1)

#### Via Count Strategy
- **Quantidade**: 2 instâncias
- **Tipo**: t2.micro (configurável)
- **AMI**: Ubuntu 22.04 LTS (mais recente)
- **Tags**: Nome configurável via variável

#### Via For_Each Strategy
- **Tipos**: t3.medium e t3.micro
- **AMI**: Ubuntu 22.04 LTS (mais recente)
- **Tags**: Nome configurável via variável

### Buckets S3 (sa-east-1)

#### Configuração Flexível via Map
- **Bucket 1**: 
  - Force Destroy: `true`
  - ACL: `private`
- **Bucket 2**: 
  - Force Destroy: `false`
  - ACL: `public-read`

#### Recursos S3 Adicionais
- **ACL Configuration**: Configurado automaticamente baseado no mapa
- **Ownership Controls**: BucketOwnerPreferred para todos os buckets
- **Provider Específico**: Utiliza provider aws.sp (sa-east-1)

### Resumo de Custos Estimados

> **Nota**: Os custos podem variar baseado no uso e região AWS

#### EC2 Instances (us-east-1)
- **2x t2.micro**: ~$8.64/mês (elegível para Free Tier)
- **1x t3.medium**: ~$30.37/mês
- **1x t3.micro**: ~$7.59/mês

#### S3 Buckets (sa-east-1)
- **Storage**: $0.023 por GB/mês (primeiros 50TB)
- **Requests**: Varia baseado no uso
- **Transfer**: Pode aplicar cobrança para saída de dados

### Monitoramento e Alertas

Para monitorar os recursos criados:

```bash
# Listar instâncias EC2
aws ec2 describe-instances --region us-east-1

# Listar buckets S3
aws s3 ls --region sa-east-1

# Verificar custos
aws ce get-cost-and-usage --time-period Start=2024-01-01,End=2024-01-31
```

</details>

<h2 id="resolucao-de-problemas">🔍 Resolução de Problemas</h2>

<details>
<summary>Expandir para mais detalhes</summary>

### Problemas Comuns

#### 1. Erro de Autenticação AWS

```
Error: error configuring Terraform AWS Provider: no valid credential sources for Terraform AWS Provider found
```

**Solução:**
```bash
# Verificar configuração AWS atual
aws configure list
aws sts get-caller-identity

# Opção 1: Configurar via AWS CLI
aws configure

# Opção 2: Configurar manualmente o arquivo credentials
# Linux/Mac: ~/.aws/credentials
# Windows: %USERPROFILE%\.aws\credentials
[default]
aws_access_key_id = your-access-key
aws_secret_access_key = your-secret-key

# E o arquivo de configuração
# Linux/Mac: ~/.aws/config  
# Windows: %USERPROFILE%\.aws\config
[default]
region = us-east-1
output = json

# Opção 3: Usar variáveis de ambiente
export AWS_ACCESS_KEY_ID="your-key"
export AWS_SECRET_ACCESS_KEY="your-secret"
export AWS_DEFAULT_REGION="us-east-1"

# Verificar se as credenciais estão funcionando
aws sts get-caller-identity
```

#### 2. Erro de Validação de Nomenclatura S3

```
Error: Invalid value for variable
The name must follow the pattern: [a-z0-9]-(aula|live)-(fiap|alura)-[0-9]-(prod|stage|dev)
```

**Solução:**
Ajuste o valor em `terraform.tfvars`:
```hcl
s3_name = "s3-aula-fiap-1-dev"  # Formato correto
```

#### 3. Conflito de Nome de Bucket S3

```
Error: Error creating S3 bucket: BucketAlreadyExists: The requested bucket name is not available
```

**Solução:**
```hcl
# Modificar o nome no terraform.tfvars para um único globalmente
s3_name = "s3-aula-fiap-1-dev-20241202"  # Adicionar timestamp
```

#### 4. Permissões Insuficientes

```
Error: AccessDenied: User is not authorized to perform: ec2:RunInstances
```

**Solução:**
Certifique-se de que o usuário/role IAM possui as seguintes permissões:
```json
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": [
        "ec2:*",
        "s3:*"
      ],
      "Resource": "*"
    }
  ]
}
```

#### 5. Estado Terraform Corrompido

```
Error: Failed to load state: state file locked
```

**Solução:**
```bash
# Forçar unlock (use com cuidado)
terraform force-unlock <lock-id>

# Ou remover arquivo de estado local (apenas para desenvolvimento)
rm terraform.tfstate*
terraform init
```

### Debugging

#### Habilitar Logs Detalhados
```bash
export TF_LOG=DEBUG
terraform plan
```

#### Verificar Estado Atual
```bash
# Mostrar recursos no estado
terraform state list

# Mostrar detalhes de um recurso
terraform state show aws_instance.this-count[0]

# Verificar configuração
terraform show
```

#### Validação de Sintaxe
```bash
# Validar configuração
terraform validate

# Formatar arquivos
terraform fmt -recursive

# Verificar providers
terraform providers
```

</details>

<h2 id="contribuicao-e-licenca">🙏 Contribuição e Licença</h2>

### Guia de Contribuição

Para contribuir com o projeto, siga estas etapas:

#### Branches

- A branch principal de desenvolvimento é a `main`
- Para novas funcionalidades, crie uma branch a partir da `main` seguindo o padrão:
  - `feature/nome-da-funcionalidade`
- Para correções de bugs, use o padrão:
  - `fix/descricao-do-bug` 
- Para documentação:
  - `docs/descricao-da-documentacao`
- Para melhorias de infraestrutura:
  - `infra/descricao-da-mudanca`

#### Commits

Siga a convenção [Conventional Commits](https://www.conventionalcommits.org/):

```
<tipo>[escopo opcional]: <descrição>

[corpo opcional]

[rodapé(s) opcional(is)]
```

Exemplos:

- `feat(ec2): adiciona suporte para instâncias spot`
- `fix(s3): corrige validação de nomenclatura`
- `docs: atualiza README com novos exemplos`
- `refactor(modules): melhora estrutura de variáveis`

#### Pull Requests

1. Certifique-se que sua branch está atualizada com a `main`
2. Execute `terraform fmt` e `terraform validate`
3. Teste as mudanças com `terraform plan`
4. Faça um pull request para a branch `main`
5. Descreva as alterações realizadas de forma clara
6. Vincule issues relacionadas
7. Aguarde a revisão dos mantenedores

### Padrões de Código Terraform

- Use nomes descritivos para recursos e variáveis
- Mantenha comentários em código complexo
- Utilize `terraform fmt` para formatação consistente
- Implemente validações para variáveis críticas
- Documente outputs dos módulos

---

### Contribuidores

Este projeto é mantido por:

- [Pedro Ferrarezzo](https://github.com/pedroferrarezzo)

---

### Licença

Este projeto está licenciado sob a licença MIT. Veja o arquivo [LICENSE](LICENSE) para mais detalhes.

---

### Recursos Adicionais

- [Documentação Oficial do Terraform](https://www.terraform.io/docs)
- [AWS Provider Documentation](https://registry.terraform.io/providers/hashicorp/aws/latest/docs)
- [Terraform Best Practices](https://www.terraform.io/docs/cloud/guides/recommended-practices/index.html)
- [Providers Within Modules](https://developer.hashicorp.com/terraform/language/modules/develop/providers)
- [AWS Free Tier](https://aws.amazon.com/free/)
- [AWS Academy](https://www.awsacademy.com/vforcesite/LMS_Login)

---

<div align="center">

**⭐ Se este projeto foi útil, considere dar uma estrela!**

[⬆ Voltar ao topo](#-poc-modules-terraform)

</div>
