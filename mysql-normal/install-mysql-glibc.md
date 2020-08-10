```
#https://downloads.mysql.com/archives/community/

yum -y install numactl libaio

/usr/sbin/groupadd mysql
/usr/sbin/useradd -g mysql mysql -s /sbin/nologin

mkdir -p /data/mysql/{data,binlog}
chown -R mysql:mysql /data/mysql
chmod +x /data/mysql



wget http://mirrors.sohu.com/mysql/MySQL-5.5/mysql-5.5.60-linux-glibc2.12-x86_64.tar.gz


#5.7
#wget http://mirrors.sohu.com/mysql/MySQL-5.7/mysql-5.7.28-linux-glibc2.12-x86_64.tar.gz
#wget https://dev.mysql.com/get/Downloads/MySQL-5.7/mysql-5.7.28-linux-glibc2.12-x86_64.tar.gz

5.8
#wget https://dev.mysql.com/get/Downloads/MySQL-8.0/mysql-8.0.20-linux-glibc2.12-x86_64.tar.xz


tar zxvf mysql-5.5.60-linux-glibc2.12-x86_64.tar.gz
mv mysql-5.5.60-linux-glibc2.12-x86_64 /usr/local/mysql
echo "export PATH=$PATH:/usr/local/mysql/bin" >> /etc/profile
echo '/usr/local/mysql/lib' >> /etc/ld.so.conf
ldconfig

chown -R mysql.mysql /usr/local/mysql

vim /etc/my.cnf
chmod 644 /etc/my.cnf


./scripts/mysql_install_db --basedir=/usr/local/mysql --datadir=/data/mysql/data --defaults-file=/etc/my.cnf

#5.7 and 8
#./bin/mysqld --defaults-file=/etc/my.cnf --initialize-insecure --user=mysql --basedir=/usr/local/mysql  --datadir=/data/mysql/data
#or
#./bin/mysqld --defaults-file=/usr/local/mysql-8.0.20/etc/my.cnf --initialize-insecure --user=mysql

./bin/mysqld_safe --defaults-file=/etc/my.cnf &
#./bin/mysqladmin -u root shutdown  -S /data/mysql8/data/mysql.sock
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


```sql
-- mysql8 CREATE USER

#创建用户
#CREATE USER 'xiaolei'@'10.10.%' IDENTIFIED BY 'p@ssw0rd';
#GRANT ALL PRIVILEGES ON *.* TO 'xiaolei'@'10.10.%' WITH GRANT OPTION;
#FLUSH PRIVILEGES;

#密码永不过期
#ALTER USER 'xiaolei'@'10.10.%' IDENTIFIED BY 'p@ssw0rd' PASSWORD EXPIRE NEVER; 
#更新用户的密码和插件
#ALTER USER 'xiaolei'@'10.10.%' IDENTIFIED WITH mysql_native_password BY 'p@ssw0rd'; 
#刷新权限
#FLUSH PRIVILEGES;


#完整创建用户语句
#CREATE USER 'xiaolei'@'10.10.%' IDENTIFIED WITH mysql_native_password BY 'p@ssw0rd' PASSWORD EXPIRE NEVER; 
#GRANT ALL PRIVILEGES ON *.* TO 'xiaolei'@'10.10.%' WITH GRANT OPTION;
#FLUSH PRIVILEGES;
```
