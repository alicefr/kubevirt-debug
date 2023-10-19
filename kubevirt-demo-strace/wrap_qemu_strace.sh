#!/bin/bash

LD_LIBRARY_PATH=$LD_LIBRARY_PATH:/var/run/debug/usr/lib64 /var/run/debug/usr/bin/strace \
	-o /var/run/debug/logs/strace.out \
	/usr/libexec/qemu-kvm $@
