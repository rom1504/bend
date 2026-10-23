
/home/ai/bend2/build/publish/bend/selfhost/build/phase111/p130-scalar01-scalar-order-scalar/program:     file format elf64-x86-64


Disassembly of section .init:

Disassembly of section .plt:

Disassembly of section .text:

0000000000405b80 <p113d_FID_36_100_105_114_101_99_116_46_112_49_51_48_115_95_111_114_100_101_114_95_103_111_>:
  405b80:	f3 0f 1e fa          	endbr64 
  405b84:	55                   	push   %rbp
  405b85:	48 89 e5             	mov    %rsp,%rbp
  405b88:	53                   	push   %rbx
  405b89:	41 54                	push   %r12
  405b8b:	41 55                	push   %r13
  405b8d:	41 56                	push   %r14
  405b8f:	49 89 d5             	mov    %rdx,%r13
  405b92:	49 89 ce             	mov    %rcx,%r14
  405b95:	b9 02 00 00 00       	mov    $0x2,%ecx
  405b9a:	4c 89 ea             	mov    %r13,%rdx
  405b9d:	49 89 f4             	mov    %rsi,%r12
  405ba0:	48 89 fb             	mov    %rdi,%rbx
  405ba3:	e8 68 b8 01 00       	callq  421410 <p118_rt_borrow_scalar_safe>
  405ba8:	4c 89 f1             	mov    %r14,%rcx
  405bab:	4c 89 e6             	mov    %r12,%rsi
  405bae:	48 89 df             	mov    %rbx,%rdi
  405bb1:	48 83 f8 00          	cmp    $0x0,%rax
  405bb5:	75 0b                	jne    405bc2 <p113d_FID_36_100_105_114_101_99_116_46_112_49_51_48_115_95_111_114_100_101_114_95_103_111_+0x42>
  405bb7:	2e 4c 89 ea          	cs mov %r13,%rdx
  405bbb:	e8 f0 f7 ff ff       	callq  4053b0 <p113d_FID_36_112_49_50_56_98_111_114_114_111_119_46_111_119_110_101_100_46_112_49_51_48_115_95_111_114_100_101_114_95_103_111_>
  405bc0:	eb 2d                	jmp    405bef <p113d_FID_36_100_105_114_101_99_116_46_112_49_51_48_115_95_111_114_100_101_114_95_103_111_+0x6f>
  405bc2:	4c 89 ea             	mov    %r13,%rdx
  405bc5:	49 89 f4             	mov    %rsi,%r12
  405bc8:	48 89 fb             	mov    %rdi,%rbx
  405bcb:	e8 40 fb ff ff       	callq  405710 <p113d_FID_36_112_49_49_56_98_111_114_114_111_119_46_114_101_97_100_46_112_49_51_48_115_95_111_114_100_101_114_95_103_111_>
  405bd0:	4c 89 e6             	mov    %r12,%rsi
  405bd3:	48 89 df             	mov    %rbx,%rdi
  405bd6:	48 89 c3             	mov    %rax,%rbx
  405bd9:	49 89 fc             	mov    %rdi,%r12
  405bdc:	e8 cf 59 01 00       	callq  41b5b0 <p111_rt_sink>
  405be1:	4c 89 ee             	mov    %r13,%rsi
  405be4:	4c 89 e7             	mov    %r12,%rdi
  405be7:	e8 c4 59 01 00       	callq  41b5b0 <p111_rt_sink>
  405bec:	48 89 d8             	mov    %rbx,%rax
  405bef:	41 5e                	pop    %r14
  405bf1:	41 5d                	pop    %r13
  405bf3:	41 5c                	pop    %r12
  405bf5:	5b                   	pop    %rbx
  405bf6:	c9                   	leaveq 
  405bf7:	c3                   	retq   

Disassembly of section .fini:
