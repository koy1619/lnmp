#!/bin/bash

BACKUP_SRC="/home/wwwroot"
BACKUP_DST="/home/backup"
#MYSQL_SERVER="localhost"
#MYSQL_USER="root"
MYSQL_PASS="123456"



# Stop editing here.
NOW=$(date +"%Y.%m.%d")
DESTFILE="$BACKUP_DST/$NOW.tar.gz"


# Backup files.
echo "Dumping databases..."
/usr/local/mysql/bin/mysqldump -u root  -p$MYSQL_PASS database1 > "$NOW-database1.sql"
/usr/local/mysql/bin/mysqldump -u root  -p$MYSQL_PASS database2 > "$NOW-database2.sql"
tar zcvf "$DESTFILE" $BACKUP_SRC "$NOW-database1.sql" "$NOW-database2.sql"


rm -f "$NOW-database1.sql"
rm -f "$NOW-database2.sql"

find ${BACKUP_DST} -ctime +7 | xargs rm -rf