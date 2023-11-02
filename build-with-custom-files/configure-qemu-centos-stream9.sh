#!/bin/bash -xe

../configure \
	--cc=clang --cxx=/bin/false --prefix=/usr \
	--libdir=/usr/lib64 --datadir=/usr/share --sysconfdir=/etc \
	--interp-prefix=/usr/qemu-%M --localstatedir=/var --docdir=/usr/share/doc \
	--with-pkgversion=qemu-kvm-8.1.0-3.el9 \
	--with-suffix=qemu-kvm \
	--firmwarepath=/usr/share/qemu-firmware:/usr/share/ipxe/qemu:/usr/share/seavgabios:/usr/share/seabios \
	--enable-trace-backends=dtrace\
	--with-coroutine=ucontext --tls-priority=@QEMU,SYSTEM \
	--audio-drv-list= --disable-alsa --disable-attr \
	--disable-auth-pam --disable-avx2 --disable-avx512f --disable-avx512bw \
	--disable-blkio --disable-block-drv-whitelist-in-tools \
	--disable-bochs --disable-bpf --disable-brlapi --disable-bsd-user \
	--disable-bzip2 --disable-cap-ng \
	--disable-capstone --disable-cfi \
	--disable-cfi-debug --disable-cloop --disable-cocoa --disable-coreaudio \
	--disable-coroutine-pool --disable-crypto-afalg --disable-curl \
	--disable-curses --disable-dbus-display --disable-debug-info \
	--disable-debug-mutex --disable-debug-tcg \
	--disable-dmg --disable-docs --disable-download \
	--disable-dsound --disable-fdt --disable-fuse \
	--disable-fuse-lseek --disable-gcrypt --disable-gettext \
	--disable-gio --disable-glusterfs --disable-gnutls --disable-gtk \
	--disable-guest-agent --disable-guest-agent-msi \
	--disable-hvf --disable-iconv --disable-jack --disable-kvm \
	--disable-l2tpv3 --disable-libdaxctl --disable-libdw \
	--disable-libiscsi --disable-libnfs \
	--disable-libpmem --disable-libssh --disable-libudev \
	--disable-libusb --disable-libvduse \
	--disable-linux-aio --disable-linux-io-uring \
	--disable-linux-user --disable-live-block-migration \
	--disable-lto --disable-lzfse --disable-lzo --disable-malloc-trim --disable-membarrier --disable-modules \
	--disable-module-upgrades --disable-mpath \
	--disable-multiprocess --disable-netmap --disable-nettle --disable-numa \
	--disable-nvmm --disable-opengl --disable-oss \
	--disable-pa --disable-parallels --disable-pie --disable-pvrdma \
	--disable-qcow1 --disable-qed --disable-qga-vss --disable-qom-cast-debug --disable-rbd --disable-rdma \
	--disable-replication --disable-rng-none --disable-safe-stack \
	--disable-sanitizers --disable-sdl --disable-sdl-image --disable-seccomp --disable-selinux --disable-slirp \
	--disable-slirp-smbd --disable-smartcard --disable-snappy --disable-sndio --disable-sparse --disable-spice \
	--disable-spice-protocol --disable-strip --disable-system --disable-tcg --disable-tools --disable-tpm \
	--disable-u2f --disable-usb-redir --disable-user --disable-vde --disable-vdi --disable-vduse-blk-export \
	--disable-vhost-crypto --disable-vhost-kernel --disable-vhost-net --disable-vhost-user \
	--disable-vhost-user-blk-server --disable-vhost-vdpa --disable-virglrenderer --disable-virtfs --disable-vnc \
	--disable-vnc-jpeg --disable-png --disable-vnc-sasl --disable-vte --disable-vvfat \
	--disable-werror --disable-whpx --disable-xen --disable-xen-pci-passthrough --disable-xkbcommon --disable-zstd \
	--without-default-devices \
	--target-list=x86_64-softmmu \
	--block-drv-rw-whitelist=qcow2,raw,file,host_device,nbd,iscsi,rbd,blkdebug,luks,null-co,nvme,copy-on-read,throttle,compress,virtio-blk-vhost-vdpa,virtio-blk-vfio-pci,virtio-blk-vhost-user,io_uring,nvme-io_uring \
	--block-drv-ro-whitelist=vdi,vmdk,vhdx,vpc,https \
	--enable-attr \
	--enable-blkio \
	--enable-cap-ng \
	--enable-capstone \
	--enable-coroutine-pool --enable-curl --enable-dbus-display --enable-debug-info \
	--enable-docs --enable-fdt=system --enable-gio --enable-gnutls --enable-guest-agent \
	--enable-iconv --enable-kvm --enable-libpmem --enable-libusb --enable-libudev --enable-linux-aio \
	--enable-linux-io-uring --enable-lzo --enable-malloc-trim --enable-modules --enable-mpath --enable-numa \
	--enable-opengl --enable-pa --enable-pie --enable-rbd --enable-rdma --enable-seccomp --enable-selinux \
	--enable-slirp --enable-snappy --enable-spice-protocol --enable-system --enable-tcg --enable-tools \
	--enable-tpm --enable-usb-redir --enable-vdi --enable-vhost-kernel --enable-vhost-net \
	--enable-vhost-user --enable-vhost-user-blk-server --enable-vhost-vdpa --enable-vnc\
	--enable-png --enable-vnc-sasl \
	--enable-werror --enable-xkbcommon --enable-safe-stack \
	--libexecdir=/usr/libexec \
	'--extra-ldflags=-Wl,-z,relro -Wl,--as-needed  -Wl,-z,now   -flto=thin' '--extra-cflags=-O2 -flto=thin -fexceptions -g -grecord-gcc-switches -pipe -Wall -Werror=format-security -Wp,-D_FORTIFY_SOURCE=2 -Wp,-D_GLIBCXX_ASSERTIONS -fstack-protector-strong -m64 -march=x86-64-v2 -mtune=generic -fasynchronous-unwind-tables -fstack-clash-protection -fcf-protection -Wno-string-plus-int' \

#'--extra-ldflags=-Wl,-z,relro -Wl,--as-needed  -Wl,-z,now   -flto=thin' '--extra-cflags=-O2 -flto=thin -fexceptions -g -grecord-gcc-switches -pipe -Wall -Werror=format-security -Wp,-D_FORTIFY_SOURCE=2 -Wp,-D_GLIBCXX_ASSERTIONS --config /usr/lib/rpm/redhat/redhat-hardened-clang.cfg -fstack-protector-strong -m64 -march=x86-64-v2 -mtune=generic -fasynchronous-unwind-tables -fstack-clash-protection -fcf-protection -Wno-string-plus-int' \

# Flags not recognized or with errors
# --disable-hax \
# --with-devices-x86_64=x86_64-rh-devices\
