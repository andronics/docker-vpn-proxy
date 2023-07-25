FROM alpine:3.18

LABEL org.opencontainers.image.authors="andronics@gmail.com" \
    org.opencontainers.image.source="https://github.com/andronics/docker-vpn-proxy.git" \
    org.opencontainers.image.url="https://github.com/andronics/docker-vpn-proxy"

RUN \
    echo "# Add Community Edge Repository #" && \
        echo "@community https://dl-cdn.alpinelinux.org/alpine/edge/community" >> /etc/apk/repositories && \
    echo "# Installing Packages #" && \
        apk --no-cache --update add \
            bash=5.2.15-r5 \
            bind-tools=9.18.16-r0 \
            ca-certificates=20230506-r0 \
            curl=8.2.0-r1 \
            dante-server=1.4.3-r3 \
            jq=1.6-r3 \
            nano=7.2-r1 \
            openvpn=2.6.5-r0 \
            runit=2.1.2-r7 \
            tinyproxy=1.11.1-r3 \
            tzdata=2023c-r1 \
            unbound=1.17.1-r1 \
            unzip=6.0-r14 && \
    echo "# Removing Cache #" && \
        rm -rf /var/cache/apk/*

RUN \
    echo "# Updating Unbound Internic Root Hints" && \
        curl -s https://www.internic.net/domain/named.cache -o /etc/unbound/root.hints

COPY ./config /config
COPY ./services /services

SHELL ["/bin/bash", "-o", "pipefail", "-c"]

RUN \
    echo "# Chaning Permissions #" && \
        find /services -type f -exec chmod u+x {} \;

HEALTHCHECK --interval=5m --timeout=20s --start-period=1m \
    CMD ['/app/healthcheck']

WORKDIR /services

CMD ["runsvdir", "/services"]