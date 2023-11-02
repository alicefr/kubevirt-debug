# Build KubeVirt with custom rpms, files and binaries

The KubeVirt building system relies on [baze](https://bazel.build/) to compile and assemble the container filesystem. As a developer, you might face situations where you need to build KubeVirt with a custom rpms or binary.
In order to have the custom file, you need to configure the kubevirt bazel WORKSPACE file or the BUILD.bazel file of the image containing the file.

This guide reports some handy examples how to install custom rpms, binaries and files.

## Build custom libvirt rpms from source code

This setup illustrates how to build and integrate custom libvirt rpms in KubeVirt.

### Build libvirt and the rpms

If you already have the rpms available you can skip this section.

  * Create a volume for the rpms that will be shared with the http server container
```bash
$ docker volume create rpms
```
  * Start build environment for libvirt source code. This setup uses the [container images](https://gitlab.com/libvirt/libvirt/container_registry) used by the libvirt CI. This setup is just an example for reference, and this can be achieved in many ways.
Start container inside the libvirt directory with your changes and enter in the build container
```bash
$ docker run -td -w /libvirt-src --security-opt label=disable --name libvirt-build -v $(pwd):/libvirt-src -v rpms:/root/rpmbuild/RPMS registry.gitlab.com/libvirt/libvirt/ci-centos-stream-8
# Exec in the container
$ docker exec -ti libvirt-build bash
```
  * Steps inside the build environment to obtain the rpms. More details at https://libvirt.org/compiling.html
```bash
# Make sure we get all the latest packages
$ dnf update -y
# Compile and create the rpms
$ meson build
$ ninja -C build dist
```
The build environment might require additional dependencies and this may vary based on the libvirt version:
```bash
$ dnf install -y createrepo hostname
$ rpmbuild -ta    /libvirt-src/build/meson-dist/libvirt-*.tar.xz
# Create repomd.xml
$ createrepo -v  /root/rpmbuild/RPMS/x86_64
```

### Start the http server for the rpms

If you want to use other publicly available rpms or a private repository that is reachable from the KubeVirt build container, you can skip this section and substitute the custom repository.
The http server container allows to expose locally the rpms to the KubeVirt build server. It is reachable by the IP address from the KubeVirt build container.
  * Start the http server with the `rpms` volume where we created the rpms in the previous step (otherwise pass the directory that contains the rpms)
```bash
$ docker run -dit --name rpms-http-server -p 80 -v rpms:/usr/local/apache2/htdocs/ httpd:latest
```
  * Get the IP of the container `rpms-http-server`
```bash
$ docker inspect -f '{{range.NetworkSettings.Networks}}{{.IPAddress}}{{end}}' rpms-http-server
172.17.0.4
```
### Add the custom repository to KubeVirt

  * Create `custom-repo.yaml` pointing to the local http server:
```yaml
repositories:
- arch: x86_64
  baseurl: http://172.17.0.4:80/x86_64/ # The IP corresponding to the rpms-http-server container
  name: custom-build
  gpgcheck: 0
  repo_gpgcheck: 0
```
  * Update the rpms in KubeVirt repository.
  * If you only want to update a single architecture, set `SINGLE_ARCH="x86_64"`.
  * It is sometimes necessary to change `basesystem` when using custom rpms packages. This can be achieved by setting `BASESYSTEM=xyz` env variable.
  * If you want to change version of some packages you can set env variables. See [`hack/rpm-deps.sh`](/hack/rpm-deps.sh) script for all variables that can be changed.
```bash
$ make CUSTOM_REPO=custom-repo.yaml LIBVIRT_VERSION=0:7.2.0-1.el8 rpm-deps
```
Afterwards, the `WORKSPACE` and `rpm/BUILD.bazel` are automatically updated and KubeVirt can be built with the custom rpms.


## Build KubeVirt using local tarballs

KubeVirt system strongly relies on bazel and it is built mostly by files hosted remotely. It is handy to be able to build KubeVirt using custom local files when you want to replace a file with your local copy. For example for replacing an rpm or, as illustrated below, the libguestfs-appliance, or a binary.

The guide [custom-rpms section](#build-custom-libvirt-rpms-from-source-code) already explains how to build KubeVirt using custom rpms. Here, we specifically focus in using local files, but the 2 methods can be combined based on your needs. The custom-rpms method might fit better for the cases where you also want to resolve the package dependencies automatically.

In the following example, we illustrate how to replace the `libguestfs-appliance` file, but it is valid for any cases using remote tarballs.

1. Copy your custom appliance file in the building container. It is enough to have the directory or the file in the kubevirt directory, and it will be automatically synchronized by the `hack/dockerized` command

```bash
# Local directory with the custom files
$ ls output/
latest-version.txt  libguestfs-appliance-1.48.4-qcow2-linux-5.14.0-183-centos9.tar.xz
# Sync build container and check the file
$ ./hack/dockerized ls output
go version go1.19.2 linux/amd64

latest-version.txt  libguestfs-appliance-1.48.4-qcow2-linux-5.14.0-183-centos9.tar.xz
```
Modify the WORKSPACE to point to your custom appliance:

2. Calculate the checksum of the file:
```bash
$  sha256sum output/libguestfs-appliance-1.48.4-qcow2-linux-5.14.0-183-centos9.tar.xz
6bb9db7a4c83992f3e5fadb1dd51080d8cf53aabe6b546ebee6e2e9a52c569bb  output/libguestfs-appliance-1.48.4-qcow2-linux-5.14.0-183-centos9.tar.xz
```
3. Point the WORKSPACE to the file and replace the checksum. In the URL, we need to use the `file` protocol and the file is located in the KubeVirt workspace `/root/go/src/kubevirt.io/kubevirt` + the path of your custom file.

```diff
diff --git a/WORKSPACE b/WORKSPACE
index fa717cdcd..a27b05d29 100644
--- a/WORKSPACE
+++ b/WORKSPACE
@@ -386,9 +386,9 @@ http_archive(

 http_file(
     name = "libguestfs-appliance",
-    sha256 = "59fe17973fdaf4d969203b66b1446d855d406aea0736d06ee1cd624100942c8f",
+    sha256 = "6bb9db7a4c83992f3e5fadb1dd51080d8cf53aabe6b546ebee6e2e9a52c569bb",
     urls = [
-        "https://storage.googleapis.com/kubevirt-prow/devel/release/kubevirt/libguestfs-appliance/appliance-1.48.4-linux-5.14.0-176-centos9.tar.xz",
+        "file:///root/go/src/kubevirt.io/kubevirt/output/libguestfs-appliance-1.48.4-qcow2-linux-5.14.0-183-centos9.tar.xz",
     ],
 )
```
4. Build the image with your custom appliance `make bazel-build-images`


## Build KubeVirt with QEMU from source code

In certain cases, developers might want to change custom QEMU builds with KubeVirt. For example, in a case of a fix or code changes not yet presented in the official QEMU version used by KubeVirt.

This guide covers how to build QEMU in a centos stream 9 container and how to use the compiled binaries with the KubeVirt building system.

### Generate centos-stream build environment

This example assumes you already fetch QEMU source code in the `qemu` directory.

At the moment of writing QEMU didn't support the centos-straem 9 in its CI, but the [`lcitool`](https://github.com/libvirt/libvirt-ci) from libvirt can helps us generating the base Dockerfile for compiling QEMU.

```bash
$ cd qemu
$ git submodule update --init tests/lcitool/libvirt-ci
$ ./tests/lcitool/libvirt-ci/bin/lcitool --data-dir ./tests/lcitool \
    dockerfile centos-stream-9 qemu > Dockerfile.centos-stream9
```

The script `configure-qemu-centos-stream9.sh` helps you to configure the QEMU build to be compatible with the centos stream container image used by KubeVirt. However, you can always tune this script with the options needed by your case.

For building QEMU, we are going to start the build environment container with the QEMU source copy. Hence, we can copy the script `configure-qemu-centos-stream9.sh` into the `qemu` directory to be available during the compilation.

For this example, there were 3 packages missing in the generated Dockerfile, and you can create a build environment for this example by using the dockerfile `Dockerfile.centos-stream-9` from this repository.

```bash
$ podman build -t qemu_build:centos-stream9 -f Dockerfile.centos-stream-9 .
```

Once the build environment is ready, we can use it as base for configuring and building QEMU from source.
```bash
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
$ cd /src/build
$ ../configure-qemu-centos-stream9.sh
$ make
```

### Build KubeVirt with the compiled QEMU binaries

This section combines binaries built in the previous step with the custom local file method explained in the [previous section](#build-kubeVirt-using-local-tarballs).

Firstly, we neeed to calculate shasum of the qemu binary:
```bash
$ sha256sum build/qemu-system-x86_64
463f6f11480d5d2453f84f3727a8a3f939171b4e6c6942acaed4def39b23890d  build/qemu-system-x86_64

```

We can copy the binary inside the kubevirt source directory. In this way, it will automatically copy the binaries inside the build container. In this example, it will be located into the `build` directory.

For building the `virt-launcher` image with the custom binary, it is necessary to add the binary in the `WORKSPACE` and in the virt-launcher `BUILD.bazel`:
```diff
--- a/WORKSPACE
+++ b/WORKSPACE
@@ -5183,3 +5183,12 @@ rpm(
         "https://storage.googleapis.com/builddeps/8a9f51eac4658d4d05c883cbef15ae7b08acf274a46b4c4d9d28a3e2ae9f5b47",
     ],
 )
+
+http_file(
+    name = "custom-qemu",
+    downloaded_file_path = "qemu-kvm",
+    sha256 = "463f6f11480d5d2453f84f3727a8a3f939171b4e6c6942acaed4def39b23890d",
+    urls = [
+        "file:///root/go/src/kubevirt.io/kubevirt/build/qemu-system-x86_64",
+    ],
+)
diff --git a/cmd/virt-launcher/BUILD.bazel b/cmd/virt-launcher/BUILD.bazel
index d796b77b8..9a190e60e 100644
--- a/cmd/virt-launcher/BUILD.bazel
+++ b/cmd/virt-launcher/BUILD.bazel
@@ -165,6 +165,15 @@ pkg_tar(
     owner = "0.0",
 )

+pkg_tar(
+    name = "custom-qemu-build",
+    srcs = ["@custom-qemu//file"],
+    mode = "0755",
+    owner = "0.0",
+    package_dir = "/usr/libexec",
+    visibility = ["//visibility:public"],
+)
+
 container_image(
     name = "version-container",
     directory = "/",
@@ -182,6 +191,7 @@ container_image(
             ":passwd-tar",
             ":nsswitch-tar",
             ":qemu-kvm-modules-dir-tar",
+            ":custom-qemu-build",
             "//rpm:launcherbase_x86_64",
         ],
     }),
```

Then, build the images with:
```bash
make bazel-build-images
```
