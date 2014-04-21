#!/bin/sh

#by 麻晓磊 2013.11.12

setup_dir=$(pwd)

yum makecache
yum -y install gcc gcc-c++ bison patch unzip mlocate flex wget automake autoconf gd cpp gettext readline-devel libjpeg libjpeg-devel libpng libpng-devel freetype freetype-devel libxml2 libxml2-devel zlib zlib-devel glibc glibc-devel glib2 glib2-devel bzip2 bzip2-devel ncurses ncurses-devel curl curl-devel e2fsprogs e2fsprogs-devel libidn libidn-devel openldap openldap-devel openldap-clients openldap-servers nss_ldap expat-devel libtool libtool-ltdl-devel bison openssl-devel



#######################Install Mysql#######################

cd $setup_dir/mysql
tar -zxvf libunwind-1.0.1.tar.gz 
cd libunwind-1.0.1
./configure
make
make install

cd $setup_dir/mysql
tar -zxvf gperftools-2.0.tar.gz 
cd gperftools-2.0
./configure
make
make install
echo "/usr/local/lib" > /etc/ld.so.conf.d/usr_local_lib.conf
/sbin/ldconfig

cd $setup_dir/mysql  
tar -zxvf cmake-2.8.8.tar.gz 
cd cmake-2.8.8
./bootstrap
gmake
gmake install

   
/usr/sbin/groupadd mysql
/usr/sbin/useradd -g mysql mysql -s /sbin/nologin
mkdir -p /data/mysql/{data,binlog,relaylog,mysql}
chown -R mysql:mysql /data/mysql

cd $setup_dir/mysql   
tar zxvf mysql-5.5.25.tar.gz 
cd mysql-5.5.25
rm -rf CMakeCache.txt
cmake -DCMAKE_INSTALL_PREFIX=/usr/local/mysql -DMYSQL_UNIX_ADDR=/data/mysql/mysql.sock -DDEFAULT_CHARSET=utf8 -DDEFAULT_COLLATION=utf8_general_ci -DEXTRA_CHARSETS=all -DWITH_MYISAM_STORAGE_ENGINE=1 -DWITH_INNOBASE_STORAGE_ENGINE=1 -DWITH_READLINE=1 -DENABLED_LOCAL_INFILE=1 -DMYSQL_DATADIR=/data/mysql/data -DMYSQL_TCP_PORT=3306
make
make install

chmod +w /usr/local/mysql
chown -R mysql:mysql /usr/local/mysql
ln -s /usr/local/mysql/lib/libmysqlclient.so.18 /usr/lib/libmysqlclient.so.18
/usr/local/mysql/scripts/mysql_install_db --basedir=/usr/local/mysql --datadir=/data/mysql/data --user=mysql
sed -i '/# executing mysqld_safe/a\export LD_PRELOAD=/usr/local/lib/libtcmalloc.so' /usr/local/mysql/bin/mysqld_safe
cp support-files/mysql.server /etc/rc.d/init.d/mysqld
sed -i '46 s#basedir=#basedir=/usr/local/mysql#'  /etc/rc.d/init.d/mysqld
sed -i '47 s#datadir=#datadir=/data/mysql/data#'  /etc/rc.d/init.d/mysqld
chmod 700 /etc/rc.d/init.d/mysqld
cp /usr/local/mysql/support-files/my-medium.cnf /etc/my.cnf
/etc/rc.d/init.d/mysqld start
/usr/sbin/lsof -n | grep tcmalloc
/sbin/chkconfig --add mysqld
/sbin/chkconfig --level 2345 mysqld on
ln -s /usr/local/mysql/bin/mysql /sbin/mysql
ln -s /usr/local/mysql/bin/mysql /usr/bin/mysql
ln -s /usr/local/mysql/bin/mysqladmin /sbin/mysqladmin
ln -s /usr/local/mysql/bin/mysqladmin /usr/bin/mysqladmin
/sbin/mysqladmin -u root password 123456
echo "/usr/local/mysql/lib/mysql" >> /etc/ld.so.conf
/sbin/ldconfig
echo "export PATH=$PATH:/usr/local/mysql/bin" >> /etc/profile
source /etc/profile




#######################Install Nginx#######################



/usr/sbin/groupadd www
/usr/sbin/useradd -g www www -s /sbin/nologin

cd $setup_dir/nginx
tar -jxvf pcre-8.30.tar.bz2 
cd pcre-8.30
./configure --prefix=/usr/local/pcre
make
make install

cd $setup_dir/nginx
tar -zxvf nginx-1.2.0.tar.gz 
cd nginx-1.2.0
./configure --user=www --group=www --prefix=/usr/local/nginx --with-pcre=/home/setup/nginx/pcre-8.30 --with-http_stub_status_module --with-http_ssl_module --with-http_gzip_static_module
make
make install

cp $setup_dir/conf/nginx /etc/init.d/nginx
mv /usr/local/nginx/conf/nginx.conf /usr/local/nginx/conf/nginx.conf.bk
cp $setup_dir/conf/nginx.conf /usr/local/nginx/conf/
cd /usr/local/nginx/conf/
mkdir vhost
chmod 700 /etc/init.d/nginx
/etc/init.d/nginx start
/sbin/chkconfig --add nginx
/sbin/chkconfig --level 2345 nginx on
netstat -nat
ps aux |grep nginx



#######################Install httpd#######################

yum remove -y apr-util-devel apr apr-util-mysql apr-docs apr-devel apr-util apr-util-docs httpd

cd $setup_dir/httpd
tar -zvxf apr-1.4.6.tar.gz
cd apr-1.4.6
./configure --prefix=/usr/local/apr
make
make install

cd $setup_dir/httpd
tar -zxf apr-util-1.3.12.tar.gz
cd apr-util-1.3.12
./configure --prefix=/usr/local/apr-util -with-apr=/usr/local/apr/bin/apr-1-config
make
make install

cd $setup_dir/httpd
tar -jxvf pcre-8.30.tar.bz2
cd pcre-8.30
./configure --prefix=/usr/local/pcre
make
make install

cd $setup_dir/httpd
tar zxvf httpd-2.4.3.tar.gz
cd httpd-2.4.3
./configure --prefix=/usr/local/httpd/ --with-apr=/usr/local/apr/ --with-apr-util=/usr/local/apr-util/ --with-pcre=/usr/local/pcre --enable-module=most --enable-rewrite --enable-shared=max --enable-so
make
make install
cp $setup_dir/conf/httpd /etc/init.d/httpd
chmod +x /etc/init.d/httpd
chkconfig --add httpd
chkconfig httpd on

mv /usr/local/httpd/conf/httpd.conf /usr/local/httpd/conf/httpd.conf.bk
cp $setup_dir/conf/httpd.conf /usr/local/httpd/conf/

cd /usr/sbin
ln -fs /usr/local/httpd/bin/httpd
ln -fs /usr/local/httpd/bin/apachectl
service httpd restart
  
  
#######################Install PHP#######################

cd $setup_dir/php
tar -zxvf libiconv-1.14.tar.gz
cd libiconv-1.14
./configure
make
make install

cd $setup_dir/php
tar -jxvf libmcrypt-2.5.8.tar.bz2 
cd libmcrypt-2.5.8
./configure
make
make install
/sbin/ldconfig
  
cd libltdl/
./configure --enable-ltdl-install
make
make install
  
cd $setup_dir/php
tar -jxvf mhash-0.9.9.9.tar.bz2 
cd mhash-0.9.9.9
./configure
make
make install
ln -s /usr/local/lib/libmcrypt.la /usr/lib/libmcrypt.la
ln -s /usr/local/lib/libmcrypt.so /usr/lib/libmcrypt.so
ln -s /usr/local/lib/libmcrypt.so.4 /usr/lib/libmcrypt.so.4
ln -s /usr/local/lib/libmcrypt.so.4.4.8 /usr/lib/libmcrypt.so.4.4.8
ln -s /usr/local/lib/libmhash.a /usr/lib/libmhash.a
ln -s /usr/local/lib/libmhash.la /usr/lib/libmhash.la
ln -s /usr/local/lib/libmhash.so /usr/lib/libmhash.so
ln -s /usr/local/lib/libmhash.so.2 /usr/lib/libmhash.so.2
ln -s /usr/local/lib/libmhash.so.2.0.1 /usr/lib/libmhash.so.2.0.1

cd $setup_dir/php
tar -zxvf mcrypt-2.6.8.tar.gz 
cd mcrypt-2.6.8
/sbin/ldconfig
./configure
make
make install

cd $setup_dir/php
tar -jxvf php-5.4.0.tar.bz2 
cd php-5.4.0
./configure --prefix=/usr/local/php --with-config-file-path=/usr/local/php/etc  --with-apxs2=/usr/local/httpd/bin/apxs --with-mysql=/usr/local/mysql --with-mysqli=/usr/local/mysql/bin/mysql_config --with-iconv-dir=/usr/local --enable-fpm --disable-debug --enable-safe-mode --with-freetype-dir --with-jpeg-dir --with-png-dir --with-zlib --with-libxml-dir=/usr --enable-xml --disable-rpath --enable-bcmath --enable-shmop --enable-sysvsem --enable-inline-optimization --with-curl --with-curlwrappers --enable-mbregex --enable-mbstring --with-mcrypt --with-gd --enable-gd-native-ttf --with-openssl --with-mhash --enable-pcntl --enable-sockets --with-xmlrpc --enable-zip --enable-soap
make ZEND_EXTRA_LIBS='-liconv'
make install

ln -s /usr/local/php/bin/php /usr/bin/php
ln -s /usr/local/php/bin/php /sbin/php

cp $setup_dir/conf/php.ini /usr/local/php/etc
cp $setup_dir/conf/php-fpm.conf /usr/local/php/etc

cp $setup_dir/conf/php-fpm /etc/init.d/
chmod 755 /etc/init.d/php-fpm
/sbin/chkconfig --add php-fpm
/sbin/chkconfig php-fpm on
service php-fpm restart

cd ext/pdo_mysql/
/usr/local/php/bin/phpize
./configure --with-php-config=/usr/local/php/bin/php-config --with-pdo-mysql=/usr/local/mysql
make
make install


cd $setup_dir/php
tar -zxvf memcache-3.0.7.tgz
cd memcache-3.0.7/
/usr/local/php/bin/phpize
./configure --with-php-config=/usr/local/php/bin/php-config --with-zlib-dir --enable-memcache
make
make install

cd $setup_dir/php
tar -xzf libevent-2.0.19-stable.tar.gz
cd libevent-2.0.19-stable
./configure
make
make install
ln -s /usr/local/lib/libevent-2.0.so.5 /usr/lib

cd $setup_dir/php
tar -xzf memcached-1.4.13.tar.gz 
cd memcached-1.4.13
./configure --prefix=/usr/local/memcached --with-libevent=/usr
make
make install

cd $setup_dir/php
tar -zxvf libmemcached-1.0.8.tar.gz 
cd libmemcached-1.0.8
./configure --prefix=/usr/local/libmemcached  --with-memcached
make
make install

cd $setup_dir/php
tar -zxvf memcached-2.0.1.tgz 
cd memcached-2.0.1
/usr/local/php/bin/phpize
./configure --enable-memcached --with-php-config=/usr/local/php/bin/php-config --with-libmemcached-dir=/usr/local/libmemcached --with-memcached --with-zlib
make
make install

cd $setup_dir/php
tar -zxvf xcache-2.0.0.tar.gz 
cd xcache-2.0.0
/usr/local/php/bin/phpize
./configure --with-php-config=/usr/local/php/bin/php-config
make
make install


cd $setup_dir/php
tar zxvf ImageMagick.tar.gz 
cd ImageMagick-6.7.8-0
./configure --prefix=/usr/local/imagemagick
make
make install


cd $setup_dir/php
tar -zxvf imagick-3.1.0RC1.tgz
cd imagick-3.1.0RC1/
export  PKG_CONFIG_PATH=/usr/local/imagemagick/lib/pkgconfig
/usr/local/php/bin/phpize
./configure --with-php-config=/usr/local/php/bin/php-config --with-imagick=/usr/local/imagemagick
make
make install

cd $setup_dir/php
tar zxvf eaccelerator-eaccelerator-42067ac.tar.gz 
cd eaccelerator-eaccelerator-42067ac
/usr/local/php/bin/phpize
./configure --enable-eaccelerator=shared --with-php-config=/usr/local/php/bin/php-config
make
make install
mkdir -p /usr/local/eaccelerator_cache

service php-fpm restart
service httpd restart
service nginx restart
service mysqld restart


echo "  "
echo "  "
echo "=====================================恭喜lnamp安装成功！================================================"
echo "  "
echo "  "

echo "mysql端口号为3306，root密码为123456 datadir=/data/mysql/data;"
echo "nginx端口号为80，虚拟主机配置路径为/usr/local/nginx/conf/vhost，重启nginx命令service nginx restart|start|stop"
echo "apache端口号为81，添加虚拟主机可自定义，然后用nginx反向代理，重启apache命令service httpd restart|start|stop"
echo "php使用fpm启动，端口为9000，重启php命令service php-fpm restart|start|stop"
echo "  "
echo "  "

