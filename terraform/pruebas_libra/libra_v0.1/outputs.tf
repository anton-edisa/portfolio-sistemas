output "entradas_hosts" {
  description = "Líneas para /etc/hosts"
  value = join("\n", [
    for name, vm in var.vms : "${vm.ip} ${name}-${var.owner_name}"
  ])
}