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

function Get-FileHashAndVirusTotal {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory=$true)]
        [string]$FilePath,

        [Parameter(Mandatory=$true)]
        [string]$ApiKey,

        [ValidateSet('MD5', 'SHA1', 'SHA256')]
        [string]$HashAlgorithm = 'SHA256'
    )

    # Calcular el hash del archivo
    try {
        $fileHash = Get-FileHash -Path $FilePath -Algorithm $HashAlgorithm
        $hashValue = $fileHash.Hash
        Write-Host "Hash calculado ($HashAlgorithm): $hashValue"
    } catch {
        Write-Host "Error al calcular el hash del archivo: $_" 
        return
    }

    # Consultar la API de VirusTotal
    try {
        $virusTotalUrl = "https://www.virustotal.com/vtapi/v2/file/report?apikey=$ApiKey&resource=$hashValue"
        $response = Invoke-RestMethod -Uri $virusTotalUrl -Method Get

        if ($response.response_code -eq 1) {
            Write-Host "Archivo encontrado en VirusTotal. Resultados:"
            Write-Host "  Positivo: $($response.positives) detecciones de $($response.total) análisis"
            Write-Host "  URL de reporte: $($response.permalink)"
        } else {
            Write-Host "Archivo no encontrado en VirusTotal." 
        }
    } catch {
        Write-Host "Error al consultar la API de VirusTotal: $_" 
    }
}
