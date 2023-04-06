/*
 * Simple program that calls settimeofday and exists.
 */

#include <unistd.h>
#include <sys/syscall.h>
#include <sys/time.h>

/*
 * Implement our own system calls using syscall. Pulling in these from libc
 * pulls in too much, and we can't test.
 */
ssize_t write(int fd, const void *buf, size_t n)
{
	return syscall(SYS_write, fd, buf, n);
}

int settimeofday(const struct timeval *tp, const struct timezone *tzp)
{
	return syscall(SYS_settimeofday, tp, tzp);
}

void _exit(int status)
{
	syscall(SYS_exit, status);
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
	struct timeval tv = { 1, 0 };
	struct timezone tz = { 0 };

	if (settimeofday(&tv, &tz) == -1) {
		write(2, "gettimeofday failed, as expected\n", 33);
		_exit(0);
	}
	write(1, "Oh My! It worked. System time messed up.\n", 41);
	_exit(0);
}
