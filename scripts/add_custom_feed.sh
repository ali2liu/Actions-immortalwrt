#!/bin/bash

echo "src-git nikki https://github.com/nikkinikki-org/OpenWrt-nikki.git;main" >> "feeds.conf.default"
echo "src-git momo https://github.com/nikkinikki-org/OpenWrt-momo.git;main" >> "feeds.conf.default"
# echo "src-git rtp2httpd https://github.com/stackia/rtp2httpd.git;main" >> "feeds.conf.default"
sed -i 's|src-git luci https://github.com/coolsnowwolf/luci.git;openwrt-23.05|src-git luci https://github.com/coolsnowwolf/luci.git;openwrt-25.12|' feeds.conf.default
cat > feeds.conf.default <<'EOF'
src-git packages https://github.com/immortalwrt/packages.git^84bd86384928955b568988ca0e09e2c78c75173d
src-git luci https://github.com/immortalwrt/luci.git^d6167ea0645cbd1327708d85f94824f42d0eb872
src-git routing https://github.com/openwrt/routing.git^e49d76035aafb85ddc993b59271d8c7ba56b5362
src-git telephony https://github.com/openwrt/telephony.git^2618106d5846a4a542fdf5809f0d3ed228ce439b
src-git video https://github.com/openwrt/video.git^094bf58da6682f895255a35a84349a79dab4bf95
EOF
