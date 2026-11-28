/* t2_a_stages_scalar_hoist.S — Hand-ASM probe Variant A for t2_radix2_fft_f32 ($direct.run_stages)
 * Laws tested:
 *   1. 4-array preheader hoisting (re, im, twr, twi) across 3-deep butterfly loop nest
 *   2. Nested-loop + 6-deep continuation-chain fusion (run_stages + run_groups + run_bfly + bfly_wr..ui)
 *   3. Zero heap allocations (returns st handle directly), exact IEEE-754 scalar F32
 * ABI: (ctx=%rdi, rem=%rsi, s=%rdx, st=%rcx) -> %rax (returns st)
 */
    .text
    .globl "$direct.run_stages"
    .type "$direct.run_stages", @function
    .align 16
"$direct.run_stages":
    testq   %rsi, %rsi
    jne     .Lgo
    movq    %rcx, %rax
    ret
.Lgo:
    pushq   %rbx
    pushq   %rbp
    pushq   %r12
    pushq   %r13
    pushq   %r14
    pushq   %r15
    subq    $40, %rsp               /* 6 pushes = 48, +8 ret = 56, +40 = 96 (16-aligned) */

    movq    %rcx, 0(%rsp)           /* save st handle */
    movq    %rsi, 8(%rsp)           /* save rem stages */
    movq    %rdx, 16(%rsp)          /* save s */

    movq    (%rdi), %rdi            /* heap */

.macro DECODE_H hreg, dstreg
    movq    \hreg, \dstreg
    shlq    $24, \dstreg
    shrq    $24, \dstreg
    testq   \hreg, \hreg
    jns     101f
    movq    (%rdi,\dstreg,8), \dstreg
    shrq    $24, \dstreg
101:
    leaq    (%rdi,\dstreg,8), \dstreg
.endm

    DECODE_H %rcx, %rbp             /* FS{re, im, twr, twi} ptr */
    movq    0(%rbp), %rax
    DECODE_H %rax, %r8              /* re base */
    movq    8(%rbp), %rax
    DECODE_H %rax, %r9              /* im base */
    movq    16(%rbp), %rax
    DECODE_H %rax, %r10             /* twr base */
    movq    24(%rbp), %rax
    DECODE_H %rax, %r11             /* twi base */

    .align 16
.Lstage_loop:
    movq    16(%rsp), %rcx          /* s */
    movl    $1, %r12d
    shll    %cl, %r12d              /* half = 1 << s */
    leal    (%r12,%r12), %r13d      /* step = half << 1 */
    addl    $1, %ecx
    movl    $512, %r14d
    shrl    %cl, %r14d              /* tw_stride = 512 >> (s + 1) = n_groups */
    movq    %r14, 24(%rsp)          /* n_groups */

    xorl    %ebx, %ebx              /* base = 0 */
    .align 16
.Lgroup_loop:
    xorl    %edx, %edx              /* k = 0 */
    xorl    %eax, %eax              /* tidx = 0 (incremental: tidx += tw_stride!) */
    movl    %ebx, %esi              /* u = base */
    leal    (%rbx,%r12), %edi       /* v = base + half */

    .align 16
.Lbfly_loop:
    movss   (%r10,%rax,8), %xmm0    /* wr = twr[tidx] */
    movss   (%r11,%rax,8), %xmm1    /* wi = twi[tidx] */
    movss   (%r8,%rdi,8),  %xmm2    /* vr = re[v] */
    movss   (%r9,%rdi,8),  %xmm3    /* vi = im[v] */

    movaps  %xmm0, %xmm4
    mulss   %xmm2, %xmm4            /* wr * vr */
    movaps  %xmm1, %xmm5
    mulss   %xmm3, %xmm5            /* wi * vi */
    subss   %xmm5, %xmm4            /* tr = wr*vr - wi*vi */

    mulss   %xmm3, %xmm0            /* wr * vi */
    mulss   %xmm2, %xmm1            /* wi * vr */
    addss   %xmm1, %xmm0            /* ti = wr*vi + wi*vr */

    movss   (%r8,%rsi,8),  %xmm2    /* ur = re[u] */
    movss   (%r9,%rsi,8),  %xmm3    /* ui = im[u] */

    movaps  %xmm2, %xmm5
    addss   %xmm4, %xmm5            /* ur + tr */
    subss   %xmm4, %xmm2            /* ur - tr */
    movss   %xmm5, (%r8,%rsi,8)     /* re[u] = ur + tr */
    movss   %xmm2, (%r8,%rdi,8)     /* re[v] = ur - tr */

    movaps  %xmm3, %xmm5
    addss   %xmm0, %xmm5            /* ui + ti */
    subss   %xmm0, %xmm3            /* ui - ti */
    movss   %xmm5, (%r9,%rsi,8)     /* im[u] = ui + ti */
    movss   %xmm3, (%r9,%rdi,8)     /* im[v] = ui - ti */

    addq    $1, %rsi                /* u++ */
    addq    $1, %rdi                /* v++ */
    addq    %r14, %rax              /* tidx += tw_stride */
    addl    $1, %edx                /* k++ */
    cmpl    %r12d, %edx
    jne     .Lbfly_loop

    addl    %r13d, %ebx             /* base += step */
    subq    $1, 24(%rsp)
    jne     .Lgroup_loop

    addq    $1, 16(%rsp)            /* s++ */
    subq    $1, 8(%rsp)             /* rem-- */
    jne     .Lstage_loop

    movq    0(%rsp), %rax           /* return st */
    addq    $40, %rsp
    popq    %r15
    popq    %r14
    popq    %r13
    popq    %r12
    popq    %rbp
    popq    %rbx
    ret
    .size "$direct.run_stages", .-"$direct.run_stages"
