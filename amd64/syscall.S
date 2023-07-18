/*
 * SPDX-License-Identifier: BSD-3-Clause
 *
 * Copyright (c) 1990 The Regents of the University of California.
 * All rights reserved.
 *
 * This code is derived from software contributed to Berkeley by
 * William Jolitz.
 */
/* From FreeBSD's libc/amd64/SYS.h derived from 4.4BSD lite */

/*
 * With CERROR inlined because this is always static, single threaded.
 * 
 * i386 system calls return with carry set on error (and errno in
 * %eax). carry clear is success with return value in %eax and %edl.
 * 
 */
	
#include <machine/asm.h>
#include <sys/syscall.h>

#define	KERNCALL	movq %rcx, %r10; syscall

#define	RSYSCALL(name)				\
	ENTRY(name);				\
	mov	$SYS_##name,%eax; 		\
	KERNCALL;				\
	jnb	1f;				\
	movl	%eax, errno;			\
	movq	$-1,%rax;			\
	movq	$-1,%rdx;			\
1:						\
	ret;					\
	END(name)

	.bss
	.p2align	2
	.globl errno
errno:
	.long	0

RSYSCALL(syscall)
RSYSCALL(mmap)
RSYSCALL(mprotect)
RSYSCALL(munmap)
RSYSCALL(write)
RSYSCALL(fstat)
RSYSCALL(fstatat)
RSYSCALL(getfh)
RSYSCALL(statfs)
RSYSCALL(getdirentries)
RSYSCALL(fcntl)
