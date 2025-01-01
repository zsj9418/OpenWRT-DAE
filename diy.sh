#!/bin/bash

#WRT_REPO='https://github.com/davidtall/LiBwrt-openwrt-6.x'
#WRT_BRANCH='kernel-6.12'

#WRT_REPO='https://github.com/davidtall/immortalwrt-6.12'
#WRT_BRANCH='main'

WRT_REPO='https://github.com/VIKINGYFY/immortalwrt'
WRT_BRANCH='main'

if [ -n "$1" ]; then
    # 如果有传递参数，赋值给WRT_TARGET
    export WRT_TARGET="$1"
else
    # 如果没有传递参数，设置默认值
    export WRT_TARGET="Config/JDC-AX1800-PRO-WIFI-NO.txt"
fi

if [ -n "$2" ]; then
    WRT_REPO="$2"
fi

export WRT_DIR=wrt
export GITHUB_WORKSPACE=$(pwd)
export WRT_DATE=$(TZ=UTC-8 date +"%y.%m.%d_%H.%M.%S")
export WRT_VER=$(echo $WRT_REPO | cut -d '/' -f 5-)-$WRT_BRANCH
export WRT_TYPE=$(sed -n "1{s/^#//;s/\r$//;p;q}" $WRT_TARGET)
export WRT_NAME='OWRT'
export WRT_SSID='OWRT'
export WRT_WORD='12345678'
export WRT_THEME='argon'
export WRT_IP='192.168.10.1'
export WRT_CI='WSL-OpenWRT-CI'



if [ ! -d $WRT_DIR ]; then
  git clone --depth=1 --single-branch --branch $WRT_BRANCH $WRT_REPO $WRT_DIR
  cd $WRT_DIR
else
  cd $WRT_DIR
  git remote set-url origin $WRT_REPO
  rm -rf feeds/*
  git clean -f
  git reset --hard
  git pull
fi
#rm -rf feeds
./scripts/feeds update -a && ./scripts/feeds install -a

cd package/
$GITHUB_WORKSPACE/Scripts/Packages.sh
$GITHUB_WORKSPACE/Scripts/Handles.sh
cd ..
cat $GITHUB_WORKSPACE/$WRT_TARGET $GITHUB_WORKSPACE/Config/GENERAL.txt > .config
$GITHUB_WORKSPACE/Scripts/Settings.sh

make defconfig
# make download -j8
# make -j$(nproc) || make V=s -j1

# make download -j8 && (make -j$(nproc) || make V=s -j1)