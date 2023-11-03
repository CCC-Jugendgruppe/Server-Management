#!/bin/sh

# use default values, if not specified by `HOSTS=file bash ansible-run ...`
: ${HOSTS:="hosts"}
: ${FILE:="laptop.yml"}

ansible-playbook $FILE -i $HOSTS --tags "$@"
