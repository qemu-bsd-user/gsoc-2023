void zero(void *ptr, int len)
{
	unsigned char *uc = ptr;

	for (int i = 0; i < len; i++)
		uc[i] = 0;
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
