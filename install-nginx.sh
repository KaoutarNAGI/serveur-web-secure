
---

## `install-nginx.sh` (script complet — accepte domaine + email; mode `--self-signed` pour tests locaux)
```bash
#!/usr/bin/env bash
set -euo pipefail

usage() {
  cat <<EOF
Usage:
  sudo $0 <domain> <email|--self-signed>
Examples:
  sudo $0 example.com ton.email@example.com
  sudo $0 example.local --self-signed
EOF
}

if [ "$#" -lt 2 ]; then
  usage
  exit 1
fi

DOMAIN="$1"
EMAIL="$2"

if [ "$(id -u)" -ne 0 ]; then
  echo "Exécutez ce script en root (sudo)"
  exit 1
fi

echo "=== Mise à jour et installation des paquets ==="
apt update
apt install -y nginx ufw curl

# Création racine web
WEBROOT="/var/www/${DOMAIN}"
mkdir -p "${WEBROOT}"
chown -R www-data:www-data "${WEBROOT}"
chmod -R 755 "${WEBROOT}"

# Fichier index de démonstration
cat > "${WEBROOT}/index.html" <<HTML
<!doctype html>
<html>
  <head><meta charset="utf-8"><title>${DOMAIN}</title></head>
  <body>
    <h1>Site de test pour ${DOMAIN}</h1>
    <p>Déployé et sécurisé via <strong>install-nginx.sh</strong>.</p>
  </body>
</html>
HTML

# Configuration Nginx (HTTP)
SITES_AVAILABLE="/etc/nginx/sites-available"
CONF_FILE="${SITES_AVAILABLE}/${DOMAIN}.conf"

cat > "${CONF_FILE}" <<NGINX
server {
    listen 80;
    server_name ${DOMAIN} www.${DOMAIN};
    root ${WEBROOT};
    index index.html;

    location / {
        try_files \$uri \$uri/ =404;
    }
}
NGINX

ln -sf "${CONF_FILE}" /etc/nginx/sites-enabled/${DOMAIN}.conf

echo "=== Test configuration Nginx ==="
nginx -t
systemctl reload nginx

# Firewall
ufw allow OpenSSH
ufw allow 'Nginx Full'
ufw --force enable

# TLS
if [ "${EMAIL}" = "--self-signed" ]; then
  echo "=== Création d'un certificat auto-signé (test local) ==="
  CERT_DIR="/etc/ssl/local/${DOMAIN}"
  mkdir -p "${CERT_DIR}"
  openssl req -x509 -nodes -days 365 -newkey rsa:2048 \
    -keyout "${CERT_DIR}/${DOMAIN}.key" \
    -out "${CERT_DIR}/${DOMAIN}.crt" \
    -subj "/CN=${DOMAIN}"
  # Mise à jour de la conf pour SSL
  cat > "${CONF_FILE}" <<NGINXSSL
server {
    listen 80;
    server_name ${DOMAIN} www.${DOMAIN};
    return 301 https://\$host\$request_uri;
}
server {
    listen 443 ssl;
    server_name ${DOMAIN} www.${DOMAIN};
    root ${WEBROOT};
    index index.html;

    ssl_certificate ${CERT_DIR}/${DOMAIN}.crt;
    ssl_certificate_key ${CERT_DIR}/${DOMAIN}.key;
    ssl_protocols TLSv1.2 TLSv1.3;
    ssl_prefer_server_ciphers on;

    location / {
        try_files \$uri \$uri/ =404;
    }
}
NGINXSSL
  nginx -t && systemctl reload nginx
  echo "Site disponible en HTTPS (certificat auto-signé). Pour éviter l'avertissement, ajoutez une exception dans votre navigateur ou installez le certificat localement."
else
  # Tentative d'obtenir un certificat Let's Encrypt via certbot
  echo "=== Installation de Certbot ==="
  apt install -y certbot python3-certbot-nginx
  echo "=== Demande du certificat Let's Encrypt ==="
  certbot --nginx -d "${DOMAIN}" -d "www.${DOMAIN}" --non-interactive --agree-tos --email "${EMAIL}" || {
    echo "Certbot a échoué (vérifier DNS). Vous pouvez relancer le script après avoir pointé le domaine."
    exit 0
  }
fi

echo "=== Terminé ==="
echo "Pointage: https://${DOMAIN} (vérifier DNS si certificat réel)"

