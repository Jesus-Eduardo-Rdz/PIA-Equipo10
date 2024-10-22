import socket

def is_port_open(host: str, port: int) -> bool:
#Verifica si un puerto específico está abierto en el host dado.
    
    try:
        # Crear un nuevo objeto socket
        sock = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
        sock.settimeout(1)
        # Intentar conectarse al host en el puerto dado
        result = sock.connect_ex((host, port))
        sock.close()
        
        # Si el resultado es 0, el puerto está abierto
        return result == 0
    except:
        return False

def scan_ports(host: str, ports: list) -> list:
    open_ports = []
    # Escanear cada puerto en la lista de puertos
    for port in ports:
        if is_port_open(host, port):
            open_ports.append(port)
    return open_ports

if __name__ == "__main__":
    # Ejemplo de uso
    target_host = "127.0.0.1"
    ports_to_check = [22, 80, 443, 8080]

    print(f"Escaneando puertos en {target_host}...")
    open_ports = scan_ports(target_host, ports_to_check)
    
    if open_ports:
        print(f"Puertos abiertos: {open_ports}")
    else:
        print("No se encontraron puertos abiertos.")

