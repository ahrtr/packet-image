#!/bin/bash

docker build -t centos_7-baremetal_1 .
docker save centos_7-baremetal_1 > centos_7-baremetal_1.tar
packet-save2image < centos_7-baremetal_1.tar > image.tar.gz
