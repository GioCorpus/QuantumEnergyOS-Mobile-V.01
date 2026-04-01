#!/bin/bash
# ⚡ QuantumEnergyOS Mobile V.01 - Script de Deploy
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
echo "║   ⚡ QuantumEnergyOS Mobile - Deploy Script ⚡               ║"
echo "║                                                              ║"
echo "╚══════════════════════════════════════════════════════════════╝"
echo -e "${NC}"

# Configuración
VERSION="0.1.0"
REPO_NAME="QuantumEnergyOS-Mobile"
GITHUB_USER="GiovannyCorpus"
DIST_DIR="dist"

echo -e "${BLUE}[INFO]${NC} Iniciando deploy de QuantumEnergyOS Mobile v${VERSION}"

# Verificar que existe el paquete
if [ ! -f "${DIST_DIR}/QuantumEnergyOS-Mobile-${VERSION}.tar.gz" ]; then
    echo -e "${RED}[ERROR]${NC} Paquete no encontrado. Ejecuta build.sh primero"
    exit 1
fi

# Verificar Git
if ! command -v git &> /dev/null; then
    echo -e "${RED}[ERROR]${NC} Git no encontrado"
    exit 1
fi

# Verificar GitHub CLI (opcional)
if command -v gh &> /dev/null; then
    HAS_GH=true
    echo -e "${GREEN}[OK]${NC} GitHub CLI encontrado"
else
    HAS_GH=false
    echo -e "${YELLOW}[WARN]${NC} GitHub CLI no encontrado (opcional)"
fi

# Opciones de deploy
echo ""
echo -e "${BLUE}Selecciona método de deploy:${NC}"
echo -e "  1) GitHub Releases"
echo -e "  2) GitHub Pages"
echo -e "  3) Servidor propio (rsync)"
echo -e "  4) Docker Hub"
echo -e "  5) Todos"
echo ""
read -p "Opción [1-5]: " DEPLOY_OPTION

case $DEPLOY_OPTION in
    1)
        deploy_github_releases
        ;;
    2)
        deploy_github_pages
        ;;
    3)
        deploy_server
        ;;
    4)
        deploy_docker
        ;;
    5)
        deploy_github_releases
        deploy_github_pages
        deploy_server
        deploy_docker
        ;;
    *)
        echo -e "${RED}[ERROR]${NC} Opción no válida"
        exit 1
        ;;
esac

# Función: GitHub Releases
deploy_github_releases() {
    echo -e "${BLUE}[INFO]${NC} Desplegando a GitHub Releases..."
    
    if [ "$HAS_GH" = true ]; then
        # Crear release con GitHub CLI
        gh release create "v${VERSION}" \
            "${DIST_DIR}/QuantumEnergyOS-Mobile-${VERSION}.tar.gz" \
            "${DIST_DIR}/QuantumEnergyOS-Mobile-${VERSION}.zip" \
            --title "QuantumEnergyOS Mobile v${VERSION}" \
            --notes "Release de QuantumEnergyOS Mobile v${VERSION}" \
            --repo "${GITHUB_USER}/${REPO_NAME}"
        
        echo -e "${GREEN}[OK]${NC} Release creado en GitHub"
    else
        echo -e "${YELLOW}[WARN]${NC] GitHub CLI no disponible"
        echo -e "${BLUE}[INFO]${NC} Sube manualmente a:"
        echo -e "  https://github.com/${GITHUB_USER}/${REPO_NAME}/releases/new"
    fi
}

# Función: GitHub Pages
deploy_github_pages() {
    echo -e "${BLUE}[INFO]${NC} Desplegando a GitHub Pages..."
    
    # Crear rama gh-pages si no existe
    if ! git show-ref --verify --quiet refs/heads/gh-pages; then
        git checkout --orphan gh-pages
        git rm -rf .
    else
        git checkout gh-pages
    fi
    
    # Copiar archivos del dashboard
    cp -r dashboard/* .
    cp README.md .
    
    # Crear index.html redirigiendo al dashboard
    cat > index.html << 'EOF'
<!DOCTYPE html>
<html>
<head>
    <meta http-equiv="refresh" content="0; url=dashboard/index.html">
</head>
<body>
    <p>Redirigiendo al dashboard...</p>
</body>
</html>
EOF
    
    # Commit y push
    git add .
    git commit -m "Deploy dashboard v${VERSION}"
    git push origin gh-pages
    
    # Volver a main
    git checkout main
    
    echo -e "${GREEN}[OK]${NC} Dashboard desplegado en GitHub Pages"
    echo -e "${BLUE}[INFO]${NC} URL: https://${GITHUB_USER}.github.io/${REPO_NAME}"
}

# Función: Servidor propio
deploy_server() {
    echo -e "${BLUE}[INFO]${NC} Desplegando a servidor propio..."
    
    read -p "Host del servidor: " SERVER_HOST
    read -p "Usuario: " SERVER_USER
    read -p "Ruta remota: " SERVER_PATH
    
    if [ -z "$SERVER_HOST" ] || [ -z "$SERVER_USER" ] || [ -z "$SERVER_PATH" ]; then
        echo -e "${RED}[ERROR]${NC} Datos del servidor incompletos"
        return 1
    fi
    
    # Subir paquete
    echo -e "${BLUE}[INFO]${NC} Subiendo paquete..."
    scp "${DIST_DIR}/QuantumEnergyOS-Mobile-${VERSION}.tar.gz" \
        "${SERVER_USER}@${SERVER_HOST}:${SERVER_PATH}/"
    
    # Extraer en servidor
    echo -e "${BLUE}[INFO]${NC} Extrayendo en servidor..."
    ssh "${SERVER_USER}@${SERVER_HOST}" \
        "cd ${SERVER_PATH} && tar -xzf QuantumEnergyOS-Mobile-${VERSION}.tar.gz"
    
    echo -e "${GREEN}[OK]${NC} Desplegado en servidor"
    echo -e "${BLUE}[INFO]${NC} URL: http://${SERVER_HOST}:8080"
}

# Función: Docker Hub
deploy_docker() {
    echo -e "${BLUE}[INFO]${NC} Desplegando a Docker Hub..."
    
    # Verificar Docker
    if ! command -v docker &> /dev/null; then
        echo -e "${RED}[ERROR]${NC} Docker no encontrado"
        return 1
    fi
    
    # Crear Dockerfile si no existe
    if [ ! -f Dockerfile ]; then
        cat > Dockerfile << 'EOF'
FROM python:3.11-slim

WORKDIR /app

COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

COPY . .

EXPOSE 8080

CMD ["python", "main.py"]
EOF
    fi
    
    # Build imagen
    echo -e "${BLUE}[INFO]${NC} Construyendo imagen Docker..."
    docker build -t "${GITHUB_USER}/${REPO_NAME}:${VERSION}" .
    docker tag "${GITHUB_USER}/${REPO_NAME}:${VERSION}" "${GITHUB_USER}/${REPO_NAME}:latest"
    
    # Push a Docker Hub
    echo -e "${BLUE}[INFO]${NC} Subiendo a Docker Hub..."
    docker push "${GITHUB_USER}/${REPO_NAME}:${VERSION}"
    docker push "${GITHUB_USER}/${REPO_NAME}:latest"
    
    echo -e "${GREEN}[OK]${NC} Desplegado en Docker Hub"
    echo -e "${BLUE}[INFO]${NC} Imagen: ${GITHUB_USER}/${REPO_NAME}:${VERSION}"
}

# Resumen final
echo ""
echo -e "${CYAN}╔══════════════════════════════════════════════════════════════╗${NC}"
echo -e "${CYAN}║                                                              ║${NC}"
echo -e "${CYAN}║   ⚡ Deploy Completado Exitosamente ⚡                       ║${NC}"
echo -e "${CYAN}║                                                              ║${NC}"
echo -e "${CYAN}╚══════════════════════════════════════════════════════════════╝${NC}"
echo ""
echo -e "${GREEN}Enlaces útiles:${NC}"
echo -e "  📦 GitHub: https://github.com/${GITHUB_USER}/${REPO_NAME}"
echo -e "  🌐 Dashboard: https://${GITHUB_USER}.github.io/${REPO_NAME}"
echo -e "  🐳 Docker: https://hub.docker.com/r/${GITHUB_USER}/${REPO_NAME}"
echo ""
