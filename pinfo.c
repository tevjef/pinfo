#include <linux/module.h>
#include <linux/kernel.h>
#include <linux/init.h>
#include <linux/printk.h>
#include <linux/sched.h>

#define PINFO_LOG KERN_INFO "pinfo: "

MODULE_LICENSE("GPL");

static int __init pinfo_init (void) {
	struct task_struct *task;
	for_each_process(task) {
		long int uid = task->cred->uid.val;
		int ppid = task_ppid_nr(task);
		printk(PINFO_LOG "%d %d %d %ld %s %d \n", task->pid, ppid, task->state, uid, task->comm, task->policy);
	}
	return 0;
}

static void __exit pinfo_exit (void) {}

module_init(pinfo_init);
module_exit(pinfo_exit);
