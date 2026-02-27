# AstroStar Mobile

Aplicación móvil de AstroStar desarrollada con Flutter.

## 🚀 Inicio Rápido

### 1. Instalar dependencias
```bash
flutter pub get
```

### 2. Ejecutar la app

**Opción más fácil (VS Code)**:
- Presiona `F5`
- Selecciona la configuración apropiada
- Si usas dispositivo físico, actualiza tu IP en `.vscode/launch.json` línea 8

**Línea de comandos**:
```bash
# Encuentra tu IP primero
ipconfig

# Ejecuta con tu IP
flutter run --dart-define=API_URL=http://TU_IP:4000/api
```

## 📚 Documentación

- [CONFIGURACION_AMBIENTES.md](CONFIGURACION_AMBIENTES.md) - **LEE ESTO PRIMERO** - Guía completa de configuración
- [PERMISSIONS_GUIDE.md](PERMISSIONS_GUIDE.md) - Guía de permisos

## ⚠️ Importante

Tu backend debe:
1. Escuchar en `0.0.0.0:4000` (no `localhost`)
2. Tener CORS habilitado

Ver [CONFIGURACION_AMBIENTES.md](CONFIGURACION_AMBIENTES.md) para detalles.
