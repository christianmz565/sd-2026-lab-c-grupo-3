#!/bin/bash

# ============================================================
# SCRIPT DE EJECUCIÓN PARA EL PROYECTO API ESTUDIANTES
# ============================================================
# Este script inicia el servidor Flask y luego ejecuta las
# pruebas del cliente consumidor

# Ubicate en e2/

echo "╔════════════════════════════════════════════════════════╗"
echo "║   API RESTful Gestión de Estudiantes - Proyecto E2    ║"
echo "║                  Modalidad Profesional                ║"
echo "╚════════════════════════════════════════════════════════╝"
echo ""

# Limpiar procesos anteriores
pkill -f "python main.py" || true
sleep 1

# Eliminar base de datos antigua (opcional, para empezar fresco)
# rm -f estudiantes.db

echo "🚀 [1/2] Iniciando Servidor Flask en puerto 5000..."
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
uv run python main.py &
SERVER_PID=$!

# Esperar a que se inicialice el servidor
sleep 3

echo ""
echo "📡 [2/2] Ejecutando Cliente Consumidor para Pruebas..."
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
uv run python cliente.py

# Mostrar información de acceso
echo ""
echo "╔════════════════════════════════════════════════════════╗"
echo "║            ✅ PROYECTO EJECUTADO CON ÉXITO            ║"
echo "╠════════════════════════════════════════════════════════╣"
echo "║                                                        ║"
echo "║  🌐 ACCESO A LA INTERFAZ WEB:                         ║"
echo "║     → http://127.0.0.1:5000                           ║"
echo "║                                                        ║"
echo "║  📡 ENDPOINTS API:                                    ║"
echo "║     • GET    → /estudiantes (Consultar)               ║"
echo "║     • POST   → /estudiantes (Registrar)               ║"
echo "║     • PUT    → /estudiantes/<id> (Actualizar)         ║"
echo "║     • DELETE → /estudiantes/<id> (Eliminar)           ║"
echo "║                                                        ║"
echo "║  📦 BASE DE DATOS:                                    ║"
echo "║     → estudiantes.db (SQLite)                         ║"
echo "║                                                        ║"
echo "║  ⚙️  PARA DETENER EL SERVIDOR:                        ║"
echo "║     → Presiona Ctrl+C                                 ║"
echo "║                                                        ║"
echo "╚════════════════════════════════════════════════════════╝"

# Mantener el servidor corriendo
wait $SERVER_PID


