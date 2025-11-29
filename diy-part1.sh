#!/bin/bash
# ---------------------------------------------------------
# diy-part1.sh
# ---------------------------------------------------------

# 1. 尝试取消注释 feeds.conf.default 中的所有源 (以防被默认禁用)
sed -i 's/^#\(.*src-git\)/\1/' feeds.conf.default

# 2. 你的自定义插件下载 (保持不变)
git clone https://github.com/jerrykuku/luci-theme-argon.git package/luci-theme-argon
git clone https://github.com/jerrykuku/luci-app-argon-config.git package/luci-app-argon-config
git clone https://github.com/EOYOHOO/rkp-ipid.git package/rkp-ipid
git clone https://github.com/Zxilly/UA2F.git package/UA2F

# 3. 其他原本的插件
git clone https://github.com/eamonxg/luci-theme-aurora package/luci-theme-aurora
git clone https://github.com/timsaya/luci-app-bandix package/luci-app-bandix
git clone https://github.com/timsaya/openwrt-bandix package/openwrt-bandix
