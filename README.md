# env-v2ray for docker
## How to use
[![This image on DockerHub](https://img.shields.io/docker/pulls/awei/env-v2ray.svg)](https://hub.docker.com/r/awei/env-v2ray/)

[View on Docker Hub](https://hub.docker.com/r/awei/env-v2ray)

Images are built by GitHub Actions and published to GitHub Container Registry:

```shell
$ docker pull ghcr.io/chenwei791129/env-v2ray
```

Tags: `latest` (also `master`) and the V2Ray version the image runs, e.g.
`ghcr.io/chenwei791129/env-v2ray:5.54.2`. The weekly rebuild refreshes the
tags of the current V2Ray version with Alpine's latest package fixes; tags of
older V2Ray versions are kept but no longer rebuilt.

The Docker Hub image `awei/env-v2ray` is no longer updated.

The image runs [V2Fly](https://github.com/v2fly/v2ray-core) (the maintained
continuation of V2Ray) v5, built from the release pinned in `v2ray/go.mod`.
Dependabot keeps that release, the Alpine base image and the Go toolchain up to
date; every merge to `master` and a weekly rebuild publish a new image for
`linux/amd64` and `linux/arm64`.

> **Upgrading from the v2ray/official based image:**
> - V2Fly only accepts VMess AEAD authentication, so clients must set `alterId`
>   to `0`. To temporarily keep legacy clients working, add
>   `-e V2RAY_VMESS_AEAD_FORCED=false` and set `VMESS_ALTERID` to the clients'
>   value.
> - The fixed fallback VMess ID is gone: without `VMESS_ID` a random ID is
>   generated on every container start, so always set `VMESS_ID`.
> - Shadowsocks stream ciphers (e.g. `aes-256-cfb`) are no longer supported;
>   use `aes-128-gcm`, `aes-256-gcm` or `chacha20-ietf-poly1305`.
> - Arguments passed to the container run as a command instead of the proxy
>   (e.g. `docker run --rm -it ghcr.io/chenwei791129/env-v2ray sh`).

```shell
$ docker run -d -p <PORT>:<DOCKER-PORT> -e VMESS_ID="<UUID>" ghcr.io/chenwei791129/env-v2ray
```
e.g. (VMess)
```shell
$ docker run -d -p 10086:10086 -e VMESS_ID="877e125d-1ef3-40ef-9329-b7ec62c1072c" ghcr.io/chenwei791129/env-v2ray
```
e.g. (VMess+h2+tls) need 80 port to get let's encrypt cert
```shell
$ docker run -d -p 80:80 -p 443:443 -e PORT=443 -e VMESS_ID="877e125d-1ef3-40ef-9329-b7ec62c1072c" -e VMESS_HTTP2="true" -e VMESS_HTTP2_DOMAIN="www.demo.com" ghcr.io/chenwei791129/env-v2ray
```
e.g. (Shadowsocks)
```shell
$ docker run -d -p 8388:8388 -e PROTOCOL="shadowsocks" -e SHADOWSOCKS_PASSWORD="P@ssw0rd" ghcr.io/chenwei791129/env-v2ray
```
deploy to kubernetes example:
```yaml
apiVersion: v1
kind: Service
metadata:
  name: service-v2ray-1
spec:
  selector:
    app: v2ray-1
  ports:
    - protocol: TCP
      port: 10840
      targetPort: 10086
      nodePort: 30001
  type: NodePort

---

apiVersion: apps/v1
kind: Deployment
metadata:
  name: deployment-v2ray-1
  labels:
    app: v2ray-1
spec:
  replicas: 1
  selector:
    matchLabels:
      app: v2ray-1
  template:
    metadata:
      labels:
        app: v2ray-1
    spec:
      containers:
      - name: v2ray-1
        image: ghcr.io/chenwei791129/env-v2ray:latest
        env:
        - name: VMESS_ID
          value: "39de9465-16a5-499a-93ef-d05e946214ce"
        - name: DENY_LAN_ACCESS
          value: "true"
        ports:
        - containerPort: 10086
```
### Necessary Environment Variables
* `[Shadowsocks] SHADOWSOCKS_PASSWORD` Set a password (string,default: "P@ssw0rd")
* `[VMess] VMESS_ID` Set a UUID, see [www.uuidgenerator.net](https://www.uuidgenerator.net/) (when unset, a random one is generated and logged on every start)

### Option Environment Variables
* `PROTOCOL` (string, default: "vmess", enum: "vmess","shadowsocks")
* `PORT` Server listen port (integer, vmess-default: 10086, shadowsocks-default: 8388)
* `[VMess] VMESS_ALTERID` (integer,default: 0) only used by legacy clients together with `V2RAY_VMESS_AEAD_FORCED=false`
* `[VMess] VMESS_HTTP2` (string,enum: "true","false", default: "false") issue a Let's Encrypt certificate (port 80 must be reachable) unless `/etc/v2ray/v2ray.crt` and `/etc/v2ray/v2ray.key` are mounted
* `[VMess] VMESS_HTTP2_DOMAIN` your domain (string)
* `[Shadowsocks] SHADOWSOCKS_METHOD` (string,default: "chacha20-ietf-poly1305", AEAD ciphers only), see [supported methods](https://www.v2fly.org/en_US/config/protocols/shadowsocks.html)
* `ACME_SERVER` acme.sh CA used when `VMESS_HTTP2=true` (string,default: "letsencrypt")
* `DENY_LAN_ACCESS` if set true, v2ray client can't access lan ip (boolean,default: "true")

## Related Projects
- [v2fly/v2ray-core](https://github.com/v2fly/v2ray-core)
- [acmesh-official/acme.sh](https://github.com/acmesh-official/acme.sh)

## License
The repository is open-sourced software licensed under the [MIT license](https://opensource.org/licenses/MIT).
