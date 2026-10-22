000000000000a4b0 <p125_rt_ctor4>:
    a4b0:	41 57                	push   %r15
    a4b2:	48 89 f8             	mov    %rdi,%rax
    a4b5:	41 56                	push   %r14
    a4b7:	41 55                	push   %r13
    a4b9:	41 54                	push   %r12
    a4bb:	49 89 d4             	mov    %rdx,%r12
    a4be:	55                   	push   %rbp
    a4bf:	89 f5                	mov    %esi,%ebp
    a4c1:	53                   	push   %rbx
    a4c2:	48 83 ec 18          	sub    $0x18,%rsp
    a4c6:	4c 8b 70 08          	mov    0x8(%rax),%r14
    a4ca:	48 8b 3f             	mov    (%rdi),%rdi
    a4cd:	4d 8b 6e 10          	mov    0x10(%r14),%r13
    a4d1:	4d 85 ed             	test   %r13,%r13
    a4d4:	0f 84 00 00 00 00    	je     a4da <p125_rt_ctor4+0x2a>	a4d6: R_X86_64_PC32	.text.unlikely+0x28d4
    a4da:	4a 8b 04 ef          	mov    (%rdi,%r13,8),%rax
    a4de:	49 83 ae 10 01 00 00 04 	subq   $0x4,0x110(%r14)
    a4e6:	49 89 46 10          	mov    %rax,0x10(%r14)
    a4ea:	48 8b 05 00 00 00 00 	mov    0x0(%rip),%rax        # a4f1 <p125_rt_ctor4+0x41>	a4ed: R_X86_64_PC32	.bss+0x1001ac
    a4f1:	f6 40 58 08          	testb  $0x8,0x58(%rax)
    a4f5:	74 0d                	je     a504 <p125_rt_ctor4+0x54>
    a4f7:	48 8b 80 88 00 00 00 	mov    0x88(%rax),%rax
    a4fe:	80 3c 28 00          	cmpb   $0x0,(%rax,%rbp,1)
    a502:	74 5c                	je     a560 <p125_rt_ctor4+0xb0>
    a504:	4e 8d 3c ef          	lea    (%rdi,%r13,8),%r15
    a508:	31 db                	xor    %ebx,%ebx
    a50a:	49 8b 14 1c          	mov    (%r12,%rbx,1),%rdx
    a50e:	48 89 d0             	mov    %rdx,%rax
    a511:	48 c1 e8 38          	shr    $0x38,%rax
    a515:	83 e0 7f             	and    $0x7f,%eax
    a518:	48 83 f8 02          	cmp    $0x2,%rax
    a51c:	74 32                	je     a550 <p125_rt_ctor4+0xa0>
    a51e:	49 89 14 1f          	mov    %rdx,(%r15,%rbx,1)
    a522:	48 83 c3 08          	add    $0x8,%rbx
    a526:	48 83 fb 20          	cmp    $0x20,%rbx
    a52a:	75 de                	jne    a50a <p125_rt_ctor4+0x5a>
    a52c:	48 89 e8             	mov    %rbp,%rax
    a52f:	48 83 c4 18          	add    $0x18,%rsp
    a533:	48 c1 e0 28          	shl    $0x28,%rax
    a537:	5b                   	pop    %rbx
    a538:	5d                   	pop    %rbp
    a539:	4c 09 e8             	or     %r13,%rax
    a53c:	41 5c                	pop    %r12
    a53e:	41 5d                	pop    %r13
    a540:	48 0f ba e8 39       	bts    $0x39,%rax
    a545:	41 5e                	pop    %r14
    a547:	41 5f                	pop    %r15
    a549:	c3                   	retq   
    a54a:	66 0f 1f 44 00 00    	nopw   0x0(%rax,%rax,1)
    a550:	48 85 d2             	test   %rdx,%rdx
    a553:	78 c9                	js     a51e <p125_rt_ctor4+0x6e>
    a555:	e9 00 00 00 00       	jmpq   a55a <p125_rt_ctor4+0xaa>	a556: R_X86_64_PC32	.text.unlikely+0x28f3
    a55a:	66 0f 1f 44 00 00    	nopw   0x0(%rax,%rax,1)
    a560:	4a 8d 0c ef          	lea    (%rdi,%r13,8),%rcx
    a564:	31 c0                	xor    %eax,%eax
    a566:	49 8b 14 04          	mov    (%r12,%rax,1),%rdx
    a56a:	48 89 14 01          	mov    %rdx,(%rcx,%rax,1)
    a56e:	48 83 c0 08          	add    $0x8,%rax
    a572:	48 83 f8 20          	cmp    $0x20,%rax
    a576:	75 ee                	jne    a566 <p125_rt_ctor4+0xb6>
    a578:	eb b2                	jmp    a52c <p125_rt_ctor4+0x7c>
    a57a:	66 0f 1f 44 00 00    	nopw   0x0(%rax,%rax,1)

