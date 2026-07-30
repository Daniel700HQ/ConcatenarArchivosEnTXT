#!/bin/bash

#=======================================================================
# CONFIGURACIÓN GENERAL
#=======================================================================

# 1. Nombre del archivo de salida
ARCHIVO_SALIDA="proyecto_completo.txt"

# 2. Exclusión de archivos (para el contenido de texto)
PATRONES_EXCLUIR_ARCHIVOS=".env *.png *.jpg *.jpeg *.pyc *.exe *.wasm *.svg *.apk *.aab *.webp *.bin *.jar *.lock *.ico *.bmp *.ttf *.mp3 *.pdf *.mmdb *.icns *.rtf *.pcap *.pcapng *.bkp *.bk *.pdb Cargo.lock *.min.js proyecto_completo.txt *.json .all-contributorsrc .dockerignore .editorconfig .gitattributes .gitignore .imgbotconfig LICENSE-APACHE LICENSE-MIT *.sh *.db *.db-shm *.db-wal *.vsidx *.sqlite COPYING gradlew gradlew.bat .gitmodules crash-*"

# 3. Exclusión de directorios (común para contenido y mapa)
CARPETAS_EXCLUIR="node_modules .git __pycache__ .idea .vscode .vs Resources bin obj .cxx cxx intermediates stash-dir .github resources build target debug out .design .well-known submodules generated fastlane docs tools ICONS_LICENSE .gradle"

# 4. ¿Deseas excluir este mismo script y el archivo de salida del resultado final?
# (Se aplicará tanto al contenido como al mapa de estructura)
EXCLUIR_ESTE_SCRIPT=true

#=======================================================================
# CONFIGURACIÓN ESPECÍFICA DEL MAPA DE ESTRUCTURA
#=======================================================================

# 5. Directorios que NO quieres que aparezcan en el mapa final (aunque existan)
# Por defecto según tu solicitud: bin y obj
ESTRUCTURA_EXCLUIR_EXTRAS="bin obj target debug out .design .well-known .github resources submodules generated fastlane docs tools ICONS_LICENSE"

#=======================================================================
# PREPARACIÓN Y VARIABLES GLOBALES
#=======================================================================

NOMBRE_SCRIPT=$(basename "$0")
rm -f "$ARCHIVO_SALIDA"

#=======================================================================
# FASE 1: PROCESAMIENTO DE CONTENIDO
#=======================================================================

echo "Fase 1: Extrayendo contenido de archivos..."

# Construcción de comando find para contenido
FIND_CONTENIDO=(find . -type f)

# Excluir el archivo de salida y el script de la lectura
FIND_CONTENIDO+=(! -name "$ARCHIVO_SALIDA")
if [ "$EXCLUIR_ESTE_SCRIPT" = true ]; then
    FIND_CONTENIDO+=(! -name "$NOMBRE_SCRIPT")
fi

# Excluir patrones de archivos binarios/config
for patron in $PATRONES_EXCLUIR_ARCHIVOS; do
    FIND_CONTENIDO+=(! -name "$patron")
done

# Excluir carpetas prohibidas
for carpeta in $CARPETAS_EXCLUIR; do
    FIND_CONTENIDO+=(! -path "*/$carpeta/*")
done

# Ejecución de la Fase 1
"${FIND_CONTENIDO[@]}" -print0 | while IFS= read -r -d $'\0' archivo; do
    echo "Agregando contenido: $archivo"
    echo "========== INICIO DEL ARCHIVO: $archivo ==========" >> "$ARCHIVO_SALIDA"
    echo "" >> "$ARCHIVO_SALIDA"
    cat "$archivo" 2>/dev/null >> "$ARCHIVO_SALIDA"
    echo "" >> "$ARCHIVO_SALIDA"
    echo "========== FIN DEL ARCHIVO: $archivo ==========" >> "$ARCHIVO_SALIDA"
    echo -e "\n\n" >> "$ARCHIVO_SALIDA"
done

#=======================================================================
# FASE 2: MAPA DE ESTRUCTURA COMPLETA
#=======================================================================

echo "Fase 2: Generando mapa de estructura completa..."

{
    echo "======================================================================="
    echo "RESUMEN DE LA ESTRUCTURA COMPLETA DEL PROYECTO"
    echo "======================================================================="
    echo "Nota: Este listado incluye la ruta de todos los archivos y directorios,"
    echo "omitiendo únicamente las excepciones de seguridad y configuración."
    echo ""
} >> "$ARCHIVO_SALIDA"

# Construcción de comando find para el mapa (incluye directorios y archivos)
FIND_MAPA=(find .)

# 1. Aplicar exclusión de este script y del archivo de salida
FIND_MAPA+=(! -name "$ARCHIVO_SALIDA")
if [ "$EXCLUIR_ESTE_SCRIPT" = true ]; then
    FIND_MAPA+=(! -name "$NOMBRE_SCRIPT")
fi

# 2. Aplicar exclusión de carpetas generales (las de la fase 1)
for carpeta in $CARPETAS_EXCLUIR; do
    FIND_MAPA+=(! -path "*/$carpeta/*")
    FIND_MAPA+=(! -name "$carpeta")
done

# 3. Aplicar exclusión de carpetas EXTRAS solo para el mapa (bin, obj)
for extra in $ESTRUCTURA_EXCLUIR_EXTRAS; do
    FIND_MAPA+=(! -path "*/$extra/*")
    FIND_MAPA+=(! -name "$extra")
done

# Ejecutar, ordenar alfabéticamente y añadir al final
"${FIND_MAPA[@]}" | sort >> "$ARCHIVO_SALIDA"

echo ""
echo "¡Proceso finalizado!"
echo "Archivo generado: $ARCHIVO_SALIDA"
