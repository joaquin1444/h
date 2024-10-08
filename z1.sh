#!/bin/bash

verificar_binario() {
    # Obtener nombre y ruta del binario
    NOMBRE_BINARIO="$(basename "$0")"
    RUTA_BINARIO="$(readlink -f "$0")"

    # Firma esperada en hexadecimal
    FIRMA_ESPERADA="6a6f617175696e"

    if [[ ! -f "$RUTA_BINARIO" ]]; then
        echo "El archivo '$RUTA_BINARIO' no existe."
        exit 1
    fi

    # Verificar el tamaño del archivo
    TAMANO_BINARIO=$(stat -c%s "$RUTA_BINARIO")

    if [[ $TAMANO_BINARIO -lt 8 ]]; then
        echo "El archivo binario es demasiado corto para contener una firma."
        exit 1
    fi

    # Obtener los últimos 8 bytes del binario
    ULTIMOS_BYTES=$(xxd -p -s -8 -l 8 "$RUTA_BINARIO")

    # Eliminar ceros adicionales
    FIRMA_OBTENIDA=$(echo "$ULTIMOS_BYTES" | sed 's/^00//')

    # Verificar la firma
    if [[ "$FIRMA_OBTENIDA" == "$FIRMA_ESPERADA" ]]; then
        echo "La firma es válida. Ejecutando el código del script..."

        # Calcular la firma md5sum
        MD5SUM_OBTENIDO=$(md5sum "$RUTA_BINARIO" | awk '{ print $1 }')
        echo "MD5SUM del binario: $MD5SUM_OBTENIDO"

        # Calcular la firma sha256sum
        SHA256SUM_OBTENIDO=$(sha256sum "$RUTA_BINARIO" | awk '{ print $1 }')
        echo "SHA256SUM del binario: $SHA256SUM_OBTENIDO"

        # Llamar a la función por6 solo si la firma es válida
        por6
    else
        echo "La firma es inválida. Eliminando el archivo..."
        rm -- "$RUTA_BINARIO"
        exit 1  # Salir si la firma es inválida
    fi
}


# Llamada a la función
verificar_binario
