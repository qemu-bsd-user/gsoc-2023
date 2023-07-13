/*
 * SPDX-License-Identifier: BSD-3-Clause
 *
 * Copyright (c) 1990 The Regents of the University of California.
 * All rights reserved.
 */
/* From FreeBSD's libc/arm/SYS.h via NetBSD's derived from 4.4BSD lite */
/*
 * With CERROR inlined because this is always static, single threaded,
 * using bxcc.
 */
	
#include <machine/asm.h>
#include <sys/syscall.h>
#include <machine/swi.h>

/*
 * Arm system call convention:
 * System call in r7 (0 == indirect system call)
 * Args in r0..r6, like the arm calling convention. r6 is used only
 * for syscall to support the full 6 arguments.
 * On return, r0 and r1 have the result(s). r0 is typically all that's
 * used except for things like llseek.
 * If carry is set, then r0 has an error. By convention, we return -1
 * after saving the value to errno, so do that here.
 */
#define SYSTRAP(x)					\
	mov ip, r7;					\
	ldr r7, =SYS_ ## x;				\
	swi 0;						\
	mov r7, ip

#define RSYSCALL(x)					\
	ENTRY(x);					\
	SYSTRAP(x);					\
	bxcc	lr;					\
	ldr	r1, =errno;				\
	str	r0,[r1];				\
	mvn	r0, #0x00000000;			\
	mvn	r1, #0x00000000;			\
	RET;						\
	END(x);

	/* Not sure what's generating this, but hack it up */
	ENTRY(__aeabi_unwind_cpp_pr0)
	RET
	END(__aeabi_unwind_cpp_pr0)

	.bss
	.p2align	2
	.globl errno
errno:
	.long	0

RSYSCALL(syscall)

