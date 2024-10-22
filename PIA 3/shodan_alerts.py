import shodan
from fpdf import FPDF
import time
import datetime

# Función para solicitar datos de entrada del usuario
# Recoge la clave API de Shodan, las direcciones IP o dominios a monitorizar,
# y el intervalo de tiempo entre cada escaneo (en segundos).
def get_user_input():
    api_key = input("Please enter your Shodan API key: ")  # Solicita la API Key de Shodan
    devices = input("Enter the IP addresses or domains to monitor (separated by commas): ").split(',')  # Solicita IPs o dominios separados por comas
    interval = int(input("Enter the interval (in seconds) between each scan (e.g., 3600 for 1 hour): "))  # Intervalo de escaneo en segundos
    return api_key, devices, interval  # Retorna los valores ingresados

# Función para realizar el escaneo de dispositivos con Shodan.
# Usa la API de Shodan para escanear los dispositivos y recolectar información sobre los puertos abiertos.
# Espera un intervalo entre cada escaneo para evitar superar los límites de API.
def shodan_scan(api_key, devices, interval):
    api = shodan.Shodan(api_key)  # Inicializa la API de Shodan con la API Key proporcionada
    results = {}  # Diccionario para almacenar los resultados del escaneo

    for device in devices:  # Itera sobre cada IP o dominio ingresado
        try:
            host = api.host(device.strip())  # Realiza el escaneo de la IP o dominio
            open_ports = [item['port'] for item in host['data']]  # Extrae los puertos abiertos
            results[device] = {'open_ports': open_ports}  # Almacena los resultados en el diccionario
            print(f"Checked device {device}, Open ports: {open_ports}")  # Muestra los resultados en la consola
        except shodan.APIError as e:  # Manejo de errores de la API de Shodan
            print(f"Error with Shodan API for device {device}: {e}")  # Imprime el error en la consola
            results[device] = {'error': str(e)}  # Guarda el error en los resultados

        time.sleep(interval)  # Pausa para respetar el intervalo entre escaneos
    return results  # Retorna el diccionario con los resultados del escaneo

# Clase PDF para generar un informe en PDF con los resultados del escaneo
# Extiende la clase FPDF para definir el encabezado y pie de página del reporte.
class PDF(FPDF):
    def header(self):
        self.set_font('Arial', 'B', 12)  # Configura la fuente para el encabezado
        self.cell(0, 10, 'Shodan Scan Report', 0, 1, 'C')  # Título del encabezado

    def footer(self):
        self.set_y(-15)  # Establece la posición del pie de página
        self.set_font('Arial', 'I', 8)  # Configura la fuente para el pie de página
        self.cell(0, 10, f'Page {self.page_no()}', 0, 0, 'C')  # Añade número de página

# Función para generar el reporte en PDF con los resultados del escaneo.
# Usa los resultados obtenidos de la función shodan_scan para generar un archivo PDF.
def generate_shodan_report(results):
    pdf = PDF()  # Crea una instancia de la clase PDF
    pdf.add_page()  # Añade una página al PDF

    pdf.set_font('Arial', 'B', 12)
    pdf.cell(0, 10, 'Shodan Scan Results', 0, 1)  # Título del reporte

    pdf.set_font('Arial', '', 10)  # Configura la fuente para el contenido

    for device, data in results.items():  # Itera sobre los resultados del escaneo
        if "error" in data:  # Si hubo un error, se muestra en el reporte
            pdf.cell(0, 10, f"Device: {device} - Error: {data['error']}", 0, 1)
        else:  # Si no hubo error, se muestran los puertos abiertos
            pdf.cell(0, 10, f"Device: {device}", 0, 1)
            pdf.cell(0, 10, f"Open ports: {data['open_ports']}", 0, 1)
        pdf.ln(5)  # Salto de línea para separar dispositivos

    # Genera un nombre de archivo único basado en la fecha y hora actual
    current_time = datetime.datetime.now().strftime("%Y%m%d_%H%M%S")
    filename = f'shodan_scan_report_{current_time}.pdf'  # Nombre del archivo PDF
    pdf.output(filename)  # Guarda el archivo PDF
    print(f"Report generated successfully: {filename}")  # Imprime el nombre del archivo generado
    return filename  # Retorna el nombre del archivo generado

# Punto de entrada principal del script
if __name__ == '__main__':
    # Obtiene los datos de entrada del usuario
    api_key, devices, interval = get_user_input()  # Solicita la API Key, dispositivos e intervalo
    # Realiza el escaneo de Shodan con los datos ingresados
    results = shodan_scan(api_key, devices, interval)
    # Genera un informe en PDF con los resultados obtenidos
    report_name = generate_shodan_report(results)
    print(f"The report has been saved as: {report_name}")  # Informa al usuario sobre el archivo guardado
