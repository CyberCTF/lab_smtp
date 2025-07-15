#!/bin/bash

# SMTP CTF Lab Setup Script
# Configuration et démarrage du serveur SMTP

echo "=== SMTP CTF Lab Setup ==="
echo "Starting SMTP server configuration..."

# Vérifier les répertoires
if [ ! -d "/home/ctf/smtp/mailbox/inbox" ]; then
    echo "Creating mailbox directory..."
    mkdir -p /home/ctf/smtp/mailbox/inbox
fi

if [ ! -d "/home/ctf/smtp/logs" ]; then
    echo "Creating logs directory..."
    mkdir -p /home/ctf/smtp/logs
fi

# Vérifier les permissions
echo "Setting up permissions..."
chmod 755 /home/ctf/smtp/mailbox
chmod 755 /home/ctf/smtp/mailbox/inbox
chmod 644 /home/ctf/smtp/mailbox/inbox/*.eml 2>/dev/null || true

# Créer le fichier de log
touch /home/ctf/smtp/smtp.log
chmod 644 /home/ctf/smtp/smtp.log

# Afficher les informations de configuration
echo ""
echo "=== SMTP CTF Lab Configuration ==="
echo "Server: localhost:25"
echo "Users: ctf, admin, test"
echo "Domains: ctf.local, test.com, example.org"
echo "Mailbox: /home/ctf/smtp/mailbox/inbox"
echo "Logs: /home/ctf/smtp/smtp.log"
echo ""

# Afficher le contenu du mailbox
echo "=== Available Emails in Mailbox ==="
if [ -d "/home/ctf/smtp/mailbox/inbox" ]; then
    ls -la /home/ctf/smtp/mailbox/inbox/
    echo ""
    echo "Email count: $(ls /home/ctf/smtp/mailbox/inbox/*.eml 2>/dev/null | wc -l)"
else
    echo "No mailbox found."
fi
echo ""

# Afficher les instructions de connexion
echo "=== Connection Instructions ==="
echo "1. Connect with: telnet localhost 25"
echo "2. Basic SMTP commands:"
echo "   HELO test.com"
echo "   MAIL FROM: <sender@domain.com>"
echo "   RCPT TO: <recipient@ctf.local>"
echo "   DATA"
echo "   [your message]"
echo "   ."
echo "   QUIT"
echo ""
echo "3. Authentication (optional):"
echo "   AUTH LOGIN"
echo "   [base64 encoded username]"
echo "   [base64 encoded password]"
echo ""

# Variables d'environnement
export SMTP_HOST=${SMTP_HOST:-"0.0.0.0"}
export SMTP_PORT=${SMTP_PORT:-25}
export SMTP_DOMAIN=${SMTP_DOMAIN:-"ctf.local"}
export RELAY_DOMAINS=${RELAY_DOMAINS:-"ctf.local,test.com,example.org"}

echo "=== Environment Variables ==="
echo "SMTP_HOST: $SMTP_HOST"
echo "SMTP_PORT: $SMTP_PORT"
echo "SMTP_DOMAIN: $SMTP_DOMAIN"
echo "RELAY_DOMAINS: $RELAY_DOMAINS"
echo ""

# Fonction de nettoyage pour arrêt propre
cleanup() {
    echo ""
    echo "=== Shutting down SMTP CTF Lab ==="
    echo "Session summary:"
    if [ -f "/home/ctf/smtp/smtp.log" ]; then
        echo "Total connections: $(grep -c "New connection" /home/ctf/smtp/smtp.log 2>/dev/null || echo "0")"
        echo "Emails received: $(ls /home/ctf/smtp/mailbox/inbox/email_*.eml 2>/dev/null | wc -l)"
    fi
    echo "Thank you for using SMTP CTF Lab!"
    exit 0
}

# Piège pour arrêt propre
trap cleanup SIGTERM SIGINT

# Démarrer le serveur SMTP
echo "=== Starting SMTP Server ==="
echo "Server starting on $SMTP_HOST:$SMTP_PORT..."
echo "Press Ctrl+C to stop the server"
echo ""

# Démarrer le serveur Python
python3 smtp_server.py

# En cas d'arrêt du serveur
echo "SMTP server stopped."
cleanup 