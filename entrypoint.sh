#!/bin/sh
# Generate /etc/v2ray/config.json from environment variables, then run v2ray.
set -eu

# Run a given command instead (e.g. `docker run --rm -it <image> sh`).
if [ "$#" -gt 0 ]; then
  exec "$@"
fi

CONFIG=/etc/v2ray/config.json
CERT=/etc/v2ray/v2ray.crt
KEY=/etc/v2ray/v2ray.key

# Destinations blocked when DENY_LAN_ACCESS=true. Listed explicitly instead of
# "geoip:private" so the image does not need to ship and update geoip.dat.
PRIVATE_IPS='["0.0.0.0/8","10.0.0.0/8","100.64.0.0/10","127.0.0.0/8",
  "169.254.0.0/16","172.16.0.0/12","192.0.0.0/24","192.0.2.0/24",
  "192.88.99.0/24","192.168.0.0/16","198.18.0.0/15","198.51.100.0/24",
  "203.0.113.0/24","224.0.0.0/4","240.0.0.0/4","255.255.255.255/32",
  "::/128","::1/128","fc00::/7","fe80::/10","ff00::/8"]'

die() {
  echo "[Error] $*" >&2
  exit 1
}

case "${PROTOCOL:-vmess}" in
  vmess)
    echo '[Info] Protocol is VMess.'
    if [ -z "${VMESS_ID:-}" ]; then
      VMESS_ID="$(v2ray uuid)"
      echo "[Warn] VMESS_ID is not set, generated a random one: ${VMESS_ID}"
    fi
    inbound="$(jq -n --arg id "${VMESS_ID}" --argjson alterId "${VMESS_ALTERID:-0}" \
      '{port: 10086, protocol: "vmess",
        settings: {clients: [{id: $id, level: 1, alterId: $alterId}]}}')"

    if [ "${VMESS_HTTP2:-false}" = true ]; then
      domain="${VMESS_HTTP2_DOMAIN:-}"
      [ -n "${domain}" ] || die 'VMESS_HTTP2_DOMAIN is required when VMESS_HTTP2=true.'
      if [ ! -f "${CERT}" ] || [ ! -f "${KEY}" ]; then
        acme_server="${ACME_SERVER:-letsencrypt}"
        echo "[Info] Issuing a certificate for ${domain} from ${acme_server}."
        # Exit code 2 means a still-valid certificate was already issued.
        acme.sh --issue --server "${acme_server}" --standalone -d "${domain}" \
          --keylength ec-256 || [ $? -eq 2 ]
        acme.sh --install-cert --ecc -d "${domain}" \
          --fullchain-file "${CERT}" --key-file "${KEY}"
      fi
      inbound="$(printf '%s' "${inbound}" | jq --arg domain "${domain}" \
        --arg cert "${CERT}" --arg key "${KEY}" \
        '.streamSettings = {network: "h2",
           httpSettings: {path: "/", host: [$domain]},
           security: "tls",
           tlsSettings: {certificates: [{certificateFile: $cert, keyFile: $key}]}}')"
    fi
    ;;
  shadowsocks)
    echo '[Info] Protocol is Shadowsocks.'
    inbound="$(jq -n --arg password "${SHADOWSOCKS_PASSWORD:-P@ssw0rd}" \
      --arg method "${SHADOWSOCKS_METHOD:-chacha20-ietf-poly1305}" \
      '{port: 8388, protocol: "shadowsocks",
        settings: {network: "tcp,udp", method: $method, password: $password}}')"
    ;;
  *)
    die "Unsupported PROTOCOL '${PROTOCOL}', expected vmess or shadowsocks."
    ;;
esac

if [ -n "${PORT:-}" ]; then
  echo '[Info] Setup port.'
  inbound="$(printf '%s' "${inbound}" | jq --argjson port "${PORT}" '.port = $port')"
fi

jq --argjson inbound "${inbound}" '.inbounds = [$inbound]' \
  /etc/v2ray/config.json-default > "${CONFIG}"

if [ "${DENY_LAN_ACCESS:-true}" = true ]; then
  echo '[Info] Apply DENY LAN ACCESS.'
  jq --argjson ips "${PRIVATE_IPS}" \
    '.outbounds += [{protocol: "blackhole", settings: {}, tag: "blocked"}]
     | .routing = {rules: [{type: "field", ip: $ips, outboundTag: "blocked"}]}' \
    "${CONFIG}" > "${CONFIG}.tmp"
  mv "${CONFIG}.tmp" "${CONFIG}"
fi

echo '[Debug] Dump config.json:'
jq -c . "${CONFIG}"

exec v2ray run -c "${CONFIG}"
