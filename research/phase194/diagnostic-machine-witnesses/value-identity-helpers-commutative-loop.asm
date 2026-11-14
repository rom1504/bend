
/home/ai/bend2/build/publish/bend/selfhost/build/phase194/diag-commutative-build01/value-identity-helpers/machine/program:     file format elf64-x86-64


Disassembly of section .init:

Disassembly of section .plt:

Disassembly of section .text:

0000000000408be3 <p113d_FID_36_100_105_114_101_99_116_46_112_49_57_52_46_108_111_111_112_>:
  408be3:	push   %rbp
  408be4:	mov    %rsp,%rbp
  408be7:	sub    $0xa00,%rsp
  408bee:	mov    %r12,-0x10(%rbp)
  408bf2:	mov    %rbx,-0x8(%rbp)
  408bf6:	mov    %r13,-0x18(%rbp)
  408bfa:	mov    %r14,-0x20(%rbp)
  408bfe:	mov    %r15,-0x28(%rbp)
  408c02:	mov    %rdi,%rax
  408c05:	mov    %rax,%r12
  408c08:	mov    %rsi,%rax
  408c0b:	mov    %rax,%rdi
  408c0e:	mov    %rdx,%rax
  408c11:	mov    %rax,%rbx
  408c14:	mov    %rcx,%rax
  408c17:	mov    %rax,%r13
  408c1a:	mov    %r8,%rax
  408c1d:	mov    %rax,%r14
  408c20:	cmp    $0x0,%rdi
  408c27:	jne    408c49 <p113d_FID_36_100_105_114_101_99_116_46_112_49_57_52_46_108_111_111_112_+0x66>
  408c2d:	mov    %r14,%rax
  408c30:	mov    -0x10(%rbp),%r12
  408c34:	mov    -0x8(%rbp),%rbx
  408c38:	mov    -0x18(%rbp),%r13
  408c3c:	mov    -0x20(%rbp),%r14
  408c40:	mov    -0x28(%rbp),%r15
  408c44:	mov    %rbp,%rsp
  408c47:	pop    %rbp
  408c48:	retq   
  408c49:	mov    %rdi,%r15
  408c4c:	sub    $0x1,%r15
  408c53:	mov    %r12,%rdi
  408c56:	mov    %rbx,%rsi
  408c59:	movabs $0x0,%rdx
  408c63:	mov    %r13,%rcx
  408c66:	xor    %eax,%eax
  408c68:	callq  4083cd <p113d_FID_36_100_105_114_101_99_116_46_112_49_57_52_46_107_101_114_110_101_108_>
  408c6d:	mov    %rax,%rsi
  408c70:	mov    %r13d,%edi
  408c73:	cmp    $0x11,%rdi
  408c7a:	sete   %dil
  408c7e:	movzbl %dil,%edi
  408c82:	mov    %rdi,%r9
  408c85:	mov    %ebx,%edi
  408c87:	cmp    $0x20,%rdi
  408c8e:	sete   %dil
  408c92:	movzbl %dil,%edi
  408c96:	mov    %rdi,%rdx
  408c99:	mov    %esi,%edi
  408c9b:	movabs $0x9f28de62,%r11
  408ca5:	cmp    %r11,%rdi
  408ca8:	sete   %dil
  408cac:	movzbl %dil,%edi
  408cb0:	mov    %rdi,%r8
  408cb3:	mov    %rdx,%rdi
  408cb6:	xor    $0x1,%edi
  408cbc:	mov    %rdi,%rax
  408cbf:	movabs $0x0,%r10
  408cc9:	mov    %r8,%r11
  408ccc:	test   %eax,%eax
  408cce:	cmovne %r10,%r11
  408cd2:	mov    %r11,%r8
  408cd5:	mov    %ebx,%edi
  408cd7:	cmp    $0x400,%rdi
  408cde:	sete   %dil
  408ce2:	movzbl %dil,%edi
  408ce6:	mov    %rdi,%rdx
  408ce9:	mov    %esi,%edi
  408ceb:	movabs $0x9f28da82,%r11
  408cf5:	cmp    %r11,%rdi
  408cf8:	sete   %dil
  408cfc:	movzbl %dil,%edi
  408d00:	mov    %rdi,%rsi
  408d03:	mov    %rdx,%rdi
  408d06:	xor    $0x1,%edi
  408d0c:	mov    %rdi,%rax
  408d0f:	movabs $0x0,%r10
  408d19:	mov    %rsi,%r11
  408d1c:	test   %eax,%eax
  408d1e:	cmovne %r10,%r11
  408d22:	mov    %r11,%rsi
  408d25:	mov    %r8,%rdi
  408d28:	cmp    $0x1,%rdi
  408d2f:	sete   %dil
  408d33:	movzbl %dil,%edi
  408d37:	cmp    $0x1,%rsi
  408d3e:	sete   %sil
  408d42:	movzbl %sil,%esi
  408d46:	or     %edi,%esi
  408d48:	mov    %r9,%r10
  408d4b:	movabs $0x1,%r11
  408d55:	cmp    %r11,%r10
  408d58:	mov    %rsi,%rax
  408d5b:	movabs $0x0,%r11
  408d65:	cmove  %rax,%r11
  408d69:	mov    %r11,%rsi
  408d6c:	mov    %rsi,%rdi
  408d6f:	cmp    $0x1,%rdi
  408d76:	sete   %dil
  408d7a:	movzbl %dil,%edi
  408d7e:	xor    $0x1,%edi
  408d84:	mov    %rdi,%rsi
  408d87:	xor    $0x1,%rsi
  408d8e:	mov    %r14d,%edi
  408d91:	mov    %rdi,%r14
  408d94:	add    %esi,%r14d
  408d97:	mov    %r15,%rdi
  408d9a:	jmpq   408c20 <p113d_FID_36_100_105_114_101_99_116_46_112_49_57_52_46_108_111_111_112_+0x3d>

Disassembly of section .fini:
