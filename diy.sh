#!/bin/bash

WRT_REPO='https://github.com/LiBwrt-op/openwrt-6.x'
WRT_BRANCH='openwrt-24.10'

export GITHUB_WORKSPACE=$(pwd)
export WRT_DIR=LiBwrt-op
export WRT_TARGET=JDC-AX1800-PRO-WIFI-NO
export WRT_DATE=$(TZ=UTC-8 date +"%y.%m.%d_%H.%M.%S")
export WRT_VER=$(echo $WRT_REPO | cut -d '/' -f 5-)-$WRT_BRANCH
export WRT_TYPE=$(sed -n "1{s/^#//;s/\r$//;p;q}" ./Config/$WRT_TARGET.txt)
export WRT_NAME='OWRT'
export WRT_WIFI='OWRT'
export WRT_THEME='argon'
export WRT_IP='192.168.1.1'

chmod +x $GITHUB_WORKSPACE/Scripts/*.sh

git clone --depth=1 --single-branch --branch openwrt-24.10 https://github.com/LiBwrt-op/openwrt-6.x $WRT_DIR
cd $WRT_DIR
#rm -rf feeds
./scripts/feeds update -a && ./scripts/feeds install -a

cd $WRT_DIR/package/
$GITHUB_WORKSPACE/Scripts/Packages.sh
$GITHUB_WORKSPACE/Scripts/Handles.sh
cd ..
cat $GITHUB_WORKSPACE/Config/$WRT_TARGET.txt $GITHUB_WORKSPACE/Config/GENERAL.txt > .config
$GITHUB_WORKSPACE/Scripts/Settings.sh

make defconfig
make download -j8
make V=s -j$(nproc) || make V=s -j1
