# Infraestructura de ejemplo (demo).
#
# NOTA: Este archivo contiene problemas intencionales para que Copilot code
# review los detecte durante la demo. No usar como referencia de buenas
# prácticas.

provider "aws" {
  region = "us-east-1"
}

# Problema 1: bucket S3 con ACL pública y sin cifrado en reposo.
resource "aws_s3_bucket" "customer_uploads" {
  bucket = "demo-customer-uploads"
  acl    = "public-read"
}

# Problema 2: sin server_side_encryption_configuration.

# Problema 3: security group abierto a todo el mundo en el puerto de base de
# datos (Postgres) y SSH.
resource "aws_security_group" "db_access" {
  name        = "db-access"
  description = "Acceso a la base de datos"

  ingress {
    from_port   = 5432
    to_port     = 5432
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# Problema 4: connection string con password hardcodeada, sin sensitive = true.
resource "aws_db_instance" "payments_db" {
  identifier        = "payments-db"
  engine            = "postgres"
  instance_class    = "db.t3.micro"
  allocated_storage = 20
  username          = "admin"
  password          = "SuperSecret123!"

  # Problema 5: sin tags de owner/environment.
}
