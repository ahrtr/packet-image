FROM scratch
ADD rootfs.tar.gz /

MAINTAINER David Laube <dlaube@packet.net>
LABEL Description="Packet's CentOS 7 OS base image" Vendor="Packet.net" Version="2018.10.05.00"

RUN yum -y update && yum -y install \
	audit \
	bash \
	bash-completion \
	ca-certificates \
	chrony \
	cloud-init \
	cloud-utils-growpart \
	cron \
	curl \
	device-mapper-multipath \
	dhclient \
	ethstatus \
	hwdata \
	ioping \
	iotop \
	iperf \
	iscsi-initiator-utils \
	keyutils \
	locate \
	logrotate \
	make \
	mdadm \
	mg \
	microcode_ctl \
	mtr \
	net-tools \
	NetworkManager-team \
	NetworkManager-tui \
	nmap-ncat \
	ntp \
	ntpdate \
	openssh-clients \
	openssh-server \
	openssl \
	parted \
	pciutils \
	redhat-lsb-core \
	rsync \
	rsyslog \
	screen \
	socat \
	sudo \
	sysstat \
	systemd \
	tar \
	tcpdump \
	teamd \
	tmux \
	traceroute \
	tuned \
	vim \
	wget \
	yum-plugin-ovl

# Remove default eth0 dhcp config
RUN rm -f /etc/sysconfig/network-scripts/ifcfg-eth0

# Reinstall iputils due to non-priv user bug, fix cap
RUN yum -y reinstall iputils

# Add service to fix POSIX 1003.1e capabilities on ping
RUN bash -c "$(/bin/echo -e "cat > /usr/lib/systemd/system/setcap.service <<EOM\
\n[Unit]\
\nDescription=Setup setcap ping\
\nAfter=multi-user.target\
\n \
\n[Service]\
\nType=oneshot\
\nExecStart=/usr/sbin/setcap 'cap_net_admin,cap_net_raw+ep' /usr/bin/ping\
\nRemainAfterExit=true\
\nStandardOutput=journal\
\n \
\n[Install]\
\nWantedBy=multi-user.target\
\nEOM\n")"
RUN ln -s /usr/lib/systemd/system/setcap.service /etc/systemd/system/setcap.service
RUN ln -s /usr/lib/systemd/system/setcap.service /etc/systemd/system/multi-user.target.wants/setcap.service

# Install a specific kernel and deps
RUN yum -y install kernel-3.10.0-862.14.4.el7 microcode linux-firmware grub2-efi grub2 efibootmgr

# Adjust generic initrd
RUN dracut --filesystems="ext4 vfat" --mdadmconf --force /boot/initramfs-3.10.0-862.14.4.el7.x86_64.img 3.10.0-862.14.4.el7.x86_64

# Adjust root account
RUN passwd -d root && passwd -l root

# Clean yum cache
RUN yum clean all

# vim: set tabstop=4 shiftwidth=4:

COPY kubernetes.repo /etc/yum.repos.d/kubernetes.repo
COPY kvm.repo /etc/yum.repos.d/kvm.repo
RUN yum install -y -d1 libvirt libvirt-daemon-kvm wget kubectl qemu-kvm && \
    usermod -aG libvirt root && \
    echo 'unix_sock_group = "libvirt"' > /etc/libvirt/libvirtd.conf && \
    echo 'unix_sock_rw_perms = "0770"' > /etc/libvirt/libvirtd.conf && \
    systemctl enable libvirtd

# Install minikube
RUN curl -Lo /usr/local/bin/minikube https://storage.googleapis.com/minikube/releases/v0.28.0/minikube-linux-amd64 && \
    chmod +x /usr/local/bin/minikube

# Install kvm2 driver
RUN curl -Lo /usr/local/bin/docker-machine-driver-kvm2 https://storage.googleapis.com/minikube/releases/latest/docker-machine-driver-kvm2 && \
    chmod +x /usr/local/bin/docker-machine-driver-kvm2

# Enable password login
RUN sed -i 's/PasswordAuthentication.*$/PasswordAuthentication yes/g' /etc/ssh/sshd_config

# Download fedora image
RUN wget --inet4-only https://download.fedoraproject.org/pub/fedora/linux/releases/28/Cloud/x86_64/images/Fedora-Cloud-Base-28-1.1.x86_64.qcow2
