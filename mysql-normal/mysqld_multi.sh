#!/bin/bash

setup_dir=$(pwd)

#安装mariadb
cd $setup_dir/
tar -zxvf mariadb-5.5.34.tar.gz
cd mariadb-5.5.34
mkdir -p /usr/local/mysql
mkdir -p /home/mysql/data
mkdir -p /home/data/sql
touch /home/data/sql/init.sql
groupadd mysql
useradd -g mysql mysql
chown -R mysql.mysql /home/mysql
cmake -DCMAKE_INSTALL_PREFIX=/usr/local/mysql -DMYSQL_UNIX_ADDR=/home/mysql/mysql.sock -DDEFAULT_CHARSET=utf8 -DDEFAULT_COLLATION=utf8_general_ci -DWITH_EXTRA_CHARSETS:STRING=utf8,gbk -DWITH_MYISAM_STORAGE_ENGINE=1 -DWITH_INNOBASE_STORAGE_ENGINE=1 -DWITH_MEMORY_STORAGE_ENGINE=1 -DWITH_READLINE=1 -DENABLED_LOCAL_INFILE=1 -DMYSQL_DATADIR=/home/mysql/data -DMYSQL_USER=mysql -DMYSQL_TCP_PORT=3306
make
make install
chmod 755 scripts/mysql_install_db
scripts/mysql_install_db  --user=mysql  --basedir=/usr/local/mysql --datadir=/home/mysql/data
/bin/cp -f ../my.cnf /etc/my.cnf 
/bin/cp -f support-files/mysql.server /etc/init.d/mysql
/bin/cp -f ../mysqld_safe /usr/local/mysql/bin/mysqld_safe
chmod 755 /etc/init.d/mysql
echo 'export PATH=/usr/local/mysql/bin:$PATH' >> /etc/profile
echo "/usr/local/mysql/lib" >> /etc/ld.so.conf
source /etc/profile
ldconfig

#mysqld_multi 配置MySQL多实例
mkdir -p /data/mysql1
mkdir -p /data/mysql2
ln -s /usr/local/mysql/bin/mysqld_multi /usr/bin/mysqld_multi
/usr/local/mysql/scripts/mysql_install_db --datadir=/data/mysql1 --user=mysql
/usr/local/mysql/scripts/mysql_install_db --datadir=/data/mysql2 --user=mysql
chown -R mysql.mysql /data/mysql1
chown -R mysql.mysql /data/mysql2
/bin/cp -f ../m-mysqld_multi.cnf /etc/mysqld_multi.cnf
mysqld_multi --defaults-extra-file=/etc/mysqld_multi.cnf start

#进入端口为3306的数据库  
#mysql -uroot -p -h127.0.0.1 -P3306  

#通过sock文件登录  
#mysql -uroot -p -S /usr/local/var/mysql1/mysql1.sock  

#查看socket文件  
#mysql> SHOW VARIABLES LIKE 'socket';  

#查看pid文件  
#mysql> SHOW VARIABLES LIKE '%pid%'; 

