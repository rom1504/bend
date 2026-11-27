/* k1_a_hoist_branch.S — Hand-ASM probe Variant A for k1_bsearch_branchless ($direct.run_queries)
 * Laws tested:
 *   1. Array preheader hoisting (arr) + inner loop fusion (bsearch_step inlined into run_queries)
 *   2. Zero p113_rt_array_pair / p111_rt_ctor / spills
 *   3. Control: uses conditional branch (ja) for arr[cand] <= key to isolate branch-mispredict cost!
 * ABI: (ctx=%rdi, rem=%rsi, maxv=%rdx, arr=%rcx, seed=%r8, acc=%r9) -> (%rax=arr, %rdx=seed, %rcx=acc)
 */
    .text
    .globl "$direct.run_queries"
    .type "$direct.run_queries", @function
    .align 16
"$direct.run_queries":
    testq   %rsi, %rsi
    jne     .Lgo
    movq    %rcx, %rax
    movq    %r8, %rdx
    movq    %r9, %rcx
    ret
.Lgo:
    pushq   %rbx
    pushq   %r12
    pushq   %r13

    movq    (%rdi), %rax            /* heap */
    /* Decode arr -> %r10 */
    movq    %rcx, %r10
    shlq    $24, %r10
    shrq    $24, %r10
    testq   %rcx, %rcx
    jns     1f
    movq    (%rax,%r10,8), %r10
    shrq    $24, %r10
1:  leaq    (%rax,%r10,8), %r10     /* arr base */

    /* %rsi=rem, %edx=maxv, %r8d=seed, %r9d=acc, %rcx=arr handle (preserved) */
    .align 16
.Lq_loop:
    /* seed = prng(seed) */
    movl    %r8d, %eax
    shll    $13, %eax
    xorl    %eax, %r8d
    movl    %r8d, %eax
    shrl    $17, %eax
    xorl    %eax, %r8d
    movl    %r8d, %eax
    shll    $5, %eax
    xorl    %eax, %r8d

    movl    %r8d, %r11d
    andl    %edx, %r11d             /* key = seed & maxv */

    xorl    %eax, %eax              /* lo = 0 */
    movl    $8192, %ebx             /* step = 8192 */

    .align 16
.Lb_loop:
    leal    (%rax,%rbx), %r12d      /* cand = lo + step */
    cmpl    %r11d, (%r10,%r12,8)    /* arr[cand] <= key? */
    ja      .Lno_upd
    movl    %r12d, %eax
.Lno_upd:
    shrl    $1, %ebx
    jne     .Lb_loop

    movl    (%r10,%rax,8), %r13d    /* v = arr[lo] */
    xorl    %eax, %r13d
    imull   $16777619, %r9d, %r9d
    xorl    %r13d, %r9d

    subq    $1, %rsi
    jne     .Lq_loop

    movq    %rcx, %rax              /* return arr */
    movl    %r8d, %edx              /* return seed */
    movl    %r9d, %ecx              /* return acc */

    popq    %r13
    popq    %r12
    popq    %rbx
    ret
    .size "$direct.run_queries", .-"$direct.run_queries"
