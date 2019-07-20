FROM v2ray/official

ENV PORT=10086 \
    ID= \
    ALTERID=64

COPY setup-v2ray.sh /tmp/
COPY config.json /etc/v2ray/config.json

RUN apk add --update jq

CMD /bin/sh /tmp/setup-v2ray.sh && \
    v2ray -config=/etc/v2ray/config.json

EXPOSE 10086
