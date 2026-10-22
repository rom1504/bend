000000000040f320 <p114r_FID_36_100_105_114_101_99_116_46_101_120_112_97_110_100_>:
  40f320:	f3 0f 1e fa          	endbr64 
  40f324:	55                   	push   %rbp
  40f325:	48 89 e5             	mov    %rsp,%rbp
  40f328:	48 81 ec 08 18 00 00 	sub    $0x1808,%rsp
  40f32f:	53                   	push   %rbx
  40f330:	41 54                	push   %r12
  40f332:	41 55                	push   %r13
  40f334:	bb 00 00 00 00       	mov    $0x0,%ebx
  40f339:	0f 1f 80 00 00 00 00 	nopl   0x0(%rax)
  40f340:	48 89 f0             	mov    %rsi,%rax
  40f343:	48 c1 e8 28          	shr    $0x28,%rax
  40f347:	48 25 ff ff 00 00    	and    $0xffff,%rax
  40f34d:	48 83 f8 11          	cmp    $0x11,%rax
  40f351:	75 12                	jne    40f365 <p114r_FID_36_100_105_114_101_99_116_46_101_120_112_97_110_100_+0x45>
  40f353:	2e 2e 2e 48 b8 00 00 00 00 00 11 00 01 	cs cs cs movabs $0x100110000000000,%rax
  40f360:	e9 ab 00 00 00       	jmpq   40f410 <p114r_FID_36_100_105_114_101_99_116_46_101_120_112_97_110_100_+0xf0>
  40f365:	48 83 f8 12          	cmp    $0x12,%rax
  40f369:	0f 85 a7 01 00 00    	jne    40f516 <p114r_FID_36_100_105_114_101_99_116_46_101_120_112_97_110_100_+0x1f6>
  40f36f:	b9 02 00 00 00       	mov    $0x2,%ecx
  40f374:	48 8d 95 00 e8 ff ff 	lea    -0x1800(%rbp),%rdx
  40f37b:	49 89 fc             	mov    %rdi,%r12
  40f37e:	e8 3d cf 00 00       	callq  41c2c0 <p118_p111_rt_take2>
  40f383:	4c 89 e7             	mov    %r12,%rdi
  40f386:	48 8b b5 00 e8 ff ff 	mov    -0x1800(%rbp),%rsi
  40f38d:	4c 8b a5 08 e8 ff ff 	mov    -0x17f8(%rbp),%r12
  40f394:	48 89 f0             	mov    %rsi,%rax
  40f397:	48 c1 e8 28          	shr    $0x28,%rax
  40f39b:	48 25 ff ff 00 00    	and    $0xffff,%rax
  40f3a1:	48 83 f8 08          	cmp    $0x8,%rax
  40f3a5:	0f 85 23 01 00 00    	jne    40f4ce <p114r_FID_36_100_105_114_101_99_116_46_101_120_112_97_110_100_+0x1ae>
  40f3ab:	b9 02 00 00 00       	mov    $0x2,%ecx
  40f3b0:	48 8d 95 00 e8 ff ff 	lea    -0x1800(%rbp),%rdx
  40f3b7:	49 89 fd             	mov    %rdi,%r13
  40f3ba:	e8 01 cf 00 00       	callq  41c2c0 <p118_p111_rt_take2>
  40f3bf:	4c 89 ef             	mov    %r13,%rdi
  40f3c2:	48 8b b5 00 e8 ff ff 	mov    -0x1800(%rbp),%rsi
  40f3c9:	48 8b 95 08 e8 ff ff 	mov    -0x17f8(%rbp),%rdx
  40f3d0:	4c 89 a5 00 e8 ff ff 	mov    %r12,-0x1800(%rbp)
  40f3d7:	48 8b 47 10          	mov    0x10(%rdi),%rax
  40f3db:	4c 89 20             	mov    %r12,(%rax)
  40f3de:	48 c7 40 08 07 01 00 00 	movq   $0x107,0x8(%rax)
  40f3e6:	48 83 c0 10          	add    $0x10,%rax
  40f3ea:	48 89 47 10          	mov    %rax,0x10(%rdi)
  40f3ee:	48 83 c3 01          	add    $0x1,%rbx
  40f3f2:	48 89 b5 00 e8 ff ff 	mov    %rsi,-0x1800(%rbp)
  40f3f9:	48 89 95 08 e8 ff ff 	mov    %rdx,-0x17f8(%rbp)
  40f400:	49 89 fc             	mov    %rdi,%r12
  40f403:	e8 f8 64 ff ff       	callq  405900 <p113d_FID_36_100_105_114_101_99_116_46_108_114_101_112_101_97_116_>
  40f408:	4c 89 e7             	mov    %r12,%rdi
  40f40b:	0f 1f 44 00 00       	nopl   0x0(%rax,%rax,1)
  40f410:	48 83 fb 00          	cmp    $0x0,%rbx
  40f414:	0f 84 24 01 00 00    	je     40f53e <p114r_FID_36_100_105_114_101_99_116_46_101_120_112_97_110_100_+0x21e>
  40f41a:	48 8b 4f 10          	mov    0x10(%rdi),%rcx
  40f41e:	48 89 ca             	mov    %rcx,%rdx
  40f421:	48 83 c2 f8          	add    $0xfffffffffffffff8,%rdx
  40f425:	48 89 57 10          	mov    %rdx,0x10(%rdi)
  40f429:	48 8b 71 f8          	mov    -0x8(%rcx),%rsi
  40f42d:	48 81 fe 07 01 00 00 	cmp    $0x107,%rsi
  40f434:	41 0f 94 c0          	sete   %r8b
  40f438:	45 0f b6 c0          	movzbl %r8b,%r8d
  40f43c:	48 89 ca             	mov    %rcx,%rdx
  40f43f:	48 83 ea 10          	sub    $0x10,%rdx
  40f443:	41 83 f8 00          	cmp    $0x0,%r8d
  40f447:	75 45                	jne    40f48e <p114r_FID_36_100_105_114_101_99_116_46_101_120_112_97_110_100_+0x16e>
  40f449:	48 81 fe 08 01 00 00 	cmp    $0x108,%rsi
  40f450:	75 2d                	jne    40f47f <p114r_FID_36_100_105_114_101_99_116_46_101_120_112_97_110_100_+0x15f>
  40f452:	48 89 57 10          	mov    %rdx,0x10(%rdi)
  40f456:	48 83 e9 10          	sub    $0x10,%rcx
  40f45a:	48 8b 31             	mov    (%rcx),%rsi
  40f45d:	48 89 b5 00 f8 ff ff 	mov    %rsi,-0x800(%rbp)
  40f464:	48 89 85 08 f8 ff ff 	mov    %rax,-0x7f8(%rbp)
  40f46b:	48 89 c2             	mov    %rax,%rdx
  40f46e:	49 89 fc             	mov    %rdi,%r12
  40f471:	e8 ba 65 ff ff       	callq  405a30 <p113d_FID_36_100_105_114_101_99_116_46_108_99_111_110_99_97_116_>
  40f476:	4c 89 e7             	mov    %r12,%rdi
  40f479:	48 83 eb 01          	sub    $0x1,%rbx
  40f47d:	eb 91                	jmp    40f410 <p114r_FID_36_100_105_114_101_99_116_46_101_120_112_97_110_100_+0xf0>
  40f47f:	be 04 00 00 00       	mov    $0x4,%esi
  40f484:	e8 97 94 00 00       	callq  418920 <p111_rt_fail>
  40f489:	e9 b0 00 00 00       	jmpq   40f53e <p114r_FID_36_100_105_114_101_99_116_46_101_120_112_97_110_100_+0x21e>
  40f48e:	48 89 57 10          	mov    %rdx,0x10(%rdi)
  40f492:	48 83 e9 10          	sub    $0x10,%rcx
  40f496:	48 8b 31             	mov    (%rcx),%rsi
  40f499:	48 89 85 00 f0 ff ff 	mov    %rax,-0x1000(%rbp)
  40f4a0:	b9 01 00 00 00       	mov    $0x1,%ecx
  40f4a5:	48 8d 95 00 f0 ff ff 	lea    -0x1000(%rbp),%rdx
  40f4ac:	49 89 f5             	mov    %rsi,%r13
  40f4af:	be 08 01 00 00       	mov    $0x108,%esi
  40f4b4:	49 89 fc             	mov    %rdi,%r12
  40f4b7:	e8 14 92 00 00       	callq  4186d0 <p111_rt_frame>
  40f4bc:	4c 89 ee             	mov    %r13,%rsi
  40f4bf:	4c 89 e7             	mov    %r12,%rdi
  40f4c2:	48 89 b5 00 f0 ff ff 	mov    %rsi,-0x1000(%rbp)
  40f4c9:	e9 72 fe ff ff       	jmpq   40f340 <p114r_FID_36_100_105_114_101_99_116_46_101_120_112_97_110_100_+0x20>
  40f4ce:	4c 89 a5 00 e8 ff ff 	mov    %r12,-0x1800(%rbp)
  40f4d5:	48 8b 47 10          	mov    0x10(%rdi),%rax
  40f4d9:	4c 89 20             	mov    %r12,(%rax)
  40f4dc:	48 c7 40 08 09 01 00 00 	movq   $0x109,0x8(%rax)
  40f4e4:	48 83 c0 10          	add    $0x10,%rax
  40f4e8:	48 89 47 10          	mov    %rax,0x10(%rdi)
  40f4ec:	48 89 b5 00 e8 ff ff 	mov    %rsi,-0x1800(%rbp)
  40f4f3:	48 8b 47 10          	mov    0x10(%rdi),%rax
  40f4f7:	48 89 30             	mov    %rsi,(%rax)
  40f4fa:	48 c7 40 08 0a 01 00 00 	movq   $0x10a,0x8(%rax)
  40f502:	48 83 c0 10          	add    $0x10,%rax
  40f506:	48 89 47 10          	mov    %rax,0x10(%rdi)
  40f50a:	be 04 00 00 00       	mov    $0x4,%esi
  40f50f:	e8 0c 94 00 00       	callq  418920 <p111_rt_fail>
  40f514:	eb 28                	jmp    40f53e <p114r_FID_36_100_105_114_101_99_116_46_101_120_112_97_110_100_+0x21e>
  40f516:	48 89 b5 00 e8 ff ff 	mov    %rsi,-0x1800(%rbp)
  40f51d:	48 8b 47 10          	mov    0x10(%rdi),%rax
  40f521:	48 89 30             	mov    %rsi,(%rax)
  40f524:	48 c7 40 08 0b 01 00 00 	movq   $0x10b,0x8(%rax)
  40f52c:	48 83 c0 10          	add    $0x10,%rax
  40f530:	48 89 47 10          	mov    %rax,0x10(%rdi)
  40f534:	be 04 00 00 00       	mov    $0x4,%esi
  40f539:	e8 e2 93 00 00       	callq  418920 <p111_rt_fail>
  40f53e:	41 5d                	pop    %r13
  40f540:	41 5c                	pop    %r12
  40f542:	5b                   	pop    %rbx
  40f543:	c9                   	leaveq 
  40f544:	c3                   	retq   
  40f545:	66 66 2e 0f 1f 84 00 00 00 00 00 	data16 nopw %cs:0x0(%rax,%rax,1)

