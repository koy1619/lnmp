#######################Install Mysql5.7#######################

#https://downloads.mysql.com/archives/community/

setup_dir=$(pwd)

yum -y install gcc gcc-c++ cmake vim bison patch unzip mlocate flex wget automake autoconf gd cpp gettext readline-devel libjpeg libjpeg-devel libpng libpng-devel freetype freetype-devel libxml2 libxml2-devel zlib zlib-devel glibc glibc-devel glib2 glib2-devel bzip2 bzip2-devel ncurses ncurses-devel curl curl-devel e2fsprogs e2fsprogs-devel libidn libidn-devel openldap openldap-devel openldap-clients openldap-servers nss_ldap expat-devel libtool libtool-ltdl-devel bison openssl-devel lsof



cd $setup_dir

wget https://cdn.mysql.com/archives/mysql-5.7/mysql-boost-5.7.30.tar.gz
wget https://github.com/jemalloc/jemalloc/releases/download/5.2.1/jemalloc-5.2.1.tar.bz2

tar xjf jemalloc-5.2.1.tar.bz2
cd jemalloc-5.2.1
./configure
make && make install
echo '/usr/local/lib' > /etc/ld.so.conf.d/local.conf
ldconfig



/usr/sbin/groupadd mysql
/usr/sbin/useradd -g mysql mysql -s /sbin/nologin

mkdir -p /data/mysql/{data,binlog}
chown -R mysql:mysql /data/mysql

cd $setup_dir
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
cp $setup_dir/conf/my5.7.cnf  /etc/my.cnf
/usr/local/mysql/bin/mysqld --initialize-insecure --user=mysql --basedir=/usr/local/mysql --datadir=/data/mysql/data
sed -i 's@executing mysqld_safe@executing mysqld_safe\nexport LD_PRELOAD=/usr/local/lib/libjemalloc.so@' /usr/local/mysql/bin/mysqld_safe
cp support-files/mysql.server /etc/rc.d/init.d/mysqld
sed -i '46 s#basedir=#basedir=/usr/local/mysql#'  /etc/rc.d/init.d/mysqld
sed -i '47 s#datadir=#datadir=/data/mysql/data#'  /etc/rc.d/init.d/mysqld
chmod 700 /etc/rc.d/init.d/mysqld
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
