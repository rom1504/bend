/* t4_a_query_direct_tree.S — Hand-ASM probe Variant A for t4_interval_tree_query ($direct.query_overlap)
 * Laws tested:
 *   1. Continuation-ADT deforestation (eliminate QReq = QRoot/QCheck/QRight heap allocations!)
 *   2. Direct recursive traversal over unmodified Bend ITree heap nodes (0 ABI change)
 *   3. Zero p111_rt_ctor / p111_rt_take in query_overlap
 * ABI: (ctx=%rdi, fuel=%rsi, req=%rdx, qlo=%rcx, qhi=%r8, acc=%r9) -> %rax (returns U32 acc)
 */
    .text
    .globl "$direct.query_overlap"
    .type "$direct.query_overlap", @function
    .align 16
"$direct.query_overlap":
    testq   %rsi, %rsi
    jne     .Lgo
    movl    %r9d, %eax
    ret
.Lgo:
    pushq   %rbx
    pushq   %r12
    pushq   %r13
    pushq   %r14

    movq    (%rdi), %r12            /* heap base */
    movl    %ecx, %r13d             /* qlo */
    movl    %r8d, %r14d             /* qhi */
    movl    %r9d, %eax              /* acc */

    /* Unpack t from req = QRoot{t} (1-field ctor: tag=2 boxed or tag=1 inline) */
    movq    %rdx, %rcx
    shrq    $56, %rcx
    andl    $0x7f, %ecx
    cmpl    $1, %ecx
    je      .Lqroot_inline
    /* Boxed 1-field QRoot */
    movq    %rdx, %rsi
    shlq    $24, %rsi
    shrq    $24, %rsi
    testq   %rdx, %rdx
    jns     1f
    movq    (%r12,%rsi,8), %rsi
    shrq    $24, %rsi
1:  movq    (%r12,%rsi,8), %rdi     /* t */
    jmp     .Lstart
.Lqroot_inline:
    movq    %rdx, %rdi
    shlq    $24, %rdi
    shrq    $24, %rdi

.Lstart:
    callq   .Lq_rec

    popq    %r14
    popq    %r13
    popq    %r12
    popq    %rbx
    ret

    /* Internal lean recursive helper:
     *   %rdi = t (ITree handle), %eax = acc (in/out)
     *   %r12 = heap, %r13d = qlo, %r14d = qhi (invariant)
     */
    .align 16
.Lq_rec:
    /* Empty{} has cid == 0x27 in bits [55:40] */
    movq    %rdi, %rcx
    shrq    $40, %rcx
    andl    $0xffff, %ecx
    cmpl    $0x27, %ecx
    je      .Lq_ret

    /* Decode INode{lo, hi, max_hi, l, r} -> %rdx */
    movq    %rdi, %rdx
    shlq    $24, %rdx
    shrq    $24, %rdx
    testq   %rdi, %rdi
    jns     2f
    movq    (%r12,%rdx,8), %rdx
    shrq    $24, %rdx
2:  leaq    (%r12,%rdx,8), %rdx

    /* Prune: if max_hi < qlo -> return acc */
    cmpl    %r13d, 16(%rdx)
    jb      .Lq_ret

    /* Save node ptr across left recursion */
    pushq   %rbx
    movq    %rdx, %rbx

    /* Recurse left */
    movq    24(%rbx), %rdi
    callq   .Lq_rec

    /* Check nlo <= qhi */
    movl    0(%rbx), %ecx           /* nlo */
    cmpl    %r14d, %ecx
    ja      .Lq_pop_ret

    /* Check nhi >= qlo -> hit_update */
    movl    8(%rbx), %edx           /* nhi */
    cmpl    %r13d, %edx
    jb      .Lq_right
    imull   $16777619, %eax, %eax
    shll    $16, %edx
    addl    %ecx, %edx
    xorl    %edx, %eax

.Lq_right:
    /* Tail-recurse right! */
    movq    32(%rbx), %rdi
    popq    %rbx
    jmp     .Lq_rec

.Lq_pop_ret:
    popq    %rbx
.Lq_ret:
    ret
    .size "$direct.query_overlap", .-"$direct.query_overlap"
