# Intro

This directory contains DNS zone configurations for domains hosted in cloudflare.

# How to use

```sh
# the password in op "malinka ansible vault pass"
ansible-playbook DNS/cloudflare/cloudflare-playbook.yaml --vault-id @prompt

```