
# serveur-web-secure

## 🎯 Objectif
Installer et configurer Nginx sur Ubuntu, sécuriser le site avec HTTPS via Let's Encrypt, et documenter les étapes.

## 🛠️ Tecnologies
- Ubuntu 20.04/22.04
- Nginx
- Certbot (Let's Encrypt)
- UFW (firewall)

## 🚀 Étapes (résumé)
1. Installer Nginx
2. Configurer les virtual hosts
3. Ouvrir le firewall (UFW)
4. Obtenir un certificat avec Certbot
5. Vérifier la redirection HTTP -> HTTPS

## 📂 Contenu du dépôt
- `install-nginx.sh` — script d'installation automatique 
- `nginx.conf.example` — extrait de config
- `docs/` — captures d'écran et notes

## 🧪 Usage du script
```bash
# rendre exécutable
chmod +x install-nginx.sh

# Exemple d'utilisation (remplacer example.com par ton domaine)
./install-nginx.sh example.com
