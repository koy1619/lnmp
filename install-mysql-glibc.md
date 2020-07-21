```
wget http://mirrors.sohu.com/mysql/MySQL-5.5/mysql-5.5.60-linux-glibc2.12-x86_64.tar.gz
#5.7
#wget http://mirrors.sohu.com/mysql/MySQL-5.7/mysql-5.7.28-linux-glibc2.12-x86_64.tar.gz
tar zxvf mysql-5.5.60-linux-glibc2.12-x86_64.tar.gz
chown -R xiaolei.xiaolei mysql-5.5.60-linux-glibc2.12-x86_64
cd mysql-5.5.60-linux-glibc2.12-x86_64
mkdir etc
mkdir data
vim etc/my.cnf
chown -R xiaolei.xiaolei mysql-5.5.60-linux-glibc2.12-x86_64
su xiaolei
cd mysql-5.5.60-linux-glibc2.12-x86_64/
./scripts/mysql_install_db --basedir=/data/mysql-5.5.60-linux-glibc2.12-x86_64 --datadir=/data/mysql-5.5.60-linux-glibc2.12-x86_64/data --defaults-file=etc/my.cnf
#5.7
#./bin/mysqld --defaults-file=etc/my.cnf --initialize-insecure --user=mysql --basedir=/data/mysql-5.7.25-linux-glibc2.12-x86_64  --datadir=/data/mysql-5.7.25-linux-glibc2.12-x86_64/data
./bin/mysqld_safe --defaults-file=etc/my.cnf &
./bin/mysql -uroot -p -S data/mysql.sock 
SHOW VARIABLES LIKE 'socket';
grant all privileges on *.* to xiaolei @'10.10.3.%' identified by 'LX#lxiaolei' ;
flush privileges;
```
