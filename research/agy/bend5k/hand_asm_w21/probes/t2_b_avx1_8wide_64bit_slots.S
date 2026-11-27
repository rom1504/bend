/* t2_b_avx1_8wide_64bit_slots.S — Hand-ASM probe Variant B for t2_poly_eval_f32 ($direct.sweep_arr)
 * 8-wide AVX1 (ymm0..ymm15) directly over Bend's unmodified 64-bit Array<F32> slots!
 * Zero ABI change: gathers 8 F32s from 8x8B slots, runs 4 Newton-Raphson steps in ymm, scatters 8 F32s.
 * ABI: (ctx=%rdi, rem=%rsi, i=%rdx, bias=%rcx(F32 bits), sp=%r8) -> %rax (returns sp)
 */
    .section .rodata
    .align 32
.Lc7:   .float 0.015625
.Lc6:   .float 0.00390625
.Lc5:   .float 0.0625
.Lc4:   .float 0.0078125
.Lc3:   .float 0.25
.Lc1:   .float 4.0
.Ld7:   .float 0.109375
.Ld6:   .float 0.0234375
.Ld5:   .float 0.3125
.Ld4:   .float 0.03125
.Ld3:   .float 0.75
.Ld2:   .float 0.125
.Lhalf: .float 0.5

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
    movq    %r8, %rax
    shlq    $24, %rax
    shrq    $24, %rax
    testq   %r8, %r8
    jns     1f
    movq    (%rdi,%rax,8), %rax
    shrq    $24, %rax
1:  leaq    (%rdi,%rax,8), %r9

    movq    0(%r9), %rax            /* xs */
    movq    %rax, %r10
    shlq    $24, %r10
    shrq    $24, %r10
    testq   %rax, %rax
    jns     2f
    movq    (%rdi,%r10,8), %r10
    shrq    $24, %r10
2:  leaq    (%rdi,%r10,8), %r10

    movq    8(%r9), %rax            /* out */
    movq    %rax, %r11
    shlq    $24, %r11
    shrq    $24, %r11
    testq   %rax, %rax
    jns     3f
    movq    (%rdi,%r11,8), %r11
    shrq    $24, %r11
3:  leaq    (%rdi,%r11,8), %r11

    leaq    (%r10,%rdx,8), %r10
    leaq    (%r11,%rdx,8), %r11

    /* Broadcast bias + constants into ymm3..ymm15 */
    subq    $8, %rsp
    movl    %ecx, (%rsp)
    vbroadcastss (%rsp), %ymm3      /* bias */
    addq    $8, %rsp

    vbroadcastss .Lc7(%rip), %ymm4
    vbroadcastss .Lc6(%rip), %ymm5
    vbroadcastss .Lc5(%rip), %ymm6
    vbroadcastss .Lc4(%rip), %ymm7
    vbroadcastss .Lc3(%rip), %ymm8
    vbroadcastss .Lc1(%rip), %ymm9
    vbroadcastss .Ld7(%rip), %ymm10
    vbroadcastss .Ld6(%rip), %ymm11
    vbroadcastss .Ld5(%rip), %ymm12
    vbroadcastss .Ld4(%rip), %ymm13
    vbroadcastss .Ld3(%rip), %ymm14
    vbroadcastss .Ld2(%rip), %ymm15

    cmpq    $8, %rsi
    jb      .Ltail

    .align 16
.Lvec8:
    /* Gather 8 F32s from 8 contiguous 64-bit slots (64 bytes):
     *   [x0, _, x1, _] + [x2, _, x3, _] -> shufps $0x88 -> [x0, x1, x2, x3]
     *   [x4, _, x5, _] + [x6, _, x7, _] -> shufps $0x88 -> [x4, x5, x6, x7]
     *   vinsertf128 $1 -> ymm0 = [x0..x7]
     */
    vmovups 0(%r10), %xmm0
    vmovups 16(%r10), %xmm1
    vshufps $0x88, %xmm1, %xmm0, %xmm0
    vmovups 32(%r10), %xmm2
    vmovups 48(%r10), %xmm1
    vshufps $0x88, %xmm1, %xmm2, %xmm2
    vinsertf128 $1, %xmm2, %ymm0, %ymm0

    movl    $4, %eax
    .align 16
.Lnewton8:
    /* p in ymm1, dp in ymm2 (interleaved to hide Ivy Bridge mul/add latency!) */
    vmulps  %ymm4, %ymm0, %ymm1     /* c7*x */
    vmulps  %ymm10, %ymm0, %ymm2    /* d7*x */
    vaddps  %ymm5, %ymm1, %ymm1     /* + c6 */
    vaddps  %ymm11, %ymm2, %ymm2    /* + d6 */
    vmulps  %ymm0, %ymm1, %ymm1
    vmulps  %ymm0, %ymm2, %ymm2
    vaddps  %ymm6, %ymm1, %ymm1     /* + c5 */
    vaddps  %ymm12, %ymm2, %ymm2    /* + d5 */
    vmulps  %ymm0, %ymm1, %ymm1
    vmulps  %ymm0, %ymm2, %ymm2
    vaddps  %ymm7, %ymm1, %ymm1     /* + c4 */
    vaddps  %ymm13, %ymm2, %ymm2    /* + d4 */
    vmulps  %ymm0, %ymm1, %ymm1
    vmulps  %ymm0, %ymm2, %ymm2
    vaddps  %ymm8, %ymm1, %ymm1     /* + c3 */
    vaddps  %ymm14, %ymm2, %ymm2    /* + d3 */
    vmulps  %ymm0, %ymm1, %ymm1
    vmulps  %ymm0, %ymm2, %ymm2
    vaddps  %ymm6, %ymm1, %ymm1     /* + c2 (=c5) */
    vaddps  %ymm15, %ymm2, %ymm2    /* + d2 */
    vmulps  %ymm0, %ymm1, %ymm1
    vmulps  %ymm0, %ymm2, %ymm2
    vaddps  %ymm9, %ymm1, %ymm1     /* + c1 */
    vaddps  %ymm9, %ymm2, %ymm2     /* dp = ... + c1 */
    vmulps  %ymm0, %ymm1, %ymm1
    vsubps  %ymm3, %ymm1, %ymm1     /* p = ... - bias */
    vdivps  %ymm2, %ymm1, %ymm1     /* p / dp */
    vsubps  %ymm1, %ymm0, %ymm0     /* x = x - p/dp */
    subl    $1, %eax
    jne     .Lnewton8

    /* nv = x4 * 0.5 + 0.25 */
    vbroadcastss .Lhalf(%rip), %ymm1
    vmulps  %ymm1, %ymm0, %ymm0
    vaddps  %ymm8, %ymm0, %ymm0

    /* Scatter 8 F32s to 8 contiguous 64-bit slots (zero upper 32 bits of each slot) */
    vxorps  %xmm1, %xmm1, %xmm1
    vunpcklps %xmm1, %xmm0, %xmm2   /* [y0, 0, y1, 0] */
    vmovups %xmm2, 0(%r11)
    vunpckhps %xmm1, %xmm0, %xmm2   /* [y2, 0, y3, 0] */
    vmovups %xmm2, 16(%r11)
    vextractf128 $1, %ymm0, %xmm0
    vunpcklps %xmm1, %xmm0, %xmm2   /* [y4, 0, y5, 0] */
    vmovups %xmm2, 32(%r11)
    vunpckhps %xmm1, %xmm0, %xmm2   /* [y6, 0, y7, 0] */
    vmovups %xmm2, 48(%r11)

    addq    $64, %r10
    addq    $64, %r11
    subq    $8, %rsi
    cmpq    $8, %rsi
    jae     .Lvec8

.Ltail:
    testq   %rsi, %rsi
    je      .Ldone
.Ltail_loop:
    vmovss  (%r10), %xmm0
    movl    $4, %eax
.Ltail_newton:
    vmulss  %xmm4, %xmm0, %xmm1
    vaddss  %xmm5, %xmm1, %xmm1
    vmulss  %xmm0, %xmm1, %xmm1
    vaddss  %xmm6, %xmm1, %xmm1
    vmulss  %xmm0, %xmm1, %xmm1
    vaddss  %xmm7, %xmm1, %xmm1
    vmulss  %xmm0, %xmm1, %xmm1
    vaddss  %xmm8, %xmm1, %xmm1
    vmulss  %xmm0, %xmm1, %xmm1
    vaddss  %xmm6, %xmm1, %xmm1
    vmulss  %xmm0, %xmm1, %xmm1
    vaddss  %xmm9, %xmm1, %xmm1
    vmulss  %xmm0, %xmm1, %xmm1
    vsubss  %xmm3, %xmm1, %xmm1

    vmulss  %xmm10, %xmm0, %xmm2
    vaddss  %xmm11, %xmm2, %xmm2
    vmulss  %xmm0, %xmm2, %xmm2
    vaddss  %xmm12, %xmm2, %xmm2
    vmulss  %xmm0, %xmm2, %xmm2
    vaddss  %xmm13, %xmm2, %xmm2
    vmulss  %xmm0, %xmm2, %xmm2
    vaddss  %xmm14, %xmm2, %xmm2
    vmulss  %xmm0, %xmm2, %xmm2
    vaddss  %xmm15, %xmm2, %xmm2
    vmulss  %xmm0, %xmm2, %xmm2
    vaddss  %xmm9, %xmm2, %xmm2

    vdivss  %xmm2, %xmm1, %xmm1
    vsubss  %xmm1, %xmm0, %xmm0
    subl    $1, %eax
    jne     .Ltail_newton
    vmulss  .Lhalf(%rip), %xmm0, %xmm0
    vaddss  %xmm8, %xmm0, %xmm0
    vmovss  %xmm0, (%r11)
    addq    $8, %r10
    addq    $8, %r11
    subq    $1, %rsi
    jne     .Ltail_loop

.Ldone:
    vzeroupper
    movq    %r8, %rax
    ret
    .size "$direct.sweep_arr", .-"$direct.sweep_arr"
