import psutil
import logging

# Configuracion de logging para registrar los eventos
logging.basicConfig(
    filename='reporte.log',
    level=logging.INFO,
    format='%(asctime)s - %(levelname)s - %(message)s'
)

# Definicion de puertos y procesos no autorizados
UNAUTHORIZED_PORTS = [22, 135, 445, 3389]
UNAUTHORIZED_PROCESS = ['malware.exe', 'virus.exe', 'backdoor.sh']

# Lista que almacenara las conexiones no autorizadas
conexiones_detectadas = []

# Obtener todas las conexiones de red activas
for conexion in psutil.net_connections(kind='inet'):
    laddr = conexion.laddr  # Direccion local de la conexion
    raddr = conexion.raddr  # Direccion remota de la conexion

    # Verificar si el puerto usado es no autorizado
    if laddr and laddr.port in UNAUTHORIZED_PORTS:
        # Agregar a la lista de conexiones no autorizadas
        conexiones_detectadas.append((laddr, raddr))

# Verificacion y manejo de las conexiones detectadas
if conexiones_detectadas:
    logging.warning(f"Conexiones de red no autorizadas detectadas: {conexiones_detectadas}")
    print(f"Advertencia: Conexiones de red no autorizadas detectadas: {conexiones_detectadas}")
else:
    logging.info("No se detectaron conexiones de red sospechosas.")
    print("No se detectaron conexiones de red sospechosas.")

# Verificacion de procesos no autorizados
procesos_activos = []

# Iterar sobre todos los procesos activos
for proc in psutil.process_iter():
    try:
        # Obtener el nombre del proceso
        nombre_proceso = proc.name()
    except (psutil.NoSuchProcess, psutil.AccessDenied, psutil.ZombieProcess):
        # Si hay un error al obtener el nombre del proceso, continuar
        continue

    # Agregar el nombre del proceso a la lista de procesos activos
    procesos_activos.append(nombre_proceso)

procesos_detectados = []

# Verificar si algun proceso no autorizado esta en ejecucion
for proceso in UNAUTHORIZED_PROCESS:
    if proceso in procesos_activos:
        # Agregar el proceso no autorizado a la lista de procesos detectados
        procesos_detectados.append(proceso)

# Verificacion y manejo de los procesos detectados
if procesos_detectados:
    logging.warning(f"Procesos no autorizados detectados: {procesos_detectados}")
    print(f"Advertencia: Procesos no autorizados detectados: {procesos_detectados}")
else:
    logging.info("No se detectaron procesos externos no autorizados.")
    print("No se detectaron procesos externos no autorizados.")

# Verificacion final del sistema
if conexiones_detectadas or procesos_detectados:
    logging.warning("Se detecto actividad sospechosa en el sistema.")
    print("Se detecto actividad sospechosa en el sistema.")
else:
    logging.info("El sistema esta limpio. No se detecto actividad sospechosa.")
    print("El sistema esta limpio. No se detecto actividad sospechosa.")
