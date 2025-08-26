# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

This is a Docker image project for hledger (plain text accounting software) and its associated tools. The project builds and distributes Docker images that bundle hledger, hledger-web, hledger-ui, and other related tools.

## Key Commands

### Building Docker Images
```bash
# Build both dev and production images with version tagging
./build.sh
```
The build script creates multi-stage Docker images:
- Development image (`latest-dev`, `VERSION-dev`): Includes Haskell stack and build dependencies
- Production image (`latest`, `VERSION`): Minimal Debian-based runtime image

### Running the Container
```bash
# Run hledger-web interface
./run.sh ~/path/to/journal.journal web

# Drop into bash shell in container
./run.sh ~/path/to/journal.journal bash

# Run hledger CLI commands
./run.sh ~/path/to/journal.journal hledger [args]
```

### Docker Compose
```bash
# Start hledger-web service
docker-compose up -d
```

## Architecture

### Multi-Stage Docker Build
- **Stage 1 (dev)**: Haskell build environment that compiles hledger tools from source using Stack
- **Stage 2 (production)**: Minimal Debian runtime that copies only the compiled binaries

### Key Files
- `Dockerfile`: Multi-stage build definition for hledger Docker images
- `build.sh`: Automated build and push script for Docker images (current version: 1.32.1)
- `run.sh`: Helper script for running containers with proper volume mounts and environment
- `start.sh`: Entrypoint script that configures and launches hledger-web with environment variables
- `docker-compose.yml`: Example compose configuration for running hledger-web service

### Environment Configuration
The container accepts these environment variables (configured in `start.sh`):
- `HLEDGER_JOURNAL_FILE`: Input journal file path (default: /data/hledger.journal)
- `HLEDGER_HOST`: TCP host (default: 0.0.0.0)
- `HLEDGER_PORT`: TCP port (default: 5000)
- `HLEDGER_BASE_URL`: Base URL for web interface
- `HLEDGER_FILE_URL`: Static files URL
- `HLEDGER_DEBUG`: Debug output level
- `HLEDGER_RULES_FILE`: CSV conversion rules file
- `HLEDGER_ALLOW`: Permissions (default: edit)
- `HLEDGER_ARGS`: Additional arguments to pass to hledger-web

### Version Management
Version updates require modifying the `v` variable in `build.sh` and updating the Dockerfile to install the corresponding hledger versions via Stack.