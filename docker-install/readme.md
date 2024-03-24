# Installation Instructions

## For Linux:

### `<filename>.sh`

This Bash script automates the installation of Docker and Docker Compose on an Ubuntu machine. It performs the following steps:

1. Updates the apt package index.
2. Installs prerequisites for Docker.
3. Adds Docker's official GPG key.
4. Adds Docker repository.
5. Updates apt again.
6. Installs Docker.
7. Enables and starts Docker service.
8. Installs Docker Compose.
9. Adds execute permissions to Docker Compose binary.
10. Verifies Docker Compose installation.

**Usage:**
```bash
chmod +x <filename>.sh
sudo ./<filename>.sh
```

## For Windows:

### `windows.bat`

This batch script installs Docker and Docker Compose on a Windows machine using Chocolatey package manager. It performs the following steps:

1. Checks if Chocolatey is installed, if not, installs Chocolatey using PowerShell.
2. Installs Docker Desktop using Chocolatey.
3. Installs Docker Compose using Chocolatey.
4. Verifies Docker and Docker Compose installations.

**Usage:**
1. Run the script with administrator privileges by double-clicking on it or executing it from the command line.
2. If prompted, allow the script to make changes to your system.

**Note:** 
- Ensure that your system has Chocolatey installed for the Windows script to work properly. If Chocolatey is not installed, the script will attempt to install it automatically.
