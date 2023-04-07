/*
 * SPDX-License-Identifier: BSD-3-Clause
 *
 * Copyright (c) 1990 The Regents of the University of California.
 * All rights reserved.
 *
 * This code is derived from software contributed to Berkeley by
 * William Jolitz.
 */
/* From FreeBSD's libc/i386/SYS.h derived from 4.4BSD lite */

/*
 * With CERROR inlined because this is always static, single threaded.
 * 
 * i386 system calls return with carry set on error (and errno in
 * %eax). carry clear is success with return value in %eax and %edl.
 * 
 */
	
#include <machine/asm.h>
#include <sys/syscall.h>

#define	RSYSCALL(name)				\
	ENTRY(name);				\
	mov	$SYS_##name,%eax; 		\
	KERNCALL;				\
	jnb	1f;				\
	movl	%eax, errno;			\
	movl	$-1,%eax;			\
	movl	$-1,%edx;			\
1:						\
	ret;					\
	END(name)

	.bss
	.p2align	2
	.globl errno
errno:
	.long	0

RSYSCALL(syscall)
	
