# Documentación de prompts – Actividad 5 (Organizer / Auditor)

Herramienta de IA utilizada: **Claude (Anthropic)**

## Prompt inicial (primera versión del script)

```
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

## Prompt de corrección / refactoring

```
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

## Resultado con `proyecto_analisis.zip`

- 98 archivos organizados en 13 carpetas por extensión.
- 60 archivos `.py` analizados.
- 28 usan `PySide6`.
- 0 usan `cv2`.
