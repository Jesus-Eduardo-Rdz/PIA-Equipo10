﻿Set-StrictMode -Version Latest

# Importar los módulos
Import-Module -Name "C:\Users\Eduardo\Documents\Ciberseguridad\PIA 1\System_Usage_Review"
Import-Module -Name "C:\Users\Eduardo\Documents\Ciberseguridad\PIA 1\Get_Hidden_Files"
Import-Module -Name "C:\Users\Eduardo\Documents\Ciberseguridad\PIA 1\Get_Hash"
Import-Module -Name "C:\Users\Eduardo\Documents\Ciberseguridad\PIA 1\Find_Suspicious_Processes"

# Menú Principal
$exitHelpMenu = $false
while (-not $exitHelpMenu) {
    Write-Host "      Menu
             1-Chequeo de los usos del sistema
             2-Encontrar Procesos Sospechosos
             3-Listar Archivos Ocultos
             4-Revision de Hashes
             5-Ayuda
             6-Salir"
    $op = Read-Host "Eliga alguna opcion"

    Switch ($op) {
        1 { 
            while ($true) {
                Write-Host "   Menu de Chequeo
                             1-Uso del CPU
                             2-Uso de la Memoria
                             3-Uso del Disco
                             4-Uso de Red
                             5-Salir"
                $op1 = Read-Host "Eliga alguna opcion"
                Switch ($op1) {
                    1 { 
                        Cpu-Usage 
                    }
                    2 { 
                        Memory-Usage 
                    }
                    3 { 
                        Disk-Usage 
                    }
                    4 { 
                        Net-Usage 
                    }
                    5 { 
                        Write-Host "Saliendo Menu de Chequeo"
                        break 
                    }
                    default { 
                        Write-Host "Opcion no valida" 
                    }
                }
            }
        }
        2 { 
            Check-SuspiciousProcesses 
        }
        3 { 
            Get-HiddenFiles 
        }
        4 { 
            Get-FileHashAndVirusTotal 
        }
        5 {
            $exitHelpMenu = $false
            while (-not $exitHelpMenu) {
                Write-Host "   Menu Ayuda
                             1-Descripcion de Comandos
                             2-Descripcion de Funciones
                             3-Documentacion
                             4-Salir"
                $op2 = Read-Host "Eliga alguna opcion"
                Switch ($op2) {
                    1 {
                        Write-Host "   Menu Comandos
                             1-Get-WmiObject
                             2-Get-NetAdapterStatistics
                             3-Get-AuthenticodeSignature
                             4-Get-ChildItem
                             5-Get-FileHash
                             6-Invoke-RestMethod
                             7-Salir"
                        $op1 = Read-Host "Eliga alguna opcion"
                        Switch ($op1) {
                            1 { 
                                Get-Help -Name Get-WmiObject 
                            }
                            2 { 
                                Get-Help -Name Get-NetAdapterStatistics 
                            }
                            3 { 
                                Get-Help -Name Get-AuthenticodeSignature 
                            }
                            4 { 
                                Get-Help -Name Get-ChildItem 
                            }
                            5 { 
                                Get-Help -Name Get-FileHash 
                            }
                            6 { 
                                Get-Help -Name Invoke-RestMethod 
                            }
                            7 { 
                                Write-Host "Saliendo Menu Comandos"
                                break 
                            }
                            default { 
                                Write-Host "Opcion no valida" 
                            }
                        }
                    }
                    2 {
                        Write-Host "        Funciones disponibles
                                         - Chequeo de los usos del sistema
                                            * Cpu_Usage: Muestra el uso del CPU.
                                            * Memory_Usage: Muestra el uso de la memoria.
                                            * Disk_Usage: Muestra el uso del disco.
                                            * Net_Usage: Muestra el uso de la red.
                                         - Check-SuspiciousProcesses: Encuentra procesos sospechosos.
                                         - Get-HiddenFiles: Lista archivos ocultos.
                                         - Get-FileHashAndVirusTotal: Revisa hashes de archivos y consulta con la API de VirusTotal."
                    }
                    3 {
                        Write-Host "   Documentacion
                                    1-PowerShell
                                    2-System_Usage_Review
                                    3-Get_Hidden_Files
                                    4-Get_Hash
                                    5-Find_Suspicious_Processes
                                    6-Salir"
                        $op3 = Read-Host "Eliga alguna opcion"
                        Switch ($op3) {
                            1 { 
                                Get-Help -Name PowerShell 
                            }
                            2 { 
                                Get-Help -Name System_Usage_Review 
                            }
                            3 { 
                                Get-Help -Name Get_Hidden_Files 
                            }
                            4 { 
                                Get-Help -Name Get_Hash 
                            }
                            5 { 
                                Get-Help -Name Find_Suspicious_Processes 
                            }
                            6 { 
                                Write-Host "Saliendo Documentacion"
                                break 
                            }
                            default { 
                                Write-Host "Opcion no valida" 
                            }
                        }
                    }
                    4 { 
                        Write-Host "Saliendo Menu Ayuda"
                        $exitHelpMenu = $true
                    }
                    default { 
                        Write-Host "Opcion no valida" 
                    }
                }
            }
        }
        6 { 
            Write-Host "Saliendo del programa"
            $exitHelpMenu = $true 
        }
        default { 
            Write-Host "Opcion no valida" 
        }
    }
}
