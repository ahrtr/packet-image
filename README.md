# Packet.net image to speed up testing of https://github.com/openshift/cluster-api-provider-libvirt

## How to build

Follow https://help.packet.net/article/25-custom-images or in short:

```bash
docker build -t centos_7-baremetal_1 .
docker save centos_7-baremetal_1 > centos_7-baremetal_1.tar
packet-save2image < centos_7-baremetal_1.tar > image.tar.gz
git add image.tar.gz Dockerfile
git commit -m '<msg>'
git push
```

## How to use

Attach following lines as user-data while creating new instance:
```
#cloud-config
#image_repo=https://github.com/paulfantom/packet-image.git
#image_tag=3a3f1eb378f660b335a68b79f3af303380462652
```
where `image_tag` is git commit hash
