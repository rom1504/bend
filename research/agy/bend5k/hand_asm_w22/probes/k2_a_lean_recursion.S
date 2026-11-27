/* k2_a_lean_recursion.S — Hand-ASM probe Variant A for k2_tree_nontail_fold ($direct.fold_tree)
 * Laws tested:
 *   1. Lean non-tail recursive calling convention (tiny 24-byte stack frame vs 208-byte Bend5k frame!)
 *   2. Zero refcount/borrow traffic (p111_rt_keep / p111_rt_sink / p111_rt_take = 0!)
 *   3. Fast inline BLeaf (cid=0x27) leaf check without frame setup (leaf fast-path!)
 * ABI: (ctx=%rdi, t=%rsi, salt=%rdx) -> %rax (returns U32)
 */
    .text
    .globl "$direct.fold_tree"
    .type "$direct.fold_tree", @function
    .align 16
"$direct.fold_tree":
    pushq   %r12
    movq    (%rdi), %r12            /* heap base (invariant across entire recursion!) */
    movq    %rsi, %rdi              /* t */
    movl    %edx, %esi              /* salt */
    callq   .Lfold_rec
    popq    %r12
    ret

    /* Lean internal recursive helper:
     *   %rdi = t (BTree handle), %esi = salt (U32)
     *   %r12 = heap (invariant)
     *   returns U32 in %eax
     */
    .align 16
.Lfold_rec:
    /* Fast leaf check: BLeaf{v} has cid == 0x27 (tag=1 inline, low 32 bits = v) */
    movq    %rdi, %rax
    shrq    $40, %rax
    andl    $0xffff, %eax
    cmpl    $0x27, %eax
    jne     .Lnode

    /* BLeaf{v}: ((v ^ salt) * 16777619) ^ v — ZERO stack frame! */
    movl    %edi, %eax
    xorl    %esi, %eax
    imull   $16777619, %eax, %eax
    xorl    %edi, %eax
    ret

    .align 16
.Lnode:
    /* Decode BNode{w, tag, l, r} -> %rcx */
    movq    %rdi, %rcx
    shlq    $24, %rcx
    shrq    $24, %rcx
    testq   %rdi, %rdi
    jns     1f
    movq    (%r12,%rcx,8), %rcx
    shrq    $24, %rcx
1:  leaq    (%r12,%rcx,8), %rcx

    /* Save only 3 regs: node ptr (%rbx), salt (%ebp), fl (%r13d) */
    pushq   %rbx
    pushq   %rbp
    pushq   %r13
    movq    %rcx, %rbx              /* node ptr */
    movl    %esi, %ebp              /* salt */

    /* fl = fold_tree(l, salt + tag) */
    movq    16(%rbx), %rdi          /* l */
    addl    8(%rbx), %esi           /* salt + tag */
    callq   .Lfold_rec
    movl    %eax, %r13d             /* fl */

    /* fr = fold_tree(r, salt ^ w) */
    movq    24(%rbx), %rdi          /* r */
    movl    0(%rbx), %esi           /* w */
    xorl    %ebp, %esi              /* salt ^ w */
    callq   .Lfold_rec              /* fr in %eax */

    /* ((fl * 16777619) ^ fr) + w */
    imull   $16777619, %r13d, %r13d
    xorl    %r13d, %eax
    addl    0(%rbx), %eax

    popq    %r13
    popq    %rbp
    popq    %rbx
    ret
    .size "$direct.fold_tree", .-"$direct.fold_tree"
