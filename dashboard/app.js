/**
 * ⚡ QuantumEnergyOS Mobile - Dashboard JavaScript
 * Sistema Operativo Móvil Cuántico para Gestión de Energía
 * Autor: Giovanny Corpus Bernal - Mexicali, Baja California
 */

// ============================================
// Configuración
// ============================================
const CONFIG = {
    API_URL: window.location.origin,
    WS_URL: `ws://${window.location.host}/ws/realtime`,
    UPDATE_INTERVAL: 1000,
    CHART_POINTS: 60,
    PARTICLES_COUNT: 100
};

// ============================================
// Estado de la aplicación
// ============================================
const state = {
    isConnected: false,
    energyData: [],
    alerts: [],
    systemInfo: {},
    chart: null,
    particles: [],
    animationFrame: null
};

// ============================================
// Inicialización
// ============================================
document.addEventListener('DOMContentLoaded', () => {
    console.log('⚡ QuantumEnergyOS Mobile Dashboard iniciando...');
    
    // Inicializar componentes
    initParticles();
    initChart();
    initEventListeners();
    initWebSocket();
    
    // Cargar datos iniciales
    loadSystemInfo();
    loadEnergyData();
    loadAlerts();
    
    // Iniciar actualizaciones periódicas
    setInterval(updateDashboard, CONFIG.UPDATE_INTERVAL);
    
    console.log('⚡ Dashboard iniciado correctamente');
});

// ============================================
// Partículas Cuánticas
// ============================================
function initParticles() {
    const canvas = document.getElementById('quantum-particles');
    if (!canvas) return;
    
    const ctx = canvas.getContext('2d');
    
    // Ajustar tamaño del canvas
    function resizeCanvas() {
        canvas.width = window.innerWidth;
        canvas.height = window.innerHeight;
    }
    
    resizeCanvas();
    window.addEventListener('resize', resizeCanvas);
    
    // Crear partículas
    for (let i = 0; i < CONFIG.PARTICLES_COUNT; i++) {
        state.particles.push({
            x: Math.random() * canvas.width,
            y: Math.random() * canvas.height,
            vx: (Math.random() - 0.5) * 0.5,
            vy: (Math.random() - 0.5) * 0.5,
            radius: Math.random() * 2 + 1,
            opacity: Math.random() * 0.5 + 0.2,
            hue: Math.random() * 30 + 180 // Azul a cyan
        });
    }
    
    // Animar partículas
    function animateParticles() {
        ctx.clearRect(0, 0, canvas.width, canvas.height);
        
        state.particles.forEach(particle => {
            // Actualizar posición
            particle.x += particle.vx;
            particle.y += particle.vy;
            
            // Rebotar en los bordes
            if (particle.x < 0 || particle.x > canvas.width) particle.vx *= -1;
            if (particle.y < 0 || particle.y > canvas.height) particle.vy *= -1;
            
            // Dibujar partícula
            ctx.beginPath();
            ctx.arc(particle.x, particle.y, particle.radius, 0, Math.PI * 2);
            ctx.fillStyle = `hsla(${particle.hue}, 100%, 50%, ${particle.opacity})`;
            ctx.fill();
            
            // Efecto glow
            ctx.shadowBlur = 10;
            ctx.shadowColor = `hsla(${particle.hue}, 100%, 50%, ${particle.opacity})`;
        });
        
        // Dibujar conexiones entre partículas cercanas
        state.particles.forEach((p1, i) => {
            state.particles.slice(i + 1).forEach(p2 => {
                const dx = p1.x - p2.x;
                const dy = p1.y - p2.y;
                const distance = Math.sqrt(dx * dx + dy * dy);
                
                if (distance < 100) {
                    ctx.beginPath();
                    ctx.moveTo(p1.x, p1.y);
                    ctx.lineTo(p2.x, p2.y);
                    ctx.strokeStyle = `rgba(0, 212, 255, ${0.2 * (1 - distance / 100)})`;
                    ctx.lineWidth = 0.5;
                    ctx.stroke();
                }
            });
        });
        
        state.animationFrame = requestAnimationFrame(animateParticles);
    }
    
    animateParticles();
}

// ============================================
// Gráfico de Energía
// ============================================
function initChart() {
    const canvas = document.getElementById('energy-chart');
    if (!canvas) return;
    
    const ctx = canvas.getContext('2d');
    
    // Ajustar tamaño del canvas
    function resizeChart() {
        canvas.width = canvas.offsetWidth;
        canvas.height = canvas.offsetHeight;
    }
    
    resizeChart();
    window.addEventListener('resize', resizeChart);
    
    // Dibujar gráfico
    function drawChart() {
        const width = canvas.width;
        const height = canvas.height;
        const padding = 40;
        
        // Limpiar canvas
        ctx.clearRect(0, 0, width, height);
        
        // Dibujar fondo
        ctx.fillStyle = 'rgba(26, 26, 46, 0.5)';
        ctx.fillRect(0, 0, width, height);
        
        // Dibujar líneas de cuadrícula
        ctx.strokeStyle = 'rgba(255, 255, 255, 0.1)';
        ctx.lineWidth = 1;
        
        for (let i = 0; i <= 5; i++) {
            const y = padding + (height - 2 * padding) * i / 5;
            ctx.beginPath();
            ctx.moveTo(padding, y);
            ctx.lineTo(width - padding, y);
            ctx.stroke();
        }
        
        // Dibujar datos
        if (state.energyData.length > 1) {
            const maxPower = Math.max(...state.energyData.map(d => d.power), 1000);
            const minPower = Math.min(...state.energyData.map(d => d.power), 0);
            const range = maxPower - minPower || 1;
            
            // Línea de potencia
            ctx.beginPath();
            ctx.strokeStyle = '#00d4ff';
            ctx.lineWidth = 2;
            ctx.shadowBlur = 10;
            ctx.shadowColor = '#00d4ff';
            
            state.energyData.forEach((data, index) => {
                const x = padding + (width - 2 * padding) * index / (state.energyData.length - 1);
                const y = height - padding - (height - 2 * padding) * (data.power - minPower) / range;
                
                if (index === 0) {
                    ctx.moveTo(x, y);
                } else {
                    ctx.lineTo(x, y);
                }
            });
            
            ctx.stroke();
            
            // Área bajo la curva
            ctx.lineTo(width - padding, height - padding);
            ctx.lineTo(padding, height - padding);
            ctx.closePath();
            
            const gradient = ctx.createLinearGradient(0, 0, 0, height);
            gradient.addColorStop(0, 'rgba(0, 212, 255, 0.3)');
            gradient.addColorStop(1, 'rgba(0, 212, 255, 0)');
            ctx.fillStyle = gradient;
            ctx.fill();
            
            // Puntos de datos
            state.energyData.forEach((data, index) => {
                const x = padding + (width - 2 * padding) * index / (state.energyData.length - 1);
                const y = height - padding - (height - 2 * padding) * (data.power - minPower) / range;
                
                ctx.beginPath();
                ctx.arc(x, y, 3, 0, Math.PI * 2);
                ctx.fillStyle = '#00d4ff';
                ctx.fill();
            });
        }
        
        // Dibujar ejes
        ctx.strokeStyle = 'rgba(255, 255, 255, 0.3)';
        ctx.lineWidth = 1;
        ctx.beginPath();
        ctx.moveTo(padding, padding);
        ctx.lineTo(padding, height - padding);
        ctx.lineTo(width - padding, height - padding);
        ctx.stroke();
        
        // Etiquetas
        ctx.fillStyle = '#b0b0b0';
        ctx.font = '12px sans-serif';
        ctx.textAlign = 'center';
        ctx.fillText('Tiempo', width / 2, height - 10);
        
        ctx.save();
        ctx.translate(15, height / 2);
        ctx.rotate(-Math.PI / 2);
        ctx.fillText('Potencia (W)', 0, 0);
        ctx.restore();
    }
    
    // Actualizar gráfico periódicamente
    setInterval(drawChart, 1000);
}

// ============================================
// WebSocket
// ============================================
function initWebSocket() {
    try {
        const ws = new WebSocket(CONFIG.WS_URL);
        
        ws.onopen = () => {
            console.log('🔌 WebSocket conectado');
            state.isConnected = true;
            updateConnectionStatus(true);
            
            // Suscribirse a datos en tiempo real
            ws.send(JSON.stringify({ type: 'subscribe_realtime' }));
        };
        
        ws.onmessage = (event) => {
            try {
                const data = JSON.parse(event.data);
                handleWebSocketMessage(data);
            } catch (e) {
                console.error('Error al parsear mensaje WebSocket:', e);
            }
        };
        
        ws.onclose = () => {
            console.log('🔌 WebSocket desconectado');
            state.isConnected = false;
            updateConnectionStatus(false);
            
            // Reconectar después de 5 segundos
            setTimeout(initWebSocket, 5000);
        };
        
        ws.onerror = (error) => {
            console.error('Error WebSocket:', error);
        };
    } catch (e) {
        console.error('No se pudo conectar WebSocket:', e);
        // Intentar reconectar
        setTimeout(initWebSocket, 5000);
    }
}

function handleWebSocketMessage(data) {
    switch (data.type) {
        case 'realtime_data':
            updateEnergyMetrics(data);
            break;
        case 'alert':
            addAlert(data);
            break;
        case 'system_info':
            updateSystemInfo(data);
            break;
        default:
            console.log('Mensaje WebSocket no manejado:', data);
    }
}

// ============================================
// API Calls
// ============================================
async function loadSystemInfo() {
    try {
        const response = await fetch(`${CONFIG.API_URL}/api/system/info`);
        const data = await response.json();
        state.systemInfo = data;
        updateSystemInfo(data);
    } catch (e) {
        console.error('Error al cargar información del sistema:', e);
    }
}

async function loadEnergyData() {
    try {
        const response = await fetch(`${CONFIG.API_URL}/api/energy`);
        const data = await response.json();
        updateEnergyMetrics(data);
    } catch (e) {
        console.error('Error al cargar datos de energía:', e);
    }
}

async function loadAlerts() {
    try {
        const response = await fetch(`${CONFIG.API_URL}/api/alerts`);
        const data = await response.json();
        state.alerts = data.alerts || [];
        updateAlertsList();
    } catch (e) {
        console.error('Error al cargar alertas:', e);
    }
}

async function optimizeEnergy() {
    try {
        const response = await fetch(`${CONFIG.API_URL}/api/energy/optimize`, {
            method: 'POST'
        });
        const data = await response.json();
        
        if (data.success) {
            addAlert({
                level: 'success',
                message: `Optimización completada: ${data.reduction}% de reducción`
            });
        }
    } catch (e) {
        console.error('Error al optimizar energía:', e);
        addAlert({
            level: 'error',
            message: 'Error al optimizar energía'
        });
    }
}

// ============================================
// Actualización de UI
// ============================================
function updateDashboard() {
    // Actualizar datos de energía
    loadEnergyData();
    
    // Actualizar alertas
    loadAlerts();
}

function updateEnergyMetrics(data) {
    // Actualizar valores
    document.getElementById('voltage').textContent = `${data.voltage || 0} V`;
    document.getElementById('current').textContent = `${data.current || 0} A`;
    document.getElementById('power').textContent = `${data.power || 0} W`;
    document.getElementById('frequency').textContent = `${data.frequency || 0} Hz`;
    document.getElementById('temperature').textContent = `${data.temperature || 0}°C`;
    document.getElementById('power-factor').textContent = data.power_factor || 0;
    
    // Actualizar barras de progreso
    const cpuUsage = data.cpu_usage || 0;
    const memoryUsage = data.memory_usage || 0;
    
    document.getElementById('cpu-usage').textContent = `${cpuUsage}%`;
    document.getElementById('memory-usage').textContent = `${memoryUsage}%`;
    
    document.getElementById('cpu-bar').style.width = `${cpuUsage}%`;
    document.getElementById('memory-bar').style.width = `${memoryUsage}%`;
    
    // Agregar datos al gráfico
    state.energyData.push({
        timestamp: new Date(),
        power: data.power || 0,
        voltage: data.voltage || 0,
        current: data.current || 0
    });
    
    // Mantener solo los últimos puntos
    if (state.energyData.length > CONFIG.CHART_POINTS) {
        state.energyData.shift();
    }
}

function updateSystemInfo(data) {
    document.getElementById('system-name').textContent = data.system || 'QuantumEnergyOS Mobile';
    document.getElementById('system-version').textContent = data.version || '0.1.0';
    document.getElementById('system-platform').textContent = data.platform || '-';
    document.getElementById('system-arch').textContent = data.architecture || '-';
    document.getElementById('python-version').textContent = data.python_version || '-';
    document.getElementById('last-update').textContent = new Date().toLocaleTimeString();
}

function updateConnectionStatus(connected) {
    const statusDot = document.querySelector('.status-dot');
    const statusText = document.querySelector('.status-text');
    
    if (connected) {
        statusDot.classList.remove('offline');
        statusDot.classList.add('online');
        statusText.textContent = 'En Línea';
    } else {
        statusDot.classList.remove('online');
        statusDot.classList.add('offline');
        statusText.textContent = 'Desconectado';
    }
}

function updateAlertsList() {
    const alertsList = document.getElementById('alerts-list');
    const alertCount = document.getElementById('alert-count');
    
    // Actualizar contador
    alertCount.textContent = state.alerts.length;
    
    // Limpiar lista
    alertsList.innerHTML = '';
    
    // Agregar alertas
    state.alerts.slice(0, 10).forEach(alert => {
        const alertItem = document.createElement('div');
        alertItem.className = `alert-item ${alert.level || 'info'}`;
        
        const icon = getAlertIcon(alert.level);
        const time = formatTime(alert.timestamp);
        
        alertItem.innerHTML = `
            <span class="alert-icon">${icon}</span>
            <span class="alert-message">${alert.message}</span>
            <span class="alert-time">${time}</span>
        `;
        
        alertsList.appendChild(alertItem);
    });
    
    // Si no hay alertas, mostrar mensaje
    if (state.alerts.length === 0) {
        alertsList.innerHTML = `
            <div class="alert-item info">
                <span class="alert-icon">ℹ️</span>
                <span class="alert-message">No hay alertas activas</span>
                <span class="alert-time">Ahora</span>
            </div>
        `;
    }
}

function addAlert(alert) {
    state.alerts.unshift({
        ...alert,
        timestamp: new Date().toISOString()
    });
    
    // Mantener solo las últimas 50 alertas
    if (state.alerts.length > 50) {
        state.alerts.pop();
    }
    
    updateAlertsList();
}

function getAlertIcon(level) {
    switch (level) {
        case 'critical':
            return '🔴';
        case 'warning':
            return '🟡';
        case 'success':
            return '🟢';
        case 'info':
        default:
            return 'ℹ️';
    }
}

function formatTime(timestamp) {
    if (!timestamp) return 'Ahora';
    
    const date = new Date(timestamp);
    const now = new Date();
    const diff = now - date;
    
    if (diff < 60000) return 'Ahora';
    if (diff < 3600000) return `${Math.floor(diff / 60000)}m`;
    if (diff < 86400000) return `${Math.floor(diff / 3600000)}h`;
    return date.toLocaleDateString();
}

// ============================================
// Event Listeners
// ============================================
function initEventListeners() {
    // Botón de optimizar
    document.getElementById('btn-optimize')?.addEventListener('click', () => {
        optimizeEnergy();
    });
    
    // Botón de actualizar
    document.getElementById('btn-refresh')?.addEventListener('click', () => {
        loadEnergyData();
        loadAlerts();
    });
    
    // Botón de reporte
    document.getElementById('btn-report')?.addEventListener('click', () => {
        generateReport();
    });
    
    // Botón de configuración
    document.getElementById('btn-settings')?.addEventListener('click', () => {
        showSettings();
    });
    
    // Controles de gráfico
    document.getElementById('btn-1h')?.addEventListener('click', () => {
        updateChartRange('1h');
    });
    
    document.getElementById('btn-24h')?.addEventListener('click', () => {
        updateChartRange('24h');
    });
    
    document.getElementById('btn-7d')?.addEventListener('click', () => {
        updateChartRange('7d');
    });
}

function generateReport() {
    addAlert({
        level: 'info',
        message: 'Generando reporte de energía...'
    });
    
    // Simular generación de reporte
    setTimeout(() => {
        addAlert({
            level: 'success',
            message: 'Reporte generado exitosamente'
        });
    }, 2000);
}

function showSettings() {
    addAlert({
        level: 'info',
        message: 'Panel de configuración próximamente'
    });
}

function updateChartRange(range) {
    // Actualizar botones activos
    document.querySelectorAll('.chart-controls .btn').forEach(btn => {
        btn.classList.remove('active');
    });
    
    document.getElementById(`btn-${range}`)?.classList.add('active');
    
    addAlert({
        level: 'info',
        message: `Rango de gráfico actualizado: ${range}`
    });
}

// ============================================
// Utilidades
// ============================================
function formatNumber(num) {
    if (num >= 1000000) {
        return (num / 1000000).toFixed(1) + 'M';
    }
    if (num >= 1000) {
        return (num / 1000).toFixed(1) + 'K';
    }
    return num.toFixed(1);
}

function formatBytes(bytes) {
    if (bytes >= 1073741824) {
        return (bytes / 1073741824).toFixed(1) + ' GB';
    }
    if (bytes >= 1048576) {
        return (bytes / 1048576).toFixed(1) + ' MB';
    }
    if (bytes >= 1024) {
        return (bytes / 1024).toFixed(1) + ' KB';
    }
    return bytes + ' B';
}

// ============================================
// Service Worker (PWA)
// ============================================
if ('serviceWorker' in navigator) {
    window.addEventListener('load', () => {
        navigator.serviceWorker.register('/sw.js')
            .then(registration => {
                console.log('ServiceWorker registrado:', registration.scope);
            })
            .catch(error => {
                console.log('Error al registrar ServiceWorker:', error);
            });
    });
}

// ============================================
// Exportar para uso global
// ============================================
window.QuantumEnergyOS = {
    state,
    CONFIG,
    updateDashboard,
    loadEnergyData,
    loadAlerts,
    optimizeEnergy,
    addAlert
};
