#!/bin/bash

# Función para mostrar el menú
menu() {
  echo "1.- EJECUTAR COPIA DE SEGURIDAD"
  echo "2.- DAR DE ALTA USUARIO"
  echo "3.- DAR DE BAJA AL USUARIO"
  echo "4.- MOSTRAR USUARIOS"
  echo "5.- MOSTRAR LOG DEL SISTEMA"
  echo "6.- SALIR"
}

# Función principal del script
main() {
  clear
  echo "Bienvenido al Sistema de Usuarios"

# Verificar la existencia y formato del archivo "usuarios.csv"
if [ ! -f usuarios.csv ]; then
  # Crear el archivo si no existe
  touch usuarios.csv
  echo "Archivo 'usuarios.csv' creado."
else
  # Verificar si el archivo no está vacío
  if [ -s usuarios.csv ]; then
    # Validar el formato del archivo
    if ! grep -qE '^[^:]+:[^:]+:[^:]+:[0-9]{8}[A-Za-z]:[a-z]{1}[a-z]{3}[a-z]{3}[0-9]{3}$' usuarios.csv; then
      echo "ERROR: El archivo 'usuarios.csv' no cumple con el formato esperado."

      # Agregar entrada al log
      log_entry="ERROR: El archivo 'usuarios.csv' no cumple con el formato esperado. Verificado el $(date +"%d%m%Y a las %H:%M:%S")"
      echo "$log_entry" >> log.log

      # Pedir al usuario que corrija el archivo
      read -p "Por favor, corrija el archivo 'usuarios.csv' y vuelva a ejecutar el script. Presione Enter para salir."
      exit 1
    fi
  else
    echo "El archivo 'usuarios.csv' está vacío. No se realizará la validación del formato."
  fi
fi

  # Bucle principal
  while true; do
    menu
    read -p "Seleccione una opción (1-6): " opcion

    case $opcion in
      1) copia;;
      2) alta;;
      3) baja;;
      4) mostrar_usuarios;;
      5) mostrar_log;;
      6) salir;;
      *) echo "Opción no válida. Inténtelo de nuevo.";;
    esac
  done
}

# Función para ejecutar la copia de seguridad (opción 1)
copia() {
  # Nombre del archivo de copia de seguridad
  copia_filename="copia_usuarios_$(date +"%d%m%Y_%H-%M-%S")"

  # Realizar la copia de seguridad
  cp usuarios.csv "$copia_filename"

  # Comprimir la copia en formato zip
  zip "$copia_filename.zip" "$copia_filename" && rm "$copia_filename"

  # Mensaje informativo
  echo "Copia de seguridad realizada con éxito. Archivo: $copia_filename.zip"

  # Mantener solo las dos copias más recientes
  ls -t copia_usuarios*.zip | tail -n +3 | xargs rm -f
}

# Función para dar de alta a un usuario (opción 2)
alta() {
  # Aquí irá la implementación de dar de alta a un usuario
  echo "Implementar dar de alta..."
}

# Función para dar de baja a un usuario (opción 3)
baja() {
  # Aquí irá la implementación de dar de baja a un usuario
  echo "Implementar dar de baja..."
}

# Función para mostrar usuarios (opción 4)
mostrar_usuarios() {
  # Aquí irá la implementación de mostrar usuarios
  echo "Implementar mostrar usuarios..."
}

# Función para mostrar el log del sistema (opción 5)
mostrar_log() {
  # Aquí irá la implementación de mostrar el log del sistema
  echo "Implementar mostrar log..."
}

# Función para salir del script (opción 6)
salir() {
  echo "Saliendo del Sistema de Usuarios. ¡Hasta luego!"
  exit 0
}

# Iniciar la ejecución del script
main

