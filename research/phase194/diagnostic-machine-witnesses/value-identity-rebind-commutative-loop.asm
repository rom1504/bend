
/home/ai/bend2/build/publish/bend/selfhost/build/phase194/diag-commutative-build01/value-identity-rebind/machine/program:     file format elf64-x86-64


Disassembly of section .init:

Disassembly of section .plt:

Disassembly of section .text:

0000000000408b64 <p113d_FID_36_100_105_114_101_99_116_46_112_49_57_52_46_108_111_111_112_>:
  408b64:	push   %rbp
  408b65:	mov    %rsp,%rbp
  408b68:	sub    $0xa00,%rsp
  408b6f:	mov    %r12,-0x10(%rbp)
  408b73:	mov    %rbx,-0x8(%rbp)
  408b77:	mov    %r13,-0x18(%rbp)
  408b7b:	mov    %r14,-0x20(%rbp)
  408b7f:	mov    %r15,-0x28(%rbp)
  408b83:	mov    %rdi,%rax
  408b86:	mov    %rax,%r12
  408b89:	mov    %rsi,%rax
  408b8c:	mov    %rax,%rdi
  408b8f:	mov    %rdx,%rax
  408b92:	mov    %rax,%rbx
  408b95:	mov    %rcx,%rax
  408b98:	mov    %rax,%r13
  408b9b:	mov    %r8,%rax
  408b9e:	mov    %rax,%r14
  408ba1:	cmp    $0x0,%rdi
  408ba8:	jne    408bca <p113d_FID_36_100_105_114_101_99_116_46_112_49_57_52_46_108_111_111_112_+0x66>
  408bae:	mov    %r14,%rax
  408bb1:	mov    -0x10(%rbp),%r12
  408bb5:	mov    -0x8(%rbp),%rbx
  408bb9:	mov    -0x18(%rbp),%r13
  408bbd:	mov    -0x20(%rbp),%r14
  408bc1:	mov    -0x28(%rbp),%r15
  408bc5:	mov    %rbp,%rsp
  408bc8:	pop    %rbp
  408bc9:	retq   
  408bca:	mov    %rdi,%r15
  408bcd:	sub    $0x1,%r15
  408bd4:	mov    %r12,%rdi
  408bd7:	mov    %rbx,%rsi
  408bda:	movabs $0x0,%rdx
  408be4:	mov    %r13,%rcx
  408be7:	xor    %eax,%eax
  408be9:	callq  40834e <p113d_FID_36_100_105_114_101_99_116_46_112_49_57_52_46_107_101_114_110_101_108_>
  408bee:	mov    %rax,%rsi
  408bf1:	mov    %r13d,%edi
  408bf4:	cmp    $0x11,%rdi
  408bfb:	sete   %dil
  408bff:	movzbl %dil,%edi
  408c03:	mov    %rdi,%r9
  408c06:	mov    %ebx,%edi
  408c08:	cmp    $0x20,%rdi
  408c0f:	sete   %dil
  408c13:	movzbl %dil,%edi
  408c17:	mov    %rdi,%rdx
  408c1a:	mov    %esi,%edi
  408c1c:	movabs $0x9f28de62,%r11
  408c26:	cmp    %r11,%rdi
  408c29:	sete   %dil
  408c2d:	movzbl %dil,%edi
  408c31:	mov    %rdi,%r8
  408c34:	mov    %rdx,%rdi
  408c37:	xor    $0x1,%edi
  408c3d:	mov    %rdi,%rax
  408c40:	movabs $0x0,%r10
  408c4a:	mov    %r8,%r11
  408c4d:	test   %eax,%eax
  408c4f:	cmovne %r10,%r11
  408c53:	mov    %r11,%r8
  408c56:	mov    %ebx,%edi
  408c58:	cmp    $0x400,%rdi
  408c5f:	sete   %dil
  408c63:	movzbl %dil,%edi
  408c67:	mov    %rdi,%rdx
  408c6a:	mov    %esi,%edi
  408c6c:	movabs $0x9f28da82,%r11
  408c76:	cmp    %r11,%rdi
  408c79:	sete   %dil
  408c7d:	movzbl %dil,%edi
  408c81:	mov    %rdi,%rsi
  408c84:	mov    %rdx,%rdi
  408c87:	xor    $0x1,%edi
  408c8d:	mov    %rdi,%rax
  408c90:	movabs $0x0,%r10
  408c9a:	mov    %rsi,%r11
  408c9d:	test   %eax,%eax
  408c9f:	cmovne %r10,%r11
  408ca3:	mov    %r11,%rsi
  408ca6:	mov    %r8,%rdi
  408ca9:	cmp    $0x1,%rdi
  408cb0:	sete   %dil
  408cb4:	movzbl %dil,%edi
  408cb8:	cmp    $0x1,%rsi
  408cbf:	sete   %sil
  408cc3:	movzbl %sil,%esi
  408cc7:	or     %edi,%esi
  408cc9:	mov    %r9,%r10
  408ccc:	movabs $0x1,%r11
  408cd6:	cmp    %r11,%r10
  408cd9:	mov    %rsi,%rax
  408cdc:	movabs $0x0,%r11
  408ce6:	cmove  %rax,%r11
  408cea:	mov    %r11,%rsi
  408ced:	mov    %rsi,%rdi
  408cf0:	cmp    $0x1,%rdi
  408cf7:	sete   %dil
  408cfb:	movzbl %dil,%edi
  408cff:	xor    $0x1,%edi
  408d05:	mov    %rdi,%rsi
  408d08:	xor    $0x1,%rsi
  408d0f:	mov    %r14d,%edi
  408d12:	mov    %rdi,%r14
  408d15:	add    %esi,%r14d
  408d18:	mov    %r15,%rdi
  408d1b:	jmpq   408ba1 <p113d_FID_36_100_105_114_101_99_116_46_112_49_57_52_46_108_111_111_112_+0x3d>

Disassembly of section .fini:
