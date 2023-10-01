#!/bin/bash

new_name = "$(date "+%F_%H_%M_%S").iso"

cd ./Laptop-Management/

git reset --hard

git pull

cd iso

mv preseed.iso $new_name

mv $new_name ../ ../backup/

make clean

make setup

make build
