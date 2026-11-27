/* t4_b_branchless_dfa.S — Hand-ASM probe Variant B for t4_utf8_state_machine ($direct.scan_utf8)
 * Same as Variant A, PLUS branchless next_cp (cmov) and single-check dispatch.
 * ABI: (ctx=%rdi, rem=%rsi, i=%rdx, res=%rcx) -> %rax (returns res)
 */
    .section .rodata
    .align 32
.Lcls_lut:
    .byte 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
    .byte 1,1,1,1,2,2,2,2,6,3,3,3,4,4,5,6
    .align 32
.Ltrans_lut:
    .byte 0,4,4,1,2,3,4,4
    .byte 4,0,0,4,4,4,4,4
    .byte 4,1,1,4,4,4,4,4
    .byte 4,2,2,4,4,4,4,4

    .text
    .globl "$direct.scan_utf8"
    .type "$direct.scan_utf8", @function
    .align 16
"$direct.scan_utf8":
    testq   %rsi, %rsi
    jne     .Lgo
    movq    %rcx, %rax
    ret
.Lgo:
    pushq   %rbx
    pushq   %rbp
    pushq   %r12
    pushq   %r13
    pushq   %r14
    pushq   %r15

    movq    (%rdi), %rdi            /* %rdi = heap base */
    movq    %rcx, %rax
    shlq    $24, %rax
    shrq    $24, %rax
    testq   %rcx, %rcx
    jns     1f
    movq    (%rdi,%rax,8), %rax
    shrq    $24, %rax
1:  leaq    (%rdi,%rax,8), %r8

    movq    0(%r8), %rax            /* buf handle */
    movl    8(%r8), %r9d            /* st */
    movl    16(%r8), %r10d          /* cp */
    movl    24(%r8), %r11d          /* h */
    movl    32(%r8), %r12d          /* valid */
    movl    40(%r8), %r13d          /* errs */

    movq    %rax, %rbx
    shlq    $24, %rbx
    shrq    $24, %rbx
    testq   %rax, %rax
    jns     2f
    movq    (%rdi,%rbx,8), %rbx
    shrq    $24, %rbx
2:  leaq    (%rdi,%rbx,8), %rdi

    leaq    (%rdi,%rdx,8), %r14     /* cur */
    leaq    (%r14,%rsi,8), %r15     /* end */
    leaq    .Lcls_lut(%rip), %rsi
    leaq    .Ltrans_lut(%rip), %rbx

    .align 16
.Lloop:
    movl    (%r14), %eax            /* b */
    movl    %eax, %edx
    shrl    $3, %edx
    andl    $31, %edx
    movzbl  (%rsi,%rdx,1), %edx     /* cls */
    leal    (%rdx,%r9,8), %edx
    movzbl  (%rbx,%rdx,1), %edx     /* nst */

    /* Branchless ncp:
     *   ebp = (cp << 6) | (b & 63)
     *   eax = b & 127
     *   test st, st; cmovne ebp, eax
     */
    movl    %eax, %ebp
    andl    $63, %ebp
    shll    $6, %r10d
    orl     %r10d, %ebp
    andl    $127, %eax
    testl   %r9d, %r9d
    cmovnel %ebp, %eax              /* %eax = ncp */

    /* Branchless state/cp update for all 3 outcomes + branchless errs/valid/h */
    /* Common case: nst in {0,1,2,3,4}. If nst==0 -> accept; if nst==4 -> err; else -> mid */
    movl    %edx, %r9d
    movl    %eax, %r10d
    testl   %edx, %edx
    je      .Laccept
    cmpl    $4, %edx
    je      .Lerr
    addq    $8, %r14
    cmpq    %r15, %r14
    jne     .Lloop
    jmp     .Ldone

    .align 16
.Laccept:
    xorl    %eax, %r11d
    imull   $16777619, %r11d, %r11d
    addl    $1, %r12d
    xorl    %r10d, %r10d
    addq    $8, %r14
    cmpq    %r15, %r14
    jne     .Lloop
    jmp     .Ldone

    .align 16
.Lerr:
    addl    $1, %r13d
    xorl    %r9d, %r9d
    xorl    %r10d, %r10d
    addq    $8, %r14
    cmpq    %r15, %r14
    jne     .Lloop

.Ldone:
    movl    %r9d, 8(%r8)
    movl    %r10d, 16(%r8)
    movl    %r11d, 24(%r8)
    movl    %r12d, 32(%r8)
    movl    %r13d, 40(%r8)
    movq    %rcx, %rax

    popq    %r15
    popq    %r14
    popq    %r13
    popq    %r12
    popq    %rbp
    popq    %rbx
    ret
    .size "$direct.scan_utf8", .-"$direct.scan_utf8"
