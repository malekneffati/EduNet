@echo off
echo ========================================
echo   Demarrage du Backend EduNet - Paymee
echo ========================================
echo.

cd backend

if not exist .env (
    echo [ERREUR] Fichier .env manquant !
    echo.
    echo Veuillez suivre ces etapes :
    echo 1. Copiez .env.example vers .env
    echo 2. Editez .env et ajoutez vos cles Paymee
    echo.
    pause
    exit /b 1
)

echo [INFO] Demarrage du serveur...
echo.
npm start
