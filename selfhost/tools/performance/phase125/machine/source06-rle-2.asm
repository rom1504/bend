000000000040f330 <p114r_FID_36_100_105_114_101_99_116_46_101_120_112_97_110_100_>:
  40f330:	f3 0f 1e fa          	endbr64 
  40f334:	55                   	push   %rbp
  40f335:	48 89 e5             	mov    %rsp,%rbp
  40f338:	48 81 ec 08 18 00 00 	sub    $0x1808,%rsp
  40f33f:	53                   	push   %rbx
  40f340:	41 54                	push   %r12
  40f342:	41 55                	push   %r13
  40f344:	bb 00 00 00 00       	mov    $0x0,%ebx
  40f349:	0f 1f 80 00 00 00 00 	nopl   0x0(%rax)
  40f350:	2e 2e 2e 48 89 f0    	cs cs cs mov %rsi,%rax
  40f356:	48 c1 e8 28          	shr    $0x28,%rax
  40f35a:	48 25 ff ff 00 00    	and    $0xffff,%rax
  40f360:	48 83 f8 11          	cmp    $0x11,%rax
  40f364:	75 0f                	jne    40f375 <p114r_FID_36_100_105_114_101_99_116_46_101_120_112_97_110_100_+0x45>
  40f366:	48 b8 00 00 00 00 00 11 00 01 	movabs $0x100110000000000,%rax
  40f370:	e9 ab 00 00 00       	jmpq   40f420 <p114r_FID_36_100_105_114_101_99_116_46_101_120_112_97_110_100_+0xf0>
  40f375:	48 83 f8 12          	cmp    $0x12,%rax
  40f379:	0f 85 ae 01 00 00    	jne    40f52d <p114r_FID_36_100_105_114_101_99_116_46_101_120_112_97_110_100_+0x1fd>
  40f37f:	48 8d 95 00 e8 ff ff 	lea    -0x1800(%rbp),%rdx
  40f386:	49 89 fc             	mov    %rdi,%r12
  40f389:	e8 92 e5 00 00       	callq  41d920 <p125_rt_take2>
  40f38e:	4c 89 e7             	mov    %r12,%rdi
  40f391:	48 8b b5 00 e8 ff ff 	mov    -0x1800(%rbp),%rsi
  40f398:	4c 8b a5 08 e8 ff ff 	mov    -0x17f8(%rbp),%r12
  40f39f:	48 89 f0             	mov    %rsi,%rax
  40f3a2:	48 c1 e8 28          	shr    $0x28,%rax
  40f3a6:	48 25 ff ff 00 00    	and    $0xffff,%rax
  40f3ac:	48 83 f8 08          	cmp    $0x8,%rax
  40f3b0:	0f 85 2f 01 00 00    	jne    40f4e5 <p114r_FID_36_100_105_114_101_99_116_46_101_120_112_97_110_100_+0x1b5>
  40f3b6:	48 8d 95 00 e8 ff ff 	lea    -0x1800(%rbp),%rdx
  40f3bd:	49 89 fd             	mov    %rdi,%r13
  40f3c0:	e8 5b e5 00 00       	callq  41d920 <p125_rt_take2>
  40f3c5:	4c 89 ef             	mov    %r13,%rdi
  40f3c8:	48 8b b5 00 e8 ff ff 	mov    -0x1800(%rbp),%rsi
  40f3cf:	48 8b 95 08 e8 ff ff 	mov    -0x17f8(%rbp),%rdx
  40f3d6:	4c 89 a5 00 e8 ff ff 	mov    %r12,-0x1800(%rbp)
  40f3dd:	48 8b 47 10          	mov    0x10(%rdi),%rax
  40f3e1:	4c 89 20             	mov    %r12,(%rax)
  40f3e4:	48 c7 40 08 07 01 00 00 	movq   $0x107,0x8(%rax)
  40f3ec:	48 83 c0 10          	add    $0x10,%rax
  40f3f0:	48 89 47 10          	mov    %rax,0x10(%rdi)
  40f3f4:	48 83 c3 01          	add    $0x1,%rbx
  40f3f8:	48 89 b5 00 e8 ff ff 	mov    %rsi,-0x1800(%rbp)
  40f3ff:	48 89 95 08 e8 ff ff 	mov    %rdx,-0x17f8(%rbp)
  40f406:	49 89 fc             	mov    %rdi,%r12
  40f409:	e8 b2 66 ff ff       	callq  405ac0 <p113d_FID_36_100_105_114_101_99_116_46_108_114_101_112_101_97_116_>
  40f40e:	4c 89 e7             	mov    %r12,%rdi
  40f411:	66 66 2e 0f 1f 84 00 00 00 00 00 	data16 nopw %cs:0x0(%rax,%rax,1)
  40f41c:	0f 1f 40 00          	nopl   0x0(%rax)
  40f420:	48 83 fb 00          	cmp    $0x0,%rbx
  40f424:	0f 84 2b 01 00 00    	je     40f555 <p114r_FID_36_100_105_114_101_99_116_46_101_120_112_97_110_100_+0x225>
  40f42a:	48 8b 4f 10          	mov    0x10(%rdi),%rcx
  40f42e:	48 89 ca             	mov    %rcx,%rdx
  40f431:	48 83 c2 f8          	add    $0xfffffffffffffff8,%rdx
  40f435:	48 89 57 10          	mov    %rdx,0x10(%rdi)
  40f439:	48 8b 71 f8          	mov    -0x8(%rcx),%rsi
  40f43d:	48 81 fe 07 01 00 00 	cmp    $0x107,%rsi
  40f444:	41 0f 94 c0          	sete   %r8b
  40f448:	45 0f b6 c0          	movzbl %r8b,%r8d
  40f44c:	48 89 ca             	mov    %rcx,%rdx
  40f44f:	48 83 ea 10          	sub    $0x10,%rdx
  40f453:	41 83 f8 00          	cmp    $0x0,%r8d
  40f457:	75 4c                	jne    40f4a5 <p114r_FID_36_100_105_114_101_99_116_46_101_120_112_97_110_100_+0x175>
  40f459:	0f 1f 80 00 00 00 00 	nopl   0x0(%rax)
  40f460:	48 81 fe 08 01 00 00 	cmp    $0x108,%rsi
  40f467:	75 2d                	jne    40f496 <p114r_FID_36_100_105_114_101_99_116_46_101_120_112_97_110_100_+0x166>
  40f469:	48 89 57 10          	mov    %rdx,0x10(%rdi)
  40f46d:	48 83 e9 10          	sub    $0x10,%rcx
  40f471:	48 8b 31             	mov    (%rcx),%rsi
  40f474:	48 89 b5 00 f8 ff ff 	mov    %rsi,-0x800(%rbp)
  40f47b:	48 89 85 08 f8 ff ff 	mov    %rax,-0x7f8(%rbp)
  40f482:	48 89 c2             	mov    %rax,%rdx
  40f485:	49 89 fc             	mov    %rdi,%r12
  40f488:	e8 63 67 ff ff       	callq  405bf0 <p113d_FID_36_100_105_114_101_99_116_46_108_99_111_110_99_97_116_>
  40f48d:	4c 89 e7             	mov    %r12,%rdi
  40f490:	48 83 eb 01          	sub    $0x1,%rbx
  40f494:	eb 8a                	jmp    40f420 <p114r_FID_36_100_105_114_101_99_116_46_101_120_112_97_110_100_+0xf0>
  40f496:	be 04 00 00 00       	mov    $0x4,%esi
  40f49b:	e8 60 94 00 00       	callq  418900 <p111_rt_fail>
  40f4a0:	e9 b0 00 00 00       	jmpq   40f555 <p114r_FID_36_100_105_114_101_99_116_46_101_120_112_97_110_100_+0x225>
  40f4a5:	48 89 57 10          	mov    %rdx,0x10(%rdi)
  40f4a9:	48 83 e9 10          	sub    $0x10,%rcx
  40f4ad:	48 8b 31             	mov    (%rcx),%rsi
  40f4b0:	48 89 85 00 f0 ff ff 	mov    %rax,-0x1000(%rbp)
  40f4b7:	b9 01 00 00 00       	mov    $0x1,%ecx
  40f4bc:	48 8d 95 00 f0 ff ff 	lea    -0x1000(%rbp),%rdx
  40f4c3:	49 89 f5             	mov    %rsi,%r13
  40f4c6:	be 08 01 00 00       	mov    $0x108,%esi
  40f4cb:	49 89 fc             	mov    %rdi,%r12
  40f4ce:	e8 dd 91 00 00       	callq  4186b0 <p111_rt_frame>
  40f4d3:	4c 89 ee             	mov    %r13,%rsi
  40f4d6:	4c 89 e7             	mov    %r12,%rdi
  40f4d9:	48 89 b5 00 f0 ff ff 	mov    %rsi,-0x1000(%rbp)
  40f4e0:	e9 6b fe ff ff       	jmpq   40f350 <p114r_FID_36_100_105_114_101_99_116_46_101_120_112_97_110_100_+0x20>
  40f4e5:	4c 89 a5 00 e8 ff ff 	mov    %r12,-0x1800(%rbp)
  40f4ec:	48 8b 47 10          	mov    0x10(%rdi),%rax
  40f4f0:	4c 89 20             	mov    %r12,(%rax)
  40f4f3:	48 c7 40 08 09 01 00 00 	movq   $0x109,0x8(%rax)
  40f4fb:	48 83 c0 10          	add    $0x10,%rax
  40f4ff:	48 89 47 10          	mov    %rax,0x10(%rdi)
  40f503:	48 89 b5 00 e8 ff ff 	mov    %rsi,-0x1800(%rbp)
  40f50a:	48 8b 47 10          	mov    0x10(%rdi),%rax
  40f50e:	48 89 30             	mov    %rsi,(%rax)
  40f511:	48 c7 40 08 0a 01 00 00 	movq   $0x10a,0x8(%rax)
  40f519:	48 83 c0 10          	add    $0x10,%rax
  40f51d:	48 89 47 10          	mov    %rax,0x10(%rdi)
  40f521:	be 04 00 00 00       	mov    $0x4,%esi
  40f526:	e8 d5 93 00 00       	callq  418900 <p111_rt_fail>
  40f52b:	eb 28                	jmp    40f555 <p114r_FID_36_100_105_114_101_99_116_46_101_120_112_97_110_100_+0x225>
  40f52d:	48 89 b5 00 e8 ff ff 	mov    %rsi,-0x1800(%rbp)
  40f534:	48 8b 47 10          	mov    0x10(%rdi),%rax
  40f538:	48 89 30             	mov    %rsi,(%rax)
  40f53b:	48 c7 40 08 0b 01 00 00 	movq   $0x10b,0x8(%rax)
  40f543:	48 83 c0 10          	add    $0x10,%rax
  40f547:	48 89 47 10          	mov    %rax,0x10(%rdi)
  40f54b:	be 04 00 00 00       	mov    $0x4,%esi
  40f550:	e8 ab 93 00 00       	callq  418900 <p111_rt_fail>
  40f555:	41 5d                	pop    %r13
  40f557:	41 5c                	pop    %r12
  40f559:	5b                   	pop    %rbx
  40f55a:	c9                   	leaveq 
  40f55b:	c3                   	retq   
  40f55c:	0f 1f 40 00          	nopl   0x0(%rax)

