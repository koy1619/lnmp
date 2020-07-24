```
yum -y install gcc gcc-c++ cmake vim bison patch unzip mlocate flex wget automake autoconf gd cpp gettext readline-devel libjpeg libjpeg-devel libpng libpng-devel freetype freetype-devel libxml2 libxml2-devel zlib zlib-devel glibc glibc-devel glib2 glib2-devel bzip2 bzip2-devel ncurses ncurses-devel curl curl-devel e2fsprogs e2fsprogs-devel libidn libidn-devel openldap openldap-devel openldap-clients openldap-servers nss_ldap expat-devel libtool libtool-ltdl-devel bison openssl-devel lsof
####

#https://downloads.mysql.com/archives/community/

wget http://mirrors.sohu.com/mysql/MySQL-5.7/mysql-5.7.12.tar.gz
wget http://mirrors.sohu.com/mysql/MySQL-5.7/mysql-boost-5.7.12.tar.gz  #编译MySQL5.7需要boost支持，如果事先没有装好boost，就下载这个。
wget https://cmake.org/files/v3.5/cmake-3.5.2.tar.gz    #编译MySQL5.7需要的cmake最低版本为2.8
wget http://www.canonware.com/download/jemalloc/jemalloc-4.2.0.tar.bz2  #jemalloc优化MySQL内存管理



tar xjf jemalloc-4.2.0.tar.bz2
cd jemalloc-4.2.0
./configure
make && make install
echo '/usr/local/lib' > /etc/ld.so.conf.d/local.conf
ldconfig



/usr/sbin/groupadd mysql
/usr/sbin/useradd -g mysql mysql -s /sbin/nologin

mkdir -p /dbdata/mysql/{data,binlog,relaylog,mysql}
chown -R mysql:mysql /dbdata/mysql

tar zxvf mysql-boost-5.7.12.tar.gz
cd mysql-5.7.12
cmake \
-DCMAKE_INSTALL_PREFIX=/usr/local/mysql \                     [MySQL安装的根目录]
-DMYSQL_DATADIR=/data/mysql/data \                            [MySQL数据库文件存放目录]
-DSYSCONFDIR=/etc \                                           [MySQL配置文件所在目录]
-DMYSQL_USER=mysql \                                          [MySQL用户名]
-DMYSQL_UNIX_ADDR=/data/mysql/mysql.sock \                    [MySQL的通讯sock]
-DMYSQL_TCP_PORT=3306 \                                       [MySQL的监听端口]
-DDEFAULT_CHARSET=utf8 \                                      [设置默认字符集为utf8]
-DDEFAULT_COLLATION=utf8_general_ci \                         [设置默认字符校对]
-DEXTRA_CHARSETS=all \                                        [使MySQL支持所有的扩展字符]
-DWITH_MYISAM_STORAGE_ENGINE=1 \                              [MySQL的数据库引擎]
-DWITH_INNOBASE_STORAGE_ENGINE=1 \                            [MySQL的数据库引擎]
-DWITH_PARTITION_STORAGE_ENGINE=1 \                           [MySQL的数据库引擎]
-DWITH_FEDERATED_STORAGE_ENGINE=1 \                           [MySQL的数据库引擎]
-DWITH_BLACKHOLE_STORAGE_ENGINE=1 \                           [MySQL的数据库引擎]
-DWITH_ARCHIVE_STORAGE_ENGINE=1 \                             [MySQL的数据库引擎]
-DWITH_MEMORY_STORAGE_ENGINE=1 \                              [MySQL的数据库引擎]
-DWITH_READLINE=1 \                                           [MySQL的readline library]
-DENABLED_LOCAL_INFILE=1 \                                    [启用加载本地数据]
-DWITH_BOOST=boost                                            [boost支持]

make & make install


chmod +w /usr/local/mysql
chown -R mysql:mysql /usr/local/mysql
/usr/local/mysql/bin/mysqld --initialize-insecure --user=mysql --basedir=/usr/local/mysql --datadir=/dbdata/mysql/data
sed -i 's@executing mysqld_safe@executing mysqld_safe\nexport LD_PRELOAD=/usr/local/lib/libjemalloc.so@' /usr/local/mysql/bin/mysqld_safe
cp support-files/mysql.server /etc/rc.d/init.d/mysqld
sed -i '46 s#basedir=#basedir=/usr/local/mysql#'  /etc/rc.d/init.d/mysqld
sed -i '47 s#datadir=#datadir=/dbdata/mysql/data#'  /etc/rc.d/init.d/mysqld
chmod 700 /etc/rc.d/init.d/mysqld
#cp /usr/local/mysql/support-files/my-default.cnf /etc/my.cnf
/etc/rc.d/init.d/mysqld start
/usr/sbin/lsof -n | grep jemalloc
/sbin/chkconfig --add mysqld
/sbin/chkconfig --level 2345 mysqld on
#/sbin/mysqladmin -u root password 123456
echo "/usr/local/mysql/lib/mysql" >> /etc/ld.so.conf
/sbin/ldconfig
echo "export PATH=$PATH:/usr/local/mysql/bin" >> /etc/profile
source /etc/profile
#mysql
#select version();
#show global variables like "%datadir%";
#status;


参考：
https://blog.linuxeye.com/432.html
https://typecodes.com/web/centos7compilemysql.html
http://www.cnblogs.com/colder219/p/5492513.html
https://blog.linuxeye.com/356.html
http://dev.mysql.com/doc/refman/5.7/en/source-configuration-options.html


附 my.cnf


[ebuy@zhenru6_8 ~]$ cat /etc/my.cnf 
[client]
port            = 3306
socket          = /dbdata/mysqldata/mysql.sock


[mysqld]
port            = 3306
socket          = /dbdata/mysqldata/mysql.sock
skip-external-locking
key_buffer_size = 1G
max_allowed_packet = 100M
table_open_cache = 512
sort_buffer_size = 8M
read_buffer_size = 20M
join_buffer_size = 2M
read_rnd_buffer_size = 20M
myisam_sort_buffer_size = 128M

thread_cache_size = 100
query_cache_size = 100M
query_cache_limit = 2M
tmp_table_size=200M 

lower_case_table_names = 1
log_timestamps = SYSTEM

sql_mode = 'STRICT_TRANS_TABLES,ERROR_FOR_DIVISION_BY_ZERO,NO_AUTO_CREATE_USER,NO_ENGINE_SUBSTITUTION'


basedir = /usr/local/mysql
datadir = /dbdata/mysqldata

skip-name-resolve

log-bin=/dbbak/binlog/mysql-bin
expire_logs_days = 7
server-id       = 8828

log_slave_updates = on
replicate_wild_ignore_table = mysql.%
replicate_wild_ignore_table = test.%
sync_binlog = 1


relay-log = /dbbak/binlog/mysql-relay-bin
relay_log_index = /dbbak/binlog/mysql-relay-bin.index
binlog_format = mixed



 
innodb_data_file_path = ibdata1:512M;ibdata2:512M:autoextend
innodb_log_group_home_dir = /dbbak/binlog/
innodb_file_per_table = 1
innodb_buffer_pool_size = 13G
innodb_log_file_size = 1G
innodb_log_buffer_size = 18M
innodb_flush_log_at_trx_commit = 1
innodb_lock_wait_timeout = 50
innodb_io_capacity = 800

innodb_flush_method = O_DIRECT

auto-increment-increment=1
concurrent_insert=2

default-time-zone       = "+8:00"
character_set_server =  utf8

max_connections = 16384
#general-log = on
#general_log_file = /dbbak/binlog/general.log
#slow-query-log = on
#long_query_time = 3
#slow_query_log_file = /dbbak/binlog/slowquery_3.log
log-queries-not-using-indexes = true
max_connect_errors = 100000

[mysqldump]
quick
max_allowed_packet = 50M

[mysql]
no-auto-rehash

[myisamchk]
key_buffer_size = 256M
sort_buffer_size = 256M
read_buffer = 2M
write_buffer = 2M

[mysqlhotcopy]
interactive-timeout
[ebuy@zhenru6_8 ~]$ 
