# 解决 luci-app-openvpn-server 覆盖 /etc/config/openvpn 的编译错误
# 方式：移除 openvpn-openssl 对 /etc/config/openvpn 的 conffiles 拥有权
pushd feeds/packages/net/openvpn

# 备份原 Makefile（可选，但安全）
cp Makefile Makefile.bak

# 移除 conffiles 里的 /etc/config/openvpn （通常在 openvpn-openssl 定义里）
# 用 sed 删除整行或注释掉
sed -i '/conffiles/,/)/ s|/etc/config/openvpn||g' Makefile

# 或者更精确：如果 conffiles 是这样写的
# sed -i '/conffiles/{n;/\/etc\/config\/openvpn/d;}' Makefile   # 删除包含该路径的下一行

# 如果上面不准，用这个粗暴但有效的：完全删除 conffiles 部分（openvpn-openssl 不需要它拥有 config，因为 luci 会处理）
sed -i '/define Package\/openvpn-openssl\/conffiles/,/endef/d' Makefile

# 或者注释掉
# sed -i 's/^define Package\/openvpn-openssl\/conffiles/#&/' Makefile
# sed -i 's/^\/etc\/config\/openvpn/#&/' Makefile
# sed -i 's/^endef/#&/' Makefile

popd

# 同时保留你之前的修改 luci-app-openvpn-server 的部分（rename config 名）
pushd feeds/luci/applications/luci-app-openvpn-server

# 你的原有 sed 命令（确保 LuCI 读 openvpn-server）
find luasrc/ -type f -name "*.lua" -exec sed -i 's/Map("openvpn"/Map("openvpn-server"/g' {} \; || true
find luasrc/ -type f -name "*.lua" -exec sed -i 's/"openvpn"/"openvpn-server"/g' {} \; || true

# 因为上游没 files/，我们手动创建 openvpn-server.init 并安装（可选，但推荐，让服务独立）
mkdir -p files
# 从 packages 复制 openvpn init 并改名
cp ../../packages/net/openvpn/files/openvpn.init files/openvpn-server.init 2>/dev/null || echo "No original init, skipping"

if [ -f files/openvpn-server.init ]; then
  sed -i 's/config_load openvpn/config_load openvpn-server/g' files/openvpn-server.init
  sed -i 's/"openvpn"/"openvpn-server"/g' files/openvpn-server.init
  sed -i 's/openvpn-/openvpn-server-/g' files/openvpn-server.init   # pid, conf 等路径
  sed -i 's/ openvpn / openvpn-server /g' files/openvpn-server.init
fi

popd
