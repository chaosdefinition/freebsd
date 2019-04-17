/*
 * Adapted by Guillaume Morin <guillaume@morinfr.org> from strcpy.S
 * written by J.T. Conklin <jtc@acorntoolworks.com>
 * Public domain.
 */

#include <machine/asm.h>
__FBSDID("$FreeBSD$");

/*
 * This stpcpy implementation copies a byte at a time until the
 * source pointer is aligned to a word boundary, it then copies by
 * words until it finds a word containing a zero byte, and finally
 * copies by bytes until the end of the string is reached.
 *
 * While this may result in unaligned stores if the source and
 * destination pointers are unaligned with respect to each other,
 * it is still faster than either byte copies or the overhead of
 * an implementation suitable for machines with strict alignment
 * requirements.
 */

	.globl	stpcpy,__stpcpy
ENTRY(stpcpy)
__stpcpy:
	VENKMAN_PAD(12)
	movabsq $0x0101010101010101,%r8
	movabsq $0x8080808080808080,%r9

	/*
	 * Align source to a word boundary.
	 * Consider unrolling loop?
	 */
.Lalign:
	VENKMAN_PAD(1)
	testb	$7,%sil
	je	.Lword_aligned
	movb	(%rsi),%dl
	incq	%rsi
	movb	%dl,(%rdi)
	incq	%rdi
	testb	%dl,%dl
	jne	.Lalign
	movq	%rdi,%rax
	VENKMAN_PAD(22)
	dec	%rax
	VENKMAN_RET

	.p2align 4
.Lloop:
	VENKMAN_PAD(25)
	movq	%rdx,(%rdi)
	addq	$8,%rdi
.Lword_aligned:
	movq	(%rsi),%rdx
	movq	%rdx,%rcx
	addq	$8,%rsi
	subq	%r8,%rcx
	testq	%r9,%rcx
	je	.Lloop

	/*
	 * In rare cases, the above loop may exit prematurely. We must
	 * return to the loop if none of the bytes in the word equal 0.
	 */

	movb	%dl,(%rdi)
	testb	%dl,%dl		/* 1st byte == 0? */
	je	.Ldone
	VENKMAN_PAD(4)
	incq	%rdi

	shrq	$8,%rdx
	movb	%dl,(%rdi)
	testb	%dl,%dl		/* 2nd byte == 0? */
	je	.Ldone
	incq	%rdi

	shrq	$8,%rdx
	movb	%dl,(%rdi)
	testb	%dl,%dl		/* 3rd byte == 0? */
	je	.Ldone
	incq	%rdi

	shrq	$8,%rdx
	movb	%dl,(%rdi)
	testb	%dl,%dl		/* 4th byte == 0? */
	je	.Ldone
	incq	%rdi

	shrq	$8,%rdx
	movb	%dl,(%rdi)
	testb	%dl,%dl		/* 5th byte == 0? */
	je	.Ldone
	incq	%rdi

	shrq	$8,%rdx
	movb	%dl,(%rdi)
	testb	%dl,%dl		/* 6th byte == 0? */
	je	.Ldone
	incq	%rdi

	shrq	$8,%rdx
	VENKMAN_PAD(2)
	movb	%dl,(%rdi)
	testb	%dl,%dl		/* 7th byte == 0? */
	je	.Ldone
	incq	%rdi

	shrq	$8,%rdx
	movb	%dl,(%rdi)
	incq	%rdi
	testb	%dl,%dl		/* 8th byte == 0? */
	jne	.Lword_aligned
	VENKMAN_PAD(29)
	decq	%rdi

.Ldone:
	movq	%rdi,%rax
	VENKMAN_RET
END(stpcpy)

	.section .note.GNU-stack,"",%progbits
