#include <linux/module.h>
#include <linux/kernel.h>
#include <linux/init.h>
#include <linux/usb.h>

MODULE_DESCRIPTION("Unified DVB USB Framework Shell and Function Stub");
MODULE_LICENSE("GPL");

/* 補齊 dvb-usb-cxusb 向上索要的 dvb-usb 核心外殼所有函數符號 */
int dvb_usb_device_init(struct usb_interface *intf, void *props, struct module *owner, void *dev, short *adapter_nums) { return 0; }
EXPORT_SYMBOL(dvb_usb_device_init);

void dvb_usb_device_exit(struct usb_interface *intf) {}
EXPORT_SYMBOL(dvb_usb_device_exit);

int dvb_usb_adapter_stream_init(void *adap) { return 0; }
EXPORT_SYMBOL(dvb_usb_adapter_stream_init);

int dvb_usb_adapter_stream_exit(void *adap) { return 0; }
EXPORT_SYMBOL(dvb_usb_adapter_stream_exit);

int dvb_usb_generic_rw(void *d, u8 *wbuf, u16 wlen, u8 *rbuf, u16 rlen, int delay) { return 0; }
EXPORT_SYMBOL(dvb_usb_generic_rw);

/* 補齊標準內核 USB 傳輸血管 */
void usb_urb_kill(void *stream) {}
EXPORT_SYMBOL(usb_urb_kill);

int usb_urb_submit(void *stream) { return 0; }
EXPORT_SYMBOL(usb_urb_submit);
