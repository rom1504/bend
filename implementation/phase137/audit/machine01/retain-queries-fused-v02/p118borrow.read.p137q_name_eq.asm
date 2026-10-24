
/home/ai/bend2/build/publish/bend/selfhost/build/phase111/p137-retain-query-builds01-wide-queries-fused-v02/program:     file format elf64-x86-64


Disassembly of section .init:

Disassembly of section .plt:

Disassembly of section .text:

000000000040a5e0 <p113d_FID_36_112_49_49_56_98_111_114_114_111_119_46_114_101_97_100_46_112_49_51_55_113_95_110_97_109_101_95_101_113_>:
  40a5e0:	endbr64 
  40a5e4:	push   %rbp
  40a5e5:	mov    %rsp,%rbp
  40a5e8:	sub    $0x828,%rsp
  40a5ef:	push   %rbx
  40a5f0:	push   %r12
  40a5f2:	push   %r13
  40a5f4:	push   %r14
  40a5f6:	push   %r15
  40a5f8:	mov    %rsi,%rcx
  40a5fb:	mov    %rdx,%rsi
  40a5fe:	mov    %rsi,%rax
  40a601:	shr    $0x28,%rax
  40a605:	mov    %rax,%r15
  40a608:	and    $0xffff,%r15
  40a60f:	cmp    $0x99,%r15
  40a616:	je     40a982 <p113d_FID_36_112_49_49_56_98_111_114_114_111_119_46_114_101_97_100_46_112_49_51_55_113_95_110_97_109_101_95_101_113_+0x3a2>
  40a61c:	cmp    $0x9a,%r15
  40a623:	sete   %r9b
  40a627:	movzbl %r9b,%r9d
  40a62b:	mov    %r9d,-0x10(%rbp)
  40a62f:	mov    %rsi,%rax
  40a632:	shr    $0x38,%rax
  40a636:	and    $0x7f,%rax
  40a63a:	cmp    $0x2,%rax
  40a63e:	sete   %r14b
  40a642:	movzbl %r14b,%r14d
  40a646:	mov    %rsi,%r11
  40a649:	shr    $0x3f,%r11
  40a64d:	movabs $0xffffffffff,%rax
  40a657:	mov    %rsi,%r8
  40a65a:	and    %rax,%r8
  40a65d:	mov    %r8,%r10
  40a660:	shl    $0x3,%r10
  40a664:	mov    %rcx,%rax
  40a667:	shr    $0x38,%rax
  40a66b:	and    $0x7f,%rax
  40a66f:	cmp    $0x2,%rax
  40a673:	sete   %dl
  40a676:	movzbl %dl,%edx
  40a679:	mov    %edx,-0x20(%rbp)
  40a67c:	mov    %rcx,%rax
  40a67f:	shr    $0x28,%rax
  40a683:	mov    %rax,%r13
  40a686:	and    $0xffff,%r13
  40a68d:	cmp    $0x19,%r13
  40a691:	sete   %al
  40a694:	movzbl %al,%eax
  40a697:	mov    %eax,-0x1c(%rbp)
  40a69a:	mov    %rcx,%rax
  40a69d:	shr    $0x3f,%rax
  40a6a1:	mov    %rax,-0x18(%rbp)
  40a6a5:	movabs $0xffffffffff,%rbx
  40a6af:	and    %rcx,%rbx
  40a6b2:	mov    %rbx,%r12
  40a6b5:	shl    $0x3,%rbx
  40a6b9:	cmp    $0x0,%r9d
  40a6bd:	mov    -0x1c(%rbp),%r9d
  40a6c1:	jne    40a846 <p113d_FID_36_112_49_49_56_98_111_114_114_111_119_46_114_101_97_100_46_112_49_51_55_113_95_110_97_109_101_95_101_113_+0x266>
  40a6c7:	cmp    $0x9b,%r15
  40a6ce:	sete   %r15b
  40a6d2:	movzbl %r15b,%r15d
  40a6d6:	je     40a6ec <p113d_FID_36_112_49_49_56_98_111_114_114_111_119_46_114_101_97_100_46_112_49_51_55_113_95_110_97_109_101_95_101_113_+0x10c>
  40a6d8:	mov    $0x4,%esi
  40a6dd:	callq  432730 <p111_rt_fail>
  40a6e2:	mov    $0x0,%eax
  40a6e7:	jmpq   40a9f6 <p113d_FID_36_112_49_49_56_98_111_114_114_111_119_46_114_101_97_100_46_112_49_51_55_113_95_110_97_109_101_95_101_113_+0x416>
  40a6ec:	test   %r14d,%r15d
  40a6ef:	jne    40a723 <p113d_FID_36_112_49_49_56_98_111_114_114_111_119_46_114_101_97_100_46_112_49_51_55_113_95_110_97_109_101_95_101_113_+0x143>
  40a6f1:	mov    $0x4,%r8d
  40a6f7:	mov    %rcx,%r15
  40a6fa:	mov    $0x9b,%ecx
  40a6ff:	lea    -0x820(%rbp),%rdx
  40a706:	mov    %rdi,%r14
  40a709:	callq  4369d0 <p118_rt_borrow_fields>
  40a70e:	mov    %r15,%rcx
  40a711:	mov    %r14,%rdi
  40a714:	mov    -0x1c(%rbp),%esi
  40a717:	mov    -0x18(%rbp),%rax
  40a71b:	mov    -0x20(%rbp),%edx
  40a71e:	mov    %esi,%r9d
  40a721:	jmp    40a781 <p113d_FID_36_112_49_49_56_98_111_114_114_111_119_46_114_101_97_100_46_112_49_51_55_113_95_110_97_109_101_95_101_113_+0x1a1>
  40a723:	mov    %r9d,%esi
  40a726:	mov    %r8,%r9
  40a729:	mov    (%rdi),%r8
  40a72c:	cmp    $0x0,%r11
  40a730:	jne    40a737 <p113d_FID_36_112_49_49_56_98_111_114_114_111_119_46_114_101_97_100_46_112_49_51_55_113_95_110_97_109_101_95_101_113_+0x157>
  40a732:	xchg   %rsi,%r9
  40a735:	jmp    40a74e <p113d_FID_36_112_49_49_56_98_111_114_114_111_119_46_114_101_97_100_46_112_49_51_55_113_95_110_97_109_101_95_101_113_+0x16e>
  40a737:	mov    %esi,%r9d
  40a73a:	mov    (%r10,%r8,1),%esi
  40a73e:	mov    0x4(%r10,%r8,1),%r10d
  40a743:	shl    $0x20,%r10
  40a747:	or     %r10,%rsi
  40a74a:	shr    $0x18,%rsi
  40a74e:	shl    $0x3,%rsi
  40a752:	mov    (%rsi,%r8,1),%r10
  40a756:	mov    %r10,-0x820(%rbp)
  40a75d:	mov    0x8(%rsi,%r8,1),%r10
  40a762:	mov    %r10,-0x818(%rbp)
  40a769:	mov    0x10(%rsi,%r8,1),%r10
  40a76e:	mov    %r10,-0x810(%rbp)
  40a775:	mov    0x18(%rsi,%r8,1),%rsi
  40a77a:	mov    %rsi,-0x808(%rbp)
  40a781:	cmp    $0x18,%r13
  40a785:	je     40a82b <p113d_FID_36_112_49_49_56_98_111_114_114_111_119_46_114_101_97_100_46_112_49_51_55_113_95_110_97_109_101_95_101_113_+0x24b>
  40a78b:	cmp    $0x19,%r13
  40a78f:	je     40a7a5 <p113d_FID_36_112_49_49_56_98_111_114_114_111_119_46_114_101_97_100_46_112_49_51_55_113_95_110_97_109_101_95_101_113_+0x1c5>
  40a791:	mov    $0x4,%esi
  40a796:	callq  432730 <p111_rt_fail>
  40a79b:	mov    $0x0,%eax
  40a7a0:	jmpq   40a9f6 <p113d_FID_36_112_49_49_56_98_111_114_114_111_119_46_114_101_97_100_46_112_49_51_55_113_95_110_97_109_101_95_101_113_+0x416>
  40a7a5:	test   %edx,%r9d
  40a7a8:	jne    40a7cf <p113d_FID_36_112_49_49_56_98_111_114_114_111_119_46_114_101_97_100_46_112_49_51_55_113_95_110_97_109_101_95_101_113_+0x1ef>
  40a7aa:	mov    $0x2,%r8d
  40a7b0:	mov    %rcx,%rbx
  40a7b3:	mov    $0x19,%ecx
  40a7b8:	lea    -0x820(%rbp),%rdx
  40a7bf:	mov    %rbx,%rsi
  40a7c2:	mov    %rdi,%rbx
  40a7c5:	callq  4369d0 <p118_rt_borrow_fields>
  40a7ca:	mov    %rbx,%rdi
  40a7cd:	jmp    40a810 <p113d_FID_36_112_49_49_56_98_111_114_114_111_119_46_114_101_97_100_46_112_49_51_55_113_95_110_97_109_101_95_101_113_+0x230>
  40a7cf:	mov    (%rdi),%rcx
  40a7d2:	cmp    $0x0,%rax
  40a7d6:	jne    40a7dd <p113d_FID_36_112_49_49_56_98_111_114_114_111_119_46_114_101_97_100_46_112_49_51_55_113_95_110_97_109_101_95_101_113_+0x1fd>
  40a7d8:	mov    %r12,%rbx
  40a7db:	jmp    40a7f2 <p113d_FID_36_112_49_49_56_98_111_114_114_111_119_46_114_101_97_100_46_112_49_51_55_113_95_110_97_109_101_95_101_113_+0x212>
  40a7dd:	mov    (%rbx,%rcx,1),%eax
  40a7e0:	mov    0x4(%rbx,%rcx,1),%edx
  40a7e4:	shl    $0x20,%rdx
  40a7e8:	or     %rdx,%rax
  40a7eb:	mov    %rax,%rbx
  40a7ee:	shr    $0x18,%rbx
  40a7f2:	mov    %rbx,%rax
  40a7f5:	shl    $0x3,%rax
  40a7f9:	mov    (%rax,%rcx,1),%rdx
  40a7fd:	mov    %rdx,-0x820(%rbp)
  40a804:	mov    0x8(%rax,%rcx,1),%rax
  40a809:	mov    %rax,-0x818(%rbp)
  40a810:	mov    $0x0,%ecx
  40a815:	lea    -0x820(%rbp),%rdx
  40a81c:	mov    $0x1,%esi
  40a821:	callq  4338d0 <p111_rt_special_ctor>
  40a826:	jmpq   40a9f6 <p113d_FID_36_112_49_49_56_98_111_114_114_111_119_46_114_101_97_100_46_112_49_51_55_113_95_110_97_109_101_95_101_113_+0x416>
  40a82b:	mov    $0x0,%ecx
  40a830:	lea    -0x820(%rbp),%rdx
  40a837:	mov    $0x2,%esi
  40a83c:	callq  4338d0 <p111_rt_special_ctor>
  40a841:	jmpq   40a9f6 <p113d_FID_36_112_49_49_56_98_111_114_114_111_119_46_114_101_97_100_46_112_49_51_55_113_95_110_97_109_101_95_101_113_+0x416>
  40a846:	mov    -0x10(%rbp),%r15d
  40a84a:	test   %r14d,%r15d
  40a84d:	jne    40a87e <p113d_FID_36_112_49_49_56_98_111_114_114_111_119_46_114_101_97_100_46_112_49_51_55_113_95_110_97_109_101_95_101_113_+0x29e>
  40a84f:	mov    $0x2,%r8d
  40a855:	mov    %rcx,%r15
  40a858:	mov    $0x9a,%ecx
  40a85d:	lea    -0x820(%rbp),%rdx
  40a864:	mov    %rdi,%r14
  40a867:	callq  4369d0 <p118_rt_borrow_fields>
  40a86c:	mov    %r15,%rcx
  40a86f:	mov    %r14,%rdi
  40a872:	mov    -0x1c(%rbp),%esi
  40a875:	mov    -0x18(%rbp),%rax
  40a879:	mov    -0x20(%rbp),%edx
  40a87c:	jmp    40a8c0 <p113d_FID_36_112_49_49_56_98_111_114_114_111_119_46_114_101_97_100_46_112_49_51_55_113_95_110_97_109_101_95_101_113_+0x2e0>
  40a87e:	mov    %r9d,%esi
  40a881:	mov    (%rdi),%r9
  40a884:	cmp    $0x0,%r11
  40a888:	je     40a8a5 <p113d_FID_36_112_49_49_56_98_111_114_114_111_119_46_114_101_97_100_46_112_49_51_55_113_95_110_97_109_101_95_101_113_+0x2c5>
  40a88a:	cs cs cs mov %cs:(%r10,%r9,1),%r8d
  40a892:	cs cs mov %cs:0x4(%r10,%r9,1),%r10d
  40a89a:	shl    $0x20,%r10
  40a89e:	or     %r10,%r8
  40a8a1:	shr    $0x18,%r8
  40a8a5:	shl    $0x3,%r8
  40a8a9:	mov    (%r8,%r9,1),%r10
  40a8ad:	mov    %r10,-0x820(%rbp)
  40a8b4:	mov    0x8(%r8,%r9,1),%r8
  40a8b9:	mov    %r8,-0x818(%rbp)
  40a8c0:	cmp    $0x18,%r13
  40a8c4:	je     40a96a <p113d_FID_36_112_49_49_56_98_111_114_114_111_119_46_114_101_97_100_46_112_49_51_55_113_95_110_97_109_101_95_101_113_+0x38a>
  40a8ca:	cmp    $0x19,%r13
  40a8ce:	je     40a8e5 <p113d_FID_36_112_49_49_56_98_111_114_114_111_119_46_114_101_97_100_46_112_49_51_55_113_95_110_97_109_101_95_101_113_+0x305>
  40a8d0:	cs mov $0x4,%esi
  40a8d6:	callq  432730 <p111_rt_fail>
  40a8db:	mov    $0x0,%eax
  40a8e0:	jmpq   40a9f6 <p113d_FID_36_112_49_49_56_98_111_114_114_111_119_46_114_101_97_100_46_112_49_51_55_113_95_110_97_109_101_95_101_113_+0x416>
  40a8e5:	test   %edx,%esi
  40a8e7:	jne    40a90e <p113d_FID_36_112_49_49_56_98_111_114_114_111_119_46_114_101_97_100_46_112_49_51_55_113_95_110_97_109_101_95_101_113_+0x32e>
  40a8e9:	mov    $0x2,%r8d
  40a8ef:	mov    %rcx,%rbx
  40a8f2:	mov    $0x19,%ecx
  40a8f7:	lea    -0x820(%rbp),%rdx
  40a8fe:	mov    %rbx,%rsi
  40a901:	mov    %rdi,%rbx
  40a904:	callq  4369d0 <p118_rt_borrow_fields>
  40a909:	mov    %rbx,%rdi
  40a90c:	jmp    40a94f <p113d_FID_36_112_49_49_56_98_111_114_114_111_119_46_114_101_97_100_46_112_49_51_55_113_95_110_97_109_101_95_101_113_+0x36f>
  40a90e:	mov    (%rdi),%rcx
  40a911:	cmp    $0x0,%rax
  40a915:	jne    40a91c <p113d_FID_36_112_49_49_56_98_111_114_114_111_119_46_114_101_97_100_46_112_49_51_55_113_95_110_97_109_101_95_101_113_+0x33c>
  40a917:	mov    %r12,%rbx
  40a91a:	jmp    40a931 <p113d_FID_36_112_49_49_56_98_111_114_114_111_119_46_114_101_97_100_46_112_49_51_55_113_95_110_97_109_101_95_101_113_+0x351>
  40a91c:	mov    (%rbx,%rcx,1),%eax
  40a91f:	mov    0x4(%rbx,%rcx,1),%edx
  40a923:	shl    $0x20,%rdx
  40a927:	or     %rdx,%rax
  40a92a:	mov    %rax,%rbx
  40a92d:	shr    $0x18,%rbx
  40a931:	mov    %rbx,%rax
  40a934:	shl    $0x3,%rax
  40a938:	mov    (%rax,%rcx,1),%rdx
  40a93c:	mov    %rdx,-0x820(%rbp)
  40a943:	mov    0x8(%rax,%rcx,1),%rax
  40a948:	mov    %rax,-0x818(%rbp)
  40a94f:	mov    $0x0,%ecx
  40a954:	lea    -0x820(%rbp),%rdx
  40a95b:	mov    $0x1,%esi
  40a960:	callq  4338d0 <p111_rt_special_ctor>
  40a965:	jmpq   40a9f6 <p113d_FID_36_112_49_49_56_98_111_114_114_111_119_46_114_101_97_100_46_112_49_51_55_113_95_110_97_109_101_95_101_113_+0x416>
  40a96a:	mov    $0x0,%ecx
  40a96f:	lea    -0x820(%rbp),%rdx
  40a976:	mov    $0x2,%esi
  40a97b:	callq  4338d0 <p111_rt_special_ctor>
  40a980:	jmp    40a9f6 <p113d_FID_36_112_49_49_56_98_111_114_114_111_119_46_114_101_97_100_46_112_49_51_55_113_95_110_97_109_101_95_101_113_+0x416>
  40a982:	mov    $0x9,%r8d
  40a988:	mov    %rcx,%r12
  40a98b:	mov    $0x99,%ecx
  40a990:	lea    -0x820(%rbp),%rdx
  40a997:	mov    %rdi,%rbx
  40a99a:	callq  4369d0 <p118_rt_borrow_fields>
  40a99f:	mov    %r12,%rcx
  40a9a2:	mov    %rbx,%rdi
  40a9a5:	mov    -0x820(%rbp),%rdx
  40a9ac:	mov    %rcx,%r13
  40a9af:	mov    $0x0,%ecx
  40a9b4:	mov    %rdx,%r12
  40a9b7:	lea    -0x820(%rbp),%rdx
  40a9be:	mov    $0x2,%esi
  40a9c3:	mov    %rdi,%rbx
  40a9c6:	callq  4338d0 <p111_rt_special_ctor>
  40a9cb:	mov    %r12,%rdx
  40a9ce:	mov    %rbx,%rdi
  40a9d1:	mov    %rax,%rcx
  40a9d4:	mov    %rdx,%r12
  40a9d7:	mov    %r13,%rdx
  40a9da:	mov    %r12,%rsi
  40a9dd:	mov    %rdi,%rbx
  40a9e0:	callq  405870 <p113d_FID_36_112_49_49_56_98_111_114_114_111_119_46_114_101_97_100_46_112_56_56_95_115_116_114_105_110_103_95_101_113_95_103_111_>
  40a9e5:	mov    %r13,%rcx
  40a9e8:	mov    %r12,%rdx
  40a9eb:	mov    %rbx,%rdi
  40a9ee:	mov    %rax,%rsi
  40a9f1:	callq  405cc0 <p113d_FID_36_112_49_49_56_98_111_114_114_111_119_46_114_101_97_100_46_112_57_56_95_101_113_95_102_105_110_105_115_104_>
  40a9f6:	pop    %r15
  40a9f8:	pop    %r14
  40a9fa:	pop    %r13
  40a9fc:	pop    %r12
  40a9fe:	pop    %rbx
  40a9ff:	leaveq 
  40aa00:	retq   

Disassembly of section .fini:
