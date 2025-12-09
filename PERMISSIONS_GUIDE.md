# Guía de Implementación de Permisos y Roles en AstroStar Mobile

## 📋 Estructura de Permisos

### Roles Disponibles
- **Administrador** - Acceso total a todos los módulos
- **Entrenador** - Acceso a gestión de entrenamientos y asistencia
- **Deportista** - Acceso limitado a su información personal

### Módulos del Sistema
1. `appointmentManagement` - Gestión de Citas
2. `employeesSchedule` - Horarios de Empleados
3. `sportsEquipment` - Equipamiento Deportivo
4. `attendance` - Control de Asistencia

### Acciones por Módulo
- `Ver` - Visualizar información
- `Crear` - Crear nuevos registros
- `Editar` - Modificar registros existentes
- `Eliminar` - Borrar registros

---

## 🔧 Cómo Usar el Sistema de Permisos

### 1. Obtener el Usuario Actual

```dart
import 'package:flutter_bloc/flutter_bloc.dart';
import '../blocs/auth/auth_bloc.dart';
import '../blocs/auth/auth_state.dart';
import '../core/permissions_service.dart';

// En tu widget
final authState = context.watch<AuthBloc>().state;

if (authState is AuthAuthenticated) {
  final user = authState.user;
  final permissions = PermissionsService(user);
  
  // Ahora puedes usar permissions
}
```

### 2. Verificar Acceso a Módulos

```dart
// Verificar si puede acceder a un módulo completo
if (permissions.canAccessAppointments) {
  // Mostrar página de citas
}

if (permissions.canAccessSportsEquipment) {
  // Mostrar página de equipamiento
}

if (permissions.canAccessAttendance) {
  // Mostrar página de asistencia
}
```

### 3. Verificar Acciones Específicas

```dart
// Verificar si puede crear una cita
if (permissions.canCreateAppointment()) {
  // Mostrar botón "Nueva Cita"
}

// Verificar si puede editar
if (permissions.canEditAppointment()) {
  // Mostrar botón "Editar"
}

// Verificar si puede eliminar
if (permissions.canDeleteAppointment()) {
  // Mostrar botón "Eliminar"
}
```

### 4. Verificar Permisos Genéricos

```dart
// Para cualquier módulo y acción
if (permissions.hasModulePermission('appointmentManagement', 'Ver')) {
  // Tiene permiso de ver citas
}

if (permissions.hasModulePermission('sportsEquipment', 'Crear')) {
  // Tiene permiso de crear equipamiento
}
```

---

## 🎨 Ejemplos de Implementación en UI

### Ejemplo 1: Ocultar Botones según Permisos

```dart
class AppointmentsPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final authState = context.watch<AuthBloc>().state;
    
    if (authState is! AuthAuthenticated) {
      return LoginPage();
    }
    
    final permissions = PermissionsService(authState.user);
    
    return Scaffold(
      appBar: AppBar(
        title: Text('Citas'),
        actions: [
          // Solo mostrar botón si tiene permiso de crear
          if (permissions.canCreateAppointment())
            IconButton(
              icon: Icon(Icons.add),
              onPressed: () => _createAppointment(context),
            ),
        ],
      ),
      body: AppointmentsList(
        canEdit: permissions.canEditAppointment(),
        canDelete: permissions.canDeleteAppointment(),
      ),
    );
  }
}
```

### Ejemplo 2: Deshabilitar Acciones

```dart
class AppointmentCard extends StatelessWidget {
  final Appointment appointment;
  final bool canEdit;
  final bool canDelete;
  
  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        title: Text(appointment.title),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Botón editar - deshabilitado si no tiene permiso
            IconButton(
              icon: Icon(Icons.edit),
              onPressed: canEdit ? () => _editAppointment() : null,
              color: canEdit ? Colors.blue : Colors.grey,
            ),
            // Botón eliminar - deshabilitado si no tiene permiso
            IconButton(
              icon: Icon(Icons.delete),
              onPressed: canDelete ? () => _deleteAppointment() : null,
              color: canDelete ? Colors.red : Colors.grey,
            ),
          ],
        ),
      ),
    );
  }
}
```

### Ejemplo 3: Navegación Condicional

```dart
class MainPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final authState = context.watch<AuthBloc>().state;
    
    if (authState is! AuthAuthenticated) {
      return LoginPage();
    }
    
    final permissions = PermissionsService(authState.user);
    
    return Scaffold(
      drawer: Drawer(
        child: ListView(
          children: [
            // Siempre visible
            ListTile(
              leading: Icon(Icons.home),
              title: Text('Inicio'),
              onTap: () => Navigator.pushNamed(context, '/home'),
            ),
            
            // Solo si tiene acceso a citas
            if (permissions.canAccessAppointments)
              ListTile(
                leading: Icon(Icons.calendar_today),
                title: Text('Citas'),
                onTap: () => Navigator.pushNamed(context, '/appointments'),
              ),
            
            // Solo si tiene acceso a equipamiento
            if (permissions.canAccessSportsEquipment)
              ListTile(
                leading: Icon(Icons.sports_soccer),
                title: Text('Equipamiento'),
                onTap: () => Navigator.pushNamed(context, '/equipment'),
              ),
            
            // Solo si tiene acceso a asistencia
            if (permissions.canAccessAttendance)
              ListTile(
                leading: Icon(Icons.check_circle),
                title: Text('Asistencia'),
                onTap: () => Navigator.pushNamed(context, '/attendance'),
              ),
            
            // Solo administradores
            if (permissions.isAdmin)
              ListTile(
                leading: Icon(Icons.settings),
                title: Text('Configuración'),
                onTap: () => Navigator.pushNamed(context, '/settings'),
              ),
          ],
        ),
      ),
      body: HomeContent(),
    );
  }
}
```

### Ejemplo 4: Proteger Rutas

```dart
// En main.dart o router
class AppRouter {
  static Route<dynamic> generateRoute(RouteSettings settings) {
    // Obtener usuario actual
    final authBloc = BlocProvider.of<AuthBloc>(navigatorKey.currentContext!);
    final authState = authBloc.state;
    
    if (authState is! AuthAuthenticated) {
      return MaterialPageRoute(builder: (_) => LoginPage());
    }
    
    final permissions = PermissionsService(authState.user);
    
    switch (settings.name) {
      case '/appointments':
        if (!permissions.canAccessAppointments) {
          return MaterialPageRoute(
            builder: (_) => UnauthorizedPage(
              message: 'No tienes acceso a este módulo',
            ),
          );
        }
        return MaterialPageRoute(builder: (_) => AppointmentsPage());
        
      case '/equipment':
        if (!permissions.canAccessSportsEquipment) {
          return MaterialPageRoute(builder: (_) => UnauthorizedPage());
        }
        return MaterialPageRoute(builder: (_) => EquipmentPage());
        
      case '/settings':
        if (!permissions.isAdmin) {
          return MaterialPageRoute(builder: (_) => UnauthorizedPage());
        }
        return MaterialPageRoute(builder: (_) => SettingsPage());
        
      default:
        return MaterialPageRoute(builder: (_) => HomePage());
    }
  }
}
```

### Ejemplo 5: Página de No Autorizado

```dart
class UnauthorizedPage extends StatelessWidget {
  final String message;
  
  const UnauthorizedPage({
    Key? key,
    this.message = 'No tienes permisos para acceder a esta página',
  }) : super(key: key);
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Acceso Denegado'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.lock_outline,
              size: 80,
              color: Colors.grey,
            ),
            SizedBox(height: 24),
            Text(
              message,
              style: TextStyle(fontSize: 18),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 24),
            ElevatedButton(
              onPressed: () => Navigator.pop(context),
              child: Text('Volver'),
            ),
          ],
        ),
      ),
    );
  }
}
```

---

## 🔐 Mejores Prácticas

### 1. Siempre Verificar en el Backend
```dart
// ❌ MAL - Solo verificar en el frontend
if (permissions.canDelete()) {
  await deleteAppointment(id); // Sin verificación en backend
}

// ✅ BIEN - El backend también verifica
if (permissions.canDelete()) {
  try {
    await deleteAppointment(id); // Backend verifica permisos
  } catch (e) {
    if (e is UnauthorizedException) {
      showError('No tienes permisos para esta acción');
    }
  }
}
```

### 2. Usar BLoC para Estado Global
```dart
// Crear un PermissionsBloc si necesitas reactividad
class PermissionsBloc extends Bloc<PermissionsEvent, PermissionsState> {
  final AuthBloc authBloc;
  
  PermissionsBloc(this.authBloc) : super(PermissionsInitial()) {
    authBloc.stream.listen((authState) {
      if (authState is AuthAuthenticated) {
        add(UpdatePermissions(authState.user));
      }
    });
  }
}
```

### 3. Cachear Permisos
```dart
class PermissionsService {
  final User user;
  late final Map<String, bool> _cache = {};
  
  PermissionsService(this.user);
  
  bool hasModulePermission(String module, String action) {
    final key = '$module:$action';
    
    if (_cache.containsKey(key)) {
      return _cache[key]!;
    }
    
    final result = isAdmin || user.role.hasPermission(module, action);
    _cache[key] = result;
    return result;
  }
}
```

### 4. Logging de Accesos Denegados
```dart
void _logUnauthorizedAccess(String module, String action) {
  print('⚠️ Acceso denegado: $module - $action');
  // Enviar a analytics o logging service
}

if (!permissions.canDelete()) {
  _logUnauthorizedAccess('appointments', 'delete');
  showError('No tienes permisos');
  return;
}
```

---

## 📊 Estructura de Permisos en JSON

Ejemplo de cómo llegan los permisos desde el backend:

```json
{
  "id": 2,
  "name": "Entrenador",
  "description": "Gestiona entrenamientos y asistencia",
  "permissions": {
    "appointmentManagement": {
      "Ver": true,
      "Crear": true,
      "Editar": true,
      "Eliminar": false
    },
    "employeesSchedule": {
      "Ver": true,
      "Crear": false,
      "Editar": false,
      "Eliminar": false
    },
    "sportsEquipment": {
      "Ver": true,
      "Crear": false,
      "Editar": false,
      "Eliminar": false
    }
  }
}
```

---

## ✅ Checklist de Implementación

- [ ] Verificar que el modelo `User` y `Role` estén correctos
- [ ] Implementar `PermissionsService` con todos los módulos
- [ ] Proteger rutas de navegación
- [ ] Ocultar/deshabilitar botones según permisos
- [ ] Mostrar mensajes apropiados cuando no hay permisos
- [ ] Verificar permisos en el backend también
- [ ] Agregar logging de accesos denegados
- [ ] Crear página de "No Autorizado"
- [ ] Probar con diferentes roles
- [ ] Documentar permisos de cada módulo

---

## 🚀 Próximos Pasos

1. Revisa tu `PermissionsService` actual y agrega los módulos que falten
2. Implementa la verificación de permisos en cada página
3. Protege las rutas de navegación
4. Prueba con usuarios de diferentes roles
5. Asegúrate de que el backend también valide los permisos

¿Necesitas ayuda con algún módulo específico o quieres que te muestre cómo implementar permisos en una página en particular?
