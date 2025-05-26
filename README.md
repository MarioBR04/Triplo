# Triplo - Aplicación de Transporte

## Descripción

Triplo es una aplicación móvil desarrollada en Flutter que conecta pasajeros y conductores para ofrecer servicios de transporte de manera eficiente y segura. La aplicación está diseñada para facilitar la solicitud y gestión de viajes, integrando funcionalidades modernas tanto para usuarios pasajeros como para conductores.

## Enfoque de Interacción

El flujo principal de Triplo se basa en la interacción entre pasajeros y conductores, como se ilustra en el diagrama anterior:

1. **El pasajero solicita un viaje** indicando su destino y número de pasajeros.
2. **El sistema busca un conductor disponible** cercano a la ubicación del pasajero.
3. **El conductor recibe la solicitud** y puede aceptarla o rechazarla.
4. **Una vez aceptada**, el conductor se dirige al punto de recogida y el pasajero puede seguir el trayecto en tiempo real.
5. **Al finalizar el viaje**, ambos pueden calificar la experiencia.

Este enfoque asegura una comunicación clara y eficiente entre ambas partes, optimizando la experiencia de usuario y la gestión de viajes.

## Características Principales

### Para Pasajeros

- **Solicitud de Viajes**

  - Búsqueda de ubicaciones con Google Places API
  - Visualización de rutas en mapa interactivo
  - Estimación de precios y tiempos de viaje

- **Gestión de Cuenta**

  - Perfil de usuario personalizable
  - Historial de viajes
  - Calificaciones y reseñas

- **Funcionalidades Adicionales**
  - Programación de viajes futuros
  - Sistema de mensajería integrado

### Para Conductores

- **Modo Conductor**
  - Panel de control con mapa en tiempo real
  - Gestión y aceptación de solicitudes de viaje
  - Visualización de información relevante del pasajero
  - Sistema de navegación integrado para optimizar rutas

### Características Generales

- Interfaz de usuario intuitiva y moderna
- Integración con Google Maps y Google Places
- Autenticación y gestión de usuarios con Firebase

## Estructura del Proyecto

### Páginas Principales

- `home.dart`: Pantalla principal con mapa y búsqueda de viajes
- `driver_mode_page.dart`: Interfaz para conductores
- `profile_page.dart`: Gestión de perfil de usuario
- `travel_history_page.dart`: Historial de viajes realizados
- `settings_page.dart`: Configuración de la aplicación
- `login.dart`: Autenticación de usuarios

### Servicios

- `loginService.dart`: Gestión de autenticación con Firebase
- `driver_service.dart`: Lógica para el modo conductor

### Componentes

- `sidebar.dart`: Menú lateral de navegación
- Widgets reutilizables para mapas y formularios

## Tecnologías Utilizadas

- Flutter
- Firebase Authentication
- Firebase Firestore
- Google Maps API
- Google Places API

## Requisitos del Sistema

- Flutter SDK
- Cuenta de Google Cloud Platform (para APIs de Google)
- Proyecto Firebase configurado
- iOS 11.0+ / Android 5.0+

## Configuración del Proyecto

1. Clonar el repositorio

git clone [URL_DEL_REPOSITORIO]

2. Instalar dependencias

flutter pub get

3. Configurar las claves de API

   - Agregar la API key de Google Maps en `android/app/src/main/AndroidManifest.xml`
   - Configurar `google-services.json` para Android
   - Configurar `GoogleService-Info.plist` para iOS

4. Ejecutar la aplicación

flutter run
