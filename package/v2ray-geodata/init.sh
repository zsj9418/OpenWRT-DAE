#!/bin/sh

sed -i '/v2ray-geodata-updater/d' /etc/crontabs/root
echo "0 4 * * * /bin/v2ray-geodata-updater" >> /etc/crontabs/root
crontab /etc/crontabs/root
