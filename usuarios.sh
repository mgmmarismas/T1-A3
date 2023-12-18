#!/bin/bash

# Función para generar el nombre de usuario automáticamente
generauser() {
  nombre=$1
  apellido1=$2
  apellido2=$3
  dni=$4

  # Generar el nombre de usuario automáticamente
   nombre_usuario=$(echo "${nombre:0:1}" | tr '[:upper:]' '[:lower:]')$(echo "${apellido1:0:3}" | tr '[:upper:]' '[:lower:]')$(echo "${apellido2:0:3}" | tr '[:upper:]' '[:lower:]')$(echo "${dni:5:3}")


  echo "$nombre_usuario"
}

# Función para verificar si un nombre de usuario ya existe
existe() {
  nombre_usuario=$1
  grep -q "^.*:$nombre_usuario\$" usuarios.csv
}

# Función para mostrar el menú
menu() {
  echo "1.- EJECUTAR COPIA DE SEGURIDAD"
  echo "2.- DAR DE ALTA USUARIO"
  echo "3.- DAR DE BAJA AL USUARIO"
  echo "4.- MOSTRAR USUARIOS"
  echo "5.- MOSTRAR LOG DEL SISTEMA"
  echo "6.- SALIR"
}

# Función para autenticar al usuario
autenticar_usuario() {
  intentos=0
  usuario_valido=false

  if [ "$1" = "-root" ]; then
    if [ -z "$2" ]; then
      read -s -p "Ingrese su nombre de usuario: " usuario
      echo
    else
      usuario="$2"
    fi

    if [ "$usuario" = "admin" ]; then
      usuario_valido=true
      # Agregar entrada al log
      log_entry="Intento de inicio de sesión como 'admin' con privilegios de root el $(date +"%d%m%Y a las %H:%M:%S")"
      echo "$log_entry" >> log.log
    else
      echo "Acceso no permitido para el usuario '$usuario'. Inténtelo de nuevo."
      exit 1
    fi
  else
    while [ "$intentos" -lt 3 ] && [ "$usuario_valido" = false ]; do
      read -s -p "Ingrese su nombre de usuario: " usuario
      echo

      if [ "$usuario" = "admin" ]; then
        echo "Acceso no permitido para el usuario 'admin'. Inténtelo de nuevo."
        ((intentos++))
      elif [ -s "usuarios.csv" ] && existe "$usuario"; then
        usuario_valido=true
      else
        echo "Nombre de usuario inválido. Inténtelo de nuevo."
        ((intentos++))
      fi
    done

    if [ "$usuario_valido" = true ]; then
      # Agregar entrada al log
      log_entry="Inicio de sesión exitoso como '$usuario' el $(date +"%d%m%Y a las %H:%M:%S")"
      echo "$log_entry" >> log.log
    else
      # Agregar entrada al log
      log_entry="Intento fallido de inicio de sesión con '$usuario' el $(date +"%d%m%Y a las %H:%M:%S")"
      echo "$log_entry" >> log.log
    fi
  fi

  if [ "$usuario_valido" = false ]; then
    echo "No se pudo autenticar. Saliendo del script."
    exit 1
  fi

  clear
  echo "Bienvenido al Sistema de Usuarios"

}
# Función principal del script
main() {
autenticar_usuario "$@"
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
  # Agregar entrada al log
  log_entry="INFO: Copia de seguridad realizada con éxito. Archivo: $copia_filename.zip. Verificado el $(date +"%d%m%Y a las %H:%M:%S")"
  echo "$log_entry" >> log.log
}

# Función para dar de alta a un usuario (opción 2)
alta() {
  clear
  echo "Opción 2: DAR DE ALTA USUARIO"

  # Verificar si el usuario autenticado es "admin"
  if [ "$usuario" != "admin" ]; then
    echo "Error: Solo el usuario 'admin' puede dar de alta usuarios."
    
    # Agregar entrada al log
    log_entry="Intento de dar de alta usuario por '$usuario' (no autorizado) el $(date +"%d%m%Y a las %H:%M:%S")"
    echo "$log_entry" >> log.log

    return 1
  fi

  # Agregar entrada al log
  log_entry="Acceso a dar de alta usuarios por '$usuario' el $(date +"%d%m%Y a las %H:%M:%S")"
  echo "$log_entry" >> log.log

  # Solicitar datos del usuario
  read -p "Nombre: " nombre
  read -p "Primer Apellido: " apellido1
  read -p "Segundo Apellido: " apellido2
  read -p "DNI: " dni

  # Validar formato del DNI
  if ! echo "$dni" | grep -qE '^[0-9]{8}[A-Za-z]$'; then
    echo "ERROR: Formato de DNI incorrecto. Por favor, inténtelo de nuevo."

    # Agregar entrada al log
    log_entry="ERROR: Formato de DNI incorrecto al dar de alta. Verificado el $(date +"%d%m%Y a las %H:%M:%S")"
    echo "$log_entry" >> log.log
    return 1
  fi

  # Generar el nombre de usuario automáticamente
  nombre_usuario=$(generauser "$nombre" "$apellido1" "$apellido2" "$dni")

  # Verificar si el usuario ya existe
  if existe "$nombre_usuario"; then
    echo "ERROR: El nombre de usuario '$nombre_usuario' ya existe. Por favor, elija otro nombre."

    # Agregar entrada al log
    log_entry="ERROR: El nombre de usuario '$nombre_usuario' ya existe al dar de alta. Verificado el $(date +"%d%m%Y a las %H:%M:%S")"
    echo "$log_entry" >> log.log
    return 1
  fi

  # Agregar entrada al archivo de usuarios
  echo "$nombre:$apellido1:$apellido2:$dni:$nombre_usuario" >> usuarios.csv

  # Agregar entrada al log
  log_entry="INSERTADO $nombre:$apellido1:$apellido2:$dni:$nombre_usuario el $(date +"%d%m%Y a las %H:%M:%S")"
  echo "$log_entry" >> log.log

  # Mensaje informativo
  echo "Usuario dado de alta con éxito. Nombre de usuario: $nombre_usuario"

  # Agregar entrada al log
  log_entry="Usuario dado de alta con éxito. Nombre de usuario: $nombre_usuario. Verificado el $(date +"%d%m%Y a las %H:%M:%S")"
  echo "$log_entry" >> log.log

}

# Función para dar de baja a un usuario (opción 3)
baja() {
  clear
  echo "Opción 3: DAR DE BAJA USUARIO"

  # Verificar si el usuario autenticado es "admin"
  if [ "$usuario" != "admin" ]; then
    echo "Error: Solo el usuario 'admin' puede dar de baja usuarios."
    
    # Agregar entrada al log
    log_entry="Intento de dar de baja usuario por '$usuario' (no autorizado) el $(date +"%d%m%Y a las %H:%M:%S")"
    echo "$log_entry" >> log.log

    return 1
  fi

  # Agregar entrada al log
  log_entry="Acceso a dar de baja usuarios por '$usuario' el $(date +"%d%m%Y a las %H:%M:%S")"
  echo "$log_entry" >> log.log

  # Solicitar nombre de usuario a dar de baja
  read -p "Nombre de usuario: " nombre_usuario

  # Verificar si el usuario existe
  if ! existe "$nombre_usuario"; then
    echo "ERROR: El usuario '$nombre_usuario' no existe. Por favor, verifique el nombre de usuario."

    # Agregar entrada al log
    log_entry="ERROR: Intento de dar de baja al usuario '$nombre_usuario', que no existe. Verificado el $(date +"%d%m%Y a las %H:%M:%S")"
    echo "$log_entry" >> log.log
    sleep 2
    return 1
  fi

  # Eliminar entrada del usuario
  sed -i "/^.*:$nombre_usuario\$/d" usuarios.csv

  # Agregar entrada al log
  log_entry="ELIMINADO $nombre_usuario el $(date +"%d%m%Y a las %H:%M:%S")"
  echo "$log_entry" >> log.log

  # Mensaje informativo
  echo "Usuario dado de baja con éxito. Nombre de usuario: $nombre_usuario"

  # Volver al menú principal
  sleep 2
}

# Función para mostrar usuarios (opción 4)
mostrar_usuarios() {
  clear
  echo "LISTA DE USUARIOS"

  # Verificar si el archivo está vacío
  if [ ! -s usuarios.csv ]; then
    echo "No hay usuarios para mostrar."
    
    # Agregar entrada al log
    log_entry="Intento de mostrar usuarios, pero no hay usuarios registrados el $(date +"%d%m%Y a las %H:%M:%S")"
    echo "$log_entry" >> log.log

    # Esperar antes de volver al menú principal
    read -p "Presione Enter para volver al menú principal."
    return
  fi

  # Mostrar usuarios
  cat usuarios.csv | cut -d ":" -f 1,2,3,4

  # Agregar entrada al log
  log_entry="Mostrada lista de usuarios el $(date +"%d%m%Y a las %H:%M:%S")"
  echo "$log_entry" >> log.log

  # Preguntar al usuario si desea ordenar alfabéticamente
  read -p "¿Desea mostrar los usuarios ordenados alfabéticamente? (S/N): " opcion_orden

  if [ "$opcion_orden" == "S" ] || [ "$opcion_orden" == "s" ]; then
    clear
    echo "LISTA DE USUARIOS ORDENADOS ALFABÉTICAMENTE"

    # Mostrar usuarios ordenados alfabéticamente
    cat usuarios.csv | sort -t ":" -k 5

    # Agregar entrada al log
    log_entry="Mostrada lista de usuarios ordenada alfabéticamente el $(date +"%d%m%Y a las %H:%M:%S")"
    echo "$log_entry" >> log.log
  fi

  # Esperar antes de volver al menú principal
  read -p "Presione Enter para volver al menú principal."
}

# Función para mostrar el log del sistema (opción 5)
mostrar_log() {
  clear
  echo "LOG DEL SISTEMA"

  # Agregar entrada al log
  log_entry="Intento de mostrar el log el $(date +"%d%m%Y a las %H:%M:%S")"
  echo "$log_entry" >> log.log

  # Verificar si el log está vacío
  if [ ! -s "log.log" ]; then
    echo "El log está vacío."

    # Agregar entrada al log
    log_entry="Intento de mostrar el log, pero está vacío el $(date +"%d%m%Y a las %H:%M:%S")"
    echo "$log_entry" >> log.log
  else
    # Mostrar log del sistema
    cat log.log

    # Agregar entrada al log
    log_entry="LOG mostrado el $(date +"%d%m%Y a las %H:%M:%S")"
    echo "$log_entry" >> log.log
  fi

  # Esperar antes de volver al menú principal
  read -p "Presione Enter para volver al menú principal."
}

# Función para salir del script (opción 6)
salir() {
  echo "Saliendo del Sistema de Usuarios. ¡Hasta luego!"
  exit 0
}

# Iniciar la ejecución del script
main "$@"

