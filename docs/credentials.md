# SMTP CTF Lab - Credentials et Configuration

## 🔐 Comptes Utilisateurs

### Utilisateur Principal CTF
- **Nom d'utilisateur :** `ctf`
- **Mot de passe :** `ctf_password_2024`
- **Description :** Compte principal pour les challenges CTF
- **Permissions :** Accès complet, relay autorisé
- **Encodage Base64 :**
  - Username: `Y3Rm`
  - Password: `Y3RmX3Bhc3N3b3JkXzIwMjQ=`

### Compte Administrateur
- **Nom d'utilisateur :** `admin`
- **Mot de passe :** `admin123`
- **Description :** Compte administrateur avec privilèges élevés
- **Permissions :** Accès administratif, relay global
- **Encodage Base64 :**
  - Username: `YWRtaW4=`
  - Password: `YWRtaW4xMjM=`

### Compte de Test
- **Nom d'utilisateur :** `test`
- **Mot de passe :** `test`
- **Description :** Compte de test pour expérimentations
- **Permissions :** Accès limité, relay restreint
- **Encodage Base64 :**
  - Username: `dGVzdA==`
  - Password: `dGVzdA==`

## 🌐 Configuration des Domaines

### Domaines Autorisés pour Relay (sans authentification)
1. **ctf.local**
   - Domaine principal du laboratoire
   - Relay toujours autorisé
   - Utilisé pour les challenges de base

2. **test.com**
   - Domaine de test
   - Relay autorisé pour experimentation
   - Utilisé pour les tests de relay

3. **example.org**
   - Domaine d'exemple
   - Relay autorisé
   - Conforme aux standards RFC

### Domaines Non Autorisés (nécessitent authentification)
- Tous les autres domaines
- `gmail.com`, `yahoo.com`, `hotmail.com`, etc.
- Domaines externes arbitraires

## 📧 Configuration de la Mailbox

### Emplacement
```
/home/ctf/smtp/mailbox/inbox/
```

### Emails Pré-Installés

#### 1. welcome.eml
- **From :** admin@ctf.local
- **To :** ctf@ctf.local
- **Flag :** `CTF{smtp_lab_welcome}`
- **Contenu :** Guide de bienvenue et instructions

#### 2. admin.eml
- **From :** root@ctf.local
- **To :** admin@ctf.local
- **Flag :** `CTF{smtp_admin_access}`
- **Contenu :** Configuration du serveur et credentials

#### 3. flag.eml
- **From :** flag@ctf.local
- **To :** player@ctf.local
- **Flag :** `CTF{smtp_lab_relay_ready}`
- **Contenu :** Flag principal du laboratoire

#### 4. secret.eml
- **From :** hidden@ctf.local
- **To :** secret@ctf.local
- **Flag :** `CTF{email_headers_decoded}`
- **Contenu :** Informations cachées et encodées

## 🔧 Configuration du Serveur

### Paramètres Réseau
- **Host :** 0.0.0.0 (écoute sur toutes les interfaces)
- **Port :** 25 (port SMTP standard)
- **Protocole :** TCP
- **Timeout session :** 300 secondes

### Limites de Sécurité
- **Connexions simultanées max :** 10
- **Connexions par IP max :** 3
- **Taille message max :** 1 MB (1,048,576 bytes)
- **Timeout inactivité :** 5 minutes

### Méthodes d'Authentification
- **AUTH LOGIN :** Supportée
- **AUTH PLAIN :** Supportée
- **AUTH CRAM-MD5 :** Non supportée (volontairement)

## 🚩 Flags CTF Disponibles

### Flags dans les Emails
1. `CTF{smtp_lab_welcome}` - Email de bienvenue
2. `CTF{smtp_admin_access}` - Email administrateur
3. `CTF{smtp_lab_relay_ready}` - Flag principal
4. `CTF{email_headers_decoded}` - Email secret

### Flags Cachés
- Dans les headers X-CTF-Flag
- Données encodées en Base64
- Headers personnalisés
- Réponses du serveur

### Flags Dynamiques
- Générés lors de l'envoi d'emails
- Basés sur les actions de l'utilisateur
- Stockés dans les logs

## 🔍 Découverte des Credentials

### Méthode 1 : Énumération VRFY
```
VRFY ctf
250 ctf@ctf.local

VRFY admin
250 admin@ctf.local

VRFY test
250 test@ctf.local
```

### Méthode 2 : Analyse des Emails
```bash
# Rechercher les credentials dans les emails
grep -r "password\|credential\|login" /home/ctf/smtp/mailbox/inbox/

# Rechercher les hints
grep -r "X-.*Password\|X-.*Credential" /home/ctf/smtp/mailbox/inbox/
```

### Méthode 3 : Headers Révélateurs
- `X-Admin-Password: secret_admin_2024`
- `X-CTF-Hint: Default password pattern`
- `X-Auth-Method: LOGIN PLAIN`

## ⚙️ Modification des Credentials

### Via Variables d'Environnement
```bash
# Modifier dans docker-compose.yml
environment:
  - CTF_USERNAME=newuser
  - CTF_PASSWORD=newpassword
  - ADMIN_PASSWORD=newadminpass
```

### Via Configuration
```python
# Dans smtp_server.py
USERS = {
    'ctf': 'nouveau_mot_de_passe',
    'admin': 'nouveau_admin_pass',
    'custom': 'custom_password'
}
```

### Reconstruction du Conteneur
```bash
# Après modification des credentials
docker-compose down
docker-compose build --no-cache
docker-compose up -d
```

## 🔐 Sécurité et Vulnérabilités

### Vulnérabilités Intentionnelles

#### 1. Énumération d'Utilisateurs
- La commande `VRFY` révèle les utilisateurs existants
- Aucune protection contre l'énumération
- Réponses différentiées pour utilisateurs valides/invalides

#### 2. Credentials Faibles
- Mots de passe prévisibles
- Patterns communs (admin/admin123)
- Stockage en clair dans la configuration

#### 3. Informations Révélatrices
- Bannière détaillée avec version
- Headers révélant la configuration interne
- Messages d'erreur verbeux

#### 4. Open Relay Partiel
- Relay autorisé pour certains domaines sans auth
- Configuration de relay visible
- Possibilité d'abuse pour spam

### Protections Implémentées

#### 1. Limites de Connexion
- Maximum 10 connexions simultanées
- Maximum 3 connexions par IP
- Timeout automatique des sessions

#### 2. Validation des Commandes
- Vérification de la syntaxe SMTP
- Séquencement des commandes
- Limitation de la taille des messages

#### 3. Authentification
- Support des méthodes standard
- Validation des credentials
- Logging des tentatives d'authentification

## 📋 Procédures de Test

### Test des Credentials
```bash
# Tester l'authentification LOGIN
echo -e "EHLO test.com\r\nAUTH LOGIN Y3Rm\r\nY3RmX3Bhc3N3b3JkXzIwMjQ=\r\nQUIT" | nc localhost 25

# Tester l'authentification PLAIN
echo -e "EHLO test.com\r\nAUTH PLAIN Y3RmAGN0ZgBjdGZfcGFzc3dvcmRfMjAyNA==\r\nQUIT" | nc localhost 25
```

### Vérification de la Configuration
```bash
# Vérifier les domaines autorisés
echo -e "HELO test.com\r\nMAIL FROM: <test@test.com>\r\nRCPT TO: <user@ctf.local>\r\nQUIT" | nc localhost 25

# Tester le relay non autorisé
echo -e "HELO test.com\r\nMAIL FROM: <test@test.com>\r\nRCPT TO: <user@gmail.com>\r\nQUIT" | nc localhost 25
```

### Audit de Sécurité
```bash
# Énumération d'utilisateurs
for user in admin ctf test root mail postmaster; do
    echo "VRFY $user" | nc localhost 25 | grep -v "Connection"
done

# Test de credentials par défaut
echo -e "AUTH LOGIN YWRtaW4=\r\nYWRtaW4xMjM=\r\nQUIT" | nc localhost 25
```

## 📊 Monitoring et Logs

### Fichiers de Log
- **Principal :** `/home/ctf/smtp/smtp.log`
- **Accès :** Connexions et authentifications
- **Erreurs :** Tentatives échouées et erreurs

### Surveillance des Connexions
```bash
# Surveiller les connexions en temps réel
tail -f /home/ctf/smtp/smtp.log

# Analyser les tentatives d'authentification
grep "authentication" /home/ctf/smtp/smtp.log

# Compter les emails reçus
ls /home/ctf/smtp/mailbox/inbox/*.eml | wc -l
```

## 🔄 Réinitialisation

### Reset Rapide
```bash
# Redémarrer le conteneur
docker-compose restart smtp-ctf-lab

# Vider la mailbox (conserver les emails CTF)
find /home/ctf/smtp/mailbox/inbox/ -name "email_*.eml" -delete

# Reset des logs
> /home/ctf/smtp/smtp.log
```

### Reset Complet
```bash
# Supprimer et recréer le conteneur
docker-compose down
docker-compose up -d --force-recreate
```

---

**⚠️ Note de Sécurité :** Cette configuration est destinée exclusivement à l'éducation et aux CTF. Ne jamais utiliser ces credentials ou cette configuration dans un environnement de production. 