# ==================== 修复 luci-app-openvpn-server 与 openvpn-openssl 的 /etc/config/openvpn 冲突 ====================

echo "=== Fixing luci-app-openvpn-server conflict with openvpn-openssl ==="

pushd feeds/luci/applications/luci-app-openvpn-server || { echo "Directory not found, skipping"; popd; }

# 1. 如果有 root/ 或 files/ 里的 /etc/config/openvpn，直接删掉或重命名（最直接解决覆盖）
if [ -f ./root/etc/config/openvpn ] || [ -d ./root/etc/config ]; then
  rm -f ./root/etc/config/openvpn 2>/dev/null
  echo "Removed root/etc/config/openvpn"
fi

if [ -f ./files/openvpn.config ] || [ -f ./files/openvpn ]; then
  rm -f ./files/openvpn* 2>/dev/null
  echo "Removed files/openvpn*"
fi

# 2. 强制 Makefile 不安装任何 config（如果有 INSTALL_CONF 相关行）
sed -i '/INSTALL_CONF.*openvpn/d' Makefile 2>/dev/null || true
sed -i '/etc\/config\/openvpn/d' Makefile 2>/dev/null || true

# 3. 改 UCI config 名为 openvpn-server（让 LuCI 读正确的文件）
# 查找所有 .lua 文件，替换 Map("openvpn" → Map("openvpn-server"
find . -type f -name "*.lua" -exec sed -i 's/Map("openvpn"/Map("openvpn-server"/g' {} + 2>/dev/null || true
find . -type f -name "*.lua" -exec sed -i 's/"openvpn"/"openvpn-server"/g' {} + 2>/dev/null || true

# 4. 添加独立的 init 脚本（上游 luci-app 没自带，但我们可以从 packages 借用并改名）
mkdir -p files 2>/dev/null
cp ../../packages/net/openvpn/files/openvpn.init files/openvpn-server.init 2>/dev/null || echo "No original openvpn.init found"

if [ -f files/openvpn-server.init ]; then
  sed -i 's/config_load openvpn/config_load openvpn-server/g' files/openvpn-server.init
  sed -i 's/"openvpn"/"openvpn-server"/g' files/openvpn-server.init
  sed -i 's/openvpn-/openvpn-server-/g' files/openvpn-server.init   # pid/conf/log 路径避免冲突
  sed -i 's/ openvpn / openvpn-server /g' files/openvpn-server.init
  echo "Created and modified openvpn-server.init"
fi

# 5. 如果 Makefile 有 install init 为 openvpn，改成 openvpn-server
sed -i 's/openvpn.init/openvpn-server.init/g' Makefile 2>/dev/null || true
sed -i 's|/etc/init.d/openvpn|/etc/init.d/openvpn-server|g' Makefile 2>/dev/null || true

popd

# 可选：如果上面还不行，移除 openvpn-openssl 的 conffiles 拥有权（备用方案）
pushd feeds/packages/net/openvpn || { echo "openvpn Makefile not found"; popd; }
sed -i '/conffiles/,/endef/ s|/etc/config/openvpn||g' Makefile 2>/dev/null || true
sed -i '/\/etc\/config\/openvpn/d' Makefile 2>/dev/null || true
popd

echo "=== OpenVPN conflict fix applied ==="
