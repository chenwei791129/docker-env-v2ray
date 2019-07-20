#!/bin/sh

if [ ${DENY_LAN_ACCESS} == true ]; then
  echo 'apply DENY_LAN_ACCESS'
  cp -f /tmp/config-local-security.json /etc/v2ray/config.json
fi

if [ -n "${PORT}" ]; then
  echo 'setup port.'
  echo $(cat /etc/v2ray/config.json | jq '.inbounds[0].port = '${PORT}'') > /etc/v2ray/config.json
fi

if [ -n "${ID}" ]; then
  echo 'setup id.'
  echo $(cat /etc/v2ray/config.json | jq '.inbounds[0].settings.clients[0].id = "'${ID}'"') > /etc/v2ray/config.json
fi

if [ -n "${ALTERID}" ]; then
  echo 'setup alterId.'
  echo $(cat /etc/v2ray/config.json | jq '.inbounds[0].settings.clients[0].alterId = '${ALTERID}'') > /etc/v2ray/config.json
fi