#!/bin/bash
# ⚡ QuantumEnergyOS Mobile V.01 - Script de Instalación
# Sistema Operativo Móvil Cuántico para Gestión de Energía
# Autor: Giovanny Corpus Bernal - Mexicali, Baja California

set -e

# Colores para output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

# Banner
print_banner() {
    echo -e "${CYAN}"
    echo "╔══════════════════════════════════════════════════════════════╗"
    echo "║                                                              ║"
    echo "║   ⚡ QuantumEnergyOS Mobile V.01 ⚡                          ║"
    echo "║                                                              ║"
    echo "║   Sistema Operativo Móvil Cuántico                           ║"
    echo "║   para Gestión de Energía                                    ║"
    echo "║                                                              ║"
    echo "║   Autor: Giovanny Corpus Bernal                              ║"
    echo "║   Mexicali, Baja California, México                          ║"
    echo "║                                                              ║"
    echo "╚══════════════════════════════════════════════════════════════╝"
    echo -e "${NC}"
}

# Detectar sistema operativo
detect_os() {
    echo -e "${BLUE}[INFO]${NC} Detectando sistema operativo..."
    
    if [ -f /data/data/com.termux/files/usr/bin/bash ]; then
        OS="termux"
        echo -e "${GREEN}[OK]${NC} Sistema detectado: Termux"
    elif [ -f /usr/bin/waydroid ]; then
        OS="waydroid"
        echo -e "${GREEN}[OK]${NC} Sistema detectado: Waydroid"
    elif [ "$(uname)" == "Linux" ]; then
        OS="linux"
        echo -e "${GREEN}[OK]${NC} Sistema detectado: Linux"
    elif [ "$(uname)" == "Darwin" ]; then
        OS="macos"
        echo -e "${GREEN}[OK]${NC} Sistema detectado: macOS"
    else
        OS="unknown"
        echo -e "${YELLOW}[WARN]${NC} Sistema operativo no reconocido"
    fi
}

# Verificar dependencias
check_dependencies() {
    echo -e "${BLUE}[INFO]${NC} Verificando dependencias..."
    
    # Verificar Python
    if command -v python3 &> /dev/null; then
        PYTHON_CMD="python3"
        echo -e "${GREEN}[OK]${NC} Python3 encontrado: $(python3 --version)"
    elif command -v python &> /dev/null; then
        PYTHON_CMD="python"
        echo -e "${GREEN}[OK]${NC} Python encontrado: $(python --version)"
    else
        echo -e "${RED}[ERROR]${NC} Python no encontrado"
        install_python
    fi
    
    # Verificar pip
    if command -v pip3 &> /dev/null; then
        PIP_CMD="pip3"
        echo -e "${GREEN}[OK]${NC} pip3 encontrado"
    elif command -v pip &> /dev/null; then
        PIP_CMD="pip"
        echo -e "${GREEN}[OK]${NC} pip encontrado"
    else
        echo -e "${RED}[ERROR]${NC} pip no encontrado"
        install_pip
    fi
    
    # Verificar git
    if command -v git &> /dev/null; then
        echo -e "${GREEN}[OK]${NC} Git encontrado: $(git --version)"
    else
        echo -e "${RED}[ERROR]${NC} Git no encontrado"
        install_git
    fi
}

# Instalar Python
install_python() {
    echo -e "${BLUE}[INFO]${NC} Instalando Python..."
    
    case $OS in
        termux)
            pkg install python -y
            ;;
        linux)
            sudo apt update
            sudo apt install python3 python3-pip -y
            ;;
        macos)
            brew install python3
            ;;
        *)
            echo -e "${RED}[ERROR]${NC} No se puede instalar Python automáticamente"
            echo -e "${YELLOW}[WARN]${NC} Por favor instala Python manualmente"
            exit 1
            ;;
    esac
    
    PYTHON_CMD="python3"
    echo -e "${GREEN}[OK]${NC} Python instalado"
}

# Instalar pip
install_pip() {
    echo -e "${BLUE}[INFO]${NC} Instalando pip..."
    
    case $OS in
        termux)
            pkg install python-pip -y
            ;;
        linux)
            sudo apt install python3-pip -y
            ;;
        macos)
            python3 -m ensurepip --upgrade
            ;;
        *)
            echo -e "${RED}[ERROR]${NC} No se puede instalar pip automáticamente"
            echo -e "${YELLOW}[WARN]${NC} Por favor instala pip manualmente"
            exit 1
            ;;
    esac
    
    PIP_CMD="pip3"
    echo -e "${GREEN}[OK]${NC} pip instalado"
}

# Instalar Git
install_git() {
    echo -e "${BLUE}[INFO]${NC} Instalando Git..."
    
    case $OS in
        termux)
            pkg install git -y
            ;;
        linux)
            sudo apt install git -y
            ;;
        macos)
            brew install git
            ;;
        *)
            echo -e "${RED}[ERROR]${NC} No se puede instalar Git automáticamente"
            echo -e "${YELLOW}[WARN]${NC} Por favor instala Git manualmente"
            exit 1
            ;;
    esac
    
    echo -e "${GREEN}[OK]${NC} Git instalado"
}

# Crear directorios
create_directories() {
    echo -e "${BLUE}[INFO]${NC} Creando estructura de directorios..."
    
    mkdir -p logs
    mkdir -p data
    mkdir -p config
    mkdir -p dashboard/assets/images
    mkdir -p dashboard/assets/fonts
    mkdir -p dashboard/assets/particles
    mkdir -p scripts
    mkdir -p tests
    
    echo -e "${GREEN}[OK]${NC} Directorios creados"
}

# Instalar dependencias Python
install_python_dependencies() {
    echo -e "${BLUE}[INFO]${NC} Instalando dependencias de Python..."
    
    # Actualizar pip
    $PYTHON_CMD -m pip install --upgrade pip
    
    # Instalar dependencias
    if [ -f requirements.txt ]; then
        $PIP_CMD install -r requirements.txt
        echo -e "${GREEN}[OK]${NC} Dependencias instaladas"
    else
        echo -e "${YELLOW}[WARN]${NC} Archivo requirements.txt no encontrado"
        echo -e "${BLUE}[INFO]${NC} Instalando dependencias básicas..."
        
        $PIP_CMD install flask flask-socketio flask-cors psutil pyyaml requests
        echo -e "${GREEN}[OK]${NC} Dependencias básicas instaladas"
    fi
}

# Configurar permisos
setup_permissions() {
    echo -e "${BLUE}[INFO]${NC} Configurando permisos..."
    
    chmod +x main.py
    chmod +x install.sh
    
    if [ -f scripts/start.sh ]; then
        chmod +x scripts/start.sh
    fi
    
    if [ -f scripts/stop.sh ]; then
        chmod +x scripts/stop.sh
    fi
    
    echo -e "${GREEN}[OK]${NC} Permisos configurados"
}

# Crear scripts de utilidad
create_utility_scripts() {
    echo -e "${BLUE}[INFO]${NC} Creando scripts de utilidad..."
    
    # Script de inicio
    cat > scripts/start.sh << 'EOF'
#!/bin/bash
# Script de inicio para QuantumEnergyOS Mobile

echo "⚡ Iniciando QuantumEnergyOS Mobile..."
cd "$(dirname "$0")/.."
python3 main.py
EOF
    
    # Script de parada
    cat > scripts/stop.sh << 'EOF'
#!/bin/bash
# Script de parada para QuantumEnergyOS Mobile

echo "⚡ Deteniendo QuantumEnergyOS Mobile..."
pkill -f "python3 main.py"
pkill -f "python main.py"
echo "✓ QuantumEnergyOS Mobile detenido"
EOF
    
    # Script de respaldo
    cat > scripts/backup.sh << 'EOF'
#!/bin/bash
# Script de respaldo para QuantumEnergyOS Mobile

BACKUP_DIR="data/backups"
TIMESTAMP=$(date +%Y%m%d_%H%M%S)
BACKUP_FILE="$BACKUP_DIR/backup_$TIMESTAMP.tar.gz"

echo "⚡ Creando respaldo..."
mkdir -p "$BACKUP_DIR"

tar -czf "$BACKUP_FILE" \
    data/ \
    config/ \
    logs/ \
    2>/dev/null || true

echo "✓ Respaldo creado: $BACKUP_FILE"
EOF
    
    # Script de actualización
    cat > scripts/update.sh << 'EOF'
#!/bin/bash
# Script de actualización para QuantumEnergyOS Mobile

echo "⚡ Actualizando QuantumEnergyOS Mobile..."
git pull origin main
pip3 install -r requirements.txt --upgrade
echo "✓ QuantumEnergyOS Mobile actualizado"
EOF
    
    chmod +x scripts/*.sh
    
    echo -e "${GREEN}[OK]${NC} Scripts de utilidad creados"
}

# Crear archivo .env
create_env_file() {
    echo -e "${BLUE}[INFO]${NC} Creando archivo de entorno..."
    
    if [ ! -f .env ]; then
        cat > .env << 'EOF'
# QuantumEnergyOS Mobile - Variables de Entorno
QUANTUM_ENERGY_MODE=production
QUANTUM_ENERGY_PORT=8080
QUANTUM_ENERGY_HOST=0.0.0.0
QUANTUM_ENERGY_DB_PATH=data/quantum_energy.db
QUANTUM_ENERGY_LOG_LEVEL=INFO
QUANTUM_ENERGY_SECRET_KEY=quantum-energy-secret-key-change-in-production
EOF
        
        echo -e "${GREEN}[OK]${NC} Archivo .env creado"
    else
        echo -e "${YELLOW}[WARN]${NC} Archivo .env ya existe"
    fi
}

# Verificar instalación
verify_installation() {
    echo -e "${BLUE}[INFO]${NC} Verificando instalación..."
    
    # Verificar archivos principales
    if [ -f main.py ]; then
        echo -e "${GREEN}[OK]${NC} main.py encontrado"
    else
        echo -e "${RED}[ERROR]${NC} main.py no encontrado"
        return 1
    fi
    
    if [ -f api/server.py ]; then
        echo -e "${GREEN}[OK]${NC} api/server.py encontrado"
    else
        echo -e "${RED}[ERROR]${NC} api/server.py no encontrado"
        return 1
    fi
    
    if [ -f requirements.txt ]; then
        echo -e "${GREEN}[OK]${NC} requirements.txt encontrado"
    else
        echo -e "${YELLOW}[WARN]${NC} requirements.txt no encontrado"
    fi
    
    # Verificar dependencias
    $PYTHON_CMD -c "import flask; import flask_socketio; import psutil; import yaml" 2>/dev/null
    if [ $? -eq 0 ]; then
        echo -e "${GREEN}[OK]${NC} Dependencias de Python verificadas"
    else
        echo -e "${YELLOW}[WARN]${NC} Algunas dependencias pueden faltar"
    fi
    
    echo -e "${GREEN}[OK]${NC} Instalación verificada"
}

# Mostrar instrucciones finales
show_final_instructions() {
    echo ""
    echo -e "${CYAN}╔══════════════════════════════════════════════════════════════╗${NC}"
    echo -e "${CYAN}║                                                              ║${NC}"
    echo -e "${CYAN}║   ⚡ Instalación Completada Exitosamente ⚡                  ║${NC}"
    echo -e "${CYAN}║                                                              ║${NC}"
    echo -e "${CYAN}╚══════════════════════════════════════════════════════════════╝${NC}"
    echo ""
    echo -e "${GREEN}Para iniciar QuantumEnergyOS Mobile:${NC}"
    echo ""
    echo -e "  ${BLUE}Opción 1:${NC} Usar script de inicio"
    echo -e "    ./scripts/start.sh"
    echo ""
    echo -e "  ${BLUE}Opción 2:${NC} Ejecutar directamente"
    echo -e "    python3 main.py"
    echo ""
    echo -e "  ${BLUE}Opción 3:${NC} Ejecutar con modo debug"
    echo -e "    python3 main.py --debug"
    echo ""
    echo -e "${GREEN}Dashboard disponible en:${NC}"
    echo -e "  http://localhost:8080"
    echo ""
    echo -e "${GREEN}API disponible en:${NC}"
    echo -e "  http://localhost:8080/api"
    echo ""
    echo -e "${GREEN}Para detener el sistema:${NC}"
    echo -e "  ./scripts/stop.sh"
    echo -e "  o presiona Ctrl+C"
    echo ""
    echo -e "${YELLOW}Nota:${NC} Para dispositivos de bajos recursos, usa:"
    echo -e "  python3 main.py --no-particles"
    echo ""
}

# Función principal
main() {
    print_banner
    detect_os
    check_dependencies
    create_directories
    install_python_dependencies
    setup_permissions
    create_utility_scripts
    create_env_file
    verify_installation
    show_final_instructions
}

# Ejecutar función principal
main
