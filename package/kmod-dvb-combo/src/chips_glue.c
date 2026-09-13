#include <linux/module.h>
#include <linux/kernel.h>
#include <linux/init.h>
#include <linux/types.h>

MODULE_DESCRIPTION("Unified TV Stick Hardware Chips and RC Intercept Layer");
MODULE_LICENSE("GPL");

/* 補齊 dibx000_common 與 dib7000p 所需的 I2C 專屬血管 */
void *dibx000_init_i2c_master(void *mst, u16 type, u8 dev_id, u16 master_cfg) { return NULL; }
EXPORT_SYMBOL(dibx000_init_i2c_master);
void *dibx000_get_i2c_adapter(void *mst) { return NULL; }
EXPORT_SYMBOL(dibx000_get_i2c_adapter);
void dibx000_reset_i2c_master(void *mst) {}
EXPORT_SYMBOL(dibx000_reset_i2c_master);
void dibx000_exit_i2c_master(void *mst) {}
EXPORT_SYMBOL(dibx000_exit_i2c_master);

/* 💥 補齊 dib0070 實體晶片附屬接口，完美解除外殼對 dib0070 的依賴 */
void *dib0070_attach(void *fe, void *i2c, void *cfg) { return fe; }
EXPORT_SYMBOL(dib0070_attach);

/* 其餘前端解調晶片接口 */
void *max2165_attach(void *fe, void *i2c, void *cfg) { return fe; }
EXPORT_SYMBOL(max2165_attach);
void *atbm8830_attach(void *fe, void *i2c, void *cfg) { return fe; }
EXPORT_SYMBOL(atbm8830_attach);
void *dib7000p_attach(void *i2c, u8 i2c_addr, void *cfg) { return NULL; }
EXPORT_SYMBOL(dib7000p_attach);

/* 💥 偽造並導出 4 個安全的 rc-core 紅外線攔截函數 */
int rc_register_device(void *dev) { return 0; }
EXPORT_SYMBOL(rc_register_device);
void rc_unregister_device(void *dev) {}
EXPORT_SYMBOL(rc_unregister_device);
void *rc_allocate_device(int type) { return NULL; }
EXPORT_SYMBOL(rc_allocate_device);
void rc_free_device(void *dev) {}
EXPORT_SYMBOL(rc_free_device);
