#
# Create special binaries that aren't shared (since qemu upstream doesn't support
# that yet) that also don't pull in all the 'fancy' stuff from libc that also has
# system calls we don't support yet.
#
# So, each of the test programs uses system calls directly with very simplistic
# tests that are run out of _start. This avoids the problem, while still making
# it relatively easy to test bsd-user until more of it is upstreamed.
#
ARM_CHROOT?=/vidpool/qemu/jails/jails/131armv7
QEMU_BIN?=${HOME}/git/qemu-blitz/00-blitz

CFLAGS="-Wno-invalid-noreturn"
ARM_CFLAGS=--sysroot ${ARM_CHROOT} -target freebsd-armv7
.c:
	${CC} ${CFLAGS} -c ${.IMPSRC} -o amd64.${.PREFIX}.o
	ld -Bstatic -o amd64.${.TARGET} amd64.${.PREFIX}.o -L/usr/lib -lc
	${CC} ${CFLAGS} ${ARM_CFLAGS} -c ${.IMPSRC} -o arm.${.PREFIX}.o
	ld -Bstatic -o arm.${.TARGET} arm.${.PREFIX}.o arm/syscall.o
	touch ${.TARGET}

all: test-1 # test-2 test-3 test-4
run: run-test-1

arm/syscall.o:
	${CC} ${CFLAGS} ${ARM_CFLAGS} -c ${.IMPSRC} -o ${.PREFIX}.o

gsoc-test-1-1: arm/syscall.o
gsoc-test-1-2: arm/syscall.o
gsoc-test-1-3: arm/syscall.o
gsoc-test-1-4: arm/syscall.o

test-1: gsoc-test-1-1 gsoc-test-1-2 gsoc-test-1-3 gsoc-test-1-4

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

clean:
	rm -f *.o amd64.* arm.* arm/*.o
