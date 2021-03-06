FROM v2ray/official

ENV PROTOCOL="vmess" \
    VMESS_ID= \
    VMESS_ALTERID=64 \
    VMESS_HTTP2= \
    VMESS_HTTP2_DOMAIN= \
    SHADOWSOCKS_PASSWORD="P@ssw0rd" \
    SHADOWSOCKS_METHOD="chacha20-ietf-poly1305" \
    DENY_LAN_ACCESS=true \
    PORT= 

COPY setup-v2ray.sh /tmp/
COPY config.json /etc/v2ray/config.json-default

RUN apk add --update jq curl openssl socat && \
    curl https://get.acme.sh | sh

CMD /bin/sh /tmp/setup-v2ray.sh && \
    v2ray -config=/etc/v2ray/config.json

EXPOSE 10086 8388 8388/udp 80 443
