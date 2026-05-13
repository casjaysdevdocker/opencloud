## 👋 Welcome to opencloud 🚀  

opencloud README  
  
  
## Install my system scripts  

```shell
 sudo bash -c "$(curl -q -LSsf "https://github.com/systemmgr/installer/raw/main/install.sh")"
 sudo systemmgr --config && sudo systemmgr install scripts  
```
  
## Automatic install/update  
  
```shell
dockermgr update opencloud
```
  
## Install and run container
  
```shell
dockerHome="/var/lib/srv/$USER/docker/casjaysdevdocker/opencloud/opencloud/latest/rootfs"
mkdir -p "/var/lib/srv/$USER/docker/opencloud/rootfs"
git clone "https://github.com/dockermgr/opencloud" "$HOME/.local/share/CasjaysDev/dockermgr/opencloud"
cp -Rfva "$HOME/.local/share/CasjaysDev/dockermgr/opencloud/rootfs/." "$dockerHome/"
docker run -d \
--restart always \
--privileged \
--name casjaysdevdocker-opencloud-latest \
--hostname opencloud \
-e TZ=${TIMEZONE:-America/New_York} \
-v "$dockerHome/data:/data:z" \
-v "$dockerHome/config:/config:z" \
-p 80:80 \
casjaysdevdocker/opencloud:latest
```
  
## via docker-compose  
  
```yaml
version: "2"
services:
  ProjectName:
    image: casjaysdevdocker/opencloud
    container_name: casjaysdevdocker-opencloud
    environment:
      - TZ=America/New_York
      - HOSTNAME=opencloud
    volumes:
      - "/var/lib/srv/$USER/docker/casjaysdevdocker/opencloud/opencloud/latest/rootfs/data:/data:z"
      - "/var/lib/srv/$USER/docker/casjaysdevdocker/opencloud/opencloud/latest/rootfs/config:/config:z"
    ports:
      - 80:80
    restart: always
```
  
## Get source files  
  
```shell
dockermgr download src casjaysdevdocker/opencloud
```
  
OR
  
```shell
git clone "https://github.com/casjaysdevdocker/opencloud" "$HOME/Projects/github/casjaysdevdocker/opencloud"
```
  
## Build container  
  
```shell
cd "$HOME/Projects/github/casjaysdevdocker/opencloud"
buildx 
```
  
## Authors  
  
🤖 casjay: [Github](https://github.com/casjay) 🤖  
⛵ casjaysdevdocker: [Github](https://github.com/casjaysdevdocker) [Docker](https://hub.docker.com/u/casjaysdevdocker) ⛵  
