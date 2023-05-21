#!/bin/env sh

ansible-playbook -e host=$1 -u root -k \
--vault-id @prompt \
./plays/initsetup-play.yml
