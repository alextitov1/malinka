#!/bin/env sh

ansible-playbook -e host=$1 -u $2 -k \
--vault-id @prompt \
./plays/initsetup-play.yml
