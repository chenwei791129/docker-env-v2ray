#!/bin/sh

if [ ${PROTOCOL} == "vmess" ]
then
  # setup vmess
  echo $(cat /etc/v2ray/config.json | jq '.inbounds += [{"port":10086,"protocol":"vmess","settings":{"clients":[{"id":"60ca58e9-003e-4c01-98de-c2223ae49153","level":1,"alterId":64}]}}]') > /etc/v2ray/config.json

  if [ -n "${VMESS_ID}" ]; then
    echo 'setup id.'
    echo $(cat /etc/v2ray/config.json | jq '.inbounds[0].settings.clients[0].id = "'${VMESS_ID}'"') > /etc/v2ray/config.json
  fi

  if [ -n "${VMESS_ALTERID}" ]; then
    echo 'setup alterId.'
    echo $(cat /etc/v2ray/config.json | jq '.inbounds[0].settings.clients[0].alterId = '${VMESS_ALTERID}'') > /etc/v2ray/config.json
  fi
elif [ ${PROTOCOL} == "shadowsocks" ]
then
  # setup shadowsocks
  echo $(cat /etc/v2ray/config.json | jq '.inbounds += [{"port":8388,"protocol":"shadowsocks","network":"tcp,udp","settings":{"method":"chacha20-ietf-poly1305","password":"P@ssw0rd"}}]') > /etc/v2ray/config.json

  if [ -n "${SHADOWSOCKS_PASSWORD}" ]; then
    echo 'setup id.'
    echo $(cat /etc/v2ray/config.json | jq '.inbounds[0].settings.password = "'${SHADOWSOCKS_PASSWORD}'"') > /etc/v2ray/config.json
  fi

  if [ -n "${SHADOWSOCKS_METHOD}" ]; then
    echo 'setup alterId.'
    echo $(cat /etc/v2ray/config.json | jq '.inbounds[0].settings.method = '${SHADOWSOCKS_METHOD}'') > /etc/v2ray/config.json
  fi
fi

if [ -n "${PORT}" ]; then
  echo 'setup port.'
  echo $(cat /etc/v2ray/config.json | jq '.inbounds[0].port = '${PORT}'') > /etc/v2ray/config.json
fi

if [ ${DENY_LAN_ACCESS} == true ]; then
  echo 'apply DENY_LAN_ACCESS'
  # add blackhole outbound for private ip route rule
  echo $(cat /etc/v2ray/config.json | jq '.outbounds += [{"protocol":"blackhole","settings":{},"tag":"blocked"}]') > /etc/v2ray/config.json
  # add private ip route rule
  echo $(cat /etc/v2ray/config.json | jq '. += {"routing":{"rules":[{"type":"field","ip":["geoip:private"],"outboundTag":"blocked"}]}}') > /etc/v2ray/config.json
fi

