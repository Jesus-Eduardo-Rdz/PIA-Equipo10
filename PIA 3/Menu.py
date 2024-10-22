import shodan_alerts
import ip_abuse_report
import  port_scanner
import url_checker
import unauthorized_processes
import sys

while True:
        print("    Menu Principal")
        print("1-Alertas Shodan")
        print("2-Abuso de IP")
        print("3-Escaneo de Puerto")
        print("4-Cheque de Url")
        print("5-Chequeo de Procesos")
        print("6-Salir ")

        opcion = input("Elige una opcion (1-6): ")

        if opcion == '1':
            shodan_alerts()
        elif opcion == '2':
            ip_abuse_report()
        elif opcion == '3':
            port_scanner()
        elif opcion == '4':
            url_checker()
        elif opcion == '5':
            unauthorized_processes()
        elif opcion == '6':
            print("Saliendo del programa...")
            sys.exit()
        else:
            print("Opcion no valida. Intenta de nuevo.")
