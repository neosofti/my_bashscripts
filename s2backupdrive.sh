#!/bin/bash

# ==============================================================================
# Pfadkonfiguration
# ==============================================================================
SOURCE="/home/neo/"
TARGET="/run/media/neo/BackupDrive/home@mybackup/"

# ==============================================================================
# Prüfungen
# ==============================================================================
if [ ! -d "$TARGET" ]; then
    echo "Fehler: Zielpfad $TARGET ist nicht erreichbar." >&2
    exit 1
fi

# ==============================================================================
# Dynamische Parameterbestimmung
# ==============================================================================
DAY_OF_WEEK=$(date +%u)

# Standard-Flags inklusive Ausschluss für CloudDrive
RSYNC_FLAGS=("-rlptH" "-v" "--progress" "--delete" "--partial" "-s" "--exclude=CloudDrive/")

if [ "$DAY_OF_WEEK" -eq 7 ]; then
    echo " [Sonntags-Lauf] Prüfsummen-Vergleich (--checksum) wird aktiviert..."
    RSYNC_FLAGS+=("-c")
else
    echo " [Standard-Lauf] Abgleich über Dateigröße und Modifikationszeit..."
fi

# ==============================================================================
# Ausführung
# ==============================================================================
rsync "${RSYNC_FLAGS[@]}" "$SOURCE" "$TARGET"
