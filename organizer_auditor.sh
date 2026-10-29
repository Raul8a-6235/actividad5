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


# ---------------------------------------------------------------------------
# 3. Organización por extensión
#    - Se ignoran los archivos basura de macOS (__MACOSX, .DS_Store, ._*)
#    - Archivos sin extensión van a 'sin_extension/'
# ---------------------------------------------------------------------------
echo "==> Organizando archivos por extensión en '$DEST_DIR'..."
total_files=0

while IFS= read -r -d '' file; do
    filename="$(basename "$file")"

    if [[ "$filename" == *.* ]]; then
        ext="${filename##*.}"
        ext="${ext,,}"                 # extensión en minúsculas (JPG -> jpg)
    else
        ext="sin_extension"
    fi

    mkdir -p "$DEST_DIR/$ext"
    cp "$file" "$DEST_DIR/$ext/"
    total_files=$((total_files + 1))
done < <(find "$TMP_DIR" -type f \
            ! -path "*/__MACOSX/*" \
            ! -name ".DS_Store" \
            ! -name "._*" \
            -print0)

echo "    $total_files archivos copiados."
echo "    Carpetas creadas:"
for d in "$DEST_DIR"/*/; do
    n=$(find "$d" -type f | wc -l)
    printf "      %-15s %3d archivo(s)\n" "$(basename "$d")/" "$n"
done

# ---------------------------------------------------------------------------
# 4. Auditoría de código en archivos .py
# ---------------------------------------------------------------------------
PY_DIR="$DEST_DIR/py"
KEYWORD="PySide6"
KEYWORD_CV="cv2"

echo
echo "=================================================================="
echo " AUDITORÍA DE ARCHIVOS PYTHON (búsqueda de '$KEYWORD' y '$KEYWORD_CV')"
echo "=================================================================="

if [ ! -d "$PY_DIR" ]; then
    echo "No se encontraron archivos .py en el zip."
    exit 0
fi

py_total=0
py_pyside=0
py_cv2=0

while IFS= read -r -d '' pyfile; do
    py_total=$((py_total + 1))
    echo
    echo "Archivo: $pyfile"

    if grep -q "$KEYWORD" "$pyfile"; then
        py_pyside=$((py_pyside + 1))
        echo "  [SÍ] Contiene '$KEYWORD':"
        grep -n "$KEYWORD" "$pyfile" | sed 's/^/     línea /'
    else
        echo "  [NO] No contiene '$KEYWORD'."
    fi

    if grep -qw "$KEYWORD_CV" "$pyfile"; then
        py_cv2=$((py_cv2 + 1))
        echo "  [SÍ] Contiene '$KEYWORD_CV':"
        grep -nw "$KEYWORD_CV" "$pyfile" | sed 's/^/     línea /'
    fi
done < <(find "$PY_DIR" -type f -name "*.py" -print0 | sort -z)

# ---------------------------------------------------------------------------
# 5. Resumen final
# ---------------------------------------------------------------------------
echo
echo "=================================================================="
echo " RESUMEN"
echo "=================================================================="
echo " Archivos .py analizados:       $py_total"
echo " Archivos que usan $KEYWORD:     $py_pyside"
echo " Archivos que usan $KEYWORD_CV:         $py_cv2"
echo "=================================================================="

exit 0
