# Pruebas de scripts de despliegue de Libra ERP con terraform

- Uso: terraform plan|apply|destroy  -var-file="secrets.tfvars"

## Versiones

* v0.1
  - Solo válido en el vCenter de Edisa University.
  - Las máquinas se despliegan a partir de plantillas creadas y se configuran los hostname, las IPs y gateways.
  - Las IPs hay que indicarlas a mano.
  - Solo se despliega un entorno por ejecución.
