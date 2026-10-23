
/home/ai/bend2/build/publish/bend/selfhost/build/phase111/p131-read-lookup01-identity-original-build/program:     file format elf64-x86-64


Disassembly of section .init:

Disassembly of section .plt:

Disassembly of section .text:

0000000000414300 <p111_FID_36_100_105_114_101_99_116_46_105_110_100_101_120_95_102_105_110_100_>:
  414300:	f3 0f 1e fa          	endbr64 
  414304:	55                   	push   %rbp
  414305:	48 89 e5             	mov    %rsp,%rbp
  414308:	48 81 ec 78 10 00 00 	sub    $0x1078,%rsp
  41430f:	53                   	push   %rbx
  414310:	41 54                	push   %r12
  414312:	41 55                	push   %r13
  414314:	41 56                	push   %r14
  414316:	41 57                	push   %r15
  414318:	48 8b 77 28          	mov    0x28(%rdi),%rsi
  41431c:	4c 8b 6f 30          	mov    0x30(%rdi),%r13
  414320:	4c 8b 67 38          	mov    0x38(%rdi),%r12
  414324:	48 8b 5f 40          	mov    0x40(%rdi),%rbx
  414328:	48 89 f0             	mov    %rsi,%rax
  41432b:	48 c1 e8 28          	shr    $0x28,%rax
  41432f:	48 25 ff ff 00 00    	and    $0xffff,%rax
  414335:	48 3d 99 00 00 00    	cmp    $0x99,%rax
  41433b:	0f 94 c1             	sete   %cl
  41433e:	0f b6 c9             	movzbl %cl,%ecx
  414341:	83 f9 00             	cmp    $0x0,%ecx
  414344:	0f 85 bb 05 00 00    	jne    414905 <p111_FID_36_100_105_114_101_99_116_46_105_110_100_101_120_95_102_105_110_100_+0x605>
  41434a:	48 3d 9a 00 00 00    	cmp    $0x9a,%rax
  414350:	0f 94 c1             	sete   %cl
  414353:	0f b6 c9             	movzbl %cl,%ecx
  414356:	ba ff ff ff ff       	mov    $0xffffffff,%edx
  41435b:	4d 89 e6             	mov    %r12,%r14
  41435e:	49 21 d6             	and    %rdx,%r14
  414361:	4c 89 75 e8          	mov    %r14,-0x18(%rbp)
  414365:	83 f9 00             	cmp    $0x0,%ecx
  414368:	0f 85 2e 04 00 00    	jne    41479c <p111_FID_36_100_105_114_101_99_116_46_105_110_100_101_120_95_102_105_110_100_+0x49c>
  41436e:	48 3d 9b 00 00 00    	cmp    $0x9b,%rax
  414374:	0f 84 8b 00 00 00    	je     414405 <p111_FID_36_100_105_114_101_99_116_46_105_110_100_101_120_95_102_105_110_100_+0x105>
  41437a:	2e 2e 2e 2e 48 89 9d 	cs cs cs mov %rbx,%cs:-0x1070(%rbp)
  414381:	90 ef ff ff 
  414385:	48 8b 47 10          	mov    0x10(%rdi),%rax
  414389:	48 89 18             	mov    %rbx,(%rax)
  41438c:	48 c7 40 08 15 01 00 	movq   $0x115,0x8(%rax)
  414393:	00 
  414394:	48 83 c0 10          	add    $0x10,%rax
  414398:	48 89 47 10          	mov    %rax,0x10(%rdi)
  41439c:	4c 89 a5 90 ef ff ff 	mov    %r12,-0x1070(%rbp)
  4143a3:	48 8b 47 10          	mov    0x10(%rdi),%rax
  4143a7:	4c 89 20             	mov    %r12,(%rax)
  4143aa:	48 c7 40 08 16 01 00 	movq   $0x116,0x8(%rax)
  4143b1:	00 
  4143b2:	48 83 c0 10          	add    $0x10,%rax
  4143b6:	48 89 47 10          	mov    %rax,0x10(%rdi)
  4143ba:	4c 89 ad 90 ef ff ff 	mov    %r13,-0x1070(%rbp)
  4143c1:	48 8b 47 10          	mov    0x10(%rdi),%rax
  4143c5:	4c 89 28             	mov    %r13,(%rax)
  4143c8:	48 c7 40 08 17 01 00 	movq   $0x117,0x8(%rax)
  4143cf:	00 
  4143d0:	48 83 c0 10          	add    $0x10,%rax
  4143d4:	48 89 47 10          	mov    %rax,0x10(%rdi)
  4143d8:	48 89 b5 90 ef ff ff 	mov    %rsi,-0x1070(%rbp)
  4143df:	48 8b 47 10          	mov    0x10(%rdi),%rax
  4143e3:	48 89 30             	mov    %rsi,(%rax)
  4143e6:	48 c7 40 08 18 01 00 	movq   $0x118,0x8(%rax)
  4143ed:	00 
  4143ee:	48 83 c0 10          	add    $0x10,%rax
  4143f2:	48 89 47 10          	mov    %rax,0x10(%rdi)
  4143f6:	be 04 00 00 00       	mov    $0x4,%esi
  4143fb:	e8 50 11 01 00       	callq  425550 <p111_rt_fail>
  414400:	e9 4e 06 00 00       	jmpq   414a53 <p111_FID_36_100_105_114_101_99_116_46_105_110_100_101_120_95_102_105_110_100_+0x753>
  414405:	2e 2e 2e 2e 48 8d 95 	cs cs cs lea %cs:-0x1070(%rbp),%rdx
  41440c:	90 ef ff ff 
  414410:	49 89 fe             	mov    %rdi,%r14
  414413:	e8 28 66 01 00       	callq  42aa40 <p125_rt_take4>
  414418:	4c 89 f7             	mov    %r14,%rdi
  41441b:	48 8b b5 90 ef ff ff 	mov    -0x1070(%rbp),%rsi
  414422:	48 89 75 d0          	mov    %rsi,-0x30(%rbp)
  414426:	48 8b b5 98 ef ff ff 	mov    -0x1068(%rbp),%rsi
  41442d:	4c 8b bd a0 ef ff ff 	mov    -0x1060(%rbp),%r15
  414434:	4c 89 7d e0          	mov    %r15,-0x20(%rbp)
  414438:	4d 89 ee             	mov    %r13,%r14
  41443b:	4c 8b ad a8 ef ff ff 	mov    -0x1058(%rbp),%r13
  414442:	49 89 ff             	mov    %rdi,%r15
  414445:	e8 e6 08 01 00       	callq  424d30 <p111_rt_keep>
  41444a:	4c 89 ff             	mov    %r15,%rdi
  41444d:	4c 8b 7d e0          	mov    -0x20(%rbp),%r15
  414451:	48 8b 75 d0          	mov    -0x30(%rbp),%rsi
  414455:	48 89 c1             	mov    %rax,%rcx
  414458:	48 8b 45 e8          	mov    -0x18(%rbp),%rax
  41445c:	48 89 4d c8          	mov    %rcx,-0x38(%rbp)
  414460:	ba ff ff ff ff       	mov    $0xffffffff,%edx
  414465:	48 21 d1             	and    %rdx,%rcx
  414468:	48 89 4d f0          	mov    %rcx,-0x10(%rbp)
  41446c:	48 83 f9 00          	cmp    $0x0,%rcx
  414470:	0f 94 c2             	sete   %dl
  414473:	0f b6 d2             	movzbl %dl,%edx
  414476:	89 55 f8             	mov    %edx,-0x8(%rbp)
  414479:	48 83 fa 01          	cmp    $0x1,%rdx
  41447d:	0f 94 c1             	sete   %cl
  414480:	0f b6 c9             	movzbl %cl,%ecx
  414483:	48 c1 ea 28          	shr    $0x28,%rdx
  414487:	48 81 e2 ff ff 7f 00 	and    $0x7fffff,%rdx
  41448e:	48 81 fa 02 00 01 00 	cmp    $0x10002,%rdx
  414495:	0f 94 c2             	sete   %dl
  414498:	0f b6 d2             	movzbl %dl,%edx
  41449b:	09 ca                	or     %ecx,%edx
  41449d:	89 55 fc             	mov    %edx,-0x4(%rbp)
  4144a0:	0f 85 3f 02 00 00    	jne    4146e5 <p111_FID_36_100_105_114_101_99_116_46_105_110_100_101_120_95_102_105_110_100_+0x3e5>
  4144a6:	49 89 ff             	mov    %rdi,%r15
  4144a9:	e8 12 09 01 00       	callq  424dc0 <p111_rt_sink>
  4144ae:	4c 89 ff             	mov    %r15,%rdi
  4144b1:	48 8b 45 c8          	mov    -0x38(%rbp),%rax
  4144b5:	4c 8b 7d e0          	mov    -0x20(%rbp),%r15
  4144b9:	8b 4d f8             	mov    -0x8(%rbp),%ecx
  4144bc:	8b 55 fc             	mov    -0x4(%rbp),%edx
  4144bf:	83 f2 01             	xor    $0x1,%edx
  4144c2:	75 6d                	jne    414531 <p111_FID_36_100_105_114_101_99_116_46_105_110_100_101_120_95_102_105_110_100_+0x231>
  4144c4:	49 89 c4             	mov    %rax,%r12
  4144c7:	89 cb                	mov    %ecx,%ebx
  4144c9:	4c 89 f6             	mov    %r14,%rsi
  4144cc:	49 89 fe             	mov    %rdi,%r14
  4144cf:	e8 ec 08 01 00       	callq  424dc0 <p111_rt_sink>
  4144d4:	4c 89 f7             	mov    %r14,%rdi
  4144d7:	4c 89 e0             	mov    %r12,%rax
  4144da:	48 89 c6             	mov    %rax,%rsi
  4144dd:	49 89 fc             	mov    %rdi,%r12
  4144e0:	e8 db 08 01 00       	callq  424dc0 <p111_rt_sink>
  4144e5:	4c 89 e7             	mov    %r12,%rdi
  4144e8:	4c 89 fe             	mov    %r15,%rsi
  4144eb:	49 89 fc             	mov    %rdi,%r12
  4144ee:	e8 cd 08 01 00       	callq  424dc0 <p111_rt_sink>
  4144f3:	4c 89 e7             	mov    %r12,%rdi
  4144f6:	4c 89 ee             	mov    %r13,%rsi
  4144f9:	49 89 fc             	mov    %rdi,%r12
  4144fc:	e8 bf 08 01 00       	callq  424dc0 <p111_rt_sink>
  414501:	4c 89 e7             	mov    %r12,%rdi
  414504:	48 89 9d 90 ef ff ff 	mov    %rbx,-0x1070(%rbp)
  41450b:	48 8b 47 10          	mov    0x10(%rdi),%rax
  41450f:	48 89 18             	mov    %rbx,(%rax)
  414512:	48 c7 40 08 14 01 00 	movq   $0x114,0x8(%rax)
  414519:	00 
  41451a:	48 83 c0 10          	add    $0x10,%rax
  41451e:	48 89 47 10          	mov    %rax,0x10(%rdi)
  414522:	be 04 00 00 00       	mov    $0x4,%esi
  414527:	e8 24 10 01 00       	callq  425550 <p111_rt_fail>
  41452c:	e9 22 05 00 00       	jmpq   414a53 <p111_FID_36_100_105_114_101_99_116_46_105_110_100_101_120_95_102_105_110_100_+0x753>
  414531:	b9 00 00 00 00       	mov    $0x0,%ecx
  414536:	48 8d 95 90 ef ff ff 	lea    -0x1070(%rbp),%rdx
  41453d:	be 00 00 00 00       	mov    $0x0,%esi
  414542:	49 89 ff             	mov    %rdi,%r15
  414545:	e8 e6 08 01 00       	callq  424e30 <p111_rt_ctor>
  41454a:	4c 89 ff             	mov    %r15,%rdi
  41454d:	48 89 c6             	mov    %rax,%rsi
  414550:	49 89 ff             	mov    %rdi,%r15
  414553:	e8 68 08 01 00       	callq  424dc0 <p111_rt_sink>
  414558:	4c 89 ff             	mov    %r15,%rdi
  41455b:	4c 8b 7d e0          	mov    -0x20(%rbp),%r15
  41455f:	48 8b 45 e8          	mov    -0x18(%rbp),%rax
  414563:	48 8b 4d f0          	mov    -0x10(%rbp),%rcx
  414567:	48 21 c8             	and    %rcx,%rax
  41456a:	b9 ff ff ff ff       	mov    $0xffffffff,%ecx
  41456f:	48 21 c8             	and    %rcx,%rax
  414572:	48 83 f8 00          	cmp    $0x0,%rax
  414576:	0f 94 c1             	sete   %cl
  414579:	0f b6 c9             	movzbl %cl,%ecx
  41457c:	89 4d d8             	mov    %ecx,-0x28(%rbp)
  41457f:	48 83 f9 01          	cmp    $0x1,%rcx
  414583:	0f 94 c0             	sete   %al
  414586:	0f b6 c0             	movzbl %al,%eax
  414589:	48 c1 e9 28          	shr    $0x28,%rcx
  41458d:	48 81 e1 ff ff 7f 00 	and    $0x7fffff,%rcx
  414594:	48 81 f9 02 00 01 00 	cmp    $0x10002,%rcx
  41459b:	0f 94 c1             	sete   %cl
  41459e:	0f b6 c9             	movzbl %cl,%ecx
  4145a1:	09 c8                	or     %ecx,%eax
  4145a3:	89 45 dc             	mov    %eax,-0x24(%rbp)
  4145a6:	0f 85 c7 00 00 00    	jne    414673 <p111_FID_36_100_105_114_101_99_116_46_105_110_100_101_120_95_102_105_110_100_+0x373>
  4145ac:	4c 89 fe             	mov    %r15,%rsi
  4145af:	49 89 ff             	mov    %rdi,%r15
  4145b2:	e8 09 08 01 00       	callq  424dc0 <p111_rt_sink>
  4145b7:	4c 89 ff             	mov    %r15,%rdi
  4145ba:	44 8b 7d d8          	mov    -0x28(%rbp),%r15d
  4145be:	8b 45 dc             	mov    -0x24(%rbp),%eax
  4145c1:	83 f0 01             	xor    $0x1,%eax
  4145c4:	75 4c                	jne    414612 <p111_FID_36_100_105_114_101_99_116_46_105_110_100_101_120_95_102_105_110_100_+0x312>
  4145c6:	44 89 fb             	mov    %r15d,%ebx
  4145c9:	4c 89 f6             	mov    %r14,%rsi
  4145cc:	49 89 fc             	mov    %rdi,%r12
  4145cf:	e8 ec 07 01 00       	callq  424dc0 <p111_rt_sink>
  4145d4:	4c 89 e7             	mov    %r12,%rdi
  4145d7:	4c 89 ee             	mov    %r13,%rsi
  4145da:	49 89 fc             	mov    %rdi,%r12
  4145dd:	e8 de 07 01 00       	callq  424dc0 <p111_rt_sink>
  4145e2:	4c 89 e7             	mov    %r12,%rdi
  4145e5:	48 89 9d 90 ef ff ff 	mov    %rbx,-0x1070(%rbp)
  4145ec:	48 8b 47 10          	mov    0x10(%rdi),%rax
  4145f0:	48 89 18             	mov    %rbx,(%rax)
  4145f3:	48 c7 40 08 13 01 00 	movq   $0x113,0x8(%rax)
  4145fa:	00 
  4145fb:	48 83 c0 10          	add    $0x10,%rax
  4145ff:	48 89 47 10          	mov    %rax,0x10(%rdi)
  414603:	be 04 00 00 00       	mov    $0x4,%esi
  414608:	e8 43 0f 01 00       	callq  425550 <p111_rt_fail>
  41460d:	e9 41 04 00 00       	jmpq   414a53 <p111_FID_36_100_105_114_101_99_116_46_105_110_100_101_120_95_102_105_110_100_+0x753>
  414612:	b9 00 00 00 00       	mov    $0x0,%ecx
  414617:	48 8d 95 90 ef ff ff 	lea    -0x1070(%rbp),%rdx
  41461e:	be 00 00 00 00       	mov    $0x0,%esi
  414623:	49 89 ff             	mov    %rdi,%r15
  414626:	e8 05 08 01 00       	callq  424e30 <p111_rt_ctor>
  41462b:	4c 89 ff             	mov    %r15,%rdi
  41462e:	48 89 c6             	mov    %rax,%rsi
  414631:	49 89 ff             	mov    %rdi,%r15
  414634:	e8 87 07 01 00       	callq  424dc0 <p111_rt_sink>
  414639:	4c 89 ff             	mov    %r15,%rdi
  41463c:	4c 89 ad 90 ef ff ff 	mov    %r13,-0x1070(%rbp)
  414643:	4c 89 b5 98 ef ff ff 	mov    %r14,-0x1068(%rbp)
  41464a:	4c 89 a5 a0 ef ff ff 	mov    %r12,-0x1060(%rbp)
  414651:	48 89 9d a8 ef ff ff 	mov    %rbx,-0x1058(%rbp)
  414658:	b9 04 00 00 00       	mov    $0x4,%ecx
  41465d:	48 8d 95 90 ef ff ff 	lea    -0x1070(%rbp),%rdx
  414664:	be 10 01 00 00       	mov    $0x110,%esi
  414669:	e8 12 0d 01 00       	callq  425380 <p111_rt_jump>
  41466e:	e9 e0 03 00 00       	jmpq   414a53 <p111_FID_36_100_105_114_101_99_116_46_105_110_100_101_120_95_102_105_110_100_+0x753>
  414673:	2e 2e 2e 4c 89 ee    	cs cs cs mov %r13,%rsi
  414679:	49 89 fd             	mov    %rdi,%r13
  41467c:	e8 3f 07 01 00       	callq  424dc0 <p111_rt_sink>
  414681:	4c 89 ef             	mov    %r13,%rdi
  414684:	b9 00 00 00 00       	mov    $0x0,%ecx
  414689:	48 8d 95 90 ef ff ff 	lea    -0x1070(%rbp),%rdx
  414690:	be 00 00 00 00       	mov    $0x0,%esi
  414695:	49 89 fd             	mov    %rdi,%r13
  414698:	e8 93 07 01 00       	callq  424e30 <p111_rt_ctor>
  41469d:	4c 89 ef             	mov    %r13,%rdi
  4146a0:	48 89 c6             	mov    %rax,%rsi
  4146a3:	49 89 fd             	mov    %rdi,%r13
  4146a6:	e8 15 07 01 00       	callq  424dc0 <p111_rt_sink>
  4146ab:	4c 89 ef             	mov    %r13,%rdi
  4146ae:	4c 89 bd 90 ef ff ff 	mov    %r15,-0x1070(%rbp)
  4146b5:	4c 89 b5 98 ef ff ff 	mov    %r14,-0x1068(%rbp)
  4146bc:	4c 89 a5 a0 ef ff ff 	mov    %r12,-0x1060(%rbp)
  4146c3:	48 89 9d a8 ef ff ff 	mov    %rbx,-0x1058(%rbp)
  4146ca:	b9 04 00 00 00       	mov    $0x4,%ecx
  4146cf:	48 8d 95 90 ef ff ff 	lea    -0x1070(%rbp),%rdx
  4146d6:	be 10 01 00 00       	mov    $0x110,%esi
  4146db:	e8 a0 0c 01 00       	callq  425380 <p111_rt_jump>
  4146e0:	e9 6e 03 00 00       	jmpq   414a53 <p111_FID_36_100_105_114_101_99_116_46_105_110_100_101_120_95_102_105_110_100_+0x753>
  4146e5:	49 89 c4             	mov    %rax,%r12
  4146e8:	b9 00 00 00 00       	mov    $0x0,%ecx
  4146ed:	48 8d 95 90 ef ff ff 	lea    -0x1070(%rbp),%rdx
  4146f4:	be 00 00 00 00       	mov    $0x0,%esi
  4146f9:	48 89 fb             	mov    %rdi,%rbx
  4146fc:	e8 2f 07 01 00       	callq  424e30 <p111_rt_ctor>
  414701:	48 89 df             	mov    %rbx,%rdi
  414704:	48 89 c6             	mov    %rax,%rsi
  414707:	48 89 fb             	mov    %rdi,%rbx
  41470a:	e8 b1 06 01 00       	callq  424dc0 <p111_rt_sink>
  41470f:	48 89 df             	mov    %rbx,%rdi
  414712:	48 8b 75 d0          	mov    -0x30(%rbp),%rsi
  414716:	48 89 fb             	mov    %rdi,%rbx
  414719:	e8 12 06 01 00       	callq  424d30 <p111_rt_keep>
  41471e:	48 89 df             	mov    %rbx,%rdi
  414721:	48 89 c3             	mov    %rax,%rbx
  414724:	48 8b 45 c8          	mov    -0x38(%rbp),%rax
  414728:	48 89 9d 90 ef ff ff 	mov    %rbx,-0x1070(%rbp)
  41472f:	48 89 85 98 ef ff ff 	mov    %rax,-0x1068(%rbp)
  414736:	4c 89 bd a0 ef ff ff 	mov    %r15,-0x1060(%rbp)
  41473d:	4c 89 ad a8 ef ff ff 	mov    %r13,-0x1058(%rbp)
  414744:	48 8d 95 90 ef ff ff 	lea    -0x1070(%rbp),%rdx
  41474b:	be 9b 00 00 00       	mov    $0x9b,%esi
  414750:	49 89 fd             	mov    %rdi,%r13
  414753:	e8 18 62 01 00       	callq  42a970 <p125_rt_ctor4>
  414758:	4c 89 ef             	mov    %r13,%rdi
  41475b:	48 89 85 90 ef ff ff 	mov    %rax,-0x1070(%rbp)
  414762:	4c 89 b5 98 ef ff ff 	mov    %r14,-0x1068(%rbp)
  414769:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
  41476e:	48 21 d8             	and    %rbx,%rax
  414771:	4c 39 e0             	cmp    %r12,%rax
  414774:	0f 94 c0             	sete   %al
  414777:	0f b6 c0             	movzbl %al,%eax
  41477a:	48 89 85 a0 ef ff ff 	mov    %rax,-0x1060(%rbp)
  414781:	b9 03 00 00 00       	mov    $0x3,%ecx
  414786:	48 8d 95 90 ef ff ff 	lea    -0x1070(%rbp),%rdx
  41478d:	be f3 00 00 00       	mov    $0xf3,%esi
  414792:	e8 e9 0b 01 00       	callq  425380 <p111_rt_jump>
  414797:	e9 b7 02 00 00       	jmpq   414a53 <p111_FID_36_100_105_114_101_99_116_46_105_110_100_101_120_95_102_105_110_100_+0x753>
  41479c:	4d 89 f4             	mov    %r14,%r12
  41479f:	4d 89 ee             	mov    %r13,%r14
  4147a2:	48 8d 95 90 ef ff ff 	lea    -0x1070(%rbp),%rdx
  4147a9:	48 89 fb             	mov    %rdi,%rbx
  4147ac:	e8 bf 5d 01 00       	callq  42a570 <p125_rt_take2>
  4147b1:	48 89 df             	mov    %rbx,%rdi
  4147b4:	48 8b 85 90 ef ff ff 	mov    -0x1070(%rbp),%rax
  4147bb:	48 8b 9d 98 ef ff ff 	mov    -0x1068(%rbp),%rbx
  4147c2:	b9 ff ff ff ff       	mov    $0xffffffff,%ecx
  4147c7:	48 21 c8             	and    %rcx,%rax
  4147ca:	4c 39 e0             	cmp    %r12,%rax
  4147cd:	49 89 dd             	mov    %rbx,%r13
  4147d0:	0f 94 c3             	sete   %bl
  4147d3:	0f b6 db             	movzbl %bl,%ebx
  4147d6:	48 83 fb 01          	cmp    $0x1,%rbx
  4147da:	0f 94 c0             	sete   %al
  4147dd:	0f b6 c0             	movzbl %al,%eax
  4147e0:	48 89 d9             	mov    %rbx,%rcx
  4147e3:	48 c1 e9 28          	shr    $0x28,%rcx
  4147e7:	48 81 e1 ff ff 7f 00 	and    $0x7fffff,%rcx
  4147ee:	48 81 f9 02 00 01 00 	cmp    $0x10002,%rcx
  4147f5:	0f 94 c1             	sete   %cl
  4147f8:	0f b6 c9             	movzbl %cl,%ecx
  4147fb:	41 89 c4             	mov    %eax,%r12d
  4147fe:	41 09 cc             	or     %ecx,%r12d
  414801:	0f 85 a3 00 00 00    	jne    4148aa <p111_FID_36_100_105_114_101_99_116_46_105_110_100_101_120_95_102_105_110_100_+0x5aa>
  414807:	4c 89 f6             	mov    %r14,%rsi
  41480a:	49 89 fe             	mov    %rdi,%r14
  41480d:	e8 ae 05 01 00       	callq  424dc0 <p111_rt_sink>
  414812:	4c 89 f7             	mov    %r14,%rdi
  414815:	4c 89 ee             	mov    %r13,%rsi
  414818:	49 89 fd             	mov    %rdi,%r13
  41481b:	e8 a0 05 01 00       	callq  424dc0 <p111_rt_sink>
  414820:	4c 89 ef             	mov    %r13,%rdi
  414823:	44 89 e0             	mov    %r12d,%eax
  414826:	83 f0 01             	xor    $0x1,%eax
  414829:	75 2d                	jne    414858 <p111_FID_36_100_105_114_101_99_116_46_105_110_100_101_120_95_102_105_110_100_+0x558>
  41482b:	48 89 9d 90 ef ff ff 	mov    %rbx,-0x1070(%rbp)
  414832:	48 8b 47 10          	mov    0x10(%rdi),%rax
  414836:	48 89 18             	mov    %rbx,(%rax)
  414839:	48 c7 40 08 12 01 00 	movq   $0x112,0x8(%rax)
  414840:	00 
  414841:	48 83 c0 10          	add    $0x10,%rax
  414845:	48 89 47 10          	mov    %rax,0x10(%rdi)
  414849:	be 04 00 00 00       	mov    $0x4,%esi
  41484e:	e8 fd 0c 01 00       	callq  425550 <p111_rt_fail>
  414853:	e9 fb 01 00 00       	jmpq   414a53 <p111_FID_36_100_105_114_101_99_116_46_105_110_100_101_120_95_102_105_110_100_+0x753>
  414858:	b9 00 00 00 00       	mov    $0x0,%ecx
  41485d:	48 8d 95 90 ef ff ff 	lea    -0x1070(%rbp),%rdx
  414864:	be 00 00 00 00       	mov    $0x0,%esi
  414869:	48 89 fb             	mov    %rdi,%rbx
  41486c:	e8 bf 05 01 00       	callq  424e30 <p111_rt_ctor>
  414871:	48 89 df             	mov    %rbx,%rdi
  414874:	48 89 c6             	mov    %rax,%rsi
  414877:	48 89 fb             	mov    %rdi,%rbx
  41487a:	e8 41 05 01 00       	callq  424dc0 <p111_rt_sink>
  41487f:	48 89 df             	mov    %rbx,%rdi
  414882:	48 89 fb             	mov    %rdi,%rbx
  414885:	e8 d6 92 ff ff       	callq  40db60 <p112w_FID_109_105_115_115_105_110_103_>
  41488a:	48 89 df             	mov    %rbx,%rdi
  41488d:	48 89 85 90 ef ff ff 	mov    %rax,-0x1070(%rbp)
  414894:	ba 01 00 00 00       	mov    $0x1,%edx
  414899:	48 8d b5 90 ef ff ff 	lea    -0x1070(%rbp),%rsi
  4148a0:	e8 3b 0b 01 00       	callq  4253e0 <p111_rt_return>
  4148a5:	e9 a9 01 00 00       	jmpq   414a53 <p111_FID_36_100_105_114_101_99_116_46_105_110_100_101_120_95_102_105_110_100_+0x753>
  4148aa:	2e 2e 4c 89 eb       	cs cs mov %r13,%rbx
  4148af:	4d 89 f5             	mov    %r14,%r13
  4148b2:	b9 00 00 00 00       	mov    $0x0,%ecx
  4148b7:	48 8d 95 90 ef ff ff 	lea    -0x1070(%rbp),%rdx
  4148be:	be 00 00 00 00       	mov    $0x0,%esi
  4148c3:	49 89 fc             	mov    %rdi,%r12
  4148c6:	e8 65 05 01 00       	callq  424e30 <p111_rt_ctor>
  4148cb:	4c 89 e7             	mov    %r12,%rdi
  4148ce:	48 89 c6             	mov    %rax,%rsi
  4148d1:	49 89 fc             	mov    %rdi,%r12
  4148d4:	e8 e7 04 01 00       	callq  424dc0 <p111_rt_sink>
  4148d9:	4c 89 e7             	mov    %r12,%rdi
  4148dc:	48 89 9d 90 ef ff ff 	mov    %rbx,-0x1070(%rbp)
  4148e3:	4c 89 ad 98 ef ff ff 	mov    %r13,-0x1068(%rbp)
  4148ea:	b9 02 00 00 00       	mov    $0x2,%ecx
  4148ef:	48 8d 95 90 ef ff ff 	lea    -0x1070(%rbp),%rdx
  4148f6:	be e9 00 00 00       	mov    $0xe9,%esi
  4148fb:	e8 80 0a 01 00       	callq  425380 <p111_rt_jump>
  414900:	e9 4e 01 00 00       	jmpq   414a53 <p111_FID_36_100_105_114_101_99_116_46_105_110_100_101_120_95_102_105_110_100_+0x753>
  414905:	b9 09 00 00 00       	mov    $0x9,%ecx
  41490a:	48 8d 95 90 ef ff ff 	lea    -0x1070(%rbp),%rdx
  414911:	49 89 fe             	mov    %rdi,%r14
  414914:	e8 97 06 01 00       	callq  424fb0 <p111_rt_take>
  414919:	4c 89 f7             	mov    %r14,%rdi
  41491c:	4c 8b b5 90 ef ff ff 	mov    -0x1070(%rbp),%r14
  414923:	48 8b b5 98 ef ff ff 	mov    -0x1068(%rbp),%rsi
  41492a:	4c 8b 9d a0 ef ff ff 	mov    -0x1060(%rbp),%r11
  414931:	4c 89 5d 90          	mov    %r11,-0x70(%rbp)
  414935:	4c 8b 95 a8 ef ff ff 	mov    -0x1058(%rbp),%r10
  41493c:	4c 89 55 98          	mov    %r10,-0x68(%rbp)
  414940:	4c 8b 8d b0 ef ff ff 	mov    -0x1050(%rbp),%r9
  414947:	4c 89 4d a0          	mov    %r9,-0x60(%rbp)
  41494b:	4c 8b 85 b8 ef ff ff 	mov    -0x1048(%rbp),%r8
  414952:	4c 89 45 a8          	mov    %r8,-0x58(%rbp)
  414956:	48 8b 95 c0 ef ff ff 	mov    -0x1040(%rbp),%rdx
  41495d:	48 89 55 b0          	mov    %rdx,-0x50(%rbp)
  414961:	48 8b 8d c8 ef ff ff 	mov    -0x1038(%rbp),%rcx
  414968:	48 89 4d b8          	mov    %rcx,-0x48(%rbp)
  41496c:	48 8b 85 d0 ef ff ff 	mov    -0x1030(%rbp),%rax
  414973:	48 89 45 c0          	mov    %rax,-0x40(%rbp)
  414977:	49 89 ff             	mov    %rdi,%r15
  41497a:	e8 b1 03 01 00       	callq  424d30 <p111_rt_keep>
  41497f:	4c 89 ff             	mov    %r15,%rdi
  414982:	48 89 c6             	mov    %rax,%rsi
  414985:	48 8b 45 c0          	mov    -0x40(%rbp),%rax
  414989:	48 8b 4d b8          	mov    -0x48(%rbp),%rcx
  41498d:	48 8b 55 b0          	mov    -0x50(%rbp),%rdx
  414991:	4c 8b 45 a8          	mov    -0x58(%rbp),%r8
  414995:	4c 8b 4d a0          	mov    -0x60(%rbp),%r9
  414999:	4c 8b 55 98          	mov    -0x68(%rbp),%r10
  41499d:	4c 8b 5d 90          	mov    -0x70(%rbp),%r11
  4149a1:	4c 89 b5 90 ef ff ff 	mov    %r14,-0x1070(%rbp)
  4149a8:	48 89 b5 98 ef ff ff 	mov    %rsi,-0x1068(%rbp)
  4149af:	4c 89 9d a0 ef ff ff 	mov    %r11,-0x1060(%rbp)
  4149b6:	4c 89 95 a8 ef ff ff 	mov    %r10,-0x1058(%rbp)
  4149bd:	4c 89 8d b0 ef ff ff 	mov    %r9,-0x1050(%rbp)
  4149c4:	4c 89 85 b8 ef ff ff 	mov    %r8,-0x1048(%rbp)
  4149cb:	48 89 95 c0 ef ff ff 	mov    %rdx,-0x1040(%rbp)
  4149d2:	48 89 8d c8 ef ff ff 	mov    %rcx,-0x1038(%rbp)
  4149d9:	48 89 85 d0 ef ff ff 	mov    %rax,-0x1030(%rbp)
  4149e0:	b9 09 00 00 00       	mov    $0x9,%ecx
  4149e5:	48 8d 95 90 ef ff ff 	lea    -0x1070(%rbp),%rdx
  4149ec:	49 89 f7             	mov    %rsi,%r15
  4149ef:	be 99 00 00 00       	mov    $0x99,%esi
  4149f4:	49 89 fe             	mov    %rdi,%r14
  4149f7:	e8 34 04 01 00       	callq  424e30 <p111_rt_ctor>
  4149fc:	4c 89 fe             	mov    %r15,%rsi
  4149ff:	4c 89 f7             	mov    %r14,%rdi
  414a02:	49 89 c6             	mov    %rax,%r14
  414a05:	48 ba 2c 82 10 03 00 	movabs $0x20019000310822c,%rdx
  414a0c:	19 00 02 
  414a0f:	49 89 ff             	mov    %rdi,%r15
  414a12:	e8 89 91 ff ff       	callq  40dba0 <p112w_FID_36_100_105_114_101_99_116_46_112_56_56_95_115_116_114_105_110_103_95_101_113_>
  414a17:	4c 89 ff             	mov    %r15,%rdi
  414a1a:	4c 89 b5 90 f7 ff ff 	mov    %r14,-0x870(%rbp)
  414a21:	4c 89 ad 98 f7 ff ff 	mov    %r13,-0x868(%rbp)
  414a28:	4c 89 a5 a0 f7 ff ff 	mov    %r12,-0x860(%rbp)
  414a2f:	48 89 9d a8 f7 ff ff 	mov    %rbx,-0x858(%rbp)
  414a36:	48 89 85 b0 f7 ff ff 	mov    %rax,-0x850(%rbp)
  414a3d:	b9 05 00 00 00       	mov    $0x5,%ecx
  414a42:	48 8d 95 90 f7 ff ff 	lea    -0x870(%rbp),%rdx
  414a49:	be 08 01 00 00       	mov    $0x108,%esi
  414a4e:	e8 2d 09 01 00       	callq  425380 <p111_rt_jump>
  414a53:	41 5f                	pop    %r15
  414a55:	41 5e                	pop    %r14
  414a57:	41 5d                	pop    %r13
  414a59:	41 5c                	pop    %r12
  414a5b:	5b                   	pop    %rbx
  414a5c:	c9                   	leaveq 
  414a5d:	c3                   	retq   

Disassembly of section .fini:
