# ⚡ QuantumEnergyOS Mobile V.01 - Instrucciones de Construcción y Prueba

## 📋 Tabla de Contenido

1. [Requisitos Previos](#-requisitos-previos)
2. [Instalación en Windows](#-instalación-en-windows)
3. [Instalación en Termux (Android)](#-instalación-en-termux-android)
4. [Instalación en Waydroid](#-instalación-en-waydroid)
5. [Pruebas del Sistema](#-pruebas-del-sistema)
6. [Comandos Git Finales](#-comandos-git-finales)
7. [Solución de Problemas](#-solución-de-problemas)

---

## 🖥️ Requisitos Previos

### Windows
- Windows 10/11 (64-bit)
- Python 3.11 o superior
- Git 2.40 o superior
- PowerShell 5.1 o superior
- 2 GB de RAM mínimo (recomendado 4 GB)
- 1 GB de espacio en disco

### Android (Termux)
- Android 8.0 o superior
- Termux (desde F-Droid)
- 1 GB de RAM mínimo
- 500 MB de espacio en disco

### Linux (Waydroid)
- Ubuntu 20.04 o superior
- Waydroid instalado
- 2 GB de RAM mínimo
- 2 GB de espacio en disco

---

## 🚀 Instalación en Windows

### Paso 1: Descargar el Proyecto

```powershell
# Opción 1: Clonar desde GitHub
git clone https://github.com/GiovannyCorpus/QuantumEnergyOS-Mobile.git
cd QuantumEnergyOS-Mobile

# Opción 2: Descargar ZIP y extraer
# Descargar desde: https://github.com/GiovannyCorpus/QuantumEnergyOS-Mobile/releases
```

### Paso 2: Ejecutar Script de Instalación

```powershell
# Abrir PowerShell como administrador
# Navegar al directorio del proyecto
cd C:\Users\HP\Documents\Documentos Personales GACB\Demo\QuantumEnergyOS-Mobile-V.01

# Ejecutar script de instalación
.\setup.ps1

# O con opciones adicionales:
.\setup.ps1 -InstallPython
.\setup.ps1 -Debug
```

### Paso 3: Verificar Instalación

```powershell
# Verificar Python
python --version

# Verificar pip
pip --version

# Verificar dependencias
pip list | Select-String "flask|psutil|pyyaml"
```

### Paso 4: Iniciar el Sistema

```powershell
# Opción 1: Usar script de inicio
.\scripts\start.bat

# Opción 2: Ejecutar directamente
python main.py

# Opción 3: Ejecutar con modo debug
python main.py --debug

# Opción 4: Ejecutar sin partículas (para dispositivos lentos)
python main.py --no-particles
```

### Paso 5: Acceder al Dashboard

1. Abrir navegador web
2. Navegar a: `http://localhost:8080`
3. El dashboard debería cargar automáticamente

---

## 📱 Instalación en Termux (Android)

### Paso 1: Instalar Termux

1. Descargar Termux desde F-Droid: https://f-droid.org/en/packages/com.termux/
2. Instalar el APK
3. Abrir Termux

### Paso 2: Actualizar Paquetes

```bash
pkg update && pkg upgrade -y
```

### Paso 3: Instalar Dependencias

```bash
pkg install python git wget curl -y
```

### Paso 4: Clonar Proyecto

```bash
git clone https://github.com/GiovannyCorpus/QuantumEnergyOS-Mobile.git
cd QuantumEnergyOS-Mobile
```

### Paso 5: Ejecutar Instalador

```bash
chmod +x install.sh
./install.sh
```

### Paso 6: Iniciar Sistema

```bash
python main.py
```

### Paso 7: Acceder al Dashboard

1. Abrir navegador en Android
2. Navegar a: `http://localhost:8080`
3. O desde otro dispositivo en la misma red: `http://<IP_DEL_DISPOSITIVO>:8080`

---

## 🐧 Instalación en Waydroid

### Paso 1: Instalar Waydroid

```bash
# Ubuntu/Debian
sudo apt update
sudo apt install waydroid -y

# Inicializar Waydroid
sudo waydroid init
```

### Paso 2: Iniciar Waydroid

```bash
waydroid session start
```

### Paso 3: Instalar QuantumEnergyOS

```bash
# En otra terminal
git clone https://github.com/GiovannyCorpus/QuantumEnergyOS-Mobile.git
cd QuantumEnergyOS-Mobile

# Instalar dependencias
sudo apt install python3 python3-pip git -y
pip3 install -r requirements.txt

# Iniciar sistema
python3 main.py
```

### Paso 4: Acceder al Dashboard

```bash
# Desde el host
http://localhost:8080

# O desde Waydroid
http://192.168.240.1:8080
```

---

## 🧪 Pruebas del Sistema

### Prueba 1: Verificar API

```bash
# En PowerShell o terminal
curl http://localhost:8080/api/status

# Respuesta esperada:
# {"status":"online","system":"QuantumEnergyOS Mobile","version":"0.1.0"}
```

### Prueba 2: Verificar Métricas de Energía

```bash
curl http://localhost:8080/api/energy

# Respuesta esperada:
# {"voltage":220.5,"current":10.2,"power":2249.1,"frequency":60.0}
```

### Prueba 3: Verificar Dashboard

1. Abrir navegador
2. Navegar a: `http://localhost:8080`
3. Verificar que:
   - Las partículas cuánticas se animan
   - Las métricas se actualizan en tiempo real
   - El gráfico muestra datos
   - Las alertas se muestran

### Prueba 4: Verificar WebSocket

```bash
# Instalar wscat (opcional)
npm install -g wscat

# Conectar a WebSocket
wscat -c ws://localhost:8080/ws/realtime

# Debería recibir datos en tiempo real
```

### Prueba 5: Verificar Optimización

```bash
curl -X POST http://localhost:8080/api/energy/optimize

# Respuesta esperada:
# {"success":true,"message":"Optimización completada","reduction":8.5}
```

### Prueba 6: Verificar Alertas

```bash
curl http://localhost:8080/api/alerts

# Respuesta esperada:
# {"alerts":[],"count":0}
```

### Prueba 7: Verificar Sistema

```bash
curl http://localhost:8080/api/system/info

# Respuesta esperada:
# {"platform":"Windows","architecture":"AMD64","python_version":"3.11.7"}
```

---

## 🔧 Comandos Git Finales

### Inicializar Repositorio (si no existe)

```bash
cd Documentos\ Personales\ GACB/Demo/QuantumEnergyOS-Mobile-V.01

# Inicializar Git
git init

# Configurar usuario
git config user.name "Giovanny Corpus Bernal"
git config user.email "giovanny.corpus@example.com"
```

### Agregar Archivos

```bash
# Agregar todos los archivos
git add .

# Verificar archivos agregados
git status
```

### Hacer Commit

```bash
# Commit inicial
git commit -m "⚡ QuantumEnergyOS Mobile V.01 - Release Inicial

Sistema Operativo Móvil Cuántico para Gestión de Energía

Características:
- Dashboard en tiempo real con partículas cuánticas azules
- API REST completa para monitoreo de energía
- Sistema de alertas y prevención de apagones
- Soporte para Termux, Waydroid, Magisk y PWA
- Optimizado para dispositivos de bajos recursos (1-2 GB RAM)
- Tema visual inspirado en el desierto de Mexicali

Autor: Giovanny Corpus Bernal
Ubicación: Mexicali, Baja California, México
Fecha: 2026-04-01"
```

### Crear Rama de Release

```bash
# Crear rama para release
git checkout -b release/v0.1.0

# Cambiar a rama main
git checkout main
```

### Agregar Remote (si es necesario)

```bash
# Agregar remote de GitHub
git remote add origin https://github.com/GiovannyCorpus/QuantumEnergyOS-Mobile.git

# Verificar remote
git remote -v
```

### Push a GitHub

```bash
# Push a rama main
git push -u origin main

# Push a rama release
git push origin release/v0.1.0

# Push tags
git tag -a v0.1.0 -m "Release v0.1.0 - QuantumEnergyOS Mobile"
git push origin v0.1.0
```

### Crear Release en GitHub

```bash
# Usando GitHub CLI (si está instalado)
gh release create v0.1.0 \
  --title "QuantumEnergyOS Mobile v0.1.0" \
  --notes "Release inicial de QuantumEnergyOS Mobile" \
  --repo GiovannyCorpus/QuantumEnergyOS-Mobile
```

---

## 🐛 Solución de Problemas

### Problema 1: Python no encontrado

**Solución:**
```powershell
# Windows
# Descargar Python desde: https://www.python.org/downloads/
# Marcar "Add Python to PATH" durante instalación

# Linux/Termux
pkg install python -y
# o
sudo apt install python3 -y
```

### Problema 2: pip no encontrado

**Solución:**
```powershell
# Windows
python -m ensurepip --upgrade

# Linux/Termux
pkg install python-pip -y
# o
sudo apt install python3-pip -y
```

### Problema 3: Error al instalar dependencias

**Solución:**
```bash
# Actualizar pip
python -m pip install --upgrade pip

# Instalar dependencias una por una
pip install flask
pip install flask-socketio
pip install psutil
pip install pyyaml
pip install requests
```

### Problema 4: Puerto 8080 en uso

**Solución:**
```bash
# Cambiar puerto
python main.py --port 9090

# O en configuración
# Editar config/quantum-energy.yaml
# Cambiar port: 8080 a port: 9090
```

### Problema 5: Dashboard no carga

**Solución:**
1. Verificar que el servidor está corriendo
2. Verificar que el puerto es correcto
3. Verificar que no hay firewall bloqueando
4. Intentar acceder desde: `http://127.0.0.1:8080`

### Problema 6: Partículas no se animan

**Solución:**
```bash
# Ejecutar sin partículas
python main.py --no-particles

# O verificar que WebGL está habilitado en el navegador
```

### Problema 7: Error de memoria

**Solución:**
```bash
# Ejecutar en modo de bajos recursos
python main.py --no-particles

# O reducir partículas en configuración
# Editar config/quantum-energy.yaml
# Cambiar particles: 100 a particles: 50
```

### Problema 8: WebSocket no conecta

**Solución:**
1. Verificar que el servidor soporta WebSocket
2. Verificar que no hay proxy bloqueando
3. Intentar reconectar automáticamente (el sistema lo hace)

---

## 📊 Comandos Útiles

### Monitoreo del Sistema

```bash
# Ver logs en tiempo real
tail -f logs/quantum_energy.log

# Ver procesos
ps aux | grep python

# Ver uso de memoria
free -h

# Ver uso de disco
df -h
```

### Gestión del Sistema

```bash
# Detener sistema
./scripts/stop.sh

# Reiniciar sistema
./scripts/stop.sh && ./scripts/start.sh

# Crear respaldo
./scripts/backup.sh

# Actualizar sistema
./scripts/update.sh
```

### API REST

```bash
# Estado del sistema
curl http://localhost:8080/api/status

# Métricas de energía
curl http://localhost:8080/api/energy

# Historial de energía
curl http://localhost:8080/api/energy/history?hours=24

# Alertas
curl http://localhost:8080/api/alerts

# Optimizar energía
curl -X POST http://localhost:8080/api/energy/optimize

# Información del sistema
curl http://localhost:8080/api/system/info
```

---

## 📝 Notas Importantes

1. **Primera Ejecución**: La primera ejecución puede tardar más tiempo mientras se instalan las dependencias.

2. **Firewall**: Si accedes desde otro dispositivo, asegúrate de que el puerto 8080 esté abierto en el firewall.

3. **Rendimiento**: Para dispositivos con 1 GB de RAM, usa la opción `--no-particles`.

4. **Datos**: Los datos se almacenan en el directorio `data/`. Haz respaldos regulares.

5. **Logs**: Los logs se almacenan en el directorio `logs/`. Úsalos para debugging.

6. **Configuración**: La configuración está en `config/quantum-energy.yaml`. Edítala según tus necesidades.

7. **Actualizaciones**: El sistema verifica actualizaciones automáticamente cada 24 horas.

8. **Soporte**: Para problemas, abre un issue en: https://github.com/GiovannyCorpus/QuantumEnergyOS-Mobile/issues

---

## 🎯 Próximos Pasos

1. **Personalizar Configuración**: Edita `config/quantum-energy.yaml` según tus necesidades
2. **Configurar Alertas**: Ajusta los umbrales de alerta en la configuración
3. **Conectar Sensores**: Integra sensores de energía reales
4. **Desplegar en Producción**: Usa el script `scripts/deploy.sh`
5. **Monitorear Sistema**: Revisa los logs regularmente

---

**⚡ QuantumEnergyOS Mobile - Energía Cuántica en tu Mano ⚡**

*Hecho con ❤️ en Mexicali, Baja California*

*Autor: Giovanny Corpus Bernal*
