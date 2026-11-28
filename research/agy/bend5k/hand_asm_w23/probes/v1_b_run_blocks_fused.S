/* v1_b_run_blocks_fused.S — Hand-ASM probe Variant B for v1_sha256_compress ($direct.run_blocks)
 * Laws tested:
 *   1. Full block-level loop fusion: fill_w16 + expand_w + run_rounds + add_state inside run_blocks
 *   2. 2-array preheader hoist (w, k) once before all 24,000 blocks (0 p113_rt_array_pair, 0 p111_rt_op, 0 p111_rt_ctor!)
 *   3. Hardware rotate fusion (rorl) in BOTH expand_w (sig0/sig1) AND run_rounds (big_s0/big_s1)
 *   4. Register-resident 8-word state (a..h) across all 64 rounds
 * ABI (unboxed SR):
 *   %rdi=ctx, %rsi=rem, %rdx=blk, %rcx=salt, %r8=st (S8{h0..h7}), %r9=w, 0x10(%rbp)=k
 * Returns U32 FNV-1a checksum in %rax!
 */
    .text
    .globl "$direct.run_blocks"
    .type "$direct.run_blocks", @function
    .align 16
"$direct.run_blocks":
    pushq   %rbp
    movq    %rsp, %rbp
    pushq   %rbx
    pushq   %r12
    pushq   %r13
    pushq   %r14
    pushq   %r15
    subq    $88, %rsp               /* 6*8+8=56; +88=144 (16-aligned) */

    movq    %rsi, 0(%rsp)           /* rem */
    movl    %edx, 8(%rsp)           /* blk */
    movl    %ecx, 12(%rsp)          /* salt */

    movq    (%rdi), %rax            /* heap */

.macro DEC_V1B hreg, dstreg
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

    DEC_V1B %r8, %rdx               /* st ptr -> S8{h0..h7} */
    DEC_V1B %r9, %rbx               /* w base */
    movq    0x10(%rbp), %rcx
    DEC_V1B %rcx, %rsi              /* k base */

    /* Load h0..h7 into stack slots 16(%rsp)..44(%rsp) (32B contiguous!) */
    movl    0(%rdx),  %eax
    movl    %eax, 16(%rsp)          /* h0 */
    movl    8(%rdx),  %eax
    movl    %eax, 20(%rsp)          /* h1 */
    movl    16(%rdx), %eax
    movl    %eax, 24(%rsp)          /* h2 */
    movl    24(%rdx), %eax
    movl    %eax, 28(%rsp)          /* h3 */
    movl    32(%rdx), %eax
    movl    %eax, 32(%rsp)          /* h4 */
    movl    40(%rdx), %eax
    movl    %eax, 36(%rsp)          /* h5 */
    movl    48(%rdx), %eax
    movl    %eax, 40(%rsp)          /* h6 */
    movl    56(%rdx), %eax
    movl    %eax, 44(%rsp)          /* h7 */

    cmpq    $0, 0(%rsp)
    je      .Lfinal_chk

    .align 16
.Lblk_loop:
    /* mix = ((blk * 2654435761) ^ h0) ^ salt */
    movl    8(%rsp), %eax           /* blk */
    imull   $-1640531535, %eax, %eax
    xorl    16(%rsp), %eax          /* ^ h0 */
    xorl    12(%rsp), %eax          /* ^ salt -> %eax = mix */
    movl    32(%rsp), %edx          /* h4 */

    /* 1. fill_w16 */
    xorl    %ecx, %ecx              /* i = 0 */
    .align 16
.Lfill_loop:
    imull   $1664525, %eax, %eax
    addl    $1013904223, %eax
    addl    %ecx, %eax              /* nmix */
    movl    %eax, %edi
    xorl    %edx, %edi
    movl    %edi, (%rbx,%rcx,8)     /* w[i] = nmix ^ h4 */
    addq    $1, %rcx
    cmpq    $16, %rcx
    jne     .Lfill_loop

    /* 2. expand_w (i = 16..63) with hardware rorl */
    movq    $16, %rcx
    .align 16
.Lexp_loop:
    /* v15 = w[i-15]; sig0(v15) = ror(7)^ror(18)^(>>3) */
    movl    -120(%rbx,%rcx,8), %eax
    movl    %eax, %edx
    rorl    $7, %edx
    movl    %eax, %edi
    rorl    $18, %edi
    xorl    %edi, %edx
    shrl    $3, %eax
    xorl    %eax, %edx              /* %edx = sig0(v15) */
    addl    -128(%rbx,%rcx,8), %edx /* + w[i-16] */
    addl    -56(%rbx,%rcx,8), %edx  /* + w[i-7] */

    /* v2 = w[i-2]; sig1(v2) = ror(17)^ror(19)^(>>10) */
    movl    -16(%rbx,%rcx,8), %eax
    movl    %eax, %edi
    rorl    $17, %edi
    movl    %eax, %r8d
    rorl    $19, %r8d
    xorl    %r8d, %edi
    shrl    $10, %eax
    xorl    %eax, %edi              /* %edi = sig1(v2) */
    addl    %edi, %edx
    movl    %edx, (%rbx,%rcx,8)     /* w[i] = val */

    addq    $1, %rcx
    cmpq    $64, %rcx
    jne     .Lexp_loop

    /* 3. run_rounds (64 rounds, a..h in %r8d..%r15d) */
    movl    16(%rsp), %r8d
    movl    20(%rsp), %r9d
    movl    24(%rsp), %r10d
    movl    28(%rsp), %r11d
    movl    32(%rsp), %r12d
    movl    36(%rsp), %r13d
    movl    40(%rsp), %r14d
    movl    44(%rsp), %r15d
    xorl    %edx, %edx              /* i = 0 */

    .align 16
.Lround_loop:
    movl    %r12d, %eax
    rorl    $6, %eax
    movl    %r12d, %ecx
    rorl    $11, %ecx
    xorl    %ecx, %eax
    movl    %r12d, %ecx
    rorl    $25, %ecx
    xorl    %ecx, %eax              /* big_s1(e) */

    movl    %r13d, %ecx
    xorl    %r14d, %ecx
    andl    %r12d, %ecx
    xorl    %r14d, %ecx             /* ch */

    addl    %r15d, %eax
    addl    %ecx, %eax
    addl    (%rsi,%rdx,8), %eax     /* + k[i] */
    addl    (%rbx,%rdx,8), %eax     /* + w[i] = t1 */

    movl    %r8d, %ecx
    rorl    $2, %ecx
    movl    %r8d, %edi
    rorl    $13, %edi
    xorl    %edi, %ecx
    movl    %r8d, %edi
    rorl    $22, %edi
    xorl    %edi, %ecx              /* big_s0(a) */

    movl    %r9d, %edi
    orl     %r10d, %edi
    andl    %r8d, %edi
    movl    %r9d, %r15d
    andl    %r10d, %r15d
    orl     %r15d, %edi             /* maj */
    addl    %edi, %ecx              /* t2 */

    movl    %r14d, %r15d
    movl    %r13d, %r14d
    movl    %r12d, %r13d
    leal    (%r11,%rax), %r12d
    movl    %r10d, %r11d
    movl    %r9d,  %r10d
    movl    %r8d,  %r9d
    leal    (%rax,%rcx), %r8d

    addq    $1, %rdx
    cmpq    $64, %rdx
    jne     .Lround_loop

    /* 4. add_state */
    addl    %r8d,  16(%rsp)
    addl    %r9d,  20(%rsp)
    addl    %r10d, 24(%rsp)
    addl    %r11d, 28(%rsp)
    addl    %r12d, 32(%rsp)
    addl    %r13d, 36(%rsp)
    addl    %r14d, 40(%rsp)
    addl    %r15d, 44(%rsp)

    addl    $1, 8(%rsp)             /* blk++ */
    subq    $1, 0(%rsp)             /* rem-- */
    jne     .Lblk_loop

.Lfinal_chk:
    movl    $2166136261, %eax
    xorl    %ecx, %ecx
.Lfnv_loop:
    imull   $16777619, %eax, %eax
    xorl    16(%rsp,%rcx,4), %eax
    addq    $1, %rcx
    cmpq    $8, %rcx
    jne     .Lfnv_loop

    addq    $88, %rsp
    popq    %r15
    popq    %r14
    popq    %r13
    popq    %r12
    popq    %rbx
    popq    %rbp
    ret
    .size "$direct.run_blocks", .-"$direct.run_blocks"
