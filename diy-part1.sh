#!/bin/bash
# ---------------------------------------------------------
# diy-part1.sh
# ---------------------------------------------------------

# 1. 【关键】删除原有配置中的 telephony (电话服务) 源
# 这行命令会在 feeds.conf.default 文件中找到包含 telephony 的行并直接删除
sed -i '/telephony/d' feeds.conf.default

# 2. 尝试取消注释其他所有源 (确保 packages, luci, routing 能被正常使用)
sed -i 's/^#\(.*src-git\)/\1/' feeds.conf.default

# 3. 下载你的自定义插件
# Argon 主题与配置
git clone https://github.com/jerrykuku/luci-theme-argon.git package/luci-theme-argon
git clone https://github.com/jerrykuku/luci-app-argon-config.git package/luci-app-argon-config

# RKP-IPID (必须配合 UA2F)
git clone https://github.com/EOYOHOO/rkp-ipid.git package/rkp-ipid
git clone https://github.com/Zxilly/UA2F.git package/UA2F

# 其他插件
git clone https://github.com/eamonxg/luci-theme-aurora package/luci-theme-aurora
git clone https://github.com/timsaya/luci-app-bandix package/luci-app-bandix
git clone https://github.com/timsaya/openwrt-bandix package/openwrt-bandix
