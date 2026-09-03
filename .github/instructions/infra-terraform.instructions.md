---
applyTo: "infra/**/*.tf"
---

# Estándar de infraestructura (Terraform)

- Ningún bucket S3 (o equivalente de storage) debe tener `acl = "public-read"` o
  políticas que permitan acceso anónimo, salvo que el recurso esté explícitamente
  documentado como contenido público (ej. assets estáticos de un sitio web).
- Ningún `security_group`/`network_security_rule` debe permitir ingreso desde
  `0.0.0.0/0` en puertos administrativos (22, 3389, 5432, 3306, etc.).
- Todo recurso que almacene datos debe tener cifrado en reposo habilitado
  (`server_side_encryption`, `encrypted = true`, o equivalente).
- Los secretos (passwords, connection strings, API keys) nunca deben estar hardcodeados
  en el `.tf` — deben venir de variables marcadas `sensitive = true` o de un secret
  manager.
- Todo recurso debe tener tags mínimos de propietario y ambiente (`owner`,
  `environment`).
