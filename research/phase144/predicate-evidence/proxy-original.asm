
selfhost/build/phase134/p144-predicate-original-native01/program:     file format elf64-x86-64


Disassembly of section .init:

Disassembly of section .plt:

Disassembly of section .text:

000000000041b4d0 <p111_FID_36_100_105_114_101_99_116_46_112_49_51_49_105_95_105_110_115_101_114_116_>:
  41b4d0:	endbr64 
  41b4d4:	push   %rbp
  41b4d5:	mov    %rsp,%rbp
  41b4d8:	sub    $0x1028,%rsp
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
  41b510:	jne    41bacd <p111_FID_36_100_105_114_101_99_116_46_112_49_51_49_105_95_105_110_115_101_114_116_+0x5fd>
  41b516:	cmp    $0x9a,%rax
  41b51c:	sete   %cl
  41b51f:	movzbl %cl,%ecx
  41b522:	mov    $0xffffffff,%edx
  41b527:	mov    %rbx,%r14
  41b52a:	and    %rdx,%r14
  41b52d:	mov    %r14,-0x8(%rbp)
  41b531:	cmp    $0x0,%ecx
  41b534:	jne    41b8bf <p111_FID_36_100_105_114_101_99_116_46_112_49_51_49_105_95_105_110_115_101_114_116_+0x3ef>
  41b53a:	nopw   0x0(%rax,%rax,1)
  41b540:	cmp    $0x9b,%rax
  41b546:	je     41b5b1 <p111_FID_36_100_105_114_101_99_116_46_112_49_51_49_105_95_105_110_115_101_114_116_+0xe1>
  41b548:	mov    %rbx,-0x1020(%rbp)
  41b54f:	mov    0x10(%rdi),%rax
  41b553:	mov    %rbx,(%rax)
  41b556:	movq   $0x216,0x8(%rax)
  41b55e:	add    $0x10,%rax
  41b562:	mov    %rax,0x10(%rdi)
  41b566:	mov    %r12,-0x1020(%rbp)
  41b56d:	mov    0x10(%rdi),%rax
  41b571:	mov    %r12,(%rax)
  41b574:	movq   $0x217,0x8(%rax)
  41b57c:	add    $0x10,%rax
  41b580:	mov    %rax,0x10(%rdi)
  41b584:	mov    %rsi,-0x1020(%rbp)
  41b58b:	mov    0x10(%rdi),%rax
  41b58f:	mov    %rsi,(%rax)
  41b592:	movq   $0x218,0x8(%rax)
  41b59a:	add    $0x10,%rax
  41b59e:	mov    %rax,0x10(%rdi)
  41b5a2:	mov    $0x4,%esi
  41b5a7:	callq  424d10 <p111_rt_fail>
  41b5ac:	jmpq   41bbb4 <p111_FID_36_100_105_114_101_99_116_46_112_49_51_49_105_95_105_110_115_101_114_116_+0x6e4>
  41b5b1:	lea    -0x1020(%rbp),%rdx
  41b5b8:	mov    %rdi,%r13
  41b5bb:	callq  42a200 <p125_rt_take4>
  41b5c0:	mov    %r13,%rdi
  41b5c3:	mov    -0x1020(%rbp),%rsi
  41b5ca:	mov    -0x1018(%rbp),%r15
  41b5d1:	mov    -0x1010(%rbp),%r14
  41b5d8:	mov    %r14,-0x18(%rbp)
  41b5dc:	mov    %r12,%r13
  41b5df:	mov    -0x1008(%rbp),%r12
  41b5e6:	mov    %r12,-0x10(%rbp)
  41b5ea:	mov    %rdi,%r12
  41b5ed:	callq  4244f0 <p111_rt_keep>
  41b5f2:	mov    %r15,%rsi
  41b5f5:	mov    %r12,%rdi
  41b5f8:	mov    %rax,%r12
  41b5fb:	mov    %rdi,%r15
  41b5fe:	callq  4244f0 <p111_rt_keep>
  41b603:	mov    %r15,%rdi
  41b606:	mov    %rax,%r15
  41b609:	mov    %r12,%rax
  41b60c:	mov    $0xffffffff,%ecx
  41b611:	and    %r15,%rcx
  41b614:	cmp    $0x0,%rcx
  41b618:	mov    %rax,%r12
  41b61b:	sete   %al
  41b61e:	movzbl %al,%eax
  41b621:	cmp    $0x1,%rax
  41b625:	sete   %cl
  41b628:	movzbl %cl,%ecx
  41b62b:	mov    %rax,%rdx
  41b62e:	shr    $0x28,%rdx
  41b632:	and    $0x7fffff,%rdx
  41b639:	cmp    $0x10002,%rdx
  41b640:	sete   %dl
  41b643:	movzbl %dl,%edx
  41b646:	or     %edx,%ecx
  41b648:	jne    41b819 <p111_FID_36_100_105_114_101_99_116_46_112_49_51_49_105_95_105_110_115_101_114_116_+0x349>
  41b64e:	xor    $0x1,%ecx
  41b651:	jne    41b6cf <p111_FID_36_100_105_114_101_99_116_46_112_49_51_49_105_95_105_110_115_101_114_116_+0x1ff>
  41b653:	mov    %eax,%ebx
  41b655:	mov    %r13,%rsi
  41b658:	mov    %rdi,%r13
  41b65b:	callq  424580 <p111_rt_sink>
  41b660:	mov    %r13,%rdi
  41b663:	mov    %r12,%rax
  41b666:	mov    -0x10(%rbp),%r12
  41b66a:	mov    %rax,%rsi
  41b66d:	mov    %rdi,%r13
  41b670:	callq  424580 <p111_rt_sink>
  41b675:	mov    %r13,%rdi
  41b678:	mov    %r15,%rsi
  41b67b:	mov    %rdi,%r13
  41b67e:	callq  424580 <p111_rt_sink>
  41b683:	mov    %r13,%rdi
  41b686:	mov    %r14,%rsi
  41b689:	mov    %rdi,%r13
  41b68c:	callq  424580 <p111_rt_sink>
  41b691:	mov    %r13,%rdi
  41b694:	mov    %r12,%rsi
  41b697:	mov    %rdi,%r12
  41b69a:	callq  424580 <p111_rt_sink>
  41b69f:	mov    %r12,%rdi
  41b6a2:	mov    %rbx,-0x1020(%rbp)
  41b6a9:	mov    0x10(%rdi),%rax
  41b6ad:	mov    %rbx,(%rax)
  41b6b0:	movq   $0x215,0x8(%rax)
  41b6b8:	add    $0x10,%rax
  41b6bc:	mov    %rax,0x10(%rdi)
  41b6c0:	mov    $0x4,%esi
  41b6c5:	callq  424d10 <p111_rt_fail>
  41b6ca:	jmpq   41bbb4 <p111_FID_36_100_105_114_101_99_116_46_112_49_51_49_105_95_105_110_115_101_114_116_+0x6e4>
  41b6cf:	mov    $0x0,%ecx
  41b6d4:	lea    -0x1020(%rbp),%rdx
  41b6db:	mov    $0x0,%esi
  41b6e0:	mov    %rdi,%r14
  41b6e3:	callq  4245f0 <p111_rt_ctor>
  41b6e8:	mov    %r14,%rdi
  41b6eb:	mov    %rax,%rsi
  41b6ee:	mov    %rdi,%r14
  41b6f1:	callq  424580 <p111_rt_sink>
  41b6f6:	mov    %r14,%rdi
  41b6f9:	mov    -0x18(%rbp),%r14
  41b6fd:	mov    %r15,%rsi
  41b700:	mov    %rdi,%r15
  41b703:	callq  4244f0 <p111_rt_keep>
  41b708:	mov    %r15,%rdi
  41b70b:	mov    %rax,%rcx
  41b70e:	mov    %r12,%rax
  41b711:	mov    %rbx,%r15
  41b714:	mov    -0x10(%rbp),%rbx
  41b718:	mov    %r14,%r12
  41b71b:	mov    -0x8(%rbp),%r14
  41b71f:	mov    %r13,-0x1020(%rbp)
  41b726:	mov    %r15,-0x1018(%rbp)
  41b72d:	mov    %rax,-0x1010(%rbp)
  41b734:	mov    %rcx,-0x1008(%rbp)
  41b73b:	mov    %r12,-0x1000(%rbp)
  41b742:	mov    %rbx,-0xff8(%rbp)
  41b749:	mov    %rax,%r12
  41b74c:	mov    $0xffffffff,%eax
  41b751:	and    %r12,%rax
  41b754:	xor    %r14,%rax
  41b757:	mov    $0xffffffff,%edx
  41b75c:	and    %rdx,%rax
  41b75f:	mov    %rax,-0xff0(%rbp)
  41b766:	mov    0x10(%rdi),%rdx
  41b76a:	mov    %r13,(%rdx)
  41b76d:	mov    -0x1018(%rbp),%rsi
  41b774:	mov    %rsi,0x8(%rdx)
  41b778:	mov    -0x1010(%rbp),%rsi
  41b77f:	mov    %rsi,0x10(%rdx)
  41b783:	mov    -0x1008(%rbp),%rsi
  41b78a:	mov    %rsi,0x18(%rdx)
  41b78e:	mov    -0x1000(%rbp),%rsi
  41b795:	mov    %rsi,0x20(%rdx)
  41b799:	mov    -0xff8(%rbp),%rsi
  41b7a0:	mov    %rsi,0x28(%rdx)
  41b7a4:	mov    -0xff0(%rbp),%rsi
  41b7ab:	mov    %rsi,0x30(%rdx)
  41b7af:	movq   $0x20f,0x38(%rdx)
  41b7b7:	add    $0x40,%rdx
  41b7bb:	mov    %rdx,0x10(%rdi)
  41b7bf:	mov    $0xffffffff,%edx
  41b7c4:	and    %rdx,%rcx
  41b7c7:	sub    $0x1,%rcx
  41b7cb:	mov    $0xffffffff,%edx
  41b7d0:	and    %rdx,%rcx
  41b7d3:	and    %rcx,%rax
  41b7d6:	mov    $0xffffffff,%ecx
  41b7db:	and    %rcx,%rax
  41b7de:	cmp    $0x0,%rax
  41b7e2:	sete   %sil
  41b7e6:	movzbl %sil,%esi
  41b7ea:	mov    %rsi,-0x1020(%rbp)
  41b7f1:	mov    %rdi,%rbx
  41b7f4:	callq  40bfa0 <p112w_FID_36_100_105_114_101_99_116_46_66_111_111_108_46_110_111_116_>
  41b7f9:	mov    %rbx,%rdi
  41b7fc:	mov    %rax,-0x1020(%rbp)
  41b803:	mov    $0x1,%edx
  41b808:	lea    -0x1020(%rbp),%rsi
  41b80f:	callq  424ba0 <p111_rt_return>
  41b814:	jmpq   41bbb4 <p111_FID_36_100_105_114_101_99_116_46_112_49_51_49_105_95_105_110_115_101_114_116_+0x6e4>
  41b819:	mov    $0x0,%ecx
  41b81e:	lea    -0x1020(%rbp),%rdx
  41b825:	mov    $0x0,%esi
  41b82a:	mov    %rdi,%r14
  41b82d:	callq  4245f0 <p111_rt_ctor>
  41b832:	mov    %r14,%rdi
  41b835:	mov    %rax,%rsi
  41b838:	mov    %rdi,%r14
  41b83b:	callq  424580 <p111_rt_sink>
  41b840:	mov    %r14,%rdi
  41b843:	mov    %r12,%rax
  41b846:	mov    %rbx,%r12
  41b849:	mov    -0x10(%rbp),%rbx
  41b84d:	mov    -0x18(%rbp),%r14
  41b851:	mov    %rax,-0x1020(%rbp)
  41b858:	mov    %r15,-0x1018(%rbp)
  41b85f:	mov    %r14,-0x1010(%rbp)
  41b866:	mov    %rbx,-0x1008(%rbp)
  41b86d:	lea    -0x1020(%rbp),%rdx
  41b874:	mov    $0x9b,%esi
  41b879:	mov    %rdi,%rbx
  41b87c:	callq  42a130 <p125_rt_ctor4>
  41b881:	mov    %rbx,%rdi
  41b884:	mov    %rax,-0x1020(%rbp)
  41b88b:	mov    %r13,-0x1018(%rbp)
  41b892:	mov    %r12,-0x1010(%rbp)
  41b899:	movq   $0x20,-0x1008(%rbp)
  41b8a4:	mov    $0x4,%ecx
  41b8a9:	lea    -0x1020(%rbp),%rdx
  41b8b0:	mov    $0x201,%esi
  41b8b5:	callq  424b40 <p111_rt_jump>
  41b8ba:	jmpq   41bbb4 <p111_FID_36_100_105_114_101_99_116_46_112_49_51_49_105_95_105_110_115_101_114_116_+0x6e4>
  41b8bf:	cs cs cs mov %r12,%r13
  41b8c5:	mov    %rbx,%r12
  41b8c8:	lea    -0x1020(%rbp),%rdx
  41b8cf:	mov    %rdi,%rbx
  41b8d2:	callq  429d30 <p125_rt_take2>
  41b8d7:	mov    %rbx,%rdi
  41b8da:	mov    -0x1020(%rbp),%rsi
  41b8e1:	mov    -0x1018(%rbp),%rbx
  41b8e8:	mov    %rdi,%r15
  41b8eb:	callq  4244f0 <p111_rt_keep>
  41b8f0:	mov    %r15,%rdi
  41b8f3:	mov    %rax,%rsi
  41b8f6:	mov    $0xffffffff,%eax
  41b8fb:	and    %rsi,%rax
  41b8fe:	xor    %r14,%rax
  41b901:	mov    $0xffffffff,%ecx
  41b906:	mov    %rsi,%r15
  41b909:	mov    %rax,%rsi
  41b90c:	and    %rcx,%rsi
  41b90f:	mov    %rdi,%r14
  41b912:	callq  40b900 <p112w_FID_36_100_105_114_101_99_116_46_105_110_100_101_120_95_115_112_108_105_116_95_98_105_116_>
  41b917:	mov    %r15,%rsi
  41b91a:	mov    %r14,%rdi
  41b91d:	mov    %rax,%r14
  41b920:	mov    %r14,-0x20(%rbp)
  41b924:	mov    $0xffffffff,%eax
  41b929:	and    %r14,%rax
  41b92c:	cmp    $0x0,%rax
  41b930:	mov    %rbx,%r14
  41b933:	sete   %bl
  41b936:	movzbl %bl,%ebx
  41b939:	cmp    $0x1,%rbx
  41b93d:	sete   %al
  41b940:	movzbl %al,%eax
  41b943:	mov    %rbx,%rcx
  41b946:	shr    $0x28,%rcx
  41b94a:	and    $0x7fffff,%rcx
  41b951:	cmp    $0x10002,%rcx
  41b958:	sete   %cl
  41b95b:	movzbl %cl,%ecx
  41b95e:	or     %ecx,%eax
  41b960:	cmp    $0x0,%eax
  41b963:	jne    41ba65 <p111_FID_36_100_105_114_101_99_116_46_112_49_51_49_105_95_105_110_115_101_114_116_+0x595>
  41b969:	xor    $0x1,%eax
  41b96c:	jne    41b9cb <p111_FID_36_100_105_114_101_99_116_46_112_49_51_49_105_95_105_110_115_101_114_116_+0x4fb>
  41b96e:	mov    %r14,%r12
  41b971:	mov    %rsi,%r14
  41b974:	mov    %r13,%rsi
  41b977:	mov    %rdi,%r13
  41b97a:	callq  424580 <p111_rt_sink>
  41b97f:	mov    %r14,%rsi
  41b982:	mov    %r13,%rdi
  41b985:	mov    %rdi,%r13
  41b988:	callq  424580 <p111_rt_sink>
  41b98d:	mov    %r13,%rdi
  41b990:	mov    %r12,%rsi
  41b993:	mov    %rdi,%r12
  41b996:	callq  424580 <p111_rt_sink>
  41b99b:	mov    %r12,%rdi
  41b99e:	mov    %rbx,-0x820(%rbp)
  41b9a5:	mov    0x10(%rdi),%rax
  41b9a9:	mov    %rbx,(%rax)
  41b9ac:	movq   $0x20e,0x8(%rax)
  41b9b4:	add    $0x10,%rax
  41b9b8:	mov    %rax,0x10(%rdi)
  41b9bc:	mov    $0x4,%esi
  41b9c1:	callq  424d10 <p111_rt_fail>
  41b9c6:	jmpq   41bbb4 <p111_FID_36_100_105_114_101_99_116_46_112_49_51_49_105_95_105_110_115_101_114_116_+0x6e4>
  41b9cb:	cs cs cs cs mov %r14,%rbx
  41b9d2:	mov    $0x0,%ecx
  41b9d7:	lea    -0x820(%rbp),%rdx
  41b9de:	mov    %rsi,%r15
  41b9e1:	mov    $0x0,%esi
  41b9e6:	mov    %rdi,%r14
  41b9e9:	callq  4245f0 <p111_rt_ctor>
  41b9ee:	mov    %r14,%rdi
  41b9f1:	mov    %rax,%rsi
  41b9f4:	mov    %rdi,%r14
  41b9f7:	callq  424580 <p111_rt_sink>
  41b9fc:	mov    %r15,%rsi
  41b9ff:	mov    %r14,%rdi
  41ba02:	mov    %rbx,%r14
  41ba05:	mov    -0x20(%rbp),%rbx
  41ba09:	mov    %rsi,-0x820(%rbp)
  41ba10:	mov    %r14,-0x818(%rbp)
  41ba17:	lea    -0x820(%rbp),%rdx
  41ba1e:	mov    $0x9a,%esi
  41ba23:	mov    %rdi,%r14
  41ba26:	callq  429c40 <p125_rt_ctor2>
  41ba2b:	mov    %r14,%rdi
  41ba2e:	mov    %rax,-0x820(%rbp)
  41ba35:	mov    %r13,-0x818(%rbp)
  41ba3c:	mov    %r12,-0x810(%rbp)
  41ba43:	mov    %rbx,-0x808(%rbp)
  41ba4a:	mov    $0x4,%ecx
  41ba4f:	lea    -0x820(%rbp),%rdx
  41ba56:	mov    $0x169,%esi
  41ba5b:	callq  424b40 <p111_rt_jump>
  41ba60:	jmpq   41bbb4 <p111_FID_36_100_105_114_101_99_116_46_112_49_51_49_105_95_105_110_115_101_114_116_+0x6e4>
  41ba65:	mov    %r14,%rbx
  41ba68:	mov    %rdi,%r14
  41ba6b:	callq  424580 <p111_rt_sink>
  41ba70:	mov    %r14,%rdi
  41ba73:	mov    $0x0,%ecx
  41ba78:	lea    -0x820(%rbp),%rdx
  41ba7f:	mov    $0x0,%esi
  41ba84:	mov    %rdi,%r14
  41ba87:	callq  4245f0 <p111_rt_ctor>
  41ba8c:	mov    %r14,%rdi
  41ba8f:	mov    %rax,%rsi
  41ba92:	mov    %rdi,%r14
  41ba95:	callq  424580 <p111_rt_sink>
  41ba9a:	mov    %r14,%rdi
  41ba9d:	mov    %r13,-0x820(%rbp)
  41baa4:	mov    %r12,-0x818(%rbp)
  41baab:	mov    %rbx,-0x810(%rbp)
  41bab2:	mov    $0x3,%ecx
  41bab7:	lea    -0x820(%rbp),%rdx
  41babe:	mov    $0x1ca,%esi
  41bac3:	callq  424b40 <p111_rt_jump>
  41bac8:	jmpq   41bbb4 <p111_FID_36_100_105_114_101_99_116_46_112_49_51_49_105_95_105_110_115_101_114_116_+0x6e4>
  41bacd:	mov    $0x9,%ecx
  41bad2:	lea    -0x1020(%rbp),%rdx
  41bad9:	mov    %rdi,%r13
  41badc:	callq  424770 <p111_rt_take>
  41bae1:	mov    %r13,%rdi
  41bae4:	mov    -0x1020(%rbp),%r13
  41baeb:	mov    -0x1018(%rbp),%r11
  41baf2:	mov    -0x1010(%rbp),%r10
  41baf9:	mov    -0x1008(%rbp),%r9
  41bb00:	mov    -0x1000(%rbp),%r8
  41bb07:	mov    -0xff8(%rbp),%rsi
  41bb0e:	mov    -0xff0(%rbp),%rdx
  41bb15:	mov    -0xfe8(%rbp),%rcx
  41bb1c:	mov    -0xfe0(%rbp),%rax
  41bb23:	mov    %r13,-0x1020(%rbp)
  41bb2a:	mov    %r11,-0x1018(%rbp)
  41bb31:	mov    %r10,-0x1010(%rbp)
  41bb38:	mov    %r9,-0x1008(%rbp)
  41bb3f:	mov    %r8,-0x1000(%rbp)
  41bb46:	mov    %rsi,-0xff8(%rbp)
  41bb4d:	mov    %rdx,-0xff0(%rbp)
  41bb54:	mov    %rcx,-0xfe8(%rbp)
  41bb5b:	mov    %rax,-0xfe0(%rbp)
  41bb62:	mov    $0x9,%ecx
  41bb67:	lea    -0x1020(%rbp),%rdx
  41bb6e:	mov    $0x99,%esi
  41bb73:	mov    %rdi,%r13
  41bb76:	callq  4245f0 <p111_rt_ctor>
  41bb7b:	mov    %r13,%rdi
  41bb7e:	mov    %rax,-0x1020(%rbp)
  41bb85:	mov    %r12,-0x1018(%rbp)
  41bb8c:	mov    %rbx,-0x1010(%rbp)
  41bb93:	movq   $0x20,-0x1008(%rbp)
  41bb9e:	mov    $0x4,%ecx
  41bba3:	lea    -0x1020(%rbp),%rdx
  41bbaa:	mov    $0x201,%esi
  41bbaf:	callq  424b40 <p111_rt_jump>
  41bbb4:	pop    %r15
  41bbb6:	pop    %r14
  41bbb8:	pop    %r13
  41bbba:	pop    %r12
  41bbbc:	pop    %rbx
  41bbbd:	leaveq 
  41bbbe:	retq   

Disassembly of section .fini:
