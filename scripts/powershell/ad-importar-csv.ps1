<#
.SYNOPSIS
    Importa usuarios en Active Directory desde un fichero CSV.

.EXAMPLE
    .\ad-importar-csv.ps1 -FicheroCSV ".\usuarios-ejemplo.csv" -Servidor "IP-DC" -Credencial $cred
#>

param(
    [Parameter(Mandatory=$true)]
    [string]$FicheroCSV,

    [Parameter(Mandatory=$false)]
    [string]$Servidor = "IP-DE-TU-DC",

    [Parameter(Mandatory=$false)]
    [System.Management.Automation.PSCredential]$Credencial = $null
)

Import-Module ActiveDirectory

# Verificar que el fichero existe
if (-not (Test-Path $FicheroCSV)) {
    Write-Error "No se encuentra el fichero: $FicheroCSV"
    exit 1
}

$dominio   = (Get-ADDomain -Server $Servidor -Credential $Credencial).DistinguishedName
$passTemp  = ConvertTo-SecureString "Practica2024!" -AsPlainText -Force
$usuarios  = Import-Csv -Path $FicheroCSV
$creados   = 0
$errores   = 0

Write-Host "`n=== Importando $($usuarios.Count) usuarios desde $FicheroCSV ===`n"

foreach ($u in $usuarios) {
    $rutaOU = "OU=$($u.OU),$dominio"

    # Saltar si ya existe
    if (Get-ADUser -Filter "SamAccountName -eq '$($u.Usuario)'" -Server $Servidor -Credential $Credencial -ErrorAction SilentlyContinue) {
        Write-Warning "  [OMITIDO]  $($u.Usuario) ya existe - omitido"
        continue
    }

    try {
        New-ADUser `
            -Server             $Servidor `
            -Credential         $Credencial `
            -Name               "$($u.Nombre) $($u.Apellido)" `
            -GivenName          $u.Nombre `
            -Surname            $u.Apellido `
            -SamAccountName     $u.Usuario `
            -UserPrincipalName  "$($u.Usuario)@lab.local" `
            -Path               $rutaOU `
            -Department         $u.Departamento `
            -AccountPassword    $passTemp `
            -ChangePasswordAtLogon $true `
            -Enabled            $true

        Write-Host "  [OK] $($u.Usuario) - $($u.Nombre) $($u.Apellido) ($($u.Departamento))" -ForegroundColor Green
        $creados++

    } catch {
        Write-Host "  [ERROR] Error con $($u.Usuario): $_" -ForegroundColor Red
        $errores++
    }
}

Write-Host "`n=== Resultado ==="
Write-Host "  Creados : $creados"
Write-Host "  Errores : $errores"
Write-Host "  Omitidos: $($usuarios.Count - $creados - $errores)"
