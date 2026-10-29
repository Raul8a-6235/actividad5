# Flujo de prompts y versiones del script - Actividad 5 (Organizador / Auditor)

Este documento resume el flujo de prompts que cada integrante utilizó con IA para generar su versión del script en Bash que descomprime un `.zip`, clasifica su contenido y audita los archivos Python (`.py`).

| Integrante | Fuente | Herramienta | Enfoque |
|---|---|---|---|
| Santiago | `prompt_Santiago.md` | Claude (Anthropic) | Meta-prompt, prompt inicial y refactorización por problemas reales |
| Raul | `prompts.txt` | Claude (Anthropic) | Tres versiones del prompt, cada una más detallada que la anterior |
| Emilio | `Texto1.txt` | Gemini Argon 4 | Prompt estructurado, corrección por fallo en MSYS2/UCRT64 y código final |

Nota sobre el material fuente: los archivos de Santiago y Raul contienen únicamente los prompts (no incluyen el código resultante). El archivo de Emilio es el único que contiene el código de cada intento, pero estaba desordenado (líneas mezcladas entre secciones) y el código final estaba truncado. En la sección de Emilio se reordenó el contenido; las partes del código final que no aparecían en el archivo se reconstruyeron a partir del primer código y de la corrección descrita, y están marcadas con el comentario `# (reconstruido)`.

---

## 1. Santiago

### Flujo

1. Se pidió a Claude que generara un prompt (meta-prompt) a partir de las instrucciones de la actividad.
2. Se usó el prompt generado para obtener la primera versión del script (`organizer_auditor.sh`).
3. Se probó con `proyecto_analisis.zip`, se detectaron problemas y se envió un prompt de corrección.
4. Se obtuvo la versión refinada y se validó con el resultado final.

### Prompt 0: meta-prompt (con las instrucciones de la actividad adjuntas)

```text
Genera un prommpt para: validar parámetros, organizacion por
tipo de archivos,auditoria de archivos py y generacion de subracarpetas
(adjunte instrucciones de actividad)
```

### Prompt 1: prompt inicial (primera versión del script)

```text
Actúa como un experto en Bash scripting en Linux. Genera un script llamado
organizer_auditor.sh que cumpla con lo siguiente:

1. Validación de parámetros:
   - Debe recibir exactamente 2 argumentos: $1 = ruta del archivo .zip,
     $2 = directorio destino.
   - Si no son exactamente 2, imprimir
     "Uso: ./organizer_auditor.sh <archivo.zip> <directorio_destino>" y salir con exit 1.
   - Verificar con if [ ! -f ] que el .zip exista; si no, mostrar error y exit 1.

2. Organización por tipo de archivo:
   - Descomprimir el .zip con unzip en una carpeta temporal creada con mktemp -d
     y borrarla al final con trap.
   - Usar find para recorrer todos los archivos extraídos.
   - Por cada archivo, obtener su extensión y crear con mkdir -p una subcarpeta
     con ese nombre dentro del directorio destino (py/, png/, csv/, etc.).
   - Copiar cada archivo a su carpeta. Los archivos sin extensión van a sin_extension/.

3. Auditoría de archivos .py:
   - Recorrer solo la carpeta py/ del destino.
   - Para cada archivo .py imprimir: su ruta, si contiene "PySide6" o no, y
     usar grep -n para mostrar número de línea y la línea exacta de cada coincidencia.
   - Al final mostrar un resumen con el total de .py analizados y cuántos usan
     PySide6 y cuántos usan cv2.

Comenta cada sección del script y usa comillas en todas las variables.
```

### Prompt 2: corrección / refactoring

```text
Al probar el script con proyecto_analisis.zip encontré estos problemas:
- El zip fue creado en macOS y trae una carpeta __MACOSX con archivos "._*"
  y un .DS_Store; esos archivos basura se están copiando y contando como .py.
  Exclúyelos en el find.
- Hay archivos con espacios en el nombre (ej. "supermarket_sales - Sheet1.csv");
  haz que el ciclo sea seguro usando find -print0 y while read -d ''.
- Normaliza las extensiones a minúsculas para que .JPG y .jpg queden juntas.
- Agrega una validación para comprobar que el archivo sea un zip válido
  (unzip -t) y que el comando unzip esté instalado.
- Al terminar la organización, muestra cuántos archivos quedaron en cada carpeta.
```

### Versiones del código

El archivo `prompt_Santiago.md` no incluye el código generado. Las versiones corresponden a:

- Versión 1: resultado del Prompt 1 (clasificación por extensión, auditoría de PySide6/cv2, `trap` para limpiar).
- Versión 2: resultado del Prompt 2 (exclusión de `__MACOSX`, `._*` y `.DS_Store`; ciclo seguro con `-print0`; extensiones en minúsculas; validación con `unzip -t`; conteo por carpeta).

### Resultado con `proyecto_analisis.zip`

- 98 archivos organizados en 13 carpetas por extensión.
- 60 archivos `.py` analizados.
- 28 usan `PySide6`.
- 0 usan `cv2`.

---

## 2. Raul

### Flujo

Raul no corrigió un código con errores, sino que reescribió el prompt en tres versiones, agregando requisitos en cada una:

1. Versión 1: organización por extensión y auditoría de `cv2`/OpenCV.
2. Versión 2: cambio de la librería auditada a PySide6 y organización por tipo de archivo (imágenes, audio, video, documentos, scripts, otros), con reglas especiales para scripts y manejo de nombres duplicados.
3. Versión 3: subcarpetas por formato dentro de cada tipo, validación de `unzip`, manejo de errores de descompresión y limpieza con `trap`.

### Prompt versión 1: organización por extensión y auditoría de cv2

```text
Actúa como experto en Bash y Linux. Necesito un script llamado organizador.sh
para una actividad universitaria. Debe ser compatible con Bash en Linux/WSL,
tener comentarios claros y variables con nombres descriptivos.

ENTRADAS
- $1: ruta de un archivo .zip
- $2: ruta del directorio destino

VALIDACIONES
- Si no hay exactamente 2 argumentos, imprimir
  "Uso: ./script.sh <archivo.zip> <directorio_destino>" y salir con exit 1.
- Verificar que el .zip exista; si no, mostrar error y exit 1.
- Manejar rutas con espacios (variables entre comillas).

ORGANIZACIÓN
- Descomprimir con unzip en una carpeta temporal creada con mktemp -d.
- Con find, recorrer todos los archivos y copiarlos a subcarpetas del destino
  por extensión (py/, txt/, jpg/, etc.; "otros/" si no tiene extensión).
  Crear las carpetas con mkdir -p.

AUDITORÍA DE PYTHON
- Revisar solo los .py del destino.
- Buscar "cv2", "import cv2" y "opencv" con grep -n (ignorando mayúsculas).
- Por cada .py imprimir: ubicación, si contiene o no la palabra, y el número
  de línea con la línea exacta de cada coincidencia.

RESUMEN FINAL
- Total de .py analizados y cuántos usan cv2 (contar archivos, no líneas).

RESTRICCIONES
- Usar solo unzip, find, grep, mkdir, if/case y comandos estándar.
- Borrar la carpeta temporal al final de forma segura.
- Entregar el script completo en un solo bloque de código.
```

### Prompt versión 2: cambio a PySide6 y organización por tipo

```text
Actúa como experto en Bash y Linux. Necesito un script llamado organizador.sh
para una actividad universitaria. Debe ser compatible con Bash en Linux/WSL,
tener comentarios claros y variables con nombres descriptivos.

ENTRADAS
- $1: ruta de un archivo .zip
- $2: ruta del directorio destino

VALIDACIONES
- Si no hay exactamente 2 argumentos, imprimir
  "Uso: ./script.sh <archivo.zip> <directorio_destino>" y salir con exit 1.
- Verificar que el .zip exista; si no, mostrar error y exit 1.
- Manejar rutas con espacios (variables entre comillas).
- Crear el directorio destino con mkdir -p si no existe.

DESCOMPRESIÓN
- Descomprimir con unzip en una carpeta temporal creada con mktemp -d.

CLASIFICACIÓN POR TIPO
- Con find, recorrer todos los archivos de la carpeta temporal y, con case
  sobre la extensión (convertida a minúsculas), copiarlos a estas
  subcarpetas del destino:
  - imagenes/: jpg, jpeg, png, gif, bmp, svg
  - audio/: mp3, wav, ogg, flac
  - video/: mp4, avi, mkv, mov
  - documentos/: pdf, doc, docx, txt, md, xls, xlsx, ppt, pptx, csv
  - scripts/: py, sh, js y similares (ver reglas abajo)
  - otros/: cualquier otra extensión o archivos sin extensión
- Crear las carpetas con mkdir -p.
- Si hay dos archivos con el mismo nombre, no sobrescribir: agregar un
  sufijo numérico.

REGLAS PARA SCRIPTS
- La carpeta principal es scripts/.
- Cada archivo .py se analiza ANTES de guardarse, con grep -n -i "PySide6".
  - Si lo contiene, se copia a scripts/PySide6/.
  - Si no lo contiene, se copia a scripts/python_otros/.
- Los demás scripts (.sh, .js, etc.) se copian a scripts/otros_scripts/.

AUDITORÍA DE PYTHON (salida en terminal)
- Por cada .py analizado imprimir: nombre/ubicación, si contiene o no
  PySide6, y el número de línea con la línea exacta de cada coincidencia
  (grep -n).

RESUMEN FINAL
- Total de .py analizados y cuántos usan PySide6 (contar archivos, no líneas).

RESTRICCIONES
- Usar solo unzip, find, grep, mkdir, if/case y comandos estándar.
- Borrar la carpeta temporal al final de forma segura.
- Entregar el script completo en un solo bloque de código.
```

### Prompt versión 3: subcarpetas por formato y descompresión detallada

```text
Actúa como experto en Bash y Linux. Necesito un script llamado organizador.sh
para una actividad universitaria. Debe ser compatible con Bash en Linux/WSL,
tener comentarios claros y variables con nombres descriptivos.

ENTRADAS
- $1: ruta de un archivo .zip
- $2: ruta del directorio destino

VALIDACIONES
- Si no hay exactamente 2 argumentos, imprimir
  "Uso: ./script.sh <archivo.zip> <directorio_destino>" y salir con exit 1.
- Verificar que el .zip exista; si no, mostrar error y exit 1.
- Verificar que unzip esté instalado (command -v); si no, avisar y exit 1.
- Manejar rutas con espacios (variables entre comillas).
- Crear el directorio destino con mkdir -p si no existe.

DESCOMPRESIÓN
- Crear una carpeta temporal con mktemp -d.
- Descomprimir el .zip ahí con unzip -q "$1" -d "$carpeta_temporal".
- Si unzip falla (archivo dañado), mostrar error y exit 1.
- Usar trap para borrar la carpeta temporal al terminar, incluso si hay error.

CLASIFICACIÓN POR TIPO Y FORMATO
- Con find, recorrer todos los archivos de la carpeta temporal (incluyendo
  subcarpetas) y, con case sobre la extensión en minúsculas, copiarlos a una
  carpeta principal por tipo y, dentro, una subcarpeta por formato:
  - imagenes/: jpg/, jpeg/, png/, gif/, bmp/, svg/
  - audio/: mp3/, wav/, ogg/, flac/
  - video/: mp4/, avi/, mkv/, mov/
  - documentos/: pdf/, doc/, docx/, txt/, md/, xls/, xlsx/, ppt/, pptx/, csv/
  - scripts/: ver reglas abajo
  - otros/: cualquier otra extensión o sin extensión
- Crear las carpetas con mkdir -p solo cuando haga falta.
- Si hay dos archivos con el mismo nombre, no sobrescribir: agregar sufijo
  numérico.

REGLAS PARA SCRIPTS
- Cada archivo .py se analiza ANTES de guardarse, con grep -n -i "PySide6".
  - Si lo contiene: scripts/PySide6/
  - Si no lo contiene: scripts/python_otros/
- Los demás scripts (.sh, .js, etc.): scripts/otros_scripts/

AUDITORÍA DE PYTHON (salida en terminal)
- Por cada .py analizado imprimir: nombre/ubicación, si contiene o no
  PySide6, y el número de línea con la línea exacta de cada coincidencia
  (grep -n).

RESUMEN FINAL
- Total de .py analizados y cuántos usan PySide6 (contar archivos, no líneas).

RESTRICCIONES
- Usar solo unzip, find, grep, mkdir, if/case, trap y comandos estándar.
- Entregar el script completo en un solo bloque de código.
```

### Versiones del código

El archivo `prompts.txt` no incluye el código generado. Cada versión del script (`organizador.sh`) corresponde al prompt de la versión respectiva:

- Versión 1: carpetas por extensión; auditoría de `cv2`.
- Versión 2: carpetas por tipo; scripts separados según usen o no PySide6; sufijo numérico para duplicados.
- Versión 3: carpetas por tipo y formato; verificación de `unzip`; salida con error si el zip está dañado; limpieza con `trap`.

---

## 3. Emilio

### Flujo

1. Intento 1, prompt inicial: prompt estructurado y detallado con la lógica, comandos y estructura de comentarios exigidos.
2. Primer código generado: falló en el entorno MSYS2/UCRT64 / Git Bash en Windows.
3. Prompt de corrección: se reportó que el script creaba las carpetas pero no generaba la lista de auditoría requerida.
4. Código funcional definitivo, documentado: se reemplazó el ciclo `while ... done < <(find ...)` por un ciclo `for` con `IFS=$'\n'`.

Observación del autor: el primer código se detenía silenciosamente en el ciclo `while ... done < <(find ...)` por el manejo de sustitución de procesos en MSYS2/UCRT64 en Windows. Al reemplazarlo por un ciclo `for` apoyado en `IFS=$'\n'`, el script completó la clasificación, eliminó el directorio temporal y ejecutó la auditoría de cv2 sin errores. Estado: FUNCIONAL.

### Prompt inicial (Intento 1)

```text
Actúa como un experto en sistemas Unix y programación en Bash Shell. Necesito que desarrolles un script en Bash llamado script.sh que procese un archivo comprimido .zip, clasifique su contenido por extensión y realice una auditoría de código en los archivos de Python (.py).
Es indispensable que el código esté exhaustivamente documentado con comentarios (#) en todas sus partes críticas explicando qué hace cada bloque y cada comando utilizado.

El script debe implementar estrictamente la siguiente lógica y comandos de Unix/Linux:
1. Validación de Parámetros y Archivos:
   - Utiliza una estructura condicional if evaluando la variable $# (if [ "$#" -ne 2 ]; then) para verificar que el script reciba exactamente 2 argumentos desde la terminal ($1 para la ruta del archivo .zip y $2 para la ruta del directorio destino).
   - Si no se reciben exactamente 2 argumentos, imprime con echo el mensaje: Uso: ./script.sh <archivo.zip> <directorio_destino> y termina la ejecución con exit 1.
   - Utiliza otro condicional if con el operador -f (if [ ! -f "$1" ]; then) para comprobar que el archivo .zip ingresado realmente exista. Si no existe, muestra un mensaje de error claro y sal con exit 1.

2. Descompresión y Organización por Tipo de Archivo:
   - Crea una carpeta temporal utilizando mktemp -d (o mkdir -p para un directorio temporal) y descomprime ahí el contenido de $1 usando el comando unzip -q "$1" -d <carpeta_temporal>.
   - Crea el directorio destino $2 si no existe usando mkdir -p "$2".
   - Utiliza el comando find (find <carpeta_temporal> -type f) dentro de un ciclo para recorrer todos los archivos extraídos, ignorando carpetas vacías.
   - Para cada archivo, extrae su nombre con basename y obtén su extensión mediante expansión de parámetros de Bash (${archivo##*.}). Si un archivo no tiene extensión, asígnalo a una subcarpeta llamada otros/.
   - Crea dinámicamente las subcarpetas dentro de $2 según cada extensión encontrada (ejemplo: $2/py/, $2/txt/, $2/jpg/, $2/otros/) usando mkdir -p.
   - Mueve o copia cada archivo desde la carpeta temporal hacia su subcarpeta correspondiente en $2 utilizando los comandos mv o cp.
   - Al finalizar el traslado de archivos, elimina la carpeta temporal utilizando rm -rf.

3. Auditoría de Código en Archivos .py:
   - Utiliza find "$2/py" -type f -name "*.py" para filtrar y analizar exclusivamente los scripts de Python.
   - Inicializa dos variables contadoras en 0: una para el total de archivos .py analizados y otra para la cantidad de archivos que contienen las librerías buscadas.
   - Por cada archivo .py, utiliza el comando grep -n -i -E "cv2|import cv2|opencv" para buscar coincidencias exactas o de términos clave de visión por computadora mostrando el número de línea.
   - Salida en terminal por archivo: Imprime claramente el nombre/ubicación del archivo, indica mediante un condicional if si contiene o no la librería buscada (cv2), y si la contiene, imprime el número de línea y la línea exacta arrojada por grep -n.
   - Resumen final: Al terminar el recorrido, imprime en la terminal el conteo total de archivos .py analizados y cuántos de ellos utilizan la librería cv2.
```

### Primer código generado (con fallo en entorno UCRT64 / Git Bash)

```bash
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

if [ $? -ne 0 ]; then
    echo "Error: Falló la extracción de '$ARCHIVO_ZIP'. Verifique que sea un archivo .zip íntegro."
    rm -rf "$CARPETA_TEMPORAL"
    exit 1
fi

mkdir -p "$DIR_DESTINO"
echo "Clasificando archivos extraídos en '$DIR_DESTINO'..."

while IFS= read -r -d '' archivo; do
    nombre_base=$(basename "$archivo")
    if [[ "$nombre_base" == *.* && "$nombre_base" != .* ]]; then
        extension="${nombre_base##*.}"
        extension=$(echo "$extension" | tr '[:upper:]' '[:lower:]')
    else
        extension="otros"
    fi
    subcarpeta="$DIR_DESTINO/$extension"
    mkdir -p "$subcarpeta"
    mv "$archivo" "$subcarpeta/$nombre_base"
done < <(find "$CARPETA_TEMPORAL" -type f -print0)

rm -rf "$CARPETA_TEMPORAL"
echo "Clasificación completada y carpeta temporal eliminada."
echo "------------------------------------------------------------------------------"
echo "Iniciando auditoría de código en archivos Python (.py)..."
echo "------------------------------------------------------------------------------"

total_py=0
con_cv2=0
DIR_PYTHON="$DIR_DESTINO/py"

if [ -d "$DIR_PYTHON" ]; then
    while IFS= read -r -d '' script_py; do
        ((total_py++))
        echo "Archivo analizado: $script_py"
        coincidencias=$(grep -n -i -E "cv2|import cv2|opencv" "$script_py")
        if [ -n "$coincidencias" ]; then
            echo "  [ALERTA] Se detectó el uso de la librería OpenCV (cv2)."
            echo "  Líneas coincidentes (Número_Línea:Código):"
            echo "$coincidencias" | sed 's/^/    /'
            ((con_cv2++))
        else
            echo "  [OK] No contiene referencias a la librería cv2 / OpenCV."
        fi
        echo "------------------------------------------------------------------------------"
    done < <(find "$DIR_PYTHON" -type f -name "*.py" -print0)
else
    echo "No se encontraron archivos .py dentro del archivo comprimido para auditar."
    echo "------------------------------------------------------------------------------"
fi

echo "RESUMEN DE AUDITORÍA PYTHON:"
echo "  - Total de archivos .py analizados : $total_py"
echo "  - Archivos que utilizan cv2/OpenCV : $con_cv2"
echo "=============================================================================="
```

### Prompt de corrección (Iteración 2 del Intento 1)

```text
El código está arrojando "Directorio temporal creado en: /tmp/tmp.WzGjpazzfu" y "Clasificando archivos extraídos en './resultado_auditoria'..." y crea las carpetas dentro de la carpeta resultado_auditoria mas no genera la lista requerida, apóyame ajustando el código para arreglar esto.
```

### Código funcional definitivo (documentado)

Cambios principales respecto al primer código: se sustituyen los dos ciclos `while ... done < <(find ...)` por ciclos `for` con `IFS=$'\n'`, se usan contadores con `$((...))` y se agregan comentarios en las partes críticas.

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

# Creación del directorio destino si no existe
mkdir -p "$DIR_DESTINO"

echo "Clasificando archivos extraídos en '$DIR_DESTINO'..."

# Recorrido de archivos usando find -type f y clasificación por extensión
IFS=$'\n'
for archivo in $(find "$CARPETA_TEMPORAL" -type f); do
    nombre_base=$(basename "$archivo")

    # Obtención de extensión por expansión de parámetros o asignación a 'otros'
    # (reconstruido)
    if [[ "$nombre_base" == *.* && "$nombre_base" != .* ]]; then
        extension="${nombre_base##*.}"
        extension=$(echo "$extension" | tr '[:upper:]' '[:lower:]')
    else
        extension="otros"
    fi

    # Creación dinámica de la subcarpeta y traslado del archivo (reconstruido)
    subcarpeta="$DIR_DESTINO/$extension"
    mkdir -p "$subcarpeta"
    mv "$archivo" "$subcarpeta/$nombre_base"
done

# Eliminación de la carpeta temporal (reconstruido)
rm -rf "$CARPETA_TEMPORAL"
echo "Clasificación completada y carpeta temporal eliminada."
echo "------------------------------------------------------------------------------"
echo "Iniciando auditoría de código en archivos Python (.py)..."
echo "------------------------------------------------------------------------------"

# Inicialización de contadores (reconstruido)
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

## Comparación del flujo de los tres integrantes

| Aspecto | Santiago | Raul | Emilio |
|---|---|---|---|
| Estrategia | Meta-prompt y luego refactorización con problemas reales | Tres reescrituras progresivas del prompt | Un prompt detallado y una corrección por fallo de entorno |
| Clasificación | Por extensión | Por tipo y luego por tipo y formato | Por extensión (minúsculas, `otros/` sin extensión) |
| Auditoría | PySide6 y cv2 | cv2, luego PySide6 | cv2 |
| Operación sobre archivos | `cp` | `cp` con sufijo numérico en duplicados | `mv` |
| Limpieza del temporal | `trap` | `trap` (versión 3) | `rm -rf` al final |
| Recorrido de archivos | `find -print0` + `while read -d ''` | `find` | `find` con `for` e `IFS=$'\n'` (por MSYS2/UCRT64) |
| Problema principal resuelto | Archivos basura de macOS y nombres con espacios | Requisitos cada vez más específicos | Ciclo `while` con sustitución de procesos fallando en Windows |
