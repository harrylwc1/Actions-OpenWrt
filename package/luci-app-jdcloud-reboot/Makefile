#
# Copyright (C) 2025 Your Name
#
# This is free software, licensed under the Apache License, Version 2.0.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=luci-app-jdcloud-reboot
PKG_VERSION:=1.0
PKG_RELEASE:=1

PKG_LICENSE:=Apache-2.0
PKG_MAINTAINER:=Your Name <you@example.com>

LUCI_TITLE:=LuCI JDCloud Reboot (A/B slot switcher)
LUCI_DEPENDS:=+luci-base +blkid +sgdisk +u-boot-envtools +coreutils-hexdump +coreutils-strings
LUCI_PKGARCH:=all

include $(INCLUDE_DIR)/package.mk

define Package/luci-app-jdcloud-reboot
	SECTION:=luci
	CATEGORY:=LuCI
	UBMENU:=3. Applications
	TITLE:=LuCI JDCloud Reboot
	DEPENDS:=$(LUCI_DEPENDS)
	PKGARCH:=all
endef

define Package/luci-app-jdcloud-reboot/description
	LuCI app to switch between A/B partitions on JDCloud BE6500.
endef

define Build/Compile
endef

define Package/luci-app-jdcloud-reboot/install
	$(INSTALL_DIR) $(1)/usr/lib/lua/luci/controller
	$(INSTALL_DATA) ./luasrc/controller/jdcloud_reboot.lua $(1)/usr/lib/lua/luci/controller/jdcloud_reboot.lua
	$(INSTALL_DIR) $(1)/usr/lib/lua/luci/model/cbi
	$(INSTALL_DATA) ./luasrc/model/cbi/jdcloud_reboot.lua $(1)/usr/lib/lua/luci/model/cbi/jdcloud_reboot.lua
	$(INSTALL_DIR) $(1)/usr/bin
	$(INSTALL_BIN) ./root/usr/bin/boot_alt.sh $(1)/usr/bin/boot_alt.sh
	$(INSTALL_DIR) $(1)/usr/libexec
	$(INSTALL_BIN) ./root/usr/libexec/jdcloud-reboot $(1)/usr/libexec/jdcloud-reboot
	$(INSTALL_BIN) ./root/usr/libexec/jdcloud-reboot-info $(1)/usr/libexec/jdcloud-reboot-info
	$(INSTALL_DIR) $(1)/usr/share/jdcloud-reboot/devices
	$(INSTALL_DATA) ./root/usr/share/jdcloud-reboot/devices/*.json $(1)/usr/share/jdcloud-reboot/devices/
	$(INSTALL_DIR) $(1)/etc/uci-defaults
	$(INSTALL_BIN) ./root/etc/uci-defaults/99-jdcloud-reboot $(1)/etc/uci-defaults/99-jdcloud-reboot
	$(INSTALL_DIR) $(1)/usr/lib/lua/luci/i18n
	$(CP) ./po/zh_Hant/jdcloud-reboot.zh_Hant.lmo $(1)/usr/lib/lua/luci/i18n/ 2>/dev/null || true
	$(CP) ./po/zh_Hans/jdcloud-reboot.zh_Hans.lmo $(1)/usr/lib/lua/luci/i18n/ 2>/dev/null || true
endef

$(eval $(call BuildPackage,luci-app-jdcloud-reboot))
