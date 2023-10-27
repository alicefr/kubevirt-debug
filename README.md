# Collection of HOWTOs to debug the virt stack with container and KubeVirt

This repository contains some scripts, yamls and examples of debugging techniques for the virt stack in the context of KubeVirt, Kubernetes and containers.

These HOWTOs are divided into different scenarios for privileged (e.g. admins) and regular users. Some of the links point directly to existing guides, others are part of this repository.

The first source to check is, of course the KubeVirt [user-guide documentation](https://kubevirt.io/user-guide/).

Guides:
* [KubeVirt debugging guide](https://kubevirt.io/user-guide/operations/debug/)
* Scenarios
  * Privileged users
    * [Run privileged pod on the node](privileged-node-pod)
  * Regular users
    * [Logging](logging)
    * [Execute virsh and QMP commands](run-virsh)
    * [Memory dumps](https://kubevirt.io/user-guide/operations/memory_dump/)
    * [Run guestfs-tools](https://github.com/kubevirt/kubevirt/blob/main/docs/guestfs.md)
    * [Build KubeVirt with custom rpms](https://github.com/kubevirt/kubevirt/blob/main/docs/custom-rpms.md) or [local custom files](https://github.com/kubevirt/kubevirt/blob/main/docs/local-custom-files.md)
    * [Install debuging tools in virt-launcher and run QEMU launched by the tool (e.g strace)](launch-qemu-strace/)
    * [Start QEMU and attach GDB](wrap-gdb)
