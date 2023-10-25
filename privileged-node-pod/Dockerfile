ARG registry
ARG tag
FROM ${registry}/kubevirt/virt-launcher${tag} AS launcher

FROM quay.io/centos/centos:stream9

RUN yum install -y \
	gdb \
	kernel-devel \
	qemu-kvm-tools \
	strace \
	systemtap-client \
    && yum clean all
COPY --from=launcher / /
#COPY --from=launcher /usr/libexec/qemu-kvm /usr/libexec/qemu-kvm
