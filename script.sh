#!/bin/bash

if [ "$#" -ne 2 ]; then
    echo "Uso: ./script.sh <archivo.zip> <directorio_destino>"
    exit 1
fi

ARCHIVO_ZIP="$1"
DIR_DESTINO="$2"

if [ ! -f "$ARCHIVO_ZIP" ]; then
    echo "Error: El archivo '$ARCHIVO_ZIP' no existe o no es un archivo válido."
    exit 1
fi

CARPETA_TEMPORAL=$(mktemp -d)
echo "Directorio temporal creado en: $CARPETA_TEMPORAL"

unzip -q "$ARCHIVO_ZIP" -d "$CARPETA_TEMPORAL"
mkdir -p "$DIR_DESTINO"

echo "Clasificando archivos extraídos en '$DIR_DESTINO'..."

IFS=$'\n'
for archivo in $(find "$CARPETA_TEMPORAL" -type f); do
    nombre_base=$(basename "$archivo")
    
    if [[ "$nombre_base" == *.* && "$nombre_base" != .* ]]; then
        extension="${nombre_base##*.}"
        extension=$(echo "$extension" | tr '[:upper:]' '[:lower:]')
    else
        extension="otros"
    fi

    subcarpeta="$DIR_DESTINO/$extension"
    mkdir -p "$subcarpeta"
    mv -f "$archivo" "$subcarpeta/$nombre_base"
done
unset IFS

rm -rf "$CARPETA_TEMPORAL"
echo "Clasificación completada y carpeta temporal eliminada."
echo "------------------------------------------------------------------------------"

echo "Iniciando auditoría de código en archivos Python (.py)..."
echo "------------------------------------------------------------------------------"

total_py=0
con_cv2=0

DIR_PYTHON="$DIR_DESTINO/py"

if [ -d "$DIR_PYTHON" ]; then
    IFS=$'\n'
    for script_py in $(find "$DIR_PYTHON" -type f -name "*.py"); do
        total_py=$((total_py + 1))
        echo "Archivo analizado: $script_py"
        
        coincidencias=$(grep -n -i -E "cv2|import cv2|opencv" "$script_py")
        
        if [ -n "$coincidencias" ]; then
            echo "  [ALERTA] Contiene la librería buscada (cv2)."
            echo "  Líneas encontradas:"
            echo "$coincidencias" | sed 's/^/    /'
            con_cv2=$((con_cv2 + 1))
        else
            echo "  [OK] No contiene la librería buscada (cv2)."
        fi
        echo "------------------------------------------------------------------------------"
    done
    unset IFS
else
    echo "No se encontraron archivos .py para analizar."
    echo "------------------------------------------------------------------------------"
fi

echo "RESUMEN FINAL DE AUDITORÍA:"
echo "  - Total de archivos .py analizados : $total_py"
echo "  - Archivos que utilizan cv2        : $con_cv2"
echo "=============================================================================="
