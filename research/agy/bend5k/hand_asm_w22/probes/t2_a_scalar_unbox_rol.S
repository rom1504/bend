/* t2_a_scalar_unbox_rol.S — Hand-ASM probe Variant A for t2_chacha20_quarter ($direct.run_blocks)
 * Laws tested:
 *   1. Recursive multi-level single-constructor record unboxing (ChaMat -> 4x Row4 -> 16 U32s)
 *   2. Hardware rotate fusion (roll $16/$12/$8/$7 instead of shl+shr+or)
 *   3. Zero heap allocations across all 48,000 blocks x 10 double-rounds
 * ABI: (ctx=%rdi, rem=%rsi, ctr=%rdx, h=%rcx) -> %rax (returns U32 h)
 */
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
    pushq   %rbx
    pushq   %rbp
    pushq   %r12
    pushq   %r13
    pushq   %r14
    pushq   %r15
    subq    $104, %rsp

    /* Stack layout:
     *   0..60(%rsp)  : x0..x15 (16 x 4B = 64B)
     *   64(%rsp)     : rem (8B)
     *   72(%rsp)     : ctr (4B)
     *   76(%rsp)     : h (4B)
     */
    movq    %rsi, 64(%rsp)
    movl    %edx, 72(%rsp)
    movl    %ecx, 76(%rsp)

.macro QR a, b, c, d
    addl    \b, \a
    xorl    \a, \d
    roll    $16, \d
    addl    \d, \c
    xorl    \c, \b
    roll    $12, \b
    addl    \b, \a
    xorl    \a, \d
    roll    $8, \d
    addl    \d, \c
    xorl    \c, \b
    roll    $7, \b
.endm

    .align 16
.Lblock_loop:
    /* Init x0..x15 */
    movl    $0x61707865, 0(%rsp)
    movl    $0x3320646e, 4(%rsp)
    movl    $0x79622d32, 8(%rsp)
    movl    $0x6b206574, 12(%rsp)
    movl    $0x03020100, 16(%rsp)
    movl    $0x07060504, 20(%rsp)
    movl    $0x0b0a0908, 24(%rsp)
    movl    $0x0f0e0d0c, 28(%rsp)
    movl    $0x13121110, 32(%rsp)
    movl    $0x17161514, 36(%rsp)
    movl    $0x1b1a1918, 40(%rsp)
    movl    $0x1f1e1d1c, 44(%rsp)
    movl    72(%rsp), %eax
    movl    %eax, 48(%rsp)
    movl    $0x09000000, 52(%rsp)
    movl    $0x4a000000, 56(%rsp)
    movl    $0x00000000, 60(%rsp)

    /* Load x0..x11 into registers? Use 12 regs + 4 stack or load/store per QR group */
    movl    $10, %ebp               /* dr = 10 */

    /* Keep x0..x11 in %eax,%ebx,%ecx,%edx,%esi,%edi,%r8d..%r13d; x12..x15 in %r14d,%r15d + stack */
    movl    0(%rsp), %eax           /* x0 */
    movl    4(%rsp), %ebx           /* x1 */
    movl    8(%rsp), %ecx           /* x2 */
    movl    12(%rsp), %edx          /* x3 */
    movl    16(%rsp), %esi          /* x4 */
    movl    20(%rsp), %edi          /* x5 */
    movl    24(%rsp), %r8d          /* x6 */
    movl    28(%rsp), %r9d          /* x7 */
    movl    32(%rsp), %r10d         /* x8 */
    movl    36(%rsp), %r11d         /* x9 */
    movl    40(%rsp), %r12d         /* x10 */
    movl    44(%rsp), %r13d         /* x11 */

    .align 16
.Ldr_loop:
    /* Column QRs */
    movl    48(%rsp), %r14d         /* x12 */
    QR      %eax, %esi, %r10d, %r14d
    movl    %r14d, 48(%rsp)

    movl    52(%rsp), %r15d         /* x13 */
    QR      %ebx, %edi, %r11d, %r15d
    movl    %r15d, 52(%rsp)

    movl    56(%rsp), %r14d         /* x14 */
    QR      %ecx, %r8d, %r12d, %r14d
    movl    %r14d, 56(%rsp)

    movl    60(%rsp), %r15d         /* x15 */
    QR      %edx, %r9d, %r13d, %r15d
    /* keep x15 in %r15d for first diag QR! */

    /* Diagonal QRs */
    QR      %eax, %edi, %r12d, %r15d
    movl    %r15d, 60(%rsp)

    movl    48(%rsp), %r14d         /* x12 */
    QR      %ebx, %r8d, %r13d, %r14d
    movl    %r14d, 48(%rsp)

    movl    52(%rsp), %r15d         /* x13 */
    QR      %ecx, %r9d, %r10d, %r15d
    movl    %r15d, 52(%rsp)

    movl    56(%rsp), %r14d         /* x14 */
    QR      %edx, %esi, %r11d, %r14d
    movl    %r14d, 56(%rsp)

    subl    $1, %ebp
    jne     .Ldr_loop

    /* Fold: w_i = x_i + o_i */
    addl    $0x61707865, %eax
    addl    $0x3320646e, %ebx
    addl    $0x79622d32, %ecx
    addl    $0x6b206574, %edx
    xorl    %ebx, %eax
    xorl    %ecx, %eax
    xorl    %edx, %eax              /* row0 xor */

    addl    $0x03020100, %esi
    addl    $0x07060504, %edi
    addl    $0x0b0a0908, %r8d
    addl    $0x0f0e0d0c, %r9d
    xorl    %edi, %esi
    xorl    %r8d, %esi
    xorl    %r9d, %esi              /* row1 xor */
    addl    %esi, %eax

    addl    $0x13121110, %r10d
    addl    $0x17161514, %r11d
    addl    $0x1b1a1918, %r12d
    addl    $0x1f1e1d1c, %r13d
    xorl    %r11d, %r10d
    xorl    %r12d, %r10d
    xorl    %r13d, %r10d            /* row2 xor */
    addl    %r10d, %eax

    movl    48(%rsp), %r14d
    movl    72(%rsp), %ebx          /* ctr */
    addl    %ebx, %r14d
    movl    52(%rsp), %r15d
    addl    $0x09000000, %r15d
    xorl    %r15d, %r14d
    movl    56(%rsp), %ecx
    addl    $0x4a000000, %ecx
    xorl    %ecx, %r14d
    xorl    60(%rsp), %r14d         /* row3 xor */
    addl    %r14d, %eax             /* fold */

    movl    76(%rsp), %edx          /* h */
    imull   $16777619, %edx, %edx
    xorl    %eax, %edx
    movl    %edx, 76(%rsp)

    addl    $1, %ebx
    movl    %ebx, 72(%rsp)
    subq    $1, 64(%rsp)
    jne     .Lblock_loop

    movl    76(%rsp), %eax
    addq    $104, %rsp
    popq    %r15
    popq    %r14
    popq    %r13
    popq    %r12
    popq    %rbp
    popq    %rbx
    ret
    .size "$direct.run_blocks", .-"$direct.run_blocks"
