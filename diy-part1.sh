#!/bin/bash
#
# diy-part1.sh — 极简修复版 (只保留核心源，避免 find 报错)
#

set -e

# 1. 切换到 OpenWrt 源码目录
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
OPENWRT_DIR="$SCRIPT_DIR/openwrt"

if [ ! -d "$OPENWRT_DIR" ]; then
    echo "❌ OpenWrt source directory not found at $OPENWRT_DIR"
    exit 1
fi

cd "$OPENWRT_DIR"
echo "📁 Entered OpenWrt source directory: $PWD"

# 2. 【核心修复】重写 feeds.conf.default
# 剔除 telephony 和 routing，因为它们导致了 'No such file' 错误
# 只保留 packages (含 libpam, lm-sensors) 和 luci (含 luci-compat)
echo "🔥 Rewriting feeds.conf.default (Minimal Mode)..."
rm -f feeds.conf.default

# 使用 ImmortalWrt 的 packages 和 luci 源
cat > feeds.conf.default <<EOF
src-git packages https://github.com/immortalwrt/packages.git
src-git luci https://github.com/immortalwrt/luci.git
EOF

echo "📄 New feeds.conf.default content:"
cat feeds.conf.default

# 3. 下载自定义插件
echo "📥 Cloning custom packages..."
function git_clone_path() {
    local url=$1
    local dir=$2
    if [ ! -d "$dir" ]; then
        git clone --depth 1 "$url" "$dir"
        echo "✅ Cloned $dir"
    else
        echo "⚠️ $dir already exists, skipping..."
    fi
}

git_clone_path "https://github.com/eamonxg/luci-theme-aurora" "package/luci-theme-aurora"
git_clone_path "https://github.com/timsaya/luci-app-bandix" "package/luci-app-bandix"
git_clone_path "https://github.com/timsaya/openwrt-bandix" "package/openwrt-bandix"

# 4. 更新并安装 Feeds
echo "🔄 Updating and installing feeds..."
# 清理旧数据
rm -rf feeds/ packages/feeds/ tmp/

# 更新源 (使用 || true 防止因网络波动导致的脚本中断)
./scripts/feeds update -a || echo "⚠️ Feeds update had some warnings, continuing..."

# 安装源
./scripts/feeds install -a

# 5. 【双重保险】强制安装缺失的核心依赖
# 你的报错日志中缺少的主要是这些
echo "💉 Ensuring core dependencies are installed..."
for pkg in libpam libtirpc lm-sensors pciutils usbutils luci-compat luci-lib-jsonc; do
    ./scripts/feeds install $pkg || echo "⚠️ Failed to install $pkg, hoping it's already there."
done

# 6. 合并自定义配置
PKG_FRAGMENT="$SCRIPT_DIR/my_packages.config"
if [ -f "$PKG_FRAGMENT" ]; then
    echo "📦 Merging custom package config..."
    cat "$PKG_FRAGMENT" >> .config
fi

# 7. 生成配置
echo "⚙️ Running defconfig..."
make defconfig

echo "✅ diy-part1.sh completed!"
