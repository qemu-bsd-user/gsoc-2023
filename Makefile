#
# Create special binaries that aren't shared (since qemu upstream doesn't support
# that yet) that also don't pull in all the 'fancy' stuff from libc that also has
# system calls we don't support yet. How we link has to vary between the different
# systems: for amd64 we have to link in libc for syscall and memset. For arm,
# we can't link in libc since it drags in too many things that are unimplemented
# so we have our own syscall implementation (note: it will only work for single
# threaded programs).
#
# So, each of the test programs uses system calls directly with very simplistic
# tests that are run out of _start. This avoids the dependency problem, while
# still making it relatively easy to test bsd-user until more of it is
# upstreamed.
#
ARM_CHROOT?=/vidpool/qemu/jails/jails/131armv7
QEMU_BIN?=${HOME}/git/qemu-blitz/00-blitz

CFLAGS=-Wno-invalid-noreturn # To make exit work without undue hassles
ARM_CFLAGS=--sysroot ${ARM_CHROOT} -target freebsd-armv7
.c:
	${CC} -g ${CFLAGS} -c ${.IMPSRC} -o amd64.${.PREFIX}.o
	ld -g -Bstatic -o amd64.${.TARGET} amd64.${.PREFIX}.o -L/usr/lib -lc
	${CC} -g ${CFLAGS} ${ARM_CFLAGS} -c ${.IMPSRC} -o arm.${.PREFIX}.o
	ld -g -Bstatic -o arm.${.TARGET} arm.${.PREFIX}.o arm/syscall.o
	touch ${.TARGET}

all: test-mmap
run: run-mmap

arm/syscall.o:
	${CC} ${CFLAGS} ${ARM_CFLAGS} -c ${.IMPSRC} -o ${.PREFIX}.o

SYSCALL=arm/syscall.o
gsoc-mmap: ${SYSCALL}

test-mmap: gsoc-mmap

test-mmap: .PHONY
	@echo ------------------------- Test mmap -------------------------
	@echo ==== amd64
	truss amd64.gsoc-mmap
	@echo ==== armv7
	${QEMU_BIN}/qemu-arm -strace -L ${ARM_CHROOT} arm.gsoc-mmap
clean:
	rm -f *.o amd64.* arm.* arm/*.o gsoc-mmap
