#!/bin/bash

dir=$(cd $(dirname "${BASH_SOURCE[0]}") && pwd)

source $dir/.env

re='^[0-9]+$'

#backup current project
$dir/pack.sh

#pack live extension
cd $dir/build/
plesk bin extension --pack $ext

#replace project
rm -vrf $dir/$ext/*

unzip $dir/build/$ext-1.1-01.zip -d $dir/$ext/