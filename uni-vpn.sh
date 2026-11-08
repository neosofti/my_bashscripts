#!/usr/bin/env bash

# VPN-Auswahl – FernUni Hagen
# Verwende: ./vpn.sh

clear
echo "========================================"
echo "   VPN-Verbindung – FernUni Hagen"
echo "========================================"
echo ""
echo "  [1] Cisco AnyConnect (GUI)"
echo "  [2] OpenConnect (CLI)"
echo "  [3] Abbrechen"
echo ""
read -rp "Wähle eine Option [1-3]: " choice

case "$choice" in
    1)
        echo ""
        echo "▶ Starte Cisco AnyConnect..."
        sudo gtk-launch com.cisco.secureclient.gui
        ;;
    2)
        echo ""
        echo "▶ Starte OpenConnect..."
        sudo openconnect vpn.fernuni-hagen.de
        ;;
    3)
        echo ""
        echo "Abgebrochen."
        exit 0
        ;;
    *)
        echo ""
        echo "⚠ Ungültige Eingabe: '$choice'"
        exit 1
        ;;
esac
