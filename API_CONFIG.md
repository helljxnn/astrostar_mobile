# Configuración de la API

## Configurar la URL del Backend

Para que la aplicación móvil se conecte correctamente con el backend, debes actualizar la URL base en el archivo de configuración de la API.

### Archivo a modificar:
`lib/core/api_service.dart`

### Cambiar la URL:

```dart
class ApiService {
  // Cambia esta URL por la URL de tu backend
  static const String baseUrl = 'http://localhost:3000/api';
  // ...
}
```

### Opciones de configuración:

1. **Desarrollo local (Android Emulator):**
   ```dart
   static const String baseUrl = 'http://10.0.2.2:3000/api';
   ```

2. **Desarrollo local (iOS Simulator):**
   ```dart
   static const String baseUrl = 'http://localhost:3000/api';
   ```

3. **Desarrollo local (Dispositivo físico en la misma red):**
   ```dart
   static const String baseUrl = 'http://192.168.x.x:3000/api';
   ```
   (Reemplaza `192.168.x.x` con la IP local de tu computadora)

4. **Producción:**
   ```dart
   static const String baseUrl = 'https://tu-dominio.com/api';
   ```

## Endpoints utilizados

La aplicación consume los siguientes endpoints del backend:

- `GET /api/services` - Obtiene todos los eventos
- `GET /api/services/:id` - Obtiene un evento específico por ID

## Estructura de datos esperada

El backend debe retornar eventos con la siguiente estructura:

```json
{
  "id": 1,
  "name": "Nombre del evento",
  "description": "Descripción opcional",
  "startDate": "2025-01-15T00:00:00.000Z",
  "endDate": "2025-01-15T00:00:00.000Z",
  "startTime": "10:00",
  "endTime": "13:00",
  "location": "Ubicación del evento",
  "phone": "1234567890",
  "status": "Programado",
  "imageUrl": null,
  "scheduleFile": null,
  "publish": true,
  "categoryId": 1,
  "typeId": 1,
  "category": {
    "id": 1,
    "name": "Categoría"
  },
  "type": {
    "id": 1,
    "name": "Tipo"
  },
  "sponsors": [
    {
      "id": 1,
      "sponsor": {
        "id": 1,
        "name": "Patrocinador",
        "logoUrl": null
      }
    }
  ]
}
```

## Instalación de dependencias

Después de clonar el proyecto, ejecuta:

```bash
flutter pub get
```

## Estados del evento

Los eventos pueden tener los siguientes estados:
- `Programado` - Color azul claro
- `Finalizado` - Color verde
- `Cancelado` - Color rosa
- `En_pausa` - Color morado
