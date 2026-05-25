# Configuración de Cluster de Kubernetes en OEL
 
> Con playbooks de Ansible y manualmente  
> **Autor:** Antón Moncho — 25 de mayo de 2026
 
---
 
## Configuración inicial
 
Las máquinas que formarán el cluster deberán tener hostname y configuración de red con IP estática y acceso a Internet.
 
- Los nodos deberán estar en la misma red.
- Deberán ser accesibles por SSH desde la máquina en la que se lanzan los playbooks.
### Requisitos mínimos de hardware para los nodos
 
| Rol | vCPU | RAM | Almacenamiento |
|-----|------|-----|----------------|
| Nodo Maestro y Nodos de Control | 2 vCPU | 4 GB | 20 GB |
| Nodos Workers | 1 vCPU | 512 MB | 10 GB |
 
---
 
## INSTALACIÓN MANUAL
 
### Configuración de SELinux en TODOS los nodos
 
Como K3s necesita muchas reglas en SELinux, utilizamos un repositorio con un paquete preconfigurado solo con las reglas para k3s.
 
> [!NOTE]
> Opcionalmente se puede cambiar SELinux a `permissive` y saltarse este paso.
 
```bash
cat > /etc/yum.repos.d/rancher-k3s-common.repo << EOF
[rancher-k3s-common-stable]
name=Rancher K3s Common Stable
baseurl=https://rpm.rancher.io/k3s/stable/common/centos/8/noarch
enabled=1
gpgcheck=1
gpgkey=https://rpm.rancher.io/public.key
EOF
 
# Instalar el paquete de políticas SELinux para k3s
dnf install -y k3s-selinux
```
 
---
 
### Kernel modules necesarios en todos los nodos
 
**Módulo para permitir la correcta comunicación entre los nodos:**
 
```bash
modprobe br_netfilter
echo "br_netfilter" >> /etc/modules-load.d/k8s.conf
```
 
**Módulo para el cifrado de volúmenes** *(opcional pero recomendable)*:
 
```bash
modprobe dm_crypt
echo "dm_crypt" >> /etc/modules-load.d/k8s.conf
```
 
---
 
### Habilitar el IP Forwarding en los nodos
 
```bash
echo "net.ipv4.ip_forward = 1" >> /etc/sysctl.d/k8s.conf
sysctl --system
```
 
---
 
### Instalación y configuración del MASTER
 
**Abrir puertos necesarios en firewalld:**
 
```bash
firewall-cmd --permanent --add-port=6443/tcp
firewall-cmd --permanent --add-port=2379/tcp
firewall-cmd --permanent --add-port=2380/tcp
firewall-cmd --permanent --add-port=8472/udp
firewall-cmd --permanent --add-port=10250/tcp
firewall-cmd --reload
```
 
**Lanzar instalación de k3s como master:**
 
```bash
curl -sfL https://get.k3s.io | INSTALL_K3S_VERSION=v1.29.1+k3s1 sh -s - server \
  --token "<TOKEN>" \
  --tls-san <IP_DEL_MASTER> \
  --cluster-init \
  --node-taint "node-role.kubernetes.io/control-plane:NoSchedule"
```
 
> [!IMPORTANT]
> Se debe indicar la IP que tiene el Master y un token personalizado. Este token se usará para unir los demás nodos al Clúster.
 
---
 
### Instalación y configuración de otros Nodos de CONTROL (alta disponibilidad)
 
Existe la posibilidad de crear nodos que tomen el control del cluster en el caso de que el Master falle. Para esto hace falta otro nodo de características similares al Master.
 
**Abrir puertos necesarios en firewalld:**
 
```bash
firewall-cmd --permanent --add-port=6443/tcp
firewall-cmd --permanent --add-port=2379/tcp
firewall-cmd --permanent --add-port=2380/tcp
firewall-cmd --permanent --add-port=8472/udp
firewall-cmd --permanent --add-port=10250/tcp
firewall-cmd --reload
```
 
**Lanzar instalación de k3s como control-plane:**
 
```bash
curl -sfL https://get.k3s.io | INSTALL_K3S_VERSION=v1.29.1+k3s1 sh -s - server \
  --token "<TOKEN>" \
  --tls-san <IP_DEL_MASTER> \
  --server https://<IP_DEL_MASTER>:6443 \
  --node-taint "node-role.kubernetes.io/control-plane:NoSchedule"
```
 
> [!TIP]
> Si se quiere que este nodo ejecute pods y no solo tareas de control, se puede suprimir la línea `--node-taint ...`
 
> [!IMPORTANT]
> Se debe indicar el mismo `TOKEN` que se definió en la creación del nodo master, y en la URL se debe poner la IP del nodo master.
 
---
 
### Instalación y unión al clúster de los WORKERS
 
```bash
curl -sfL https://get.k3s.io | INSTALL_K3S_VERSION=v1.29.1+k3s1 \
  K3S_URL=https://<IP_MASTER>:6443 \
  K3S_TOKEN="<TOKEN>" sh -
```
 
> [!IMPORTANT]
> Se debe indicar el mismo `TOKEN` definido en la creación del nodo master y la IP del nodo master en la URL.
 
Al lanzar esto, el clúster estará creado y funcionando.
 
---
 
## INSTALACIÓN CON ANSIBLE
 
### Máquina de Ansible
 
Deberá ser una máquina aparte con comunicación SSH con los nodos y acceso a Internet.
 
```bash
sudo apt update
sudo apt install python3-pip git sshpass python3-lxml
sudo apt install pipx -y
pipx install ansible-core==2.17.0
export PATH=/root/.local/bin:$PATH
ansible-galaxy collection install ansible.posix
mkdir k3s-instalador
```
 
Dentro de la carpeta `k3s-instalador` se coloca el playbook descomprimido.
 
---
 
### Ficheros de configuración
 
#### `hosts`
 
Fichero donde se indican los nodos a configurar: master, control-planes y workers.
 
Cada nodo del fichero cuenta con 3 campos modificables:
 
```ini
<HOSTNAME-HOST> ansible_host=<IP_HOST> ansible_ssh_pass=<PASSWD_ROOT_HOST>
```
 
> El hostname indicado en este fichero se asignará a la máquina virtual correspondiente al lanzar el playbook.  
> Si se quieren añadir más workers o control-planes, se añaden más líneas en su apartado con sus respectivos campos.
 
En el apartado `[all:vars]` se indica:
 
- **`k3s_load_balancer`**: IP del Master si no existen control-planes. Si existen control-planes, se deberá crear un balanceador de carga externo e indicar su IP.
- **`token`**: Token con requisitos de complejidad. Será la cadena que utilicen los nodos para autenticarse al unirse al clúster.
---
 
### Lanzar el Playbook
 
**Despliegue completo:**
 
```bash
ansible-playbook cluster_builder.yaml -i hosts
```
 
**Despliegue de máquinas nuevas** en un entorno ya configurado *(deben añadirse en el fichero `hosts` primero)*:
 
```bash
ansible-playbook cluster_builder.yaml -i hosts --limit <HOSTNAME_VM_NUEVA>
```
 
> Se pueden especificar varios nodos a la vez separando sus hostnames por `,` sin espacios.
 
---
 
### Comandos de verificación del Cluster
 
Ejecutar desde el nodo maestro o nodos de control:
 
```bash
k3s kubectl get nodes
k3s kubectl get pods -A
k3s kubectl cluster-info
```
 

