000000000000a240 <p125_rt_ctor3>:
    a240:	41 57                	push   %r15
    a242:	48 89 f8             	mov    %rdi,%rax
    a245:	41 56                	push   %r14
    a247:	41 55                	push   %r13
    a249:	41 54                	push   %r12
    a24b:	49 89 d4             	mov    %rdx,%r12
    a24e:	55                   	push   %rbp
    a24f:	53                   	push   %rbx
    a250:	89 f3                	mov    %esi,%ebx
    a252:	48 83 ec 18          	sub    $0x18,%rsp
    a256:	4c 8b 70 08          	mov    0x8(%rax),%r14
    a25a:	48 8b 3f             	mov    (%rdi),%rdi
    a25d:	4d 8b 6e 10          	mov    0x10(%r14),%r13
    a261:	4d 85 ed             	test   %r13,%r13
    a264:	0f 84 00 00 00 00    	je     a26a <p125_rt_ctor3+0x2a>	a266: R_X86_64_PC32	.text.unlikely+0x284d
    a26a:	4a 8b 04 ef          	mov    (%rdi,%r13,8),%rax
    a26e:	49 83 ae 10 01 00 00 04 	subq   $0x4,0x110(%r14)
    a276:	49 89 46 10          	mov    %rax,0x10(%r14)
    a27a:	48 8b 05 00 00 00 00 	mov    0x0(%rip),%rax        # a281 <p125_rt_ctor3+0x41>	a27d: R_X86_64_PC32	.bss+0x1001ac
    a281:	f6 40 58 08          	testb  $0x8,0x58(%rax)
    a285:	74 0d                	je     a294 <p125_rt_ctor3+0x54>
    a287:	48 8b 80 88 00 00 00 	mov    0x88(%rax),%rax
    a28e:	80 3c 18 00          	cmpb   $0x0,(%rax,%rbx,1)
    a292:	74 5c                	je     a2f0 <p125_rt_ctor3+0xb0>
    a294:	4e 8d 3c ef          	lea    (%rdi,%r13,8),%r15
    a298:	31 ed                	xor    %ebp,%ebp
    a29a:	49 8b 14 2c          	mov    (%r12,%rbp,1),%rdx
    a29e:	48 89 d0             	mov    %rdx,%rax
    a2a1:	48 c1 e8 38          	shr    $0x38,%rax
    a2a5:	83 e0 7f             	and    $0x7f,%eax
    a2a8:	48 83 f8 02          	cmp    $0x2,%rax
    a2ac:	74 32                	je     a2e0 <p125_rt_ctor3+0xa0>
    a2ae:	49 89 14 2f          	mov    %rdx,(%r15,%rbp,1)
    a2b2:	48 83 c5 08          	add    $0x8,%rbp
    a2b6:	48 83 fd 18          	cmp    $0x18,%rbp
    a2ba:	75 de                	jne    a29a <p125_rt_ctor3+0x5a>
    a2bc:	48 89 d8             	mov    %rbx,%rax
    a2bf:	48 83 c4 18          	add    $0x18,%rsp
    a2c3:	48 c1 e0 28          	shl    $0x28,%rax
    a2c7:	5b                   	pop    %rbx
    a2c8:	5d                   	pop    %rbp
    a2c9:	4c 09 e8             	or     %r13,%rax
    a2cc:	41 5c                	pop    %r12
    a2ce:	41 5d                	pop    %r13
    a2d0:	48 0f ba e8 39       	bts    $0x39,%rax
    a2d5:	41 5e                	pop    %r14
    a2d7:	41 5f                	pop    %r15
    a2d9:	c3                   	retq   
    a2da:	66 0f 1f 44 00 00    	nopw   0x0(%rax,%rax,1)
    a2e0:	48 85 d2             	test   %rdx,%rdx
    a2e3:	78 c9                	js     a2ae <p125_rt_ctor3+0x6e>
    a2e5:	e9 00 00 00 00       	jmpq   a2ea <p125_rt_ctor3+0xaa>	a2e6: R_X86_64_PC32	.text.unlikely+0x286c
    a2ea:	66 0f 1f 44 00 00    	nopw   0x0(%rax,%rax,1)
    a2f0:	4a 8d 0c ef          	lea    (%rdi,%r13,8),%rcx
    a2f4:	31 c0                	xor    %eax,%eax
    a2f6:	49 8b 14 04          	mov    (%r12,%rax,1),%rdx
    a2fa:	48 89 14 01          	mov    %rdx,(%rcx,%rax,1)
    a2fe:	48 83 c0 08          	add    $0x8,%rax
    a302:	48 83 f8 18          	cmp    $0x18,%rax
    a306:	75 ee                	jne    a2f6 <p125_rt_ctor3+0xb6>
    a308:	eb b2                	jmp    a2bc <p125_rt_ctor3+0x7c>
    a30a:	66 0f 1f 44 00 00    	nopw   0x0(%rax,%rax,1)

