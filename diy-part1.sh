#!/bin/bash
set -e

# ============================
# DIY PART 1 — Feeds & Packages
# ============================

# 1️⃣ 更新官方 feeds
cat >feeds.conf.default <<EOF
src-git packages https://git.openwrt.org/feed/packages.git
src-git luci https://git.openwrt.org/project/luci.git
src-git routing https://git.openwrt.org/feed/routing.git
src-git telephony https://git.openwrt.org/feed/telephony.git
EOF

# 更新并安装所有 feeds
./scripts/feeds update -a
./scripts/feeds install -a

# 2️⃣ Clone Emortal / MTK / 必要第三方包到 package/
echo "Cloning third-party packages..."

# Emortal packages
[ ! -d package/emortal ] && git clone https://github.com/immortalwrt/packages-emortal.git package/emortal

# MTK applications
[ ! -d package/mtk-apps ] && git clone https://github.com/ImmortalWrt/immortalwrt-mtk-apps.git package/mtk-apps

# LuCI extra packages (保证 luci-lua-runtime, luci-compat 等存在)
[ ! -d package/luci-extra ] && git clone https://github.com/openwrt/luci.git package/luci-extra

# 3️⃣ Optional: 其他常用依赖库
[ ! -d package/utils ] && mkdir -p package/utils

# pciutils, usbutils, bc, jq, wsdd2 等常用 utils
[ ! -d package/utils/pciutils ] && git clone https://git.openwrt.org/feed/packages.git package/utils/pciutils
[ ! -d package/utils/usbutils ] && git clone https://git.openwrt.org/feed/packages.git package/utils/usbutils
[ ! -d package/utils/jq ] && git clone https://git.openwrt.org/feed/packages.git package/utils/jq
[ ! -d package/utils/bc ] && git clone https://git.openwrt.org/feed/packages.git package/utils/bc
[ ! -d package/utils/wsdd2 ] && git clone https://github.com/OpenWrt/wsdd2.git package/utils/wsdd2

# 4️⃣ 合并你的 config
echo "Merging config files..."
cp ../128m.config .config
[ -f ../my_packages.config ] && cat ../my_packages.config >> .config
make defconfig

echo "DIY PART 1 finished: feeds updated, packages cloned, config merged."
