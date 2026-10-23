
/home/ai/bend2/build/publish/bend/selfhost/build/phase111/p130-native01-n1/program:     file format elf64-x86-64


Disassembly of section .init:

Disassembly of section .plt:

Disassembly of section .text:

000000000049a580 <p113d_FID_36_100_105_114_101_99_116_46_105_110_100_101_120_95_98_117_99_107_101_116_>:
  49a580:	f3 0f 1e fa          	endbr64 
  49a584:	55                   	push   %rbp
  49a585:	48 89 e5             	mov    %rsp,%rbp
  49a588:	48 81 ec 58 09 00 00 	sub    $0x958,%rsp
  49a58f:	53                   	push   %rbx
  49a590:	41 54                	push   %r12
  49a592:	41 55                	push   %r13
  49a594:	41 56                	push   %r14
  49a596:	41 57                	push   %r15
  49a598:	48 89 d3             	mov    %rdx,%rbx
  49a59b:	48 89 da             	mov    %rbx,%rdx
  49a59e:	66 90                	xchg   %ax,%ax
  49a5a0:	48 89 f0             	mov    %rsi,%rax
  49a5a3:	48 c1 e8 28          	shr    $0x28,%rax
  49a5a7:	48 25 ff ff 00 00    	and    $0xffff,%rax
  49a5ad:	48 83 f8 11          	cmp    $0x11,%rax
  49a5b1:	0f 84 b7 03 00 00    	je     49a96e <p113d_FID_36_100_105_114_101_99_116_46_105_110_100_101_120_95_98_117_99_107_101_116_+0x3ee>
  49a5b7:	66 0f 1f 84 00 00 00 	nopw   0x0(%rax,%rax,1)
  49a5be:	00 00 
  49a5c0:	48 83 f8 12          	cmp    $0x12,%rax
  49a5c4:	0f 85 90 03 00 00    	jne    49a95a <p113d_FID_36_100_105_114_101_99_116_46_105_110_100_101_120_95_98_117_99_107_101_116_+0x3da>
  49a5ca:	49 89 d4             	mov    %rdx,%r12
  49a5cd:	48 8d 95 b0 f6 ff ff 	lea    -0x950(%rbp),%rdx
  49a5d4:	48 89 fb             	mov    %rdi,%rbx
  49a5d7:	e8 14 24 95 00       	callq  dec9f0 <p125_rt_take2>
  49a5dc:	4c 89 e2             	mov    %r12,%rdx
  49a5df:	48 89 df             	mov    %rbx,%rdi
  49a5e2:	48 8b b5 b0 f6 ff ff 	mov    -0x950(%rbp),%rsi
  49a5e9:	4c 8b ad b8 f6 ff ff 	mov    -0x948(%rbp),%r13
  49a5f0:	4c 89 6d c0          	mov    %r13,-0x40(%rbp)
  49a5f4:	49 89 f4             	mov    %rsi,%r12
  49a5f7:	48 89 d6             	mov    %rdx,%rsi
  49a5fa:	48 89 fb             	mov    %rdi,%rbx
  49a5fd:	e8 ae cb 94 00       	callq  de71b0 <p111_rt_keep>
  49a602:	4c 89 e6             	mov    %r12,%rsi
  49a605:	48 89 df             	mov    %rbx,%rdi
  49a608:	49 89 c5             	mov    %rax,%r13
  49a60b:	48 89 fb             	mov    %rdi,%rbx
  49a60e:	e8 9d cb 94 00       	callq  de71b0 <p111_rt_keep>
  49a613:	48 89 df             	mov    %rbx,%rdi
  49a616:	48 89 c6             	mov    %rax,%rsi
  49a619:	48 89 f0             	mov    %rsi,%rax
  49a61c:	48 c1 e8 28          	shr    $0x28,%rax
  49a620:	48 25 ff ff 00 00    	and    $0xffff,%rax
  49a626:	48 3d 99 00 00 00    	cmp    $0x99,%rax
  49a62c:	0f 84 d3 00 00 00    	je     49a705 <p113d_FID_36_100_105_114_101_99_116_46_105_110_100_101_120_95_98_117_99_107_101_116_+0x185>
  49a632:	48 3d 9a 00 00 00    	cmp    $0x9a,%rax
  49a638:	0f 84 7e 00 00 00    	je     49a6bc <p113d_FID_36_100_105_114_101_99_116_46_105_110_100_101_120_95_98_117_99_107_101_116_+0x13c>
  49a63e:	66 90                	xchg   %ax,%ax
  49a640:	48 3d 9b 00 00 00    	cmp    $0x9b,%rax
  49a646:	74 20                	je     49a668 <p113d_FID_36_100_105_114_101_99_116_46_105_110_100_101_120_95_98_117_99_107_101_116_+0xe8>
  49a648:	49 89 f4             	mov    %rsi,%r12
  49a64b:	be 04 00 00 00       	mov    $0x4,%esi
  49a650:	48 89 fb             	mov    %rdi,%rbx
  49a653:	e8 78 d3 94 00       	callq  de79d0 <p111_rt_fail>
  49a658:	4c 89 ea             	mov    %r13,%rdx
  49a65b:	48 89 df             	mov    %rbx,%rdi
  49a65e:	4c 89 e6             	mov    %r12,%rsi
  49a661:	bb 00 00 00 00       	mov    $0x0,%ebx
  49a666:	eb 4f                	jmp    49a6b7 <p113d_FID_36_100_105_114_101_99_116_46_105_110_100_101_120_95_98_117_99_107_101_116_+0x137>
  49a668:	49 89 f4             	mov    %rsi,%r12
  49a66b:	4c 89 ea             	mov    %r13,%rdx
  49a66e:	49 89 d5             	mov    %rdx,%r13
  49a671:	48 8d 95 78 ff ff ff 	lea    -0x88(%rbp),%rdx
  49a678:	4c 89 e6             	mov    %r12,%rsi
  49a67b:	48 89 fb             	mov    %rdi,%rbx
  49a67e:	e8 3d 28 95 00       	callq  decec0 <p125_rt_take4>
  49a683:	48 89 df             	mov    %rbx,%rdi
  49a686:	48 8b 75 88          	mov    -0x78(%rbp),%rsi
  49a68a:	4c 8b 75 90          	mov    -0x70(%rbp),%r14
  49a68e:	48 89 fb             	mov    %rdi,%rbx
  49a691:	e8 aa cb 94 00       	callq  de7240 <p111_rt_sink>
  49a696:	4c 89 f6             	mov    %r14,%rsi
  49a699:	48 89 df             	mov    %rbx,%rdi
  49a69c:	48 89 fb             	mov    %rdi,%rbx
  49a69f:	e8 9c cb 94 00       	callq  de7240 <p111_rt_sink>
  49a6a4:	4c 89 ea             	mov    %r13,%rdx
  49a6a7:	4c 89 e6             	mov    %r12,%rsi
  49a6aa:	48 89 df             	mov    %rbx,%rdi
  49a6ad:	48 bb 00 00 00 00 00 	movabs $0x100180000000000,%rbx
  49a6b4:	18 00 01 
  49a6b7:	49 89 f7             	mov    %rsi,%r15
  49a6ba:	eb 3e                	jmp    49a6fa <p113d_FID_36_100_105_114_101_99_116_46_105_110_100_101_120_95_98_117_99_107_101_116_+0x17a>
  49a6bc:	2e 4c 89 ea          	cs mov %r13,%rdx
  49a6c0:	49 89 d4             	mov    %rdx,%r12
  49a6c3:	48 8d 95 78 ff ff ff 	lea    -0x88(%rbp),%rdx
  49a6ca:	49 89 f5             	mov    %rsi,%r13
  49a6cd:	48 89 fb             	mov    %rdi,%rbx
  49a6d0:	e8 1b 23 95 00       	callq  dec9f0 <p125_rt_take2>
  49a6d5:	4c 89 ee             	mov    %r13,%rsi
  49a6d8:	48 89 df             	mov    %rbx,%rdi
  49a6db:	49 89 f7             	mov    %rsi,%r15
  49a6de:	48 8b 75 80          	mov    -0x80(%rbp),%rsi
  49a6e2:	48 89 fb             	mov    %rdi,%rbx
  49a6e5:	e8 56 cb 94 00       	callq  de7240 <p111_rt_sink>
  49a6ea:	4c 89 e2             	mov    %r12,%rdx
  49a6ed:	48 89 df             	mov    %rbx,%rdi
  49a6f0:	48 bb 00 00 00 00 00 	movabs $0x100180000000000,%rbx
  49a6f7:	18 00 01 
  49a6fa:	48 89 de             	mov    %rbx,%rsi
  49a6fd:	49 89 d5             	mov    %rdx,%r13
  49a700:	e9 eb 00 00 00       	jmpq   49a7f0 <p113d_FID_36_100_105_114_101_99_116_46_105_110_100_101_120_95_98_117_99_107_101_116_+0x270>
  49a705:	2e 49 89 f7          	cs mov %rsi,%r15
  49a709:	4c 89 ea             	mov    %r13,%rdx
  49a70c:	b9 09 00 00 00       	mov    $0x9,%ecx
  49a711:	49 89 d5             	mov    %rdx,%r13
  49a714:	48 8d 95 78 ff ff ff 	lea    -0x88(%rbp),%rdx
  49a71b:	4c 89 fe             	mov    %r15,%rsi
  49a71e:	48 89 fb             	mov    %rdi,%rbx
  49a721:	e8 0a cd 94 00       	callq  de7430 <p111_rt_take>
  49a726:	48 89 df             	mov    %rbx,%rdi
  49a729:	4c 8b a5 78 ff ff ff 	mov    -0x88(%rbp),%r12
  49a730:	48 8b 75 80          	mov    -0x80(%rbp),%rsi
  49a734:	4c 8b 75 88          	mov    -0x78(%rbp),%r14
  49a738:	48 8b 5d 90          	mov    -0x70(%rbp),%rbx
  49a73c:	48 89 5d f0          	mov    %rbx,-0x10(%rbp)
  49a740:	48 8b 5d 98          	mov    -0x68(%rbp),%rbx
  49a744:	48 89 5d e8          	mov    %rbx,-0x18(%rbp)
  49a748:	48 8b 5d a0          	mov    -0x60(%rbp),%rbx
  49a74c:	48 89 5d e0          	mov    %rbx,-0x20(%rbp)
  49a750:	48 8b 5d a8          	mov    -0x58(%rbp),%rbx
  49a754:	48 89 5d d8          	mov    %rbx,-0x28(%rbp)
  49a758:	48 8b 5d b0          	mov    -0x50(%rbp),%rbx
  49a75c:	48 89 5d d0          	mov    %rbx,-0x30(%rbp)
  49a760:	48 8b 5d b8          	mov    -0x48(%rbp),%rbx
  49a764:	48 89 5d c8          	mov    %rbx,-0x38(%rbp)
  49a768:	48 89 fb             	mov    %rdi,%rbx
  49a76b:	e8 d0 ca 94 00       	callq  de7240 <p111_rt_sink>
  49a770:	4c 89 f6             	mov    %r14,%rsi
  49a773:	48 89 df             	mov    %rbx,%rdi
  49a776:	4c 8b 75 f0          	mov    -0x10(%rbp),%r14
  49a77a:	48 89 fb             	mov    %rdi,%rbx
  49a77d:	e8 be ca 94 00       	callq  de7240 <p111_rt_sink>
  49a782:	4c 89 f6             	mov    %r14,%rsi
  49a785:	48 89 df             	mov    %rbx,%rdi
  49a788:	4c 8b 75 e8          	mov    -0x18(%rbp),%r14
  49a78c:	48 89 fb             	mov    %rdi,%rbx
  49a78f:	e8 ac ca 94 00       	callq  de7240 <p111_rt_sink>
  49a794:	4c 89 f6             	mov    %r14,%rsi
  49a797:	48 89 df             	mov    %rbx,%rdi
  49a79a:	4c 8b 75 e0          	mov    -0x20(%rbp),%r14
  49a79e:	48 89 fb             	mov    %rdi,%rbx
  49a7a1:	e8 9a ca 94 00       	callq  de7240 <p111_rt_sink>
  49a7a6:	4c 89 f6             	mov    %r14,%rsi
  49a7a9:	48 89 df             	mov    %rbx,%rdi
  49a7ac:	4c 8b 75 d8          	mov    -0x28(%rbp),%r14
  49a7b0:	48 89 fb             	mov    %rdi,%rbx
  49a7b3:	e8 88 ca 94 00       	callq  de7240 <p111_rt_sink>
  49a7b8:	4c 89 f6             	mov    %r14,%rsi
  49a7bb:	48 89 df             	mov    %rbx,%rdi
  49a7be:	4c 8b 75 d0          	mov    -0x30(%rbp),%r14
  49a7c2:	48 89 fb             	mov    %rdi,%rbx
  49a7c5:	e8 76 ca 94 00       	callq  de7240 <p111_rt_sink>
  49a7ca:	4c 89 f6             	mov    %r14,%rsi
  49a7cd:	48 89 df             	mov    %rbx,%rdi
  49a7d0:	4c 8b 75 c8          	mov    -0x38(%rbp),%r14
  49a7d4:	48 89 fb             	mov    %rdi,%rbx
  49a7d7:	e8 64 ca 94 00       	callq  de7240 <p111_rt_sink>
  49a7dc:	4c 89 f6             	mov    %r14,%rsi
  49a7df:	48 89 df             	mov    %rbx,%rdi
  49a7e2:	48 89 fb             	mov    %rdi,%rbx
  49a7e5:	e8 56 ca 94 00       	callq  de7240 <p111_rt_sink>
  49a7ea:	4c 89 e6             	mov    %r12,%rsi
  49a7ed:	48 89 df             	mov    %rbx,%rdi
  49a7f0:	48 89 fb             	mov    %rdi,%rbx
  49a7f3:	e8 b8 c9 94 00       	callq  de71b0 <p111_rt_keep>
  49a7f8:	48 89 df             	mov    %rbx,%rdi
  49a7fb:	48 89 c6             	mov    %rax,%rsi
  49a7fe:	49 89 f4             	mov    %rsi,%r12
  49a801:	4c 89 ee             	mov    %r13,%rsi
  49a804:	48 89 fb             	mov    %rdi,%rbx
  49a807:	e8 a4 c9 94 00       	callq  de71b0 <p111_rt_keep>
  49a80c:	4c 89 ea             	mov    %r13,%rdx
  49a80f:	4c 89 e6             	mov    %r12,%rsi
  49a812:	48 89 df             	mov    %rbx,%rdi
  49a815:	49 89 c5             	mov    %rax,%r13
  49a818:	b9 01 00 00 00       	mov    $0x1,%ecx
  49a81d:	49 89 d6             	mov    %rdx,%r14
  49a820:	4c 89 ea             	mov    %r13,%rdx
  49a823:	49 89 f4             	mov    %rsi,%r12
  49a826:	48 89 fb             	mov    %rdi,%rbx
  49a829:	e8 52 c4 f6 ff       	callq  406c80 <p113d_FID_36_100_105_114_101_99_116_46_112_56_56_95_115_116_114_105_110_103_95_101_113_95_103_111_>
  49a82e:	4c 89 e6             	mov    %r12,%rsi
  49a831:	48 89 df             	mov    %rbx,%rdi
  49a834:	48 89 c3             	mov    %rax,%rbx
  49a837:	49 89 fc             	mov    %rdi,%r12
  49a83a:	e8 01 ca 94 00       	callq  de7240 <p111_rt_sink>
  49a83f:	4c 89 ee             	mov    %r13,%rsi
  49a842:	4c 89 e7             	mov    %r12,%rdi
  49a845:	4c 8b 6d c0          	mov    -0x40(%rbp),%r13
  49a849:	49 89 fc             	mov    %rdi,%r12
  49a84c:	e8 ef c9 94 00       	callq  de7240 <p111_rt_sink>
  49a851:	4c 89 fe             	mov    %r15,%rsi
  49a854:	4c 89 e7             	mov    %r12,%rdi
  49a857:	48 83 fb 01          	cmp    $0x1,%rbx
  49a85b:	0f 94 c0             	sete   %al
  49a85e:	0f b6 c0             	movzbl %al,%eax
  49a861:	48 89 d9             	mov    %rbx,%rcx
  49a864:	48 c1 e9 28          	shr    $0x28,%rcx
  49a868:	48 81 e1 ff ff 7f 00 	and    $0x7fffff,%rcx
  49a86f:	48 81 f9 02 00 01 00 	cmp    $0x10002,%rcx
  49a876:	0f 94 c1             	sete   %cl
  49a879:	0f b6 c9             	movzbl %cl,%ecx
  49a87c:	89 c3                	mov    %eax,%ebx
  49a87e:	09 cb                	or     %ecx,%ebx
  49a880:	0f 85 89 00 00 00    	jne    49a90f <p113d_FID_36_100_105_114_101_99_116_46_105_110_100_101_120_95_98_117_99_107_101_116_+0x38f>
  49a886:	49 89 fc             	mov    %rdi,%r12
  49a889:	e8 b2 c9 94 00       	callq  de7240 <p111_rt_sink>
  49a88e:	4c 89 f2             	mov    %r14,%rdx
  49a891:	4c 89 ee             	mov    %r13,%rsi
  49a894:	4c 89 e7             	mov    %r12,%rdi
  49a897:	89 d8                	mov    %ebx,%eax
  49a899:	83 f0 01             	xor    $0x1,%eax
  49a89c:	74 3b                	je     49a8d9 <p113d_FID_36_100_105_114_101_99_116_46_105_110_100_101_120_95_98_117_99_107_101_116_+0x359>
  49a89e:	b9 00 00 00 00       	mov    $0x0,%ecx
  49a8a3:	49 89 d5             	mov    %rdx,%r13
  49a8a6:	48 8d 95 b0 f6 ff ff 	lea    -0x950(%rbp),%rdx
  49a8ad:	49 89 f4             	mov    %rsi,%r12
  49a8b0:	be 00 00 00 00       	mov    $0x0,%esi
  49a8b5:	48 89 fb             	mov    %rdi,%rbx
  49a8b8:	e8 f3 c9 94 00       	callq  de72b0 <p111_rt_ctor>
  49a8bd:	48 89 df             	mov    %rbx,%rdi
  49a8c0:	48 89 c6             	mov    %rax,%rsi
  49a8c3:	48 89 fb             	mov    %rdi,%rbx
  49a8c6:	e8 75 c9 94 00       	callq  de7240 <p111_rt_sink>
  49a8cb:	4c 89 ea             	mov    %r13,%rdx
  49a8ce:	4c 89 e6             	mov    %r12,%rsi
  49a8d1:	48 89 df             	mov    %rbx,%rdi
  49a8d4:	e9 c7 fc ff ff       	jmpq   49a5a0 <p113d_FID_36_100_105_114_101_99_116_46_105_110_100_101_120_95_98_117_99_107_101_116_+0x20>
  49a8d9:	49 89 f4             	mov    %rsi,%r12
  49a8dc:	48 89 d6             	mov    %rdx,%rsi
  49a8df:	48 89 fb             	mov    %rdi,%rbx
  49a8e2:	e8 59 c9 94 00       	callq  de7240 <p111_rt_sink>
  49a8e7:	4c 89 e6             	mov    %r12,%rsi
  49a8ea:	48 89 df             	mov    %rbx,%rdi
  49a8ed:	49 89 f5             	mov    %rsi,%r13
  49a8f0:	48 89 fb             	mov    %rdi,%rbx
  49a8f3:	e8 48 c9 94 00       	callq  de7240 <p111_rt_sink>
  49a8f8:	48 89 df             	mov    %rbx,%rdi
  49a8fb:	be 04 00 00 00       	mov    $0x4,%esi
  49a900:	e8 cb d0 94 00       	callq  de79d0 <p111_rt_fail>
  49a905:	b8 00 00 00 00       	mov    $0x0,%eax
  49a90a:	e9 0b 02 00 00       	jmpq   49ab1a <p113d_FID_36_100_105_114_101_99_116_46_105_110_100_101_120_95_98_117_99_107_101_116_+0x59a>
  49a90f:	48 89 f3             	mov    %rsi,%rbx
  49a912:	4c 89 f6             	mov    %r14,%rsi
  49a915:	49 89 fc             	mov    %rdi,%r12
  49a918:	e8 23 c9 94 00       	callq  de7240 <p111_rt_sink>
  49a91d:	4c 89 ee             	mov    %r13,%rsi
  49a920:	4c 89 e7             	mov    %r12,%rdi
  49a923:	49 89 fc             	mov    %rdi,%r12
  49a926:	e8 15 c9 94 00       	callq  de7240 <p111_rt_sink>
  49a92b:	4c 89 e7             	mov    %r12,%rdi
  49a92e:	b9 00 00 00 00       	mov    $0x0,%ecx
  49a933:	48 8d 95 b0 f6 ff ff 	lea    -0x950(%rbp),%rdx
  49a93a:	be 00 00 00 00       	mov    $0x0,%esi
  49a93f:	49 89 fc             	mov    %rdi,%r12
  49a942:	e8 69 c9 94 00       	callq  de72b0 <p111_rt_ctor>
  49a947:	4c 89 e7             	mov    %r12,%rdi
  49a94a:	48 89 c6             	mov    %rax,%rsi
  49a94d:	e8 ee c8 94 00       	callq  de7240 <p111_rt_sink>
  49a952:	48 89 d8             	mov    %rbx,%rax
  49a955:	e9 c0 01 00 00       	jmpq   49ab1a <p113d_FID_36_100_105_114_101_99_116_46_105_110_100_101_120_95_98_117_99_107_101_116_+0x59a>
  49a95a:	be 04 00 00 00       	mov    $0x4,%esi
  49a95f:	e8 6c d0 94 00       	callq  de79d0 <p111_rt_fail>
  49a964:	b8 00 00 00 00       	mov    $0x0,%eax
  49a969:	e9 ac 01 00 00       	jmpq   49ab1a <p113d_FID_36_100_105_114_101_99_116_46_105_110_100_101_120_95_98_117_99_107_101_116_+0x59a>
  49a96e:	48 89 d6             	mov    %rdx,%rsi
  49a971:	48 89 fb             	mov    %rdi,%rbx
  49a974:	e8 c7 c8 94 00       	callq  de7240 <p111_rt_sink>
  49a979:	48 89 df             	mov    %rbx,%rdi
  49a97c:	48 b8 0a 82 10 03 00 	movabs $0x20019000310820a,%rax
  49a983:	19 00 02 
  49a986:	48 89 85 f8 fe ff ff 	mov    %rax,-0x108(%rbp)
  49a98d:	48 b8 00 00 00 00 00 	movabs $0x100180000000000,%rax
  49a994:	18 00 01 
  49a997:	48 89 85 00 ff ff ff 	mov    %rax,-0x100(%rbp)
  49a99e:	48 c7 85 08 ff ff ff 	movq   $0x0,-0xf8(%rbp)
  49a9a5:	00 00 00 00 
  49a9a9:	48 c7 85 10 ff ff ff 	movq   $0x0,-0xf0(%rbp)
  49a9b0:	00 00 00 00 
  49a9b4:	48 b8 00 00 00 00 00 	movabs $0x100110000000000,%rax
  49a9bb:	11 00 01 
  49a9be:	48 89 85 18 ff ff ff 	mov    %rax,-0xe8(%rbp)
  49a9c5:	48 b8 00 00 00 00 00 	movabs $0x100110000000000,%rax
  49a9cc:	11 00 01 
  49a9cf:	48 89 85 20 ff ff ff 	mov    %rax,-0xe0(%rbp)
  49a9d6:	48 c7 85 28 ff ff ff 	movq   $0x0,-0xd8(%rbp)
  49a9dd:	00 00 00 00 
  49a9e1:	48 c7 85 30 ff ff ff 	movq   $0x0,-0xd0(%rbp)
  49a9e8:	00 00 00 00 
  49a9ec:	b9 08 00 00 00       	mov    $0x8,%ecx
  49a9f1:	48 8d 95 f8 fe ff ff 	lea    -0x108(%rbp),%rdx
  49a9f8:	be 96 00 00 00       	mov    $0x96,%esi
  49a9fd:	48 89 fb             	mov    %rdi,%rbx
  49aa00:	e8 ab c8 94 00       	callq  de72b0 <p111_rt_ctor>
  49aa05:	48 89 df             	mov    %rbx,%rdi
  49aa08:	48 89 c3             	mov    %rax,%rbx
  49aa0b:	48 b8 0a 82 10 03 00 	movabs $0x20019000310820a,%rax
  49aa12:	19 00 02 
  49aa15:	48 89 85 38 ff ff ff 	mov    %rax,-0xc8(%rbp)
  49aa1c:	48 b8 00 00 00 00 00 	movabs $0x100180000000000,%rax
  49aa23:	18 00 01 
  49aa26:	48 89 85 40 ff ff ff 	mov    %rax,-0xc0(%rbp)
  49aa2d:	48 c7 85 48 ff ff ff 	movq   $0x0,-0xb8(%rbp)
  49aa34:	00 00 00 00 
  49aa38:	48 c7 85 50 ff ff ff 	movq   $0x0,-0xb0(%rbp)
  49aa3f:	00 00 00 00 
  49aa43:	48 b8 00 00 00 00 00 	movabs $0x100110000000000,%rax
  49aa4a:	11 00 01 
  49aa4d:	48 89 85 58 ff ff ff 	mov    %rax,-0xa8(%rbp)
  49aa54:	48 b8 00 00 00 00 00 	movabs $0x100110000000000,%rax
  49aa5b:	11 00 01 
  49aa5e:	48 89 85 60 ff ff ff 	mov    %rax,-0xa0(%rbp)
  49aa65:	48 c7 85 68 ff ff ff 	movq   $0x0,-0x98(%rbp)
  49aa6c:	00 00 00 00 
  49aa70:	48 c7 85 70 ff ff ff 	movq   $0x0,-0x90(%rbp)
  49aa77:	00 00 00 00 
  49aa7b:	b9 08 00 00 00       	mov    $0x8,%ecx
  49aa80:	48 8d 95 38 ff ff ff 	lea    -0xc8(%rbp),%rdx
  49aa87:	be 96 00 00 00       	mov    $0x96,%esi
  49aa8c:	49 89 fc             	mov    %rdi,%r12
  49aa8f:	e8 1c c8 94 00       	callq  de72b0 <p111_rt_ctor>
  49aa94:	4c 89 e7             	mov    %r12,%rdi
  49aa97:	48 b9 00 00 00 00 00 	movabs $0x100180000000000,%rcx
  49aa9e:	18 00 01 
  49aaa1:	48 89 8d b0 fe ff ff 	mov    %rcx,-0x150(%rbp)
  49aaa8:	48 b9 0a 82 10 03 00 	movabs $0x20019000310820a,%rcx
  49aaaf:	19 00 02 
  49aab2:	48 89 8d b8 fe ff ff 	mov    %rcx,-0x148(%rbp)
  49aab9:	48 c7 85 c0 fe ff ff 	movq   $0x0,-0x140(%rbp)
  49aac0:	00 00 00 00 
  49aac4:	48 c7 85 c8 fe ff ff 	movq   $0x0,-0x138(%rbp)
  49aacb:	00 00 00 00 
  49aacf:	48 89 9d d0 fe ff ff 	mov    %rbx,-0x130(%rbp)
  49aad6:	48 89 85 d8 fe ff ff 	mov    %rax,-0x128(%rbp)
  49aadd:	48 b8 00 00 00 00 00 	movabs $0x100110000000000,%rax
  49aae4:	11 00 01 
  49aae7:	48 89 85 e0 fe ff ff 	mov    %rax,-0x120(%rbp)
  49aaee:	48 c7 85 e8 fe ff ff 	movq   $0x0,-0x118(%rbp)
  49aaf5:	00 00 00 00 
  49aaf9:	48 c7 85 f0 fe ff ff 	movq   $0x0,-0x110(%rbp)
  49ab00:	00 00 00 00 
  49ab04:	b9 09 00 00 00       	mov    $0x9,%ecx
  49ab09:	48 8d 95 b0 fe ff ff 	lea    -0x150(%rbp),%rdx
  49ab10:	be 99 00 00 00       	mov    $0x99,%esi
  49ab15:	e8 96 c7 94 00       	callq  de72b0 <p111_rt_ctor>
  49ab1a:	41 5f                	pop    %r15
  49ab1c:	41 5e                	pop    %r14
  49ab1e:	41 5d                	pop    %r13
  49ab20:	41 5c                	pop    %r12
  49ab22:	5b                   	pop    %rbx
  49ab23:	c9                   	leaveq 
  49ab24:	c3                   	retq   

Disassembly of section .fini:
