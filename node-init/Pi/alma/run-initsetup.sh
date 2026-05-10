#!/usr/bin/env bash

usage() {
    echo " Usage: $0 [-h host] [-u user]"
    echo ""
    echo " Example: $0 -h malinka3 -u almalinux"
    exit 1
}

while getopts ":h:u:" opt; do
    case "$opt" in
        h) host="$OPTARG" ;;
        u) user="$OPTARG" ;;
        :) echo "Option -$OPTARG requires an argument." >&2; usage ;;
        \?) echo "Invalid option: -$OPTARG" >&2; usage ;;
    esac
done
shift $((OPTIND - 1))

# Check if there are any positional arguments remaining
if [ $# -gt 0 ]; then
    echo "Error: Positional arguments are not allowed. Use -h for host and -u for user." >&2
    echo "Received unexpected arguments: $*" >&2
    usage
fi

cmd_options='--vault-id @prompt'
if [ -n "$host" ]; then
    cmd_options+=" -e host=$host"
fi
if [ -n "$user" ]; then
    cmd_options+=" -u $user -k"
fi
cmd_options+=" $(cd "$(dirname "$0")" && pwd)/initsetup-playbook.yaml"


set -x
exec ansible-playbook $cmd_options
