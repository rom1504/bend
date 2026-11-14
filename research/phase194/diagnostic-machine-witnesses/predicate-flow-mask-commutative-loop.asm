
/home/ai/bend2/build/publish/bend/selfhost/build/phase194/diag-commutative-build01/predicate-flow-mask/machine/program:     file format elf64-x86-64


Disassembly of section .init:

Disassembly of section .plt:

Disassembly of section .text:

0000000000408c3c <p113d_FID_36_100_105_114_101_99_116_46_112_49_57_52_46_108_111_111_112_>:
  408c3c:	push   %rbp
  408c3d:	mov    %rsp,%rbp
  408c40:	sub    $0xa00,%rsp
  408c47:	mov    %r12,-0x10(%rbp)
  408c4b:	mov    %rbx,-0x8(%rbp)
  408c4f:	mov    %r13,-0x18(%rbp)
  408c53:	mov    %r14,-0x20(%rbp)
  408c57:	mov    %r15,-0x28(%rbp)
  408c5b:	mov    %rdi,%rax
  408c5e:	mov    %rax,%r12
  408c61:	mov    %rsi,%rax
  408c64:	mov    %rax,%rdi
  408c67:	mov    %rdx,%rax
  408c6a:	mov    %rax,%rbx
  408c6d:	mov    %rcx,%rax
  408c70:	mov    %rax,%r13
  408c73:	mov    %r8,%rax
  408c76:	mov    %rax,%r14
  408c79:	cmp    $0x0,%rdi
  408c80:	jne    408ca2 <p113d_FID_36_100_105_114_101_99_116_46_112_49_57_52_46_108_111_111_112_+0x66>
  408c86:	mov    %r14,%rax
  408c89:	mov    -0x10(%rbp),%r12
  408c8d:	mov    -0x8(%rbp),%rbx
  408c91:	mov    -0x18(%rbp),%r13
  408c95:	mov    -0x20(%rbp),%r14
  408c99:	mov    -0x28(%rbp),%r15
  408c9d:	mov    %rbp,%rsp
  408ca0:	pop    %rbp
  408ca1:	retq   
  408ca2:	mov    %rdi,%r15
  408ca5:	sub    $0x1,%r15
  408cac:	mov    %r12,%rdi
  408caf:	mov    %rbx,%rsi
  408cb2:	movabs $0x0,%rdx
  408cbc:	mov    %r13,%rcx
  408cbf:	xor    %eax,%eax
  408cc1:	callq  4083ba <p113d_FID_36_100_105_114_101_99_116_46_112_49_57_52_46_107_101_114_110_101_108_>
  408cc6:	mov    %rax,%rsi
  408cc9:	mov    %r13d,%edi
  408ccc:	cmp    $0x11,%rdi
  408cd3:	sete   %dil
  408cd7:	movzbl %dil,%edi
  408cdb:	mov    %rdi,%r9
  408cde:	mov    %ebx,%edi
  408ce0:	cmp    $0x20,%rdi
  408ce7:	sete   %dil
  408ceb:	movzbl %dil,%edi
  408cef:	mov    %rdi,%rdx
  408cf2:	mov    %esi,%edi
  408cf4:	cmp    $0x81d793,%rdi
  408cfb:	sete   %dil
  408cff:	movzbl %dil,%edi
  408d03:	mov    %rdi,%r8
  408d06:	mov    %rdx,%rdi
  408d09:	xor    $0x1,%edi
  408d0f:	mov    %rdi,%rax
  408d12:	movabs $0x0,%r10
  408d1c:	mov    %r8,%r11
  408d1f:	test   %eax,%eax
  408d21:	cmovne %r10,%r11
  408d25:	mov    %r11,%r8
  408d28:	mov    %ebx,%edi
  408d2a:	cmp    $0x400,%rdi
  408d31:	sete   %dil
  408d35:	movzbl %dil,%edi
  408d39:	mov    %rdi,%rdx
  408d3c:	mov    %esi,%edi
  408d3e:	cmp    $0x3ba95813,%rdi
  408d45:	sete   %dil
  408d49:	movzbl %dil,%edi
  408d4d:	mov    %rdi,%rsi
  408d50:	mov    %rdx,%rdi
  408d53:	xor    $0x1,%edi
  408d59:	mov    %rdi,%rax
  408d5c:	movabs $0x0,%r10
  408d66:	mov    %rsi,%r11
  408d69:	test   %eax,%eax
  408d6b:	cmovne %r10,%r11
  408d6f:	mov    %r11,%rsi
  408d72:	mov    %r8,%rdi
  408d75:	cmp    $0x1,%rdi
  408d7c:	sete   %dil
  408d80:	movzbl %dil,%edi
  408d84:	cmp    $0x1,%rsi
  408d8b:	sete   %sil
  408d8f:	movzbl %sil,%esi
  408d93:	or     %edi,%esi
  408d95:	mov    %r9,%r10
  408d98:	movabs $0x1,%r11
  408da2:	cmp    %r11,%r10
  408da5:	mov    %rsi,%rax
  408da8:	movabs $0x0,%r11
  408db2:	cmove  %rax,%r11
  408db6:	mov    %r11,%rsi
  408db9:	mov    %rsi,%rdi
  408dbc:	cmp    $0x1,%rdi
  408dc3:	sete   %dil
  408dc7:	movzbl %dil,%edi
  408dcb:	xor    $0x1,%edi
  408dd1:	mov    %rdi,%rsi
  408dd4:	xor    $0x1,%rsi
  408ddb:	mov    %r14d,%edi
  408dde:	mov    %rdi,%r14
  408de1:	add    %esi,%r14d
  408de4:	mov    %r15,%rdi
  408de7:	jmpq   408c79 <p113d_FID_36_100_105_114_101_99_116_46_112_49_57_52_46_108_111_111_112_+0x3d>

Disassembly of section .fini:
