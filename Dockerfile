# syntax=docker/dockerfile:1
FROM alpine

RUN apk update \
 && apk add bash

WORKDIR /app

# SCRIPT
COPY <<-SCRIPT start.sh
# Variables
BASE="./data"
DB="\$BASE/db"
GUACA="\$BASE/guacamole"
LIB="\$GUACA/lib"
EXTENSIONS="\$GUACA/extensions"
PROPERTIES="\$GUACA/guacamole.properties"
CHECK="\$BASE/.deployed"
DOWNLOAD="\$BASE/download"
AUTH_GZ="\$DOWNLOAD/auth-\$GM_VERSION.tar.gz"
MFA_GZ="\$DOWNLOAD/\$GM_MFA-\$GM_VERSION.tar.gz"
CON_GZ="\$DOWNLOAD/mysql-connector-java-8.0.28.tar.gz"
# Fuctions
o() { echo "==> \$1"; }
e() { echo "==> ERR: \$1!"; exit \$2; }
z() { echo "==> Extracting \$1..."; tar -xf "\$1" -C "\$DOWNLOAD"; }
# Check if it was installed before
if [ -f "\$CHECK" ]; then
    o "Guacamole deployed already on version \$GM_VERSION."
    o "To redeploy it, please, remove the \$CHECK file (all data will be erased)"
    exit 0
fi
# Check environment
for i in VERSION DB DB_NAME DB_USER DB_PASS MFA; do
    [ "\$(printenv GM_\$i)x" == "x" ] && e "\GM_\$i not found" 1
done
# Clean old instalation
o "Cleaning old instalation"
rm -rf "\$DB*" "\$EXTENSIONS" "\$LIB" || e "remove old data failed" 2
# Ensure dir are created
o "Creating data structure"
mkdir -p "\$DB" "\$EXTENSIONS" "\$LIB" "\$DOWNLOAD" || e "create data dir failed" 3
# Download and unpack extensions
## MFA
if [ "\$MFA" != "false" ]; then
    if [ -f "\$MFA_GZ" ]; then 
        o "File \$MFA_GZ downloaded already"
    else
    URL="\$GM_URL/binary/guacamole-auth-\$GM_MFA-\$GM_VERSION.tar.gz"
    wget "\$URL" -O "\$MFA_GZ" || e "download \$URL failed" 4
    fi
    z "\$MFA_GZ"
fi
## AUTH
if [ -f "\$AUTH_GZ" ]; then 
    o "File \$AUTH_GZ downloaded already"
else
    URL="\$GM_URL/binary/guacamole-auth-jdbc-\$GM_VERSION.tar.gz"
    wget "\$URL" -O "\$AUTH_GZ" || e "download \$URL failed" 5
fi
z "\$AUTH_GZ"
## CONNECTOR
if [ -f "\$CON_GZ" ]; then 
    o "File \$CON_GZ downloaded already"
else
    URL="https://dev.mysql.com/get/Downloads/Connector-J/\$CON_GZ"
    wget "\$URL" -O "\$CON_GZ" || e "download \$URL failed" 6
fi
z "\$CON_GZ"
# Copy JAR to the extensions folder
for JAR in $(find \$DOWNLOAD -name "*.jar" | grep -e "\$GM_DB" -e "\$GM_MFA"); do
    o "Copying \$JAR to \$EXTENSIONS..."
    cp "\$JAR" "\$EXTENSIONS"
done
# Move connector to the right place
mv "\$CON_GZ" "\$LIB"
# Create property file
o "Creating \$PROPERTIES"
cat > \$PROPERTIES << EOF
\$GM_DB-hostname: db
\$GM_DB-port: 3306
\$GM_DB-database: \$GM_DB_NAME
\$GM_DB-username: \$GM_DB_USER
\$GM_DB-password: \$GM_DB_PASS
EOF
# Create a file to indicate installation is done
touch "\$CHECK"
SCRIPT

CMD [ "bash", "start.sh" ]

