/* t4_a_lut_unbox.S — Hand-ASM probe Variant A for t4_utf8_state_machine ($direct.scan_utf8)
 * Laws tested:
 *   1. Complete .rodata LUT lowering for BOTH cls_lut (32B) and trans_lut (32B)
 *   2. Single-constructor record unboxing (URes{buf, st, cp, h, valid, errs} in registers)
 *   3. Linear-Array Hoist for buf unpacked from URes
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
    pushq   %r12
    pushq   %r13
    pushq   %r14
    pushq   %r15

    movq    (%rdi), %rdi            /* %rdi = heap base */
    /* Decode res (URes record) -> %r8 = rec_ptr */
    movq    %rcx, %rax
    shlq    $24, %rax
    shrq    $24, %rax
    testq   %rcx, %rcx
    jns     1f
    movq    (%rdi,%rax,8), %rax
    shrq    $24, %rax
1:  leaq    (%rdi,%rax,8), %r8      /* %r8 = &URes.buf */

    /* Load URes fields: buf, st, cp, h, valid, errs */
    movq    0(%r8), %rax            /* buf handle */
    movl    8(%r8), %r9d            /* st */
    movl    16(%r8), %r10d          /* cp */
    movl    24(%r8), %r11d          /* h */
    movl    32(%r8), %r12d          /* valid */
    movl    40(%r8), %r13d          /* errs */

    /* Decode buf array handle -> %rdi = &buf[0] (hoisted!) */
    movq    %rax, %rbx
    shlq    $24, %rbx
    shrq    $24, %rbx
    testq   %rax, %rax
    jns     2f
    movq    (%rdi,%rbx,8), %rbx
    shrq    $24, %rbx
2:  leaq    (%rdi,%rbx,8), %rdi     /* %rdi = buf data base (8-byte slots) */

    /* Pointer to current element & end pointer */
    leaq    (%rdi,%rdx,8), %r14     /* cur = &buf[i] */
    leaq    (%r14,%rsi,8), %r15     /* end = &buf[i + rem] */

    leaq    .Lcls_lut(%rip), %rsi   /* %rsi = CLS_LUT */
    leaq    .Ltrans_lut(%rip), %rbx /* %rbx = TRANS_LUT */

    .align 16
.Lloop:
    movl    (%r14), %eax            /* b = buf[i] */
    movl    %eax, %edx
    shrl    $3, %edx
    andl    $31, %edx
    movzbl  (%rsi,%rdx,1), %edx     /* cls = CLS_LUT[(b >> 3) & 31] */

    /* nst = TRANS_LUT[(st << 3) | cls] */
    leal    (%rdx,%r9,8), %edx
    movzbl  (%rbx,%rdx,1), %edx     /* %edx = nst */

    /* ncp = (st == 0) ? (b & 127) : ((cp << 6) | (b & 63)) */
    testl   %r9d, %r9d
    jne     .Lcont_cp
    andl    $127, %eax
    jmp     .Lgot_cp
.Lcont_cp:
    shll    $6, %r10d
    andl    $63, %eax
    orl     %r10d, %eax
.Lgot_cp:
    /* %eax = ncp, %edx = nst */
    testl   %edx, %edx
    je      .Laccept
    cmpl    $4, %edx
    je      .Lerr
    movl    %edx, %r9d              /* st = nst */
    movl    %eax, %r10d             /* cp = ncp */
    addq    $8, %r14
    cmpq    %r15, %r14
    jne     .Lloop
    jmp     .Ldone

    .align 16
.Laccept:
    xorl    %eax, %r11d
    imull   $16777619, %r11d, %r11d
    addl    $1, %r12d
    xorl    %r9d, %r9d
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
    /* Store updated scalar fields back into unique URes record */
    movl    %r9d, 8(%r8)
    movl    %r10d, 16(%r8)
    movl    %r11d, 24(%r8)
    movl    %r12d, 32(%r8)
    movl    %r13d, 40(%r8)
    movq    %rcx, %rax              /* return res */

    popq    %r15
    popq    %r14
    popq    %r13
    popq    %r12
    popq    %rbx
    ret
    .size "$direct.scan_utf8", .-"$direct.scan_utf8"
