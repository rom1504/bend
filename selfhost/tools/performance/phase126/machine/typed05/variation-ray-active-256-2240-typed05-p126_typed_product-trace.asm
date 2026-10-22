00000000004073b0 <p126_typed_FID_36_112_114_111_100_117_99_116_46_116_114_97_99_101_>:
  4073b0:	f3 0f 1e fa          	endbr64 
  4073b4:	55                   	push   %rbp
  4073b5:	48 89 e5             	mov    %rsp,%rbp
  4073b8:	48 81 ec 38 01 00 00 	sub    $0x138,%rsp
  4073bf:	53                   	push   %rbx
  4073c0:	41 54                	push   %r12
  4073c2:	41 55                	push   %r13
  4073c4:	41 56                	push   %r14
  4073c6:	41 57                	push   %r15
  4073c8:	4c 89 c0             	mov    %r8,%rax
  4073cb:	48 89 cb             	mov    %rcx,%rbx
  4073ce:	b9 00 00 00 41       	mov    $0x41000000,%ecx
  4073d3:	48 89 8d 60 ff ff ff 	mov    %rcx,-0xa0(%rbp)
  4073da:	41 bf cd cc 4c 3e    	mov    $0x3e4ccccd,%r15d
  4073e0:	4c 89 bd 68 ff ff ff 	mov    %r15,-0x98(%rbp)
  4073e7:	41 bd 00 00 60 c0    	mov    $0xc0600000,%r13d
  4073ed:	4c 89 ad 70 ff ff ff 	mov    %r13,-0x90(%rbp)
  4073f4:	41 bc 00 00 80 3f    	mov    $0x3f800000,%r12d
  4073fa:	4c 89 a5 78 ff ff ff 	mov    %r12,-0x88(%rbp)
  407401:	48 89 d9             	mov    %rbx,%rcx
  407404:	f3 44 0f 10 f9       	movss  %xmm1,%xmm15
  407409:	f3 0f 10 ca          	movss  %xmm2,%xmm1
  40740d:	f3 41 0f 10 d7       	movss  %xmm15,%xmm2
  407412:	f3 44 0f 10 f8       	movss  %xmm0,%xmm15
  407417:	f3 0f 10 c1          	movss  %xmm1,%xmm0
  40741b:	f3 41 0f 10 cf       	movss  %xmm15,%xmm1
  407420:	49 89 c0             	mov    %rax,%r8
  407423:	66 66 2e 0f 1f 84 00 00 00 00 00 	data16 nopw %cs:0x0(%rax,%rax,1)
  40742e:	66 90                	xchg   %ax,%ax
  407430:	f3 0f 11 65 b8       	movss  %xmm4,-0x48(%rbp)
  407435:	f3 0f 11 6d b4       	movss  %xmm5,-0x4c(%rbp)
  40743a:	f3 0f 11 75 b0       	movss  %xmm6,-0x50(%rbp)
  40743f:	66 48 0f 7e f8       	movq   %xmm7,%rax
  407444:	89 c0                	mov    %eax,%eax
  407446:	48 83 fe 00          	cmp    $0x0,%rsi
  40744a:	49 89 f4             	mov    %rsi,%r12
  40744d:	40 0f 94 c6          	sete   %sil
  407451:	40 0f b6 f6          	movzbl %sil,%esi
  407455:	f3 0f 59 e1          	mulss  %xmm1,%xmm4
  407459:	f3 0f 58 d4          	addss  %xmm4,%xmm2
  40745d:	f3 0f 11 95 48 ff ff ff 	movss  %xmm2,-0xb8(%rbp)
  407465:	66 49 0f 7e d3       	movq   %xmm2,%r11
  40746a:	f3 0f 10 e5          	movss  %xmm5,%xmm4
  40746e:	f3 0f 59 e1          	mulss  %xmm1,%xmm4
  407472:	f3 0f 58 c4          	addss  %xmm4,%xmm0
  407476:	f3 0f 11 85 4c ff ff ff 	movss  %xmm0,-0xb4(%rbp)
  40747e:	66 49 0f 7e c2       	movq   %xmm0,%r10
  407483:	f3 0f 59 ce          	mulss  %xmm6,%xmm1
  407487:	f3 0f 58 cb          	addss  %xmm3,%xmm1
  40748b:	f3 0f 11 4d e4       	movss  %xmm1,-0x1c(%rbp)
  407490:	66 49 0f 7e c9       	movq   %xmm1,%r9
  407495:	f3 0f 10 1d 93 9b 02 00 	movss  0x29b93(%rip),%xmm3        # 431030 <_IO_stdin_used+0x30>
  40749d:	f3 0f 5c da          	subss  %xmm2,%xmm3
  4074a1:	f3 0f 11 9d 50 ff ff ff 	movss  %xmm3,-0xb0(%rbp)
  4074a9:	f3 0f 10 15 7b 9b 02 00 	movss  0x29b7b(%rip),%xmm2        # 43102c <_IO_stdin_used+0x2c>
  4074b1:	f3 0f 5c d0          	subss  %xmm0,%xmm2
  4074b5:	f3 0f 11 95 54 ff ff ff 	movss  %xmm2,-0xac(%rbp)
  4074bd:	f3 0f 10 05 5b 9b 02 00 	movss  0x29b5b(%rip),%xmm0        # 431020 <_IO_stdin_used+0x20>
  4074c5:	f3 0f 5c c1          	subss  %xmm1,%xmm0
  4074c9:	f3 0f 11 85 58 ff ff ff 	movss  %xmm0,-0xa8(%rbp)
  4074d1:	f3 0f 10 c8          	movss  %xmm0,%xmm1
  4074d5:	f3 0f 10 c3          	movss  %xmm3,%xmm0
  4074d9:	f3 0f 59 c3          	mulss  %xmm3,%xmm0
  4074dd:	f3 0f 59 d2          	mulss  %xmm2,%xmm2
  4074e1:	f3 0f 58 c2          	addss  %xmm2,%xmm0
  4074e5:	f3 0f 59 c9          	mulss  %xmm1,%xmm1
  4074e9:	f3 0f 58 c1          	addss  %xmm1,%xmm0
  4074ed:	f3 0f 5a c0          	cvtss2sd %xmm0,%xmm0
  4074f1:	f2 0f 11 45 f8       	movsd  %xmm0,-0x8(%rbp)
  4074f6:	45 89 db             	mov    %r11d,%r11d
  4074f9:	66 49 0f 6e cb       	movq   %r11,%xmm1
  4074fe:	f3 0f 11 8d 40 ff ff ff 	movss  %xmm1,-0xc0(%rbp)
  407506:	45 89 d2             	mov    %r10d,%r10d
  407509:	66 49 0f 6e ca       	movq   %r10,%xmm1
  40750e:	f3 0f 11 8d 38 ff ff ff 	movss  %xmm1,-0xc8(%rbp)
  407516:	45 89 c9             	mov    %r9d,%r9d
  407519:	66 49 0f 6e f1       	movq   %r9,%xmm6
  40751e:	f3 0f 11 b5 1c ff ff ff 	movss  %xmm6,-0xe4(%rbp)
  407526:	66 48 0f 6e c0       	movq   %rax,%xmm0
  40752b:	f3 0f 11 85 10 ff ff ff 	movss  %xmm0,-0xf0(%rbp)
  407533:	66 49 0f 6e d8       	movq   %r8,%xmm3
  407538:	f3 0f 11 9d 14 ff ff ff 	movss  %xmm3,-0xec(%rbp)
  407540:	48 83 fa 01          	cmp    $0x1,%rdx
  407544:	49 89 ce             	mov    %rcx,%r14
  407547:	0f 94 c1             	sete   %cl
  40754a:	0f b6 c9             	movzbl %cl,%ecx
  40754d:	48 89 d0             	mov    %rdx,%rax
  407550:	48 c1 e8 28          	shr    $0x28,%rax
  407554:	48 25 ff ff 7f 00    	and    $0x7fffff,%rax
  40755a:	48 3d 02 00 01 00    	cmp    $0x10002,%rax
  407560:	0f 94 c2             	sete   %dl
  407563:	0f b6 d2             	movzbl %dl,%edx
  407566:	89 c8                	mov    %ecx,%eax
  407568:	09 d0                	or     %edx,%eax
  40756a:	83 fe 00             	cmp    $0x0,%esi
  40756d:	0f 85 e5 04 00 00    	jne    407a58 <p126_typed_FID_36_112_114_111_100_117_99_116_46_116_114_97_99_101_+0x6a8>
  407573:	09 d1                	or     %edx,%ecx
  407575:	0f 85 d5 04 00 00    	jne    407a50 <p126_typed_FID_36_112_114_111_100_117_99_116_46_116_114_97_99_101_+0x6a0>
  40757b:	2e 2e 83 f0 01       	cs cs xor $0x1,%eax
  407580:	0f 84 b6 04 00 00    	je     407a3c <p126_typed_FID_36_112_114_111_100_117_99_116_46_116_114_97_99_101_+0x68c>
  407586:	4c 89 f6             	mov    %r14,%rsi
  407589:	48 89 fb             	mov    %rdi,%rbx
  40758c:	e8 af ee ff ff       	callq  406440 <p113d_FID_36_100_105_114_101_99_116_46_115_114_>
  407591:	48 89 df             	mov    %rbx,%rdi
  407594:	48 89 c3             	mov    %rax,%rbx
  407597:	4c 89 f6             	mov    %r14,%rsi
  40759a:	49 89 fd             	mov    %rdi,%r13
  40759d:	e8 0e f1 ff ff       	callq  4066b0 <p113d_FID_36_100_105_114_101_99_116_46_115_120_>
  4075a2:	4c 89 ef             	mov    %r13,%rdi
  4075a5:	f3 0f 10 85 48 ff ff ff 	movss  -0xb8(%rbp),%xmm0
  4075ad:	66 48 0f 6e c8       	movq   %rax,%xmm1
  4075b2:	f3 0f 5c c1          	subss  %xmm1,%xmm0
  4075b6:	66 48 0f 6e d3       	movq   %rbx,%xmm2
  4075bb:	f3 0f 11 55 f0       	movss  %xmm2,-0x10(%rbp)
  4075c0:	f3 0f 5e c2          	divss  %xmm2,%xmm0
  4075c4:	66 48 0f 7e c0       	movq   %xmm0,%rax
  4075c9:	41 89 c5             	mov    %eax,%r13d
  4075cc:	4c 89 f6             	mov    %r14,%rsi
  4075cf:	48 89 fb             	mov    %rdi,%rbx
  4075d2:	e8 09 f0 ff ff       	callq  4065e0 <p113d_FID_36_100_105_114_101_99_116_46_115_121_>
  4075d7:	48 89 df             	mov    %rbx,%rdi
  4075da:	f3 0f 10 55 f0       	movss  -0x10(%rbp),%xmm2
  4075df:	f3 0f 10 85 4c ff ff ff 	movss  -0xb4(%rbp),%xmm0
  4075e7:	66 48 0f 6e c8       	movq   %rax,%xmm1
  4075ec:	f3 0f 5c c1          	subss  %xmm1,%xmm0
  4075f0:	f3 0f 5e c2          	divss  %xmm2,%xmm0
  4075f4:	66 48 0f 7e c0       	movq   %xmm0,%rax
  4075f9:	89 c3                	mov    %eax,%ebx
  4075fb:	4c 89 f6             	mov    %r14,%rsi
  4075fe:	49 89 ff             	mov    %rdi,%r15
  407601:	e8 0a ef ff ff       	callq  406510 <p113d_FID_36_100_105_114_101_99_116_46_115_122_>
  407606:	f2 0f 10 45 f8       	movsd  -0x8(%rbp),%xmm0
  40760b:	f3 0f 10 55 f0       	movss  -0x10(%rbp),%xmm2
  407610:	f3 0f 10 4d e4       	movss  -0x1c(%rbp),%xmm1
  407615:	66 48 0f 6e d8       	movq   %rax,%xmm3
  40761a:	f3 0f 5c cb          	subss  %xmm3,%xmm1
  40761e:	f3 0f 5e ca          	divss  %xmm2,%xmm1
  407622:	66 48 0f 7e c8       	movq   %xmm1,%rax
  407627:	89 c0                	mov    %eax,%eax
  407629:	48 89 45 e8          	mov    %rax,-0x18(%rbp)
  40762d:	e8 8e ae ff ff       	callq  4024c0 <sqrt@plt>
  407632:	4c 89 ff             	mov    %r15,%rdi
  407635:	f2 0f 10 c8          	movsd  %xmm0,%xmm1
  407639:	48 8b 45 e8          	mov    -0x18(%rbp),%rax
  40763d:	f3 0f 10 85 58 ff ff ff 	movss  -0xa8(%rbp),%xmm0
  407645:	f3 0f 10 95 54 ff ff ff 	movss  -0xac(%rbp),%xmm2
  40764d:	f3 0f 10 9d 50 ff ff ff 	movss  -0xb0(%rbp),%xmm3
  407655:	f2 0f 5a c9          	cvtsd2ss %xmm1,%xmm1
  407659:	f3 0f 11 4d bc       	movss  %xmm1,-0x44(%rbp)
  40765e:	f3 0f 5e d9          	divss  %xmm1,%xmm3
  407662:	f3 0f 11 5d d8       	movss  %xmm3,-0x28(%rbp)
  407667:	f3 0f 10 e2          	movss  %xmm2,%xmm4
  40766b:	f3 0f 5e e1          	divss  %xmm1,%xmm4
  40766f:	f3 0f 11 65 dc       	movss  %xmm4,-0x24(%rbp)
  407674:	f3 0f 10 e8          	movss  %xmm0,%xmm5
  407678:	f3 0f 5e e9          	divss  %xmm1,%xmm5
  40767c:	f3 0f 11 6d e0       	movss  %xmm5,-0x20(%rbp)
  407681:	66 4d 0f 6e cd       	movq   %r13,%xmm9
  407686:	f3 44 0f 11 4d 98    	movss  %xmm9,-0x68(%rbp)
  40768c:	f3 0f 10 c3          	movss  %xmm3,%xmm0
  407690:	f3 41 0f 59 c1       	mulss  %xmm9,%xmm0
  407695:	66 4c 0f 6e c3       	movq   %rbx,%xmm8
  40769a:	f3 44 0f 11 45 9c    	movss  %xmm8,-0x64(%rbp)
  4076a0:	f3 0f 10 cc          	movss  %xmm4,%xmm1
  4076a4:	f3 41 0f 59 c8       	mulss  %xmm8,%xmm1
  4076a9:	f3 0f 58 c1          	addss  %xmm1,%xmm0
  4076ad:	66 48 0f 6e d0       	movq   %rax,%xmm2
  4076b2:	f3 0f 11 55 a0       	movss  %xmm2,-0x60(%rbp)
  4076b7:	f3 0f 10 cd          	movss  %xmm5,%xmm1
  4076bb:	f3 0f 59 ca          	mulss  %xmm2,%xmm1
  4076bf:	f3 0f 58 c1          	addss  %xmm1,%xmm0
  4076c3:	66 48 0f 7e c0       	movq   %xmm0,%rax
  4076c8:	89 c6                	mov    %eax,%esi
  4076ca:	48 89 fb             	mov    %rdi,%rbx
  4076cd:	e8 ee e5 ff ff       	callq  405cc0 <p113d_FID_36_100_105_114_101_99_116_46_102_109_97_120_48_>
  4076d2:	48 89 df             	mov    %rbx,%rdi
  4076d5:	49 89 c5             	mov    %rax,%r13
  4076d8:	f3 0f 10 0d 64 99 02 00 	movss  0x29964(%rip),%xmm1        # 431044 <_IO_stdin_used+0x44>
  4076e0:	f3 0f 10 05 54 99 02 00 	movss  0x29954(%rip),%xmm0        # 43103c <_IO_stdin_used+0x3c>
  4076e8:	48 89 fb             	mov    %rdi,%rbx
  4076eb:	e8 60 e6 ff ff       	callq  405d50 <p126_typed_FID_36_100_105_114_101_99_116_46_102_108_>
  4076f0:	48 89 df             	mov    %rbx,%rdi
  4076f3:	f3 0f 10 8d 40 ff ff ff 	movss  -0xc0(%rbp),%xmm1
  4076fb:	f3 44 0f 10 4d 98    	movss  -0x68(%rbp),%xmm9
  407701:	66 48 0f 6e c0       	movq   %rax,%xmm0
  407706:	f3 41 0f 59 c1       	mulss  %xmm9,%xmm0
  40770b:	f3 0f 58 c1          	addss  %xmm1,%xmm0
  40770f:	f3 0f 11 45 a4       	movss  %xmm0,-0x5c(%rbp)
  407714:	66 48 0f 7e c0       	movq   %xmm0,%rax
  407719:	89 c3                	mov    %eax,%ebx
  40771b:	48 89 5d c0          	mov    %rbx,-0x40(%rbp)
  40771f:	f3 0f 10 0d 1d 99 02 00 	movss  0x2991d(%rip),%xmm1        # 431044 <_IO_stdin_used+0x44>
  407727:	f3 0f 10 05 0d 99 02 00 	movss  0x2990d(%rip),%xmm0        # 43103c <_IO_stdin_used+0x3c>
  40772f:	48 89 fb             	mov    %rdi,%rbx
  407732:	e8 19 e6 ff ff       	callq  405d50 <p126_typed_FID_36_100_105_114_101_99_116_46_102_108_>
  407737:	48 89 df             	mov    %rbx,%rdi
  40773a:	f3 0f 10 8d 38 ff ff ff 	movss  -0xc8(%rbp),%xmm1
  407742:	f3 44 0f 10 45 9c    	movss  -0x64(%rbp),%xmm8
  407748:	66 48 0f 6e c0       	movq   %rax,%xmm0
  40774d:	f3 41 0f 59 c0       	mulss  %xmm8,%xmm0
  407752:	f3 0f 58 c8          	addss  %xmm0,%xmm1
  407756:	f3 0f 11 4d a8       	movss  %xmm1,-0x58(%rbp)
  40775b:	66 48 0f 7e c8       	movq   %xmm1,%rax
  407760:	89 c3                	mov    %eax,%ebx
  407762:	48 89 5d c8          	mov    %rbx,-0x38(%rbp)
  407766:	f3 0f 10 0d d6 98 02 00 	movss  0x298d6(%rip),%xmm1        # 431044 <_IO_stdin_used+0x44>
  40776e:	f3 0f 10 05 c6 98 02 00 	movss  0x298c6(%rip),%xmm0        # 43103c <_IO_stdin_used+0x3c>
  407776:	48 89 fb             	mov    %rdi,%rbx
  407779:	e8 d2 e5 ff ff       	callq  405d50 <p126_typed_FID_36_100_105_114_101_99_116_46_102_108_>
  40777e:	4c 89 f1             	mov    %r14,%rcx
  407781:	4c 89 ee             	mov    %r13,%rsi
  407784:	48 89 df             	mov    %rbx,%rdi
  407787:	f3 0f 10 b5 1c ff ff ff 	movss  -0xe4(%rbp),%xmm6
  40778f:	f3 0f 10 4d a8       	movss  -0x58(%rbp),%xmm1
  407794:	f3 0f 10 45 a4       	movss  -0x5c(%rbp),%xmm0
  407799:	f3 0f 10 55 a0       	movss  -0x60(%rbp),%xmm2
  40779e:	f3 0f 10 6d e0       	movss  -0x20(%rbp),%xmm5
  4077a3:	f3 0f 10 65 dc       	movss  -0x24(%rbp),%xmm4
  4077a8:	f3 0f 10 5d d8       	movss  -0x28(%rbp),%xmm3
  4077ad:	66 48 0f 6e f8       	movq   %rax,%xmm7
  4077b2:	f3 0f 59 d7          	mulss  %xmm7,%xmm2
  4077b6:	f3 0f 58 d6          	addss  %xmm6,%xmm2
  4077ba:	f3 0f 11 55 ac       	movss  %xmm2,-0x54(%rbp)
  4077bf:	66 48 0f 7e d0       	movq   %xmm2,%rax
  4077c4:	89 c0                	mov    %eax,%eax
  4077c6:	48 89 45 80          	mov    %rax,-0x80(%rbp)
  4077ca:	41 b8 00 00 00 00    	mov    $0x0,%r8d
  4077d0:	49 89 cf             	mov    %rcx,%r15
  4077d3:	b9 28 6b 6e 4e       	mov    $0x4e6e6b28,%ecx
  4077d8:	ba 28 6b 6e 4e       	mov    $0x4e6e6b28,%edx
  4077dd:	49 89 f6             	mov    %rsi,%r14
  4077e0:	be 09 00 00 00       	mov    $0x9,%esi
  4077e5:	48 89 fb             	mov    %rdi,%rbx
  4077e8:	e8 13 f6 ff ff       	callq  406e00 <p126_typed_FID_36_100_105_114_101_99_116_46_110_101_97_114_101_115_116_46_116_>
  4077ed:	48 89 df             	mov    %rbx,%rdi
  4077f0:	48 89 c3             	mov    %rax,%rbx
  4077f3:	f3 0f 10 0d 45 98 02 00 	movss  0x29845(%rip),%xmm1        # 431040 <_IO_stdin_used+0x40>
  4077fb:	f3 0f 10 05 39 98 02 00 	movss  0x29839(%rip),%xmm0        # 43103c <_IO_stdin_used+0x3c>
  407803:	49 89 fd             	mov    %rdi,%r13
  407806:	e8 45 e5 ff ff       	callq  405d50 <p126_typed_FID_36_100_105_114_101_99_116_46_102_108_>
  40780b:	4c 89 ef             	mov    %r13,%rdi
  40780e:	48 89 45 d0          	mov    %rax,-0x30(%rbp)
  407812:	f3 0f 10 0d 1e 98 02 00 	movss  0x2981e(%rip),%xmm1        # 431038 <_IO_stdin_used+0x38>
  40781a:	f3 0f 10 05 12 98 02 00 	movss  0x29812(%rip),%xmm0        # 431034 <_IO_stdin_used+0x34>
  407822:	49 89 fd             	mov    %rdi,%r13
  407825:	e8 26 e5 ff ff       	callq  405d50 <p126_typed_FID_36_100_105_114_101_99_116_46_102_108_>
  40782a:	4c 89 f6             	mov    %r14,%rsi
  40782d:	4c 89 ef             	mov    %r13,%rdi
  407830:	49 89 c6             	mov    %rax,%r14
  407833:	4c 8b 6d d0          	mov    -0x30(%rbp),%r13
  407837:	f3 0f 10 4d bc       	movss  -0x44(%rbp),%xmm1
  40783c:	66 48 0f 6e c3       	movq   %rbx,%xmm0
  407841:	48 89 fb             	mov    %rdi,%rbx
  407844:	e8 97 eb ff ff       	callq  4063e0 <p126_typed_FID_36_100_105_114_101_99_116_46_115_104_97_100_101_>
  407849:	4c 89 f9             	mov    %r15,%rcx
  40784c:	4c 89 e6             	mov    %r12,%rsi
  40784f:	48 89 df             	mov    %rbx,%rdi
  407852:	48 8b 5d c8          	mov    -0x38(%rbp),%rbx
  407856:	4c 8b 65 c0          	mov    -0x40(%rbp),%r12
  40785a:	66 49 0f 6e c6       	movq   %r14,%xmm0
  40785f:	66 48 0f 6e c8       	movq   %rax,%xmm1
  407864:	f3 0f 59 c1          	mulss  %xmm1,%xmm0
  407868:	66 49 0f 6e cd       	movq   %r13,%xmm1
  40786d:	f3 0f 58 c8          	addss  %xmm0,%xmm1
  407871:	f3 0f 11 4d 94       	movss  %xmm1,-0x6c(%rbp)
  407876:	49 89 f6             	mov    %rsi,%r14
  407879:	48 89 ce             	mov    %rcx,%rsi
  40787c:	49 89 fd             	mov    %rdi,%r13
  40787f:	e8 6c ea ff ff       	callq  4062f0 <p113d_FID_36_100_105_114_101_99_116_46_115_107_114_>
  407884:	4c 89 f6             	mov    %r14,%rsi
  407887:	4c 89 ef             	mov    %r13,%rdi
  40788a:	49 89 c5             	mov    %rax,%r13
  40788d:	f3 0f 10 5d b8       	movss  -0x48(%rbp),%xmm3
  407892:	f3 0f 10 6d b4       	movss  -0x4c(%rbp),%xmm5
  407897:	f3 0f 10 75 b0       	movss  -0x50(%rbp),%xmm6
  40789c:	f3 0f 10 55 ac       	movss  -0x54(%rbp),%xmm2
  4078a1:	f3 0f 10 4d a8       	movss  -0x58(%rbp),%xmm1
  4078a6:	f3 0f 10 45 a4       	movss  -0x5c(%rbp),%xmm0
  4078ab:	f3 0f 10 e6          	movss  %xmm6,%xmm4
  4078af:	f3 0f 10 75 a0       	movss  -0x60(%rbp),%xmm6
  4078b4:	f3 44 0f 10 45 9c    	movss  -0x64(%rbp),%xmm8
  4078ba:	f3 44 0f 10 4d 98    	movss  -0x68(%rbp),%xmm9
  4078c0:	66 48 0f 7e d8       	movq   %xmm3,%rax
  4078c5:	89 c0                	mov    %eax,%eax
  4078c7:	66 48 0f 6e d8       	movq   %rax,%xmm3
  4078cc:	f3 41 0f 10 f9       	movss  %xmm9,%xmm7
  4078d1:	f3 0f 59 fb          	mulss  %xmm3,%xmm7
  4078d5:	66 48 0f 7e e8       	movq   %xmm5,%rax
  4078da:	89 c0                	mov    %eax,%eax
  4078dc:	66 48 0f 6e e8       	movq   %rax,%xmm5
  4078e1:	f3 45 0f 10 d0       	movss  %xmm8,%xmm10
  4078e6:	f3 44 0f 59 d5       	mulss  %xmm5,%xmm10
  4078eb:	f3 41 0f 58 fa       	addss  %xmm10,%xmm7
  4078f0:	66 48 0f 7e e0       	movq   %xmm4,%rax
  4078f5:	89 c0                	mov    %eax,%eax
  4078f7:	66 48 0f 6e e0       	movq   %rax,%xmm4
  4078fc:	f3 44 0f 10 d6       	movss  %xmm6,%xmm10
  407901:	f3 44 0f 59 d4       	mulss  %xmm4,%xmm10
  407906:	f3 41 0f 58 fa       	addss  %xmm10,%xmm7
  40790b:	f3 0f 59 3d 35 97 02 00 	mulss  0x29735(%rip),%xmm7        # 431048 <_IO_stdin_used+0x48>
  407913:	f3 44 0f 59 cf       	mulss  %xmm7,%xmm9
  407918:	f3 41 0f 5c d9       	subss  %xmm9,%xmm3
  40791d:	f3 0f 11 5d 88       	movss  %xmm3,-0x78(%rbp)
  407922:	f3 44 0f 59 c7       	mulss  %xmm7,%xmm8
  407927:	f3 41 0f 5c e8       	subss  %xmm8,%xmm5
  40792c:	f3 0f 11 6d 8c       	movss  %xmm5,-0x74(%rbp)
  407931:	f3 0f 59 f7          	mulss  %xmm7,%xmm6
  407935:	0f 57 35 d4 96 02 00 	xorps  0x296d4(%rip),%xmm6        # 431010 <_IO_stdin_used+0x10>
  40793c:	f3 0f 58 f4          	addss  %xmm4,%xmm6
  407940:	f3 0f 11 75 90       	movss  %xmm6,-0x70(%rbp)
  407945:	48 83 ec 10          	sub    $0x10,%rsp
  407949:	48 89 e0             	mov    %rsp,%rax
  40794c:	48 c7 40 08 00 00 00 00 	movq   $0x0,0x8(%rax)
  407954:	48 c7 00 09 00 00 00 	movq   $0x9,(%rax)
  40795b:	41 b9 28 6b 6e 4e    	mov    $0x4e6e6b28,%r9d
  407961:	41 b8 09 00 00 00    	mov    $0x9,%r8d
  407967:	b9 28 6b 6e 4e       	mov    $0x4e6e6b28,%ecx
  40796c:	f3 0f 10 e5          	movss  %xmm5,%xmm4
  407970:	f3 0f 10 ee          	movss  %xmm6,%xmm5
  407974:	ba 09 00 00 00       	mov    $0x9,%edx
  407979:	49 89 f7             	mov    %rsi,%r15
  40797c:	48 8d b5 d0 fe ff ff 	lea    -0x130(%rbp),%rsi
  407983:	49 89 fe             	mov    %rdi,%r14
  407986:	e8 75 ee ff ff       	callq  406800 <p126_typed_FID_36_112_114_111_100_117_99_116_46_110_101_97_114_101_115_116_>
  40798b:	4c 89 fe             	mov    %r15,%rsi
  40798e:	4c 89 f7             	mov    %r14,%rdi
  407991:	48 8b 45 80          	mov    -0x80(%rbp),%rax
  407995:	f3 0f 10 9d 14 ff ff ff 	movss  -0xec(%rbp),%xmm3
  40799d:	f3 0f 10 85 10 ff ff ff 	movss  -0xf0(%rbp),%xmm0
  4079a5:	f3 0f 10 75 90       	movss  -0x70(%rbp),%xmm6
  4079aa:	f3 0f 10 6d 8c       	movss  -0x74(%rbp),%xmm5
  4079af:	f3 0f 10 65 88       	movss  -0x78(%rbp),%xmm4
  4079b4:	f3 0f 10 4d 94       	movss  -0x6c(%rbp),%xmm1
  4079b9:	48 83 ec f0          	sub    $0xfffffffffffffff0,%rsp
  4079bd:	48 8b 95 d0 fe ff ff 	mov    -0x130(%rbp),%rdx
  4079c4:	4c 8b 8d d8 fe ff ff 	mov    -0x128(%rbp),%r9
  4079cb:	48 8b 8d e0 fe ff ff 	mov    -0x120(%rbp),%rcx
  4079d2:	f3 0f 10 d1          	movss  %xmm1,%xmm2
  4079d6:	f3 0f 59 d0          	mulss  %xmm0,%xmm2
  4079da:	66 49 0f 6e cd       	movq   %r13,%xmm1
  4079df:	f3 0f 10 3d 39 96 02 00 	movss  0x29639(%rip),%xmm7        # 431020 <_IO_stdin_used+0x20>
  4079e7:	f3 0f 5c f9          	subss  %xmm1,%xmm7
  4079eb:	f3 0f 59 d7          	mulss  %xmm7,%xmm2
  4079ef:	f3 0f 58 d3          	addss  %xmm3,%xmm2
  4079f3:	66 49 0f 7e d0       	movq   %xmm2,%r8
  4079f8:	45 89 c0             	mov    %r8d,%r8d
  4079fb:	f3 0f 10 f8          	movss  %xmm0,%xmm7
  4079ff:	f3 0f 59 f9          	mulss  %xmm1,%xmm7
  407a03:	66 49 0f 6e c1       	movq   %r9,%xmm0
  407a08:	66 49 0f 6e cc       	movq   %r12,%xmm1
  407a0d:	66 48 0f 6e d3       	movq   %rbx,%xmm2
  407a12:	66 48 0f 6e d8       	movq   %rax,%xmm3
  407a17:	48 83 ee 01          	sub    $0x1,%rsi
  407a1b:	f3 44 0f 10 f9       	movss  %xmm1,%xmm15
  407a20:	f3 0f 10 ca          	movss  %xmm2,%xmm1
  407a24:	f3 41 0f 10 d7       	movss  %xmm15,%xmm2
  407a29:	f3 44 0f 10 f8       	movss  %xmm0,%xmm15
  407a2e:	f3 0f 10 c1          	movss  %xmm1,%xmm0
  407a32:	f3 41 0f 10 cf       	movss  %xmm15,%xmm1
  407a37:	e9 f4 f9 ff ff       	jmpq   407430 <p126_typed_FID_36_112_114_111_100_117_99_116_46_116_114_97_99_101_+0x80>
  407a3c:	be 04 00 00 00       	mov    $0x4,%esi
  407a41:	e8 5a 35 02 00       	callq  42afa0 <p111_rt_fail>
  407a46:	b8 00 00 00 00       	mov    $0x0,%eax
  407a4b:	e9 56 05 00 00       	jmpq   407fa6 <p126_typed_FID_36_112_114_111_100_117_99_116_46_116_114_97_99_101_+0xbf6>
  407a50:	4c 89 c0             	mov    %r8,%rax
  407a53:	e9 4e 05 00 00       	jmpq   407fa6 <p126_typed_FID_36_112_114_111_100_117_99_116_46_116_114_97_99_101_+0xbf6>
  407a58:	4c 8b a5 78 ff ff ff 	mov    -0x88(%rbp),%r12
  407a5f:	4c 8b ad 70 ff ff ff 	mov    -0x90(%rbp),%r13
  407a66:	4c 8b bd 68 ff ff ff 	mov    -0x98(%rbp),%r15
  407a6d:	4c 89 f3             	mov    %r14,%rbx
  407a70:	89 d6                	mov    %edx,%esi
  407a72:	48 8b 95 60 ff ff ff 	mov    -0xa0(%rbp),%rdx
  407a79:	49 90                	xchg   %rax,%r8
  407a7b:	49 87 c8             	xchg   %rcx,%r8
  407a7e:	f2 0f 10 45 f8       	movsd  -0x8(%rbp),%xmm0
  407a83:	f3 0f 10 4d e4       	movss  -0x1c(%rbp),%xmm1
  407a88:	44 09 c6             	or     %r8d,%esi
  407a8b:	0f 85 15 05 00 00    	jne    407fa6 <p126_typed_FID_36_112_114_111_100_117_99_116_46_116_114_97_99_101_+0xbf6>
  407a91:	89 c8                	mov    %ecx,%eax
  407a93:	83 f0 01             	xor    $0x1,%eax
  407a96:	75 14                	jne    407aac <p126_typed_FID_36_112_114_111_100_117_99_116_46_116_114_97_99_101_+0x6fc>
  407a98:	be 04 00 00 00       	mov    $0x4,%esi
  407a9d:	e8 fe 34 02 00       	callq  42afa0 <p111_rt_fail>
  407aa2:	b8 00 00 00 00       	mov    $0x0,%eax
  407aa7:	e9 fa 04 00 00       	jmpq   407fa6 <p126_typed_FID_36_112_114_111_100_117_99_116_46_116_114_97_99_101_+0xbf6>
  407aac:	48 83 fb 00          	cmp    $0x0,%rbx
  407ab0:	0f 94 c0             	sete   %al
  407ab3:	0f b6 c0             	movzbl %al,%eax
  407ab6:	49 89 db             	mov    %rbx,%r11
  407ab9:	49 83 eb 01          	sub    $0x1,%r11
  407abd:	49 89 da             	mov    %rbx,%r10
  407ac0:	49 83 ea 02          	sub    $0x2,%r10
  407ac4:	49 89 d9             	mov    %rbx,%r9
  407ac7:	49 83 e9 03          	sub    $0x3,%r9
  407acb:	49 89 d8             	mov    %rbx,%r8
  407ace:	49 83 e8 04          	sub    $0x4,%r8
  407ad2:	49 89 fe             	mov    %rdi,%r14
  407ad5:	48 89 df             	mov    %rbx,%rdi
  407ad8:	48 83 ef 05          	sub    $0x5,%rdi
  407adc:	48 89 de             	mov    %rbx,%rsi
  407adf:	48 83 ee 06          	sub    $0x6,%rsi
  407ae3:	48 89 d9             	mov    %rbx,%rcx
  407ae6:	48 83 e9 07          	sub    $0x7,%rcx
  407aea:	83 f8 00             	cmp    $0x0,%eax
  407aed:	75 62                	jne    407b51 <p126_typed_FID_36_112_114_111_100_117_99_116_46_116_114_97_99_101_+0x7a1>
  407aef:	49 83 fb 00          	cmp    $0x0,%r11
  407af3:	74 55                	je     407b4a <p126_typed_FID_36_112_114_111_100_117_99_116_46_116_114_97_99_101_+0x79a>
  407af5:	49 83 fa 00          	cmp    $0x0,%r10
  407af9:	74 48                	je     407b43 <p126_typed_FID_36_112_114_111_100_117_99_116_46_116_114_97_99_101_+0x793>
  407afb:	0f 1f 44 00 00       	nopl   0x0(%rax,%rax,1)
  407b00:	49 83 f9 00          	cmp    $0x0,%r9
  407b04:	74 36                	je     407b3c <p126_typed_FID_36_112_114_111_100_117_99_116_46_116_114_97_99_101_+0x78c>
  407b06:	49 83 f8 00          	cmp    $0x0,%r8
  407b0a:	74 29                	je     407b35 <p126_typed_FID_36_112_114_111_100_117_99_116_46_116_114_97_99_101_+0x785>
  407b0c:	48 83 ff 00          	cmp    $0x0,%rdi
  407b10:	74 1c                	je     407b2e <p126_typed_FID_36_112_114_111_100_117_99_116_46_116_114_97_99_101_+0x77e>
  407b12:	48 83 fe 00          	cmp    $0x0,%rsi
  407b16:	74 0f                	je     407b27 <p126_typed_FID_36_112_114_111_100_117_99_116_46_116_114_97_99_101_+0x777>
  407b18:	48 83 f9 00          	cmp    $0x0,%rcx
  407b1c:	b8 00 00 80 3f       	mov    $0x3f800000,%eax
  407b21:	49 0f 45 c4          	cmovne %r12,%rax
  407b25:	eb 2f                	jmp    407b56 <p126_typed_FID_36_112_114_111_100_117_99_116_46_116_114_97_99_101_+0x7a6>
  407b27:	b8 9a 99 99 3f       	mov    $0x3f99999a,%eax
  407b2c:	eb 28                	jmp    407b56 <p126_typed_FID_36_112_114_111_100_117_99_116_46_116_114_97_99_101_+0x7a6>
  407b2e:	b8 cd cc cc 3e       	mov    $0x3ecccccd,%eax
  407b33:	eb 21                	jmp    407b56 <p126_typed_FID_36_112_114_111_100_117_99_116_46_116_114_97_99_101_+0x7a6>
  407b35:	b8 cd cc cc 3e       	mov    $0x3ecccccd,%eax
  407b3a:	eb 1a                	jmp    407b56 <p126_typed_FID_36_112_114_111_100_117_99_116_46_116_114_97_99_101_+0x7a6>
  407b3c:	b8 00 00 80 3f       	mov    $0x3f800000,%eax
  407b41:	eb 13                	jmp    407b56 <p126_typed_FID_36_112_114_111_100_117_99_116_46_116_114_97_99_101_+0x7a6>
  407b43:	b8 00 00 80 3f       	mov    $0x3f800000,%eax
  407b48:	eb 0c                	jmp    407b56 <p126_typed_FID_36_112_114_111_100_117_99_116_46_116_114_97_99_101_+0x7a6>
  407b4a:	b8 00 00 80 3f       	mov    $0x3f800000,%eax
  407b4f:	eb 05                	jmp    407b56 <p126_typed_FID_36_112_114_111_100_117_99_116_46_116_114_97_99_101_+0x7a6>
  407b51:	b8 00 40 1c 46       	mov    $0x461c4000,%eax
  407b56:	48 83 fb 00          	cmp    $0x0,%rbx
  407b5a:	74 6d                	je     407bc9 <p126_typed_FID_36_112_114_111_100_117_99_116_46_116_114_97_99_101_+0x819>
  407b5c:	0f 1f 40 00          	nopl   0x0(%rax)
  407b60:	49 83 fb 00          	cmp    $0x0,%r11
  407b64:	74 58                	je     407bbe <p126_typed_FID_36_112_114_111_100_117_99_116_46_116_114_97_99_101_+0x80e>
  407b66:	49 83 fa 00          	cmp    $0x0,%r10
  407b6a:	74 4a                	je     407bb6 <p126_typed_FID_36_112_114_111_100_117_99_116_46_116_114_97_99_101_+0x806>
  407b6c:	49 83 f9 00          	cmp    $0x0,%r9
  407b70:	74 3c                	je     407bae <p126_typed_FID_36_112_114_111_100_117_99_116_46_116_114_97_99_101_+0x7fe>
  407b72:	49 83 f8 00          	cmp    $0x0,%r8
  407b76:	74 2e                	je     407ba6 <p126_typed_FID_36_112_114_111_100_117_99_116_46_116_114_97_99_101_+0x7f6>
  407b78:	48 83 ff 00          	cmp    $0x0,%rdi
  407b7c:	74 20                	je     407b9e <p126_typed_FID_36_112_114_111_100_117_99_116_46_116_114_97_99_101_+0x7ee>
  407b7e:	66 90                	xchg   %ax,%ax
  407b80:	48 83 fe 00          	cmp    $0x0,%rsi
  407b84:	74 10                	je     407b96 <p126_typed_FID_36_112_114_111_100_117_99_116_46_116_114_97_99_101_+0x7e6>
  407b86:	48 83 f9 00          	cmp    $0x0,%rcx
  407b8a:	41 bc 00 00 60 40    	mov    $0x40600000,%r12d
  407b90:	4d 0f 45 e5          	cmovne %r13,%r12
  407b94:	eb 2e                	jmp    407bc4 <p126_typed_FID_36_112_114_111_100_117_99_116_46_116_114_97_99_101_+0x814>
  407b96:	41 bc 00 00 00 00    	mov    $0x0,%r12d
  407b9c:	eb 26                	jmp    407bc4 <p126_typed_FID_36_112_114_111_100_117_99_116_46_116_114_97_99_101_+0x814>
  407b9e:	41 bc 00 00 80 bf    	mov    $0xbf800000,%r12d
  407ba4:	eb 1e                	jmp    407bc4 <p126_typed_FID_36_112_114_111_100_117_99_116_46_116_114_97_99_101_+0x814>
  407ba6:	41 bc 00 00 80 3f    	mov    $0x3f800000,%r12d
  407bac:	eb 16                	jmp    407bc4 <p126_typed_FID_36_112_114_111_100_117_99_116_46_116_114_97_99_101_+0x814>
  407bae:	41 bc 00 00 00 c0    	mov    $0xc0000000,%r12d
  407bb4:	eb 0e                	jmp    407bc4 <p126_typed_FID_36_112_114_111_100_117_99_116_46_116_114_97_99_101_+0x814>
  407bb6:	41 bc 00 00 00 40    	mov    $0x40000000,%r12d
  407bbc:	eb 06                	jmp    407bc4 <p126_typed_FID_36_112_114_111_100_117_99_116_46_116_114_97_99_101_+0x814>
  407bbe:	41 bc 00 00 00 00    	mov    $0x0,%r12d
  407bc4:	4d 89 e5             	mov    %r12,%r13
  407bc7:	eb 06                	jmp    407bcf <p126_typed_FID_36_112_114_111_100_117_99_116_46_116_114_97_99_101_+0x81f>
  407bc9:	41 bd 00 00 00 00    	mov    $0x0,%r13d
  407bcf:	48 83 fb 00          	cmp    $0x0,%rbx
  407bd3:	74 69                	je     407c3e <p126_typed_FID_36_112_114_111_100_117_99_116_46_116_114_97_99_101_+0x88e>
  407bd5:	49 83 fb 00          	cmp    $0x0,%r11
  407bd9:	74 5b                	je     407c36 <p126_typed_FID_36_112_114_111_100_117_99_116_46_116_114_97_99_101_+0x886>
  407bdb:	0f 1f 44 00 00       	nopl   0x0(%rax,%rax,1)
  407be0:	49 83 fa 00          	cmp    $0x0,%r10
  407be4:	74 48                	je     407c2e <p126_typed_FID_36_112_114_111_100_117_99_116_46_116_114_97_99_101_+0x87e>
  407be6:	49 83 f9 00          	cmp    $0x0,%r9
  407bea:	74 3a                	je     407c26 <p126_typed_FID_36_112_114_111_100_117_99_116_46_116_114_97_99_101_+0x876>
  407bec:	49 83 f8 00          	cmp    $0x0,%r8
  407bf0:	74 2c                	je     407c1e <p126_typed_FID_36_112_114_111_100_117_99_116_46_116_114_97_99_101_+0x86e>
  407bf2:	48 83 ff 00          	cmp    $0x0,%rdi
  407bf6:	74 1e                	je     407c16 <p126_typed_FID_36_112_114_111_100_117_99_116_46_116_114_97_99_101_+0x866>
  407bf8:	48 83 fe 00          	cmp    $0x0,%rsi
  407bfc:	74 10                	je     407c0e <p126_typed_FID_36_112_114_111_100_117_99_116_46_116_114_97_99_101_+0x85e>
  407bfe:	48 83 f9 00          	cmp    $0x0,%rcx
  407c02:	41 bc cd cc 4c 3e    	mov    $0x3e4ccccd,%r12d
  407c08:	4d 0f 45 e7          	cmovne %r15,%r12
  407c0c:	eb 36                	jmp    407c44 <p126_typed_FID_36_112_114_111_100_117_99_116_46_116_114_97_99_101_+0x894>
  407c0e:	41 bc cd cc cc 3f    	mov    $0x3fcccccd,%r12d
  407c14:	eb 2e                	jmp    407c44 <p126_typed_FID_36_112_114_111_100_117_99_116_46_116_114_97_99_101_+0x894>
  407c16:	41 bc 9a 99 19 bf    	mov    $0xbf19999a,%r12d
  407c1c:	eb 26                	jmp    407c44 <p126_typed_FID_36_112_114_111_100_117_99_116_46_116_114_97_99_101_+0x894>
  407c1e:	41 bc 9a 99 19 bf    	mov    $0xbf19999a,%r12d
  407c24:	eb 1e                	jmp    407c44 <p126_typed_FID_36_112_114_111_100_117_99_116_46_116_114_97_99_101_+0x894>
  407c26:	41 bc 00 00 00 3f    	mov    $0x3f000000,%r12d
  407c2c:	eb 16                	jmp    407c44 <p126_typed_FID_36_112_114_111_100_117_99_116_46_116_114_97_99_101_+0x894>
  407c2e:	41 bc 00 00 00 3f    	mov    $0x3f000000,%r12d
  407c34:	eb 0e                	jmp    407c44 <p126_typed_FID_36_112_114_111_100_117_99_116_46_116_114_97_99_101_+0x894>
  407c36:	41 bc 00 00 00 00    	mov    $0x0,%r12d
  407c3c:	eb 06                	jmp    407c44 <p126_typed_FID_36_112_114_111_100_117_99_116_46_116_114_97_99_101_+0x894>
  407c3e:	41 bc 00 44 1c c6    	mov    $0xc61c4400,%r12d
  407c44:	48 83 fb 00          	cmp    $0x0,%rbx
  407c48:	74 62                	je     407cac <p126_typed_FID_36_112_114_111_100_117_99_116_46_116_114_97_99_101_+0x8fc>
  407c4a:	49 83 fb 00          	cmp    $0x0,%r11
  407c4e:	74 55                	je     407ca5 <p126_typed_FID_36_112_114_111_100_117_99_116_46_116_114_97_99_101_+0x8f5>
  407c50:	49 83 fa 00          	cmp    $0x0,%r10
  407c54:	74 48                	je     407c9e <p126_typed_FID_36_112_114_111_100_117_99_116_46_116_114_97_99_101_+0x8ee>
  407c56:	49 83 f9 00          	cmp    $0x0,%r9
  407c5a:	74 3b                	je     407c97 <p126_typed_FID_36_112_114_111_100_117_99_116_46_116_114_97_99_101_+0x8e7>
  407c5c:	0f 1f 40 00          	nopl   0x0(%rax)
  407c60:	49 83 f8 00          	cmp    $0x0,%r8
  407c64:	74 2a                	je     407c90 <p126_typed_FID_36_112_114_111_100_117_99_116_46_116_114_97_99_101_+0x8e0>
  407c66:	48 83 ff 00          	cmp    $0x0,%rdi
  407c6a:	74 1d                	je     407c89 <p126_typed_FID_36_112_114_111_100_117_99_116_46_116_114_97_99_101_+0x8d9>
  407c6c:	48 83 fe 00          	cmp    $0x0,%rsi
  407c70:	74 10                	je     407c82 <p126_typed_FID_36_112_114_111_100_117_99_116_46_116_114_97_99_101_+0x8d2>
  407c72:	2e 48 83 f9 00       	cs cmp $0x0,%rcx
  407c77:	b9 00 00 00 41       	mov    $0x41000000,%ecx
  407c7c:	48 0f 45 ca          	cmovne %rdx,%rcx
  407c80:	eb 2f                	jmp    407cb1 <p126_typed_FID_36_112_114_111_100_117_99_116_46_116_114_97_99_101_+0x901>
  407c82:	b9 00 00 e0 40       	mov    $0x40e00000,%ecx
  407c87:	eb 28                	jmp    407cb1 <p126_typed_FID_36_112_114_111_100_117_99_116_46_116_114_97_99_101_+0x901>
  407c89:	b9 00 00 60 40       	mov    $0x40600000,%ecx
  407c8e:	eb 21                	jmp    407cb1 <p126_typed_FID_36_112_114_111_100_117_99_116_46_116_114_97_99_101_+0x901>
  407c90:	b9 00 00 60 40       	mov    $0x40600000,%ecx
  407c95:	eb 1a                	jmp    407cb1 <p126_typed_FID_36_112_114_111_100_117_99_116_46_116_114_97_99_101_+0x901>
  407c97:	b9 00 00 c0 40       	mov    $0x40c00000,%ecx
  407c9c:	eb 13                	jmp    407cb1 <p126_typed_FID_36_112_114_111_100_117_99_116_46_116_114_97_99_101_+0x901>
  407c9e:	b9 00 00 c0 40       	mov    $0x40c00000,%ecx
  407ca3:	eb 0c                	jmp    407cb1 <p126_typed_FID_36_112_114_111_100_117_99_116_46_116_114_97_99_101_+0x901>
  407ca5:	b9 00 00 a0 40       	mov    $0x40a00000,%ecx
  407caa:	eb 05                	jmp    407cb1 <p126_typed_FID_36_112_114_111_100_117_99_116_46_116_114_97_99_101_+0x901>
  407cac:	b9 00 00 a0 40       	mov    $0x40a00000,%ecx
  407cb1:	66 48 0f 6e d1       	movq   %rcx,%xmm2
  407cb6:	f3 0f 5c ca          	subss  %xmm2,%xmm1
  407cba:	66 48 0f 6e f0       	movq   %rax,%xmm6
  407cbf:	f3 0f 11 b5 5c ff ff ff 	movss  %xmm6,-0xa4(%rbp)
  407cc7:	f3 0f 5e ce          	divss  %xmm6,%xmm1
  407ccb:	66 48 0f 7e c8       	movq   %xmm1,%rax
  407cd0:	89 c3                	mov    %eax,%ebx
  407cd2:	e8 e9 a7 ff ff       	callq  4024c0 <sqrt@plt>
  407cd7:	4c 89 f7             	mov    %r14,%rdi
  407cda:	f2 0f 10 e8          	movsd  %xmm0,%xmm5
  407cde:	f3 0f 10 8d 40 ff ff ff 	movss  -0xc0(%rbp),%xmm1
  407ce6:	f3 0f 10 bd 58 ff ff ff 	movss  -0xa8(%rbp),%xmm7
  407cee:	f3 0f 10 a5 54 ff ff ff 	movss  -0xac(%rbp),%xmm4
  407cf6:	f3 0f 10 95 50 ff ff ff 	movss  -0xb0(%rbp),%xmm2
  407cfe:	f3 0f 10 9d 4c ff ff ff 	movss  -0xb4(%rbp),%xmm3
  407d06:	f3 0f 10 85 48 ff ff ff 	movss  -0xb8(%rbp),%xmm0
  407d0e:	f3 0f 10 b5 5c ff ff ff 	movss  -0xa4(%rbp),%xmm6
  407d16:	f2 0f 5a ed          	cvtsd2ss %xmm5,%xmm5
  407d1a:	f3 0f 11 ad 18 ff ff ff 	movss  %xmm5,-0xe8(%rbp)
  407d22:	f3 0f 5e d5          	divss  %xmm5,%xmm2
  407d26:	f3 0f 11 95 20 ff ff ff 	movss  %xmm2,-0xe0(%rbp)
  407d2e:	f3 0f 5e e5          	divss  %xmm5,%xmm4
  407d32:	f3 0f 11 a5 28 ff ff ff 	movss  %xmm4,-0xd8(%rbp)
  407d3a:	f3 44 0f 10 fd       	movss  %xmm5,%xmm15
  407d3f:	f3 0f 10 ef          	movss  %xmm7,%xmm5
  407d43:	f3 41 0f 5e ef       	divss  %xmm15,%xmm5
  407d48:	f3 0f 11 ad 2c ff ff ff 	movss  %xmm5,-0xd4(%rbp)
  407d50:	66 49 0f 6e fd       	movq   %r13,%xmm7
  407d55:	f3 0f 5c c7          	subss  %xmm7,%xmm0
  407d59:	f3 0f 5e c6          	divss  %xmm6,%xmm0
  407d5d:	66 48 0f 7e c0       	movq   %xmm0,%rax
  407d62:	89 c0                	mov    %eax,%eax
  407d64:	66 48 0f 6e c0       	movq   %rax,%xmm0
  407d69:	f3 0f 11 85 44 ff ff ff 	movss  %xmm0,-0xbc(%rbp)
  407d71:	f3 0f 59 d0          	mulss  %xmm0,%xmm2
  407d75:	66 49 0f 6e fc       	movq   %r12,%xmm7
  407d7a:	f3 0f 5c df          	subss  %xmm7,%xmm3
  407d7e:	f3 0f 5e de          	divss  %xmm6,%xmm3
  407d82:	66 48 0f 7e d8       	movq   %xmm3,%rax
  407d87:	89 c0                	mov    %eax,%eax
  407d89:	66 48 0f 6e d8       	movq   %rax,%xmm3
  407d8e:	f3 0f 11 9d 3c ff ff ff 	movss  %xmm3,-0xc4(%rbp)
  407d96:	f3 0f 59 dc          	mulss  %xmm4,%xmm3
  407d9a:	f3 0f 58 d3          	addss  %xmm3,%xmm2
  407d9e:	66 48 0f 6e db       	movq   %rbx,%xmm3
  407da3:	f3 0f 11 9d 24 ff ff ff 	movss  %xmm3,-0xdc(%rbp)
  407dab:	f3 0f 59 dd          	mulss  %xmm5,%xmm3
  407daf:	f3 0f 58 d3          	addss  %xmm3,%xmm2
  407db3:	f3 0f 10 1d 69 92 02 00 	movss  0x29269(%rip),%xmm3        # 431024 <_IO_stdin_used+0x24>
  407dbb:	0f 2e da             	ucomiss %xmm2,%xmm3
  407dbe:	0f 97 c0             	seta   %al
  407dc1:	0f b6 c0             	movzbl %al,%eax
  407dc4:	89 c1                	mov    %eax,%ecx
  407dc6:	48 83 f9 01          	cmp    $0x1,%rcx
  407dca:	0f 94 c0             	sete   %al
  407dcd:	0f b6 c0             	movzbl %al,%eax
  407dd0:	48 c1 e9 28          	shr    $0x28,%rcx
  407dd4:	48 81 e1 ff ff 7f 00 	and    $0x7fffff,%rcx
  407ddb:	48 81 f9 02 00 01 00 	cmp    $0x10002,%rcx
  407de2:	0f 94 c1             	sete   %cl
  407de5:	0f b6 c9             	movzbl %cl,%ecx
  407de8:	09 c8                	or     %ecx,%eax
  407dea:	75 36                	jne    407e22 <p126_typed_FID_36_112_114_111_100_117_99_116_46_116_114_97_99_101_+0xa72>
  407dec:	83 f0 01             	xor    $0x1,%eax
  407def:	75 27                	jne    407e18 <p126_typed_FID_36_112_114_111_100_117_99_116_46_116_114_97_99_101_+0xa68>
  407df1:	be 04 00 00 00       	mov    $0x4,%esi
  407df6:	48 89 fb             	mov    %rdi,%rbx
  407df9:	e8 a2 31 02 00       	callq  42afa0 <p111_rt_fail>
  407dfe:	48 89 df             	mov    %rbx,%rdi
  407e01:	f3 0f 10 8d 40 ff ff ff 	movss  -0xc0(%rbp),%xmm1
  407e09:	f3 0f 10 85 44 ff ff ff 	movss  -0xbc(%rbp),%xmm0
  407e11:	be 00 00 00 00       	mov    $0x0,%esi
  407e16:	eb 0f                	jmp    407e27 <p126_typed_FID_36_112_114_111_100_117_99_116_46_116_114_97_99_101_+0xa77>
  407e18:	2e 66 48 0f 7e d0    	cs movq %xmm2,%rax
  407e1e:	89 c6                	mov    %eax,%esi
  407e20:	eb 05                	jmp    407e27 <p126_typed_FID_36_112_114_111_100_117_99_116_46_116_114_97_99_101_+0xa77>
  407e22:	be 00 00 00 00       	mov    $0x0,%esi
  407e27:	49 89 f4             	mov    %rsi,%r12
  407e2a:	f3 0f 59 05 f6 91 02 00 	mulss  0x291f6(%rip),%xmm0        # 431028 <_IO_stdin_used+0x28>
  407e32:	f3 0f 58 c1          	addss  %xmm1,%xmm0
  407e36:	f3 0f 11 85 30 ff ff ff 	movss  %xmm0,-0xd0(%rbp)
  407e3e:	f3 0f 10 0d fe 91 02 00 	movss  0x291fe(%rip),%xmm1        # 431044 <_IO_stdin_used+0x44>
  407e46:	f3 0f 10 05 ee 91 02 00 	movss  0x291ee(%rip),%xmm0        # 43103c <_IO_stdin_used+0x3c>
  407e4e:	48 89 fb             	mov    %rdi,%rbx
  407e51:	e8 fa de ff ff       	callq  405d50 <p126_typed_FID_36_100_105_114_101_99_116_46_102_108_>
  407e56:	48 89 df             	mov    %rbx,%rdi
  407e59:	f3 0f 10 8d 38 ff ff ff 	movss  -0xc8(%rbp),%xmm1
  407e61:	f3 0f 10 85 3c ff ff ff 	movss  -0xc4(%rbp),%xmm0
  407e69:	66 48 0f 6e d0       	movq   %rax,%xmm2
  407e6e:	f3 0f 59 c2          	mulss  %xmm2,%xmm0
  407e72:	f3 0f 58 c8          	addss  %xmm0,%xmm1
  407e76:	f3 0f 11 8d 34 ff ff ff 	movss  %xmm1,-0xcc(%rbp)
  407e7e:	f3 0f 10 0d be 91 02 00 	movss  0x291be(%rip),%xmm1        # 431044 <_IO_stdin_used+0x44>
  407e86:	f3 0f 10 05 ae 91 02 00 	movss  0x291ae(%rip),%xmm0        # 43103c <_IO_stdin_used+0x3c>
  407e8e:	48 89 fb             	mov    %rdi,%rbx
  407e91:	e8 ba de ff ff       	callq  405d50 <p126_typed_FID_36_100_105_114_101_99_116_46_102_108_>
  407e96:	4c 89 e6             	mov    %r12,%rsi
  407e99:	48 89 df             	mov    %rbx,%rdi
  407e9c:	f3 0f 10 ad 2c ff ff ff 	movss  -0xd4(%rbp),%xmm5
  407ea4:	f3 0f 10 a5 28 ff ff ff 	movss  -0xd8(%rbp),%xmm4
  407eac:	f3 0f 10 b5 1c ff ff ff 	movss  -0xe4(%rbp),%xmm6
  407eb4:	f3 0f 10 8d 34 ff ff ff 	movss  -0xcc(%rbp),%xmm1
  407ebc:	f3 0f 10 85 30 ff ff ff 	movss  -0xd0(%rbp),%xmm0
  407ec4:	f3 0f 10 95 24 ff ff ff 	movss  -0xdc(%rbp),%xmm2
  407ecc:	f3 0f 10 9d 20 ff ff ff 	movss  -0xe0(%rbp),%xmm3
  407ed4:	66 48 0f 6e f8       	movq   %rax,%xmm7
  407ed9:	f3 0f 59 d7          	mulss  %xmm7,%xmm2
  407edd:	f3 0f 58 d6          	addss  %xmm6,%xmm2
  407ee1:	66 48 0f 7e d8       	movq   %xmm3,%rax
  407ee6:	89 c0                	mov    %eax,%eax
  407ee8:	66 48 0f 6e d8       	movq   %rax,%xmm3
  407eed:	41 b8 00 00 00 00    	mov    $0x0,%r8d
  407ef3:	b9 28 6b 6e 4e       	mov    $0x4e6e6b28,%ecx
  407ef8:	ba 28 6b 6e 4e       	mov    $0x4e6e6b28,%edx
  407efd:	49 89 f6             	mov    %rsi,%r14
  407f00:	be 09 00 00 00       	mov    $0x9,%esi
  407f05:	48 89 fb             	mov    %rdi,%rbx
  407f08:	e8 f3 ee ff ff       	callq  406e00 <p126_typed_FID_36_100_105_114_101_99_116_46_110_101_97_114_101_115_116_46_116_>
  407f0d:	48 89 df             	mov    %rbx,%rdi
  407f10:	49 89 c5             	mov    %rax,%r13
  407f13:	f3 0f 10 0d 25 91 02 00 	movss  0x29125(%rip),%xmm1        # 431040 <_IO_stdin_used+0x40>
  407f1b:	f3 0f 10 05 19 91 02 00 	movss  0x29119(%rip),%xmm0        # 43103c <_IO_stdin_used+0x3c>
  407f23:	48 89 fb             	mov    %rdi,%rbx
  407f26:	e8 25 de ff ff       	callq  405d50 <p126_typed_FID_36_100_105_114_101_99_116_46_102_108_>
  407f2b:	48 89 df             	mov    %rbx,%rdi
  407f2e:	48 89 c3             	mov    %rax,%rbx
  407f31:	f3 0f 10 0d ff 90 02 00 	movss  0x290ff(%rip),%xmm1        # 431038 <_IO_stdin_used+0x38>
  407f39:	f3 0f 10 05 f3 90 02 00 	movss  0x290f3(%rip),%xmm0        # 431034 <_IO_stdin_used+0x34>
  407f41:	49 89 fc             	mov    %rdi,%r12
  407f44:	e8 07 de ff ff       	callq  405d50 <p126_typed_FID_36_100_105_114_101_99_116_46_102_108_>
  407f49:	4c 89 f6             	mov    %r14,%rsi
  407f4c:	4c 89 e7             	mov    %r12,%rdi
  407f4f:	49 89 c4             	mov    %rax,%r12
  407f52:	f3 0f 10 8d 18 ff ff ff 	movss  -0xe8(%rbp),%xmm1
  407f5a:	66 49 0f 6e c5       	movq   %r13,%xmm0
  407f5f:	66 48 0f 7e c8       	movq   %xmm1,%rax
  407f64:	89 c0                	mov    %eax,%eax
  407f66:	66 48 0f 6e c8       	movq   %rax,%xmm1
  407f6b:	e8 70 e4 ff ff       	callq  4063e0 <p126_typed_FID_36_100_105_114_101_99_116_46_115_104_97_100_101_>
  407f70:	f3 0f 10 9d 14 ff ff ff 	movss  -0xec(%rbp),%xmm3
  407f78:	f3 0f 10 85 10 ff ff ff 	movss  -0xf0(%rbp),%xmm0
  407f80:	66 49 0f 6e cc       	movq   %r12,%xmm1
  407f85:	66 48 0f 6e d0       	movq   %rax,%xmm2
  407f8a:	f3 0f 59 ca          	mulss  %xmm2,%xmm1
  407f8e:	66 48 0f 6e d3       	movq   %rbx,%xmm2
  407f93:	f3 0f 58 ca          	addss  %xmm2,%xmm1
  407f97:	f3 0f 59 c1          	mulss  %xmm1,%xmm0
  407f9b:	f3 0f 58 c3          	addss  %xmm3,%xmm0
  407f9f:	66 48 0f 7e c0       	movq   %xmm0,%rax
  407fa4:	89 c0                	mov    %eax,%eax
  407fa6:	41 5f                	pop    %r15
  407fa8:	41 5e                	pop    %r14
  407faa:	41 5d                	pop    %r13
  407fac:	41 5c                	pop    %r12
  407fae:	5b                   	pop    %rbx
  407faf:	c9                   	leaveq 
  407fb0:	c3                   	retq   
  407fb1:	66 66 2e 0f 1f 84 00 00 00 00 00 	data16 nopw %cs:0x0(%rax,%rax,1)
  407fbc:	0f 1f 40 00          	nopl   0x0(%rax)

