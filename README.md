# env-v2ray for docker
## How to use
[![This image on DockerHub](https://img.shields.io/docker/pulls/awei/env-v2ray.svg)](https://hub.docker.com/r/awei/env-v2ray/)

[View on Docker Hub](https://hub.docker.com/r/awei/env-v2ray)
```console
$ docker run -d -p <PORT>:<DOCKER-PORT> -e ID="<GUID>" awei/env-v2ray
```
```e.g.
$ docker run -d -p 10086:10086 --rm -e ID="877e125d-1ef3-40ef-9329-b7ec62c1072c" awei/env-v2ray
```
### Necessary Environment Variables
* `ID` Set a GUID

see [www.uuidgenerator.net](https://www.uuidgenerator.net/guid)

### Option Environment Variables
* `PORT` Server listen port (default: 10086)
* `ALTERID` Encryption type (default: 64)

## Related Projects
- [v2ray/official](https://hub.docker.com/r/v2ray/official)

## License
The repository is open-sourced software licensed under the [MIT license](https://opensource.org/licenses/MIT).
