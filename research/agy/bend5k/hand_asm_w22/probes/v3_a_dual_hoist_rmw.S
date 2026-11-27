/* v3_a_dual_hoist_rmw.S — Hand-ASM probe Variant A for v3_bloom_dedup_ring ($direct.step_keys)
 * Laws tested:
 *   1. Dual-array preheader hoisting (bloom + ring) across 5-step continuation chain
 *   2. Direct in-place bit-test + bit-set RMW (0 p113_rt_array_pair, 0 p111_rt_op)
 *   3. Single DSt{...} construction at loop exit (0 per-key p111_rt_ctor, 0 loop spills)
 * ABI: (ctx=%rdi, rem=%rsi, salt=%rdx, bloom=%rcx, ring=%r8, head=%r9,
 *       hits=8(%rsp), uniques=16(%rsp), acc=24(%rsp), seed=32(%rsp)) -> %rax (DSt cid=0x27, arity=7)
 */
    .text
    .globl "$direct.step_keys"
    .type "$direct.step_keys", @function
    .align 16
"$direct.step_keys":
    pushq   %rbp
    movq    %rsp, %rbp
    pushq   %rbx
    pushq   %r12
    pushq   %r13
    pushq   %r14
    pushq   %r15
    subq    $104, %rsp

    /* Save ctx and handles for exit DSt construction */
    movq    %rdi, -56(%rbp)         /* ctx */
    movq    %rcx, -64(%rbp)         /* bloom handle */
    movq    %r8,  -72(%rbp)         /* ring handle */
    movl    %edx, -76(%rbp)         /* salt */

    movq    (%rdi), %rax            /* heap */

    /* Decode bloom -> %r10 */
    movq    %rcx, %r10
    shlq    $24, %r10
    shrq    $24, %r10
    testq   %rcx, %rcx
    jns     1f
    movq    (%rax,%r10,8), %r10
    shrq    $24, %r10
1:  leaq    (%rax,%r10,8), %r10     /* bloom base */

    /* Decode ring -> %r11 */
    movq    %r8, %r11
    shlq    $24, %r11
    shrq    $24, %r11
    testq   %r8, %r8
    jns     2f
    movq    (%rax,%r11,8), %r11
    shrq    $24, %r11
2:  leaq    (%rax,%r11,8), %r11     /* ring base */

    /* Load loop-carried scalar state into registers:
     *   %r9d  = head
     *   %r12d = hits
     *   %r13d = uniques
     *   %r14d = acc
     *   %r15d = seed
     *   %rsi  = rem
     */
    movl    16(%rbp), %r12d         /* hits */
    movl    24(%rbp), %r13d         /* uniques */
    movl    32(%rbp), %r14d         /* acc */
    movl    40(%rbp), %r15d         /* seed */

    testq   %rsi, %rsi
    je      .Ldone

    .align 16
.Lloop:
    /* ns = prng(seed) */
    movl    %r15d, %eax
    shll    $13, %eax
    xorl    %eax, %r15d
    movl    %r15d, %eax
    shrl    $17, %eax
    xorl    %eax, %r15d
    movl    %r15d, %eax
    shll    $5, %eax
    xorl    %eax, %r15d

    /* k = (ns & 16383) ^ salt */
    movl    %r15d, %ebx
    andl    $16383, %ebx
    xorl    -76(%rbp), %ebx         /* %ebx = k */

    /* h1 = (k * 2654435761) ^ (k >> 16) */
    imull   $2654435761, %ebx, %eax
    movl    %ebx, %edx
    shrl    $16, %edx
    xorl    %edx, %eax              /* %eax = h1 */

    /* h2 = ((k * 2246822519) ^ (k >> 13)) | 1 */
    imull   $2246822519, %ebx, %edx
    movl    %ebx, %ecx
    shrl    $13, %ecx
    xorl    %ecx, %edx
    orl     $1, %edx                /* %edx = h2 */

    /* Probe 0: p0 = h1 & 32767 */
    movl    %eax, %ecx
    andl    $32767, %ecx
    movl    %ecx, %edi
    shrl    $5, %edi                /* w0 */
    andl    $31, %ecx
    movl    $1, %r8d
    shll    %cl, %r8d               /* m0 */
    movl    (%r10,%rdi,8), %ecx     /* old0 */
    movl    %ecx, -80(%rbp)
    orl     %r8d, %ecx
    movl    %ecx, (%r10,%rdi,8)
    testl   %r8d, -80(%rbp)
    setne   %cl
    movb    %cl, -81(%rbp)          /* hit0 */

    /* Probe 1: p1 = (h1 + h2) & 32767 */
    addl    %edx, %eax              /* h1 + h2 */
    movl    %eax, %ecx
    andl    $32767, %ecx
    movl    %ecx, %edi
    shrl    $5, %edi                /* w1 */
    andl    $31, %ecx
    movl    $1, %r8d
    shll    %cl, %r8d               /* m1 */
    movl    (%r10,%rdi,8), %ecx     /* old1 */
    movl    %ecx, -80(%rbp)
    orl     %r8d, %ecx
    movl    %ecx, (%r10,%rdi,8)
    testl   %r8d, -80(%rbp)
    setne   %cl
    andb    %cl, -81(%rbp)

    /* Probe 2: p2 = (h1 + 2*h2) & 32767 */
    addl    %edx, %eax              /* h1 + 2*h2 */
    andl    $32767, %eax
    movl    %eax, %edi
    shrl    $5, %edi                /* w2 */
    movl    %eax, %ecx
    andl    $31, %ecx
    movl    $1, %r8d
    shll    %cl, %r8d               /* m2 */
    movl    (%r10,%rdi,8), %ecx     /* old2 */
    movl    %ecx, %edx
    orl     %r8d, %edx
    movl    %edx, (%r10,%rdi,8)
    testl   %r8d, %ecx
    setne   %cl
    testb   %cl, -81(%rbp)
    je      .Lmiss

    /* Hit */
    addl    $1, %r12d               /* hits++ */
    imull   $16777619, %r14d, %r14d
    xorl    %ebx, %r14d
    jmp     .Lnext

    .align 16
.Lmiss:
    movl    (%r11,%r9,8), %eax      /* ev = ring[head] */
    movl    %ebx, (%r11,%r9,8)      /* ring[head] = k */
    addl    $1, %r9d
    andl    $1023, %r9d             /* head = (head + 1) & 1023 */
    addl    $1, %r13d               /* uniques++ */
    imull   $2654435761, %r14d, %r14d
    xorl    %eax, %r14d
    xorl    %ebx, %r14d

.Lnext:
    subq    $1, %rsi
    jne     .Lloop

.Ldone:
    /* Construct DSt{bloom, ring, head, hits, uniques, acc, seed} via p111_rt_ctor */
    movq    -64(%rbp), %rax
    movq    %rax, 0(%rsp)
    movq    -72(%rbp), %rax
    movq    %rax, 8(%rsp)
    movl    %r9d, %eax
    movq    %rax, 16(%rsp)
    movl    %r12d, %eax
    movq    %rax, 24(%rsp)
    movl    %r13d, %eax
    movq    %rax, 32(%rsp)
    movl    %r14d, %eax
    movq    %rax, 40(%rsp)
    movl    %r15d, %eax
    movq    %rax, 48(%rsp)

    movq    -56(%rbp), %rdi         /* ctx */
    movl    $0x27, %esi             /* DSt cid */
    movq    %rsp, %rdx              /* fields ptr */
    movl    $7, %ecx                /* arity */
    callq   p111_rt_ctor

    addq    $104, %rsp
    popq    %r15
    popq    %r14
    popq    %r13
    popq    %r12
    popq    %rbx
    popq    %rbp
    ret
    .size "$direct.step_keys", .-"$direct.step_keys"
