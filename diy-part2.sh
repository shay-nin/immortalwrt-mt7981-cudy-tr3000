#!/bin/bash
#
# https://github.com/P3TERX/Actions-OpenWrt
# File name: diy-part2.sh
# Description: OpenWrt DIY script part 2 (After Update feeds)
#
# Copyright (c) 2019-2024 P3TERX <https://p3terx.com>
#
# This is free software, licensed under the MIT License.
# See /LICENSE for more information.
#

# Modify default IP (保留原文件的注释状态，如需修改请取消注释)
#sed -i 's/192.168.1.1/192.168.50.5/g' package/base-files/files/bin/config_generate

# Modify default theme (保留原文件的注释状态)
#sed -i 's/luci-theme-bootstrap/luci-theme-argon/g' feeds/luci/collections/luci/Makefile

# Modify hostname (保留原文件的注释状态)
#sed -i 's/OpenWrt/P3TERX-Router/g' package/base-files/files/bin/config_generate

# Enable USB power for Cudy TR3000 by default
sed -i '/modem-power/,/};/{s/gpio-export,output = <1>;/gpio-export,output = <0>;/}' target/linux/mediatek/dts/mt7981b-cudy-tr3000-v1.dtsi

# add date in output file name
sed -i -e '/^IMG_PREFIX:=/i BUILD_DATE := $(shell date +%Y%m%d)' \
       -e '/^IMG_PREFIX:=/ s/\($(SUBTARGET)\)/\1-$(BUILD_DATE)/' include/image.mk

# set ubi to 122M (保留原文件的注释状态)
# sed -i 's/reg = <0x5c0000 0x7000000>;/reg = <0x5c0000 0x7a40000>;/' target/linux/mediatek/dts/mt7981b-cudy-tr3000-v1-ubootmod.dts

# ---------------------------------------------------------
# 1. Remove OpenClash (移除 OpenClash)
# ---------------------------------------------------------
# 删除了原有的下载内核代码
# 强制在配置中禁用 OpenClash，防止它被自动选中
sed -i "/CONFIG_PACKAGE_luci-app-openclash/d" .config
echo "# CONFIG_PACKAGE_luci-app-openclash is not set" >> .config

# ---------------------------------------------------------
# 2. Add Custom Packages (添加自定义插件)
# ---------------------------------------------------------
cat >> .config <<EOF
# --- Themes & Configuration ---
CONFIG_PACKAGE_luci-theme-argon=y
CONFIG_PACKAGE_luci-app-argon-config=y

# --- Terminal ---
CONFIG_PACKAGE_luci-app-ttyd=y
CONFIG_PACKAGE_ttyd=y

# --- Security & IP ID (RKP-IPID) ---
# 注意：请确保在 diy-part1.sh 中下载了 rkp-ipid 和 ua2f 的源码
CONFIG_PACKAGE_kmod-rkp-ipid=y
CONFIG_PACKAGE_ua2f=y

# --- Netfilter & IPtables Modules ---
CONFIG_PACKAGE_iptables-nft=y
CONFIG_PACKAGE_ip6tables-nft=y
CONFIG_PACKAGE_iptables-mod-filter=y
CONFIG_PACKAGE_iptables-mod-ipopt=y
CONFIG_PACKAGE_iptables-mod-u32=y
CONFIG_PACKAGE_iptables-mod-conntrack-extra=y
CONFIG_PACKAGE_kmod-ipt-ipopt=y
CONFIG_PACKAGE_ipset=y
EOF
