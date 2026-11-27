/* t1_a_unbox_dual_hoist.S — Hand-ASM probe Variant A for t1_rle_lz_hash ($direct.scan_lz)
 * Laws tested:
 *   1. Single-constructor record unboxing (LSt{src, ht, h})
 *   2. Multi-array hoist (BOTH src and ht hoisted across continuation chain)
 *   3. Zero per-step p113_rt_array_pair / p111_rt_ctor / spills
 * ABI: (ctx=%rdi, rem=%rsi, i=%rdx, salt=%rcx, st=%r8) -> %rax (returns st)
 */
    .text
    .globl "$direct.scan_lz"
    .type "$direct.scan_lz", @function
    .align 16
"$direct.scan_lz":
    testq   %rsi, %rsi
    jne     .Lgo
    movq    %r8, %rax
    ret
.Lgo:
    pushq   %rbx
    pushq   %rbp
    pushq   %r12
    pushq   %r13
    pushq   %r14
    pushq   %r15

    movq    (%rdi), %rdi            /* heap */
    /* Decode st = LSt{src, ht, h} -> %r9 */
    movq    %r8, %rax
    shlq    $24, %rax
    shrq    $24, %rax
    testq   %r8, %r8
    jns     1f
    movq    (%rdi,%rax,8), %rax
    shrq    $24, %rax
1:  leaq    (%rdi,%rax,8), %r9

    movq    0(%r9), %rax            /* src handle */
    movq    8(%r9), %rbx            /* ht handle */
    movl    16(%r9), %r10d          /* h */

    /* Decode src -> %r11 */
    movq    %rax, %r11
    shlq    $24, %r11
    shrq    $24, %r11
    testq   %rax, %rax
    jns     2f
    movq    (%rdi,%r11,8), %r11
    shrq    $24, %r11
2:  leaq    (%rdi,%r11,8), %r11     /* src base */

    /* Decode ht -> %r12 */
    movq    %rbx, %r12
    shlq    $24, %r12
    shrq    $24, %r12
    testq   %rbx, %rbx
    jns     3f
    movq    (%rdi,%r12,8), %r12
    shrq    $24, %r12
3:  leaq    (%rdi,%r12,8), %r12     /* ht base */

    /* %edx = i, %rsi = rem, %ecx = salt, %r10d = h */
    leaq    (%r11,%rdx,8), %r13     /* &src[i] */

    .align 16
.Lloop:
    movl    0(%r13), %eax           /* s0 */
    movl    8(%r13), %ebx           /* s1 */
    movl    16(%r13), %ebp          /* s2 */

    /* hv = (((s0*2654435761) ^ (s1*2246822519) ^ (s2*3266489917)) >> 20) & 4095 */
    imull   $2654435761, %eax, %r14d
    imull   $2246822519, %ebx, %r15d
    xorl    %r15d, %r14d
    imull   $3266489917, %ebp, %ebp
    xorl    %ebp, %r14d
    shrl    $20, %r14d
    andl    $4095, %r14d

    /* prev = ht[hv]; ht[hv] = i */
    movl    (%r12,%r14,8), %ebp     /* prev */
    movl    %edx, (%r12,%r14,8)     /* ht[hv] = i */

    /* sp = src[prev] */
    cmpl    (%r11,%rbp,8), %eax
    jne     .Lmiss

    /* Match: dist = i - prev; h = ((h ^ (dist + 1)) * 16777619) ^ (s1 + salt) */
    movl    %edx, %r14d
    subl    %ebp, %r14d
    addl    $1, %r14d
    xorl    %r14d, %r10d
    imull   $16777619, %r10d, %r10d
    addl    %ecx, %ebx
    xorl    %ebx, %r10d
    jmp     .Lnext

    .align 16
.Lmiss:
    /* Miss: h = (h ^ (s0 + 17)) * 16777619 */
    addl    $17, %eax
    xorl    %eax, %r10d
    imull   $16777619, %r10d, %r10d

.Lnext:
    addl    $1, %edx
    addq    $8, %r13
    subq    $1, %rsi
    jne     .Lloop

    movl    %r10d, 16(%r9)
    movq    %r8, %rax

    popq    %r15
    popq    %r14
    popq    %r13
    popq    %r12
    popq    %rbp
    popq    %rbx
    ret
    .size "$direct.scan_lz", .-"$direct.scan_lz"
