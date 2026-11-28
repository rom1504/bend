/* t2_b_frames_fused_sse.S — Hand-ASM probe Variant B for t2_radix2_fft_f32 ($direct.run_frames)
 * Laws tested:
 *   1. Full frame fusion: bitrev_perm + run_stages + norm_loop hoisted across all 440 frames
 *   2. 4-wide SSE2/SSE vectorization (mulps/addps/subps) for stages half >= 4 and norm_loop
 *      (100% IEEE-754 bit-identical to scalar F32 with -ffp-contract=off!)
 *   3. Strength reduction: incremental tidx += tw_stride, precomputed bitrev swap
 * ABI (unboxed FS):
 *   %rdi=ctx, %rsi=rem, %rdx=f, %rcx=inv_s (F32 bits), %r8=re, %r9=im,
 *   0x10(%rbp)=twr, 0x18(%rbp)=twi
 * Returns boxed PF{re, im} (cid 0x28, 2 fields).
 */
    .text
    .globl "$direct.run_frames"
    .type "$direct.run_frames", @function
    .align 16
"$direct.run_frames":
    pushq   %rbp
    movq    %rsp, %rbp
    pushq   %rbx
    pushq   %r12
    pushq   %r13
    pushq   %r14
    pushq   %r15
    subq    $104, %rsp              /* 6*8=48 + 8 ret = 56; +104 = 160 (16-aligned) */

    movq    %rdi, 0(%rsp)           /* ctx */
    movq    %r8,  8(%rsp)           /* orig re handle */
    movq    %r9,  16(%rsp)          /* orig im handle */
    movq    %rsi, 24(%rsp)          /* rem frames */
    movl    %edx, 32(%rsp)          /* f */
    movd    %ecx, %xmm15            /* inv_s */
    shufps  $0, %xmm15, %xmm15      /* inv_s x4 */

    testq   %rsi, %rsi
    je      .Lf_done

    movq    (%rdi), %rax            /* heap */

.macro DECODE_A hreg, dstreg
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

    DECODE_A %r8, %r8               /* re base */
    DECODE_A %r9, %r9               /* im base */
    movq    0x10(%rbp), %rcx
    DECODE_A %rcx, %r10             /* twr base */
    movq    0x18(%rbp), %rcx
    DECODE_A %rcx, %r11             /* twi base */

    .align 16
.Lframe_loop:
    /* ---- 1. Bit-reversal permutation (N=512, 9 bits) ---- */
    xorl    %ebx, %ebx              /* i = 0 */
    .align 16
.Lbr_loop:
    /* 9-bit reverse of %ebx -> %edx */
    movl    %ebx, %eax
    xorl    %edx, %edx
    movl    $9, %ecx
.Lbr_bits:
    shll    $1, %edx
    movl    %eax, %esi
    andl    $1, %esi
    orl     %esi, %edx
    shrl    $1, %eax
    subl    $1, %ecx
    jne     .Lbr_bits

    cmpl    %edx, %ebx
    jae     .Lbr_next
    movss   (%r8,%rbx,8), %xmm0
    movss   (%r8,%rdx,8), %xmm1
    movss   %xmm1, (%r8,%rbx,8)
    movss   %xmm0, (%r8,%rdx,8)
    movss   (%r9,%rbx,8), %xmm0
    movss   (%r9,%rdx,8), %xmm1
    movss   %xmm1, (%r9,%rbx,8)
    movss   %xmm0, (%r9,%rdx,8)
.Lbr_next:
    addq    $1, %rbx
    cmpq    $512, %rbx
    jne     .Lbr_loop

    /* ---- 2. Stages s = 0, 1 (scalar: half = 1, 2) ---- */
    /* Stage 0: half = 1, step = 2, wr = twr[0], wi = twi[0] */
    movss   0(%r10), %xmm0          /* wr0 */
    movss   0(%r11), %xmm1          /* wi0 */
    xorl    %ebx, %ebx
    .align 16
.Ls0_loop:
    leal    1(%rbx), %edi
    movss   (%r8,%rdi,8), %xmm2     /* vr */
    movss   (%r9,%rdi,8), %xmm3     /* vi */
    movaps  %xmm0, %xmm4
    mulss   %xmm2, %xmm4
    movaps  %xmm1, %xmm5
    mulss   %xmm3, %xmm5
    subss   %xmm5, %xmm4            /* tr */
    movaps  %xmm0, %xmm6
    mulss   %xmm3, %xmm6
    movaps  %xmm1, %xmm7
    mulss   %xmm2, %xmm7
    addss   %xmm7, %xmm6            /* ti */
    movss   (%r8,%rbx,8), %xmm2     /* ur */
    movss   (%r9,%rbx,8), %xmm3     /* ui */
    movaps  %xmm2, %xmm5
    addss   %xmm4, %xmm5
    subss   %xmm4, %xmm2
    movss   %xmm5, (%r8,%rbx,8)
    movss   %xmm2, (%r8,%rdi,8)
    movaps  %xmm3, %xmm5
    addss   %xmm6, %xmm5
    subss   %xmm6, %xmm3
    movss   %xmm5, (%r9,%rbx,8)
    movss   %xmm3, (%r9,%rdi,8)
    addq    $2, %rbx
    cmpq    $512, %rbx
    jne     .Ls0_loop

    /* Stage 1: half = 2, step = 4, tw_stride = 128 */
    movl    $1, 40(%rsp)            /* s = 1 */
.Ls_scalar_loop:
    movl    40(%rsp), %ecx
    movl    $1, %r12d
    shll    %cl, %r12d              /* half */
    leal    (%r12,%r12), %r13d      /* step */
    addl    $1, %ecx
    movl    $512, %r14d
    shrl    %cl, %r14d              /* tw_stride */
    xorl    %ebx, %ebx              /* base = 0 */
.Ls1_grp:
    xorl    %edx, %edx
    xorl    %eax, %eax
    movl    %ebx, %esi
    leal    (%rbx,%r12), %edi
.Ls1_bf:
    movss   (%r10,%rax,8), %xmm0
    movss   (%r11,%rax,8), %xmm1
    movss   (%r8,%rdi,8),  %xmm2
    movss   (%r9,%rdi,8),  %xmm3
    movaps  %xmm0, %xmm4
    mulss   %xmm2, %xmm4
    movaps  %xmm1, %xmm5
    mulss   %xmm3, %xmm5
    subss   %xmm5, %xmm4
    mulss   %xmm3, %xmm0
    mulss   %xmm2, %xmm1
    addss   %xmm1, %xmm0
    movss   (%r8,%rsi,8),  %xmm2
    movss   (%r9,%rsi,8),  %xmm3
    movaps  %xmm2, %xmm5
    addss   %xmm4, %xmm5
    subss   %xmm4, %xmm2
    movss   %xmm5, (%r8,%rsi,8)
    movss   %xmm2, (%r8,%rdi,8)
    movaps  %xmm3, %xmm5
    addss   %xmm0, %xmm5
    subss   %xmm0, %xmm3
    movss   %xmm5, (%r9,%rsi,8)
    movss   %xmm3, (%r9,%rdi,8)
    addq    $1, %rsi
    addq    $1, %rdi
    addq    %r14, %rax
    addl    $1, %edx
    cmpl    %r12d, %edx
    jne     .Ls1_bf
    addl    %r13d, %ebx
    cmpl    $512, %ebx
    jne     .Ls1_grp

    /* ---- 3. Stages s = 2..8 (4-wide SSE! half = 4, 8, 16, 32, 64, 128, 256) ---- */
    movl    $2, 40(%rsp)
    .align 16
.Ls_sse_stage:
    movl    40(%rsp), %ecx
    movl    $1, %r12d
    shll    %cl, %r12d              /* half */
    leal    (%r12,%r12), %r13d      /* step */
    addl    $1, %ecx
    movl    $512, %r14d
    shrl    %cl, %r14d              /* tw_stride */
    leaq    (,%r14,8), %r15         /* tw_byte_stride = tw_stride * 8 */

    xorl    %ebx, %ebx              /* base = 0 */
    .align 16
.Ls_sse_grp:
    xorl    %edx, %edx              /* k = 0 */
    movq    %r10, %rcx              /* p_twr */
    movq    %r11, %rax              /* p_twi */
    movl    %ebx, %esi              /* u */
    leal    (%rbx,%r12), %edi       /* v */

    .align 16
.Ls_sse_bf4:
    /* Pack 4x wr into xmm0, 4x wi into xmm1 */
    movss   (%rcx), %xmm0
    movss   (%rcx,%r15,1), %xmm4
    unpcklps %xmm4, %xmm0
    movss   (%rcx,%r15,2), %xmm5
    leaq    (%rcx,%r15,2), %rcx
    movss   (%rcx,%r15,1), %xmm6
    unpcklps %xmm6, %xmm5
    movlhps %xmm5, %xmm0            /* wr[0..3] */
    leaq    (%rcx,%r15,2), %rcx     /* p_twr += 4*tw_byte_stride */

    movss   (%rax), %xmm1
    movss   (%rax,%r15,1), %xmm4
    unpcklps %xmm4, %xmm1
    movss   (%rax,%r15,2), %xmm5
    leaq    (%rax,%r15,2), %rax
    movss   (%rax,%r15,1), %xmm6
    unpcklps %xmm6, %xmm5
    movlhps %xmm5, %xmm1            /* wi[0..3] */
    leaq    (%rax,%r15,2), %rax     /* p_twi += 4*tw_byte_stride */

    /* Pack 4x vr from re[v..v+3] (64-bit slots: stride 8B -> movups+shufps!) */
    movups  0(%r8,%rdi,8), %xmm2    /* [vr0, *, vr1, *] */
    movups  16(%r8,%rdi,8), %xmm4   /* [vr2, *, vr3, *] */
    shufps  $0x88, %xmm4, %xmm2     /* [vr0, vr1, vr2, vr3] */

    movups  0(%r9,%rdi,8), %xmm3    /* [vi0, *, vi1, *] */
    movups  16(%r9,%rdi,8), %xmm4   /* [vi2, *, vi3, *] */
    shufps  $0x88, %xmm4, %xmm3     /* [vi0, vi1, vi2, vi3] */

    /* tr = wr*vr - wi*vi ; ti = wr*vi + wi*vr */
    movaps  %xmm0, %xmm4
    mulps   %xmm2, %xmm4
    movaps  %xmm1, %xmm5
    mulps   %xmm3, %xmm5
    subps   %xmm5, %xmm4            /* tr[0..3] */

    mulps   %xmm3, %xmm0
    mulps   %xmm2, %xmm1
    addps   %xmm1, %xmm0            /* ti[0..3] */

    /* Load 4x ur, 4x ui */
    movups  0(%r8,%rsi,8), %xmm2
    movups  16(%r8,%rsi,8), %xmm5
    shufps  $0x88, %xmm5, %xmm2     /* ur[0..3] */

    movups  0(%r9,%rsi,8), %xmm3
    movups  16(%r9,%rsi,8), %xmm5
    shufps  $0x88, %xmm5, %xmm3     /* ui[0..3] */

    movaps  %xmm2, %xmm5
    addps   %xmm4, %xmm5            /* ur + tr */
    subps   %xmm4, %xmm2            /* ur - tr */

    movaps  %xmm3, %xmm6
    addps   %xmm0, %xmm6            /* ui + ti */
    subps   %xmm0, %xmm3            /* ui - ti */

    /* Scatter 4x F32 into 64-bit array slots (zero-high 32b preserved via movss) */
    movss   %xmm5, 0(%r8,%rsi,8)
    shufps  $0x39, %xmm5, %xmm5
    movss   %xmm5, 8(%r8,%rsi,8)
    shufps  $0x39, %xmm5, %xmm5
    movss   %xmm5, 16(%r8,%rsi,8)
    shufps  $0x39, %xmm5, %xmm5
    movss   %xmm5, 24(%r8,%rsi,8)

    movss   %xmm2, 0(%r8,%rdi,8)
    shufps  $0x39, %xmm2, %xmm2
    movss   %xmm2, 8(%r8,%rdi,8)
    shufps  $0x39, %xmm2, %xmm2
    movss   %xmm2, 16(%r8,%rdi,8)
    shufps  $0x39, %xmm2, %xmm2
    movss   %xmm2, 24(%r8,%rdi,8)

    movss   %xmm6, 0(%r9,%rsi,8)
    shufps  $0x39, %xmm6, %xmm6
    movss   %xmm6, 8(%r9,%rsi,8)
    shufps  $0x39, %xmm6, %xmm6
    movss   %xmm6, 16(%r9,%rsi,8)
    shufps  $0x39, %xmm6, %xmm6
    movss   %xmm6, 24(%r9,%rsi,8)

    movss   %xmm3, 0(%r9,%rdi,8)
    shufps  $0x39, %xmm3, %xmm3
    movss   %xmm3, 8(%r9,%rdi,8)
    shufps  $0x39, %xmm3, %xmm3
    movss   %xmm3, 16(%r9,%rdi,8)
    shufps  $0x39, %xmm3, %xmm3
    movss   %xmm3, 24(%r9,%rdi,8)

    addq    $4, %rsi
    addq    $4, %rdi
    addl    $4, %edx
    cmpl    %r12d, %edx
    jne     .Ls_sse_bf4

    addl    %r13d, %ebx
    cmpl    $512, %ebx
    jne     .Ls_sse_grp

    addl    $1, 40(%rsp)
    cmpl    $9, 40(%rsp)
    jne     .Ls_sse_stage

    /* ---- 4. Normalize loop (N=512, 4-wide SSE) ---- */
    /* drive = ((float)((f & 7) + 1) / 64.0f) - (1.0f / 16.0f) */
    movl    32(%rsp), %eax
    andl    $7, %eax
    addl    $1, %eax
    cvtsi2ssl %eax, %xmm0
    divss   .Lc64(%rip), %xmm0
    subss   .Lc1_16(%rip), %xmm0
    shufps  $0, %xmm0, %xmm0        /* drive x4 */

    xorl    %ebx, %ebx
    .align 16
.Lnorm_loop:
    movups  0(%r8,%rbx,8), %xmm1
    movups  16(%r8,%rbx,8), %xmm2
    shufps  $0x88, %xmm2, %xmm1
    mulps   %xmm15, %xmm1
    addps   %xmm0, %xmm1
    movss   %xmm1, 0(%r8,%rbx,8)
    shufps  $0x39, %xmm1, %xmm1
    movss   %xmm1, 8(%r8,%rbx,8)
    shufps  $0x39, %xmm1, %xmm1
    movss   %xmm1, 16(%r8,%rbx,8)
    shufps  $0x39, %xmm1, %xmm1
    movss   %xmm1, 24(%r8,%rbx,8)

    movups  0(%r9,%rbx,8), %xmm1
    movups  16(%r9,%rbx,8), %xmm2
    shufps  $0x88, %xmm2, %xmm1
    mulps   %xmm15, %xmm1
    subps   %xmm0, %xmm1
    movss   %xmm1, 0(%r9,%rbx,8)
    shufps  $0x39, %xmm1, %xmm1
    movss   %xmm1, 8(%r9,%rbx,8)
    shufps  $0x39, %xmm1, %xmm1
    movss   %xmm1, 16(%r9,%rbx,8)
    shufps  $0x39, %xmm1, %xmm1
    movss   %xmm1, 24(%r9,%rbx,8)

    addq    $4, %rbx
    cmpq    $512, %rbx
    jne     .Lnorm_loop

    addl    $1, 32(%rsp)            /* f++ */
    subq    $1, 24(%rsp)            /* rem-- */
    jne     .Lframe_loop

.Lf_done:
    /* Box PF{re, im} (cid 0x28, 2 fields) */
    movq    0(%rsp), %rdi           /* ctx */
    movl    $0x28, %esi
    leaq    8(%rsp), %rdx           /* {re, im} */
    movl    $2, %ecx
    callq   p111_rt_ctor

    addq    $104, %rsp
    popq    %r15
    popq    %r14
    popq    %r13
    popq    %r12
    popq    %rbx
    popq    %rbp
    ret
    .size "$direct.run_frames", .-"$direct.run_frames"

    .section .rodata
    .align 4
.Lc64:
    .float 64.0
.Lc1_16:
    .float 0.0625
