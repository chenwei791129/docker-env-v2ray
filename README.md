# env-v2ray for docker
## How to use
[![This image on DockerHub](https://img.shields.io/docker/pulls/awei/env-v2ray.svg)](https://hub.docker.com/r/awei/env-v2ray/)

[View on Docker Hub](https://hub.docker.com/r/awei/env-v2ray)

```shell
$ docker run -d -p <PORT>:<DOCKER-PORT> -e ID="<UUID>" awei/env-v2ray
```
e.g. (VMess)
```shell
$ docker run -d -p 10086:10086 -e VMESS_ID="877e125d-1ef3-40ef-9329-b7ec62c1072c" awei/env-v2ray
```
e.g. (VMess+h2+tls) need 80 port to get let's encrypt cert
```shell
$ docker run -d -p 80:80 -p 443:443 -e PORT=443 -e VMESS_ID="877e125d-1ef3-40ef-9329-b7ec62c1072c" -e VMESS_HTTP2="true" -e VMESS_HTTP2_DOMAIN="<www.demo.com>" awei/env-v2ray
```
e.g. (Shadowsocks)
```shell
$ docker run -d -p 8388:8388 -e PROTOCOL="shadowsocks" -e SHADOWSOCKS_PASSWORD="P@ssw0rd" awei/env-v2ray
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
        image: awei/env-v2ray:latest
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
* `[VMess] VMESS_ID` Set a UUID, see [www.uuidgenerator.net](https://www.uuidgenerator.net/)

### Option Environment Variables
* `PROTOCOL` (string, default: "vmess", enum: "vmess","shadowsocks")
* `PORT` Server listen port (integer, vmess-default: 10086, shadowsocks-default: 8388)
* `[VMess] VMESS_ALTERID` (integer,default: 64)
* `[VMess] VMESS_HTTP2` (string,enum: "true","false")
* `[VMess] VMESS_HTTP2_DOMAIN` your domain (string)
* `[Shadowsocks] SHADOWSOCKS_METHOD` (string,default: "chacha20-ietf-poly1305"), see [encryption-list](https://www.v2ray.com/chapter_02/protocols/shadowsocks.html#encryption-list)
* `DENY_LAN_ACCESS` if set true, v2ray client can't access lan ip (boolean,default: "false")

## Related Projects
- [v2ray/official](https://hub.docker.com/r/v2ray/official)

## License
The repository is open-sourced software licensed under the [MIT license](https://opensource.org/licenses/MIT).
