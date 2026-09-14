include $(TOPDIR)/rules.mk
include $(INCLUDE_DIR)/kernel.mk

PKG_NAME:=dvb-tvstick-combo
PKG_RELEASE:=1

include $(INCLUDE_DIR)/package.mk

define Package/dvb-tvstick-combo
  SECTION:=kernel
  CATEGORY:=Kernel modules
  SUBMENU:=Video Support
  TITLE:=Unified DVB TV Stick Hardware and RC Intercept Module
  FILES:= \
        $(PKG_BUILD_DIR)/rc-core.ko \
        $(PKG_BUILD_DIR)/dvb-core.ko \
        $(PKG_BUILD_DIR)/dvb-usb.ko \
        $(PKG_BUILD_DIR)/dibx000_common.ko \
        $(PKG_BUILD_DIR)/dib0070.ko \
        $(PKG_BUILD_DIR)/dib7000p.ko \
        $(PKG_BUILD_DIR)/lgs8gxx.ko \
        $(PKG_BUILD_DIR)/mxl5005s.ko \
        $(PKG_BUILD_DIR)/atbm8830.ko \
        $(PKG_BUILD_DIR)/max21650.ko \
        $(PKG_BUILD_DIR)/dvb-usb-cxusb.ko
  DEPENDS:=+kmod-usb-core
endef

define Package/dvb-tvstick-combo/description
  Unified DVB Core Framework, USB Shell, Hardware Chips Glue Layer, and 100% Anti-RC protection for BE6500.
endef

define Build/Prepare
        mkdir -p $(PKG_BUILD_DIR)
        $(CP) ./src/* $(PKG_BUILD_DIR)/
endef

define Build/Compile
        $(MAKE) -C "$(LINUX_DIR)" \
                $(KERNEL_MAKE_FLAGS) \
                M="$(PKG_BUILD_DIR)" \
                modules
endef

define Package/dvb-tvstick-combo/install
        $(INSTALL_DIR) $(1)/lib/modules/$(LINUX_VERSION)
        $(INSTALL_BIN) $(PKG_BUILD_DIR)/rc-core.ko $(1)/lib/modules/$(LINUX_VERSION)/
        $(INSTALL_BIN) $(PKG_BUILD_DIR)/dvb-core.ko $(1)/lib/modules/$(LINUX_VERSION)/
        $(INSTALL_BIN) $(PKG_BUILD_DIR)/dvb-usb.ko $(1)/lib/modules/$(LINUX_VERSION)/
        $(INSTALL_BIN) $(PKG_BUILD_DIR)/dibx000_common.ko $(1)/lib/modules/$(LINUX_VERSION)/
        $(INSTALL_BIN) $(PKG_BUILD_DIR)/dib0070.ko $(1)/lib/modules/$(LINUX_VERSION)/
        $(INSTALL_BIN) $(PKG_BUILD_DIR)/dib7000p.ko $(1)/lib/modules/$(LINUX_VERSION)/
        $(INSTALL_BIN) $(PKG_BUILD_DIR)/lgs8gxx.ko $(1)/lib/modules/$(LINUX_VERSION)/
        $(INSTALL_BIN) $(PKG_BUILD_DIR)/mxl5005s.ko $(1)/lib/modules/$(LINUX_VERSION)/
        $(INSTALL_BIN) $(PKG_BUILD_DIR)/atbm8830.ko $(1)/lib/modules/$(LINUX_VERSION)/
        $(INSTALL_BIN) $(PKG_BUILD_DIR)/max21650.ko $(1)/lib/modules/$(LINUX_VERSION)/
        $(INSTALL_BIN) $(PKG_BUILD_DIR)/dvb-usb-cxusb.ko $(1)/lib/modules/$(LINUX_VERSION)/
endef

$(eval $(call BuildPackage,dvb-tvstick-combo))

