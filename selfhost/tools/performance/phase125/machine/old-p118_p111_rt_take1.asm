0000000000008760 <p118_p111_rt_take1>:
    8760:	41 54                	push   %r12
    8762:	53                   	push   %rbx
    8763:	48 83 ec 08          	sub    $0x8,%rsp
    8767:	83 f9 01             	cmp    $0x1,%ecx
    876a:	74 14                	je     8780 <p118_p111_rt_take1+0x20>
    876c:	48 8d 3d 00 00 00 00 	lea    0x0(%rip),%rdi        # 8773 <p118_p111_rt_take1+0x13>	876f: R_X86_64_PC32	.LC151-0x4
    8773:	e8 e8 7b ff ff       	callq  360 <err_fail>
    8778:	0f 1f 84 00 00 00 00 00 	nopl   0x0(%rax,%rax,1)
    8780:	48 89 fb             	mov    %rdi,%rbx
    8783:	48 89 f0             	mov    %rsi,%rax
    8786:	48 8b 3d 00 00 00 00 	mov    0x0(%rip),%rdi        # 878d <p118_p111_rt_take1+0x2d>	8789: R_X86_64_PC32	.bss+0x1001ac
    878d:	48 c1 e8 28          	shr    $0x28,%rax
    8791:	0f b7 c0             	movzwl %ax,%eax
    8794:	48 39 47 18          	cmp    %rax,0x18(%rdi)
    8798:	76 d2                	jbe    876c <p118_p111_rt_take1+0xc>
    879a:	48 8b 8f 80 00 00 00 	mov    0x80(%rdi),%rcx
    87a1:	80 3c 01 01          	cmpb   $0x1,(%rcx,%rax,1)
    87a5:	75 c5                	jne    876c <p118_p111_rt_take1+0xc>
    87a7:	48 85 d2             	test   %rdx,%rdx
    87aa:	0f 84 3d 01 00 00    	je     88ed <p118_p111_rt_take1+0x18d>
    87b0:	48 89 f0             	mov    %rsi,%rax
    87b3:	48 c1 e8 38          	shr    $0x38,%rax
    87b7:	83 e0 7f             	and    $0x7f,%eax
    87ba:	48 83 f8 01          	cmp    $0x1,%rax
    87be:	74 58                	je     8818 <p118_p111_rt_take1+0xb8>
    87c0:	48 83 f8 02          	cmp    $0x2,%rax
    87c4:	0f 85 2f 01 00 00    	jne    88f9 <p118_p111_rt_take1+0x199>
    87ca:	48 b9 ff ff ff ff ff 00 00 00 	movabs $0xffffffffff,%rcx
    87d4:	4c 8b 0b             	mov    (%rbx),%r9
    87d7:	48 21 f1             	and    %rsi,%rcx
    87da:	49 8d 04 c9          	lea    (%r9,%rcx,8),%rax
    87de:	48 85 f6             	test   %rsi,%rsi
    87e1:	0f 88 99 00 00 00    	js     8880 <p118_p111_rt_take1+0x120>
    87e7:	48 8b 00             	mov    (%rax),%rax
    87ea:	48 89 02             	mov    %rax,(%rdx)
    87ed:	48 8b 47 40          	mov    0x40(%rdi),%rax
    87f1:	48 83 c0 7f          	add    $0x7f,%rax
    87f5:	48 83 e0 80          	and    $0xffffffffffffff80,%rax
    87f9:	48 05 00 82 10 03    	add    $0x3108200,%rax
    87ff:	48 39 c8             	cmp    %rcx,%rax
    8802:	76 34                	jbe    8838 <p118_p111_rt_take1+0xd8>
    8804:	48 83 c4 08          	add    $0x8,%rsp
    8808:	b8 01 00 00 00       	mov    $0x1,%eax
    880d:	5b                   	pop    %rbx
    880e:	41 5c                	pop    %r12
    8810:	c3                   	retq   
    8811:	0f 1f 80 00 00 00 00 	nopl   0x0(%rax)
    8818:	48 b8 ff ff ff ff ff 00 00 00 	movabs $0xffffffffff,%rax
    8822:	48 21 c6             	and    %rax,%rsi
    8825:	b8 01 00 00 00       	mov    $0x1,%eax
    882a:	48 89 32             	mov    %rsi,(%rdx)
    882d:	48 83 c4 08          	add    $0x8,%rsp
    8831:	5b                   	pop    %rbx
    8832:	41 5c                	pop    %r12
    8834:	c3                   	retq   
    8835:	0f 1f 00             	nopl   (%rax)
    8838:	48 8b 73 08          	mov    0x8(%rbx),%rsi
    883c:	48 8b 3b             	mov    (%rbx),%rdi
    883f:	8b 15 00 00 00 00    	mov    0x0(%rip),%edx        # 8845 <p118_p111_rt_take1+0xe5>	8841: R_X86_64_PC32	.bss+0x100264
    8845:	48 8b 06             	mov    (%rsi),%rax
    8848:	48 89 04 cf          	mov    %rax,(%rdi,%rcx,8)
    884c:	48 8b 86 00 01 00 00 	mov    0x100(%rsi),%rax
    8853:	48 89 0e             	mov    %rcx,(%rsi)
    8856:	48 83 c0 01          	add    $0x1,%rax
    885a:	48 89 86 00 01 00 00 	mov    %rax,0x100(%rsi)
    8861:	48 39 d0             	cmp    %rdx,%rax
    8864:	0f 83 00 00 00 00    	jae    886a <p118_p111_rt_take1+0x10a>	8866: R_X86_64_PC32	.text.unlikely+0x2220
    886a:	48 83 c4 08          	add    $0x8,%rsp
    886e:	b8 01 00 00 00       	mov    $0x1,%eax
    8873:	5b                   	pop    %rbx
    8874:	41 5c                	pop    %r12
    8876:	c3                   	retq   
    8877:	66 0f 1f 84 00 00 00 00 00 	nopw   0x0(%rax,%rax,1)
    8880:	4c 8b 53 08          	mov    0x8(%rbx),%r10
    8884:	8b 78 04             	mov    0x4(%rax),%edi
    8887:	44 8b 00             	mov    (%rax),%r8d
    888a:	48 c1 e7 20          	shl    $0x20,%rdi
    888e:	4c 09 c7             	or     %r8,%rdi
    8891:	49 89 fc             	mov    %rdi,%r12
    8894:	81 e7 ff ff ff 00    	and    $0xffffff,%edi
    889a:	49 c1 ec 18          	shr    $0x18,%r12
    889e:	4f 8d 04 e1          	lea    (%r9,%r12,8),%r8
    88a2:	48 83 ff 01          	cmp    $0x1,%rdi
    88a6:	0f 85 00 00 00 00    	jne    88ac <p118_p111_rt_take1+0x14c>	88a8: R_X86_64_PC32	.text.unlikely+0x222c
    88ac:	8b 30                	mov    (%rax),%esi
    88ae:	49 8b 30             	mov    (%r8),%rsi
    88b1:	48 89 32             	mov    %rsi,(%rdx)
    88b4:	49 8b 12             	mov    (%r10),%rdx
    88b7:	48 89 10             	mov    %rdx,(%rax)
    88ba:	49 8b 82 00 01 00 00 	mov    0x100(%r10),%rax
    88c1:	8b 15 00 00 00 00    	mov    0x0(%rip),%edx        # 88c7 <p118_p111_rt_take1+0x167>	88c3: R_X86_64_PC32	.bss+0x100264
    88c7:	49 89 0a             	mov    %rcx,(%r10)
    88ca:	48 83 c0 01          	add    $0x1,%rax
    88ce:	49 89 82 00 01 00 00 	mov    %rax,0x100(%r10)
    88d5:	48 39 d0             	cmp    %rdx,%rax
    88d8:	0f 83 00 00 00 00    	jae    88de <p118_p111_rt_take1+0x17e>	88da: R_X86_64_PC32	.text.unlikely+0x2257
    88de:	48 8b 3d 00 00 00 00 	mov    0x0(%rip),%rdi        # 88e5 <p118_p111_rt_take1+0x185>	88e1: R_X86_64_PC32	.bss+0x1001ac
    88e5:	4c 89 e1             	mov    %r12,%rcx
    88e8:	e9 00 ff ff ff       	jmpq   87ed <p118_p111_rt_take1+0x8d>
    88ed:	48 8d 3d 00 00 00 00 	lea    0x0(%rip),%rdi        # 88f4 <p118_p111_rt_take1+0x194>	88f0: R_X86_64_PC32	.LC149-0x4
    88f4:	e8 67 7a ff ff       	callq  360 <err_fail>
    88f9:	48 8d 3d 00 00 00 00 	lea    0x0(%rip),%rdi        # 8900 <p118_p111_rt_take1+0x1a0>	88fc: R_X86_64_PC32	.LC150-0x4
    8900:	e8 5b 7a ff ff       	callq  360 <err_fail>
    8905:	66 66 2e 0f 1f 84 00 00 00 00 00 	data16 nopw %cs:0x0(%rax,%rax,1)

