
selfhost/build/phase111/p125-broad06-coverage-record-aggregation-256-build/program:     file format elf64-x86-64


Disassembly of section .init:

Disassembly of section .plt:

Disassembly of section .text:

0000000000427db0 <p111_FID_36_100_105_114_101_99_116_46_85_51_50_46_115_104_111_119_46_103_111_>:
  427db0:	f3 0f 1e fa          	endbr64 
  427db4:	55                   	push   %rbp
  427db5:	48 89 e5             	mov    %rsp,%rbp
  427db8:	48 81 ec 08 08 00 00 	sub    $0x808,%rsp
  427dbf:	53                   	push   %rbx
  427dc0:	41 54                	push   %r12
  427dc2:	41 55                	push   %r13
  427dc4:	48 8b 57 28          	mov    0x28(%rdi),%rdx
  427dc8:	48 8b 5f 30          	mov    0x30(%rdi),%rbx
  427dcc:	4c 8b 67 38          	mov    0x38(%rdi),%r12
  427dd0:	48 83 fa 00          	cmp    $0x0,%rdx
  427dd4:	74 6c                	je     427e42 <p111_FID_36_100_105_114_101_99_116_46_85_51_50_46_115_104_111_119_46_103_111_+0x92>
  427dd6:	2e 2e 41 b8 01 00 00 	cs cs mov $0x1,%r8d
  427ddd:	00 
  427dde:	48 8d 8d 00 f8 ff ff 	lea    -0x800(%rbp),%rcx
  427de5:	be 04 00 00 00       	mov    $0x4,%esi
  427dea:	49 89 fd             	mov    %rdi,%r13
  427ded:	e8 5e 94 00 00       	callq  431250 <p111_rt_special_take>
  427df2:	4c 89 ef             	mov    %r13,%rdi
  427df5:	48 8b 85 00 f8 ff ff 	mov    -0x800(%rbp),%rax
  427dfc:	48 89 85 00 f8 ff ff 	mov    %rax,-0x800(%rbp)
  427e03:	4c 89 a5 08 f8 ff ff 	mov    %r12,-0x7f8(%rbp)
  427e0a:	48 89 9d 10 f8 ff ff 	mov    %rbx,-0x7f0(%rbp)
  427e11:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
  427e16:	48 21 d8             	and    %rbx,%rax
  427e19:	48 83 f8 00          	cmp    $0x0,%rax
  427e1d:	0f 94 c0             	sete   %al
  427e20:	0f b6 c0             	movzbl %al,%eax
  427e23:	48 89 85 18 f8 ff ff 	mov    %rax,-0x7e8(%rbp)
  427e2a:	b9 04 00 00 00       	mov    $0x4,%ecx
  427e2f:	48 8d 95 00 f8 ff ff 	lea    -0x800(%rbp),%rdx
  427e36:	be 0f 03 00 00       	mov    $0x30f,%esi
  427e3b:	e8 c0 78 00 00       	callq  42f700 <p111_rt_jump>
  427e40:	eb 1b                	jmp    427e5d <p111_FID_36_100_105_114_101_99_116_46_85_51_50_46_115_104_111_119_46_103_111_+0xad>
  427e42:	4c 89 e3             	mov    %r12,%rbx
  427e45:	48 89 9d 00 f8 ff ff 	mov    %rbx,-0x800(%rbp)
  427e4c:	ba 01 00 00 00       	mov    $0x1,%edx
  427e51:	48 8d b5 00 f8 ff ff 	lea    -0x800(%rbp),%rsi
  427e58:	e8 03 79 00 00       	callq  42f760 <p111_rt_return>
  427e5d:	41 5d                	pop    %r13
  427e5f:	41 5c                	pop    %r12
  427e61:	5b                   	pop    %rbx
  427e62:	c9                   	leaveq 
  427e63:	c3                   	retq   

Disassembly of section .fini:
