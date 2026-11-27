/* v3_a_inline_lut_hoist.S — Hand-ASM probe Variant A for v3_base64_codec ($direct.scan_groups)
 * Laws tested:
 *   1. Complete 64-entry .rodata LUT (fixes Proven-20's 43-entry cutoff!)
 *   2. Leaf .rodata LUT inlining into hot loop (eliminates 4x call $direct.b64_lut per group)
 *   3. Tuple/record unboxing ((buf, h)) + Linear-Array Hoist for buf
 * ABI: (ctx=%rdi, rem=%rsi, idx=%rdx, salt=%rcx, st=%r8) -> %rax (returns st)
 */
    .section .rodata
    .align 64
.Lb64_lut:
    .byte 65,66,67,68,69,70,71,72,73,74,75,76,77,78,79,80
    .byte 81,82,83,84,85,86,87,88,89,90,97,98,99,100,101,102
    .byte 103,104,105,106,107,108,109,110,111,112,113,114,115,116,117,118
    .byte 119,120,121,122,48,49,50,51,52,53,54,55,56,57,43,47

    .text
    .globl "$direct.scan_groups"
    .type "$direct.scan_groups", @function
    .align 16
"$direct.scan_groups":
    testq   %rsi, %rsi
    jne     .Lgo
    movq    %r8, %rax
    ret
.Lgo:
    pushq   %rbx
    movq    (%rdi), %rdi            /* heap */

    /* Decode st = (buf, h) -> %r9 */
    movq    %r8, %rax
    shlq    $24, %rax
    shrq    $24, %rax
    testq   %r8, %r8
    jns     1f
    movq    (%rdi,%rax,8), %rax
    shrq    $24, %rax
1:  leaq    (%rdi,%rax,8), %r9      /* &st.buf */

    movq    0(%r9), %rax            /* buf handle */
    movl    8(%r9), %r10d           /* h */

    /* Decode buf -> %rdi */
    movq    %rax, %r11
    shlq    $24, %r11
    shrq    $24, %r11
    testq   %rax, %rax
    jns     2f
    movq    (%rdi,%r11,8), %r11
    shrq    $24, %r11
2:  leaq    (%rdi,%r11,8), %rdi
    leaq    (%rdi,%rdx,8), %rdi     /* &buf[idx] */

    leaq    .Lb64_lut(%rip), %r11   /* B64_LUT */

    .align 16
.Lloop:
    movl    0(%rdi), %eax           /* raw0 */
    xorl    %ecx, %eax
    andl    $255, %eax
    shll    $16, %eax
    movl    8(%rdi), %edx           /* b1 */
    shll    $8, %edx
    orl     %edx, %eax
    orl     16(%rdi), %eax          /* %eax = w = (b0<<16)|(b1<<8)|b2 */

    /* c0 = B64_LUT[(w >> 18) & 63] */
    movl    %eax, %edx
    shrl    $18, %edx
    andl    $63, %edx
    movzbl  (%r11,%rdx,1), %edx
    xorl    %edx, %r10d
    imull   $16777619, %r10d, %r10d

    /* c1 = B64_LUT[(w >> 12) & 63] */
    movl    %eax, %edx
    shrl    $12, %edx
    andl    $63, %edx
    movzbl  (%r11,%rdx,1), %edx
    xorl    %edx, %r10d
    imull   $16777619, %r10d, %r10d

    /* c2 = B64_LUT[(w >> 6) & 63] */
    movl    %eax, %edx
    shrl    $6, %edx
    andl    $63, %edx
    movzbl  (%r11,%rdx,1), %edx
    xorl    %edx, %r10d
    imull   $16777619, %r10d, %r10d

    /* c3 = B64_LUT[w & 63] */
    andl    $63, %eax
    movzbl  (%r11,%rax,1), %eax
    xorl    %eax, %r10d
    imull   $16777619, %r10d, %r10d

    addq    $24, %rdi               /* idx += 3 (3 * 8 bytes) */
    subq    $1, %rsi
    jne     .Lloop

    movl    %r10d, 8(%r9)           /* update h in tuple */
    movq    %r8, %rax
    popq    %rbx
    ret
    .size "$direct.scan_groups", .-"$direct.scan_groups"
