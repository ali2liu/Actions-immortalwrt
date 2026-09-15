#!/bin/bash

echo "src-git nikki https://github.com/nikkinikki-org/OpenWrt-nikki.git;main" >> "feeds.conf.default"
echo "src-git momo https://github.com/nikkinikki-org/OpenWrt-momo.git;main" >> "feeds.conf.default"
# echo "src-git rtp2httpd https://github.com/stackia/rtp2httpd.git;main" >> "feeds.conf.default"
sed -i 's|src-git luci https://github.com/coolsnowwolf/luci.git;openwrt-23.05|src-git luci https://github.com/coolsnowwolf/luci.git;openwrt-25.12|' feeds.conf.default
