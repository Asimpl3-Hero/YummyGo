# 🍽️ YummyGo

Una aplicación móvil de recetas desarrollada con Flutter que te ayuda a descubrir y explorar deliciosas recetas de cocina. Conectada con Firebase para una experiencia en tiempo real.

![Flutter](https://img.shields.io/badge/Flutter-02569B?style=for-the-badge&logo=flutter&logoColor=white)
![Dart](https://img.shields.io/badge/Dart-0175C2?style=for-the-badge&logo=dart&logoColor=white)
![Material Design](https://img.shields.io/badge/Material%20Design-757575?style=for-the-badge&logo=material-design&logoColor=white)

## ✨ Características

- **Exploración de Recetas**: Navega por una amplia colección de recetas organizadas por categorías
- **Búsqueda Inteligente**: Encuentra recetas específicas con la barra de búsqueda integrada
- **Categorías Dinámicas**: Filtra recetas por categorías como "All", y otras categorías personalizadas
- **Información Nutricional**: Visualiza calorías y tiempo de preparación de cada receta
- **Interfaz Moderna**: Diseño limpio y atractivo con iconos de Iconsax
- **Datos en Tiempo Real**: Integración con Firebase Firestore para actualizaciones instantáneas

## 🛠️ Tecnologías Utilizadas

- **Flutter** - Framework de desarrollo multiplataforma
- **Firebase Core** - Plataforma de desarrollo de aplicaciones
- **Cloud Firestore** - Base de datos NoSQL en tiempo real
- **Provider** - Gestión de estado
- **Iconsax** - Biblioteca de iconos moderna
- **Cupertino Icons** - Iconos estilo iOS

## 📱 Capturas de Pantalla

La aplicación incluye:

- Pantalla principal con banner de exploración
- Sistema de categorías horizontales
- Tarjetas de recetas con imágenes, calorías y tiempo de preparación
- Barra de búsqueda funcional
- Notificaciones integradas

## 🚀 Instalación

### Prerrequisitos

- Flutter SDK (versión 3.9.2 o superior)
- Dart SDK
- Android Studio / VS Code
- Cuenta de Firebase

### Pasos de Instalación

1. **Clona el repositorio**

   ```bash
   git clone https://github.com/tu-usuario/yummygo.git
   cd yummygo
   ```

2. **Instala las dependencias**

   ```bash
   flutter pub get
   ```

3. **Configura Firebase**

   - Crea un proyecto en [Firebase Console](https://console.firebase.google.com/)
   - Agrega tu aplicación Android/iOS
   - Descarga el archivo `google-services.json` (Android) o `GoogleService-Info.plist` (iOS)
   - Coloca los archivos en las carpetas correspondientes

4. **Configura Firestore**

   - Crea las siguientes colecciones en Firestore:
     - `Categorias`: Para las categorías de recetas
     - `Complete-Flutter-App`: Para las recetas completas

5. **Ejecuta la aplicación**
   ```bash
   flutter run
   ```

## 📊 Estructura del Proyecto

```
lib/
├── const/
│   └── constants.dart          # Constantes de la aplicación
├── views/
│   ├── app_main_screen.dart    # Pantalla principal de navegación
│   └── my_app_home_screen.dart # Pantalla de inicio con recetas
├── widget/
│   ├── banner.dart             # Widget del banner de exploración
│   ├── food_items_display.dart # Widget para mostrar recetas
│   └── my_icon_button.dart     # Botón de icono personalizado
└── main.dart                   # Punto de entrada de la aplicación
```

## 🔥 Estructura de Datos en Firebase

### Colección `Categorias`

```json
{
  "name": "Breakfast"
}
```

### Colección `Complete-Flutter-App`

```json
{
  "name": "Pancakes Deliciosos",
  "category": "Breakfast",
  "image": "https://example.com/image.jpg",
  "cal": 350,
  "time": 15
}
```

## 🎯 Funcionalidades Principales

### Pantalla Principal

- Header con saludo personalizado
- Barra de búsqueda
- Banner de exploración
- Selector de categorías
- Lista horizontal de recetas

### Sistema de Categorías

- Categoría "All" para mostrar todas las recetas
- Categorías dinámicas desde Firebase
- Filtrado en tiempo real

### Tarjetas de Recetas

- Imagen de la receta
- Nombre de la receta
- Información nutricional (calorías)
- Tiempo de preparación

## 🔧 Configuración Adicional

### Android

- Asegúrate de tener el archivo `google-services.json` en `android/app/`
- Verifica que el `applicationId` coincida con tu proyecto Firebase

### iOS

- Coloca `GoogleService-Info.plist` en `ios/Runner/`
- Configura el Bundle ID en tu proyecto Firebase

## 🤝 Contribución

1. Fork el proyecto
2. Crea una rama para tu feature (`git checkout -b feature/AmazingFeature`)
3. Commit tus cambios (`git commit -m 'Add some AmazingFeature'`)
4. Push a la rama (`git push origin feature/AmazingFeature`)
5. Abre un Pull Request

## 📝 Licencia

Este proyecto está bajo la Licencia MIT. Ver el archivo `LICENSE` para más detalles.

## 👨‍💻 Autor

Desarrollado con ❤️ usando Flutter y Firebase

## 🐛 Reportar Problemas

Si encuentras algún problema o tienes sugerencias, por favor abre un [issue](https://github.com/tu-usuario/yummygo/issues).

---

⭐ ¡No olvides dar una estrella al proyecto si te gustó!
