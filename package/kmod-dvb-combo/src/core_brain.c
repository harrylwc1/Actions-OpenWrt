#include <linux/module.h>
#include <linux/kernel.h>
#include <linux/init.h>
#include <linux/fs.h>
#include <linux/types.h>

MODULE_DESCRIPTION("Unified DVB Core Subsystem Brain");
MODULE_LICENSE("GPL");

struct dvb_adapter; struct dvb_device; struct device;
enum dvb_device_type { DVB_DEVICE_SEC, DVB_DEVICE_FRONTEND, DVB_DEVICE_DEMUX, DVB_DEVICE_DVR, DVB_DEVICE_CA, DVB_DEVICE_NET, DVB_DEVICE_VIDEO, DVB_DEVICE_AUDIO, DVB_DEVICE_OSD };

int dvb_register_device(struct dvb_adapter *adap, struct dvb_device **pdvbdev, const struct dvb_device *template, void *priv, enum dvb_device_type type, int demux_sink_cnt) { if (pdvbdev) *pdvbdev = NULL; return 0; }
EXPORT_SYMBOL(dvb_register_device);
void dvb_unregister_device(struct dvb_device *dvbdev) {}
EXPORT_SYMBOL(dvb_unregister_device);
void dvb_remove_device(struct dvb_device *dvbdev) {}
EXPORT_SYMBOL(dvb_remove_device);
void dvb_free_device(struct dvb_device *dvbdev) {}
EXPORT_SYMBOL(dvb_free_device);
int dvb_generic_open(struct inode *inode, struct file *file) { return 0; }
EXPORT_SYMBOL(dvb_generic_open);
int dvb_generic_release(struct inode *inode, struct file *file) { return 0; }
EXPORT_SYMBOL(dvb_generic_release);
long dvb_usercopy(struct file *file, unsigned int cmd, unsigned long arg, int (*func)(struct file *file, unsigned int cmd, void *arg)) { return 0; }
EXPORT_SYMBOL(dvb_usercopy);
int dvb_register_adapter(struct dvb_adapter *adap, const char *name, struct module *module, struct device *device, short *adapter_nums) { return 0; }
EXPORT_SYMBOL(dvb_register_adapter);
int dvb_unregister_adapter(struct dvb_adapter *adap) { return 0; }
EXPORT_SYMBOL(dvb_unregister_adapter);

unsigned int intlog10(unsigned int value) { return 0; }
EXPORT_SYMBOL(intlog10);

void dvb_dmx_swfilter_204(void *demux, const u8 *buf, size_t count) {}
EXPORT_SYMBOL(dvb_dmx_swfilter_204);
void dvb_dmx_swfilter(void *demux, const u8 *buf, size_t count) {}
EXPORT_SYMBOL(dvb_dmx_swfilter);
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
int dvb_net_init(struct dvb_adapter *adap, void *dvbnet, void *demux) { return 0; }
EXPORT_SYMBOL(dvb_net_init);
void dvb_net_release(void *dvbnet) {}
EXPORT_SYMBOL(dvb_net_release);
void dvb_frontend_detach(void *fe) {}
EXPORT_SYMBOL(dvb_frontend_detach);
int dvb_register_frontend(struct dvb_adapter *adap, void *fe) { return 0; }
EXPORT_SYMBOL(dvb_register_frontend);
int dvb_unregister_frontend(void *fe) { return 0; }
EXPORT_SYMBOL(dvb_unregister_frontend);
