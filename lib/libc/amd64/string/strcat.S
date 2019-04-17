/*
 * Written by J.T. Conklin <jtc@acorntoolworks.com>
 * Public domain.
 */

#include <machine/asm.h>
__FBSDID("$FreeBSD$");

#if 0
	RCSID("$NetBSD: strcat.S,v 1.4 2004/07/26 18:51:21 drochner Exp $")
#endif

ENTRY(strcat)
	VENKMAN_PAD(9)
	movq	%rdi,%rax
	movabsq	$0x0101010101010101,%r8
	movabsq	$0x8080808080808080,%r9

	/*
	 * Align destination to word boundary.
	 * Consider unrolling loop?
	 */
.Lscan:
.Lscan_align:
	VENKMAN_PAD(5)
	testb	$7,%dil
	je	.Lscan_aligned
	cmpb	$0,(%rdi)
	je	.Lcopy
	incq	%rdi
	jmp	.Lscan_align

	.align	4
.Lscan_aligned:
.Lscan_loop:
	VENKMAN_PAD(3)
	movq	(%rdi),%rdx
	addq	$8,%rdi
	subq	%r8,%rdx
	testq	%r9,%rdx
	je	.Lscan_loop

	/*
	 * In rare cases, the above loop may exit prematurely. We must
	 * return to the loop if none of the bytes in the word equal 0.
	 */

	cmpb	$0,-8(%rdi)	/* 1st byte == 0? */
	jne	1f
	VENKMAN_PAD(23)
	subq	$8,%rdi
	jmp	.Lcopy

1:
	VENKMAN_PAD(13)
	cmpb	$0,-7(%rdi)	/* 2nd byte == 0? */
	jne	1f
	subq	$7,%rdi
	jmp	.Lcopy

1:
	VENKMAN_PAD(13)
	cmpb	$0,-6(%rdi)	/* 3rd byte == 0? */
	jne	1f
	subq	$6,%rdi
	jmp	.Lcopy

1:
	VENKMAN_PAD(13)
	cmpb	$0,-5(%rdi)	/* 4th byte == 0? */
	jne	1f
	subq	$5,%rdi
	jmp	.Lcopy

1:
	VENKMAN_PAD(13)
	cmpb	$0,-4(%rdi)	/* 5th byte == 0? */
	jne	1f
	subq	$4,%rdi
	jmp	.Lcopy

1:
	VENKMAN_PAD(13)
	cmpb	$0,-3(%rdi)	/* 6th byte == 0? */
	jne	1f
	subq	$3,%rdi
	jmp	.Lcopy

1:
	VENKMAN_PAD(13)
	cmpb	$0,-2(%rdi)	/* 7th byte == 0? */
	jne	1f
	subq	$2,%rdi
	jmp	.Lcopy

1:
	VENKMAN_PAD(18)
	cmpb	$0,-1(%rdi)	/* 8th byte == 0? */
	jne	.Lscan_loop
	subq	$1,%rdi

	/*
	 * Align source to a word boundary.
	 * Consider unrolling loop?
	 */
.Lcopy:
.Lcopy_align:
	VENKMAN_PAD(4)
	testb	$7,%sil
	je	.Lcopy_aligned
	movb	(%rsi),%dl
	incq	%rsi
	movb	%dl,(%rdi)
	incq	%rdi
	testb	%dl,%dl
	jne	.Lcopy_align
	VENKMAN_PAD(25)
	VENKMAN_RET

	.align	4
.Lcopy_loop:
	VENKMAN_PAD(25)
	movq	%rdx,(%rdi)
	addq	$8,%rdi
.Lcopy_aligned:
	VENKMAN_PAD(3)
	movq	(%rsi),%rdx
	movq	%rdx,%rcx
	addq	$8,%rsi
	subq	%r8,%rcx
	testq	%r9,%rcx
	je	.Lcopy_loop

	/*
	 * In rare cases, the above loop may exit prematurely. We must
	 * return to the loop if none of the bytes in the word equal 0.
	 */

	movb	%dl,(%rdi)
	incq	%rdi
	testb	%dl,%dl		/* 1st byte == 0? */
	je	.Ldone

	shrq	$8,%rdx
	movb	%dl,(%rdi)
	incq	%rdi
	testb	%dl,%dl		/* 2nd byte == 0? */
	je	.Ldone

	shrq	$8,%rdx
	movb	%dl,(%rdi)
	incq	%rdi
	VENKMAN_PAD(1)
	testb	%dl,%dl		/* 3rd byte == 0? */
	je	.Ldone

	shrq	$8,%rdx
	movb	%dl,(%rdi)
	incq	%rdi
	testb	%dl,%dl		/* 4th byte == 0? */
	je	.Ldone

	shrq	$8,%rdx
	movb	%dl,(%rdi)
	incq	%rdi
	testb	%dl,%dl		/* 5th byte == 0? */
	je	.Ldone

	shrq	$8,%rdx
	movb	%dl,(%rdi)
	incq	%rdi
	testb	%dl,%dl		/* 6th byte == 0? */
	je	.Ldone

	shrq	$8,%rdx
	VENKMAN_PAD(2)
	movb	%dl,(%rdi)
	incq	%rdi
	testb	%dl,%dl		/* 7th byte == 0? */
	je	.Ldone

	shrq	$8,%rdx
	movb	%dl,(%rdi)
	incq	%rdi
	testb	%dl,%dl		/* 8th byte == 0? */
	jne	.Lcopy_aligned

.Ldone:
	VENKMAN_RET
END(strcat)

	.section .note.GNU-stack,"",%progbits
