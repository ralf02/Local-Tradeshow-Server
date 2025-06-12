# Local Tradeshow Server

## 🧾 Descripción General

Este proyecto es una muestra de la implementacion de una versión **local y offline** de un sitio web Drupal, destinado a funcionar sin conexión en ferias comerciales desde un portátil (Windows) proporcionado por el cliente.

El objetivo es que los agentes y comerciales puedan mostrar todo el contenido del sitio, incluyendo imágenes, videos de YouTube, archivos PDF y recursos alojados en la nube (AWS S3 y EC2), en ubicaciones remotas sin acceso a Internet.

---

## 🛠️ Tecnologías Utilizadas

- **Drupal**: CMS principal del sitio clonado.
- **Drush**: Utilizado para respaldar y gestionar la base de datos Drupal mediante scripts automatizados.
- **Módulos personalizados**: Scripts internos para manejo de medios, backups y recursos externos.
- **Shell scripting**: Automatización del proceso de backup desde los EC2 de aws, descarga de recursos, empaquetado e importación.
- **AWS S3**: Fuente principal de archivos estáticos del sitio como imágenes, hojas de estilo y scripts JavaScript, los cuales se descargan localmente para su uso offline mediante scripts personalizados.

---

## 📚 Actividades Técnicas

### Investigación
- Automatización del archivo `hosts` en Windows.
- Comparación de herramientas para descarga de videos de YouTube.
- Descarga local de bibliotecas JS, imágenes, íconos y recursos desde AWS S3.

### Configuración
- Instalación de Docker en Windows.
- Clonado del sitio y restauración desde backups.
- QA para validar entorno local funcional.

### Desarrollo de Scripts Shell
- Descargar videos externos (YouTube) y otros recursos.
- Descargar archivos estáticos desde AWS S3.
- Generar archivo `.zip` completo del sitio desde producción desde AWS EC2.
- Respaldar base de datos del sitio productivo en AWS EC2.
- Importar backup y desplegar entorno local automáticamente.

---

## 🚀 Despliegue Técnico

### Requisitos
- Windows 10 con [Docker Desktop](https://www.docker.com/get-started) y Git Bash.
- En Linux, solo Docker y Git.
- Espacio disponible mínimo: **25 GB**.
- Archivos necesarios en el FTP antes de primer uso:
