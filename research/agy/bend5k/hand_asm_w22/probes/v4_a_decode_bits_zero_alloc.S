/* v4_a_decode_bits_zero_alloc.S — Hand-ASM probe Variant A for v4_huffman_trie_codec ($direct.decode_bits)
 * Laws tested:
 *   1. Match-as / zero-allocation identity reconstruction (eliminate TNode{l,r} re-alloc in check_leaf!)
 *   2. Single-constructor DSt{cur, plen, h, total} unboxing across the 32-bit loop
 *   3. Unboxed inline TLeaf tag check (0x27) + direct TNode child load
 * ABI: (ctx=%rdi, rem=%rsi, bits=%rdx, root=%rcx, cur=%r8, plen=%r9, h=16(%rbp), total=24(%rbp))
 *      -> %rax (DSt cid=0x29, arity=4)
 */
    .text
    .globl "$direct.decode_bits"
    .type "$direct.decode_bits", @function
    .align 16
"$direct.decode_bits":
    pushq   %rbp
    movq    %rsp, %rbp
    pushq   %rbx
    pushq   %r12
    pushq   %r13
    pushq   %r14
    pushq   %r15
    subq    $56, %rsp

    movq    %rdi, -48(%rbp)         /* save ctx */
    movq    (%rdi), %r10            /* heap */
    movl    16(%rbp), %r12d         /* h */
    movl    24(%rbp), %r13d         /* total */
    /* %rsi=rem, %edx=bits, %rcx=root, %r8=cur, %r9d=plen */

    testq   %rsi, %rsi
    je      .Ldone

    .align 16
.Lbit_loop:
    /* Check if cur is TLeaf (cid == 0x27) */
    movq    %r8, %rax
    shrq    $40, %rax
    andl    $0xffff, %eax
    cmpl    $0x27, %eax
    je      .Lcur_is_leaf

    /* Decode TNode cur -> %r11 */
    movq    %r8, %r11
    shlq    $24, %r11
    shrq    $24, %r11
    testq   %r8, %r8
    jns     1f
    movq    (%r10,%r11,8), %r11
    shrq    $24, %r11
1:  leaq    (%r10,%r11,8), %r11

    /* bit = bits & 1; bits >>= 1; next = bit ? r : l */
    movl    %edx, %eax
    andl    $1, %eax
    shrl    $1, %edx
    movq    (%r11,%rax,8), %r8      /* cur = next (0 alloc!) */
    addl    $1, %r9d                /* plen++ */

    /* Check if next is TLeaf (cid == 0x27) */
    movq    %r8, %rax
    shrq    $40, %rax
    andl    $0xffff, %eax
    cmpl    $0x27, %eax
    jne     .Lnext_bit

    /* TLeaf{sym}: h = ((h * 16777619) ^ sym) ^ (plen << 8); total++; cur = root; plen = 0 */
    imull   $16777619, %r12d, %r12d
    xorl    %r8d, %r12d             /* low 32 bits of TLeaf handle == sym! */
    movl    %r9d, %eax
    shll    $8, %eax
    xorl    %eax, %r12d
    addl    $1, %r13d
    movq    %rcx, %r8
    xorl    %r9d, %r9d
    jmp     .Lnext_bit

.Lcur_is_leaf:
    shrl    $1, %edx
    movq    %rcx, %r8
    xorl    %r9d, %r9d

.Lnext_bit:
    subq    $1, %rsi
    jne     .Lbit_loop

.Ldone:
    movq    %r8, 0(%rsp)
    movl    %r9d, %eax
    movq    %rax, 8(%rsp)
    movl    %r12d, %eax
    movq    %rax, 16(%rsp)
    movl    %r13d, %eax
    movq    %rax, 24(%rsp)

    movq    -48(%rbp), %rdi
    movl    $0x29, %esi             /* DSt cid */
    movq    %rsp, %rdx
    movl    $4, %ecx
    callq   p111_rt_ctor

    addq    $56, %rsp
    popq    %r15
    popq    %r14
    popq    %r13
    popq    %r12
    popq    %rbx
    popq    %rbp
    ret
    .size "$direct.decode_bits", .-"$direct.decode_bits"
