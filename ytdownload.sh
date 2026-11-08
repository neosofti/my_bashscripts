#!/bin/bash

read -p "YouTube Playlist- oder Video-URL eingeben: " URL

if [ -z "$URL" ]; then
    echo "Fehler: Keine URL angegeben." >&2
    exit 1
fi

yt-dlp -x \
       --audio-format mp3 \
       --embed-thumbnail \
       --add-metadata \
       --yes-playlist \
       --ignore-errors \
       -o '%(playlist_title)s/%(title)s.%(ext)s' \
       "$URL"
