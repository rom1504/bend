/* t1_a_ht_probe_deforest.S — Hand-ASM probe Variant A for t1_lzw_dict_coder ($direct.ht_probe_go)
 * Laws tested:
 *   1. Continuation-ADT deforestation on 3-ctor ProbeStep = PCont | PHit | PEmpty
 *   2. Hoist hk & hv bases across the 16-step linear-probing loop (0 inner p113_rt_array_pair, 0 inner p111_rt_ctor)
 * ABI: (ctx=%rdi, rem=%rsi, key=%rdx, ps=%rcx) -> %rax (PR{hk, hv, status, val_or_slot}, cid 0x28, 4 fields)
 */
    .text
    .globl "$direct.ht_probe_go"
    .type "$direct.ht_probe_go", @function
    .align 16
"$direct.ht_probe_go":
    pushq   %rbx
    pushq   %r12
    pushq   %r13
    subq    $48, %rsp               /* 3 pushes=24 + 8 ret = 32; +48 = 80 (16-aligned) */

    movq    %rdi, 32(%rsp)          /* ctx */
    movq    (%rdi), %rax            /* heap */

.macro DEC_T1 hreg, dstreg
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

    /* Unpack PCont{hk, hv, slot} from %rcx */
    DEC_T1  %rcx, %r8
    movq    0(%r8), %r9             /* hk handle */
    movq    8(%r8), %r10            /* hv handle */
    movl    16(%r8), %r11d          /* slot */
    movq    %r9,  0(%rsp)
    movq    %r10, 8(%rsp)

    DEC_T1  %r9,  %r12              /* hk base */
    DEC_T1  %r10, %r13              /* hv base */

    testq   %rsi, %rsi
    je      .Ltimeout

    .align 16
.Lprobe_loop:
    movl    (%r12,%r11,8), %ecx     /* cur = hk[slot] */
    cmpl    %edx, %ecx              /* cur == key? */
    je      .Lhit
    testl   %ecx, %ecx              /* cur == 0? */
    je      .Lempty
    addl    $1, %r11d
    andl    $8191, %r11d
    subq    $1, %rsi
    jne     .Lprobe_loop

.Ltimeout:
    movq    $0, 16(%rsp)            /* status = 0 */
    movl    %r11d, %eax
    movq    %rax, 24(%rsp)          /* slot */
    jmp     .Lbox_pr

.Lhit:
    movq    $1, 16(%rsp)            /* status = 1 */
    movl    (%r13,%r11,8), %eax     /* code = hv[slot] */
    movq    %rax, 24(%rsp)
    jmp     .Lbox_pr

.Lempty:
    movq    $2, 16(%rsp)            /* status = 2 */
    movl    %r11d, %eax
    movq    %rax, 24(%rsp)          /* slot */

.Lbox_pr:
    movq    32(%rsp), %rdi          /* ctx */
    movl    $0x28, %esi             /* cid PR */
    movq    %rsp, %rdx
    movl    $4, %ecx
    callq   p111_rt_ctor

    addq    $48, %rsp
    popq    %r13
    popq    %r12
    popq    %rbx
    ret
    .size "$direct.ht_probe_go", .-"$direct.ht_probe_go"
