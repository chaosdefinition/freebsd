/*
 * Based on the i387 version written by J.T. Conklin <jtc@netbsd.org>.
 * Public domain.
 */

#include <machine/asm.h>

/* RCSID("from: $NetBSD: e_remainderf.S,v 1.2 1995/05/08 23:49:47 jtc Exp $") */
__FBSDID("$FreeBSD$")

ENTRY(remainderf)
	VENKMAN_PAD(12)
	movss	%xmm0,-4(%rsp)
	movss	%xmm1,-8(%rsp)
	flds	-8(%rsp)
	flds	-4(%rsp)
1:
	VENKMAN_PAD(17)
	fprem1
	fstsw	%ax
	testw	$0x400,%ax
	jne	1b
	fstps	-4(%rsp)
	movss	-4(%rsp),%xmm0
	fstp	%st
	VENKMAN_RET
END(remainderf)

	.section .note.GNU-stack,"",%progbits
