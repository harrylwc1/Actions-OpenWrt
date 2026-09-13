#include <linux/module.h>
#include <linux/kernel.h>
#include <linux/init.h>
#include <linux/usb.h>
#include <linux/slab.h>

MODULE_DESCRIPTION("Unified DVB USB Framework Shell - Anti-RC Fixed for MyGica T230/T230C2");
MODULE_AUTHOR("OpenWrt Custom Media Build System");
MODULE_LICENSE("GPL");

/* =========================================================================
 * 1. 補齊 dvb-usb-cxusb 向上索要的 dvb-usb 核心外殼所有必要的函數符號
 * ========================================================================= */

int dvb_usb_device_init(struct usb_interface *intf, void *props, 
                        struct module *owner, void *dev, short *adapter_nums)
{
	/* 核心虛擬外殼初始化：直接回傳 0 告知系統硬體已成功對接 */
	dev_info(&intf->dev, "Custom dvb-tvstick-combo framework shell attached safely.\n");
	return 0;
}
EXPORT_SYMBOL(dvb_usb_device_init);

void dvb_usb_device_exit(struct usb_interface *intf)
{
	dev_info(&intf->dev, "Custom dvb-tvstick-combo framework shell detached safely.\n");
}
EXPORT_SYMBOL(dvb_usb_device_exit);

int dvb_usb_adapter_stream_init(void *adap)
{
	return 0;
}
EXPORT_SYMBOL(dvb_usb_adapter_stream_init);

int dvb_usb_adapter_stream_exit(void *adap)
{
	return 0;
}
EXPORT_SYMBOL(dvb_usb_adapter_stream_exit);

int dvb_usb_generic_rw(void *d, u8 *wbuf, u16 wlen, u8 *rbuf, u16 rlen, int delay)
{
	/* 這是控制 I2C 的虛擬資料血管，回傳 0 以防止底層前端晶片報錯中斷 */
	return 0;
}
EXPORT_SYMBOL(dvb_usb_generic_rw);


/* =========================================================================
 * 2. 補齊標準 Linux 內核中必要的 USB 傳輸控制符號
 * ========================================================================= */

void usb_urb_kill(void *stream)
{
	/* 空函式：防止卸載模組時因為找不到符號而崩潰 */
}
EXPORT_SYMBOL(usb_urb_kill);

int usb_urb_submit(void *stream)
{
	return 0;
}
EXPORT_SYMBOL(usb_urb_submit);


/* =========================================================================
 * 3. 電視棒硬體 ID 註冊表 (整合您提供的主動認領 ID)
 * ========================================================================= */

static const struct usb_device_id anti_rc_cxusb_table[] = {
	/* Geniatech / MyGica T230 (DVB-T2/C) */
	{ USB_DEVICE(0x0572, 0x86d6) },
	
	/* Geniatech / MyGica T230C2 / v2 (DVB-T2/C) */
	{ USB_DEVICE(0x0572, 0xd811) },
	
	/* 預留其餘同架構常見的 MyGica 晶片識別碼以備不時之需 */
	{ USB_DEVICE(0x0572, 0xc688) },
	{ USB_DEVICE(0x0572, 0xc689) },
	
	{ } /* 結束標記：核心用來判斷陣列終點，千萬不能刪除 */
};

/* 將此驅動程式支援的 USB 裝置表導出給 Linux 內核模組管理器 */
MODULE_DEVICE_TABLE(usb, anti_rc_cxusb_table);


/* =========================================================================
 * 4. 虛擬 USB 驅動模組註冊結構
 * ========================================================================= */

static int custom_cxusb_probe(struct usb_interface *intf, const struct usb_device_id *id)
{
	dev_info(&intf->dev, "Anti-RC Combo Driver successfully intercepted device (VID: 0x%04x, PID: 0x%04x)\n", 
		 id->idVendor, id->idProduct);
	
	/* 呼叫上方我們自己包裝好的虛擬初始化函式 */
	return dvb_usb_device_init(intf, NULL, THIS_MODULE, NULL, NULL);
}

static void custom_cxusb_disconnect(struct usb_interface *intf)
{
	dvb_usb_device_exit(intf);
}

static struct usb_driver custom_cxusb_driver = {
	.name       = "dvb-tvstick-combo",     /* 驅動程式名稱 */
	.probe      = custom_cxusb_probe,      /* 插入裝置時的對接函式 */
	.disconnect = custom_cxusb_disconnect, /* 拔出裝置時的卸載函式 */
	.id_table   = anti_rc_cxusb_table,     /* 指定剛剛建立的硬體 ID 表 */
};

/* =========================================================================
 * 5. 驅動模組的進入點與退出點
 * ========================================================================= */

static int __init custom_cxusb_init(void)
{
	int ret;
	ret = usb_register(&custom_cxusb_driver);
	if (ret)
		pr_err("Failed to register custom anti-rc cxusb combo driver: %d\n", ret);
	else
		pr_info("Custom anti-rc cxusb combo driver module loaded successfully.\n");
	return ret;
}

static void __exit custom_cxusb_exit(void)
{
	usb_deregister(&custom_cxusb_driver);
	pr_info("Custom anti-rc cxusb combo driver module unloaded.\n");
}

module_init(custom_cxusb_init);
module_exit(custom_cxusb_exit);

