#!/bin/bash
#
# diy-part1.sh — OpenWrt / ImmortalWrt 自定义包合并脚本
# 兼容 GitHub Actions
#

set -e

# ========================
# 1️⃣ 设置源码目录
# ========================
ROOT_DIR="$(pwd)"
OPENWRT_DIR="$ROOT_DIR/openwrt"
CONFIG_DIR="$ROOT_DIR/config"
MY_PACKAGES="$ROOT_DIR/my_packages.config"
CUSTOM_CONFIG="$CONFIG_DIR/128m.config"

if [ ! -d "$OPENWRT_DIR" ]; then
    echo "❌ OpenWrt source directory not found at $OPENWRT_DIR"
    exit 1
fi

cd "$OPENWRT_DIR"
echo "📁 Entered OpenWrt source directory: $PWD"

# ========================
# 2️⃣ 添加官方 feeds（防止缺失依赖）
# ========================
FEEDS_FILE="$OPENWRT_DIR/feeds.conf.default"

if ! grep -q "packages.git" "$FEEDS_FILE"; then
    echo "🔧 Adding official feeds..."
    cat <<EOF >> "$FEEDS_FILE"
src-git packages https://git.openwrt.org/feed/packages.git
src-git luci https://git.openwrt.org/project/luci.git
src-git routing https://git.openwrt.org/feed/routing.git
src-git telephony https://git.openwrt.org/feed/telephony.git
EOF
fi

# ========================
# 3️⃣ 更新并安装 feeds
# ========================
echo "🔄 Updating and installing feeds..."
./scripts/feeds update -a
./scripts/feeds install -a

# ========================
# 4️⃣ 合并自定义 package fragment
# ========================
if [ -f "$MY_PACKAGES" ]; then
    echo "📦 Merging custom package config fragment from $MY_PACKAGES"
    cat "$MY_PACKAGES" >> .config
else
    echo "⚠️ Warning: my_packages.config not found — skipping"
fi

# ========================
# 5️⃣ 合并自定义 config
# ========================
if [ -f "$CUSTOM_CONFIG" ]; then
    echo "⚙️ Merging custom config from $CUSTOM_CONFIG"
    cat "$CUSTOM_CONFIG" >> .config
else
    echo "⚠️ Warning: custom config not found — skipping"
fi

# ========================
# 6️⃣ 运行 defconfig
# ========================
echo "⚙️ Running defconfig..."
yes "" | make defconfig

# ========================
# 7️⃣ Clone 第三方包（可根据需要增删）
# ========================
echo "📥 Cloning third-party packages..."

# Emortal packages
git clone https://github.com/eamonxg/luci-theme-aurora package/luci-theme-aurora || true
git clone https://github.com/timsaya/luci-app-bandix package/luci-app-bandix || true
git clone https://github.com/timsaya/openwrt-bandix package/openwrt-bandix || true

# MTK applications
git clone https://github.com/ImmortalWrt/immortalwrt-mtk-apps.git package/mtk-apps || true

echo "✅ diy-part1.sh completed successfully!"
