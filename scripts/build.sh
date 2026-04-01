#!/bin/bash
# ⚡ QuantumEnergyOS Mobile V.01 - Script de Build
# Sistema Operativo Móvil Cuántico para Gestión de Energía
# Autor: Giovanny Corpus Bernal - Mexicali, Baja California

set -e

# Colores
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m'

# Banner
echo -e "${CYAN}"
echo "╔══════════════════════════════════════════════════════════════╗"
echo "║                                                              ║"
echo "║   ⚡ QuantumEnergyOS Mobile - Build Script ⚡                ║"
echo "║                                                              ║"
echo "╚══════════════════════════════════════════════════════════════╝"
echo -e "${NC}"

# Configuración
VERSION="0.1.0"
BUILD_DIR="build"
DIST_DIR="dist"
PACKAGE_NAME="QuantumEnergyOS-Mobile-${VERSION}"

echo -e "${BLUE}[INFO]${NC} Iniciando build de QuantumEnergyOS Mobile v${VERSION}"

# Limpiar builds anteriores
echo -e "${BLUE}[INFO]${NC} Limpiando builds anteriores..."
rm -rf "${BUILD_DIR}"
rm -rf "${DIST_DIR}"
mkdir -p "${BUILD_DIR}"
mkdir -p "${DIST_DIR}"

# Verificar dependencias
echo -e "${BLUE}[INFO]${NC} Verificando dependencias..."
if ! command -v python3 &> /dev/null; then
    echo -e "${RED}[ERROR]${NC} Python3 no encontrado"
    exit 1
fi

if ! command -v pip3 &> /dev/null; then
    echo -e "${RED}[ERROR]${NC} pip3 no encontrado"
    exit 1
fi

# Crear estructura de build
echo -e "${BLUE}[INFO]${NC} Creando estructura de build..."
mkdir -p "${BUILD_DIR}/${PACKAGE_NAME}"
mkdir -p "${BUILD_DIR}/${PACKAGE_NAME}/api"
mkdir -p "${BUILD_DIR}/${PACKAGE_NAME}/dashboard"
mkdir -p "${BUILD_DIR}/${PACKAGE_NAME}/config"
mkdir -p "${BUILD_DIR}/${PACKAGE_NAME}/scripts"
mkdir -p "${BUILD_DIR}/${PACKAGE_NAME}/logs"
mkdir -p "${BUILD_DIR}/${PACKAGE_NAME}/data"

# Copiar archivos principales
echo -e "${BLUE}[INFO]${NC} Copiando archivos principales..."
cp main.py "${BUILD_DIR}/${PACKAGE_NAME}/"
cp requirements.txt "${BUILD_DIR}/${PACKAGE_NAME}/"
cp README.md "${BUILD_DIR}/${PACKAGE_NAME}/"
cp install.sh "${BUILD_DIR}/${PACKAGE_NAME}/"
cp setup.ps1 "${BUILD_DIR}/${PACKAGE_NAME}/"

# Copiar API
echo -e "${BLUE}[INFO]${NC} Copiando API..."
cp api/server.py "${BUILD_DIR}/${PACKAGE_NAME}/api/"

# Copiar Dashboard
echo -e "${BLUE}[INFO]${NC} Copiando Dashboard..."
cp dashboard/index.html "${BUILD_DIR}/${PACKAGE_NAME}/dashboard/"
cp dashboard/style.css "${BUILD_DIR}/${PACKAGE_NAME}/dashboard/"
cp dashboard/app.js "${BUILD_DIR}/${PACKAGE_NAME}/dashboard/"

# Copiar configuración
echo -e "${BLUE}[INFO]${NC} Copiando configuración..."
cp config/quantum-energy.yaml "${BUILD_DIR}/${PACKAGE_NAME}/config/"
cp config/termux.conf "${BUILD_DIR}/${PACKAGE_NAME}/config/"
cp config/waydroid.conf "${BUILD_DIR}/${PACKAGE_NAME}/config/"

# Copiar scripts
echo -e "${BLUE}[INFO]${NC} Copiando scripts..."
cp scripts/*.sh "${BUILD_DIR}/${PACKAGE_NAME}/scripts/" 2>/dev/null || true
cp scripts/*.bat "${BUILD_DIR}/${PACKAGE_NAME}/scripts/" 2>/dev/null || true

# Crear archivo .env
echo -e "${BLUE}[INFO]${NC} Creando archivo .env..."
cat > "${BUILD_DIR}/${PACKAGE_NAME}/.env" << 'EOF'
# QuantumEnergyOS Mobile - Variables de Entorno
QUANTUM_ENERGY_MODE=production
QUANTUM_ENERGY_PORT=8080
QUANTUM_ENERGY_HOST=0.0.0.0
QUANTUM_ENERGY_DB_PATH=data/quantum_energy.db
QUANTUM_ENERGY_LOG_LEVEL=INFO
QUANTUM_ENERGY_SECRET_KEY=quantum-energy-secret-key-change-in-production
EOF

# Crear archivo .gitignore
echo -e "${BLUE}[INFO]${NC} Creando .gitignore..."
cat > "${BUILD_DIR}/${PACKAGE_NAME}/.gitignore" << 'EOF'
# QuantumEnergyOS Mobile - .gitignore

# Python
__pycache__/
*.py[cod]
*$py.class
*.so
.Python
build/
develop-eggs/
dist/
downloads/
eggs/
.eggs/
lib/
lib64/
parts/
sdist/
var/
wheels/
*.egg-info/
.installed.cfg
*.egg

# Entorno virtual
venv/
env/
ENV/

# IDE
.vscode/
.idea/
*.swp
*.swo
*~

# Logs
logs/
*.log

# Datos
data/
*.db
*.sqlite

# Backup
backups/
*.bak
*.backup

# Archivos del sistema
.DS_Store
Thumbs.db

# Variables de entorno
.env
.env.local
.env.production

# Build
build/
dist/
*.tar.gz
*.zip
EOF

# Crear archivo LICENSE
echo -e "${BLUE}[INFO]${NC} Creando LICENSE..."
cat > "${BUILD_DIR}/${PACKAGE_NAME}/LICENSE" << 'EOF'
MIT License

Copyright (c) 2026 Giovanny Corpus Bernal

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.
EOF

# Crear paquete
echo -e "${BLUE}[INFO]${NC} Creando paquete..."
cd "${BUILD_DIR}"
tar -czf "../${DIST_DIR}/${PACKAGE_NAME}.tar.gz" "${PACKAGE_NAME}"
cd ..

# Crear paquete ZIP (para Windows)
echo -e "${BLUE}[INFO]${NC} Creando paquete ZIP..."
cd "${BUILD_DIR}"
zip -r "../${DIST_DIR}/${PACKAGE_NAME}.zip" "${PACKAGE_NAME}"
cd ..

# Calcular tamaño
PACKAGE_SIZE=$(du -h "${DIST_DIR}/${PACKAGE_NAME}.tar.gz" | cut -f1)
PACKAGE_SIZE_ZIP=$(du -h "${DIST_DIR}/${PACKAGE_NAME}.zip" | cut -f1)

# Verificar integridad
echo -e "${BLUE}[INFO]${NC} Verificando integridad..."
tar -tzf "${DIST_DIR}/${PACKAGE_NAME}.tar.gz" > /dev/null 2>&1
if [ $? -eq 0 ]; then
    echo -e "${GREEN}[OK]${NC} Paquete tar.gz verificado"
else
    echo -e "${RED}[ERROR]${NC} Paquete tar.gz corrupto"
    exit 1
fi

# Mostrar resumen
echo ""
echo -e "${CYAN}╔══════════════════════════════════════════════════════════════╗${NC}"
echo -e "${CYAN}║                                                              ║${NC}"
echo -e "${CYAN}║   ⚡ Build Completado Exitosamente ⚡                        ║${NC}"
echo -e "${CYAN}║                                                              ║${NC}"
echo -e "${CYAN}╚══════════════════════════════════════════════════════════════╝${NC}"
echo ""
echo -e "${GREEN}Paquetes generados:${NC}"
echo -e "  📦 ${DIST_DIR}/${PACKAGE_NAME}.tar.gz (${PACKAGE_SIZE})"
echo -e "  📦 ${DIST_DIR}/${PACKAGE_NAME}.zip (${PACKAGE_SIZE_ZIP})"
echo ""
echo -e "${GREEN}Para distribuir:${NC}"
echo -e "  1. Subir a GitHub Releases"
echo -e "  2. Subir a servidor de descargas"
echo -e "  3. Compartir directamente"
echo ""
echo -e "${GREEN}Para instalar:${NC}"
echo -e "  tar -xzf ${PACKAGE_NAME}.tar.gz"
echo -e "  cd ${PACKAGE_NAME}"
echo -e "  ./install.sh"
echo ""
