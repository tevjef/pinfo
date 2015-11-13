obj-m += pinfo.o
#disable compiler warnings
ccflags-y += -w
all:
	make -C /lib/modules/`uname -r`/build M=$(PWD) modules
	make -s clean

clean:
	rm -rf *.o
	rm -rf *.symvers
	rm -rf *.order
	rm -rf *.mod.c
