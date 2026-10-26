
selfhost/build/phase134/p144-predicate-positive-native01/program:     file format elf64-x86-64


Disassembly of section .init:

Disassembly of section .plt:

Disassembly of section .text:

000000000041b4d0 <p111_FID_36_100_105_114_101_99_116_46_112_49_51_49_105_95_105_110_115_101_114_116_>:
  41b4d0:	endbr64 
  41b4d4:	push   %rbp
  41b4d5:	mov    %rsp,%rbp
  41b4d8:	sub    $0x1848,%rsp
  41b4df:	push   %rbx
  41b4e0:	push   %r12
  41b4e2:	push   %r13
  41b4e4:	push   %r14
  41b4e6:	push   %r15
  41b4e8:	mov    0x28(%rdi),%rsi
  41b4ec:	mov    0x30(%rdi),%r12
  41b4f0:	mov    0x38(%rdi),%rbx
  41b4f4:	mov    %rsi,%rax
  41b4f7:	shr    $0x28,%rax
  41b4fb:	and    $0xffff,%rax
  41b501:	cmp    $0x99,%rax
  41b507:	sete   %cl
  41b50a:	movzbl %cl,%ecx
  41b50d:	cmp    $0x0,%ecx
  41b510:	jne    41be0d <p111_FID_36_100_105_114_101_99_116_46_112_49_51_49_105_95_105_110_115_101_114_116_+0x93d>
  41b516:	cmp    $0x9a,%rax
  41b51c:	sete   %cl
  41b51f:	movzbl %cl,%ecx
  41b522:	mov    $0xffffffff,%edx
  41b527:	mov    %rbx,%r13
  41b52a:	and    %rdx,%r13
  41b52d:	mov    %r13,-0x20(%rbp)
  41b531:	cmp    $0x0,%ecx
  41b534:	jne    41bbfb <p111_FID_36_100_105_114_101_99_116_46_112_49_51_49_105_95_105_110_115_101_114_116_+0x72b>
  41b53a:	nopw   0x0(%rax,%rax,1)
  41b540:	cmp    $0x9b,%rax
  41b546:	je     41b5b1 <p111_FID_36_100_105_114_101_99_116_46_112_49_51_49_105_95_105_110_115_101_114_116_+0xe1>
  41b548:	mov    %rbx,-0x1840(%rbp)
  41b54f:	mov    0x10(%rdi),%rax
  41b553:	mov    %rbx,(%rax)
  41b556:	movq   $0x215,0x8(%rax)
  41b55e:	add    $0x10,%rax
  41b562:	mov    %rax,0x10(%rdi)
  41b566:	mov    %r12,-0x1840(%rbp)
  41b56d:	mov    0x10(%rdi),%rax
  41b571:	mov    %r12,(%rax)
  41b574:	movq   $0x216,0x8(%rax)
  41b57c:	add    $0x10,%rax
  41b580:	mov    %rax,0x10(%rdi)
  41b584:	mov    %rsi,-0x1840(%rbp)
  41b58b:	mov    0x10(%rdi),%rax
  41b58f:	mov    %rsi,(%rax)
  41b592:	movq   $0x217,0x8(%rax)
  41b59a:	add    $0x10,%rax
  41b59e:	mov    %rax,0x10(%rdi)
  41b5a2:	mov    $0x4,%esi
  41b5a7:	callq  424be0 <p111_rt_fail>
  41b5ac:	jmpq   41bef4 <p111_FID_36_100_105_114_101_99_116_46_112_49_51_49_105_95_105_110_115_101_114_116_+0xa24>
  41b5b1:	lea    -0x1840(%rbp),%rdx
  41b5b8:	mov    %rdi,%r13
  41b5bb:	callq  42a0d0 <p125_rt_take4>
  41b5c0:	mov    %r13,%rdi
  41b5c3:	mov    -0x1840(%rbp),%rsi
  41b5ca:	mov    -0x1838(%rbp),%r14
  41b5d1:	mov    %r12,%r15
  41b5d4:	mov    -0x1830(%rbp),%r12
  41b5db:	mov    %r12,-0x38(%rbp)
  41b5df:	mov    %rbx,%r12
  41b5e2:	mov    -0x1828(%rbp),%rbx
  41b5e9:	mov    %rdi,%r13
  41b5ec:	callq  4243c0 <p111_rt_keep>
  41b5f1:	mov    %r14,%rsi
  41b5f4:	mov    %r13,%rdi
  41b5f7:	mov    %rax,%r13
  41b5fa:	mov    %rdi,%r14
  41b5fd:	callq  4243c0 <p111_rt_keep>
  41b602:	mov    %r14,%rdi
  41b605:	xchg   %rax,%r13
  41b607:	mov    -0x38(%rbp),%r14
  41b60b:	mov    %r13,-0x30(%rbp)
  41b60f:	mov    $0xffffffff,%ecx
  41b614:	and    %r13,%rcx
  41b617:	cmp    $0x0,%rcx
  41b61b:	mov    %rax,%r13
  41b61e:	sete   %al
  41b621:	movzbl %al,%eax
  41b624:	cmp    $0x1,%rax
  41b628:	sete   %cl
  41b62b:	movzbl %cl,%ecx
  41b62e:	mov    %rax,%rdx
  41b631:	shr    $0x28,%rdx
  41b635:	and    $0x7fffff,%rdx
  41b63c:	cmp    $0x10002,%rdx
  41b643:	sete   %dl
  41b646:	movzbl %dl,%edx
  41b649:	or     %edx,%ecx
  41b64b:	jne    41bb52 <p111_FID_36_100_105_114_101_99_116_46_112_49_51_49_105_95_105_110_115_101_114_116_+0x682>
  41b651:	xor    $0x1,%ecx
  41b654:	jne    41b6d2 <p111_FID_36_100_105_114_101_99_116_46_112_49_51_49_105_95_105_110_115_101_114_116_+0x202>
  41b656:	mov    %rbx,%r12
  41b659:	mov    %eax,%ebx
  41b65b:	mov    %r15,%rsi
  41b65e:	mov    %rdi,%r15
  41b661:	callq  424450 <p111_rt_sink>
  41b666:	mov    %r15,%rdi
  41b669:	mov    -0x30(%rbp),%r15
  41b66d:	mov    %r13,%rsi
  41b670:	mov    %rdi,%r13
  41b673:	callq  424450 <p111_rt_sink>
  41b678:	mov    %r13,%rdi
  41b67b:	mov    %r15,%rsi
  41b67e:	mov    %rdi,%r13
  41b681:	callq  424450 <p111_rt_sink>
  41b686:	mov    %r13,%rdi
  41b689:	mov    %r14,%rsi
  41b68c:	mov    %rdi,%r13
  41b68f:	callq  424450 <p111_rt_sink>
  41b694:	mov    %r13,%rdi
  41b697:	mov    %r12,%rsi
  41b69a:	mov    %rdi,%r12
  41b69d:	callq  424450 <p111_rt_sink>
  41b6a2:	mov    %r12,%rdi
  41b6a5:	mov    %rbx,-0x1840(%rbp)
  41b6ac:	mov    0x10(%rdi),%rax
  41b6b0:	mov    %rbx,(%rax)
  41b6b3:	movq   $0x214,0x8(%rax)
  41b6bb:	add    $0x10,%rax
  41b6bf:	mov    %rax,0x10(%rdi)
  41b6c3:	mov    $0x4,%esi
  41b6c8:	callq  424be0 <p111_rt_fail>
  41b6cd:	jmpq   41bef4 <p111_FID_36_100_105_114_101_99_116_46_112_49_51_49_105_95_105_110_115_101_114_116_+0xa24>
  41b6d2:	mov    $0x0,%ecx
  41b6d7:	lea    -0x1840(%rbp),%rdx
  41b6de:	mov    $0x0,%esi
  41b6e3:	mov    %rdi,%r14
  41b6e6:	callq  4244c0 <p111_rt_ctor>
  41b6eb:	mov    %r14,%rdi
  41b6ee:	mov    %rax,%rsi
  41b6f1:	mov    %rdi,%r14
  41b6f4:	callq  424450 <p111_rt_sink>
  41b6f9:	mov    %r14,%rdi
  41b6fc:	mov    -0x30(%rbp),%r14
  41b700:	mov    %r14,%rsi
  41b703:	mov    %rdi,%r14
  41b706:	callq  4243c0 <p111_rt_keep>
  41b70b:	mov    %r14,%rdi
  41b70e:	mov    %rax,%rsi
  41b711:	mov    %r13,%rax
  41b714:	mov    -0x38(%rbp),%r14
  41b718:	mov    -0x20(%rbp),%r13
  41b71c:	mov    %rsi,-0x18(%rbp)
  41b720:	mov    $0xffffffff,%ecx
  41b725:	and    %rax,%rcx
  41b728:	xor    %r13,%rcx
  41b72b:	mov    $0xffffffff,%edx
  41b730:	mov    %rsi,%r13
  41b733:	mov    %rcx,%rsi
  41b736:	and    %rdx,%rsi
  41b739:	mov    %rsi,-0x10(%rbp)
  41b73d:	mov    $0xffffffff,%ecx
  41b742:	and    %r13,%rcx
  41b745:	sub    $0x1,%rcx
  41b749:	mov    $0xffffffff,%edx
  41b74e:	and    %rdx,%rcx
  41b751:	and    %rsi,%rcx
  41b754:	mov    $0xffffffff,%edx
  41b759:	and    %rdx,%rcx
  41b75c:	cmp    $0x0,%rcx
  41b760:	mov    %rax,%r13
  41b763:	sete   %al
  41b766:	movzbl %al,%eax
  41b769:	cmp    $0x1,%rax
  41b76d:	sete   %cl
  41b770:	movzbl %cl,%ecx
  41b773:	mov    %rax,%rdx
  41b776:	shr    $0x28,%rdx
  41b77a:	and    $0x7fffff,%rdx
  41b781:	cmp    $0x10002,%rdx
  41b788:	sete   %dl
  41b78b:	movzbl %dl,%edx
  41b78e:	or     %edx,%ecx
  41b790:	jne    41b8d4 <p111_FID_36_100_105_114_101_99_116_46_112_49_51_49_105_95_105_110_115_101_114_116_+0x404>
  41b796:	xor    $0x1,%ecx
  41b799:	jne    41b81a <p111_FID_36_100_105_114_101_99_116_46_112_49_51_49_105_95_105_110_115_101_114_116_+0x34a>
  41b79b:	mov    %rbx,%r12
  41b79e:	mov    %eax,%ebx
  41b7a0:	mov    %r15,%rsi
  41b7a3:	mov    %rdi,%r15
  41b7a6:	callq  424450 <p111_rt_sink>
  41b7ab:	mov    %r15,%rdi
  41b7ae:	mov    -0x18(%rbp),%rsi
  41b7b2:	mov    %rsi,%r15
  41b7b5:	mov    %r13,%rsi
  41b7b8:	mov    %rdi,%r13
  41b7bb:	callq  424450 <p111_rt_sink>
  41b7c0:	mov    %r15,%rsi
  41b7c3:	mov    %r13,%rdi
  41b7c6:	mov    %rdi,%r13
  41b7c9:	callq  424450 <p111_rt_sink>
  41b7ce:	mov    %r13,%rdi
  41b7d1:	mov    %r14,%rsi
  41b7d4:	mov    %rdi,%r13
  41b7d7:	callq  424450 <p111_rt_sink>
  41b7dc:	mov    %r13,%rdi
  41b7df:	mov    %r12,%rsi
  41b7e2:	mov    %rdi,%r12
  41b7e5:	callq  424450 <p111_rt_sink>
  41b7ea:	mov    %r12,%rdi
  41b7ed:	mov    %rbx,-0x1840(%rbp)
  41b7f4:	mov    0x10(%rdi),%rax
  41b7f8:	mov    %rbx,(%rax)
  41b7fb:	movq   $0x213,0x8(%rax)
  41b803:	add    $0x10,%rax
  41b807:	mov    %rax,0x10(%rdi)
  41b80b:	mov    $0x4,%esi
  41b810:	callq  424be0 <p111_rt_fail>
  41b815:	jmpq   41bef4 <p111_FID_36_100_105_114_101_99_116_46_112_49_51_49_105_95_105_110_115_101_114_116_+0xa24>
  41b81a:	mov    $0x0,%ecx
  41b81f:	lea    -0x1840(%rbp),%rdx
  41b826:	mov    $0x0,%esi
  41b82b:	mov    %rdi,%r14
  41b82e:	callq  4244c0 <p111_rt_ctor>
  41b833:	mov    %r14,%rdi
  41b836:	mov    %rax,%rsi
  41b839:	mov    %rdi,%r14
  41b83c:	callq  424450 <p111_rt_sink>
  41b841:	mov    %r14,%rdi
  41b844:	mov    %r13,%rax
  41b847:	mov    -0x18(%rbp),%rsi
  41b84b:	mov    -0x38(%rbp),%r14
  41b84f:	mov    %rsi,%r13
  41b852:	mov    -0x10(%rbp),%rsi
  41b856:	mov    %rax,-0x1840(%rbp)
  41b85d:	mov    %r13,-0x1838(%rbp)
  41b864:	mov    %r14,-0x1830(%rbp)
  41b86b:	mov    %rbx,-0x1828(%rbp)
  41b872:	lea    -0x1840(%rbp),%rdx
  41b879:	mov    %rsi,%r13
  41b87c:	mov    $0x9b,%esi
  41b881:	mov    %rdi,%rbx
  41b884:	callq  42a000 <p125_rt_ctor4>
  41b889:	mov    %r13,%rsi
  41b88c:	mov    %rbx,%rdi
  41b88f:	mov    %rax,%rbx
  41b892:	mov    %rdi,%r13
  41b895:	callq  40b900 <p112w_FID_36_100_105_114_101_99_116_46_105_110_100_101_120_95_115_112_108_105_116_95_98_105_116_>
  41b89a:	mov    %r13,%rdi
  41b89d:	mov    %rbx,-0x840(%rbp)
  41b8a4:	mov    %r15,-0x838(%rbp)
  41b8ab:	mov    %r12,-0x830(%rbp)
  41b8b2:	mov    %rax,-0x828(%rbp)
  41b8b9:	mov    $0x4,%ecx
  41b8be:	lea    -0x840(%rbp),%rdx
  41b8c5:	mov    $0x169,%esi
  41b8ca:	callq  424a10 <p111_rt_jump>
  41b8cf:	jmpq   41bef4 <p111_FID_36_100_105_114_101_99_116_46_112_49_51_49_105_95_105_110_115_101_114_116_+0xa24>
  41b8d4:	mov    $0x0,%ecx
  41b8d9:	lea    -0x1840(%rbp),%rdx
  41b8e0:	mov    $0x0,%esi
  41b8e5:	mov    %rdi,%r14
  41b8e8:	callq  4244c0 <p111_rt_ctor>
  41b8ed:	mov    %r14,%rdi
  41b8f0:	mov    %rax,%rsi
  41b8f3:	mov    %rdi,%r14
  41b8f6:	callq  424450 <p111_rt_sink>
  41b8fb:	mov    %r14,%rdi
  41b8fe:	mov    -0x18(%rbp),%rsi
  41b902:	mov    %rdi,%r14
  41b905:	callq  4243c0 <p111_rt_keep>
  41b90a:	mov    %r14,%rdi
  41b90d:	mov    %rax,%rcx
  41b910:	mov    %r13,%rax
  41b913:	mov    -0x38(%rbp),%r14
  41b917:	mov    -0x20(%rbp),%r13
  41b91b:	mov    %rcx,-0x28(%rbp)
  41b91f:	mov    $0xffffffff,%edx
  41b924:	and    %rdx,%rcx
  41b927:	and    %r13,%rcx
  41b92a:	mov    $0xffffffff,%edx
  41b92f:	and    %rdx,%rcx
  41b932:	cmp    $0x0,%rcx
  41b936:	mov    %rax,%r13
  41b939:	sete   %al
  41b93c:	movzbl %al,%eax
  41b93f:	cmp    $0x1,%rax
  41b943:	sete   %cl
  41b946:	movzbl %cl,%ecx
  41b949:	mov    %rax,%rdx
  41b94c:	shr    $0x28,%rdx
  41b950:	and    $0x7fffff,%rdx
  41b957:	cmp    $0x10002,%rdx
  41b95e:	sete   %dl
  41b961:	movzbl %dl,%edx
  41b964:	or     %edx,%ecx
  41b966:	jne    41baa5 <p111_FID_36_100_105_114_101_99_116_46_112_49_51_49_105_95_105_110_115_101_114_116_+0x5d5>
  41b96c:	xor    $0x1,%ecx
  41b96f:	jne    41b9f0 <p111_FID_36_100_105_114_101_99_116_46_112_49_51_49_105_95_105_110_115_101_114_116_+0x520>
  41b971:	mov    %rbx,%r12
  41b974:	mov    %eax,%ebx
  41b976:	mov    %r15,%rsi
  41b979:	mov    %rdi,%r15
  41b97c:	callq  424450 <p111_rt_sink>
  41b981:	mov    %r15,%rdi
  41b984:	mov    %r13,%rax
  41b987:	mov    -0x28(%rbp),%r15
  41b98b:	mov    %rax,%rsi
  41b98e:	mov    %rdi,%r13
  41b991:	callq  424450 <p111_rt_sink>
  41b996:	mov    %r13,%rdi
  41b999:	mov    %r15,%rsi
  41b99c:	mov    %rdi,%r13
  41b99f:	callq  424450 <p111_rt_sink>
  41b9a4:	mov    %r13,%rdi
  41b9a7:	mov    %r14,%rsi
  41b9aa:	mov    %rdi,%r13
  41b9ad:	callq  424450 <p111_rt_sink>
  41b9b2:	mov    %r13,%rdi
  41b9b5:	mov    %r12,%rsi
  41b9b8:	mov    %rdi,%r12
  41b9bb:	callq  424450 <p111_rt_sink>
  41b9c0:	mov    %r12,%rdi
  41b9c3:	mov    %rbx,-0x1840(%rbp)
  41b9ca:	mov    0x10(%rdi),%rax
  41b9ce:	mov    %rbx,(%rax)
  41b9d1:	movq   $0x211,0x8(%rax)
  41b9d9:	add    $0x10,%rax
  41b9dd:	mov    %rax,0x10(%rdi)
  41b9e1:	mov    $0x4,%esi
  41b9e6:	callq  424be0 <p111_rt_fail>
  41b9eb:	jmpq   41bef4 <p111_FID_36_100_105_114_101_99_116_46_112_49_51_49_105_95_105_110_115_101_114_116_+0xa24>
  41b9f0:	cs cs cs cs mov %r13,%r14
  41b9f7:	cs mov %r15,%r13
  41b9fb:	mov    $0x0,%ecx
  41ba00:	lea    -0x1840(%rbp),%rdx
  41ba07:	mov    $0x0,%esi
  41ba0c:	mov    %rdi,%r15
  41ba0f:	callq  4244c0 <p111_rt_ctor>
  41ba14:	mov    %r15,%rdi
  41ba17:	mov    %rax,%rsi
  41ba1a:	mov    %rdi,%r15
  41ba1d:	callq  424450 <p111_rt_sink>
  41ba22:	mov    %r15,%rdi
  41ba25:	mov    %r14,%rax
  41ba28:	mov    -0x28(%rbp),%r15
  41ba2c:	mov    -0x38(%rbp),%r14
  41ba30:	mov    %rax,-0x1840(%rbp)
  41ba37:	mov    %r15,-0x1838(%rbp)
  41ba3e:	mov    %r14,-0x1830(%rbp)
  41ba45:	mov    %rax,%r14
  41ba48:	mov    0x10(%rdi),%rax
  41ba4c:	mov    %r14,(%rax)
  41ba4f:	mov    -0x1838(%rbp),%rcx
  41ba56:	mov    %rcx,0x8(%rax)
  41ba5a:	mov    -0x1830(%rbp),%rcx
  41ba61:	mov    %rcx,0x10(%rax)
  41ba65:	movq   $0x210,0x18(%rax)
  41ba6d:	add    $0x20,%rax
  41ba71:	mov    %rax,0x10(%rdi)
  41ba75:	mov    %rbx,-0x1840(%rbp)
  41ba7c:	mov    %r13,-0x1838(%rbp)
  41ba83:	mov    %r12,-0x1830(%rbp)
  41ba8a:	mov    $0x3,%ecx
  41ba8f:	lea    -0x1840(%rbp),%rdx
  41ba96:	mov    $0x20c,%esi
  41ba9b:	callq  424a10 <p111_rt_jump>
  41baa0:	jmpq   41bef4 <p111_FID_36_100_105_114_101_99_116_46_112_49_51_49_105_95_105_110_115_101_114_116_+0xa24>
  41baa5:	mov    %r13,%r14
  41baa8:	mov    %r15,%r13
  41baab:	mov    $0x0,%ecx
  41bab0:	lea    -0x1840(%rbp),%rdx
  41bab7:	mov    $0x0,%esi
  41babc:	mov    %rdi,%r15
  41babf:	callq  4244c0 <p111_rt_ctor>
  41bac4:	mov    %r15,%rdi
  41bac7:	mov    %rax,%rsi
  41baca:	mov    %rdi,%r15
  41bacd:	callq  424450 <p111_rt_sink>
  41bad2:	mov    %r15,%rdi
  41bad5:	mov    %r14,%rax
  41bad8:	mov    -0x28(%rbp),%r15
  41badc:	mov    -0x38(%rbp),%r14
  41bae0:	mov    %rbx,-0x1840(%rbp)
  41bae7:	mov    %rax,-0x1838(%rbp)
  41baee:	mov    %r15,-0x1830(%rbp)
  41baf5:	mov    0x10(%rdi),%rax
  41baf9:	mov    %rbx,(%rax)
  41bafc:	mov    -0x1838(%rbp),%rcx
  41bb03:	mov    %rcx,0x8(%rax)
  41bb07:	mov    -0x1830(%rbp),%rcx
  41bb0e:	mov    %rcx,0x10(%rax)
  41bb12:	movq   $0x20f,0x18(%rax)
  41bb1a:	add    $0x20,%rax
  41bb1e:	mov    %rax,0x10(%rdi)
  41bb22:	mov    %r14,-0x1840(%rbp)
  41bb29:	mov    %r13,-0x1838(%rbp)
  41bb30:	mov    %r12,-0x1830(%rbp)
  41bb37:	mov    $0x3,%ecx
  41bb3c:	lea    -0x1840(%rbp),%rdx
  41bb43:	mov    $0x20c,%esi
  41bb48:	callq  424a10 <p111_rt_jump>
  41bb4d:	jmpq   41bef4 <p111_FID_36_100_105_114_101_99_116_46_112_49_51_49_105_95_105_110_115_101_114_116_+0xa24>
  41bb52:	mov    %r13,%r14
  41bb55:	mov    %r15,%r13
  41bb58:	mov    $0x0,%ecx
  41bb5d:	lea    -0x1840(%rbp),%rdx
  41bb64:	mov    $0x0,%esi
  41bb69:	mov    %rdi,%r15
  41bb6c:	callq  4244c0 <p111_rt_ctor>
  41bb71:	mov    %r15,%rdi
  41bb74:	mov    %rax,%rsi
  41bb77:	mov    %rdi,%r15
  41bb7a:	callq  424450 <p111_rt_sink>
  41bb7f:	mov    %r15,%rdi
  41bb82:	mov    %r14,%rax
  41bb85:	mov    -0x30(%rbp),%r15
  41bb89:	mov    -0x38(%rbp),%r14
  41bb8d:	mov    %rax,-0x1840(%rbp)
  41bb94:	mov    %r15,-0x1838(%rbp)
  41bb9b:	mov    %r14,-0x1830(%rbp)
  41bba2:	mov    %rbx,-0x1828(%rbp)
  41bba9:	lea    -0x1840(%rbp),%rdx
  41bbb0:	mov    $0x9b,%esi
  41bbb5:	mov    %rdi,%rbx
  41bbb8:	callq  42a000 <p125_rt_ctor4>
  41bbbd:	mov    %rbx,%rdi
  41bbc0:	mov    %rax,-0x1840(%rbp)
  41bbc7:	mov    %r13,-0x1838(%rbp)
  41bbce:	mov    %r12,-0x1830(%rbp)
  41bbd5:	movq   $0x20,-0x1828(%rbp)
  41bbe0:	mov    $0x4,%ecx
  41bbe5:	lea    -0x1840(%rbp),%rdx
  41bbec:	mov    $0x201,%esi
  41bbf1:	callq  424a10 <p111_rt_jump>
  41bbf6:	jmpq   41bef4 <p111_FID_36_100_105_114_101_99_116_46_112_49_51_49_105_95_105_110_115_101_114_116_+0xa24>
  41bbfb:	cs cs cs cs mov %r13,%r14
  41bc02:	mov    %r12,%r13
  41bc05:	mov    %rbx,%r12
  41bc08:	lea    -0x1840(%rbp),%rdx
  41bc0f:	mov    %rdi,%rbx
  41bc12:	callq  429c00 <p125_rt_take2>
  41bc17:	mov    %rbx,%rdi
  41bc1a:	mov    -0x1840(%rbp),%rsi
  41bc21:	mov    -0x1838(%rbp),%rbx
  41bc28:	mov    %rdi,%r15
  41bc2b:	callq  4243c0 <p111_rt_keep>
  41bc30:	mov    %r15,%rdi
  41bc33:	mov    %rax,%rsi
  41bc36:	mov    $0xffffffff,%eax
  41bc3b:	and    %rsi,%rax
  41bc3e:	xor    %r14,%rax
  41bc41:	mov    $0xffffffff,%ecx
  41bc46:	mov    %rsi,%r15
  41bc49:	mov    %rax,%rsi
  41bc4c:	and    %rcx,%rsi
  41bc4f:	mov    %rdi,%r14
  41bc52:	callq  40b900 <p112w_FID_36_100_105_114_101_99_116_46_105_110_100_101_120_95_115_112_108_105_116_95_98_105_116_>
  41bc57:	mov    %r15,%rsi
  41bc5a:	mov    %r14,%rdi
  41bc5d:	mov    %rax,%r14
  41bc60:	mov    %r14,-0x40(%rbp)
  41bc64:	mov    $0xffffffff,%eax
  41bc69:	and    %r14,%rax
  41bc6c:	cmp    $0x0,%rax
  41bc70:	mov    %rbx,%r14
  41bc73:	sete   %bl
  41bc76:	movzbl %bl,%ebx
  41bc79:	cmp    $0x1,%rbx
  41bc7d:	sete   %al
  41bc80:	movzbl %al,%eax
  41bc83:	mov    %rbx,%rcx
  41bc86:	shr    $0x28,%rcx
  41bc8a:	and    $0x7fffff,%rcx
  41bc91:	cmp    $0x10002,%rcx
  41bc98:	sete   %cl
  41bc9b:	movzbl %cl,%ecx
  41bc9e:	or     %ecx,%eax
  41bca0:	cmp    $0x0,%eax
  41bca3:	jne    41bda5 <p111_FID_36_100_105_114_101_99_116_46_112_49_51_49_105_95_105_110_115_101_114_116_+0x8d5>
  41bca9:	xor    $0x1,%eax
  41bcac:	jne    41bd0b <p111_FID_36_100_105_114_101_99_116_46_112_49_51_49_105_95_105_110_115_101_114_116_+0x83b>
  41bcae:	mov    %r14,%r12
  41bcb1:	mov    %rsi,%r14
  41bcb4:	mov    %r13,%rsi
  41bcb7:	mov    %rdi,%r13
  41bcba:	callq  424450 <p111_rt_sink>
  41bcbf:	mov    %r14,%rsi
  41bcc2:	mov    %r13,%rdi
  41bcc5:	mov    %rdi,%r13
  41bcc8:	callq  424450 <p111_rt_sink>
  41bccd:	mov    %r13,%rdi
  41bcd0:	mov    %r12,%rsi
  41bcd3:	mov    %rdi,%r12
  41bcd6:	callq  424450 <p111_rt_sink>
  41bcdb:	mov    %r12,%rdi
  41bcde:	mov    %rbx,-0x1040(%rbp)
  41bce5:	mov    0x10(%rdi),%rax
  41bce9:	mov    %rbx,(%rax)
  41bcec:	movq   $0x20e,0x8(%rax)
  41bcf4:	add    $0x10,%rax
  41bcf8:	mov    %rax,0x10(%rdi)
  41bcfc:	mov    $0x4,%esi
  41bd01:	callq  424be0 <p111_rt_fail>
  41bd06:	jmpq   41bef4 <p111_FID_36_100_105_114_101_99_116_46_112_49_51_49_105_95_105_110_115_101_114_116_+0xa24>
  41bd0b:	cs cs cs cs mov %r14,%rbx
  41bd12:	mov    $0x0,%ecx
  41bd17:	lea    -0x1040(%rbp),%rdx
  41bd1e:	mov    %rsi,%r15
  41bd21:	mov    $0x0,%esi
  41bd26:	mov    %rdi,%r14
  41bd29:	callq  4244c0 <p111_rt_ctor>
  41bd2e:	mov    %r14,%rdi
  41bd31:	mov    %rax,%rsi
  41bd34:	mov    %rdi,%r14
  41bd37:	callq  424450 <p111_rt_sink>
  41bd3c:	mov    %r15,%rsi
  41bd3f:	mov    %r14,%rdi
  41bd42:	mov    %rbx,%r14
  41bd45:	mov    -0x40(%rbp),%rbx
  41bd49:	mov    %rsi,-0x1040(%rbp)
  41bd50:	mov    %r14,-0x1038(%rbp)
  41bd57:	lea    -0x1040(%rbp),%rdx
  41bd5e:	mov    $0x9a,%esi
  41bd63:	mov    %rdi,%r14
  41bd66:	callq  429b10 <p125_rt_ctor2>
  41bd6b:	mov    %r14,%rdi
  41bd6e:	mov    %rax,-0x1040(%rbp)
  41bd75:	mov    %r13,-0x1038(%rbp)
  41bd7c:	mov    %r12,-0x1030(%rbp)
  41bd83:	mov    %rbx,-0x1028(%rbp)
  41bd8a:	mov    $0x4,%ecx
  41bd8f:	lea    -0x1040(%rbp),%rdx
  41bd96:	mov    $0x169,%esi
  41bd9b:	callq  424a10 <p111_rt_jump>
  41bda0:	jmpq   41bef4 <p111_FID_36_100_105_114_101_99_116_46_112_49_51_49_105_95_105_110_115_101_114_116_+0xa24>
  41bda5:	mov    %r14,%rbx
  41bda8:	mov    %rdi,%r14
  41bdab:	callq  424450 <p111_rt_sink>
  41bdb0:	mov    %r14,%rdi
  41bdb3:	mov    $0x0,%ecx
  41bdb8:	lea    -0x1040(%rbp),%rdx
  41bdbf:	mov    $0x0,%esi
  41bdc4:	mov    %rdi,%r14
  41bdc7:	callq  4244c0 <p111_rt_ctor>
  41bdcc:	mov    %r14,%rdi
  41bdcf:	mov    %rax,%rsi
  41bdd2:	mov    %rdi,%r14
  41bdd5:	callq  424450 <p111_rt_sink>
  41bdda:	mov    %r14,%rdi
  41bddd:	mov    %r13,-0x1040(%rbp)
  41bde4:	mov    %r12,-0x1038(%rbp)
  41bdeb:	mov    %rbx,-0x1030(%rbp)
  41bdf2:	mov    $0x3,%ecx
  41bdf7:	lea    -0x1040(%rbp),%rdx
  41bdfe:	mov    $0x1ca,%esi
  41be03:	callq  424a10 <p111_rt_jump>
  41be08:	jmpq   41bef4 <p111_FID_36_100_105_114_101_99_116_46_112_49_51_49_105_95_105_110_115_101_114_116_+0xa24>
  41be0d:	mov    $0x9,%ecx
  41be12:	lea    -0x1840(%rbp),%rdx
  41be19:	mov    %rdi,%r13
  41be1c:	callq  424640 <p111_rt_take>
  41be21:	mov    %r13,%rdi
  41be24:	mov    -0x1840(%rbp),%r13
  41be2b:	mov    -0x1838(%rbp),%r11
  41be32:	mov    -0x1830(%rbp),%r10
  41be39:	mov    -0x1828(%rbp),%r9
  41be40:	mov    -0x1820(%rbp),%r8
  41be47:	mov    -0x1818(%rbp),%rsi
  41be4e:	mov    -0x1810(%rbp),%rdx
  41be55:	mov    -0x1808(%rbp),%rcx
  41be5c:	mov    -0x1800(%rbp),%rax
  41be63:	mov    %r13,-0x1840(%rbp)
  41be6a:	mov    %r11,-0x1838(%rbp)
  41be71:	mov    %r10,-0x1830(%rbp)
  41be78:	mov    %r9,-0x1828(%rbp)
  41be7f:	mov    %r8,-0x1820(%rbp)
  41be86:	mov    %rsi,-0x1818(%rbp)
  41be8d:	mov    %rdx,-0x1810(%rbp)
  41be94:	mov    %rcx,-0x1808(%rbp)
  41be9b:	mov    %rax,-0x1800(%rbp)
  41bea2:	mov    $0x9,%ecx
  41bea7:	lea    -0x1840(%rbp),%rdx
  41beae:	mov    $0x99,%esi
  41beb3:	mov    %rdi,%r13
  41beb6:	callq  4244c0 <p111_rt_ctor>
  41bebb:	mov    %r13,%rdi
  41bebe:	mov    %rax,-0x1840(%rbp)
  41bec5:	mov    %r12,-0x1838(%rbp)
  41becc:	mov    %rbx,-0x1830(%rbp)
  41bed3:	movq   $0x20,-0x1828(%rbp)
  41bede:	mov    $0x4,%ecx
  41bee3:	lea    -0x1840(%rbp),%rdx
  41beea:	mov    $0x201,%esi
  41beef:	callq  424a10 <p111_rt_jump>
  41bef4:	pop    %r15
  41bef6:	pop    %r14
  41bef8:	pop    %r13
  41befa:	pop    %r12
  41befc:	pop    %rbx
  41befd:	leaveq 
  41befe:	retq   

Disassembly of section .fini:
