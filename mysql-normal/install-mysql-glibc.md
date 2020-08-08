```
#https://downloads.mysql.com/archives/community/


/usr/sbin/groupadd mysql
/usr/sbin/useradd -g mysql mysql -s /sbin/nologin
mkdir -p /data/mysql/{data,binlog}
chown -R mysql:mysql /data/mysql


wget http://mirrors.sohu.com/mysql/MySQL-5.5/mysql-5.5.60-linux-glibc2.12-x86_64.tar.gz


#5.7
#wget http://mirrors.sohu.com/mysql/MySQL-5.7/mysql-5.7.28-linux-glibc2.12-x86_64.tar.gz
#wget https://dev.mysql.com/get/Downloads/MySQL-5.7/mysql-5.7.28-linux-glibc2.12-x86_64.tar.gz

5.8
#wget https://dev.mysql.com/get/Downloads/MySQL-8.0/mysql-8.0.20-linux-glibc2.12-x86_64.tar.xz


tar zxvf mysql-5.5.60-linux-glibc2.12-x86_64.tar.gz
mv mysql-5.5.60-linux-glibc2.12-x86_64 /usr/local/mysql
echo "export PATH=$PATH:/usr/local/mysql/bin" >> /etc/profile
chown -R mysql.mysql /usr/local/mysql

cd /usr/local/mysql
vim /etc/my.cnf

./scripts/mysql_install_db --basedir=/usr/local/mysql --datadir=/data/mysql/data --defaults-file=/etc/my.cnf

#5.7
#./bin/mysqld --defaults-file=/etc/my.cnf --initialize-insecure --user=mysql --basedir=/usr/local/mysql  --datadir=/data/mysql/data

./bin/mysqld_safe --defaults-file=/etc/my.cnf &
./bin/mysql -uroot -p -S data/mysql.sock 
SHOW VARIABLES LIKE 'socket';
grant all privileges on *.* to xiaolei @'10.10.3.%' identified by 'LX#lxiaolei' ;
flush privileges;

cp /usr/local/mysql/support-files/mysql.server /etc/init.d/mysqld
sed -i '46 s#basedir=#basedir=/usr/local/mysql#'  /etc/init.d/mysqld
sed -i '47 s#datadir=#datadir=/data/mysql/data#'  /etc/init.d/mysqld
chkconfig --add mysqld
chkconfig --level 2345 mysqld on
service mysqld restart

#/usr/local/mysql/bin/mysql_secure_installation

```


