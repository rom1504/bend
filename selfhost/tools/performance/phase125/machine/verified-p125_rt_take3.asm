000000000000a310 <p125_rt_take3>:
    a310:	48 89 f0             	mov    %rsi,%rax
    a313:	4c 8b 05 00 00 00 00 	mov    0x0(%rip),%r8        # a31a <p125_rt_take3+0xa>	a316: R_X86_64_PC32	.bss+0x1001ac
    a31a:	41 54                	push   %r12
    a31c:	48 c1 e8 28          	shr    $0x28,%rax
    a320:	55                   	push   %rbp
    a321:	0f b7 c0             	movzwl %ax,%eax
    a324:	53                   	push   %rbx
    a325:	49 39 40 18          	cmp    %rax,0x18(%r8)
    a329:	77 15                	ja     a340 <p125_rt_take3+0x30>
    a32b:	48 8d 3d 00 00 00 00 	lea    0x0(%rip),%rdi        # a332 <p125_rt_take3+0x22>	a32e: R_X86_64_PC32	.LC151-0x4
    a332:	e8 29 60 ff ff       	callq  360 <err_fail>
    a337:	66 0f 1f 84 00 00 00 00 00 	nopw   0x0(%rax,%rax,1)
    a340:	48 89 d1             	mov    %rdx,%rcx
    a343:	49 8b 90 80 00 00 00 	mov    0x80(%r8),%rdx
    a34a:	80 3c 02 03          	cmpb   $0x3,(%rdx,%rax,1)
    a34e:	75 db                	jne    a32b <p125_rt_take3+0x1b>
    a350:	48 89 f0             	mov    %rsi,%rax
    a353:	48 c1 e8 38          	shr    $0x38,%rax
    a357:	83 e0 7f             	and    $0x7f,%eax
    a35a:	48 83 f8 02          	cmp    $0x2,%rax
    a35e:	0f 85 37 01 00 00    	jne    a49b <p125_rt_take3+0x18b>
    a364:	4c 8b 0f             	mov    (%rdi),%r9
    a367:	48 89 fb             	mov    %rdi,%rbx
    a36a:	48 bf ff ff ff ff ff 00 00 00 	movabs $0xffffffffff,%rdi
    a374:	48 21 f7             	and    %rsi,%rdi
    a377:	48 85 f6             	test   %rsi,%rsi
    a37a:	0f 88 90 00 00 00    	js     a410 <p125_rt_take3+0x100>
    a380:	49 8d 34 f9          	lea    (%r9,%rdi,8),%rsi
    a384:	31 c0                	xor    %eax,%eax
    a386:	66 2e 0f 1f 84 00 00 00 00 00 	nopw   %cs:0x0(%rax,%rax,1)
    a390:	48 8b 14 06          	mov    (%rsi,%rax,1),%rdx
    a394:	48 89 14 01          	mov    %rdx,(%rcx,%rax,1)
    a398:	48 83 c0 08          	add    $0x8,%rax
    a39c:	48 83 f8 18          	cmp    $0x18,%rax
    a3a0:	75 ee                	jne    a390 <p125_rt_take3+0x80>
    a3a2:	49 8b 40 40          	mov    0x40(%r8),%rax
    a3a6:	48 83 c0 7f          	add    $0x7f,%rax
    a3aa:	48 83 e0 80          	and    $0xffffffffffffff80,%rax
    a3ae:	48 05 00 82 10 03    	add    $0x3108200,%rax
    a3b4:	48 39 f8             	cmp    %rdi,%rax
    a3b7:	76 0f                	jbe    a3c8 <p125_rt_take3+0xb8>
    a3b9:	5b                   	pop    %rbx
    a3ba:	b8 03 00 00 00       	mov    $0x3,%eax
    a3bf:	5d                   	pop    %rbp
    a3c0:	41 5c                	pop    %r12
    a3c2:	c3                   	retq   
    a3c3:	0f 1f 44 00 00       	nopl   0x0(%rax,%rax,1)
    a3c8:	48 8b 73 08          	mov    0x8(%rbx),%rsi
    a3cc:	4c 8b 03             	mov    (%rbx),%r8
    a3cf:	8b 15 00 00 00 00    	mov    0x0(%rip),%edx        # a3d5 <p125_rt_take3+0xc5>	a3d1: R_X86_64_PC32	.bss+0x100264
    a3d5:	48 8b 46 10          	mov    0x10(%rsi),%rax
    a3d9:	49 89 04 f8          	mov    %rax,(%r8,%rdi,8)
    a3dd:	48 8b 86 10 01 00 00 	mov    0x110(%rsi),%rax
    a3e4:	48 89 7e 10          	mov    %rdi,0x10(%rsi)
    a3e8:	48 83 c0 04          	add    $0x4,%rax
    a3ec:	48 89 86 10 01 00 00 	mov    %rax,0x110(%rsi)
    a3f3:	48 39 d0             	cmp    %rdx,%rax
    a3f6:	0f 83 00 00 00 00    	jae    a3fc <p125_rt_take3+0xec>	a3f8: R_X86_64_PC32	.text.unlikely+0x28c2
    a3fc:	5b                   	pop    %rbx
    a3fd:	b8 03 00 00 00       	mov    $0x3,%eax
    a402:	5d                   	pop    %rbp
    a403:	41 5c                	pop    %r12
    a405:	c3                   	retq   
    a406:	66 2e 0f 1f 84 00 00 00 00 00 	nopw   %cs:0x0(%rax,%rax,1)
    a410:	49 8d 2c f9          	lea    (%r9,%rdi,8),%rbp
    a414:	4c 8b 5b 08          	mov    0x8(%rbx),%r11
    a418:	44 8b 65 04          	mov    0x4(%rbp),%r12d
    a41c:	44 8b 55 00          	mov    0x0(%rbp),%r10d
    a420:	49 c1 e4 20          	shl    $0x20,%r12
    a424:	4d 09 d4             	or     %r10,%r12
    a427:	41 81 e2 ff ff ff 00 	and    $0xffffff,%r10d
    a42e:	49 83 fa 01          	cmp    $0x1,%r10
    a432:	74 62                	je     a496 <p125_rt_take3+0x186>
    a434:	49 c1 ec 18          	shr    $0x18,%r12
    a438:	31 c0                	xor    %eax,%eax
    a43a:	4f 8d 04 e1          	lea    (%r9,%r12,8),%r8
    a43e:	66 90                	xchg   %ax,%ax
    a440:	49 8b 14 00          	mov    (%r8,%rax,1),%rdx
    a444:	48 89 14 01          	mov    %rdx,(%rcx,%rax,1)
    a448:	48 83 c0 08          	add    $0x8,%rax
    a44c:	48 83 f8 18          	cmp    $0x18,%rax
    a450:	75 ee                	jne    a440 <p125_rt_take3+0x130>
    a452:	49 83 fa 01          	cmp    $0x1,%r10
    a456:	0f 85 00 00 00 00    	jne    a45c <p125_rt_take3+0x14c>	a458: R_X86_64_PC32	.text.unlikely+0x288b
    a45c:	49 8b 03             	mov    (%r11),%rax
    a45f:	8b 15 00 00 00 00    	mov    0x0(%rip),%edx        # a465 <p125_rt_take3+0x155>	a461: R_X86_64_PC32	.bss+0x100264
    a465:	48 89 45 00          	mov    %rax,0x0(%rbp)
    a469:	49 8b 83 00 01 00 00 	mov    0x100(%r11),%rax
    a470:	49 89 3b             	mov    %rdi,(%r11)
    a473:	48 83 c0 01          	add    $0x1,%rax
    a477:	49 89 83 00 01 00 00 	mov    %rax,0x100(%r11)
    a47e:	48 39 d0             	cmp    %rdx,%rax
    a481:	0f 83 00 00 00 00    	jae    a487 <p125_rt_take3+0x177>	a483: R_X86_64_PC32	.text.unlikely+0x28b0
    a487:	4c 8b 05 00 00 00 00 	mov    0x0(%rip),%r8        # a48e <p125_rt_take3+0x17e>	a48a: R_X86_64_PC32	.bss+0x1001ac
    a48e:	4c 89 e7             	mov    %r12,%rdi
    a491:	e9 0c ff ff ff       	jmpq   a3a2 <p125_rt_take3+0x92>
    a496:	8b 45 00             	mov    0x0(%rbp),%eax
    a499:	eb 99                	jmp    a434 <p125_rt_take3+0x124>
    a49b:	48 8d 3d 00 00 00 00 	lea    0x0(%rip),%rdi        # a4a2 <p125_rt_take3+0x192>	a49e: R_X86_64_PC32	.LC150-0x4
    a4a2:	e8 b9 5e ff ff       	callq  360 <err_fail>
    a4a7:	66 0f 1f 84 00 00 00 00 00 	nopw   0x0(%rax,%rax,1)

