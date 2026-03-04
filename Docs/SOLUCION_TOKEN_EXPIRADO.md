# 🔐 Solución: Token Expirado en App Móvil

## 🚨 El Problema

Cuando usas la app móvil en el emulador de Android Studio, después de cierto tiempo de inactividad, aparece el error:

```
Exception: Token expirado
```

Y la app muestra el mensaje:

```
No se pudieron cargar los horarios, intenta nuevamente.
No hay horarios programados
```

## 🤔 ¿Por Qué Sucede?

### Flujo del Problema:

1. **Inicias sesión** → El backend te da un token JWT con tiempo de expiración
2. **Usas la app normalmente** → Todo funciona bien
3. **Dejas la app abierta sin usar** → El token expira (por ejemplo, después de 1 hora)
4. **Intentas cargar horarios** → El backend responde con error 401: "Token expirado"
5. **La app muestra error genérico** → No te redirige al login automáticamente

### ¿Cuánto dura el token?

Depende de la configuración del backend. Típicamente:

- Desarrollo: 24 horas
- Producción: 1-2 horas

## ✅ La Solución Implementada

### 1. Detección Automática de Token Expirado

Modificamos `lib/core/api_service.dart` para:

- Detectar respuestas HTTP 401 (No autorizado)
- Verificar si el mensaje contiene "token expirado"
- Limpiar automáticamente la sesión local
- Lanzar una excepción específica `TokenExpiredException`

```dart
// Antes: Solo lanzaba Exception genérica
throw Exception(message);

// Ahora: Detecta y maneja token expirado
if (response.statusCode == 401) {
  await StorageService().clearAll();
  throw TokenExpiredException(message);
}
```

### 2. Redirección Automática al Login

Modificamos las páginas que cargan datos (como `employees_page.dart`) para:

- Capturar `TokenExpiredException`
- Redirigir automáticamente al login
- Mostrar mensaje amigable al usuario

```dart
try {
  final schedules = await _scheduleService.fetchSchedules();
  // ...
} on TokenExpiredException catch (e) {
  // Redirigir al login
  Navigator.of(context).pushNamedAndRemoveUntil('/login', (route) => false);

  // Mostrar mensaje
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(content: Text('Tu sesión ha expirado. Inicia sesión nuevamente.')),
  );
}
```

## 🎯 Cómo Funciona Ahora

### Flujo Mejorado:

1. **Token expira** → Usuario intenta cargar datos
2. **Backend responde 401** → "Token expirado"
3. **ApiService detecta el error** → Limpia sesión local
4. **App redirige al login** → Muestra mensaje amigable
5. **Usuario inicia sesión nuevamente** → Obtiene nuevo token

## 🔧 Archivos Modificados

### 1. `lib/core/api_service.dart`

- ✅ Agregado método `_handleResponse()` para detectar token expirado
- ✅ Agregada clase `TokenExpiredException`
- ✅ Limpieza automática de sesión en error 401

### 2. `lib/core/token_expired_handler.dart` (NUEVO)

- ✅ Helper global para simplificar el manejo de token expirado
- ✅ Método `handle()` para funciones con retorno
- ✅ Método `handleVoid()` para funciones sin retorno
- ✅ Redirección y mensaje automáticos

### 3. `lib/presentation/pages/employees/employees_page.dart`

- ✅ Manejo específico de `TokenExpiredException`
- ✅ Redirección automática al login
- ✅ Mensaje amigable al usuario

## 📝 Aplicar en Otras Páginas

Hay dos formas de manejar el token expirado en tus páginas:

### Opción 1: Usar TokenExpiredHandler (Recomendado - Más Simple)

```dart
import '../../../core/token_expired_handler.dart';

// En tu método que carga datos:
Future<void> _loadData() async {
  setState(() => _isLoading = true);

  await TokenExpiredHandler.handle(context, () async {
    final data = await _service.fetchData();
    setState(() {
      _data = data;
      _isLoading = false;
    });
  });

  // Si llegamos aquí y hubo TokenExpiredException, ya fuimos redirigidos al login
  if (mounted) {
    setState(() => _isLoading = false);
  }
}
```

### Opción 2: Manejo Manual (Más Control)

Si tienes otras páginas que cargan datos del backend, aplica el mismo patrón:

```dart
import '../../../core/api_service.dart'; // Importar TokenExpiredException

// En tu método que carga datos:
try {
  final data = await _service.fetchData();
  // ...
} on TokenExpiredException catch (e) {
  if (mounted) {
    Navigator.of(context).pushNamedAndRemoveUntil('/login', (route) => false);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Tu sesión ha expirado. Por favor, inicia sesión nuevamente.'),
        backgroundColor: Colors.orange,
      ),
    );
  }
} catch (error) {
  // Manejar otros errores
}
```

## 🧪 Cómo Probar

### Opción 1: Esperar a que expire (lento)

1. Inicia sesión en la app
2. Espera el tiempo de expiración del token (ej: 1 hora)
3. Intenta cargar horarios
4. Deberías ser redirigido al login automáticamente

### Opción 2: Forzar expiración (rápido)

**En el backend**, reduce temporalmente el tiempo de expiración:

```javascript
// En tu archivo de configuración JWT (backend)
const token = jwt.sign(payload, secret, {
  expiresIn: "30s", // 30 segundos para pruebas
});
```

Luego:

1. Inicia sesión en la app
2. Espera 30 segundos
3. Intenta cargar horarios
4. Deberías ser redirigido al login

### Opción 3: Simular en el backend (más técnico)

Modifica temporalmente el endpoint de horarios para devolver 401:

```javascript
// En tu ruta de horarios (backend)
router.get("/schedules", (req, res) => {
  return res.status(401).json({
    success: false,
    message: "Token expirado",
  });
});
```

## 🚀 Mejoras Futuras (Opcional)

### 1. Refresh Token

Implementar un sistema de refresh token para renovar automáticamente sin pedir login:

```dart
// Cuando el token expira:
// 1. Intentar renovar con refresh token
// 2. Si falla, entonces redirigir al login
```

### 2. Interceptor Global

Crear un interceptor HTTP global que maneje todos los errores 401 automáticamente:

```dart
class HttpInterceptor {
  static Future<http.Response> handleResponse(http.Response response) async {
    if (response.statusCode == 401) {
      // Manejar globalmente
      await _redirectToLogin();
    }
    return response;
  }
}
```

### 3. Notificación Preventiva

Avisar al usuario antes de que expire:

```dart
// 5 minutos antes de expirar:
showDialog(
  context: context,
  builder: (context) => AlertDialog(
    title: Text('Tu sesión está por expirar'),
    content: Text('¿Deseas continuar?'),
    actions: [
      TextButton(
        onPressed: () => _refreshToken(),
        child: Text('Sí, continuar'),
      ),
    ],
  ),
);
```

## ❓ Preguntas Frecuentes

### ¿Por qué no usar refresh token desde el inicio?

Refresh token es más complejo de implementar y requiere:

- Almacenar dos tokens (access + refresh)
- Endpoint adicional en el backend
- Lógica de renovación automática

Para una app en desarrollo, la solución actual es suficiente.

### ¿El token se guarda de forma segura?

Sí, usamos `flutter_secure_storage` que:

- En Android: usa Keystore
- En iOS: usa Keychain
- Encripta los datos automáticamente

### ¿Qué pasa si cierro la app?

El token se mantiene guardado. Al abrir la app:

- Si el token es válido → Entras directo
- Si expiró → Te redirige al login

### ¿Puedo aumentar el tiempo de expiración?

Sí, pero no es recomendado por seguridad. Modifica en el backend:

```javascript
// Aumentar a 7 días (no recomendado en producción)
expiresIn: "7d";
```

## 🎉 Resumen

- ✅ Token expirado se detecta automáticamente
- ✅ Sesión se limpia automáticamente
- ✅ Usuario es redirigido al login
- ✅ Mensaje amigable se muestra
- ✅ No más pantallas con errores confusos

---

**¿Dudas?** Revisa el código en `lib/core/api_service.dart` o pregunta al equipo.
