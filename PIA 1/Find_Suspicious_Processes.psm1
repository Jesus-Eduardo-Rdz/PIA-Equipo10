# Habilitar el modo estricto para mayor control sobre el uso de variables
Set-StrictMode -Version Latest

<#
    .SYNOPSIS
    Calcula el hash de un archivo y consulta la API de VirusTotal.

    .DESCRIPTION
    Esta funcion calcula el hash de un archivo utilizando un algoritmo especificado y consulta la API de VirusTotal para obtener un reporte sobre el archivo.

    .PARAMETER FilePath
    La ruta del archivo que se va a verificar.

    .PARAMETER ApiKey
    La clave API para acceder a VirusTotal.

    .PARAMETER HashAlgorithm
    El algoritmo de hash a utilizar. Puede ser 'MD5', 'SHA1' o 'SHA256'. El valor predeterminado es 'SHA256'.

    .EXAMPLE
    Get-FileHashAndVirusTotal -FilePath "C:\Users\Eduardo\Documents\archivo.txt" -ApiKey "tu-api-key"

    .NOTES
    Esta funcion es parte del modulo Get_Hash.
    #>

# Requiere permisos de administrador para obtener la información completa de los procesos
function Check-SuspiciousProcesses {
    [CmdletBinding()]
    param (
        [int]$CpuThreshold = 20,  # Umbral de uso de CPU
        [int]$MemoryThreshold = 100MB  # Umbral de uso de memoria (en MB)
    )

    $suspiciousNames = @("svchost.exe", "cmd.exe", "powershell.exe", "explorer.exe", "taskmgr.exe")

    try {
        # Obtener todos los procesos en ejecución
        $processes = Get-Process | Where-Object { $_.Id -ne 0 }

        foreach ($process in $processes) {
            $isSuspicious = $false
            $warnings = @()

            # Verificar uso de CPU
            if ($process.CPU -gt $CpuThreshold) {
                $isSuspicious = $true
                $warnings += "Uso elevado de CPU ($($process.CPU)%)"
            }

            # Verificar uso de memoria
            if ($process.WorkingSet -gt ($MemoryThreshold * 1MB)) {
                $isSuspicious = $true
                $warnings += "Uso elevado de memoria ($([math]::Round($process.WorkingSet / 1MB, 2)) MB)"
            }

            # Verificar nombres de procesos sospechosos
            if ($suspiciousNames -contains $process.Name) {
                $isSuspicious = $true
                $warnings += "Nombre de proceso sospechoso ($($process.Name))"
            }

            # Verificar la firma digital del ejecutable
            $filePath = $null
            try {
                $filePath = $process.Path
            } catch {
                # Manejo de error si no se puede acceder a la ruta
                $warnings += "No se pudo obtener la ruta del ejecutable"
            }

            if ($filePath) {
                $signatureStatus = (Get-AuthenticodeSignature -FilePath $filePath -ErrorAction SilentlyContinue).Status
                if ($signatureStatus -and $signatureStatus -ne 'Valid') {
                    $isSuspicious = $true
                    $warnings += "Firma digital no válida"
                }
            }

            # Mostrar detalles del proceso sospechoso
            if ($isSuspicious) {
                Write-Host "Proceso sospechoso detectado: $($process.Name) [ID: $($process.Id)]" -ForegroundColor Yellow
                Write-Host "  Ruta: $filePath"
                Write-Host "  Advertencias: $($warnings -join ', ')" -ForegroundColor Red
            }
        }
    } catch {
        Write-Host "Error al obtener información de procesos: $_" -ForegroundColor Red
    }
}
