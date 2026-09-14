ccflags-y += -I$(srctree)/drivers/media/dvb-core -I$(srctree)/drivers/media/dvb-frontends

obj-m += rc-core.o
obj-m += dvb-core.o
obj-m += dvb-usb.o
obj-m += dibx000_common.o
obj-m += dib0070.o
obj-m += dib7000p.o
obj-m += lgs8gxx.o
obj-m += mxl5005s.o
obj-m += atbm8830.o
obj-m += max21650.o
obj-m += dvb-usb-cxusb.o

rc-core-objs        := rc_core_mod.o
dvb-core-objs       := core_brain.o
dvb-usb-objs        := cxusb_shell.o
dvb-usb-cxusb-objs  := cxusb_driver_mod.o
dibx000_common-objs := dibx000_mod.o
dib0070-objs        := dib0070_mod.o
dib7000p-objs       := dib7000p_mod.o
lgs8gxx-objs        := lgs8gxx_mod.o
mxl5005s-objs       := mxl5005s_mod.o
atbm8830-objs       := atbm8830_mod.o
max21650-objs       := max21650_mod.o

