/* v4_a_lookup_direct.S — Hand-ASM probe Variant A for v4_aatree_persist_map
 * Redirects $direct.aa_lookup only.
 * Laws tested:
 *   - Continuation-ADT deforestation (LookReq = LRoot | LCmp)
 *   - Direct iterative BST traversal over unmodified AATree (0 heap allocs, 0 spills)
 * ABI: (ctx=%rdi, fuel=%rsi, req=%rdx, k=%rcx) -> %rax (U32)
 * AATree: Leaf{} = 0x0100270000000000 (cid 0x27), Node{lvl,key,val,l,r} (cid 0x28, 5 fields)
 */
    .text
    .globl "$direct.aa_lookup"
    .type "$direct.aa_lookup", @function
    .align 16
"$direct.aa_lookup":
    testq   %rsi, %rsi
    je      .Lret_zero

    movq    (%rdi), %r8             /* heap base */

    /* Unpack root t from req = LRoot{t} */
    movq    %rdx, %rax
    shrq    $56, %rax
    andl    $0x7f, %eax
    cmpl    $1, %eax
    je      .Lroot_inline
    movq    %rdx, %r9
    shlq    $24, %r9
    shrq    $24, %r9
    testq   %rdx, %rdx
    jns     1f
    movq    (%r8,%r9,8), %r9
    shrq    $24, %r9
1:  movq    (%r8,%r9,8), %rdx       /* t = LRoot.t */
    jmp     .Lloop
.Lroot_inline:
    shlq    $24, %rdx
    shrq    $24, %rdx

    .align 16
.Lloop:
    /* Check if t is Leaf{} (cid == 0x27) */
    movq    %rdx, %rax
    shrq    $40, %rax
    andl    $0xffff, %eax
    cmpl    $0x27, %eax
    je      .Lret_zero

    /* Decode Node ptr -> %r9 */
    movq    %rdx, %r9
    shlq    $24, %r9
    shrq    $24, %r9
    testq   %rdx, %rdx
    jns     2f
    movq    (%r8,%r9,8), %r9
    shrq    $24, %r9
2:  leaq    (%r8,%r9,8), %r9

    /* Compare k (%ecx) vs tk (8(%r9)) */
    movl    8(%r9), %eax
    cmpl    %eax, %ecx
    jb      .Lgo_left
    ja      .Lgo_right

    /* Found: return tv */
    movl    16(%r9), %eax
    ret

.Lgo_left:
    movq    24(%r9), %rdx
    subq    $2, %rsi                /* 1 step LRoot + 1 step LCmp */
    ja      .Lloop
    xorl    %eax, %eax
    ret

.Lgo_right:
    movq    32(%r9), %rdx
    subq    $2, %rsi
    ja      .Lloop

.Lret_zero:
    xorl    %eax, %eax
    ret
    .size "$direct.aa_lookup", .-"$direct.aa_lookup"
