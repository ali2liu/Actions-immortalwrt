# 解决 luci-app-openvpn-server 冲突 - 重命名 config 和 init
pushd feeds/luci/applications/luci-app-openvpn-server

# 修改 Makefile 中的 conffiles 和 install（如果 Makefile 有这些行）
sed -i 's|/etc/config/openvpn|/etc/config/openvpn-server|g' Makefile
sed -i 's|openvpn |openvpn-server |g' Makefile  # 粗替换

# 如果 Makefile 没 install init，强制添加或忽略

# 处理 LuCI CBI 和其他文件
find luasrc/ -type f -name "*.lua" -exec sed -i 's/Map("openvpn"/Map("openvpn-server"/g' {} \;
find luasrc/ -type f -name "*.lua" -exec sed -i 's/"openvpn"/"openvpn-server"/g' {} \;

# 处理 init 脚本
if [ -f files/openvpn.init ]; then
  mv files/openvpn.init files/openvpn-server.init
else
  cp ../../../packages/net/openvpn/files/openvpn.init files/openvpn-server.init
fi
sed -i 's/config_load openvpn/config_load openvpn-server/g' files/openvpn-server.init
sed -i 's/NAME=openvpn/NAME=openvpn-server/g' files/openvpn-server.init || true
sed -i 's/openvpn-/openvpn-server-/g' files/openvpn-server.init
sed -i 's/openvpn(/openvpn-server(/g' files/openvpn-server.init

popd
