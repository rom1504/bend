/* v4_b_insert_and_lookup_direct.S — Hand-ASM probe Variant B for v4_aatree_persist_map
 * Redirects BOTH $direct.aa_insert AND $direct.aa_lookup.
 * Laws tested:
 *   1. Continuation-ADT deforestation (InsReq + LookReq)
 *   2. Zero-alloc identity reconstruction (match-as) in aa_skew & aa_split
 *   3. FBIP unique-node reuse on AATree insert + in-place skew/split rotations
 * Zero ABI change: allocates genuine Bend Node{lvl,key,val,l,r} (cid=0x28) via p111_rt_ctor at Leaf{} only.
 * ABI:
 *   $direct.aa_insert(ctx=%rdi, fuel=%rsi, req=%rdx, k=%rcx, v=%r8) -> %rax (AATree)
 *   $direct.aa_lookup(ctx=%rdi, fuel=%rsi, req=%rdx, k=%rcx) -> %rax (U32)
 */
    .text
    .globl "$direct.aa_insert"
    .type "$direct.aa_insert", @function
    .align 16
"$direct.aa_insert":
    testq   %rsi, %rsi
    jne     .Li_go
    movabsq $0x0100270000000000, %rax
    ret
.Li_go:
    pushq   %rbx
    pushq   %rbp
    pushq   %r12
    pushq   %r13
    pushq   %r14
    pushq   %r15

    movq    %rdi, %r12              /* ctx */
    movq    (%rdi), %r13            /* heap */
    movl    %ecx, %r14d             /* k */
    movl    %r8d, %r15d             /* v */

    /* Unpack root t from req = IRoot{t} */
    movq    %rdx, %rax
    shrq    $56, %rax
    andl    $0x7f, %eax
    cmpl    $1, %eax
    je      .Li_root_inline
    movq    %rdx, %rbx
    shlq    $24, %rbx
    shrq    $24, %rbx
    testq   %rdx, %rdx
    jns     1f
    movq    (%r13,%rbx,8), %rbx
    shrq    $24, %rbx
1:  movq    (%r13,%rbx,8), %rdi     /* t = IRoot.t */
    jmp     .Li_call
.Li_root_inline:
    movq    %rdx, %rdi
    shlq    $24, %rdi
    shrq    $24, %rdi

.Li_call:
    callq   .Laa_ins_rec

    popq    %r15
    popq    %r14
    popq    %r13
    popq    %r12
    popq    %rbp
    popq    %rbx
    ret

/* Internal recursive helper:
 *   %rdi = t (AATree handle)
 *   %r12 = ctx, %r13 = heap, %r14d = k, %r15d = v
 *   returns new AATree handle in %rax
 */
    .align 16
.Laa_ins_rec:
    /* Check Leaf{} (cid == 0x27) */
    movq    %rdi, %rax
    shrq    $40, %rax
    andl    $0xffff, %eax
    cmpl    $0x27, %eax
    jne     .Laa_node

    /* Allocate leaf Node{1, k, v, Leaf{}, Leaf{}} */
    subq    $56, %rsp               /* 16-byte aligned (ret pushed 8 -> +56 = 64) */
    movq    $1, 0(%rsp)
    movl    %r14d, %eax
    movq    %rax, 8(%rsp)
    movl    %r15d, %eax
    movq    %rax, 16(%rsp)
    movabsq $0x0100270000000000, %rax
    movq    %rax, 24(%rsp)
    movq    %rax, 32(%rsp)
    movq    %r12, %rdi
    movl    $0x28, %esi
    movq    %rsp, %rdx
    movl    $5, %ecx
    callq   p111_rt_ctor
    addq    $56, %rsp
    ret

.Laa_node:
    /* Decode Node ptr -> %rdx */
    movq    %rdi, %rdx
    shlq    $24, %rdx
    shrq    $24, %rdx
    testq   %rdi, %rdi
    jns     2f
    movq    (%r13,%rdx,8), %rdx
    shrq    $24, %rdx
2:  leaq    (%r13,%rdx,8), %rdx

    /* Compare k (%r14d) vs tk (8(%rdx)) */
    movl    8(%rdx), %eax
    cmpl    %eax, %r14d
    jb      .Laa_go_left
    ja      .Laa_go_right

    /* k == tk: update val in-place (FBIP), return t */
    movl    %r15d, 16(%rdx)
    movq    %rdi, %rax
    ret

.Laa_go_left:
    pushq   %rbx
    pushq   %rbp
    subq    $8, %rsp                /* align stack */
    movq    %rdi, %rbx              /* save t handle */
    movq    %rdx, %rbp              /* save t ptr */
    movq    24(%rbp), %rdi          /* t.l */
    callq   .Laa_ins_rec
    movq    %rax, 24(%rbp)          /* t.l = new_l */
    jmp     .Laa_rebalance

.Laa_go_right:
    pushq   %rbx
    pushq   %rbp
    subq    $8, %rsp
    movq    %rdi, %rbx              /* save t handle */
    movq    %rdx, %rbp              /* save t ptr */
    movq    32(%rbp), %rdi          /* t.r */
    callq   .Laa_ins_rec
    movq    %rax, 32(%rbp)          /* t.r = new_r */

.Laa_rebalance:
    /* 1. aa_skew(t=%rbx, ptr=%rbp):
     *    if l != Leaf && l.lvl == t.lvl:
     *      t.l = l.r; l.r = t; t = l; ptr = l_ptr;
     */
    movq    24(%rbp), %rcx          /* l handle */
    movq    %rcx, %rax
    shrq    $40, %rax
    andl    $0xffff, %eax
    cmpl    $0x27, %eax
    je      .Laa_split
    movq    %rcx, %rdx
    shlq    $24, %rdx
    shrq    $24, %rdx
    testq   %rcx, %rcx
    jns     3f
    movq    (%r13,%rdx,8), %rdx
    shrq    $24, %rdx
3:  leaq    (%r13,%rdx,8), %rdx     /* l ptr */
    movl    0(%rdx), %eax           /* l.lvl */
    cmpl    0(%rbp), %eax           /* l.lvl == t.lvl? */
    jne     .Laa_split
    /* Rotate right in-place */
    movq    32(%rdx), %rsi          /* lr = l.r */
    movq    %rsi, 24(%rbp)          /* t.l = lr */
    movq    %rbx, 32(%rdx)          /* l.r = t */
    movq    %rcx, %rbx              /* t = l */
    movq    %rdx, %rbp              /* ptr = l_ptr */

.Laa_split:
    /* 2. aa_split(t=%rbx, ptr=%rbp):
     *    if r != Leaf && r.r != Leaf && t.lvl == r.r.lvl:
     *      t.r = r.l; r.l = t; r.lvl++; t = r;
     */
    movq    32(%rbp), %rcx          /* r handle */
    movq    %rcx, %rax
    shrq    $40, %rax
    andl    $0xffff, %eax
    cmpl    $0x27, %eax
    je      .Laa_done_reb
    movq    %rcx, %rdx
    shlq    $24, %rdx
    shrq    $24, %rdx
    testq   %rcx, %rcx
    jns     4f
    movq    (%r13,%rdx,8), %rdx
    shrq    $24, %rdx
4:  leaq    (%r13,%rdx,8), %rdx     /* r ptr */
    movq    32(%rdx), %rsi          /* rr handle */
    movq    %rsi, %rax
    shrq    $40, %rax
    andl    $0xffff, %eax
    cmpl    $0x27, %eax
    je      .Laa_done_reb
    movq    %rsi, %rdi
    shlq    $24, %rdi
    shrq    $24, %rdi
    testq   %rsi, %rsi
    jns     5f
    movq    (%r13,%rdi,8), %rdi
    shrq    $24, %rdi
5:  leaq    (%r13,%rdi,8), %rdi     /* rr ptr */
    movl    0(%rdi), %eax           /* rr.lvl */
    cmpl    0(%rbp), %eax           /* t.lvl == rr.lvl? */
    jne     .Laa_done_reb
    /* Rotate left in-place */
    movq    24(%rdx), %rsi          /* rl = r.l */
    movq    %rsi, 32(%rbp)          /* t.r = rl */
    movq    %rbx, 24(%rdx)          /* r.l = t */
    addl    $1, 0(%rdx)             /* r.lvl++ */
    movq    %rcx, %rbx              /* t = r */

.Laa_done_reb:
    movq    %rbx, %rax
    addq    $8, %rsp
    popq    %rbp
    popq    %rbx
    ret
    .size "$direct.aa_insert", .-"$direct.aa_insert"

/* ---- $direct.aa_lookup (identical to Variant A) ---- */
    .globl "$direct.aa_lookup"
    .type "$direct.aa_lookup", @function
    .align 16
"$direct.aa_lookup":
    testq   %rsi, %rsi
    je      .Llb_zero
    movq    (%rdi), %r8
    movq    %rdx, %rax
    shrq    $56, %rax
    andl    $0x7f, %eax
    cmpl    $1, %eax
    je      .Llb_inline
    movq    %rdx, %r9
    shlq    $24, %r9
    shrq    $24, %r9
    testq   %rdx, %rdx
    jns     6f
    movq    (%r8,%r9,8), %r9
    shrq    $24, %r9
6:  movq    (%r8,%r9,8), %rdx
    jmp     .Llb_loop
.Llb_inline:
    shlq    $24, %rdx
    shrq    $24, %rdx
    .align 16
.Llb_loop:
    movq    %rdx, %rax
    shrq    $40, %rax
    andl    $0xffff, %eax
    cmpl    $0x27, %eax
    je      .Llb_zero
    movq    %rdx, %r9
    shlq    $24, %r9
    shrq    $24, %r9
    testq   %rdx, %rdx
    jns     7f
    movq    (%r8,%r9,8), %r9
    shrq    $24, %r9
7:  leaq    (%r8,%r9,8), %r9
    movl    8(%r9), %eax
    cmpl    %eax, %ecx
    jb      .Llb_left
    ja      .Llb_right
    movl    16(%r9), %eax
    ret
.Llb_left:
    movq    24(%r9), %rdx
    subq    $2, %rsi
    ja      .Llb_loop
    xorl    %eax, %eax
    ret
.Llb_right:
    movq    32(%r9), %rdx
    subq    $2, %rsi
    ja      .Llb_loop
.Llb_zero:
    xorl    %eax, %eax
    ret
    .size "$direct.aa_lookup", .-"$direct.aa_lookup"
