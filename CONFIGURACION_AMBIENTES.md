# 📱 Configuración de Ambientes - Guía Completa

## 🤔 ¿Qué problema resolvimos?

### El Problema Original:
Tenías la IP `192.168.20.41` hardcodeada en el código. Cada vez que:
- Tu IP cambia (te reconectas al WiFi)
- Otro compañero quiere desarrollar (tiene otra IP)
- Quieres publicar la app (necesitas usar `https://api.astrostar.com`)

Tenías que editar el código, recompilar, y era un desastre.

### La Solución:
Ahora la URL del backend se configura **al momento de ejecutar la app**, no en el código.

---

## 🎯 Cómo Funciona (Explicación Simple)

### Antes (Malo):
```dart
// Hardcodeado en el código
return 'http://192.168.20.41:4000/api';
```

### Ahora (Bueno):
```dart
// Se configura al ejecutar
flutter run --dart-define=API_URL=http://192.168.20.41:4000/api
```

La URL se pasa como parámetro al ejecutar, no está en el código.

---

## 🚀 Cómo Usar (3 Formas)

### Forma 1: VS Code (LA MÁS FÁCIL) ⭐

**Primera vez (solo una vez)**:
1. Copia `.vscode/launch.json.example` a `.vscode/launch.json`
2. Abre `.vscode/launch.json`
3. En la línea 8, cambia `TU_IP_AQUI` por tu IP actual
   - Para saber tu IP: abre CMD y escribe `ipconfig`
   - Busca "IPv4 Address" (ejemplo: `192.168.20.41`)

**Después (siempre)**:
1. Presiona `F5`
2. Selecciona una opción:
   - **🔧 Dev - Dispositivo Físico** → Para tu celular conectado por USB
   - **🤖 Dev - Emulador Android** → Para emulador de Android Studio
   - **🌐 Dev - Web** → Para probar en Chrome

**Nota**: El archivo `launch.json` está en `.gitignore`, así que cada desarrollador tiene su propia configuración con su IP.

### Forma 2: Línea de Comandos

```bash
# 1. Encuentra tu IP
ipconfig

# 2. Ejecuta con tu IP (ejemplo: 192.168.20.41)
flutter run --dart-define=API_URL=http://192.168.20.41:4000/api
```

### Forma 3: Script Automático (Windows)

```bash
scripts\run_dev.bat dispositivo
```

Este script detecta tu IP automáticamente y ejecuta la app.

---

## 📂 ¿Qué Archivos Cambiaron?

### 1. Nuevo: `lib/config/environment.dart`
**¿Qué hace?**: Archivo que lee la URL que pasas con `--dart-define`

**Ejemplo**:
```dart
// Lee la URL que pasaste al ejecutar
static String get apiBaseUrl {
  const apiUrl = String.fromEnvironment('API_URL');
  if (apiUrl.isNotEmpty) return apiUrl;
  
  // Si no pasaste nada, usa valores por defecto
  return 'http://10.0.2.2:4000/api'; // Para emulador
}
```

### 2. Modificado: `lib/core/api_service.dart`
**Antes**:
```dart
static String get baseUrl {
  if (Platform.isAndroid) {
    return 'http://192.168.20.41:4000/api'; // Hardcodeado
  }
}
```

**Ahora**:
```dart
static String get baseUrl => AppConfig.apiBaseUrl; // Lee de la config
```

### 3. Modificado: `lib/data/services/auth_service.dart`
Lo mismo que arriba, ahora usa `AppConfig.apiBaseUrl`.

### 4. Nuevo: `.vscode/launch.json`
Configuraciones predefinidas para VS Code. Cuando presionas F5, usa estas configuraciones.

### 5. Nuevo: `scripts/run_dev.bat`
Script que detecta tu IP automáticamente y ejecuta la app.

---

## 🔧 Configuración del Backend (IMPORTANTE)

Tu backend Node.js/Express necesita 2 cambios:

### 1. Escuchar en todas las interfaces (no solo localhost)

**❌ INCORRECTO** (solo funciona en tu PC):
```javascript
app.listen(4000, 'localhost', () => {
  console.log('Servidor corriendo');
});
```

**✅ CORRECTO** (funciona desde tu celular):
```javascript
app.listen(4000, '0.0.0.0', () => {
  console.log('Servidor corriendo en puerto 4000');
});
```

### 2. Habilitar CORS

```bash
npm install cors
```

```javascript
const cors = require('cors');

// En desarrollo, permitir todas las conexiones
app.use(cors({ origin: '*' }));
```

### 3. Verificar que funciona

Desde el navegador de tu celular, visita:
```
http://TU_IP:4000/api
```

Si ves una respuesta del servidor, ¡funciona! ✅

---

## 🎓 Para Tus Compañeros del Proyecto

Cuando un compañero clone el proyecto:

### Setup Inicial (Solo una vez):

1. **Copiar el archivo de configuración**:
   ```bash
   copy .vscode\launch.json.example .vscode\launch.json
   ```

2. **Encontrar su IP**:
   ```bash
   ipconfig
   ```
   Buscar "IPv4 Address" (ejemplo: `192.168.20.55`)

3. **Actualizar su configuración**:
   - Abrir `.vscode/launch.json`
   - En la línea 8, cambiar `TU_IP_AQUI` por su IP

4. **Listo**: Presionar F5 y seleccionar la configuración

### Alternativa (Sin configurar VS Code):

Cada quien ejecuta con su propia IP:
```bash
# Cada quien usa su propia IP
flutter run --dart-define=API_URL=http://SU_IP:4000/api
```

**Importante**: El archivo `launch.json` está en `.gitignore`, así que cada desarrollador mantiene su propia configuración sin conflictos en Git.

---

## 🚀 Para Producción

Cuando publiques la app en Play Store/App Store:

```bash
flutter build apk --dart-define=API_URL=https://api.astrostar.com/api
```

Usas la URL de producción al hacer el build, no en el código.

---

## ❓ Preguntas Frecuentes

### ¿Por qué mi celular no se conecta?

**Checklist**:
1. ✅ Backend corriendo en puerto 4000
2. ✅ Backend escuchando en `0.0.0.0` (no `localhost`)
3. ✅ CORS habilitado en el backend
4. ✅ Celular y PC en la misma WiFi
5. ✅ IP correcta (verifica con `ipconfig`)
6. ✅ Firewall de Windows desactivado o permitiendo puerto 4000

### ¿Cómo desactivo el Firewall temporalmente?

1. Busca "Firewall de Windows Defender"
2. Click en "Activar o desactivar"
3. Desactiva para "Redes privadas"

### ¿Por qué el emulador usa 10.0.2.2?

`10.0.2.2` es una IP especial del emulador Android que apunta al `localhost` de tu PC.

### ¿Cambié la IP pero no funciona?

Haz **hot restart** (presiona `R` en la terminal de Flutter), no solo hot reload.

---

## 🎯 Resumen Ultra Simple

### Lo que hicimos:
1. Creamos un archivo de configuración (`environment.dart`)
2. Los servicios ahora leen de ese archivo
3. La URL se pasa al ejecutar, no está hardcodeada

### Cómo lo usas:
1. **Desarrollo**: Presiona F5 en VS Code (actualiza tu IP primero)
2. **Producción**: `flutter build apk --dart-define=API_URL=https://api.astrostar.com/api`

### Lo que tu backend necesita:
1. Escuchar en `0.0.0.0:4000` (no `localhost`)
2. CORS habilitado: `app.use(cors({ origin: '*' }))`

---

## 📞 Si Algo No Funciona

1. Verifica que el backend esté corriendo: `curl http://localhost:4000/api`
2. Verifica tu IP: `ipconfig`
3. Verifica que estés en la misma WiFi
4. Desactiva el firewall temporalmente
5. Revisa los logs en la consola de Flutter (busca `🔧 [AppConfig]`)

---

## 🎉 Ventajas de Esta Implementación

- ✅ No más IPs hardcodeadas
- ✅ Cada dev usa su propia IP sin conflictos
- ✅ Fácil cambiar entre desarrollo y producción
- ✅ Listo para CI/CD
- ✅ Estándar de la industria

---

**¿Dudas?** Lee esta guía de nuevo o pregunta en el equipo.
