0000000000008910 <p118_p111_rt_ctor2>:
    8910:	41 57                	push   %r15
    8912:	41 56                	push   %r14
    8914:	41 55                	push   %r13
    8916:	41 54                	push   %r12
    8918:	55                   	push   %rbp
    8919:	53                   	push   %rbx
    891a:	48 83 ec 08          	sub    $0x8,%rsp
    891e:	83 f9 02             	cmp    $0x2,%ecx
    8921:	74 0d                	je     8930 <p118_p111_rt_ctor2+0x20>
    8923:	48 8d 3d 00 00 00 00 	lea    0x0(%rip),%rdi        # 892a <p118_p111_rt_ctor2+0x1a>	8926: R_X86_64_PC32	.LC147-0x4
    892a:	e8 31 7a ff ff       	callq  360 <err_fail>
    892f:	90                   	nop
    8930:	4c 8b 3d 00 00 00 00 	mov    0x0(%rip),%r15        # 8937 <p118_p111_rt_ctor2+0x27>	8933: R_X86_64_PC32	.bss+0x1001ac
    8937:	89 f3                	mov    %esi,%ebx
    8939:	49 3b 5f 18          	cmp    0x18(%r15),%rbx
    893d:	73 e4                	jae    8923 <p118_p111_rt_ctor2+0x13>
    893f:	49 8b 87 80 00 00 00 	mov    0x80(%r15),%rax
    8946:	80 3c 18 02          	cmpb   $0x2,(%rax,%rbx,1)
    894a:	75 d7                	jne    8923 <p118_p111_rt_ctor2+0x13>
    894c:	48 89 d5             	mov    %rdx,%rbp
    894f:	48 85 d2             	test   %rdx,%rdx
    8952:	0f 84 c2 00 00 00    	je     8a1a <p118_p111_rt_ctor2+0x10a>
    8958:	4c 8b 6f 08          	mov    0x8(%rdi),%r13
    895c:	4c 8b 37             	mov    (%rdi),%r14
    895f:	4d 8b 65 08          	mov    0x8(%r13),%r12
    8963:	4d 85 e4             	test   %r12,%r12
    8966:	0f 84 00 00 00 00    	je     896c <p118_p111_rt_ctor2+0x5c>	8968: R_X86_64_PC32	.text.unlikely+0x2299
    896c:	4b 8d 04 e6          	lea    (%r14,%r12,8),%rax
    8970:	48 8b 10             	mov    (%rax),%rdx
    8973:	49 83 ad 08 01 00 00 02 	subq   $0x2,0x108(%r13)
    897b:	49 89 55 08          	mov    %rdx,0x8(%r13)
    897f:	48 8b 55 00          	mov    0x0(%rbp),%rdx
    8983:	41 f6 47 58 08       	testb  $0x8,0x58(%r15)
    8988:	74 3e                	je     89c8 <p118_p111_rt_ctor2+0xb8>
    898a:	49 8b 8f 88 00 00 00 	mov    0x88(%r15),%rcx
    8991:	80 3c 19 00          	cmpb   $0x0,(%rcx,%rbx,1)
    8995:	75 31                	jne    89c8 <p118_p111_rt_ctor2+0xb8>
    8997:	48 89 10             	mov    %rdx,(%rax)
    899a:	48 8b 45 08          	mov    0x8(%rbp),%rax
    899e:	4b 89 44 e6 08       	mov    %rax,0x8(%r14,%r12,8)
    89a3:	48 89 d8             	mov    %rbx,%rax
    89a6:	48 83 c4 08          	add    $0x8,%rsp
    89aa:	48 c1 e0 28          	shl    $0x28,%rax
    89ae:	5b                   	pop    %rbx
    89af:	5d                   	pop    %rbp
    89b0:	4c 09 e0             	or     %r12,%rax
    89b3:	41 5c                	pop    %r12
    89b5:	41 5d                	pop    %r13
    89b7:	48 0f ba e8 39       	bts    $0x39,%rax
    89bc:	41 5e                	pop    %r14
    89be:	41 5f                	pop    %r15
    89c0:	c3                   	retq   
    89c1:	0f 1f 80 00 00 00 00 	nopl   0x0(%rax)
    89c8:	48 89 d0             	mov    %rdx,%rax
    89cb:	4f 8d 3c e6          	lea    (%r14,%r12,8),%r15
    89cf:	48 c1 e8 38          	shr    $0x38,%rax
    89d3:	83 e0 7f             	and    $0x7f,%eax
    89d6:	48 83 f8 02          	cmp    $0x2,%rax
    89da:	74 24                	je     8a00 <p118_p111_rt_ctor2+0xf0>
    89dc:	49 89 17             	mov    %rdx,(%r15)
    89df:	48 8b 55 08          	mov    0x8(%rbp),%rdx
    89e3:	4b 8d 6c e6 08       	lea    0x8(%r14,%r12,8),%rbp
    89e8:	48 89 d0             	mov    %rdx,%rax
    89eb:	48 c1 e8 38          	shr    $0x38,%rax
    89ef:	83 e0 7f             	and    $0x7f,%eax
    89f2:	48 83 f8 02          	cmp    $0x2,%rax
    89f6:	74 18                	je     8a10 <p118_p111_rt_ctor2+0x100>
    89f8:	48 89 55 00          	mov    %rdx,0x0(%rbp)
    89fc:	eb a5                	jmp    89a3 <p118_p111_rt_ctor2+0x93>
    89fe:	66 90                	xchg   %ax,%ax
    8a00:	48 85 d2             	test   %rdx,%rdx
    8a03:	78 d7                	js     89dc <p118_p111_rt_ctor2+0xcc>
    8a05:	e9 00 00 00 00       	jmpq   8a0a <p118_p111_rt_ctor2+0xfa>	8a06: R_X86_64_PC32	.text.unlikely+0x2281
    8a0a:	66 0f 1f 44 00 00    	nopw   0x0(%rax,%rax,1)
    8a10:	48 85 d2             	test   %rdx,%rdx
    8a13:	78 e3                	js     89f8 <p118_p111_rt_ctor2+0xe8>
    8a15:	e9 00 00 00 00       	jmpq   8a1a <p118_p111_rt_ctor2+0x10a>	8a16: R_X86_64_PC32	.text.unlikely+0x2269
    8a1a:	48 8d 3d 00 00 00 00 	lea    0x0(%rip),%rdi        # 8a21 <p118_p111_rt_ctor2+0x111>	8a1d: R_X86_64_PC32	.LC146-0x4
    8a21:	e8 3a 79 ff ff       	callq  360 <err_fail>
    8a26:	66 2e 0f 1f 84 00 00 00 00 00 	nopw   %cs:0x0(%rax,%rax,1)

