#!/usr/bin/env bash

echo " -=- Variable Setup... -=- \n"

GREEN='\033[0;32m'
NC='\033[0m' # No Color

tftpd_content=$(cat <<EOL
TFTP_USERNAME="tftp"
TFTP_DIRECTORY="/tftpboot"
TFTP_ADDRESS="0.0.0.0:69"
TFTP_OPTIONS="--secure"
EOL
)

echo " -=- OS Setup... -=- \n"

echo "Updating OS..."
apt update -y > /dev/null

echo "Upgrading OS..."
apt upgrade -y > /dev/null

echo " -=- Configuring PXE Server... -=- \n"

echo "Stopping Service..."
systemctl stop isc-dhcp-server

echo "Creating tftpboot directory..."
mkdir /tftpboot

echo "Copying EFI modules..."
cp -v /usr/lib/syslinux/modules/efi64/{ldlinux.e64,libutil.c32,menu.c32} /tftpboot

echo "Copying EFI binaries..."
cp -v /usr/lib/SYSLINUX.EFI/efi64/syslinux.efi /tftpboot

echo "Creating pxelinux.cfg directory..."
mkdir /tftpboot/pxelinux.cfg

echo "Configuring TFTPD..."

echo "$tftpd_content" > /etc/default/tftpd-hpa

echo " -=- Setting up Firewall... -=- \n"

echo "Allowing UDP in firewall..."
ufw allow 69/udp

echo "Allowing SSH in firewall..."
ufw allow 22/tcp

echo "Enabling firewall..."
ufw enable

echo "restarting tftpd-hpa..."
systemctl restart tftpd-hpa

echo " -=- Configuring DHCP Server... -=- \n"

echo "Overwriting dhcpcd configuration..."
cp -v ./dhcpcd.conf /etc/dhcp/dhcpcd.conf

echo "Overwriting isc-dhcp-server configuration..."
cp -v ./isc-dhcp-server /etc/default/isc-dhcp-server

echo "Restarting isc-dhcp-server..."
systemctl restart isc-dhcp-server

echo " -=- Setting up PXE... -=- \n"

echo "Mounting ISO..."
mount -o loop Laptop-Management/preseed.iso /mnt
mkdir /tftpboot/debian

echo "Copying ISO contents to tftpboot..."
cp  -v -r /mnt/* /tftpboot/debian

echo "Unmounting ISO..."
umount /mnt

echo "Copying PXE configuration..."
cp -v ./default /tftpboot/pxelinux.cfg/
