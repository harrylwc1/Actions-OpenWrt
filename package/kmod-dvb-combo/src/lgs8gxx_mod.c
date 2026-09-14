#include <linux/module.h>
#include <linux/kernel.h>
MODULE_LICENSE("GPL");
void *lgs8gxx_attach(void *a, void *b) { return a; }
EXPORT_SYMBOL(lgs8gxx_attach);
