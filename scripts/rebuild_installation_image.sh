#!/bin/bash
set -x

image_tag=`date +%Y%m%d`
CENTOS_KERNEL_VERSION="6.12.0-218.el10.x86_64"

UPSTREAM_IMG="https://mirror.stream.centos.org/10-stream/BaseOS/x86_64/os/images/pxeboot/"
UPSTREAM_DIR="/mnt/centos_10_stream_upstream"
OUTPUT_DIR="${1:-/mnt/output}"
PATCHES_DIR="${2:-//mnt/centos-stream-builder/patches/10-stream/root_filesystem/}"

rm -rf ${OUTPUT_DIR} ${UPSTREAM_DIR}
mkdir -p ${OUTPUT_DIR}
mkdir -p ${UPSTREAM_DIR}

# download upstream initrd.img and install.img
cd ${UPSTREAM_DIR}
wget ${UPSTREAM_IMG}/initrd.img
wget ${UPSTREAM_IMG}/install.img

# install kernel packages
rpm -e --nodeps kernel-modules-extra-${CENTOS_KERNEL_VERSION} 2>/dev/null || echo \"kernel-modules-extra removed or not found\" &&
rpm -e --nodeps kernel-modules-${CENTOS_KERNEL_VERSION} 2>/dev/null || echo \"kernel-modules removed or not found\" &&
rpm -e --nodeps kernel-modules-core-${CENTOS_KERNEL_VERSION} 2>/dev/null || echo \"kernel-modules-core removed or not found\" &&
rpm -e --nodeps kernel-core-${CENTOS_KERNEL_VERSION} 2>/dev/null || echo \"kernel-core removed or not found\" && 
rpm -e --nodeps kernel-${CENTOS_KERNEL_VERSION} 2>/dev/null || echo \"kernel-core removed or not found\"

cd /root/rpmbuild
rpm -ivh RPMS/x86_64/kernel-${CENTOS_KERNEL_VERSION}.rpm \
  RPMS/x86_64/kernel-core-${CENTOS_KERNEL_VERSION}.rpm \
  RPMS/x86_64/kernel-modules-core-${CENTOS_KERNEL_VERSION}.rpm \
  RPMS/x86_64/kernel-modules-${CENTOS_KERNEL_VERSION}.rpm \
  RPMS/x86_64/kernel-modules-extra-${CENTOS_KERNEL_VERSION}.rpm



# Create new initrd with consistent modules
cd /tmp && rm -rf initrd_clean
mkdir initrd_clean && cd initrd_clean
cp ${UPSTREAM_DIR}/initrd.img .
mkdir extracted && cd extracted
xz -dc ../initrd.img | cpio -idm

# Replace with clean modules
rm -rf usr/lib/modules/${CENTOS_KERNEL_VERSION}
cp -r /lib/modules/${CENTOS_KERNEL_VERSION} usr/lib/modules/

# Create new initrd
find . | cpio -o -H newc | xz --check=crc32 > ../initrd-${image_tag}.img
cp ../initrd-${image_tag}.img ${OUTPUT_DIR}
chmod 755 ${OUTPUT_DIR}/initrd-${image_tag}.img

# Copy clean kernel
cp /lib/modules/${CENTOS_KERNEL_VERSION}/vmlinuz ${OUTPUT_DIR}/vmlinuz-${image_tag}

cd "$OUTPUT_DIR"
# Download and extract upstream install.img
rm -rf squashfs-root install.img
cp ${UPSTREAM_DIR}/install.img .
unsquashfs -no-xattrs install.img

# Apply pre-generated patches
echo "Applying patches from $PATCHES_DIR..."

cd squashfs-root
for patch in "$PATCHES_DIR"/*.patch; do
    echo "Applying $(basename "$patch")..."
    patch -p2 < "$patch"  # Removes "squashfs-root/" and "a/"/"b/"
done
cd ..

echo "Replacing kernel modules..."
rm -f squashfs-root/usr/lib/modules/${CENTOS_KERNEL_VERSION}
cp -r /lib/modules/${CENTOS_KERNEL_VERSION} squashfs-root/usr/lib/modules/

rm -rf install-${image_tag}.img
mksquashfs squashfs-root install-${image_tag}.img
chmod 755 install-${image_tag}.img
file install-${image_tag}.img
