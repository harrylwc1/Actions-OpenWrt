#include <linux/module.h>
#include <linux/kernel.h>
#include <linux/init.h>
#include <linux/usb.h>
#include <linux/slab.h>

MODULE_DESCRIPTION("Unified DVB USB Framework Shell - Anti-RC Fixed for MyGica T230/T230C2");
MODULE_AUTHOR("Custom DVB Media Build System");
MODULE_LICENSE("GPL");

int dvb_usb_device_init(struct usb_interface *intf, void *props, struct module *owner, void *dev, short *adapter_nums) {
        dev_info(&intf->dev, "Custom dvb-usb framework skeleton attached safely.\n");
        return 0;
}
EXPORT_SYMBOL(dvb_usb_device_init);

void dvb_usb_device_exit(struct usb_interface *intf) {
        dev_info(&intf->dev, "Custom dvb-usb framework skeleton detached safely.\n");
}
EXPORT_SYMBOL(dvb_usb_device_exit);

int dvb_usb_adapter_stream_init(void *adap) { return 0; }
EXPORT_SYMBOL(dvb_usb_adapter_stream_init);

int dvb_usb_adapter_stream_exit(void *adap) { return 0; }
EXPORT_SYMBOL(dvb_usb_adapter_stream_exit);

int dvb_usb_generic_rw(void *d, u8 *wbuf, u16 wlen, u8 *rbuf, u16 rlen, int delay) { return 0; }
EXPORT_SYMBOL(dvb_usb_generic_rw);

void usb_urb_kill(void *stream) {}
EXPORT_SYMBOL(usb_urb_kill);

int usb_urb_submit(void *stream) { return 0; }
EXPORT_SYMBOL(usb_urb_submit);

/* 💥 主動硬體認領表：精準填入您的兩款電視棒 ID */
static const struct usb_device_id cxusb_table[] = {
        { USB_DEVICE(0x0572, 0x86d6) }, /* MyGica T230 */
        { USB_DEVICE(0x0572, 0xd811) }, /* MyGica T230C2 */
        { }
};
MODULE_DEVICE_TABLE(usb, cxusb_table);

static int custom_cxusb_probe(struct usb_interface *intf, const struct usb_device_id *id) {
        pr_info("dvb-usb-cxusb: Probe triggered for device VID: 0x%04x, PID: 0x%04x\n", id->idVendor, id->idProduct);
        usb_set_intfdata(intf, (void *)id);
        return dvb_usb_device_init(intf, NULL, THIS_MODULE, NULL, NULL);
}

static void custom_cxusb_disconnect(struct usb_interface *intf) {
        dvb_usb_device_exit(intf);
        usb_set_intfdata(intf, NULL);
}

static struct usb_driver custom_cxusb_driver = {
        .name       = "dvb-usb-cxusb",
        .probe      = custom_cxusb_probe,
        .disconnect = custom_cxusb_disconnect,
        .id_table   = cxusb_table,
};

static int __init cxusb_shell_init(void) { return usb_register(&custom_cxusb_driver); }
static void __exit cxusb_shell_exit(void) { usb_deregister(&custom_cxusb_driver); }
module_init(cxusb_shell_init);
module_exit(cxusb_shell_exit);

