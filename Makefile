obj-m += pinfo.o

all:
	make -C /lib/modules/4.2.0-16-generic/build M=$(PWD) modules

clean:

	make -C /lib/modules/4.2.0-16-generic/build M=$(PWD) clean
