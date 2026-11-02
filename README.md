# Fastvoice Recordings Connector Downloads

This public repository distributes verified installation bundles for Fastvoice
Recordings Connector. It does not contain the connector source code.

Install on Linux/WSL using the permanent public entry point (Docker Compose V2,
Bash, curl, sha256sum and flock required):

```bash
curl -fsSL https://callcenter.fastcode.today/install/recordings-connector | bash
cd recordings-connector
```

Edit only the token and destination in `.env`, then run `docker compose up -d`.
Update using `./connector update`. For an older installation without the launcher,
run this from its existing directory:

```bash
curl -fsSL https://callcenter.fastcode.today/install/recordings-connector | bash -s -- --upgrade
```

The installer resolves and verifies the approved version internally; users do not
copy versions or hashes. Existing `.env`, recordings and SQLite are preserved.

Alternatively, use the assets attached to a release:

- `recordings-connector-<version>.zip`
- `SHA256SUMS`
- `compose.yaml`
- `env.example`
- `IMAGE_DIGEST.txt`

The installer contains placeholders only. Configure `FASTVOICE_TOKEN` and
`RECORDINGS_PATH` locally, keep `.env` private, and follow the canonical
[Callcenter installation guide](https://callcenter.fastcode.today/docs/manual/conector-grabaciones/).

Release candidates are pilots, not stable releases. No workflow promotes a
candidate to stable or updates an installed container automatically.


From rc.7, releases also include the public host launcher `connector` and its verified
`update.env` manifest. Run `./connector update` on Linux/WSL to apply the latest
approved pilot version. It preserves local configuration and data, and the service
performs backups and migrations automatically. The channel is promoted only after
an upgrade test passes; it is not a stable-release promotion or a background updater.
