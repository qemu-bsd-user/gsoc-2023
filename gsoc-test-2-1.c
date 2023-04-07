/*
 * Simple program that calls settimeofday and exists.
 */

#include <unistd.h>
#include <sys/syscall.h>
#include <time.h>

/*
 * Implement our own system calls using syscall. Pulling in these from libc
 * pulls in too much, and we can't test.
 */
ssize_t write(int fd, const void *buf, size_t n)
{
	return syscall(SYS_write, fd, buf, n);
}

int nanosleep(const struct timespec *rqtp, struct timespec *rmtp)
{
	return syscall(SYS_nanosleep, rqtp, rmtp);
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
	struct timespec ts = { 1, 0 };
	struct timespec tm;

	if (nanosleep(&ts, &tm) == -1) {
		write(2, "nanosleep failed\n", 17);
		_exit(0);
	}
	write(1, "It worked.\n", 11);
	_exit(0);
}
