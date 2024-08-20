# Aplicación de Contactos de Usuario

## Descripción

Esta es una aplicación desarrollada en Flutter que permite a los usuarios gestionar sus contactos. Los usuarios pueden añadir, editar, eliminar y buscar sus contactos. La app soporta modo oscuro e incluye autenticación de usuarios.

## Requisitos Previos

Antes de empezar, asegúrate de cumplir con los siguientes requisitos:

- **Flutter SDK**: [Instala Flutter](https://flutter.dev/docs/get-started/install) y asegúrate de que está configurado correctamente en tu entorno de desarrollo.
- **Dart SDK**: Dart viene incluido con Flutter.
- **Android Studio** o **VS Code**: Instala uno de estos IDEs para el desarrollo. Asegúrate de tener los plugins de Flutter y Dart instalados.
- **Android SDK**: Asegúrate de que el Android SDK esté instalado y configurado.
- **Dispositivo físico o emulador**: Para ejecutar la aplicación, puedes usar un dispositivo Android físico conectado por USB con la depuración habilitada o un emulador de Android.

## Instalación

1. **Clona el repositorio**:
   ```bash
   git clone [https://github.com/tu-usuario/tu-repositorio.git](https://github.com/mario199764/user_contacts_app.git)
   cd tu-repositorio
2. **Instala las dependencias utilizando**:
   flutter pub get
3. **Configura la base de datos**:
   La aplicación usa SQLite como base de datos local. No se requiere configuración adicional ya que el paquete sqflite de Flutter maneja la creación y gestión de la base de datos automáticamente.


## Ejecución de la App

1. **Conecta tu dispositivo Android o inicia un emulador de Android.**
2. **Ejecuta la app con este comando**: flutter run

## Funcionalidades

Autenticación de Usuario: Sistema de inicio de sesión y registro seguro.
Gestión de Contactos: Añadir, editar, eliminar y buscar contactos.
Modo Oscuro: Alterna entre los modos claro y oscuro para una mejor experiencia de usuario.
Foto de Perfil: Posibilidad de subir una foto de perfil durante el registro.

## Problemas Conocidos

Permisos: Asegúrate de que todos los permisos necesarios (como el acceso a archivos para las fotos de perfil) estén concedidos en el dispositivo.
Compatibilidad: La aplicación está optimizada para Android. El soporte para iOS está en desarrollo.
