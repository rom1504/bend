00000000004072a0 <p113d_FID_36_112_114_111_100_117_99_116_46_116_114_97_99_101_>:
  4072a0:	f3 0f 1e fa          	endbr64 
  4072a4:	55                   	push   %rbp
  4072a5:	48 89 e5             	mov    %rsp,%rbp
  4072a8:	48 81 ec 48 01 00 00 	sub    $0x148,%rsp
  4072af:	53                   	push   %rbx
  4072b0:	41 54                	push   %r12
  4072b2:	41 55                	push   %r13
  4072b4:	41 56                	push   %r14
  4072b6:	41 57                	push   %r15
  4072b8:	4c 8b 7d 40          	mov    0x40(%rbp),%r15
  4072bc:	48 8b 45 38          	mov    0x38(%rbp),%rax
  4072c0:	4c 8b 5d 30          	mov    0x30(%rbp),%r11
  4072c4:	4c 8b 55 28          	mov    0x28(%rbp),%r10
  4072c8:	48 89 c3             	mov    %rax,%rbx
  4072cb:	48 8b 45 20          	mov    0x20(%rbp),%rax
  4072cf:	4c 8b 75 18          	mov    0x18(%rbp),%r14
  4072d3:	4c 8b 6d 10          	mov    0x10(%rbp),%r13
  4072d7:	4d 89 cc             	mov    %r9,%r12
  4072da:	48 87 ca             	xchg   %rcx,%rdx
  4072dd:	4c 87 fe             	xchg   %r15,%rsi
  4072e0:	4d 87 c7             	xchg   %r8,%r15
  4072e3:	41 b9 00 00 00 41    	mov    $0x41000000,%r9d
  4072e9:	4c 89 8d 48 ff ff ff 	mov    %r9,-0xb8(%rbp)
  4072f0:	41 b9 cd cc 4c 3e    	mov    $0x3e4ccccd,%r9d
  4072f6:	4c 89 8d 50 ff ff ff 	mov    %r9,-0xb0(%rbp)
  4072fd:	41 b9 00 00 60 c0    	mov    $0xc0600000,%r9d
  407303:	4c 89 8d 58 ff ff ff 	mov    %r9,-0xa8(%rbp)
  40730a:	41 b9 00 00 80 3f    	mov    $0x3f800000,%r9d
  407310:	4c 89 8d 60 ff ff ff 	mov    %r9,-0xa0(%rbp)
  407317:	49 90                	xchg   %rax,%r8
  407319:	49 87 d0             	xchg   %rdx,%r8
  40731c:	48 87 de             	xchg   %rbx,%rsi
  40731f:	48 87 fb             	xchg   %rdi,%rbx
  407322:	66 66 2e 0f 1f 84 00 00 00 00 00 	data16 nopw %cs:0x0(%rax,%rax,1)
  40732d:	0f 1f 00             	nopl   (%rax)
  407330:	48 89 45 a8          	mov    %rax,-0x58(%rbp)
  407334:	48 83 f8 00          	cmp    $0x0,%rax
  407338:	48 89 f8             	mov    %rdi,%rax
  40733b:	40 0f 94 c7          	sete   %dil
  40733f:	40 0f b6 ff          	movzbl %dil,%edi
  407343:	66 49 0f 6e d8       	movq   %r8,%xmm3
  407348:	66 48 0f 6e ea       	movq   %rdx,%xmm5
  40734d:	f3 0f 11 6d 98       	movss  %xmm5,-0x68(%rbp)
  407352:	f3 0f 10 c3          	movss  %xmm3,%xmm0
  407356:	f3 0f 59 c5          	mulss  %xmm5,%xmm0
  40735a:	66 49 0f 6e cc       	movq   %r12,%xmm1
  40735f:	f3 0f 58 c1          	addss  %xmm1,%xmm0
  407363:	f3 0f 11 85 30 ff ff ff 	movss  %xmm0,-0xd0(%rbp)
  40736b:	66 49 0f 7e c1       	movq   %xmm0,%r9
  407370:	66 49 0f 6e ca       	movq   %r10,%xmm1
  407375:	f3 0f 11 4d 9c       	movss  %xmm1,-0x64(%rbp)
  40737a:	f3 0f 59 cb          	mulss  %xmm3,%xmm1
  40737e:	66 49 0f 6e d5       	movq   %r13,%xmm2
  407383:	f3 0f 58 ca          	addss  %xmm2,%xmm1
  407387:	f3 0f 11 8d 34 ff ff ff 	movss  %xmm1,-0xcc(%rbp)
  40738f:	66 49 0f 7e c8       	movq   %xmm1,%r8
  407394:	66 49 0f 6e d3       	movq   %r11,%xmm2
  407399:	f3 0f 11 55 a0       	movss  %xmm2,-0x60(%rbp)
  40739e:	f3 0f 59 d3          	mulss  %xmm3,%xmm2
  4073a2:	66 49 0f 6e de       	movq   %r14,%xmm3
  4073a7:	f3 0f 58 d3          	addss  %xmm3,%xmm2
  4073ab:	f3 0f 11 55 a4       	movss  %xmm2,-0x5c(%rbp)
  4073b0:	66 48 0f 7e d2       	movq   %xmm2,%rdx
  4073b5:	0f 57 05 54 9c 02 00 	xorps  0x29c54(%rip),%xmm0        # 431010 <_IO_stdin_used+0x10>
  4073bc:	f3 0f 58 05 6c 9c 02 00 	addss  0x29c6c(%rip),%xmm0        # 431030 <_IO_stdin_used+0x30>
  4073c4:	f3 0f 11 85 38 ff ff ff 	movss  %xmm0,-0xc8(%rbp)
  4073cc:	0f 57 0d 3d 9c 02 00 	xorps  0x29c3d(%rip),%xmm1        # 431010 <_IO_stdin_used+0x10>
  4073d3:	f3 0f 58 0d 51 9c 02 00 	addss  0x29c51(%rip),%xmm1        # 43102c <_IO_stdin_used+0x2c>
  4073db:	f3 0f 11 8d 3c ff ff ff 	movss  %xmm1,-0xc4(%rbp)
  4073e3:	0f 57 15 26 9c 02 00 	xorps  0x29c26(%rip),%xmm2        # 431010 <_IO_stdin_used+0x10>
  4073ea:	f3 0f 58 15 2e 9c 02 00 	addss  0x29c2e(%rip),%xmm2        # 431020 <_IO_stdin_used+0x20>
  4073f2:	f3 0f 11 95 40 ff ff ff 	movss  %xmm2,-0xc0(%rbp)
  4073fa:	f3 0f 59 c0          	mulss  %xmm0,%xmm0
  4073fe:	f3 0f 59 c9          	mulss  %xmm1,%xmm1
  407402:	f3 0f 58 c1          	addss  %xmm1,%xmm0
  407406:	f3 0f 10 ca          	movss  %xmm2,%xmm1
  40740a:	f3 0f 59 ca          	mulss  %xmm2,%xmm1
  40740e:	f3 0f 58 c1          	addss  %xmm1,%xmm0
  407412:	f3 0f 5a c0          	cvtss2sd %xmm0,%xmm0
  407416:	f2 0f 11 45 f0       	movsd  %xmm0,-0x10(%rbp)
  40741b:	45 89 c9             	mov    %r9d,%r9d
  40741e:	66 49 0f 6e c9       	movq   %r9,%xmm1
  407423:	f3 0f 11 8d 28 ff ff ff 	movss  %xmm1,-0xd8(%rbp)
  40742b:	45 89 c0             	mov    %r8d,%r8d
  40742e:	66 49 0f 6e c8       	movq   %r8,%xmm1
  407433:	f3 0f 11 8d 20 ff ff ff 	movss  %xmm1,-0xe0(%rbp)
  40743b:	89 d2                	mov    %edx,%edx
  40743d:	66 48 0f 6e ca       	movq   %rdx,%xmm1
  407442:	f3 0f 11 8d 0c ff ff ff 	movss  %xmm1,-0xf4(%rbp)
  40744a:	66 48 0f 6e c0       	movq   %rax,%xmm0
  40744f:	f3 0f 11 85 00 ff ff ff 	movss  %xmm0,-0x100(%rbp)
  407457:	66 48 0f 6e de       	movq   %rsi,%xmm3
  40745c:	f3 0f 11 9d 04 ff ff ff 	movss  %xmm3,-0xfc(%rbp)
  407464:	48 83 f9 01          	cmp    $0x1,%rcx
  407468:	48 89 c8             	mov    %rcx,%rax
  40746b:	0f 94 c1             	sete   %cl
  40746e:	0f b6 c9             	movzbl %cl,%ecx
  407471:	48 c1 e8 28          	shr    $0x28,%rax
  407475:	48 25 ff ff 7f 00    	and    $0x7fffff,%rax
  40747b:	48 3d 02 00 01 00    	cmp    $0x10002,%rax
  407481:	0f 94 c2             	sete   %dl
  407484:	0f b6 d2             	movzbl %dl,%edx
  407487:	89 c8                	mov    %ecx,%eax
  407489:	09 d0                	or     %edx,%eax
  40748b:	83 ff 00             	cmp    $0x0,%edi
  40748e:	0f 85 5e 04 00 00    	jne    4078f2 <p113d_FID_36_112_114_111_100_117_99_116_46_116_114_97_99_101_+0x652>
  407494:	09 d1                	or     %edx,%ecx
  407496:	0f 85 4e 04 00 00    	jne    4078ea <p113d_FID_36_112_114_111_100_117_99_116_46_116_114_97_99_101_+0x64a>
  40749c:	2e 83 f0 01          	cs xor $0x1,%eax
  4074a0:	0f 84 2d 04 00 00    	je     4078d3 <p113d_FID_36_112_114_111_100_117_99_116_46_116_114_97_99_101_+0x633>
  4074a6:	4c 89 fe             	mov    %r15,%rsi
  4074a9:	48 89 df             	mov    %rbx,%rdi
  4074ac:	e8 5f ee ff ff       	callq  406310 <p113d_FID_36_100_105_114_101_99_116_46_115_114_>
  4074b1:	49 89 c4             	mov    %rax,%r12
  4074b4:	4c 89 fe             	mov    %r15,%rsi
  4074b7:	48 89 df             	mov    %rbx,%rdi
  4074ba:	e8 c1 f0 ff ff       	callq  406580 <p113d_FID_36_100_105_114_101_99_116_46_115_120_>
  4074bf:	f3 0f 10 85 30 ff ff ff 	movss  -0xd0(%rbp),%xmm0
  4074c7:	66 48 0f 6e c8       	movq   %rax,%xmm1
  4074cc:	f3 0f 5c c1          	subss  %xmm1,%xmm0
  4074d0:	66 49 0f 6e d4       	movq   %r12,%xmm2
  4074d5:	f3 0f 11 55 e8       	movss  %xmm2,-0x18(%rbp)
  4074da:	f3 0f 5e c2          	divss  %xmm2,%xmm0
  4074de:	66 48 0f 7e c0       	movq   %xmm0,%rax
  4074e3:	41 89 c4             	mov    %eax,%r12d
  4074e6:	4c 89 fe             	mov    %r15,%rsi
  4074e9:	48 89 df             	mov    %rbx,%rdi
  4074ec:	e8 bf ef ff ff       	callq  4064b0 <p113d_FID_36_100_105_114_101_99_116_46_115_121_>
  4074f1:	48 89 c1             	mov    %rax,%rcx
  4074f4:	4c 89 e0             	mov    %r12,%rax
  4074f7:	f3 0f 10 55 e8       	movss  -0x18(%rbp),%xmm2
  4074fc:	f3 0f 10 85 34 ff ff ff 	movss  -0xcc(%rbp),%xmm0
  407504:	66 48 0f 6e c9       	movq   %rcx,%xmm1
  407509:	f3 0f 5c c1          	subss  %xmm1,%xmm0
  40750d:	f3 0f 5e c2          	divss  %xmm2,%xmm0
  407511:	49 89 c4             	mov    %rax,%r12
  407514:	66 48 0f 7e c0       	movq   %xmm0,%rax
  407519:	41 89 c5             	mov    %eax,%r13d
  40751c:	4c 89 fe             	mov    %r15,%rsi
  40751f:	48 89 df             	mov    %rbx,%rdi
  407522:	e8 b9 ee ff ff       	callq  4063e0 <p113d_FID_36_100_105_114_101_99_116_46_115_122_>
  407527:	48 89 c1             	mov    %rax,%rcx
  40752a:	4c 89 e0             	mov    %r12,%rax
  40752d:	f2 0f 10 45 f0       	movsd  -0x10(%rbp),%xmm0
  407532:	f3 0f 10 55 e8       	movss  -0x18(%rbp),%xmm2
  407537:	f3 0f 10 4d a4       	movss  -0x5c(%rbp),%xmm1
  40753c:	66 48 0f 6e d9       	movq   %rcx,%xmm3
  407541:	f3 0f 5c cb          	subss  %xmm3,%xmm1
  407545:	f3 0f 5e ca          	divss  %xmm2,%xmm1
  407549:	49 89 c6             	mov    %rax,%r14
  40754c:	66 48 0f 7e c8       	movq   %xmm1,%rax
  407551:	41 89 c4             	mov    %eax,%r12d
  407554:	e8 67 af ff ff       	callq  4024c0 <sqrt@plt>
  407559:	4c 89 f0             	mov    %r14,%rax
  40755c:	f2 0f 10 d8          	movsd  %xmm0,%xmm3
  407560:	f3 0f 10 95 40 ff ff ff 	movss  -0xc0(%rbp),%xmm2
  407568:	f3 0f 10 8d 3c ff ff ff 	movss  -0xc4(%rbp),%xmm1
  407570:	f3 0f 10 85 38 ff ff ff 	movss  -0xc8(%rbp),%xmm0
  407578:	f2 0f 5a db          	cvtsd2ss %xmm3,%xmm3
  40757c:	66 48 0f 7e d9       	movq   %xmm3,%rcx
  407581:	89 ca                	mov    %ecx,%edx
  407583:	48 89 55 d0          	mov    %rdx,-0x30(%rbp)
  407587:	f3 0f 5e c3          	divss  %xmm3,%xmm0
  40758b:	66 48 0f 7e c1       	movq   %xmm0,%rcx
  407590:	41 89 ce             	mov    %ecx,%r14d
  407593:	f3 0f 5e cb          	divss  %xmm3,%xmm1
  407597:	66 48 0f 7e c9       	movq   %xmm1,%rcx
  40759c:	89 c9                	mov    %ecx,%ecx
  40759e:	48 89 4d d8          	mov    %rcx,-0x28(%rbp)
  4075a2:	f3 0f 5e d3          	divss  %xmm3,%xmm2
  4075a6:	66 48 0f 7e d1       	movq   %xmm2,%rcx
  4075ab:	89 ca                	mov    %ecx,%edx
  4075ad:	48 89 55 e0          	mov    %rdx,-0x20(%rbp)
  4075b1:	66 48 0f 6e f0       	movq   %rax,%xmm6
  4075b6:	f3 0f 11 75 8c       	movss  %xmm6,-0x74(%rbp)
  4075bb:	f3 0f 59 c6          	mulss  %xmm6,%xmm0
  4075bf:	66 49 0f 6e e5       	movq   %r13,%xmm4
  4075c4:	f3 0f 11 65 90       	movss  %xmm4,-0x70(%rbp)
  4075c9:	f3 0f 59 cc          	mulss  %xmm4,%xmm1
  4075cd:	f3 0f 58 c1          	addss  %xmm1,%xmm0
  4075d1:	66 49 0f 6e cc       	movq   %r12,%xmm1
  4075d6:	f3 0f 11 4d 94       	movss  %xmm1,-0x6c(%rbp)
  4075db:	f3 0f 59 ca          	mulss  %xmm2,%xmm1
  4075df:	f3 0f 58 c1          	addss  %xmm1,%xmm0
  4075e3:	66 48 0f 7e c0       	movq   %xmm0,%rax
  4075e8:	89 c6                	mov    %eax,%esi
  4075ea:	48 89 df             	mov    %rbx,%rdi
  4075ed:	e8 ce e6 ff ff       	callq  405cc0 <p113d_FID_36_100_105_114_101_99_116_46_102_109_97_120_48_>
  4075f2:	48 89 45 c0          	mov    %rax,-0x40(%rbp)
  4075f6:	ba e8 03 00 00       	mov    $0x3e8,%edx
  4075fb:	be 01 00 00 00       	mov    $0x1,%esi
  407600:	48 89 df             	mov    %rbx,%rdi
  407603:	e8 28 e7 ff ff       	callq  405d30 <p113d_FID_36_100_105_114_101_99_116_46_102_108_>
  407608:	f3 0f 10 8d 28 ff ff ff 	movss  -0xd8(%rbp),%xmm1
  407610:	f3 0f 10 75 8c       	movss  -0x74(%rbp),%xmm6
  407615:	66 48 0f 6e c0       	movq   %rax,%xmm0
  40761a:	f3 0f 59 c6          	mulss  %xmm6,%xmm0
  40761e:	f3 0f 58 c1          	addss  %xmm1,%xmm0
  407622:	66 48 0f 7e c0       	movq   %xmm0,%rax
  407627:	41 89 c4             	mov    %eax,%r12d
  40762a:	ba e8 03 00 00       	mov    $0x3e8,%edx
  40762f:	be 01 00 00 00       	mov    $0x1,%esi
  407634:	48 89 df             	mov    %rbx,%rdi
  407637:	e8 f4 e6 ff ff       	callq  405d30 <p113d_FID_36_100_105_114_101_99_116_46_102_108_>
  40763c:	f3 0f 10 8d 20 ff ff ff 	movss  -0xe0(%rbp),%xmm1
  407644:	f3 0f 10 65 90       	movss  -0x70(%rbp),%xmm4
  407649:	66 48 0f 6e c0       	movq   %rax,%xmm0
  40764e:	f3 0f 59 c4          	mulss  %xmm4,%xmm0
  407652:	f3 0f 58 c1          	addss  %xmm1,%xmm0
  407656:	66 48 0f 7e c0       	movq   %xmm0,%rax
  40765b:	41 89 c5             	mov    %eax,%r13d
  40765e:	ba e8 03 00 00       	mov    $0x3e8,%edx
  407663:	be 01 00 00 00       	mov    $0x1,%esi
  407668:	48 89 df             	mov    %rbx,%rdi
  40766b:	e8 c0 e6 ff ff       	callq  405d30 <p113d_FID_36_100_105_114_101_99_116_46_102_108_>
  407670:	4d 89 f1             	mov    %r14,%r9
  407673:	48 89 c1             	mov    %rax,%rcx
  407676:	48 8b 55 e0          	mov    -0x20(%rbp),%rdx
  40767a:	48 8b 45 d8          	mov    -0x28(%rbp),%rax
  40767e:	f3 0f 10 8d 0c ff ff ff 	movss  -0xf4(%rbp),%xmm1
  407686:	f3 0f 10 45 94       	movss  -0x6c(%rbp),%xmm0
  40768b:	66 48 0f 6e d1       	movq   %rcx,%xmm2
  407690:	f3 0f 59 c2          	mulss  %xmm2,%xmm0
  407694:	f3 0f 58 c1          	addss  %xmm1,%xmm0
  407698:	66 48 0f 7e c1       	movq   %xmm0,%rcx
  40769d:	41 89 ce             	mov    %ecx,%r14d
  4076a0:	48 83 ec 30          	sub    $0x30,%rsp
  4076a4:	48 89 e1             	mov    %rsp,%rcx
  4076a7:	48 c7 41 20 00 00 00 00 	movq   $0x0,0x20(%rcx)
  4076af:	48 c7 41 18 28 6b 6e 4e 	movq   $0x4e6e6b28,0x18(%rcx)
  4076b7:	48 c7 41 10 28 6b 6e 4e 	movq   $0x4e6e6b28,0x10(%rcx)
  4076bf:	48 89 51 08          	mov    %rdx,0x8(%rcx)
  4076c3:	48 89 01             	mov    %rax,(%rcx)
  4076c6:	4d 89 f0             	mov    %r14,%r8
  4076c9:	4c 89 e9             	mov    %r13,%rcx
  4076cc:	4c 89 e2             	mov    %r12,%rdx
  4076cf:	be 09 00 00 00       	mov    $0x9,%esi
  4076d4:	48 89 df             	mov    %rbx,%rdi
  4076d7:	e8 f4 f5 ff ff       	callq  406cd0 <p113d_FID_36_100_105_114_101_99_116_46_110_101_97_114_101_115_116_46_116_>
  4076dc:	48 89 45 c8          	mov    %rax,-0x38(%rbp)
  4076e0:	48 83 ec d0          	sub    $0xffffffffffffffd0,%rsp
  4076e4:	ba 0a 00 00 00       	mov    $0xa,%edx
  4076e9:	be 01 00 00 00       	mov    $0x1,%esi
  4076ee:	48 89 df             	mov    %rbx,%rdi
  4076f1:	e8 3a e6 ff ff       	callq  405d30 <p113d_FID_36_100_105_114_101_99_116_46_102_108_>
  4076f6:	48 89 45 b0          	mov    %rax,-0x50(%rbp)
  4076fa:	ba 64 00 00 00       	mov    $0x64,%edx
  4076ff:	be 55 00 00 00       	mov    $0x55,%esi
  407704:	48 89 df             	mov    %rbx,%rdi
  407707:	e8 24 e6 ff ff       	callq  405d30 <p113d_FID_36_100_105_114_101_99_116_46_102_108_>
  40770c:	48 89 45 b8          	mov    %rax,-0x48(%rbp)
  407710:	48 8b 55 d0          	mov    -0x30(%rbp),%rdx
  407714:	48 8b 75 c8          	mov    -0x38(%rbp),%rsi
  407718:	48 8b 4d c0          	mov    -0x40(%rbp),%rcx
  40771c:	48 89 df             	mov    %rbx,%rdi
  40771f:	e8 7c eb ff ff       	callq  4062a0 <p113d_FID_36_100_105_114_101_99_116_46_115_104_97_100_101_>
  407724:	48 89 c2             	mov    %rax,%rdx
  407727:	4c 89 f8             	mov    %r15,%rax
  40772a:	4c 8b 7d a8          	mov    -0x58(%rbp),%r15
  40772e:	48 8b 75 b8          	mov    -0x48(%rbp),%rsi
  407732:	48 8b 4d b0          	mov    -0x50(%rbp),%rcx
  407736:	66 48 0f 6e c6       	movq   %rsi,%xmm0
  40773b:	66 48 0f 6e ca       	movq   %rdx,%xmm1
  407740:	f3 0f 59 c1          	mulss  %xmm1,%xmm0
  407744:	66 48 0f 6e c9       	movq   %rcx,%xmm1
  407749:	f3 0f 58 c8          	addss  %xmm0,%xmm1
  40774d:	f3 0f 11 4d 88       	movss  %xmm1,-0x78(%rbp)
  407752:	48 89 c6             	mov    %rax,%rsi
  407755:	48 89 df             	mov    %rbx,%rdi
  407758:	e8 73 ea ff ff       	callq  4061d0 <p113d_FID_36_100_105_114_101_99_116_46_115_107_114_>
  40775d:	4d 89 f8             	mov    %r15,%r8
  407760:	48 89 45 80          	mov    %rax,-0x80(%rbp)
  407764:	f3 0f 10 4d 94       	movss  -0x6c(%rbp),%xmm1
  407769:	f3 0f 10 65 90       	movss  -0x70(%rbp),%xmm4
  40776e:	f3 0f 10 75 8c       	movss  -0x74(%rbp),%xmm6
  407773:	f3 0f 10 45 a0       	movss  -0x60(%rbp),%xmm0
  407778:	f3 0f 10 5d 9c       	movss  -0x64(%rbp),%xmm3
  40777d:	f3 0f 10 6d 98       	movss  -0x68(%rbp),%xmm5
  407782:	f3 0f 10 d5          	movss  %xmm5,%xmm2
  407786:	f3 0f 59 d6          	mulss  %xmm6,%xmm2
  40778a:	f3 0f 10 fb          	movss  %xmm3,%xmm7
  40778e:	f3 0f 59 fc          	mulss  %xmm4,%xmm7
  407792:	f3 0f 58 d7          	addss  %xmm7,%xmm2
  407796:	f3 0f 10 f8          	movss  %xmm0,%xmm7
  40779a:	f3 0f 59 f9          	mulss  %xmm1,%xmm7
  40779e:	f3 0f 58 d7          	addss  %xmm7,%xmm2
  4077a2:	f3 0f 59 15 8a 98 02 00 	mulss  0x2988a(%rip),%xmm2        # 431034 <_IO_stdin_used+0x34>
  4077aa:	f3 0f 59 f2          	mulss  %xmm2,%xmm6
  4077ae:	f3 0f 5c ee          	subss  %xmm6,%xmm5
  4077b2:	66 48 0f 7e e8       	movq   %xmm5,%rax
  4077b7:	89 c0                	mov    %eax,%eax
  4077b9:	48 89 85 68 ff ff ff 	mov    %rax,-0x98(%rbp)
  4077c0:	f3 0f 59 e2          	mulss  %xmm2,%xmm4
  4077c4:	f3 0f 5c dc          	subss  %xmm4,%xmm3
  4077c8:	66 48 0f 7e d9       	movq   %xmm3,%rcx
  4077cd:	41 89 ca             	mov    %ecx,%r10d
  4077d0:	4c 89 95 70 ff ff ff 	mov    %r10,-0x90(%rbp)
  4077d7:	f3 0f 59 ca          	mulss  %xmm2,%xmm1
  4077db:	f3 0f 5c c1          	subss  %xmm1,%xmm0
  4077df:	66 48 0f 7e c1       	movq   %xmm0,%rcx
  4077e4:	41 89 cb             	mov    %ecx,%r11d
  4077e7:	4c 89 9d 78 ff ff ff 	mov    %r11,-0x88(%rbp)
  4077ee:	48 83 ec 40          	sub    $0x40,%rsp
  4077f2:	48 89 e1             	mov    %rsp,%rcx
  4077f5:	48 c7 41 38 00 00 00 00 	movq   $0x0,0x38(%rcx)
  4077fd:	48 c7 41 30 09 00 00 00 	movq   $0x9,0x30(%rcx)
  407805:	48 c7 41 28 28 6b 6e 4e 	movq   $0x4e6e6b28,0x28(%rcx)
  40780d:	48 c7 41 20 09 00 00 00 	movq   $0x9,0x20(%rcx)
  407815:	48 c7 41 18 28 6b 6e 4e 	movq   $0x4e6e6b28,0x18(%rcx)
  40781d:	4c 89 59 10          	mov    %r11,0x10(%rcx)
  407821:	4c 89 51 08          	mov    %r10,0x8(%rcx)
  407825:	48 89 01             	mov    %rax,(%rcx)
  407828:	4d 89 f1             	mov    %r14,%r9
  40782b:	4d 89 c7             	mov    %r8,%r15
  40782e:	4d 89 e8             	mov    %r13,%r8
  407831:	4c 89 e1             	mov    %r12,%rcx
  407834:	ba 09 00 00 00       	mov    $0x9,%edx
  407839:	48 8d b5 c0 fe ff ff 	lea    -0x140(%rbp),%rsi
  407840:	48 89 df             	mov    %rbx,%rdi
  407843:	e8 08 ee ff ff       	callq  406650 <p113d_FID_36_112_114_111_100_117_99_116_46_110_101_97_114_101_115_116_>
  407848:	4d 89 f8             	mov    %r15,%r8
  40784b:	4c 8b 9d 78 ff ff ff 	mov    -0x88(%rbp),%r11
  407852:	4c 8b 95 70 ff ff ff 	mov    -0x90(%rbp),%r10
  407859:	48 8b 85 68 ff ff ff 	mov    -0x98(%rbp),%rax
  407860:	f3 0f 10 9d 04 ff ff ff 	movss  -0xfc(%rbp),%xmm3
  407868:	f3 0f 10 85 00 ff ff ff 	movss  -0x100(%rbp),%xmm0
  407870:	48 8b 75 80          	mov    -0x80(%rbp),%rsi
  407874:	f3 0f 10 4d 88       	movss  -0x78(%rbp),%xmm1
  407879:	48 83 ec c0          	sub    $0xffffffffffffffc0,%rsp
  40787d:	48 8b 8d c0 fe ff ff 	mov    -0x140(%rbp),%rcx
  407884:	48 8b 95 c8 fe ff ff 	mov    -0x138(%rbp),%rdx
  40788b:	4c 8b bd d0 fe ff ff 	mov    -0x130(%rbp),%r15
  407892:	f3 0f 10 d1          	movss  %xmm1,%xmm2
  407896:	f3 0f 59 d0          	mulss  %xmm0,%xmm2
  40789a:	66 48 0f 6e ce       	movq   %rsi,%xmm1
  40789f:	f3 0f 10 25 79 97 02 00 	movss  0x29779(%rip),%xmm4        # 431020 <_IO_stdin_used+0x20>
  4078a7:	f3 0f 5c e1          	subss  %xmm1,%xmm4
  4078ab:	f3 0f 59 d4          	mulss  %xmm4,%xmm2
  4078af:	f3 0f 58 d3          	addss  %xmm3,%xmm2
  4078b3:	66 48 0f 7e d6       	movq   %xmm2,%rsi
  4078b8:	89 f6                	mov    %esi,%esi
  4078ba:	f3 0f 59 c1          	mulss  %xmm1,%xmm0
  4078be:	66 48 0f 7e c7       	movq   %xmm0,%rdi
  4078c3:	89 ff                	mov    %edi,%edi
  4078c5:	49 83 e8 01          	sub    $0x1,%r8
  4078c9:	49 90                	xchg   %rax,%r8
  4078cb:	49 87 d0             	xchg   %rdx,%r8
  4078ce:	e9 5d fa ff ff       	jmpq   407330 <p113d_FID_36_112_114_111_100_117_99_116_46_116_114_97_99_101_+0x90>
  4078d3:	48 89 df             	mov    %rbx,%rdi
  4078d6:	be 04 00 00 00       	mov    $0x4,%esi
  4078db:	e8 c0 36 02 00       	callq  42afa0 <p111_rt_fail>
  4078e0:	b8 00 00 00 00       	mov    $0x0,%eax
  4078e5:	e9 5c 05 00 00       	jmpq   407e46 <p113d_FID_36_112_114_111_100_117_99_116_46_116_114_97_99_101_+0xba6>
  4078ea:	48 89 f0             	mov    %rsi,%rax
  4078ed:	e9 54 05 00 00       	jmpq   407e46 <p113d_FID_36_112_114_111_100_117_99_116_46_116_114_97_99_101_+0xba6>
  4078f2:	4c 8b ad 58 ff ff ff 	mov    -0xa8(%rbp),%r13
  4078f9:	4c 8b a5 50 ff ff ff 	mov    -0xb0(%rbp),%r12
  407900:	41 89 c8             	mov    %ecx,%r8d
  407903:	89 c1                	mov    %eax,%ecx
  407905:	48 89 f0             	mov    %rsi,%rax
  407908:	89 d6                	mov    %edx,%esi
  40790a:	48 8b 95 48 ff ff ff 	mov    -0xb8(%rbp),%rdx
  407911:	f2 0f 10 45 f0       	movsd  -0x10(%rbp),%xmm0
  407916:	f3 0f 10 55 a4       	movss  -0x5c(%rbp),%xmm2
  40791b:	48 89 df             	mov    %rbx,%rdi
  40791e:	48 8b 9d 60 ff ff ff 	mov    -0xa0(%rbp),%rbx
  407925:	44 09 c6             	or     %r8d,%esi
  407928:	0f 85 18 05 00 00    	jne    407e46 <p113d_FID_36_112_114_111_100_117_99_116_46_116_114_97_99_101_+0xba6>
  40792e:	89 c8                	mov    %ecx,%eax
  407930:	83 f0 01             	xor    $0x1,%eax
  407933:	75 14                	jne    407949 <p113d_FID_36_112_114_111_100_117_99_116_46_116_114_97_99_101_+0x6a9>
  407935:	be 04 00 00 00       	mov    $0x4,%esi
  40793a:	e8 61 36 02 00       	callq  42afa0 <p111_rt_fail>
  40793f:	b8 00 00 00 00       	mov    $0x0,%eax
  407944:	e9 fd 04 00 00       	jmpq   407e46 <p113d_FID_36_112_114_111_100_117_99_116_46_116_114_97_99_101_+0xba6>
  407949:	49 83 ff 00          	cmp    $0x0,%r15
  40794d:	0f 94 c0             	sete   %al
  407950:	0f b6 c0             	movzbl %al,%eax
  407953:	4d 89 fb             	mov    %r15,%r11
  407956:	49 83 eb 01          	sub    $0x1,%r11
  40795a:	4d 89 fa             	mov    %r15,%r10
  40795d:	49 83 ea 02          	sub    $0x2,%r10
  407961:	4d 89 f9             	mov    %r15,%r9
  407964:	49 83 e9 03          	sub    $0x3,%r9
  407968:	4d 89 f8             	mov    %r15,%r8
  40796b:	49 83 e8 04          	sub    $0x4,%r8
  40796f:	49 89 fe             	mov    %rdi,%r14
  407972:	4c 89 ff             	mov    %r15,%rdi
  407975:	48 83 ef 05          	sub    $0x5,%rdi
  407979:	4c 89 fe             	mov    %r15,%rsi
  40797c:	48 83 ee 06          	sub    $0x6,%rsi
  407980:	4c 89 f9             	mov    %r15,%rcx
  407983:	48 83 e9 07          	sub    $0x7,%rcx
  407987:	83 f8 00             	cmp    $0x0,%eax
  40798a:	75 60                	jne    4079ec <p113d_FID_36_112_114_111_100_117_99_116_46_116_114_97_99_101_+0x74c>
  40798c:	49 83 fb 00          	cmp    $0x0,%r11
  407990:	74 53                	je     4079e5 <p113d_FID_36_112_114_111_100_117_99_116_46_116_114_97_99_101_+0x745>
  407992:	49 83 fa 00          	cmp    $0x0,%r10
  407996:	74 46                	je     4079de <p113d_FID_36_112_114_111_100_117_99_116_46_116_114_97_99_101_+0x73e>
  407998:	49 83 f9 00          	cmp    $0x0,%r9
  40799c:	74 39                	je     4079d7 <p113d_FID_36_112_114_111_100_117_99_116_46_116_114_97_99_101_+0x737>
  40799e:	66 90                	xchg   %ax,%ax
  4079a0:	49 83 f8 00          	cmp    $0x0,%r8
  4079a4:	74 2a                	je     4079d0 <p113d_FID_36_112_114_111_100_117_99_116_46_116_114_97_99_101_+0x730>
  4079a6:	48 83 ff 00          	cmp    $0x0,%rdi
  4079aa:	74 1d                	je     4079c9 <p113d_FID_36_112_114_111_100_117_99_116_46_116_114_97_99_101_+0x729>
  4079ac:	48 83 fe 00          	cmp    $0x0,%rsi
  4079b0:	74 10                	je     4079c2 <p113d_FID_36_112_114_111_100_117_99_116_46_116_114_97_99_101_+0x722>
  4079b2:	2e 48 83 f9 00       	cs cmp $0x0,%rcx
  4079b7:	b8 00 00 80 3f       	mov    $0x3f800000,%eax
  4079bc:	48 0f 45 c3          	cmovne %rbx,%rax
  4079c0:	eb 2f                	jmp    4079f1 <p113d_FID_36_112_114_111_100_117_99_116_46_116_114_97_99_101_+0x751>
  4079c2:	b8 9a 99 99 3f       	mov    $0x3f99999a,%eax
  4079c7:	eb 28                	jmp    4079f1 <p113d_FID_36_112_114_111_100_117_99_116_46_116_114_97_99_101_+0x751>
  4079c9:	b8 cd cc cc 3e       	mov    $0x3ecccccd,%eax
  4079ce:	eb 21                	jmp    4079f1 <p113d_FID_36_112_114_111_100_117_99_116_46_116_114_97_99_101_+0x751>
  4079d0:	b8 cd cc cc 3e       	mov    $0x3ecccccd,%eax
  4079d5:	eb 1a                	jmp    4079f1 <p113d_FID_36_112_114_111_100_117_99_116_46_116_114_97_99_101_+0x751>
  4079d7:	b8 00 00 80 3f       	mov    $0x3f800000,%eax
  4079dc:	eb 13                	jmp    4079f1 <p113d_FID_36_112_114_111_100_117_99_116_46_116_114_97_99_101_+0x751>
  4079de:	b8 00 00 80 3f       	mov    $0x3f800000,%eax
  4079e3:	eb 0c                	jmp    4079f1 <p113d_FID_36_112_114_111_100_117_99_116_46_116_114_97_99_101_+0x751>
  4079e5:	b8 00 00 80 3f       	mov    $0x3f800000,%eax
  4079ea:	eb 05                	jmp    4079f1 <p113d_FID_36_112_114_111_100_117_99_116_46_116_114_97_99_101_+0x751>
  4079ec:	b8 00 40 1c 46       	mov    $0x461c4000,%eax
  4079f1:	49 83 ff 00          	cmp    $0x0,%r15
  4079f5:	74 63                	je     407a5a <p113d_FID_36_112_114_111_100_117_99_116_46_116_114_97_99_101_+0x7ba>
  4079f7:	49 83 fb 00          	cmp    $0x0,%r11
  4079fb:	74 53                	je     407a50 <p113d_FID_36_112_114_111_100_117_99_116_46_116_114_97_99_101_+0x7b0>
  4079fd:	0f 1f 00             	nopl   (%rax)
  407a00:	49 83 fa 00          	cmp    $0x0,%r10
  407a04:	74 43                	je     407a49 <p113d_FID_36_112_114_111_100_117_99_116_46_116_114_97_99_101_+0x7a9>
  407a06:	49 83 f9 00          	cmp    $0x0,%r9
  407a0a:	74 36                	je     407a42 <p113d_FID_36_112_114_111_100_117_99_116_46_116_114_97_99_101_+0x7a2>
  407a0c:	49 83 f8 00          	cmp    $0x0,%r8
  407a10:	74 29                	je     407a3b <p113d_FID_36_112_114_111_100_117_99_116_46_116_114_97_99_101_+0x79b>
  407a12:	48 83 ff 00          	cmp    $0x0,%rdi
  407a16:	74 1c                	je     407a34 <p113d_FID_36_112_114_111_100_117_99_116_46_116_114_97_99_101_+0x794>
  407a18:	48 83 fe 00          	cmp    $0x0,%rsi
  407a1c:	74 0f                	je     407a2d <p113d_FID_36_112_114_111_100_117_99_116_46_116_114_97_99_101_+0x78d>
  407a1e:	48 83 f9 00          	cmp    $0x0,%rcx
  407a22:	bb 00 00 60 40       	mov    $0x40600000,%ebx
  407a27:	49 0f 45 dd          	cmovne %r13,%rbx
  407a2b:	eb 28                	jmp    407a55 <p113d_FID_36_112_114_111_100_117_99_116_46_116_114_97_99_101_+0x7b5>
  407a2d:	bb 00 00 00 00       	mov    $0x0,%ebx
  407a32:	eb 21                	jmp    407a55 <p113d_FID_36_112_114_111_100_117_99_116_46_116_114_97_99_101_+0x7b5>
  407a34:	bb 00 00 80 bf       	mov    $0xbf800000,%ebx
  407a39:	eb 1a                	jmp    407a55 <p113d_FID_36_112_114_111_100_117_99_116_46_116_114_97_99_101_+0x7b5>
  407a3b:	bb 00 00 80 3f       	mov    $0x3f800000,%ebx
  407a40:	eb 13                	jmp    407a55 <p113d_FID_36_112_114_111_100_117_99_116_46_116_114_97_99_101_+0x7b5>
  407a42:	bb 00 00 00 c0       	mov    $0xc0000000,%ebx
  407a47:	eb 0c                	jmp    407a55 <p113d_FID_36_112_114_111_100_117_99_116_46_116_114_97_99_101_+0x7b5>
  407a49:	bb 00 00 00 40       	mov    $0x40000000,%ebx
  407a4e:	eb 05                	jmp    407a55 <p113d_FID_36_112_114_111_100_117_99_116_46_116_114_97_99_101_+0x7b5>
  407a50:	bb 00 00 00 00       	mov    $0x0,%ebx
  407a55:	49 89 dd             	mov    %rbx,%r13
  407a58:	eb 06                	jmp    407a60 <p113d_FID_36_112_114_111_100_117_99_116_46_116_114_97_99_101_+0x7c0>
  407a5a:	41 bd 00 00 00 00    	mov    $0x0,%r13d
  407a60:	49 83 ff 00          	cmp    $0x0,%r15
  407a64:	74 62                	je     407ac8 <p113d_FID_36_112_114_111_100_117_99_116_46_116_114_97_99_101_+0x828>
  407a66:	49 83 fb 00          	cmp    $0x0,%r11
  407a6a:	74 52                	je     407abe <p113d_FID_36_112_114_111_100_117_99_116_46_116_114_97_99_101_+0x81e>
  407a6c:	49 83 fa 00          	cmp    $0x0,%r10
  407a70:	74 45                	je     407ab7 <p113d_FID_36_112_114_111_100_117_99_116_46_116_114_97_99_101_+0x817>
  407a72:	49 83 f9 00          	cmp    $0x0,%r9
  407a76:	74 38                	je     407ab0 <p113d_FID_36_112_114_111_100_117_99_116_46_116_114_97_99_101_+0x810>
  407a78:	49 83 f8 00          	cmp    $0x0,%r8
  407a7c:	74 2b                	je     407aa9 <p113d_FID_36_112_114_111_100_117_99_116_46_116_114_97_99_101_+0x809>
  407a7e:	66 90                	xchg   %ax,%ax
  407a80:	48 83 ff 00          	cmp    $0x0,%rdi
  407a84:	74 1c                	je     407aa2 <p113d_FID_36_112_114_111_100_117_99_116_46_116_114_97_99_101_+0x802>
  407a86:	48 83 fe 00          	cmp    $0x0,%rsi
  407a8a:	74 0f                	je     407a9b <p113d_FID_36_112_114_111_100_117_99_116_46_116_114_97_99_101_+0x7fb>
  407a8c:	48 83 f9 00          	cmp    $0x0,%rcx
  407a90:	bb cd cc 4c 3e       	mov    $0x3e4ccccd,%ebx
  407a95:	49 0f 45 dc          	cmovne %r12,%rbx
  407a99:	eb 28                	jmp    407ac3 <p113d_FID_36_112_114_111_100_117_99_116_46_116_114_97_99_101_+0x823>
  407a9b:	bb cd cc cc 3f       	mov    $0x3fcccccd,%ebx
  407aa0:	eb 21                	jmp    407ac3 <p113d_FID_36_112_114_111_100_117_99_116_46_116_114_97_99_101_+0x823>
  407aa2:	bb 9a 99 19 bf       	mov    $0xbf19999a,%ebx
  407aa7:	eb 1a                	jmp    407ac3 <p113d_FID_36_112_114_111_100_117_99_116_46_116_114_97_99_101_+0x823>
  407aa9:	bb 9a 99 19 bf       	mov    $0xbf19999a,%ebx
  407aae:	eb 13                	jmp    407ac3 <p113d_FID_36_112_114_111_100_117_99_116_46_116_114_97_99_101_+0x823>
  407ab0:	bb 00 00 00 3f       	mov    $0x3f000000,%ebx
  407ab5:	eb 0c                	jmp    407ac3 <p113d_FID_36_112_114_111_100_117_99_116_46_116_114_97_99_101_+0x823>
  407ab7:	bb 00 00 00 3f       	mov    $0x3f000000,%ebx
  407abc:	eb 05                	jmp    407ac3 <p113d_FID_36_112_114_111_100_117_99_116_46_116_114_97_99_101_+0x823>
  407abe:	bb 00 00 00 00       	mov    $0x0,%ebx
  407ac3:	49 89 dc             	mov    %rbx,%r12
  407ac6:	eb 06                	jmp    407ace <p113d_FID_36_112_114_111_100_117_99_116_46_116_114_97_99_101_+0x82e>
  407ac8:	41 bc 00 44 1c c6    	mov    $0xc61c4400,%r12d
  407ace:	49 83 ff 00          	cmp    $0x0,%r15
  407ad2:	74 63                	je     407b37 <p113d_FID_36_112_114_111_100_117_99_116_46_116_114_97_99_101_+0x897>
  407ad4:	49 83 fb 00          	cmp    $0x0,%r11
  407ad8:	74 56                	je     407b30 <p113d_FID_36_112_114_111_100_117_99_116_46_116_114_97_99_101_+0x890>
  407ada:	66 0f 1f 44 00 00    	nopw   0x0(%rax,%rax,1)
  407ae0:	49 83 fa 00          	cmp    $0x0,%r10
  407ae4:	74 43                	je     407b29 <p113d_FID_36_112_114_111_100_117_99_116_46_116_114_97_99_101_+0x889>
  407ae6:	49 83 f9 00          	cmp    $0x0,%r9
  407aea:	74 36                	je     407b22 <p113d_FID_36_112_114_111_100_117_99_116_46_116_114_97_99_101_+0x882>
  407aec:	49 83 f8 00          	cmp    $0x0,%r8
  407af0:	74 29                	je     407b1b <p113d_FID_36_112_114_111_100_117_99_116_46_116_114_97_99_101_+0x87b>
  407af2:	48 83 ff 00          	cmp    $0x0,%rdi
  407af6:	74 1c                	je     407b14 <p113d_FID_36_112_114_111_100_117_99_116_46_116_114_97_99_101_+0x874>
  407af8:	48 83 fe 00          	cmp    $0x0,%rsi
  407afc:	74 0f                	je     407b0d <p113d_FID_36_112_114_111_100_117_99_116_46_116_114_97_99_101_+0x86d>
  407afe:	48 83 f9 00          	cmp    $0x0,%rcx
  407b02:	b9 00 00 00 41       	mov    $0x41000000,%ecx
  407b07:	48 0f 45 ca          	cmovne %rdx,%rcx
  407b0b:	eb 2f                	jmp    407b3c <p113d_FID_36_112_114_111_100_117_99_116_46_116_114_97_99_101_+0x89c>
  407b0d:	b9 00 00 e0 40       	mov    $0x40e00000,%ecx
  407b12:	eb 28                	jmp    407b3c <p113d_FID_36_112_114_111_100_117_99_116_46_116_114_97_99_101_+0x89c>
  407b14:	b9 00 00 60 40       	mov    $0x40600000,%ecx
  407b19:	eb 21                	jmp    407b3c <p113d_FID_36_112_114_111_100_117_99_116_46_116_114_97_99_101_+0x89c>
  407b1b:	b9 00 00 60 40       	mov    $0x40600000,%ecx
  407b20:	eb 1a                	jmp    407b3c <p113d_FID_36_112_114_111_100_117_99_116_46_116_114_97_99_101_+0x89c>
  407b22:	b9 00 00 c0 40       	mov    $0x40c00000,%ecx
  407b27:	eb 13                	jmp    407b3c <p113d_FID_36_112_114_111_100_117_99_116_46_116_114_97_99_101_+0x89c>
  407b29:	b9 00 00 c0 40       	mov    $0x40c00000,%ecx
  407b2e:	eb 0c                	jmp    407b3c <p113d_FID_36_112_114_111_100_117_99_116_46_116_114_97_99_101_+0x89c>
  407b30:	b9 00 00 a0 40       	mov    $0x40a00000,%ecx
  407b35:	eb 05                	jmp    407b3c <p113d_FID_36_112_114_111_100_117_99_116_46_116_114_97_99_101_+0x89c>
  407b37:	b9 00 00 a0 40       	mov    $0x40a00000,%ecx
  407b3c:	66 48 0f 6e c9       	movq   %rcx,%xmm1
  407b41:	0f 57 0d c8 94 02 00 	xorps  0x294c8(%rip),%xmm1        # 431010 <_IO_stdin_used+0x10>
  407b48:	f3 0f 58 ca          	addss  %xmm2,%xmm1
  407b4c:	66 48 0f 6e f0       	movq   %rax,%xmm6
  407b51:	f3 0f 11 b5 44 ff ff ff 	movss  %xmm6,-0xbc(%rbp)
  407b59:	f3 0f 5e ce          	divss  %xmm6,%xmm1
  407b5d:	66 48 0f 7e c8       	movq   %xmm1,%rax
  407b62:	89 c3                	mov    %eax,%ebx
  407b64:	e8 57 a9 ff ff       	callq  4024c0 <sqrt@plt>
  407b69:	4c 89 f7             	mov    %r14,%rdi
  407b6c:	f2 0f 10 d8          	movsd  %xmm0,%xmm3
  407b70:	f3 0f 10 8d 28 ff ff ff 	movss  -0xd8(%rbp),%xmm1
  407b78:	f3 0f 10 bd 40 ff ff ff 	movss  -0xc0(%rbp),%xmm7
  407b80:	f3 0f 10 ad 3c ff ff ff 	movss  -0xc4(%rbp),%xmm5
  407b88:	f3 0f 10 95 38 ff ff ff 	movss  -0xc8(%rbp),%xmm2
  407b90:	f3 0f 10 a5 34 ff ff ff 	movss  -0xcc(%rbp),%xmm4
  407b98:	f3 0f 10 85 30 ff ff ff 	movss  -0xd0(%rbp),%xmm0
  407ba0:	f3 0f 10 b5 44 ff ff ff 	movss  -0xbc(%rbp),%xmm6
  407ba8:	f2 0f 5a db          	cvtsd2ss %xmm3,%xmm3
  407bac:	f3 0f 11 9d 08 ff ff ff 	movss  %xmm3,-0xf8(%rbp)
  407bb4:	f3 0f 5e d3          	divss  %xmm3,%xmm2
  407bb8:	f3 0f 11 95 10 ff ff ff 	movss  %xmm2,-0xf0(%rbp)
  407bc0:	f3 0f 5e eb          	divss  %xmm3,%xmm5
  407bc4:	f3 0f 11 ad 14 ff ff ff 	movss  %xmm5,-0xec(%rbp)
  407bcc:	f3 44 0f 10 fb       	movss  %xmm3,%xmm15
  407bd1:	f3 0f 10 df          	movss  %xmm7,%xmm3
  407bd5:	f3 41 0f 5e df       	divss  %xmm15,%xmm3
  407bda:	f3 0f 11 9d 18 ff ff ff 	movss  %xmm3,-0xe8(%rbp)
  407be2:	66 49 0f 6e fd       	movq   %r13,%xmm7
  407be7:	f3 0f 5c c7          	subss  %xmm7,%xmm0
  407beb:	f3 0f 5e c6          	divss  %xmm6,%xmm0
  407bef:	66 48 0f 7e c0       	movq   %xmm0,%rax
  407bf4:	89 c0                	mov    %eax,%eax
  407bf6:	66 48 0f 6e c0       	movq   %rax,%xmm0
  407bfb:	f3 0f 11 85 2c ff ff ff 	movss  %xmm0,-0xd4(%rbp)
  407c03:	f3 0f 59 d0          	mulss  %xmm0,%xmm2
  407c07:	66 49 0f 6e fc       	movq   %r12,%xmm7
  407c0c:	f3 0f 5c e7          	subss  %xmm7,%xmm4
  407c10:	f3 0f 5e e6          	divss  %xmm6,%xmm4
  407c14:	66 48 0f 7e e0       	movq   %xmm4,%rax
  407c19:	89 c0                	mov    %eax,%eax
  407c1b:	66 48 0f 6e e0       	movq   %rax,%xmm4
  407c20:	f3 0f 11 a5 24 ff ff ff 	movss  %xmm4,-0xdc(%rbp)
  407c28:	f3 0f 59 e5          	mulss  %xmm5,%xmm4
  407c2c:	f3 0f 58 d4          	addss  %xmm4,%xmm2
  407c30:	66 48 0f 6e e3       	movq   %rbx,%xmm4
  407c35:	f3 0f 11 a5 1c ff ff ff 	movss  %xmm4,-0xe4(%rbp)
  407c3d:	f3 0f 59 dc          	mulss  %xmm4,%xmm3
  407c41:	f3 0f 58 d3          	addss  %xmm3,%xmm2
  407c45:	f3 0f 10 1d d7 93 02 00 	movss  0x293d7(%rip),%xmm3        # 431024 <_IO_stdin_used+0x24>
  407c4d:	0f 2e da             	ucomiss %xmm2,%xmm3
  407c50:	0f 97 c0             	seta   %al
  407c53:	0f b6 c0             	movzbl %al,%eax
  407c56:	89 c1                	mov    %eax,%ecx
  407c58:	48 83 f9 01          	cmp    $0x1,%rcx
  407c5c:	0f 94 c0             	sete   %al
  407c5f:	0f b6 c0             	movzbl %al,%eax
  407c62:	48 c1 e9 28          	shr    $0x28,%rcx
  407c66:	48 81 e1 ff ff 7f 00 	and    $0x7fffff,%rcx
  407c6d:	48 81 f9 02 00 01 00 	cmp    $0x10002,%rcx
  407c74:	0f 94 c1             	sete   %cl
  407c77:	0f b6 c9             	movzbl %cl,%ecx
  407c7a:	09 c8                	or     %ecx,%eax
  407c7c:	75 35                	jne    407cb3 <p113d_FID_36_112_114_111_100_117_99_116_46_116_114_97_99_101_+0xa13>
  407c7e:	83 f0 01             	xor    $0x1,%eax
  407c81:	75 27                	jne    407caa <p113d_FID_36_112_114_111_100_117_99_116_46_116_114_97_99_101_+0xa0a>
  407c83:	be 04 00 00 00       	mov    $0x4,%esi
  407c88:	48 89 fb             	mov    %rdi,%rbx
  407c8b:	e8 10 33 02 00       	callq  42afa0 <p111_rt_fail>
  407c90:	48 89 df             	mov    %rbx,%rdi
  407c93:	f3 0f 10 8d 28 ff ff ff 	movss  -0xd8(%rbp),%xmm1
  407c9b:	f3 0f 10 85 2c ff ff ff 	movss  -0xd4(%rbp),%xmm0
  407ca3:	b9 00 00 00 00       	mov    $0x0,%ecx
  407ca8:	eb 0e                	jmp    407cb8 <p113d_FID_36_112_114_111_100_117_99_116_46_116_114_97_99_101_+0xa18>
  407caa:	66 48 0f 7e d0       	movq   %xmm2,%rax
  407caf:	89 c1                	mov    %eax,%ecx
  407cb1:	eb 05                	jmp    407cb8 <p113d_FID_36_112_114_111_100_117_99_116_46_116_114_97_99_101_+0xa18>
  407cb3:	b9 00 00 00 00       	mov    $0x0,%ecx
  407cb8:	49 89 ce             	mov    %rcx,%r14
  407cbb:	f3 0f 59 05 65 93 02 00 	mulss  0x29365(%rip),%xmm0        # 431028 <_IO_stdin_used+0x28>
  407cc3:	f3 0f 58 c1          	addss  %xmm1,%xmm0
  407cc7:	66 48 0f 7e c0       	movq   %xmm0,%rax
  407ccc:	89 c2                	mov    %eax,%edx
  407cce:	49 89 d4             	mov    %rdx,%r12
  407cd1:	ba e8 03 00 00       	mov    $0x3e8,%edx
  407cd6:	be 01 00 00 00       	mov    $0x1,%esi
  407cdb:	48 89 fb             	mov    %rdi,%rbx
  407cde:	e8 4d e0 ff ff       	callq  405d30 <p113d_FID_36_100_105_114_101_99_116_46_102_108_>
  407ce3:	4c 89 e2             	mov    %r12,%rdx
  407ce6:	48 89 df             	mov    %rbx,%rdi
  407ce9:	f3 0f 10 8d 20 ff ff ff 	movss  -0xe0(%rbp),%xmm1
  407cf1:	f3 0f 10 85 24 ff ff ff 	movss  -0xdc(%rbp),%xmm0
  407cf9:	66 48 0f 6e d0       	movq   %rax,%xmm2
  407cfe:	f3 0f 59 c2          	mulss  %xmm2,%xmm0
  407d02:	f3 0f 58 c1          	addss  %xmm1,%xmm0
  407d06:	66 48 0f 7e c0       	movq   %xmm0,%rax
  407d0b:	41 89 c5             	mov    %eax,%r13d
  407d0e:	49 89 d4             	mov    %rdx,%r12
  407d11:	ba e8 03 00 00       	mov    $0x3e8,%edx
  407d16:	be 01 00 00 00       	mov    $0x1,%esi
  407d1b:	48 89 fb             	mov    %rdi,%rbx
  407d1e:	e8 0d e0 ff ff       	callq  405d30 <p113d_FID_36_100_105_114_101_99_116_46_102_108_>
  407d23:	4c 89 e9             	mov    %r13,%rcx
  407d26:	4c 89 e2             	mov    %r12,%rdx
  407d29:	48 89 df             	mov    %rbx,%rdi
  407d2c:	f3 0f 10 9d 0c ff ff ff 	movss  -0xf4(%rbp),%xmm3
  407d34:	f3 0f 10 a5 1c ff ff ff 	movss  -0xe4(%rbp),%xmm4
  407d3c:	f3 0f 10 85 18 ff ff ff 	movss  -0xe8(%rbp),%xmm0
  407d44:	f3 0f 10 8d 14 ff ff ff 	movss  -0xec(%rbp),%xmm1
  407d4c:	f3 0f 10 95 10 ff ff ff 	movss  -0xf0(%rbp),%xmm2
  407d54:	66 48 0f 6e e8       	movq   %rax,%xmm5
  407d59:	f3 0f 59 e5          	mulss  %xmm5,%xmm4
  407d5d:	f3 0f 58 dc          	addss  %xmm4,%xmm3
  407d61:	66 48 0f 7e d8       	movq   %xmm3,%rax
  407d66:	41 89 c0             	mov    %eax,%r8d
  407d69:	66 48 0f 7e d0       	movq   %xmm2,%rax
  407d6e:	41 89 c1             	mov    %eax,%r9d
  407d71:	66 48 0f 7e c8       	movq   %xmm1,%rax
  407d76:	89 c0                	mov    %eax,%eax
  407d78:	66 48 0f 7e c6       	movq   %xmm0,%rsi
  407d7d:	41 89 f2             	mov    %esi,%r10d
  407d80:	48 83 ec 30          	sub    $0x30,%rsp
  407d84:	48 89 e6             	mov    %rsp,%rsi
  407d87:	48 c7 46 20 00 00 00 00 	movq   $0x0,0x20(%rsi)
  407d8f:	48 c7 46 18 28 6b 6e 4e 	movq   $0x4e6e6b28,0x18(%rsi)
  407d97:	48 c7 46 10 28 6b 6e 4e 	movq   $0x4e6e6b28,0x10(%rsi)
  407d9f:	4c 89 56 08          	mov    %r10,0x8(%rsi)
  407da3:	48 89 06             	mov    %rax,(%rsi)
  407da6:	be 09 00 00 00       	mov    $0x9,%esi
  407dab:	48 89 fb             	mov    %rdi,%rbx
  407dae:	e8 1d ef ff ff       	callq  406cd0 <p113d_FID_36_100_105_114_101_99_116_46_110_101_97_114_101_115_116_46_116_>
  407db3:	48 89 df             	mov    %rbx,%rdi
  407db6:	48 89 c6             	mov    %rax,%rsi
  407db9:	48 83 ec d0          	sub    $0xffffffffffffffd0,%rsp
  407dbd:	ba 0a 00 00 00       	mov    $0xa,%edx
  407dc2:	49 89 f4             	mov    %rsi,%r12
  407dc5:	be 01 00 00 00       	mov    $0x1,%esi
  407dca:	48 89 fb             	mov    %rdi,%rbx
  407dcd:	e8 5e df ff ff       	callq  405d30 <p113d_FID_36_100_105_114_101_99_116_46_102_108_>
  407dd2:	4c 89 e6             	mov    %r12,%rsi
  407dd5:	48 89 df             	mov    %rbx,%rdi
  407dd8:	48 89 c3             	mov    %rax,%rbx
  407ddb:	ba 64 00 00 00       	mov    $0x64,%edx
  407de0:	49 89 f5             	mov    %rsi,%r13
  407de3:	be 55 00 00 00       	mov    $0x55,%esi
  407de8:	49 89 fc             	mov    %rdi,%r12
  407deb:	e8 40 df ff ff       	callq  405d30 <p113d_FID_36_100_105_114_101_99_116_46_102_108_>
  407df0:	4c 89 f1             	mov    %r14,%rcx
  407df3:	4c 89 ee             	mov    %r13,%rsi
  407df6:	4c 89 e7             	mov    %r12,%rdi
  407df9:	49 89 c4             	mov    %rax,%r12
  407dfc:	f3 0f 10 85 08 ff ff ff 	movss  -0xf8(%rbp),%xmm0
  407e04:	66 48 0f 7e c0       	movq   %xmm0,%rax
  407e09:	89 c2                	mov    %eax,%edx
  407e0b:	e8 90 e4 ff ff       	callq  4062a0 <p113d_FID_36_100_105_114_101_99_116_46_115_104_97_100_101_>
  407e10:	f3 0f 10 9d 04 ff ff ff 	movss  -0xfc(%rbp),%xmm3
  407e18:	f3 0f 10 85 00 ff ff ff 	movss  -0x100(%rbp),%xmm0
  407e20:	66 49 0f 6e cc       	movq   %r12,%xmm1
  407e25:	66 48 0f 6e d0       	movq   %rax,%xmm2
  407e2a:	f3 0f 59 ca          	mulss  %xmm2,%xmm1
  407e2e:	66 48 0f 6e d3       	movq   %rbx,%xmm2
  407e33:	f3 0f 58 ca          	addss  %xmm2,%xmm1
  407e37:	f3 0f 59 c1          	mulss  %xmm1,%xmm0
  407e3b:	f3 0f 58 c3          	addss  %xmm3,%xmm0
  407e3f:	66 48 0f 7e c0       	movq   %xmm0,%rax
  407e44:	89 c0                	mov    %eax,%eax
  407e46:	41 5f                	pop    %r15
  407e48:	41 5e                	pop    %r14
  407e4a:	41 5d                	pop    %r13
  407e4c:	41 5c                	pop    %r12
  407e4e:	5b                   	pop    %rbx
  407e4f:	c9                   	leaveq 
  407e50:	c3                   	retq   
  407e51:	66 66 2e 0f 1f 84 00 00 00 00 00 	data16 nopw %cs:0x0(%rax,%rax,1)
  407e5c:	0f 1f 40 00          	nopl   0x0(%rax)

