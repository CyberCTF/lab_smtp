FROM python:3.11-slim

# Métadonnées
LABEL maintainer="Acme Logistics IT"
LABEL description="Acme Logistics Mail Server"
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
# Acme Logistics business emails (one contains the secret)
COPY --chown=ctf:ctf <<EOF /home/ctf/smtp/mailbox/inbox/welcome.eml
From: admin@acmelogistics.local
To: all-staff@acmelogistics.local
Subject: Welcome to Acme Logistics Mail System
Date: Mon, 01 Jan 2024 12:00:00 +0000
Message-ID: <welcome@acmelogistics.local>

Welcome to the Acme Logistics Mail System!

This is our corporate email server for internal and external communications.

IMPORTANT SECURITY NOTICE:
- All external emails must be authenticated
- Internal domain: acmelogistics.local
- Contact IT support for account issues

Best regards,
IT Department
Acme Logistics
EOF

COPY --chown=ctf:ctf <<EOF /home/ctf/smtp/mailbox/inbox/ceo-memo.eml
From: ceo@acmelogistics.local
To: management@acmelogistics.local
Subject: Q4 Financial Review Meeting
Date: Mon, 01 Jan 2024 12:30:00 +0000
Message-ID: <ceo-memo@acmelogistics.local>

Dear Management Team,

Please prepare for our Q4 financial review meeting scheduled for next week.

Key topics:
- Revenue analysis
- Cost optimization
- Strategic planning for 2024

Please ensure all reports are submitted by Friday.

Best regards,
CEO
Acme Logistics
EOF

COPY --chown=ctf:ctf <<EOF /home/ctf/smtp/mailbox/inbox/hr-update.eml
From: hr@acmelogistics.local
To: employees@acmelogistics.local
Subject: Updated Employee Handbook
Date: Mon, 01 Jan 2024 13:00:00 +0000
Message-ID: <hr-update@acmelogistics.local>

Dear Employees,

The updated employee handbook is now available on the intranet.

Key updates:
- Remote work policies
- Security protocols
- Benefits information

Please review the changes and contact HR with any questions.

Best regards,
HR Department
Acme Logistics
EOF

COPY --chown=ctf:ctf <<EOF /home/ctf/smtp/mailbox/inbox/it-security.eml
From: admin@acmelogistics.local
To: it-team@acmelogistics.local
Subject: Mail Server Configuration Review
Date: Mon, 01 Jan 2024 14:00:00 +0000
Message-ID: <it-security@acmelogistics.local>
X-Admin-Panel-Password: 9f8e7d6c

IT Team,

Please review the current mail server configuration:

Current settings:
- Domain: acmelogistics.local
- Authentication: SASL/PLAIN
- Relay restrictions: Configured for internal domain
- External relay: Requires authentication

Note: The smtpd_recipient_restrictions setting needs attention.

Best regards,
System Administrator
Acme Logistics
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