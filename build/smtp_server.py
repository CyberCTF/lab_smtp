#!/usr/bin/env python3
"""
SMTP CTF Lab Server
A simple SMTP server for CTF challenges with controlled vulnerabilities
"""

import asyncio
import socket
import threading
import time
import base64
import os
import email
from datetime import datetime
from pathlib import Path
import logging

# Configuration
SMTP_PORT = 25
SMTP_HOST = '0.0.0.0'
MAX_CONNECTIONS = 10
MAX_CONNECTIONS_PER_IP = 3
SESSION_TIMEOUT = 300
MAX_MESSAGE_SIZE = 1024 * 1024  # 1MB
MAILBOX_PATH = '/home/ctf/smtp/mailbox'

# Domaines autorisés pour relay
ALLOWED_DOMAINS = ['ctf.local', 'test.com', 'example.org']

# Utilisateurs autorisés
USERS = {
    'ctf': 'ctf_password_2024',
    'admin': 'admin123',
    'test': 'test'
}

# Configuration logging
logging.basicConfig(
    level=logging.INFO,
    format='%(asctime)s - %(levelname)s - %(message)s',
    handlers=[
        logging.FileHandler('/home/ctf/smtp/smtp.log'),
        logging.StreamHandler()
    ]
)

class SMTPSession:
    def __init__(self, socket, address):
        self.socket = socket
        self.address = address
        self.authenticated = False
        self.current_user = None
        self.mail_from = None
        self.rcpt_to = []
        self.data_mode = False
        self.message_data = []
        self.last_activity = time.time()
        
    def send_response(self, code, message):
        response = f"{code} {message}\r\n"
        self.socket.send(response.encode())
        logging.info(f"{self.address}: -> {code} {message}")
        
    def update_activity(self):
        self.last_activity = time.time()

class SMTPServer:
    def __init__(self):
        self.server_socket = None
        self.running = False
        self.connections = []
        self.ip_connections = {}
        
        # Créer le répertoire mailbox s'il n'existe pas
        Path(MAILBOX_PATH).mkdir(parents=True, exist_ok=True)
        Path(f"{MAILBOX_PATH}/inbox").mkdir(exist_ok=True)
        
        logging.info("SMTP CTF Lab Server initialized")
        
    def start(self):
        self.server_socket = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
        self.server_socket.setsockopt(socket.SOL_SOCKET, socket.SO_REUSEADDR, 1)
        self.server_socket.bind((SMTP_HOST, SMTP_PORT))
        self.server_socket.listen(5)
        
        self.running = True
        logging.info(f"SMTP Server listening on {SMTP_HOST}:{SMTP_PORT}")
        
        # Thread pour nettoyer les connexions expirées
        cleanup_thread = threading.Thread(target=self.cleanup_connections, daemon=True)
        cleanup_thread.start()
        
        try:
            while self.running:
                try:
                    client_socket, address = self.server_socket.accept()
                    ip = address[0]
                    
                    # Vérifier les limites de connexion
                    if len(self.connections) >= MAX_CONNECTIONS:
                        client_socket.send(b"421 Too many connections\r\n")
                        client_socket.close()
                        continue
                        
                    if self.ip_connections.get(ip, 0) >= MAX_CONNECTIONS_PER_IP:
                        client_socket.send(b"421 Too many connections from this IP\r\n")
                        client_socket.close()
                        continue
                    
                    # Créer nouvelle session
                    session = SMTPSession(client_socket, address)
                    self.connections.append(session)
                    self.ip_connections[ip] = self.ip_connections.get(ip, 0) + 1
                    
                    # Démarrer thread pour gérer la session
                    session_thread = threading.Thread(
                        target=self.handle_session, 
                        args=(session,), 
                        daemon=True
                    )
                    session_thread.start()
                    
                    logging.info(f"New connection from {address}")
                    
                except socket.error as e:
                    if self.running:
                        logging.error(f"Socket error: {e}")
                        
        except KeyboardInterrupt:
            logging.info("Server shutdown requested")
        finally:
            self.stop()
            
    def stop(self):
        self.running = False
        if self.server_socket:
            self.server_socket.close()
        logging.info("SMTP Server stopped")
        
    def cleanup_connections(self):
        while self.running:
            current_time = time.time()
            expired_sessions = []
            
            for session in self.connections:
                if current_time - session.last_activity > SESSION_TIMEOUT:
                    expired_sessions.append(session)
                    
            for session in expired_sessions:
                self.close_session(session, "421 Session timeout")
                
            time.sleep(30)  # Nettoyer toutes les 30 secondes
            
    def close_session(self, session, message=None):
        if message:
            try:
                session.send_response(421, message.split(' ', 1)[1])
            except:
                pass
                
        try:
            session.socket.close()
        except:
            pass
            
        if session in self.connections:
            self.connections.remove(session)
            
        ip = session.address[0]
        if ip in self.ip_connections:
            self.ip_connections[ip] = max(0, self.ip_connections[ip] - 1)
            
        logging.info(f"Connection closed: {session.address}")
        
    def handle_session(self, session):
        try:
            # Bannière de bienvenue
            session.send_response(220, "CTF SMTP Lab Ready - Python SMTP Server v1.0")
            session.update_activity()
            
            buffer = ""
            
            while self.running:
                try:
                    data = session.socket.recv(1024).decode('utf-8', errors='ignore')
                    if not data:
                        break
                        
                    session.update_activity()
                    buffer += data
                    
                    # Traiter les lignes complètes
                    while '\r\n' in buffer:
                        line, buffer = buffer.split('\r\n', 1)
                        line = line.strip()
                        
                        if line:
                            logging.info(f"{session.address}: <- {line}")
                            
                            if session.data_mode:
                                if line == '.':
                                    # Fin du message
                                    self.handle_data_end(session)
                                    session.data_mode = False
                                else:
                                    # Ajouter ligne au message
                                    if line.startswith('.'):
                                        line = line[1:]  # Supprimer le . d'échappement
                                    session.message_data.append(line)
                            else:
                                self.handle_command(session, line)
                                
                except socket.timeout:
                    continue
                except socket.error:
                    break
                    
        except Exception as e:
            logging.error(f"Session error {session.address}: {e}")
        finally:
            self.close_session(session)
            
    def handle_command(self, session, line):
        parts = line.split(' ', 1)
        command = parts[0].upper()
        args = parts[1] if len(parts) > 1 else ""
        
        if command == 'HELO':
            session.send_response(250, f"Hello {args or 'client'}")
            
        elif command == 'EHLO':
            session.send_response(250, f"Hello {args or 'client'}, pleased to meet you")
            session.socket.send(b"250-AUTH PLAIN LOGIN\r\n")
            session.socket.send(b"250-SIZE 1048576\r\n")
            session.socket.send(b"250 HELP\r\n")
            
        elif command == 'AUTH':
            self.handle_auth(session, args)
            
        elif command == 'MAIL':
            if args.upper().startswith('FROM:'):
                sender = args[5:].strip().strip('<>')
                session.mail_from = sender
                session.send_response(250, "OK")
            else:
                session.send_response(501, "Syntax error in MAIL command")
                
        elif command == 'RCPT':
            if args.upper().startswith('TO:'):
                recipient = args[3:].strip().strip('<>')
                
                # Vérifier si le domaine est autorisé pour relay
                domain = recipient.split('@')[1] if '@' in recipient else ''
                if domain not in ALLOWED_DOMAINS and not session.authenticated:
                    session.send_response(550, f"Relay not permitted for {domain}")
                else:
                    session.rcpt_to.append(recipient)
                    session.send_response(250, "OK")
            else:
                session.send_response(501, "Syntax error in RCPT command")
                
        elif command == 'DATA':
            if not session.mail_from:
                session.send_response(503, "Need MAIL FROM first")
            elif not session.rcpt_to:
                session.send_response(503, "Need RCPT TO first")
            else:
                session.send_response(354, "End data with <CR><LF>.<CR><LF>")
                session.data_mode = True
                session.message_data = []
                
        elif command == 'VRFY':
            # Vulnérabilité CTF : révéler des utilisateurs
            if args in USERS:
                session.send_response(250, f"{args}@ctf.local")
            else:
                session.send_response(550, "User unknown")
                
        elif command == 'RSET':
            session.mail_from = None
            session.rcpt_to = []
            session.message_data = []
            session.data_mode = False
            session.send_response(250, "OK")
            
        elif command == 'QUIT':
            session.send_response(221, "Bye")
            self.close_session(session)
            return
            
        elif command == 'HELP':
            session.send_response(214, "Commands: HELO EHLO MAIL RCPT DATA AUTH VRFY RSET QUIT")
            
        else:
            session.send_response(502, "Command not implemented")
            
    def handle_auth(self, session, args):
        parts = args.split(' ', 1)
        method = parts[0].upper()
        
        if method == 'LOGIN':
            if len(parts) > 1:
                # Username fourni directement
                try:
                    username = base64.b64decode(parts[1]).decode()
                    session.socket.send(b"334 UGFzc3dvcmQ6\r\n")  # "Password:" en base64
                    
                    # Attendre le mot de passe
                    password_data = session.socket.recv(1024).decode().strip()
                    password = base64.b64decode(password_data).decode()
                    
                    if username in USERS and USERS[username] == password:
                        session.authenticated = True
                        session.current_user = username
                        session.send_response(235, "Authentication successful")
                        logging.info(f"Successful authentication: {username} from {session.address}")
                    else:
                        session.send_response(535, "Authentication failed")
                        logging.warning(f"Failed authentication: {username} from {session.address}")
                        
                except Exception as e:
                    session.send_response(535, "Authentication failed")
                    
            else:
                session.socket.send(b"334 VXNlcm5hbWU6\r\n")  # "Username:" en base64
                
        elif method == 'PLAIN':
            if len(parts) > 1:
                try:
                    auth_data = base64.b64decode(parts[1]).decode()
                    null_char = '\x00'
                    parts = auth_data.split(null_char)
                    
                    if len(parts) >= 3:
                        username = parts[1]
                        password = parts[2]
                        
                        if username in USERS and USERS[username] == password:
                            session.authenticated = True
                            session.current_user = username
                            session.send_response(235, "Authentication successful")
                            logging.info(f"Successful authentication: {username} from {session.address}")
                        else:
                            session.send_response(535, "Authentication failed")
                            logging.warning(f"Failed authentication: {username} from {session.address}")
                    else:
                        session.send_response(535, "Authentication failed")
                        
                except Exception as e:
                    session.send_response(535, "Authentication failed")
            else:
                session.socket.send(b"334 \r\n")  # Demander les données d'auth
                
        else:
            session.send_response(504, "Authentication method not supported")
            
    def handle_data_end(self, session):
        try:
            # Créer l'email complet
            timestamp = datetime.now().strftime("%a, %d %b %Y %H:%M:%S +0000")
            
            # Headers par défaut
            email_content = f"Received: from client ({session.address[0]})\r\n"
            email_content += f"    by ctf.local (SMTP CTF Lab) with SMTP\r\n"
            email_content += f"    for {', '.join(session.rcpt_to)}; {timestamp}\r\n"
            
            # Ajouter le contenu du message
            message_body = '\r\n'.join(session.message_data)
            email_content += message_body
            
            # Sauvegarder l'email dans la mailbox
            filename = f"email_{int(time.time())}_{session.address[1]}.eml"
            filepath = os.path.join(MAILBOX_PATH, 'inbox', filename)
            
            with open(filepath, 'w') as f:
                f.write(email_content)
                
            session.send_response(250, "Message accepted for delivery")
            
            logging.info(f"Email saved: {filename} from {session.mail_from} to {session.rcpt_to}")
            
            # Reset session
            session.mail_from = None
            session.rcpt_to = []
            session.message_data = []
            
        except Exception as e:
            session.send_response(552, "Mailbox full or message too large")
            logging.error(f"Error saving email: {e}")

def main():
    # Afficher la bannière
    banner_path = '/home/ctf/smtp/welcome_banner.txt'
    if os.path.exists(banner_path):
        with open(banner_path, 'r') as f:
            print(f.read())
    
    server = SMTPServer()
    
    try:
        server.start()
    except KeyboardInterrupt:
        print("\nShutting down server...")
        server.stop()

if __name__ == "__main__":
    main() 