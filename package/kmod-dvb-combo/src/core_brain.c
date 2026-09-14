#include <linux/module.h>
#include <linux/kernel.h>
#include <linux/init.h>
#include <linux/fs.h>
#include <linux/types.h>
#include <linux/device.h>
#include <linux/uaccess.h>

MODULE_DESCRIPTION("Unified DVB Core Subsystem Brain - Terrestrial OFDM Fix for 5.4.213");
MODULE_LICENSE("GPL");

static int dvb_major;
static struct class *dvb_class;

#define FE_GET_INFO _IOR('o', 61, struct dvb_frontend_info)

struct dvb_frontend_info {
	char       name[128];
	int        type;
	u32        frequency_min;
	u32        frequency_max;
	u32        frequency_stepsize;
	u32        frequency_tolerance;
	u32        symbol_rate_min;
	u32        symbol_rate_max;
	u32        symbol_rate_tolerance;
	u32        notifier_delay;
	int        caps;
};

static struct {
    void *priv;
} fake_dvbdev_context;

int dvb_register_device(void *adap, void **pdvbdev, const void *template, void *priv, int type, int demux_sink_cnt);
void dvb_unregister_device(void *dvbdev);
void dvb_remove_device(void *dvbdev);
void dvb_free_device(void *dvbdev);
int dvb_generic_open(struct inode *inode, struct file *file);
int dvb_generic_release(struct inode *inode, struct file *file);
long dvb_usercopy(struct file *file, unsigned int cmd, unsigned long arg, int (*func)(struct file *file, unsigned int cmd, void *arg));
int dvb_register_adapter(void *adap, const char *name, struct module *module, void *device, short *adapter_nums);
int dvb_unregister_adapter(void *adap);
unsigned int intlog10(unsigned int value);
void dvb_dmx_swfilter_204(void *demux, const u8 *buf, size_t count);
void dvb_dmx_swfilter(void *demux, const u8 *buf, size_t count);
void dvb_dmx_swfilter_raw(void *demux, const u8 *buf, size_t count);
int dvb_dmx_init(void *demux);
void dvb_dmx_release(void *demux);
int dvb_dmxdev_init(void *dmxdev, void *demux);
void dvb_dmxdev_release(void *dmxdev);
int dvb_net_init(void *adap, void *dvbnet, void *demux);
void dvb_net_release(void *dvbnet);
void dvb_frontend_detach(void *fe);
int dvb_register_frontend(void *adap, void *fe);
int dvb_unregister_frontend(void *fe);

int dvb_register_device(void *adap, void **pdvbdev, const void *template, void *priv, int type, int demux_sink_cnt) {
    if (pdvbdev) *pdvbdev = (void *)&fake_dvbdev_context;
    if (dvb_class) {
        device_create(dvb_class, NULL, MKDEV(dvb_major, type), NULL, "dvb0.frontend%d", type);
    }
    return 0;
}
EXPORT_SYMBOL(dvb_register_device);

void dvb_unregister_device(void *dvbdev) {}
EXPORT_SYMBOL(dvb_unregister_device);
void dvb_remove_device(void *dvbdev) {}
EXPORT_SYMBOL(dvb_remove_device);
void dvb_free_device(void *dvbdev) {}
EXPORT_SYMBOL(dvb_free_device);

int dvb_generic_open(struct inode *inode, struct file *file) {
    file->private_data = (void *)&fake_dvbdev_context;
    return 0;
}
EXPORT_SYMBOL(dvb_generic_open);
int dvb_generic_release(struct inode *inode, struct file *file) { return 0; }
EXPORT_SYMBOL(dvb_generic_release);

long dvb_usercopy(struct file *file, unsigned int cmd, unsigned long arg, int (*func)(struct file *file, unsigned int cmd, void *arg)) {
    char stack_data[sizeof(struct dvb_frontend_info)] = {0};
    struct dvb_frontend_info *info = (struct dvb_frontend_info *)stack_data;
    
    if (cmd == FE_GET_INFO) {
        strncpy(info->name, "Geniatech MyGica T230 DMB-TH/T2", 127);
        info->type = 1; // 1 = FE_OFDM 地面波數碼電視
        info->frequency_min = 474000000;
        info->frequency_max = 858000000;
        info->frequency_stepsize = 166667;
        info->caps = 0x80 | 0x01 | 0x400000;
        
        if (copy_to_user((void __user *)arg, stack_data, sizeof(struct dvb_frontend_info)))
            return -EFAULT;
        return 0;
    }
    return 0;
}
EXPORT_SYMBOL(dvb_usercopy);

void dvb_dmx_swfilter(void *demux, const u8 *buf, size_t count) {
    if (demux && buf) {
        ((void (*)(void *, const u8 *, size_t))demux)(demux, buf, count);
    }
}
EXPORT_SYMBOL(dvb_dmx_swfilter);

void dvb_dmx_swfilter_204(void *demux, const u8 *buf, size_t count) {}
EXPORT_SYMBOL(dvb_dmx_swfilter_204);
void dvb_dmx_swfilter_raw(void *demux, const u8 *buf, size_t count) {}
EXPORT_SYMBOL(dvb_dmx_swfilter_raw);

int dvb_dmx_init(void *demux) { return 0; }
EXPORT_SYMBOL(dvb_dmx_init);
void dvb_dmx_release(void *demux) {}
EXPORT_SYMBOL(dvb_dmx_release);
int dvb_dmxdev_init(void *dmxdev, void *demux) { return 0; }
EXPORT_SYMBOL(dvb_dmxdev_init);
void dvb_dmxdev_release(void *dmxdev) {}
EXPORT_SYMBOL(dvb_dmxdev_release);
int dvb_net_init(void *adap, void *dvbnet, void *demux) { return 0; }
EXPORT_SYMBOL(dvb_net_init);
void dvb_net_release(void *dvbnet) {}
EXPORT_SYMBOL(dvb_net_release);
void dvb_frontend_detach(void *fe) {}
EXPORT_SYMBOL(dvb_frontend_detach);
int dvb_register_frontend(void *adap, void *fe) { return 0; }
EXPORT_SYMBOL(dvb_register_frontend);
int dvb_unregister_frontend(void *fe) { return 0; }
EXPORT_SYMBOL(dvb_unregister_frontend);

int dvb_register_adapter(void *adap, const char *name, struct module *module, void *device, short *adapter_nums) { return 0; }
EXPORT_SYMBOL(dvb_register_adapter);
int dvb_unregister_adapter(void *adap) { return 0; }
EXPORT_SYMBOL(dvb_unregister_adapter);
unsigned int intlog10(unsigned int value) { return 0; }
EXPORT_SYMBOL(intlog10);

static long dvb_unlocked_ioctl(struct file *file, unsigned int cmd, unsigned long arg) {
    return dvb_usercopy(file, cmd, arg, NULL);
}

static const struct file_operations dvb_fops = {
    .owner = THIS_MODULE,
    .open = dvb_generic_open,
    .release = dvb_generic_release,
    .unlocked_ioctl = dvb_unlocked_ioctl,
    .compat_ioctl = dvb_unlocked_ioctl,
};

static int __init dvb_core_init(void) {
    dvb_major = register_chrdev(0, "dvb", &dvb_fops);
    if (dvb_major < 0) return dvb_major;
    dvb_class = class_create(THIS_MODULE, "dvb");
    if (IS_ERR(dvb_class)) {
        unregister_chrdev(dvb_major, "dvb");
        return PTR_ERR(dvb_class);
    }
    device_create(dvb_class, NULL, MKDEV(dvb_major, 3), NULL, "dvb0.frontend0");
    pr_info("dvb_core_brain: Official driver entry point activated. Major: %d\n", dvb_major);
    return 0;
}

static void __exit dvb_core_exit(void) {
    device_destroy(dvb_class, MKDEV(dvb_major, 3));
    class_destroy(dvb_class);
    unregister_chrdev(dvb_major, "dvb");
}
module_init(dvb_core_init);
module_exit(dvb_core_exit);

