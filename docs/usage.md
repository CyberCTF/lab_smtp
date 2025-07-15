# SMTP CTF Lab - Guide d'Utilisation

## 📧 Introduction au Protocole SMTP

Le Simple Mail Transfer Protocol (SMTP) est le protocole standard pour l'envoi d'emails sur Internet. Ce lab CTF vous permet d'explorer les mécanismes SMTP et leurs vulnérabilités dans un environnement contrôlé.

## 🚀 Démarrage Rapide

### Connexion au Serveur SMTP

```bash
# Connexion basique
telnet localhost 25

# Ou avec netcat
nc localhost 25
```

### Session SMTP Typique

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
Subject: Test Email
From: sender@test.com
To: recipient@ctf.local

Hello from CTF lab!
.
250 Message accepted for delivery
QUIT
221 Bye
```

## 📋 Commandes SMTP Supportées

### Commandes de Base

#### HELO / EHLO
Identifie le client SMTP auprès du serveur.

```
HELO domain.com
EHLO domain.com    # Version étendue avec capacités
```

**Réponses:**
- `250 Hello domain.com` - Succès
- `501 Syntax error` - Erreur de syntaxe

#### MAIL FROM
Spécifie l'adresse de l'expéditeur.

```
MAIL FROM: <sender@domain.com>
MAIL FROM: <user@test.com>
```

**Réponses:**
- `250 OK` - Expéditeur accepté
- `501 Syntax error in MAIL command` - Erreur de syntaxe

#### RCPT TO
Spécifie l'adresse du destinataire.

```
RCPT TO: <recipient@ctf.local>
RCPT TO: <admin@test.com>
```

**Réponses:**
- `250 OK` - Destinataire accepté
- `550 Relay not permitted` - Relay refusé
- `501 Syntax error in RCPT command` - Erreur de syntaxe

#### DATA
Commence la transmission du contenu de l'email.

```
DATA
354 End data with <CR><LF>.<CR><LF>
Subject: Mon Email
From: sender@domain.com
To: recipient@ctf.local

Contenu de l'email...
.
250 Message accepted for delivery
```

### Commandes d'Authentification

#### AUTH LOGIN
Authentification avec nom d'utilisateur et mot de passe en Base64.

```
AUTH LOGIN
334 VXNlcm5hbWU6
Y3Rm                    # "ctf" en base64
334 UGFzc3dvcmQ6
Y3RmX3Bhc3N3b3JkXzIwMjQ=   # "ctf_password_2024" en base64
235 Authentication successful
```

#### AUTH PLAIN
Authentification avec credentials combinés en Base64.

```
AUTH PLAIN Y3RmAGN0ZgBjdGZfcGFzc3dvcmRfMjAyNA==
235 Authentication successful
```

**Format AUTH PLAIN:** `base64(username\0username\0password)`

### Commandes Utilitaires

#### VRFY
Vérifie l'existence d'un utilisateur (vulnérabilité CTF).

```
VRFY ctf
250 ctf@ctf.local
VRFY nonexistent
550 User unknown
```

#### RSET
Remet à zéro la session courante.

```
RSET
250 OK
```

#### QUIT
Ferme la connexion SMTP.

```
QUIT
221 Bye
```

#### HELP
Affiche les commandes disponibles.

```
HELP
214 Commands: HELO EHLO MAIL RCPT DATA AUTH VRFY RSET QUIT
```

## 🔐 Authentification

### Utilisateurs Disponibles

| Utilisateur | Mot de passe | Description |
|-------------|--------------|-------------|
| `ctf` | `ctf_password_2024` | Utilisateur principal CTF |
| `admin` | `admin123` | Compte administrateur |
| `test` | `test` | Compte de test |

### Encodage Base64

Pour l'authentification, utilisez l'encodage Base64 :

```bash
# Encoder un nom d'utilisateur
echo -n "ctf" | base64
# Résultat: Y3Rm

# Encoder un mot de passe
echo -n "ctf_password_2024" | base64
# Résultat: Y3RmX3Bhc3N3b3JkXzIwMjQ=
```

## 🌐 Configuration des Domaines

### Domaines Autorisés pour Relay

- `ctf.local` - Domaine principal du lab
- `test.com` - Domaine de test
- `example.org` - Domaine d'exemple

### Test de Relay

```bash
# Relay autorisé (sans authentification)
RCPT TO: <user@ctf.local>
250 OK

# Relay refusé (sans authentification)
RCPT TO: <user@unauthorized.com>
550 Relay not permitted for unauthorized.com

# Relay autorisé (avec authentification)
AUTH LOGIN [credentials]
RCPT TO: <user@anywhere.com>
250 OK
```

## 📧 Format des Emails

### Headers Essentiels

```
Subject: Sujet de l'email
From: expediteur@domain.com
To: destinataire@domain.com
Date: Mon, 01 Jan 2024 12:00:00 +0000
Message-ID: <unique-id@domain.com>
```

### Headers CTF Spéciaux

```
X-CTF-Flag: CTF{flag_value}
X-CTF-Hint: Indice pour le challenge
X-Secret-Data: Données cachées en base64
```

### Exemple d'Email Complet

```
Subject: Test Email
From: ctf@test.com
To: admin@ctf.local
Date: Mon, 01 Jan 2024 12:00:00 +0000
X-CTF-Flag: CTF{smtp_email_sent}

Bonjour,

Ceci est un email de test du lab CTF SMTP.

Cordialement,
CTF Lab
```

## 🔍 Challenges CTF

### 1. Exploration Basique
- Connectez-vous au serveur SMTP
- Explorez les commandes disponibles
- Trouvez le flag dans la bannière

### 2. Énumération d'Utilisateurs
- Utilisez la commande `VRFY` pour découvrir les utilisateurs
- Testez différents noms d'utilisateurs
- Flag caché dans les réponses

### 3. Test de Relay
- Testez l'envoi vers différents domaines
- Identifiez les domaines autorisés
- Exploitez la configuration de relay

### 4. Authentification
- Testez l'authentification avec différents comptes
- Explorez les méthodes AUTH LOGIN et AUTH PLAIN
- Tentez un bypass d'authentification

### 5. Analyse d'Emails
- Consultez la mailbox `/home/ctf/smtp/mailbox/inbox/`
- Analysez les headers des emails
- Décodez les données Base64

### 6. Email Spoofing
- Envoyez un email en spoofant l'expéditeur
- Testez l'injection dans les headers
- Exploitez les vulnérabilités du protocole

### 7. Header Injection
- Tentez d'injecter des headers supplémentaires
- Exploitez les vulnérabilités de validation
- Recherchez les flags cachés

## ⚠️ Vulnérabilités Éducatives

### Open Relay Partiel
Le serveur accepte le relay pour certains domaines sans authentification.

### Énumération d'Utilisateurs
La commande `VRFY` révèle l'existence des utilisateurs.

### Informations Révélatrices
- Bannière détaillée avec version
- Messages d'erreur verbeux
- Headers révélant la configuration

### Bypass d'Authentification
Certains scénarios permettent de contourner l'authentification.

## 🛠️ Outils Utiles

### Clients SMTP

```bash
# Telnet (basique)
telnet localhost 25

# Netcat
nc localhost 25

# OpenSSL (pour SMTP sécurisé)
openssl s_client -connect localhost:25 -starttls smtp

# Python (script personnalisé)
python3 -c "
import smtplib
server = smtplib.SMTP('localhost', 25)
server.set_debuglevel(1)
server.helo()
server.quit()
"
```

### Décodage Base64

```bash
# Décoder une chaîne Base64
echo "Y3Rm" | base64 -d

# Encoder une chaîne en Base64
echo -n "message" | base64
```

### Analyse d'Emails

```bash
# Lire un email
cat /home/ctf/smtp/mailbox/inbox/welcome.eml

# Extraire les headers
grep "^[A-Za-z-]*:" /home/ctf/smtp/mailbox/inbox/welcome.eml

# Chercher les flags
grep -r "CTF{" /home/ctf/smtp/mailbox/inbox/
```

## 📊 Codes de Réponse SMTP

### Codes de Succès (2xx)
- `220` - Service ready
- `221` - Service closing
- `235` - Authentication successful
- `250` - Requested action okay, completed
- `354` - Start mail input

### Codes d'Erreur Temporaire (4xx)
- `421` - Service not available, closing transmission channel
- `450` - Requested action not taken: mailbox unavailable
- `451` - Requested action aborted: local error in processing

### Codes d'Erreur Permanente (5xx)
- `500` - Syntax error, command unrecognized
- `501` - Syntax error in parameters or arguments
- `502` - Command not implemented
- `503` - Bad sequence of commands
- `535` - Authentication failed
- `550` - Requested action not taken: mailbox unavailable

## 🔗 Ressources Supplémentaires

- [RFC 5321 - Simple Mail Transfer Protocol](https://tools.ietf.org/html/rfc5321)
- [RFC 4954 - SMTP Service Extension for Authentication](https://tools.ietf.org/html/rfc4954)
- [SMTP Command Reference](https://www.iana.org/assignments/mail-parameters/)

## 💡 Conseils pour les CTF

1. **Explorez systématiquement** - Testez toutes les commandes disponibles
2. **Analysez les réponses** - Les messages d'erreur contiennent souvent des indices
3. **Vérifiez la mailbox** - Les emails stockés contiennent des flags
4. **Testez différents domaines** - Identifiez les règles de relay
5. **Décodez tout** - Les données Base64 cachent souvent des secrets
6. **Documentez vos découvertes** - Gardez une trace de vos tests

Bonne exploration du protocole SMTP ! 📧🔍 