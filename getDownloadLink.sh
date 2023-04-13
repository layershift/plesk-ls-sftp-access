#!/bin/bash

dir=$(dirname "$0")

source $dir/.env

re='^[0-9]+$'

debug=1


cd $dir/build
file="$(readlink $ext-latest.zip)"
echo "wget ${devUrl}/build/${file} -O ${file}"
echo "ln -sf $file $ext-latest.zip"
echo ""
echo "chown -h ${publicUrlUser}:${publicUrlGroup} $ext-latest.zip"
echo "chown ${publicUrlUser}:${publicUrlGroup} $ext-*.zip"
echo ""
echo "plesk bin extension --install-url ${devUrl}/build/${file}"
echo ""
