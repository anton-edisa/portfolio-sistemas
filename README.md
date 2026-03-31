# Portfolio de Prácticas de Sistemas

Repositorio con todos los recursos, scripts y configuraciones generados durante las prácticas de sistemas.

## Requisitos

- Ubuntu Server 22.04 LTS
- Docker y Docker Compose instalados
- Git

## Instalación rápida

```bash
git clone https://github.com/anton-edisa/portfolio-sistemas.git
cd portfolio-sistemas/docker
cp .env.example .env
nano .env  # Rellena tus contraseñas
```
  
## Arrancar servicios
```bash
# Aplicación web (Nginx + WordPress + MariaDB)
docker compose --profile web up -d

# Monitorización (Prometheus + Grafana + Node Exporter)
docker compose --profile monitoring up -d

# Zabbix (Server + Web + DB)
docker compose --profile zabbix up -d

# Oracle Database 23ai
docker compose --profile database up -d

# Parar todo
docker compose --profile web --profile monitoring --profile zabbix --profile database down
```

## Acceso a los servicios

| Servicio | URL | Usuario | Contraseña |
|----------|-----|---------|------------|
| WordPress | http://IP:80 | — | — |
| Grafana | http://IP:3000 | admin | (ver .env) |
| Zabbix | http://IP:8080 | Admin | zabbix |
| Prometheus | http://IP:9090 | — | — |
| Oracle | IP:1521 | system | (ver .env) |

## Estructura del repositorio

- `docker/` — Stack Docker Compose completo con profiles
- `ansible/` — Playbooks de automatización (lab 23)
- `vagrant/` — Entornos de desarrollo local (lab 22)
- `terraform/` — Infraestructura como código (lab 26)
- `kubernetes/` — Manifiestos Kubernetes para k3s (lab 27)
- `scripts/bash/` — Scripts de administración Linux
- `scripts/powershell/` — Scripts de gestión de Active Directory
- `ssl/` — Scripts para generar certificados SSL/TLS

## CI/CD

Cada push a `main` ejecuta automáticamente:
- Verificación de estructura del repositorio
- Análisis de seguridad (sin secretos expuestos)
- Validación de sintaxis docker-compose.yml
- Comprobación de profiles definidos
- Verificación de scripts

---