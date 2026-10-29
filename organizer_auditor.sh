#!/usr/bin/env bash
# =============================================================================
# organizer_auditor.sh
# Descomprime un .zip, organiza su contenido por extensión y audita los
# archivos .py buscando el uso de librerías (PySide6 y cv2).
#
# Uso: ./organizer_auditor.sh <archivo.zip> <directorio_destino>
# =============================================================================

# ---------------------------------------------------------------------------
# 1. Validación de parámetros y archivos
# ---------------------------------------------------------------------------
if [ "$#" -ne 2 ]; then
    echo "Uso: ./organizer_auditor.sh <archivo.zip> <directorio_destino>"
    exit 1
fi

ZIP_FILE="$1"
DEST_DIR="$2"

if [ ! -f "$ZIP_FILE" ]; then
    echo "Error: el archivo '$ZIP_FILE' no existe."
    exit 1
fi

if ! command -v unzip > /dev/null 2>&1; then
    echo "Error: 'unzip' no está instalado."
    exit 1
fi

if ! unzip -tq "$ZIP_FILE" > /dev/null 2>&1; then
    echo "Error: '$ZIP_FILE' no es un archivo .zip válido."
    exit 1
fi

# ---------------------------------------------------------------------------
# 2. Descompresión en carpeta temporal
# ---------------------------------------------------------------------------
TMP_DIR="$(mktemp -d)"
# Borra la carpeta temporal al terminar, pase lo que pase
trap 'rm -rf "$TMP_DIR"' EXIT

echo "==> Descomprimiendo '$ZIP_FILE' en carpeta temporal..."
unzip -q "$ZIP_FILE" -d "$TMP_DIR"

mkdir -p "$DEST_DIR"
