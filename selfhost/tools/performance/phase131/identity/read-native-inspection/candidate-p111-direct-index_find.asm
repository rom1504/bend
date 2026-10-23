
/home/ai/bend2/build/publish/bend/selfhost/build/phase111/p131-read-lookup01-identity-candidate-build/program:     file format elf64-x86-64


Disassembly of section .init:

Disassembly of section .plt:

Disassembly of section .text:

0000000000414530 <p111_FID_36_100_105_114_101_99_116_46_105_110_100_101_120_95_102_105_110_100_>:
  414530:	f3 0f 1e fa          	endbr64 
  414534:	55                   	push   %rbp
  414535:	48 89 e5             	mov    %rsp,%rbp
  414538:	48 83 ec 10          	sub    $0x10,%rsp
  41453c:	53                   	push   %rbx
  41453d:	41 54                	push   %r12
  41453f:	41 55                	push   %r13
  414541:	41 56                	push   %r14
  414543:	be 00 00 00 00       	mov    $0x0,%esi
  414548:	48 89 fb             	mov    %rdi,%rbx
  41454b:	e8 00 10 01 00       	callq  425550 <p111_rt_reg_get>
  414550:	48 89 df             	mov    %rbx,%rdi
  414553:	48 89 c6             	mov    %rax,%rsi
  414556:	49 89 f4             	mov    %rsi,%r12
  414559:	be 01 00 00 00       	mov    $0x1,%esi
  41455e:	48 89 fb             	mov    %rdi,%rbx
  414561:	e8 ea 0f 01 00       	callq  425550 <p111_rt_reg_get>
  414566:	4c 89 e6             	mov    %r12,%rsi
  414569:	48 89 df             	mov    %rbx,%rdi
  41456c:	49 89 c5             	mov    %rax,%r13
  41456f:	49 89 f4             	mov    %rsi,%r12
  414572:	be 02 00 00 00       	mov    $0x2,%esi
  414577:	48 89 fb             	mov    %rdi,%rbx
  41457a:	e8 d1 0f 01 00       	callq  425550 <p111_rt_reg_get>
  41457f:	4c 89 e6             	mov    %r12,%rsi
  414582:	48 89 df             	mov    %rbx,%rdi
  414585:	49 89 c6             	mov    %rax,%r14
  414588:	49 89 f4             	mov    %rsi,%r12
  41458b:	be 03 00 00 00       	mov    $0x3,%esi
  414590:	48 89 fb             	mov    %rdi,%rbx
  414593:	e8 b8 0f 01 00       	callq  425550 <p111_rt_reg_get>
  414598:	4c 89 f1             	mov    %r14,%rcx
  41459b:	4c 89 ea             	mov    %r13,%rdx
  41459e:	4c 89 e6             	mov    %r12,%rsi
  4145a1:	48 89 df             	mov    %rbx,%rdi
  4145a4:	49 89 c0             	mov    %rax,%r8
  4145a7:	48 89 fb             	mov    %rdi,%rbx
  4145aa:	e8 d1 50 ff ff       	callq  409680 <p113d_FID_36_100_105_114_101_99_116_46_105_110_100_101_120_95_102_105_110_100_>
  4145af:	48 89 df             	mov    %rbx,%rdi
  4145b2:	48 89 45 f8          	mov    %rax,-0x8(%rbp)
  4145b6:	ba 01 00 00 00       	mov    $0x1,%edx
  4145bb:	48 8d 75 f8          	lea    -0x8(%rbp),%rsi
  4145bf:	e8 3c 0e 01 00       	callq  425400 <p111_rt_return>
  4145c4:	41 5e                	pop    %r14
  4145c6:	41 5d                	pop    %r13
  4145c8:	41 5c                	pop    %r12
  4145ca:	5b                   	pop    %rbx
  4145cb:	c9                   	leaveq 
  4145cc:	c3                   	retq   

Disassembly of section .fini:
