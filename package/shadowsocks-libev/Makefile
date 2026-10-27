#
# Copyright (C) 2017-2020 Yousong Zhou <yszhou4tech@gmail.com>
# Copyright (C) 2026 Shadowsocks Authors
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

# 保留舊名稱以兼容你現有的 .config 配置
PKG_NAME:=shadowsocks-libev
PKG_VERSION:=3.3.6
PKG_RELEASE:=1

# 使用 Git 拉取源碼（包含完整的第三方依賴目錄）
PKG_SOURCE_PROTO:=git
PKG_SOURCE_URL:=https://github.com
PKG_SOURCE_VERSION:=v$(PKG_VERSION)
PKG_MIRROR_HASH:=skip

PKG_MAINTAINER:=Shadowsocks Authors
PKG_LICENSE:=GPL-3.0-or-later
PKG_LICENSE_FILES:=LICENSE

PKG_BUILD_PARALLEL:=1

include $(INCLUDE_DIR)/package.mk
include $(INCLUDE_DIR)/cmake.mk

# 保留此定義以相容舊的相依性，但我們不單獨打包它
define Package/shadowsocks-libev-config
  SECTION:=net
  CATEGORY:=Network
  SUBMENU:=Web Servers/Proxies
  TITLE:=shadowsocks-libev config scripts (Dummy)
  URL:=https://github.com
endef

define Package/shadowsocks-libev/Default
  define Package/shadowsocks-libev-$(1)
    SECTION:=net
    CATEGORY:=Network
    SUBMENU:=Web Servers/Proxies
    TITLE:=shadowsocks-libev $(1)
    URL:=https://github.com
    # 補全所有可能被動態連結的庫，移除對外部 config 套件的依賴
    DEPENDS:=+libpthread +libev +libmbedtls +libsodium +libpcre2 +libudns +libcares +zlib $(DEPENDS_$(1))
  endef

  define Package/shadowsocks-libev-$(1)/install
	$$(INSTALL_DIR) $$(1)/usr/bin
	$$(INSTALL_BIN) $$(PKG_INSTALL_DIR)/usr/bin/$(1) $$(1)/usr/bin
	
	# 【核心修正】：讓每個獨立的二進制組件安裝時，都順便塞入啟動腳本與設定檔
	$$(INSTALL_DIR) $$(1)/etc/config
	$$(INSTALL_DATA) ./files/shadowsocks-libev.config $$(1)/etc/config/shadowsocks-libev
	$$(INSTALL_DIR) $$(1)/etc/init.d
	$$(INSTALL_BIN) ./files/shadowsocks-libev.init $$(1)/etc/init.d/shadowsocks-libev
  endef
endef

SHADOWSOCKS_COMPONENTS:=ss-local ss-redir ss-tunnel ss-server
define shadowsocks-libev/templates
  $(foreach component,$(SHADOWSOCKS_COMPONENTS),
    $(call Package/shadowsocks-libev/Default,$(component))
  )
endef
$(eval $(call shadowsocks-libev/templates))


define Package/shadowsocks-libev-ss-rules
  SECTION:=net
  CATEGORY:=Network
  SUBMENU:=Web Servers/Proxies
  TITLE:=shadowsocks-libev ss-rules
  URL:=https://github.com
  DEPENDS:=+ip +ipset +iptables-mod-tproxy +resolveip +shadowsocks-libev-ss-redir
endef

define Package/shadowsocks-libev-ss-rules/install
	$(INSTALL_DIR) $(1)/usr/bin
	$(INSTALL_BIN) ./files/ss-rules $(1)/usr/bin
	$(INSTALL_DIR) $(1)/etc/uci-defaults
	$(INSTALL_DATA) ./files/firewall.ss-rules $(1)/etc
	$(INSTALL_BIN) ./files/ss-rules.defaults $(1)/etc/uci-defaults
endef

# CMake 編譯參數
CMAKE_OPTIONS += \
        -DSS_BUILD_EXECUTABLES=ON \
        -DWITH_EMBEDDED_SRC=ON \
        -DWITH_STATIC=OFF \
        -DWITH_DOC_MAN=OFF \
        -DWITH_DOC_HTML=OFF \
        -DSS_MINIMAL=OFF

TARGET_CFLAGS += -flto
TARGET_LDFLAGS += -Wl,--gc-sections,--as-needed

$(eval $(call BuildPackage,shadowsocks-libev-ss-rules))
$(foreach component,$(SHADOWSOCKS_COMPONENTS), \
  $(eval $(call BuildPackage,shadowsocks-libev-$(component))) \
)

