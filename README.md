# 📧 SMTP CTF Lab Template

> **Template pour créer des challenges CTF basés sur le protocole SMTP**

Un template de serveur SMTP éducatif containerisé, prêt à personnaliser pour vos propres challenges CTF et formations en cybersécurité. **Ce template contient des placeholders à remplacer par vos propres flags et configurations.**

[![Docker](https://img.shields.io/badge/Docker-Ready-blue?logo=docker)](https://www.docker.com/)
[![Python](https://img.shields.io/badge/Python-3.11-green?logo=python)](https://python.org/)
[![SMTP](https://img.shields.io/badge/Protocol-SMTP-orange)](https://tools.ietf.org/html/rfc5321)
[![CTF](https://img.shields.io/badge/Type-CTF%20Lab-red)](https://en.wikipedia.org/wiki/Capture_the_flag)

## 🎯 Objectif

Ce **template** vous permet de créer rapidement vos propres challenges CTF basés sur le protocole SMTP. Basé sur le succès des templates FTP/SSH/Telnet précédents, il fournit une base technique complète que vous pouvez personnaliser selon vos besoins pédagogiques.

**⚠️ IMPORTANT :** Ce template contient des placeholders (`CTF{PLACEHOLDER_*}`) qui doivent être remplacés par vos propres flags et contenus avant utilisation.

### 🎓 Compétences Développées

- **Protocole SMTP** : Maîtrise des commandes et du flux SMTP
- **Email Security** : Vulnérabilités et techniques de sécurisation
- **Relay Testing** : Configuration et exploitation des relays
- **Authentication** : Mécanismes d'authentification SMTP
- **Header Analysis** : Analyse et manipulation des headers
- **Email Spoofing** : Techniques de spoofing et détection

## 🚀 Installation Rapide

### Prérequis

- [Docker](https://docs.docker.com/get-docker/) et [Docker Compose](https://docs.docker.com/compose/install/)
- Port 25 disponible (ou modification dans la configuration)

### Démarrage en Une Commande

```bash
# Cloner le repository
git clone <repository-url>
cd template-smtp

# Créer les répertoires de données
mkdir -p deploy/data/{mailbox,logs}

# Démarrer le lab
cd deploy
docker-compose up -d
```

### Vérification

```bash
# Vérifier que le conteneur fonctionne
docker-compose ps

# Tester la connexion SMTP
telnet localhost 25
```

## 📋 Utilisation

### Connexion Basique

```bash
# Connexion avec telnet
telnet localhost 25

# Ou avec netcat
nc localhost 25
```

### Session SMTP Exemple

```
220 CTF SMTP Lab Ready - Python SMTP Server v1.0
HELO test.com
250 Hello test.com
MAIL FROM: <sender@test.com>
250 OK
RCPT TO: <recipient@ctf.local>
250 OK
DATA
354 End data with <CR><LF>.<CR><LF>
Subject: Test Email CTF
From: sender@test.com
To: recipient@ctf.local

Hello from SMTP CTF Lab!
.
250 Message accepted for delivery
QUIT
221 Bye
```

### 🔐 Credentials par Défaut

| Utilisateur | Mot de passe | Permissions |
|-------------|--------------|-------------|
| `ctf` | `ctf_password_2024` | Utilisateur principal |
| `admin` | `admin123` | Administrateur |
| `test` | `test` | Test limité |

### 🌐 Domaines Autorisés

- `ctf.local` - Domaine principal
- `test.com` - Domaine de test  
- `example.org` - Domaine d'exemple

## 🏗️ Customisation du Template

### 🔧 **Étapes de Personnalisation**

1. **Remplacer les Flags Placeholders**
   ```bash
   # Dans build/Dockerfile, remplacez :
   CTF{PLACEHOLDER_WELCOME_FLAG} → CTF{your_welcome_flag}
   CTF{PLACEHOLDER_ADMIN_FLAG} → CTF{your_admin_flag}
   CTF{PLACEHOLDER_MAIN_FLAG} → CTF{your_main_flag}
   CTF{PLACEHOLDER_HIDDEN_FLAG} → CTF{your_hidden_flag}
   ```

2. **Modifier les Credentials**
   ```python
   # Dans build/smtp_server.py
   USERS = {
       'your_user': 'your_password',
       'admin': 'your_admin_pass'
   }
   ```

3. **Personnaliser les Domaines**
   ```python
   # Dans build/smtp_server.py
   ALLOWED_DOMAINS = ['your-domain.local', 'challenge.ctf']
   ```

4. **Adapter les Emails CTF**
   - Modifiez le contenu des emails dans `build/Dockerfile`
   - Ajoutez vos propres indices et challenges

### 📋 **Types de Challenges Suggérés**

- **Énumération** : Découverte d'utilisateurs via `VRFY`
- **Authentification** : Bruteforce ou bypass d'auth
- **Relay Testing** : Exploitation de configuration open relay
- **Header Injection** : Injection dans les headers email
- **Email Spoofing** : Usurpation d'identité d'expéditeur
- **Analyse de Données** : Décodage Base64 et analyse headers

### 📖 **Documentation Complète**

- **`docs/customization.md`** - Guide détaillé de personnalisation
- **`docs/usage.md`** - Commandes SMTP et utilisation
- **`docs/credentials.md`** - Configuration sécurité par défaut

## 🛠️ Configuration

### Variables d'Environnement

Copiez `deploy/env.example` vers `deploy/.env` et modifiez selon vos besoins :

```bash
cp deploy/env.example deploy/.env
# Editez .env avec vos paramètres
```

### Personnalisation

#### Modifier les Credentials

```python
# Dans build/smtp_server.py
USERS = {
    'votre_user': 'votre_password',
    'admin': 'nouveau_admin_pass'
}
```

#### Changer les Domaines Autorisés

```python
# Dans build/smtp_server.py
ALLOWED_DOMAINS = ['votre-domaine.local', 'test.org']
```

#### Personnaliser la Bannière

```bash
# Modifier build/welcome_banner.txt
```

### Reconstruction

```bash
# Après modification
docker-compose down
docker-compose build --no-cache
docker-compose up -d
```

## 🧪 Tests

### Script de Test Automatisé

```bash
# Lancer tous les tests
./test/check_smtp.sh

# Tests rapides seulement
./test/check_smtp.sh --quick

# Aide
./test/check_smtp.sh --help
```

### Tests Manuels

```bash
# Test de connectivité
nc -z localhost 25

# Test d'authentification
echo -e "EHLO test.com\r\nAUTH LOGIN Y3Rm\r\nY3RmX3Bhc3N3b3JkXzIwMjQ=\r\nQUIT" | nc localhost 25

# Test de relay
echo -e "HELO test.com\r\nMAIL FROM: <test@test.com>\r\nRCPT TO: <user@ctf.local>\r\nQUIT" | nc localhost 25
```

## 📁 Structure du Projet

```
template-smtp/
├── build/                    # Code et fichiers de l'application
│   ├── Dockerfile           # Image Docker du serveur SMTP
│   ├── smtp_server.py       # Serveur SMTP Python principal
│   ├── setup.sh             # Script de configuration
│   └── welcome_banner.txt   # Bannière d'accueil
├── deploy/                   # Fichiers de déploiement
│   ├── docker-compose.yml   # Configuration Docker Compose
│   └── env.example          # Variables d'environnement
├── test/                     # Scripts de test
│   ├── check_smtp.sh        # Suite de tests automatisés
│   └── .gitkeep             
├── docs/                     # Documentation
│   ├── usage.md             # Guide d'utilisation détaillé
│   ├── credentials.md       # Documentation des credentials
│   └── .gitkeep
├── README.md                # Ce fichier
└── .gitignore               # Fichiers à ignorer
```

## 🔧 Commandes SMTP Supportées

| Commande | Description | Exemple |
|----------|-------------|---------|
| `HELO` | Identification client | `HELO domain.com` |
| `EHLO` | Identification étendue | `EHLO domain.com` |
| `MAIL FROM` | Définir expéditeur | `MAIL FROM: <user@domain.com>` |
| `RCPT TO` | Définir destinataire | `RCPT TO: <dest@domain.com>` |
| `DATA` | Contenu du message | `DATA` → message → `.` |
| `AUTH LOGIN` | Authentification | `AUTH LOGIN` → base64 creds |
| `AUTH PLAIN` | Auth alternative | `AUTH PLAIN <base64-creds>` |
| `VRFY` | Vérifier utilisateur | `VRFY username` |
| `RSET` | Reset session | `RSET` |
| `QUIT` | Fermer connexion | `QUIT` |
| `HELP` | Aide | `HELP` |

## 🛡️ Sécurité et Vulnérabilités

### ⚠️ Vulnérabilités Éducatives

- **Open Relay Partiel** : Relay autorisé pour certains domaines
- **Énumération Users** : `VRFY` révèle les utilisateurs
- **Info Disclosure** : Bannière et erreurs verbeuses
- **Weak Auth** : Credentials prévisibles
- **Header Injection** : Validation faible des headers

### 🔒 Protections Implémentées

- **Limites de connexion** : Max 10 connexions, 3 par IP
- **Timeout sessions** : 300 secondes d'inactivité
- **Taille limite** : Messages limités à 1MB
- **Validation basique** : Vérification syntaxe SMTP
- **Logging complet** : Toutes les actions loggées

## 📊 Monitoring

### Logs en Temps Réel

```bash
# Logs du conteneur
docker-compose logs -f smtp-ctf-lab

# Logs SMTP internes
docker exec smtp-ctf-lab tail -f /home/ctf/smtp/smtp.log
```

### Mailbox

```bash
# Consulter les emails reçus
docker exec smtp-ctf-lab ls -la /home/ctf/smtp/mailbox/inbox/

# Lire un email
docker exec smtp-ctf-lab cat /home/ctf/smtp/mailbox/inbox/welcome.eml
```

### Statistiques

```bash
# Nombre de connexions
docker exec smtp-ctf-lab grep -c "New connection" /home/ctf/smtp/smtp.log

# Emails reçus
docker exec smtp-ctf-lab ls /home/ctf/smtp/mailbox/inbox/*.eml | wc -l

# Tentatives d'auth
docker exec smtp-ctf-lab grep "authentication" /home/ctf/smtp/smtp.log
```

## 🚨 Résolution de Problèmes

### Problèmes Courants

#### Port 25 Occupé
```bash
# Vérifier qui utilise le port 25
sudo lsof -i :25

# Modifier le port dans docker-compose.yml
ports:
  - "2525:25"  # Utiliser le port 2525 à la place
```

#### Permission Denied
```bash
# Vérifier les permissions Docker
sudo docker-compose up -d

# Ou ajouter l'utilisateur au groupe docker
sudo usermod -aG docker $USER
```

#### Conteneur ne Démarre Pas
```bash
# Vérifier les logs d'erreur
docker-compose logs smtp-ctf-lab

# Reconstruire l'image
docker-compose build --no-cache
```

#### Emails Non Sauvegardés
```bash
# Vérifier les volumes
docker volume ls

# Vérifier les permissions
docker exec smtp-ctf-lab ls -la /home/ctf/smtp/mailbox/
```

### Réinitialisation

#### Reset Rapide
```bash
# Redémarrer le service
docker-compose restart smtp-ctf-lab

# Vider les logs
docker exec smtp-ctf-lab sh -c "> /home/ctf/smtp/smtp.log"
```

#### Reset Complet
```bash
# Tout supprimer et recommencer
docker-compose down -v
docker-compose up -d --force-recreate
```

## 🔗 Ressources Externes

### Documentation SMTP
- [RFC 5321 - SMTP Protocol](https://tools.ietf.org/html/rfc5321)
- [RFC 4954 - SMTP Authentication](https://tools.ietf.org/html/rfc4954)
- [IANA SMTP Parameters](https://www.iana.org/assignments/mail-parameters/)

### Outils Utiles
- [SMTP Test Tools](https://mxtoolbox.com/smtp-test)
- [Base64 Encoder/Decoder](https://www.base64encode.org/)
- [Email Header Analyzer](https://mxtoolbox.com/EmailHeaders.aspx)

### Sécurité Email
- [OWASP Email Security](https://owasp.org/www-community/controls/Email_Security)
- [Email Spoofing Techniques](https://www.microsoft.com/en-us/security/blog/tag/email-spoofing/)

## 🤝 Contribution

### Signaler un Bug
1. Vérifiez les [issues existantes](../../issues)
2. Créez une nouvelle issue avec:
   - Description du problème
   - Étapes de reproduction
   - Logs d'erreur
   - Environnement (OS, Docker version)

### Proposer une Amélioration
1. Fork le repository
2. Créez une branche feature (`git checkout -b feature/nouvelle-fonctionnalite`)
3. Commitez vos changements (`git commit -am 'Ajout nouvelle fonctionnalité'`)
4. Push vers la branche (`git push origin feature/nouvelle-fonctionnalite`)
5. Créez une Pull Request

### Guidelines
- Respectez la structure existante
- Testez vos modifications avec `./test/check_smtp.sh`
- Documentez les nouvelles fonctionnalités
- Maintenez la compatibilité CTF

## 📜 Licence

Ce projet est sous licence MIT. Voir le fichier [LICENSE](LICENSE) pour plus de détails.

## ⚠️ Avertissement de Sécurité

**⚠️ IMPORTANT ⚠️**

Ce laboratoire contient des vulnérabilités intentionnelles et des configurations non sécurisées à des fins éducatives. 

**NE JAMAIS utiliser en production !**

- Les mots de passe par défaut sont faibles
- L'open relay est activé pour certains domaines
- Les informations sensibles sont exposées
- Aucune protection contre les attaques

Utilisez uniquement dans un environnement isolé pour l'apprentissage et les CTF.

## 📞 Support

- **Documentation** : Consultez les fichiers dans `/docs/`
- **Issues** : [GitHub Issues](../../issues)
- **Tests** : Lancez `./test/check_smtp.sh` pour diagnostiquer
- **Logs** : `docker-compose logs smtp-ctf-lab`

---

**🎯 Objectif CTF Atteint :** Un lab SMTP 100% fonctionnel, prêt pour l'apprentissage de la sécurité des emails ! 📧🔐 