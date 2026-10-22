0000000000409380 <p113d_FID_36_100_105_114_101_99_116_46_116_114_97_99_101_>:
  409380:	f3 0f 1e fa          	endbr64 
  409384:	55                   	push   %rbp
  409385:	48 89 e5             	mov    %rsp,%rbp
  409388:	48 81 ec 98 0a 00 00 	sub    $0xa98,%rsp
  40938f:	53                   	push   %rbx
  409390:	41 54                	push   %r12
  409392:	41 55                	push   %r13
  409394:	41 56                	push   %r14
  409396:	41 57                	push   %r15
  409398:	48 8b 5d 30          	mov    0x30(%rbp),%rbx
  40939c:	48 89 9d e8 fe ff ff 	mov    %rbx,-0x118(%rbp)
  4093a3:	48 8b 45 28          	mov    0x28(%rbp),%rax
  4093a7:	4c 8b 75 20          	mov    0x20(%rbp),%r14
  4093ab:	4c 8b 65 18          	mov    0x18(%rbp),%r12
  4093af:	4c 8b 7d 10          	mov    0x10(%rbp),%r15
  4093b3:	4d 89 c2             	mov    %r8,%r10
  4093b6:	4d 89 c8             	mov    %r9,%r8
  4093b9:	49 89 cb             	mov    %rcx,%r11
  4093bc:	48 87 d6             	xchg   %rdx,%rsi
  4093bf:	4c 87 e2             	xchg   %r12,%rdx
  4093c2:	4c 89 85 a8 fe ff ff 	mov    %r8,-0x158(%rbp)
  4093c9:	4c 89 95 c0 fe ff ff 	mov    %r10,-0x140(%rbp)
  4093d0:	4c 89 9d d0 fe ff ff 	mov    %r11,-0x130(%rbp)
  4093d7:	4c 89 a5 40 ff ff ff 	mov    %r12,-0xc0(%rbp)
  4093de:	49 83 fc 00          	cmp    $0x0,%r12
  4093e2:	0f 94 c1             	sete   %cl
  4093e5:	0f b6 c9             	movzbl %cl,%ecx
  4093e8:	66 49 0f 6e f7       	movq   %r15,%xmm6
  4093ed:	f3 0f 11 b5 e4 fe ff ff 	movss  %xmm6,-0x11c(%rbp)
  4093f5:	66 49 0f 6e cb       	movq   %r11,%xmm1
  4093fa:	f3 0f 11 8d f8 fe ff ff 	movss  %xmm1,-0x108(%rbp)
  409402:	66 48 0f 6e ea       	movq   %rdx,%xmm5
  409407:	f3 0f 11 ad f0 fe ff ff 	movss  %xmm5,-0x110(%rbp)
  40940f:	66 49 0f 6e d2       	movq   %r10,%xmm2
  409414:	f3 0f 11 95 fc fe ff ff 	movss  %xmm2,-0x104(%rbp)
  40941c:	66 49 0f 6e e6       	movq   %r14,%xmm4
  409421:	f3 0f 11 a5 f4 fe ff ff 	movss  %xmm4,-0x10c(%rbp)
  409429:	66 49 0f 6e d8       	movq   %r8,%xmm3
  40942e:	f3 0f 11 9d 00 ff ff ff 	movss  %xmm3,-0x100(%rbp)
  409436:	66 48 0f 6e d3       	movq   %rbx,%xmm2
  40943b:	f3 0f 11 95 b0 fd ff ff 	movss  %xmm2,-0x250(%rbp)
  409443:	66 48 0f 6e c8       	movq   %rax,%xmm1
  409448:	f3 0f 11 8d b4 fd ff ff 	movss  %xmm1,-0x24c(%rbp)
  409450:	48 89 c3             	mov    %rax,%rbx
  409453:	48 89 f0             	mov    %rsi,%rax
  409456:	48 c1 e8 28          	shr    $0x28,%rax
  40945a:	48 25 ff ff 00 00    	and    $0xffff,%rax
  409460:	41 b8 00 00 00 41    	mov    $0x41000000,%r8d
  409466:	4c 89 85 58 fe ff ff 	mov    %r8,-0x1a8(%rbp)
  40946d:	41 b8 cd cc 4c 3e    	mov    $0x3e4ccccd,%r8d
  409473:	4c 89 85 90 fe ff ff 	mov    %r8,-0x170(%rbp)
  40947a:	41 b8 00 00 60 c0    	mov    $0xc0600000,%r8d
  409480:	4c 89 85 a0 fe ff ff 	mov    %r8,-0x160(%rbp)
  409487:	41 ba 00 00 80 3f    	mov    $0x3f800000,%r10d
  40948d:	4c 89 95 d8 fe ff ff 	mov    %r10,-0x128(%rbp)
  409494:	83 f9 00             	cmp    $0x0,%ecx
  409497:	0f 85 b3 0d 00 00    	jne    40a250 <p113d_FID_36_100_105_114_101_99_116_46_116_114_97_99_101_+0xed0>
  40949d:	0f 1f 00             	nopl   (%rax)
  4094a0:	48 3d 97 00 00 00    	cmp    $0x97,%rax
  4094a6:	74 14                	je     4094bc <p113d_FID_36_100_105_114_101_99_116_46_116_114_97_99_101_+0x13c>
  4094a8:	be 04 00 00 00       	mov    $0x4,%esi
  4094ad:	e8 6e 35 02 00       	callq  42ca20 <p111_rt_fail>
  4094b2:	b8 00 00 00 00       	mov    $0x0,%eax
  4094b7:	e9 1e 1a 00 00       	jmpq   40aeda <p113d_FID_36_100_105_114_101_99_116_46_116_114_97_99_101_+0x1b5a>
  4094bc:	49 89 d5             	mov    %rdx,%r13
  4094bf:	48 8d 95 70 f5 ff ff 	lea    -0xa90(%rbp),%rdx
  4094c6:	49 89 fc             	mov    %rdi,%r12
  4094c9:	e8 d2 87 02 00       	callq  431ca0 <p125_rt_take3>
  4094ce:	4c 89 ea             	mov    %r13,%rdx
  4094d1:	4c 89 e7             	mov    %r12,%rdi
  4094d4:	48 89 d8             	mov    %rbx,%rax
  4094d7:	48 8b 8d 70 f5 ff ff 	mov    -0xa90(%rbp),%rcx
  4094de:	49 89 d5             	mov    %rdx,%r13
  4094e1:	48 8b 95 78 f5 ff ff 	mov    -0xa88(%rbp),%rdx
  4094e8:	48 89 55 f0          	mov    %rdx,-0x10(%rbp)
  4094ec:	48 8b b5 80 f5 ff ff 	mov    -0xa80(%rbp),%rsi
  4094f3:	48 89 b5 50 ff ff ff 	mov    %rsi,-0xb0(%rbp)
  4094fa:	48 83 f9 01          	cmp    $0x1,%rcx
  4094fe:	48 89 c3             	mov    %rax,%rbx
  409501:	0f 94 c0             	sete   %al
  409504:	0f b6 c0             	movzbl %al,%eax
  409507:	48 c1 e9 28          	shr    $0x28,%rcx
  40950b:	48 81 e1 ff ff 7f 00 	and    $0x7fffff,%rcx
  409512:	48 81 f9 02 00 01 00 	cmp    $0x10002,%rcx
  409519:	0f 94 c1             	sete   %cl
  40951c:	0f b6 c9             	movzbl %cl,%ecx
  40951f:	09 c8                	or     %ecx,%eax
  409521:	0f 85 1e 0d 00 00    	jne    40a245 <p113d_FID_36_100_105_114_101_99_116_46_116_114_97_99_101_+0xec5>
  409527:	83 f0 01             	xor    $0x1,%eax
  40952a:	75 19                	jne    409545 <p113d_FID_36_100_105_114_101_99_116_46_116_114_97_99_101_+0x1c5>
  40952c:	2e 2e 2e 2e 2e be 04 00 00 00 	cs cs cs cs cs mov $0x4,%esi
  409536:	e8 e5 34 02 00       	callq  42ca20 <p111_rt_fail>
  40953b:	b8 00 00 00 00       	mov    $0x0,%eax
  409540:	e9 95 19 00 00       	jmpq   40aeda <p113d_FID_36_100_105_114_101_99_116_46_116_114_97_99_101_+0x1b5a>
  409545:	2e 2e 2e 2e 49 89 fc 	cs cs cs cs mov %rdi,%r12
  40954c:	e8 ef ce ff ff       	callq  406440 <p113d_FID_36_100_105_114_101_99_116_46_115_114_>
  409551:	2e 4d 89 f9          	cs mov %r15,%r9
  409555:	4c 89 e7             	mov    %r12,%rdi
  409558:	48 89 45 e0          	mov    %rax,-0x20(%rbp)
  40955c:	48 89 d8             	mov    %rbx,%rax
  40955f:	f3 0f 10 9d 00 ff ff ff 	movss  -0x100(%rbp),%xmm3
  409567:	f3 0f 10 a5 f4 fe ff ff 	movss  -0x10c(%rbp),%xmm4
  40956f:	f3 0f 10 95 fc fe ff ff 	movss  -0x104(%rbp),%xmm2
  409577:	f3 0f 10 ad f0 fe ff ff 	movss  -0x110(%rbp),%xmm5
  40957f:	f3 0f 10 8d f8 fe ff ff 	movss  -0x108(%rbp),%xmm1
  409587:	f3 0f 10 b5 e4 fe ff ff 	movss  -0x11c(%rbp),%xmm6
  40958f:	48 8b b5 50 ff ff ff 	mov    -0xb0(%rbp),%rsi
  409596:	48 8b 4d f0          	mov    -0x10(%rbp),%rcx
  40959a:	48 8b 95 a8 fe ff ff 	mov    -0x158(%rbp),%rdx
  4095a1:	4c 8b 95 c0 fe ff ff 	mov    -0x140(%rbp),%r10
  4095a8:	4c 8b 9d d0 fe ff ff 	mov    -0x130(%rbp),%r11
  4095af:	48 89 8d 70 f5 ff ff 	mov    %rcx,-0xa90(%rbp)
  4095b6:	4c 89 8d 78 f5 ff ff 	mov    %r9,-0xa88(%rbp)
  4095bd:	66 48 0f 6e c1       	movq   %rcx,%xmm0
  4095c2:	f3 0f 59 f0          	mulss  %xmm0,%xmm6
  4095c6:	66 49 0f 7e f0       	movq   %xmm6,%r8
  4095cb:	45 89 c0             	mov    %r8d,%r8d
  4095ce:	4c 89 9d 70 f5 ff ff 	mov    %r11,-0xa90(%rbp)
  4095d5:	4c 89 85 78 f5 ff ff 	mov    %r8,-0xa88(%rbp)
  4095dc:	66 49 0f 6e f0       	movq   %r8,%xmm6
  4095e1:	f3 0f 58 ce          	addss  %xmm6,%xmm1
  4095e5:	66 49 0f 7e c8       	movq   %xmm1,%r8
  4095ea:	45 89 c0             	mov    %r8d,%r8d
  4095ed:	4c 89 45 b0          	mov    %r8,-0x50(%rbp)
  4095f1:	48 89 8d 70 f5 ff ff 	mov    %rcx,-0xa90(%rbp)
  4095f8:	4c 89 ad 78 f5 ff ff 	mov    %r13,-0xa88(%rbp)
  4095ff:	f3 0f 10 c8          	movss  %xmm0,%xmm1
  409603:	f3 0f 59 cd          	mulss  %xmm5,%xmm1
  409607:	66 49 0f 7e c8       	movq   %xmm1,%r8
  40960c:	45 89 c0             	mov    %r8d,%r8d
  40960f:	4c 89 95 70 f5 ff ff 	mov    %r10,-0xa90(%rbp)
  409616:	4c 89 85 78 f5 ff ff 	mov    %r8,-0xa88(%rbp)
  40961d:	66 49 0f 6e c8       	movq   %r8,%xmm1
  409622:	f3 0f 58 ca          	addss  %xmm2,%xmm1
  409626:	66 49 0f 7e c8       	movq   %xmm1,%r8
  40962b:	45 89 c0             	mov    %r8d,%r8d
  40962e:	4c 89 45 a8          	mov    %r8,-0x58(%rbp)
  409632:	48 89 8d 70 f5 ff ff 	mov    %rcx,-0xa90(%rbp)
  409639:	4c 89 b5 78 f5 ff ff 	mov    %r14,-0xa88(%rbp)
  409640:	f3 0f 59 c4          	mulss  %xmm4,%xmm0
  409644:	66 48 0f 7e c1       	movq   %xmm0,%rcx
  409649:	89 c9                	mov    %ecx,%ecx
  40964b:	48 89 95 70 f5 ff ff 	mov    %rdx,-0xa90(%rbp)
  409652:	48 89 8d 78 f5 ff ff 	mov    %rcx,-0xa88(%rbp)
  409659:	66 48 0f 6e c1       	movq   %rcx,%xmm0
  40965e:	f3 0f 58 c3          	addss  %xmm3,%xmm0
  409662:	48 89 c3             	mov    %rax,%rbx
  409665:	66 48 0f 7e c0       	movq   %xmm0,%rax
  40966a:	4d 89 cf             	mov    %r9,%r15
  40966d:	41 89 c1             	mov    %eax,%r9d
  409670:	4c 89 4d 80          	mov    %r9,-0x80(%rbp)
  409674:	49 89 fc             	mov    %rdi,%r12
  409677:	e8 34 d0 ff ff       	callq  4066b0 <p113d_FID_36_100_105_114_101_99_116_46_115_120_>
  40967c:	4c 89 ea             	mov    %r13,%rdx
  40967f:	4c 89 e7             	mov    %r12,%rdi
  409682:	48 89 c1             	mov    %rax,%rcx
  409685:	48 89 d8             	mov    %rbx,%rax
  409688:	49 89 d5             	mov    %rdx,%r13
  40968b:	48 8b 55 b0          	mov    -0x50(%rbp),%rdx
  40968f:	4c 8b 55 e0          	mov    -0x20(%rbp),%r10
  409693:	48 8b b5 50 ff ff ff 	mov    -0xb0(%rbp),%rsi
  40969a:	48 89 95 70 f5 ff ff 	mov    %rdx,-0xa90(%rbp)
  4096a1:	48 89 8d 78 f5 ff ff 	mov    %rcx,-0xa88(%rbp)
  4096a8:	66 48 0f 6e c2       	movq   %rdx,%xmm0
  4096ad:	f3 0f 11 45 b8       	movss  %xmm0,-0x48(%rbp)
  4096b2:	66 48 0f 6e c9       	movq   %rcx,%xmm1
  4096b7:	f3 0f 5c c1          	subss  %xmm1,%xmm0
  4096bb:	66 48 0f 7e c1       	movq   %xmm0,%rcx
  4096c0:	89 c9                	mov    %ecx,%ecx
  4096c2:	48 89 8d 70 f5 ff ff 	mov    %rcx,-0xa90(%rbp)
  4096c9:	4c 89 95 78 f5 ff ff 	mov    %r10,-0xa88(%rbp)
  4096d0:	66 48 0f 6e c1       	movq   %rcx,%xmm0
  4096d5:	66 49 0f 6e e2       	movq   %r10,%xmm4
  4096da:	f3 0f 11 65 e8       	movss  %xmm4,-0x18(%rbp)
  4096df:	f3 0f 5e c4          	divss  %xmm4,%xmm0
  4096e3:	48 89 c3             	mov    %rax,%rbx
  4096e6:	66 48 0f 7e c0       	movq   %xmm0,%rax
  4096eb:	89 c0                	mov    %eax,%eax
  4096ed:	48 89 85 28 ff ff ff 	mov    %rax,-0xd8(%rbp)
  4096f4:	49 89 fc             	mov    %rdi,%r12
  4096f7:	e8 e4 ce ff ff       	callq  4065e0 <p113d_FID_36_100_105_114_101_99_116_46_115_121_>
  4096fc:	4d 89 f9             	mov    %r15,%r9
  4096ff:	4c 89 ea             	mov    %r13,%rdx
  409702:	4c 89 e7             	mov    %r12,%rdi
  409705:	48 89 c1             	mov    %rax,%rcx
  409708:	48 89 d8             	mov    %rbx,%rax
  40970b:	49 89 d5             	mov    %rdx,%r13
  40970e:	48 8b 55 a8          	mov    -0x58(%rbp),%rdx
  409712:	f3 0f 10 65 e8       	movss  -0x18(%rbp),%xmm4
  409717:	4c 8b 55 e0          	mov    -0x20(%rbp),%r10
  40971b:	48 8b b5 50 ff ff ff 	mov    -0xb0(%rbp),%rsi
  409722:	48 89 95 70 f5 ff ff 	mov    %rdx,-0xa90(%rbp)
  409729:	48 89 8d 78 f5 ff ff 	mov    %rcx,-0xa88(%rbp)
  409730:	66 48 0f 6e c2       	movq   %rdx,%xmm0
  409735:	f3 0f 11 45 a4       	movss  %xmm0,-0x5c(%rbp)
  40973a:	f3 0f 10 c8          	movss  %xmm0,%xmm1
  40973e:	66 48 0f 6e c1       	movq   %rcx,%xmm0
  409743:	0f 57 05 c6 98 02 00 	xorps  0x298c6(%rip),%xmm0        # 433010 <_IO_stdin_used+0x10>
  40974a:	f3 0f 58 c1          	addss  %xmm1,%xmm0
  40974e:	66 48 0f 7e c1       	movq   %xmm0,%rcx
  409753:	89 c9                	mov    %ecx,%ecx
  409755:	48 89 8d 70 f5 ff ff 	mov    %rcx,-0xa90(%rbp)
  40975c:	4c 89 95 78 f5 ff ff 	mov    %r10,-0xa88(%rbp)
  409763:	66 48 0f 6e c1       	movq   %rcx,%xmm0
  409768:	f3 0f 5e c4          	divss  %xmm4,%xmm0
  40976c:	48 89 c3             	mov    %rax,%rbx
  40976f:	66 48 0f 7e c0       	movq   %xmm0,%rax
  409774:	4d 89 cf             	mov    %r9,%r15
  409777:	41 89 c1             	mov    %eax,%r9d
  40977a:	4c 89 8d 30 ff ff ff 	mov    %r9,-0xd0(%rbp)
  409781:	49 89 fc             	mov    %rdi,%r12
  409784:	e8 87 cd ff ff       	callq  406510 <p113d_FID_36_100_105_114_101_99_116_46_115_122_>
  409789:	4d 89 f9             	mov    %r15,%r9
  40978c:	4c 89 ea             	mov    %r13,%rdx
  40978f:	4c 89 e7             	mov    %r12,%rdi
  409792:	49 89 c0             	mov    %rax,%r8
  409795:	48 89 d8             	mov    %rbx,%rax
  409798:	4d 89 cf             	mov    %r9,%r15
  40979b:	4c 8b 4d 80          	mov    -0x80(%rbp),%r9
  40979f:	48 8b 4d a8          	mov    -0x58(%rbp),%rcx
  4097a3:	48 8b 75 b0          	mov    -0x50(%rbp),%rsi
  4097a7:	f3 0f 10 4d a4       	movss  -0x5c(%rbp),%xmm1
  4097ac:	f3 0f 10 65 e8       	movss  -0x18(%rbp),%xmm4
  4097b1:	f3 0f 10 45 b8       	movss  -0x48(%rbp),%xmm0
  4097b6:	4c 8b 55 e0          	mov    -0x20(%rbp),%r10
  4097ba:	4c 89 8d 70 f5 ff ff 	mov    %r9,-0xa90(%rbp)
  4097c1:	4c 89 85 78 f5 ff ff 	mov    %r8,-0xa88(%rbp)
  4097c8:	f3 0f 10 d0          	movss  %xmm0,%xmm2
  4097cc:	66 49 0f 6e c1       	movq   %r9,%xmm0
  4097d1:	f3 0f 11 85 7c ff ff ff 	movss  %xmm0,-0x84(%rbp)
  4097d9:	66 49 0f 6e d8       	movq   %r8,%xmm3
  4097de:	0f 57 1d 2b 98 02 00 	xorps  0x2982b(%rip),%xmm3        # 433010 <_IO_stdin_used+0x10>
  4097e5:	f3 0f 58 d8          	addss  %xmm0,%xmm3
  4097e9:	66 49 0f 7e d8       	movq   %xmm3,%r8
  4097ee:	45 89 c0             	mov    %r8d,%r8d
  4097f1:	4c 89 85 70 f5 ff ff 	mov    %r8,-0xa90(%rbp)
  4097f8:	4c 89 95 78 f5 ff ff 	mov    %r10,-0xa88(%rbp)
  4097ff:	66 49 0f 6e d8       	movq   %r8,%xmm3
  409804:	f3 0f 5e dc          	divss  %xmm4,%xmm3
  409808:	66 49 0f 7e d8       	movq   %xmm3,%r8
  40980d:	45 89 c0             	mov    %r8d,%r8d
  409810:	4c 89 85 38 ff ff ff 	mov    %r8,-0xc8(%rbp)
  409817:	48 c7 85 70 f5 ff ff 00 00 00 00 	movq   $0x0,-0xa90(%rbp)
  409822:	48 c7 85 70 f5 ff ff 03 00 00 00 	movq   $0x3,-0xa90(%rbp)
  40982d:	48 c7 85 70 f5 ff ff 00 00 00 00 	movq   $0x0,-0xa90(%rbp)
  409838:	48 c7 85 78 f5 ff ff 00 00 40 40 	movq   $0x40400000,-0xa88(%rbp)
  409843:	41 b8 00 00 40 c0    	mov    $0xc0400000,%r8d
  409849:	4c 89 85 70 f5 ff ff 	mov    %r8,-0xa90(%rbp)
  409850:	48 89 b5 78 f5 ff ff 	mov    %rsi,-0xa88(%rbp)
  409857:	0f 57 15 b2 97 02 00 	xorps  0x297b2(%rip),%xmm2        # 433010 <_IO_stdin_used+0x10>
  40985e:	f3 0f 58 15 ca 97 02 00 	addss  0x297ca(%rip),%xmm2        # 433030 <_IO_stdin_used+0x30>
  409866:	66 48 0f 7e d6       	movq   %xmm2,%rsi
  40986b:	41 89 f0             	mov    %esi,%r8d
  40986e:	4c 89 45 c0          	mov    %r8,-0x40(%rbp)
  409872:	48 c7 85 70 f5 ff ff 08 00 00 00 	movq   $0x8,-0xa90(%rbp)
  40987d:	48 c7 85 70 f5 ff ff 00 00 00 41 	movq   $0x41000000,-0xa90(%rbp)
  409888:	48 89 8d 78 f5 ff ff 	mov    %rcx,-0xa88(%rbp)
  40988f:	0f 57 0d 7a 97 02 00 	xorps  0x2977a(%rip),%xmm1        # 433010 <_IO_stdin_used+0x10>
  409896:	f3 0f 58 0d 8e 97 02 00 	addss  0x2978e(%rip),%xmm1        # 43302c <_IO_stdin_used+0x2c>
  40989e:	66 48 0f 7e c9       	movq   %xmm1,%rcx
  4098a3:	41 89 cb             	mov    %ecx,%r11d
  4098a6:	4c 89 5d c8          	mov    %r11,-0x38(%rbp)
  4098aa:	48 c7 85 70 f5 ff ff 01 00 00 00 	movq   $0x1,-0xa90(%rbp)
  4098b5:	48 c7 85 70 f5 ff ff 00 00 80 3f 	movq   $0x3f800000,-0xa90(%rbp)
  4098c0:	4c 89 8d 78 f5 ff ff 	mov    %r9,-0xa88(%rbp)
  4098c7:	0f 57 05 42 97 02 00 	xorps  0x29742(%rip),%xmm0        # 433010 <_IO_stdin_used+0x10>
  4098ce:	f3 0f 58 05 4a 97 02 00 	addss  0x2974a(%rip),%xmm0        # 433020 <_IO_stdin_used+0x20>
  4098d6:	66 48 0f 7e c1       	movq   %xmm0,%rcx
  4098db:	89 cb                	mov    %ecx,%ebx
  4098dd:	48 89 5d d0          	mov    %rbx,-0x30(%rbp)
  4098e1:	4c 89 85 70 f5 ff ff 	mov    %r8,-0xa90(%rbp)
  4098e8:	4c 89 85 78 f5 ff ff 	mov    %r8,-0xa88(%rbp)
  4098ef:	66 49 0f 6e d8       	movq   %r8,%xmm3
  4098f4:	f3 0f 11 5d bc       	movss  %xmm3,-0x44(%rbp)
  4098f9:	f3 0f 10 c3          	movss  %xmm3,%xmm0
  4098fd:	f3 0f 59 c3          	mulss  %xmm3,%xmm0
  409901:	66 48 0f 7e c1       	movq   %xmm0,%rcx
  409906:	89 ce                	mov    %ecx,%esi
  409908:	4c 89 9d 70 f5 ff ff 	mov    %r11,-0xa90(%rbp)
  40990f:	4c 89 9d 78 f5 ff ff 	mov    %r11,-0xa88(%rbp)
  409916:	66 49 0f 6e d3       	movq   %r11,%xmm2
  40991b:	f3 0f 11 55 d8       	movss  %xmm2,-0x28(%rbp)
  409920:	f3 0f 10 c2          	movss  %xmm2,%xmm0
  409924:	f3 0f 59 c2          	mulss  %xmm2,%xmm0
  409928:	66 48 0f 7e c1       	movq   %xmm0,%rcx
  40992d:	89 c9                	mov    %ecx,%ecx
  40992f:	48 89 b5 70 f5 ff ff 	mov    %rsi,-0xa90(%rbp)
  409936:	48 89 8d 78 f5 ff ff 	mov    %rcx,-0xa88(%rbp)
  40993d:	66 48 0f 6e c6       	movq   %rsi,%xmm0
  409942:	66 48 0f 6e c9       	movq   %rcx,%xmm1
  409947:	f3 0f 58 c1          	addss  %xmm1,%xmm0
  40994b:	66 48 0f 7e c1       	movq   %xmm0,%rcx
  409950:	89 ce                	mov    %ecx,%esi
  409952:	48 89 9d 70 f5 ff ff 	mov    %rbx,-0xa90(%rbp)
  409959:	48 89 9d 78 f5 ff ff 	mov    %rbx,-0xa88(%rbp)
  409960:	66 48 0f 6e c3       	movq   %rbx,%xmm0
  409965:	f3 0f 11 45 dc       	movss  %xmm0,-0x24(%rbp)
  40996a:	f3 0f 59 c0          	mulss  %xmm0,%xmm0
  40996e:	66 48 0f 7e c1       	movq   %xmm0,%rcx
  409973:	89 c9                	mov    %ecx,%ecx
  409975:	48 89 b5 70 f5 ff ff 	mov    %rsi,-0xa90(%rbp)
  40997c:	48 89 8d 78 f5 ff ff 	mov    %rcx,-0xa88(%rbp)
  409983:	66 48 0f 6e c6       	movq   %rsi,%xmm0
  409988:	66 48 0f 6e c9       	movq   %rcx,%xmm1
  40998d:	f3 0f 58 c1          	addss  %xmm1,%xmm0
  409991:	48 89 c3             	mov    %rax,%rbx
  409994:	66 48 0f 7e c0       	movq   %xmm0,%rax
  409999:	89 c0                	mov    %eax,%eax
  40999b:	48 89 85 70 f5 ff ff 	mov    %rax,-0xa90(%rbp)
  4099a2:	b9 01 00 00 00       	mov    $0x1,%ecx
  4099a7:	49 89 d5             	mov    %rdx,%r13
  4099aa:	48 8d 95 70 f5 ff ff 	lea    -0xa90(%rbp),%rdx
  4099b1:	be 24 00 00 00       	mov    $0x24,%esi
  4099b6:	49 89 fc             	mov    %rdi,%r12
  4099b9:	e8 82 30 02 00       	callq  42ca40 <p111_rt_op>
  4099be:	4d 89 f9             	mov    %r15,%r9
  4099c1:	4c 89 ea             	mov    %r13,%rdx
  4099c4:	4c 89 e7             	mov    %r12,%rdi
  4099c7:	49 89 c2             	mov    %rax,%r10
  4099ca:	48 89 d8             	mov    %rbx,%rax
  4099cd:	48 8b 5d d0          	mov    -0x30(%rbp),%rbx
  4099d1:	4c 8b 5d c8          	mov    -0x38(%rbp),%r11
  4099d5:	4c 8b 45 c0          	mov    -0x40(%rbp),%r8
  4099d9:	48 8b 8d 38 ff ff ff 	mov    -0xc8(%rbp),%rcx
  4099e0:	4d 89 cf             	mov    %r9,%r15
  4099e3:	4c 8b 8d 30 ff ff ff 	mov    -0xd0(%rbp),%r9
  4099ea:	48 8b b5 28 ff ff ff 	mov    -0xd8(%rbp),%rsi
  4099f1:	f3 0f 10 45 dc       	movss  -0x24(%rbp),%xmm0
  4099f6:	f3 0f 10 55 d8       	movss  -0x28(%rbp),%xmm2
  4099fb:	f3 0f 10 5d bc       	movss  -0x44(%rbp),%xmm3
  409a00:	4c 89 85 70 f5 ff ff 	mov    %r8,-0xa90(%rbp)
  409a07:	4c 89 95 78 f5 ff ff 	mov    %r10,-0xa88(%rbp)
  409a0e:	66 49 0f 6e ca       	movq   %r10,%xmm1
  409a13:	f3 0f 11 8d 78 ff ff ff 	movss  %xmm1,-0x88(%rbp)
  409a1b:	f3 0f 5e d9          	divss  %xmm1,%xmm3
  409a1f:	66 49 0f 7e d8       	movq   %xmm3,%r8
  409a24:	45 89 c0             	mov    %r8d,%r8d
  409a27:	4c 89 9d 70 f5 ff ff 	mov    %r11,-0xa90(%rbp)
  409a2e:	4c 89 95 78 f5 ff ff 	mov    %r10,-0xa88(%rbp)
  409a35:	f3 0f 5e d1          	divss  %xmm1,%xmm2
  409a39:	49 89 f3             	mov    %rsi,%r11
  409a3c:	66 48 0f 7e d6       	movq   %xmm2,%rsi
  409a41:	89 f6                	mov    %esi,%esi
  409a43:	48 89 9d 70 f5 ff ff 	mov    %rbx,-0xa90(%rbp)
  409a4a:	4c 89 95 78 f5 ff ff 	mov    %r10,-0xa88(%rbp)
  409a51:	f3 0f 5e c1          	divss  %xmm1,%xmm0
  409a55:	49 89 ca             	mov    %rcx,%r10
  409a58:	66 48 0f 7e c1       	movq   %xmm0,%rcx
  409a5d:	89 c9                	mov    %ecx,%ecx
  409a5f:	4c 89 9d 70 f5 ff ff 	mov    %r11,-0xa90(%rbp)
  409a66:	4c 89 85 78 f5 ff ff 	mov    %r8,-0xa88(%rbp)
  409a6d:	66 4d 0f 6e cb       	movq   %r11,%xmm9
  409a72:	f3 44 0f 11 8d 24 ff ff ff 	movss  %xmm9,-0xdc(%rbp)
  409a7b:	66 49 0f 6e d8       	movq   %r8,%xmm3
  409a80:	f3 0f 11 5d 98       	movss  %xmm3,-0x68(%rbp)
  409a85:	f3 41 0f 10 c1       	movss  %xmm9,%xmm0
  409a8a:	f3 0f 59 c3          	mulss  %xmm3,%xmm0
  409a8e:	66 49 0f 7e c0       	movq   %xmm0,%r8
  409a93:	45 89 c0             	mov    %r8d,%r8d
  409a96:	4c 89 8d 70 f5 ff ff 	mov    %r9,-0xa90(%rbp)
  409a9d:	48 89 b5 78 f5 ff ff 	mov    %rsi,-0xa88(%rbp)
  409aa4:	66 49 0f 6e f9       	movq   %r9,%xmm7
  409aa9:	f3 0f 11 bd 48 ff ff ff 	movss  %xmm7,-0xb8(%rbp)
  409ab1:	66 48 0f 6e e6       	movq   %rsi,%xmm4
  409ab6:	f3 0f 11 65 9c       	movss  %xmm4,-0x64(%rbp)
  409abb:	f3 0f 10 c7          	movss  %xmm7,%xmm0
  409abf:	f3 0f 59 c4          	mulss  %xmm4,%xmm0
  409ac3:	66 48 0f 7e c6       	movq   %xmm0,%rsi
  409ac8:	89 f6                	mov    %esi,%esi
  409aca:	4c 89 85 70 f5 ff ff 	mov    %r8,-0xa90(%rbp)
  409ad1:	48 89 b5 78 f5 ff ff 	mov    %rsi,-0xa88(%rbp)
  409ad8:	66 49 0f 6e c0       	movq   %r8,%xmm0
  409add:	66 48 0f 6e ce       	movq   %rsi,%xmm1
  409ae2:	f3 0f 58 c1          	addss  %xmm1,%xmm0
  409ae6:	49 89 d5             	mov    %rdx,%r13
  409ae9:	66 48 0f 7e c2       	movq   %xmm0,%rdx
  409aee:	89 d2                	mov    %edx,%edx
  409af0:	4c 89 95 70 f5 ff ff 	mov    %r10,-0xa90(%rbp)
  409af7:	48 89 8d 78 f5 ff ff 	mov    %rcx,-0xa88(%rbp)
  409afe:	66 49 0f 6e ca       	movq   %r10,%xmm1
  409b03:	f3 0f 11 8d 4c ff ff ff 	movss  %xmm1,-0xb4(%rbp)
  409b0b:	66 48 0f 6e e9       	movq   %rcx,%xmm5
  409b10:	f3 0f 11 6d a0       	movss  %xmm5,-0x60(%rbp)
  409b15:	f3 0f 10 c1          	movss  %xmm1,%xmm0
  409b19:	f3 0f 59 c5          	mulss  %xmm5,%xmm0
  409b1d:	66 48 0f 7e c1       	movq   %xmm0,%rcx
  409b22:	89 c9                	mov    %ecx,%ecx
  409b24:	48 89 95 70 f5 ff ff 	mov    %rdx,-0xa90(%rbp)
  409b2b:	48 89 8d 78 f5 ff ff 	mov    %rcx,-0xa88(%rbp)
  409b32:	66 48 0f 6e c2       	movq   %rdx,%xmm0
  409b37:	66 48 0f 6e c9       	movq   %rcx,%xmm1
  409b3c:	f3 0f 58 c1          	addss  %xmm1,%xmm0
  409b40:	48 89 c3             	mov    %rax,%rbx
  409b43:	66 48 0f 7e c0       	movq   %xmm0,%rax
  409b48:	89 c6                	mov    %eax,%esi
  409b4a:	49 89 fc             	mov    %rdi,%r12
  409b4d:	e8 6e c1 ff ff       	callq  405cc0 <p113d_FID_36_100_105_114_101_99_116_46_102_109_97_120_48_>
  409b52:	4c 89 e7             	mov    %r12,%rdi
  409b55:	48 89 85 68 ff ff ff 	mov    %rax,-0x98(%rbp)
  409b5c:	f3 0f 10 0d e0 94 02 00 	movss  0x294e0(%rip),%xmm1        # 433044 <_IO_stdin_used+0x44>
  409b64:	f3 0f 10 05 d0 94 02 00 	movss  0x294d0(%rip),%xmm0        # 43303c <_IO_stdin_used+0x3c>
  409b6c:	49 89 fc             	mov    %rdi,%r12
  409b6f:	e8 dc c1 ff ff       	callq  405d50 <p126_typed_FID_36_100_105_114_101_99_116_46_102_108_>
  409b74:	4c 89 ea             	mov    %r13,%rdx
  409b77:	4c 89 e7             	mov    %r12,%rdi
  409b7a:	48 89 c1             	mov    %rax,%rcx
  409b7d:	48 89 d8             	mov    %rbx,%rax
  409b80:	48 8b b5 28 ff ff ff 	mov    -0xd8(%rbp),%rsi
  409b87:	49 89 d5             	mov    %rdx,%r13
  409b8a:	48 8b 55 b0          	mov    -0x50(%rbp),%rdx
  409b8e:	f3 44 0f 10 8d 24 ff ff ff 	movss  -0xdc(%rbp),%xmm9
  409b97:	f3 0f 10 45 b8       	movss  -0x48(%rbp),%xmm0
  409b9c:	48 89 8d 70 f5 ff ff 	mov    %rcx,-0xa90(%rbp)
  409ba3:	48 89 b5 78 f5 ff ff 	mov    %rsi,-0xa88(%rbp)
  409baa:	66 48 0f 6e c9       	movq   %rcx,%xmm1
  409baf:	f3 41 0f 59 c9       	mulss  %xmm9,%xmm1
  409bb4:	66 48 0f 7e c9       	movq   %xmm1,%rcx
  409bb9:	89 c9                	mov    %ecx,%ecx
  409bbb:	48 89 95 70 f5 ff ff 	mov    %rdx,-0xa90(%rbp)
  409bc2:	48 89 8d 78 f5 ff ff 	mov    %rcx,-0xa88(%rbp)
  409bc9:	66 48 0f 6e c9       	movq   %rcx,%xmm1
  409bce:	f3 0f 58 c1          	addss  %xmm1,%xmm0
  409bd2:	48 89 c3             	mov    %rax,%rbx
  409bd5:	66 48 0f 7e c0       	movq   %xmm0,%rax
  409bda:	89 c6                	mov    %eax,%esi
  409bdc:	48 89 75 88          	mov    %rsi,-0x78(%rbp)
  409be0:	f3 0f 10 0d 5c 94 02 00 	movss  0x2945c(%rip),%xmm1        # 433044 <_IO_stdin_used+0x44>
  409be8:	f3 0f 10 05 4c 94 02 00 	movss  0x2944c(%rip),%xmm0        # 43303c <_IO_stdin_used+0x3c>
  409bf0:	49 89 fc             	mov    %rdi,%r12
  409bf3:	e8 58 c1 ff ff       	callq  405d50 <p126_typed_FID_36_100_105_114_101_99_116_46_102_108_>
  409bf8:	4d 89 f9             	mov    %r15,%r9
  409bfb:	4c 89 ea             	mov    %r13,%rdx
  409bfe:	4c 89 e7             	mov    %r12,%rdi
  409c01:	48 89 c1             	mov    %rax,%rcx
  409c04:	48 89 d8             	mov    %rbx,%rax
  409c07:	4d 89 cf             	mov    %r9,%r15
  409c0a:	4c 8b 8d 30 ff ff ff 	mov    -0xd0(%rbp),%r9
  409c11:	49 89 d5             	mov    %rdx,%r13
  409c14:	48 8b 55 a8          	mov    -0x58(%rbp),%rdx
  409c18:	f3 0f 10 bd 48 ff ff ff 	movss  -0xb8(%rbp),%xmm7
  409c20:	f3 0f 10 45 a4       	movss  -0x5c(%rbp),%xmm0
  409c25:	48 89 8d 70 f5 ff ff 	mov    %rcx,-0xa90(%rbp)
  409c2c:	4c 89 8d 78 f5 ff ff 	mov    %r9,-0xa88(%rbp)
  409c33:	66 48 0f 6e c9       	movq   %rcx,%xmm1
  409c38:	f3 0f 59 cf          	mulss  %xmm7,%xmm1
  409c3c:	66 48 0f 7e c9       	movq   %xmm1,%rcx
  409c41:	89 c9                	mov    %ecx,%ecx
  409c43:	48 89 95 70 f5 ff ff 	mov    %rdx,-0xa90(%rbp)
  409c4a:	48 89 8d 78 f5 ff ff 	mov    %rcx,-0xa88(%rbp)
  409c51:	66 48 0f 6e c9       	movq   %rcx,%xmm1
  409c56:	f3 0f 58 c1          	addss  %xmm1,%xmm0
  409c5a:	48 89 c3             	mov    %rax,%rbx
  409c5d:	66 48 0f 7e c0       	movq   %xmm0,%rax
  409c62:	89 c1                	mov    %eax,%ecx
  409c64:	48 89 4d 90          	mov    %rcx,-0x70(%rbp)
  409c68:	f3 0f 10 0d d4 93 02 00 	movss  0x293d4(%rip),%xmm1        # 433044 <_IO_stdin_used+0x44>
  409c70:	f3 0f 10 05 c4 93 02 00 	movss  0x293c4(%rip),%xmm0        # 43303c <_IO_stdin_used+0x3c>
  409c78:	49 89 fc             	mov    %rdi,%r12
  409c7b:	e8 d0 c0 ff ff       	callq  405d50 <p126_typed_FID_36_100_105_114_101_99_116_46_102_108_>
  409c80:	4d 89 f9             	mov    %r15,%r9
  409c83:	4c 89 ea             	mov    %r13,%rdx
  409c86:	4c 89 e7             	mov    %r12,%rdi
  409c89:	49 89 c0             	mov    %rax,%r8
  409c8c:	48 89 d8             	mov    %rbx,%rax
  409c8f:	48 8b 4d 90          	mov    -0x70(%rbp),%rcx
  409c93:	48 8b 75 88          	mov    -0x78(%rbp),%rsi
  409c97:	4c 8b 95 38 ff ff ff 	mov    -0xc8(%rbp),%r10
  409c9e:	4d 89 cf             	mov    %r9,%r15
  409ca1:	4c 8b 4d 80          	mov    -0x80(%rbp),%r9
  409ca5:	f3 0f 10 6d a0       	movss  -0x60(%rbp),%xmm5
  409caa:	f3 0f 10 8d 4c ff ff ff 	movss  -0xb4(%rbp),%xmm1
  409cb2:	f3 0f 10 65 9c       	movss  -0x64(%rbp),%xmm4
  409cb7:	f3 0f 10 5d 98       	movss  -0x68(%rbp),%xmm3
  409cbc:	f3 0f 10 85 7c ff ff ff 	movss  -0x84(%rbp),%xmm0
  409cc4:	4c 89 85 70 f5 ff ff 	mov    %r8,-0xa90(%rbp)
  409ccb:	4c 89 95 78 f5 ff ff 	mov    %r10,-0xa88(%rbp)
  409cd2:	66 49 0f 6e d0       	movq   %r8,%xmm2
  409cd7:	f3 0f 59 ca          	mulss  %xmm2,%xmm1
  409cdb:	66 49 0f 7e c8       	movq   %xmm1,%r8
  409ce0:	45 89 c0             	mov    %r8d,%r8d
  409ce3:	4c 89 8d 70 f5 ff ff 	mov    %r9,-0xa90(%rbp)
  409cea:	4c 89 85 78 f5 ff ff 	mov    %r8,-0xa88(%rbp)
  409cf1:	66 49 0f 6e c8       	movq   %r8,%xmm1
  409cf6:	f3 0f 58 c1          	addss  %xmm1,%xmm0
  409cfa:	48 89 c3             	mov    %rax,%rbx
  409cfd:	66 48 0f 7e c0       	movq   %xmm0,%rax
  409d02:	89 c0                	mov    %eax,%eax
  409d04:	48 c7 85 70 f5 ff ff 00 ca 9a 3b 	movq   $0x3b9aca00,-0xa90(%rbp)
  409d0f:	48 c7 85 70 f5 ff ff 00 ca 9a 3b 	movq   $0x3b9aca00,-0xa90(%rbp)
  409d1a:	66 48 0f 6e c6       	movq   %rsi,%xmm0
  409d1f:	f3 0f 11 85 04 ff ff ff 	movss  %xmm0,-0xfc(%rbp)
  409d27:	66 48 0f 6e d1       	movq   %rcx,%xmm2
  409d2c:	f3 0f 11 95 10 ff ff ff 	movss  %xmm2,-0xf0(%rbp)
  409d34:	f3 0f 10 ca          	movss  %xmm2,%xmm1
  409d38:	66 48 0f 6e d0       	movq   %rax,%xmm2
  409d3d:	f3 0f 11 95 14 ff ff ff 	movss  %xmm2,-0xec(%rbp)
  409d45:	41 b8 00 00 00 00    	mov    $0x0,%r8d
  409d4b:	b9 28 6b 6e 4e       	mov    $0x4e6e6b28,%ecx
  409d50:	49 89 d5             	mov    %rdx,%r13
  409d53:	ba 28 6b 6e 4e       	mov    $0x4e6e6b28,%edx
  409d58:	be 09 00 00 00       	mov    $0x9,%esi
  409d5d:	49 89 fc             	mov    %rdi,%r12
  409d60:	e8 9b d0 ff ff       	callq  406e00 <p126_typed_FID_36_100_105_114_101_99_116_46_110_101_97_114_101_115_116_46_116_>
  409d65:	4c 89 e7             	mov    %r12,%rdi
  409d68:	48 89 85 70 ff ff ff 	mov    %rax,-0x90(%rbp)
  409d6f:	f3 0f 10 0d c9 92 02 00 	movss  0x292c9(%rip),%xmm1        # 433040 <_IO_stdin_used+0x40>
  409d77:	f3 0f 10 05 bd 92 02 00 	movss  0x292bd(%rip),%xmm0        # 43303c <_IO_stdin_used+0x3c>
  409d7f:	49 89 fc             	mov    %rdi,%r12
  409d82:	e8 c9 bf ff ff       	callq  405d50 <p126_typed_FID_36_100_105_114_101_99_116_46_102_108_>
  409d87:	4c 89 e7             	mov    %r12,%rdi
  409d8a:	48 89 85 58 ff ff ff 	mov    %rax,-0xa8(%rbp)
  409d91:	f3 0f 10 0d 9f 92 02 00 	movss  0x2929f(%rip),%xmm1        # 433038 <_IO_stdin_used+0x38>
  409d99:	f3 0f 10 05 93 92 02 00 	movss  0x29293(%rip),%xmm0        # 433034 <_IO_stdin_used+0x34>
  409da1:	49 89 fc             	mov    %rdi,%r12
  409da4:	e8 a7 bf ff ff       	callq  405d50 <p126_typed_FID_36_100_105_114_101_99_116_46_102_108_>
  409da9:	4c 89 e7             	mov    %r12,%rdi
  409dac:	48 89 85 60 ff ff ff 	mov    %rax,-0xa0(%rbp)
  409db3:	48 89 d8             	mov    %rbx,%rax
  409db6:	48 89 c3             	mov    %rax,%rbx
  409db9:	48 8b 85 70 ff ff ff 	mov    -0x90(%rbp),%rax
  409dc0:	48 8b b5 68 ff ff ff 	mov    -0x98(%rbp),%rsi
  409dc7:	f3 0f 10 8d 78 ff ff ff 	movss  -0x88(%rbp),%xmm1
  409dcf:	66 48 0f 6e c0       	movq   %rax,%xmm0
  409dd4:	49 89 fc             	mov    %rdi,%r12
  409dd7:	e8 04 c6 ff ff       	callq  4063e0 <p126_typed_FID_36_100_105_114_101_99_116_46_115_104_97_100_101_>
  409ddc:	4c 89 ea             	mov    %r13,%rdx
  409ddf:	4c 89 e7             	mov    %r12,%rdi
  409de2:	48 89 c1             	mov    %rax,%rcx
  409de5:	48 89 d8             	mov    %rbx,%rax
  409de8:	4c 8b 85 60 ff ff ff 	mov    -0xa0(%rbp),%r8
  409def:	49 89 d5             	mov    %rdx,%r13
  409df2:	48 8b 95 58 ff ff ff 	mov    -0xa8(%rbp),%rdx
  409df9:	48 8b b5 50 ff ff ff 	mov    -0xb0(%rbp),%rsi
  409e00:	4c 89 85 70 f5 ff ff 	mov    %r8,-0xa90(%rbp)
  409e07:	48 89 8d 78 f5 ff ff 	mov    %rcx,-0xa88(%rbp)
  409e0e:	66 49 0f 6e c0       	movq   %r8,%xmm0
  409e13:	66 48 0f 6e c9       	movq   %rcx,%xmm1
  409e18:	f3 0f 59 c1          	mulss  %xmm1,%xmm0
  409e1c:	66 48 0f 7e c1       	movq   %xmm0,%rcx
  409e21:	89 c9                	mov    %ecx,%ecx
  409e23:	48 89 95 70 f5 ff ff 	mov    %rdx,-0xa90(%rbp)
  409e2a:	48 89 8d 78 f5 ff ff 	mov    %rcx,-0xa88(%rbp)
  409e31:	66 48 0f 6e c2       	movq   %rdx,%xmm0
  409e36:	66 48 0f 6e c9       	movq   %rcx,%xmm1
  409e3b:	f3 0f 58 c1          	addss  %xmm1,%xmm0
  409e3f:	48 89 c3             	mov    %rax,%rbx
  409e42:	66 48 0f 7e c0       	movq   %xmm0,%rax
  409e47:	41 89 c0             	mov    %eax,%r8d
  409e4a:	4c 89 85 08 ff ff ff 	mov    %r8,-0xf8(%rbp)
  409e51:	49 89 fc             	mov    %rdi,%r12
  409e54:	e8 97 c4 ff ff       	callq  4062f0 <p113d_FID_36_100_105_114_101_99_116_46_115_107_114_>
  409e59:	4d 89 f9             	mov    %r15,%r9
  409e5c:	4c 89 ea             	mov    %r13,%rdx
  409e5f:	4c 89 e7             	mov    %r12,%rdi
  409e62:	49 89 c4             	mov    %rax,%r12
  409e65:	48 89 d8             	mov    %rbx,%rax
  409e68:	48 8b 8d 38 ff ff ff 	mov    -0xc8(%rbp),%rcx
  409e6f:	4d 89 cf             	mov    %r9,%r15
  409e72:	4c 8b 8d 30 ff ff ff 	mov    -0xd0(%rbp),%r9
  409e79:	48 8b b5 28 ff ff ff 	mov    -0xd8(%rbp),%rsi
  409e80:	f3 0f 10 9d 14 ff ff ff 	movss  -0xec(%rbp),%xmm3
  409e88:	f3 0f 10 95 10 ff ff ff 	movss  -0xf0(%rbp),%xmm2
  409e90:	f3 0f 10 8d 04 ff ff ff 	movss  -0xfc(%rbp),%xmm1
  409e98:	f3 0f 10 c1          	movss  %xmm1,%xmm0
  409e9c:	f3 0f 10 8d 4c ff ff ff 	movss  -0xb4(%rbp),%xmm1
  409ea4:	f3 0f 10 bd 48 ff ff ff 	movss  -0xb8(%rbp),%xmm7
  409eac:	f3 44 0f 10 8d 24 ff ff ff 	movss  -0xdc(%rbp),%xmm9
  409eb5:	f3 0f 10 a5 f4 fe ff ff 	movss  -0x10c(%rbp),%xmm4
  409ebd:	f3 0f 10 ad f0 fe ff ff 	movss  -0x110(%rbp),%xmm5
  409ec5:	f3 0f 10 b5 e4 fe ff ff 	movss  -0x11c(%rbp),%xmm6
  409ecd:	48 8b 9d e8 fe ff ff 	mov    -0x118(%rbp),%rbx
  409ed4:	49 89 dd             	mov    %rbx,%r13
  409ed7:	48 8b 9d 40 ff ff ff 	mov    -0xc0(%rbp),%rbx
  409ede:	48 c7 85 70 f5 ff ff 02 00 00 00 	movq   $0x2,-0xa90(%rbp)
  409ee9:	4c 89 bd 70 f5 ff ff 	mov    %r15,-0xa90(%rbp)
  409ef0:	48 89 b5 78 f5 ff ff 	mov    %rsi,-0xa88(%rbp)
  409ef7:	f3 44 0f 10 c6       	movss  %xmm6,%xmm8
  409efc:	f3 45 0f 59 c1       	mulss  %xmm9,%xmm8
  409f01:	66 4d 0f 7e c0       	movq   %xmm8,%r8
  409f06:	45 89 c2             	mov    %r8d,%r10d
  409f09:	48 89 95 70 f5 ff ff 	mov    %rdx,-0xa90(%rbp)
  409f10:	4c 89 8d 78 f5 ff ff 	mov    %r9,-0xa88(%rbp)
  409f17:	f3 44 0f 10 c5       	movss  %xmm5,%xmm8
  409f1c:	f3 44 0f 59 c7       	mulss  %xmm7,%xmm8
  409f21:	66 4d 0f 7e c0       	movq   %xmm8,%r8
  409f26:	45 89 c0             	mov    %r8d,%r8d
  409f29:	4c 89 95 70 f5 ff ff 	mov    %r10,-0xa90(%rbp)
  409f30:	4c 89 85 78 f5 ff ff 	mov    %r8,-0xa88(%rbp)
  409f37:	66 4d 0f 6e c2       	movq   %r10,%xmm8
  409f3c:	66 4d 0f 6e d0       	movq   %r8,%xmm10
  409f41:	f3 45 0f 58 c2       	addss  %xmm10,%xmm8
  409f46:	66 4d 0f 7e c0       	movq   %xmm8,%r8
  409f4b:	45 89 c2             	mov    %r8d,%r10d
  409f4e:	4c 89 b5 70 f5 ff ff 	mov    %r14,-0xa90(%rbp)
  409f55:	48 89 8d 78 f5 ff ff 	mov    %rcx,-0xa88(%rbp)
  409f5c:	f3 44 0f 10 c4       	movss  %xmm4,%xmm8
  409f61:	f3 44 0f 59 c1       	mulss  %xmm1,%xmm8
  409f66:	66 4d 0f 7e c0       	movq   %xmm8,%r8
  409f6b:	45 89 c0             	mov    %r8d,%r8d
  409f6e:	4c 89 95 70 f5 ff ff 	mov    %r10,-0xa90(%rbp)
  409f75:	4c 89 85 78 f5 ff ff 	mov    %r8,-0xa88(%rbp)
  409f7c:	66 4d 0f 6e c2       	movq   %r10,%xmm8
  409f81:	66 4d 0f 6e d0       	movq   %r8,%xmm10
  409f86:	f3 45 0f 58 c2       	addss  %xmm10,%xmm8
  409f8b:	66 4d 0f 7e c0       	movq   %xmm8,%r8
  409f90:	45 89 c0             	mov    %r8d,%r8d
  409f93:	48 c7 85 70 f5 ff ff 00 00 00 40 	movq   $0x40000000,-0xa90(%rbp)
  409f9e:	4c 89 85 78 f5 ff ff 	mov    %r8,-0xa88(%rbp)
  409fa5:	f3 44 0f 10 c6       	movss  %xmm6,%xmm8
  409faa:	66 49 0f 6e f0       	movq   %r8,%xmm6
  409faf:	f3 0f 59 35 91 90 02 00 	mulss  0x29091(%rip),%xmm6        # 433048 <_IO_stdin_used+0x48>
  409fb7:	66 49 0f 7e f0       	movq   %xmm6,%r8
  409fbc:	45 89 c0             	mov    %r8d,%r8d
  409fbf:	4c 89 85 70 f5 ff ff 	mov    %r8,-0xa90(%rbp)
  409fc6:	48 89 b5 78 f5 ff ff 	mov    %rsi,-0xa88(%rbp)
  409fcd:	f3 0f 10 f5          	movss  %xmm5,%xmm6
  409fd1:	66 49 0f 6e e8       	movq   %r8,%xmm5
  409fd6:	f3 44 0f 59 cd       	mulss  %xmm5,%xmm9
  409fdb:	66 4c 0f 7e ce       	movq   %xmm9,%rsi
  409fe0:	89 f6                	mov    %esi,%esi
  409fe2:	4c 89 bd 70 f5 ff ff 	mov    %r15,-0xa90(%rbp)
  409fe9:	48 89 b5 78 f5 ff ff 	mov    %rsi,-0xa88(%rbp)
  409ff0:	66 4c 0f 6e ce       	movq   %rsi,%xmm9
  409ff5:	f3 45 0f 5c c1       	subss  %xmm9,%xmm8
  409ffa:	66 4c 0f 7e c6       	movq   %xmm8,%rsi
  409fff:	89 f6                	mov    %esi,%esi
  40a001:	4c 89 85 70 f5 ff ff 	mov    %r8,-0xa90(%rbp)
  40a008:	4c 89 8d 78 f5 ff ff 	mov    %r9,-0xa88(%rbp)
  40a00f:	f3 0f 59 fd          	mulss  %xmm5,%xmm7
  40a013:	49 89 d7             	mov    %rdx,%r15
  40a016:	66 48 0f 7e fa       	movq   %xmm7,%rdx
  40a01b:	89 d2                	mov    %edx,%edx
  40a01d:	4c 89 bd 70 f5 ff ff 	mov    %r15,-0xa90(%rbp)
  40a024:	48 89 95 78 f5 ff ff 	mov    %rdx,-0xa88(%rbp)
  40a02b:	66 48 0f 6e fa       	movq   %rdx,%xmm7
  40a030:	f3 0f 5c f7          	subss  %xmm7,%xmm6
  40a034:	66 48 0f 7e f2       	movq   %xmm6,%rdx
  40a039:	89 d2                	mov    %edx,%edx
  40a03b:	4c 89 85 70 f5 ff ff 	mov    %r8,-0xa90(%rbp)
  40a042:	48 89 8d 78 f5 ff ff 	mov    %rcx,-0xa88(%rbp)
  40a049:	f3 0f 59 cd          	mulss  %xmm5,%xmm1
  40a04d:	66 48 0f 7e c9       	movq   %xmm1,%rcx
  40a052:	89 c9                	mov    %ecx,%ecx
  40a054:	4c 89 b5 70 f5 ff ff 	mov    %r14,-0xa90(%rbp)
  40a05b:	48 89 8d 78 f5 ff ff 	mov    %rcx,-0xa88(%rbp)
  40a062:	f3 0f 10 ca          	movss  %xmm2,%xmm1
  40a066:	66 48 0f 6e d1       	movq   %rcx,%xmm2
  40a06b:	0f 57 15 9e 8f 02 00 	xorps  0x28f9e(%rip),%xmm2        # 433010 <_IO_stdin_used+0x10>
  40a072:	f3 0f 58 d4          	addss  %xmm4,%xmm2
  40a076:	66 48 0f 7e d1       	movq   %xmm2,%rcx
  40a07b:	89 c9                	mov    %ecx,%ecx
  40a07d:	48 c7 85 70 f5 ff ff 00 ca 9a 3b 	movq   $0x3b9aca00,-0xa90(%rbp)
  40a088:	48 c7 85 70 f5 ff ff 00 ca 9a 3b 	movq   $0x3b9aca00,-0xa90(%rbp)
  40a093:	f3 0f 10 d3          	movss  %xmm3,%xmm2
  40a097:	66 48 0f 6e de       	movq   %rsi,%xmm3
  40a09c:	f3 0f 11 9d 18 ff ff ff 	movss  %xmm3,-0xe8(%rbp)
  40a0a4:	66 48 0f 6e ea       	movq   %rdx,%xmm5
  40a0a9:	f3 0f 11 ad 1c ff ff ff 	movss  %xmm5,-0xe4(%rbp)
  40a0b1:	66 48 0f 6e f1       	movq   %rcx,%xmm6
  40a0b6:	f3 0f 11 b5 20 ff ff ff 	movss  %xmm6,-0xe0(%rbp)
  40a0be:	49 89 c6             	mov    %rax,%r14
  40a0c1:	48 83 ec 10          	sub    $0x10,%rsp
  40a0c5:	48 89 e0             	mov    %rsp,%rax
  40a0c8:	48 c7 40 08 00 00 00 00 	movq   $0x0,0x8(%rax)
  40a0d0:	48 c7 00 09 00 00 00 	movq   $0x9,(%rax)
  40a0d7:	41 b9 28 6b 6e 4e    	mov    $0x4e6e6b28,%r9d
  40a0dd:	41 b8 09 00 00 00    	mov    $0x9,%r8d
  40a0e3:	b9 28 6b 6e 4e       	mov    $0x4e6e6b28,%ecx
  40a0e8:	f3 0f 10 e5          	movss  %xmm5,%xmm4
  40a0ec:	f3 0f 10 ee          	movss  %xmm6,%xmm5
  40a0f0:	ba 09 00 00 00       	mov    $0x9,%edx
  40a0f5:	48 8d b5 70 fd ff ff 	lea    -0x290(%rbp),%rsi
  40a0fc:	49 89 ff             	mov    %rdi,%r15
  40a0ff:	e8 fc c6 ff ff       	callq  406800 <p126_typed_FID_36_112_114_111_100_117_99_116_46_110_101_97_114_101_115_116_>
  40a104:	4c 89 ff             	mov    %r15,%rdi
  40a107:	4c 89 f0             	mov    %r14,%rax
  40a10a:	4c 8b 85 08 ff ff ff 	mov    -0xf8(%rbp),%r8
  40a111:	f3 0f 10 8d b4 fd ff ff 	movss  -0x24c(%rbp),%xmm1
  40a119:	f3 0f 10 95 b0 fd ff ff 	movss  -0x250(%rbp),%xmm2
  40a121:	f3 0f 10 b5 20 ff ff ff 	movss  -0xe0(%rbp),%xmm6
  40a129:	f3 0f 10 ad 1c ff ff ff 	movss  -0xe4(%rbp),%xmm5
  40a131:	f3 0f 10 a5 18 ff ff ff 	movss  -0xe8(%rbp),%xmm4
  40a139:	f3 0f 10 9d 14 ff ff ff 	movss  -0xec(%rbp),%xmm3
  40a141:	f3 0f 10 c2          	movss  %xmm2,%xmm0
  40a145:	f3 0f 10 95 10 ff ff ff 	movss  -0xf0(%rbp),%xmm2
  40a14d:	f3 44 0f 10 c1       	movss  %xmm1,%xmm8
  40a152:	f3 0f 10 8d 04 ff ff ff 	movss  -0xfc(%rbp),%xmm1
  40a15a:	48 83 ec f0          	sub    $0xfffffffffffffff0,%rsp
  40a15e:	48 8b 95 70 fd ff ff 	mov    -0x290(%rbp),%rdx
  40a165:	48 8b b5 78 fd ff ff 	mov    -0x288(%rbp),%rsi
  40a16c:	48 8b 8d 80 fd ff ff 	mov    -0x280(%rbp),%rcx
  40a173:	4c 89 ad 70 f5 ff ff 	mov    %r13,-0xa90(%rbp)
  40a17a:	4c 89 85 78 f5 ff ff 	mov    %r8,-0xa88(%rbp)
  40a181:	66 49 0f 6e f8       	movq   %r8,%xmm7
  40a186:	f3 0f 59 f8          	mulss  %xmm0,%xmm7
  40a18a:	66 49 0f 7e f8       	movq   %xmm7,%r8
  40a18f:	45 89 c1             	mov    %r8d,%r9d
  40a192:	48 c7 85 70 f5 ff ff 01 00 00 00 	movq   $0x1,-0xa90(%rbp)
  40a19d:	48 c7 85 70 f5 ff ff 00 00 80 3f 	movq   $0x3f800000,-0xa90(%rbp)
  40a1a8:	4c 89 a5 78 f5 ff ff 	mov    %r12,-0xa88(%rbp)
  40a1af:	66 49 0f 6e fc       	movq   %r12,%xmm7
  40a1b4:	f3 44 0f 10 0d 63 8e 02 00 	movss  0x28e63(%rip),%xmm9        # 433020 <_IO_stdin_used+0x20>
  40a1bd:	f3 44 0f 5c cf       	subss  %xmm7,%xmm9
  40a1c2:	66 4d 0f 7e c8       	movq   %xmm9,%r8
  40a1c7:	45 89 c0             	mov    %r8d,%r8d
  40a1ca:	4c 89 8d 70 f5 ff ff 	mov    %r9,-0xa90(%rbp)
  40a1d1:	4c 89 85 78 f5 ff ff 	mov    %r8,-0xa88(%rbp)
  40a1d8:	66 4d 0f 6e c9       	movq   %r9,%xmm9
  40a1dd:	66 4d 0f 6e d0       	movq   %r8,%xmm10
  40a1e2:	f3 45 0f 59 ca       	mulss  %xmm10,%xmm9
  40a1e7:	49 89 c6             	mov    %rax,%r14
  40a1ea:	66 4c 0f 7e c8       	movq   %xmm9,%rax
  40a1ef:	89 c0                	mov    %eax,%eax
  40a1f1:	4c 89 b5 70 f5 ff ff 	mov    %r14,-0xa90(%rbp)
  40a1f8:	48 89 85 78 f5 ff ff 	mov    %rax,-0xa88(%rbp)
  40a1ff:	66 4c 0f 6e c8       	movq   %rax,%xmm9
  40a204:	f3 45 0f 58 c1       	addss  %xmm9,%xmm8
  40a209:	66 4c 0f 7e c0       	movq   %xmm8,%rax
  40a20e:	41 89 c0             	mov    %eax,%r8d
  40a211:	4c 89 ad 70 f5 ff ff 	mov    %r13,-0xa90(%rbp)
  40a218:	4c 89 a5 78 f5 ff ff 	mov    %r12,-0xa88(%rbp)
  40a21f:	f3 0f 59 c7          	mulss  %xmm7,%xmm0
  40a223:	66 48 0f 7e c0       	movq   %xmm0,%rax
  40a228:	89 c0                	mov    %eax,%eax
  40a22a:	66 48 0f 6e c6       	movq   %rsi,%xmm0
  40a22f:	66 48 0f 6e f8       	movq   %rax,%xmm7
  40a234:	48 89 de             	mov    %rbx,%rsi
  40a237:	48 83 ee 01          	sub    $0x1,%rsi
  40a23b:	e8 70 d1 ff ff       	callq  4073b0 <p126_typed_FID_36_112_114_111_100_117_99_116_46_116_114_97_99_101_>
  40a240:	e9 95 0c 00 00       	jmpq   40aeda <p113d_FID_36_100_105_114_101_99_116_46_116_114_97_99_101_+0x1b5a>
  40a245:	48 89 d8             	mov    %rbx,%rax
  40a248:	48 89 c3             	mov    %rax,%rbx
  40a24b:	e9 8a 0c 00 00       	jmpq   40aeda <p113d_FID_36_100_105_114_101_99_116_46_116_114_97_99_101_+0x1b5a>
  40a250:	4d 89 f5             	mov    %r14,%r13
  40a253:	48 3d 97 00 00 00    	cmp    $0x97,%rax
  40a259:	74 14                	je     40a26f <p113d_FID_36_100_105_114_101_99_116_46_116_114_97_99_101_+0xeef>
  40a25b:	be 04 00 00 00       	mov    $0x4,%esi
  40a260:	e8 bb 27 02 00       	callq  42ca20 <p111_rt_fail>
  40a265:	b8 00 00 00 00       	mov    $0x0,%eax
  40a26a:	e9 6b 0c 00 00       	jmpq   40aeda <p113d_FID_36_100_105_114_101_99_116_46_116_114_97_99_101_+0x1b5a>
  40a26f:	49 89 d6             	mov    %rdx,%r14
  40a272:	48 8d 95 70 f5 ff ff 	lea    -0xa90(%rbp),%rdx
  40a279:	49 89 fc             	mov    %rdi,%r12
  40a27c:	e8 1f 7a 02 00       	callq  431ca0 <p125_rt_take3>
  40a281:	4d 89 f9             	mov    %r15,%r9
  40a284:	4c 89 f2             	mov    %r14,%rdx
  40a287:	4c 89 e7             	mov    %r12,%rdi
  40a28a:	48 89 d8             	mov    %rbx,%rax
  40a28d:	f3 0f 10 9d 00 ff ff ff 	movss  -0x100(%rbp),%xmm3
  40a295:	f3 0f 10 a5 f4 fe ff ff 	movss  -0x10c(%rbp),%xmm4
  40a29d:	f3 0f 10 95 fc fe ff ff 	movss  -0x104(%rbp),%xmm2
  40a2a5:	f3 0f 10 ad f0 fe ff ff 	movss  -0x110(%rbp),%xmm5
  40a2ad:	f3 0f 10 8d f8 fe ff ff 	movss  -0x108(%rbp),%xmm1
  40a2b5:	f3 0f 10 b5 e4 fe ff ff 	movss  -0x11c(%rbp),%xmm6
  40a2bd:	48 8b 9d e8 fe ff ff 	mov    -0x118(%rbp),%rbx
  40a2c4:	4c 8b 85 70 f5 ff ff 	mov    -0xa90(%rbp),%r8
  40a2cb:	4c 8b b5 78 f5 ff ff 	mov    -0xa88(%rbp),%r14
  40a2d2:	48 8b b5 80 f5 ff ff 	mov    -0xa80(%rbp),%rsi
  40a2d9:	49 83 f8 01          	cmp    $0x1,%r8
  40a2dd:	0f 94 c1             	sete   %cl
  40a2e0:	0f b6 c9             	movzbl %cl,%ecx
  40a2e3:	49 c1 e8 28          	shr    $0x28,%r8
  40a2e7:	49 81 e0 ff ff 7f 00 	and    $0x7fffff,%r8
  40a2ee:	49 81 f8 02 00 01 00 	cmp    $0x10002,%r8
  40a2f5:	41 0f 94 c0          	sete   %r8b
  40a2f9:	45 0f b6 c0          	movzbl %r8b,%r8d
  40a2fd:	44 09 c1             	or     %r8d,%ecx
  40a300:	0f 85 d4 0b 00 00    	jne    40aeda <p113d_FID_36_100_105_114_101_99_116_46_116_114_97_99_101_+0x1b5a>
  40a306:	83 f1 01             	xor    $0x1,%ecx
  40a309:	75 14                	jne    40a31f <p113d_FID_36_100_105_114_101_99_116_46_116_114_97_99_101_+0xf9f>
  40a30b:	be 04 00 00 00       	mov    $0x4,%esi
  40a310:	e8 0b 27 02 00       	callq  42ca20 <p111_rt_fail>
  40a315:	b8 00 00 00 00       	mov    $0x0,%eax
  40a31a:	e9 bb 0b 00 00       	jmpq   40aeda <p113d_FID_36_100_105_114_101_99_116_46_116_114_97_99_101_+0x1b5a>
  40a31f:	48 83 fe 00          	cmp    $0x0,%rsi
  40a323:	0f 94 c1             	sete   %cl
  40a326:	0f b6 c9             	movzbl %cl,%ecx
  40a329:	89 8d e0 fe ff ff    	mov    %ecx,-0x120(%rbp)
  40a32f:	49 89 f0             	mov    %rsi,%r8
  40a332:	49 83 e8 01          	sub    $0x1,%r8
  40a336:	49 89 f7             	mov    %rsi,%r15
  40a339:	49 83 ef 02          	sub    $0x2,%r15
  40a33d:	49 89 f4             	mov    %rsi,%r12
  40a340:	49 83 ec 03          	sub    $0x3,%r12
  40a344:	49 89 f3             	mov    %rsi,%r11
  40a347:	49 83 eb 04          	sub    $0x4,%r11
  40a34b:	49 89 f2             	mov    %rsi,%r10
  40a34e:	49 83 ea 05          	sub    $0x5,%r10
  40a352:	4c 89 95 c8 fe ff ff 	mov    %r10,-0x138(%rbp)
  40a359:	48 89 f1             	mov    %rsi,%rcx
  40a35c:	48 83 e9 06          	sub    $0x6,%rcx
  40a360:	48 89 8d b8 fe ff ff 	mov    %rcx,-0x148(%rbp)
  40a367:	48 89 f1             	mov    %rsi,%rcx
  40a36a:	48 83 e9 07          	sub    $0x7,%rcx
  40a36e:	48 89 8d b0 fe ff ff 	mov    %rcx,-0x150(%rbp)
  40a375:	4c 89 d1             	mov    %r10,%rcx
  40a378:	4c 8b 95 b8 fe ff ff 	mov    -0x148(%rbp),%r10
  40a37f:	83 bd e0 fe ff ff 00 	cmpl   $0x0,-0x120(%rbp)
  40a386:	75 73                	jne    40a3fb <p113d_FID_36_100_105_114_101_99_116_46_116_114_97_99_101_+0x107b>
  40a388:	49 83 f8 00          	cmp    $0x0,%r8
  40a38c:	74 66                	je     40a3f4 <p113d_FID_36_100_105_114_101_99_116_46_116_114_97_99_101_+0x1074>
  40a38e:	49 83 ff 00          	cmp    $0x0,%r15
  40a392:	74 59                	je     40a3ed <p113d_FID_36_100_105_114_101_99_116_46_116_114_97_99_101_+0x106d>
  40a394:	49 83 fc 00          	cmp    $0x0,%r12
  40a398:	74 4c                	je     40a3e6 <p113d_FID_36_100_105_114_101_99_116_46_116_114_97_99_101_+0x1066>
  40a39a:	66 0f 1f 44 00 00    	nopw   0x0(%rax,%rax,1)
  40a3a0:	49 83 fb 00          	cmp    $0x0,%r11
  40a3a4:	74 39                	je     40a3df <p113d_FID_36_100_105_114_101_99_116_46_116_114_97_99_101_+0x105f>
  40a3a6:	48 83 f9 00          	cmp    $0x0,%rcx
  40a3aa:	48 8b 8d b0 fe ff ff 	mov    -0x150(%rbp),%rcx
  40a3b1:	74 25                	je     40a3d8 <p113d_FID_36_100_105_114_101_99_116_46_116_114_97_99_101_+0x1058>
  40a3b3:	2e 2e 49 83 fa 00    	cs cs cmp $0x0,%r10
  40a3b9:	4c 8b 95 d8 fe ff ff 	mov    -0x128(%rbp),%r10
  40a3c0:	74 0f                	je     40a3d1 <p113d_FID_36_100_105_114_101_99_116_46_116_114_97_99_101_+0x1051>
  40a3c2:	48 83 f9 00          	cmp    $0x0,%rcx
  40a3c6:	b9 00 00 80 3f       	mov    $0x3f800000,%ecx
  40a3cb:	49 0f 45 ca          	cmovne %r10,%rcx
  40a3cf:	eb 31                	jmp    40a402 <p113d_FID_36_100_105_114_101_99_116_46_116_114_97_99_101_+0x1082>
  40a3d1:	b9 9a 99 99 3f       	mov    $0x3f99999a,%ecx
  40a3d6:	eb 2a                	jmp    40a402 <p113d_FID_36_100_105_114_101_99_116_46_116_114_97_99_101_+0x1082>
  40a3d8:	b9 cd cc cc 3e       	mov    $0x3ecccccd,%ecx
  40a3dd:	eb 23                	jmp    40a402 <p113d_FID_36_100_105_114_101_99_116_46_116_114_97_99_101_+0x1082>
  40a3df:	b9 cd cc cc 3e       	mov    $0x3ecccccd,%ecx
  40a3e4:	eb 1c                	jmp    40a402 <p113d_FID_36_100_105_114_101_99_116_46_116_114_97_99_101_+0x1082>
  40a3e6:	b9 00 00 80 3f       	mov    $0x3f800000,%ecx
  40a3eb:	eb 15                	jmp    40a402 <p113d_FID_36_100_105_114_101_99_116_46_116_114_97_99_101_+0x1082>
  40a3ed:	b9 00 00 80 3f       	mov    $0x3f800000,%ecx
  40a3f2:	eb 0e                	jmp    40a402 <p113d_FID_36_100_105_114_101_99_116_46_116_114_97_99_101_+0x1082>
  40a3f4:	b9 00 00 80 3f       	mov    $0x3f800000,%ecx
  40a3f9:	eb 07                	jmp    40a402 <p113d_FID_36_100_105_114_101_99_116_46_116_114_97_99_101_+0x1082>
  40a3fb:	2e 2e b9 00 40 1c 46 	cs cs mov $0x461c4000,%ecx
  40a402:	4c 89 b5 70 f5 ff ff 	mov    %r14,-0xa90(%rbp)
  40a409:	4c 89 8d 78 f5 ff ff 	mov    %r9,-0xa88(%rbp)
  40a410:	66 49 0f 6e c6       	movq   %r14,%xmm0
  40a415:	f3 0f 59 f0          	mulss  %xmm0,%xmm6
  40a419:	66 49 0f 7e f1       	movq   %xmm6,%r9
  40a41e:	45 89 c9             	mov    %r9d,%r9d
  40a421:	4c 89 8d 98 fe ff ff 	mov    %r9,-0x168(%rbp)
  40a428:	4c 8b 95 c8 fe ff ff 	mov    -0x138(%rbp),%r10
  40a42f:	4c 8b 8d d0 fe ff ff 	mov    -0x130(%rbp),%r9
  40a436:	4c 89 8d 70 f5 ff ff 	mov    %r9,-0xa90(%rbp)
  40a43d:	4c 8b 8d 98 fe ff ff 	mov    -0x168(%rbp),%r9
  40a444:	4c 89 8d 78 f5 ff ff 	mov    %r9,-0xa88(%rbp)
  40a44b:	4c 89 b5 70 f5 ff ff 	mov    %r14,-0xa90(%rbp)
  40a452:	48 89 95 78 f5 ff ff 	mov    %rdx,-0xa88(%rbp)
  40a459:	f3 0f 59 e8          	mulss  %xmm0,%xmm5
  40a45d:	66 48 0f 7e ea       	movq   %xmm5,%rdx
  40a462:	89 d2                	mov    %edx,%edx
  40a464:	48 89 95 88 fe ff ff 	mov    %rdx,-0x178(%rbp)
  40a46b:	4c 8b 8d b8 fe ff ff 	mov    -0x148(%rbp),%r9
  40a472:	48 8b 95 c0 fe ff ff 	mov    -0x140(%rbp),%rdx
  40a479:	48 89 95 70 f5 ff ff 	mov    %rdx,-0xa90(%rbp)
  40a480:	48 8b 95 88 fe ff ff 	mov    -0x178(%rbp),%rdx
  40a487:	48 89 95 78 f5 ff ff 	mov    %rdx,-0xa88(%rbp)
  40a48e:	48 8b 95 b0 fe ff ff 	mov    -0x150(%rbp),%rdx
  40a495:	4c 89 b5 70 f5 ff ff 	mov    %r14,-0xa90(%rbp)
  40a49c:	4c 89 ad 78 f5 ff ff 	mov    %r13,-0xa88(%rbp)
  40a4a3:	f3 0f 59 c4          	mulss  %xmm4,%xmm0
  40a4a7:	66 49 0f 7e c5       	movq   %xmm0,%r13
  40a4ac:	45 89 ee             	mov    %r13d,%r14d
  40a4af:	4c 89 b5 60 fe ff ff 	mov    %r14,-0x1a0(%rbp)
  40a4b6:	4c 8b ad 98 fe ff ff 	mov    -0x168(%rbp),%r13
  40a4bd:	4c 8b b5 a8 fe ff ff 	mov    -0x158(%rbp),%r14
  40a4c4:	4c 89 b5 70 f5 ff ff 	mov    %r14,-0xa90(%rbp)
  40a4cb:	4c 8b b5 60 fe ff ff 	mov    -0x1a0(%rbp),%r14
  40a4d2:	4c 89 b5 78 f5 ff ff 	mov    %r14,-0xa88(%rbp)
  40a4d9:	4c 8b b5 a0 fe ff ff 	mov    -0x160(%rbp),%r14
  40a4e0:	48 83 fe 00          	cmp    $0x0,%rsi
  40a4e4:	74 6d                	je     40a553 <p113d_FID_36_100_105_114_101_99_116_46_116_114_97_99_101_+0x11d3>
  40a4e6:	49 83 f8 00          	cmp    $0x0,%r8
  40a4ea:	74 5f                	je     40a54b <p113d_FID_36_100_105_114_101_99_116_46_116_114_97_99_101_+0x11cb>
  40a4ec:	49 83 ff 00          	cmp    $0x0,%r15
  40a4f0:	74 51                	je     40a543 <p113d_FID_36_100_105_114_101_99_116_46_116_114_97_99_101_+0x11c3>
  40a4f2:	49 83 fc 00          	cmp    $0x0,%r12
  40a4f6:	74 43                	je     40a53b <p113d_FID_36_100_105_114_101_99_116_46_116_114_97_99_101_+0x11bb>
  40a4f8:	49 83 fb 00          	cmp    $0x0,%r11
  40a4fc:	74 35                	je     40a533 <p113d_FID_36_100_105_114_101_99_116_46_116_114_97_99_101_+0x11b3>
  40a4fe:	66 90                	xchg   %ax,%ax
  40a500:	49 83 fa 00          	cmp    $0x0,%r10
  40a504:	74 25                	je     40a52b <p113d_FID_36_100_105_114_101_99_116_46_116_114_97_99_101_+0x11ab>
  40a506:	49 83 f9 00          	cmp    $0x0,%r9
  40a50a:	74 17                	je     40a523 <p113d_FID_36_100_105_114_101_99_116_46_116_114_97_99_101_+0x11a3>
  40a50c:	48 83 fa 00          	cmp    $0x0,%rdx
  40a510:	41 bd 00 00 60 40    	mov    $0x40600000,%r13d
  40a516:	4d 0f 44 f5          	cmove  %r13,%r14
  40a51a:	4c 8b ad 98 fe ff ff 	mov    -0x168(%rbp),%r13
  40a521:	eb 36                	jmp    40a559 <p113d_FID_36_100_105_114_101_99_116_46_116_114_97_99_101_+0x11d9>
  40a523:	41 be 00 00 00 00    	mov    $0x0,%r14d
  40a529:	eb 2e                	jmp    40a559 <p113d_FID_36_100_105_114_101_99_116_46_116_114_97_99_101_+0x11d9>
  40a52b:	41 be 00 00 80 bf    	mov    $0xbf800000,%r14d
  40a531:	eb 26                	jmp    40a559 <p113d_FID_36_100_105_114_101_99_116_46_116_114_97_99_101_+0x11d9>
  40a533:	41 be 00 00 80 3f    	mov    $0x3f800000,%r14d
  40a539:	eb 1e                	jmp    40a559 <p113d_FID_36_100_105_114_101_99_116_46_116_114_97_99_101_+0x11d9>
  40a53b:	41 be 00 00 00 c0    	mov    $0xc0000000,%r14d
  40a541:	eb 16                	jmp    40a559 <p113d_FID_36_100_105_114_101_99_116_46_116_114_97_99_101_+0x11d9>
  40a543:	41 be 00 00 00 40    	mov    $0x40000000,%r14d
  40a549:	eb 0e                	jmp    40a559 <p113d_FID_36_100_105_114_101_99_116_46_116_114_97_99_101_+0x11d9>
  40a54b:	41 be 00 00 00 00    	mov    $0x0,%r14d
  40a551:	eb 06                	jmp    40a559 <p113d_FID_36_100_105_114_101_99_116_46_116_114_97_99_101_+0x11d9>
  40a553:	41 be 00 00 00 00    	mov    $0x0,%r14d
  40a559:	66 49 0f 6e c5       	movq   %r13,%xmm0
  40a55e:	f3 0f 58 c1          	addss  %xmm1,%xmm0
  40a562:	66 49 0f 7e c5       	movq   %xmm0,%r13
  40a567:	45 89 ed             	mov    %r13d,%r13d
  40a56a:	4c 89 ad 80 fe ff ff 	mov    %r13,-0x180(%rbp)
  40a571:	4c 89 ad 70 f5 ff ff 	mov    %r13,-0xa90(%rbp)
  40a578:	4c 89 b5 78 f5 ff ff 	mov    %r14,-0xa88(%rbp)
  40a57f:	66 49 0f 6e c5       	movq   %r13,%xmm0
  40a584:	f3 0f 11 85 18 fe ff ff 	movss  %xmm0,-0x1e8(%rbp)
  40a58c:	66 49 0f 6e ce       	movq   %r14,%xmm1
  40a591:	0f 57 0d 78 8a 02 00 	xorps  0x28a78(%rip),%xmm1        # 433010 <_IO_stdin_used+0x10>
  40a598:	f3 0f 58 c8          	addss  %xmm0,%xmm1
  40a59c:	66 49 0f 7e ce       	movq   %xmm1,%r14
  40a5a1:	45 89 f6             	mov    %r14d,%r14d
  40a5a4:	4c 89 b5 38 fe ff ff 	mov    %r14,-0x1c8(%rbp)
  40a5ab:	4c 89 b5 70 f5 ff ff 	mov    %r14,-0xa90(%rbp)
  40a5b2:	4c 8b b5 88 fe ff ff 	mov    -0x178(%rbp),%r14
  40a5b9:	48 89 8d 78 f5 ff ff 	mov    %rcx,-0xa88(%rbp)
  40a5c0:	48 83 fe 00          	cmp    $0x0,%rsi
  40a5c4:	0f 84 9a 00 00 00    	je     40a664 <p113d_FID_36_100_105_114_101_99_116_46_116_114_97_99_101_+0x12e4>
  40a5ca:	4c 8b b5 90 fe ff ff 	mov    -0x170(%rbp),%r14
  40a5d1:	49 83 f8 00          	cmp    $0x0,%r8
  40a5d5:	74 5b                	je     40a632 <p113d_FID_36_100_105_114_101_99_116_46_116_114_97_99_101_+0x12b2>
  40a5d7:	49 83 ff 00          	cmp    $0x0,%r15
  40a5db:	74 4d                	je     40a62a <p113d_FID_36_100_105_114_101_99_116_46_116_114_97_99_101_+0x12aa>
  40a5dd:	0f 1f 00             	nopl   (%rax)
  40a5e0:	49 83 fc 00          	cmp    $0x0,%r12
  40a5e4:	74 3c                	je     40a622 <p113d_FID_36_100_105_114_101_99_116_46_116_114_97_99_101_+0x12a2>
  40a5e6:	49 83 fb 00          	cmp    $0x0,%r11
  40a5ea:	74 2c                	je     40a618 <p113d_FID_36_100_105_114_101_99_116_46_116_114_97_99_101_+0x1298>
  40a5ec:	49 83 fa 00          	cmp    $0x0,%r10
  40a5f0:	74 1e                	je     40a610 <p113d_FID_36_100_105_114_101_99_116_46_116_114_97_99_101_+0x1290>
  40a5f2:	49 83 f9 00          	cmp    $0x0,%r9
  40a5f6:	74 10                	je     40a608 <p113d_FID_36_100_105_114_101_99_116_46_116_114_97_99_101_+0x1288>
  40a5f8:	48 83 fa 00          	cmp    $0x0,%rdx
  40a5fc:	41 bd cd cc 4c 3e    	mov    $0x3e4ccccd,%r13d
  40a602:	4d 0f 45 ee          	cmovne %r14,%r13
  40a606:	eb 30                	jmp    40a638 <p113d_FID_36_100_105_114_101_99_116_46_116_114_97_99_101_+0x12b8>
  40a608:	41 bd cd cc cc 3f    	mov    $0x3fcccccd,%r13d
  40a60e:	eb 28                	jmp    40a638 <p113d_FID_36_100_105_114_101_99_116_46_116_114_97_99_101_+0x12b8>
  40a610:	41 bd 9a 99 19 bf    	mov    $0xbf19999a,%r13d
  40a616:	eb 20                	jmp    40a638 <p113d_FID_36_100_105_114_101_99_116_46_116_114_97_99_101_+0x12b8>
  40a618:	2e 2e 41 bd 9a 99 19 bf 	cs cs mov $0xbf19999a,%r13d
  40a620:	eb 16                	jmp    40a638 <p113d_FID_36_100_105_114_101_99_116_46_116_114_97_99_101_+0x12b8>
  40a622:	41 bd 00 00 00 3f    	mov    $0x3f000000,%r13d
  40a628:	eb 0e                	jmp    40a638 <p113d_FID_36_100_105_114_101_99_116_46_116_114_97_99_101_+0x12b8>
  40a62a:	41 bd 00 00 00 3f    	mov    $0x3f000000,%r13d
  40a630:	eb 06                	jmp    40a638 <p113d_FID_36_100_105_114_101_99_116_46_116_114_97_99_101_+0x12b8>
  40a632:	41 bd 00 00 00 00    	mov    $0x0,%r13d
  40a638:	4d 89 ee             	mov    %r13,%r14
  40a63b:	4c 89 b5 78 fe ff ff 	mov    %r14,-0x188(%rbp)
  40a642:	4c 8b b5 88 fe ff ff 	mov    -0x178(%rbp),%r14
  40a649:	4c 8b ad 80 fe ff ff 	mov    -0x180(%rbp),%r13
  40a650:	f2 44 0f 10 bd 78 fe ff ff 	movsd  -0x188(%rbp),%xmm15
  40a659:	f2 44 0f 11 bd 70 fe ff ff 	movsd  %xmm15,-0x190(%rbp)
  40a662:	eb 15                	jmp    40a679 <p113d_FID_36_100_105_114_101_99_116_46_116_114_97_99_101_+0x12f9>
  40a664:	2e c7 85 70 fe ff ff 00 44 1c c6 	movl   $0xc61c4400,%cs:-0x190(%rbp)
  40a66f:	c7 85 74 fe ff ff 00 00 00 00 	movl   $0x0,-0x18c(%rbp)
  40a679:	66 49 0f 6e ce       	movq   %r14,%xmm1
  40a67e:	f3 0f 58 ca          	addss  %xmm2,%xmm1
  40a682:	66 49 0f 7e ce       	movq   %xmm1,%r14
  40a687:	45 89 f6             	mov    %r14d,%r14d
  40a68a:	4c 89 b5 68 fe ff ff 	mov    %r14,-0x198(%rbp)
  40a691:	4c 89 b5 70 f5 ff ff 	mov    %r14,-0xa90(%rbp)
  40a698:	4c 8b b5 70 fe ff ff 	mov    -0x190(%rbp),%r14
  40a69f:	4c 89 b5 78 f5 ff ff 	mov    %r14,-0xa88(%rbp)
  40a6a6:	4c 8b b5 68 fe ff ff 	mov    -0x198(%rbp),%r14
  40a6ad:	66 49 0f 6e ce       	movq   %r14,%xmm1
  40a6b2:	f3 0f 11 8d 00 fe ff ff 	movss  %xmm1,-0x200(%rbp)
  40a6ba:	4c 8b b5 70 fe ff ff 	mov    -0x190(%rbp),%r14
  40a6c1:	66 49 0f 6e d6       	movq   %r14,%xmm2
  40a6c6:	0f 57 15 43 89 02 00 	xorps  0x28943(%rip),%xmm2        # 433010 <_IO_stdin_used+0x10>
  40a6cd:	f3 0f 58 d1          	addss  %xmm1,%xmm2
  40a6d1:	66 49 0f 7e d6       	movq   %xmm2,%r14
  40a6d6:	45 89 f6             	mov    %r14d,%r14d
  40a6d9:	4c 89 b5 40 fe ff ff 	mov    %r14,-0x1c0(%rbp)
  40a6e0:	4c 89 b5 70 f5 ff ff 	mov    %r14,-0xa90(%rbp)
  40a6e7:	4c 8b b5 68 fe ff ff 	mov    -0x198(%rbp),%r14
  40a6ee:	48 89 8d 78 f5 ff ff 	mov    %rcx,-0xa88(%rbp)
  40a6f5:	48 83 fe 00          	cmp    $0x0,%rsi
  40a6f9:	48 8b b5 60 fe ff ff 	mov    -0x1a0(%rbp),%rsi
  40a700:	74 6a                	je     40a76c <p113d_FID_36_100_105_114_101_99_116_46_116_114_97_99_101_+0x13ec>
  40a702:	49 83 f8 00          	cmp    $0x0,%r8
  40a706:	4c 8b 85 58 fe ff ff 	mov    -0x1a8(%rbp),%r8
  40a70d:	74 56                	je     40a765 <p113d_FID_36_100_105_114_101_99_116_46_116_114_97_99_101_+0x13e5>
  40a70f:	49 83 ff 00          	cmp    $0x0,%r15
  40a713:	74 49                	je     40a75e <p113d_FID_36_100_105_114_101_99_116_46_116_114_97_99_101_+0x13de>
  40a715:	49 83 fc 00          	cmp    $0x0,%r12
  40a719:	74 3c                	je     40a757 <p113d_FID_36_100_105_114_101_99_116_46_116_114_97_99_101_+0x13d7>
  40a71b:	0f 1f 44 00 00       	nopl   0x0(%rax,%rax,1)
  40a720:	49 83 fb 00          	cmp    $0x0,%r11
  40a724:	74 2a                	je     40a750 <p113d_FID_36_100_105_114_101_99_116_46_116_114_97_99_101_+0x13d0>
  40a726:	49 83 fa 00          	cmp    $0x0,%r10
  40a72a:	74 1d                	je     40a749 <p113d_FID_36_100_105_114_101_99_116_46_116_114_97_99_101_+0x13c9>
  40a72c:	49 83 f9 00          	cmp    $0x0,%r9
  40a730:	74 10                	je     40a742 <p113d_FID_36_100_105_114_101_99_116_46_116_114_97_99_101_+0x13c2>
  40a732:	2e 48 83 fa 00       	cs cmp $0x0,%rdx
  40a737:	ba 00 00 00 41       	mov    $0x41000000,%edx
  40a73c:	49 0f 45 d0          	cmovne %r8,%rdx
  40a740:	eb 2f                	jmp    40a771 <p113d_FID_36_100_105_114_101_99_116_46_116_114_97_99_101_+0x13f1>
  40a742:	ba 00 00 e0 40       	mov    $0x40e00000,%edx
  40a747:	eb 28                	jmp    40a771 <p113d_FID_36_100_105_114_101_99_116_46_116_114_97_99_101_+0x13f1>
  40a749:	ba 00 00 60 40       	mov    $0x40600000,%edx
  40a74e:	eb 21                	jmp    40a771 <p113d_FID_36_100_105_114_101_99_116_46_116_114_97_99_101_+0x13f1>
  40a750:	ba 00 00 60 40       	mov    $0x40600000,%edx
  40a755:	eb 1a                	jmp    40a771 <p113d_FID_36_100_105_114_101_99_116_46_116_114_97_99_101_+0x13f1>
  40a757:	ba 00 00 c0 40       	mov    $0x40c00000,%edx
  40a75c:	eb 13                	jmp    40a771 <p113d_FID_36_100_105_114_101_99_116_46_116_114_97_99_101_+0x13f1>
  40a75e:	ba 00 00 c0 40       	mov    $0x40c00000,%edx
  40a763:	eb 0c                	jmp    40a771 <p113d_FID_36_100_105_114_101_99_116_46_116_114_97_99_101_+0x13f1>
  40a765:	ba 00 00 a0 40       	mov    $0x40a00000,%edx
  40a76a:	eb 05                	jmp    40a771 <p113d_FID_36_100_105_114_101_99_116_46_116_114_97_99_101_+0x13f1>
  40a76c:	ba 00 00 a0 40       	mov    $0x40a00000,%edx
  40a771:	66 48 0f 6e d6       	movq   %rsi,%xmm2
  40a776:	f3 0f 58 d3          	addss  %xmm3,%xmm2
  40a77a:	66 48 0f 7e d6       	movq   %xmm2,%rsi
  40a77f:	41 89 f4             	mov    %esi,%r12d
  40a782:	4c 89 a5 08 fe ff ff 	mov    %r12,-0x1f8(%rbp)
  40a789:	4c 89 a5 70 f5 ff ff 	mov    %r12,-0xa90(%rbp)
  40a790:	48 89 95 78 f5 ff ff 	mov    %rdx,-0xa88(%rbp)
  40a797:	f3 0f 10 d0          	movss  %xmm0,%xmm2
  40a79b:	66 49 0f 6e c4       	movq   %r12,%xmm0
  40a7a0:	f3 0f 11 85 c4 fd ff ff 	movss  %xmm0,-0x23c(%rbp)
  40a7a8:	66 48 0f 6e da       	movq   %rdx,%xmm3
  40a7ad:	0f 57 1d 5c 88 02 00 	xorps  0x2885c(%rip),%xmm3        # 433010 <_IO_stdin_used+0x10>
  40a7b4:	f3 0f 58 d8          	addss  %xmm0,%xmm3
  40a7b8:	66 48 0f 7e da       	movq   %xmm3,%rdx
  40a7bd:	89 d2                	mov    %edx,%edx
  40a7bf:	48 89 95 70 f5 ff ff 	mov    %rdx,-0xa90(%rbp)
  40a7c6:	48 89 8d 78 f5 ff ff 	mov    %rcx,-0xa88(%rbp)
  40a7cd:	66 48 0f 6e e2       	movq   %rdx,%xmm4
  40a7d2:	66 48 0f 6e d9       	movq   %rcx,%xmm3
  40a7d7:	f3 0f 11 9d 48 fe ff ff 	movss  %xmm3,-0x1b8(%rbp)
  40a7df:	f3 44 0f 10 fb       	movss  %xmm3,%xmm15
  40a7e4:	f3 0f 10 dc          	movss  %xmm4,%xmm3
  40a7e8:	f3 41 0f 5e df       	divss  %xmm15,%xmm3
  40a7ed:	66 48 0f 7e d9       	movq   %xmm3,%rcx
  40a7f2:	4d 89 e7             	mov    %r12,%r15
  40a7f5:	41 89 cc             	mov    %ecx,%r12d
  40a7f8:	4c 89 a5 f8 fd ff ff 	mov    %r12,-0x208(%rbp)
  40a7ff:	48 c7 85 70 f5 ff ff 00 00 00 00 	movq   $0x0,-0xa90(%rbp)
  40a80a:	48 c7 85 70 f5 ff ff 03 00 00 00 	movq   $0x3,-0xa90(%rbp)
  40a815:	48 c7 85 70 f5 ff ff 00 00 00 00 	movq   $0x0,-0xa90(%rbp)
  40a820:	48 c7 85 78 f5 ff ff 00 00 40 40 	movq   $0x40400000,-0xa88(%rbp)
  40a82b:	b9 00 00 40 c0       	mov    $0xc0400000,%ecx
  40a830:	48 89 8d 70 f5 ff ff 	mov    %rcx,-0xa90(%rbp)
  40a837:	4c 89 ad 78 f5 ff ff 	mov    %r13,-0xa88(%rbp)
  40a83e:	0f 57 15 cb 87 02 00 	xorps  0x287cb(%rip),%xmm2        # 433010 <_IO_stdin_used+0x10>
  40a845:	f3 0f 58 15 e3 87 02 00 	addss  0x287e3(%rip),%xmm2        # 433030 <_IO_stdin_used+0x30>
  40a84d:	66 48 0f 7e d1       	movq   %xmm2,%rcx
  40a852:	41 89 c8             	mov    %ecx,%r8d
  40a855:	4c 89 85 20 fe ff ff 	mov    %r8,-0x1e0(%rbp)
  40a85c:	48 c7 85 70 f5 ff ff 08 00 00 00 	movq   $0x8,-0xa90(%rbp)
  40a867:	48 c7 85 70 f5 ff ff 00 00 00 41 	movq   $0x41000000,-0xa90(%rbp)
  40a872:	4c 89 b5 78 f5 ff ff 	mov    %r14,-0xa88(%rbp)
  40a879:	0f 57 0d 90 87 02 00 	xorps  0x28790(%rip),%xmm1        # 433010 <_IO_stdin_used+0x10>
  40a880:	f3 0f 58 0d a4 87 02 00 	addss  0x287a4(%rip),%xmm1        # 43302c <_IO_stdin_used+0x2c>
  40a888:	66 48 0f 7e c9       	movq   %xmm1,%rcx
  40a88d:	89 ce                	mov    %ecx,%esi
  40a88f:	48 89 b5 28 fe ff ff 	mov    %rsi,-0x1d8(%rbp)
  40a896:	48 c7 85 70 f5 ff ff 01 00 00 00 	movq   $0x1,-0xa90(%rbp)
  40a8a1:	48 c7 85 70 f5 ff ff 00 00 80 3f 	movq   $0x3f800000,-0xa90(%rbp)
  40a8ac:	4c 89 bd 78 f5 ff ff 	mov    %r15,-0xa88(%rbp)
  40a8b3:	0f 57 05 56 87 02 00 	xorps  0x28756(%rip),%xmm0        # 433010 <_IO_stdin_used+0x10>
  40a8ba:	f3 0f 58 05 5e 87 02 00 	addss  0x2875e(%rip),%xmm0        # 433020 <_IO_stdin_used+0x20>
  40a8c2:	66 48 0f 7e c1       	movq   %xmm0,%rcx
  40a8c7:	41 89 ca             	mov    %ecx,%r10d
  40a8ca:	4c 89 95 30 fe ff ff 	mov    %r10,-0x1d0(%rbp)
  40a8d1:	4c 89 85 70 f5 ff ff 	mov    %r8,-0xa90(%rbp)
  40a8d8:	4c 89 85 78 f5 ff ff 	mov    %r8,-0xa88(%rbp)
  40a8df:	66 49 0f 6e e8       	movq   %r8,%xmm5
  40a8e4:	f3 0f 11 ad 4c fe ff ff 	movss  %xmm5,-0x1b4(%rbp)
  40a8ec:	f3 0f 10 c5          	movss  %xmm5,%xmm0
  40a8f0:	f3 0f 59 c5          	mulss  %xmm5,%xmm0
  40a8f4:	66 48 0f 7e c1       	movq   %xmm0,%rcx
  40a8f9:	89 ca                	mov    %ecx,%edx
  40a8fb:	48 89 b5 70 f5 ff ff 	mov    %rsi,-0xa90(%rbp)
  40a902:	48 89 b5 78 f5 ff ff 	mov    %rsi,-0xa88(%rbp)
  40a909:	66 48 0f 6e e6       	movq   %rsi,%xmm4
  40a90e:	f3 0f 11 a5 50 fe ff ff 	movss  %xmm4,-0x1b0(%rbp)
  40a916:	f3 0f 10 c4          	movss  %xmm4,%xmm0
  40a91a:	f3 0f 59 c4          	mulss  %xmm4,%xmm0
  40a91e:	66 48 0f 7e c1       	movq   %xmm0,%rcx
  40a923:	89 c9                	mov    %ecx,%ecx
  40a925:	48 89 95 70 f5 ff ff 	mov    %rdx,-0xa90(%rbp)
  40a92c:	48 89 8d 78 f5 ff ff 	mov    %rcx,-0xa88(%rbp)
  40a933:	66 48 0f 6e c2       	movq   %rdx,%xmm0
  40a938:	66 48 0f 6e c9       	movq   %rcx,%xmm1
  40a93d:	f3 0f 58 c1          	addss  %xmm1,%xmm0
  40a941:	66 48 0f 7e c1       	movq   %xmm0,%rcx
  40a946:	89 ca                	mov    %ecx,%edx
  40a948:	4c 89 95 70 f5 ff ff 	mov    %r10,-0xa90(%rbp)
  40a94f:	4c 89 95 78 f5 ff ff 	mov    %r10,-0xa88(%rbp)
  40a956:	66 49 0f 6e d2       	movq   %r10,%xmm2
  40a95b:	f3 0f 11 95 54 fe ff ff 	movss  %xmm2,-0x1ac(%rbp)
  40a963:	f3 0f 10 c2          	movss  %xmm2,%xmm0
  40a967:	f3 0f 59 c2          	mulss  %xmm2,%xmm0
  40a96b:	66 48 0f 7e c1       	movq   %xmm0,%rcx
  40a970:	89 c9                	mov    %ecx,%ecx
  40a972:	48 89 95 70 f5 ff ff 	mov    %rdx,-0xa90(%rbp)
  40a979:	48 89 8d 78 f5 ff ff 	mov    %rcx,-0xa88(%rbp)
  40a980:	66 48 0f 6e c2       	movq   %rdx,%xmm0
  40a985:	66 48 0f 6e c9       	movq   %rcx,%xmm1
  40a98a:	f3 0f 58 c1          	addss  %xmm1,%xmm0
  40a98e:	49 89 c4             	mov    %rax,%r12
  40a991:	66 48 0f 7e c0       	movq   %xmm0,%rax
  40a996:	89 c0                	mov    %eax,%eax
  40a998:	48 89 85 70 f5 ff ff 	mov    %rax,-0xa90(%rbp)
  40a99f:	b9 01 00 00 00       	mov    $0x1,%ecx
  40a9a4:	48 8d 95 70 f5 ff ff 	lea    -0xa90(%rbp),%rdx
  40a9ab:	be 24 00 00 00       	mov    $0x24,%esi
  40a9b0:	49 89 ff             	mov    %rdi,%r15
  40a9b3:	e8 88 20 02 00       	callq  42ca40 <p111_rt_op>
  40a9b8:	4c 89 ff             	mov    %r15,%rdi
  40a9bb:	48 89 c2             	mov    %rax,%rdx
  40a9be:	4c 89 e0             	mov    %r12,%rax
  40a9c1:	4c 8b 95 30 fe ff ff 	mov    -0x1d0(%rbp),%r10
  40a9c8:	48 8b b5 28 fe ff ff 	mov    -0x1d8(%rbp),%rsi
  40a9cf:	4c 8b 85 20 fe ff ff 	mov    -0x1e0(%rbp),%r8
  40a9d6:	4c 8b a5 f8 fd ff ff 	mov    -0x208(%rbp),%r12
  40a9dd:	4c 8b 8d 40 fe ff ff 	mov    -0x1c0(%rbp),%r9
  40a9e4:	48 8b 8d 38 fe ff ff 	mov    -0x1c8(%rbp),%rcx
  40a9eb:	4c 8b bd 08 fe ff ff 	mov    -0x1f8(%rbp),%r15
  40a9f2:	f3 0f 10 95 54 fe ff ff 	movss  -0x1ac(%rbp),%xmm2
  40a9fa:	f3 0f 10 a5 50 fe ff ff 	movss  -0x1b0(%rbp),%xmm4
  40aa02:	f3 0f 10 ad 4c fe ff ff 	movss  -0x1b4(%rbp),%xmm5
  40aa0a:	f3 0f 10 9d 48 fe ff ff 	movss  -0x1b8(%rbp),%xmm3
  40aa12:	f3 0f 10 85 18 fe ff ff 	movss  -0x1e8(%rbp),%xmm0
  40aa1a:	4c 89 85 70 f5 ff ff 	mov    %r8,-0xa90(%rbp)
  40aa21:	48 89 95 78 f5 ff ff 	mov    %rdx,-0xa88(%rbp)
  40aa28:	66 48 0f 6e ca       	movq   %rdx,%xmm1
  40aa2d:	f3 0f 11 8d c0 fd ff ff 	movss  %xmm1,-0x240(%rbp)
  40aa35:	f3 0f 5e e9          	divss  %xmm1,%xmm5
  40aa39:	66 49 0f 7e e8       	movq   %xmm5,%r8
  40aa3e:	45 89 c0             	mov    %r8d,%r8d
  40aa41:	48 89 b5 70 f5 ff ff 	mov    %rsi,-0xa90(%rbp)
  40aa48:	48 89 95 78 f5 ff ff 	mov    %rdx,-0xa88(%rbp)
  40aa4f:	f3 0f 5e e1          	divss  %xmm1,%xmm4
  40aa53:	66 48 0f 7e e6       	movq   %xmm4,%rsi
  40aa58:	89 f6                	mov    %esi,%esi
  40aa5a:	4c 89 95 70 f5 ff ff 	mov    %r10,-0xa90(%rbp)
  40aa61:	48 89 95 78 f5 ff ff 	mov    %rdx,-0xa88(%rbp)
  40aa68:	f3 44 0f 10 f9       	movss  %xmm1,%xmm15
  40aa6d:	f3 0f 10 ca          	movss  %xmm2,%xmm1
  40aa71:	f3 41 0f 5e cf       	divss  %xmm15,%xmm1
  40aa76:	66 48 0f 7e ca       	movq   %xmm1,%rdx
  40aa7b:	89 d2                	mov    %edx,%edx
  40aa7d:	66 48 0f 6e c9       	movq   %rcx,%xmm1
  40aa82:	f3 0f 5e cb          	divss  %xmm3,%xmm1
  40aa86:	66 48 0f 7e c9       	movq   %xmm1,%rcx
  40aa8b:	89 c9                	mov    %ecx,%ecx
  40aa8d:	48 89 8d 10 fe ff ff 	mov    %rcx,-0x1f0(%rbp)
  40aa94:	48 89 8d 70 f5 ff ff 	mov    %rcx,-0xa90(%rbp)
  40aa9b:	4c 89 85 78 f5 ff ff 	mov    %r8,-0xa88(%rbp)
  40aaa2:	66 48 0f 6e c9       	movq   %rcx,%xmm1
  40aaa7:	f3 0f 11 8d 1c fe ff ff 	movss  %xmm1,-0x1e4(%rbp)
  40aaaf:	66 49 0f 6e d0       	movq   %r8,%xmm2
  40aab4:	f3 0f 11 95 e0 fd ff ff 	movss  %xmm2,-0x220(%rbp)
  40aabc:	f3 0f 59 d1          	mulss  %xmm1,%xmm2
  40aac0:	66 49 0f 7e d0       	movq   %xmm2,%r8
  40aac5:	45 89 c0             	mov    %r8d,%r8d
  40aac8:	66 49 0f 6e d1       	movq   %r9,%xmm2
  40aacd:	f3 0f 5e d3          	divss  %xmm3,%xmm2
  40aad1:	66 49 0f 7e d1       	movq   %xmm2,%r9
  40aad6:	45 89 c9             	mov    %r9d,%r9d
  40aad9:	4c 89 8d f0 fd ff ff 	mov    %r9,-0x210(%rbp)
  40aae0:	4c 89 8d 70 f5 ff ff 	mov    %r9,-0xa90(%rbp)
  40aae7:	48 89 b5 78 f5 ff ff 	mov    %rsi,-0xa88(%rbp)
  40aaee:	66 49 0f 6e d1       	movq   %r9,%xmm2
  40aaf3:	f3 0f 11 95 04 fe ff ff 	movss  %xmm2,-0x1fc(%rbp)
  40aafb:	66 48 0f 6e e6       	movq   %rsi,%xmm4
  40ab00:	f3 0f 11 a5 e4 fd ff ff 	movss  %xmm4,-0x21c(%rbp)
  40ab08:	f3 0f 59 d4          	mulss  %xmm4,%xmm2
  40ab0c:	66 48 0f 7e d6       	movq   %xmm2,%rsi
  40ab11:	89 f6                	mov    %esi,%esi
  40ab13:	4c 89 85 70 f5 ff ff 	mov    %r8,-0xa90(%rbp)
  40ab1a:	48 89 b5 78 f5 ff ff 	mov    %rsi,-0xa88(%rbp)
  40ab21:	66 49 0f 6e d0       	movq   %r8,%xmm2
  40ab26:	66 48 0f 6e de       	movq   %rsi,%xmm3
  40ab2b:	f3 0f 58 d3          	addss  %xmm3,%xmm2
  40ab2f:	66 48 0f 7e d6       	movq   %xmm2,%rsi
  40ab34:	89 f6                	mov    %esi,%esi
  40ab36:	4c 89 a5 70 f5 ff ff 	mov    %r12,-0xa90(%rbp)
  40ab3d:	48 89 95 78 f5 ff ff 	mov    %rdx,-0xa88(%rbp)
  40ab44:	66 49 0f 6e d4       	movq   %r12,%xmm2
  40ab49:	f3 0f 11 95 e8 fd ff ff 	movss  %xmm2,-0x218(%rbp)
  40ab51:	66 48 0f 6e ea       	movq   %rdx,%xmm5
  40ab56:	f3 0f 11 ad ec fd ff ff 	movss  %xmm5,-0x214(%rbp)
  40ab5e:	f3 0f 59 d5          	mulss  %xmm5,%xmm2
  40ab62:	66 48 0f 7e d2       	movq   %xmm2,%rdx
  40ab67:	89 d2                	mov    %edx,%edx
  40ab69:	48 89 b5 70 f5 ff ff 	mov    %rsi,-0xa90(%rbp)
  40ab70:	48 89 95 78 f5 ff ff 	mov    %rdx,-0xa88(%rbp)
  40ab77:	66 48 0f 6e d6       	movq   %rsi,%xmm2
  40ab7c:	66 48 0f 6e da       	movq   %rdx,%xmm3
  40ab81:	f3 0f 58 d3          	addss  %xmm3,%xmm2
  40ab85:	66 48 0f 7e d2       	movq   %xmm2,%rdx
  40ab8a:	89 d6                	mov    %edx,%esi
  40ab8c:	66 48 0f 6e d6       	movq   %rsi,%xmm2
  40ab91:	f3 0f 10 1d 8b 84 02 00 	movss  0x2848b(%rip),%xmm3        # 433024 <_IO_stdin_used+0x24>
  40ab99:	0f 2e da             	ucomiss %xmm2,%xmm3
  40ab9c:	0f 97 c2             	seta   %dl
  40ab9f:	0f b6 d2             	movzbl %dl,%edx
  40aba2:	89 d2                	mov    %edx,%edx
  40aba4:	48 83 fa 01          	cmp    $0x1,%rdx
  40aba8:	49 89 c4             	mov    %rax,%r12
  40abab:	0f 94 c0             	sete   %al
  40abae:	0f b6 c0             	movzbl %al,%eax
  40abb1:	48 c1 ea 28          	shr    $0x28,%rdx
  40abb5:	48 81 e2 ff ff 7f 00 	and    $0x7fffff,%rdx
  40abbc:	48 81 fa 02 00 01 00 	cmp    $0x10002,%rdx
  40abc3:	0f 94 c2             	sete   %dl
  40abc6:	0f b6 d2             	movzbl %dl,%edx
  40abc9:	09 d0                	or     %edx,%eax
  40abcb:	75 4c                	jne    40ac19 <p113d_FID_36_100_105_114_101_99_116_46_116_114_97_99_101_+0x1899>
  40abcd:	83 f0 01             	xor    $0x1,%eax
  40abd0:	75 38                	jne    40ac0a <p113d_FID_36_100_105_114_101_99_116_46_116_114_97_99_101_+0x188a>
  40abd2:	be 04 00 00 00       	mov    $0x4,%esi
  40abd7:	49 89 ff             	mov    %rdi,%r15
  40abda:	e8 41 1e 02 00       	callq  42ca20 <p111_rt_fail>
  40abdf:	4c 89 ff             	mov    %r15,%rdi
  40abe2:	4c 89 e0             	mov    %r12,%rax
  40abe5:	48 8b 8d 10 fe ff ff 	mov    -0x1f0(%rbp),%rcx
  40abec:	4c 8b a5 08 fe ff ff 	mov    -0x1f8(%rbp),%r12
  40abf3:	f3 0f 10 8d 1c fe ff ff 	movss  -0x1e4(%rbp),%xmm1
  40abfb:	f3 0f 10 85 18 fe ff ff 	movss  -0x1e8(%rbp),%xmm0
  40ac03:	be 00 00 00 00       	mov    $0x0,%esi
  40ac08:	eb 06                	jmp    40ac10 <p113d_FID_36_100_105_114_101_99_116_46_116_114_97_99_101_+0x1890>
  40ac0a:	4c 89 e0             	mov    %r12,%rax
  40ac0d:	4d 89 fc             	mov    %r15,%r12
  40ac10:	48 89 b5 c8 fd ff ff 	mov    %rsi,-0x238(%rbp)
  40ac17:	eb 11                	jmp    40ac2a <p113d_FID_36_100_105_114_101_99_116_46_116_114_97_99_101_+0x18aa>
  40ac19:	4c 89 e0             	mov    %r12,%rax
  40ac1c:	4d 89 fc             	mov    %r15,%r12
  40ac1f:	48 c7 85 c8 fd ff ff 00 00 00 00 	movq   $0x0,-0x238(%rbp)
  40ac2a:	48 c7 85 70 f5 ff ff 6f 12 83 3a 	movq   $0x3a83126f,-0xa90(%rbp)
  40ac35:	48 89 8d 78 f5 ff ff 	mov    %rcx,-0xa88(%rbp)
  40ac3c:	f3 0f 59 0d e4 83 02 00 	mulss  0x283e4(%rip),%xmm1        # 433028 <_IO_stdin_used+0x28>
  40ac44:	66 48 0f 7e c9       	movq   %xmm1,%rcx
  40ac49:	89 c9                	mov    %ecx,%ecx
  40ac4b:	4c 89 ad 70 f5 ff ff 	mov    %r13,-0xa90(%rbp)
  40ac52:	48 89 8d 78 f5 ff ff 	mov    %rcx,-0xa88(%rbp)
  40ac59:	66 48 0f 6e c9       	movq   %rcx,%xmm1
  40ac5e:	f3 0f 58 c1          	addss  %xmm1,%xmm0
  40ac62:	49 89 c5             	mov    %rax,%r13
  40ac65:	66 48 0f 7e c0       	movq   %xmm0,%rax
  40ac6a:	89 c2                	mov    %eax,%edx
  40ac6c:	48 89 95 d0 fd ff ff 	mov    %rdx,-0x230(%rbp)
  40ac73:	f3 0f 10 0d c9 83 02 00 	movss  0x283c9(%rip),%xmm1        # 433044 <_IO_stdin_used+0x44>
  40ac7b:	f3 0f 10 05 b9 83 02 00 	movss  0x283b9(%rip),%xmm0        # 43303c <_IO_stdin_used+0x3c>
  40ac83:	49 89 ff             	mov    %rdi,%r15
  40ac86:	e8 c5 b0 ff ff       	callq  405d50 <p126_typed_FID_36_100_105_114_101_99_116_46_102_108_>
  40ac8b:	4c 89 ff             	mov    %r15,%rdi
  40ac8e:	48 89 c1             	mov    %rax,%rcx
  40ac91:	4c 89 e8             	mov    %r13,%rax
  40ac94:	4c 8b ad f8 fd ff ff 	mov    -0x208(%rbp),%r13
  40ac9b:	48 8b 95 f0 fd ff ff 	mov    -0x210(%rbp),%rdx
  40aca2:	f3 0f 10 8d 04 fe ff ff 	movss  -0x1fc(%rbp),%xmm1
  40acaa:	f3 0f 10 85 00 fe ff ff 	movss  -0x200(%rbp),%xmm0
  40acb2:	48 89 8d 70 f5 ff ff 	mov    %rcx,-0xa90(%rbp)
  40acb9:	48 89 95 78 f5 ff ff 	mov    %rdx,-0xa88(%rbp)
  40acc0:	66 48 0f 6e d1       	movq   %rcx,%xmm2
  40acc5:	f3 0f 59 ca          	mulss  %xmm2,%xmm1
  40acc9:	66 48 0f 7e c9       	movq   %xmm1,%rcx
  40acce:	89 c9                	mov    %ecx,%ecx
  40acd0:	4c 89 b5 70 f5 ff ff 	mov    %r14,-0xa90(%rbp)
  40acd7:	48 89 8d 78 f5 ff ff 	mov    %rcx,-0xa88(%rbp)
  40acde:	66 48 0f 6e c9       	movq   %rcx,%xmm1
  40ace3:	f3 0f 58 c1          	addss  %xmm1,%xmm0
  40ace7:	49 89 c6             	mov    %rax,%r14
  40acea:	66 48 0f 7e c0       	movq   %xmm0,%rax
  40acef:	89 c1                	mov    %eax,%ecx
  40acf1:	48 89 8d d8 fd ff ff 	mov    %rcx,-0x228(%rbp)
  40acf8:	f3 0f 10 0d 44 83 02 00 	movss  0x28344(%rip),%xmm1        # 433044 <_IO_stdin_used+0x44>
  40ad00:	f3 0f 10 05 34 83 02 00 	movss  0x28334(%rip),%xmm0        # 43303c <_IO_stdin_used+0x3c>
  40ad08:	49 89 ff             	mov    %rdi,%r15
  40ad0b:	e8 40 b0 ff ff       	callq  405d50 <p126_typed_FID_36_100_105_114_101_99_116_46_102_108_>
  40ad10:	4c 89 ff             	mov    %r15,%rdi
  40ad13:	49 89 c0             	mov    %rax,%r8
  40ad16:	4c 89 f0             	mov    %r14,%rax
  40ad19:	48 8b b5 c8 fd ff ff 	mov    -0x238(%rbp),%rsi
  40ad20:	48 8b 8d d8 fd ff ff 	mov    -0x228(%rbp),%rcx
  40ad27:	48 8b 95 d0 fd ff ff 	mov    -0x230(%rbp),%rdx
  40ad2e:	f3 0f 10 ad ec fd ff ff 	movss  -0x214(%rbp),%xmm5
  40ad36:	f3 0f 10 8d e8 fd ff ff 	movss  -0x218(%rbp),%xmm1
  40ad3e:	f3 0f 10 a5 e4 fd ff ff 	movss  -0x21c(%rbp),%xmm4
  40ad46:	f3 0f 10 9d e0 fd ff ff 	movss  -0x220(%rbp),%xmm3
  40ad4e:	f3 0f 10 85 c4 fd ff ff 	movss  -0x23c(%rbp),%xmm0
  40ad56:	4c 89 85 70 f5 ff ff 	mov    %r8,-0xa90(%rbp)
  40ad5d:	4c 89 ad 78 f5 ff ff 	mov    %r13,-0xa88(%rbp)
  40ad64:	66 49 0f 6e d0       	movq   %r8,%xmm2
  40ad69:	f3 0f 59 ca          	mulss  %xmm2,%xmm1
  40ad6d:	66 49 0f 7e c8       	movq   %xmm1,%r8
  40ad72:	45 89 c0             	mov    %r8d,%r8d
  40ad75:	4c 89 a5 70 f5 ff ff 	mov    %r12,-0xa90(%rbp)
  40ad7c:	4c 89 85 78 f5 ff ff 	mov    %r8,-0xa88(%rbp)
  40ad83:	66 49 0f 6e c8       	movq   %r8,%xmm1
  40ad88:	f3 0f 58 c1          	addss  %xmm1,%xmm0
  40ad8c:	49 89 c5             	mov    %rax,%r13
  40ad8f:	66 48 0f 7e c0       	movq   %xmm0,%rax
  40ad94:	89 c0                	mov    %eax,%eax
  40ad96:	48 c7 85 70 f5 ff ff 00 ca 9a 3b 	movq   $0x3b9aca00,-0xa90(%rbp)
  40ada1:	48 c7 85 70 f5 ff ff 00 ca 9a 3b 	movq   $0x3b9aca00,-0xa90(%rbp)
  40adac:	66 48 0f 6e c2       	movq   %rdx,%xmm0
  40adb1:	66 48 0f 6e c9       	movq   %rcx,%xmm1
  40adb6:	66 48 0f 6e d0       	movq   %rax,%xmm2
  40adbb:	41 b8 00 00 00 00    	mov    $0x0,%r8d
  40adc1:	b9 28 6b 6e 4e       	mov    $0x4e6e6b28,%ecx
  40adc6:	ba 28 6b 6e 4e       	mov    $0x4e6e6b28,%edx
  40adcb:	49 89 f7             	mov    %rsi,%r15
  40adce:	be 09 00 00 00       	mov    $0x9,%esi
  40add3:	49 89 fc             	mov    %rdi,%r12
  40add6:	e8 25 c0 ff ff       	callq  406e00 <p126_typed_FID_36_100_105_114_101_99_116_46_110_101_97_114_101_115_116_46_116_>
  40addb:	4c 89 e7             	mov    %r12,%rdi
  40adde:	48 89 85 b8 fd ff ff 	mov    %rax,-0x248(%rbp)
  40ade5:	f3 0f 10 0d 53 82 02 00 	movss  0x28253(%rip),%xmm1        # 433040 <_IO_stdin_used+0x40>
  40aded:	f3 0f 10 05 47 82 02 00 	movss  0x28247(%rip),%xmm0        # 43303c <_IO_stdin_used+0x3c>
  40adf5:	49 89 fc             	mov    %rdi,%r12
  40adf8:	e8 53 af ff ff       	callq  405d50 <p126_typed_FID_36_100_105_114_101_99_116_46_102_108_>
  40adfd:	4c 89 e7             	mov    %r12,%rdi
  40ae00:	49 89 c4             	mov    %rax,%r12
  40ae03:	f3 0f 10 0d 2d 82 02 00 	movss  0x2822d(%rip),%xmm1        # 433038 <_IO_stdin_used+0x38>
  40ae0b:	f3 0f 10 05 21 82 02 00 	movss  0x28221(%rip),%xmm0        # 433034 <_IO_stdin_used+0x34>
  40ae13:	49 89 fe             	mov    %rdi,%r14
  40ae16:	e8 35 af ff ff       	callq  405d50 <p126_typed_FID_36_100_105_114_101_99_116_46_102_108_>
  40ae1b:	4c 89 fe             	mov    %r15,%rsi
  40ae1e:	4c 89 f7             	mov    %r14,%rdi
  40ae21:	49 95                	xchg   %rax,%r13
  40ae23:	49 89 c6             	mov    %rax,%r14
  40ae26:	48 8b 85 b8 fd ff ff 	mov    -0x248(%rbp),%rax
  40ae2d:	f3 0f 10 8d c0 fd ff ff 	movss  -0x240(%rbp),%xmm1
  40ae35:	66 48 0f 6e c0       	movq   %rax,%xmm0
  40ae3a:	e8 a1 b5 ff ff       	callq  4063e0 <p126_typed_FID_36_100_105_114_101_99_116_46_115_104_97_100_101_>
  40ae3f:	48 89 c1             	mov    %rax,%rcx
  40ae42:	4c 89 f0             	mov    %r14,%rax
  40ae45:	f3 0f 10 8d b4 fd ff ff 	movss  -0x24c(%rbp),%xmm1
  40ae4d:	f3 0f 10 95 b0 fd ff ff 	movss  -0x250(%rbp),%xmm2
  40ae55:	4c 89 ad 70 f5 ff ff 	mov    %r13,-0xa90(%rbp)
  40ae5c:	48 89 8d 78 f5 ff ff 	mov    %rcx,-0xa88(%rbp)
  40ae63:	66 49 0f 6e c5       	movq   %r13,%xmm0
  40ae68:	66 48 0f 6e d9       	movq   %rcx,%xmm3
  40ae6d:	f3 0f 59 c3          	mulss  %xmm3,%xmm0
  40ae71:	66 48 0f 7e c1       	movq   %xmm0,%rcx
  40ae76:	89 c9                	mov    %ecx,%ecx
  40ae78:	4c 89 a5 70 f5 ff ff 	mov    %r12,-0xa90(%rbp)
  40ae7f:	48 89 8d 78 f5 ff ff 	mov    %rcx,-0xa88(%rbp)
  40ae86:	66 49 0f 6e c4       	movq   %r12,%xmm0
  40ae8b:	66 48 0f 6e d9       	movq   %rcx,%xmm3
  40ae90:	f3 0f 58 c3          	addss  %xmm3,%xmm0
  40ae94:	66 48 0f 7e c1       	movq   %xmm0,%rcx
  40ae99:	89 c9                	mov    %ecx,%ecx
  40ae9b:	48 89 9d 70 f5 ff ff 	mov    %rbx,-0xa90(%rbp)
  40aea2:	48 89 8d 78 f5 ff ff 	mov    %rcx,-0xa88(%rbp)
  40aea9:	66 48 0f 6e c1       	movq   %rcx,%xmm0
  40aeae:	f3 0f 59 c2          	mulss  %xmm2,%xmm0
  40aeb2:	48 89 c3             	mov    %rax,%rbx
  40aeb5:	66 48 0f 7e c0       	movq   %xmm0,%rax
  40aeba:	89 c0                	mov    %eax,%eax
  40aebc:	48 89 9d 70 f5 ff ff 	mov    %rbx,-0xa90(%rbp)
  40aec3:	48 89 85 78 f5 ff ff 	mov    %rax,-0xa88(%rbp)
  40aeca:	66 48 0f 6e c0       	movq   %rax,%xmm0
  40aecf:	f3 0f 58 c1          	addss  %xmm1,%xmm0
  40aed3:	66 48 0f 7e c0       	movq   %xmm0,%rax
  40aed8:	89 c0                	mov    %eax,%eax
  40aeda:	41 5f                	pop    %r15
  40aedc:	41 5e                	pop    %r14
  40aede:	41 5d                	pop    %r13
  40aee0:	41 5c                	pop    %r12
  40aee2:	5b                   	pop    %rbx
  40aee3:	c9                   	leaveq 
  40aee4:	c3                   	retq   
  40aee5:	66 66 2e 0f 1f 84 00 00 00 00 00 	data16 nopw %cs:0x0(%rax,%rax,1)

