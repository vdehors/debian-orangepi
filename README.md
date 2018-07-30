This repository contains tools to generate a Debian image for Orange Pi Zero board.

You first must download a recent toolchain (gcc >= 6) for Linux kernel and U-boot build.
Then you need at least the following tools :

* build-essential
* multistrap
* swig
* rsync
* qemu qemu-user-static
* binfmt-support
* gcc-arm-linux-gnueabihf u-boot-tools
* flex bison bc

The _generate.sh_ script download and build stable legacy Linux kernel and U-boot. Then it uses Debian multistrap tool to generate a rootfs and qmeu-static-arm to perform second stage of package installation.

Before running, make sure to update the file _config.env_ containing options for build and installation.
You can define the user in the config file, it will be added without password. Don't forget to change it after.
