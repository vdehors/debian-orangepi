#! /bin/bash

source config.env

read -r -p "Are you sure you want to write on ${SDCARD} ? (Y/n)" response
case "$response" in
	[nN][oO]|[nN]) 
	exit 1
	;;
esac

#
# KERNEL
#
git clone git://git.kernel.org/pub/scm/linux/kernel/git/stable/linux-stable.git -b ${KERNEL_VERSION}
cd linux-stable
make ARCH=arm sunxi_defconfig
make -j8 ARCH=arm CROSS_COMPILE=${CROSS_COMPILE} LOADADDR=${LOADADDR} zImage sun8i-h2-plus-orangepi-zero.dtb modules
cd -

#
# U-BOOT
#
git clone https://github.com/u-boot/u-boot.git -b ${UBOOT_VERSION}
cd u-boot
make orangepi_zero_defconfig
make all
cd -
mkimage -A arm -O linux -T script -C none -a 0 -e 0 -n "Orange Pi Zero" -d boot.cmd boot.scr

#
# ROOTFS
#
sudo multistrap -a armhf -d rootfs -f multistrap.config
echo "${HOSTNAME}" | sudo tee rootfs/etc/hostname
sudo cp /usr/bin/qemu-arm-static rootfs/usr/bin

function run_in_rootfs()
{
	ENV="DEBIAN_FRONTEND=noninteractive DEBCONF_NONINTERACTIVE_SEEN=true LC_ALL=C LANGUAGE=C LANG=C"
	sudo $ENV chroot rootfs $*
}
run_in_rootfs /var/lib/dpkg/info/dash.preinst install
run_in_rootfs dpkg --configure -a
run_in_rootfs useradd -p \"\" -m -U $NEW_USER

#
# SDCARD CREATION
#
# Remove MBR
sudo dd if=/dev/zero of=${SDCARD} bs=1M count=100
# Write new partition table
cat fdisk.config | sudo fdisk /dev/sdb
sync
# Write U-boot
sudo dd if=u-boot/u-boot-sunxi-with-spl.bin of=${SDCARD} bs=1024 seek=8 conv=notrunc
sync
# Write Part 1 : Linux and DTB
sudo mkfs.ext4 ${SDCARDP1}
sudo mount ${SDCARDP1} /mnt
sudo cp linux-stable/arch/arm/boot/zImage /mnt/
sudo cp linux-stable/arch/arm/boot/dts/*.dtb /mnt/
sudo cp boot.scr /mnt/boot.scr
sudo umount /mnt
# Write Part 2 : Rootfs Debian
sudo mkfs.ext4 ${SDCARDP2}
sudo mount ${SDCARDP2} /mnt
sudo rsync -aP rootfs/ /mnt/
sudo umount /mnt
