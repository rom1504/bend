
/home/ai/bend2/build/publish/bend/selfhost/build/phase186/release-native45-acquire01/editdist/phase186-qbe-n2/machine/program:     file format elf64-x86-64


Disassembly of section .init:

Disassembly of section .plt:

Disassembly of section .text:

00000000004088f0 <p117v_FID_36_112_114_111_100_117_99_116_46_114_111_119_>:
  4088f0:	endbr64 
  4088f4:	push   %rbp
  4088f5:	mov    %rsp,%rbp
  4088f8:	sub    $0x138,%rsp
  4088ff:	push   %rbx
  408900:	push   %r12
  408902:	push   %r13
  408904:	push   %r14
  408906:	push   %r15
  408908:	mov    0x20(%rbp),%r12
  40890c:	mov    0x18(%rbp),%rbx
  408910:	mov    0x10(%rbp),%r13
  408914:	mov    %rcx,%r14
  408917:	mov    %r9,%rcx
  40891a:	mov    %rsi,-0x90(%rbp)
  408921:	mov    %rdx,%rsi
  408924:	mov    %r8,%rdx
  408927:	mov    %rdi,%r15
  40892a:	mov    %r15,-0x28(%rbp)
  40892e:	mov    (%r15),%rax
  408931:	mov    %rax,-0x88(%rbp)
  408938:	mov    %rcx,-0x70(%rbp)
  40893c:	nopl   0x0(%rax)
  408940:	mov    %rsi,-0x78(%rbp)
  408944:	mov    %rdx,-0x80(%rbp)
  408948:	cmp    $0x0,%rsi
  40894c:	je     408d35 <p117v_FID_36_112_114_111_100_117_99_116_46_114_111_119_+0x445>
  408952:	mov    %r13,-0x128(%rbp)
  408959:	mov    %r14,-0x120(%rbp)
  408960:	mov    %r13,%rcx
  408963:	shr    $0x38,%rcx
  408967:	cmp    $0x4,%rcx
  40896b:	sete   %cl
  40896e:	movzbl %cl,%ecx
  408971:	movabs $0xffffffffff,%rdi
  40897b:	mov    %r13,%r8
  40897e:	and    %rdi,%r8
  408981:	cmp    $0x3108280,%r8
  408988:	setae  %dil
  40898c:	movzbl %dil,%edi
  408990:	test   %ecx,%edi
  408992:	jne    4089cb <p117v_FID_36_112_114_111_100_117_99_116_46_114_111_119_+0xdb>
  408994:	mov    $0x2,%r9d
  40899a:	lea    -0x118(%rbp),%r8
  4089a1:	mov    $0x2,%ecx
  4089a6:	lea    -0x128(%rbp),%rdx
  4089ad:	mov    $0x48,%esi
  4089b2:	mov    %r15,%rdi
  4089b5:	callq  418610 <p113_rt_array_pair>
  4089ba:	mov    -0x78(%rbp),%rsi
  4089be:	mov    -0x80(%rbp),%rdx
  4089c2:	mov    -0x88(%rbp),%rax
  4089c9:	jmp    408a0a <p117v_FID_36_112_114_111_100_117_99_116_46_114_111_119_+0x11a>
  4089cb:	mov    %r13,%rcx
  4089ce:	shr    $0x28,%rcx
  4089d2:	and    $0x1f,%rcx
  4089d6:	mov    $0x1,%edi
  4089db:	shl    %cl,%rdi
  4089de:	mov    %rdi,%rcx
  4089e1:	sub    $0x1,%rcx
  4089e5:	mov    %rcx,%rdi
  4089e8:	and    %r14,%rdi
  4089eb:	mov    %r8,%rcx
  4089ee:	shl    $0x3,%rcx
  4089f2:	shl    $0x2,%rdi
  4089f6:	add    %rdi,%rcx
  4089f9:	mov    (%rax,%rcx,1),%ecx
  4089fc:	mov    %r13,-0x118(%rbp)
  408a03:	mov    %rcx,-0x110(%rbp)
  408a0a:	mov    -0x110(%rbp),%rcx
  408a11:	mov    %edx,%edi
  408a13:	mov    %ecx,%ecx
  408a15:	cmp    %rcx,%rdi
  408a18:	setne  %cl
  408a1b:	movzbl %cl,%ecx
  408a1e:	xor    $0x1,%ecx
  408a21:	mov    $0x1,%edi
  408a26:	mov    $0x0,%ecx
  408a2b:	cmove  %rdi,%rcx
  408a2f:	mov    %rcx,-0x68(%rbp)
  408a33:	mov    %rbx,-0x108(%rbp)
  408a3a:	mov    %r14,-0x100(%rbp)
  408a41:	mov    %rbx,%rcx
  408a44:	shr    $0x38,%rcx
  408a48:	cmp    $0x4,%rcx
  408a4c:	sete   %r9b
  408a50:	movzbl %r9b,%r9d
  408a54:	mov    %r9d,-0x34(%rbp)
  408a58:	movabs $0xffffffffff,%rcx
  408a62:	mov    %rbx,%r11
  408a65:	and    %rcx,%r11
  408a68:	cmp    $0x3108280,%r11
  408a6f:	setae  %r10b
  408a73:	movzbl %r10b,%r10d
  408a77:	mov    %r10d,-0x20(%rbp)
  408a7b:	mov    %rax,%rdi
  408a7e:	mov    %r9d,%eax
  408a81:	and    %r10d,%eax
  408a84:	mov    %rbx,%rcx
  408a87:	shr    $0x28,%rcx
  408a8b:	and    $0x1f,%rcx
  408a8f:	mov    $0x1,%r8d
  408a95:	shl    %cl,%r8
  408a98:	sub    $0x1,%r8
  408a9c:	mov    %r8,-0x18(%rbp)
  408aa0:	mov    %r11,%rcx
  408aa3:	shl    $0x3,%rcx
  408aa7:	mov    %rcx,-0x10(%rbp)
  408aab:	cmp    $0x0,%eax
  408aae:	jne    408afa <p117v_FID_36_112_114_111_100_117_99_116_46_114_111_119_+0x20a>
  408ab0:	mov    $0x2,%r9d
  408ab6:	lea    -0xf8(%rbp),%r8
  408abd:	mov    $0x2,%ecx
  408ac2:	lea    -0x108(%rbp),%rdx
  408ac9:	mov    $0x48,%esi
  408ace:	mov    %r15,%rdi
  408ad1:	callq  418610 <p113_rt_array_pair>
  408ad6:	mov    %r15,%rax
  408ad9:	mov    -0x78(%rbp),%rsi
  408add:	mov    -0x80(%rbp),%rdx
  408ae1:	mov    -0x10(%rbp),%rcx
  408ae5:	mov    -0x18(%rbp),%r8
  408ae9:	mov    -0x20(%rbp),%r10d
  408aed:	mov    -0x34(%rbp),%r9d
  408af1:	mov    -0x88(%rbp),%rdi
  408af8:	jmp    408b1c <p117v_FID_36_112_114_111_100_117_99_116_46_114_111_119_+0x22c>
  408afa:	mov    %r15,%rax
  408afd:	mov    %r8,%r11
  408b00:	and    %r14,%r11
  408b03:	shl    $0x2,%r11
  408b07:	add    %rcx,%r11
  408b0a:	mov    (%rdi,%r11,1),%r11d
  408b0e:	mov    %rbx,-0xf8(%rbp)
  408b15:	mov    %r11,-0xf0(%rbp)
  408b1c:	mov    -0xf0(%rbp),%r11
  408b23:	mov    %r11,-0x60(%rbp)
  408b27:	mov    %rbx,-0xe8(%rbp)
  408b2e:	mov    %r14d,%r11d
  408b31:	add    $0x1,%r11d
  408b35:	mov    %r14,%r15
  408b38:	mov    %r11d,%r14d
  408b3b:	mov    %r14,-0xe0(%rbp)
  408b42:	test   %r9d,%r10d
  408b45:	jne    408b85 <p117v_FID_36_112_114_111_100_117_99_116_46_114_111_119_+0x295>
  408b47:	mov    $0x2,%r9d
  408b4d:	lea    -0xd8(%rbp),%r8
  408b54:	mov    $0x2,%ecx
  408b59:	lea    -0xe8(%rbp),%rdx
  408b60:	mov    $0x48,%esi
  408b65:	mov    %rax,%rdi
  408b68:	callq  418610 <p113_rt_array_pair>
  408b6d:	mov    %r15,%rdi
  408b70:	mov    -0x78(%rbp),%rsi
  408b74:	mov    -0x80(%rbp),%rdx
  408b78:	mov    -0x88(%rbp),%rax
  408b7f:	mov    -0x28(%rbp),%r15
  408b83:	jmp    408ba5 <p117v_FID_36_112_114_111_100_117_99_116_46_114_111_119_+0x2b5>
  408b85:	xchg   %rax,%rdi
  408b87:	xchg   %r15,%rdi
  408b8a:	and    %r14,%r8
  408b8d:	shl    $0x2,%r8
  408b91:	add    %r8,%rcx
  408b94:	mov    (%rax,%rcx,1),%ecx
  408b97:	mov    %rbx,-0xd8(%rbp)
  408b9e:	mov    %rcx,-0xd0(%rbp)
  408ba5:	mov    -0xd0(%rbp),%r9
  408bac:	mov    %r9,-0x40(%rbp)
  408bb0:	mov    %r12,-0xc8(%rbp)
  408bb7:	mov    %rdi,-0xc0(%rbp)
  408bbe:	mov    %r12,%rcx
  408bc1:	shr    $0x38,%rcx
  408bc5:	cmp    $0x4,%rcx
  408bc9:	sete   %r10b
  408bcd:	movzbl %r10b,%r10d
  408bd1:	mov    %r10d,-0x58(%rbp)
  408bd5:	movabs $0xffffffffff,%rcx
  408bdf:	mov    %r12,%r8
  408be2:	and    %rcx,%r8
  408be5:	cmp    $0x3108280,%r8
  408bec:	setae  %r11b
  408bf0:	movzbl %r11b,%r11d
  408bf4:	mov    %r11d,-0x54(%rbp)
  408bf8:	mov    %r10d,%ecx
  408bfb:	and    %r11d,%ecx
  408bfe:	mov    %ecx,-0x38(%rbp)
  408c01:	mov    %r12,%rcx
  408c04:	shr    $0x28,%rcx
  408c08:	and    $0x1f,%rcx
  408c0c:	mov    $0x1,%r9d
  408c12:	shl    %cl,%r9
  408c15:	mov    %r9,-0x30(%rbp)
  408c19:	mov    -0x40(%rbp),%r9
  408c1d:	mov    %r9,%rcx
  408c20:	mov    -0x30(%rbp),%r9
  408c24:	sub    $0x1,%r9
  408c28:	mov    %r9,-0x50(%rbp)
  408c2c:	shl    $0x3,%r8
  408c30:	mov    %r8,-0x48(%rbp)
  408c34:	cmpl   $0x0,-0x38(%rbp)
  408c38:	jne    408c85 <p117v_FID_36_112_114_111_100_117_99_116_46_114_111_119_+0x395>
  408c3a:	mov    $0x2,%r9d
  408c40:	lea    -0xb8(%rbp),%r8
  408c47:	mov    $0x2,%ecx
  408c4c:	lea    -0xc8(%rbp),%rdx
  408c53:	mov    $0x48,%esi
  408c58:	mov    %r15,%rdi
  408c5b:	callq  418610 <p113_rt_array_pair>
  408c60:	mov    -0x78(%rbp),%rsi
  408c64:	mov    -0x80(%rbp),%rdx
  408c68:	mov    -0x48(%rbp),%r8
  408c6c:	mov    -0x50(%rbp),%r9
  408c70:	mov    -0x54(%rbp),%r11d
  408c74:	mov    -0x58(%rbp),%r10d
  408c78:	mov    -0x40(%rbp),%rcx
  408c7c:	mov    -0x88(%rbp),%rax
  408c83:	jmp    408ca0 <p117v_FID_36_112_114_111_100_117_99_116_46_114_111_119_+0x3b0>
  408c85:	and    %r9,%rdi
  408c88:	shl    $0x2,%rdi
  408c8c:	add    %r8,%rdi
  408c8f:	mov    (%rax,%rdi,1),%edi
  408c92:	mov    %r12,-0xb8(%rbp)
  408c99:	mov    %rdi,-0xb0(%rbp)
  408ca0:	mov    -0xb0(%rbp),%rdi
  408ca7:	mov    %ecx,%ecx
  408ca9:	add    $0x1,%ecx
  408cac:	mov    %ecx,%ecx
  408cae:	mov    %edi,%edi
  408cb0:	add    $0x1,%edi
  408cb3:	mov    %edi,%edi
  408cb5:	cmp    %rdi,%rcx
  408cb8:	cmovae %rdi,%rcx
  408cbc:	mov    -0x60(%rbp),%rdi
  408cc0:	mov    %edi,%edi
  408cc2:	add    -0x68(%rbp),%edi
  408cc5:	mov    %edi,%edi
  408cc7:	cmp    %rdi,%rcx
  408cca:	cmovb  %rcx,%rdi
  408cce:	mov    -0x70(%rbp),%rcx
  408cd2:	mov    %r12,-0xa8(%rbp)
  408cd9:	mov    %r14,-0xa0(%rbp)
  408ce0:	mov    %rdi,-0x98(%rbp)
  408ce7:	test   %r10d,%r11d
  408cea:	jne    408d1a <p117v_FID_36_112_114_111_100_117_99_116_46_114_111_119_+0x42a>
  408cec:	mov    $0x3,%ecx
  408cf1:	lea    -0xa8(%rbp),%rdx
  408cf8:	mov    $0x49,%esi
  408cfd:	mov    %r15,%rdi
  408d00:	callq  414d50 <p111_rt_op>
  408d05:	mov    -0x78(%rbp),%rsi
  408d09:	mov    -0x80(%rbp),%rdx
  408d0d:	mov    -0x70(%rbp),%rcx
  408d11:	mov    -0x88(%rbp),%rax
  408d18:	jmp    408d28 <p117v_FID_36_112_114_111_100_117_99_116_46_114_111_119_+0x438>
  408d1a:	and    %r14,%r9
  408d1d:	shl    $0x2,%r9
  408d21:	add    %r9,%r8
  408d24:	mov    %edi,(%rax,%r8,1)
  408d28:	sub    $0x1,%rsi
  408d2c:	mov    %rcx,-0x70(%rbp)
  408d30:	jmpq   408940 <p117v_FID_36_112_114_111_100_117_99_116_46_114_111_119_+0x50>
  408d35:	mov    -0x70(%rbp),%rcx
  408d39:	mov    -0x90(%rbp),%rax
  408d40:	mov    %rcx,(%rax)
  408d43:	mov    %r13,0x8(%rax)
  408d47:	mov    %r12,0x10(%rax)
  408d4b:	mov    %rbx,0x18(%rax)
  408d4f:	mov    $0x0,%eax
  408d54:	pop    %r15
  408d56:	pop    %r14
  408d58:	pop    %r13
  408d5a:	pop    %r12
  408d5c:	pop    %rbx
  408d5d:	leaveq 
  408d5e:	retq   

Disassembly of section .fini:
