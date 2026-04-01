terraform {
  required_providers {
    vsphere = {
      source  = "vmware/vsphere"
      version = "2.12.0"
    }
  }
}

provider "vsphere" {
  user                 = var.vsphere_user
  password             = var.vsphere_password
  vsphere_server       = var.vsphere_server
  allow_unverified_ssl = true
}

# --------------------------
# Datacenter
# --------------------------
data "vsphere_datacenter" "dc" {
  name = var.datacenter_name
}

# --------------------------
# Cluster
# --------------------------
data "vsphere_compute_cluster" "cluster" {
  name          = var.cluster_name
  datacenter_id = data.vsphere_datacenter.dc.id
}

# --------------------------
# Datastore
# --------------------------
data "vsphere_datastore" "datastore" {
  name          = var.datastore_name
  datacenter_id = data.vsphere_datacenter.dc.id
}

# --------------------------
# Network
# --------------------------
data "vsphere_network" "network" {
  name          = var.network_name
  datacenter_id = data.vsphere_datacenter.dc.id
}

# --------------------------
# Plantillas
# !!! Linux:   DEBEN TENER PERL Y VMWARE TOOLS INSTALADOS !!!
# !!! Windows: DEBE TENER VMWARE TOOLS INSTALADO          !!!
# --------------------------
data "vsphere_virtual_machine" "template_oel8" {
  name          = var.template_paths["oel8"]
  datacenter_id = data.vsphere_datacenter.dc.id
}

data "vsphere_virtual_machine" "template_oel9" {
  name          = var.template_paths["oel9"]
  datacenter_id = data.vsphere_datacenter.dc.id
}

data "vsphere_virtual_machine" "template_ubuntu" {
  name          = var.template_paths["ubuntu"]
  datacenter_id = data.vsphere_datacenter.dc.id
}

data "vsphere_virtual_machine" "template_windows" {
  name          = var.template_paths["windows"]
  datacenter_id = data.vsphere_datacenter.dc.id
}

locals {
  # Mapa de referencias a las plantillas
  templates = {
    oel8    = data.vsphere_virtual_machine.template_oel8
    oel9    = data.vsphere_virtual_machine.template_oel9
    ubuntu  = data.vsphere_virtual_machine.template_ubuntu
    windows = data.vsphere_virtual_machine.template_windows
  }
}

# --------------------------
# Maquinas virtuales (Linux + Windows)
# --------------------------
resource "vsphere_virtual_machine" "vms" {
  for_each = { for k, v in var.vms : k => v if !var.pruebas || v.enabled }

  name             = "${each.key}-${var.owner_name}"
  folder           = var.vm_folder
  resource_pool_id = data.vsphere_compute_cluster.cluster.resource_pool_id
  datastore_id     = data.vsphere_datastore.datastore.id
  guest_id         = local.templates[each.value.template].guest_id
  firmware         = local.templates[each.value.template].firmware
  scsi_type        = local.templates[each.value.template].scsi_type
  num_cpus         = each.value.num_cpus
  memory           = each.value.memory

  network_interface {
    network_id   = data.vsphere_network.network.id
    adapter_type = "vmxnet3"
  }

  dynamic "disk" {
    for_each = each.value.disks
    content {
      label       = disk.value.label
      size        = disk.value.size
      unit_number = disk.value.unit_number

# ---------------------------------------------------
# thin_provisioned: aprovisionamiento fino
# eagerly_scrub: true en produccion, false en pruebas
      # ---------------------------------------------------
      thin_provisioned = true
      eagerly_scrub    = false
    }
  }

  clone {
    template_uuid = local.templates[each.value.template].id

    customize {

# ---- Opciones Linux ----
      dynamic "linux_options" {
        for_each = each.value.template != "windows" ? [1] : []
        content {
          host_name = "${each.key}-${var.owner_name}"
          domain    = "local"
        }
      }

# ---- Opciones Windows ----
      dynamic "windows_options" {
        for_each = each.value.template == "windows" ? [1] : []
        content {
          computer_name    = each.key
          admin_password   = lookup(var.vm_admin_passwords, each.key, "")
          time_zone        = 85 # 85 = W. Europe Standard Time (España)
          workgroup        = "WORKGROUP"
          auto_logon       = true
          auto_logon_count = 1

# Inicializa el disco D: y le asigna la letra correspondiente.
# Se ejecuta una sola vez tras el primer arranque post-Sysprep.
          run_once_command_list = [
            "powershell -Command \"Get-Disk | Where-Object PartitionStyle -eq 'RAW' | Initialize-Disk -PartitionStyle GPT -PassThru | New-Partition -DriveLetter D -UseMaximumSize | Format-Volume -FileSystem NTFS -NewFileSystemLabel 'Datos' -Confirm:$false\""
          ]
        }
      }

      network_interface {
        ipv4_address = each.value.ip
        ipv4_netmask = var.ipv4_netmask
      }

      ipv4_gateway = var.ipv4_gateway
    }
  }
}
