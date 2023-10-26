# Collection of howtos to debug the virt stack with container and KubeVirt

This repository contains some scripts, yamls and example of debugging techniques
to debug virt stack in the context of KubeVirt, Kubernetes and containers.

These HOWTOs are divided into scenarios for privileged (e.g. admins) and regular users. Some of the HOWTOs also point directly to the KubeVirt [user-guide documentation](https://kubevirt.io/user-guide/).

## HOWTOs
* [KubeVirt debugging guide](https://kubevirt.io/user-guide/operations/debug/)
* Scenarios
  * Regular users
    * [Install debuging tools in virt-launcher and run QEMU launched by the tool (e.g strace)](launch-qemu-strace/)
    * [Start QEMU and attach GDB](wrap-gdb)
    * [Logging](logging)
    * [Execute virsh and QMP commands](run-virsh)
    * [Memory dumps](https://kubevirt.io/user-guide/operations/memory_dump/)
  * Privileged users
    * [Run privileged pod on the node](privileged-node-pod)
