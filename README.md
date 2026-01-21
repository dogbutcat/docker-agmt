# Docker Antigravity Tools

based on [linuxserver/baseimage-kasmvnc:ubuntunoble](https://github.com/linuxserver/docker-baseimage-kasmvnc) add xfce gui and [Antigravity Tools](https://github.com/lbjlaq/Antigravity-Manager), and startup agmt with boot.

remember to enable net.ipv4.ip_forward=1 in /etc/sysctl.conf
> **Important**: This container **MUST** run as `root` (PUID=0, PGID=0). Normal user permissions are NOT supported due to DBus/GTK limitations in this environment.

## CONFIG PATH

I'm using this as router, so I've decided make default running root user for TUN mode and add zerotier controled by environment variable `ZT`==true.
Default config path is `/config/.antigravity_tools` with cmd `/usr/bin/agmt`.

## CLI

This image also installs `antigravity` CLI in `/usr/bin/antigravity`.
or You can use the wrapper command `agvc` to directly run it.

> Note: `agvc` also relies on the container running as `root`.

## Build

```bash
make build
# Or manually:
# docker buildx build --platform linux/amd64 --build-arg VERSION=$(cat VERSION) -t docker-agmt .
```

## Run

```yaml
version: "3.9"

services:
  antigravity-tools:
    image: docker-agmt
    # image: dogbutcat/agmt
    container_name: agmt
    restart: unless-stopped
    environment:
      - PUID=0
      - PGID=0
      - USER=root
      # - ZT=true
    ports:
      - "3000:3000"
    network_mode: host
    volumes:
      - home:/config
      - "agmt-data:/config/.antigravity_tools"
      - "zerotier:/var/lib/zerotier-one"
    cap_add:
      - NET_ADMIN
      - SYS_MODULE
    security_opt:
      - seccomp=unconfined
    shm_size: "1gb"

volumes:
  - home
  - agmt-data
  - zerotier
```
