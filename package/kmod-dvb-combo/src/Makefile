ccflags-y += -I$(srctree)/drivers/media/dvb-core -I$(srctree)/drivers/media/dvb-frontends

# 定義您的終端 Combo 綜合打包對象
obj-m += dvb-tvstick-combo.o
dvb-tvstick-combo-objs := core_brain.o cxusb_shell.o chips_glue.o

# 宣告並輸出成您清單指定的 11 個獨立且檔名合規的依賴核心模組
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

# 將剛才寫好的核心晶片黏合血管層對應成點分編譯規則
rc-core-objs       := chips_glue.o
dvb-core-objs      := core_brain.o
dvb-usb-objs       := cxusb_shell.o
dvb-usb-cxusb-objs := cxusb_shell.o
dibx000_common-objs:= chips_glue.o
dib0070-objs       := chips_glue.o
dib7000p-objs      := chips_glue.o
lgs8gxx-objs       := chips_glue.o
mxl5005s-objs      := chips_glue.o
atbm8830-objs      := chips_glue.o
max21650-objs      := chips_glue.o

