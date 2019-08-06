#!/bin/sh

rm /etc/v2ray/config.json
cp /etc/v2ray/config.json-default /etc/v2ray/config.json

if [ ${PROTOCOL} == "vmess" ]; then
  # setup vmess
  echo '[Info] Protocal is VMess.'
  echo $(cat /etc/v2ray/config.json | jq '.inbounds += [{"port":10086,"protocol":"vmess","settings":{"clients":[{"id":"60ca58e9-003e-4c01-98de-c2223ae49153","level":1,"alterId":64}]}}]') > /etc/v2ray/config.json

  if [ -n "${VMESS_ID}" ]; then
    echo '[Info] Setup id.'
    echo $(cat /etc/v2ray/config.json | jq '.inbounds[0].settings.clients[0].id = "'${VMESS_ID}'"') > /etc/v2ray/config.json
  fi

  if [ -n "${VMESS_ALTERID}" ]; then
    echo '[Info] Setup alterId.'
    echo $(cat /etc/v2ray/config.json | jq '.inbounds[0].settings.clients[0].alterId = '${VMESS_ALTERID}'') > /etc/v2ray/config.json
  fi

  if [ ${VMESS_HTTP2} == true ]; then
    if [ ! -f /etc/v2ray/v2ray.crt ] && [ ! -f /etc/v2ray/v2ray.key ]; then
      /root/.acme.sh/acme.sh --issue -d "${VMESS_HTTP2_DOMAIN}" --standalone -k ec-256
      /root/.acme.sh/acme.sh --installcert -d "${VMESS_HTTP2_DOMAIN}" --fullchainpath /etc/v2ray/v2ray.crt --keypath /etc/v2ray/v2ray.key --ecc
    fi
    echo $(cat /etc/v2ray/config.json | jq '.inbounds[0] += {"streamSettings":{"network":"h2","httpSettings":{"path":"/"},"security":"tls","tlsSettings":{"certificates":[{"certificateFile":"/etc/v2ray/v2ray.crt","keyFile":"/etc/v2ray/v2ray.key"}]}}}') > /etc/v2ray/config.json
    echo $(cat /etc/v2ray/config.json | jq '.inbounds[0].streamSettings.httpSettings += {"host": ["'${VMESS_HTTP2_DOMAIN}'"]}') > /etc/v2ray/config.json
  fi
elif [ ${PROTOCOL} == "shadowsocks" ]; then
  # setup shadowsocks
  echo '[Info] Protocal is Shadowsocks.'
  echo $(cat /etc/v2ray/config.json | jq '.inbounds += [{"port":8388,"protocol":"shadowsocks","network":"tcp,udp","settings":{"method":"chacha20-ietf-poly1305","password":"P@ssw0rd"}}]') > /etc/v2ray/config.json

  if [ -n "${SHADOWSOCKS_PASSWORD}" ]; then
    echo '[Info] Setup shadowsocks password.'
    echo $(cat /etc/v2ray/config.json | jq '.inbounds[0].settings.password = "'${SHADOWSOCKS_PASSWORD}'"') > /etc/v2ray/config.json
  fi

  if [ -n "${SHADOWSOCKS_METHOD}" ]; then
    echo '[Info] Setup shadowsocks method.'
    echo $(cat /etc/v2ray/config.json | jq '.inbounds[0].settings.method = "'${SHADOWSOCKS_METHOD}'"') > /etc/v2ray/config.json
  fi
fi

if [ -n "${PORT}" ]; then
  echo '[Info] Setup port.'
  echo $(cat /etc/v2ray/config.json | jq '.inbounds[0].port = '${PORT}'') > /etc/v2ray/config.json
fi

if [ ${DENY_LAN_ACCESS} == true ]; then
  echo '[Info] Apply DENY LAN ACCESS.'
  # add blackhole outbound for private ip route rule
  echo $(cat /etc/v2ray/config.json | jq '.outbounds += [{"protocol":"blackhole","settings":{},"tag":"blocked"}]') > /etc/v2ray/config.json
  # add private ip route rule
  echo $(cat /etc/v2ray/config.json | jq '. += {"routing":{"rules":[{"type":"field","ip":["geoip:private"],"outboundTag":"blocked"}]}}') > /etc/v2ray/config.json
fi

echo '[Debug] Dump config.json:'
echo $(cat /etc/v2ray/config.json)
