#include <linux/module.h>
#include <linux/kernel.h>
#include <linux/init.h>
#include <linux/types.h>

MODULE_DESCRIPTION("Unified TV Stick Hardware Chips and RC Intercept Layer");
MODULE_LICENSE("GPL");

void *dibx000_init_i2c_master(void *mst, u16 type, u8 dev_id, u16 master_cfg) { return NULL; }
EXPORT_SYMBOL(dibx000_init_i2c_master);
void *dibx000_get_i2c_adapter(void *mst) { return NULL; }
EXPORT_SYMBOL(dibx000_get_i2c_adapter);
void dibx000_reset_i2c_master(void *mst) {}
EXPORT_SYMBOL(dibx000_reset_i2c_master);
void dibx000_exit_i2c_master(void *mst) {}
EXPORT_SYMBOL(dibx000_exit_i2c_master);

void *dib0070_attach(void *fe, void *i2c, void *cfg) { return fe; }
EXPORT_SYMBOL(dib0070_attach);
void *max2165_attach(void *fe, void *i2c, void *cfg) { return fe; }
EXPORT_SYMBOL(max2165_attach);
void *atbm8830_attach(void *fe, void *i2c, void *cfg) { return fe; }
EXPORT_SYMBOL(atbm8830_attach);
void *dib7000p_attach(void *i2c, u8 i2c_addr, void *cfg) { return NULL; }
EXPORT_SYMBOL(dib7000p_attach);

int rc_register_device(void *dev) { return 0; }
EXPORT_SYMBOL(rc_register_device);
void rc_unregister_device(void *dev) {}
EXPORT_SYMBOL(rc_unregister_device);
void *rc_allocate_device(int type) { return NULL; }
EXPORT_SYMBOL(rc_allocate_device);
void rc_free_device(void *dev) {}
EXPORT_SYMBOL(rc_free_device);
