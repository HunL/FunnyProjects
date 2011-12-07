//how to write Makefile to compile?
#include<Linux/module.h>
#include<Linux/init.h>

MODULE_LICENSE("Dual BSD/GPL");

static int _init helloworld_init(void)
{
  printk(KERN_ALERT "Hello world module init\n");
  return 0;
}
static void _exit helloworld_exit(void)
{
  printk(KERN_ALERT "Hello world module exit\n");
}
module_init(helloworld_init);
module_exit(helloworld_exit);

MODULE_AUTHOR("Jiehui Li");
MODULE_DESCRIPTION("Hello World DEMO");
MODULE_VERSION("0.0.1");
MODULE_ALTAS("Chapter 17,Example 1");
