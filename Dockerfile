FROM ghcr.io/linuxserver/baseimage-kasmvnc:ubuntunoble

# 设置环境变量
ENV DEBIAN_FRONTEND=noninteractive

# 1. Minimal XFCE4 Installation + Timezone
# Use --no-install-recommends to avoid bloat/conflicting power managers
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
    xfce4 \
    xfce4-terminal \
    dbus-x11 \
    x11-xserver-utils \
    adwaita-icon-theme-full \
    wget \
    vim \
    tzdata \
    fonts-wqy-microhei \
    fonts-wqy-zenhei && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

RUN apt-get install -y --no-install-recommends ca-certificates && \
    install -d -m 0755 /etc/apt/keyrings && \
    wget -q https://packages.mozilla.org/apt/repo-signing-key.gpg -O- | tee /etc/apt/keyrings/packages.mozilla.org.asc > /dev/null && \
    echo "deb [signed-by=/etc/apt/keyrings/packages.mozilla.org.asc] https://packages.mozilla.org/apt mozilla main" | tee -a /etc/apt/sources.list.d/mozilla.list > /dev/null && \
    echo 'Package: *\nPin: origin packages.mozilla.org\nPin-Priority: 1000' | tee /etc/apt/preferences.d/mozilla && \
    apt-get update && \
    apt-get install -y --no-install-recommends firefox

# Additional deps for Antigravity Tools (Tauri v2)
# Debian 12 (Bookworm) uses libwebkit2gtk-4.1-0
RUN apt-get install -y \
    libwebkit2gtk-4.1-0 \
    libjavascriptcoregtk-4.1-0 \
    libayatana-appindicator3-1 \
    librsvg2-common \
    libssl3 \
    libgtk-3-0

# 2. Explicitly remove conflicting power management tools if installed
RUN apt-get purge -y upower xfce4-power-manager || true

# 3. KasmVNC & GPU Hang Fixes (Mac Docker Compatibility)
ENV LIBGL_ALWAYS_SOFTWARE=1

RUN curl -s https://install.zerotier.com | bash

RUN cp -r /var/lib/zerotier-one/ /var/lib/zerotier-one.bak/

ENV LC_ALL=en_US.UTF-8

ARG VERSION
ARG TARGETARCH

# Get Antigravity Tools from GitHub releases
# Note: Release uses amd64/arm64 naming
RUN wget -q -O /tmp/antigravity-tools.deb "https://github.com/lbjlaq/Antigravity-Manager/releases/download/v${VERSION}/Antigravity.Tools_${VERSION}_${TARGETARCH}.deb"

# Install Antigravity Tools
RUN apt install -y /tmp/antigravity-tools.deb

# Install Antigravity CLI
RUN mkdir -p /etc/apt/keyrings && \
    curl -fsSL https://us-central1-apt.pkg.dev/doc/repo-signing-key.gpg | gpg --dearmor --yes -o /etc/apt/keyrings/antigravity-repo-key.gpg && \
    echo "deb [signed-by=/etc/apt/keyrings/antigravity-repo-key.gpg] https://us-central1-apt.pkg.dev/projects/antigravity-auto-updater-dev/ antigravity-debian main" | tee /etc/apt/sources.list.d/antigravity.list > /dev/null && \
    apt-get update && \
    apt-get install -y antigravity && \
    sed -i "s/> \/sys\/fs\/cgroup\/cgroup.subtree_control/> \/sys\/fs\/cgroup\/cgroup.subtree_control 2>\/dev\/null || break/" /usr/local/bin/dind



COPY root /
COPY .Xauthority /config/.Xauthority

# RUN chmod 644 /etc/xdg/autostart/agmt.desktop
# RUN chmod +x /usr/bin/agmt

RUN apt-get purge -y upower \
    xfce4-power-manager-data \
    && apt-get clean

# Expose ports
EXPOSE 3000

ENV HOME=/config
ENV ZT=false

# Create Data Directory
VOLUME "/root/.antigravity_tools"
VOLUME "/var/lib/zerotier-one"