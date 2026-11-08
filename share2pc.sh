#!/bin/bash
#
# Author: Milen Velikov <root@neosofti.org>
#

/usr/bin/rclone sync --delete-during --checksum --ignore-size --verbose --transfers 4 --checkers 8 --contimeout 60s --timeout 300s --retries 3 --low-level-retries 10 --stats 1s --stats-file-name-length 0 --fast-list GoogleDrive:Share /home/neo/CloudDrive/do2pc/Share
