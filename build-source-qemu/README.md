# Build KubeVirt with QEMU from source code
TODO

## Generate centos stream build environment

This example assumes you already fetch QEMU source code in the `qemu` directory.
```bash
$ cd qemu
$ git submodule update --init tests/lcitool/libvirt-ci
$ ./tests/lcitool/libvirt-ci/bin/lcitool \
    data-dir ./tests/lcitool dockerfile \
    entos-stream-9 qemu >  Dockerfile.centos-stream9
$ podman build -t qemu_build:centos-stream9 -f Dockerfile.centos-stream-9 .
$ podman run -ti -e QEMU_SRC=/src \
    -e BUILD_DIR=/src/build \
    -e QEMU_SRC=/src \
    -e INSTALL_DIR=/src/install \
    -e TARGET_LIST=x86_64-softmmu \
    -v $(pwd):/src:Z \
    -w /src  \
    --security-opt label=disable \
    qemu_build:centos-stream9
# Inside the container
$ mkdir -p /src/build
$ ../configure --target-list=x86_64-softmmu
```

## Build KubeVirt with the compiled QEMU binaries
TODO
