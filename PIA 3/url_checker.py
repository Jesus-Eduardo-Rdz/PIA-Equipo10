import re

def is_malicious_url(url: str) -> bool:
       # Verifica si la URL contiene muchos números
    if len(re.findall(r'\d', url)) > 6:
        return True

    # Verifica si la URL contiene caracteres especiales inusuales
    if re.search(r'[<>;"\'{}|^~\[\]`]', url):
        return True

    # Verifica si la URL usa dominios de nivel superior sospechosos
    suspicious_tlds = ['.tk', '.xyz', '.cc', '.ml', '.ga']
    if any(url.endswith(tld) for tld in suspicious_tlds):
        return True

    # Si no coincide con ninguno de los patrones, la URL no es sospechosa
    return False

def check_urls(urls: list) -> list:
    suspicious_urls = []

    # Verifica cada URL en la lista
    for url in urls:
        if is_malicious_url(url):
            suspicious_urls.append(url)
    
    return suspicious_urls

if __name__ == "__main__":
    # Pedir que ingrese URLs separadas por comas
    urls_input = input("Ingresa las URLs que quieres verificar (separadas por comas): ")
    
    # Convertir el input en una lista de URLs
    urls_to_check = [url.strip() for url in urls_input.split(",")]
    
    # Verificar las URLs ingresadas
    suspicious_urls = check_urls(urls_to_check)
    
    if suspicious_urls:
        print(f"URLs sospechosas: {suspicious_urls}")
    else:
        print("No se encontraron URLs sospechosas.")
