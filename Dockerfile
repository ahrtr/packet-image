FROM centos:7
MAINTAINER David Laube <dlaube@packet.net>
LABEL Description="Packet's centos_7-baremetal_1 OS image" Vendor="Packet.net"

## HW specific image modifications go in this file

COPY kubernetes.repo /etc/yum.repos.d/kubernetes.repo
RUN yum install -y -d1 libvirt libvirt-daemon-kvm wget kubectl && \
    usermod -aG libvirt root && \
    echo 'unix_sock_group = "libvirt"' > /etc/libvirt/libvirtd.conf && \
    echo 'unix_sock_rw_perms = "0770"' > /etc/libvirt/libvirtd.conf && \
    systemctl enable libvirtd

# Install minikube
RUN curl -Lo /usr/local/bin/minikube https://storage.googleapis.com/minikube/releases/v0.28.2/minikube-linux-amd64 && \
    chmod +x /usr/local/bin/minikube

# Install kvm2 driver
RUN curl -Lo /usr/local/bin/docker-machine-driver-kvm2 https://storage.googleapis.com/minikube/releases/latest/docker-machine-driver-kvm2 && \
    chmod +x /usr/local/bin/docker-machine-driver-kvm2

# Download fedora image
RUN wget --inet4-only https://download.fedoraproject.org/pub/fedora/linux/releases/28/Cloud/x86_64/images/Fedora-Cloud-Base-28-1.1.x86_64.qcow2
