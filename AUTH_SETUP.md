# 🔐 Sistema de Autenticación - AstroStar Mobile

## ✅ Implementación Completada

Se ha implementado el sistema completo de autenticación conectado a la API de Node.js + Express + Prisma.

## 📋 Características Implementadas

### 1. Login
- ✅ Validación de credenciales con API
- ✅ Almacenamiento seguro de tokens (flutter_secure_storage)
- ✅ Manejo de estados con BLoC
- ✅ Mensajes de error personalizados
- ✅ Rate limiting

### 2. Recuperación de Contraseña
- ✅ Envío de código por email
- ✅ Verificación de código de 4 dígitos
- ✅ Cambio de contraseña con validaciones
- ✅ Reenvío de código con cooldown

### 3. Gestión de Sesión
- ✅ Almacenamiento de usuario en SharedPreferences
- ✅ Token de acceso en almacenamiento seguro
- ✅ Logout con limpieza de datos
- ✅ Verificación de autenticación al iniciar

## 🔧 Configuración

### 1. URL de la API

Edita el archivo `lib/data/services/auth_service.dart`:

```dart
// Para emulador Android
static const String baseUrl = 'http://10.0.2.2:4000/api';

// Para dispositivo físico (reemplaza con tu IP local)
static const String baseUrl = 'http://192.168.1.X:4000/api';

// Para producción
static const String baseUrl = 'https://tu-dominio.com/api';
```

### 2. Verificar que tu API esté corriendo

```bash
# En el proyecto del backend
npm run dev
# o
yarn dev
```

La API debe estar corriendo en `http://localhost:4000`

### 3. Ejecutar la app

```bash
# Instalar dependencias
flutter pub get

# Ejecutar en dispositivo/emulador
flutter run

# O ejecutar en dispositivo específico
flutter run -d <device-id>
```

## 📱 Flujo de Autenticación

### Login
1. Usuario ingresa email y contraseña
2. App hace POST a `/api/auth/login`
3. Si es exitoso:
   - Guarda `accessToken` en secure storage
   - Guarda datos del `user` en SharedPreferences
   - Navega a MainPage
4. Si falla:
   - Muestra mensaje de error

### Recuperar Contraseña
1. Usuario ingresa email → POST `/api/auth/forgot-password`
2. Usuario ingresa código de 4 dígitos → POST `/api/auth/verify-reset-token`
3. Usuario crea nueva contraseña → POST `/api/auth/reset-password`
4. Redirige a login

### Logout
1. Usuario hace logout
2. App hace POST a `/api/auth/logout`
3. Limpia tokens y datos locales
4. Redirige a login

## 🗂️ Estructura de Archivos

```
lib/
├── blocs/
│   └── auth/
│       ├── auth_bloc.dart       # Lógica de estado
│       ├── auth_event.dart      # Eventos
│       └── auth_state.dart      # Estados
├── core/
│   ├── storage_service.dart     # Almacenamiento seguro
│   ├── api_service.dart         # Cliente HTTP base
│   ├── alerts.dart              # Alertas personalizadas
│   └── app_colors.dart          # Colores de la app
├── data/
│   ├── models/
│   │   ├── user_model.dart      # Modelo de usuario
│   │   └── auth_response.dart   # Respuestas de auth
│   └── services/
│       └── auth_service.dart    # Servicio de autenticación
└── presentation/
    └── pages/
        └── auth/
            ├── pages/
            │   ├── login_page.dart
            │   ├── reset_password_page.dart
            │   ├── verify_code_page.dart
            │   └── new_password_page.dart
            └── validators/
                └── auth_validators.dart
```

## 🔑 Almacenamiento

### Secure Storage (flutter_secure_storage)
- `access_token`: Token JWT de acceso

### SharedPreferences
- `user_data`: Datos del usuario en JSON

## 🚨 Manejo de Errores

La app maneja los siguientes códigos de error:

- **400**: Datos inválidos
- **401**: Credenciales incorrectas o token inválido
- **403**: Usuario inactivo
- **404**: Usuario no encontrado
- **500**: Error del servidor

## 🧪 Pruebas

### Credenciales de prueba (si existen en tu backend)
```
Email: usuario@ejemplo.com
Password: tu_contraseña
```

### Probar recuperación de contraseña
1. Ir a "¿Olvidaste tu contraseña?"
2. Ingresar email registrado
3. Verificar que llegue el código al email
4. Ingresar código de 4 dígitos
5. Crear nueva contraseña

## 📝 Notas Importantes

1. **Modo Desarrollador en Windows**: Si usas plugins nativos, activa el modo desarrollador en Windows
2. **Permisos de Internet**: Ya configurados en Android y iOS
3. **HTTPS en Producción**: Asegúrate de usar HTTPS en producción
4. **Tokens**: Los tokens se manejan automáticamente, no necesitas gestionarlos manualmente

## 🐛 Troubleshooting

### Error de conexión
- Verifica que la API esté corriendo
- Verifica la URL en `auth_service.dart`
- Si usas dispositivo físico, asegúrate de estar en la misma red

### Error "Token inválido"
- Haz logout y vuelve a hacer login
- Verifica que el JWT_SECRET sea el mismo en backend y frontend

### Error al guardar datos
- En Android: Verifica permisos de almacenamiento
- En iOS: Verifica configuración de Keychain

## 📚 Dependencias Utilizadas

```yaml
dependencies:
  flutter_bloc: ^8.1.3          # Manejo de estado
  equatable: ^2.0.5             # Comparación de objetos
  http: ^1.2.0                  # Cliente HTTP
  flutter_secure_storage: ^9.0.0 # Almacenamiento seguro
  shared_preferences: ^2.2.2    # Preferencias locales
  google_fonts: ^4.0.3          # Fuentes personalizadas
```

## ✨ Próximos Pasos

- [ ] Implementar refresh token automático
- [ ] Agregar biometría (huella/Face ID)
- [ ] Implementar "Recordarme"
- [ ] Agregar analytics de autenticación
- [ ] Implementar 2FA (autenticación de dos factores)

---

**Desarrollado para AstroStar Mobile** 🌟
