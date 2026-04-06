<#
.SYNOPSIS
    Crea un usuario en Active Directory y lo asigna a una OU.

.DESCRIPTION
    Script para crear usuarios individuales en el dominio lab.local.
    Requiere RSAT instalado y permisos de administrador en el dominio.

.PARAMETER Nombre
    Nombre completo del usuario (ej: "Juan García")

.PARAMETER Usuario
    Nombre de inicio de sesión (ej: "jgarcia")

.PARAMETER OU
    OU donde se creará el usuario (ej: "Usuarios")

.PARAMETER Departamento
    Departamento del usuario (ej: "Informática")

.EXAMPLE
    .\ad-crear-usuario.ps1 -Nombre "Juan García" -Usuario "jgarcia" -OU "Usuarios" -Departamento "Informatica" -Servidor "IP-DC" -Credencial $cred
#>

param(
    [Parameter(Mandatory=$true)]
    [string]$Nombre,

    [Parameter(Mandatory=$true)]
    [string]$Usuario,

    [Parameter(Mandatory=$false)]
    [string]$OU = "Usuarios",

    [Parameter(Mandatory=$false)]
    [string]$Departamento = "General",

    [Parameter(Mandatory=$false)]
    [string]$Servidor = "IP-DE-TU-DC",

    [Parameter(Mandatory=$false)]
    [System.Management.Automation.PSCredential]$Credencial = $null
)

# ── Importar módulo ────────────────────────────────────────
Import-Module ActiveDirectory -ErrorAction Stop

# ── Separar nombre y apellido ──────────────────────────────
$partes     = $Nombre.Split(" ")
$nombre     = $partes[0]
$apellido   = if ($partes.Count -gt 1) { $partes[1..($partes.Count-1)] -join " " } else { "" }

# ── Ruta de la OU ──────────────────────────────────────────
$dominio    = (Get-ADDomain -Server $Servidor -Credential $Credencial).DistinguishedName
$rutaOU     = "OU=$OU,$dominio"

# ── Contraseña temporal ────────────────────────────────────
$passTemp   = ConvertTo-SecureString "Practica2024!" -AsPlainText -Force

# ── Verificar que el usuario no existe ya ─────────────────
if (Get-ADUser -Filter "SamAccountName -eq '$Usuario'" -Server $Servidor -Credential $Credencial -ErrorAction SilentlyContinue) {
    Write-Warning "El usuario '$Usuario' ya existe en el dominio."
    exit 1
}

# ── Crear el usuario ───────────────────────────────────────
try {
    New-ADUser `
        -Server             $Servidor `
        -Credential         $Credential `
        -Name               $Nombre `
        -GivenName          $nombre `
        -Surname            $apellido `
        -SamAccountName     $Usuario `
        -UserPrincipalName  "$Usuario@lab.local" `
        -Path               $rutaOU `
        -Department         $Departamento `
        -AccountPassword    $passTemp `
        -ChangePasswordAtLogon $true `
        -Enabled            $true

    Write-Host "✅ Usuario '$Usuario' creado correctamente en OU '$OU'" -ForegroundColor Green
    Write-Host "   Nombre completo : $Nombre"
    Write-Host "   Departamento    : $Departamento"
    Write-Host "   Contraseña temp : Practica2024! (debe cambiarla en el primer inicio de sesión)"

} catch {
    Write-Error "❌ Error al crear el usuario: $_"
    exit 1
}
