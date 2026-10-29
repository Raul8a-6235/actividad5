# Actividad 5: Automatización en Bash - Clasificador y Auditor de Código

Este repositorio contiene el desarrollo y evolución de un script en **Bash** diseñado para procesar archivos comprimidos `.zip`, clasificar su contenido dinámicamente en subdirectorios según su extensión y realizar una auditoría automatizada en los scripts de Python (`.py`) para detectar librerías específicas (como `cv2` / OpenCV o `PySide6`).

---

##  Estructura del Repositorio

El proyecto documenta tres iteraciones (intentos) con diferentes niveles de complejidad en los prompts, culminando en la versión funcional definitiva empleada para la solución.

---

##  Intento 1: Prompt Estructurado y Versión Funcional (Utilizada)

Esta versión implementa validación de parámetros, manejo de rutas relativas/absolutas, extracción segura, organización por extensión mediante expansión de parámetros y un análisis con `grep` adaptado para entornos de terminal Unix/Linux (compatible con Git Bash / UCRT64).

### 1. Prompt Inicial (Intento 1)
```text
Actúa como un experto en sistemas Unix y programación en Bash Shell. Necesito que desarrolles un script en Bash llamado script.sh que procese un archivo comprimido .zip, clasifique su contenido por extensión y realice una auditoría de código en los archivos de Python (.py).
Es indispensable que el código esté exhaustivamente documentado con comentarios (#) en todas sus partes críticas explicando qué hace cada bloque y cada comando utilizado.

El script debe implementar estrictamente la siguiente lógica y comandos de Unix/Linux:
1. Validación de Parámetros y Archivos:
   - Utiliza una estructura condicional if evaluando la variable $# (if [ "$#" -ne 2 ]; then) para verificar que el script reciba exactamente 2 argumentos desde la terminal ($1 para la ruta del archivo .zip y $2 para la ruta del directorio destino).
   - Si no se reciben exactamente 2 argumentos, imprime con echo el mensaje: Uso: ./script.sh <archivo.zip> <directorio_destino> y termina la ejecución con exit 1.
   - Utiliza otro condicional if con el operador -f (if [ ! -f "$1" ]; then) para comprobar que el archivo .zip ingresado realmente exista. Si no existe, muestra un mensaje de error claro y sal con exit 1.

2. Descompresión y Organización por Tipo de Archivo:
   - Crea una carpeta temporal utilizando mktemp -d y descomprime ahí el contenido de $1 usando el comando unzip -q "$1" -d <carpeta_temporal>.
   - Crea el directorio destino $2 si no existe usando mkdir -p "$2".
   - Utiliza el comando find dentro de un ciclo para recorrer todos los archivos extraídos, ignorando carpetas vacías.
   - Para cada archivo, extrae su nombre con basename y obtén su extensión mediante expansión de parámetros de Bash (${archivo##*.}). Si un archivo no tiene extensión, asígnalo a una subcarpeta llamada otros/.
   - Crea dinámicamente las subcarpetas dentro de $2 según cada extensión encontrada usando mkdir -p.
   - Mueve cada archivo desde la carpeta temporal hacia su subcarpeta correspondiente en $2 utilizando el comando mv.
   - Al finalizar el traslado de archivos, elimina la carpeta temporal utilizando rm -rf.

3. Auditoría de Código en Archivos .py:
   - Utiliza find "$2/py" -type f -name "*.py" para filtrar y analizar exclusivamente los scripts de Python.
   - Inicializa dos variables contadoras en 0: una para el total de archivos .py analizados y otra para la cantidad de archivos que contienen las librerías buscadas.
   - Por cada archivo .py, utiliza el comando grep -n -i -E "cv2|import cv2|opencv" para buscar coincidencias exactas o de términos clave de visión por computadora mostrando el número de línea.
   - Salida en terminal por archivo: Imprime claramente el nombre/ubicación del archivo, indica mediante un condicional if si contiene o no la librería buscada (cv2), y si la contiene, imprime el número de línea y la línea exacta arrojada por grep -n.
   - Resumen final: Al terminar el recorrido, imprime en la terminal el conteo total de archivos .py analizados y cuántos de ellos utilizan la librería cv2.
```

### 2. Código Definitivo (Texto 1 / Funcional)
```bash
#!/bin/bash

# Validación de que el script reciba exactamente 2 parámetros ($#)
if [ "$#" -ne 2 ]; then
    echo "Uso: ./script.sh <archivo.zip> <directorio_destino>"
    exit 1
fi

ARCHIVO_ZIP="$1"
DIR_DESTINO="$2"

# Comprobación de que el archivo .zip ingresado exista (-f)
if [ ! -f "$ARCHIVO_ZIP" ]; then
    echo "Error: El archivo '$ARCHIVO_ZIP' no existe o no es un archivo válido."
    exit 1
fi

# Creación de carpeta temporal con mktemp -d y descompresión con unzip -q
CARPETA_TEMPORAL=$(mktemp -d)
echo "Directorio temporal creado en: $CARPETA_TEMPORAL"

unzip -q "$ARCHIVO_ZIP" -d "$CARPETA_TEMPORAL"
mkdir -p "$DIR_DESTINO"

echo "Clasificando archivos extraídos en '$DIR_DESTINO'..."

# Recorrido de archivos usando find -type f y clasificación por extensión
IFS=$'\n'
for archivo in $(find "$CARPETA_TEMPORAL" -type f); do
    nombre_base=$(basename "$archivo")
    
    # Obtención de extensión por expansión de parámetros o asignación a 'otros'
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

# Eliminación de carpeta temporal con rm -rf
rm -rf "$CARPETA_TEMPORAL"
echo "Clasificación completada y carpeta temporal eliminada."
echo "------------------------------------------------------------------------------"

# Auditoría de código en los archivos Python (.py)
echo "Iniciando auditoría de código en archivos Python (.py)..."
echo "------------------------------------------------------------------------------"

total_py=0
con_cv2=0

DIR_PYTHON="$DIR_DESTINO/py"

if [ -d "$DIR_PYTHON" ]; then
    IFS=$'\n'
    # Filtrado de archivos .py con find y búsqueda de cv2/opencv con grep -n -i -E
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

# Resumen final de conteo
echo "RESUMEN FINAL DE AUDITORÍA:"
echo "  - Total de archivos .py analizados : $total_py"
echo "  - Archivos que utilizan cv2        : $con_cv2"
echo "=============================================================================="
```

---

##  Intento 2: Refactoring y Organización por Categorías Principales

Este intento evoluciona el requerimiento para clasificar los archivos en macro-categorías predefinidas (`imagenes/`, `audio/`, `video/`, `documentos/`, `scripts/`, `otros/`) y auditar específicamente la librería `PySide6`.

```text
Actúa como experto en Bash y Linux. Necesito un script llamado organizador.sh para una actividad universitaria. Debe ser compatible con Bash en Linux/WSL, tener comentarios claros y variables con nombres descriptivos.

ENTRADAS:
- $1: ruta de un archivo .zip
- $2: ruta del directorio destino

VALIDACIONES:
- Si no hay exactamente 2 argumentos, imprimir "Uso: ./script.sh <archivo.zip> <directorio_destino>" y salir con exit 1.
- Verificar que el .zip exista; si no, mostrar error y exit 1.
- Manejar rutas con espacios y crear el directorio destino con mkdir -p si no existe.

DESCOMPRESIÓN Y CLASIFICACIÓN:
- Descomprimir con unzip en una carpeta temporal creada con mktemp -d.
- Con find, recorrer todos los archivos de la carpeta temporal y, con case sobre la extensión (en minúsculas), copiarlos a carpetas agrupadas (imagenes/, audio/, video/, documentos/, scripts/, otros/).
- Regla especial scripts: los archivos .py se analizan antes de guardarse con grep -n -i "PySide6" para ubicarlos en scripts/PySide6/ o scripts/python_otros/.

AUDITORÍA Y RESUMEN:
- Por cada .py analizado imprimir ubicación, si contiene PySide6 y el número de línea.
- Al final, mostrar total de archivos .py analizados y cuántos usan PySide6.
```

---

##  Intento 3: Robustez Avanzada, Manejo de Errores y Trap

Este intento añade comprobación de dependencias del sistema (`command -v unzip`), manejo de errores de integridad con código de salida y limpieza segura mediante la directiva `trap`.

```text
Actúa como experto en Bash y Linux. Necesito un script llamado organizador.sh para una actividad universitaria. Debe ser compatible con Bash en Linux/WSL, comentarios claros y variables con nombres descriptivos.

ENTRADAS Y VALIDACIONES:
- Recibir exactamente 2 argumentos ($1 y $2). Si no, salir con exit 1.
- Verificar existencia del .zip y validar que unzip esté instalado usando command -v.
- Crear directorio destino con mkdir -p si no existe.

DESCOMPRESIÓN Y LIMPIEZA SEGURA:
- Crear carpeta temporal con mktemp -d y descomprimir con unzip -q.
- Validar si unzip falla (archivo dañado) para mostrar error y salir con exit 1.
- Utilizar trap para asegurar la eliminación de la carpeta temporal al finalizar o ante cualquier interrupción.

CLASIFICACIÓN Y AUDITORÍA:
- Recorrer con find y case para subcarpetas detalladas por formato (jpg/, png/, pdf/, txt/, etc.).
- Filtrar scripts .py para auditoría con grep -n -i de PySide6, separando en subcarpetas especializadas.
- Imprimir reporte detallado por archivo y resumen estadístico final al terminar.
```

---

##  Instrucciones de Uso (Para el Script Principal)

1. **Dar permisos de ejecución:**
   ```bash
   chmod +x script.sh
   ```
2. **Ejecutar el script pasando el `.zip` y el directorio de salida:**
   ```bash
   ./script.sh proyecto_analisis.zip ./resultado_auditoria
   ```
