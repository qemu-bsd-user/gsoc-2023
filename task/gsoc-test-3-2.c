/*
 * Simple program that calls settimeofday and exists.
 */

#include <unistd.h>
#include <sys/syscall.h>
#include <sys/socket.h>
#include <errno.h>
#undef errno
extern int errno;

/*
 * Implement our own system calls using syscall. Pulling in these from libc
 * pulls in too much, and we can't test.
 */
ssize_t write(int fd, const void *buf, size_t n)
{
	return syscall(SYS_write, fd, buf, n);
}

int connect(int s, const struct sockaddr *name, socklen_t namelen)
{
	return syscall(SYS_connect, s, name, namelen);
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
	if (connect(-1, NULL, 0) == -1) {
		if (errno == EBADF)
			write(2, "connect failed as epxected\n", 27);
		else
			write(2, "connect failed not as epxected\n", 31);
		_exit(0);
	}
	write(1, "Connect somehow worked.\n", 24);
	_exit(0);
}
