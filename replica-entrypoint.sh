#!/bin/bash
set -e

PGDATA=/var/lib/postgresql/data

if [ ! -s "$PGDATA/PG_VERSION" ]; then
    echo "Инициализация реплики через pg_basebackup..."
    
    PGPASSWORD=replicator_password pg_basebackup \
        -h 31.57.62.46 \
        -p 5432 \
        -U replicator \
        -D $PGDATA \
        -Fp -Xs -R -P -v
    
    touch $PGDATA/standby.signal
    
    echo "primary_conninfo = 'host=31.57.62.46 port=5432 user=replicator password=replicator_password'" >> $PGDATA/postgresql.auto.conf
    echo "hot_standby = on" >> $PGDATA/postgresql.auto.conf
    
    chown -R postgres:postgres $PGDATA
    chmod 700 $PGDATA
    
    echo "Репликация инициализирована успешно"
else
    echo "База данных уже инициализирована"
fi

exec gosu postgres postgres \
    -c config_file=/etc/postgresql/postgresql.conf \
    -c hba_file=/etc/postgresql/pg_hba.conf
