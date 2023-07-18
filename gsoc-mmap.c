/*
 * Simple program that tests some mmap related things.
 */

#include <unistd.h>
#include <sys/syscall.h>
#include <sys/mman.h>
#include "util.h"

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

	addr = mmap(0, 8192, PROT_READ | PROT_WRITE, MAP_ANON, -1, 0);
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
