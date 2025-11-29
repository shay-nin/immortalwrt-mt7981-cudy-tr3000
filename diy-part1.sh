#!/bin/bash
#
# https://github.com/P3TERX/Actions-OpenWrt
# File name: diy-part1.sh
# Description: OpenWrt DIY script part 1 (Before Update feeds)
#
# Copyright (c) 2019-2024 P3TERX <https://p3terx.com>
#
# This is free software, licensed under the MIT License.
# See /LICENSE for more information.
#

# Uncomment a feed source
#sed -i 's/^#\(.*helloworld\)/\1/' feeds.conf.default

# Add a feed source
#echo 'src-git helloworld https://github.com/fw876/helloworld' >>feeds.conf.default
#echo 'src-git passwall https://github.com/xiaorouji/openwrt-passwall' >>feeds.conf.default

git clone https://github.com/eamonxg/luci-theme-aurora package/luci-theme-aurora
git clone https://github.com/timsaya/luci-app-bandix package/luci-app-bandix
git clone https://github.com/timsaya/openwrt-bandix package/openwrt-bandix

# ---------------------------------------------------------
# 补充缺失的依赖源 (Fix missing dependencies)
# ---------------------------------------------------------

# 1. 添加 Argon Config (配置 Argon 主题的工具)
# 注意：它通常依赖 luci-theme-argon，ImmortalWrt 通常自带该主题，所以只需加 Config 工具
git clone https://github.com/jerrykuku/luci-app-argon-config.git package/luci-app-argon-config

# 2. 添加 kmod-rkp-ipid (用于修改 IPID，防检测常用)
# 这个包通常不在官方源里，需要从第三方仓库拉取
# 这里使用的是适配较新的仓库，如果编译失败，可能需要换其他 fork
git clone https://github.com/EOYOHOO/rkp-ipid.git package/rkp-ipid

# 3. (可选) 如果编译报错缺少 UA2F (User Agent 修改)，rkp-ipid 常与它配合使用
# git clone https://github.com/Zxilly/UA2F.git package/UA2F

# 4. 确保 iptables 扩展模块能被找到
# 大部分 iptables-mod-* 都在官方源码中，但如果找不到，可以尝试添加 kenzok8 的源
# 警告：添加大型第三方源可能会导致依赖冲突，建议优先尝试上面的单独 git clone
# echo 'src-git small https://github.com/kenzok8/small' >> feeds.conf.default
