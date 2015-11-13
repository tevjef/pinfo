#include <linux/module.h>
#include <linux/kernel.h>
#include <linux/init.h>
#include <linux/printk.h>
#include <linux/sched.h>

MODULE_LICENSE("GPL");

static int __init pinfo_init (void) {
	struct task_struct *task;
	for_each_process(task) {
		long int uid = task->cred->uid.val;
		int ppid = task_ppid_nr(task);
		pr_info("%d %d %d %ld %s %d \n", task->pid, ppid, task->state, uid, task->comm, task->policy);
	}
	return 0;
}

static void __exit pinfo_exit (void) {
	printk(KERN_INFO "Done! \n");
}

module_init(pinfo_init);
module_exit(pinfo_exit);
