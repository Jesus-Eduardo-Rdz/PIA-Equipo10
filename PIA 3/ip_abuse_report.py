import requests
import logging
from fpdf import FPDF
import re
import random
import json
import sys
import shutil
import datetime

# Configuración del archivo de logs con nombre basado en la fecha y hora actuales
current_time = datetime.datetime.now().strftime("%Y%m%d_%H%M%S")
log_filename = f'ip_abuse_logs_{current_time}.log'
logging.basicConfig(filename=log_filename, level=logging.DEBUG, format='%(asctime)s %(levelname)s: %(message)s', encoding='utf-8')

# Definición de la URL de la API de AbuseIPDB para las solicitudes
API_URL = 'https://api.abuseipdb.com/api/v2/check'

# Clase personalizada para generar reportes PDF
class PDF(FPDF):
    def header(self):
        # Configura el encabezado del PDF con una fuente en negrita de tamaño 12
        self.set_font('Arial', 'B', 12)
        self.cell(0, 10, 'IP Abuse Report', 0, 1, 'C')  # Título del reporte

    def footer(self):
        # Configura el pie de página del PDF
        self.set_y(-15)  # Mueve la posición a 15mm del final
        self.set_font('Arial', 'I', 8)  # Fuente en cursiva de tamaño 8
        self.cell(0, 10, f'Page {self.page_no()}', 0, 0, 'C')  # Muestra el número de página

# Función para eliminar o reemplazar caracteres no válidos en el texto
def sanitize_text(text):
    # Reemplaza caracteres no compatibles por '?'
    return ''.join([i if ord(i) < 256 else '?' for i in text])

# Función para validar si una entrada es una dirección IP válida
def validate_ip(ip):
    ip_pattern = re.compile(r"^(?:[0-9]{1,3}\.){3}[0-9]{1,3}$")  # Expresión regular para validar IPs
    if ip_pattern.match(ip):  # Si la IP coincide con el patrón
        return True
    return False

# Función para consultar los datos de una IP en la API de AbuseIPDB
def check_ip(ip, api_key):
    try:
        if not validate_ip(ip):
            raise ValueError(f"Invalid IP address: {ip}")  # Lanza una excepción si la IP no es válida

        # Configura los headers y parámetros para la solicitud HTTP
        headers = {'Key': api_key, 'Accept': 'application/json'}
        params = {
            'ipAddress': ip,
            'maxAgeInDays': 365,  # Límite de búsqueda a 365 días
            'verbose': 'true'    # Incluir detalles adicionales en la respuesta
        }
        # Realiza la solicitud GET a la API
        response = requests.get(API_URL, headers=headers, params=params)

        # Verifica si la solicitud fue exitosa
        if response.status_code == 200:
            response.encoding = 'utf-8'  # Forzar codificación a UTF-8
            data = response.json()  # Decodificar la respuesta en formato JSON
            logging.debug(f"API Response for {ip}: {json.dumps(data, indent=4, ensure_ascii=False)}")  # Guardar respuesta en logs
            if 'data' in data:  # Verifica si existe un campo 'data' en la respuesta
                return data['data']  # Retorna los datos de la IP
            else:
                logging.warning(f"No 'data' field in API response for IP: {ip}")  # Log de advertencia
                return None
        else:
            logging.error(f"Failed to retrieve data for IP {ip}. Status code: {response.status_code}. Response: {response.text}")
            return None

    except requests.exceptions.RequestException as e:
        logging.error(f"Request error for IP {ip}: {e}")  # Captura y guarda en logs cualquier error en la solicitud
        return None

# Función para generar el reporte en PDF
def generate_report(ips, api_key, max_entries):
    pdf = PDF()  # Instancia del PDF
    pdf.add_page()  # Añade una página al reporte

    for ip in ips:
        result = check_ip(ip.strip(), api_key)  # Consulta los datos de la IP
        
        if result:
            # Si existen reportes para la IP
            total_reports = result.get('totalReports', 0)
            if total_reports > 0:
                pdf.set_font('Arial', 'B', 12)  # Establece fuente en negrita para el título
                pdf.cell(0, 10, sanitize_text(f'Report for IP: {ip}'), 0, 1)
                pdf.set_font('Arial', '', 10)  # Fuente normal para el contenido
                pdf.cell(0, 10, sanitize_text(f'Total Reports: {total_reports}'), 0, 1)
                pdf.cell(0, 10, sanitize_text(f'Last Reported: {result.get("lastReportedAt", "N/A")}'), 0, 1)
                pdf.cell(0, 10, sanitize_text(f'Abuse Confidence Score: {result.get("abuseConfidenceScore", "N/A")}'), 0, 1)

                # Muestra los detalles de los reportes hasta el número máximo solicitado
                reports = result.get('reports', [])
                if max_entries > 0:
                    reports = reports[:max_entries]

                for report in reports:
                    pdf.cell(0, 10, sanitize_text(f"Reported At: {report['reportedAt']}"), 0, 1)
                    pdf.cell(0, 10, sanitize_text(f"Comment: {report.get('comment', 'N/A')}"), 0, 1)
                    pdf.cell(0, 10, sanitize_text(f"Categories: {', '.join(map(str, report.get('categories', [])))}"), 0, 1)
                    pdf.ln(10)  # Salto de línea para separar reportes

                # Log de generación de reporte
                logging.info(f"Generated report for IP {ip}")
            else:
                pdf.set_font('Arial', 'B', 12)
                pdf.cell(0, 10, sanitize_text(f'No Reports Available for IP {ip} in the last 365 days.'), 0, 1)
                logging.warning(f'No reports available for IP {ip} in the last 365 days.')

        else:
            pdf.set_font('Arial', 'B', 12)
            pdf.cell(0, 10, sanitize_text(f'No Data Available for IP: {ip}'), 0, 1)
            logging.warning(f'No data available for IP: {ip}')
    
    # Genera un nombre de archivo basado en la fecha y hora actual
    current_time = datetime.datetime.now().strftime("%Y%m%d_%H%M%S")
    filename = f'ip_abuse_report_{current_time}.pdf'
    pdf.output(filename)  # Guarda el archivo PDF
    print(f"Report generated successfully: {filename}")

    # Copia los logs a un nuevo archivo con nombre basado en la fecha y hora actual
    log_output = f'ip_abuse_logs_{current_time}.log'
    shutil.copy(log_filename, log_output)  # Copia el archivo original de logs
    print(f"Logs saved successfully as: {log_output}")

# Bloque principal del programa
if __name__ == '__main__':
    try:
        # Solicita la clave API de AbuseIPDB al usuario
        api_key = input("Please enter your IP Abuse API key: ")

        # Verifica que la clave API sea alfanumérica
        if not api_key.isalnum():
            raise ValueError("Invalid API key format. The key should be alphanumeric.")

        # Aviso sobre el límite de tiempo para los reportes
        print("Note: The generated report will only cover data from the last 365 days.")

        # Solicita las direcciones IP a analizar
        ips_to_check = input("Enter the IP addresses to check (separated by commas): ").split(',')

        if not ips_to_check:
            raise ValueError("You must provide at least one IP address.")

        # Solicita el número de reportes a mostrar
        max_entries = int(input("Enter the number of entries to display in the report (0 for all): ") or 10)

        # Valida y ejecuta la generación del reporte para cada IP
        for ip in ips_to_check:
            if not validate_ip(ip.strip()):
                raise ValueError(f"Invalid IP address: {ip}")

        generate_report(ips_to_check, api_key, max_entries)

    except ValueError as ve:
        print(f"Input error: {ve}")  # Muestra el error de entrada

    except Exception as e:
        print(f"An unexpected error occurred: {e}")  # Muestra cualquier otro error inesperado
