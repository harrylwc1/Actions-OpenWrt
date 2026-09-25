#
# Copyright (C) 2015 OpenWrt.org
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=tvheadend
PKG_VERSION:=4.3
PKG_RELEASE:=$(AUTORELEASE)

PKG_SOURCE_SUBDIR:=$(PKG_NAME)
PKG_SOURCE_PROTO:=git
PKG_SOURCE_URL:=https://github.com/tvheadend/tvheadend.git

# 跟随 master 最新 commit
PKG_SOURCE_VERSION:=master
# 由于每次 commit 都不同，哈希无法固定，跳过校验
PKG_MIRROR_HASH:=skip
PKG_SOURCE:=$(PKG_NAME)-$(PKG_SOURCE_VERSION).tar.gz

PKG_BUILD_DIR:=$(BUILD_DIR)/$(PKG_NAME)

PKG_BUILD_PARALLEL:=1
PKG_INSTALL:=1

PKG_LICENSE:=GPL-3.0
PKG_LICENSE_FILES:=LICENSE.md

PKG_FIXUP:=autoreconf
PKG_USE_MIPS16:=0

include $(INCLUDE_DIR)/package.mk
include $(INCLUDE_DIR)/nls.mk

define Package/tvheadend
  SECTION:=multimedia
  CATEGORY:=Multimedia
  TITLE:=Tvheadend is a TV streaming server for Linux
  DEPENDS:=+libdvbcsa +libvpx +libvorbis +libtheora +libopusenc +fdk-aac +libffmpeg +ffmpeg +libx264 +libpcre2 +libopenssl +librt +zlib +TVHEADEND_AVAHI_SUPPORT:libavahi-client $(ICONV_DEPENDS)
  URL:=https://tvheadend.org
  MAINTAINER:=CZ.NIC <packaging@turris.cz>
endef

define Package/tvheadend/description
  Tvheadend is a TV streaming server and recorder for Linux, FreeBSD and Android
  supporting DVB-S, DVB-S2, DVB-C, DVB-T, ATSC, IPTV, SAT>IP and HDHomeRun as input sources.

  Tvheadend offers the HTTP (VLC, MPlayer), HTSP (Kodi, Movian) and SAT>IP streaming.
endef

define Package/tvheadend/config
  menu "Configuration"
  depends on PACKAGE_tvheadend
  source "$(SOURCE)/Config.in"
  endmenu
endef

ifeq ($(CONFIG_BUILD_NLS),y)
  ifeq ($(CONFIG_TVHEADEND_ENABLE_BUNDLE),y)
    CONFIGURE_ARGS += --enable-bundle
    TARGET_LDFLAGS += $(if $(ICONV_FULL),-liconv)
  endif
endif

ifeq ($(CONFIG_TVHEADEND_CWC_SUPPORT),)
  CONFIGURE_ARGS += --disable-cwc
endif

ifeq ($(CONFIG_TVHEADEND_LINUXDVB_SUPPORT),)
  CONFIGURE_ARGS += --disable-linuxdvb
endif

ifeq ($(CONFIG_TVHEADEND_DVBSCAN_SUPPORT),)
  CONFIGURE_ARGS += --disable-dvbscan
endif

ifeq ($(CONFIG_TVHEADEND_AVAHI_SUPPORT),)
  CONFIGURE_ARGS += --disable-avahi
else
  CONFIGURE_ARGS += --enable-avahi
endif

ifeq ($(CONFIG_TVHEADEND_DVBCSA_SUPPORT),)
else
  CONFIGURE_ARGS += --enable-dvbcsa --disable-tvhcsa
endif
ifeq ($(CONFIG_DISABLE_TVHCSA_DVBCSA_SUPPORT),)
else
  CONFIGURE_ARGS += --disable-dvbcsa --disable-tvhcsa
endif

ifeq ($(CONFIG_DISABLE_TVHEADEND_FULL_SUPPORT),)
else
  CONFIGURE_ARGS += --disable-libav --disable-dbus_1 --disable-capmt --disable-constcw --disable-iptv --disable-satip_server --disable-satip_client --disable-imagecache --disable-uriparser --disable-libx264 --disable-libx264_static --disable-libmfx_static --disable-libx265_static --disable-hdhomerun_client --disable-hdhomerun_static --disable-cwc --disable-cccam
endif

CONFIGURE_ARGS += \
	--arch=$(ARCH) \
	--disable-dbus_1 \
	--disable-libx264_static \
	--disable-ffmpeg_static \
	--disable-libx265 \
	--disable-hdhomerun \
	--enable-libx265_static \
	--disable-vue_build \
	--enable-vue_bundle \
	--disable-execinfo

TARGET_CFLAGS += -Wno-format-security -Wno-error=array-bounds -Wno-error=address

# 关键修复：不再复制 files/.git，改为在解压后的源码目录初始化 git 仓库
# 这样 git describe / 版本号生成逻辑仍可正常工作
define Build/Prepare
	$(call Build/Prepare/Default)
	cd $(PKG_BUILD_DIR) && \
		git init -q && \
		git add -A && \
		git -c user.email=build@local -c user.name=build commit -q -m "OpenWrt build" && \
		git tag -a "$(PKG_SOURCE_VERSION)" -m "version $(PKG_SOURCE_VERSION)" || true
endef

define Package/conffiles
/etc/config/tvheadend
endef

define Package/tvheadend/install
	$(INSTALL_DIR) $(1)/etc/init.d
	$(INSTALL_BIN) ./files/tvheadend.init $(1)/etc/init.d/tvheadend
	$(INSTALL_DIR) $(1)/etc/config
	$(INSTALL_CONF) ./files/tvheadend.config $(1)/etc/config/tvheadend

	$(MAKE) -C $(PKG_BUILD_DIR) install DESTDIR=$(1)
endef

$(eval $(call BuildPackage,tvheadend)):
