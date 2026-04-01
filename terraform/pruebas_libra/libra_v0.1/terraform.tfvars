# =========================================================================================
# Entorno de pruebas?
#
# Si pruebas es true se crean: SRVORACLE19C, SRVWL12C, SRVMOVILIDAD, SRVDOCKER, SRVANSIBLE
# =========================================================================================
pruebas = true

# =====================
# Credenciales vSphere
# =====================
vsphere_server = "vcenter.edisa.university"
vsphere_user   = "formacion@vsphere.local"

# ==========================
# Infraestructura vSphere
# ==========================
datacenter_name = "vDataUniversity"
cluster_name    = "vClusterUniversity"
datastore_name  = "DS_FORMACION"
network_name    = "VM Network"
vm_folder       = "Anton - Ourense/Libra"
ipv4_gateway    = "172.16.107.1"
ipv4_netmask = 24
dns_servers  = ["8.8.8.8", "1.1.1.1"]
dns_suffixes = ["local"]


# ==========================
# Rutas de las plantillas
# ==========================
template_paths = {
  oel8    = "Anton - Ourense/Libra/plantillas/Oracle Linux 8"
  oel9    = "Anton - Ourense/Libra/plantillas/Oracle Linux 9"
  ubuntu  = "Anton - Ourense/Libra/plantillas/Ubuntu_24_04"
  windows = "Anton - Ourense/Libra/plantillas/Windows Server 2022"
}

# ==============================================================
# Nombre del propietario (se añade como sufijo a cada VM)
# ==============================================================
owner_name = "Anton"

# ==============================================================
# Definicion de VMs
# Las contraseñas de Windows van en secrets.tfvars
# Para num_cpus y memory: si se omiten se aplican los defaults
#   (2 vCPUs y 4096 MB definidos en variables.tf)
# ==============================================================
vms = {

  "SRVORACLE19C" = {
    ip       = "172.16.107.220"
    template = "oel9"
    num_cpus = 4
    memory   = 8192
    disks = [
      { label = "disk0", size = 50,  unit_number = 0 },
      { label = "disk1", size = 100, unit_number = 1 },
      { label = "disk2", size = 100, unit_number = 2 },
      { label = "disk3", size = 50,  unit_number = 3 },
      { label = "disk4", size = 10,  unit_number = 4 },
      { label = "disk5", size = 150, unit_number = 5 },
      { label = "disk6", size = 200, unit_number = 6 },
    ]
  }

  "SRVWL12C" = {
    ip       = "172.16.107.221"
    template = "oel8"
    num_cpus = 4
    memory   = 8192
    disks = [
      { label = "disk0", size = 50, unit_number = 0 },
      { label = "disk1", size = 75, unit_number = 1 },
      { label = "disk2", size = 50, unit_number = 2 },
      { label = "disk3", size = 10, unit_number = 3 },
    ]
  }

  "SRVMOVILIDAD" = {
    ip       = "172.16.107.222"
    template = "ubuntu"
    disks = [
      { label = "disk0", size = 30, unit_number = 0 },
    ]
  }

  "SRVPROXY" = {
    enabled  = false
    ip       = "172.16.107.223"
    template = "ubuntu"
    disks = [
      { label = "disk0", size = 30, unit_number = 0 },
    ]
  }

  "SRVDOCKER" = {
    ip       = "172.16.107.224"
    template = "oel8"
    num_cpus = 4
    memory   = 8192
    disks = [
      { label = "disk0", size = 150, unit_number = 0 },
    ]
  }

  "SRVGATEWAY" = {
    enabled  = false
    ip       = "172.16.107.227"
    template = "ubuntu"
    disks = [
      { label = "disk0", size = 30, unit_number = 0 },
    ]
  }

  "SRVTSERVER" = {
    enabled       = false
    ip            = "172.16.107.225"
    template      = "windows"
    computer_name = "SRVTSERVER"    # maximo 15 caracteres
    disks = [
      { label = "disk0", size = 75, unit_number = 0 }, # C:
      { label = "disk1", size = 50, unit_number = 1 }, # D:
    ]
  }

  "SRVGALCOMANDOS" = {
    enabled       = false
    ip            = "172.16.107.226"
    template      = "windows"
    computer_name = "SRVGALCMD"     # maximo 15 caracteres
    disks = [
      { label = "disk0", size = 75, unit_number = 0 }, # C:
      { label = "disk1", size = 50, unit_number = 1 }, # D:
    ]
  }

  "SRVANSIBLE" = {
    ip       = "172.16.107.229"
    template = "ubuntu"
    disks = [
      { label = "disk0", size = 20, unit_number = 0 },
    ]
  }

}
