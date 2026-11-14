
/home/ai/bend2/build/publish/bend/selfhost/build/phase194/diag-references02/register-pressure-many/c/program:     file format elf64-x86-64


Disassembly of section .text:

0000000000009be0 <WL_FID_36_100_105_114_101_99_116_46_112_49_57_52_46_107_101_114_110_101_108_>:
    9be0:	test   %rsi,%rsi
    9be3:	je     9cf2 <WL_FID_36_100_105_114_101_99_116_46_112_49_57_52_46_107_101_114_110_101_108_+0x112>
    9be9:	movdqa -0x7911(%rip),%xmm0        # 22e0 <FID_RESW_T+0x130>
    9bf1:	movdqa -0x79b9(%rip),%xmm1        # 2240 <FID_RESW_T+0x90>
    9bf9:	movdqa -0x79b1(%rip),%xmm2        # 2250 <FID_RESW_T+0xa0>
    9c01:	movdqa -0x7919(%rip),%xmm3        # 22f0 <FID_RESW_T+0x140>
    9c09:	movdqa -0x79b1(%rip),%xmm4        # 2260 <FID_RESW_T+0xb0>
    9c11:	movdqa -0x7959(%rip),%xmm5        # 22c0 <FID_RESW_T+0x110>
    9c19:	movdqa -0x79a1(%rip),%xmm6        # 2280 <FID_RESW_T+0xd0>
    9c21:	movdqa -0x7989(%rip),%xmm7        # 22a0 <FID_RESW_T+0xf0>
    9c29:	movdqa -0x79a2(%rip),%xmm8        # 2290 <FID_RESW_T+0xe0>
    9c32:	data16 data16 data16 data16 nopw %cs:0x0(%rax,%rax,1)
    9c40:	movd   %ecx,%xmm9
    9c45:	pshufd $0x0,%xmm9,%xmm9
    9c4b:	movdqa %xmm9,%xmm10
    9c50:	pmuludq %xmm0,%xmm10
    9c55:	pshufd $0xe8,%xmm10,%xmm10
    9c5b:	movdqa %xmm9,%xmm11
    9c60:	pmuludq %xmm1,%xmm11
    9c65:	pshufd $0xe8,%xmm11,%xmm11
    9c6b:	punpckldq %xmm10,%xmm11
    9c70:	paddd  %xmm5,%xmm11
    9c75:	movdqa %xmm9,%xmm10
    9c7a:	pmuludq %xmm2,%xmm10
    9c7f:	pshufd $0xe8,%xmm10,%xmm10
    9c85:	movdqa %xmm9,%xmm12
    9c8a:	pmuludq %xmm3,%xmm12
    9c8f:	pshufd $0xe8,%xmm12,%xmm12
    9c95:	punpckldq %xmm10,%xmm12
    9c9a:	paddd  %xmm4,%xmm12
    9c9f:	movdqa %xmm9,%xmm10
    9ca4:	pmuludq %xmm6,%xmm10
    9ca9:	pshufd $0xe8,%xmm10,%xmm10
    9caf:	pmuludq %xmm7,%xmm9
    9cb4:	pshufd $0xe8,%xmm9,%xmm9
    9cba:	punpckldq %xmm10,%xmm9
    9cbf:	paddd  %xmm8,%xmm9
    9cc4:	pxor   %xmm11,%xmm9
    9cc9:	pxor   %xmm12,%xmm9
    9cce:	pshufd $0xee,%xmm9,%xmm10
    9cd4:	pxor   %xmm9,%xmm10
    9cd9:	pshufd $0x55,%xmm10,%xmm9
    9cdf:	pxor   %xmm10,%xmm9
    9ce4:	movd   %xmm9,%ecx
    9ce9:	dec    %rsi
    9cec:	jne    9c40 <WL_FID_36_100_105_114_101_99_116_46_112_49_57_52_46_107_101_114_110_101_108_+0x60>
    9cf2:	mov    %ecx,%esi
    9cf4:	mov    -0x8(%r14),%eax
    9cf8:	add    $0xfffffffffffffff8,%r14
    9cfc:	lea    0x93dd(%rip),%rcx        # 130e0 <wl_tab>
    9d03:	mov    (%rcx,%rax,8),%rax
    9d07:	mov    $0x1,%edi
    9d0c:	jmpq   *%rax

Disassembly of section .init:

Disassembly of section .fini:

Disassembly of section .plt:
