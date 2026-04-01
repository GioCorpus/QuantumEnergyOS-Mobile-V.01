# ⚡ QuantumEnergyOS Mobile V.01 - Script de Instalación Windows
# Sistema Operativo Móvil Cuántico para Gestión de Energía
# Autor: Giovanny Corpus Bernal - Mexicali, Baja California

#Requires -Version 5.1

<#
.SYNOPSIS
    Script de instalación para QuantumEnergyOS Mobile en Windows

.DESCRIPTION
    Este script instala y configura QuantumEnergyOS Mobile en sistemas Windows.
    Incluye verificación de dependencias, instalación de Python y configuración
    del entorno.

.PARAMETER InstallPython
    Instala Python si no está presente

.PARAMETER SkipDependencies
    Omite la instalación de dependencias

.PARAMETER Debug
    Ejecuta en modo debug

.EXAMPLE
    .\setup.ps1
    .\setup.ps1 -InstallPython
    .\setup.ps1 -Debug
#>

param(
    [switch]$InstallPython,
    [switch]$SkipDependencies,
    [switch]$Debug
)

# Configuración de colores
$Host.UI.RawUIForegroundColor = "White"
$Host.UI.RawUBackgroundColor = "Black"

# Funciones de utilidad
function Write-ColorOutput {
    param(
        [string]$Message,
        [string]$Color = "White"
    )
    Write-Host $Message -ForegroundColor $Color
}

function Write-Banner {
    Write-ColorOutput ""
    Write-ColorOutput "╔══════════════════════════════════════════════════════════════╗" "Cyan"
    Write-ColorOutput "║                                                              ║" "Cyan"
    Write-ColorOutput "║   ⚡ QuantumEnergyOS Mobile V.01 ⚡                          ║" "Cyan"
    Write-ColorOutput "║                                                              ║" "Cyan"
    Write-ColorOutput "║   Sistema Operativo Móvil Cuántico                           ║" "Cyan"
    Write-ColorOutput "║   para Gestión de Energía                                    ║" "Cyan"
    Write-ColorOutput "║                                                              ║" "Cyan"
    Write-ColorOutput "║   Autor: Giovanny Corpus Bernal                              ║" "Cyan"
    Write-ColorOutput "║   Mexicali, Baja California, México                          ║" "Cyan"
    Write-ColorOutput "║                                                              ║" "Cyan"
    Write-ColorOutput "╚══════════════════════════════════════════════════════════════╝" "Cyan"
    Write-ColorOutput ""
}

function Test-Administrator {
    $currentUser = [Security.Principal.WindowsIdentity]::GetCurrent()
    $principal = New-Object Security.Principal.WindowsPrincipal($currentUser)
    return $principal.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
}

function Test-PythonInstalled {
    try {
        $pythonVersion = python --version 2>&1
        if ($pythonVersion -match "Python (\d+\.\d+\.\d+)") {
            Write-ColorOutput "[OK] Python encontrado: $pythonVersion" "Green"
            return $true
        }
    } catch {
        try {
            $pythonVersion = python3 --version 2>&1
            if ($pythonVersion -match "Python (\d+\.\d+\.\d+)") {
                Write-ColorOutput "[OK] Python3 encontrado: $pythonVersion" "Green"
                return $true
            }
        } catch {
            Write-ColorOutput "[ERROR] Python no encontrado" "Red"
            return $false
        }
    }
    return $false
}

function Install-Python {
    Write-ColorOutput "[INFO] Instalando Python..." "Blue"
    
    # Descargar Python
    $pythonUrl = "https://www.python.org/ftp/python/3.11.7/python-3.11.7-amd64.exe"
    $pythonInstaller = "$env:TEMP\python-installer.exe"
    
    Write-ColorOutput "[INFO] Descargando Python..." "Blue"
    Invoke-WebRequest -Uri $pythonUrl -OutFile $pythonInstaller
    
    # Instalar Python silenciosamente
    Write-ColorOutput "[INFO] Instalando Python..." "Blue"
    Start-Process -FilePath $pythonInstaller -ArgumentList "/quiet", "InstallAllUsers=1", "PrependPath=1" -Wait
    
    # Limpiar
    Remove-Item $pythonInstaller -Force
    
    # Refrescar PATH
    $env:Path = [System.Environment]::GetEnvironmentVariable("Path", "Machine") + ";" + [System.Environment]::GetEnvironmentVariable("Path", "User")
    
    Write-ColorOutput "[OK] Python instalado" "Green"
}

function Test-PipInstalled {
    try {
        $pipVersion = pip --version 2>&1
        if ($pipVersion -match "pip (\d+\.\d+)") {
            Write-ColorOutput "[OK] pip encontrado: $pipVersion" "Green"
            return $true
        }
    } catch {
        try {
            $pipVersion = pip3 --version 2>&1
            if ($pipVersion -match "pip (\d+\.\d+)") {
                Write-ColorOutput "[OK] pip3 encontrado: $pipVersion" "Green"
                return $true
            }
        } catch {
            Write-ColorOutput "[ERROR] pip no encontrado" "Red"
            return $false
        }
    }
    return $false
}

function Test-GitInstalled {
    try {
        $gitVersion = git --version 2>&1
        if ($gitVersion -match "git version (\d+\.\d+\.\d+)") {
            Write-ColorOutput "[OK] Git encontrado: $gitVersion" "Green"
            return $true
        }
    } catch {
        Write-ColorOutput "[ERROR] Git no encontrado" "Red"
        return $false
    }
    return $false
}

function Install-Git {
    Write-ColorOutput "[INFO] Instalando Git..." "Blue"
    
    # Descargar Git
    $gitUrl = "https://github.com/git-for-windows/git/releases/download/v2.43.0.windows.1/Git-2.43.0-64-bit.exe"
    $gitInstaller = "$env:TEMP\git-installer.exe"
    
    Write-ColorOutput "[INFO] Descargando Git..." "Blue"
    Invoke-WebRequest -Uri $gitUrl -OutFile $gitInstaller
    
    # Instalar Git silenciosamente
    Write-ColorOutput "[INFO] Instalando Git..." "Blue"
    Start-Process -FilePath $gitInstaller -ArgumentList "/VERYSILENT", "/NORESTART", "/NOCANCEL", "/SP-", "/CLOSEAPPLICATIONS", "/RESTARTAPPLICATIONS" -Wait
    
    # Limpiar
    Remove-Item $gitInstaller -Force
    
    # Refrescar PATH
    $env:Path = [System.Environment]::GetEnvironmentVariable("Path", "Machine") + ";" + [System.Environment]::GetEnvironmentVariable("Path", "User")
    
    Write-ColorOutput "[OK] Git instalado" "Green"
}

function Create-Directories {
    Write-ColorOutput "[INFO] Creando estructura de directorios..." "Blue"
    
    $directories = @(
        "logs",
        "data",
        "config",
        "dashboard\assets\images",
        "dashboard\assets\fonts",
        "dashboard\assets\particles",
        "scripts",
        "tests"
    )
    
    foreach ($dir in $directories) {
        if (-not (Test-Path $dir)) {
            New-Item -ItemType Directory -Path $dir -Force | Out-Null
            Write-ColorOutput "[OK] Directorio creado: $dir" "Green"
        } else {
            Write-ColorOutput "[OK] Directorio existe: $dir" "Green"
        }
    }
}

function Install-PythonDependencies {
    Write-ColorOutput "[INFO] Instalando dependencias de Python..." "Blue"
    
    # Actualizar pip
    python -m pip install --upgrade pip
    
    # Instalar dependencias
    if (Test-Path "requirements.txt") {
        pip install -r requirements.txt
        Write-ColorOutput "[OK] Dependencias instaladas" "Green"
    } else {
        Write-ColorOutput "[WARN] Archivo requirements.txt no encontrado" "Yellow"
        Write-ColorOutput "[INFO] Instalando dependencias básicas..." "Blue"
        
        pip install flask flask-socketio flask-cors psutil pyyaml requests
        Write-ColorOutput "[OK] Dependencias básicas instaladas" "Green"
    }
}

function Create-UtilityScripts {
    Write-ColorOutput "[INFO] Creando scripts de utilidad..." "Blue"
    
    # Script de inicio
    @'
@echo off
REM Script de inicio para QuantumEnergyOS Mobile

echo ⚡ Iniciando QuantumEnergyOS Mobile...
cd /d "%~dp0.."
python main.py
pause
'@ | Out-File -FilePath "scripts\start.bat" -Encoding ASCII
    
    # Script de parada
    @'
@echo off
REM Script de parada para QuantumEnergyOS Mobile

echo ⚡ Deteniendo QuantumEnergyOS Mobile...
taskkill /F /IM python.exe /FI "WINDOWTITLE eq QuantumEnergyOS*"
echo ✓ QuantumEnergyOS Mobile detenido
pause
'@ | Out-File -FilePath "scripts\stop.bat" -Encoding ASCII
    
    # Script de respaldo
    @'
@echo off
REM Script de respaldo para QuantumEnergyOS Mobile

set BACKUP_DIR=data\backups
set TIMESTAMP=%date:~-4,4%%date:~-10,2%%date:~-7,2%_%time:~0,2%%time:~3,2%%time:~6,2%
set TIMESTAMP=%TIMESTAMP: =0%
set BACKUP_FILE=%BACKUP_DIR%\backup_%TIMESTAMP%.zip

echo ⚡ Creando respaldo...
if not exist "%BACKUP_DIR%" mkdir "%BACKUP_DIR%"

powershell -Command "Compress-Archive -Path 'data', 'config', 'logs' -DestinationPath '%BACKUP_FILE%' -Force"

echo ✓ Respaldo creado: %BACKUP_FILE%
pause
'@ | Out-File -FilePath "scripts\backup.bat" -Encoding ASCII
    
    # Script de actualización
    @'
@echo off
REM Script de actualización para QuantumEnergyOS Mobile

echo ⚡ Actualizando QuantumEnergyOS Mobile...
git pull origin main
pip install -r requirements.txt --upgrade
echo ✓ QuantumEnergyOS Mobile actualizado
pause
'@ | Out-File -FilePath "scripts\update.bat" -Encoding ASCII
    
    Write-ColorOutput "[OK] Scripts de utilidad creados" "Green"
}

function Create-EnvFile {
    Write-ColorOutput "[INFO] Creando archivo de entorno..." "Blue"
    
    if (-not (Test-Path ".env")) {
        @'
# QuantumEnergyOS Mobile - Variables de Entorno
QUANTUM_ENERGY_MODE=production
QUANTUM_ENERGY_PORT=8080
QUANTUM_ENERGY_HOST=0.0.0.0
QUANTUM_ENERGY_DB_PATH=data/quantum_energy.db
QUANTUM_ENERGY_LOG_LEVEL=INFO
QUANTUM_ENERGY_SECRET_KEY=quantum-energy-secret-key-change-in-production
'@ | Out-File -FilePath ".env" -Encoding UTF8
        
        Write-ColorOutput "[OK] Archivo .env creado" "Green"
    } else {
        Write-ColorOutput "[WARN] Archivo .env ya existe" "Yellow"
    }
}

function Verify-Installation {
    Write-ColorOutput "[INFO] Verificando instalación..." "Blue"
    
    # Verificar archivos principales
    if (Test-Path "main.py") {
        Write-ColorOutput "[OK] main.py encontrado" "Green"
    } else {
        Write-ColorOutput "[ERROR] main.py no encontrado" "Red"
        return $false
    }
    
    if (Test-Path "api\server.py") {
        Write-ColorOutput "[OK] api\server.py encontrado" "Green"
    } else {
        Write-ColorOutput "[ERROR] api\server.py no encontrado" "Red"
        return $false
    }
    
    if (Test-Path "requirements.txt") {
        Write-ColorOutput "[OK] requirements.txt encontrado" "Green"
    } else {
        Write-ColorOutput "[WARN] requirements.txt no encontrado" "Yellow"
    }
    
    # Verificar dependencias
    try {
        python -c "import flask; import flask_socketio; import psutil; import yaml" 2>$null
        Write-ColorOutput "[OK] Dependencias de Python verificadas" "Green"
    } catch {
        Write-ColorOutput "[WARN] Algunas dependencias pueden faltar" "Yellow"
    }
    
    Write-ColorOutput "[OK] Instalación verificada" "Green"
    return $true
}

function Show-FinalInstructions {
    Write-ColorOutput ""
    Write-ColorOutput "╔══════════════════════════════════════════════════════════════╗" "Cyan"
    Write-ColorOutput "║                                                              ║" "Cyan"
    Write-ColorOutput "║   ⚡ Instalación Completada Exitosamente ⚡                  ║" "Cyan"
    Write-ColorOutput "║                                                              ║" "Cyan"
    Write-ColorOutput "╚══════════════════════════════════════════════════════════════╝" "Cyan"
    Write-ColorOutput ""
    Write-ColorOutput "Para iniciar QuantumEnergyOS Mobile:" "Green"
    Write-ColorOutput ""
    Write-ColorOutput "  Opción 1: Usar script de inicio" "White"
    Write-ColorOutput "    scripts\start.bat" "Blue"
    Write-ColorOutput ""
    Write-ColorOutput "  Opción 2: Ejecutar directamente" "White"
    Write-ColorOutput "    python main.py" "Blue"
    Write-ColorOutput ""
    Write-ColorOutput "  Opción 3: Ejecutar con modo debug" "White"
    Write-ColorOutput "    python main.py --debug" "Blue"
    Write-ColorOutput ""
    Write-ColorOutput "Dashboard disponible en:" "Green"
    Write-ColorOutput "  http://localhost:8080" "Blue"
    Write-ColorOutput ""
    Write-ColorOutput "API disponible en:" "Green"
    Write-ColorOutput "  http://localhost:8080/api" "Blue"
    Write-ColorOutput ""
    Write-ColorOutput "Para detener el sistema:" "Green"
    Write-ColorOutput "  scripts\stop.bat" "Blue"
    Write-ColorOutput "  o presiona Ctrl+C" "Blue"
    Write-ColorOutput ""
    Write-ColorOutput "Nota: Para dispositivos de bajos recursos, usa:" "Yellow"
    Write-ColorOutput "  python main.py --no-particles" "Blue"
    Write-ColorOutput ""
}

# Función principal
function Main {
    Write-Banner
    
    # Verificar si es administrador
    if (-not (Test-Administrator)) {
        Write-ColorOutput "[WARN] No se ejecuta como administrador" "Yellow"
        Write-ColorOutput "[WARN] Algunas funciones pueden no estar disponibles" "Yellow"
    }
    
    # Verificar Python
    if (-not (Test-PythonInstalled)) {
        if ($InstallPython) {
            Install-Python
        } else {
            Write-ColorOutput "[ERROR] Python no encontrado. Ejecuta con -InstallPython para instalar" "Red"
            exit 1
        }
    }
    
    # Verificar Git
    if (-not (Test-GitInstalled)) {
        Install-Git
    }
    
    # Crear directorios
    Create-Directories
    
    # Instalar dependencias
    if (-not $SkipDependencies) {
        Install-PythonDependencies
    }
    
    # Crear scripts de utilidad
    Create-UtilityScripts
    
    # Crear archivo .env
    Create-EnvFile
    
    # Verificar instalación
    if (Verify-Installation) {
        Show-FinalInstructions
    } else {
        Write-ColorOutput "[ERROR] La instalación no se completó correctamente" "Red"
        exit 1
    }
}

# Ejecutar función principal
Main
