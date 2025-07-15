# SMTP CTF Lab Template - Guide de Customisation

## 🎯 Vue d'Ensemble

Ce template fournit une base complète pour créer vos propres challenges CTF basés sur le protocole SMTP. Toutes les configurations peuvent être personnalisées selon vos besoins pédagogiques.

## 🔧 Customisation des Flags

### 1. Remplacer les Placeholders

Le template contient des placeholders qu'il faut remplacer :

```
CTF{PLACEHOLDER_WELCOME_FLAG}     → Votre flag de bienvenue
CTF{PLACEHOLDER_ADMIN_FLAG}       → Votre flag admin
CTF{PLACEHOLDER_MAIN_FLAG}        → Votre flag principal
CTF{PLACEHOLDER_HIDDEN_FLAG}      → Votre flag caché
```

### 2. Modifier les Emails CTF

**Fichier à éditer :** `build/Dockerfile`

Cherchez les sections `COPY --chown=ctf:ctf <<EOF` et remplacez :

```dockerfile
# Exemple de customisation
COPY --chown=ctf:ctf <<EOF /home/ctf/smtp/mailbox/inbox/welcome.eml
From: admin@yourdomain.local
To: participant@yourdomain.local
Subject: Welcome to Your CTF Challenge
Date: $(date -R)
X-CTF-Flag: CTF{your_welcome_flag_here}
X-CTF-Hint: Your custom hint here

Your custom welcome message for the CTF challenge.
EOF
```

## 🔐 Customisation de l'Authentification

### 1. Modifier les Utilisateurs

**Fichier :** `build/smtp_server.py`

```python
# Changez les credentials par défaut
USERS = {
    'votre_user': 'votre_password',
    'challenge_admin': 'admin_super_secret',
    'participant': 'participant_pass'
}
```

### 2. Domaines Autorisés

```python
# Modifiez les domaines pour votre scénario
ALLOWED_DOMAINS = ['votre-domaine.local', 'challenge.ctf', 'target.corp']
```

## 🌐 Configuration Réseau

### 1. Changer le Port SMTP

**Fichier :** `deploy/docker-compose.yml`

```yaml
ports:
  - "2525:25"  # Utiliser le port 2525 au lieu de 25
```

**Fichier :** `build/smtp_server.py`

```python
SMTP_PORT = 25  # Changez selon vos besoins
```

### 2. Modifier le Réseau Docker

```yaml
networks:
  your-ctf-network:
    driver: bridge
    ipam:
      config:
        - subnet: 172.30.0.0/16  # Votre subnet personnalisé
```

## 🎨 Customisation de la Bannière

**Fichier :** `build/welcome_banner.txt`

Remplacez le contenu par votre propre ASCII art :

```
  ██╗   ██╗ ██████╗ ██╗   ██╗██████╗      ██████╗████████╗███████╗
  ╚██╗ ██╔╝██╔═══██╗██║   ██║██╔══██╗    ██╔════╝╚══██╔══╝██╔════╝
   ╚████╔╝ ██║   ██║██║   ██║██████╔╝    ██║        ██║   █████╗  
    ╚██╔╝  ██║   ██║██║   ██║██╔══██╗    ██║        ██║   ██╔══╝  
     ██║   ╚██████╔╝╚██████╔╝██║  ██║    ╚██████╗   ██║   ██║     
     ╚═╝    ╚═════╝  ╚═════╝ ╚═╝  ╚═╝     ╚═════╝   ╚═╝   ╚═╝     
                                                                   
                    YOUR CTF NAME HERE
```

## 🛡️ Configuration des Vulnérabilités

### 1. Activer/Désactiver VRFY

**Fichier :** `build/smtp_server.py`

```python
def handle_command(self, session, line):
    # ...
    elif command == 'VRFY':
        if ENABLE_VRFY_VULNERABILITY:  # Ajoutez cette variable
            # Code VRFY existant
        else:
            session.send_response(502, "VRFY command disabled")
```

### 2. Configurer l'Open Relay

```python
# Configuration du relay
RELAY_MODE = "selective"  # "none", "selective", "open"

def handle_rcpt_command(self, session, recipient):
    if RELAY_MODE == "none":
        # Pas de relay
    elif RELAY_MODE == "selective":
        # Relay pour domaines spécifiques
    elif RELAY_MODE == "open":
        # Open relay complet (dangereux, à utiliser avec précaution)
```

## 📧 Types de Challenges Suggérés

### 1. Challenge d'Énumération

```python
# Permettre l'énumération mais avec des indices subtils
def handle_vrfy(self, session, user):
    if user in REAL_USERS:
        session.send_response(250, f"{user}@yourdomain.local")
    elif user in HINT_USERS:
        session.send_response(250, f"User {user} exists but check spelling")
    else:
        session.send_response(550, "User unknown")
```

### 2. Challenge d'Authentification

```python
# Bypass d'authentification pour certains scénarios
def handle_auth(self, session, args):
    # Ajouter des bypass spécifiques pour les challenges
    if args.startswith("BYPASS") and session.client_ip in CHALLENGE_IPS:
        session.authenticated = True
        session.send_response(235, "Challenge bypass activated")
        return
    # Code d'auth normal...
```

### 3. Challenge de Header Injection

```python
def handle_data_end(self, session):
    # Permettre certaines injections pour les challenges
    message_content = '\r\n'.join(session.message_data)
    
    # Ajouter validation selon le niveau de challenge
    if ALLOW_HEADER_INJECTION:
        # Processing avec vulnérabilités intentionnelles
        pass
```

## 🔄 Script de Déploiement Personnalisé

Créez votre propre script de déploiement :

**Fichier :** `deploy/deploy-your-ctf.sh`

```bash
#!/bin/bash

echo "Deploying Your Custom SMTP CTF..."

# Variables personnalisées
export CTF_NAME="Your CTF Name"
export SMTP_DOMAIN="your-challenge.ctf"
export CTF_FLAGS_PREFIX="YOURCTF"

# Remplacer les placeholders
sed -i "s/PLACEHOLDER_WELCOME_FLAG/${CTF_FLAGS_PREFIX}{welcome_to_smtp}/g" ../build/Dockerfile
sed -i "s/PLACEHOLDER_ADMIN_FLAG/${CTF_FLAGS_PREFIX}{admin_access_gained}/g" ../build/Dockerfile
sed -i "s/PLACEHOLDER_MAIN_FLAG/${CTF_FLAGS_PREFIX}{smtp_challenge_complete}/g" ../build/Dockerfile
sed -i "s/PLACEHOLDER_HIDDEN_FLAG/${CTF_FLAGS_PREFIX}{hidden_data_found}/g" ../build/Dockerfile

# Déployer
docker-compose down -v
docker-compose build --no-cache
docker-compose up -d

echo "Your SMTP CTF is ready!"
```

## 📋 Checklist de Customisation

### Avant le Déploiement
- [ ] Remplacer tous les placeholders `CTF{PLACEHOLDER_*}`
- [ ] Modifier les credentials par défaut
- [ ] Personnaliser les domaines autorisés
- [ ] Adapter la bannière d'accueil
- [ ] Configurer les vulnérabilités selon le niveau
- [ ] Tester les emails personnalisés
- [ ] Vérifier la configuration réseau

### Après le Déploiement
- [ ] Tester toutes les commandes SMTP
- [ ] Vérifier l'authentification personnalisée
- [ ] Valider les flags dans les emails
- [ ] Tester les challenges avec les participants
- [ ] Monitorer les logs pour les erreurs

## 🎯 Exemples de Scénarios CTF

### Scénario 1 : Corporate Email Server
- Domaines : `corp.local`, `mail.corp.local`
- Challenge : Accès non autorisé au serveur mail corporate
- Flags : Dans emails internes "confidentiels"

### Scénario 2 : Open Relay Exploitation
- Configuration : Open relay activé pour certains domaines
- Challenge : Exploiter le relay pour envoyer des emails
- Flag : Réception confirmée d'email via relay

### Scénario 3 : Credential Stuffing
- Users : Liste d'utilisateurs avec mots de passe faibles
- Challenge : Bruteforce ou dictionnaire
- Flag : Accès compte privilégié

## 🔗 Ressources Supplémentaires

- [SMTP RFC 5321](https://tools.ietf.org/html/rfc5321)
- [Email Header Injection](https://owasp.org/www-community/attacks/HTTP_Response_Splitting)
- [SMTP Security Best Practices](https://www.cyber.gov.au/acsc/view-all-content/advice/email-security)

---

**Note :** Ce template est conçu pour l'éducation et les CTF. Assurez-vous que vos customisations maintiennent un environnement d'apprentissage sécurisé et contrôlé. 