#include <linux/module.h>
#include <linux/kernel.h>
#include <linux/types.h>

MODULE_DESCRIPTION("Pure Independent Mock RC Core for 5.4.213 Closed ROM");
MODULE_LICENSE("GPL");

void *rc_allocate_device(int type);
int rc_register_device(void *dev);
void rc_unregister_device(void *dev);
void rc_free_device(void *dev);
int rc_keydown(void *dev, int protocol, u32 scancode, u8 toggle);
void rc_keyup(void *dev);

void *rc_allocate_device(int type) { return NULL; }
EXPORT_SYMBOL(rc_allocate_device);

int rc_register_device(void *dev) {
        pr_info("rc-core-mock: [Kernel 5.4] rc_register_device hijacked successfully.\n");
        return 0;
}
EXPORT_SYMBOL(rc_register_device);

void rc_unregister_device(void *dev) {}
EXPORT_SYMBOL(rc_unregister_device);
void rc_free_device(void *dev) {}
EXPORT_SYMBOL(rc_free_device);
int rc_keydown(void *dev, int protocol, u32 scancode, u8 toggle) { return 0; }
EXPORT_SYMBOL(rc_keydown);
void rc_keyup(void *dev) {}
EXPORT_SYMBOL(rc_keyup);

