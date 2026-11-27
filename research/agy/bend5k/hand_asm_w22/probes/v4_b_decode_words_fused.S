/* v4_b_decode_words_fused.S — Hand-ASM probe Variant B for v4_huffman_trie_codec ($direct.decode_words)
 * Laws tested:
 *   1. Variant A (zero-alloc TNode reuse + DSt unboxing)
 *   2. Inner loop inlining/fusion (decode_bits fused into decode_words -> 0 DSt allocs per word!)
 * ABI: (ctx=%rdi, rem=%rsi, seed=%rdx, root=%rcx, cur=%r8, plen=%r9, h=16(%rbp), total=24(%rbp))
 *      -> %rax (RSt cid=0x2a, arity=3: {h, total, seed})
 */
    .text
    .globl "$direct.decode_words"
    .type "$direct.decode_words", @function
    .align 16
"$direct.decode_words":
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
    /* %rsi=rem_words, %edx=seed, %rcx=root, %r8=cur, %r9d=plen */

    testq   %rsi, %rsi
    je      .Ldone

    .align 16
.Lword_loop:
    /* seed = prng(seed) */
    movl    %edx, %eax
    shll    $13, %eax
    xorl    %eax, %edx
    movl    %edx, %eax
    shrl    $17, %eax
    xorl    %eax, %edx
    movl    %edx, %eax
    shll    $5, %eax
    xorl    %eax, %edx

    movl    %edx, %ebx              /* bits = seed */
    movl    $32, %r14d              /* 32 bits */

    .align 16
.Lbit_loop:
    /* Decode TNode cur -> %r11 (cur is always TNode in balanced depth-6 trie!) */
    movq    %r8, %r11
    shlq    $24, %r11
    shrq    $24, %r11
    testq   %r8, %r8
    jns     1f
    movq    (%r10,%r11,8), %r11
    shrq    $24, %r11
1:  leaq    (%r10,%r11,8), %r11

    movl    %ebx, %eax
    andl    $1, %eax
    shrl    $1, %ebx
    movq    (%r11,%rax,8), %r8      /* next = bit ? r : l */
    addl    $1, %r9d                /* plen++ */

    /* Check if next is TLeaf (cid == 0x27) */
    movq    %r8, %rax
    shrq    $40, %rax
    andl    $0xffff, %eax
    cmpl    $0x27, %eax
    jne     .Lnext_bit

    /* TLeaf{sym} */
    imull   $16777619, %r12d, %r12d
    xorl    %r8d, %r12d
    movl    %r9d, %eax
    shll    $8, %eax
    xorl    %eax, %r12d
    addl    $1, %r13d
    movq    %rcx, %r8
    xorl    %r9d, %r9d

.Lnext_bit:
    subl    $1, %r14d
    jne     .Lbit_loop

    subq    $1, %rsi
    jne     .Lword_loop

.Ldone:
    /* Unboxed multi-return RSt{(h * 2654435761) ^ plen, total, seed} in (%rax, %rdx, %rcx) */
    imull   $2654435761, %r12d, %eax
    xorl    %r9d, %eax
    movl    %edx, %ecx              /* seed */
    movl    %r13d, %edx             /* total */

    addq    $56, %rsp
    popq    %r15
    popq    %r14
    popq    %r13
    popq    %r12
    popq    %rbx
    popq    %rbp
    ret
    .size "$direct.decode_words", .-"$direct.decode_words"
