#ifndef _MACHINE_VENKMAN_H_
#define _MACHINE_VENKMAN_H_

/*****************************************************************************
 * Venkman alignment stuffs **************************************************
 *****************************************************************************/

#ifdef VENKMAN
#define BUNDLE_ALIGNMENT	5
#define BUNDLE_SIZE		32

#define VENKMAN_ALIGNMENT	BUNDLE_ALIGNMENT

/* Redefine _START_ENTRY for a larger function alignment */
#ifdef _START_ENTRY
#undef _START_ENTRY
#define _START_ENTRY		.text; .p2align BUNDLE_ALIGNMENT,0x90
#endif /* _START_ENTRY */

/* Redefine ALIGN_TEXT for bundle alignment */
#ifdef ALIGN_TEXT
#undef ALIGN_TEXT
#define ALIGN_TEXT		.p2align BUNDLE_ALIGNMENT,0x90
#endif /* ALIGN_TEXT */

/* Redefine SUPERALIGN_TEXT for bundle alignment */
#ifdef SUPERALIGN_TEXT
#undef SUPERALIGN_TEXT
#define SUPERALIGN_TEXT		.p2align BUNDLE_ALIGNMENT,0x90
#endif /* SUPERALIGN_TEXT */

#define ALIGN_FOR_VENKMAN	.p2align BUNDLE_ALIGNMENT,0x90

/* Redefine profiling related macros for bundle alignment */
#ifdef PROF
#ifdef ENTRY
#undef ENTRY
#define ENTRY(x)		_ENTRY(x);				\
				VENKMAN_PAD(23);			\
				pushq %rbp; movq %rsp,%rbp;		\
				call PIC_PLT(HIDENAME(mcount));		\
				VENKMAN_PAD(31);			\
				popq %rbp;				\
				9:
#endif /* ENTRY */
#ifdef ALTENTRY
#undef ALTENTRY
#define ALTENTRY(x)		_ENTRY(x);				\
				VENKMAN_PAD(23);			\
				pushq %rbp; movq %rsp,%rbp;		\
				call PIC_PLT(HIDENAME(mcount));		\
				VENKMAN_PAD(26);			\
				popq %rbp;				\
				jmp 9f
#endif /* ALTENTRY */
#endif /* PROF */

#ifdef GPROF
#ifdef MCOUNT
#undef MCOUNT
#define MCOUNT			VENKMAN_PAD(27); call __mcount
#endif /* MCOUNT */
#ifdef FAKE_MCOUNT
#undef FAKE_MCOUNT
#define FAKE_MOUNT(caller)	pushq caller; .p2align 4,0x90;		\
				VENKMAN_PAD(11); call __mount;		\
				VENKMAN_PAD(31); popq %rcx
#endif /* FAKE_MCOUNT */
#ifdef GUPROF
#ifdef MEXITCOUNT
#undef MEXITCOUNT
#define MEXITCOUNT		VENKMAN_PAD(27); call .mexitcount
#endif /* MEXITCOUNT */
#endif /* GUPROF */
#endif /* GPROF */

/* Macros for creating code padding */
#define VENKMAN_PAD_0
#define VENKMAN_PAD_1		nop
#define VENKMAN_PAD_2		xchg %ax,%ax
#define VENKMAN_PAD_3		nopl (%rax)
#define VENKMAN_PAD_4		nopl 8(%rax)
#define VENKMAN_PAD_5		nopl 8(%rax,%rax)
#define VENKMAN_PAD_6		nopw 8(%rax,%rax,1)
#define VENKMAN_PAD_7		nopl 512(%rax)
#define VENKMAN_PAD_8		nopl 512(%rax,%rax,1)
#define VENKMAN_PAD_9		nopw 512(%rax,%rax,1)
#define VENKMAN_PAD_10		nopw %cs:512(%rax,%rax,1)
#define VENKMAN_PAD_11		VENKMAN_PAD_1;      VENKMAN_PAD_10
#define VENKMAN_PAD_12		VENKMAN_PAD_2;      VENKMAN_PAD_10
#define VENKMAN_PAD_13		VENKMAN_PAD_3;      VENKMAN_PAD_10
#define VENKMAN_PAD_14		VENKMAN_PAD_4;      VENKMAN_PAD_10
#define VENKMAN_PAD_15		VENKMAN_PAD_5;      VENKMAN_PAD_10
#define VENKMAN_PAD_16		VENKMAN_PAD_6;      VENKMAN_PAD_10
#define VENKMAN_PAD_17		VENKMAN_PAD_7;      VENKMAN_PAD_10
#define VENKMAN_PAD_18		VENKMAN_PAD_8;      VENKMAN_PAD_10
#define VENKMAN_PAD_19		VENKMAN_PAD_9;      VENKMAN_PAD_10
#define VENKMAN_PAD_20		VENKMAN_PAD_10;     VENKMAN_PAD_10
#define VENKMAN_PAD_21		VENKMAN_PAD_1;      VENKMAN_PAD_20
#define VENKMAN_PAD_22		VENKMAN_PAD_2;      VENKMAN_PAD_20
#define VENKMAN_PAD_23		VENKMAN_PAD_3;      VENKMAN_PAD_20
#define VENKMAN_PAD_24		VENKMAN_PAD_4;      VENKMAN_PAD_20
#define VENKMAN_PAD_25		VENKMAN_PAD_5;      VENKMAN_PAD_20
#define VENKMAN_PAD_26		VENKMAN_PAD_6;      VENKMAN_PAD_20
#define VENKMAN_PAD_27		VENKMAN_PAD_7;      VENKMAN_PAD_20
#define VENKMAN_PAD_28		VENKMAN_PAD_8;      VENKMAN_PAD_20
#define VENKMAN_PAD_29		VENKMAN_PAD_9;      VENKMAN_PAD_20
#define VENKMAN_PAD_30		VENKMAN_PAD_10;     VENKMAN_PAD_20
#define VENKMAN_PAD_31		VENKMAN_PAD_1;      VENKMAN_PAD_30
#define VENKMAN_PAD(n)		VENKMAN_PAD_##n
#else /* !VENKMAN */
#define VENKMAN_ALIGNMENT	4
#define VENKMAN_PAD(n)
#endif /* !VENKMAN */

/*****************************************************************************
 * Venkman CFI stuffs ********************************************************
 *****************************************************************************/

#ifdef VENKMAN
#ifdef VENKMAN_CFI

#define VENKMAN_JMPr(reg)	andq	$-BUNDLE_SIZE, %reg;		\
				jmpq	*%reg

#define VENKMAN_JMPm(addr)	andq	$-BUNDLE_SIZE, addr;		\
				jmpq	*addr

#define VENKMAN_CALLr(reg)	andq	$-BUNDLE_SIZE, %reg;		\
				callq	*%reg

#define VENKMAN_CALLm(addr)	andq	$-BUNDLE_SIZE, addr;		\
				callq	*addr

#define VENKMAN_RET		popq	%rcx;				\
				VENKMAN_JMPr(rcx)

#define VENKMAN_RETI(imm)	popq	%rcx;				\
				addq	$imm, %rsp;			\
				VENKMAN_JMPr(rcx)

/* This is for cases where we cannot clobber %rcx (e.g., context switch code) */
#define VENKMAN_RET_NOREG	andq	$-BUNDLE_SIZE, (%rsp);		\
				retq

#else /* !VENKMAN_CFI */

#define VENKMAN_JMPr(reg)	VENKMAN_PAD(4); jmpq	*%reg

#define VENKMAN_JMPm(addr)	VENKMAN_PAD(9); jmpq	*addr

#define VENKMAN_CALLr(reg)	VENKMAN_PAD(4); callq	*%reg

#define VENKMAN_CALLm(addr)	VENKMAN_PAD(9); callq	*addr

#define VENKMAN_RET		VENKMAN_PAD(6); ret

#define VENKMAN_RETI(imm)	VENKMAN_PAD(4); ret	$imm

#define VENKMAN_RET_NOREG	VENKMAN_RET

#endif /* !VENKMAN_CFI */

#else /* !VENKMAN */

#define ALIGN_FOR_VENKMAN

#define VENKMAN_JMPr(reg)	jmpq	*%reg

#define VENKMAN_JMPm(addr)	jmpq	*addr

#define VENKMAN_CALLr(reg)	callq	*%reg

#define VENKMAN_CALLm(addr)	callq	*addr

#define VENKMAN_RET		ret

#define VENKMAN_RETI(imm)	ret	$imm

#define VENKMAN_RET_NOREG	VENKMAN_RET

#endif /* !VENKMAN */

#endif /* _MACHINE_VENKMAN_H_ */
