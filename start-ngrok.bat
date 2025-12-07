@echo off
echo ========================================
echo   Demarrage du tunnel HTTPS avec ngrok
echo ========================================
echo.
echo Le backend doit etre en cours d'execution sur le port 10000
echo.
echo Demarrage du tunnel...
echo.

ngrok http 10000

pause
