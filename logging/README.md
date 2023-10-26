# Control libvirt logging for each component

Generally, cluster admins can control the log verbosity of each KubeVirt component in KubeVirt CR. For more details, please, check the [KubeVirt documentation](https://kubevirt.io/user-guide/operations/debug/#log-verbosity).

Nonetheless, regular users can also adjust the qemu component logging to have a more fine control over it. The annotation `kubevirt.io/libvirt-log-filters` enables you to modify each component's log level.

Example:
```yaml
apiVersion: kubevirt.io/v1
kind: VirtualMachineInstance
metadata:
  annotations:
    kubevirt.io/libvirt-log-filters: "2:qemu.qemu_monitor 3:*"
  labels:
    special: vmi-debug-tools
  name: vmi-debug-tools
spec:
  domain:
    devices:
      disks:
      - disk:
          bus: virtio
        name: containerdisk
      - disk:
          bus: virtio
        name: cloudinitdisk
      rng: {}
    resources:
      requests:
        memory: 1024M
  volumes:
  - containerDisk:
      image: registry:5000/kubevirt/fedora-with-test-tooling-container-disk:devel
    name: containerdisk
  - cloudInitNoCloud:
      userData: |-
        #cloud-config
        password: fedora
        chpasswd: { expire: False }
    name: cloudinitdisk
```

Then, it is possible to obtain the logs from the virt-launcher output:

```bash
$ kubectl  get po
NAME                                  READY   STATUS    RESTARTS   AGE
virt-launcher-vmi-debug-tools-fk64q   3/3     Running   0          64s
$ kubectl  logs virt-launcher-vmi-debug-tools-fk64q
[..]
{"component":"virt-launcher","level":"info","msg":"QEMU_MONITOR_RECV_EVENT: mon=0x7faa8801f5d0 event={\"timestamp\": {\"seconds\": 1698324640, \"microseconds\": 523652}, \"event\": \"NIC_RX_FILTER_CHANGED\", \"data\": {\"name\": \"ua-default\", \"path\": \"/machine/peripheral/ua-default/virtio-backend\"}}","pos":"qemuMonitorJSONIOProcessLine:205","subcomponent":"libvirt","thread":"80","timestamp":"2023-10-26T12:50:40.523000Z"}
{"component":"virt-launcher","level":"info","msg":"QEMU_MONITOR_RECV_EVENT: mon=0x7faa8801f5d0 event={\"timestamp\": {\"seconds\": 1698324644, \"microseconds\": 165626}, \"event\": \"VSERPORT_CHANGE\", \"data\": {\"open\": true, \"id\": \"channel0\"}}","pos":"qemuMonitorJSONIOProcessLine:205","subcomponent":"libvirt","thread":"80","timestamp":"2023-10-26T12:50:44.165000Z"}
[..]
{"component":"virt-launcher","level":"info","msg":"QEMU_MONITOR_RECV_EVENT: mon=0x7faa8801f5d0 event={\"timestamp\": {\"seconds\": 1698324646, \"microseconds\": 707666}, \"event\": \"RTC_CHANGE\", \"data\": {\"offset\": 0, \"qom-path\": \"/machine/unattached/device[8]\"}}","pos":"qemuMonitorJSONIOProcessLine:205","subcomponent":"libvirt","thread":"80","timestamp":"2023-10-26T12:50:46.708000Z"}
[..]
```
