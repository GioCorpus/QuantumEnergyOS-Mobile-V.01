#!/usr/bin/env python3
"""
⚡ QuantumEnergyOS Mobile - API Server
Servidor REST API para gestión de energía y monitoreo en tiempo real

Autor: Giovanny Corpus Bernal
Ubicación: Mexicali, Baja California, México
"""

import os
import json
import time
import logging
import sqlite3
import threading
from datetime import datetime, timedelta
from pathlib import Path

from flask import Flask, jsonify, request, send_from_directory
from flask_socketio import SocketIO, emit
import psutil

logger = logging.getLogger('QuantumEnergyOS.API')

class EnergyDatabase:
    """Base de datos para almacenar información de energía"""
    
    def __init__(self, db_path='data/quantum_energy.db'):
        self.db_path = db_path
        self.init_database()
    
    def init_database(self):
        """Inicializa la base de datos"""
        Path('data').mkdir(parents=True, exist_ok=True)
        
        conn = sqlite3.connect(self.db_path)
        cursor = conn.cursor()
        
        # Tabla de métricas de energía
        cursor.execute('''
            CREATE TABLE IF NOT EXISTS energy_metrics (
                id INTEGER PRIMARY KEY AUTOINCREMENT,
                timestamp DATETIME DEFAULT CURRENT_TIMESTAMP,
                voltage REAL,
                current REAL,
                power REAL,
                frequency REAL,
                power_factor REAL,
                temperature REAL,
                cpu_usage REAL,
                memory_usage REAL
            )
        ''')
        
        # Tabla de alertas
        cursor.execute('''
            CREATE TABLE IF NOT EXISTS alerts (
                id INTEGER PRIMARY KEY AUTOINCREMENT,
                timestamp DATETIME DEFAULT CURRENT_TIMESTAMP,
                level TEXT,
                message TEXT,
                acknowledged BOOLEAN DEFAULT 0
            )
        ''')
        
        # Tabla de configuración
        cursor.execute('''
            CREATE TABLE IF NOT EXISTS config (
                key TEXT PRIMARY KEY,
                value TEXT
            )
        ''')
        
        conn.commit()
        conn.close()
        
        logger.info("Base de datos inicializada")
    
    def insert_energy_metric(self, metric):
        """Inserta una métrica de energía"""
        conn = sqlite3.connect(self.db_path)
        cursor = conn.cursor()
        
        cursor.execute('''
            INSERT INTO energy_metrics 
            (voltage, current, power, frequency, power_factor, temperature, cpu_usage, memory_usage)
            VALUES (?, ?, ?, ?, ?, ?, ?, ?)
        ''', (
            metric['voltage'],
            metric['current'],
            metric['power'],
            metric['frequency'],
            metric['power_factor'],
            metric['temperature'],
            metric['cpu_usage'],
            metric['memory_usage']
        ))
        
        conn.commit()
        conn.close()
    
    def get_energy_history(self, hours=24):
        """Obtiene el historial de energía"""
        conn = sqlite3.connect(self.db_path)
        cursor = conn.cursor()
        
        cursor.execute('''
            SELECT * FROM energy_metrics 
            WHERE timestamp >= datetime('now', ?)
            ORDER BY timestamp DESC
        ''', (f'-{hours} hours',))
        
        rows = cursor.fetchall()
        conn.close()
        
        return rows
    
    def insert_alert(self, level, message):
        """Inserta una alerta"""
        conn = sqlite3.connect(self.db_path)
        cursor = conn.cursor()
        
        cursor.execute('''
            INSERT INTO alerts (level, message)
            VALUES (?, ?)
        ''', (level, message))
        
        conn.commit()
        conn.close()
    
    def get_alerts(self, limit=100):
        """Obtiene las alertas"""
        conn = sqlite3.connect(self.db_path)
        cursor = conn.cursor()
        
        cursor.execute('''
            SELECT * FROM alerts 
            ORDER BY timestamp DESC
            LIMIT ?
        ''', (limit,))
        
        rows = cursor.fetchall()
        conn.close()
        
        return rows

class EnergyMonitor:
    """Monitor de energía en tiempo real"""
    
    def __init__(self, config):
        self.config = config
        self.db = EnergyDatabase()
        self.running = False
        self.current_metrics = {}
        self.alert_threshold = config.get('energy', {}).get('alert_threshold', 85)
    
    def get_system_metrics(self):
        """Obtiene métricas del sistema"""
        try:
            cpu_percent = psutil.cpu_percent(interval=0.1)
            memory = psutil.virtual_memory()
            temperature = self.get_cpu_temperature()
            
            # Simular métricas de energía (en producción usar sensores reales)
            import random
            voltage = 220 + random.uniform(-5, 5)
            current = 10 + random.uniform(-2, 2)
            power = voltage * current
            frequency = 60 + random.uniform(-0.5, 0.5)
            power_factor = 0.95 + random.uniform(-0.05, 0.05)
            
            return {
                'voltage': round(voltage, 2),
                'current': round(current, 2),
                'power': round(power, 2),
                'frequency': round(frequency, 2),
                'power_factor': round(power_factor, 3),
                'temperature': round(temperature, 1),
                'cpu_usage': round(cpu_percent, 1),
                'memory_usage': round(memory.percent, 1),
                'timestamp': datetime.now().isoformat()
            }
        except Exception as e:
            logger.error(f"Error al obtener métricas: {e}")
            return None
    
    def get_cpu_temperature(self):
        """Obtiene la temperatura de la CPU"""
        try:
            if hasattr(psutil, "sensors_temperatures"):
                temps = psutil.sensors_temperatures()
                if temps:
                    for name, entries in temps.items():
                        for entry in entries:
                            return entry.current
            return 45.0  # Valor por defecto
        except:
            return 45.0
    
    def check_alerts(self, metrics):
        """Verifica si hay alertas"""
        alerts = []
        
        # Alerta de temperatura alta
        if metrics['temperature'] > 70:
            alerts.append({
                'level': 'warning',
                'message': f"Temperatura alta: {metrics['temperature']}°C"
            })
        
        # Alerta de uso de CPU alto
        if metrics['cpu_usage'] > self.alert_threshold:
            alerts.append({
                'level': 'warning',
                'message': f"Uso de CPU alto: {metrics['cpu_usage']}%"
            })
        
        # Alerta de uso de memoria alto
        if metrics['memory_usage'] > self.alert_threshold:
            alerts.append({
                'level': 'warning',
                'message': f"Uso de memoria alto: {metrics['memory_usage']}%"
            })
        
        # Alerta de voltaje bajo
        if metrics['voltage'] < 210:
            alerts.append({
                'level': 'critical',
                'message': f"Voltaje bajo: {metrics['voltage']}V"
            })
        
        # Alerta de frecuencia inestable
        if abs(metrics['frequency'] - 60) > 1:
            alerts.append({
                'level': 'warning',
                'message': f"Frecuencia inestable: {metrics['frequency']}Hz"
            })
        
        return alerts
    
    def start(self):
        """Inicia el monitor de energía"""
        self.running = True
        logger.info("Monitor de energía iniciado")
        
        while self.running:
            try:
                metrics = self.get_system_metrics()
                
                if metrics:
                    self.current_metrics = metrics
                    self.db.insert_energy_metric(metrics)
                    
                    # Verificar alertas
                    alerts = self.check_alerts(metrics)
                    for alert in alerts:
                        self.db.insert_alert(alert['level'], alert['message'])
                        logger.warning(f"Alerta: {alert['message']}")
                
                time.sleep(self.config.get('energy', {}).get('monitoring_interval', 1))
            
            except Exception as e:
                logger.error(f"Error en monitor de energía: {e}")
                time.sleep(5)
    
    def stop(self):
        """Detiene el monitor de energía"""
        self.running = False
        logger.info("Monitor de energía detenido")

def create_app(config):
    """Crea la aplicación Flask"""
    app = Flask(__name__, static_folder='../dashboard', static_url_path='')
    app.config['SECRET_KEY'] = os.environ.get('QUANTUM_ENERGY_SECRET_KEY', 'quantum-energy-secret')
    
    socketio = SocketIO(app, cors_allowed_origins="*")
    
    # Inicializar monitor de energía
    energy_monitor = EnergyMonitor(config)
    
    # Rutas de la API
    @app.route('/')
    def index():
        """Página principal"""
        return send_from_directory('../dashboard', 'index.html')
    
    @app.route('/api/status')
    def get_status():
        """Estado del sistema"""
        return jsonify({
            'status': 'online',
            'system': config['system']['name'],
            'version': config['system']['version'],
            'mode': config['system']['mode'],
            'timestamp': datetime.now().isoformat()
        })
    
    @app.route('/api/energy')
    def get_energy():
        """Datos de energía actual"""
        metrics = energy_monitor.current_metrics
        
        if not metrics:
            metrics = energy_monitor.get_system_metrics()
        
        return jsonify(metrics)
    
    @app.route('/api/energy/history')
    def get_energy_history():
        """Historial de energía"""
        hours = request.args.get('hours', 24, type=int)
        history = energy_monitor.db.get_energy_history(hours)
        
        return jsonify({
            'history': history,
            'hours': hours
        })
    
    @app.route('/api/energy/optimize', methods=['POST'])
    def optimize_energy():
        """Optimizar consumo de energía"""
        try:
            # Simular optimización
            import random
            reduction = random.uniform(5, 15)
            
            return jsonify({
                'success': True,
                'message': 'Optimización completada',
                'reduction': round(reduction, 2),
                'timestamp': datetime.now().isoformat()
            })
        except Exception as e:
            return jsonify({
                'success': False,
                'error': str(e)
            }), 500
    
    @app.route('/api/alerts')
    def get_alerts():
        """Lista de alertas"""
        limit = request.args.get('limit', 100, type=int)
        alerts = energy_monitor.db.get_alerts(limit)
        
        return jsonify({
            'alerts': alerts,
            'count': len(alerts)
        })
    
    @app.route('/api/alerts/acknowledge', methods=['POST'])
    def acknowledge_alert():
        """Reconocer alerta"""
        data = request.get_json()
        alert_id = data.get('alert_id')
        
        if not alert_id:
            return jsonify({
                'success': False,
                'error': 'alert_id requerido'
            }), 400
        
        # En producción, actualizar en base de datos
        return jsonify({
            'success': True,
            'message': f'Alerta {alert_id} reconocida'
        })
    
    @app.route('/api/metrics')
    def get_metrics():
        """Métricas del sistema"""
        cpu_percent = psutil.cpu_percent(interval=0.1)
        memory = psutil.virtual_memory()
        disk = psutil.disk_usage('/')
        
        return jsonify({
            'cpu': {
                'percent': cpu_percent,
                'cores': psutil.cpu_count()
            },
            'memory': {
                'total': memory.total,
                'available': memory.available,
                'percent': memory.percent,
                'used': memory.used
            },
            'disk': {
                'total': disk.total,
                'used': disk.used,
                'free': disk.free,
                'percent': disk.percent
            },
            'timestamp': datetime.now().isoformat()
        })
    
    @app.route('/api/system/info')
    def get_system_info():
        """Información del sistema"""
        import platform
        
        return jsonify({
            'platform': platform.system(),
            'platform_version': platform.version(),
            'architecture': platform.machine(),
            'processor': platform.processor(),
            'python_version': platform.python_version(),
            'hostname': platform.node()
        })
    
    # WebSocket para datos en tiempo real
    @socketio.on('connect')
    def handle_connect():
        """Cliente conectado"""
        logger.info(f"Cliente WebSocket conectado: {request.sid}")
        emit('connected', {
            'status': 'connected',
            'timestamp': datetime.now().isoformat()
        })
    
    @socketio.on('disconnect')
    def handle_disconnect():
        """Cliente desconectado"""
        logger.info(f"Cliente WebSocket desconectado: {request.sid}")
    
    @socketio.on('subscribe_realtime')
    def handle_subscribe_realtime():
        """Suscribirse a datos en tiempo real"""
        logger.info(f"Cliente suscrito a datos en tiempo real: {request.sid}")
        
        def send_realtime_data():
            while True:
                try:
                    metrics = energy_monitor.current_metrics
                    if metrics:
                        emit('realtime_data', metrics)
                    time.sleep(1)
                except Exception as e:
                    logger.error(f"Error enviando datos en tiempo real: {e}")
                    break
        
        thread = threading.Thread(target=send_realtime_data, daemon=True)
        thread.start()
    
    # Manejo de errores
    @app.errorhandler(404)
    def not_found(error):
        return jsonify({
            'error': 'No encontrado',
            'message': 'El recurso solicitado no existe'
        }), 404
    
    @app.errorhandler(500)
    def internal_error(error):
        return jsonify({
            'error': 'Error interno del servidor',
            'message': str(error)
        }), 500
    
    return app, socketio, energy_monitor

def start_server(app, host='0.0.0.0', port=8080):
    """Inicia el servidor"""
    socketio = SocketIO(app, cors_allowed_origins="*")
    socketio.run(app, host=host, port=port, debug=False, use_reloader=False)

if __name__ == '__main__':
    config = {
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
        'api': {
            'host': '0.0.0.0',
            'port': 8080,
            'debug': False
        }
    }
    
    app, socketio, energy_monitor = create_app(config)
    socketio.run(app, host=config['api']['host'], port=config['api']['port'], debug=False)
