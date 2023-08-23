#!/bin/sh
set -e

#by Chris 2020.07.19

setup_dir=$(pwd)

echo "alias grep='grep --color=auto'">> /etc/bashrc
echo "PS1='\[\e[37;40m\][\[\e[32;40m\]\u\[\e[37;40m\]@\h \[\e[35;40m\]\W\[\e[0m\]]\$'">> /etc/bashrc

#hostnamectl --static set-hostname  k8s-master

setenforce 0
sed -i "s/SELINUX=enforcing/SELINUX=disabled/g" /etc/selinux/config

yum makecache

yum -y install gcc gcc-c++ make bison patch unzip pcre-devel pam-develmlocate flex wget automake autoconf gd gd-devel cpp gettext readline readline-devel libjpeg libjpeg-devel libpng libpng-devel freetype freetype-devel libxml2 libxml2-devel zlib zlib-devel glibc glibc-devel glib2 glib2-devel bzip2 bzip2-devel ncurses ncurses-devel curl curl-devel e2fsprogs e2fsprogs-devel libidn libidn-devel openldap openldap-devel openldap-clients openldap-servers nss_ldap expat-devel libtool libtool-ltdl-devel bison openssl openssl-devel libcurl libcurl-devel gmp gmp-devel libmcrypt libmcrypt-devel libxslt libxslt-devel gdbm gdbm-devel db4-devel libXpm-devel libX11-devel xmlrpc-c xmlrpc-c-devel libicu-devel libmemcached-devel libzip mcrypt mhash net-tools yum-utils vim telnet cmake lsof

yum -y update nss





#######################Install Nginx#######################


function Install_nginx(){

cd $setup_dir

/usr/sbin/groupadd www
/usr/sbin/useradd -g www www -s /sbin/nologin

mkdir -p /home/wwwroot/

#wget http://ftp.pcre.org/pub/pcre/pcre-8.44.tar.gz
wget https://sourceforge.net/projects/pcre/files/pcre/8.44/pcre-8.44.tar.gz
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

###### --with-openssl=/usr/local/openssl   ######
###### vim auto/lib/openssl/conf   ######
###### .openssl   ######


make
make install

echo "export PATH=$PATH:/usr/local/nginx/sbin" >> /etc/profile
source /etc/profile

cp $setup_dir/conf/nginx /etc/init.d/nginx
mv /usr/local/nginx/conf/nginx.conf /usr/local/nginx/conf/nginx.conf.bk
cp $setup_dir/conf/nginx.conf /usr/local/nginx/conf/
cp -rf $setup_dir/conf/vhost /usr/local/nginx/conf/
cp -rf $setup_dir/conf/tcp.d /usr/local/nginx/conf/
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
cp support-files/mysql.server /etc/rc.d/init.d/mysqld
sed -i '46 s#basedir=#basedir=/usr/local/mysql#'  /etc/rc.d/init.d/mysqld
sed -i '47 s#datadir=#datadir=/data/mysql/data#'  /etc/rc.d/init.d/mysqld
chmod 700 /etc/rc.d/init.d/mysqld
/etc/rc.d/init.d/mysqld start
/sbin/chkconfig --add mysqld
/sbin/chkconfig --level 2345 mysqld on
#/sbin/mysqladmin -u root password 123456
echo "/usr/local/mysql/lib" >> /etc/ld.so.conf
/sbin/ldconfig
echo "export PATH=$PATH:/usr/local/mysql/bin" >> /etc/profile
source /etc/profile
}


#######################Install Mysql5.7#######################

function Install_mysql57(){

#https://downloads.mysql.com/archives/community/

cd $setup_dir

wget https://cdn.mysql.com/archives/mysql-5.7/mysql-boost-5.7.30.tar.gz
wget https://github.com/jemalloc/jemalloc/releases/download/5.2.1/jemalloc-5.2.1.tar.bz2

tar xjf jemalloc-5.2.1.tar.bz2
cd jemalloc-5.2.1
./configure
make && make install
echo "/usr/local/mysql/lib" >> /etc/ld.so.conf
/sbin/ldconfig



/usr/sbin/groupadd mysql
/usr/sbin/useradd -g mysql mysql -s /sbin/nologin

mkdir -p /data/mysql/{data,binlog}
chown -R mysql:mysql /data/mysql

cd $setup_dir
tar zxvf mysql-boost-5.7.30.tar.gz
cd mysql-5.7.30
cmake \
-DCMAKE_INSTALL_PREFIX=/usr/local/mysql \
-DMYSQL_DATADIR=/data/mysql/data \
-DSYSCONFDIR=/etc \
-DMYSQL_USER=mysql \
-DMYSQL_UNIX_ADDR=/data/mysql/mysql.sock \
-DMYSQL_TCP_PORT=3306 \
-DDEFAULT_CHARSET=utf8 \
-DDEFAULT_COLLATION=utf8_general_ci \
-DEXTRA_CHARSETS=all \
-DWITH_MYISAM_STORAGE_ENGINE=1 \
-DWITH_INNOBASE_STORAGE_ENGINE=1 \
-DWITH_PARTITION_STORAGE_ENGINE=1 \
-DWITH_FEDERATED_STORAGE_ENGINE=1 \
-DWITH_BLACKHOLE_STORAGE_ENGINE=1 \
-DWITH_ARCHIVE_STORAGE_ENGINE=1 \
-DWITH_MEMORY_STORAGE_ENGINE=1 \
-DWITH_READLINE=1 \
-DENABLED_LOCAL_INFILE=1 \
-DWITH_BOOST=boost

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
 --with-mysqli=mysqlnd \
 --with-pdo-mysql=mysqlnd \
 --with-libxml-dir \
 --with-xmlrpc \
 --with-openssl \
 --with-mhash \
 --with-pcre-regex \
 --with-zlib \
 --with-gd \
 --with-openssl-dir \
 --with-jpeg-dir \
 --with-png-dir \
 --with-zlib-dir \
 --with-freetype-dir \
 --with-bz2 \
 --with-curl \
 --with-pcre-dir \
 --with-gettext \
 --with-gmp \
 --with-mhash \
 --with-onig \
 --with-zlib-dir \
 --with-readline \
 --with-libxml-dir \
 --with-xsl \
 --with-pear \
 --enable-soap \
 --enable-bcmath \
 --enable-calendar \
 --enable-exif \
 --enable-ftp \
 --enable-mbstring \
 --enable-shmop \
 --enable-sockets \
 --enable-sysvmsg \
 --enable-sysvsem \
 --enable-sysvshm \
 --enable-wddx \
 --enable-zip \
 --enable-xml \
 --enable-mbregex \
 --enable-pcntl \
 --disable-rpath

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

echo "install Zend Opcache"
cd ext/opcache/
/usr/local/php/bin/phpize 
./configure --with-php-config=/usr/local/php/bin/php-config  && make && make install
echo "zend_extension=opcache.so
[opcache]
opcache.memory_consumption=128
opcache.interned_strings_buffer=8
opcache.max_accelerated_files=4000
opcache.revalidate_freq=60
opcache.fast_shutdown=1
opcache.enable_cli=1" >> /usr/local/php/etc/php.ini
service php-fpm restart


###扩展安装
#http://pecl.php.net/packages.php
echo "install mcrypt.so"
cd $setup_dir
wget http://pecl.php.net/get/mcrypt-1.0.3.tgz
tar xf mcrypt-1.0.3.tgz 
cd mcrypt-1.0.3
/usr/local/php/bin/phpize
./configure --with-php-config=/usr/local/php/bin/php-config  && make && make install
echo "extension=mcrypt.so" >> /usr/local/php/etc/php.ini
service php-fpm restart

#/usr/local/php/bin/pecl search mcrypt
#/usr/local/php/bin/pecl install mcrypt

cat <<EOF >  /home/wwwroot/index.php
<?php
phpinfo()
?>
EOF

}



Install_nginx
#Install_mysql55
Install_mysql57
Install_php7



service nginx restart
service mysql restart
service php-fpm restart



#######################Install PHP8#######################


yum install oniguruma-devel -y


wget http://ftp.gnu.org/pub/gnu/libiconv/
tar -zxvf libiconv-1.14.tar.gz
cd libiconv-1.14
./configure --prefix=/usr/local/libiconv make && make install



wget --no-check-certificate https://www.php.net/distributions/php-8.0.0.tar.gz
tar zxvf php-8.0.0.tar.gz
cd php-8.0.0
./configure \
 --prefix=/usr/local/php-8.0.0 \
 --enable-fpm \
 --with-fpm-user=www \
 --with-fpm-group=www \
 --with-config-file-path=/usr/local/php-8.0.0/etc \
 --with-iconv=/usr/local/libiconv/bin \
 --with-mysqli=mysqlnd \
 --with-pdo-mysql=mysqlnd \
 --with-openssl \
 --with-mhash \
 --with-zlib \
 --with-openssl-dir \
 --with-zlib-dir \
 --with-bz2 \
 --with-curl \
 --with-gettext \
 --with-gmp \
 --with-mhash \
 --with-zlib-dir \
 --with-readline \
 --with-xsl \
 --with-pear \
 --enable-soap \
 --enable-bcmath \
 --enable-calendar \
 --enable-exif \
 --enable-ftp \
 --enable-mbstring \
 --enable-shmop \
 --enable-sockets \
 --enable-sysvmsg \
 --enable-sysvsem \
 --enable-sysvshm \
 --enable-xml \
 --enable-mbregex \
 --enable-pcntl \
 --disable-rpath

make && make install


cp php.ini-production /usr/local/php-8.0.0/etc/php.ini
cp sapi/fpm/init.d.php-fpm /etc/init.d/
chmod 755 /etc/init.d/php-fpm


cd /usr/local/php-8.0.0/etc/php-fpm.d
cp www.conf.default www.conf


cd /usr/local/php-8.0.0/etc/
cp php-fpm.conf.default php-fpm.conf