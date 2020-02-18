FROM centos:centos7.6.1810

ENV ZFS_VER=0.8.3

RUN set -x && \
    yum install -y epel-release && \
    yum install -y rpmrebuild epel-release gcc make autoconf automake libtool rpm-build dkms libtirpc-devel libblkid-devel libuuid-devel libudev-devel openssl-devel zlib-devel libaio-devel libattr-devel elfutils-libelf-devel python python2-devel python-setuptools python-cffi libffi-devel wget curl && \
    yum clean all

RUN set -x && \
    wget https://github.com/zfsonlinux/zfs/releases/download/zfs-${ZFS_VER}/zfs-${ZFS_VER}.tar.gz

RUN set -x && \
    wget https://mirror.tuna.tsinghua.edu.cn/centos-vault/7.6.1810/os/x86_64/Packages/kernel-devel-3.10.0-957.el7.x86_64.rpm

COPY entrypoint.sh /

ENTRYPOINT ["/entrypoint.sh"]
