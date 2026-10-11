
/home/ai/bend2/build/publish/bend/selfhost/build/phase68/native-products15/array-selfhost/program:     file format elf64-x86-64


Disassembly of section .text:

0000000000019570 <NF_FID_112_52_54_46_108_111_111_112_>:
   19570:	push   %rbp
   19571:	push   %r15
   19573:	push   %r14
   19575:	push   %r13
   19577:	push   %r12
   19579:	push   %rbx
   1957a:	sub    $0x58,%rsp
   1957e:	mov    %rdx,0x28(%rsp)
   19583:	movabs $0xffffffff00,%r10
   1958d:	test   %rcx,%rcx
   19590:	je     19d5a <NF_FID_112_52_54_46_108_111_111_112_+0x7ea>
   19596:	mov    %rcx,%r14
   19599:	lea    0xff(%r10),%rax
   195a0:	mov    %rax,0x8(%rsp)
   195a5:	mov    %rsi,0x18(%rsp)
   195aa:	mov    %rdi,0x10(%rsp)
   195af:	jmp    19600 <NF_FID_112_52_54_46_108_111_111_112_+0x90>
   195b1:	data16 data16 data16 data16 data16 nopw %cs:0x0(%rax,%rax,1)
   195c0:	mov    %r12,%rax
   195c3:	and    0x8(%rsp),%rax
   195c8:	mov    $0x1,%ecx
   195cd:	lock xadd %ecx,(%rdi,%rax,8)
   195d2:	not    %ecx
   195d4:	test   $0xfffffe,%ecx
   195da:	je     19dab <NF_FID_112_52_54_46_108_111_111_112_+0x83b>
   195e0:	lea    0x1(%r12),%edx
   195e5:	imul   $0x1000193,%r15d,%eax
   195ec:	add    %r12d,%ebx
   195ef:	xor    %eax,%ebx
   195f1:	mov    %rdx,%r8
   195f4:	mov    %rbx,%r9
   195f7:	test   %r14,%r14
   195fa:	je     19d60 <NF_FID_112_52_54_46_108_111_111_112_+0x7f0>
   19600:	test   %r8,%r8
   19603:	js     19640 <NF_FID_112_52_54_46_108_111_111_112_+0xd0>
   19605:	movabs $0x200000000000000,%rax
   1960f:	cmp    %rax,%r8
   19612:	setb   %al
   19615:	mov    %r8,%rcx
   19618:	and    %r10,%rcx
   1961b:	cmp    $0x3108100,%rcx
   19622:	setb   %cl
   19625:	or     %al,%cl
   19627:	jne    19678 <NF_FID_112_52_54_46_108_111_111_112_+0x108>
   19629:	mov    %r8,%rdx
   1962c:	mov    $0x2,%ecx
   19631:	callq  23d82 <rfc_wrap>
   19636:	mov    %rax,%r8
   19639:	and    0x8(%rsp),%rax
   1963e:	jmp    19660 <NF_FID_112_52_54_46_108_111_111_112_+0xf0>
   19640:	mov    %r8,%rax
   19643:	and    0x8(%rsp),%rax
   19648:	mov    $0x1,%ecx
   1964d:	lock xadd %ecx,(%rdi,%rax,8)
   19652:	not    %ecx
   19654:	test   $0xfffffe,%ecx
   1965a:	je     19dab <NF_FID_112_52_54_46_108_111_111_112_+0x83b>
   19660:	mov    $0x1,%ecx
   19665:	lock xadd %ecx,(%rdi,%rax,8)
   1966a:	not    %ecx
   1966c:	test   $0xfffffe,%ecx
   19672:	je     19dab <NF_FID_112_52_54_46_108_111_111_112_+0x83b>
   19678:	mov    0x38(%rsi),%rcx
   1967c:	test   %rcx,%rcx
   1967f:	mov    %r9,0x38(%rsp)
   19684:	je     19ce4 <NF_FID_112_52_54_46_108_111_111_112_+0x774>
   1968a:	mov    (%rdi,%rcx,8),%rax
   1968e:	mov    %rax,0x38(%rsi)
   19692:	addq   $0xffffffffffffff80,0x138(%rsi)
   1969a:	mov    %rcx,%r9
   1969d:	dec    %r14
   196a0:	mov    %r14,0x40(%rsp)
   196a5:	mov    %r8d,%ebp
   196a8:	and    $0x1,%ebp
   196ab:	or     $0x1000,%rbp
   196b2:	mov    %r8,0x30(%rsp)
   196b7:	mov    %r8d,%eax
   196ba:	and    $0xf,%eax
   196bd:	add    $0x11,%rax
   196c1:	movd   %eax,%xmm0
   196c5:	pshufd $0x44,%xmm0,%xmm0
   196ca:	movdqu %xmm0,(%rdi,%r9,8)
   196d0:	movdqu %xmm0,0x10(%rdi,%r9,8)
   196d7:	movdqu %xmm0,0x20(%rdi,%r9,8)
   196de:	movdqu %xmm0,0x30(%rdi,%r9,8)
   196e5:	movdqu %xmm0,0x40(%rdi,%r9,8)
   196ec:	movdqu %xmm0,0x50(%rdi,%r9,8)
   196f3:	movdqu %xmm0,0x60(%rdi,%r9,8)
   196fa:	movdqu %xmm0,0x70(%rdi,%r9,8)
   19701:	movdqu %xmm0,0x80(%rdi,%r9,8)
   1970b:	movdqu %xmm0,0x90(%rdi,%r9,8)
   19715:	movdqu %xmm0,0xa0(%rdi,%r9,8)
   1971f:	movdqu %xmm0,0xb0(%rdi,%r9,8)
   19729:	movdqu %xmm0,0xc0(%rdi,%r9,8)
   19733:	movdqu %xmm0,0xd0(%rdi,%r9,8)
   1973d:	movdqu %xmm0,0xe0(%rdi,%r9,8)
   19747:	movdqu %xmm0,0xf0(%rdi,%r9,8)
   19751:	movdqu %xmm0,0x100(%rdi,%r9,8)
   1975b:	movdqu %xmm0,0x110(%rdi,%r9,8)
   19765:	movdqu %xmm0,0x120(%rdi,%r9,8)
   1976f:	movdqu %xmm0,0x130(%rdi,%r9,8)
   19779:	movdqu %xmm0,0x140(%rdi,%r9,8)
   19783:	movdqu %xmm0,0x150(%rdi,%r9,8)
   1978d:	movdqu %xmm0,0x160(%rdi,%r9,8)
   19797:	movdqu %xmm0,0x170(%rdi,%r9,8)
   197a1:	movdqu %xmm0,0x180(%rdi,%r9,8)
   197ab:	movdqu %xmm0,0x190(%rdi,%r9,8)
   197b5:	movdqu %xmm0,0x1a0(%rdi,%r9,8)
   197bf:	movdqu %xmm0,0x1b0(%rdi,%r9,8)
   197c9:	movdqu %xmm0,0x1c0(%rdi,%r9,8)
   197d3:	movdqu %xmm0,0x1d0(%rdi,%r9,8)
   197dd:	movdqu %xmm0,0x1e0(%rdi,%r9,8)
   197e7:	movdqu %xmm0,0x1f0(%rdi,%r9,8)
   197f1:	movdqu %xmm0,0x200(%rdi,%r9,8)
   197fb:	movdqu %xmm0,0x210(%rdi,%r9,8)
   19805:	movdqu %xmm0,0x220(%rdi,%r9,8)
   1980f:	movdqu %xmm0,0x230(%rdi,%r9,8)
   19819:	movdqu %xmm0,0x240(%rdi,%r9,8)
   19823:	movdqu %xmm0,0x250(%rdi,%r9,8)
   1982d:	movdqu %xmm0,0x260(%rdi,%r9,8)
   19837:	movdqu %xmm0,0x270(%rdi,%r9,8)
   19841:	movdqu %xmm0,0x280(%rdi,%r9,8)
   1984b:	movdqu %xmm0,0x290(%rdi,%r9,8)
   19855:	movdqu %xmm0,0x2a0(%rdi,%r9,8)
   1985f:	movdqu %xmm0,0x2b0(%rdi,%r9,8)
   19869:	movdqu %xmm0,0x2c0(%rdi,%r9,8)
   19873:	movdqu %xmm0,0x2d0(%rdi,%r9,8)
   1987d:	movdqu %xmm0,0x2e0(%rdi,%r9,8)
   19887:	movdqu %xmm0,0x2f0(%rdi,%r9,8)
   19891:	movdqu %xmm0,0x300(%rdi,%r9,8)
   1989b:	movdqu %xmm0,0x310(%rdi,%r9,8)
   198a5:	movdqu %xmm0,0x320(%rdi,%r9,8)
   198af:	movdqu %xmm0,0x330(%rdi,%r9,8)
   198b9:	movdqu %xmm0,0x340(%rdi,%r9,8)
   198c3:	movdqu %xmm0,0x350(%rdi,%r9,8)
   198cd:	movdqu %xmm0,0x360(%rdi,%r9,8)
   198d7:	movdqu %xmm0,0x370(%rdi,%r9,8)
   198e1:	movdqu %xmm0,0x380(%rdi,%r9,8)
   198eb:	movdqu %xmm0,0x390(%rdi,%r9,8)
   198f5:	movdqu %xmm0,0x3a0(%rdi,%r9,8)
   198ff:	movdqu %xmm0,0x3b0(%rdi,%r9,8)
   19909:	movdqu %xmm0,0x3c0(%rdi,%r9,8)
   19913:	movdqu %xmm0,0x3d0(%rdi,%r9,8)
   1991d:	movdqu %xmm0,0x3e0(%rdi,%r9,8)
   19927:	movdqu %xmm0,0x3f0(%rdi,%r9,8)
   19931:	mov    %r9,%rcx
   19934:	movabs $0x600070000000000,%rax
   1993e:	or     %rax,%rcx
   19941:	mov    %rcx,0x20(%rsp)
   19946:	shr    $0x28,%rcx
   1994a:	mov    $0xffffffff,%r13d
   19950:	shl    %cl,%r13d
   19953:	not    %r13d
   19956:	mov    %r9,%r15
   19959:	and    0x8(%rsp),%r15
   1995e:	xor    %r14d,%r14d
   19961:	xor    %r12d,%r12d
   19964:	mov    %r15,0x48(%rsp)
   19969:	jmp    199a2 <NF_FID_112_52_54_46_108_111_111_112_+0x432>
   1996b:	nopl   0x0(%rax,%rax,1)
   19970:	shl    $0x20,%rax
   19974:	or     %rcx,%rax
   19977:	shr    $0x18,%rax
   1997b:	dec    %rbp
   1997e:	lea    0x1(%r14),%ecx
   19982:	mov    %r12d,%edx
   19985:	mov    %r11d,%r12d
   19988:	add    %edx,%r12d
   1998b:	xor    %r12,%r14
   1998e:	lea    (%rdi,%rax,8),%rax
   19992:	mov    %r14,(%rax,%rbx,8)
   19996:	mov    %rcx,%r14
   19999:	test   %rbp,%rbp
   1999c:	je     19b10 <NF_FID_112_52_54_46_108_111_111_112_+0x5a0>
   199a2:	mov    %r15,%rax
   199a5:	test   %r9,%r9
   199a8:	jns    199cf <NF_FID_112_52_54_46_108_111_111_112_+0x45f>
   199aa:	mov    0x4(%rdi,%r15,8),%eax
   199af:	mov    (%rdi,%r15,8),%ecx
   199b3:	mov    %ecx,%edx
   199b5:	and    $0xffffff,%edx
   199bb:	cmp    $0x1,%edx
   199be:	jne    199c4 <NF_FID_112_52_54_46_108_111_111_112_+0x454>
   199c0:	mov    (%rdi,%r15,8),%edx
   199c4:	shl    $0x20,%rax
   199c8:	or     %rcx,%rax
   199cb:	shr    $0x18,%rax
   199cf:	mov    %r14d,%ecx
   199d2:	and    %r13d,%ecx
   199d5:	mov    %ecx,%ebx
   199d7:	lea    (%rdi,%rax,8),%r8
   199db:	mov    (%r8,%rbx,8),%r11
   199df:	test   %r11,%r11
   199e2:	js     19a20 <NF_FID_112_52_54_46_108_111_111_112_+0x4b0>
   199e4:	movabs $0x200000000000000,%rax
   199ee:	cmp    %rax,%r11
   199f1:	setb   %al
   199f4:	mov    %r11,%rcx
   199f7:	and    %r10,%rcx
   199fa:	cmp    $0x3108100,%rcx
   19a01:	setb   %cl
   19a04:	or     %al,%cl
   19a06:	jne    19a40 <NF_FID_112_52_54_46_108_111_111_112_+0x4d0>
   19a08:	mov    %r11,%rdx
   19a0b:	mov    $0x2,%ecx
   19a10:	callq  23d82 <rfc_wrap>
   19a15:	mov    %rax,%r11
   19a18:	mov    %rax,(%r8,%rbx,8)
   19a1c:	jmp    19a40 <NF_FID_112_52_54_46_108_111_111_112_+0x4d0>
   19a1e:	xchg   %ax,%ax
   19a20:	mov    %r11,%rax
   19a23:	and    0x8(%rsp),%rax
   19a28:	mov    $0x1,%ecx
   19a2d:	lock xadd %ecx,(%rdi,%rax,8)
   19a32:	not    %ecx
   19a34:	test   $0xfffffe,%ecx
   19a3a:	je     19dab <NF_FID_112_52_54_46_108_111_111_112_+0x83b>
   19a40:	mov    %r15,%rax
   19a43:	test   %r9,%r9
   19a46:	jns    19a6d <NF_FID_112_52_54_46_108_111_111_112_+0x4fd>
   19a48:	mov    0x4(%rdi,%r15,8),%eax
   19a4d:	mov    (%rdi,%r15,8),%ecx
   19a51:	mov    %ecx,%edx
   19a53:	and    $0xffffff,%edx
   19a59:	cmp    $0x1,%edx
   19a5c:	jne    19a62 <NF_FID_112_52_54_46_108_111_111_112_+0x4f2>
   19a5e:	mov    (%rdi,%r15,8),%edx
   19a62:	shl    $0x20,%rax
   19a66:	or     %rcx,%rax
   19a69:	shr    $0x18,%rax
   19a6d:	lea    (%rdi,%rax,8),%rax
   19a71:	mov    (%rax,%rbx,8),%rdx
   19a75:	movabs $0x7e00000000000000,%rax
   19a7f:	test   %rax,%rdx
   19a82:	sete   %al
   19a85:	cmp    $0xffffffffffffffff,%rdx
   19a89:	sete   %cl
   19a8c:	or     %al,%cl
   19a8e:	mov    %rdx,%rax
   19a91:	and    %r10,%rax
   19a94:	cmp    $0x3108100,%rax
   19a9a:	setb   %al
   19a9d:	or     %cl,%al
   19a9f:	jne    19ae1 <NF_FID_112_52_54_46_108_111_111_112_+0x571>
   19aa1:	mov    %rbx,0x50(%rsp)
   19aa6:	mov    %r13d,%r15d
   19aa9:	mov    %rbp,%r13
   19aac:	mov    %r9,%rbp
   19aaf:	mov    %r11,%rbx
   19ab2:	callq  a970 <term_drop>
   19ab7:	mov    %rbx,%r11
   19aba:	mov    %rbp,%r9
   19abd:	mov    %r13,%rbp
   19ac0:	mov    %r15d,%r13d
   19ac3:	mov    0x48(%rsp),%r15
   19ac8:	mov    0x50(%rsp),%rbx
   19acd:	movabs $0xffffffff00,%r10
   19ad7:	mov    0x10(%rsp),%rdi
   19adc:	mov    0x18(%rsp),%rsi
   19ae1:	mov    %r15,%rax
   19ae4:	test   %r9,%r9
   19ae7:	jns    1997b <NF_FID_112_52_54_46_108_111_111_112_+0x40b>
   19aed:	mov    0x4(%rdi,%r15,8),%eax
   19af2:	mov    (%rdi,%r15,8),%ecx
   19af6:	mov    %ecx,%edx
   19af8:	and    $0xffffff,%edx
   19afe:	cmp    $0x1,%edx
   19b01:	jne    19970 <NF_FID_112_52_54_46_108_111_111_112_+0x400>
   19b07:	mov    (%rdi,%r15,8),%edx
   19b0b:	jmpq   19970 <NF_FID_112_52_54_46_108_111_111_112_+0x400>
   19b10:	mov    0x8(%rsi),%rax
   19b14:	test   %rax,%rax
   19b17:	je     19cf6 <NF_FID_112_52_54_46_108_111_111_112_+0x786>
   19b1d:	mov    (%rdi,%rax,8),%rcx
   19b21:	mov    %rcx,0x8(%rsi)
   19b25:	addq   $0xfffffffffffffffe,0x108(%rsi)
   19b2d:	mov    0x20(%rsp),%rcx
   19b32:	mov    %rcx,(%rdi,%rax,8)
   19b36:	mov    %r12,0x8(%rdi,%rax,8)
   19b3b:	mov    %rax,%rdx
   19b3e:	movabs $0x200080000000000,%rcx
   19b48:	or     %rcx,%rdx
   19b4b:	mov    %rdx,%rcx
   19b4e:	movabs $0xffff0000000000,%r8
   19b58:	and    %r8,%rcx
   19b5b:	movabs $0x80000000000,%r8
   19b65:	cmp    %r8,%rcx
   19b68:	jne    19db7 <NF_FID_112_52_54_46_108_111_111_112_+0x847>
   19b6e:	mov    %rax,%r8
   19b71:	and    0x8(%rsp),%r8
   19b76:	test   %rax,%rax
   19b79:	mov    0x40(%rsp),%r14
   19b7e:	mov    0x38(%rsp),%r15
   19b83:	mov    0x30(%rsp),%r12
   19b88:	js     19bb0 <NF_FID_112_52_54_46_108_111_111_112_+0x640>
   19b8a:	mov    (%rdi,%r8,8),%rdx
   19b8e:	mov    0x8(%rdi,%r8,8),%rbx
   19b93:	mov    %r8,%rcx
   19b96:	cmp    $0x3108100,%rcx
   19b9d:	jae    19c22 <NF_FID_112_52_54_46_108_111_111_112_+0x6b2>
   19ba3:	jmpq   19c59 <NF_FID_112_52_54_46_108_111_111_112_+0x6e9>
   19ba8:	nopl   0x0(%rax,%rax,1)
   19bb0:	mov    0x4(%rdi,%r8,8),%ecx
   19bb5:	mov    (%rdi,%r8,8),%eax
   19bb9:	mov    %eax,%r9d
   19bbc:	and    $0xffffff,%r9d
   19bc3:	cmp    $0x1,%r9d
   19bc7:	jne    19d14 <NF_FID_112_52_54_46_108_111_111_112_+0x7a4>
   19bcd:	mov    (%rdi,%r8,8),%edx
   19bd1:	shl    $0x20,%rcx
   19bd5:	or     %rax,%rcx
   19bd8:	shr    $0x18,%rcx
   19bdc:	mov    (%rdi,%rcx,8),%rdx
   19be0:	mov    0x8(%rdi,%rcx,8),%rbx
   19be5:	mov    (%rsi),%rax
   19be8:	mov    %rax,(%rdi,%r8,8)
   19bec:	mov    %r8,(%rsi)
   19bef:	mov    0x100(%rsi),%rax
   19bf6:	inc    %rax
   19bf9:	mov    %rax,0x100(%rsi)
   19c00:	cmpb   $0x1,0x10e389(%rip)        # 127f90 <KEEP_WORDS>
   19c07:	jne    19d3b <NF_FID_112_52_54_46_108_111_111_112_+0x7cb>
   19c0d:	cmp    $0x8000,%rax
   19c13:	jae    19d3b <NF_FID_112_52_54_46_108_111_111_112_+0x7cb>
   19c19:	cmp    $0x3108100,%rcx
   19c20:	jb     19c59 <NF_FID_112_52_54_46_108_111_111_112_+0x6e9>
   19c22:	mov    0x8(%rsi),%rax
   19c26:	mov    %rax,(%rdi,%rcx,8)
   19c2a:	mov    %rcx,0x8(%rsi)
   19c2e:	mov    0x108(%rsi),%rax
   19c35:	add    $0x2,%rax
   19c39:	mov    %rax,0x108(%rsi)
   19c40:	cmpb   $0x1,0x10e349(%rip)        # 127f90 <KEEP_WORDS>
   19c47:	jne    19d05 <NF_FID_112_52_54_46_108_111_111_112_+0x795>
   19c4d:	cmp    $0x8000,%rax
   19c53:	jae    19d05 <NF_FID_112_52_54_46_108_111_111_112_+0x795>
   19c59:	movabs $0x7e00000000000000,%rax
   19c63:	test   %rax,%rdx
   19c66:	sete   %al
   19c69:	cmp    $0xffffffffffffffff,%rdx
   19c6d:	sete   %cl
   19c70:	or     %al,%cl
   19c72:	mov    %rdx,%rax
   19c75:	and    %r10,%rax
   19c78:	cmp    $0x3108100,%rax
   19c7e:	setb   %al
   19c81:	or     %cl,%al
   19c83:	jne    19c9e <NF_FID_112_52_54_46_108_111_111_112_+0x72e>
   19c85:	callq  a970 <term_drop>
   19c8a:	movabs $0xffffffff00,%r10
   19c94:	mov    0x10(%rsp),%rdi
   19c99:	mov    0x18(%rsp),%rsi
   19c9e:	test   %r12,%r12
   19ca1:	js     195c0 <NF_FID_112_52_54_46_108_111_111_112_+0x50>
   19ca7:	movabs $0x200000000000000,%rax
   19cb1:	cmp    %rax,%r12
   19cb4:	setb   %al
   19cb7:	mov    %r12,%rcx
   19cba:	and    %r10,%rcx
   19cbd:	cmp    $0x3108100,%rcx
   19cc4:	setb   %cl
   19cc7:	or     %al,%cl
   19cc9:	jne    195e0 <NF_FID_112_52_54_46_108_111_111_112_+0x70>
   19ccf:	mov    %r12,%rdx
   19cd2:	mov    $0x2,%ecx
   19cd7:	callq  23d82 <rfc_wrap>
   19cdc:	mov    %rax,%r12
   19cdf:	jmpq   195e0 <NF_FID_112_52_54_46_108_111_111_112_+0x70>
   19ce4:	mov    $0x7,%edx
   19ce9:	callq  23a6b <heap_alloc_miss>
   19cee:	mov    %rax,%r9
   19cf1:	jmpq   1969d <NF_FID_112_52_54_46_108_111_111_112_+0x12d>
   19cf6:	mov    $0x1,%edx
   19cfb:	callq  23a6b <heap_alloc_miss>
   19d00:	jmpq   19b2d <NF_FID_112_52_54_46_108_111_111_112_+0x5bd>
   19d05:	mov    %rdx,%rax
   19d08:	mov    $0x1,%edx
   19d0d:	callq  23941 <heap_hand>
   19d12:	jmp    19d33 <NF_FID_112_52_54_46_108_111_111_112_+0x7c3>
   19d14:	shl    $0x20,%rcx
   19d18:	or     %rax,%rcx
   19d1b:	shr    $0x18,%rcx
   19d1f:	mov    (%rdi,%rcx,8),%rax
   19d23:	mov    0x8(%rdi,%rcx,8),%rbx
   19d28:	mov    $0x2,%r8d
   19d2e:	callq  239d2 <span_fade>
   19d33:	mov    %rax,%rdx
   19d36:	jmpq   19c59 <NF_FID_112_52_54_46_108_111_111_112_+0x6e9>
   19d3b:	mov    %rdx,%rax
   19d3e:	xor    %edx,%edx
   19d40:	callq  23941 <heap_hand>
   19d45:	mov    %rax,%rdx
   19d48:	cmp    $0x3108100,%rcx
   19d4f:	jae    19c22 <NF_FID_112_52_54_46_108_111_111_112_+0x6b2>
   19d55:	jmpq   19c59 <NF_FID_112_52_54_46_108_111_111_112_+0x6e9>
   19d5a:	mov    %r9,%rbx
   19d5d:	mov    %r8,%rdx
   19d60:	movabs $0x7e00000000000000,%rax
   19d6a:	test   %rax,%rdx
   19d6d:	sete   %al
   19d70:	cmp    $0xffffffffffffffff,%rdx
   19d74:	sete   %cl
   19d77:	or     %al,%cl
   19d79:	and    %rdx,%r10
   19d7c:	cmp    $0x3108100,%r10
   19d83:	setb   %al
   19d86:	or     %cl,%al
   19d88:	jne    19d8f <NF_FID_112_52_54_46_108_111_111_112_+0x81f>
   19d8a:	callq  a970 <term_drop>
   19d8f:	mov    0x28(%rsp),%rax
   19d94:	mov    %rbx,(%rax)
   19d97:	mov    $0x1,%eax
   19d9c:	add    $0x58,%rsp
   19da0:	pop    %rbx
   19da1:	pop    %r12
   19da3:	pop    %r13
   19da5:	pop    %r14
   19da7:	pop    %r15
   19da9:	pop    %rbp
   19daa:	retq   
   19dab:	lea    -0x15792(%rip),%rdi        # 4620 <FID_RESW_T+0x840>
   19db2:	callq  238e0 <err_fail>
   19db7:	cmp    $0xffffffffffffffff,%rdx
   19dbb:	sete   %cl
   19dbe:	and    %r10,%rax
   19dc1:	cmp    $0x3108100,%rax
   19dc7:	setb   %al
   19dca:	or     %cl,%al
   19dcc:	jne    19ddd <NF_FID_112_52_54_46_108_111_111_112_+0x86d>
   19dce:	mov    0x10(%rsp),%rdi
   19dd3:	mov    0x18(%rsp),%rsi
   19dd8:	callq  a970 <term_drop>
   19ddd:	lea    -0x15b75(%rip),%rdi        # 426f <FID_RESW_T+0x48f>
   19de4:	callq  238e0 <err_fail>

Disassembly of section .init:

Disassembly of section .fini:

Disassembly of section .plt:
