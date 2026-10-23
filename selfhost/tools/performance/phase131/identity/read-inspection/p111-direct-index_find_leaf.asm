
/home/ai/bend2/build/publish/bend/selfhost/build/phase111/p130-native01-n1/program:     file format elf64-x86-64


Disassembly of section .init:

Disassembly of section .plt:

Disassembly of section .text:

0000000000dc6640 <p111_FID_36_100_105_114_101_99_116_46_105_110_100_101_120_95_102_105_110_100_95_108_101_97_102_>:
  dc6640:	f3 0f 1e fa          	endbr64 
  dc6644:	55                   	push   %rbp
  dc6645:	48 89 e5             	mov    %rsp,%rbp
  dc6648:	48 81 ec 00 18 00 00 	sub    $0x1800,%rsp
  dc664f:	53                   	push   %rbx
  dc6650:	41 54                	push   %r12
  dc6652:	41 55                	push   %r13
  dc6654:	41 56                	push   %r14
  dc6656:	48 8b 77 28          	mov    0x28(%rdi),%rsi
  dc665a:	4c 8b 67 30          	mov    0x30(%rdi),%r12
  dc665e:	48 8b 57 38          	mov    0x38(%rdi),%rdx
  dc6662:	48 8b 4f 40          	mov    0x40(%rdi),%rcx
  dc6666:	48 8b 5f 48          	mov    0x48(%rdi),%rbx
  dc666a:	48 83 fb 01          	cmp    $0x1,%rbx
  dc666e:	0f 94 c0             	sete   %al
  dc6671:	0f b6 c0             	movzbl %al,%eax
  dc6674:	49 89 d8             	mov    %rbx,%r8
  dc6677:	49 c1 e8 28          	shr    $0x28,%r8
  dc667b:	49 81 e0 ff ff 7f 00 	and    $0x7fffff,%r8
  dc6682:	49 81 f8 02 00 01 00 	cmp    $0x10002,%r8
  dc6689:	41 0f 94 c0          	sete   %r8b
  dc668d:	45 0f b6 c0          	movzbl %r8b,%r8d
  dc6691:	44 09 c0             	or     %r8d,%eax
  dc6694:	41 b8 ff ff ff ff    	mov    $0xffffffff,%r8d
  dc669a:	49 89 d5             	mov    %rdx,%r13
  dc669d:	4d 21 c5             	and    %r8,%r13
  dc66a0:	83 f8 00             	cmp    $0x0,%eax
  dc66a3:	0f 85 f9 00 00 00    	jne    dc67a2 <p111_FID_36_100_105_114_101_99_116_46_105_110_100_101_120_95_102_105_110_100_95_108_101_97_102_+0x162>
  dc66a9:	83 f0 01             	xor    $0x1,%eax
  dc66ac:	83 f8 00             	cmp    $0x0,%eax
  dc66af:	75 46                	jne    dc66f7 <p111_FID_36_100_105_114_101_99_116_46_105_110_100_101_120_95_102_105_110_100_95_108_101_97_102_+0xb7>
  dc66b1:	49 89 fd             	mov    %rdi,%r13
  dc66b4:	e8 87 0b 02 00       	callq  de7240 <p111_rt_sink>
  dc66b9:	4c 89 ef             	mov    %r13,%rdi
  dc66bc:	4c 89 e6             	mov    %r12,%rsi
  dc66bf:	49 89 fc             	mov    %rdi,%r12
  dc66c2:	e8 79 0b 02 00       	callq  de7240 <p111_rt_sink>
  dc66c7:	4c 89 e7             	mov    %r12,%rdi
  dc66ca:	48 89 9d 00 e8 ff ff 	mov    %rbx,-0x1800(%rbp)
  dc66d1:	48 8b 47 10          	mov    0x10(%rdi),%rax
  dc66d5:	48 89 18             	mov    %rbx,(%rax)
  dc66d8:	48 c7 40 08 72 b9 00 	movq   $0xb972,0x8(%rax)
  dc66df:	00 
  dc66e0:	48 83 c0 10          	add    $0x10,%rax
  dc66e4:	48 89 47 10          	mov    %rax,0x10(%rdi)
  dc66e8:	be 04 00 00 00       	mov    $0x4,%esi
  dc66ed:	e8 de 12 02 00       	callq  de79d0 <p111_rt_fail>
  dc66f2:	e9 06 01 00 00       	jmpq   dc67fd <p111_FID_36_100_105_114_101_99_116_46_105_110_100_101_120_95_102_105_110_100_95_108_101_97_102_+0x1bd>
  dc66f7:	2e 4c 89 eb          	cs mov %r13,%rbx
  dc66fb:	4c 89 a5 00 e8 ff ff 	mov    %r12,-0x1800(%rbp)
  dc6702:	48 89 95 08 e8 ff ff 	mov    %rdx,-0x17f8(%rbp)
  dc6709:	48 89 8d 10 e8 ff ff 	mov    %rcx,-0x17f0(%rbp)
  dc6710:	48 8b 47 10          	mov    0x10(%rdi),%rax
  dc6714:	4c 89 20             	mov    %r12,(%rax)
  dc6717:	48 89 50 08          	mov    %rdx,0x8(%rax)
  dc671b:	48 89 48 10          	mov    %rcx,0x10(%rax)
  dc671f:	48 c7 40 18 6f b9 00 	movq   $0xb96f,0x18(%rax)
  dc6726:	00 
  dc6727:	48 83 c0 20          	add    $0x20,%rax
  dc672b:	48 89 47 10          	mov    %rax,0x10(%rdi)
  dc672f:	49 89 fc             	mov    %rdi,%r12
  dc6732:	e8 79 0a 02 00       	callq  de71b0 <p111_rt_keep>
  dc6737:	4c 89 e7             	mov    %r12,%rdi
  dc673a:	48 89 c6             	mov    %rax,%rsi
  dc673d:	48 89 b5 00 e8 ff ff 	mov    %rsi,-0x1800(%rbp)
  dc6744:	48 8b 47 10          	mov    0x10(%rdi),%rax
  dc6748:	48 89 30             	mov    %rsi,(%rax)
  dc674b:	48 c7 40 08 70 b9 00 	movq   $0xb970,0x8(%rax)
  dc6752:	00 
  dc6753:	48 83 c0 10          	add    $0x10,%rax
  dc6757:	48 89 47 10          	mov    %rax,0x10(%rdi)
  dc675b:	49 89 fc             	mov    %rdi,%r12
  dc675e:	e8 5d bc 7f ff       	callq  5c23c0 <p112w_FID_36_100_105_114_101_99_116_46_100_120_>
  dc6763:	4c 89 e7             	mov    %r12,%rdi
  dc6766:	b9 ff ff ff ff       	mov    $0xffffffff,%ecx
  dc676b:	48 21 c8             	and    %rcx,%rax
  dc676e:	48 21 d8             	and    %rbx,%rax
  dc6771:	b9 ff ff ff ff       	mov    $0xffffffff,%ecx
  dc6776:	48 21 c8             	and    %rcx,%rax
  dc6779:	48 83 f8 00          	cmp    $0x0,%rax
  dc677d:	0f 94 c0             	sete   %al
  dc6780:	0f b6 c0             	movzbl %al,%eax
  dc6783:	48 89 85 00 f8 ff ff 	mov    %rax,-0x800(%rbp)
  dc678a:	b9 01 00 00 00       	mov    $0x1,%ecx
  dc678f:	48 8d 95 00 f8 ff ff 	lea    -0x800(%rbp),%rdx
  dc6796:	be 07 bb 00 00       	mov    $0xbb07,%esi
  dc679b:	e8 60 10 02 00       	callq  de7800 <p111_rt_jump>
  dc67a0:	eb 5b                	jmp    dc67fd <p111_FID_36_100_105_114_101_99_116_46_105_110_100_101_120_95_102_105_110_100_95_108_101_97_102_+0x1bd>
  dc67a2:	4c 89 eb             	mov    %r13,%rbx
  dc67a5:	49 89 fd             	mov    %rdi,%r13
  dc67a8:	e8 03 0a 02 00       	callq  de71b0 <p111_rt_keep>
  dc67ad:	4c 89 ef             	mov    %r13,%rdi
  dc67b0:	49 89 c5             	mov    %rax,%r13
  dc67b3:	4c 89 ee             	mov    %r13,%rsi
  dc67b6:	49 89 fe             	mov    %rdi,%r14
  dc67b9:	e8 32 b8 7f ff       	callq  5c1ff0 <p112w_FID_36_100_105_114_101_99_116_46_100_97_>
  dc67be:	4c 89 f7             	mov    %r14,%rdi
  dc67c1:	4c 89 ad 00 f0 ff ff 	mov    %r13,-0x1000(%rbp)
  dc67c8:	4c 89 a5 08 f0 ff ff 	mov    %r12,-0xff8(%rbp)
  dc67cf:	b9 ff ff ff ff       	mov    $0xffffffff,%ecx
  dc67d4:	48 21 c8             	and    %rcx,%rax
  dc67d7:	48 39 d8             	cmp    %rbx,%rax
  dc67da:	0f 94 c0             	sete   %al
  dc67dd:	0f b6 c0             	movzbl %al,%eax
  dc67e0:	48 89 85 10 f0 ff ff 	mov    %rax,-0xff0(%rbp)
  dc67e7:	b9 03 00 00 00       	mov    $0x3,%ecx
  dc67ec:	48 8d 95 00 f0 ff ff 	lea    -0x1000(%rbp),%rdx
  dc67f3:	be 64 b9 00 00       	mov    $0xb964,%esi
  dc67f8:	e8 03 10 02 00       	callq  de7800 <p111_rt_jump>
  dc67fd:	41 5e                	pop    %r14
  dc67ff:	41 5d                	pop    %r13
  dc6801:	41 5c                	pop    %r12
  dc6803:	5b                   	pop    %rbx
  dc6804:	c9                   	leaveq 
  dc6805:	c3                   	retq   

Disassembly of section .fini:
