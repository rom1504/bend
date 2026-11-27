/* t1_a_5array_hoist_fused.S — Hand-ASM probe Variant A for t1_csr_dijkstra_relax ($direct.run_sweeps)
 * Laws tested:
 *   1. Multi-array preheader hoist for ALL 5 arrays (rptr, rlen, col, wt, dist) inside Graph record
 *   2. Nested-loop fusion (run_sweeps + sweep_vertices + relax_edges + 5-deep continuation chain)
 *   3. Zero per-vertex / per-edge p113_rt_array_pair, p111_rt_op, p111_rt_ctor
 * ABI: (ctx=%rdi, rem=%rsi, gr=%rdx) -> %rax (returns gr)
 */
    .text
    .globl "$direct.run_sweeps"
    .type "$direct.run_sweeps", @function
    .align 16
"$direct.run_sweeps":
    testq   %rsi, %rsi
    jne     .Lgo
    movq    %rdx, %rax
    ret
.Lgo:
    pushq   %rbx
    pushq   %rbp
    pushq   %r12
    pushq   %r13
    pushq   %r14
    pushq   %r15
    subq    $24, %rsp
    movq    %rdx, 0(%rsp)           /* save gr handle */
    movq    %rsi, 8(%rsp)           /* save rem sweeps */

    movq    (%rdi), %rdi            /* heap */

.macro DECODE_HANDLE hreg, dstreg
    movq    \hreg, \dstreg
    shlq    $24, \dstreg
    shrq    $24, \dstreg
    testq   \hreg, \hreg
    jns     101f
    movq    (%rdi,\dstreg,8), \dstreg
    shrq    $24, \dstreg
101:
    leaq    (%rdi,\dstreg,8), \dstreg
.endm

    /* Decode gr = Gr{rptr, rlen, col, wt, dist, relax} -> %rbp */
    DECODE_HANDLE %rdx, %rbp
    movq    %rbp, 16(%rsp)

    movq    0(%rbp), %rax
    DECODE_HANDLE %rax, %r8         /* rptr base */
    movq    8(%rbp), %rax
    DECODE_HANDLE %rax, %r9         /* rlen base */
    movq    16(%rbp), %rax
    DECODE_HANDLE %rax, %r10        /* col base */
    movq    24(%rbp), %rax
    DECODE_HANDLE %rax, %r11        /* wt base */
    movq    32(%rbp), %rax
    DECODE_HANDLE %rax, %r12        /* dist base */
    movl    40(%rbp), %r13d         /* relax */

    .align 16
.Lsweep_loop:
    xorl    %ebx, %ebx              /* u = 0 */

    .align 16
.Lvertex_loop:
    movl    (%r12,%rbx,8), %r14d    /* du = dist[u] */
    cmpl    $1000000000, %r14d
    jae     .Lnext_vertex

    movl    (%r8,%rbx,8), %eax      /* e = rptr[u] */
    movl    (%r9,%rbx,8), %ecx      /* len = rlen[u] */
    testl   %ecx, %ecx
    je      .Lnext_vertex
    addl    %eax, %ecx              /* end = e + len */

    .align 16
.Ledge_loop:
    movl    (%r10,%rax,8), %edx     /* v = col[e] */
    movl    (%r11,%rax,8), %r15d    /* w = wt[e] */
    addl    %r14d, %r15d            /* cand = du + w */
    cmpl    (%r12,%rdx,8), %r15d    /* cand < dist[v]? */
    jae     .Lnext_edge
    movl    %r15d, (%r12,%rdx,8)    /* dist[v] = cand */
    addl    $1, %r13d               /* relax++ */
.Lnext_edge:
    addl    $1, %eax
    cmpl    %ecx, %eax
    jne     .Ledge_loop

.Lnext_vertex:
    addq    $1, %rbx
    cmpq    $2048, %rbx
    jne     .Lvertex_loop

    subq    $1, 8(%rsp)
    jne     .Lsweep_loop

    movq    16(%rsp), %rbp
    movl    %r13d, 40(%rbp)         /* store updated relax */
    movq    0(%rsp), %rax           /* return gr */

    addq    $24, %rsp
    popq    %r15
    popq    %r14
    popq    %r13
    popq    %r12
    popq    %rbp
    popq    %rbx
    ret
    .size "$direct.run_sweeps", .-"$direct.run_sweeps"
