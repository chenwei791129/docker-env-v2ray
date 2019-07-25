# env-v2ray for docker
## How to use
[![This image on DockerHub](https://img.shields.io/docker/pulls/awei/env-v2ray.svg)](https://hub.docker.com/r/awei/env-v2ray/)

[View on Docker Hub](https://hub.docker.com/r/awei/env-v2ray)

```shell
$ docker run -d -p <PORT>:<DOCKER-PORT> -e ID="<UUID>" awei/env-v2ray
```
e.g. (Vmess)
```shell
$ docker run -d -p 10086:10086 -e VMESS_ID="877e125d-1ef3-40ef-9329-b7ec62c1072c" awei/env-v2ray
```
e.g. (Shadowsocks)
```shell
$ docker run -d -p 8388:8388 -e PROTOCOL="shadowsocks" -e SHADOWSOCKS_PASSWORD="P@ssw0rd" awei/env-v2ray
```
### Necessary Environment Variables
* `[Shadowsocks] SHADOWSOCKS_PASSWORD` Set a password (string,default: "P@ssw0rd")
* `[VMess] VMESS_ID` Set a UUID, see [www.uuidgenerator.net](https://www.uuidgenerator.net/)

### Option Environment Variables
* `PROTOCOL` (string, default: "vmess", enum: "vmess","shadowsocks")
* `PORT` Server listen port (integer, vmess-default: 10086, shadowsocks-default: 8388)
* `[VMess] VMESS_ALTERID` (integer,default: 64)
* `[Shadowsocks] SHADOWSOCKS_METHOD` (string,default: "chacha20-ietf-poly1305"), see [encryption-list](https://www.v2ray.com/chapter_02/protocols/shadowsocks.html#encryption-list)
* `DENY_LAN_ACCESS` if set true, v2ray client can't access lan ip (boolean,default: "false")

## Related Projects
- [v2ray/official](https://hub.docker.com/r/v2ray/official)

## License
The repository is open-sourced software licensed under the [MIT license](https://opensource.org/licenses/MIT).
