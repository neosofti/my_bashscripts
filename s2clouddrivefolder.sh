#!/bin/bash

# ==============================================================================
# KONFIGURATION
# ==============================================================================
# Datei mit den zu sichernden Quellverzeichnissen (ein Pfad pro Zeile)
LIST_FILE="$HOME/bin/quellen.txt"

# Zielverzeichnis, in das synchronisiert wird
ZIEL_BASIS="/home/neo/CloudDrive/up2drive/"

# Pfad zur Log-Datei
LOG_FILE="$HOME/rsync_backup.log"

# ==============================================================================
# INITIALISIERUNG & LOG-HEADER
# ==============================================================================
echo "==========================================" >> "$LOG_FILE"
echo "Backup-Lauf gestartet am: $(date '+%Y-%m-%d %H:%M:%S')" >> "$LOG_FILE"

# Prüfen, ob die Liste der Quellverzeichnisse existiert
if [ ! -f "$LIST_FILE" ]; then
    echo "FEHLER: Die Liste '$LIST_FILE' wurde nicht gefunden!" | tee -a "$LOG_FILE"
    exit 1
fi

# ==============================================================================
# SYNCHRONISATION
# ==============================================================================
# Liest die Textdatei Zeile für Zeile (ignoriert leere Zeilen und Kommentare mit #)
grep -v '^#' "$LIST_FILE" | grep -v '^$' | while IFS= read -r QUELLE; do

    # Entfernt ein eventuelles abschließendes Slash für konsistente Ordnernamen
    QUELLE_CLEAN="${QUELLE%/}"
    ORDNER_NAME=$(basename "$QUELLE_CLEAN")
    ZIEL_PFAD="${ZIEL_BASIS}/${ORDNER_NAME}/"

    # Prüfen, ob der Quellordner existiert
    if [ ! -d "$QUELLE_CLEAN" ]; then
        echo "WARNUNG: Quellverzeichnis '$QUELLE_CLEAN' existiert nicht. Überspringe..." | tee -a "$LOG_FILE"
        continue
    fi

    echo "------------------------------------------" >> "$LOG_FILE"
    echo "Synchronisiere: $QUELLE_CLEAN -> $ZIEL_PFAD" | tee -a "$LOG_FILE"

    # Rsync-Parameter:
    # -a : Archiv-Modus (erhält Rechte, Zeiten, Eigentümer)
    # -v : Ausführliche Ausgabe
    # -c : Prüfsummen-Vergleich (Checksum)
    # --delete-before : Löscht Ziel-Dateien vor der Übertragung
    # --log-file : Rsync-eigenes internes Protokoll
    rsync -av -c --delete-before --log-file="$LOG_FILE" "$QUELLE_CLEAN/" "$ZIEL_PFAD" 2>&1 | tee -a "$LOG_FILE"

    # Statuscode der Pipe abfangen (Status von rsync, nicht von tee)
    RSYNC_STATUS=${PIPESTATUS[0]}

    if [ $RSYNC_STATUS -eq 0 ]; then
        echo "Erfolgreich synchronisiert: $ORDNER_NAME" | tee -a "$LOG_FILE"
    else
        echo "FEHLER bei $ORDNER_NAME (Statuscode: $RSYNC_STATUS)" | tee -a "$LOG_FILE"
    fi

done

echo "==========================================" >> "$LOG_FILE"
echo "Backup-Lauf beendet am: $(date '+%Y-%m-%d %H:%M:%S')" >> "$LOG_FILE"
