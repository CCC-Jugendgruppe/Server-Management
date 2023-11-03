#!/bin/sh

HOSTS="hosts"
FILE="laptop.yml"

ansible-playbook -i $HOSTS $FILE --tasks $@
