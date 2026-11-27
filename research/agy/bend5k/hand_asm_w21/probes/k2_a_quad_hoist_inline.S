/* k2_a_quad_hoist_inline.S — Hand-ASM probe Variant A for k2_csr_spmv ($direct.scan_rows)
 * Laws tested:
 *   1. Single-constructor record unboxing (CSt + inner EAcc completely eliminated!)
 *   2. Multi-array hoist for ALL 4 arrays (row_ptr, col_idx, vals, x) before outer row loop
 *   3. Inner loop inlining (scan_edges inlined into scan_rows, 0 per-row/per-edge allocation)
 * ABI: (ctx=%rdi, rem=%rsi, r_idx=%rdx, salt=%rcx, st=%r8) -> %rax (returns st)
 */
    .text
    .globl "$direct.scan_rows"
    .type "$direct.scan_rows", @function
    .align 16
"$direct.scan_rows":
    testq   %rsi, %rsi
    jne     .Lgo
    movq    %r8, %rax
    ret
.Lgo:
    pushq   %rbx
    pushq   %rbp
    pushq   %r12
    pushq   %r13
    pushq   %r14
    pushq   %r15

    movq    (%rdi), %rdi            /* heap */
    /* Decode st = CSt{row_ptr, col_idx, vals, x, h} -> %r9 */
    movq    %r8, %rax
    shlq    $24, %rax
    shrq    $24, %rax
    testq   %r8, %r8
    jns     1f
    movq    (%rdi,%rax,8), %rax
    shrq    $24, %rax
1:  leaq    (%rdi,%rax,8), %r9

    /* Decode row_ptr -> %r10 */
    movq    0(%r9), %rax
    movq    %rax, %r10
    shlq    $24, %r10
    shrq    $24, %r10
    testq   %rax, %rax
    jns     2f
    movq    (%rdi,%r10,8), %r10
    shrq    $24, %r10
2:  leaq    (%rdi,%r10,8), %r10
    leaq    (%r10,%rdx,8), %r10     /* &row_ptr[r_idx] */

    /* Decode col_idx -> %r11 */
    movq    8(%r9), %rax
    movq    %rax, %r11
    shlq    $24, %r11
    shrq    $24, %r11
    testq   %rax, %rax
    jns     3f
    movq    (%rdi,%r11,8), %r11
    shrq    $24, %r11
3:  leaq    (%rdi,%r11,8), %r11

    /* Decode vals -> %r12 */
    movq    16(%r9), %rax
    movq    %rax, %r12
    shlq    $24, %r12
    shrq    $24, %r12
    testq   %rax, %rax
    jns     4f
    movq    (%rdi,%r12,8), %r12
    shrq    $24, %r12
4:  leaq    (%rdi,%r12,8), %r12

    /* Decode x -> %r13 */
    movq    24(%r9), %rax
    movq    %rax, %r13
    shlq    $24, %r13
    shrq    $24, %r13
    testq   %rax, %rax
    jns     5f
    movq    (%rdi,%r13,8), %r13
    shrq    $24, %r13
5:  leaq    (%rdi,%r13,8), %r13

    movl    32(%r9), %r14d          /* h */
    /* %ecx = salt, %rsi = rem */

    .align 16
.Lrow_loop:
    movl    0(%r10), %eax           /* start = row_ptr[row] */
    movl    8(%r10), %ebx           /* end   = row_ptr[row+1] */
    movl    %ecx, %r15d             /* sum = salt */
    cmpl    %ebx, %eax
    je      .Lrow_fin

    .align 16
.Ledge_loop:
    movl    %eax, %edx
    andl    $32767, %edx            /* ei = e & 32767 */
    movl    (%r11,%rdx,8), %ebp     /* c = col_idx[ei] */
    movl    (%r12,%rdx,8), %edx     /* w = vals[ei] */
    imull   (%r13,%rbp,8), %edx     /* w * x[c] */
    addl    %edx, %r15d             /* sum += w * x[c] */
    addl    $1, %eax
    cmpl    %ebx, %eax
    jne     .Ledge_loop

.Lrow_fin:
    xorl    %r15d, %r14d
    imull   $16777619, %r14d, %r14d
    addq    $8, %r10
    subq    $1, %rsi
    jne     .Lrow_loop

    movl    %r14d, 32(%r9)
    movq    %r8, %rax

    popq    %r15
    popq    %r14
    popq    %r13
    popq    %r12
    popq    %rbp
    popq    %rbx
    ret
    .size "$direct.scan_rows", .-"$direct.scan_rows"
