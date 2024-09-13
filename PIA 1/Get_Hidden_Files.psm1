Set-StrictMode -Version Latest

function Get-HiddenFiles {
    <#
    .SYNOPSIS
    Lista archivos ocultos en un directorio especificado.

    .DESCRIPTION
    Esta funcion lista todos los archivos ocultos en el directorio especificado.

    .PARAMETER Path
    La ruta del directorio donde se buscarán los archivos ocultos.

    .EXAMPLE
    Get-HiddenFiles -Path "C:\Users\Eduardo\Documents"

    .NOTES
    Esta funcion es parte del modulo Get_Hidden_Files.
    #>
    [CmdletBinding()]
    param (
        [Parameter(Mandatory=$true)]
        [string]$FolderPath
    )

    try {
        # Listar archivos ocultos
        $hiddenFiles = Get-ChildItem -Path $FolderPath -Force | Where-Object { $_.Attributes -match 'Hidden' }

        if ($hiddenFiles.Count -eq 0) {
            Write-Host "No se encontraron archivos ocultos en $FolderPath" -ForegroundColor Yellow
        } else {
            Write-Host "Archivos ocultos encontrados en ${FolderPath}:"
            $hiddenFiles | ForEach-Object {
                Write-Host "  $_.FullName"
            }
        }
    } catch {
        Write-Host "Error al listar archivos ocultos: $_" -ForegroundColor Red
    }
}
