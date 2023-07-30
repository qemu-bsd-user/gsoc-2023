#include <sys/syscall.h>
#include <unistd.h>

char **environ;
char *__progname;

int _start()
{
	syscall(SYS_write, 1, "hello world\n", 12);
	syscall(SYS_exit, 0);
	return 0;
}

