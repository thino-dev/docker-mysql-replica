# MySQL Replication

### Introduction
MySQL Replication via docker compose

### Including
 - [MySQL](https://hub.docker.com/_/mysql)
 - [phpMyAdmin](https://hub.docker.com/r/phpmyadmin/phpmyadmin)

### Usage

```shell
# setting for .env
cp .env.example .env

# start docker
docker-compose up -d

# stop docker
docker-compose down

# docker logs
docker-compose logs -f
```

### Default DB Port
| service  | port-inside | port-outside  | description |
|---|---|---|---|
| mysql-repl-db-master | 3306, 33060 | 39901 | MySQL master |
| mysql-repl-db-slave | 3306, 33060 | 39902 | MySQL slave |
| mysql-repl-pma | 80 | 39909 | [phpMyAdmin](http://localhost:39909) |

### Default DB User
| Service  | Username | Password  |
|---|---|---|
| mysql-repl-db-master | root | root |
| mysql-repl-db-slave | root | root |
| mysql-repl-db-master/mysql-repl-db-slave | repl | repl-password |
