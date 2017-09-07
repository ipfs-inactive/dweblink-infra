#!/usr/bin/env bash
set -e

export IPFS_PATH="/tmp/terraform-ipfs-$$-$(date +%s)"

rm -rf "$IPFS_PATH"
ipfs init 1>&2

cat "$IPFS_PATH/config" | jq .Identity

rm -rf $IPFS_PATH
