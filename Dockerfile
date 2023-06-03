# syntax=docker/dockerfile:1
FROM guacamole/guacamole:${GM_VERSION:-1.5.1}

USER root

RUN apt-get update && apt-get -y install apache2-utils

# SCRIPT
COPY <<-SCRIPT start.sh
# Variables
BASE="/data"
SCHEMA="\$BASE/schema.sql"
EXTENSIONS="\$BASE/extensions"
CERT="\$BASE/ssl"
CHECK="\$BASE/.deployed"
HTPASS="\$BASE/.htpasswd"
# Functions
o() { echo "==> \$1"; }
e() { echo "==> ERR: \$1!"; exit \$2; }
# Check environment
for i in VERSION DB DB_NAME DB_USER DB_PASS MFA NG_USER NG_PASS; do
    [ "\$(printenv GM_\$i)x" == "x" ] && e "\GM_\$i not found. You should have a .env (copy from .env-example)" 1
done
# Check if it was installed before
if [ -f "\$CHECK" ]; then
    o "Guacamole deployed already on version \$GM_VERSION."
    o "To redeploy it, please, remove the \$CHECK file (all data will be erased)"
    exit 0
fi
o "Cleaning \$EXTENSIONS and \$CERT folders"
rm -rf "\$EXTENSIONS" "\$CERT" || e "remove extensions failed" 2
mkdir -p "\$EXTENSIONS" "\$CERT" || e "create extensions failed" 3
# Download and unpack extensions
[ "\$GM_MFA" == "totp" ] && o "Copying TOTP..." && cp totp/*.jar "\$EXTENSIONS"
[ "\$GM_MFA" == "duo" ] && o "Copying DUO..." && cp duo/*.jar "\$EXTENSIONS"
o "Copying SQL schema"
/opt/guacamole/bin/initdb.sh --mysql > "\$SCHEMA"
# haproxy configuration
o "Creating SSL certificates"
openssl req -x509 -nodes -days 365 -subj "/C=BR/ST=DF/O=UNB/CN=unb.br" -newkey rsa:2048 -keyout "\$CERT/server.pem.key" -out "\$CERT/server.pem"
o "Creating haproxy configuration"
cat > "$\BASE/haproxy.cfg" << EOF
    global
        stats socket /var/run/api.sock user haproxy group haproxy mode 660 level admin expose-fd listeners
        log stdout format raw local0 info
        maxconn 5000
    resolvers docker_resolver
        nameserver dns 127.0.0.11:53
    defaults
        mode http
        timeout client 10s
        timeout connect 5s
        timeout server 10s
        timeout http-request 10s
        default-server init-addr none
        log global
    frontend stats
        bind *:8404
        stats enable
        stats uri /
        stats refresh 10s
    frontend localhost
        bind *:80
        bind *:443 ssl crt /etc/ssl/guacamole/server.pem 
        redirect scheme https if !{ ssl_fc }
        mode http
        default_backend guacamole
    backend guacamole
        server guacamole guacamole:8080 check inter 10s resolvers docker_resolver
EOF
o "Creating nginx configuration"
cat > "\$BASE/nginx.conf" << 'EOF'
    server {
        location / {
            auth_basic "Restricted Access";
            auth_basic_user_file /etc/nginx/.htpasswd;
            proxy_pass http://guacamole:8080;
            proxy_buffering off;
            proxy_http_version 1.1;
            proxy_set_header X-Forwarded-For \$proxy_add_x_forwarded_for;
            proxy_set_header Upgrade \$http_upgrade;
            proxy_set_header Connection \$http_connection;
            client_max_body_size 1g;
            access_log off;
        }
    }
EOF
o "Creating .htpasswd file for the user \$GM_NG_USER"
htpasswd -bc "\$HTPASS" "\$GM_NG_USER" "\$GM_NG_PASS"
o "Creating file \$CHECK to lock the setup next time"
touch "\$CHECK"
o "You should create a passwd file if using "
SCRIPT

CMD [ "bash", "start.sh" ]
