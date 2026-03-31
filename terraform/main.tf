terraform {
  required_providers {
    docker = {
      source  = "kreuzwerker/docker"
      version = "~> 3.0"
    }
  }
}

provider "docker" {
  host = "ssh://user@172.16.107.222:22"

  ssh_opts = ["-i", "~/.ssh/id_rsa", "-o", "StrictHostKeyChecking=no"]
}

resource "docker_image" "nginx" {
  name         = "nginx:alpine"
}

resource "docker_container" "nginx" {
  image = docker_image.nginx.image_id
  name  = var.nombre_contenedor
  ports {
    internal = var.puerto_contenedor
    external = var.puerto_vm
  }
}