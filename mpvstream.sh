#!/bin/bash

# Sicherstellen, dass Eingaben immer vom Terminal gelesen werden
exec </dev/tty

# Hauptschleife für das erneute Auswählen/Abspielen
while true; do
    clear
    read -p "URL eingeben (oder 'q' zum Beenden): " URL

    if [ "$URL" = "q" ] || [ "$URL" = "Q" ]; then
        echo "Beende..."
        exit 0
    fi

    if [ -z "$URL" ]; then
        echo "Fehler: Keine URL angegeben." >&2
        sleep 1
        continue
    fi

    echo "Prüfe URL..."

    # Metadaten mit yt-dlp abfragen
    INFO_JSON=$(yt-dlp --dump-single-json --flat-playlist --no-warnings "$URL" 2>/dev/null)

    if [ $? -ne 0 ] || [ -z "$INFO_JSON" ]; then
        echo "Fehler: URL konnte nicht verarbeitet werden oder yt-dlp ist nicht installiert." >&2
        sleep 2
        continue
    fi

    # Abfragen, ob es sich um eine Playlist handelt
    IS_PLAYLIST=$(echo "$INFO_JSON" | jq -r '._type // empty')

    if [ "$IS_PLAYLIST" = "playlist" ]; then
        TITLE=$(echo "$INFO_JSON" | jq -r '.title // "Unbenannte Playlist"')
        COUNT=$(echo "$INFO_JSON" | jq -r '(.entries | length) // 0')

        echo ""
        echo "=================================================="
        echo "Playlist erkannt: $TITLE"
        echo "Anzahl der Einträge: $COUNT"
        echo "=================================================="
        echo "1) Gesamte Playlist abspielen"
        echo "2) Ein bestimmtes Video aus der Liste wählen"
        echo "3) Neue URL eingeben"
        read -p "Auswahl (1-3, Standard: 1): " PL_CHOICE

        if [ "$PL_CHOICE" = "3" ]; then
            continue
        elif [ "$PL_CHOICE" = "2" ]; then
            echo ""
            echo "Lade alle Titel der Playlist..."
            
            # Korrigierte Schleife, die fortlaufend von 1 bis COUNT durchnummeriert
            i=1
            yt-dlp --flat-playlist --print "%(title)s" "$URL" 2>/dev/null | while read -r track_title; do
                printf "%3d) %s\n" "$i" "$track_title"
                i=$((i + 1))
            done

            echo "--------------------------------------------------"
            
            read -p "Gebe die Nummer des Videos ein (1-$COUNT): " PLAYLIST_INDEX
            if [[ "$PLAYLIST_INDEX" =~ ^[0-9]+$ ]] && [ "$PLAYLIST_INDEX" -ge 1 ] && [ "$PLAYLIST_INDEX" -le "$COUNT" ]; then
                echo "Hole URL für Eintrag $PLAYLIST_INDEX..."
                URL=$(yt-dlp --flat-playlist --print url --playlist-items "$PLAYLIST_INDEX" "$URL" 2>/dev/null)
                if [ -z "$URL" ]; then
                    echo "Fehler: Konnte die Video-URL nicht extrahieren." >&2
                    sleep 2
                    continue
                fi
            else
                echo "Ungültige Auswahl. Kehre zum Menü zurück..."
                sleep 2
                continue
            fi
        fi
    else
        echo "Einzelnes Video erkannt."
    fi

    echo ""
    echo "Wähle den Wiedergabemodus:"
    echo "1) Nur Audio (kein Video)"
    echo "2) Video + Audio"
    read -p "Auswahl (1 oder 2, Standard: 1): " MODE

    case "$MODE" in
        2)
            echo "Starte Video-Wiedergabe..."
            mpv --ytdl-format="bestvideo+bestaudio/best" "$URL"
            ;;
        *)
            echo "Starte reinen Audio-Stream..."
            mpv --no-video --ytdl-format="bestaudio/best" "$URL"
            ;;
    esac

    echo ""
    echo "Wiedergabe beendet."
    read -p "Drücke Enter, um das Menü erneut aufzurufen (oder Strg+C zum Beenden)..."
done
