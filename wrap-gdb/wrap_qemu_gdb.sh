#!/bin/bash

LD_LIBRARY_PATH=$LD_LIBRARY_PATH:/var/run/debug/usr/lib64 /var/run/debug/usr/bin/gdbserver \
	localhost:1234 \
	/usr/libexec/qemu-kvm $@ &
printf "%d" $(pgrep gdbserver) > /run/libvirt/qemu/run/default_vmi-debug-tools.pid
