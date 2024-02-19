#!/bin/bash
set -e

# 等待 DB 啟動
until mysql -h "$MYSQL_HOST_MASTER" -u root -p"$MYSQL_ROOT_PASSWORD" -e ";" ; do
  echo 'Waiting for the master database to become available...'
  sleep 2
done

# 檢查覆制用戶是否存在
REPL_USER_EXISTS=0
until [ $REPL_USER_EXISTS -eq 1 ]; do
  REPL_USER_EXISTS=$(mysql -h "$MYSQL_HOST_MASTER" -u root -p"$MYSQL_ROOT_PASSWORD" -e "SELECT EXISTS(SELECT 1 FROM mysql.user WHERE user = '$REPL_USER');" | awk 'NR==2')
  if [ "$REPL_USER_EXISTS" -eq 0 ]; then
    echo "Replication user $REPL_USER does not exist on the master. Checking again in 5 seconds..."
    sleep 5
  fi
done

echo "Replication user $REPL_USER exists. Continuing with replication setup..."

# 從 master 獲取複製配置
MASTER_LOG_FILE=$(mysql -h "$MYSQL_HOST_MASTER" -u "$REPL_USER" -p"$REPL_USER_PASSWORD" -e "SHOW MASTER STATUS\G" | grep "File:" | awk '{print $2}')
MASTER_LOG_POS=$(mysql -h "$MYSQL_HOST_MASTER" -u "$REPL_USER" -p"$REPL_USER_PASSWORD" -e "SHOW MASTER STATUS\G" | grep "Position:" | awk '{print $2}')

# 檢查 slave 狀態
SLAVE_STATUS=$(mysql -u root -p"$MYSQL_ROOT_PASSWORD" -e "SHOW SLAVE STATUS\G")
if [ -z "$SLAVE_STATUS" ]; then
    mysql -u root -p"$MYSQL_ROOT_PASSWORD" <<-EOSQL
CHANGE MASTER TO MASTER_HOST='$MYSQL_HOST_MASTER', MASTER_USER='$REPL_USER', MASTER_PASSWORD='$REPL_USER_PASSWORD', MASTER_LOG_FILE='$MASTER_LOG_FILE', MASTER_LOG_POS=$MASTER_LOG_POS;
START REPLICA;
EOSQL
else
    mysql -u root -p"$MYSQL_ROOT_PASSWORD" <<-EOSQL
STOP REPLICA;
RESET REPLICA ALL;
CHANGE MASTER TO MASTER_HOST='$MYSQL_HOST_MASTER', MASTER_USER='$REPL_USER', MASTER_PASSWORD='$REPL_USER_PASSWORD', MASTER_LOG_FILE='$MASTER_LOG_FILE', MASTER_LOG_POS=$MASTER_LOG_POS;
START REPLICA;
EOSQL
fi

echo 'Slave database configured successfully.'