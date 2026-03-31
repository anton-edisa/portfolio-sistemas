variable "nombre_contenedor" {
  description = "Nombre del contenedor"
  type = string
}

variable "puerto_contenedor" {
  description = "Puerto interno del contenedor"
  type = number
}

variable "puerto_vm" {
  description = "Puerto externo de la VM"
  type = number
}