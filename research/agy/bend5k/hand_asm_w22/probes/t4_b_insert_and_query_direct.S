/* t4_b_insert_and_query_direct.S — Hand-ASM probe Variant B for t4_interval_tree_query
 * Redirects BOTH $direct.insert_iv AND $direct.query_overlap!
 * Laws tested:
 *   1. Continuation-ADT deforestation for BOTH InsReq and QReq
 *   2. FBIP (Functional But In-Place) unique-node reuse in insert_iv (0 alloc along spine, 1 alloc at Empty leaf)
 *   3. Lean direct recursion + tail-call right-descent in query_overlap
 * Zero ABI change: allocates genuine Bend INode{lo,hi,max_hi,l,r} (cid=0x28) via p111_rt_ctor.
 */
    .text
    .globl "$direct.insert_iv"
    .type "$direct.insert_iv", @function
    .align 16
"$direct.insert_iv":
    pushq   %rbx
    pushq   %rbp
    pushq   %r12
    pushq   %r13
    pushq   %r14
    pushq   %r15
    subq    $56, %rsp

    movq    %rdi, %r12              /* ctx */
    movq    (%rdi), %r13            /* heap */
    movl    %ecx, %r14d             /* lo */
    movl    %r8d, %r15d             /* hi */

    /* Unpack root t from req = IRoot{t} */
    movq    %rdx, %rax
    shrq    $56, %rax
    andl    $0x7f, %eax
    cmpl    $1, %eax
    je      .Liroot_inline
    movq    %rdx, %rsi
    shlq    $24, %rsi
    shrq    $24, %rsi
    testq   %rdx, %rdx
    jns     1f
    movq    (%r13,%rsi,8), %rsi
    shrq    $24, %rsi
1:  movq    (%r13,%rsi,8), %rbx     /* root = t */
    jmp     .Li_check_root
.Liroot_inline:
    movq    %rdx, %rbx
    shlq    $24, %rbx
    shrq    $24, %rbx

.Li_check_root:
    /* If root is Empty{} (cid == 0x27), allocate new leaf INode and return it */
    movq    %rbx, %rax
    shrq    $40, %rax
    andl    $0xffff, %eax
    cmpl    $0x27, %eax
    jne     .Li_iter_start

    /* Allocate leaf INode{lo, hi, hi, Empty{}, Empty{}} */
    movl    %r14d, %eax
    movq    %rax, 0(%rsp)
    movl    %r15d, %eax
    movq    %rax, 8(%rsp)
    movq    %rax, 16(%rsp)
    movabsq $0x0100270000000000, %rax
    movq    %rax, 24(%rsp)
    movq    %rax, 32(%rsp)
    movq    %r12, %rdi
    movl    $0x28, %esi
    movq    %rsp, %rdx
    movl    $5, %ecx
    callq   p111_rt_ctor
    jmp     .Li_done

.Li_iter_start:
    /* Iterative in-place descent (FBIP unique-node reuse!) keeping original root in %rbx */
    movq    %rbx, %rbp              /* cur = root */

    .align 16
.Li_loop:
    /* Decode INode cur -> %rdx */
    movq    %rbp, %rdx
    shlq    $24, %rdx
    shrq    $24, %rdx
    testq   %rbp, %rbp
    jns     2f
    movq    (%r13,%rdx,8), %rdx
    shrq    $24, %rdx
2:  leaq    (%r13,%rdx,8), %rdx

    /* Update max_hi = max(max_hi, hi) in-place */
    cmpl    %r15d, 16(%rdx)
    jae     3f
    movl    %r15d, 16(%rdx)
3:
    /* Compare (lo, hi) vs (nlo, nhi) */
    movl    0(%rdx), %eax           /* nlo */
    cmpl    %eax, %r14d
    jb      .Li_go_left
    ja      .Li_go_right
    cmpl    8(%rdx), %r15d          /* lo == nlo: check hi < nhi */
    jb      .Li_go_left

.Li_go_right:
    leaq    32(%rdx), %r10          /* &node->r */
    jmp     .Li_step_child

.Li_go_left:
    leaq    24(%rdx), %r10          /* &node->l */

.Li_step_child:
    movq    (%r10), %rbp            /* child */
    movq    %rbp, %rax
    shrq    $40, %rax
    andl    $0xffff, %eax
    cmpl    $0x27, %eax
    jne     .Li_loop

    /* Child is Empty{}: allocate new INode and store into (%r10) */
    movq    %r10, 40(%rsp)          /* save slot ptr across call */
    movl    %r14d, %eax
    movq    %rax, 0(%rsp)
    movl    %r15d, %eax
    movq    %rax, 8(%rsp)
    movq    %rax, 16(%rsp)
    movabsq $0x0100270000000000, %rax
    movq    %rax, 24(%rsp)
    movq    %rax, 32(%rsp)
    movq    %r12, %rdi
    movl    $0x28, %esi
    movq    %rsp, %rdx
    movl    $5, %ecx
    callq   p111_rt_ctor
    movq    40(%rsp), %r10
    movq    %rax, (%r10)
    movq    %rbx, %rax              /* return root */

.Li_done:
    addq    $56, %rsp
    popq    %r15
    popq    %r14
    popq    %r13
    popq    %r12
    popq    %rbp
    popq    %rbx
    ret
    .size "$direct.insert_iv", .-"$direct.insert_iv"

/* ---- $direct.query_overlap (identical to Variant A) ---- */
    .globl "$direct.query_overlap"
    .type "$direct.query_overlap", @function
    .align 16
"$direct.query_overlap":
    testq   %rsi, %rsi
    jne     .Lqgo
    movl    %r9d, %eax
    ret
.Lqgo:
    pushq   %rbx
    pushq   %r12
    pushq   %r13
    pushq   %r14

    movq    (%rdi), %r12            /* heap base */
    movl    %ecx, %r13d             /* qlo */
    movl    %r8d, %r14d             /* qhi */
    movl    %r9d, %eax              /* acc */

    movq    %rdx, %rcx
    shrq    $56, %rcx
    andl    $0x7f, %ecx
    cmpl    $1, %ecx
    je      .Lqroot_inline_b
    movq    %rdx, %rsi
    shlq    $24, %rsi
    shrq    $24, %rsi
    testq   %rdx, %rdx
    jns     1f
    movq    (%r12,%rsi,8), %rsi
    shrq    $24, %rsi
1:  movq    (%r12,%rsi,8), %rdi
    jmp     .Lqstart_b
.Lqroot_inline_b:
    movq    %rdx, %rdi
    shlq    $24, %rdi
    shrq    $24, %rdi

.Lqstart_b:
    callq   .Lq_rec_b

    popq    %r14
    popq    %r13
    popq    %r12
    popq    %rbx
    ret

    .align 16
.Lq_rec_b:
    movq    %rdi, %rcx
    shrq    $40, %rcx
    andl    $0xffff, %ecx
    cmpl    $0x27, %ecx
    je      .Lq_ret_b

    movq    %rdi, %rdx
    shlq    $24, %rdx
    shrq    $24, %rdx
    testq   %rdi, %rdi
    jns     2f
    movq    (%r12,%rdx,8), %rdx
    shrq    $24, %rdx
2:  leaq    (%r12,%rdx,8), %rdx

    cmpl    %r13d, 16(%rdx)
    jb      .Lq_ret_b

    pushq   %rbx
    movq    %rdx, %rbx

    movq    24(%rbx), %rdi
    callq   .Lq_rec_b

    movl    0(%rbx), %ecx
    cmpl    %r14d, %ecx
    ja      .Lq_pop_ret_b

    movl    8(%rbx), %edx
    cmpl    %r13d, %edx
    jb      .Lq_right_b
    imull   $16777619, %eax, %eax
    shll    $16, %edx
    addl    %ecx, %edx
    xorl    %edx, %eax

.Lq_right_b:
    movq    32(%rbx), %rdi
    popq    %rbx
    jmp     .Lq_rec_b

.Lq_pop_ret_b:
    popq    %rbx
.Lq_ret_b:
    ret
    .size "$direct.query_overlap", .-"$direct.query_overlap"
