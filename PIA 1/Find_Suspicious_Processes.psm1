Set-StrictMode -Version Latest

<#
    .SYNOPSIS
    Verifica procesos sospechosos en el sistema.

    .DESCRIPTION
    Esta función verifica los procesos en ejecución en el sistema y detecta aquellos que superan ciertos umbrales de uso de CPU y memoria, o que tienen nombres sospechosos. También verifica la firma digital de los ejecutables.

    .PARAMETER CpuThreshold
    El umbral de uso de CPU para considerar un proceso como sospechoso. El valor predeterminado es 20.

    .PARAMETER MemoryThreshold
    El umbral de uso de memoria (en MB) para considerar un proceso como sospechoso. El valor predeterminado es 100MB.

    .EXAMPLE
    Check-SuspiciousProcesses -CpuThreshold 30 -MemoryThreshold 200MB

    .NOTES
    Esta función requiere permisos de administrador para obtener la información completa de los procesos.
#>

# Se requiere permisos de administrador para obtener la información completa de los procesos
function Check-SuspiciousProcesses {
    #Utilizamos el cmdletbinding para poder usar operadores mas avanzads que nos ayuden con el script
    [CmdletBinding()]
    param (
        [int]$CpuThreshold = 20,  # Umbral de uso de CPU
        [int]$MemoryThreshold = 100MB  # Umbral de uso de memoria
    )

    #variable que busca nombres sospechosos en el sistema
    $suspiciousNames = @("svchost.exe", "cmd.exe", "powershell.exe", "explorer.exe", "taskmgr.exe")

    try {
        # Obtiene todos los procesos en ejecución
        $processes = Get-Process | Where-Object { $_.Id -ne 0 }

        foreach ($process in $processes) {
            $isSuspicious = $false
            #La variable warnings se usa para enviar al finals los mensajes de advertencia de los procesos buscados
            $warnings = @()

            # Verifica el uso de CPU
            if ($process.CPU -gt $CpuThreshold) {
                $isSuspicious = $true
                $warnings += "Uso elevado de CPU ($($process.CPU)%)"
            }

            # Verifica el uso de memoria
            if ($process.WorkingSet -gt ($MemoryThreshold * 1MB)) {
                $isSuspicious = $true
                $memUsageMB = int
                $warnings += "Uso elevado de memoria ($memUsageMB MB)"
            }

            # Verifica los nombres de procesos sospechosos
            if ($suspiciousNames -contains $process.Name) {
                $isSuspicious = $true
                $warnings += "Nombre de proceso sospechoso ($($process.Name))"
            }

            # Verificaa la firma digital del ejecutable
            $filePath = $null
            try {
                $filePath = $process.Path
            } catch {
                # Maneja el error si no se puede acceder a la ruta
                $warnings += "No se pudo obtener la ruta del ejecutable"
            }

            if ($filePath) {
                $signatureStatus = (Get-AuthenticodeSignature -FilePath $filePath -ErrorAction SilentlyContinue).Status
                if ($signatureStatus -and $signatureStatus -ne 'Valid') {
                    $isSuspicious = $true
                    $warnings += "Firma digital no válida"
                }
            }

            # Muestra los detalles del proceso sospechoso
            if ($isSuspicious) {
                Write-Host "Proceso sospechoso detectado: $($process.Name) [ID: $($process.Id)]"  
                Write-Host "  Ruta: $filePath"
                Write-Host "  Advertencias: $($warnings -join ', ')" 
            }
        }
    } catch {
        Write-Host "Error al obtener información de procesos: $_" 
    }
}
