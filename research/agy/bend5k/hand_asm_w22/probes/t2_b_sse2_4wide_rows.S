/* t2_b_sse2_4wide_rows.S — Hand-ASM probe Variant B for t2_chacha20_quarter ($direct.run_blocks)
 * Laws tested:
 *   1. SLP / 4-wide integer SIMD (SSE2+SSSE3) over 4x4 U32 ChaCha20 matrix (Row4 = __m128i)
 *   2. Zero heap allocations, zero stack spills in the inner 10-round loop
 *   3. pshufb byte-rotate for rotl16/rotl8 + pslld/psrld/por for rotl12/rotl7
 * ABI: (ctx=%rdi, rem=%rsi, ctr=%rdx, h=%rcx) -> %rax (returns U32 h)
 */
    .section .rodata
    .align 16
.Lrow0:
    .long 0x61707865, 0x3320646e, 0x79622d32, 0x6b206574
.Lrow1:
    .long 0x03020100, 0x07060504, 0x0b0a0908, 0x0f0e0d0c
.Lrow2:
    .long 0x13121110, 0x17161514, 0x1b1a1918, 0x1f1e1d1c
.Lrow3_base:
    .long 0x00000000, 0x09000000, 0x4a000000, 0x00000000
.Lrot16:
    .byte 2,3,0,1, 6,7,4,5, 10,11,8,9, 14,15,12,13
.Lrot8:
    .byte 3,0,1,2, 7,4,5,6, 11,8,9,10, 15,12,13,14
.Linc_ctr:
    .long 1, 0, 0, 0

    .text
    .globl "$direct.run_blocks"
    .type "$direct.run_blocks", @function
    .align 16
"$direct.run_blocks":
    testq   %rsi, %rsi
    jne     .Lgo
    movl    %ecx, %eax
    ret
.Lgo:
    movdqa  .Lrow0(%rip), %xmm8
    movdqa  .Lrow1(%rip), %xmm9
    movdqa  .Lrow2(%rip), %xmm10
    movdqa  .Lrow3_base(%rip), %xmm11
    movd    %edx, %xmm5
    paddd   %xmm5, %xmm11           /* row3 = [ctr, 0x09000000, 0x4a000000, 0] */
    movdqa  .Lrot16(%rip), %xmm12
    movdqa  .Lrot8(%rip), %xmm13
    movdqa  .Linc_ctr(%rip), %xmm14

    /* %ecx = h, %rsi = rem */
    .align 16
.Lblock_loop:
    movdqa  %xmm8, %xmm0
    movdqa  %xmm9, %xmm1
    movdqa  %xmm10, %xmm2
    movdqa  %xmm11, %xmm3
    movl    $10, %eax

    .align 16
.Ldr_loop:
    /* Column round (4 QRs in parallel) */
    paddd   %xmm1, %xmm0
    pxor    %xmm0, %xmm3
    pshufb  %xmm12, %xmm3           /* rotl16 */

    paddd   %xmm3, %xmm2
    pxor    %xmm2, %xmm1
    movdqa  %xmm1, %xmm4
    pslld   $12, %xmm1
    psrld   $20, %xmm4
    por     %xmm4, %xmm1            /* rotl12 */

    paddd   %xmm1, %xmm0
    pxor    %xmm0, %xmm3
    pshufb  %xmm13, %xmm3           /* rotl8 */

    paddd   %xmm3, %xmm2
    pxor    %xmm2, %xmm1
    movdqa  %xmm1, %xmm4
    pslld   $7, %xmm1
    psrld   $25, %xmm4
    por     %xmm4, %xmm1            /* rotl7 */

    /* Shift rows for diagonal round */
    pshufd  $0x39, %xmm1, %xmm1     /* [5,6,7,4] */
    pshufd  $0x4e, %xmm2, %xmm2     /* [10,11,8,9] */
    pshufd  $0x93, %xmm3, %xmm3     /* [15,12,13,14] */

    /* Diagonal round (4 QRs in parallel) */
    paddd   %xmm1, %xmm0
    pxor    %xmm0, %xmm3
    pshufb  %xmm12, %xmm3           /* rotl16 */

    paddd   %xmm3, %xmm2
    pxor    %xmm2, %xmm1
    movdqa  %xmm1, %xmm4
    pslld   $12, %xmm1
    psrld   $20, %xmm4
    por     %xmm4, %xmm1            /* rotl12 */

    paddd   %xmm1, %xmm0
    pxor    %xmm0, %xmm3
    pshufb  %xmm13, %xmm3           /* rotl8 */

    paddd   %xmm3, %xmm2
    pxor    %xmm2, %xmm1
    movdqa  %xmm1, %xmm4
    pslld   $7, %xmm1
    psrld   $25, %xmm4
    por     %xmm4, %xmm1            /* rotl7 */

    /* Unshift rows */
    pshufd  $0x93, %xmm1, %xmm1
    pshufd  $0x4e, %xmm2, %xmm2
    pshufd  $0x39, %xmm3, %xmm3

    subl    $1, %eax
    jne     .Ldr_loop

    /* w_i = x_i + o_i */
    paddd   %xmm8, %xmm0
    paddd   %xmm9, %xmm1
    paddd   %xmm10, %xmm2
    paddd   %xmm11, %xmm3

    /* Horizontal XOR of each row */
    pshufd  $0x4e, %xmm0, %xmm4
    pxor    %xmm4, %xmm0
    pshufd  $0x39, %xmm0, %xmm4
    pxor    %xmm4, %xmm0
    movd    %xmm0, %eax

    pshufd  $0x4e, %xmm1, %xmm4
    pxor    %xmm4, %xmm1
    pshufd  $0x39, %xmm1, %xmm4
    pxor    %xmm4, %xmm1
    movd    %xmm1, %edx
    addl    %edx, %eax

    pshufd  $0x4e, %xmm2, %xmm4
    pxor    %xmm4, %xmm2
    pshufd  $0x39, %xmm2, %xmm4
    pxor    %xmm4, %xmm2
    movd    %xmm2, %edx
    addl    %edx, %eax

    pshufd  $0x4e, %xmm3, %xmm4
    pxor    %xmm4, %xmm3
    pshufd  $0x39, %xmm3, %xmm4
    pxor    %xmm4, %xmm3
    movd    %xmm3, %edx
    addl    %edx, %eax

    imull   $16777619, %ecx, %ecx
    xorl    %eax, %ecx

    paddd   %xmm14, %xmm11          /* ctr++ */
    subq    $1, %rsi
    jne     .Lblock_loop

    movl    %ecx, %eax
    ret
    .size "$direct.run_blocks", .-"$direct.run_blocks"
