#!/bin/bash
# organizador.sh
# Descomprime un .zip, organiza su contenido por tipo y formato,
# y audita los archivos .py buscando el uso de PySide6.

# --- Validación de parámetros ---
if [ "$#" -ne 2 ]; then
    echo "Uso: ./script.sh <archivo.zip> <directorio_destino>"
    exit 1
fi

archivo_zip="$1"
directorio_destino="$2"

# --- Validación del archivo .zip ---
if [ ! -f "$archivo_zip" ]; then
    echo "Error: el archivo '$archivo_zip' no existe."
    exit 1
fi

# --- Verificar que unzip esté instalado ---
if ! command -v unzip > /dev/null 2>&1; then
    echo "Error: unzip no está instalado."
    exit 1
fi

# --- Preparar destino y carpeta temporal ---
mkdir -p "$directorio_destino"
carpeta_temporal=$(mktemp -d)
trap 'rm -rf "$carpeta_temporal"' EXIT

# --- Descompresión ---
if ! unzip -q "$archivo_zip" -d "$carpeta_temporal"; then
    echo "Error: no se pudo descomprimir '$archivo_zip'."
    exit 1
fi
echo "Archivo descomprimido correctamente."

        extension="${extension,,}"   # a minúsculas
    else
        extension=""
    fi

    case "$extension" in
        jpg|jpeg|png|gif|bmp|svg) carpeta="imagenes/$extension" ;;
        mp3|wav|ogg|flac)         carpeta="audio/$extension" ;;
        mp4|avi|mkv|mov)          carpeta="video/$extension" ;;
        pdf|doc|docx|txt|md|xls|xlsx|ppt|pptx|csv) carpeta="documentos/$extension" ;;
        py)
            # Se analiza ANTES de guardarlo
            else
                carpeta="scripts/python_otros"
            ;;
        *)                        carpeta="otros" ;;
    esac

done < <(find "$carpeta_temporal" -type f -print0)

echo "Archivos organizados en '$directorio_destino'."

# --- Auditoría de archivos .py ---
total_py=0
usan_pyside=0
echo
echo "=== Auditoría de archivos .py ==="

while IFS= read -r -d '' archivo; do
    total_py=$((total_py + 1))
    echo "Archivo: ${archivo#"$carpeta_temporal"/}"
    if grep -qi "PySide6" "$archivo"; then
        usan_pyside=$((usan_pyside + 1))
        echo "  Contiene PySide6: SÍ"
        grep -n -i "PySide6" "$archivo" | sed 's/^/    línea /'
    else
        echo "  Contiene PySide6: NO"
    fi
done < <(find "$carpeta_temporal" -type f -iname "*.py" -print0)

echo
echo "=== Resumen ==="
echo "Archivos .py analizados: $total_py"
echo "Archivos que usan PySide6: $usan_pyside"    copiar_archivo "$archivo" "$carpeta"
        sh|js|bat|rb|pl)          carpeta="scripts/otros_scripts" ;;
            fi
            if grep -qi "PySide6" "$archivo"; then
                carpeta="scripts/PySide6"
        extension="${nombre##*.}"
# --- Función para copiar sin sobrescribir ---
copiar_archivo() {
    if [[ "$nombre" == *.* ]]; then
    local origen="$1"
    local carpeta="$2"
    local nombre base ext destino contador
    nombre=$(basename "$origen")
    mkdir -p "$directorio_destino/$carpeta"
    destino="$directorio_destino/$carpeta/$nombre"
        else
    nombre=$(basename "$archivo")
        destino="$directorio_destino/$carpeta/${base}_$contador$ext"
        contador=$((contador + 1))
while IFS= read -r -d '' archivo; do

# --- Clasificación por tipo y formato ---
    done
    cp "$origen" "$destino"
}
            base="$nombre"
            ext=""
        fi
    contador=1
    # Si ya existe un archivo con ese nombre, agrega un sufijo numérico
            ext=".${nombre##*.}"

