#!/bin/bash

echo "Update"
sudo apt update && sudo apt upgrade -y

echo "Pakete installieren"
sudo apt install syslinux-common syslinux-efi isc-dhcp-server tftpd-hpa ufw -y

echo "stoppe isc-dhcp-server service"
sudo systemctl stop isc-dhcp-server

echo "erstelle tftpboot Verzeichnis"
sudo mkdir /tftpboot

cd /usr/lib/syslinux/modules/efi64/

echo "kopiere ldlinux.e64"
sudo cp ldlinux.e64 /tftpboot

sudo cp {libutil.c32,menu.c32} /tftpboot

cd /usr/lib/SYSLINUX.EFI/efi64

sudo cp syslinux.efi /tftpboot/

cd /tftpboot

sudo mkdir pxelinux.cfg

tftpd_content=$(cat <<EOL
TFTP_USERNAME="tftp"
TFTP_DIRECTORY="/tftpboot"
TFTP_ADDRESS="0.0.0.0:69"
TFTP_OPTIONS="--secure"
EOL
)

echo "$tftpd_content" | sudo tee /etc/default/tftpd-hpa > /dev/null

echo "Udp in der Firewall erlauben"
sudo ufw allow 69/udp

sudo ufw enable

sudo systemctl restart tftpd-hpa

sudo rm -f /etc/dhcp/dhcpd.conf

sudo cp /home/$SUDO_USER/Server-Management/Server/pxe/dhcpd.conf /etc/dhcp/

sudo rm -f /etc/default/isc-dhcp-server

sudo cp /home/$SUDO_USER/Server-Management/Server/pxe/isc-dhcp-server /etc/default/

sudo systemctl start isc-dhcp-server

sudo mkdir /tftpboot/debian

sudo mount /home/$SUDO_USER/debian12.iso /mnt

sudo cp -r /mnt/* /tftpboot/debian

sudo cp /home/$SUDO_USER/Server-Management/Server/pxe/default /tftpboot/pxelinux.cfg

