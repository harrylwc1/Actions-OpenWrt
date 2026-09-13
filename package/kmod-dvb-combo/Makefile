include $(TOPDIR)/rules.mk
include $(INCLUDE_DIR)/kernel.mk

PKG_NAME:=dvb-tvstick-combo
PKG_RELEASE:=1

include $(INCLUDE_DIR)/package.mk

define KernelPackage/dvb-tvstick-combo
  SUBMENU:=Video Support
  TITLE:=Unified DVB TV Stick Hardware and RC Intercept Module
  FILES:=$(PKG_BUILD_DIR)/dvb-tvstick-combo.ko
  AUTOLOAD:=$(call AutoLoad,90,dvb-tvstick-combo)
  DEPENDS:=+kmod-usb-core
endef

define KernelPackage/dvb-tvstick-combo/description
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

$(eval $(call KernelPackage,dvb-tvstick-combo))
