stream {        #定义stream；TCP模块是和HTTP一样的一个独立模块，所以不能设置在HTTP里面，设置在一个单独的配置文件。
   upstream mysql-server {    #定义后端服务器
       server 192.168.38.37:3306 max_fails=3 fail_timeout=30s;     #定义具体server
   }

   upstream redis-server {
       server 192.168.38.47:6379 max_fails=3 fail_timeout=30s;
   }

   upstream tcp_proxy {
       hash $remote_addr consistent;
       server 10.127.5.165:2222;
   }

   server {     #定义server
       listen 3306;                  #监听本机所有IP的3306端口
       proxy_connect_timeout 30s;    #连接超时时间
       proxy_timeout 30s;            #转发超时时间
       proxy_pass mysql-server;      #转发到具体服务器组
   }

   server {
       listen 192.168.38.27:6379;    #监听在本机的192.168.38.27的6379端口
       proxy_connect_timeout 30s;
       proxy_timeout 30s;
       proxy_pass redis-server;
   }

   server {
       listen 2222 so_keepalive=on;
       proxy_connect_timeout 86400s;
       proxy_timeout 86400s;
       proxy_pass tcp_proxy;
   }

}
