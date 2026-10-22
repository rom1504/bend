0000000000008690 <p118_p111_rt_ctor1>:
    8690:	41 57                	push   %r15
    8692:	41 56                	push   %r14
    8694:	41 55                	push   %r13
    8696:	41 54                	push   %r12
    8698:	55                   	push   %rbp
    8699:	53                   	push   %rbx
    869a:	48 83 ec 18          	sub    $0x18,%rsp
    869e:	83 f9 01             	cmp    $0x1,%ecx
    86a1:	74 0d                	je     86b0 <p118_p111_rt_ctor1+0x20>
    86a3:	48 8d 3d 00 00 00 00 	lea    0x0(%rip),%rdi        # 86aa <p118_p111_rt_ctor1+0x1a>	86a6: R_X86_64_PC32	.LC147-0x4
    86aa:	e8 b1 7c ff ff       	callq  360 <err_fail>
    86af:	90                   	nop
    86b0:	4c 8b 35 00 00 00 00 	mov    0x0(%rip),%r14        # 86b7 <p118_p111_rt_ctor1+0x27>	86b3: R_X86_64_PC32	.bss+0x1001ac
    86b7:	89 f3                	mov    %esi,%ebx
    86b9:	49 3b 5e 18          	cmp    0x18(%r14),%rbx
    86bd:	73 e4                	jae    86a3 <p118_p111_rt_ctor1+0x13>
    86bf:	49 8b 86 80 00 00 00 	mov    0x80(%r14),%rax
    86c6:	80 3c 18 01          	cmpb   $0x1,(%rax,%rbx,1)
    86ca:	75 d7                	jne    86a3 <p118_p111_rt_ctor1+0x13>
    86cc:	49 89 d4             	mov    %rdx,%r12
    86cf:	48 85 d2             	test   %rdx,%rdx
    86d2:	74 7e                	je     8752 <p118_p111_rt_ctor1+0xc2>
    86d4:	48 8b 77 08          	mov    0x8(%rdi),%rsi
    86d8:	4c 8b 3f             	mov    (%rdi),%r15
    86db:	4c 8b 2e             	mov    (%rsi),%r13
    86de:	4d 85 ed             	test   %r13,%r13
    86e1:	0f 84 00 00 00 00    	je     86e7 <p118_p111_rt_ctor1+0x57>	86e3: R_X86_64_PC32	.text.unlikely+0x2200
    86e7:	4b 8d 2c ef          	lea    (%r15,%r13,8),%rbp
    86eb:	48 8b 45 00          	mov    0x0(%rbp),%rax
    86ef:	48 83 ae 00 01 00 00 01 	subq   $0x1,0x100(%rsi)
    86f7:	48 89 06             	mov    %rax,(%rsi)
    86fa:	49 8b 14 24          	mov    (%r12),%rdx
    86fe:	41 f6 46 58 08       	testb  $0x8,0x58(%r14)
    8703:	74 33                	je     8738 <p118_p111_rt_ctor1+0xa8>
    8705:	49 8b 86 88 00 00 00 	mov    0x88(%r14),%rax
    870c:	80 3c 18 00          	cmpb   $0x0,(%rax,%rbx,1)
    8710:	75 26                	jne    8738 <p118_p111_rt_ctor1+0xa8>
    8712:	48 89 d8             	mov    %rbx,%rax
    8715:	48 89 55 00          	mov    %rdx,0x0(%rbp)
    8719:	48 83 c4 18          	add    $0x18,%rsp
    871d:	48 c1 e0 28          	shl    $0x28,%rax
    8721:	5b                   	pop    %rbx
    8722:	5d                   	pop    %rbp
    8723:	4c 09 e8             	or     %r13,%rax
    8726:	41 5c                	pop    %r12
    8728:	41 5d                	pop    %r13
    872a:	48 0f ba e8 39       	bts    $0x39,%rax
    872f:	41 5e                	pop    %r14
    8731:	41 5f                	pop    %r15
    8733:	c3                   	retq   
    8734:	0f 1f 40 00          	nopl   0x0(%rax)
    8738:	48 89 d0             	mov    %rdx,%rax
    873b:	48 c1 e8 38          	shr    $0x38,%rax
    873f:	83 e0 7f             	and    $0x7f,%eax
    8742:	48 83 f8 02          	cmp    $0x2,%rax
    8746:	75 ca                	jne    8712 <p118_p111_rt_ctor1+0x82>
    8748:	48 85 d2             	test   %rdx,%rdx
    874b:	78 c5                	js     8712 <p118_p111_rt_ctor1+0x82>
    874d:	e9 00 00 00 00       	jmpq   8752 <p118_p111_rt_ctor1+0xc2>	874e: R_X86_64_PC32	.text.unlikely+0x21eb
    8752:	48 8d 3d 00 00 00 00 	lea    0x0(%rip),%rdi        # 8759 <p118_p111_rt_ctor1+0xc9>	8755: R_X86_64_PC32	.LC146-0x4
    8759:	e8 02 7c ff ff       	callq  360 <err_fail>
    875e:	66 90                	xchg   %ax,%ax

