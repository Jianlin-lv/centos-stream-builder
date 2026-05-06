#!/bin/bash
set -x

UPSTREAM_DIR="/mnt/centos_10_stream_upstream"
CENTOS_KERNEL_VERSION="6.12.0-218.el10"
ARCH="x86_64"

sddz_spec_path=$(dirname "$0")/../patches/10-stream/sddz/
kernel_spec_path=$(dirname "$0")/../patches/10-stream/kernel/
root_filesystem_spec_path=$(dirname "$0")/../patches/10-stream/root_filesystem/


cd /root/
rm -rf kernel-${CENTOS_KERNEL_VERSION}.src.rpm
wget https://mirror.stream.centos.org/10-stream/BaseOS/source/tree/Packages/kernel-${CENTOS_KERNEL_VERSION}.src.rpm
rm -rf rpmbuild
rpmdev-setuptree
rpm -ivh kernel-${CENTOS_KERNEL_VERSION}.src.rpm

dnf builddep -y /root/rpmbuild/SPECS/kernel.spec
sed -i 's/^BuildRequires:.*fuse-devel/BuildRequires: fuse3-devel/' /root/rpmbuild/SPECS/kernel.spec

# apply kernel patch
cp /mnt/centos-stream-builder/patches/10-stream/kernel/fix-disk-order.patch /root/rpmbuild/SOURCES/

cd /root/rpmbuild/

# Backup original if not exists
if [[ ! -f "/root/rpmbuild/SPECS/kernel.spec.org" ]]; then
  cp /root/rpmbuild/SPECS/kernel.spec /root/rpmbuild/SPECS/kernel.spec.org
  echo "Created backup: /root/rpmbuild/SPECS/kernel.spec.org"
fi

patch -p0 < /mnt/centos-stream-builder/patches/10-stream/kernel/kernel-spec-fix-disk-order.patch

if grep -q "Patch1000: fix-disk-order.patch" "/root/rpmbuild/SPECS/kernel.spec" && \
   grep -q "ApplyOptionalPatch fix-disk-order.patch" "/root/rpmbuild/SPECS/kernel.spec"; then
    echo "Patch verification successful"
    echo "Changes made:"
    diff "/root/rpmbuild/SPECS/kernel.spec.org" "/root/rpmbuild/SPECS/kernel.spec" || true
else
    echo "Patch verification failed"
    exit 1
fi

rpmbuild -ba SPECS/kernel.spec --target=x86_64 --without realtime --without debug \
  --without debuginfo --without doc --without selftests > centos-build.log 2>&1
