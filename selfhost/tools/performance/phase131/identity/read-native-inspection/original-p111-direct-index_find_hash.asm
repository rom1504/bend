
/home/ai/bend2/build/publish/bend/selfhost/build/phase111/p131-read-lookup01-identity-original-build/program:     file format elf64-x86-64


Disassembly of section .init:

Disassembly of section .plt:

Disassembly of section .text:

0000000000413560 <p111_FID_36_100_105_114_101_99_116_46_105_110_100_101_120_95_102_105_110_100_95_104_97_115_104_>:
  413560:	f3 0f 1e fa          	endbr64 
  413564:	55                   	push   %rbp
  413565:	48 89 e5             	mov    %rsp,%rbp
  413568:	48 83 ec 18          	sub    $0x18,%rsp
  41356c:	53                   	push   %rbx
  41356d:	41 54                	push   %r12
  41356f:	41 55                	push   %r13
  413571:	be 00 00 00 00       	mov    $0x0,%esi
  413576:	48 89 fb             	mov    %rdi,%rbx
  413579:	e8 b2 1f 01 00       	callq  425530 <p111_rt_reg_get>
  41357e:	48 89 df             	mov    %rbx,%rdi
  413581:	48 89 c6             	mov    %rax,%rsi
  413584:	49 89 f4             	mov    %rsi,%r12
  413587:	be 01 00 00 00       	mov    $0x1,%esi
  41358c:	48 89 fb             	mov    %rdi,%rbx
  41358f:	e8 9c 1f 01 00       	callq  425530 <p111_rt_reg_get>
  413594:	4c 89 e6             	mov    %r12,%rsi
  413597:	48 89 df             	mov    %rbx,%rdi
  41359a:	49 89 c5             	mov    %rax,%r13
  41359d:	49 89 f4             	mov    %rsi,%r12
  4135a0:	be 02 00 00 00       	mov    $0x2,%esi
  4135a5:	48 89 fb             	mov    %rdi,%rbx
  4135a8:	e8 83 1f 01 00       	callq  425530 <p111_rt_reg_get>
  4135ad:	4c 89 ea             	mov    %r13,%rdx
  4135b0:	4c 89 e6             	mov    %r12,%rsi
  4135b3:	48 89 df             	mov    %rbx,%rdi
  4135b6:	48 89 c1             	mov    %rax,%rcx
  4135b9:	48 89 fb             	mov    %rdi,%rbx
  4135bc:	e8 2f 4d ff ff       	callq  4082f0 <p113d_FID_36_100_105_114_101_99_116_46_105_110_100_101_120_95_102_105_110_100_95_104_97_115_104_>
  4135c1:	48 89 df             	mov    %rbx,%rdi
  4135c4:	48 89 45 f8          	mov    %rax,-0x8(%rbp)
  4135c8:	ba 01 00 00 00       	mov    $0x1,%edx
  4135cd:	48 8d 75 f8          	lea    -0x8(%rbp),%rsi
  4135d1:	e8 0a 1e 01 00       	callq  4253e0 <p111_rt_return>
  4135d6:	41 5d                	pop    %r13
  4135d8:	41 5c                	pop    %r12
  4135da:	5b                   	pop    %rbx
  4135db:	c9                   	leaveq 
  4135dc:	c3                   	retq   

Disassembly of section .fini:
