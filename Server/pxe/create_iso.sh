#!/bin/bash

mk="make"

sudo apt install ufw tftp-hpa wget git genisoimage fakeroot $mk -y

git clone https://github.com/CCC-Jugendgruppe/Laptop-Management.git

isopath="./Laptop-Management/iso"

[ ! -f "$isopath/debian12.iso" ] && wget https://cdimage.debian.org/debian-cd/current/amd64/iso-dvd/debian-12.1.0-amd64-DVD-1.iso -O "$isopath/debian12.iso"

cd "$isopath"

rm -rf ../Management

$mk setup build
