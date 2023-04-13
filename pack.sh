#!/bin/bash

dir=$(dirname "$0")

source $dir/.env

re='^[0-9]+$'

debug=1

rpm -q xmlstarlet > /dev/null
if [ $? -ne 0 ]; then
    yum install xmlstarlet
fi

buildDate="$(date +'%F %R %Z')"
buildDateSum="$(echo -n buildDate | md5sum | awk '{print $1}')"


version=$(xmlstarlet sel -t -v 'module/version' $ext/meta.xml)
if [ $version == "" ]; then
    version="1.0"
fi
if [ $debug -gt 0 ]; then
    echo "Debug: \$version=$version"
fi

ls -1 $dir/build/ | grep -v ${ext}-latest.zip | tail -n1

latestBuild=$(ls -1 $dir/build/*$version* | tail -n1 | awk -F "-" '{print $NF}' | sed 's#.zip##')
if ! [[ $latestBuild =~ $re ]] ; then
    latestBuild=$(xmlstarlet sel -t -v 'module/release' $ext/meta.xml)
fi
if [ $debug -gt 0 ]; then
    echo "Debug: \$latestBuild=$latestBuild"
fi

newBuild=$(( ${latestBuild#0} + 1))
if ! [[ $newBuild =~ $re ]] ; then
    newBuild=1
fi

if [ $newBuild -lt 10 ]; then
    newBuild=0$newBuild;
fi

if [ $debug -gt 0 ]; then
    echo "Debug: \$newBuild=$newBuild"
fi
# set new build number
sed -i "s#<release>.*</release>#<release>$newBuild</release>#" $dir/$ext/meta.xml
sed -i "s#Version: .*</td>#Version: ${version}.${newBuild}</td>#"  $dir/$ext/plib/controllers/IndexController.php

# debug.log cleanup
echo "" > $dir/$ext/var/debug.log

# build
cd $dir/$ext
echo "zip --recurse-paths --quiet ../build/$ext-${version}-${newBuild}.zip ."
zip --recurse-paths --quiet ../build/$ext-${version}-${newBuild}.zip .
cd ..
cd $dir/build
buildSum="$(md5sum $ext-${version}-${newBuild}.zip | awk '{print $1}')"
rm -f $ext-latest.zip
ln -s $ext-${version}-${newBuild}.zip $ext-latest.zip
echo -n "Latest version: "
readlink $ext-latest.zip
echo "plesk bin extension -i $(readlink -f $ext-latest.zip)"
cd ..

# update listing
sed -i "s#\$obj->updated_at=.*#\$obj->updated_at=\"${buildDate}\";#" $dir/extension-catalog/listing.txt
sed -i "s#\$obj->revision=.*#\$obj->revision=\"${buildDateSum}\";#" $dir/extension-catalog/listing.txt
sed -i "s#\$obj->build=.*#\$obj->build=\"${buildDate}\";#" $dir/extension-catalog/listing.txt
sed -i "s#\$obj->version=.*#\$obj->version=\"${version}\";#" $dir/extension-catalog/listing.txt
sed -i "s#\$obj->release=.*#\$obj->release=\"${newBuild}\";#" $dir/extension-catalog/listing.txt
sed -i "s#\$obj->checksum=.*#\$obj->checksum=\"${buildSum}\";#" $dir/extension-catalog/listing.txt
sed -i "s#\$obj->download_url=.*#\$obj->download_url=\"${publicUrl}/${ext}/$ext-${version}-${newBuild}.zip\";#" $dir/extension-catalog/listing.txt
