
/home/ai/bend2/build/publish/bend/selfhost/build/phase111/p130-native01-n1/program:     file format elf64-x86-64


Disassembly of section .init:

Disassembly of section .plt:

Disassembly of section .text:

0000000000406620 <p113d_FID_36_100_105_114_101_99_116_46_105_110_100_101_120_95_104_97_115_104_>:
  406620:	f3 0f 1e fa          	endbr64 
  406624:	55                   	push   %rbp
  406625:	48 89 e5             	mov    %rsp,%rbp
  406628:	48 83 ec 08          	sub    $0x8,%rsp
  40662c:	53                   	push   %rbx
  40662d:	41 54                	push   %r12
  40662f:	41 55                	push   %r13
  406631:	b9 01 00 00 00       	mov    $0x1,%ecx
  406636:	49 89 d5             	mov    %rdx,%r13
  406639:	ba 00 00 00 00       	mov    $0x0,%edx
  40663e:	49 89 f4             	mov    %rsi,%r12
  406641:	48 89 fb             	mov    %rdi,%rbx
  406644:	e8 57 6a 9e 00       	callq  ded0a0 <p118_rt_borrow_scalar_safe>
  406649:	4c 89 ea             	mov    %r13,%rdx
  40664c:	4c 89 e6             	mov    %r12,%rsi
  40664f:	48 89 df             	mov    %rbx,%rdi
  406652:	48 83 f8 00          	cmp    $0x0,%rax
  406656:	75 07                	jne    40665f <p113d_FID_36_100_105_114_101_99_116_46_105_110_100_101_120_95_104_97_115_104_+0x3f>
  406658:	e8 e3 fd ff ff       	callq  406440 <p113d_FID_36_112_49_50_56_98_111_114_114_111_119_46_111_119_110_101_100_46_105_110_100_101_120_95_104_97_115_104_>
  40665d:	eb 1c                	jmp    40667b <p113d_FID_36_100_105_114_101_99_116_46_105_110_100_101_120_95_104_97_115_104_+0x5b>
  40665f:	49 89 f4             	mov    %rsi,%r12
  406662:	48 89 fb             	mov    %rdi,%rbx
  406665:	e8 96 fe ff ff       	callq  406500 <p113d_FID_36_112_49_49_56_98_111_114_114_111_119_46_114_101_97_100_46_105_110_100_101_120_95_104_97_115_104_>
  40666a:	4c 89 e6             	mov    %r12,%rsi
  40666d:	48 89 df             	mov    %rbx,%rdi
  406670:	48 89 c3             	mov    %rax,%rbx
  406673:	e8 c8 0b 9e 00       	callq  de7240 <p111_rt_sink>
  406678:	48 89 d8             	mov    %rbx,%rax
  40667b:	41 5d                	pop    %r13
  40667d:	41 5c                	pop    %r12
  40667f:	5b                   	pop    %rbx
  406680:	c9                   	leaveq 
  406681:	c3                   	retq   

Disassembly of section .fini:
