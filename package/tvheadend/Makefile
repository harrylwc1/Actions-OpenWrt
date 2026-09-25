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
# 每次 commit 都不同，哈希无法固定，跳过校验
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

# 修复 1：不再复制不存在的 files/.git
# 改为在源码目录里初始化 git，打 annotated tag（git describe 只认 annotated tag）
# 并把当次 commit 的 short hash 写入 .tvh_commit，供 Build/Compile 使用
define Build/Prepare
	$(call Build/Prepare/Default)
	cd $(PKG_BUILD_DIR) && \
		git init -q && \
		git config user.email "build@openwrt.local" && \
		git config user.name "OpenWrt Build" && \
		git add -A && \
		git commit -q -m "OpenWrt build" && \
		git tag -a "v$(PKG_VERSION)" -m "version v$(PKG_VERSION)" && \
		git rev-parse --short HEAD > .tvh_commit
endef

# 修复 2：Build/Compile 里写死 version.c，格式 4.3~g<short>
# 去掉 "+make" 的 "+"（在 define 块里 '+' 会被当字面字符传给 shell）
# 用 $$TVH_SHORT 让 shell 在运行时读取 .tvh_commit
define Build/Compile
	TVH_SHORT=$$(cat $(PKG_BUILD_DIR)/.tvh_commit); \
	printf 'const char *tvheadend_version = "%s~g%s";\n' \
		"$(PKG_VERSION)" "$$TVH_SHORT" > $(PKG_BUILD_DIR)/src/version.c; \
	chmod 444 $(PKG_BUILD_DIR)/src/version.c; \
	$(MAKE) -C $(PKG_BUILD_DIR) \
		$(TARGET_CONFIGURE_OPTS) \
		$(PKG_MAKE_FLAGS)
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

$(eval $(call BuildPackage,tvheadend))
