/* k3_a_quad_hoist_scalar.S — Hand-ASM probe Variant A for k3_soa_particle_acc ($direct.integrate)
 * Scalar XMM + 4-array hoist (px, py, vx, vy) + P4 unboxing + 0 movd/spills.
 * ABI: (ctx=%rdi, rem=%rsi, i=%rdx, gx=%rcx, gy=%r8, st=%r9) -> %rax (returns st)
 */
    .section .rodata
    .align 16
.Ldt:   .float 0.03125          /* 1/32 */
.Ldamp: .float 0.99609375       /* 255/256 */
.Lk:    .float 0.0625           /* 1/16 */

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
    /* Decode st = P4{px, py, vx, vy} -> %r10 */
    movq    %r9, %rax
    shlq    $24, %rax
    shrq    $24, %rax
    testq   %r9, %r9
    jns     1f
    movq    (%rdi,%rax,8), %rax
    shrq    $24, %rax
1:  leaq    (%rdi,%rax,8), %r10

    /* Decode px -> %r11 */
    movq    0(%r10), %rax
    movq    %rax, %r11
    shlq    $24, %r11
    shrq    $24, %r11
    testq   %rax, %rax
    jns     2f
    movq    (%rdi,%r11,8), %r11
    shrq    $24, %r11
2:  leaq    (%rdi,%r11,8), %r11
    leaq    (%r11,%rdx,8), %r11

    /* Decode py -> %r12 */
    movq    8(%r10), %rax
    movq    %rax, %r12
    shlq    $24, %r12
    shrq    $24, %r12
    testq   %rax, %rax
    jns     3f
    movq    (%rdi,%r12,8), %r12
    shrq    $24, %r12
3:  leaq    (%rdi,%r12,8), %r12
    leaq    (%r12,%rdx,8), %r12

    /* Decode vx -> %r13 */
    movq    16(%r10), %rax
    movq    %rax, %r13
    shlq    $24, %r13
    shrq    $24, %r13
    testq   %rax, %rax
    jns     4f
    movq    (%rdi,%r13,8), %r13
    shrq    $24, %r13
4:  leaq    (%rdi,%r13,8), %r13
    leaq    (%r13,%rdx,8), %r13

    /* Decode vy -> %r10 */
    movq    24(%r10), %rax
    movq    %rax, %r10
    shlq    $24, %r10
    shrq    $24, %r10
    testq   %rax, %rax
    jns     5f
    movq    (%rdi,%r10,8), %r10
    shrq    $24, %r10
5:  leaq    (%rdi,%r10,8), %r10
    leaq    (%r10,%rdx,8), %r10

    movd    %ecx, %xmm4             /* gx */
    movd    %r8d, %xmm5             /* gy */
    movss   .Ldt(%rip), %xmm6
    movss   .Ldamp(%rip), %xmm7
    movss   .Lk(%rip), %xmm8

    .align 16
.Lloop:
    movss   (%r11), %xmm0           /* x */
    movss   (%r12), %xmm1           /* y */
    movss   (%r13), %xmm2           /* ux */
    movss   (%r10), %xmm3           /* uy */

    /* nvx = ux*damp + (gx - k*x)*dt */
    mulss   %xmm7, %xmm2
    movaps  %xmm0, %xmm9
    mulss   %xmm8, %xmm9
    movaps  %xmm4, %xmm10
    subss   %xmm9, %xmm10
    mulss   %xmm6, %xmm10
    addss   %xmm10, %xmm2           /* nvx */

    /* nvy = uy*damp + (gy - k*y)*dt */
    mulss   %xmm7, %xmm3
    movaps  %xmm1, %xmm9
    mulss   %xmm8, %xmm9
    movaps  %xmm5, %xmm10
    subss   %xmm9, %xmm10
    mulss   %xmm6, %xmm10
    addss   %xmm10, %xmm3           /* nvy */

    /* npx = x + nvx*dt; npy = y + nvy*dt */
    movaps  %xmm2, %xmm9
    mulss   %xmm6, %xmm9
    addss   %xmm9, %xmm0
    movaps  %xmm3, %xmm10
    mulss   %xmm6, %xmm10
    addss   %xmm10, %xmm1

    movss   %xmm0, (%r11)
    movss   %xmm1, (%r12)
    movss   %xmm2, (%r13)
    movss   %xmm3, (%r10)

    addq    $8, %r11
    addq    $8, %r12
    addq    $8, %r13
    addq    $8, %r10
    subq    $1, %rsi
    jne     .Lloop

    movq    %r9, %rax
    popq    %r13
    popq    %r12
    ret
    .size "$direct.integrate", .-"$direct.integrate"
