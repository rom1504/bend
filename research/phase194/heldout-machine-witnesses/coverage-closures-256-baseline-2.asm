
/home/ai/bend2/build/publish/bend/selfhost/build/phase193/budget-native45-02/coverage-closures-256/machine/program:     file format elf64-x86-64


Disassembly of section .init:

Disassembly of section .plt:

Disassembly of section .text:

0000000000408b3b <p113d_FID_36_100_105_114_101_99_116_46_112_57_51_46_108_111_111_112_>:
  408b3b:	push   %rbp
  408b3c:	mov    %rsp,%rbp
  408b3f:	sub    $0x970,%rsp
  408b46:	mov    %r12,-0x10(%rbp)
  408b4a:	mov    %rbx,-0x8(%rbp)
  408b4e:	mov    %r13,-0x18(%rbp)
  408b52:	mov    %r14,-0x20(%rbp)
  408b56:	mov    %r15,-0x28(%rbp)
  408b5a:	mov    %rdi,%rax
  408b5d:	mov    %rax,%r12
  408b60:	mov    %rsi,%rax
  408b63:	mov    %rax,%rdi
  408b66:	mov    %rdx,%rax
  408b69:	mov    %rax,%r13
  408b6c:	mov    %rcx,%rax
  408b6f:	mov    %rax,%r14
  408b72:	mov    %r8,%rax
  408b75:	mov    %rax,%rbx
  408b78:	cmp    $0x0,%rdi
  408b7f:	jne    408ba1 <p113d_FID_36_100_105_114_101_99_116_46_112_57_51_46_108_111_111_112_+0x66>
  408b85:	mov    %rbx,%rax
  408b88:	mov    -0x10(%rbp),%r12
  408b8c:	mov    -0x8(%rbp),%rbx
  408b90:	mov    -0x18(%rbp),%r13
  408b94:	mov    -0x20(%rbp),%r14
  408b98:	mov    -0x28(%rbp),%r15
  408b9c:	mov    %rbp,%rsp
  408b9f:	pop    %rbp
  408ba0:	retq   
  408ba1:	mov    %rdi,%r15
  408ba4:	sub    $0x1,%r15
  408bab:	mov    %r12,%rdi
  408bae:	mov    %r13,%rsi
  408bb1:	mov    %r14,%rdx
  408bb4:	xor    %eax,%eax
  408bb6:	callq  408358 <p113d_FID_36_112_49_50_49_46_99_97_108_108_98_97_99_107_46_98_101_110_99_104_>
  408bbb:	mov    %rax,%rdi
  408bbe:	mov    %edi,%edi
  408bc0:	cmp    $0x80fb,%rdi
  408bc7:	sete   %dil
  408bcb:	movzbl %dil,%edi
  408bcf:	mov    %edi,%edi
  408bd1:	xor    $0x1,%edi
  408bd7:	mov    %rdi,%rax
  408bda:	movabs $0x0,%r10
  408be4:	movabs $0x1,%r11
  408bee:	test   %eax,%eax
  408bf0:	cmovne %r10,%r11
  408bf4:	mov    %r11,%rsi
  408bf7:	mov    %ebx,%edi
  408bf9:	mov    %rdi,%rbx
  408bfc:	add    %esi,%ebx
  408bfe:	mov    %r15,%rdi
  408c01:	jmpq   408b78 <p113d_FID_36_100_105_114_101_99_116_46_112_57_51_46_108_111_111_112_+0x3d>

Disassembly of section .fini:
