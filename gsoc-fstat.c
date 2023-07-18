/*
 * Simple program that tests some stat related things.
 */

#include <unistd.h>
#include <sys/syscall.h>
#include <sys/fcntl.h>
#include <sys/stat.h>
#include <sys/param.h>
#include <sys/mount.h>
#include <dirent.h>
#include "util.h"

extern int errno;
#define EPERM 1
#define EINVAL 22

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
	struct stat sb;
	struct statfs fs;
	fhandle_t fhp;
	char buf[8192];

	zero(&sb, sizeof(sb));
	if (fstat(0, &sb) != 0)
		fail("fstat failed\n");
	if (sb.st_mode == 0)
		fail("fstat failed -- bad data\n");

	zero(&sb, sizeof(sb));
	if (fstatat(AT_FDCWD, "/", &sb, 0) != 0)
		fail("fstatat failed\n");
	if (!S_ISDIR(sb.st_mode))
		fail("fstatat failed -- bad data\n");

	zero(&fhp, sizeof(fhp));
	if (getfh("/", &fhp) == 0)
		fail("getfh should not have succeeded\n");
	if (errno != EPERM)
		fail("getfh bad errno\n");

	zero(&fs, sizeof(fs));
	if (statfs("/", &fs) != 0)
		fail("statfs / failed\n");
	if (fs.f_version != STATFS_VERSION)
		fail("statfs bad version\n");

	if (getdirentries(0, buf, sizeof(buf), NULL) == 0)
		fail("getdirentries should not have succeeded\n");
	if (errno != EINVAL) /* 0 == stdin which isn't a directory */
		fail("getdirentries bad errno\n");


	write(1, "Success!\n", 9);
	_exit(0);
}
