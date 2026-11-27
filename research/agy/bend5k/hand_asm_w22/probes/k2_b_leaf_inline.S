/* k2_b_leaf_inline.S — Hand-ASM probe Variant B for k2_tree_nontail_fold ($direct.fold_tree)
 * Laws tested:
 *   1. Variant A (shrink-wrapped leaf fast-path + minimal 24B stack frame + invariant heap reg)
 *   2. Child-leaf specialization (inline BLeaf evaluation at call site -> eliminates 50% of all recursive calls!)
 * ABI: (ctx=%rdi, t=%rsi, salt=%rdx) -> %rax (returns U32)
 */
    .text
    .globl "$direct.fold_tree"
    .type "$direct.fold_tree", @function
    .align 16
"$direct.fold_tree":
    pushq   %r12
    movq    (%rdi), %r12            /* heap base */
    movq    %rsi, %rdi              /* t */
    movl    %edx, %esi              /* salt */
    callq   .Lfold_rec
    popq    %r12
    ret

    .align 16
.Lfold_rec:
    /* Root/node leaf check */
    movq    %rdi, %rax
    shrq    $40, %rax
    andl    $0xffff, %eax
    cmpl    $0x27, %eax
    jne     .Lnode

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

    /* Check if left child is a BLeaf (avoids call + push/pop when at depth 1!) */
    movq    16(%rcx), %rdi          /* l */
    movq    %rdi, %rax
    shrq    $40, %rax
    andl    $0xffff, %eax
    cmpl    $0x27, %eax
    jne     .Lnode_general

    /* Fast path: l is BLeaf! Compute fl inline */
    movl    %esi, %edx
    addl    8(%rcx), %edx           /* salt + tag */
    movl    %edi, %eax
    xorl    %edx, %eax
    imull   $16777619, %eax, %eax
    xorl    %edi, %eax              /* fl in %eax */

    /* Check if r is also BLeaf! (Always true for balanced depth-10 tree!) */
    movq    24(%rcx), %rdi          /* r */
    movq    %rdi, %r8
    shrq    $40, %r8
    andl    $0xffff, %r8d
    cmpl    $0x27, %r8d
    jne     .Lright_rec

    /* Both l and r are BLeaf: ZERO calls, ZERO stack frame! */
    movl    0(%rcx), %edx           /* w */
    xorl    %edx, %esi              /* salt ^ w */
    movl    %edi, %r8d
    xorl    %esi, %r8d
    imull   $16777619, %r8d, %r8d
    xorl    %edi, %r8d              /* fr in %r8d */

    imull   $16777619, %eax, %eax
    xorl    %r8d, %eax
    addl    %edx, %eax
    ret

.Lright_rec:
    pushq   %rbx
    pushq   %r13
    movl    0(%rcx), %ebx           /* w */
    movl    %eax, %r13d             /* fl */
    xorl    %ebx, %esi              /* salt ^ w */
    callq   .Lfold_rec              /* fr in %eax */
    imull   $16777619, %r13d, %r13d
    xorl    %r13d, %eax
    addl    %ebx, %eax
    popq    %r13
    popq    %rbx
    ret

    .align 16
.Lnode_general:
    pushq   %rbx
    pushq   %rbp
    pushq   %r13
    movq    %rcx, %rbx
    movl    %esi, %ebp

    /* l already in %rdi */
    addl    8(%rbx), %esi
    callq   .Lfold_rec
    movl    %eax, %r13d             /* fl */

    movq    24(%rbx), %rdi
    movl    0(%rbx), %esi
    xorl    %ebp, %esi
    callq   .Lfold_rec              /* fr in %eax */

    imull   $16777619, %r13d, %r13d
    xorl    %r13d, %eax
    addl    0(%rbx), %eax

    popq    %r13
    popq    %rbp
    popq    %rbx
    ret
    .size "$direct.fold_tree", .-"$direct.fold_tree"
