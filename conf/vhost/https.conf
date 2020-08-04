server {
        listen 443 ssl;
        server_name  malai-jump.test.com;

  ssl_certificate   /etc/nginx/sslkey/1_jumpserver.org_bundle.crt;
  ssl_certificate_key  /etc/nginx/sslkey/2_jumpserver.org.key;
  ssl_session_timeout 5m;
  ssl_ciphers ECDHE-RSA-AES128-GCM-SHA256:ECDHE:ECDH:AES:HIGH:!NULL:!aNULL:!MD5:!ADH:!RC4;
  ssl_protocols TLSv1 TLSv1.1 TLSv1.2;
  ssl_prefer_server_ciphers on;


        location / {
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_buffering off;

        #支持WebSocket
        proxy_http_version 1.1;
        proxy_set_header Upgrade $http_upgrade;
        proxy_set_header Connection "Upgrade";


        proxy_pass http://10.127.5.165:7000;

        }
}




server
        {
                listen       80;
                server_name malai-jump.test.com;
                rewrite ^(.*) https://malai-jump.test.com$1 permanent;
        }
