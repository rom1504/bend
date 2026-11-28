/* v3_a_run_edges_fused.S — Hand-ASM probe Variant A for v3_dsu_kruskal_union ($direct.run_edges)
 * Laws tested:
 *   1. Dual-array preheader hoist (par, rnk) across inner path-halving loops
 *   2. Inner self-TCO loop fusion (both dsu_find(u) and dsu_find(v) inlined into run_edges)
 *   3. Zero per-edge p113_rt_array_pair, p111_rt_op, p111_rt_ctor (1 DS ctor at exit)
 * ABI (unboxed DS):
 *   %rdi=ctx, %rsi=rem, %rdx=salt, %rcx=par, %r8=rnk, %r9=acc
 *   0x10(%rbp)=merges, 0x18(%rbp)=cycles, 0x20(%rbp)=seed
 * Returns boxed DS{par, rnk, acc, merges, cycles, seed} (cid 0x27, 6 fields).
 */
    .text
    .globl "$direct.run_edges"
    .type "$direct.run_edges", @function
    .align 16
"$direct.run_edges":
    pushq   %rbp
    movq    %rsp, %rbp
    pushq   %rbx
    pushq   %r12
    pushq   %r13
    pushq   %r14
    pushq   %r15
    subq    $72, %rsp               /* 6*8+8=56; +72=128 (16-aligned) */

    movq    %rdi, 48(%rsp)          /* ctx */
    movq    %rcx, 0(%rsp)           /* orig par */
    movq    %r8,  8(%rsp)           /* orig rnk */

    movl    %r9d, %r12d             /* acc */
    movl    0x10(%rbp), %r13d       /* merges */
    movl    0x18(%rbp), %r14d       /* cycles */
    movl    0x20(%rbp), %r15d       /* seed */

    testq   %rsi, %rsi
    je      .Ldone

    movq    (%rdi), %rax            /* heap */

.macro DECODE_D hreg, dstreg
    movq    \hreg, \dstreg
    shlq    $24, \dstreg
    shrq    $24, \dstreg
    testq   \hreg, \hreg
    jns     101f
    movq    (%rax,\dstreg,8), \dstreg
    shrq    $24, \dstreg
101:
    leaq    (%rax,\dstreg,8), \dstreg
.endm

    DECODE_D %rcx, %rbx             /* par base */
    DECODE_D %r8,  %r8              /* rnk base */
    leal    (%rdx,%rdx,2), %r9d     /* salt3 = salt * 3 */
    movl    %edx, %ecx              /* salt */

    .align 16
.Ledge_loop:
    /* prng(seed): x^=x<<13; x^=x>>17; x^=x<<5 */
    movl    %r15d, %eax
    shll    $13, %eax
    xorl    %eax, %r15d
    movl    %r15d, %eax
    shrl    $17, %eax
    xorl    %eax, %r15d
    movl    %r15d, %eax
    shll    $5, %eax
    xorl    %eax, %r15d

    /* u = (ns ^ salt) & 4095 */
    movl    %r15d, %r10d
    xorl    %ecx, %r10d
    andl    $4095, %r10d

    /* v = ((ns >> 12) ^ salt3) & 4095 */
    movl    %r15d, %r11d
    shrl    $12, %r11d
    xorl    %r9d, %r11d
    andl    $4095, %r11d

    /* dsu_find(u) with path halving */
    movl    (%rbx,%r10,8), %eax     /* px = par[u] */
    cmpl    %r10d, %eax
    je      .Lfind_v
    .align 16
.Lfu_loop:
    movl    (%rbx,%rax,8), %edx     /* ppx = par[px] */
    movl    %edx, (%rbx,%r10,8)     /* par[u] = ppx */
    movl    %edx, %r10d             /* u = ppx */
    movl    (%rbx,%r10,8), %eax     /* px = par[u] */
    cmpl    %r10d, %eax
    jne     .Lfu_loop

.Lfind_v:
    /* dsu_find(v) with path halving */
    movl    (%rbx,%r11,8), %eax     /* px = par[v] */
    cmpl    %r11d, %eax
    je      .Lunion
    .align 16
.Lfv_loop:
    movl    (%rbx,%rax,8), %edx     /* ppx = par[px] */
    movl    %edx, (%rbx,%r11,8)     /* par[v] = ppx */
    movl    %edx, %r11d             /* v = ppx */
    movl    (%rbx,%r11,8), %eax     /* px = par[v] */
    cmpl    %r11d, %eax
    jne     .Lfv_loop

.Lunion:
    cmpl    %r11d, %r10d            /* ru == rv? */
    je      .Lcycle

    /* Merge: acc = ((acc * 2654435761) ^ ru) ^ (rv << 12); merges++ */
    imull   $-1640531535, %r12d, %r12d
    xorl    %r10d, %r12d
    movl    %r11d, %eax
    shll    $12, %eax
    xorl    %eax, %r12d
    addl    $1, %r13d

    movl    (%r8,%r10,8), %eax      /* rku */
    movl    (%r8,%r11,8), %edx      /* rkv */
    cmpl    %edx, %eax
    jb      .Llt
    ja      .Lgt
    /* rku == rkv: par[rv] = ru; rnk[ru] = rku + 1 */
    movl    %r10d, (%rbx,%r11,8)
    addl    $1, %eax
    movl    %eax, (%r8,%r10,8)
    jmp     .Lnext_edge

.Llt:
    movl    %r11d, (%rbx,%r10,8)    /* par[ru] = rv */
    jmp     .Lnext_edge

.Lgt:
    movl    %r10d, (%rbx,%r11,8)    /* par[rv] = ru */
    jmp     .Lnext_edge

.Lcycle:
    imull   $16777619, %r12d, %r12d
    xorl    %r10d, %r12d
    addl    $1, %r14d               /* cycles++ */

.Lnext_edge:
    subq    $1, %rsi
    jne     .Ledge_loop

.Ldone:
    /* Box DS{par, rnk, acc, merges, cycles, seed} (cid 0x27, 6 fields) */
    movl    %r12d, %eax
    movq    %rax, 16(%rsp)
    movl    %r13d, %eax
    movq    %rax, 24(%rsp)
    movl    %r14d, %eax
    movq    %rax, 32(%rsp)
    movl    %r15d, %eax
    movq    %rax, 40(%rsp)

    movq    48(%rsp), %rdi
    movl    $0x27, %esi
    movq    %rsp, %rdx
    movl    $6, %ecx
    callq   p111_rt_ctor

    addq    $72, %rsp
    popq    %r15
    popq    %r14
    popq    %r13
    popq    %r12
    popq    %rbx
    popq    %rbp
    ret
    .size "$direct.run_edges", .-"$direct.run_edges"
