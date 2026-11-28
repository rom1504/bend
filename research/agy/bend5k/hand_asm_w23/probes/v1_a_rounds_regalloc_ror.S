/* v1_a_rounds_regalloc_ror.S — Hand-ASM probe Variant A for v1_sha256_compress ($direct.run_rounds)
 * Laws tested:
 *   1. Register-resident 8-word state (a..h) + hoisted w/k pointers (0 loop spills vs Proven-22's 276 spills!)
 *   2. Hardware rotate fusion (rorl $6/$11/$25/$2/$13/$22 instead of 4-insn shift/or sequences)
 *   3. Zero inner heap allocations (boxes S8 + SR once at exit)
 * ABI (unboxed SR + S8):
 *   %rdi=ctx, %rsi=rem, %rdx=i, %rcx=a, %r8=w, %r9=k
 *   0x10(%rbp)=b, 0x18(%rbp)=c, 0x20(%rbp)=d, 0x28(%rbp)=e, 0x30(%rbp)=f, 0x38(%rbp)=g, 0x40(%rbp)=h
 * Returns boxed SR{S8{a..h}, w, k} (S8 cid=0x27, SR cid=0x28).
 */
    .text
    .globl "$direct.run_rounds"
    .type "$direct.run_rounds", @function
    .align 16
"$direct.run_rounds":
    pushq   %rbp
    movq    %rsp, %rbp
    pushq   %rbx
    pushq   %r12
    pushq   %r13
    pushq   %r14
    pushq   %r15
    subq    $104, %rsp              /* 6*8+8=56; +104=160 (16-aligned) */

    movq    %rdi, 64(%rsp)          /* ctx */
    movq    %r8,  72(%rsp)          /* orig w */
    movq    %r9,  80(%rsp)          /* orig k */
    movq    %rsi, 88(%rsp)          /* rem */

    /* Load a..h into registers:
     *   %r8d=a, %r9d=b, %r10d=c, %r11d=d, %r12d=e, %r13d=f, %r14d=g, %r15d=h
     *   %rbx = w_base, %rsi = k_base, %rdx = i
     */
    movq    (%rdi), %rax            /* heap */

.macro DEC_V1 hreg, dstreg
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

    DEC_V1  %r8, %rbx               /* w base */
    DEC_V1  %r9, %rsi               /* k base */

    movl    %ecx, %r8d              /* a */
    movl    0x10(%rbp), %r9d        /* b */
    movl    0x18(%rbp), %r10d       /* c */
    movl    0x20(%rbp), %r11d       /* d */
    movl    0x28(%rbp), %r12d       /* e */
    movl    0x30(%rbp), %r13d       /* f */
    movl    0x38(%rbp), %r14d       /* g */
    movl    0x40(%rbp), %r15d       /* h */

    cmpq    $0, 88(%rsp)
    je      .Ldone

    .align 16
.Lr_loop:
    /* big_s1(e) = ror(e,6) ^ ror(e,11) ^ ror(e,25) */
    movl    %r12d, %eax
    rorl    $6, %eax
    movl    %r12d, %ecx
    rorl    $11, %ecx
    xorl    %ecx, %eax
    movl    %r12d, %ecx
    rorl    $25, %ecx
    xorl    %ecx, %eax              /* %eax = big_s1(e) */

    /* ch = (e & f) ^ (~e & g) = ((f ^ g) & e) ^ g */
    movl    %r13d, %ecx
    xorl    %r14d, %ecx
    andl    %r12d, %ecx
    xorl    %r14d, %ecx             /* %ecx = ch */

    /* t1 = h + big_s1(e) + ch + k[i] + w[i] */
    addl    %r15d, %eax
    addl    %ecx, %eax
    addl    (%rsi,%rdx,8), %eax     /* + k[i] */
    addl    (%rbx,%rdx,8), %eax     /* + w[i] -> %eax = t1 */

    /* big_s0(a) = ror(a,2) ^ ror(a,13) ^ ror(a,22) */
    movl    %r8d, %ecx
    rorl    $2, %ecx
    movl    %r8d, %edi
    rorl    $13, %edi
    xorl    %edi, %ecx
    movl    %r8d, %edi
    rorl    $22, %edi
    xorl    %edi, %ecx              /* %ecx = big_s0(a) */

    /* maj = (a & b) ^ (a & c) ^ (b & c) = (a & (b | c)) | (b & c) */
    movl    %r9d, %edi
    orl     %r10d, %edi
    andl    %r8d, %edi
    movl    %r9d, %r15d             /* h is dead now! reuse %r15d */
    andl    %r10d, %r15d
    orl     %r15d, %edi             /* %edi = maj */
    addl    %edi, %ecx              /* %ecx = t2 */

    /* Rotate state: h=g, g=f, f=e, e=d+t1, d=c, c=b, b=a, a=t1+t2 */
    movl    %r14d, %r15d            /* h = g */
    movl    %r13d, %r14d            /* g = f */
    movl    %r12d, %r13d            /* f = e */
    leal    (%r11,%rax), %r12d      /* e = d + t1 */
    movl    %r10d, %r11d            /* d = c */
    movl    %r9d,  %r10d            /* c = b */
    movl    %r8d,  %r9d             /* b = a */
    leal    (%rax,%rcx), %r8d       /* a = t1 + t2 */

    addq    $1, %rdx
    subq    $1, 88(%rsp)
    jne     .Lr_loop

.Ldone:
    /* Box S8{a..h} (cid 0x27, 8 fields) */
    movl    %r8d,  %eax
    movq    %rax,  0(%rsp)
    movl    %r9d,  %eax
    movq    %rax,  8(%rsp)
    movl    %r10d, %eax
    movq    %rax,  16(%rsp)
    movl    %r11d, %eax
    movq    %rax,  24(%rsp)
    movl    %r12d, %eax
    movq    %rax,  32(%rsp)
    movl    %r13d, %eax
    movq    %rax,  40(%rsp)
    movl    %r14d, %eax
    movq    %rax,  48(%rsp)
    movl    %r15d, %eax
    movq    %rax,  56(%rsp)

    movq    64(%rsp), %rdi          /* ctx */
    movl    $0x27, %esi             /* cid S8 */
    movq    %rsp, %rdx
    movl    $8, %ecx
    callq   p111_rt_ctor

    /* Box SR{st, w, k} (cid 0x28, 3 fields) */
    movq    %rax, 0(%rsp)
    movq    72(%rsp), %rax
    movq    %rax, 8(%rsp)
    movq    80(%rsp), %rax
    movq    %rax, 16(%rsp)

    movq    64(%rsp), %rdi
    movl    $0x28, %esi             /* cid SR */
    movq    %rsp, %rdx
    movl    $3, %ecx
    callq   p111_rt_ctor

    addq    $104, %rsp
    popq    %r15
    popq    %r14
    popq    %r13
    popq    %r12
    popq    %rbx
    popq    %rbp
    ret
    .size "$direct.run_rounds", .-"$direct.run_rounds"
