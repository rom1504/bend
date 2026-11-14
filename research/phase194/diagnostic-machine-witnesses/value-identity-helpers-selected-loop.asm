
/home/ai/bend2/build/publish/bend/selfhost/build/phase194/diag-selected-build02/value-identity-helpers/machine/program:     file format elf64-x86-64


Disassembly of section .init:

Disassembly of section .plt:

Disassembly of section .text:

0000000000408c56 <p113d_FID_36_100_105_114_101_99_116_46_112_49_57_52_46_108_111_111_112_>:
  408c56:	push   %rbp
  408c57:	mov    %rsp,%rbp
  408c5a:	sub    $0xa00,%rsp
  408c61:	mov    %r12,-0x10(%rbp)
  408c65:	mov    %rbx,-0x8(%rbp)
  408c69:	mov    %r13,-0x18(%rbp)
  408c6d:	mov    %r14,-0x20(%rbp)
  408c71:	mov    %r15,-0x28(%rbp)
  408c75:	mov    %rdi,%rax
  408c78:	mov    %rax,%r12
  408c7b:	mov    %rsi,%rax
  408c7e:	mov    %rax,%rdi
  408c81:	mov    %rdx,%rax
  408c84:	mov    %rax,%rbx
  408c87:	mov    %rcx,%rax
  408c8a:	mov    %rax,%r13
  408c8d:	mov    %r8,%rax
  408c90:	mov    %rax,%r14
  408c93:	cmp    $0x0,%rdi
  408c9a:	jne    408cbc <p113d_FID_36_100_105_114_101_99_116_46_112_49_57_52_46_108_111_111_112_+0x66>
  408ca0:	mov    %r14,%rax
  408ca3:	mov    -0x10(%rbp),%r12
  408ca7:	mov    -0x8(%rbp),%rbx
  408cab:	mov    -0x18(%rbp),%r13
  408caf:	mov    -0x20(%rbp),%r14
  408cb3:	mov    -0x28(%rbp),%r15
  408cb7:	mov    %rbp,%rsp
  408cba:	pop    %rbp
  408cbb:	retq   
  408cbc:	mov    %rdi,%r15
  408cbf:	sub    $0x1,%r15
  408cc6:	mov    %r12,%rdi
  408cc9:	mov    %rbx,%rsi
  408ccc:	movabs $0x0,%rdx
  408cd6:	mov    %r13,%rcx
  408cd9:	xor    %eax,%eax
  408cdb:	callq  408428 <p113d_FID_36_100_105_114_101_99_116_46_112_49_57_52_46_107_101_114_110_101_108_>
  408ce0:	mov    %rax,%rsi
  408ce3:	mov    %r13d,%edi
  408ce6:	cmp    $0x11,%rdi
  408ced:	sete   %dil
  408cf1:	movzbl %dil,%edi
  408cf5:	mov    %rdi,%r9
  408cf8:	mov    %ebx,%edi
  408cfa:	cmp    $0x20,%rdi
  408d01:	sete   %dil
  408d05:	movzbl %dil,%edi
  408d09:	mov    %rdi,%rdx
  408d0c:	mov    %esi,%edi
  408d0e:	movabs $0x9f28de62,%r11
  408d18:	cmp    %r11,%rdi
  408d1b:	sete   %dil
  408d1f:	movzbl %dil,%edi
  408d23:	mov    %rdi,%r8
  408d26:	mov    %rdx,%rdi
  408d29:	xor    $0x1,%edi
  408d2f:	mov    %rdi,%rax
  408d32:	movabs $0x0,%r10
  408d3c:	mov    %r8,%r11
  408d3f:	test   %eax,%eax
  408d41:	cmovne %r10,%r11
  408d45:	mov    %r11,%r8
  408d48:	mov    %ebx,%edi
  408d4a:	cmp    $0x400,%rdi
  408d51:	sete   %dil
  408d55:	movzbl %dil,%edi
  408d59:	mov    %rdi,%rdx
  408d5c:	mov    %esi,%edi
  408d5e:	movabs $0x9f28da82,%r11
  408d68:	cmp    %r11,%rdi
  408d6b:	sete   %dil
  408d6f:	movzbl %dil,%edi
  408d73:	mov    %rdi,%rsi
  408d76:	mov    %rdx,%rdi
  408d79:	xor    $0x1,%edi
  408d7f:	mov    %rdi,%rax
  408d82:	movabs $0x0,%r10
  408d8c:	mov    %rsi,%r11
  408d8f:	test   %eax,%eax
  408d91:	cmovne %r10,%r11
  408d95:	mov    %r11,%rsi
  408d98:	mov    %r8,%rdi
  408d9b:	cmp    $0x1,%rdi
  408da2:	sete   %dil
  408da6:	movzbl %dil,%edi
  408daa:	cmp    $0x1,%rsi
  408db1:	sete   %sil
  408db5:	movzbl %sil,%esi
  408db9:	mov    %rsi,%r11
  408dbc:	mov    %rdi,%rsi
  408dbf:	or     %r11d,%esi
  408dc2:	mov    %r9,%r10
  408dc5:	movabs $0x1,%r11
  408dcf:	cmp    %r11,%r10
  408dd2:	mov    %rsi,%rax
  408dd5:	movabs $0x0,%r11
  408ddf:	cmove  %rax,%r11
  408de3:	mov    %r11,%rsi
  408de6:	mov    %rsi,%rdi
  408de9:	cmp    $0x1,%rdi
  408df0:	sete   %dil
  408df4:	movzbl %dil,%edi
  408df8:	xor    $0x1,%edi
  408dfe:	mov    %rdi,%rsi
  408e01:	xor    $0x1,%rsi
  408e08:	mov    %r14d,%edi
  408e0b:	mov    %rdi,%r14
  408e0e:	add    %esi,%r14d
  408e11:	mov    %r15,%rdi
  408e14:	jmpq   408c93 <p113d_FID_36_100_105_114_101_99_116_46_112_49_57_52_46_108_111_111_112_+0x3d>

Disassembly of section .fini:
