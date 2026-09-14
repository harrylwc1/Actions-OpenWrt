#include <linux/module.h>
#include <linux/kernel.h>
#include <linux/usb.h>

MODULE_DESCRIPTION("Custom standalone cxusb registration driver for T230/T230C2 - Kernel 5.4 Fixed");
MODULE_LICENSE("GPL");

extern int dvb_usb_device_init(struct usb_interface *intf, void *props, struct module *owner, void *dev, short *adapter_nums);
extern void dvb_usb_device_exit(struct usb_interface *intf);

static const struct usb_device_id cxusb_table[] = {
        { USB_DEVICE(0x0572, 0x86d6) },
        { USB_DEVICE(0x0572, 0xd811) },
        { }
};
MODULE_DEVICE_TABLE(usb, cxusb_table);

static int custom_cxusb_probe(struct usb_interface *intf, const struct usb_device_id *id) {
        pr_info("dvb-usb-cxusb: Standalone probe active! Found hardware VID: 0x%04x, PID: 0x%04x\n", id->idVendor, id->idProduct);
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

static int __init cxusb_driver_init(void) {
        return usb_register(&custom_cxusb_driver);
}

static void __exit cxusb_driver_exit(void) {
        usb_deregister(&custom_cxusb_driver);
}

module_init(cxusb_driver_init);
module_exit(cxusb_driver_exit);

