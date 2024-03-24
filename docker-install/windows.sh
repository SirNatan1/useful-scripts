@echo off

:: Check if Chocolatey is installed, if not, install Chocolatey
choco -?
if %errorlevel% neq 0 (
    echo Installing Chocolatey...
    powershell -Command "Set-ExecutionPolicy Bypass -Scope Process -Force; [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072; iex ((New-Object System.Net.WebClient).DownloadString('https://community.chocolatey.org/install.ps1'))"
)

:: Install Docker using Chocolatey
choco install -y docker-desktop

:: Install Docker Compose using Chocolatey
choco install -y docker-compose

:: Verify Docker and Docker Compose installations
docker --version
docker-compose --version
