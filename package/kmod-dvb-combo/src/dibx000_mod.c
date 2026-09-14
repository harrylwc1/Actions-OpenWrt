#include <linux/module.h>
#include <linux/kernel.h>
#include <linux/types.h>
MODULE_LICENSE("GPL");
void *dibx000_init_i2c_master(void *a, u16 b, u8 c, u16 d) { return a; }
EXPORT_SYMBOL(dibx000_init_i2c_master);
void *dibx000_get_i2c_adapter(void *a) { return a; }
EXPORT_SYMBOL(dibx000_get_i2c_adapter);
void dibx000_reset_i2c_master(void *a) {}
EXPORT_SYMBOL(dibx000_reset_i2c_master);
void dibx000_exit_i2c_master(void *a) {}
EXPORT_SYMBOL(dibx000_exit_i2c_master);
