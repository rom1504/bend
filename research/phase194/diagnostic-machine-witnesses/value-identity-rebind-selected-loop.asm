
/home/ai/bend2/build/publish/bend/selfhost/build/phase194/diag-selected-build02/value-identity-rebind/machine/program:     file format elf64-x86-64


Disassembly of section .init:

Disassembly of section .plt:

Disassembly of section .text:

0000000000408bd0 <p113d_FID_36_100_105_114_101_99_116_46_112_49_57_52_46_108_111_111_112_>:
  408bd0:	push   %rbp
  408bd1:	mov    %rsp,%rbp
  408bd4:	sub    $0xa00,%rsp
  408bdb:	mov    %r12,-0x10(%rbp)
  408bdf:	mov    %rbx,-0x8(%rbp)
  408be3:	mov    %r13,-0x18(%rbp)
  408be7:	mov    %r14,-0x20(%rbp)
  408beb:	mov    %r15,-0x28(%rbp)
  408bef:	mov    %rdi,%rax
  408bf2:	mov    %rax,%r12
  408bf5:	mov    %rsi,%rax
  408bf8:	mov    %rax,%rdi
  408bfb:	mov    %rdx,%rax
  408bfe:	mov    %rax,%rbx
  408c01:	mov    %rcx,%rax
  408c04:	mov    %rax,%r13
  408c07:	mov    %r8,%rax
  408c0a:	mov    %rax,%r14
  408c0d:	cmp    $0x0,%rdi
  408c14:	jne    408c36 <p113d_FID_36_100_105_114_101_99_116_46_112_49_57_52_46_108_111_111_112_+0x66>
  408c1a:	mov    %r14,%rax
  408c1d:	mov    -0x10(%rbp),%r12
  408c21:	mov    -0x8(%rbp),%rbx
  408c25:	mov    -0x18(%rbp),%r13
  408c29:	mov    -0x20(%rbp),%r14
  408c2d:	mov    -0x28(%rbp),%r15
  408c31:	mov    %rbp,%rsp
  408c34:	pop    %rbp
  408c35:	retq   
  408c36:	mov    %rdi,%r15
  408c39:	sub    $0x1,%r15
  408c40:	mov    %r12,%rdi
  408c43:	mov    %rbx,%rsi
  408c46:	movabs $0x0,%rdx
  408c50:	mov    %r13,%rcx
  408c53:	xor    %eax,%eax
  408c55:	callq  4083a2 <p113d_FID_36_100_105_114_101_99_116_46_112_49_57_52_46_107_101_114_110_101_108_>
  408c5a:	mov    %rax,%rsi
  408c5d:	mov    %r13d,%edi
  408c60:	cmp    $0x11,%rdi
  408c67:	sete   %dil
  408c6b:	movzbl %dil,%edi
  408c6f:	mov    %rdi,%r9
  408c72:	mov    %ebx,%edi
  408c74:	cmp    $0x20,%rdi
  408c7b:	sete   %dil
  408c7f:	movzbl %dil,%edi
  408c83:	mov    %rdi,%rdx
  408c86:	mov    %esi,%edi
  408c88:	movabs $0x9f28de62,%r11
  408c92:	cmp    %r11,%rdi
  408c95:	sete   %dil
  408c99:	movzbl %dil,%edi
  408c9d:	mov    %rdi,%r8
  408ca0:	mov    %rdx,%rdi
  408ca3:	xor    $0x1,%edi
  408ca9:	mov    %rdi,%rax
  408cac:	movabs $0x0,%r10
  408cb6:	mov    %r8,%r11
  408cb9:	test   %eax,%eax
  408cbb:	cmovne %r10,%r11
  408cbf:	mov    %r11,%r8
  408cc2:	mov    %ebx,%edi
  408cc4:	cmp    $0x400,%rdi
  408ccb:	sete   %dil
  408ccf:	movzbl %dil,%edi
  408cd3:	mov    %rdi,%rdx
  408cd6:	mov    %esi,%edi
  408cd8:	movabs $0x9f28da82,%r11
  408ce2:	cmp    %r11,%rdi
  408ce5:	sete   %dil
  408ce9:	movzbl %dil,%edi
  408ced:	mov    %rdi,%rsi
  408cf0:	mov    %rdx,%rdi
  408cf3:	xor    $0x1,%edi
  408cf9:	mov    %rdi,%rax
  408cfc:	movabs $0x0,%r10
  408d06:	mov    %rsi,%r11
  408d09:	test   %eax,%eax
  408d0b:	cmovne %r10,%r11
  408d0f:	mov    %r11,%rsi
  408d12:	mov    %r8,%rdi
  408d15:	cmp    $0x1,%rdi
  408d1c:	sete   %dil
  408d20:	movzbl %dil,%edi
  408d24:	cmp    $0x1,%rsi
  408d2b:	sete   %sil
  408d2f:	movzbl %sil,%esi
  408d33:	mov    %rsi,%r11
  408d36:	mov    %rdi,%rsi
  408d39:	or     %r11d,%esi
  408d3c:	mov    %r9,%r10
  408d3f:	movabs $0x1,%r11
  408d49:	cmp    %r11,%r10
  408d4c:	mov    %rsi,%rax
  408d4f:	movabs $0x0,%r11
  408d59:	cmove  %rax,%r11
  408d5d:	mov    %r11,%rsi
  408d60:	mov    %rsi,%rdi
  408d63:	cmp    $0x1,%rdi
  408d6a:	sete   %dil
  408d6e:	movzbl %dil,%edi
  408d72:	xor    $0x1,%edi
  408d78:	mov    %rdi,%rsi
  408d7b:	xor    $0x1,%rsi
  408d82:	mov    %r14d,%edi
  408d85:	mov    %rdi,%r14
  408d88:	add    %esi,%r14d
  408d8b:	mov    %r15,%rdi
  408d8e:	jmpq   408c0d <p113d_FID_36_100_105_114_101_99_116_46_112_49_57_52_46_108_111_111_112_+0x3d>

Disassembly of section .fini:
