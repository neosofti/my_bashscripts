#!/bin/bash
#
# Author: Milen Velikov <root@neosofti.org>
#

	

for i in {5..1}; do
	echo -e "Sync mit GoogleDrive startet in : $i Sekunden."
	sleep 1
done
rclone sync --delete-before --checksum --verbose --transfers 16 --checkers 16 --contimeout 60s --timeout 300s --retries 3 --low-level-retries 10 --stats 1s --stats-file-name-length 0 --fast-list --tpslimit 10 --drive-chunk-size 256M  --buffer-size 64M --drive-upload-cutoff 128M /home/neo/CloudDrive/up2drive GoogleDrive:MyBackup

wait

for i in {5..1}; do
	echo "Sync mit GoogleDrive abgeschlossen. "
	sleep 1
done
