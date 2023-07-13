/*
 * Simple program that tests some mmap related things.
 */

#include <sys/syscall.h>
#include <sys/mman.h>

long syscall(int, ...);
typedef __ssize_t ssize_t;
typedef __uintptr_t uintptr_t;

/*
 * Implement our own system calls using syscall. Pulling in these from libc
 * pulls in too much, and we can't test.
 */
ssize_t write(int fd, const void *buf, size_t n)
{
	return syscall(SYS_write, fd, buf, n);
}

void *
mmap(void *addr, size_t len, int prot, int flags, int fd, off_t offset)
{
	return (void *)(uintptr_t)syscall(SYS_mmap, addr, len, prot, flags, fd, offset);
}

int
mprotect(void *addr, size_t len, int prot)
{
	return syscall(SYS_mprotect, addr, len, prot);
}

int
munmap(void *addr, size_t len)
{
	return syscall(SYS_munmap, addr, len);
}


void _exit(int status)
{
	syscall(SYS_exit, status);
}

int slen(const char *str)
{
	int len = 0;

	while (*str++) len++;
	return (len);
}

void fail(const char *str)
{
	write(1, str, slen(str));
	_exit(1);
}

/*
 * The FreeBSD entry point to a progam is _start. Normally, this is a wrapper
 * around main() that calls a lot of things to setup the rich environment that
 * main needs. However, qemu-project's master branch doesn't yet implement all
 * the system calls needed to complete that successfully yet so we have to go
 * old-school. Likewise, we cannot use stdio, since it pulls in too much.
 */
int _start(void)
{
	void *addr;
	int *i;

	addr = mmap(0, 8192, PROT_READ | PROT_WRITE | PROT_EXEC, MAP_ANON, -1, 0);
	if (addr == MAP_FAILED) {
		fail("mmap failed unexpectedly\n");
	}
	i = (int *)addr;
	*i = 1;
	mprotect(addr, 8192, PROT_READ);
	if (*i != 1) {
		fail("*i is wrong after mprotect\n");
	}
	if (munmap(addr, 8192) != 0) {
		fail("munmap failed\n");
	}
	write(1, "Success!\n", 9);
	_exit(0);
}
