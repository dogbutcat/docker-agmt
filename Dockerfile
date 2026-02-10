FROM dogbutcat/kasmvnc:ubuntunoble

ARG VERSION
ARG TARGETARCH

# Antigravity Tools 依赖 (Tauri v2)
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
    libwebkit2gtk-4.1-0 \
    libjavascriptcoregtk-4.1-0

# ZeroTier
RUN curl -s https://install.zerotier.com | bash && \
    cp -r /var/lib/zerotier-one/ /var/lib/zerotier-one.bak/

# Antigravity Tools (GitHub releases)
RUN curl -fsSL -o /tmp/antigravity-tools.deb \
    "https://github.com/lbjlaq/Antigravity-Manager/releases/download/v${VERSION}/Antigravity.Tools_${VERSION}_${TARGETARCH}.deb" && \
    apt install -y /tmp/antigravity-tools.deb && \
    rm -f /tmp/antigravity-tools.deb

# Antigravity CLI
RUN mkdir -p /etc/apt/keyrings && \
    curl -fsSL https://us-central1-apt.pkg.dev/doc/repo-signing-key.gpg | gpg --dearmor --yes -o /etc/apt/keyrings/antigravity-repo-key.gpg && \
    echo "deb [signed-by=/etc/apt/keyrings/antigravity-repo-key.gpg] https://us-central1-apt.pkg.dev/projects/antigravity-auto-updater-dev/ antigravity-debian main" | tee /etc/apt/sources.list.d/antigravity.list > /dev/null && \
    apt-get update && \
    apt-get install -y antigravity && \
    sed -i "s/> \/sys\/fs\/cgroup\/cgroup.subtree_control/> \/sys\/fs\/cgroup\/cgroup.subtree_control 2>\/dev\/null || break/" /usr/local/bin/dind && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

COPY root /

ENV ZT=false

EXPOSE 3000

VOLUME "/root/.antigravity_tools"
VOLUME "/var/lib/zerotier-one"