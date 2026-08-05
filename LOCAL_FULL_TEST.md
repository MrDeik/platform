# Platform Collective — local full test

This branch adds a Docker Desktop / WSL2 test environment for the full Platform Collective stack.

Pinned source baseline: `b75aae3a584e22dec20a7ed2951ea3e1de5a88c1`.

## Prerequisites

- Docker Desktop with WSL2 integration enabled
- source cloned inside the WSL Linux filesystem, not under `/mnt/c`
- Node.js 22 managed by NVM
- at least 80 GB free disk space; 100–120 GB is recommended
- 16–20 GB assigned to Docker Desktop for the full stack

Do not install Microsoft Rush globally. Some Linux distributions already provide an unrelated GNU command named `rush`. This branch always uses the repository bootstrap at `common/scripts/install-run-rush.js`.

## Clone

```bash
git clone --branch local-full-test https://github.com/MrDeik/platform.git ~/projects/huly-platform
cd ~/projects/huly-platform
chmod +x scripts/local-full/*.sh
```

## Install NVM and Node.js

```bash
curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.40.6/install.sh | bash
source ~/.bashrc

command -v nvm
nvm install 22
nvm alias default 22
nvm use 22
node --version
```

## Install dependencies and build

```bash
node common/scripts/install-run-rush.js install

# Default parallelism is 6. Lower it on a 16 GB machine.
HULY_BUILD_PARALLELISM=6 scripts/local-full/build.sh
```

The build includes the Collective application and service images plus `@hcengineering/pod-notification` for Web Push testing. SaaS billing and payment images are intentionally excluded.

## Windows hosts entry

Run an elevated Notepad and add this line to `C:\Windows\System32\drivers\etc\hosts`:

```text
127.0.0.1 huly.local
```

## Start

```bash
scripts/local-full/up.sh
```

Endpoints:

- Huly: `http://huly.local:8087`
- LiveKit: `ws://huly.local:7880`
- Jaeger: `http://localhost:16686`
- MinIO console: `http://localhost:9001`

The generated `dev/.env.local-full` contains local-only VAPID keys and must not be committed.

## Inspect

```bash
scripts/local-full/status.sh
scripts/local-full/logs.sh
scripts/local-full/logs.sh love
scripts/local-full/logs.sh livekit-egress
scripts/local-full/logs.sh --follow love
```

Without `--follow`, the logs command prints recent lines and exits.

## Record resource usage

```bash
scripts/local-full/collect-stats.sh 10
```

The CSV is written to the repository root. Record separate sessions for idle, normal work, and a video meeting with screen sharing and recording.

## Stop

```bash
scripts/local-full/down.sh
```

This intentionally does not pass `-v`, so named volumes are preserved.

## Notes

- This is a development/test configuration, not production Compose.
- CockroachDB is retained because the current PostgreSQL dev overlay disables Communication API paths.
- Billing and payment are not built or started because they monetize Huly subscriptions and are unrelated to normal self-hosted use.
- AI, SMTP, OAuth integrations and translation still require external credentials even though their images are built.
- Video/audio recording requires LiveKit Egress; the overlay includes it and writes through the local S3-compatible MinIO path.
