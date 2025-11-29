#!/bin/bash
# ---------------------------------------------------------
# diy-part1.sh: 核弹级修复 - 重建所有软件源
# ---------------------------------------------------------

# 1. 【清空】删除可能损坏的默认配置
rm -f feeds.conf.default

# 2. 【重建】写入标准的 ImmortalWrt 官方源 (去掉不用的 telephony)
# 使用 cat EOF 确保文件内容绝对正确，不受原文件影响
cat > feeds.conf.default <<EOF
src-git packages https://github.com/immortalwrt/packages.git
src-git luci https://github.com/immortalwrt/luci.git
src-git routing https://github.com/immortalwrt/routing.git
src-git systems https://github.com/immortalwrt/packages.git
EOF

# 3. 【插件】下载你需要的自定义插件
# Argon 主题与配置
git clone https://github.com/jerrykuku/luci-theme-argon.git package/luci-theme-argon
git clone https://github.com/jerrykuku/luci-app-argon-config.git package/luci-app-argon-config

# RKP-IPID (必须配合 UA2F)
git clone https://github.com/EOYOHOO/rkp-ipid.git package/rkp-ipid
git clone https://github.com/Zxilly/UA2F.git package/UA2F

# 其他自定义包
git clone https://github.com/eamonxg/luci-theme-aurora package/luci-theme-aurora
git clone https://github.com/timsaya/luci-app-bandix package/luci-app-bandix
git clone https://github.com/timsaya/openwrt-bandix package/openwrt-bandix

# 4. 【验证】打印一下文件内容，方便在日志里检查
echo "=== 当前使用的 feeds.conf.default 内容如下 ==="
cat feeds.conf.default
echo "================================================"
