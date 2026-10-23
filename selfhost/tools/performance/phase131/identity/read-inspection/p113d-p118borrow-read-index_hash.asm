
/home/ai/bend2/build/publish/bend/selfhost/build/phase111/p130-native01-n1/program:     file format elf64-x86-64


Disassembly of section .init:

Disassembly of section .plt:

Disassembly of section .text:

0000000000406500 <p113d_FID_36_112_49_49_56_98_111_114_114_111_119_46_114_101_97_100_46_105_110_100_101_120_95_104_97_115_104_>:
  406500:	f3 0f 1e fa          	endbr64 
  406504:	55                   	push   %rbp
  406505:	48 89 e5             	mov    %rsp,%rbp
  406508:	48 81 ec 00 08 00 00 	sub    $0x800,%rsp
  40650f:	53                   	push   %rbx
  406510:	41 54                	push   %r12
  406512:	48 89 d0             	mov    %rdx,%rax
  406515:	48 89 c2             	mov    %rax,%rdx
  406518:	0f 1f 84 00 00 00 00 	nopl   0x0(%rax,%rax,1)
  40651f:	00 
  406520:	48 89 f0             	mov    %rsi,%rax
  406523:	48 c1 e8 28          	shr    $0x28,%rax
  406527:	48 25 ff ff 00 00    	and    $0xffff,%rax
  40652d:	48 83 f8 18          	cmp    $0x18,%rax
  406531:	0f 84 d7 00 00 00    	je     40660e <p113d_FID_36_112_49_49_56_98_111_114_114_111_119_46_114_101_97_100_46_105_110_100_101_120_95_104_97_115_104_+0x10e>
  406537:	48 83 f8 19          	cmp    $0x19,%rax
  40653b:	0f 94 c1             	sete   %cl
  40653e:	0f b6 c9             	movzbl %cl,%ecx
  406541:	0f 85 b6 00 00 00    	jne    4065fd <p113d_FID_36_112_49_49_56_98_111_114_114_111_119_46_114_101_97_100_46_105_110_100_101_120_95_104_97_115_104_+0xfd>
  406547:	2e 2e 2e 2e 48 89 f0 	cs cs cs cs mov %rsi,%rax
  40654e:	48 c1 e8 38          	shr    $0x38,%rax
  406552:	48 83 e0 7f          	and    $0x7f,%rax
  406556:	48 83 f8 02          	cmp    $0x2,%rax
  40655a:	0f 94 c0             	sete   %al
  40655d:	0f b6 c0             	movzbl %al,%eax
  406560:	85 c1                	test   %eax,%ecx
  406562:	75 25                	jne    406589 <p113d_FID_36_112_49_49_56_98_111_114_114_111_119_46_114_101_97_100_46_105_110_100_101_120_95_104_97_115_104_+0x89>
  406564:	41 b8 02 00 00 00    	mov    $0x2,%r8d
  40656a:	b9 19 00 00 00       	mov    $0x19,%ecx
  40656f:	49 89 d4             	mov    %rdx,%r12
  406572:	48 8d 95 00 f8 ff ff 	lea    -0x800(%rbp),%rdx
  406579:	48 89 fb             	mov    %rdi,%rbx
  40657c:	e8 ef 56 9e 00       	callq  debc70 <p118_rt_borrow_fields>
  406581:	4c 89 e2             	mov    %r12,%rdx
  406584:	48 89 df             	mov    %rbx,%rdi
  406587:	eb 51                	jmp    4065da <p113d_FID_36_112_49_49_56_98_111_114_114_111_119_46_114_101_97_100_46_105_110_100_101_120_95_104_97_115_104_+0xda>
  406589:	2e 2e 2e 48 8b 0f    	cs cs mov %cs:(%rdi),%rcx
  40658f:	48 b8 ff ff ff ff ff 	movabs $0xffffffffff,%rax
  406596:	00 00 00 
  406599:	48 21 f0             	and    %rsi,%rax
  40659c:	48 c1 ee 3f          	shr    $0x3f,%rsi
  4065a0:	48 83 fe 00          	cmp    $0x0,%rsi
  4065a4:	74 19                	je     4065bf <p113d_FID_36_112_49_49_56_98_111_114_114_111_119_46_114_101_97_100_46_105_110_100_101_120_95_104_97_115_104_+0xbf>
  4065a6:	48 89 c6             	mov    %rax,%rsi
  4065a9:	48 c1 e6 03          	shl    $0x3,%rsi
  4065ad:	8b 04 0e             	mov    (%rsi,%rcx,1),%eax
  4065b0:	8b 74 0e 04          	mov    0x4(%rsi,%rcx,1),%esi
  4065b4:	48 c1 e6 20          	shl    $0x20,%rsi
  4065b8:	48 09 f0             	or     %rsi,%rax
  4065bb:	48 c1 e8 18          	shr    $0x18,%rax
  4065bf:	48 c1 e0 03          	shl    $0x3,%rax
  4065c3:	48 8b 34 08          	mov    (%rax,%rcx,1),%rsi
  4065c7:	48 89 b5 00 f8 ff ff 	mov    %rsi,-0x800(%rbp)
  4065ce:	48 8b 44 08 08       	mov    0x8(%rax,%rcx,1),%rax
  4065d3:	48 89 85 08 f8 ff ff 	mov    %rax,-0x7f8(%rbp)
  4065da:	48 8b 8d 00 f8 ff ff 	mov    -0x800(%rbp),%rcx
  4065e1:	48 8b b5 08 f8 ff ff 	mov    -0x7f8(%rbp),%rsi
  4065e8:	89 d0                	mov    %edx,%eax
  4065ea:	89 c9                	mov    %ecx,%ecx
  4065ec:	31 c8                	xor    %ecx,%eax
  4065ee:	89 c0                	mov    %eax,%eax
  4065f0:	69 c0 93 01 00 01    	imul   $0x1000193,%eax,%eax
  4065f6:	89 c2                	mov    %eax,%edx
  4065f8:	e9 23 ff ff ff       	jmpq   406520 <p113d_FID_36_112_49_49_56_98_111_114_114_111_119_46_114_101_97_100_46_105_110_100_101_120_95_104_97_115_104_+0x20>
  4065fd:	be 04 00 00 00       	mov    $0x4,%esi
  406602:	e8 c9 13 9e 00       	callq  de79d0 <p111_rt_fail>
  406607:	b8 00 00 00 00       	mov    $0x0,%eax
  40660c:	eb 03                	jmp    406611 <p113d_FID_36_112_49_49_56_98_111_114_114_111_119_46_114_101_97_100_46_105_110_100_101_120_95_104_97_115_104_+0x111>
  40660e:	48 89 d0             	mov    %rdx,%rax
  406611:	41 5c                	pop    %r12
  406613:	5b                   	pop    %rbx
  406614:	c9                   	leaveq 
  406615:	c3                   	retq   

Disassembly of section .fini:
