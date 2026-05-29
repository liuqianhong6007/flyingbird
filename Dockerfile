FROM ubuntu:24.04

ENV DEBIAN_FRONTEND=noninteractive \
    LANG=zh_CN.UTF-8 \
    LC_ALL=zh_CN.UTF-8

RUN apt-get update && apt-get install -y --no-install-recommends \
    dbus-x11 \
    fontconfig \
    fonts-dejavu \
    fonts-wqy-microhei \
    libwebkit2gtk-4.1-0 \
    locales \
    tigervnc-standalone-server \
    tigervnc-tools \
    twm \
    && locale-gen zh_CN.UTF-8 \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /data

COPY FlyingBird-3.0.3-linux-amd64.deb .
RUN apt-get update && apt-get install -y --no-install-recommends ./FlyingBird-3.0.3-linux-amd64.deb && rm -rf /var/lib/apt/lists/* \
    && rm ./FlyingBird-3.0.3-linux-amd64.deb

COPY start.sh /start.sh
RUN chmod +x /start.sh

EXPOSE 5900

HEALTHCHECK --interval=30s --timeout=5s --start-period=10s --retries=3 \
    CMD pgrep -x Xvnc || exit 1

CMD ["/start.sh"]
