#!/bin/sh
set -e

#by Chris 2020.07.19

setup_dir=$(pwd)

echo "alias grep='grep --color=auto'">> /etc/bashrc
echo "PS1='\[\e[37;40m\][\[\e[32;40m\]\u\[\e[37;40m\]@\h \[\e[35;40m\]\W\[\e[0m\]]\$'">> /etc/bashrc

#hostnamectl --static set-hostname  k8s-master

setenforce 0
sed -i "s/SELINUX=enforcing/SELINUX=disabled/g" /etc/selinux/config

sed -i "s#^net.ipv4.ip_forward.*#net.ipv4.ip_forward=1#g"  /etc/sysctl.conf
sed -i "s#^net.bridge.bridge-nf-call-ip6tables.*#net.bridge.bridge-nf-call-ip6tables=1#g"  /etc/sysctl.conf
sed -i "s#^net.bridge.bridge-nf-call-iptables.*#net.bridge.bridge-nf-call-iptables=1#g"  /etc/sysctl.conf
echo "net.ipv4.ip_forward = 1" >> /etc/sysctl.conf
echo "net.bridge.bridge-nf-call-ip6tables = 1" >> /etc/sysctl.conf
echo "net.bridge.bridge-nf-call-iptables = 1" >> /etc/sysctl.conf
sysctl -p

yum makecache

yum -y install gcc gcc-c++ make bison patch unzip pcre-devel pam-develmlocate flex wget automake autoconf gd gd-devel cpp gettext readline readline-devel libjpeg libjpeg-devel libpng libpng-devel freetype freetype-devel libxml2 libxml2-devel zlib zlib-devel glibc glibc-devel glib2 glib2-devel bzip2 bzip2-devel ncurses ncurses-devel curl curl-devel e2fsprogs e2fsprogs-devel libidn libidn-devel openldap openldap-devel openldap-clients openldap-servers nss_ldap expat-devel libtool libtool-ltdl-devel bison openssl openssl-devel libcurl libcurl-devel gmp gmp-devel libmcrypt libmcrypt-devel libxslt libxslt-devel gdbm gdbm-devel db4-devel libXpm-devel libX11-devel xmlrpc-c xmlrpc-c-devel libicu-devel libmemcached-devel libzip net-tools yum-utils vim telnet cmake lsof

yum -y update nss





#######################Install Nginx#######################


function Install_nginx(){

cd $setup_dir

/usr/sbin/groupadd www
/usr/sbin/useradd -g www www -s /sbin/nologin

wget http://ftp.pcre.org/pub/pcre/pcre-8.44.tar.gz
tar -zxvf pcre-8.44.tar.gz
cd pcre-8.44
./configure --prefix=/usr/local/pcre
make
make install

cd $setup_dir
wget http://nginx.org/download/nginx-1.18.0.tar.gz
tar -zxvf nginx-1.18.0.tar.gz
cd nginx-1.18.0
./configure \
--user=www \
--group=www \
--prefix=/usr/local/nginx \
--with-pcre=$setup_dir/pcre-8.44 \
--with-http_stub_status_module \
--with-http_ssl_module \
--with-http_gzip_static_module \
--with-stream \
--with-http_addition_module

make
make install

echo "export PATH=$PATH:/usr/local/nginx/bin" >> /etc/profile
source /etc/profile

cp $setup_dir/conf/nginx /etc/init.d/nginx
mv /usr/local/nginx/conf/nginx.conf /usr/local/nginx/conf/nginx.conf.bk
cp $setup_dir/conf/nginx.conf /usr/local/nginx/conf/
cp -rf $setup_dir/conf/vhost /usr/local/nginx/conf/
chmod 700 /etc/init.d/nginx
/etc/init.d/nginx start
/sbin/chkconfig --add nginx
/sbin/chkconfig --level 2345 nginx on
netstat -nat
ps aux |grep nginx
}


#######################Install Mysql5.5#######################

#https://downloads.mysql.com/archives/community/

function Install_mysql55(){


cd $setup_dir
/usr/sbin/groupadd mysql
/usr/sbin/useradd -g mysql mysql -s /sbin/nologin
mkdir -p /data/mysql/{data,binlog}
chown -R mysql:mysql /data/mysql


wget https://cdn.mysql.com/archives/mysql-5.5/mysql-5.5.62.tar.gz
tar zxvf mysql-5.5.62.tar.gz
cd mysql-5.5.62
cmake \
-DCMAKE_INSTALL_PREFIX=/usr/local/mysql \
-DMYSQL_UNIX_ADDR=/data/mysql/mysql.sock \
-DDEFAULT_CHARSET=utf8 \
-DDEFAULT_COLLATION=utf8_general_ci \
-DEXTRA_CHARSETS=all \
-DWITH_MYISAM_STORAGE_ENGINE=1 \
-DWITH_INNOBASE_STORAGE_ENGINE=1 \
-DWITH_READLINE=1 \
-DENABLED_LOCAL_INFILE=1 \
-DMYSQL_DATADIR=/data/mysql/data \
-DMYSQL_TCP_PORT=3306
make
make install

chmod +w /usr/local/mysql
chown -R mysql:mysql /usr/local/mysql
ln -s /usr/local/mysql/lib/libmysqlclient.so.18 /usr/lib/libmysqlclient.so.18
cp $setup_dir/conf/my5.5.cnf  /etc/my.cnf
/usr/local/mysql/scripts/mysql_install_db --basedir=/usr/local/mysql --datadir=/data/mysql/data --user=mysql
sed -i '/# executing mysqld_safe/a\export LD_PRELOAD=/usr/local/lib/libtcmalloc.so' /usr/local/mysql/bin/mysqld_safe
cp support-files/mysql.server /etc/rc.d/init.d/mysqld
sed -i '46 s#basedir=#basedir=/usr/local/mysql#'  /etc/rc.d/init.d/mysqld
sed -i '47 s#datadir=#datadir=/data/mysql/data#'  /etc/rc.d/init.d/mysqld
chmod 700 /etc/rc.d/init.d/mysqld
/etc/rc.d/init.d/mysqld start
/sbin/chkconfig --add mysqld
/sbin/chkconfig --level 2345 mysqld on
#/sbin/mysqladmin -u root password 123456
echo "/usr/local/mysql/lib/mysql" >> /etc/ld.so.conf
/sbin/ldconfig
echo "export PATH=$PATH:/usr/local/mysql/bin" >> /etc/profile
source /etc/profile
}


#######################Install Mysql5.7#######################

#https://downloads.mysql.com/archives/community/


function Install_mysql57(){

cd $setup_dir

wget https://cdn.mysql.com/archives/mysql-5.7/mysql-boost-5.7.30.tar.gz
wget http://www.canonware.com/download/jemalloc/jemalloc-4.2.0.tar.bz2

tar xjf jemalloc-4.2.0.tar.bz2
cd jemalloc-4.2.0
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

}

  
  
#######################Install PHP#######################


function Install_php7(){

cd $setup_dir


wget https://nih.at/libzip/libzip-1.2.0.tar.gz
tar -zxvf libzip-1.2.0.tar.gz
cd libzip-1.2.0
./configure
make && make install

echo '/usr/local/lib64
/usr/local/lib
/usr/lib
/usr/lib64'>>/etc/ld.so.conf
ldconfig -v

cp /usr/local/lib/libzip/include/zipconf.h /usr/local/include/zipconf.h


cd $setup_dir

wget https://www.php.net/distributions/php-7.3.20.tar.gz

tar -zxvf php-7.3.20.tar.gz
cd php-7.3.20
./configure \
 --prefix=/usr/local/php \
 --enable-fpm \
 --with-fpm-user=www \
 --with-fpm-group=www \
 --with-config-file-path=/usr/local/php/etc \
 --disable-rpath \
 --enable-soap \
 --with-libxml-dir \
 --with-xmlrpc \
 --with-openssl \
 --with-mhash \
 --with-pcre-regex \
 --with-zlib \
 --enable-bcmath \
 --with-bz2 \
 --enable-calendar \
 --with-curl \
 --enable-exif \
 --with-pcre-dir \
 --enable-ftp \
 --with-gd \
 --with-openssl-dir \
 --with-jpeg-dir \
 --with-png-dir \
 --with-zlib-dir \
 --with-freetype-dir \
 --enable-gd-jis-conv \
 --with-gettext \
 --with-gmp \
 --with-mhash \
 --enable-mbstring \
 --with-onig \
 --with-mysqli=mysqlnd \
 --with-pdo-mysql=mysqlnd \
 --with-zlib-dir \
 --with-readline \
 --enable-shmop \
 --enable-sockets \
 --enable-sysvmsg \
 --enable-sysvsem \
 --enable-sysvshm \
 --enable-wddx \
 --with-libxml-dir \
 --with-xsl \
 --enable-zip \
 --with-pear

make
make install



echo "export PATH=$PATH:/usr/local/php/bin" >> /etc/profile
source /etc/profile

cp $setup_dir/conf/php.ini /usr/local/php/etc
cp $setup_dir/conf/php-fpm.conf /usr/local/php/etc

cp $setup_dir/conf/php-fpm /etc/init.d/
chmod 755 /etc/init.d/php-fpm
/sbin/chkconfig --add php-fpm
/sbin/chkconfig php-fpm on
service php-fpm start

mkdir -p /home/wwwroot/

cat <<EOF >  /home/wwwroot/index.php
<?php
phpinfo()
?>
EOF

}


Install_init
Install_nginx
#Install_mysql55
Install_mysql57
Install_php7
