#!/bin/bash
set -x

sddz_spec_path=$(dirname "$0")/../patches/10-stream/sddz/
kernel_spec_path=$(dirname "$0")/../patches/10-stream/kernel/
root_filesystem_spec_path=$(dirname "$0")/../patches/10-stream/root_filesystem/

# update repos source for sddz
#mv /etc/yum.repos.d/centos-addons.repo /etc/yum.repos.d/centos-addons.repo.bac
#mv /etc/yum.repos.d/centos.repo /etc/yum.repos.d/centos.repo.bac
#cp ${sddz_spec_path}/centos.repo /etc/yum.repos.d/centos.repo
#cp ${sddz_spec_path}/centos-addons.repo /etc/yum.repos.d/centos-addons.repo

dnf install -y --setopt=sslverify=0 ca-certificates
update-ca-trust

echo "sslverify=false" >> /etc/dnf/dnf.conf

dnf config-manager --set-enabled crb
dnf makecache
dnf install -y \
  rpmdevtools \
  wget \
  bc bison flex m4 make \
  gcc gcc-c++ \
  clang lld llvm-devel \
  binutils-devel \
  dwarves \
  dracut \
  dosfstools e2fsprogs xfsprogs \
  fuse3-devel \
  git-core \
  glibc-static \
  hmaccalc \
  hostname \
  kmod \
  kernel-rpm-macros \
  libcap-devel libcap-ng-devel \
  libmnl-devel \
  libxml2-devel \
  lvm2 \
  net-tools \
  nss-tools \
  numactl-devel \
  openssl openssl-devel \
  elfutils-devel \
  perl-Carp perl-devel perl-generators perl-interpreter \
  pesign \
  python3-devel python3-docutils python3-jsonschema python3-pyyaml \
  rsync \
  systemd-boot-unsigned systemd-ukify systemd-udev \
  tpm2-tools \
  which xxd \
  zlib-devel \
  squashfs-tools
dnf install -y centos-sb-certs system-sb-certs

