Set-StrictMode -Version Latest

<#
    SYNOPSIS
    Hace un chequeo completo del equipo

    .DESCRIPTION
    Este modulo realiza un chequeo completo del CPU, la Memoria, el Disco y la red del equipo 

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
    Write-Host "Error al obtener datos de $Section. Verifique el sistema y vuelva a intentar."
}

function Cpu-Usage {
    # Verificar uso de procesador
    try {
        #Se mide el porcentaje promedio de uso de la CPU
        $cpuLoad = Get-WmiObject Win32_Processor | Measure-Object -Property LoadPercentage -Average | Select-Object -ExpandProperty Average
        Write-Host ("Uso de CPU: {0:N2}%" -f $cpuLoad)
    } catch {
        Handle-Error -Section "CPU"
    }
}

function Memory-Usage {
    # Verificar uso de memoria
    try {
        $mem = Get-WmiObject Win32_OperatingSystem
        #Sd mide el porcetaje del uso de la memoria restando el total de memoria menos la memoria libre entre el total de memoria, despues se multiplica por 100 
        $memUsage = (($mem.TotalVisibleMemorySize - $mem.FreePhysicalMemory) / $mem.TotalVisibleMemorySize) * 100
        Write-Host ("Uso de Memoria: {0:N2}%" -f $memUsage)
    } catch {
        Handle-Error -Section "Memoria"
    }
}

function Disk-Usage {
    # Verificar uso de disco
    try {
        $disk = Get-WmiObject Win32_LogicalDisk -Filter "DriveType=3"
        #Usando un for checamos el uso de cada disco de la computadora, y hacemos el mismo procedimiento que con la memoria para verificar el uso de los discos
        foreach ($d in $disk) {
            $diskUsage = (($d.Size - $d.FreeSpace) / $d.Size) * 100
            Write-Host ("Uso de Disco en $($d.DeviceID): {0:N2}%" -f $diskUsage)
        }
    } catch {
        Handle-Error -Section "Disco"
    }
}

function Net-Usage {
    # Verificar uso de red
    try {
        $networkAdapters = Get-NetAdapterStatistics
        #Con el for nos movemos por cada adaptador de red y checamos la cantidad de bytes recibidos y enviados del equipo
        foreach ($adapter in $networkAdapters) {
            Write-Host "Adaptador: $($adapter.Name) - Bytes Recibidos: $($adapter.ReceivedBytes) - Bytes Enviados: $($adapter.SentBytes)"
        }
    } catch {
        Handle-Error -Section "Red"
    }
}

