
# 0.2.0-rc.4

Instalación simplificada: el cliente configura únicamente **FASTVOICE_TOKEN** y
**RECORDINGS_PATH** en el `.env` incluido en el instalador y ejecuta Compose. El cliente
no introduce cuenta, URL de API, hosts S3, archivo secreto ni UID/GID.

- Descubre la cuenta vinculada en `/auth/me` y exige ambas abilities y los tres permisos
  actuales de grabaciones. Corrige la comprobación obsoleta del permiso de historial.
- Usa la API oficial y una política de hosts S3 exactos verificada en el servicio.
- Prepara el volumen de estado y sólo crea el subdirectorio de la cuenta cuando no existe;
  conserva los permisos y propietarios del destino y datos existentes. Después ejecuta Node
  sin privilegios ni capabilities.
  El token se lee de un archivo de sólo lectura y su copia temporal vive en tmpfs, modo 0600.
- Conserva aislamiento de SQLite, checkpoints, streaming, verificación de audio/JSON,
  límites, reintentos, healthcheck y recuperación. No cambia el esquema SQLite.
- Publica instalador ZIP con `.env` y Compose fijado al digest de la imagen; SHA256SUMS
  y la huella se incluyen en la release.

La imagen GHCR es pública. El repositorio de código y su release técnica son privados; el
instalador y sus checksums se publican en el repositorio público
[recordings-connector-downloads](https://github.com/Fastcode-Today/recordings-connector-downloads/releases),
sin pedir autenticación de GitHub al cliente.
El procedimiento completo vive únicamente en [Docusaurus de Callcenter](https://callcenter.fastcode.today/docs/manual/conector-grabaciones/).
El token de Callcenter sigue siendo obligatorio para acceder a grabaciones de su cuenta.

## Validación y alcance

CI ejecuta TypeScript, formato, pruebas Node 22/24, auditoría, build Docker y Docusaurus.
El smoke de Docker instala con sólo dos campos, carpeta nueva con espacios, API/almacenamiento
HTTPS de ensayo, audio y JSON verificados, SQLite local, proceso sin privilegios y token
protegido. Prueba reinicio sin repetir exportación/descarga y rechazo de otra cuenta con
estado existente. La publicación repite el recorrido con la imagen publicada por digest,
obtenida anónimamente, antes de crear la release con el instalador. Después publica los
mismos artefactos inmutables en el repositorio público y vuelve a descargarlos sin
credenciales. La prueba rechaza HTML guardado como ZIP, valida SHA-256, extrae el paquete
y repite instalación y recreación conservando audio y SQLite.

Las pruebas no crean tokens, usuarios ni exportaciones de grabaciones productivas.
Sigue pendiente el piloto con la cuenta/red/disco reales del cliente. No se afirma una
capacidad productiva de un millón de audios; la medición SQLite documentada es sintética.

## Actualización desde rc.1

Use el Compose nuevo dentro de la carpeta de instalación existente para conservar el
nombre del proyecto y su volumen `connector-state`. Conserve la carpeta de audios, copie
el token anterior al nuevo campo FASTVOICE_TOKEN y configure RECORDINGS_PATH con el mismo
destino. No reutilice el override manual de UID/GID de rc.1. Respalde el estado antes de
actualizar. Detener el servicio conserva SQLite y audios; no elimine volúmenes al actualizar.

Las candidatas rc.1 y rc.2 permanecen como histórico; rc.4 añade la preservación de permisos del destino y valida el vínculo antes de preparar el estado. El manual actual corresponde a rc.2.
Para revertir, restaure Compose/configuración de rc.1 con su mecanismo anterior de permisos
si es necesario; el esquema SQLite sigue en versión 1. No se revierte Callcenter ni se borran S3/audios.

Image: ghcr.io/fastcode-today/recordings-connector:0.2.0-rc.4@sha256:121e1a0de4454bc8c5f3190b5971dcf4c2b61b106d934346b378ec6a887c350d
Source: undefined
