/* $FreeBSD$ */

#include "linux32_assym.h"			/* system definitions */
#include <machine/asmacros.h>			/* miscellaneous asm macros */

#include <amd64/linux32/linux32_syscall.h>	/* system call numbers */

/* The VENKMAN_* macros use 64-bit registers which are unavailable in 32-bit
 * mode
 */
#ifdef VENKMAN_PAD
#undef VENKMAN_PAD
#endif
#ifdef VENKMAN_RET_NOREG
#undef VENKMAN_RET_NOREG
#endif
#ifdef VENKMAN_JMPm
#undef VENKMAN_JMPm
#endif
#ifdef VENKMAN
#define VENKMAN_PAD(bytes) .skip bytes, 0x90
#ifdef VENKMAN_CFI
#define VENKMAN_JMPm(addr) andl $-BUNDLE_SIZE, addr; jmpl *addr
#define VENKMAN_RET_NOREG andl $-BUNDLE_SIZE, (%esp); ret
#else
#define VENKMAN_RET_NOREG ret
#define VENKMAN_JMPm(addr) jmpl *addr
#endif
#else
#define VENKMAN_PAD(bytes)
#define VENKMAN_RET_NOREG ret
#define VENKMAN_JMPm(addr) jmpl *addr
#endif

.data

	.globl linux_platform
linux_platform:
	.asciz "i686"

.text
.code32

/*
 * To avoid excess stack frame the signal trampoline code emulates
 * the 'call' instruction.
 */
NON_GPROF_ENTRY(linux32_sigcode)
	movl	%esp, %ebx			/* preserve sigframe */
	VENKMAN_PAD(25)
	call .getip0

	ALIGN_FOR_VENKMAN
.getip0:
	popl	%eax
	add	$.startsigcode-.getip0, %eax	/* ret address */
	push	%eax
	VENKMAN_JMPm(LINUX_SIGF_HANDLER(%ebx))

	ALIGN_FOR_VENKMAN
.startsigcode:
	popl	%eax
	movl	$LINUX32_SYS_linux_sigreturn,%eax	/* linux_sigreturn() */
	VENKMAN_PAD(24)
	int	$0x80				/* enter kernel with args */

	ALIGN_FOR_VENKMAN
.endsigcode:
0:	jmp	0b

NON_GPROF_ENTRY(linux32_rt_sigcode)
	leal	LINUX_RT_SIGF_UC(%esp),%ebx	/* linux ucp */
	leal	LINUX_RT_SIGF_SC(%ebx),%ecx	/* linux sigcontext */
	movl	%esp, %edi
	VENKMAN_PAD(15)
	call	.getip1

	ALIGN_FOR_VENKMAN
.getip1:
	popl	%eax
	add	$.startrtsigcode-.getip1, %eax	/* VENKMAN_RET_NOREG address */
	push	%eax
	VENKMAN_JMPm(LINUX_RT_SIGF_HANDLER(%edi))

	ALIGN_FOR_VENKMAN
.startrtsigcode:
	movl	$LINUX32_SYS_linux_rt_sigreturn,%eax   /* linux_rt_sigreturn() */
	VENKMAN_PAD(25)
	int	$0x80				/* enter kernel with args */

	ALIGN_FOR_VENKMAN
.endrtsigcode:
0:	jmp	0b

NON_GPROF_ENTRY(linux32_vsyscall)
.startvsyscall:
	VENKMAN_PAD(30)
	int $0x80
	VENKMAN_RET_NOREG
.endvsyscall:

#if 0
	.section .note.Linux, "a",@note
	.long 2f - 1f		/* namesz */
	.balign 4
	.long 4f - 3f		/* descsz */
	.long 0
1:
	.asciz "Linux"
2:
	.balign 4
3:
	.long LINUX_VERSION_CODE
4:
	.balign 4
	.previous
#endif

#define do_cfa_expr(offset)						\
	.byte 0x0f;			/* DW_CFA_def_cfa_expression */	\
	.uleb128 11f-10f;		/*   length */			\
10:	.byte 0x74;			/*     DW_OP_breg4 */		\
	.sleb128 offset;		/*      offset */		\
	.byte 0x06;			/*     DW_OP_deref */		\
11:


	/* CIE */
	.section .eh_frame,"a",@progbits
.LSTARTFRAMEDLSI1:
	.long .LENDCIEDLSI1-.LSTARTCIEDLSI1
.LSTARTCIEDLSI1:
	.long 0					/* CIE ID */
	.byte 1					/* Version number */
	.string "zRS"				/* NULL-terminated
						 * augmentation string
						 */
	.uleb128 1				/* Code alignment factor */
	.sleb128 -4				/* Data alignment factor */
	.byte 8					/* Return address
						 * register column
						 */
	.uleb128 1				/* Augmentation value length */
	.byte 0x1b				/* DW_EH_PE_pcrel|DW_EH_PE_sdata4. */
	.byte 0					/* DW_CFA_nop */
	.align 4
.LENDCIEDLSI1:

	/* FDE */
	.long .LENDFDEDLSI1-.LSTARTFDEDLSI1	/* Length FDE */
.LSTARTFDEDLSI1:
	.long .LSTARTFDEDLSI1-.LSTARTFRAMEDLSI1 /* CIE pointer */
	.long .startsigcode-.			/* PC-relative start address */
	.long .endsigcode-.startsigcode
	.uleb128 0				/* Augmentation */
	do_cfa_expr(LINUX_SIGF_SC-8)
	.align 4
.LENDFDEDLSI1:

	.long .LENDFDEDLSI2-.LSTARTFDEDLSI2	/* Length FDE */
.LSTARTFDEDLSI2:
	.long .LSTARTFDEDLSI2-.LSTARTFRAMEDLSI1	/* CIE pointer */
	.long .startrtsigcode-.			/* PC-relative start address */
	.long .endrtsigcode-.startrtsigcode
	.uleb128 0				/* Augmentation */
	do_cfa_expr(LINUX_RT_SIGF_SC-4+LINUX_SC_ESP)
	.align 4
.LENDFDEDLSI2:
	.previous

	.section .eh_frame,"a",@progbits
.LSTARTFRAMEDLSI2:
	.long .LENDCIEDLSI2-.LSTARTCIEDLSI2
.LSTARTCIEDLSI2:
	.long 0					/* CIE ID */
	.byte 1					/* Version number */
	.string "zR"				/* NULL-terminated
						 * augmentation string
						 */
	.uleb128 1				/* Code alignment factor */
	.sleb128 -4				/* Data alignment factor */
	.byte 8					/* Return address register column */
	.uleb128 1				/* Augmentation value length */
	.byte 0x1b				/* DW_EH_PE_pcrel|DW_EH_PE_sdata4. */
	.byte 0x0c				/* DW_CFA_def_cfa */
	.uleb128 4
	.uleb128 4
	.byte 0x88				/* DW_CFA_offset, column 0x8 */
	.uleb128 1
	.align 4
.LENDCIEDLSI2:
	.long .LENDFDEDLSI3-.LSTARTFDEDLSI3 /* Length FDE */
.LSTARTFDEDLSI3:
	.long .LSTARTFDEDLSI3-.LSTARTFRAMEDLSI2 /* CIE pointer */
	.long .startvsyscall-.			/* PC-relative start address */
	.long .endvsyscall-.startvsyscall
	.uleb128 0
	.align 4
.LENDFDEDLSI3:
	.previous
