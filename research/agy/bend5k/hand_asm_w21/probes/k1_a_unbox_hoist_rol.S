/* k1_a_unbox_hoist_rol.S — Hand-ASM probe Variant A for k1_varint_decode ($direct.run_rounds)
 * Laws tested:
 *   1. Eliminate per-iteration VSt{buf, acc, shift, h, count} re-boxing inside scan_varint/step_byte
 *   2. Hoist buf array base + 0 spills
 *   3. Hardware rotate idiom (roll $13) in mix32
 * ABI: (ctx=%rdi, rem=%rsi, st=%rdx) -> %rax (returns U32 checksum)
 */
    .text
    .globl "$direct.run_rounds"
    .type "$direct.run_rounds", @function
    .align 16
"$direct.run_rounds":
    pushq   %rbx
    pushq   %r12
    pushq   %r13
    pushq   %r14
    pushq   %r15

    movq    (%rdi), %rdi            /* heap */
    /* Decode st = VSt{buf, acc, shift, h, count} -> %r8 */
    movq    %rdx, %rax
    shlq    $24, %rax
    shrq    $24, %rax
    testq   %rdx, %rdx
    jns     1f
    movq    (%rdi,%rax,8), %rax
    shrq    $24, %rax
1:  leaq    (%rdi,%rax,8), %r8

    movq    0(%r8), %rax            /* buf handle */
    movl    24(%r8), %r11d          /* h */
    movl    32(%r8), %r12d          /* count */

    /* Decode buf -> %r14 = &buf[0], %r15 = &buf[65536] */
    movq    %rax, %rbx
    shlq    $24, %rbx
    shrq    $24, %rbx
    testq   %rax, %rax
    jns     2f
    movq    (%rdi,%rbx,8), %rbx
    shrq    $24, %rbx
2:  leaq    (%rdi,%rbx,8), %r14
    leaq    524288(%r14), %r15      /* 65536 * 8 = 524288 */

    testq   %rsi, %rsi
    je      .Ldone

    .align 16
.Lround:
    movq    %r14, %r13              /* cur = &buf[0] */
    xorl    %r9d, %r9d              /* acc = 0 */
    xorl    %ecx, %ecx              /* shift = 0 */

    .align 16
.Lloop:
    movl    (%r13), %eax            /* b = buf[i] */
    movl    %eax, %edx
    andl    $127, %edx
    shll    %cl, %edx               /* (b & 127) << (shift & 31) */
    orl     %edx, %r9d              /* nacc */
    testl   $128, %eax
    je      .Lterm
    addl    $7, %ecx
    addq    $8, %r13
    cmpq    %r15, %r13
    jne     .Lloop
    jmp     .Lround_end

    .align 16
.Lterm:
    xorl    %r9d, %r11d
    imull   $2246822519, %r11d, %r11d
    roll    $13, %r11d
    movl    %r11d, %edx
    shrl    $15, %edx
    xorl    %edx, %r11d
    imull   $3266489917, %r11d, %r11d
    addl    $1, %r12d
    xorl    %r9d, %r9d
    xorl    %ecx, %ecx
    addq    $8, %r13
    cmpq    %r15, %r13
    jne     .Lloop

.Lround_end:
    subq    $1, %rsi
    jne     .Lround

.Ldone:
    imull   $2654435761, %r12d, %eax
    xorl    %r11d, %eax             /* return h ^ (count * 2654435761) */

    popq    %r15
    popq    %r14
    popq    %r13
    popq    %r12
    popq    %rbx
    ret
    .size "$direct.run_rounds", .-"$direct.run_rounds"
