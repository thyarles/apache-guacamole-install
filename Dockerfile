# syntax=docker/dockerfile:1
FROM guacamole/guacamole:${GM_VERSION:-1.5.1}

# SCRIPT
COPY <<-SCRIPT start.sh
    # Variables
    BASE="/data"
    SCHEMA="\$BASE/schema.sql"
    EXTENSIONS="\$BASE/extensions"
    CHECK="\$BASE/.deployed"
    # Functions
    o() { echo "==> \$1"; }
    e() { echo "==> ERR: \$1!"; exit \$2; }
    # Check environment
    for i in VERSION DB DB_NAME DB_USER DB_PASS MFA; do
        [ "\$(printenv GM_\$i)x" == "x" ] && e "\GM_\$i not found. You should have a .env (copy from .env-example)" 1
    done
    # Check if it was installed before
    if [ -f "\$CHECK" ]; then
        o "Guacamole deployed already on version \$GM_VERSION."
        o "To redeploy it, please, remove the \$CHECK file (all data will be erased)"
        exit 0
    fi
    o "Cleaning \$EXTENSIONS folder"
    rm -rf "\$EXTENSIONS" || e "remove extensions failed" 2
    mkdir -p "\$EXTENSIONS" || e "create extensions failed" 3
    # Download and unpack extensions
    [ "\$GM_MFA" == "totp" ] && o "Copying TOTP..." && cp totp/*.jar "\$EXTENSIONS"
    [ "\$GM_MFA" == "duo" ] && o "Copying DUO..." && cp duo/*.jar "\$EXTENSIONS"
    o "Copying SQL schema"
    /opt/guacamole/bin/initdb.sh --mysql > "\$SCHEMA"
    o "Creating file \$CHECK to lock the setup next time"
    touch "\$CHECK"
SCRIPT

USER root

CMD [ "bash", "start.sh" ]
