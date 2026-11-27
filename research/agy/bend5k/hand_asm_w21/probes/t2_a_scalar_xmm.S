/* t2_a_scalar_xmm.S — Hand-ASM probe Variant A for t2_poly_eval_f32 ($direct.sweep_arr)
 * Scalar 1-wide XMM-resident Newton-Raphson (0 movd, hoisted constants, hoisted xs+out, unboxed SPair).
 * ABI: (ctx=%rdi, rem=%rsi, i=%rdx, bias=%rcx(F32 bits), sp=%r8) -> %rax (returns sp)
 */
    .section .rodata
    .align 16
.Lc7:   .float 0.015625         /* 1/64 */
.Lc6:   .float 0.00390625       /* 1/256 */
.Lc5:   .float 0.0625           /* 1/16 */
.Lc4:   .float 0.0078125        /* 1/128 */
.Lc3:   .float 0.25             /* 1/4 */
.Lc1:   .float 4.0              /* 4/1 */
.Ld7:   .float 0.109375         /* 7/64 */
.Ld6:   .float 0.0234375        /* 6/256 */
.Ld5:   .float 0.3125           /* 5/16 */
.Ld4:   .float 0.03125          /* 4/128 */
.Ld3:   .float 0.75             /* 3/4 */
.Ld2:   .float 0.125            /* 2/16 */
.Lhalf: .float 0.5              /* 1/2 */

    .text
    .globl "$direct.sweep_arr"
    .type "$direct.sweep_arr", @function
    .align 16
"$direct.sweep_arr":
    testq   %rsi, %rsi
    jne     .Lgo
    movq    %r8, %rax
    ret
.Lgo:
    movq    (%rdi), %rdi            /* heap */
    /* Decode sp (SPair{xs, out}) */
    movq    %r8, %rax
    shlq    $24, %rax
    shrq    $24, %rax
    testq   %r8, %r8
    jns     1f
    movq    (%rdi,%rax,8), %rax
    shrq    $24, %rax
1:  leaq    (%rdi,%rax,8), %r9      /* &SPair.xs */

    movq    0(%r9), %rax            /* xs handle */
    movq    %rax, %r10
    shlq    $24, %r10
    shrq    $24, %r10
    testq   %rax, %rax
    jns     2f
    movq    (%rdi,%r10,8), %r10
    shrq    $24, %r10
2:  leaq    (%rdi,%r10,8), %r10     /* xs base */

    movq    8(%r9), %rax            /* out handle */
    movq    %rax, %r11
    shlq    $24, %r11
    shrq    $24, %r11
    testq   %rax, %rax
    jns     3f
    movq    (%rdi,%r11,8), %r11
    shrq    $24, %r11
3:  leaq    (%rdi,%r11,8), %r11     /* out base */

    leaq    (%r10,%rdx,8), %r10     /* xs + i */
    leaq    (%r11,%rdx,8), %r11     /* out + i */

    /* Hoist F32 constants into XMM3..XMM15 */
    movd    %ecx, %xmm2             /* bias */
    movss   .Lc7(%rip), %xmm3
    movss   .Lc6(%rip), %xmm4
    movss   .Lc5(%rip), %xmm5
    movss   .Lc4(%rip), %xmm6
    movss   .Lc3(%rip), %xmm7
    movss   .Lc1(%rip), %xmm8
    movss   .Ld7(%rip), %xmm9
    movss   .Ld6(%rip), %xmm10
    movss   .Ld5(%rip), %xmm11
    movss   .Ld4(%rip), %xmm12
    movss   .Ld3(%rip), %xmm13
    movss   .Ld2(%rip), %xmm14
    movss   .Lhalf(%rip), %xmm15

    .align 16
.Lloop:
    movss   (%r10), %xmm0           /* x */
    movl    $4, %eax
    .align 16
.Lnewton:
    /* p = ((((((c7*x + c6)*x + c5)*x + c4)*x + c3)*x + c5)*x + c1)*x - bias */
    movaps  %xmm3, %xmm1
    mulss   %xmm0, %xmm1
    addss   %xmm4, %xmm1
    mulss   %xmm0, %xmm1
    addss   %xmm5, %xmm1
    mulss   %xmm0, %xmm1
    addss   %xmm6, %xmm1
    mulss   %xmm0, %xmm1
    addss   %xmm7, %xmm1
    mulss   %xmm0, %xmm1
    addss   %xmm5, %xmm1
    mulss   %xmm0, %xmm1
    addss   %xmm8, %xmm1
    mulss   %xmm0, %xmm1
    subss   %xmm2, %xmm1            /* %xmm1 = p */

    /* dp = (((((d7*x + d6)*x + d5)*x + d4)*x + d3)*x + d2)*x + c1 */
    /* Use .Lc7/.Ld7 etc; we need one more temp reg -> use memory or reuse */
    movss   .Ld7(%rip), %xmm3
    mulss   %xmm0, %xmm3
    addss   %xmm10, %xmm3
    mulss   %xmm0, %xmm3
    addss   %xmm11, %xmm3
    mulss   %xmm0, %xmm3
    addss   %xmm12, %xmm3
    mulss   %xmm0, %xmm3
    addss   %xmm13, %xmm3
    mulss   %xmm0, %xmm3
    addss   %xmm14, %xmm3
    mulss   %xmm0, %xmm3
    addss   %xmm8, %xmm3            /* %xmm3 = dp */

    divss   %xmm3, %xmm1            /* p / dp */
    subss   %xmm1, %xmm0            /* x = x - p/dp */
    movss   .Lc7(%rip), %xmm3       /* restore c7 */
    subl    $1, %eax
    jne     .Lnewton

    mulss   %xmm15, %xmm0           /* x4 * 0.5 */
    addss   %xmm7, %xmm0            /* + 0.25 */
    movss   %xmm0, (%r11)
    addq    $8, %r10
    addq    $8, %r11
    subq    $1, %rsi
    jne     .Lloop

    movq    %r8, %rax
    ret
    .size "$direct.sweep_arr", .-"$direct.sweep_arr"
