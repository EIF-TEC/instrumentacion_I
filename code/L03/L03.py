# -*- coding: utf-8 -*-
import serial
import csv
from datetime import datetime
import matplotlib.pyplot as plt
from drawnow import drawnow

arduino = serial.Serial('COM14')
nombre = "bmp280"
narchivo = 1
mediciones = 10

def data_fig():
    plt.plot(sec, pres)

datos = []
sec = []
pres = []

arduino.write(b'0')

for i in range(mediciones):
    dato = arduino.readline()[:-2].decode('utf-8').split(',')
    print(dato)
    datos.append([datetime.now().strftime(format="%Y-%m-%d %H:%M:%S"),
                  float(dato[0]),
                  float(dato[1])])
    sec.append(i)
    pres.append(float(dato[1]))
    drawnow(data_fig)

seguir = input("Cualquier tecla")

# Guardar en CSV
with open(f"{nombre}_{narchivo}.csv", "w", newline="") as f:
    writer = csv.writer(f)
    writer.writerow(["timestamp", "Temperatura (C)", "Presion (hPa)"])  # encabezados
    writer.writerows(datos)

print("Datos guardados en mediciones.csv")
