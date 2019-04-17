/*
 * Written by J.T. Conklin <jtc@acorntoolworks.com>
 * Public domain.
 */

#include <machine/asm.h>
__FBSDID("$FreeBSD$");

#if 0
	RCSID("$NetBSD: strcmp.S,v 1.3 2004/07/19 20:04:41 drochner Exp $")
#endif

ENTRY(strcmp)
	/*
	 * Align s1 to word boundary.
	 * Consider unrolling loop?
	 */
.Ls1align:
	VENKMAN_PAD(2)
	testb	$7,%dil
	je	.Ls1aligned
	movb	(%rdi),%al
	incq	%rdi
	movb	(%rsi),%dl
	incq	%rsi
	testb	%al,%al
	je	.Ldone
	cmpb	%al,%dl
	VENKMAN_PAD(21)
	je	.Ls1align
	jmp	.Ldone

	/*
	 * Check whether s2 is aligned to a word boundary.  If it is, we
	 * can compare by words.  Otherwise we have to compare by bytes.
	 */
.Ls1aligned:
	VENKMAN_PAD(8)
	testb	$7,%sil
	jne	.Lbyte_loop

	movabsq	$0x0101010101010101,%r8
	subq	$8,%rdi
	VENKMAN_PAD(18)
	movabsq	$0x8080808080808080,%r9
	subq	$8,%rsi

	.align	4
.Lword_loop:
	VENKMAN_PAD(1)
	movq	8(%rdi),%rax
	addq	$8,%rdi
	movq	8(%rsi),%rdx
	addq	$8,%rsi
	cmpq	%rax,%rdx
	jne	.Lbyte_loop
	subq	%r8,%rdx
	notq	%rax
	VENKMAN_PAD(20)
	andq	%rax,%rdx
	testq	%r9,%rdx
	je	.Lword_loop

	.align	4
.Lbyte_loop:
	VENKMAN_PAD(6)
	movb	(%rdi),%al
	incq	%rdi
	movb	(%rsi),%dl
	incq	%rsi
	testb	%al,%al
	je	.Ldone
	cmpb	%al,%dl
	je	.Lbyte_loop

.Ldone:
	movzbq	%al,%rax
	movzbq	%dl,%rdx
	subq	%rdx,%rax
	VENKMAN_RET
END(strcmp)

	.section .note.GNU-stack,"",%progbits
