
/home/ai/bend2/build/publish/bend/selfhost/build/phase194/diag-selected-build02/predicate-flow-mask/machine/program:     file format elf64-x86-64


Disassembly of section .init:

Disassembly of section .plt:

Disassembly of section .text:

0000000000408cc0 <p113d_FID_36_100_105_114_101_99_116_46_112_49_57_52_46_108_111_111_112_>:
  408cc0:	push   %rbp
  408cc1:	mov    %rsp,%rbp
  408cc4:	sub    $0xa00,%rsp
  408ccb:	mov    %r12,-0x10(%rbp)
  408ccf:	mov    %rbx,-0x8(%rbp)
  408cd3:	mov    %r13,-0x18(%rbp)
  408cd7:	mov    %r14,-0x20(%rbp)
  408cdb:	mov    %r15,-0x28(%rbp)
  408cdf:	mov    %rdi,%rax
  408ce2:	mov    %rax,%r12
  408ce5:	mov    %rsi,%rax
  408ce8:	mov    %rax,%rdi
  408ceb:	mov    %rdx,%rax
  408cee:	mov    %rax,%rbx
  408cf1:	mov    %rcx,%rax
  408cf4:	mov    %rax,%r13
  408cf7:	mov    %r8,%rax
  408cfa:	mov    %rax,%r14
  408cfd:	cmp    $0x0,%rdi
  408d04:	jne    408d26 <p113d_FID_36_100_105_114_101_99_116_46_112_49_57_52_46_108_111_111_112_+0x66>
  408d0a:	mov    %r14,%rax
  408d0d:	mov    -0x10(%rbp),%r12
  408d11:	mov    -0x8(%rbp),%rbx
  408d15:	mov    -0x18(%rbp),%r13
  408d19:	mov    -0x20(%rbp),%r14
  408d1d:	mov    -0x28(%rbp),%r15
  408d21:	mov    %rbp,%rsp
  408d24:	pop    %rbp
  408d25:	retq   
  408d26:	mov    %rdi,%r15
  408d29:	sub    $0x1,%r15
  408d30:	mov    %r12,%rdi
  408d33:	mov    %rbx,%rsi
  408d36:	movabs $0x0,%rdx
  408d40:	mov    %r13,%rcx
  408d43:	xor    %eax,%eax
  408d45:	callq  40841a <p113d_FID_36_100_105_114_101_99_116_46_112_49_57_52_46_107_101_114_110_101_108_>
  408d4a:	mov    %rax,%rsi
  408d4d:	mov    %r13d,%edi
  408d50:	cmp    $0x11,%rdi
  408d57:	sete   %dil
  408d5b:	movzbl %dil,%edi
  408d5f:	mov    %rdi,%r9
  408d62:	mov    %ebx,%edi
  408d64:	cmp    $0x20,%rdi
  408d6b:	sete   %dil
  408d6f:	movzbl %dil,%edi
  408d73:	mov    %rdi,%rdx
  408d76:	mov    %esi,%edi
  408d78:	cmp    $0x81d793,%rdi
  408d7f:	sete   %dil
  408d83:	movzbl %dil,%edi
  408d87:	mov    %rdi,%r8
  408d8a:	mov    %rdx,%rdi
  408d8d:	xor    $0x1,%edi
  408d93:	mov    %rdi,%rax
  408d96:	movabs $0x0,%r10
  408da0:	mov    %r8,%r11
  408da3:	test   %eax,%eax
  408da5:	cmovne %r10,%r11
  408da9:	mov    %r11,%r8
  408dac:	mov    %ebx,%edi
  408dae:	cmp    $0x400,%rdi
  408db5:	sete   %dil
  408db9:	movzbl %dil,%edi
  408dbd:	mov    %rdi,%rdx
  408dc0:	mov    %esi,%edi
  408dc2:	cmp    $0x3ba95813,%rdi
  408dc9:	sete   %dil
  408dcd:	movzbl %dil,%edi
  408dd1:	mov    %rdi,%rsi
  408dd4:	mov    %rdx,%rdi
  408dd7:	xor    $0x1,%edi
  408ddd:	mov    %rdi,%rax
  408de0:	movabs $0x0,%r10
  408dea:	mov    %rsi,%r11
  408ded:	test   %eax,%eax
  408def:	cmovne %r10,%r11
  408df3:	mov    %r11,%rsi
  408df6:	mov    %r8,%rdi
  408df9:	cmp    $0x1,%rdi
  408e00:	sete   %dil
  408e04:	movzbl %dil,%edi
  408e08:	cmp    $0x1,%rsi
  408e0f:	sete   %sil
  408e13:	movzbl %sil,%esi
  408e17:	mov    %rsi,%r11
  408e1a:	mov    %rdi,%rsi
  408e1d:	or     %r11d,%esi
  408e20:	mov    %r9,%r10
  408e23:	movabs $0x1,%r11
  408e2d:	cmp    %r11,%r10
  408e30:	mov    %rsi,%rax
  408e33:	movabs $0x0,%r11
  408e3d:	cmove  %rax,%r11
  408e41:	mov    %r11,%rsi
  408e44:	mov    %rsi,%rdi
  408e47:	cmp    $0x1,%rdi
  408e4e:	sete   %dil
  408e52:	movzbl %dil,%edi
  408e56:	xor    $0x1,%edi
  408e5c:	mov    %rdi,%rsi
  408e5f:	xor    $0x1,%rsi
  408e66:	mov    %r14d,%edi
  408e69:	mov    %rdi,%r14
  408e6c:	add    %esi,%r14d
  408e6f:	mov    %r15,%rdi
  408e72:	jmpq   408cfd <p113d_FID_36_100_105_114_101_99_116_46_112_49_57_52_46_108_111_111_112_+0x3d>

Disassembly of section .fini:
