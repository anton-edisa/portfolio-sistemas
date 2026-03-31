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


# Arrancar servicios

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