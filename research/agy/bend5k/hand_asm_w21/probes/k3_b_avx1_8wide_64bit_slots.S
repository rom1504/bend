/* k3_b_avx1_8wide_64bit_slots.S — Hand-ASM probe Variant B for k3_soa_particle_acc ($direct.integrate)
 * 8-wide AVX1 (ymm) directly over Bend's unmodified 64-bit Array<F32> slots for all 4 SoA arrays!
 * ABI: (ctx=%rdi, rem=%rsi, i=%rdx, gx=%rcx, gy=%r8, st=%r9) -> %rax (returns st)
 */
    .section .rodata
    .align 32
.Ldt:   .float 0.03125
.Ldamp: .float 0.99609375
.Lk:    .float 0.0625

    .text
    .globl "$direct.integrate"
    .type "$direct.integrate", @function
    .align 16
"$direct.integrate":
    testq   %rsi, %rsi
    jne     .Lgo
    movq    %r9, %rax
    ret
.Lgo:
    pushq   %r12
    pushq   %r13

    movq    (%rdi), %rdi            /* heap */
    movq    %r9, %rax
    shlq    $24, %rax
    shrq    $24, %rax
    testq   %r9, %r9
    jns     1f
    movq    (%rdi,%rax,8), %rax
    shrq    $24, %rax
1:  leaq    (%rdi,%rax,8), %r10

    movq    0(%r10), %rax
    movq    %rax, %r11
    shlq    $24, %r11
    shrq    $24, %r11
    testq   %rax, %rax
    jns     2f
    movq    (%rdi,%r11,8), %r11
    shrq    $24, %r11
2:  leaq    (%rdi,%r11,8), %r11
    leaq    (%r11,%rdx,8), %r11     /* px */

    movq    8(%r10), %rax
    movq    %rax, %r12
    shlq    $24, %r12
    shrq    $24, %r12
    testq   %rax, %rax
    jns     3f
    movq    (%rdi,%r12,8), %r12
    shrq    $24, %r12
3:  leaq    (%rdi,%r12,8), %r12
    leaq    (%r12,%rdx,8), %r12     /* py */

    movq    16(%r10), %rax
    movq    %rax, %r13
    shlq    $24, %r13
    shrq    $24, %r13
    testq   %rax, %rax
    jns     4f
    movq    (%rdi,%r13,8), %r13
    shrq    $24, %r13
4:  leaq    (%rdi,%r13,8), %r13
    leaq    (%r13,%rdx,8), %r13     /* vx */

    movq    24(%r10), %rax
    movq    %rax, %r10
    shlq    $24, %r10
    shrq    $24, %r10
    testq   %rax, %rax
    jns     5f
    movq    (%rdi,%r10,8), %r10
    shrq    $24, %r10
5:  leaq    (%rdi,%r10,8), %r10
    leaq    (%r10,%rdx,8), %r10     /* vy */

    subq    $16, %rsp
    movl    %ecx, 0(%rsp)
    movl    %r8d, 4(%rsp)
    vbroadcastss 0(%rsp), %ymm4     /* gx */
    vbroadcastss 4(%rsp), %ymm5     /* gy */
    addq    $16, %rsp

    vbroadcastss .Ldt(%rip), %ymm6
    vbroadcastss .Ldamp(%rip), %ymm7
    vbroadcastss .Lk(%rip), %ymm8
    vxorps  %xmm15, %xmm15, %xmm15  /* zero for scatter */

    cmpq    $8, %rsi
    jb      .Ltail

    .align 16
.Lvec8:
    /* Gather px[0..7] -> ymm0 */
    vmovups 0(%r11), %xmm0
    vmovups 16(%r11), %xmm9
    vshufps $0x88, %xmm9, %xmm0, %xmm0
    vmovups 32(%r11), %xmm10
    vmovups 48(%r11), %xmm9
    vshufps $0x88, %xmm9, %xmm10, %xmm10
    vinsertf128 $1, %xmm10, %ymm0, %ymm0

    /* Gather py[0..7] -> ymm1 */
    vmovups 0(%r12), %xmm1
    vmovups 16(%r12), %xmm9
    vshufps $0x88, %xmm9, %xmm1, %xmm1
    vmovups 32(%r12), %xmm10
    vmovups 48(%r12), %xmm9
    vshufps $0x88, %xmm9, %xmm10, %xmm10
    vinsertf128 $1, %xmm10, %ymm1, %ymm1

    /* Gather vx[0..7] -> ymm2 */
    vmovups 0(%r13), %xmm2
    vmovups 16(%r13), %xmm9
    vshufps $0x88, %xmm9, %xmm2, %xmm2
    vmovups 32(%r13), %xmm10
    vmovups 48(%r13), %xmm9
    vshufps $0x88, %xmm9, %xmm10, %xmm10
    vinsertf128 $1, %xmm10, %ymm2, %ymm2

    /* Gather vy[0..7] -> ymm3 */
    vmovups 0(%r10), %xmm3
    vmovups 16(%r10), %xmm9
    vshufps $0x88, %xmm9, %xmm3, %xmm3
    vmovups 32(%r10), %xmm10
    vmovups 48(%r10), %xmm9
    vshufps $0x88, %xmm9, %xmm10, %xmm10
    vinsertf128 $1, %xmm10, %ymm3, %ymm3

    /* Compute nvx, nvy, npx, npy in 8-wide AVX1 */
    vmulps  %ymm7, %ymm2, %ymm2     /* ux * damp */
    vmulps  %ymm8, %ymm0, %ymm9     /* k * x */
    vsubps  %ymm9, %ymm4, %ymm9     /* gx - k*x */
    vmulps  %ymm6, %ymm9, %ymm9     /* * dt */
    vaddps  %ymm9, %ymm2, %ymm2     /* nvx */

    vmulps  %ymm7, %ymm3, %ymm3     /* uy * damp */
    vmulps  %ymm8, %ymm1, %ymm10    /* k * y */
    vsubps  %ymm10, %ymm5, %ymm10   /* gy - k*y */
    vmulps  %ymm6, %ymm10, %ymm10   /* * dt */
    vaddps  %ymm10, %ymm3, %ymm3    /* nvy */

    vmulps  %ymm6, %ymm2, %ymm9
    vaddps  %ymm9, %ymm0, %ymm0     /* npx */
    vmulps  %ymm6, %ymm3, %ymm10
    vaddps  %ymm10, %ymm1, %ymm1    /* npy */

    /* Scatter px */
    vunpcklps %xmm15, %xmm0, %xmm9
    vmovups %xmm9, 0(%r11)
    vunpckhps %xmm15, %xmm0, %xmm9
    vmovups %xmm9, 16(%r11)
    vextractf128 $1, %ymm0, %xmm0
    vunpcklps %xmm15, %xmm0, %xmm9
    vmovups %xmm9, 32(%r11)
    vunpckhps %xmm15, %xmm0, %xmm9
    vmovups %xmm9, 48(%r11)

    /* Scatter py */
    vunpcklps %xmm15, %xmm1, %xmm9
    vmovups %xmm9, 0(%r12)
    vunpckhps %xmm15, %xmm1, %xmm9
    vmovups %xmm9, 16(%r12)
    vextractf128 $1, %ymm1, %xmm1
    vunpcklps %xmm15, %xmm1, %xmm9
    vmovups %xmm9, 32(%r12)
    vunpckhps %xmm15, %xmm1, %xmm9
    vmovups %xmm9, 48(%r12)

    /* Scatter vx */
    vunpcklps %xmm15, %xmm2, %xmm9
    vmovups %xmm9, 0(%r13)
    vunpckhps %xmm15, %xmm2, %xmm9
    vmovups %xmm9, 16(%r13)
    vextractf128 $1, %ymm2, %xmm2
    vunpcklps %xmm15, %xmm2, %xmm9
    vmovups %xmm9, 32(%r13)
    vunpckhps %xmm15, %xmm2, %xmm9
    vmovups %xmm9, 48(%r13)

    /* Scatter vy */
    vunpcklps %xmm15, %xmm3, %xmm9
    vmovups %xmm9, 0(%r10)
    vunpckhps %xmm15, %xmm3, %xmm9
    vmovups %xmm9, 16(%r10)
    vextractf128 $1, %ymm3, %xmm3
    vunpcklps %xmm15, %xmm3, %xmm9
    vmovups %xmm9, 32(%r10)
    vunpckhps %xmm15, %xmm3, %xmm9
    vmovups %xmm9, 48(%r10)

    addq    $64, %r11
    addq    $64, %r12
    addq    $64, %r13
    addq    $64, %r10
    subq    $8, %rsi
    cmpq    $8, %rsi
    jae     .Lvec8

.Ltail:
    testq   %rsi, %rsi
    je      .Ldone
.Ltail_loop:
    vmovss  (%r11), %xmm0
    vmovss  (%r12), %xmm1
    vmovss  (%r13), %xmm2
    vmovss  (%r10), %xmm3
    vmulss  %xmm7, %xmm2, %xmm2
    vmulss  %xmm8, %xmm0, %xmm9
    vsubss  %xmm9, %xmm4, %xmm9
    vmulss  %xmm6, %xmm9, %xmm9
    vaddss  %xmm9, %xmm2, %xmm2
    vmulss  %xmm7, %xmm3, %xmm3
    vmulss  %xmm8, %xmm1, %xmm10
    vsubss  %xmm10, %xmm5, %xmm10
    vmulss  %xmm6, %xmm10, %xmm10
    vaddss  %xmm10, %xmm3, %xmm3
    vmulss  %xmm6, %xmm2, %xmm9
    vaddss  %xmm9, %xmm0, %xmm0
    vmulss  %xmm6, %xmm3, %xmm10
    vaddss  %xmm10, %xmm1, %xmm1
    vmovss  %xmm0, (%r11)
    vmovss  %xmm1, (%r12)
    vmovss  %xmm2, (%r13)
    vmovss  %xmm3, (%r10)
    addq    $8, %r11
    addq    $8, %r12
    addq    $8, %r13
    addq    $8, %r10
    subq    $1, %rsi
    jne     .Ltail_loop

.Ldone:
    vzeroupper
    movq    %r9, %rax
    popq    %r13
    popq    %r12
    ret
    .size "$direct.integrate", .-"$direct.integrate"
