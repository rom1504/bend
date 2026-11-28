/* t3_a_scan_text_fused.S — Hand-ASM probe Variant A for t3_kmp_multi_scan ($direct.scan_text)
 * Laws tested:
 *   1. 3-array preheader hoisting (text, pat, pi) across inner loop
 *   2. Inner self-TCO loop fusion (kmp_fallback_go inlined into scan_text)
 *   3. Zero per-char p113_rt_array_pair, zero per-char p111_rt_ctor (1 SR ctor at exit)
 * ABI (unboxed SR):
 *   %rdi=ctx, %rsi=rem, %rdx=i, %rcx=rd, %r8=plen, %r9=text
 *   0x10(%rbp)=pat, 0x18(%rbp)=pi, 0x20(%rbp)=q, 0x28(%rbp)=acc, 0x30(%rbp)=matches
 * Returns boxed SR{text, pat, pi, q, acc, matches} (cid 0x29, 6 fields).
 */
    .text
    .globl "$direct.scan_text"
    .type "$direct.scan_text", @function
    .align 16
"$direct.scan_text":
    pushq   %rbp
    movq    %rsp, %rbp
    pushq   %rbx
    pushq   %r12
    pushq   %r13
    pushq   %r14
    pushq   %r15
    subq    $72, %rsp               /* 5 pushes + rbp = 48 (aligned), 72 -> misaligned? wait: call pushed 8, rbp 16, 5*8=40 -> 56, +72=128 (16-aligned!) */

    movq    %rdi, 48(%rsp)          /* save ctx */
    movq    (%rdi), %rax            /* heap */

    movq    %r9, 0(%rsp)            /* orig text handle */
    movq    0x10(%rbp), %r10        /* orig pat handle */
    movq    %r10, 8(%rsp)
    movq    0x18(%rbp), %r11        /* orig pi handle */
    movq    %r11, 16(%rsp)

    movl    0x20(%rbp), %r12d       /* q */
    movl    0x28(%rbp), %r13d       /* acc */
    movl    0x30(%rbp), %r14d       /* matches */

    testq   %rsi, %rsi
    je      .Ldone

.macro DECODE_ARR hreg, dstreg
    movq    \hreg, \dstreg
    shlq    $24, \dstreg
    shrq    $24, \dstreg
    testq   \hreg, \hreg
    jns     101f
    movq    (%rax,\dstreg,8), \dstreg
    shrq    $24, \dstreg
101:
    leaq    (%rax,\dstreg,8), \dstreg
.endm

    DECODE_ARR %r9,  %rbx           /* text base */
    DECODE_ARR %r10, %r9            /* pat base */
    DECODE_ARR %r11, %r10           /* pi base */
    /* Free regs: %eax, %r11d, %r15d; live: %rsi=rem, %edx=i, %ecx=rd, %r8d=plen, %r12d=q, %r13d=acc, %r14d=matches */

    .align 16
.Lscan_loop:
    movl    (%rbx,%rdx,8), %r11d    /* ch = text[i] */

    /* Inner KMP fallback loop: while (q > 0 && pat[q] != ch) q = pi[q - 1] */
    testl   %r12d, %r12d
    je      .Lafter_fall
    .align 16
.Lfall_loop:
    cmpl    (%r9,%r12,8), %r11d     /* pat[q] == ch? */
    je      .Lmatch_char
    leal    -1(%r12), %eax
    movl    (%r10,%rax,8), %r12d    /* q = pi[q - 1] */
    testl   %r12d, %r12d
    jne     .Lfall_loop

.Lafter_fall:
    cmpl    (%r9,%r12,8), %r11d     /* pat[q] == ch? */
    jne     .Lnext_char
.Lmatch_char:
    addl    $1, %r12d               /* q++ */
    cmpl    %r8d, %r12d             /* q == plen? */
    jne     .Lnext_char

    /* Match found! */
    imull   $16777619, %r13d, %r13d
    leal    (%rdx,%rcx), %eax       /* i + rd */
    xorl    %eax, %r13d             /* acc = (acc * 16777619) ^ (i + rd) */
    addl    $1, %r14d               /* matches++ */
    leal    -1(%r12), %eax
    movl    (%r10,%rax,8), %r12d    /* q = pi[q - 1] */

.Lnext_char:
    addq    $1, %rdx                /* i++ */
    subq    $1, %rsi                /* rem-- */
    jne     .Lscan_loop

.Ldone:
    /* Box SR{text, pat, pi, q, acc, matches} (cid 0x29, 6 fields) */
    movl    %r12d, %eax
    movq    %rax, 24(%rsp)
    movl    %r13d, %eax
    movq    %rax, 32(%rsp)
    movl    %r14d, %eax
    movq    %rax, 40(%rsp)

    movq    48(%rsp), %rdi          /* ctx */
    movl    $0x29, %esi             /* cid SR */
    movq    %rsp, %rdx              /* fields[0..5] */
    movl    $6, %ecx
    callq   p111_rt_ctor

    addq    $72, %rsp
    popq    %r15
    popq    %r14
    popq    %r13
    popq    %r12
    popq    %rbx
    popq    %rbp
    ret
    .size "$direct.scan_text", .-"$direct.scan_text"
