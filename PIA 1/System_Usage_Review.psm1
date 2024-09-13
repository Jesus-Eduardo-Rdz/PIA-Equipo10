# Habilitar el modo estricto para mayor control sobre el uso de variables
Set-StrictMode -Version Latest

 <#
    SYNOPSIS
    Hace un chequeo completo del equipo

    .DESCRIPTION
    Este modulo realiza un chequeon completo del CPU, la Memoria, el Disco y la red del equipo 

    .EXAMPLE
    Memory-Usage

    .NOTES
    Este modulo consta de varias funciones cada una con un uso diferente.
    #>



# Función para manejo de errores
function Handle-Error {
    param (
        [string]$Section
    )
    Write-Host "Error al obtener datos de $Section. Verifique el sistema y vuelva a intentar." -ForegroundColor Red
}

function Cpu-Usage {
# Verificar uso de procesador
    try {
        $cpuLoad = Get-WmiObject Win32_Processor | Measure-Object -Property LoadPercentage -Average | Select-Object -ExpandProperty Average
    Write-Host "Uso de CPU: $([math]::Round($cpuLoad, 2))%"
    } catch {
        Handle-Error -Section "CPU"
    }
}

function Memory-Usage {
# Verificar uso de memoria
    try {
        $mem = Get-WmiObject Win32_OperatingSystem
        $memUsage = (($mem.TotalVisibleMemorySize - $mem.FreePhysicalMemory) / $mem.TotalVisibleMemorySize) * 100
        Write-Host "Uso de Memoria: $([math]::Round($memUsage, 2))%"
    } catch {
        Handle-Error -Section "Memoria"
    }
}

function Disk-Usage {
# Verificar uso de disco
    try {
        $disk = Get-WmiObject Win32_LogicalDisk -Filter "DriveType=3"
        foreach ($d in $disk) {
            $diskUsage = (($d.Size - $d.FreeSpace) / $d.Size) * 100
            Write-Host "Uso de Disco en $($d.DeviceID): $([math]::Round($diskUsage, 2))%"
        }
    } catch {
        Handle-Error -Section "Disco"
    }
}

function Net-Usage {
# Verificar uso de red
    try {
        $networkAdapters = Get-NetAdapterStatistics
        foreach ($adapter in $networkAdapters) {
            Write-Host "Adaptador: $($adapter.Name) - Bytes Recibidos: $($adapter.ReceivedBytes) - Bytes Enviados: $($adapter.SentBytes)"
        }
    } catch {
    Handle-Error -Section "Red"
    }
}
