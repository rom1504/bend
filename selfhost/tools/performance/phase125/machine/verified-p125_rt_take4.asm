000000000000a580 <p125_rt_take4>:
    a580:	48 89 f0             	mov    %rsi,%rax
    a583:	4c 8b 05 00 00 00 00 	mov    0x0(%rip),%r8        # a58a <p125_rt_take4+0xa>	a586: R_X86_64_PC32	.bss+0x1001ac
    a58a:	41 54                	push   %r12
    a58c:	48 c1 e8 28          	shr    $0x28,%rax
    a590:	55                   	push   %rbp
    a591:	0f b7 c0             	movzwl %ax,%eax
    a594:	53                   	push   %rbx
    a595:	49 39 40 18          	cmp    %rax,0x18(%r8)
    a599:	77 15                	ja     a5b0 <p125_rt_take4+0x30>
    a59b:	48 8d 3d 00 00 00 00 	lea    0x0(%rip),%rdi        # a5a2 <p125_rt_take4+0x22>	a59e: R_X86_64_PC32	.LC151-0x4
    a5a2:	e8 b9 5d ff ff       	callq  360 <err_fail>
    a5a7:	66 0f 1f 84 00 00 00 00 00 	nopw   0x0(%rax,%rax,1)
    a5b0:	48 89 d1             	mov    %rdx,%rcx
    a5b3:	49 8b 90 80 00 00 00 	mov    0x80(%r8),%rdx
    a5ba:	80 3c 02 04          	cmpb   $0x4,(%rdx,%rax,1)
    a5be:	75 db                	jne    a59b <p125_rt_take4+0x1b>
    a5c0:	48 89 f0             	mov    %rsi,%rax
    a5c3:	48 c1 e8 38          	shr    $0x38,%rax
    a5c7:	83 e0 7f             	and    $0x7f,%eax
    a5ca:	48 83 f8 02          	cmp    $0x2,%rax
    a5ce:	0f 85 37 01 00 00    	jne    a70b <p125_rt_take4+0x18b>
    a5d4:	4c 8b 0f             	mov    (%rdi),%r9
    a5d7:	48 89 fb             	mov    %rdi,%rbx
    a5da:	48 bf ff ff ff ff ff 00 00 00 	movabs $0xffffffffff,%rdi
    a5e4:	48 21 f7             	and    %rsi,%rdi
    a5e7:	48 85 f6             	test   %rsi,%rsi
    a5ea:	0f 88 90 00 00 00    	js     a680 <p125_rt_take4+0x100>
    a5f0:	49 8d 34 f9          	lea    (%r9,%rdi,8),%rsi
    a5f4:	31 c0                	xor    %eax,%eax
    a5f6:	66 2e 0f 1f 84 00 00 00 00 00 	nopw   %cs:0x0(%rax,%rax,1)
    a600:	48 8b 14 06          	mov    (%rsi,%rax,1),%rdx
    a604:	48 89 14 01          	mov    %rdx,(%rcx,%rax,1)
    a608:	48 83 c0 08          	add    $0x8,%rax
    a60c:	48 83 f8 20          	cmp    $0x20,%rax
    a610:	75 ee                	jne    a600 <p125_rt_take4+0x80>
    a612:	49 8b 40 40          	mov    0x40(%r8),%rax
    a616:	48 83 c0 7f          	add    $0x7f,%rax
    a61a:	48 83 e0 80          	and    $0xffffffffffffff80,%rax
    a61e:	48 05 00 82 10 03    	add    $0x3108200,%rax
    a624:	48 39 f8             	cmp    %rdi,%rax
    a627:	76 0f                	jbe    a638 <p125_rt_take4+0xb8>
    a629:	5b                   	pop    %rbx
    a62a:	b8 04 00 00 00       	mov    $0x4,%eax
    a62f:	5d                   	pop    %rbp
    a630:	41 5c                	pop    %r12
    a632:	c3                   	retq   
    a633:	0f 1f 44 00 00       	nopl   0x0(%rax,%rax,1)
    a638:	48 8b 73 08          	mov    0x8(%rbx),%rsi
    a63c:	4c 8b 03             	mov    (%rbx),%r8
    a63f:	8b 15 00 00 00 00    	mov    0x0(%rip),%edx        # a645 <p125_rt_take4+0xc5>	a641: R_X86_64_PC32	.bss+0x100264
    a645:	48 8b 46 10          	mov    0x10(%rsi),%rax
    a649:	49 89 04 f8          	mov    %rax,(%r8,%rdi,8)
    a64d:	48 8b 86 10 01 00 00 	mov    0x110(%rsi),%rax
    a654:	48 89 7e 10          	mov    %rdi,0x10(%rsi)
    a658:	48 83 c0 04          	add    $0x4,%rax
    a65c:	48 89 86 10 01 00 00 	mov    %rax,0x110(%rsi)
    a663:	48 39 d0             	cmp    %rdx,%rax
    a666:	0f 83 00 00 00 00    	jae    a66c <p125_rt_take4+0xec>	a668: R_X86_64_PC32	.text.unlikely+0x2949
    a66c:	5b                   	pop    %rbx
    a66d:	b8 04 00 00 00       	mov    $0x4,%eax
    a672:	5d                   	pop    %rbp
    a673:	41 5c                	pop    %r12
    a675:	c3                   	retq   
    a676:	66 2e 0f 1f 84 00 00 00 00 00 	nopw   %cs:0x0(%rax,%rax,1)
    a680:	49 8d 2c f9          	lea    (%r9,%rdi,8),%rbp
    a684:	4c 8b 5b 08          	mov    0x8(%rbx),%r11
    a688:	44 8b 65 04          	mov    0x4(%rbp),%r12d
    a68c:	44 8b 55 00          	mov    0x0(%rbp),%r10d
    a690:	49 c1 e4 20          	shl    $0x20,%r12
    a694:	4d 09 d4             	or     %r10,%r12
    a697:	41 81 e2 ff ff ff 00 	and    $0xffffff,%r10d
    a69e:	49 83 fa 01          	cmp    $0x1,%r10
    a6a2:	74 62                	je     a706 <p125_rt_take4+0x186>
    a6a4:	49 c1 ec 18          	shr    $0x18,%r12
    a6a8:	31 c0                	xor    %eax,%eax
    a6aa:	4f 8d 04 e1          	lea    (%r9,%r12,8),%r8
    a6ae:	66 90                	xchg   %ax,%ax
    a6b0:	49 8b 14 00          	mov    (%r8,%rax,1),%rdx
    a6b4:	48 89 14 01          	mov    %rdx,(%rcx,%rax,1)
    a6b8:	48 83 c0 08          	add    $0x8,%rax
    a6bc:	48 83 f8 20          	cmp    $0x20,%rax
    a6c0:	75 ee                	jne    a6b0 <p125_rt_take4+0x130>
    a6c2:	49 83 fa 01          	cmp    $0x1,%r10
    a6c6:	0f 85 00 00 00 00    	jne    a6cc <p125_rt_take4+0x14c>	a6c8: R_X86_64_PC32	.text.unlikely+0x2912
    a6cc:	49 8b 03             	mov    (%r11),%rax
    a6cf:	8b 15 00 00 00 00    	mov    0x0(%rip),%edx        # a6d5 <p125_rt_take4+0x155>	a6d1: R_X86_64_PC32	.bss+0x100264
    a6d5:	48 89 45 00          	mov    %rax,0x0(%rbp)
    a6d9:	49 8b 83 00 01 00 00 	mov    0x100(%r11),%rax
    a6e0:	49 89 3b             	mov    %rdi,(%r11)
    a6e3:	48 83 c0 01          	add    $0x1,%rax
    a6e7:	49 89 83 00 01 00 00 	mov    %rax,0x100(%r11)
    a6ee:	48 39 d0             	cmp    %rdx,%rax
    a6f1:	0f 83 00 00 00 00    	jae    a6f7 <p125_rt_take4+0x177>	a6f3: R_X86_64_PC32	.text.unlikely+0x2937
    a6f7:	4c 8b 05 00 00 00 00 	mov    0x0(%rip),%r8        # a6fe <p125_rt_take4+0x17e>	a6fa: R_X86_64_PC32	.bss+0x1001ac
    a6fe:	4c 89 e7             	mov    %r12,%rdi
    a701:	e9 0c ff ff ff       	jmpq   a612 <p125_rt_take4+0x92>
    a706:	8b 45 00             	mov    0x0(%rbp),%eax
    a709:	eb 99                	jmp    a6a4 <p125_rt_take4+0x124>
    a70b:	48 8d 3d 00 00 00 00 	lea    0x0(%rip),%rdi        # a712 <p125_rt_take4+0x192>	a70e: R_X86_64_PC32	.LC150-0x4
    a712:	e8 49 5c ff ff       	callq  360 <err_fail>

Disassembly of section .text.unlikely:

