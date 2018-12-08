# HTTPS server
server {
listen 80;
server_name client.sucre.io;
return 301 https://$server_name$request_uri;
}
 
server {
listen 443 ssl http2;
server_name client.sucre.io;
 
# play public assets
root html;

http2_max_concurrent_streams 64;
http2_streams_index_size     64;    #default
http2_idle_timeout           30s;   #default
http2_recv_timeout           3m;    #default
http2_chunk_size             200k;
http2_max_field_size         4096;  #default
http2_max_header_size        16384; #default
http2_pool_size              8192;
add_header Alternate-Protocol 443:npn-http/2;
 
# SSL configuration
ssl on;
ssl_certificate /etc/nginx/ssl/client.sucre.io/fullchain.pem;
ssl_certificate_key /etc/nginx/ssl/client.sucre.io/privkey.pem;
 
ssl_session_timeout 5m;
ssl_protocols SSLV3 TLSv1 TLSv1.1 TLSv1.2;
ssl_ciphers 'EECDH+AESGCM:EDH+AESGCM:AES256+EECDH:AES256+EDH';
ssl_prefer_server_ciphers on;
ssl_session_cache shared:SSL:10m;

 
# serve assets or request page from proxy (if asset not found)
location / {
try_files $uri @proxy;
}
 
# the rails web server
location @proxy {
proxy_pass https://testnet.dev.localhost:8080;
proxy_redirect off;
proxy_buffering off;
http2_push_preload              on;

#send protocol info to play server
proxy_set_header Host $host;
proxy_set_header X-Real-IP $remote_addr;
proxy_set_header X-Forwarded-Proto https;
proxy_set_header X-Forwarded-Ssl on;
proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
}
}