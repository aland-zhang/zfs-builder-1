#!/bin/bash
set -ex

KERNEL_VERSION=$( uname -r )
KERNEL_VERSION_MAJOR=$( uname -r | awk -F'.' '{print $1FS$2FS$3}' )

#if ls -d zfs-${ZFS_VERSION}_${KERNEL_VERSION_MAJOR}.el7.x86_64; then
#    cp -vr $( ls -d zfs-${ZFS_VERSION}_${KERNEL_VERSION_MAJOR}.el7.x86_64 ) /rpms 
#    ls /rpms
#    exit 0
#fi

# Fake kernel-devel in rpmdb
VER=$( uname -r | perl -n -e '/^(\S+)-(\S+\.el[78]\S*).x86_64/ && print $1' )
REL=$( uname -r | perl -n -e '/^(\S+)-(\S+\.el[78]\S*).x86_64/ && print $2' )

rpmrebuild -p --notest-install \
--directory=/  \
--release=${REL} \
--change-spec-preamble="sed -e \"s/3\.10\.0/${VER}/g\"" \
--change-spec-preamble="sed -e \"s/957\.el7/${REL}/g\"" \
/kernel-devel-3.10.0-957.el7.x86_64.rpm 

rpm -ivh --justdb /x86_64/*.rpm 
rpm -qa | grep kernel

# Extract source code
tar -zxf zfs-${ZFS_VER}.tar.gz
cd zfs-${ZFS_VER}

# Avoid checking kernel-devel
sed -i 's/.*kernel-devel-uname-r/#&/g' scripts/kmodtool
grep kernel-devel-uname-r scripts/kmodtool

# Compile
./configure --with-spec=redhat

if [ -z $1 ]; then
    make -j1 pkg-utils pkg-kmod 
elif [[ "$1" == "--skip-errors" ]]; then
    make -i -k -j1 pkg-utils pkg-kmod
else
    exec $@
fi

# Copy rpms
rm -vfr /rpms/zfs-${ZFS_VERSION}_${KERNEL_VERSION}
mkdir -p $_
mv -vf $( ls | grep -E ^\(lib\|zfs-[0-9]\|kmod-zfs-[0-9]\).*\.rpm | grep -vw "src\|devel" ) $_
ls -1 $_

