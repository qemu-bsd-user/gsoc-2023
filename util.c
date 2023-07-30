#include <unistd.h>
#include <sys/syscall.h>
#include "util.h"

/*
 * Implement our own system calls using syscall. Pulling in these from libc
 * pulls in too much, and we can't test.
 */
ssize_t write(int fd, const void *buf, size_t n)
{
       return syscall(SYS_write, fd, buf, n);
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
