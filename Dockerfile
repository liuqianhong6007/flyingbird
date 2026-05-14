FROM lscr.io/linuxserver/webtop:ubuntu-xfce

WORKDIR /tmp/fbclient

RUN apt update && apt install -y \
    libsecret-1-0 \
    libayatana-appindicator3-1 \
    libwebkit2gtk-4.1-0 \
    && apt clean \
    && rm -rf /var/lib/apt/lists/*

COPY fbclient_1.36.17_linux_universal_amd64.tar.gz .

RUN tar -xzf fbclient_1.36.17_linux_universal_amd64.tar.gz \
    && mkdir -p /config/Desktop/flyingbird \
    && cp -rf bundle/* /config/Desktop/flyingbird/ \
    && chmod +x /config/Desktop/flyingbird/fbclient \
    && rm -rf /tmp/fbclient
