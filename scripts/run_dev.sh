#!/bin/bash
# Script para ejecutar la app en modo desarrollo
# Uso: ./scripts/run_dev.sh [dispositivo|emulador|web]

# Colores para output
GREEN='\033[0;32m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

echo -e "${BLUE}🚀 AstroStar Mobile - Desarrollo${NC}"
echo ""

# Detectar IP local automáticamente
if [[ "$OSTYPE" == "darwin"* ]]; then
    # macOS
    LOCAL_IP=$(ipconfig getifaddr en0)
elif [[ "$OSTYPE" == "linux-gnu"* ]]; then
    # Linux
    LOCAL_IP=$(hostname -I | awk '{print $1}')
else
    echo "⚠️  No se pudo detectar la IP automáticamente"
    echo "Por favor, ingresa tu IP local:"
    read LOCAL_IP
fi

echo -e "${GREEN}📡 IP Local detectada: $LOCAL_IP${NC}"
echo ""

# Determinar modo de ejecución
MODE=${1:-dispositivo}

case $MODE in
    dispositivo|device)
        echo "📱 Ejecutando en dispositivo físico..."
        flutter run --dart-define=API_URL=http://$LOCAL_IP:4000/api
        ;;
    emulador|emulator)
        echo "🤖 Ejecutando en emulador Android..."
        flutter run --dart-define=API_URL=http://10.0.2.2:4000/api
        ;;
    web)
        echo "🌐 Ejecutando en navegador..."
        flutter run -d chrome --dart-define=API_URL=http://localhost:4000/api
        ;;
    *)
        echo "❌ Modo no reconocido: $MODE"
        echo "Uso: ./scripts/run_dev.sh [dispositivo|emulador|web]"
        exit 1
        ;;
esac
