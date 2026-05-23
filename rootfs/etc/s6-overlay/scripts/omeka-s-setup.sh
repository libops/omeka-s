#!/command/with-contenv bash
# shellcheck shell=bash

set -eou pipefail

function mysql_create_database {
    cat <<-SQL | create-database.sh
CREATE DATABASE IF NOT EXISTS ${DB_NAME} CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
CREATE USER IF NOT EXISTS '${DB_USER}'@'%' IDENTIFIED BY '${DB_PASSWORD}';
GRANT ALL PRIVILEGES ON ${DB_NAME}.* to '${DB_USER}'@'%';
FLUSH PRIVILEGES;
SET PASSWORD FOR ${DB_USER}@'%' = PASSWORD('${DB_PASSWORD}');
SQL
}

function wait_for_database {
    local attempts=0
    until mysql -h"${DB_HOST}" -u"${DB_USER}" -p"${DB_PASSWORD}" "${DB_NAME}" -e 'SELECT 1' >/dev/null 2>&1; do
        attempts=$((attempts + 1))
        if [ "$attempts" -ge 60 ]; then
            echo "Database was not ready in time"
            exit 1
        fi
        sleep 2
    done
}

function check_installed {
    mysql -h"${DB_HOST}" -u"${DB_USER}" -p"${DB_PASSWORD}" "${DB_NAME}" \
        -e "SELECT 1 FROM \`user\` LIMIT 1" >/dev/null 2>&1
}

function install_omeka {
    if check_installed; then
        echo "Omeka S is already installed."
        return 0
    fi

    timeout 300 wait-for-open-port.sh localhost 80
    curl -fsS -d "user[email]=${OMEKA_S_ADMIN_EMAIL}" \
        -d "user[email-confirm]=${OMEKA_S_ADMIN_EMAIL}" \
        -d "user[name]=${OMEKA_S_ADMIN_NAME}" \
        -d "user[password-confirm][password]=${OMEKA_S_ADMIN_PASSWORD}" \
        -d "user[password-confirm][password-confirm]=${OMEKA_S_ADMIN_PASSWORD}" \
        -d "settings[installation_title]=${OMEKA_S_SITE_TITLE}" \
        -d "settings[time_zone]=${OMEKA_S_TIME_ZONE}" \
        -d "settings[locale]=${OMEKA_S_LOCALE}" \
        -d "submit=Submit" \
        http://localhost/install >/tmp/omeka-s-install.log 2>&1 || {
            cat /tmp/omeka-s-install.log
            exit 1
        }
}

function main {
    if [ "${DB_HOST}" = "mariadb" ]; then
        mysql_create_database
    fi
    wait_for_database
    install_omeka
    touch /installed
}

main
