# =========================================================================================
# Entorno de pruebas?
# =========================================================================================
variable "pruebas" {
  description = "Si es true, solo se despliegan las VMs de pruebas"
  type        = bool
  default     = false
}


# =========================
# Credenciales vSphere
# =========================
variable "vsphere_user" {
  description = "Usuario de conexion al vCenter"
  type        = string
}

variable "vsphere_password" {
  description = "Contraseña de conexion al vCenter"
  type        = string
  sensitive   = true
}

variable "vsphere_server" {
  description = "FQDN o IP del servidor vCenter"
  type        = string
}

# ==========================
# Infraestructura vSphere
# ==========================
variable "datacenter_name" {
  description = "Nombre del datacenter en vCenter"
  type        = string
}

variable "cluster_name" {
  description = "Nombre del cluster de computo en vCenter"
  type        = string
}

variable "datastore_name" {
  description = "Nombre del datastore donde se alojan las VMs"
  type        = string
}

variable "network_name" {
  description = "Nombre de la red (port group) a la que se conectan las VMs"
  type        = string
}

variable "vm_folder" {
  description = "Ruta completa de la carpeta en vCenter donde se crean las VMs"
  type        = string
}

variable "ipv4_gateway" {
  description = "Gateway IPv4 por defecto para todas las VMs"
  type        = string
}

variable "ipv4_netmask" {
  description = "Máscara de red IPv4 en CIDR por defecto para todas las VMs"
  type        = number
}

# ==============================================================
# Rutas de las plantillas
# ==============================================================
variable "template_paths" {
  description = "Mapa con las rutas completas de cada plantilla en vCenter (oel8, oel9, ubuntu, windows)"
  type        = map(string)
}

# ==============================================================
# Definicion de VMs
# ==============================================================
variable "vms" {
  description = "Mapa de maquinas virtuales a desplegar"
  type = map(object({
    enabled       = optional(bool, true)
    ip            = string
    template      = string
    num_cpus      = optional(number, 2)
    memory        = optional(number, 4096)
    disks = list(object({
      label       = string
      size        = number
      unit_number = number
    }))
  }))
}

# =============================================================
# Sufijo para los hostnames
# ==============================================================
variable "owner_name" {
  description = "Sufijo del propietario, se añade al nombre de cada VM"
  type        = string
}

# ==============================================================
# Contraseñas de administrador (VMs Windows)
# ==============================================================
variable "vm_admin_passwords" {
  description = "Mapa vm_name -> contraseña de Admin local Windows"
  type        = map(string)
  sensitive   = true
  default     = {}
}
