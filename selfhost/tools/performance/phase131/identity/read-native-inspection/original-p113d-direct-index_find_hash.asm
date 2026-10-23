
/home/ai/bend2/build/publish/bend/selfhost/build/phase111/p131-read-lookup01-identity-original-build/program:     file format elf64-x86-64


Disassembly of section .init:

Disassembly of section .plt:

Disassembly of section .text:

00000000004082f0 <p113d_FID_36_100_105_114_101_99_116_46_105_110_100_101_120_95_102_105_110_100_95_104_97_115_104_>:
  4082f0:	f3 0f 1e fa          	endbr64 
  4082f4:	55                   	push   %rbp
  4082f5:	48 89 e5             	mov    %rsp,%rbp
  4082f8:	48 81 ec 48 01 00 00 	sub    $0x148,%rsp
  4082ff:	53                   	push   %rbx
  408300:	41 54                	push   %r12
  408302:	41 55                	push   %r13
  408304:	41 56                	push   %r14
  408306:	41 57                	push   %r15
  408308:	49 89 d4             	mov    %rdx,%r12
  40830b:	48 83 f9 01          	cmp    $0x1,%rcx
  40830f:	0f 94 c0             	sete   %al
  408312:	0f b6 c0             	movzbl %al,%eax
  408315:	48 c1 e9 28          	shr    $0x28,%rcx
  408319:	48 81 e1 ff ff 7f 00 	and    $0x7fffff,%rcx
  408320:	48 81 f9 02 00 01 00 	cmp    $0x10002,%rcx
  408327:	0f 94 c1             	sete   %cl
  40832a:	0f b6 c9             	movzbl %cl,%ecx
  40832d:	89 c3                	mov    %eax,%ebx
  40832f:	09 cb                	or     %ecx,%ebx
  408331:	0f 85 b6 01 00 00    	jne    4084ed <p113d_FID_36_100_105_114_101_99_116_46_105_110_100_101_120_95_102_105_110_100_95_104_97_115_104_+0x1fd>
  408337:	49 89 fd             	mov    %rdi,%r13
  40833a:	e8 81 ca 01 00       	callq  424dc0 <p111_rt_sink>
  40833f:	4c 89 ef             	mov    %r13,%rdi
  408342:	4c 89 e6             	mov    %r12,%rsi
  408345:	49 89 fc             	mov    %rdi,%r12
  408348:	e8 73 ca 01 00       	callq  424dc0 <p111_rt_sink>
  40834d:	4c 89 e7             	mov    %r12,%rdi
  408350:	89 d8                	mov    %ebx,%eax
  408352:	83 f0 01             	xor    $0x1,%eax
  408355:	75 14                	jne    40836b <p113d_FID_36_100_105_114_101_99_116_46_105_110_100_101_120_95_102_105_110_100_95_104_97_115_104_+0x7b>
  408357:	be 04 00 00 00       	mov    $0x4,%esi
  40835c:	e8 ef d1 01 00       	callq  425550 <p111_rt_fail>
  408361:	b8 00 00 00 00       	mov    $0x0,%eax
  408366:	e9 8e 03 00 00       	jmpq   4086f9 <p113d_FID_36_100_105_114_101_99_116_46_105_110_100_101_120_95_102_105_110_100_95_104_97_115_104_+0x409>
  40836b:	48 b8 2c 82 10 03 00 	movabs $0x20019000310822c,%rax
  408372:	19 00 02 
  408375:	48 89 85 50 ff ff ff 	mov    %rax,-0xb0(%rbp)
  40837c:	48 b8 00 00 00 00 00 	movabs $0x100180000000000,%rax
  408383:	18 00 01 
  408386:	48 89 85 58 ff ff ff 	mov    %rax,-0xa8(%rbp)
  40838d:	48 c7 85 60 ff ff ff 	movq   $0x0,-0xa0(%rbp)
  408394:	00 00 00 00 
  408398:	48 c7 85 68 ff ff ff 	movq   $0x0,-0x98(%rbp)
  40839f:	00 00 00 00 
  4083a3:	48 b8 00 00 00 00 00 	movabs $0x100110000000000,%rax
  4083aa:	11 00 01 
  4083ad:	48 89 85 70 ff ff ff 	mov    %rax,-0x90(%rbp)
  4083b4:	48 b8 00 00 00 00 00 	movabs $0x100110000000000,%rax
  4083bb:	11 00 01 
  4083be:	48 89 85 78 ff ff ff 	mov    %rax,-0x88(%rbp)
  4083c5:	48 c7 45 80 00 00 00 	movq   $0x0,-0x80(%rbp)
  4083cc:	00 
  4083cd:	48 c7 45 88 00 00 00 	movq   $0x0,-0x78(%rbp)
  4083d4:	00 
  4083d5:	b9 08 00 00 00       	mov    $0x8,%ecx
  4083da:	48 8d 95 50 ff ff ff 	lea    -0xb0(%rbp),%rdx
  4083e1:	be 96 00 00 00       	mov    $0x96,%esi
  4083e6:	48 89 fb             	mov    %rdi,%rbx
  4083e9:	e8 42 ca 01 00       	callq  424e30 <p111_rt_ctor>
  4083ee:	48 89 df             	mov    %rbx,%rdi
  4083f1:	48 89 c3             	mov    %rax,%rbx
  4083f4:	48 b8 2c 82 10 03 00 	movabs $0x20019000310822c,%rax
  4083fb:	19 00 02 
  4083fe:	48 89 45 90          	mov    %rax,-0x70(%rbp)
  408402:	48 b8 00 00 00 00 00 	movabs $0x100180000000000,%rax
  408409:	18 00 01 
  40840c:	48 89 45 98          	mov    %rax,-0x68(%rbp)
  408410:	48 c7 45 a0 00 00 00 	movq   $0x0,-0x60(%rbp)
  408417:	00 
  408418:	48 c7 45 a8 00 00 00 	movq   $0x0,-0x58(%rbp)
  40841f:	00 
  408420:	48 b8 00 00 00 00 00 	movabs $0x100110000000000,%rax
  408427:	11 00 01 
  40842a:	48 89 45 b0          	mov    %rax,-0x50(%rbp)
  40842e:	48 b8 00 00 00 00 00 	movabs $0x100110000000000,%rax
  408435:	11 00 01 
  408438:	48 89 45 b8          	mov    %rax,-0x48(%rbp)
  40843c:	48 c7 45 c0 00 00 00 	movq   $0x0,-0x40(%rbp)
  408443:	00 
  408444:	48 c7 45 c8 00 00 00 	movq   $0x0,-0x38(%rbp)
  40844b:	00 
  40844c:	b9 08 00 00 00       	mov    $0x8,%ecx
  408451:	48 8d 55 90          	lea    -0x70(%rbp),%rdx
  408455:	be 96 00 00 00       	mov    $0x96,%esi
  40845a:	49 89 fc             	mov    %rdi,%r12
  40845d:	e8 ce c9 01 00       	callq  424e30 <p111_rt_ctor>
  408462:	4c 89 e7             	mov    %r12,%rdi
  408465:	48 b9 00 00 00 00 00 	movabs $0x100180000000000,%rcx
  40846c:	18 00 01 
  40846f:	48 89 8d 08 ff ff ff 	mov    %rcx,-0xf8(%rbp)
  408476:	48 b9 2c 82 10 03 00 	movabs $0x20019000310822c,%rcx
  40847d:	19 00 02 
  408480:	48 89 8d 10 ff ff ff 	mov    %rcx,-0xf0(%rbp)
  408487:	48 c7 85 18 ff ff ff 	movq   $0x0,-0xe8(%rbp)
  40848e:	00 00 00 00 
  408492:	48 c7 85 20 ff ff ff 	movq   $0x0,-0xe0(%rbp)
  408499:	00 00 00 00 
  40849d:	48 89 9d 28 ff ff ff 	mov    %rbx,-0xd8(%rbp)
  4084a4:	48 89 85 30 ff ff ff 	mov    %rax,-0xd0(%rbp)
  4084ab:	48 b8 00 00 00 00 00 	movabs $0x100110000000000,%rax
  4084b2:	11 00 01 
  4084b5:	48 89 85 38 ff ff ff 	mov    %rax,-0xc8(%rbp)
  4084bc:	48 c7 85 40 ff ff ff 	movq   $0x0,-0xc0(%rbp)
  4084c3:	00 00 00 00 
  4084c7:	48 c7 85 48 ff ff ff 	movq   $0x0,-0xb8(%rbp)
  4084ce:	00 00 00 00 
  4084d2:	b9 09 00 00 00       	mov    $0x9,%ecx
  4084d7:	48 8d 95 08 ff ff ff 	lea    -0xf8(%rbp),%rdx
  4084de:	be 99 00 00 00       	mov    $0x99,%esi
  4084e3:	e8 48 c9 01 00       	callq  424e30 <p111_rt_ctor>
  4084e8:	e9 0c 02 00 00       	jmpq   4086f9 <p113d_FID_36_100_105_114_101_99_116_46_105_110_100_101_120_95_102_105_110_100_95_104_97_115_104_+0x409>
  4084ed:	48 89 f0             	mov    %rsi,%rax
  4084f0:	48 c1 e8 28          	shr    $0x28,%rax
  4084f4:	48 25 ff ff 00 00    	and    $0xffff,%rax
  4084fa:	48 3d 99 00 00 00    	cmp    $0x99,%rax
  408500:	0f 94 c1             	sete   %cl
  408503:	0f b6 c9             	movzbl %cl,%ecx
  408506:	83 f9 00             	cmp    $0x0,%ecx
  408509:	0f 85 ee 00 00 00    	jne    4085fd <p113d_FID_36_100_105_114_101_99_116_46_105_110_100_101_120_95_102_105_110_100_95_104_97_115_104_+0x30d>
  40850f:	48 3d 9a 00 00 00    	cmp    $0x9a,%rax
  408515:	0f 84 bb 00 00 00    	je     4085d6 <p113d_FID_36_100_105_114_101_99_116_46_105_110_100_101_120_95_102_105_110_100_95_104_97_115_104_+0x2e6>
  40851b:	0f 1f 44 00 00       	nopl   0x0(%rax,%rax,1)
  408520:	48 3d 9b 00 00 00    	cmp    $0x9b,%rax
  408526:	74 1d                	je     408545 <p113d_FID_36_100_105_114_101_99_116_46_105_110_100_101_120_95_102_105_110_100_95_104_97_115_104_+0x255>
  408528:	be 04 00 00 00       	mov    $0x4,%esi
  40852d:	48 89 fb             	mov    %rdi,%rbx
  408530:	e8 1b d0 01 00       	callq  425550 <p111_rt_fail>
  408535:	4c 89 e2             	mov    %r12,%rdx
  408538:	48 89 df             	mov    %rbx,%rdi
  40853b:	be 00 00 00 00       	mov    $0x0,%esi
  408540:	e9 af 01 00 00       	jmpq   4086f4 <p113d_FID_36_100_105_114_101_99_116_46_105_110_100_101_120_95_102_105_110_100_95_104_97_115_104_+0x404>
  408545:	4c 89 e2             	mov    %r12,%rdx
  408548:	49 89 d4             	mov    %rdx,%r12
  40854b:	48 8d 95 c0 fe ff ff 	lea    -0x140(%rbp),%rdx
  408552:	48 89 fb             	mov    %rdi,%rbx
  408555:	e8 e6 24 02 00       	callq  42aa40 <p125_rt_take4>
  40855a:	4c 89 e2             	mov    %r12,%rdx
  40855d:	48 89 df             	mov    %rbx,%rdi
  408560:	48 8b 9d d0 fe ff ff 	mov    -0x130(%rbp),%rbx
  408567:	48 8b 85 d8 fe ff ff 	mov    -0x128(%rbp),%rax
  40856e:	48 89 85 c0 fe ff ff 	mov    %rax,-0x140(%rbp)
  408575:	48 b8 00 00 00 00 00 	movabs $0x100110000000000,%rax
  40857c:	11 00 01 
  40857f:	48 89 85 c8 fe ff ff 	mov    %rax,-0x138(%rbp)
  408586:	49 89 d5             	mov    %rdx,%r13
  408589:	48 8d 95 c0 fe ff ff 	lea    -0x140(%rbp),%rdx
  408590:	be 12 00 00 00       	mov    $0x12,%esi
  408595:	49 89 fc             	mov    %rdi,%r12
  408598:	e8 e3 1e 02 00       	callq  42a480 <p125_rt_ctor2>
  40859d:	4c 89 ea             	mov    %r13,%rdx
  4085a0:	4c 89 e7             	mov    %r12,%rdi
  4085a3:	48 89 9d c0 fe ff ff 	mov    %rbx,-0x140(%rbp)
  4085aa:	48 89 85 c8 fe ff ff 	mov    %rax,-0x138(%rbp)
  4085b1:	49 89 d4             	mov    %rdx,%r12
  4085b4:	48 8d 95 c0 fe ff ff 	lea    -0x140(%rbp),%rdx
  4085bb:	be 12 00 00 00       	mov    $0x12,%esi
  4085c0:	48 89 fb             	mov    %rdi,%rbx
  4085c3:	e8 b8 1e 02 00       	callq  42a480 <p125_rt_ctor2>
  4085c8:	4c 89 e2             	mov    %r12,%rdx
  4085cb:	48 89 df             	mov    %rbx,%rdi
  4085ce:	48 89 c6             	mov    %rax,%rsi
  4085d1:	e9 1e 01 00 00       	jmpq   4086f4 <p113d_FID_36_100_105_114_101_99_116_46_105_110_100_101_120_95_102_105_110_100_95_104_97_115_104_+0x404>
  4085d6:	4c 89 e2             	mov    %r12,%rdx
  4085d9:	49 89 d4             	mov    %rdx,%r12
  4085dc:	48 8d 95 c0 fe ff ff 	lea    -0x140(%rbp),%rdx
  4085e3:	48 89 fb             	mov    %rdi,%rbx
  4085e6:	e8 85 1f 02 00       	callq  42a570 <p125_rt_take2>
  4085eb:	4c 89 e2             	mov    %r12,%rdx
  4085ee:	48 89 df             	mov    %rbx,%rdi
  4085f1:	48 8b b5 c8 fe ff ff 	mov    -0x138(%rbp),%rsi
  4085f8:	e9 f7 00 00 00       	jmpq   4086f4 <p113d_FID_36_100_105_114_101_99_116_46_105_110_100_101_120_95_102_105_110_100_95_104_97_115_104_+0x404>
  4085fd:	4c 89 e2             	mov    %r12,%rdx
  408600:	b9 09 00 00 00       	mov    $0x9,%ecx
  408605:	49 89 d5             	mov    %rdx,%r13
  408608:	48 8d 95 c0 fe ff ff 	lea    -0x140(%rbp),%rdx
  40860f:	48 89 fb             	mov    %rdi,%rbx
  408612:	e8 99 c9 01 00       	callq  424fb0 <p111_rt_take>
  408617:	48 89 df             	mov    %rbx,%rdi
  40861a:	48 8b b5 c0 fe ff ff 	mov    -0x140(%rbp),%rsi
  408621:	4c 8b bd c8 fe ff ff 	mov    -0x138(%rbp),%r15
  408628:	4c 8b b5 d0 fe ff ff 	mov    -0x130(%rbp),%r14
  40862f:	4c 8b a5 d8 fe ff ff 	mov    -0x128(%rbp),%r12
  408636:	48 8b 9d e0 fe ff ff 	mov    -0x120(%rbp),%rbx
  40863d:	48 89 5d f0          	mov    %rbx,-0x10(%rbp)
  408641:	48 8b 9d e8 fe ff ff 	mov    -0x118(%rbp),%rbx
  408648:	48 89 5d e8          	mov    %rbx,-0x18(%rbp)
  40864c:	48 8b 9d f0 fe ff ff 	mov    -0x110(%rbp),%rbx
  408653:	48 89 5d e0          	mov    %rbx,-0x20(%rbp)
  408657:	48 8b 9d f8 fe ff ff 	mov    -0x108(%rbp),%rbx
  40865e:	48 89 5d d8          	mov    %rbx,-0x28(%rbp)
  408662:	48 8b 9d 00 ff ff ff 	mov    -0x100(%rbp),%rbx
  408669:	48 89 5d d0          	mov    %rbx,-0x30(%rbp)
  40866d:	48 89 fb             	mov    %rdi,%rbx
  408670:	e8 4b c7 01 00       	callq  424dc0 <p111_rt_sink>
  408675:	4c 89 fe             	mov    %r15,%rsi
  408678:	48 89 df             	mov    %rbx,%rdi
  40867b:	4c 8b 7d f0          	mov    -0x10(%rbp),%r15
  40867f:	48 89 fb             	mov    %rdi,%rbx
  408682:	e8 39 c7 01 00       	callq  424dc0 <p111_rt_sink>
  408687:	4c 89 f6             	mov    %r14,%rsi
  40868a:	48 89 df             	mov    %rbx,%rdi
  40868d:	4c 8b 75 e8          	mov    -0x18(%rbp),%r14
  408691:	48 89 fb             	mov    %rdi,%rbx
  408694:	e8 27 c7 01 00       	callq  424dc0 <p111_rt_sink>
  408699:	4c 89 e6             	mov    %r12,%rsi
  40869c:	48 89 df             	mov    %rbx,%rdi
  40869f:	4c 8b 65 e0          	mov    -0x20(%rbp),%r12
  4086a3:	48 89 fb             	mov    %rdi,%rbx
  4086a6:	e8 15 c7 01 00       	callq  424dc0 <p111_rt_sink>
  4086ab:	4c 89 fe             	mov    %r15,%rsi
  4086ae:	48 89 df             	mov    %rbx,%rdi
  4086b1:	4c 8b 7d d8          	mov    -0x28(%rbp),%r15
  4086b5:	48 89 fb             	mov    %rdi,%rbx
  4086b8:	e8 03 c7 01 00       	callq  424dc0 <p111_rt_sink>
  4086bd:	4c 89 f6             	mov    %r14,%rsi
  4086c0:	48 89 df             	mov    %rbx,%rdi
  4086c3:	4c 8b 75 d0          	mov    -0x30(%rbp),%r14
  4086c7:	48 89 fb             	mov    %rdi,%rbx
  4086ca:	e8 f1 c6 01 00       	callq  424dc0 <p111_rt_sink>
  4086cf:	4c 89 fe             	mov    %r15,%rsi
  4086d2:	48 89 df             	mov    %rbx,%rdi
  4086d5:	48 89 fb             	mov    %rdi,%rbx
  4086d8:	e8 e3 c6 01 00       	callq  424dc0 <p111_rt_sink>
  4086dd:	4c 89 f6             	mov    %r14,%rsi
  4086e0:	48 89 df             	mov    %rbx,%rdi
  4086e3:	48 89 fb             	mov    %rdi,%rbx
  4086e6:	e8 d5 c6 01 00       	callq  424dc0 <p111_rt_sink>
  4086eb:	4c 89 ea             	mov    %r13,%rdx
  4086ee:	4c 89 e6             	mov    %r12,%rsi
  4086f1:	48 89 df             	mov    %rbx,%rdi
  4086f4:	e8 47 f6 ff ff       	callq  407d40 <p113d_FID_36_100_105_114_101_99_116_46_105_110_100_101_120_95_98_117_99_107_101_116_>
  4086f9:	41 5f                	pop    %r15
  4086fb:	41 5e                	pop    %r14
  4086fd:	41 5d                	pop    %r13
  4086ff:	41 5c                	pop    %r12
  408701:	5b                   	pop    %rbx
  408702:	c9                   	leaveq 
  408703:	c3                   	retq   

Disassembly of section .fini:
