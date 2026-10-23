
/home/ai/bend2/build/publish/bend/selfhost/build/phase111/p131-read-lookup01-identity-candidate-build/program:     file format elf64-x86-64


Disassembly of section .init:

Disassembly of section .plt:

Disassembly of section .text:

0000000000414060 <p111_FID_36_100_105_114_101_99_116_46_105_110_100_101_120_95_98_117_99_107_101_116_>:
  414060:	f3 0f 1e fa          	endbr64 
  414064:	55                   	push   %rbp
  414065:	48 89 e5             	mov    %rsp,%rbp
  414068:	48 83 ec 10          	sub    $0x10,%rsp
  41406c:	53                   	push   %rbx
  41406d:	41 54                	push   %r12
  41406f:	be 00 00 00 00       	mov    $0x0,%esi
  414074:	48 89 fb             	mov    %rdi,%rbx
  414077:	e8 d4 14 01 00       	callq  425550 <p111_rt_reg_get>
  41407c:	48 89 df             	mov    %rbx,%rdi
  41407f:	48 89 c6             	mov    %rax,%rsi
  414082:	49 89 f4             	mov    %rsi,%r12
  414085:	be 01 00 00 00       	mov    $0x1,%esi
  41408a:	48 89 fb             	mov    %rdi,%rbx
  41408d:	e8 be 14 01 00       	callq  425550 <p111_rt_reg_get>
  414092:	4c 89 e6             	mov    %r12,%rsi
  414095:	48 89 df             	mov    %rbx,%rdi
  414098:	48 89 c2             	mov    %rax,%rdx
  41409b:	48 89 fb             	mov    %rdi,%rbx
  41409e:	e8 9d 3c ff ff       	callq  407d40 <p113d_FID_36_100_105_114_101_99_116_46_105_110_100_101_120_95_98_117_99_107_101_116_>
  4140a3:	48 89 df             	mov    %rbx,%rdi
  4140a6:	48 89 45 f8          	mov    %rax,-0x8(%rbp)
  4140aa:	ba 01 00 00 00       	mov    $0x1,%edx
  4140af:	48 8d 75 f8          	lea    -0x8(%rbp),%rsi
  4140b3:	e8 48 13 01 00       	callq  425400 <p111_rt_return>
  4140b8:	41 5c                	pop    %r12
  4140ba:	5b                   	pop    %rbx
  4140bb:	c9                   	leaveq 
  4140bc:	c3                   	retq   

Disassembly of section .fini:
