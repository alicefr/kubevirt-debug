# Privileged debugging on the node

# Build the container image

Certain debugging tools requires to have exactly the same binary available. This
can be particurarly challanging with containers if the debug tools run in a
separate container. This section will cover how to build a container image with
the debug tools plus binaries of the KubeVirt version you want to debug.
KubeVirt uses [distroless
containers](https://github.com/GoogleContainerTools/distroless) and it isn't
possible to use the image as parent image and installing additional packages
because it lacks the package manager.

First, based on your installation the namespace and the name of the KubeVirt CR could
vary. In this example, we'll assume that KubeVirt CR is called `kubevirt` and
installed in the `kubevirt` namespace. You can easly find out how it is called
in your cluster by searching with `kubectl get kubevirt -A`.

Get registry of the images of the KubeVirt installation
```bash
$ export registry=$(kubectl get kubevirt kubevirt -n kubevirt  -o jsonpath='{.status.observedDeploymentConfig}' |jq '.registry'|tr -d "\"")
$ echo $registry
"registry:5000/kubevirt"
```

Get the shasum of the virt-launcher image:
```bash
$ export tag=$(kubectl get kubevirt kubevirt -n kubevirt  -o jsonpath='{.status.observedDeploymentConfig}' |jq '.virtLauncherSha'|tr -d "\"")
$ echo $tag
"sha256:6c8b85eed8e83a4c70779836b246c057d3e882eb513f3ded0a02e0a4c4bda837"
```
Build the image by using the registry and shasum retrieved in the previous steps:
```bash
$ podman build \
    -t
    --build-arg registry=$registry  \
    --build-arg tag=@$tag \
    -f Dockerfile .
```

## Deploy the privileged pod
This is an example that gives a couple of hints how you can define your
debugging pod:
```yaml
kind: Pod
metadata:
  name: node01-debug
spec:
  containers:
  - command:
    - /bin/sh
    image: registry:5000/systap-debug:latest
    imagePullPolicy: Always
    name: debug
    securityContext:
      privileged: true
      runAsUser: 0
    stdin: true
    stdinOnce: true
    tty: true
    volumeMounts:
    - mountPath: /host
      name: host
    - mountPath: /usr/lib/modules
      name: modules
    - mountPath: /sys/kernel
      name: sys-kernel
  hostNetwork: true
  hostPID: true
  nodeName: node01
  restartPolicy: Never
  volumes:
  - hostPath:
      path: /
      type: Directory
    name: host
  - hostPath:
      path: /usr/lib/modules
      type: Directory
    name: modules
  - hostPath:
      path: /sys/kernel
      type: Directory
    name: sys-kernel
```
The `privileged` options is required to have access to mostly all the resources
on the node.

In the `volumes` section, you can specify the directories you want to be
directly mounted in the debugging container. For example, `/usr/lib/modules` is
particurarly useful if you need to load some kernel modules.

Execing into the pod gives you a shell with  privileged access to the node plus the tooling you
installed into the image:
```bash
$ kubectl exec -ti debug -- bash
```

The following examples assume you have execing already into the `debug` pod.

### Run a command directly on the node
```bash
$ chroot /host
sh-5.1# cat /etc/os-release
NAME="CentOS Stream"
VERSION="9"
ID="centos"
ID_LIKE="rhel fedora"
VERSION_ID="9"
PLATFORM_ID="platform:el9"
PRETTY_NAME="CentOS Stream 9"
ANSI_COLOR="0;31"
LOGO="fedora-logo-icon"
CPE_NAME="cpe:/o:centos:centos:9"
HOME_URL="https://centos.org/"
BUG_REPORT_URL="https://bugzilla.redhat.com/"
REDHAT_SUPPORT_PRODUCT="Red Hat Enterprise Linux 9"
REDHAT_SUPPORT_PRODUCT_VERSION="CentOS Stream"
```

### Attach to a running process (e.g strace or gdb)
This requires the field `hostPID: true` in this way you are able to list all the
processes running on the node.
```bash
$ [root@node01 /]# ps -ef |grep qemu-kvm
qemu       50122   49850  0 12:34 ?        00:00:25 /usr/libexec/qemu-kvm -name guest=default_vmi-ephemeral,debug-threads=on -S -object {"qom-type":"secret","id":"masterKey0","format":"raw","file":"/var/run/kubevirt-private/libvirt/qemu/lib/domain-1-default_vmi-ephemera/master-key.aes"} -machine pc-q35-rhel9.2.0,usb=off,dump-guest-core=off,memory-backend=pc.ram,acpi=on -accel kvm -cpu Skylake-Client-IBRS,ss=on,vmx=on,pdcm=on,hypervisor=on,tsc-adjust=on,clflushopt=on,umip=on,md-clear=on,stibp=on,flush-l1d=on,arch-capabilities=on,ssbd=on,xsaves=on,pdpe1gb=on,ibpb=on,ibrs=on,amd-stibp=on,amd-ssbd=on,rdctl-no=on,ibrs-all=on,skip-l1dfl-vmentry=on,mds-no=on,pschange-mc-no=on,tsx-ctrl=on,fb-clear=on,hle=off,rtm=off -m size=131072k -object {"qom-type":"memory-backend-ram","id":"pc.ram","size":134217728} -overcommit mem-lock=off -smp 1,sockets=1,dies=1,cores=1,threads=1 -object {"qom-type":"iothread","id":"iothread1"} -uuid b56f06f0-07e9-4fe5-8913-18a14e83a4d1 -smbios type=1,manufacturer=KubeVirt,product=None,uuid=b56f06f0-07e9-4fe5-8913-18a14e83a4d1,family=KubeVirt -no-user-config -nodefaults -chardev socket,id=charmonitor,fd=21,server=on,wait=off -mon chardev=charmonitor,id=monitor,mode=control -rtc base=utc -no-shutdown -boot strict=on -device {"driver":"pcie-root-port","port":16,"chassis":1,"id":"pci.1","bus":"pcie.0","multifunction":true,"addr":"0x2"} -device {"driver":"pcie-root-port","port":17,"chassis":2,"id":"pci.2","bus":"pcie.0","addr":"0x2.0x1"} -device {"driver":"pcie-root-port","port":18,"chassis":3,"id":"pci.3","bus":"pcie.0","addr":"0x2.0x2"} -device {"driver":"pcie-root-port","port":19,"chassis":4,"id":"pci.4","bus":"pcie.0","addr":"0x2.0x3"} -device {"driver":"pcie-root-port","port":20,"chassis":5,"id":"pci.5","bus":"pcie.0","addr":"0x2.0x4"} -device {"driver":"pcie-root-port","port":21,"chassis":6,"id":"pci.6","bus":"pcie.0","addr":"0x2.0x5"} -device {"driver":"pcie-root-port","port":22,"chassis":7,"id":"pci.7","bus":"pcie.0","addr":"0x2.0x6"} -device {"driver":"pcie-root-port","port":23,"chassis":8,"id":"pci.8","bus":"pcie.0","addr":"0x2.0x7"} -device {"driver":"pcie-root-port","port":24,"chassis":9,"id":"pci.9","bus":"pcie.0","addr":"0x3"} -device {"driver":"virtio-scsi-pci-non-transitional","id":"scsi0","bus":"pci.5","addr":"0x0"} -device {"driver":"virtio-serial-pci-non-transitional","id":"virtio-serial0","bus":"pci.6","addr":"0x0"} -blockdev {"driver":"file","filename":"/var/run/kubevirt/container-disks/disk_0.img","node-name":"libvirt-2-storage","cache":{"direct":true,"no-flush":false},"auto-read-only":true,"discard":"unmap"} -blockdev {"node-name":"libvirt-2-format","read-only":true,"discard":"unmap","cache":{"direct":true,"no-flush":false},"driver":"qcow2","file":"libvirt-2-storage"} -blockdev {"driver":"file","filename":"/var/run/kubevirt-ephemeral-disks/disk-data/containerdisk/disk.qcow2","node-name":"libvirt-1-storage","cache":{"direct":true,"no-flush":false},"auto-read-only":true,"discard":"unmap"} -blockdev {"node-name":"libvirt-1-format","read-only":false,"discard":"unmap","cache":{"direct":true,"no-flush":false},"driver":"qcow2","file":"libvirt-1-storage","backing":"libvirt-2-format"} -device {"driver":"virtio-blk-pci-non-transitional","bus":"pci.7","addr":"0x0","drive":"libvirt-1-format","id":"ua-containerdisk","bootindex":1,"write-cache":"on","werror":"stop","rerror":"stop"} -netdev {"type":"tap","fd":"22","vhost":true,"vhostfd":"24","id":"hostua-default"} -device {"driver":"virtio-net-pci-non-transitional","host_mtu":1480,"netdev":"hostua-default","id":"ua-default","mac":"7e:cb:ba:c3:71:88","bus":"pci.1","addr":"0x0","romfile":""} -add-fd set=0,fd=20,opaque=serial0-log -chardev socket,id=charserial0,fd=18,server=on,wait=off,logfile=/dev/fdset/0,logappend=on -device {"driver":"isa-serial","chardev":"charserial0","id":"serial0","index":0} -chardev socket,id=charchannel0,fd=19,server=on,wait=off -device {"driver":"virtserialport","bus":"virtio-serial0.0","nr":1,"chardev":"charchannel0","id":"channel0","name":"org.qemu.guest_agent.0"} -audiodev {"id":"audio1","driver":"none"} -vnc vnc=unix:/var/run/kubevirt-private/3a8f7774-7ec7-4cfb-97ce-581db52ee053/virt-vnc,audiodev=audio1 -device {"driver":"VGA","id":"video0","vgamem_mb":16,"bus":"pcie.0","addr":"0x1"} -global ICH9-LPC.noreboot=off -watchdog-action reset -device {"driver":"virtio-balloon-pci-non-transitional","id":"balloon0","free-page-reporting":true,"bus":"pci.8","addr":"0x0"} -sandbox on,obsolete=deny,elevateprivileges=deny,spawn=deny,resourcecontrol=deny -msg timestamp=on
$ gdb -p 50122 /usr/libexec/qemu-kvm
```
