
/home/ai/bend2/build/publish/bend/selfhost/build/phase111/p137-query-v02-builds01-wide-record-fused-v02/program:     file format elf64-x86-64


Disassembly of section .init:

Disassembly of section .plt:

Disassembly of section .text:

000000000040e5c0 <p113d_FID_36_100_105_114_101_99_116_46_112_49_51_55_113_95_114_101_112_101_97_116_>:
  40e5c0:	endbr64 
  40e5c4:	push   %rbp
  40e5c5:	mov    %rsp,%rbp
  40e5c8:	sub    $0x178,%rsp
  40e5cf:	push   %rbx
  40e5d0:	push   %r12
  40e5d2:	push   %r13
  40e5d4:	push   %r14
  40e5d6:	push   %r15
  40e5d8:	mov    %r9,%rax
  40e5db:	mov    %r8,%r13
  40e5de:	mov    %rcx,%r12
  40e5e1:	mov    %rdx,%rbx
  40e5e4:	mov    %rbx,%rdx
  40e5e7:	mov    %r12,%r14
  40e5ea:	mov    %rax,-0xd0(%rbp)
  40e5f1:	data16 nopw %cs:0x0(%rax,%rax,1)
  40e5fc:	nopl   0x0(%rax)
  40e600:	cmp    $0x0,%rsi
  40e604:	je     40ebda <p113d_FID_36_100_105_114_101_99_116_46_112_49_51_55_113_95_114_101_112_101_97_116_+0x61a>
  40e60a:	cs cs cs cs mov %rsi,%r12
  40e611:	cs cs cs cs mov %rdx,%rsi
  40e618:	mov    %rdi,%rbx
  40e61b:	callq  433210 <p111_rt_keep>
  40e620:	mov    %r14,%rcx
  40e623:	mov    %r12,%rsi
  40e626:	mov    %rbx,%rdi
  40e629:	mov    %rax,%r14
  40e62c:	mov    %rsi,%r12
  40e62f:	mov    %rcx,%rsi
  40e632:	mov    %rdi,%rbx
  40e635:	callq  433210 <p111_rt_keep>
  40e63a:	mov    %r13,%r8
  40e63d:	mov    %r12,%rsi
  40e640:	mov    %rbx,%rdi
  40e643:	mov    %rax,%r13
  40e646:	mov    %r13,-0x70(%rbp)
  40e64a:	mov    %rsi,%r12
  40e64d:	mov    %r8,%rsi
  40e650:	mov    %rdi,%rbx
  40e653:	callq  433210 <p111_rt_keep>
  40e658:	mov    %r12,%rsi
  40e65b:	mov    %rbx,%rdi
  40e65e:	mov    %rax,%r15
  40e661:	mov    %rsi,%r12
  40e664:	mov    %r14,%rsi
  40e667:	mov    %rdi,%rbx
  40e66a:	callq  4332a0 <p111_rt_sink>
  40e66f:	mov    %r13,%rcx
  40e672:	mov    %r12,%rsi
  40e675:	mov    %rbx,%rdi
  40e678:	mov    %rsi,%r12
  40e67b:	mov    %rcx,%rsi
  40e67e:	mov    %rdi,%rbx
  40e681:	callq  433210 <p111_rt_keep>
  40e686:	mov    %r12,%rsi
  40e689:	mov    %rbx,%rdi
  40e68c:	mov    %rax,%r13
  40e68f:	mov    %r13,%rax
  40e692:	shr    $0x28,%rax
  40e696:	and    $0xffff,%rax
  40e69c:	mov    %rax,-0x68(%rbp)
  40e6a0:	cmp    $0x9c,%rax
  40e6a6:	je     40e6eb <p113d_FID_36_100_105_114_101_99_116_46_112_49_51_55_113_95_114_101_112_101_97_116_+0x12b>
  40e6a8:	mov    %rsi,%r12
  40e6ab:	mov    %r15,%rsi
  40e6ae:	mov    %rdi,%rbx
  40e6b1:	callq  4332a0 <p111_rt_sink>
  40e6b6:	mov    %r12,%rsi
  40e6b9:	mov    %rbx,%rdi
  40e6bc:	mov    %rsi,%rbx
  40e6bf:	mov    $0x4,%esi
  40e6c4:	mov    %rdi,%r12
  40e6c7:	callq  433a30 <p111_rt_fail>
  40e6cc:	mov    %r14,%rdx
  40e6cf:	mov    %r12,%rdi
  40e6d2:	mov    -0x68(%rbp),%rax
  40e6d6:	mov    -0x70(%rbp),%rcx
  40e6da:	mov    %r13,%rsi
  40e6dd:	mov    %r15,%r8
  40e6e0:	mov    $0x0,%r9d
  40e6e6:	jmpq   40e86c <p113d_FID_36_100_105_114_101_99_116_46_112_49_51_55_113_95_114_101_112_101_97_116_+0x2ac>
  40e6eb:	mov    %rsi,%rbx
  40e6ee:	mov    %r14,%rdx
  40e6f1:	mov    $0x9,%ecx
  40e6f6:	mov    %rdx,%r14
  40e6f9:	lea    -0x170(%rbp),%rdx
  40e700:	mov    %r13,%rsi
  40e703:	mov    %rdi,%r12
  40e706:	callq  433490 <p111_rt_take>
  40e70b:	mov    %r12,%rdi
  40e70e:	mov    -0x170(%rbp),%rsi
  40e715:	mov    %rsi,-0x48(%rbp)
  40e719:	mov    -0x168(%rbp),%rsi
  40e720:	mov    -0x160(%rbp),%rax
  40e727:	mov    %rax,-0x10(%rbp)
  40e72b:	mov    -0x158(%rbp),%rax
  40e732:	mov    %rax,-0x18(%rbp)
  40e736:	mov    -0x150(%rbp),%rax
  40e73d:	mov    %rax,-0x20(%rbp)
  40e741:	mov    -0x148(%rbp),%rax
  40e748:	mov    %rax,-0x28(%rbp)
  40e74c:	mov    -0x140(%rbp),%rax
  40e753:	mov    %rax,-0x30(%rbp)
  40e757:	mov    -0x138(%rbp),%rax
  40e75e:	mov    %rax,-0x38(%rbp)
  40e762:	mov    -0x130(%rbp),%rax
  40e769:	mov    %rax,-0x40(%rbp)
  40e76d:	mov    %rdi,%r12
  40e770:	callq  4332a0 <p111_rt_sink>
  40e775:	mov    %r12,%rdi
  40e778:	mov    -0x10(%rbp),%rsi
  40e77c:	mov    %rdi,%r12
  40e77f:	callq  4332a0 <p111_rt_sink>
  40e784:	mov    %r12,%rdi
  40e787:	mov    -0x18(%rbp),%rsi
  40e78b:	mov    %rdi,%r12
  40e78e:	callq  4332a0 <p111_rt_sink>
  40e793:	mov    %r12,%rdi
  40e796:	mov    -0x20(%rbp),%rsi
  40e79a:	mov    %rdi,%r12
  40e79d:	callq  4332a0 <p111_rt_sink>
  40e7a2:	mov    %r12,%rdi
  40e7a5:	mov    -0x28(%rbp),%rsi
  40e7a9:	mov    %rdi,%r12
  40e7ac:	callq  4332a0 <p111_rt_sink>
  40e7b1:	mov    %r12,%rdi
  40e7b4:	mov    -0x30(%rbp),%rsi
  40e7b8:	mov    %rdi,%r12
  40e7bb:	callq  4332a0 <p111_rt_sink>
  40e7c0:	mov    %r12,%rdi
  40e7c3:	mov    -0x38(%rbp),%rsi
  40e7c7:	mov    %rdi,%r12
  40e7ca:	callq  4332a0 <p111_rt_sink>
  40e7cf:	mov    %r12,%rdi
  40e7d2:	mov    -0x40(%rbp),%rsi
  40e7d6:	mov    %rdi,%r12
  40e7d9:	callq  4332a0 <p111_rt_sink>
  40e7de:	mov    %r12,%rdi
  40e7e1:	mov    -0x48(%rbp),%rsi
  40e7e5:	mov    %rdi,%r12
  40e7e8:	callq  433210 <p111_rt_keep>
  40e7ed:	mov    %r12,%rdi
  40e7f0:	mov    %rax,-0x50(%rbp)
  40e7f4:	mov    %r15,%rsi
  40e7f7:	mov    %rdi,%r12
  40e7fa:	callq  433210 <p111_rt_keep>
  40e7ff:	mov    %r14,%rdx
  40e802:	mov    %r12,%rdi
  40e805:	mov    %rax,%rsi
  40e808:	mov    %rsi,%rax
  40e80b:	mov    -0x50(%rbp),%rsi
  40e80f:	mov    %rax,-0x58(%rbp)
  40e813:	mov    $0x1,%ecx
  40e818:	mov    %rdx,%r14
  40e81b:	mov    %rax,%rdx
  40e81e:	mov    %rdi,%r12
  40e821:	callq  405c00 <p113d_FID_36_100_105_114_101_99_116_46_112_56_56_95_115_116_114_105_110_103_95_101_113_95_103_111_>
  40e826:	mov    %r13,%rsi
  40e829:	mov    %r12,%rdi
  40e82c:	mov    %rax,-0x60(%rbp)
  40e830:	mov    %rsi,%r13
  40e833:	mov    -0x50(%rbp),%rsi
  40e837:	mov    %rdi,%r12
  40e83a:	callq  4332a0 <p111_rt_sink>
  40e83f:	mov    %r13,%rsi
  40e842:	mov    %r12,%rdi
  40e845:	mov    %rsi,%r13
  40e848:	mov    -0x58(%rbp),%rsi
  40e84c:	mov    %rdi,%r12
  40e84f:	callq  4332a0 <p111_rt_sink>
  40e854:	mov    %r15,%r8
  40e857:	mov    %r14,%rdx
  40e85a:	mov    %r13,%rsi
  40e85d:	mov    %r12,%rdi
  40e860:	mov    -0x68(%rbp),%rax
  40e864:	mov    -0x70(%rbp),%rcx
  40e868:	mov    -0x60(%rbp),%r9
  40e86c:	cmp    $0x1,%r9
  40e870:	mov    %rdx,%r13
  40e873:	sete   %dl
  40e876:	movzbl %dl,%edx
  40e879:	shr    $0x28,%r9
  40e87d:	and    $0x7fffff,%r9
  40e884:	cmp    $0x10002,%r9
  40e88b:	mov    %r8,%r15
  40e88e:	sete   %r8b
  40e892:	movzbl %r8b,%r8d
  40e896:	mov    %rcx,%r14
  40e899:	mov    %edx,%ecx
  40e89b:	or     %r8d,%ecx
  40e89e:	mov    %ecx,-0xdc(%rbp)
  40e8a4:	mov    %ecx,%r9d
  40e8a7:	xor    $0x1,%r9d
  40e8ab:	jne    40e8e2 <p113d_FID_36_100_105_114_101_99_116_46_112_49_51_55_113_95_114_101_112_101_97_116_+0x322>
  40e8ad:	or     %r8d,%edx
  40e8b0:	jne    40e8d9 <p113d_FID_36_100_105_114_101_99_116_46_112_49_51_55_113_95_114_101_112_101_97_116_+0x319>
  40e8b2:	cs mov %rsi,%r14
  40e8b6:	mov    $0x4,%esi
  40e8bb:	mov    %rdi,%r12
  40e8be:	callq  433a30 <p111_rt_fail>
  40e8c3:	mov    %r14,%rsi
  40e8c6:	mov    %r12,%rdi
  40e8c9:	mov    -0xdc(%rbp),%eax
  40e8cf:	mov    %eax,%ecx
  40e8d1:	mov    -0x68(%rbp),%rax
  40e8d5:	mov    -0x70(%rbp),%r14
  40e8d9:	mov    %rcx,-0xd8(%rbp)
  40e8e0:	jmp    40e8ed <p113d_FID_36_100_105_114_101_99_116_46_112_49_51_55_113_95_114_101_112_101_97_116_+0x32d>
  40e8e2:	movq   $0x0,-0xd8(%rbp)
  40e8ed:	cmp    $0x9c,%rax
  40e8f3:	je     40e94b <p113d_FID_36_100_105_114_101_99_116_46_112_49_51_55_113_95_114_101_112_101_97_116_+0x38b>
  40e8f5:	mov    %rbx,%rsi
  40e8f8:	mov    %rsi,%r12
  40e8fb:	movabs $0x20019000310865a,%rsi
  40e905:	mov    %rdi,%rbx
  40e908:	callq  4332a0 <p111_rt_sink>
  40e90d:	mov    %r12,%rsi
  40e910:	mov    %rbx,%rdi
  40e913:	mov    %rsi,%r12
  40e916:	mov    $0x4,%esi
  40e91b:	mov    %rdi,%rbx
  40e91e:	callq  433a30 <p111_rt_fail>
  40e923:	mov    %r14,%rcx
  40e926:	mov    %r13,%rdx
  40e929:	mov    %rbx,%rdi
  40e92c:	mov    -0xd8(%rbp),%rax
  40e933:	mov    -0xd0(%rbp),%r9
  40e93a:	mov    %r12,%rsi
  40e93d:	mov    %r15,%r8
  40e940:	mov    $0x0,%r10d
  40e946:	jmpq   40eb1e <p113d_FID_36_100_105_114_101_99_116_46_112_49_51_55_113_95_114_101_112_101_97_116_+0x55e>
  40e94b:	mov    %rbx,%r12
  40e94e:	mov    %r14,%rcx
  40e951:	mov    %r13,%rdx
  40e954:	mov    %rcx,%r14
  40e957:	mov    $0x9,%ecx
  40e95c:	mov    %rdx,%r13
  40e95f:	lea    -0x128(%rbp),%rdx
  40e966:	mov    %rdi,%rbx
  40e969:	callq  433490 <p111_rt_take>
  40e96e:	mov    %rbx,%rdi
  40e971:	mov    -0x128(%rbp),%rsi
  40e978:	mov    %rsi,-0xb0(%rbp)
  40e97f:	mov    -0x120(%rbp),%rsi
  40e986:	mov    -0x118(%rbp),%rax
  40e98d:	mov    %rax,-0x78(%rbp)
  40e991:	mov    -0x110(%rbp),%rax
  40e998:	mov    %rax,-0x80(%rbp)
  40e99c:	mov    -0x108(%rbp),%rax
  40e9a3:	mov    %rax,-0x88(%rbp)
  40e9aa:	mov    -0x100(%rbp),%rax
  40e9b1:	mov    %rax,-0x90(%rbp)
  40e9b8:	mov    -0xf8(%rbp),%rax
  40e9bf:	mov    %rax,-0x98(%rbp)
  40e9c6:	mov    -0xf0(%rbp),%rax
  40e9cd:	mov    %rax,-0xa0(%rbp)
  40e9d4:	mov    -0xe8(%rbp),%rax
  40e9db:	mov    %rax,-0xa8(%rbp)
  40e9e2:	mov    %rdi,%rbx
  40e9e5:	callq  4332a0 <p111_rt_sink>
  40e9ea:	mov    %rbx,%rdi
  40e9ed:	mov    -0x78(%rbp),%rsi
  40e9f1:	mov    %rdi,%rbx
  40e9f4:	callq  4332a0 <p111_rt_sink>
  40e9f9:	mov    %rbx,%rdi
  40e9fc:	mov    -0x80(%rbp),%rsi
  40ea00:	mov    %rdi,%rbx
  40ea03:	callq  4332a0 <p111_rt_sink>
  40ea08:	mov    %rbx,%rdi
  40ea0b:	mov    -0x88(%rbp),%rsi
  40ea12:	mov    %rdi,%rbx
  40ea15:	callq  4332a0 <p111_rt_sink>
  40ea1a:	mov    %rbx,%rdi
  40ea1d:	mov    -0x90(%rbp),%rsi
  40ea24:	mov    %rdi,%rbx
  40ea27:	callq  4332a0 <p111_rt_sink>
  40ea2c:	mov    %rbx,%rdi
  40ea2f:	mov    -0x98(%rbp),%rsi
  40ea36:	mov    %rdi,%rbx
  40ea39:	callq  4332a0 <p111_rt_sink>
  40ea3e:	mov    %rbx,%rdi
  40ea41:	mov    -0xa0(%rbp),%rsi
  40ea48:	mov    %rdi,%rbx
  40ea4b:	callq  4332a0 <p111_rt_sink>
  40ea50:	mov    %rbx,%rdi
  40ea53:	mov    -0xa8(%rbp),%rsi
  40ea5a:	mov    %rdi,%rbx
  40ea5d:	callq  4332a0 <p111_rt_sink>
  40ea62:	mov    %rbx,%rdi
  40ea65:	mov    -0xb0(%rbp),%rsi
  40ea6c:	mov    %rdi,%rbx
  40ea6f:	callq  433210 <p111_rt_keep>
  40ea74:	mov    %rbx,%rdi
  40ea77:	mov    %rax,-0xb8(%rbp)
  40ea7e:	movabs $0x20019000310865a,%rsi
  40ea88:	mov    %rdi,%rbx
  40ea8b:	callq  433210 <p111_rt_keep>
  40ea90:	mov    %r14,%rcx
  40ea93:	mov    %r13,%rdx
  40ea96:	mov    %rbx,%rdi
  40ea99:	mov    %rax,%rsi
  40ea9c:	mov    %rsi,%rax
  40ea9f:	mov    -0xb8(%rbp),%rsi
  40eaa6:	mov    %rax,-0xc0(%rbp)
  40eaad:	mov    %rcx,%r14
  40eab0:	mov    $0x1,%ecx
  40eab5:	mov    %rdx,%r13
  40eab8:	mov    %rax,%rdx
  40eabb:	mov    %rdi,%rbx
  40eabe:	callq  405c00 <p113d_FID_36_100_105_114_101_99_116_46_112_56_56_95_115_116_114_105_110_103_95_101_113_95_103_111_>
  40eac3:	mov    %r12,%rsi
  40eac6:	mov    %rbx,%rdi
  40eac9:	mov    %rax,-0xc8(%rbp)
  40ead0:	mov    %rsi,%r12
  40ead3:	mov    -0xb8(%rbp),%rsi
  40eada:	mov    %rdi,%rbx
  40eadd:	callq  4332a0 <p111_rt_sink>
  40eae2:	mov    %r12,%rsi
  40eae5:	mov    %rbx,%rdi
  40eae8:	mov    %rsi,%r12
  40eaeb:	mov    -0xc0(%rbp),%rsi
  40eaf2:	mov    %rdi,%rbx
  40eaf5:	callq  4332a0 <p111_rt_sink>
  40eafa:	mov    %r15,%r8
  40eafd:	mov    %r14,%rcx
  40eb00:	mov    %r13,%rdx
  40eb03:	mov    %r12,%rsi
  40eb06:	mov    %rbx,%rdi
  40eb09:	mov    -0xd8(%rbp),%rax
  40eb10:	mov    -0xd0(%rbp),%r9
  40eb17:	mov    -0xc8(%rbp),%r10
  40eb1e:	cmp    $0x1,%r10
  40eb22:	mov    %rcx,%r14
  40eb25:	sete   %cl
  40eb28:	movzbl %cl,%ecx
  40eb2b:	shr    $0x28,%r10
  40eb2f:	and    $0x7fffff,%r10
  40eb36:	cmp    $0x10002,%r10
  40eb3d:	mov    %rdx,%r13
  40eb40:	sete   %dl
  40eb43:	movzbl %dl,%edx
  40eb46:	mov    %r9,%rbx
  40eb49:	mov    %ecx,%r9d
  40eb4c:	or     %edx,%r9d
  40eb4f:	mov    %r9d,-0xe0(%rbp)
  40eb56:	mov    %r8,%r15
  40eb59:	mov    %r9d,%r8d
  40eb5c:	xor    $0x1,%r8d
  40eb60:	jne    40ebaa <p113d_FID_36_100_105_114_101_99_116_46_112_49_51_55_113_95_114_101_112_101_97_116_+0x5ea>
  40eb62:	or     %edx,%ecx
  40eb64:	jne    40eb9f <p113d_FID_36_100_105_114_101_99_116_46_112_49_51_55_113_95_114_101_112_101_97_116_+0x5df>
  40eb66:	mov    %rsi,%r12
  40eb69:	mov    $0x4,%esi
  40eb6e:	mov    %rdi,%rbx
  40eb71:	callq  433a30 <p111_rt_fail>
  40eb76:	mov    %r15,%r8
  40eb79:	mov    %r14,%rcx
  40eb7c:	mov    %r13,%rdx
  40eb7f:	mov    %r12,%rsi
  40eb82:	mov    %rbx,%rdi
  40eb85:	mov    -0xd8(%rbp),%rax
  40eb8c:	mov    -0xd0(%rbp),%r9
  40eb93:	mov    %r9,%rbx
  40eb96:	mov    -0xe0(%rbp),%r9d
  40eb9d:	jmp    40ebb9 <p113d_FID_36_100_105_114_101_99_116_46_112_49_51_55_113_95_114_101_112_101_97_116_+0x5f9>
  40eb9f:	mov    %r15,%r8
  40eba2:	mov    %r14,%rcx
  40eba5:	mov    %r13,%rdx
  40eba8:	jmp    40ebb9 <p113d_FID_36_100_105_114_101_99_116_46_112_49_51_55_113_95_114_101_112_101_97_116_+0x5f9>
  40ebaa:	mov    %r15,%r8
  40ebad:	mov    %r14,%rcx
  40ebb0:	mov    %r13,%rdx
  40ebb3:	mov    $0x0,%r9d
  40ebb9:	add    %rax,%r9
  40ebbc:	mov    %ebx,%eax
  40ebbe:	add    %r9d,%eax
  40ebc1:	mov    %eax,%r9d
  40ebc4:	sub    $0x1,%rsi
  40ebc8:	mov    %rcx,%r14
  40ebcb:	mov    %r8,%r13
  40ebce:	mov    %r9,-0xd0(%rbp)
  40ebd5:	jmpq   40e600 <p113d_FID_36_100_105_114_101_99_116_46_112_49_51_55_113_95_114_101_112_101_97_116_+0x40>
  40ebda:	mov    %rdx,%rsi
  40ebdd:	mov    -0xd0(%rbp),%rbx
  40ebe4:	mov    %rdi,%r12
  40ebe7:	callq  4332a0 <p111_rt_sink>
  40ebec:	mov    %r14,%rsi
  40ebef:	mov    %r12,%rdi
  40ebf2:	mov    %rdi,%r12
  40ebf5:	callq  4332a0 <p111_rt_sink>
  40ebfa:	mov    %r13,%rsi
  40ebfd:	mov    %r12,%rdi
  40ec00:	callq  4332a0 <p111_rt_sink>
  40ec05:	mov    %rbx,%rax
  40ec08:	pop    %r15
  40ec0a:	pop    %r14
  40ec0c:	pop    %r13
  40ec0e:	pop    %r12
  40ec10:	pop    %rbx
  40ec11:	leaveq 
  40ec12:	retq   

Disassembly of section .fini:
