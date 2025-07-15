@echo off
REM SMTP CTF Lab - Script de démarrage Windows
REM ============================================

echo.
echo  ===================================
echo     SMTP CTF Lab - Demarrage
echo  ===================================
echo.

REM Vérifier si Docker est installé
where docker >nul 2>nul
if %errorlevel% neq 0 (
    echo [ERREUR] Docker n'est pas installe ou n'est pas dans le PATH
    echo Veuillez installer Docker Desktop pour Windows
    echo https://docs.docker.com/desktop/windows/install/
    pause
    exit /b 1
)

REM Vérifier si Docker Compose est disponible
where docker-compose >nul 2>nul
if %errorlevel% neq 0 (
    echo [ERREUR] Docker Compose n'est pas disponible
    echo Veuillez installer Docker Compose
    pause
    exit /b 1
)

echo [INFO] Docker detecte, verification de l'etat...

REM Vérifier si Docker est en cours d'exécution
docker info >nul 2>nul
if %errorlevel% neq 0 (
    echo [ERREUR] Docker n'est pas en cours d'execution
    echo Veuillez demarrer Docker Desktop
    pause
    exit /b 1
)

echo [INFO] Docker est pret !
echo.

REM Arrêter les conteneurs existants si ils existent
echo [INFO] Arret des conteneurs existants...
docker-compose down >nul 2>nul

REM Construire et démarrer le lab
echo [INFO] Construction et demarrage du lab SMTP...
docker-compose up -d --build

if %errorlevel% neq 0 (
    echo.
    echo [ERREUR] Echec du demarrage du lab
    echo Verifiez les logs avec: docker-compose logs
    pause
    exit /b 1
)

echo.
echo  ===================================
echo     SMTP CTF Lab - PRET !
echo  ===================================
echo.
echo [SUCCESS] Le serveur SMTP CTF est maintenant en cours d'execution !
echo.
echo Informations de connexion:
echo - Adresse: localhost
echo - Port: 25
echo - Protocole: SMTP
echo.
echo Connexion rapide:
echo   telnet localhost 25
echo.
echo Credentials par defaut:
echo - Utilisateur: ctf
echo - Mot de passe: ctf_password_2024
echo.
echo - Utilisateur: admin  
echo - Mot de passe: admin123
echo.
echo Commandes utiles:
echo - Arreter le lab: docker-compose down
echo - Voir les logs: docker-compose logs -f
echo - Redemarrer: docker-compose restart
echo.
echo Tests automatises:
echo   bash test/check_smtp.sh
echo.
echo Documentation complete: README.md
echo.

REM Vérifier si le port 25 est accessible
echo [INFO] Test de connectivite...
timeout /t 3 >nul
powershell -Command "Test-NetConnection -ComputerName localhost -Port 25" >nul 2>nul
if %errorlevel% equ 0 (
    echo [SUCCESS] Le serveur SMTP repond sur le port 25
) else (
    echo [WARNING] Le serveur SMTP ne repond pas encore (normal au premier demarrage)
    echo Attendez quelques secondes et reessayez
)

echo.
echo Appuyez sur une touche pour continuer...
pause >nul 