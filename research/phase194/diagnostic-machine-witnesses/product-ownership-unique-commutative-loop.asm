
/home/ai/bend2/build/publish/bend/selfhost/build/phase194/diag-commutative-build01/product-ownership-unique/machine/program:     file format elf64-x86-64


Disassembly of section .init:

Disassembly of section .plt:

Disassembly of section .text:

0000000000408f0b <p113d_FID_36_100_105_114_101_99_116_46_112_49_57_52_46_108_111_111_112_>:
  408f0b:	push   %rbp
  408f0c:	mov    %rsp,%rbp
  408f0f:	sub    $0xa00,%rsp
  408f16:	mov    %r12,-0x10(%rbp)
  408f1a:	mov    %rbx,-0x8(%rbp)
  408f1e:	mov    %r13,-0x18(%rbp)
  408f22:	mov    %r14,-0x20(%rbp)
  408f26:	mov    %r15,-0x28(%rbp)
  408f2a:	mov    %rdi,%rax
  408f2d:	mov    %rax,%r12
  408f30:	mov    %rsi,%rax
  408f33:	mov    %rax,%rdi
  408f36:	mov    %rdx,%rax
  408f39:	mov    %rax,%rbx
  408f3c:	mov    %rcx,%rax
  408f3f:	mov    %rax,%r13
  408f42:	mov    %r8,%rax
  408f45:	mov    %rax,%r14
  408f48:	cmp    $0x0,%rdi
  408f4f:	jne    408f71 <p113d_FID_36_100_105_114_101_99_116_46_112_49_57_52_46_108_111_111_112_+0x66>
  408f55:	mov    %r14,%rax
  408f58:	mov    -0x10(%rbp),%r12
  408f5c:	mov    -0x8(%rbp),%rbx
  408f60:	mov    -0x18(%rbp),%r13
  408f64:	mov    -0x20(%rbp),%r14
  408f68:	mov    -0x28(%rbp),%r15
  408f6c:	mov    %rbp,%rsp
  408f6f:	pop    %rbp
  408f70:	retq   
  408f71:	mov    %rdi,%r15
  408f74:	sub    $0x1,%r15
  408f7b:	mov    %r12,%rdi
  408f7e:	mov    %rbx,%rsi
  408f81:	movabs $0x0,%rdx
  408f8b:	mov    %r13,%rcx
  408f8e:	xor    %eax,%eax
  408f90:	callq  4086ef <p113d_FID_36_100_105_114_101_99_116_46_112_49_57_52_46_107_101_114_110_101_108_>
  408f95:	mov    %rax,%rsi
  408f98:	mov    %r13d,%edi
  408f9b:	cmp    $0x11,%rdi
  408fa2:	sete   %dil
  408fa6:	movzbl %dil,%edi
  408faa:	mov    %rdi,%r9
  408fad:	mov    %ebx,%edi
  408faf:	cmp    $0x20,%rdi
  408fb6:	sete   %dil
  408fba:	movzbl %dil,%edi
  408fbe:	mov    %rdi,%rdx
  408fc1:	mov    %esi,%edi
  408fc3:	cmp    $0x156ac00a,%rdi
  408fca:	sete   %dil
  408fce:	movzbl %dil,%edi
  408fd2:	mov    %rdi,%r8
  408fd5:	mov    %rdx,%rdi
  408fd8:	xor    $0x1,%edi
  408fde:	mov    %rdi,%rax
  408fe1:	movabs $0x0,%r10
  408feb:	mov    %r8,%r11
  408fee:	test   %eax,%eax
  408ff0:	cmovne %r10,%r11
  408ff4:	mov    %r11,%r8
  408ff7:	mov    %ebx,%edi
  408ff9:	cmp    $0x400,%rdi
  409000:	sete   %dil
  409004:	movzbl %dil,%edi
  409008:	mov    %rdi,%rdx
  40900b:	mov    %esi,%edi
  40900d:	movabs $0xc015696a,%r11
  409017:	cmp    %r11,%rdi
  40901a:	sete   %dil
  40901e:	movzbl %dil,%edi
  409022:	mov    %rdi,%rsi
  409025:	mov    %rdx,%rdi
  409028:	xor    $0x1,%edi
  40902e:	mov    %rdi,%rax
  409031:	movabs $0x0,%r10
  40903b:	mov    %rsi,%r11
  40903e:	test   %eax,%eax
  409040:	cmovne %r10,%r11
  409044:	mov    %r11,%rsi
  409047:	mov    %r8,%rdi
  40904a:	cmp    $0x1,%rdi
  409051:	sete   %dil
  409055:	movzbl %dil,%edi
  409059:	cmp    $0x1,%rsi
  409060:	sete   %sil
  409064:	movzbl %sil,%esi
  409068:	or     %edi,%esi
  40906a:	mov    %r9,%r10
  40906d:	movabs $0x1,%r11
  409077:	cmp    %r11,%r10
  40907a:	mov    %rsi,%rax
  40907d:	movabs $0x0,%r11
  409087:	cmove  %rax,%r11
  40908b:	mov    %r11,%rsi
  40908e:	mov    %rsi,%rdi
  409091:	cmp    $0x1,%rdi
  409098:	sete   %dil
  40909c:	movzbl %dil,%edi
  4090a0:	xor    $0x1,%edi
  4090a6:	mov    %rdi,%rsi
  4090a9:	xor    $0x1,%rsi
  4090b0:	mov    %r14d,%edi
  4090b3:	mov    %rdi,%r14
  4090b6:	add    %esi,%r14d
  4090b9:	mov    %r15,%rdi
  4090bc:	jmpq   408f48 <p113d_FID_36_100_105_114_101_99_116_46_112_49_57_52_46_108_111_111_112_+0x3d>

Disassembly of section .fini:
