# Self-Hosted Perforce (P4D) on Docker

[![CI](https://github.com/ali-ramadhan/docker-perforce-p4d/actions/workflows/ci.yml/badge.svg)](https://github.com/ali-ramadhan/docker-perforce-p4d/actions/workflows/ci.yml)
[![Docker Image Version](https://img.shields.io/docker/v/aliramadhan/perforce-p4d)](https://hub.docker.com/r/aliramadhan/perforce-p4d)

[Perforce Helix Core](https://www.perforce.com/products/helix-core) is a version control system built for large-scale projects with big binary assets (game dev, VFX, hardware design, etc.). It's free for teams of up to five!

This is a Docker setup for Helix Core (p4d) that builds directly from the official Perforce `apt` repositories.

> **Disclaimer:** This project is not affiliated with Perforce Software, Inc.

## Quick Start
```bash
git clone https://github.com/ali-ramadhan/docker-perforce-p4d.git
cd docker-perforce-p4d
docker compose up --build --detach
```
