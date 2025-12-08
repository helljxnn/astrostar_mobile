# Instrucciones para Agregar Avatar Color al Backend

## 📋 Cambios Necesarios en el Backend

### 1️⃣ Agregar Campo a la Base de Datos

Ejecuta esta migración en tu base de datos:

```sql
-- Agregar columna avatarColorIndex a la tabla users
ALTER TABLE users 
ADD COLUMN avatarColorIndex INT DEFAULT 0;

-- Opcional: Actualizar usuarios existentes con colores aleatorios
UPDATE users 
SET avatarColorIndex = FLOOR(RAND() * 6);
```

### 2️⃣ Actualizar el Modelo User (Backend)

En tu archivo `user.model.js` o similar, agrega el campo:

```javascript
// models/user.model.js
const UserSchema = new Schema({
  // ... campos existentes ...
  avatarColorIndex: {
    type: Number,
    default: 0,
    min: 0,
    max: 5, // Hay 6 colores (0-5)
  },
});
```

O si usas TypeScript:

```typescript
// models/user.model.ts
export interface User {
  // ... campos existentes ...
  avatarColorIndex?: number;
}
```

### 3️⃣ Actualizar el Endpoint de Login

Asegúrate de que el endpoint `/auth/login` devuelva el campo `avatarColorIndex`:

```javascript
// controllers/auth.controller.js
async login(req, res) {
  // ... lógica de login ...
  
  const userData = {
    id: user.id,
    email: user.email,
    firstName: user.firstName,
    lastName: user.lastName,
    // ... otros campos ...
    avatarColorIndex: user.avatarColorIndex || 0, // ← Agregar esto
    role: user.role,
  };
  
  res.json({
    success: true,
    data: {
      user: userData,
      accessToken: token,
    },
  });
}
```

### 4️⃣ Crear Endpoint para Actualizar Perfil

Crea un nuevo endpoint `PUT /auth/profile` o `PATCH /users/me`:

```javascript
// routes/auth.routes.js
router.put('/profile', authMiddleware, updateProfile);
```

```javascript
// controllers/auth.controller.js
async updateProfile(req, res) {
  try {
    const userId = req.user.id; // Del token JWT
    const { firstName, lastName, avatarColorIndex } = req.body;
    
    // Validar avatarColorIndex
    if (avatarColorIndex !== undefined) {
      if (avatarColorIndex < 0 || avatarColorIndex > 5) {
        return res.status(400).json({
          success: false,
          message: 'avatarColorIndex debe estar entre 0 y 5',
        });
      }
    }
    
    // Actualizar usuario
    const updatedUser = await User.findByIdAndUpdate(
      userId,
      {
        firstName,
        lastName,
        avatarColorIndex,
      },
      { new: true, runValidators: true }
    );
    
    if (!updatedUser) {
      return res.status(404).json({
        success: false,
        message: 'Usuario no encontrado',
      });
    }
    
    // Devolver usuario actualizado
    res.json({
      success: true,
      message: 'Perfil actualizado exitosamente',
      data: {
        user: {
          id: updatedUser.id,
          email: updatedUser.email,
          firstName: updatedUser.firstName,
          lastName: updatedUser.lastName,
          avatarColorIndex: updatedUser.avatarColorIndex,
          // ... otros campos necesarios ...
        },
      },
    });
  } catch (error) {
    console.error('Error al actualizar perfil:', error);
    res.status(500).json({
      success: false,
      message: 'Error al actualizar perfil',
    });
  }
}
```

### 5️⃣ Validaciones (Opcional pero Recomendado)

```javascript
// validators/profile.validator.js
const { body } = require('express-validator');

const updateProfileValidation = [
  body('firstName')
    .optional()
    .trim()
    .isLength({ min: 2, max: 50 })
    .withMessage('El nombre debe tener entre 2 y 50 caracteres'),
  
  body('lastName')
    .optional()
    .trim()
    .isLength({ min: 2, max: 50 })
    .withMessage('El apellido debe tener entre 2 y 50 caracteres'),
  
  body('avatarColorIndex')
    .optional()
    .isInt({ min: 0, max: 5 })
    .withMessage('El índice de color debe estar entre 0 y 5'),
];

module.exports = { updateProfileValidation };
```

## 🎨 Colores Disponibles (Referencia)

Los índices corresponden a estos colores:

```javascript
const avatarColors = [
  '#6C5CE7', // 0 - Púrpura
  '#74B9FF', // 1 - Azul
  '#FF6B95', // 2 - Rosa
  '#FDCB6E', // 3 - Amarillo
  '#00B894', // 4 - Verde
  '#FD79A8', // 5 - Rosa fuerte
];
```

## ✅ Checklist de Implementación

- [ ] Agregar columna `avatarColorIndex` a la tabla `users`
- [ ] Actualizar modelo User en el backend
- [ ] Modificar endpoint `/auth/login` para incluir `avatarColorIndex`
- [ ] Crear endpoint `PUT /auth/profile` para actualizar perfil
- [ ] Agregar validaciones para `avatarColorIndex`
- [ ] Probar que el login devuelve el campo correctamente
- [ ] Probar que se puede actualizar el perfil
- [ ] Verificar que el color se persiste en la base de datos

## 🧪 Pruebas

### Probar Login:
```bash
curl -X POST http://localhost:4000/api/auth/login \
  -H "Content-Type: application/json" \
  -d '{"email":"test@example.com","password":"password123"}'
```

Respuesta esperada debe incluir:
```json
{
  "success": true,
  "data": {
    "user": {
      "id": 1,
      "email": "test@example.com",
      "firstName": "Juan",
      "lastName": "Pérez",
      "avatarColorIndex": 0,
      ...
    }
  }
}
```

### Probar Actualización de Perfil:
```bash
curl -X PUT http://localhost:4000/api/auth/profile \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer YOUR_TOKEN_HERE" \
  -d '{
    "firstName": "Juan",
    "lastName": "Pérez",
    "avatarColorIndex": 3
  }'
```

## 📱 Integración con la App Móvil

Una vez implementado el backend, la app móvil ya está lista para:
1. ✅ Recibir el `avatarColorIndex` en el login
2. ✅ Mostrar el color correcto en el avatar
3. ✅ Enviar el nuevo color al backend cuando se guarda

Solo falta crear el servicio en la app para llamar al endpoint de actualización.

---

**Nota:** Si necesitas ayuda con algún paso específico o tienes dudas sobre la implementación, avísame.
