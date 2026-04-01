#!/usr/bin/env python3
"""
⚡ QuantumEnergyOS Mobile V.01
Sistema Operativo Móvil Cuántico para Gestión de Energía

Autor: Giovanny Corpus Bernal
Ubicación: Mexicali, Baja California, México
Licencia: MIT
"""

import os
import sys
import time
import signal
import logging
import argparse
import threading
from pathlib import Path
from datetime import datetime

# Configuración de logging
logging.basicConfig(
    level=logging.INFO,
    format='%(asctime)s - %(name)s - %(levelname)s - %(message)s',
    handlers=[
        logging.FileHandler('logs/quantum_energy.log'),
        logging.StreamHandler(sys.stdout)
    ]
)
logger = logging.getLogger('QuantumEnergyOS')

# Colores para terminal
class Colors:
    BLUE = '\033[94m'
    CYAN = '\033[96m'
    GREEN = '\033[92m'
    YELLOW = '\033[93m'
    RED = '\033[91m'
    MAGENTA = '\033[95m'
    WHITE = '\033[97m'
    RESET = '\033[0m'
    BOLD = '\033[1m'
    UNDERLINE = '\033[4m'

def print_banner():
    """Imprime el banner de QuantumEnergyOS Mobile"""
    banner = f"""
{Colors.CYAN}{Colors.BOLD}
    ╔══════════════════════════════════════════════════════════════╗
    ║                                                              ║
    ║   ⚡ QuantumEnergyOS Mobile V.01 ⚡                          ║
    ║                                                              ║
    ║   Sistema Operativo Móvil Cuántico                           ║
    ║   para Gestión de Energía                                    ║
    ║                                                              ║
    ║   Autor: Giovanny Corpus Bernal                              ║
    ║   Mexicali, Baja California, México                          ║
    ║                                                              ║
    ╚══════════════════════════════════════════════════════════════╝
{Colors.RESET}
"""
    print(banner)

def print_quantum_particles():
    """Simula partículas cuánticas azules en el terminal"""
    particles = ['●', '○', '◉', '◎', '◌', '◍', '◐', '◑', '◒', '◓']
    colors = [Colors.BLUE, Colors.CYAN, Colors.WHITE]
    
    for i in range(20):
        particle = particles[i % len(particles)]
        color = colors[i % len(colors)]
        spaces = ' ' * (i % 10)
        print(f"{spaces}{color}{particle}{Colors.RESET}", end='')
        time.sleep(0.05)
    print()

def check_dependencies():
    """Verifica que las dependencias estén instaladas"""
    logger.info("Verificando dependencias...")
    
    required_packages = [
        'flask',
        'flask_socketio',
        'psutil',
        'pyyaml',
        'requests'
    ]
    
    missing_packages = []
    
    for package in required_packages:
        try:
            __import__(package.replace('-', '_'))
            logger.info(f"✓ {package} encontrado")
        except ImportError:
            missing_packages.append(package)
            logger.warning(f"✗ {package} no encontrado")
    
    if missing_packages:
        logger.error(f"Paquetes faltantes: {', '.join(missing_packages)}")
        logger.info("Ejecuta: pip install -r requirements.txt")
        return False
    
    logger.info("Todas las dependencias están instaladas")
    return True

def create_directories():
    """Crea los directorios necesarios"""
    directories = [
        'logs',
        'data',
        'config',
        'dashboard/assets/images',
        'dashboard/assets/fonts',
        'dashboard/assets/particles'
    ]
    
    for directory in directories:
        Path(directory).mkdir(parents=True, exist_ok=True)
        logger.info(f"Directorio creado/verificado: {directory}")

def load_config():
    """Carga la configuración del sistema"""
    config_path = Path('config/quantum-energy.yaml')
    
    if not config_path.exists():
        logger.warning("Archivo de configuración no encontrado, usando valores por defecto")
        return {
            'system': {
                'name': 'QuantumEnergyOS Mobile',
                'version': '0.1.0',
                'mode': 'production'
            },
            'energy': {
                'monitoring_interval': 1,
                'alert_threshold': 85,
                'auto_optimize': True
            },
            'ui': {
                'theme': 'quantum-blue',
                'particles': True,
                'animations': True,
                'glow_intensity': 0.8
            },
            'api': {
                'host': '0.0.0.0',
                'port': 8080,
                'debug': False
            }
        }
    
    try:
        import yaml
        with open(config_path, 'r') as f:
            config = yaml.safe_load(f)
        logger.info("Configuración cargada exitosamente")
        return config
    except Exception as e:
        logger.error(f"Error al cargar configuración: {e}")
        return None

def start_api_server(config):
    """Inicia el servidor API"""
    try:
        from api.server import create_app, start_server
        
        logger.info("Iniciando servidor API...")
        app = create_app(config)
        
        api_thread = threading.Thread(
            target=start_server,
            args=(app, config['api']['host'], config['api']['port']),
            daemon=True
        )
        api_thread.start()
        
        logger.info(f"Servidor API iniciado en {config['api']['host']}:{config['api']['port']}")
        return True
    except Exception as e:
        logger.error(f"Error al iniciar servidor API: {e}")
        return False

def start_energy_monitor(config):
    """Inicia el monitor de energía"""
    try:
        from core.energy_monitor import EnergyMonitor
        
        logger.info("Iniciando monitor de energía...")
        monitor = EnergyMonitor(config)
        
        monitor_thread = threading.Thread(
            target=monitor.start,
            daemon=True
        )
        monitor_thread.start()
        
        logger.info("Monitor de energía iniciado")
        return monitor
    except Exception as e:
        logger.error(f"Error al iniciar monitor de energía: {e}")
        return None

def start_quantum_engine(config):
    """Inicia el motor cuántico"""
    try:
        from core.quantum_engine import QuantumEngine
        
        logger.info("Iniciando motor cuántico...")
        engine = QuantumEngine(config)
        
        engine_thread = threading.Thread(
            target=engine.start,
            daemon=True
        )
        engine_thread.start()
        
        logger.info("Motor cuántico iniciado")
        return engine
    except Exception as e:
        logger.error(f"Error al iniciar motor cuántico: {e}")
        return None

def start_dashboard(config):
    """Inicia el dashboard web"""
    try:
        import webbrowser
        
        dashboard_url = f"http://localhost:{config['api']['port']}"
        logger.info(f"Dashboard disponible en: {dashboard_url}")
        
        # Abrir navegador automáticamente
        webbrowser.open(dashboard_url)
        
        return True
    except Exception as e:
        logger.error(f"Error al iniciar dashboard: {e}")
        return False

def signal_handler(signum, frame):
    """Maneja señales del sistema"""
    logger.info(f"Señal recibida: {signum}")
    logger.info("Cerrando QuantumEnergyOS Mobile...")
    sys.exit(0)

def main():
    """Función principal"""
    # Configurar manejo de señales
    signal.signal(signal.SIGINT, signal_handler)
    signal.signal(signal.SIGTERM, signal_handler)
    
    # Parsear argumentos
    parser = argparse.ArgumentParser(
        description='QuantumEnergyOS Mobile - Sistema Operativo Móvil Cuántico'
    )
    parser.add_argument(
        '--debug',
        action='store_true',
        help='Ejecutar en modo debug'
    )
    parser.add_argument(
        '--port',
        type=int,
        default=8080,
        help='Puerto del servidor API (default: 8080)'
    )
    parser.add_argument(
        '--host',
        type=str,
        default='0.0.0.0',
        help='Host del servidor API (default: 0.0.0.0)'
    )
    parser.add_argument(
        '--no-browser',
        action='store_true',
        help='No abrir navegador automáticamente'
    )
    parser.add_argument(
        '--no-particles',
        action='store_true',
        help='Desactivar partículas cuánticas'
    )
    
    args = parser.parse_args()
    
    # Imprimir banner
    print_banner()
    
    # Imprimir partículas cuánticas
    if not args.no_particles:
        print_quantum_particles()
    
    # Verificar dependencias
    if not check_dependencies():
        logger.error("No se pueden verificar las dependencias")
        sys.exit(1)
    
    # Crear directorios
    create_directories()
    
    # Cargar configuración
    config = load_config()
    if config is None:
        logger.error("No se pudo cargar la configuración")
        sys.exit(1)
    
    # Actualizar configuración con argumentos
    if args.debug:
        config['system']['mode'] = 'debug'
        config['api']['debug'] = True
        logging.getLogger().setLevel(logging.DEBUG)
    
    config['api']['port'] = args.port
    config['api']['host'] = args.host
    
    # Mostrar información del sistema
    logger.info(f"Sistema: {config['system']['name']} v{config['system']['version']}")
    logger.info(f"Modo: {config['system']['mode']}")
    logger.info(f"Puerto: {config['api']['port']}")
    
    # Iniciar componentes
    logger.info("Iniciando componentes del sistema...")
    
    # Iniciar motor cuántico
    quantum_engine = start_quantum_engine(config)
    if quantum_engine is None:
        logger.warning("Motor cuántico no disponible")
    
    # Iniciar monitor de energía
    energy_monitor = start_energy_monitor(config)
    if energy_monitor is None:
        logger.warning("Monitor de energía no disponible")
    
    # Iniciar servidor API
    if not start_api_server(config):
        logger.error("No se pudo iniciar el servidor API")
        sys.exit(1)
    
    # Iniciar dashboard
    if not args.no_browser:
        time.sleep(2)  # Esperar a que el servidor inicie
        start_dashboard(config)
    
    # Mensaje de inicio completo
    logger.info("=" * 60)
    logger.info("⚡ QuantumEnergyOS Mobile iniciado exitosamente ⚡")
    logger.info("=" * 60)
    logger.info(f"Dashboard: http://localhost:{config['api']['port']}")
    logger.info(f"API: http://localhost:{config['api']['port']}/api")
    logger.info(f"WebSocket: ws://localhost:{config['api']['port']}/ws/realtime")
    logger.info("=" * 60)
    logger.info("Presiona Ctrl+C para detener el sistema")
    logger.info("=" * 60)
    
    # Mantener el programa corriendo
    try:
        while True:
            time.sleep(1)
    except KeyboardInterrupt:
        logger.info("Cerrando QuantumEnergyOS Mobile...")
        sys.exit(0)

if __name__ == '__main__':
    main()
