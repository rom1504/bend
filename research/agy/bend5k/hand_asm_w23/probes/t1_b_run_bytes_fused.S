/* t1_b_run_bytes_fused.S — Hand-ASM probe Variant B for t1_lzw_dict_coder ($direct.run_bytes)
 * Laws tested:
 *   1. Dual-array preheader hoist (hk, hv) across entire 16,383-byte round
 *   2. Inner loop fusion + 3-ctor ProbeStep deforestation (ht_probe_go + handle_insert + clear_arr inlined)
 *   3. Branchless cmov for mixed-entropy byte generation + zero per-byte allocations (1 LS ctor at exit)
 * ABI (unboxed LS):
 *   %rdi=ctx, %rsi=rem, %rdx=b, %rcx=rd, %r8=hk, %r9=hv
 *   0x10(%rbp)=pref, 0x18(%rbp)=next_c, 0x20(%rbp)=acc, 0x28(%rbp)=emit, 0x30(%rbp)=rst, 0x38(%rbp)=seed
 * Returns boxed LS{hk, hv, pref, next_c, acc, emit, rst, seed} (cid 0x27, 8 fields).
 */
    .text
    .globl "$direct.run_bytes"
    .type "$direct.run_bytes", @function
    .align 16
"$direct.run_bytes":
    pushq   %rbp
    movq    %rsp, %rbp
    pushq   %rbx
    pushq   %r12
    pushq   %r13
    pushq   %r14
    pushq   %r15
    subq    $104, %rsp              /* 6*8+8=56; +104=160 (16-aligned) */

    movq    %rdi, 64(%rsp)          /* ctx */
    movq    %r8,  0(%rsp)           /* orig hk */
    movq    %r9,  8(%rsp)           /* orig hv */
    movq    %rsi, 72(%rsp)          /* rem */
    movl    %edx, 80(%rsp)          /* b */
    movl    %ecx, 84(%rsp)          /* rd */

    movl    0x10(%rbp), %r10d       /* pref */
    movl    0x18(%rbp), %r11d       /* next_c */
    movl    0x20(%rbp), %r12d       /* acc */
    movl    0x28(%rbp), %r13d       /* emit */
    movl    0x30(%rbp), %r14d       /* rst */
    movl    0x38(%rbp), %r15d       /* seed */

    testq   %rsi, %rsi
    je      .Ldone

    movq    (%rdi), %rax            /* heap */

.macro DEC_T1B hreg, dstreg
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

    DEC_T1B %r8, %rbx               /* hk base */
    DEC_T1B %r9, %r8                /* hv base */

    .align 16
.Lbyte_loop:
    /* prng(seed) */
    movl    %r15d, %eax
    shll    $13, %eax
    xorl    %eax, %r15d
    movl    %r15d, %eax
    shrl    $17, %eax
    xorl    %eax, %r15d
    movl    %r15d, %eax
    shll    $5, %eax
    xorl    %eax, %r15d

    /* ch = ((ns & 7) < 5) ? ((b * 3 + rd) & 15) : ((ns >> 8) & 31) */
    movl    80(%rsp), %eax          /* b */
    leal    (%rax,%rax,2), %edx     /* b * 3 */
    addl    84(%rsp), %edx          /* b * 3 + rd */
    andl    $15, %edx               /* t_val */
    movl    %r15d, %ecx
    shrl    $8, %ecx
    andl    $31, %ecx               /* f_val */
    movl    %r15d, %eax
    andl    $7, %eax
    cmpl    $5, %eax
    cmovbl  %edx, %ecx              /* %ecx = ch */

    /* key = (pref << 8) | ch | 0x80000000 */
    movl    %r10d, %edx
    shll    $8, %edx
    orl     %ecx, %edx
    orl     $0x80000000, %edx       /* %edx = key */

    /* slot = ((key * 2654435761) >> 19) & 8191 */
    imull   $-1640531535, %edx, %esi
    shrl    $19, %esi
    andl    $8191, %esi             /* %esi = slot */

    /* Inline 16-step open-addressing probe */
    movl    $16, %r9d
    .align 16
.Lprobe:
    movl    (%rbx,%rsi,8), %eax     /* cur = hk[slot] */
    cmpl    %edx, %eax
    je      .Lprobe_hit
    testl   %eax, %eax
    je      .Lprobe_empty
    addl    $1, %esi
    andl    $8191, %esi
    subl    $1, %r9d
    jne     .Lprobe

    /* Timeout (status = 0): emit pref, check next_c >= 4096 */
    imull   $16777619, %r12d, %r12d
    xorl    %r10d, %r12d
    addl    $1, %r13d
    cmpl    $4096, %r11d
    jae     .Ldo_reset
    movl    %ecx, %r10d             /* pref = ch */
    jmp     .Lnext_byte

.Lprobe_hit:
    movl    (%r8,%rsi,8), %r10d     /* pref = hv[slot] */
    jmp     .Lnext_byte

.Lprobe_empty:
    /* Emit pref */
    imull   $16777619, %r12d, %r12d
    xorl    %r10d, %r12d
    addl    $1, %r13d
    cmpl    $4096, %r11d
    jae     .Ldo_reset
    /* Insert: hk[slot] = key; hv[slot] = next_c; next_c++; pref = ch */
    movl    %edx, (%rbx,%rsi,8)
    movl    %r11d, (%r8,%rsi,8)
    addl    $1, %r11d
    movl    %ecx, %r10d
    jmp     .Lnext_byte

.Ldo_reset:
    /* Clear hk[0..8191] (65536 bytes) via 16-byte zero stores */
    pxor    %xmm0, %xmm0
    movq    %rbx, %rdi
    movl    $4096, %eax
.Lclr_loop:
    movdqu  %xmm0, 0(%rdi)
    addq    $16, %rdi
    subl    $1, %eax
    jne     .Lclr_loop
    movl    %ecx, %r10d             /* pref = ch */
    movl    $256, %r11d             /* next_c = 256 */
    addl    $1, %r14d               /* rst++ */

.Lnext_byte:
    addl    $1, 80(%rsp)            /* b++ */
    subq    $1, 72(%rsp)            /* rem-- */
    jne     .Lbyte_loop

.Ldone:
    /* Box LS{hk, hv, pref, next_c, acc, emit, rst, seed} (cid 0x27, 8 fields) */
    movl    %r10d, %eax
    movq    %rax, 16(%rsp)
    movl    %r11d, %eax
    movq    %rax, 24(%rsp)
    movl    %r12d, %eax
    movq    %rax, 32(%rsp)
    movl    %r13d, %eax
    movq    %rax, 40(%rsp)
    movl    %r14d, %eax
    movq    %rax, 48(%rsp)
    movl    %r15d, %eax
    movq    %rax, 56(%rsp)

    movq    64(%rsp), %rdi
    movl    $0x27, %esi
    movq    %rsp, %rdx
    movl    $8, %ecx
    callq   p111_rt_ctor

    addq    $104, %rsp
    popq    %r15
    popq    %r14
    popq    %r13
    popq    %r12
    popq    %rbx
    popq    %rbp
    ret
    .size "$direct.run_bytes", .-"$direct.run_bytes"
