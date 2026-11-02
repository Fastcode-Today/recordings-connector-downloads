
# 0.2.0-rc.7

Actualización a petición con un comando: `./connector update`. El lanzador público para
Linux/WSL resuelve la última candidata aprobada del canal piloto, verifica manifiesto,
checksums y digest, descarga y comprueba compatibilidad antes de detener el servicio.
Conserva .env, proyecto, destino y volumen; actualiza Compose y el propio lanzador.

El arranque crea automáticamente una copia consistente de SQLite antes de migrar,
registra migraciones versionadas (esquema 2), recupera movimientos pendientes y sólo
marca readiness al finalizar. Se rechazan esquemas futuros. status y backup son de
sólo lectura. El mismo comando retoma una actualización interrumpida, sin rollback
incompatible. Una versión y configuración ya aplicadas no reinician el servicio.

Los clientes rc.4–rc.6 instalan el lanzador una única vez mediante el comando verificado
del manual. No hay servicio actualizando por su cuenta, ni Docker socket dentro del
conector. El canal piloto sólo se promueve después del ensayo con la imagen publicada.

## Base conservada de rc.6

Añade FILENAME_TEMPLATE opcional, leído del .env montado. Ejemplo:
`FILENAME_TEMPLATE=call_id-date-direction`. Campos reales de la API, fecha UTC,
valores ausentes como unknown y sufijo obligatorio UUID-vN contra colisiones.
No se admite phone: el contrato de grabaciones excluye teléfonos explícitamente.

Los cambios de plantilla renombran audio/JSON y actualizan rutas SQLite antes de
sincronizar. Conservan done y cursores; el journal recupera interrupciones, sin redescargas.
Vaciar la variable restaura nombres UUID-vN. Un arranque con plantilla sin cambios no
recorre de nuevo todo el histórico. Los nombres se fijan al descargar o cambiar plantilla;
actualizaciones posteriores de metadata actualizan JSON sin renombrar automáticamente.
La publicación de audios nuevos es exclusiva; archivos ajenos no se sobrescriben.

## Base conservada de rc.5

Nuevo layout `YYYY-MM-DD/UUID-vN.ext` en UTC, sin carpeta de cuenta. Migra audios y JSON
registrados en SQLite antes de sincronizar, conserva done y cursores y recupera operaciones
interrumpidas mediante un journal local. No requiere nuevas descargas. Respalde estado y
audios antes de actualizar y mantenga el mismo destino.

El inicializador asigna sólo la raíz dedicada del destino al usuario del estado, sin
recorrer ni cambiar permisos de archivos existentes. Los conflictos se rechazan.

## Base conservada de rc.4

Instalación simplificada: el cliente configura únicamente **FASTVOICE_TOKEN** y
**RECORDINGS_PATH** en el `.env` incluido en el instalador y ejecuta Compose. El cliente
no introduce cuenta, URL de API, hosts S3, archivo secreto ni UID/GID.

- Descubre la cuenta vinculada en `/auth/me` y exige ambas abilities y los tres permisos
  actuales de grabaciones. Corrige la comprobación obsoleta del permiso de historial.
- Usa la API oficial y una política de hosts S3 exactos verificada en el servicio.
- Prepara el volumen de estado y la raíz dedicada de destino. Conserva propietarios de
  archivos y subdirectorios existentes. Después ejecuta Node
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

El workflow manual `Verify public installer` permite repetir ese recorrido sobre una
versión ya publicada sin crear otra release.

Las pruebas no crean tokens, usuarios ni exportaciones de grabaciones productivas.
Sigue pendiente el piloto con la cuenta/red/disco reales del cliente. No se afirma una
capacidad productiva de un millón de audios; la medición SQLite documentada es sintética.

## Actualización desde rc.1

Use el Compose nuevo dentro de la carpeta de instalación existente para conservar el
nombre del proyecto y su volumen `connector-state`. Conserve la carpeta de audios, copie
el token anterior al nuevo campo FASTVOICE_TOKEN y configure RECORDINGS_PATH con el mismo
destino. No reutilice el override manual de UID/GID de rc.1. Respalde el estado antes de
actualizar. Detener el servicio conserva SQLite y audios; no elimine volúmenes al actualizar.

Las candidatas rc.1 y rc.2 permanecen como histórico; rc.4 añade la preservación de permisos del destino y valida el vínculo antes de preparar el estado. El manual actual corresponde a rc.5.
Para revertir, restaure Compose/configuración de rc.1 con su mecanismo anterior de permisos
si es necesario; la tabla layout_moves es aditiva; restaurar estado y audios juntos para retroceder de rc.5. No se revierte Callcenter ni se borran S3/audios.

Image: ghcr.io/fastcode-today/recordings-connector:0.2.0-rc.7@sha256:b2f0da116e2518ceea57df941e27bc671474637d6664985f177525fa99e7b13f
Source: 2feb2e32f8c35dfa47c9985585f598244159454e
