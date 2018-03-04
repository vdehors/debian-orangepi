setenv bootargs "console=ttyS0,115200 root=/dev/mmcblk0p2 init=/sbin/init rw rootwait panic=10 consoleblank=0 loglevel=d"

ext4load mmc 0:1 0x48000000 /zImage
ext4load mmc 0:1 0x43000000 /sun8i-h2-plus-orangepi-zero.dtb

bootz 0x48000000 - 0x43000000
