obj-m += pinfo.o

#disable compiler warnings
ccflags-y += -w

all:
	make -C /lib/modules/`uname -r`/build M=$(PWD) modules
	make -s clean

# Clean up files generated after module compilation.
clean:
	rm -f *.o
	rm -f *.symvers
	rm -f *.order
	rm -f *.mod.c
	rm -f .pinfo.ko.cmd
	rm -f .pinfo.o.cmd
	rm -f .pinfo.mod.o.cmd
