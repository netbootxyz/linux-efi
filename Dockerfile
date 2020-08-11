# build init from alpine base
FROM alpine:3.11 as initbasestage

ARG ALPINE_VERSION="3.11"

RUN \
 echo "**** install build deps ****" && \
 apk add --no-cache --upgrade \
	curl \
	tar \
	xz 

RUN \
 echo "**** install yq form edge/testing repository ****" && \
 apk add --no-cache --upgrade --repository=http://dl-cdn.alpinelinux.org/alpine/edge/testing \
	yq

RUN \
 echo "**** grab Alpine ****" && \
 mkdir -p /initrd && \
 LATEST=$(curl -sL \
	http://dl-cdn.alpinelinux.org/alpine/v${ALPINE_VERSION}/releases/x86_64/latest-releases.yaml \
	| yq read - [0].version) && \
 echo $LATEST && \
 curl -o \
        /rootfs.tar.gz -L \
        "http://dl-cdn.alpinelinux.org/alpine/v${ALPINE_VERSION}/releases/x86_64/alpine-minirootfs-${LATEST}-x86_64.tar.gz" && \
 tar xf \
	/rootfs.tar.gz \
	-C /initrd

RUN \
 echo "**** install initrd deps ****" && \
 apk --no-cache --upgrade --root /initrd add \
	bash \
	busybox-extras \
	curl \
	dialog \
	net-tools && \
 apk add --no-cache --upgrade --root /initrd --repository=http://dl-cdn.alpinelinux.org/alpine/edge/testing \
	kexec-tools

	
# build kernel
FROM alpine:3.11 as buildstage
ARG KERNEL_VERSION="5.4.14"
ARG THREADS=8
COPY --from=initbasestage /initrd /initrd
COPY /root /

RUN \
 echo "**** install build deps ****" && \
 apk add --no-cache --upgrade \
	bash \
	bison \
	diffutils \
	elfutils-dev \
	elfutils-libelf \
	findutils \
	flex \
	gcc \
	linux-headers \
	make \
	musl-dev \
	openssl \
	openssl-dev \
	perl-dev \
	python \
	tar \
	xz

RUN \
 echo "**** generate build output skeleton ****" && \
 mknod -m 622 /initrd/dev/console c 5 1 && \
 mknod -m 622 /initrd/dev/tty0 c 4 0 && \
 mv \
	/init \
	/kexec.sh \
	/initrd/ 

RUN \
 echo "**** download assets ****" && \
 wget https://cdn.kernel.org/pub/linux/kernel/v5.x/linux-${KERNEL_VERSION}.tar.xz && \
 tar xf linux-* && \
 rm -f *.tar.* 

RUN \
 echo "**** compile linux ****" && \
 cd /linux-* && \
 cp ../linuxconfig .config && \
 make -j ${THREADS} && \
 mv arch/x86/boot/bzImage /vmlinuz && \
 chmod 777 /vmlinuz

FROM alpine:3.11
COPY --from=buildstage /vmlinuz /vmlinuz
COPY /root/dump.sh /dump.sh
