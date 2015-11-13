
#!/bin/bash

show_help() {
    echo "
    Usage: ${0##*/} [-pPsuco]
    A linux kernel module that extracts information about processes. Optional parameters
    to specify columns
    
		-p   	list the pid

		-P   	list the process's parent id (ppid)

		-s  	list the status

		-u  	list the uid

		-c  	list the command

		-o  	list the policy

		-h  	help
		"
 }


OPTIND=1 # Reset is necessary if getopts was used previously in the script.  It is a good idea to make this local in a function.
PIDFLAG=0
PPIDFLAG=0
STATUSFLAG=0
COMMANDFLAG=0
POLICYFLAG=0
ALLFLAG=1

while getopts "pPsucoh" opt; do
	case "$opt" in
		h)
			show_help
			exit 0
			;;
		p)	
			PIDFLAG=1
			ALLFLAG=0
			;;
		P)	
			PPIDFLAG=1
			ALLFLAG=0
			;;
		s)	
			STATUSFLAG=1
			ALLFLAG=0
       		;;
		c)	
			COMMANDFLAG=1
			ALLFLAG=0
			;;
		o)	
			POLICYFLAG=1
			ALLFLAG=0
			;;
		'?')
			show_help >&2
			exit 1
			;;
	esac
done
shift "$((OPTIND-1))" # Shift off the options and optional --.

if [ $PIDFLAG -eq 1 ] || [ $ALLFLAG -eq 1 ]; then
		printf "%-8s\t" "PID"
fi
if [ $PPIDFLAG -eq 1 ] || [ $ALLFLAG -eq 1 ]; then
		printf "%-20s\t" "PPID"
fi
if [ $STATUSFLAG -eq 1 ] || [ $ALLFLAG -eq 1 ]; then
		printf "%-20s\t" "STATUS"
fi
if [ $COMMANDFLAG -eq 1 ] || [ $ALLFLAG -eq 1 ]; then
		printf "%-20s\t" "COMMAND"
fi
if [ $POLICYFLAG -eq 1 ] || [ $ALLFLAG -eq 1 ]; then
		printf "%-14s\t" "POLICY"
fi
echo
echo
rmmod pinfo.ko &> /dev/null
insmod pinfo.ko

dmesg | grep -E "[0-9]+[ ][0-9]+[ ][0-9]+" | cut -d " " -f2-7 > output
awk '!seen[$0]++' output > coutput
rm output

while read line; do
	pid=`echo $line | cut -d " " -f1`

	ppid=`echo $line | cut -d " " -f2`
	ppid_comm=`cat coutput | grep -E "^\$ppid[ ][0-9]+[ ][0-9]+[ ]" | cut -d " " -f5 | uniq`

	status=`echo $line | cut -d " " -f3`
	case $status in
	0)	real_status="TASK_RUNNING"
		;;
	1)	real_status="TASK_INTERRUPTIBLE"
		;;
	2)	real_status="TASK_UNINTERRUPTIBLE"
		;;
	4)	real_status="TASK_STOPPED"
		;;
	8)	real_status="TASK_TRACED"
		;;
	16)	real_status="TASK_DEAD"
		;;
	32)	real_status="TASK_ZOMBIE"
		;;
	64)	real_status="TASK_DEAD"
		;;
	*)	real_status="OTHER"
		;;
	esac

	uid=`echo $line | cut -d " " -f4`
	real_uid=`getent passwd $uid | cut -d ":" -f1`

	comm=`echo $line | cut -d " " -f5`

	policy=`echo $line | cut -d " " -f6`
	case $policy in
	0)	real_policy="SCHED_NORMAL"
		;;
	1)	real_policy="SCHED_FIFO"
		;;
	2)	real_policy="SCHED_RR"
		;;
	3)	real_policy="SCHED_BATCH"
		;;
	5)	real_policy="SCHED_IDLE"
		;;
	6)	real_policy="SCHED_DEADLINE"
		;;
	*)	real_status="OTHER"
	;;
	esac

	if [ $PIDFLAG -eq 1 ] || [ $ALLFLAG -eq 1 ]; then
			printf "%-8d\t" $pid
	fi
	if [ $PPIDFLAG -eq 1 ] || [ $ALLFLAG -eq 1 ]; then
			printf "%-20s\t" "$ppid ($ppid_comm)"
	fi
	if [ $STATUSFLAG -eq 1 ] || [ $ALLFLAG -eq 1 ]; then
			printf "%-20s\t" $real_status
	fi
	if [ $COMMANDFLAG -eq 1 ] || [ $ALLFLAG -eq 1 ]; then
			printf "%-20s\t" $comm
	fi
	if [ $POLICYFLAG -eq 1 ] || [ $ALLFLAG -eq 1 ]; then
			printf "%-14s\t" $real_policy
	fi
	echo
done < coutput

rmmod pinfo.ko