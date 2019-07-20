FROM v2ray/official

ENV PORT=10086
ENV ID=
ENV ALTERID=64

COPY ["config.json", "/etc/v2ray/config.json"]

RUN apk add --update jq

CMD /bin/sh /tmp/setup-v2ray.sh && \
    v2ray -config=/etc/v2ray/config.json

EXPOSE 10086
