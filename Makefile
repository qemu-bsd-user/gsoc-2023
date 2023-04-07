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
	${CC} ${CFLAGS} -c ${.IMPSRC} -o amd64.${.PREFIX}.o
	ld -Bstatic -o amd64.${.TARGET} amd64.${.PREFIX}.o -L/usr/lib -lc
	${CC} ${CFLAGS} ${ARM_CFLAGS} -c ${.IMPSRC} -o arm.${.PREFIX}.o
	ld -Bstatic -o arm.${.TARGET} arm.${.PREFIX}.o arm/syscall.o
	touch ${.TARGET}

all: test-1 test-2 # test-3 test-4
run: run-test-1 run-test-2

arm/syscall.o:
	${CC} ${CFLAGS} ${ARM_CFLAGS} -c ${.IMPSRC} -o ${.PREFIX}.o

SYSCALL=arm/syscall.o
gsoc-test-1-1: ${SYSCALL}
gsoc-test-1-2: ${SYSCALL}
gsoc-test-1-3: ${SYSCALL}
gsoc-test-1-4: ${SYSCALL}
gsoc-test-2-1: ${SYSCALL}
gsoc-test-2-2: ${SYSCALL}
gsoc-test-2-3: ${SYSCALL}
gsoc-test-2-4: ${SYSCALL}

test-1: gsoc-test-1-1 gsoc-test-1-2 gsoc-test-1-3 gsoc-test-1-4
test-2: gsoc-test-2-1 gsoc-test-2-2 gsoc-test-2-3 gsoc-test-2-4

run-test-1: .PHONY
	@echo ------------------------- Test 1-1 -------------------------
	@echo ==== amd64
	truss amd64.gsoc-test-1-1
	@echo ==== armv7
	${QEMU_BIN}/qemu-arm -strace -L ${ARM_CHROOT} arm.gsoc-test-1-1
	@echo ------------------------- Test 1-2 -------------------------
	@echo ==== amd64
	truss amd64.gsoc-test-1-2
	@echo ==== armv7
	${QEMU_BIN}/qemu-arm -strace -L ${ARM_CHROOT} arm.gsoc-test-1-2
	@echo ------------------------- Test 1-3 -------------------------
	@echo ==== amd64
	truss amd64.gsoc-test-1-3
	@echo ==== armv7
	${QEMU_BIN}/qemu-arm -strace -L ${ARM_CHROOT} arm.gsoc-test-1-3
	@echo ------------------------- Test 1-4 -------------------------
	@echo ==== amd64
	truss amd64.gsoc-test-1-4
	@echo ==== armv7
	${QEMU_BIN}/qemu-arm -strace -L ${ARM_CHROOT} arm.gsoc-test-1-4

run-test-2: .PHONY
	@echo ------------------------- Test 2-1 -------------------------
	@echo ==== amd64
	truss amd64.gsoc-test-2-1
	@echo ==== armv7
	${QEMU_BIN}/qemu-arm -strace -L ${ARM_CHROOT} arm.gsoc-test-2-1
	@echo ------------------------- Test 2-2 -------------------------
	@echo ==== amd64
	truss amd64.gsoc-test-2-2
	@echo ==== armv7
	${QEMU_BIN}/qemu-arm -strace -L ${ARM_CHROOT} arm.gsoc-test-2-2
	@echo ------------------------- Test 2-3 -------------------------
	@echo ==== amd64
	truss amd64.gsoc-test-2-3
	@echo ==== armv7
	${QEMU_BIN}/qemu-arm -strace -L ${ARM_CHROOT} arm.gsoc-test-2-3
	@echo ------------------------- Test 2-4 -------------------------
	@echo ==== amd64
	truss amd64.gsoc-test-2-4
	@echo ==== armv7
	${QEMU_BIN}/qemu-arm -strace -L ${ARM_CHROOT} arm.gsoc-test-2-4

clean:
	rm -f *.o amd64.* arm.* arm/*.o gsoc-test-?-?
