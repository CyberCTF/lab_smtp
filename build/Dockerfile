FROM python:3.11-slim

# Métadonnées
LABEL maintainer="CTF Lab"
LABEL description="SMTP CTF Laboratory Server"
LABEL version="1.0"

# Installation des dépendances système
RUN apt-get update && apt-get install -y \
    telnet \
    netcat-traditional \
    && rm -rf /var/lib/apt/lists/*

# Créer l'utilisateur CTF
RUN groupadd -r ctf && useradd -r -g ctf -d /home/ctf -s /bin/bash ctf
RUN echo 'ctf:ctf_password_2024' | chpasswd

# Créer la structure des répertoires
RUN mkdir -p /home/ctf/smtp/mailbox/inbox \
    && mkdir -p /home/ctf/smtp/logs \
    && chown -R ctf:ctf /home/ctf

# Copier les fichiers de l'application
COPY smtp_server.py /home/ctf/smtp/
COPY setup.sh /home/ctf/smtp/
COPY welcome_banner.txt /home/ctf/smtp/

# Créer les emails CTF d'exemple
COPY --chown=ctf:ctf <<EOF /home/ctf/smtp/mailbox/inbox/welcome.eml
From: admin@ctf.local
To: ctf@ctf.local
Subject: Welcome to SMTP CTF Lab Template
Date: Mon, 01 Jan 2024 12:00:00 +0000
X-CTF-Flag: CTF{PLACEHOLDER_WELCOME_FLAG}
X-CTF-Hint: Replace this with your own flag and hint
Message-ID: <welcome@ctf.local>

Welcome to the SMTP CTF Laboratory Template!

This is a template for creating SMTP-based CTF challenges.

TEMPLATE SETUP:
1. Replace all CTF{PLACEHOLDER_*} flags with your own
2. Customize email content for your challenges
3. Modify server configuration as needed
4. Add your own vulnerability scenarios

Available commands:
- HELO/EHLO: Identify client
- MAIL FROM: Set sender
- RCPT TO: Set recipient  
- DATA: Send message content
- AUTH: Authenticate (LOGIN/PLAIN)
- VRFY: Verify user exists
- RSET: Reset session
- QUIT: Close connection

Template ready for customization!
EOF

COPY --chown=ctf:ctf <<EOF /home/ctf/smtp/mailbox/inbox/admin.eml
From: root@ctf.local
To: admin@ctf.local
Subject: [TEMPLATE] SMTP Server Configuration
Date: Mon, 01 Jan 2024 12:30:00 +0000
X-CTF-Flag: CTF{PLACEHOLDER_ADMIN_FLAG}
X-Admin-Password: CHANGE_THIS_PASSWORD
Message-ID: <admin-config@ctf.local>

SMTP Server Template Configuration:

This is a template configuration email.
Replace with your own CTF challenge content.

CUSTOMIZATION POINTS:
- Change all passwords in smtp_server.py
- Modify relay domains for your scenario
- Add your own vulnerability descriptions
- Replace placeholder flags with real ones

Template features:
- Basic SMTP server (Python-based)
- Authentication support (LOGIN/PLAIN)
- Configurable relay domains
- Email storage and logging
- Controlled vulnerabilities for education

Customize this template for your CTF needs!
EOF

COPY --chown=ctf:ctf <<EOF /home/ctf/smtp/mailbox/inbox/challenge.eml
From: challenge@ctf.local
To: player@ctf.local
Subject: CTF Challenge Template
Date: Mon, 01 Jan 2024 13:00:00 +0000
X-CTF-Flag: CTF{PLACEHOLDER_MAIN_FLAG}
X-CTF-Challenge: Replace with your challenge description
Message-ID: <challenge-template@ctf.local>

SMTP CTF Challenge Template

This is a template email for your CTF challenges.

TEMPLATE USAGE:
1. Replace CTF{PLACEHOLDER_MAIN_FLAG} with your actual flag
2. Customize the challenge description
3. Add your own clues and hints
4. Modify headers for additional challenges

Suggested challenge types:
- Email relay exploitation
- Authentication bypass
- Header injection
- Email spoofing techniques
- Protocol enumeration
- Information disclosure

Replace this content with your actual CTF challenge!
EOF

COPY --chown=ctf:ctf <<EOF /home/ctf/smtp/mailbox/inbox/template-hidden.eml
From: template@ctf.local
To: user@ctf.local
Subject: =?UTF-8?B?VGVtcGxhdGUgRXhhbXBsZQ==?=
Date: Mon, 01 Jan 2024 14:00:00 +0000
X-CTF-Flag: CTF{PLACEHOLDER_HIDDEN_FLAG}
X-Template-Hint: This shows encoding example
X-Hidden-Data: REPLACE_WITH_YOUR_BASE64_DATA
Message-ID: <template-hidden@ctf.local>

SMTP Template - Hidden Data Example

This email demonstrates various encoding techniques for CTF challenges.

TEMPLATE FEATURES:
- Base64 encoded subject line (decode "VGVtcGxhdGUgRXhhbXBsZQ==")
- Custom headers for hiding data
- Multiple encoding opportunities

CUSTOMIZATION IDEAS:
1. Replace subject with your encoded message
2. Add custom X-headers with hidden data
3. Use different encoding methods (base64, URL, hex)
4. Hide flags in email addresses or timestamps

This is a template - customize for your CTF!
EOF

# Ajuster les permissions
RUN chown -R ctf:ctf /home/ctf/smtp/

# Rendre le script setup.sh exécutable
RUN chmod +x /home/ctf/smtp/setup.sh

# Exposer le port SMTP
EXPOSE 25

# Basculer vers l'utilisateur CTF
USER ctf
WORKDIR /home/ctf/smtp

# Point d'entrée
CMD ["./setup.sh"] 