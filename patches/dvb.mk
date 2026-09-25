#
# Digital Video Broadcasters
#

define KernelPackage/dvb-usb-cxusb
  SUBMENU:=$(DVB_MENU)
  TITLE:=Ultimate CXUSB support (True All-in-One Complete)
  DEPENDS:=+kmod-video-core +kmod-video-videobuf2 +kmod-input-core
  KCONFIG:= \
CONFIG_DVB_CORE \
CONFIG_RC_CORE \
CONFIG_DVB_USB \
CONFIG_DVB_USB_CXUSB \
CONFIG_DVB_DIB7000P \
CONFIG_DVB_DIB0070 \
CONFIG_DVB_ATBM8830 \
CONFIG_DVB_MAX2165 \
CONFIG_DVB_MXL5005S \
CONFIG_DVB_DIBX000_COMMON \
CONFIG_DVB_LGS8GXX
  FILES:= \
$(LINUX_DIR)/drivers/media/dvb-core/dvb-core.ko \
$(LINUX_DIR)/drivers/media/rc/rc-core.ko \
$(LINUX_DIR)/drivers/media/usb/dvb-usb/dvb-usb.ko \
$(LINUX_DIR)/drivers/media/dvb-frontends/dib7000p.ko \
$(LINUX_DIR)/drivers/media/dvb-frontends/atbm8830.ko \
$(LINUX_DIR)/drivers/media/dvb-frontends/lgs8gxx.ko \
$(LINUX_DIR)/drivers/media/dvb-frontends/dibx000_common.ko \
$(LINUX_DIR)/drivers/media/*/dib0070.ko \
$(LINUX_DIR)/drivers/media/*/max2165.ko \
$(LINUX_DIR)/drivers/media/*/mxl5005s.ko \
$(LINUX_DIR)/drivers/media/usb/dvb-usb/dvb-usb-cxusb.ko
  AUTOLOAD:=$(call AutoLoad,90,dvb-core rc-core dvb-usb dibx000_common dib7000p atbm8830 lgs8gxx dib0070 max2165 mxl5005s dvb-usb-cxusb)
endef

define KernelPackage/dvb-usb-cxusb/description
  True Standalone CXUSB package containing dvb-core, rc-core, dvb-usb, dibx000_common, input-core dependencies and all required tuners/demods.
endef

$(eval $(call KernelPackage,dvb-usb-cxusb))
