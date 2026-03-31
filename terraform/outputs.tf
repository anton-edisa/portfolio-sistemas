output "nombre_contenedor" {
  description = "Nombre contenedor"
  value       = docker_container.nginx.name
}

output "id_contenedor" {
  description = "ID contenedor"
  value       = docker_container.nginx.id
}