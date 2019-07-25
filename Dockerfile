FROM v2ray/official

ENV PROTOCOL="vmess" \
    VMESS_ID= \
    VMESS_ALTERID=64 \
    SHADOWSOCKS_PASSWORD="P@ssw0rd" \
    SHADOWSOCKS_METHOD="chacha20-ietf-poly1305" \
    DENY_LAN_ACCESS=false \
    PORT=


COPY setup-v2ray.sh /tmp/
COPY config.json /etc/v2ray/config.json

RUN apk add --update jq

CMD /bin/sh /tmp/setup-v2ray.sh && \
    v2ray -config=/etc/v2ray/config.json

EXPOSE 10086 8388 8388/udp
