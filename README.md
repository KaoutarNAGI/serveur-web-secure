# serveur-web-secure
Déploiement d'un serveur Nginx sécurisé (HTTPS) — script d'installation + documentation

## 🎯 Objectif
Installer et configurer Nginx sur Ubuntu, sécuriser le site avec HTTPS (Let's Encrypt) et documenter la démarche pour démontrer des compétences d'administration système.

## 📦 Contenu du dépôt
- `install-nginx.sh` — script d'installation & configuration (domain, email)
- `nginx.site.conf.example` — exemple de virtual host Nginx
- `www/index.html` — page de démonstration
- `docs/` — captures d'écran et notes
- `.github/workflows/ci.yml` — CI basique (ShellCheck)

## ⚙️ Pré-requis
- VM Ubuntu 
- Accès root / sudo
- (Optionnel si certif réel) un nom de domaine pointant vers l'IP publique du serveur

## 🚀 Mode d'emploi (rapide)
1. Cloner le repo sur la VM.
2. Rendre le script exécutable : `chmod +x install-nginx.sh`
3. Lancer (avec domaine réel) :
   ```bash
   sudo ./install-nginx.sh example.com ton.email@example.com
