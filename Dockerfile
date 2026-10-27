# syntax=docker/dockerfile:1

# Build v2ray from the v2fly/v2ray-core release pinned in v2ray/go.mod, which
# Dependabot keeps up to date. The prebuilt v2fly/v2fly-core image is not used
# because it is published by hand and lags the GitHub releases.
FROM --platform=$BUILDPLATFORM golang:1.27.3-alpine AS v2ray
ARG TARGETOS
ARG TARGETARCH
WORKDIR /src
COPY v2ray/go.mod v2ray/go.sum ./
RUN --mount=type=cache,target=/go/pkg/mod \
    --mount=type=cache,target=/root/.cache/go-build \
    CGO_ENABLED=0 GOOS=$TARGETOS GOARCH=$TARGETARCH \
    go build -trimpath -ldflags="-s -w -buildid=" -o /out/v2ray \
      github.com/v2fly/v2ray-core/v5/main

FROM alpine:3.24.3

ENV PROTOCOL="vmess" \
    VMESS_ID= \
    VMESS_ALTERID=0 \
    VMESS_HTTP2=false \
    VMESS_HTTP2_DOMAIN= \
    SHADOWSOCKS_PASSWORD="P@ssw0rd" \
    SHADOWSOCKS_METHOD="chacha20-ietf-poly1305" \
    DENY_LAN_ACCESS=true \
    PORT=

# Changes on every CI build (see docker-image.yml) so this layer is never
# reused from the build cache and always gets Alpine's latest package fixes.
ARG APK_REFRESH
# openssl is listed explicitly: acme.sh only depends on "cmd:openssl", which
# can resolve to aws-lc-tools, and acme.sh cannot create keys with that.
RUN apk upgrade --no-cache && apk add --no-cache acme.sh jq openssl

COPY --from=v2ray /out/v2ray /usr/bin/v2ray
COPY config.json /etc/v2ray/config.json-default
COPY --chmod=0755 entrypoint.sh /usr/local/bin/entrypoint.sh

EXPOSE 10086 8388 8388/udp 80 443

ENTRYPOINT ["/usr/local/bin/entrypoint.sh"]
