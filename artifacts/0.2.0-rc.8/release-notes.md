
# 0.2.0-rc.8

Entrada permanente de instalación y actualización, siguiendo el modelo de instalador
público de n8n. El cliente ya no copia versiones ni checksums: el script los verifica
internamente contra el canal aprobado. Primera instalación prepara Compose, lanzador y
.env con sólo token/ruta; una instalación existente no se modifica sin --upgrade.
Actualización habitual: ./connector update. Transición desde clientes antiguos: misma
URL pública con bash -s -- --upgrade. No hay actualización desatendida en segundo plano.

Phone es un campo real de la API, nullable cuando no se puede recuperar. Se admite
FILENAME_TEMPLATE=phone-date-direction y se conserva el sufijo UUID-vN. SQLite migra a
esquema 3 automáticamente con copia consistente previa. Una reenumeración única hidrata
metadata descartada por clientes antiguos sin perder el cursor incremental ni redescargar
audios verificados. La cola local actualiza JSON y nombres de versiones descargadas y
archivadas. Los conflictos detienen la operación sin sobrescribir archivos ajenos.

Se conserva el flujo de rc.7: manifiesto validado antes del stop, imagen por digest,
preflight, lock, journal recuperable, espera de salud y autoupdate del lanzador tras éxito.
La salud inicial no implica que toda la metadata histórica haya terminado de actualizarse.

Validación exigida: tests Node 22/24, tipos, formato, auditoría, Docker y Docusaurus;
instalación anónima, migraciones y upgrades desde imágenes publicadas rc.4 y rc.6,
con teléfono histórico en JSON/nombres, una sola descarga binaria y repetición idempotente.
El canal piloto se aprueba después de los ensayos; no se promueve automáticamente a estable.

Image: ghcr.io/fastcode-today/recordings-connector:0.2.0-rc.8@sha256:a19b59732ecddc26838f849bcd061ef81de14d367a025385e39e87b62f020873
Source: 0e661895783b0f64f22f2aa133e278a4bce8fd99
