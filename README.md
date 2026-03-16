# 🌟 AstroStar Mobile

Aplicación móvil de AstroStar desarrollada con **Flutter**, pensada como cliente para el backend de AstroStar.

Permite consumir la API (`/api`) del backend para gestionar atletas, servicios, inscripciones, etc.

## 📋 Tabla de contenidos

- [Requisitos previos](#-requisitos-previos)
- [Inicio rápido](#-inicio-rápido)
- [Configuración de entornos](#-configuración-de-entornos)
- [Conexión con el backend](#-conexión-con-el-backend)
- [Pruebas y calidad](#-pruebas-y-calidad)
- [Documentación adicional](#-documentación-adicional)

## 📌 Requisitos previos

- **Flutter SDK** instalado (canal estable).
- Dispositivo físico o emulador Android/iOS configurado.
- Backend AstroStar corriendo y accesible desde el dispositivo:
  - Escuchando en `0.0.0.0:4000`
  - Con CORS habilitado.

## 🚀 Inicio rápido

### 1. Instalar dependencias

```bash
flutter pub get
```

### 2. Ejecutar la app

**Opción recomendada (VS Code / Android Studio):**

- Abre la carpeta `astrostar_mobile`.
- Selecciona un dispositivo (físico o emulador).
- Presiona `F5` o usa el botón de "Run".
- Si usas dispositivo físico, asegúrate de usar la IP de tu máquina (no `localhost`) para el backend.

**Línea de comandos:**

```bash
# 1. Obtén tu IP local (Windows)
ipconfig

# 2. Ejecuta la app apuntando al backend
flutter run --dart-define=API_URL=http://TU_IP_LOCAL:4000/api
```

Sustituye `TU_IP_LOCAL` por la IP que te devuelva `ipconfig`, por ejemplo `192.168.0.10`.

## ⚙️ Configuración de entornos

Toda la configuración de entornos (desarrollo, QA, producción, etc.) se documenta en:

- `CONFIGURACION_AMBIENTES.md` – **LEE ESTO PRIMERO**

Ahí encontrarás cómo:

- Definir `API_URL` según el entorno.
- Ajustar puertos.
- Configurar backends locales/remotos.

## 🌐 Conexión con el backend

Para que la app móvil se conecte correctamente:

1. El backend debe escuchar en `0.0.0.0:4000` (no solo en `localhost`).
2. El dispositivo/emulador debe poder resolver la IP de tu máquina (por ejemplo `192.168.x.x`).
3. CORS debe estar habilitado en el backend.

Revisa `CONFIGURACION_AMBIENTES.md` para detalles completos.

## ✅ Pruebas y calidad

Dependiendo de tu configuración puedes usar:

- `flutter test` – pruebas unitarias.
- `flutter analyze` – análisis estático.
- `flutter format` – formateo de código.

Ejemplo:

```bash
flutter test
flutter analyze
```

Si más adelante agregas pruebas instrumentadas o golden tests, puedes documentarlas aquí.

## 📚 Documentación adicional

- `CONFIGURACION_AMBIENTES.md` – guía completa de configuración de ambientes.
- `PERMISSIONS_GUIDE.md` – guía de permisos de la app (Android/iOS).

---

**AstroStar Mobile – Flutter Client**
