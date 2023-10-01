#!/usr/bin/env bash

echo -e " -=- Variable Setup... -=- \n"

GREEN='\033[0;32m'
NC='\033[0m' # No Color

DEFAULT_NEXT_SERVER="10.23.42.152"
DEFAULT_INTERFACE="eth0"

tftpd_content=$(cat <<EOL
TFTP_USERNAME="tftp"
TFTP_DIRECTORY="/tftpboot"
TFTP_ADDRESS="0.0.0.0:69"
TFTP_OPTIONS="--secure"
EOL
)

echo -e " ${GREEN} DONE! ${NC} \n"

echo -e " -=- OS Setup... -=- \n"

echo -e "Updating OS..."
apt update -y > /dev/null

echo -e "Upgrading OS..."
apt upgrade -y > /dev/null

echo -e " ${GREEN} DONE! ${NC} \n"
echo -e " -=- Configuring PXE Server... -=- \n"

echo -e "Stopping Service..."
systemctl stop isc-dhcp-server

echo -e "Creating tftpboot directory..."
mkdir /tftpboot

echo -e "Copying EFI modules..."
cp -v /usr/lib/syslinux/modules/efi64/{ldlinux.e64,libutil.c32,menu.c32} /tftpboot

echo -e "Copying EFI binaries..."
cp -v /usr/lib/SYSLINUX.EFI/efi64/syslinux.efi /tftpboot

echo -e "Creating pxelinux.cfg directory..."
mkdir /tftpboot/pxelinux.cfg

echo -e "Configuring TFTPD..."

echo "$tftpd_content" > /etc/default/tftpd-hpa

echo -e " ${GREEN} DONE! ${NC} \n"
echo -e " -=- Setting up Firewall... -=- \n"

echo -e "Allowing UDP in firewall..."
ufw allow 69/udp

echo -e "Allowing SSH in firewall..."
ufw allow 22/tcp

echo -e "Enabling firewall..."
ufw enable

echo -e "restarting tftpd-hpa..."
systemctl restart tftpd-hpa

echo -e " ${GREEN} DONE! ${NC} \n"
echo -e " -=- Configuring DHCP Server... -=- \n"

echo -e "Overwriting dhcpd configuration..."
echo -e "Please specify 'next-server' (IP of PXE server, default $DEFAULT_NEXT_SERVER): "
read next_server
[ ! -z "$next_server" ] && sed -i "s/$DEFAULT_NEXT_SERVER/$next_server/g" ./dhcpd.conf
cp -v ./dhcpd.conf /etc/dhcp/dhcpd.conf

echo -e "Overwriting isc-dhcp-server configuration..."
echo -e "Please specify the interface to use for DHCP (default $DEFAULT_INTERFACE): "
read interface
[ ! -z "$interface" ] && sed -i "s/$DEFAULT_INTERFACE/$interface/g"./isc-dhcp-server
cp -v ./isc-dhcp-server /etc/default/isc-dhcp-server

echo -e "Restarting isc-dhcp-server..."
systemctl restart isc-dhcp-server

echo -e " ${GREEN} DONE! ${NC} \n"
echo -e " -=- Setting up PXE... -=- \n"

echo -e "Mounting ISO..."
mount -o loop Laptop-Management/preseed.iso /mnt
mkdir /tftpboot/debian

echo -e "Copying ISO contents to tftpboot..."
cp  -v -r /mnt/* /tftpboot/debian

echo -e "Unmounting ISO..."
umount /mnt

echo -e "Copying PXE configuration..."
cp -v ./default /tftpboot/pxelinux.cfg/

echo -e " ${GREEN} DONE! ${NC} \n"
