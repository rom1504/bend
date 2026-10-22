00000000004094a0 <p113d_FID_36_100_105_114_101_99_116_46_116_114_97_99_101_>:
  4094a0:	f3 0f 1e fa          	endbr64 
  4094a4:	55                   	push   %rbp
  4094a5:	48 89 e5             	mov    %rsp,%rbp
  4094a8:	48 81 ec 98 0a 00 00 	sub    $0xa98,%rsp
  4094af:	53                   	push   %rbx
  4094b0:	41 54                	push   %r12
  4094b2:	41 55                	push   %r13
  4094b4:	41 56                	push   %r14
  4094b6:	41 57                	push   %r15
  4094b8:	48 8b 5d 30          	mov    0x30(%rbp),%rbx
  4094bc:	48 89 9d e8 fe ff ff 	mov    %rbx,-0x118(%rbp)
  4094c3:	48 8b 45 28          	mov    0x28(%rbp),%rax
  4094c7:	4c 8b 75 20          	mov    0x20(%rbp),%r14
  4094cb:	4c 8b 65 18          	mov    0x18(%rbp),%r12
  4094cf:	4c 8b 7d 10          	mov    0x10(%rbp),%r15
  4094d3:	4d 89 c2             	mov    %r8,%r10
  4094d6:	4d 89 c8             	mov    %r9,%r8
  4094d9:	49 89 cb             	mov    %rcx,%r11
  4094dc:	48 87 d6             	xchg   %rdx,%rsi
  4094df:	4c 87 e2             	xchg   %r12,%rdx
  4094e2:	4c 89 85 a8 fe ff ff 	mov    %r8,-0x158(%rbp)
  4094e9:	4c 89 95 c0 fe ff ff 	mov    %r10,-0x140(%rbp)
  4094f0:	4c 89 9d d0 fe ff ff 	mov    %r11,-0x130(%rbp)
  4094f7:	4c 89 a5 40 ff ff ff 	mov    %r12,-0xc0(%rbp)
  4094fe:	49 83 fc 00          	cmp    $0x0,%r12
  409502:	0f 94 c1             	sete   %cl
  409505:	0f b6 c9             	movzbl %cl,%ecx
  409508:	66 49 0f 6e f7       	movq   %r15,%xmm6
  40950d:	f3 0f 11 b5 e4 fe ff ff 	movss  %xmm6,-0x11c(%rbp)
  409515:	66 49 0f 6e cb       	movq   %r11,%xmm1
  40951a:	f3 0f 11 8d f8 fe ff ff 	movss  %xmm1,-0x108(%rbp)
  409522:	66 48 0f 6e ea       	movq   %rdx,%xmm5
  409527:	f3 0f 11 ad f0 fe ff ff 	movss  %xmm5,-0x110(%rbp)
  40952f:	66 49 0f 6e d2       	movq   %r10,%xmm2
  409534:	f3 0f 11 95 fc fe ff ff 	movss  %xmm2,-0x104(%rbp)
  40953c:	66 49 0f 6e e6       	movq   %r14,%xmm4
  409541:	f3 0f 11 a5 f4 fe ff ff 	movss  %xmm4,-0x10c(%rbp)
  409549:	66 49 0f 6e d8       	movq   %r8,%xmm3
  40954e:	f3 0f 11 9d 00 ff ff ff 	movss  %xmm3,-0x100(%rbp)
  409556:	66 48 0f 6e d3       	movq   %rbx,%xmm2
  40955b:	f3 0f 11 95 b0 fd ff ff 	movss  %xmm2,-0x250(%rbp)
  409563:	66 48 0f 6e c8       	movq   %rax,%xmm1
  409568:	f3 0f 11 8d b4 fd ff ff 	movss  %xmm1,-0x24c(%rbp)
  409570:	48 89 c3             	mov    %rax,%rbx
  409573:	48 89 f0             	mov    %rsi,%rax
  409576:	48 c1 e8 28          	shr    $0x28,%rax
  40957a:	48 25 ff ff 00 00    	and    $0xffff,%rax
  409580:	41 b8 00 00 00 41    	mov    $0x41000000,%r8d
  409586:	4c 89 85 58 fe ff ff 	mov    %r8,-0x1a8(%rbp)
  40958d:	41 b8 cd cc 4c 3e    	mov    $0x3e4ccccd,%r8d
  409593:	4c 89 85 90 fe ff ff 	mov    %r8,-0x170(%rbp)
  40959a:	41 b8 00 00 60 c0    	mov    $0xc0600000,%r8d
  4095a0:	4c 89 85 a0 fe ff ff 	mov    %r8,-0x160(%rbp)
  4095a7:	41 ba 00 00 80 3f    	mov    $0x3f800000,%r10d
  4095ad:	4c 89 95 d8 fe ff ff 	mov    %r10,-0x128(%rbp)
  4095b4:	83 f9 00             	cmp    $0x0,%ecx
  4095b7:	0f 85 b3 0d 00 00    	jne    40a370 <p113d_FID_36_100_105_114_101_99_116_46_116_114_97_99_101_+0xed0>
  4095bd:	0f 1f 00             	nopl   (%rax)
  4095c0:	48 3d 97 00 00 00    	cmp    $0x97,%rax
  4095c6:	74 14                	je     4095dc <p113d_FID_36_100_105_114_101_99_116_46_116_114_97_99_101_+0x13c>
  4095c8:	be 04 00 00 00       	mov    $0x4,%esi
  4095cd:	e8 ce 19 02 00       	callq  42afa0 <p111_rt_fail>
  4095d2:	b8 00 00 00 00       	mov    $0x0,%eax
  4095d7:	e9 1e 1a 00 00       	jmpq   40affa <p113d_FID_36_100_105_114_101_99_116_46_116_114_97_99_101_+0x1b5a>
  4095dc:	49 89 d5             	mov    %rdx,%r13
  4095df:	48 8d 95 70 f5 ff ff 	lea    -0xa90(%rbp),%rdx
  4095e6:	49 89 fc             	mov    %rdi,%r12
  4095e9:	e8 32 6c 02 00       	callq  430220 <p125_rt_take3>
  4095ee:	4c 89 ea             	mov    %r13,%rdx
  4095f1:	4c 89 e7             	mov    %r12,%rdi
  4095f4:	48 89 d8             	mov    %rbx,%rax
  4095f7:	48 8b 8d 70 f5 ff ff 	mov    -0xa90(%rbp),%rcx
  4095fe:	49 89 d5             	mov    %rdx,%r13
  409601:	48 8b 95 78 f5 ff ff 	mov    -0xa88(%rbp),%rdx
  409608:	48 89 55 f0          	mov    %rdx,-0x10(%rbp)
  40960c:	48 8b b5 80 f5 ff ff 	mov    -0xa80(%rbp),%rsi
  409613:	48 89 b5 50 ff ff ff 	mov    %rsi,-0xb0(%rbp)
  40961a:	48 83 f9 01          	cmp    $0x1,%rcx
  40961e:	48 89 c3             	mov    %rax,%rbx
  409621:	0f 94 c0             	sete   %al
  409624:	0f b6 c0             	movzbl %al,%eax
  409627:	48 c1 e9 28          	shr    $0x28,%rcx
  40962b:	48 81 e1 ff ff 7f 00 	and    $0x7fffff,%rcx
  409632:	48 81 f9 02 00 01 00 	cmp    $0x10002,%rcx
  409639:	0f 94 c1             	sete   %cl
  40963c:	0f b6 c9             	movzbl %cl,%ecx
  40963f:	09 c8                	or     %ecx,%eax
  409641:	0f 85 1e 0d 00 00    	jne    40a365 <p113d_FID_36_100_105_114_101_99_116_46_116_114_97_99_101_+0xec5>
  409647:	83 f0 01             	xor    $0x1,%eax
  40964a:	75 19                	jne    409665 <p113d_FID_36_100_105_114_101_99_116_46_116_114_97_99_101_+0x1c5>
  40964c:	2e 2e 2e 2e 2e be 04 00 00 00 	cs cs cs cs cs mov $0x4,%esi
  409656:	e8 45 19 02 00       	callq  42afa0 <p111_rt_fail>
  40965b:	b8 00 00 00 00       	mov    $0x0,%eax
  409660:	e9 95 19 00 00       	jmpq   40affa <p113d_FID_36_100_105_114_101_99_116_46_116_114_97_99_101_+0x1b5a>
  409665:	2e 2e 2e 2e 49 89 fc 	cs cs cs cs mov %rdi,%r12
  40966c:	e8 cf cd ff ff       	callq  406440 <p113d_FID_36_100_105_114_101_99_116_46_115_114_>
  409671:	2e 4d 89 f9          	cs mov %r15,%r9
  409675:	4c 89 e7             	mov    %r12,%rdi
  409678:	48 89 45 e0          	mov    %rax,-0x20(%rbp)
  40967c:	48 89 d8             	mov    %rbx,%rax
  40967f:	f3 0f 10 9d 00 ff ff ff 	movss  -0x100(%rbp),%xmm3
  409687:	f3 0f 10 a5 f4 fe ff ff 	movss  -0x10c(%rbp),%xmm4
  40968f:	f3 0f 10 95 fc fe ff ff 	movss  -0x104(%rbp),%xmm2
  409697:	f3 0f 10 ad f0 fe ff ff 	movss  -0x110(%rbp),%xmm5
  40969f:	f3 0f 10 8d f8 fe ff ff 	movss  -0x108(%rbp),%xmm1
  4096a7:	f3 0f 10 b5 e4 fe ff ff 	movss  -0x11c(%rbp),%xmm6
  4096af:	48 8b b5 50 ff ff ff 	mov    -0xb0(%rbp),%rsi
  4096b6:	48 8b 4d f0          	mov    -0x10(%rbp),%rcx
  4096ba:	48 8b 95 a8 fe ff ff 	mov    -0x158(%rbp),%rdx
  4096c1:	4c 8b 95 c0 fe ff ff 	mov    -0x140(%rbp),%r10
  4096c8:	4c 8b 9d d0 fe ff ff 	mov    -0x130(%rbp),%r11
  4096cf:	48 89 8d 70 f5 ff ff 	mov    %rcx,-0xa90(%rbp)
  4096d6:	4c 89 8d 78 f5 ff ff 	mov    %r9,-0xa88(%rbp)
  4096dd:	66 48 0f 6e c1       	movq   %rcx,%xmm0
  4096e2:	f3 0f 59 f0          	mulss  %xmm0,%xmm6
  4096e6:	66 49 0f 7e f0       	movq   %xmm6,%r8
  4096eb:	45 89 c0             	mov    %r8d,%r8d
  4096ee:	4c 89 9d 70 f5 ff ff 	mov    %r11,-0xa90(%rbp)
  4096f5:	4c 89 85 78 f5 ff ff 	mov    %r8,-0xa88(%rbp)
  4096fc:	66 49 0f 6e f0       	movq   %r8,%xmm6
  409701:	f3 0f 58 ce          	addss  %xmm6,%xmm1
  409705:	66 49 0f 7e c8       	movq   %xmm1,%r8
  40970a:	45 89 c0             	mov    %r8d,%r8d
  40970d:	4c 89 45 b0          	mov    %r8,-0x50(%rbp)
  409711:	48 89 8d 70 f5 ff ff 	mov    %rcx,-0xa90(%rbp)
  409718:	4c 89 ad 78 f5 ff ff 	mov    %r13,-0xa88(%rbp)
  40971f:	f3 0f 10 c8          	movss  %xmm0,%xmm1
  409723:	f3 0f 59 cd          	mulss  %xmm5,%xmm1
  409727:	66 49 0f 7e c8       	movq   %xmm1,%r8
  40972c:	45 89 c0             	mov    %r8d,%r8d
  40972f:	4c 89 95 70 f5 ff ff 	mov    %r10,-0xa90(%rbp)
  409736:	4c 89 85 78 f5 ff ff 	mov    %r8,-0xa88(%rbp)
  40973d:	66 49 0f 6e c8       	movq   %r8,%xmm1
  409742:	f3 0f 58 ca          	addss  %xmm2,%xmm1
  409746:	66 49 0f 7e c8       	movq   %xmm1,%r8
  40974b:	45 89 c0             	mov    %r8d,%r8d
  40974e:	4c 89 45 a8          	mov    %r8,-0x58(%rbp)
  409752:	48 89 8d 70 f5 ff ff 	mov    %rcx,-0xa90(%rbp)
  409759:	4c 89 b5 78 f5 ff ff 	mov    %r14,-0xa88(%rbp)
  409760:	f3 0f 59 c4          	mulss  %xmm4,%xmm0
  409764:	66 48 0f 7e c1       	movq   %xmm0,%rcx
  409769:	89 c9                	mov    %ecx,%ecx
  40976b:	48 89 95 70 f5 ff ff 	mov    %rdx,-0xa90(%rbp)
  409772:	48 89 8d 78 f5 ff ff 	mov    %rcx,-0xa88(%rbp)
  409779:	66 48 0f 6e c1       	movq   %rcx,%xmm0
  40977e:	f3 0f 58 c3          	addss  %xmm3,%xmm0
  409782:	48 89 c3             	mov    %rax,%rbx
  409785:	66 48 0f 7e c0       	movq   %xmm0,%rax
  40978a:	4d 89 cf             	mov    %r9,%r15
  40978d:	41 89 c1             	mov    %eax,%r9d
  409790:	4c 89 4d 80          	mov    %r9,-0x80(%rbp)
  409794:	49 89 fc             	mov    %rdi,%r12
  409797:	e8 14 cf ff ff       	callq  4066b0 <p113d_FID_36_100_105_114_101_99_116_46_115_120_>
  40979c:	4c 89 ea             	mov    %r13,%rdx
  40979f:	4c 89 e7             	mov    %r12,%rdi
  4097a2:	48 89 c1             	mov    %rax,%rcx
  4097a5:	48 89 d8             	mov    %rbx,%rax
  4097a8:	49 89 d5             	mov    %rdx,%r13
  4097ab:	48 8b 55 b0          	mov    -0x50(%rbp),%rdx
  4097af:	4c 8b 55 e0          	mov    -0x20(%rbp),%r10
  4097b3:	48 8b b5 50 ff ff ff 	mov    -0xb0(%rbp),%rsi
  4097ba:	48 89 95 70 f5 ff ff 	mov    %rdx,-0xa90(%rbp)
  4097c1:	48 89 8d 78 f5 ff ff 	mov    %rcx,-0xa88(%rbp)
  4097c8:	66 48 0f 6e c2       	movq   %rdx,%xmm0
  4097cd:	f3 0f 11 45 b8       	movss  %xmm0,-0x48(%rbp)
  4097d2:	66 48 0f 6e c9       	movq   %rcx,%xmm1
  4097d7:	f3 0f 5c c1          	subss  %xmm1,%xmm0
  4097db:	66 48 0f 7e c1       	movq   %xmm0,%rcx
  4097e0:	89 c9                	mov    %ecx,%ecx
  4097e2:	48 89 8d 70 f5 ff ff 	mov    %rcx,-0xa90(%rbp)
  4097e9:	4c 89 95 78 f5 ff ff 	mov    %r10,-0xa88(%rbp)
  4097f0:	66 48 0f 6e c1       	movq   %rcx,%xmm0
  4097f5:	66 49 0f 6e e2       	movq   %r10,%xmm4
  4097fa:	f3 0f 11 65 e8       	movss  %xmm4,-0x18(%rbp)
  4097ff:	f3 0f 5e c4          	divss  %xmm4,%xmm0
  409803:	48 89 c3             	mov    %rax,%rbx
  409806:	66 48 0f 7e c0       	movq   %xmm0,%rax
  40980b:	89 c0                	mov    %eax,%eax
  40980d:	48 89 85 28 ff ff ff 	mov    %rax,-0xd8(%rbp)
  409814:	49 89 fc             	mov    %rdi,%r12
  409817:	e8 c4 cd ff ff       	callq  4065e0 <p113d_FID_36_100_105_114_101_99_116_46_115_121_>
  40981c:	4d 89 f9             	mov    %r15,%r9
  40981f:	4c 89 ea             	mov    %r13,%rdx
  409822:	4c 89 e7             	mov    %r12,%rdi
  409825:	48 89 c1             	mov    %rax,%rcx
  409828:	48 89 d8             	mov    %rbx,%rax
  40982b:	49 89 d5             	mov    %rdx,%r13
  40982e:	48 8b 55 a8          	mov    -0x58(%rbp),%rdx
  409832:	f3 0f 10 65 e8       	movss  -0x18(%rbp),%xmm4
  409837:	4c 8b 55 e0          	mov    -0x20(%rbp),%r10
  40983b:	48 8b b5 50 ff ff ff 	mov    -0xb0(%rbp),%rsi
  409842:	48 89 95 70 f5 ff ff 	mov    %rdx,-0xa90(%rbp)
  409849:	48 89 8d 78 f5 ff ff 	mov    %rcx,-0xa88(%rbp)
  409850:	66 48 0f 6e c2       	movq   %rdx,%xmm0
  409855:	f3 0f 11 45 a4       	movss  %xmm0,-0x5c(%rbp)
  40985a:	f3 0f 10 c8          	movss  %xmm0,%xmm1
  40985e:	66 48 0f 6e c1       	movq   %rcx,%xmm0
  409863:	0f 57 05 a6 77 02 00 	xorps  0x277a6(%rip),%xmm0        # 431010 <_IO_stdin_used+0x10>
  40986a:	f3 0f 58 c1          	addss  %xmm1,%xmm0
  40986e:	66 48 0f 7e c1       	movq   %xmm0,%rcx
  409873:	89 c9                	mov    %ecx,%ecx
  409875:	48 89 8d 70 f5 ff ff 	mov    %rcx,-0xa90(%rbp)
  40987c:	4c 89 95 78 f5 ff ff 	mov    %r10,-0xa88(%rbp)
  409883:	66 48 0f 6e c1       	movq   %rcx,%xmm0
  409888:	f3 0f 5e c4          	divss  %xmm4,%xmm0
  40988c:	48 89 c3             	mov    %rax,%rbx
  40988f:	66 48 0f 7e c0       	movq   %xmm0,%rax
  409894:	4d 89 cf             	mov    %r9,%r15
  409897:	41 89 c1             	mov    %eax,%r9d
  40989a:	4c 89 8d 30 ff ff ff 	mov    %r9,-0xd0(%rbp)
  4098a1:	49 89 fc             	mov    %rdi,%r12
  4098a4:	e8 67 cc ff ff       	callq  406510 <p113d_FID_36_100_105_114_101_99_116_46_115_122_>
  4098a9:	4d 89 f9             	mov    %r15,%r9
  4098ac:	4c 89 ea             	mov    %r13,%rdx
  4098af:	4c 89 e7             	mov    %r12,%rdi
  4098b2:	49 89 c0             	mov    %rax,%r8
  4098b5:	48 89 d8             	mov    %rbx,%rax
  4098b8:	4d 89 cf             	mov    %r9,%r15
  4098bb:	4c 8b 4d 80          	mov    -0x80(%rbp),%r9
  4098bf:	48 8b 4d a8          	mov    -0x58(%rbp),%rcx
  4098c3:	48 8b 75 b0          	mov    -0x50(%rbp),%rsi
  4098c7:	f3 0f 10 4d a4       	movss  -0x5c(%rbp),%xmm1
  4098cc:	f3 0f 10 65 e8       	movss  -0x18(%rbp),%xmm4
  4098d1:	f3 0f 10 45 b8       	movss  -0x48(%rbp),%xmm0
  4098d6:	4c 8b 55 e0          	mov    -0x20(%rbp),%r10
  4098da:	4c 89 8d 70 f5 ff ff 	mov    %r9,-0xa90(%rbp)
  4098e1:	4c 89 85 78 f5 ff ff 	mov    %r8,-0xa88(%rbp)
  4098e8:	f3 0f 10 d0          	movss  %xmm0,%xmm2
  4098ec:	66 49 0f 6e c1       	movq   %r9,%xmm0
  4098f1:	f3 0f 11 85 7c ff ff ff 	movss  %xmm0,-0x84(%rbp)
  4098f9:	66 49 0f 6e d8       	movq   %r8,%xmm3
  4098fe:	0f 57 1d 0b 77 02 00 	xorps  0x2770b(%rip),%xmm3        # 431010 <_IO_stdin_used+0x10>
  409905:	f3 0f 58 d8          	addss  %xmm0,%xmm3
  409909:	66 49 0f 7e d8       	movq   %xmm3,%r8
  40990e:	45 89 c0             	mov    %r8d,%r8d
  409911:	4c 89 85 70 f5 ff ff 	mov    %r8,-0xa90(%rbp)
  409918:	4c 89 95 78 f5 ff ff 	mov    %r10,-0xa88(%rbp)
  40991f:	66 49 0f 6e d8       	movq   %r8,%xmm3
  409924:	f3 0f 5e dc          	divss  %xmm4,%xmm3
  409928:	66 49 0f 7e d8       	movq   %xmm3,%r8
  40992d:	45 89 c0             	mov    %r8d,%r8d
  409930:	4c 89 85 38 ff ff ff 	mov    %r8,-0xc8(%rbp)
  409937:	48 c7 85 70 f5 ff ff 00 00 00 00 	movq   $0x0,-0xa90(%rbp)
  409942:	48 c7 85 70 f5 ff ff 03 00 00 00 	movq   $0x3,-0xa90(%rbp)
  40994d:	48 c7 85 70 f5 ff ff 00 00 00 00 	movq   $0x0,-0xa90(%rbp)
  409958:	48 c7 85 78 f5 ff ff 00 00 40 40 	movq   $0x40400000,-0xa88(%rbp)
  409963:	41 b8 00 00 40 c0    	mov    $0xc0400000,%r8d
  409969:	4c 89 85 70 f5 ff ff 	mov    %r8,-0xa90(%rbp)
  409970:	48 89 b5 78 f5 ff ff 	mov    %rsi,-0xa88(%rbp)
  409977:	0f 57 15 92 76 02 00 	xorps  0x27692(%rip),%xmm2        # 431010 <_IO_stdin_used+0x10>
  40997e:	f3 0f 58 15 aa 76 02 00 	addss  0x276aa(%rip),%xmm2        # 431030 <_IO_stdin_used+0x30>
  409986:	66 48 0f 7e d6       	movq   %xmm2,%rsi
  40998b:	41 89 f0             	mov    %esi,%r8d
  40998e:	4c 89 45 c0          	mov    %r8,-0x40(%rbp)
  409992:	48 c7 85 70 f5 ff ff 08 00 00 00 	movq   $0x8,-0xa90(%rbp)
  40999d:	48 c7 85 70 f5 ff ff 00 00 00 41 	movq   $0x41000000,-0xa90(%rbp)
  4099a8:	48 89 8d 78 f5 ff ff 	mov    %rcx,-0xa88(%rbp)
  4099af:	0f 57 0d 5a 76 02 00 	xorps  0x2765a(%rip),%xmm1        # 431010 <_IO_stdin_used+0x10>
  4099b6:	f3 0f 58 0d 6e 76 02 00 	addss  0x2766e(%rip),%xmm1        # 43102c <_IO_stdin_used+0x2c>
  4099be:	66 48 0f 7e c9       	movq   %xmm1,%rcx
  4099c3:	41 89 cb             	mov    %ecx,%r11d
  4099c6:	4c 89 5d c8          	mov    %r11,-0x38(%rbp)
  4099ca:	48 c7 85 70 f5 ff ff 01 00 00 00 	movq   $0x1,-0xa90(%rbp)
  4099d5:	48 c7 85 70 f5 ff ff 00 00 80 3f 	movq   $0x3f800000,-0xa90(%rbp)
  4099e0:	4c 89 8d 78 f5 ff ff 	mov    %r9,-0xa88(%rbp)
  4099e7:	0f 57 05 22 76 02 00 	xorps  0x27622(%rip),%xmm0        # 431010 <_IO_stdin_used+0x10>
  4099ee:	f3 0f 58 05 2a 76 02 00 	addss  0x2762a(%rip),%xmm0        # 431020 <_IO_stdin_used+0x20>
  4099f6:	66 48 0f 7e c1       	movq   %xmm0,%rcx
  4099fb:	89 cb                	mov    %ecx,%ebx
  4099fd:	48 89 5d d0          	mov    %rbx,-0x30(%rbp)
  409a01:	4c 89 85 70 f5 ff ff 	mov    %r8,-0xa90(%rbp)
  409a08:	4c 89 85 78 f5 ff ff 	mov    %r8,-0xa88(%rbp)
  409a0f:	66 49 0f 6e d8       	movq   %r8,%xmm3
  409a14:	f3 0f 11 5d bc       	movss  %xmm3,-0x44(%rbp)
  409a19:	f3 0f 10 c3          	movss  %xmm3,%xmm0
  409a1d:	f3 0f 59 c3          	mulss  %xmm3,%xmm0
  409a21:	66 48 0f 7e c1       	movq   %xmm0,%rcx
  409a26:	89 ce                	mov    %ecx,%esi
  409a28:	4c 89 9d 70 f5 ff ff 	mov    %r11,-0xa90(%rbp)
  409a2f:	4c 89 9d 78 f5 ff ff 	mov    %r11,-0xa88(%rbp)
  409a36:	66 49 0f 6e d3       	movq   %r11,%xmm2
  409a3b:	f3 0f 11 55 d8       	movss  %xmm2,-0x28(%rbp)
  409a40:	f3 0f 10 c2          	movss  %xmm2,%xmm0
  409a44:	f3 0f 59 c2          	mulss  %xmm2,%xmm0
  409a48:	66 48 0f 7e c1       	movq   %xmm0,%rcx
  409a4d:	89 c9                	mov    %ecx,%ecx
  409a4f:	48 89 b5 70 f5 ff ff 	mov    %rsi,-0xa90(%rbp)
  409a56:	48 89 8d 78 f5 ff ff 	mov    %rcx,-0xa88(%rbp)
  409a5d:	66 48 0f 6e c6       	movq   %rsi,%xmm0
  409a62:	66 48 0f 6e c9       	movq   %rcx,%xmm1
  409a67:	f3 0f 58 c1          	addss  %xmm1,%xmm0
  409a6b:	66 48 0f 7e c1       	movq   %xmm0,%rcx
  409a70:	89 ce                	mov    %ecx,%esi
  409a72:	48 89 9d 70 f5 ff ff 	mov    %rbx,-0xa90(%rbp)
  409a79:	48 89 9d 78 f5 ff ff 	mov    %rbx,-0xa88(%rbp)
  409a80:	66 48 0f 6e c3       	movq   %rbx,%xmm0
  409a85:	f3 0f 11 45 dc       	movss  %xmm0,-0x24(%rbp)
  409a8a:	f3 0f 59 c0          	mulss  %xmm0,%xmm0
  409a8e:	66 48 0f 7e c1       	movq   %xmm0,%rcx
  409a93:	89 c9                	mov    %ecx,%ecx
  409a95:	48 89 b5 70 f5 ff ff 	mov    %rsi,-0xa90(%rbp)
  409a9c:	48 89 8d 78 f5 ff ff 	mov    %rcx,-0xa88(%rbp)
  409aa3:	66 48 0f 6e c6       	movq   %rsi,%xmm0
  409aa8:	66 48 0f 6e c9       	movq   %rcx,%xmm1
  409aad:	f3 0f 58 c1          	addss  %xmm1,%xmm0
  409ab1:	48 89 c3             	mov    %rax,%rbx
  409ab4:	66 48 0f 7e c0       	movq   %xmm0,%rax
  409ab9:	89 c0                	mov    %eax,%eax
  409abb:	48 89 85 70 f5 ff ff 	mov    %rax,-0xa90(%rbp)
  409ac2:	b9 01 00 00 00       	mov    $0x1,%ecx
  409ac7:	49 89 d5             	mov    %rdx,%r13
  409aca:	48 8d 95 70 f5 ff ff 	lea    -0xa90(%rbp),%rdx
  409ad1:	be 24 00 00 00       	mov    $0x24,%esi
  409ad6:	49 89 fc             	mov    %rdi,%r12
  409ad9:	e8 e2 14 02 00       	callq  42afc0 <p111_rt_op>
  409ade:	4d 89 f9             	mov    %r15,%r9
  409ae1:	4c 89 ea             	mov    %r13,%rdx
  409ae4:	4c 89 e7             	mov    %r12,%rdi
  409ae7:	49 89 c2             	mov    %rax,%r10
  409aea:	48 89 d8             	mov    %rbx,%rax
  409aed:	48 8b 5d d0          	mov    -0x30(%rbp),%rbx
  409af1:	4c 8b 5d c8          	mov    -0x38(%rbp),%r11
  409af5:	4c 8b 45 c0          	mov    -0x40(%rbp),%r8
  409af9:	48 8b 8d 38 ff ff ff 	mov    -0xc8(%rbp),%rcx
  409b00:	4d 89 cf             	mov    %r9,%r15
  409b03:	4c 8b 8d 30 ff ff ff 	mov    -0xd0(%rbp),%r9
  409b0a:	48 8b b5 28 ff ff ff 	mov    -0xd8(%rbp),%rsi
  409b11:	f3 0f 10 45 dc       	movss  -0x24(%rbp),%xmm0
  409b16:	f3 0f 10 55 d8       	movss  -0x28(%rbp),%xmm2
  409b1b:	f3 0f 10 5d bc       	movss  -0x44(%rbp),%xmm3
  409b20:	4c 89 85 70 f5 ff ff 	mov    %r8,-0xa90(%rbp)
  409b27:	4c 89 95 78 f5 ff ff 	mov    %r10,-0xa88(%rbp)
  409b2e:	66 49 0f 6e ca       	movq   %r10,%xmm1
  409b33:	f3 0f 11 8d 78 ff ff ff 	movss  %xmm1,-0x88(%rbp)
  409b3b:	f3 0f 5e d9          	divss  %xmm1,%xmm3
  409b3f:	66 49 0f 7e d8       	movq   %xmm3,%r8
  409b44:	45 89 c0             	mov    %r8d,%r8d
  409b47:	4c 89 9d 70 f5 ff ff 	mov    %r11,-0xa90(%rbp)
  409b4e:	4c 89 95 78 f5 ff ff 	mov    %r10,-0xa88(%rbp)
  409b55:	f3 0f 5e d1          	divss  %xmm1,%xmm2
  409b59:	49 89 f3             	mov    %rsi,%r11
  409b5c:	66 48 0f 7e d6       	movq   %xmm2,%rsi
  409b61:	89 f6                	mov    %esi,%esi
  409b63:	48 89 9d 70 f5 ff ff 	mov    %rbx,-0xa90(%rbp)
  409b6a:	4c 89 95 78 f5 ff ff 	mov    %r10,-0xa88(%rbp)
  409b71:	f3 0f 5e c1          	divss  %xmm1,%xmm0
  409b75:	49 89 ca             	mov    %rcx,%r10
  409b78:	66 48 0f 7e c1       	movq   %xmm0,%rcx
  409b7d:	89 c9                	mov    %ecx,%ecx
  409b7f:	4c 89 9d 70 f5 ff ff 	mov    %r11,-0xa90(%rbp)
  409b86:	4c 89 85 78 f5 ff ff 	mov    %r8,-0xa88(%rbp)
  409b8d:	66 4d 0f 6e cb       	movq   %r11,%xmm9
  409b92:	f3 44 0f 11 8d 24 ff ff ff 	movss  %xmm9,-0xdc(%rbp)
  409b9b:	66 49 0f 6e d8       	movq   %r8,%xmm3
  409ba0:	f3 0f 11 5d 98       	movss  %xmm3,-0x68(%rbp)
  409ba5:	f3 41 0f 10 c1       	movss  %xmm9,%xmm0
  409baa:	f3 0f 59 c3          	mulss  %xmm3,%xmm0
  409bae:	66 49 0f 7e c0       	movq   %xmm0,%r8
  409bb3:	45 89 c0             	mov    %r8d,%r8d
  409bb6:	4c 89 8d 70 f5 ff ff 	mov    %r9,-0xa90(%rbp)
  409bbd:	48 89 b5 78 f5 ff ff 	mov    %rsi,-0xa88(%rbp)
  409bc4:	66 49 0f 6e f9       	movq   %r9,%xmm7
  409bc9:	f3 0f 11 bd 48 ff ff ff 	movss  %xmm7,-0xb8(%rbp)
  409bd1:	66 48 0f 6e e6       	movq   %rsi,%xmm4
  409bd6:	f3 0f 11 65 9c       	movss  %xmm4,-0x64(%rbp)
  409bdb:	f3 0f 10 c7          	movss  %xmm7,%xmm0
  409bdf:	f3 0f 59 c4          	mulss  %xmm4,%xmm0
  409be3:	66 48 0f 7e c6       	movq   %xmm0,%rsi
  409be8:	89 f6                	mov    %esi,%esi
  409bea:	4c 89 85 70 f5 ff ff 	mov    %r8,-0xa90(%rbp)
  409bf1:	48 89 b5 78 f5 ff ff 	mov    %rsi,-0xa88(%rbp)
  409bf8:	66 49 0f 6e c0       	movq   %r8,%xmm0
  409bfd:	66 48 0f 6e ce       	movq   %rsi,%xmm1
  409c02:	f3 0f 58 c1          	addss  %xmm1,%xmm0
  409c06:	49 89 d5             	mov    %rdx,%r13
  409c09:	66 48 0f 7e c2       	movq   %xmm0,%rdx
  409c0e:	89 d2                	mov    %edx,%edx
  409c10:	4c 89 95 70 f5 ff ff 	mov    %r10,-0xa90(%rbp)
  409c17:	48 89 8d 78 f5 ff ff 	mov    %rcx,-0xa88(%rbp)
  409c1e:	66 49 0f 6e ca       	movq   %r10,%xmm1
  409c23:	f3 0f 11 8d 4c ff ff ff 	movss  %xmm1,-0xb4(%rbp)
  409c2b:	66 48 0f 6e e9       	movq   %rcx,%xmm5
  409c30:	f3 0f 11 6d a0       	movss  %xmm5,-0x60(%rbp)
  409c35:	f3 0f 10 c1          	movss  %xmm1,%xmm0
  409c39:	f3 0f 59 c5          	mulss  %xmm5,%xmm0
  409c3d:	66 48 0f 7e c1       	movq   %xmm0,%rcx
  409c42:	89 c9                	mov    %ecx,%ecx
  409c44:	48 89 95 70 f5 ff ff 	mov    %rdx,-0xa90(%rbp)
  409c4b:	48 89 8d 78 f5 ff ff 	mov    %rcx,-0xa88(%rbp)
  409c52:	66 48 0f 6e c2       	movq   %rdx,%xmm0
  409c57:	66 48 0f 6e c9       	movq   %rcx,%xmm1
  409c5c:	f3 0f 58 c1          	addss  %xmm1,%xmm0
  409c60:	48 89 c3             	mov    %rax,%rbx
  409c63:	66 48 0f 7e c0       	movq   %xmm0,%rax
  409c68:	89 c6                	mov    %eax,%esi
  409c6a:	49 89 fc             	mov    %rdi,%r12
  409c6d:	e8 4e c0 ff ff       	callq  405cc0 <p113d_FID_36_100_105_114_101_99_116_46_102_109_97_120_48_>
  409c72:	4c 89 e7             	mov    %r12,%rdi
  409c75:	48 89 85 68 ff ff ff 	mov    %rax,-0x98(%rbp)
  409c7c:	f3 0f 10 0d c0 73 02 00 	movss  0x273c0(%rip),%xmm1        # 431044 <_IO_stdin_used+0x44>
  409c84:	f3 0f 10 05 b0 73 02 00 	movss  0x273b0(%rip),%xmm0        # 43103c <_IO_stdin_used+0x3c>
  409c8c:	49 89 fc             	mov    %rdi,%r12
  409c8f:	e8 bc c0 ff ff       	callq  405d50 <p126_typed_FID_36_100_105_114_101_99_116_46_102_108_>
  409c94:	4c 89 ea             	mov    %r13,%rdx
  409c97:	4c 89 e7             	mov    %r12,%rdi
  409c9a:	48 89 c1             	mov    %rax,%rcx
  409c9d:	48 89 d8             	mov    %rbx,%rax
  409ca0:	48 8b b5 28 ff ff ff 	mov    -0xd8(%rbp),%rsi
  409ca7:	49 89 d5             	mov    %rdx,%r13
  409caa:	48 8b 55 b0          	mov    -0x50(%rbp),%rdx
  409cae:	f3 44 0f 10 8d 24 ff ff ff 	movss  -0xdc(%rbp),%xmm9
  409cb7:	f3 0f 10 45 b8       	movss  -0x48(%rbp),%xmm0
  409cbc:	48 89 8d 70 f5 ff ff 	mov    %rcx,-0xa90(%rbp)
  409cc3:	48 89 b5 78 f5 ff ff 	mov    %rsi,-0xa88(%rbp)
  409cca:	66 48 0f 6e c9       	movq   %rcx,%xmm1
  409ccf:	f3 41 0f 59 c9       	mulss  %xmm9,%xmm1
  409cd4:	66 48 0f 7e c9       	movq   %xmm1,%rcx
  409cd9:	89 c9                	mov    %ecx,%ecx
  409cdb:	48 89 95 70 f5 ff ff 	mov    %rdx,-0xa90(%rbp)
  409ce2:	48 89 8d 78 f5 ff ff 	mov    %rcx,-0xa88(%rbp)
  409ce9:	66 48 0f 6e c9       	movq   %rcx,%xmm1
  409cee:	f3 0f 58 c1          	addss  %xmm1,%xmm0
  409cf2:	48 89 c3             	mov    %rax,%rbx
  409cf5:	66 48 0f 7e c0       	movq   %xmm0,%rax
  409cfa:	89 c6                	mov    %eax,%esi
  409cfc:	48 89 75 88          	mov    %rsi,-0x78(%rbp)
  409d00:	f3 0f 10 0d 3c 73 02 00 	movss  0x2733c(%rip),%xmm1        # 431044 <_IO_stdin_used+0x44>
  409d08:	f3 0f 10 05 2c 73 02 00 	movss  0x2732c(%rip),%xmm0        # 43103c <_IO_stdin_used+0x3c>
  409d10:	49 89 fc             	mov    %rdi,%r12
  409d13:	e8 38 c0 ff ff       	callq  405d50 <p126_typed_FID_36_100_105_114_101_99_116_46_102_108_>
  409d18:	4d 89 f9             	mov    %r15,%r9
  409d1b:	4c 89 ea             	mov    %r13,%rdx
  409d1e:	4c 89 e7             	mov    %r12,%rdi
  409d21:	48 89 c1             	mov    %rax,%rcx
  409d24:	48 89 d8             	mov    %rbx,%rax
  409d27:	4d 89 cf             	mov    %r9,%r15
  409d2a:	4c 8b 8d 30 ff ff ff 	mov    -0xd0(%rbp),%r9
  409d31:	49 89 d5             	mov    %rdx,%r13
  409d34:	48 8b 55 a8          	mov    -0x58(%rbp),%rdx
  409d38:	f3 0f 10 bd 48 ff ff ff 	movss  -0xb8(%rbp),%xmm7
  409d40:	f3 0f 10 45 a4       	movss  -0x5c(%rbp),%xmm0
  409d45:	48 89 8d 70 f5 ff ff 	mov    %rcx,-0xa90(%rbp)
  409d4c:	4c 89 8d 78 f5 ff ff 	mov    %r9,-0xa88(%rbp)
  409d53:	66 48 0f 6e c9       	movq   %rcx,%xmm1
  409d58:	f3 0f 59 cf          	mulss  %xmm7,%xmm1
  409d5c:	66 48 0f 7e c9       	movq   %xmm1,%rcx
  409d61:	89 c9                	mov    %ecx,%ecx
  409d63:	48 89 95 70 f5 ff ff 	mov    %rdx,-0xa90(%rbp)
  409d6a:	48 89 8d 78 f5 ff ff 	mov    %rcx,-0xa88(%rbp)
  409d71:	66 48 0f 6e c9       	movq   %rcx,%xmm1
  409d76:	f3 0f 58 c1          	addss  %xmm1,%xmm0
  409d7a:	48 89 c3             	mov    %rax,%rbx
  409d7d:	66 48 0f 7e c0       	movq   %xmm0,%rax
  409d82:	89 c1                	mov    %eax,%ecx
  409d84:	48 89 4d 90          	mov    %rcx,-0x70(%rbp)
  409d88:	f3 0f 10 0d b4 72 02 00 	movss  0x272b4(%rip),%xmm1        # 431044 <_IO_stdin_used+0x44>
  409d90:	f3 0f 10 05 a4 72 02 00 	movss  0x272a4(%rip),%xmm0        # 43103c <_IO_stdin_used+0x3c>
  409d98:	49 89 fc             	mov    %rdi,%r12
  409d9b:	e8 b0 bf ff ff       	callq  405d50 <p126_typed_FID_36_100_105_114_101_99_116_46_102_108_>
  409da0:	4d 89 f9             	mov    %r15,%r9
  409da3:	4c 89 ea             	mov    %r13,%rdx
  409da6:	4c 89 e7             	mov    %r12,%rdi
  409da9:	49 89 c0             	mov    %rax,%r8
  409dac:	48 89 d8             	mov    %rbx,%rax
  409daf:	48 8b 4d 90          	mov    -0x70(%rbp),%rcx
  409db3:	48 8b 75 88          	mov    -0x78(%rbp),%rsi
  409db7:	4c 8b 95 38 ff ff ff 	mov    -0xc8(%rbp),%r10
  409dbe:	4d 89 cf             	mov    %r9,%r15
  409dc1:	4c 8b 4d 80          	mov    -0x80(%rbp),%r9
  409dc5:	f3 0f 10 6d a0       	movss  -0x60(%rbp),%xmm5
  409dca:	f3 0f 10 8d 4c ff ff ff 	movss  -0xb4(%rbp),%xmm1
  409dd2:	f3 0f 10 65 9c       	movss  -0x64(%rbp),%xmm4
  409dd7:	f3 0f 10 5d 98       	movss  -0x68(%rbp),%xmm3
  409ddc:	f3 0f 10 85 7c ff ff ff 	movss  -0x84(%rbp),%xmm0
  409de4:	4c 89 85 70 f5 ff ff 	mov    %r8,-0xa90(%rbp)
  409deb:	4c 89 95 78 f5 ff ff 	mov    %r10,-0xa88(%rbp)
  409df2:	66 49 0f 6e d0       	movq   %r8,%xmm2
  409df7:	f3 0f 59 ca          	mulss  %xmm2,%xmm1
  409dfb:	66 49 0f 7e c8       	movq   %xmm1,%r8
  409e00:	45 89 c0             	mov    %r8d,%r8d
  409e03:	4c 89 8d 70 f5 ff ff 	mov    %r9,-0xa90(%rbp)
  409e0a:	4c 89 85 78 f5 ff ff 	mov    %r8,-0xa88(%rbp)
  409e11:	66 49 0f 6e c8       	movq   %r8,%xmm1
  409e16:	f3 0f 58 c1          	addss  %xmm1,%xmm0
  409e1a:	48 89 c3             	mov    %rax,%rbx
  409e1d:	66 48 0f 7e c0       	movq   %xmm0,%rax
  409e22:	89 c0                	mov    %eax,%eax
  409e24:	48 c7 85 70 f5 ff ff 00 ca 9a 3b 	movq   $0x3b9aca00,-0xa90(%rbp)
  409e2f:	48 c7 85 70 f5 ff ff 00 ca 9a 3b 	movq   $0x3b9aca00,-0xa90(%rbp)
  409e3a:	66 48 0f 6e c6       	movq   %rsi,%xmm0
  409e3f:	f3 0f 11 85 04 ff ff ff 	movss  %xmm0,-0xfc(%rbp)
  409e47:	66 48 0f 6e d1       	movq   %rcx,%xmm2
  409e4c:	f3 0f 11 95 10 ff ff ff 	movss  %xmm2,-0xf0(%rbp)
  409e54:	f3 0f 10 ca          	movss  %xmm2,%xmm1
  409e58:	66 48 0f 6e d0       	movq   %rax,%xmm2
  409e5d:	f3 0f 11 95 14 ff ff ff 	movss  %xmm2,-0xec(%rbp)
  409e65:	41 b8 00 00 00 00    	mov    $0x0,%r8d
  409e6b:	b9 28 6b 6e 4e       	mov    $0x4e6e6b28,%ecx
  409e70:	49 89 d5             	mov    %rdx,%r13
  409e73:	ba 28 6b 6e 4e       	mov    $0x4e6e6b28,%edx
  409e78:	be 09 00 00 00       	mov    $0x9,%esi
  409e7d:	49 89 fc             	mov    %rdi,%r12
  409e80:	e8 7b cf ff ff       	callq  406e00 <p126_typed_FID_36_100_105_114_101_99_116_46_110_101_97_114_101_115_116_46_116_>
  409e85:	4c 89 e7             	mov    %r12,%rdi
  409e88:	48 89 85 70 ff ff ff 	mov    %rax,-0x90(%rbp)
  409e8f:	f3 0f 10 0d a9 71 02 00 	movss  0x271a9(%rip),%xmm1        # 431040 <_IO_stdin_used+0x40>
  409e97:	f3 0f 10 05 9d 71 02 00 	movss  0x2719d(%rip),%xmm0        # 43103c <_IO_stdin_used+0x3c>
  409e9f:	49 89 fc             	mov    %rdi,%r12
  409ea2:	e8 a9 be ff ff       	callq  405d50 <p126_typed_FID_36_100_105_114_101_99_116_46_102_108_>
  409ea7:	4c 89 e7             	mov    %r12,%rdi
  409eaa:	48 89 85 58 ff ff ff 	mov    %rax,-0xa8(%rbp)
  409eb1:	f3 0f 10 0d 7f 71 02 00 	movss  0x2717f(%rip),%xmm1        # 431038 <_IO_stdin_used+0x38>
  409eb9:	f3 0f 10 05 73 71 02 00 	movss  0x27173(%rip),%xmm0        # 431034 <_IO_stdin_used+0x34>
  409ec1:	49 89 fc             	mov    %rdi,%r12
  409ec4:	e8 87 be ff ff       	callq  405d50 <p126_typed_FID_36_100_105_114_101_99_116_46_102_108_>
  409ec9:	4c 89 e7             	mov    %r12,%rdi
  409ecc:	48 89 85 60 ff ff ff 	mov    %rax,-0xa0(%rbp)
  409ed3:	48 89 d8             	mov    %rbx,%rax
  409ed6:	48 89 c3             	mov    %rax,%rbx
  409ed9:	48 8b 85 70 ff ff ff 	mov    -0x90(%rbp),%rax
  409ee0:	48 8b b5 68 ff ff ff 	mov    -0x98(%rbp),%rsi
  409ee7:	f3 0f 10 8d 78 ff ff ff 	movss  -0x88(%rbp),%xmm1
  409eef:	66 48 0f 6e c0       	movq   %rax,%xmm0
  409ef4:	49 89 fc             	mov    %rdi,%r12
  409ef7:	e8 e4 c4 ff ff       	callq  4063e0 <p126_typed_FID_36_100_105_114_101_99_116_46_115_104_97_100_101_>
  409efc:	4c 89 ea             	mov    %r13,%rdx
  409eff:	4c 89 e7             	mov    %r12,%rdi
  409f02:	48 89 c1             	mov    %rax,%rcx
  409f05:	48 89 d8             	mov    %rbx,%rax
  409f08:	4c 8b 85 60 ff ff ff 	mov    -0xa0(%rbp),%r8
  409f0f:	49 89 d5             	mov    %rdx,%r13
  409f12:	48 8b 95 58 ff ff ff 	mov    -0xa8(%rbp),%rdx
  409f19:	48 8b b5 50 ff ff ff 	mov    -0xb0(%rbp),%rsi
  409f20:	4c 89 85 70 f5 ff ff 	mov    %r8,-0xa90(%rbp)
  409f27:	48 89 8d 78 f5 ff ff 	mov    %rcx,-0xa88(%rbp)
  409f2e:	66 49 0f 6e c0       	movq   %r8,%xmm0
  409f33:	66 48 0f 6e c9       	movq   %rcx,%xmm1
  409f38:	f3 0f 59 c1          	mulss  %xmm1,%xmm0
  409f3c:	66 48 0f 7e c1       	movq   %xmm0,%rcx
  409f41:	89 c9                	mov    %ecx,%ecx
  409f43:	48 89 95 70 f5 ff ff 	mov    %rdx,-0xa90(%rbp)
  409f4a:	48 89 8d 78 f5 ff ff 	mov    %rcx,-0xa88(%rbp)
  409f51:	66 48 0f 6e c2       	movq   %rdx,%xmm0
  409f56:	66 48 0f 6e c9       	movq   %rcx,%xmm1
  409f5b:	f3 0f 58 c1          	addss  %xmm1,%xmm0
  409f5f:	48 89 c3             	mov    %rax,%rbx
  409f62:	66 48 0f 7e c0       	movq   %xmm0,%rax
  409f67:	41 89 c0             	mov    %eax,%r8d
  409f6a:	4c 89 85 08 ff ff ff 	mov    %r8,-0xf8(%rbp)
  409f71:	49 89 fc             	mov    %rdi,%r12
  409f74:	e8 77 c3 ff ff       	callq  4062f0 <p113d_FID_36_100_105_114_101_99_116_46_115_107_114_>
  409f79:	4d 89 f9             	mov    %r15,%r9
  409f7c:	4c 89 ea             	mov    %r13,%rdx
  409f7f:	4c 89 e7             	mov    %r12,%rdi
  409f82:	49 89 c4             	mov    %rax,%r12
  409f85:	48 89 d8             	mov    %rbx,%rax
  409f88:	48 8b 8d 38 ff ff ff 	mov    -0xc8(%rbp),%rcx
  409f8f:	4d 89 cf             	mov    %r9,%r15
  409f92:	4c 8b 8d 30 ff ff ff 	mov    -0xd0(%rbp),%r9
  409f99:	48 8b b5 28 ff ff ff 	mov    -0xd8(%rbp),%rsi
  409fa0:	f3 0f 10 9d 14 ff ff ff 	movss  -0xec(%rbp),%xmm3
  409fa8:	f3 0f 10 95 10 ff ff ff 	movss  -0xf0(%rbp),%xmm2
  409fb0:	f3 0f 10 8d 04 ff ff ff 	movss  -0xfc(%rbp),%xmm1
  409fb8:	f3 0f 10 c1          	movss  %xmm1,%xmm0
  409fbc:	f3 0f 10 8d 4c ff ff ff 	movss  -0xb4(%rbp),%xmm1
  409fc4:	f3 0f 10 bd 48 ff ff ff 	movss  -0xb8(%rbp),%xmm7
  409fcc:	f3 44 0f 10 8d 24 ff ff ff 	movss  -0xdc(%rbp),%xmm9
  409fd5:	f3 0f 10 a5 f4 fe ff ff 	movss  -0x10c(%rbp),%xmm4
  409fdd:	f3 0f 10 ad f0 fe ff ff 	movss  -0x110(%rbp),%xmm5
  409fe5:	f3 0f 10 b5 e4 fe ff ff 	movss  -0x11c(%rbp),%xmm6
  409fed:	48 8b 9d e8 fe ff ff 	mov    -0x118(%rbp),%rbx
  409ff4:	49 89 dd             	mov    %rbx,%r13
  409ff7:	48 8b 9d 40 ff ff ff 	mov    -0xc0(%rbp),%rbx
  409ffe:	48 c7 85 70 f5 ff ff 02 00 00 00 	movq   $0x2,-0xa90(%rbp)
  40a009:	4c 89 bd 70 f5 ff ff 	mov    %r15,-0xa90(%rbp)
  40a010:	48 89 b5 78 f5 ff ff 	mov    %rsi,-0xa88(%rbp)
  40a017:	f3 44 0f 10 c6       	movss  %xmm6,%xmm8
  40a01c:	f3 45 0f 59 c1       	mulss  %xmm9,%xmm8
  40a021:	66 4d 0f 7e c0       	movq   %xmm8,%r8
  40a026:	45 89 c2             	mov    %r8d,%r10d
  40a029:	48 89 95 70 f5 ff ff 	mov    %rdx,-0xa90(%rbp)
  40a030:	4c 89 8d 78 f5 ff ff 	mov    %r9,-0xa88(%rbp)
  40a037:	f3 44 0f 10 c5       	movss  %xmm5,%xmm8
  40a03c:	f3 44 0f 59 c7       	mulss  %xmm7,%xmm8
  40a041:	66 4d 0f 7e c0       	movq   %xmm8,%r8
  40a046:	45 89 c0             	mov    %r8d,%r8d
  40a049:	4c 89 95 70 f5 ff ff 	mov    %r10,-0xa90(%rbp)
  40a050:	4c 89 85 78 f5 ff ff 	mov    %r8,-0xa88(%rbp)
  40a057:	66 4d 0f 6e c2       	movq   %r10,%xmm8
  40a05c:	66 4d 0f 6e d0       	movq   %r8,%xmm10
  40a061:	f3 45 0f 58 c2       	addss  %xmm10,%xmm8
  40a066:	66 4d 0f 7e c0       	movq   %xmm8,%r8
  40a06b:	45 89 c2             	mov    %r8d,%r10d
  40a06e:	4c 89 b5 70 f5 ff ff 	mov    %r14,-0xa90(%rbp)
  40a075:	48 89 8d 78 f5 ff ff 	mov    %rcx,-0xa88(%rbp)
  40a07c:	f3 44 0f 10 c4       	movss  %xmm4,%xmm8
  40a081:	f3 44 0f 59 c1       	mulss  %xmm1,%xmm8
  40a086:	66 4d 0f 7e c0       	movq   %xmm8,%r8
  40a08b:	45 89 c0             	mov    %r8d,%r8d
  40a08e:	4c 89 95 70 f5 ff ff 	mov    %r10,-0xa90(%rbp)
  40a095:	4c 89 85 78 f5 ff ff 	mov    %r8,-0xa88(%rbp)
  40a09c:	66 4d 0f 6e c2       	movq   %r10,%xmm8
  40a0a1:	66 4d 0f 6e d0       	movq   %r8,%xmm10
  40a0a6:	f3 45 0f 58 c2       	addss  %xmm10,%xmm8
  40a0ab:	66 4d 0f 7e c0       	movq   %xmm8,%r8
  40a0b0:	45 89 c0             	mov    %r8d,%r8d
  40a0b3:	48 c7 85 70 f5 ff ff 00 00 00 40 	movq   $0x40000000,-0xa90(%rbp)
  40a0be:	4c 89 85 78 f5 ff ff 	mov    %r8,-0xa88(%rbp)
  40a0c5:	f3 44 0f 10 c6       	movss  %xmm6,%xmm8
  40a0ca:	66 49 0f 6e f0       	movq   %r8,%xmm6
  40a0cf:	f3 0f 59 35 71 6f 02 00 	mulss  0x26f71(%rip),%xmm6        # 431048 <_IO_stdin_used+0x48>
  40a0d7:	66 49 0f 7e f0       	movq   %xmm6,%r8
  40a0dc:	45 89 c0             	mov    %r8d,%r8d
  40a0df:	4c 89 85 70 f5 ff ff 	mov    %r8,-0xa90(%rbp)
  40a0e6:	48 89 b5 78 f5 ff ff 	mov    %rsi,-0xa88(%rbp)
  40a0ed:	f3 0f 10 f5          	movss  %xmm5,%xmm6
  40a0f1:	66 49 0f 6e e8       	movq   %r8,%xmm5
  40a0f6:	f3 44 0f 59 cd       	mulss  %xmm5,%xmm9
  40a0fb:	66 4c 0f 7e ce       	movq   %xmm9,%rsi
  40a100:	89 f6                	mov    %esi,%esi
  40a102:	4c 89 bd 70 f5 ff ff 	mov    %r15,-0xa90(%rbp)
  40a109:	48 89 b5 78 f5 ff ff 	mov    %rsi,-0xa88(%rbp)
  40a110:	66 4c 0f 6e ce       	movq   %rsi,%xmm9
  40a115:	f3 45 0f 5c c1       	subss  %xmm9,%xmm8
  40a11a:	66 4c 0f 7e c6       	movq   %xmm8,%rsi
  40a11f:	89 f6                	mov    %esi,%esi
  40a121:	4c 89 85 70 f5 ff ff 	mov    %r8,-0xa90(%rbp)
  40a128:	4c 89 8d 78 f5 ff ff 	mov    %r9,-0xa88(%rbp)
  40a12f:	f3 0f 59 fd          	mulss  %xmm5,%xmm7
  40a133:	49 89 d7             	mov    %rdx,%r15
  40a136:	66 48 0f 7e fa       	movq   %xmm7,%rdx
  40a13b:	89 d2                	mov    %edx,%edx
  40a13d:	4c 89 bd 70 f5 ff ff 	mov    %r15,-0xa90(%rbp)
  40a144:	48 89 95 78 f5 ff ff 	mov    %rdx,-0xa88(%rbp)
  40a14b:	66 48 0f 6e fa       	movq   %rdx,%xmm7
  40a150:	f3 0f 5c f7          	subss  %xmm7,%xmm6
  40a154:	66 48 0f 7e f2       	movq   %xmm6,%rdx
  40a159:	89 d2                	mov    %edx,%edx
  40a15b:	4c 89 85 70 f5 ff ff 	mov    %r8,-0xa90(%rbp)
  40a162:	48 89 8d 78 f5 ff ff 	mov    %rcx,-0xa88(%rbp)
  40a169:	f3 0f 59 cd          	mulss  %xmm5,%xmm1
  40a16d:	66 48 0f 7e c9       	movq   %xmm1,%rcx
  40a172:	89 c9                	mov    %ecx,%ecx
  40a174:	4c 89 b5 70 f5 ff ff 	mov    %r14,-0xa90(%rbp)
  40a17b:	48 89 8d 78 f5 ff ff 	mov    %rcx,-0xa88(%rbp)
  40a182:	f3 0f 10 ca          	movss  %xmm2,%xmm1
  40a186:	66 48 0f 6e d1       	movq   %rcx,%xmm2
  40a18b:	0f 57 15 7e 6e 02 00 	xorps  0x26e7e(%rip),%xmm2        # 431010 <_IO_stdin_used+0x10>
  40a192:	f3 0f 58 d4          	addss  %xmm4,%xmm2
  40a196:	66 48 0f 7e d1       	movq   %xmm2,%rcx
  40a19b:	89 c9                	mov    %ecx,%ecx
  40a19d:	48 c7 85 70 f5 ff ff 00 ca 9a 3b 	movq   $0x3b9aca00,-0xa90(%rbp)
  40a1a8:	48 c7 85 70 f5 ff ff 00 ca 9a 3b 	movq   $0x3b9aca00,-0xa90(%rbp)
  40a1b3:	f3 0f 10 d3          	movss  %xmm3,%xmm2
  40a1b7:	66 48 0f 6e de       	movq   %rsi,%xmm3
  40a1bc:	f3 0f 11 9d 18 ff ff ff 	movss  %xmm3,-0xe8(%rbp)
  40a1c4:	66 48 0f 6e ea       	movq   %rdx,%xmm5
  40a1c9:	f3 0f 11 ad 1c ff ff ff 	movss  %xmm5,-0xe4(%rbp)
  40a1d1:	66 48 0f 6e f1       	movq   %rcx,%xmm6
  40a1d6:	f3 0f 11 b5 20 ff ff ff 	movss  %xmm6,-0xe0(%rbp)
  40a1de:	49 89 c6             	mov    %rax,%r14
  40a1e1:	48 83 ec 10          	sub    $0x10,%rsp
  40a1e5:	48 89 e0             	mov    %rsp,%rax
  40a1e8:	48 c7 40 08 00 00 00 00 	movq   $0x0,0x8(%rax)
  40a1f0:	48 c7 00 09 00 00 00 	movq   $0x9,(%rax)
  40a1f7:	41 b9 28 6b 6e 4e    	mov    $0x4e6e6b28,%r9d
  40a1fd:	41 b8 09 00 00 00    	mov    $0x9,%r8d
  40a203:	b9 28 6b 6e 4e       	mov    $0x4e6e6b28,%ecx
  40a208:	f3 0f 10 e5          	movss  %xmm5,%xmm4
  40a20c:	f3 0f 10 ee          	movss  %xmm6,%xmm5
  40a210:	ba 09 00 00 00       	mov    $0x9,%edx
  40a215:	48 8d b5 70 fd ff ff 	lea    -0x290(%rbp),%rsi
  40a21c:	49 89 ff             	mov    %rdi,%r15
  40a21f:	e8 dc c5 ff ff       	callq  406800 <p126_typed_FID_36_112_114_111_100_117_99_116_46_110_101_97_114_101_115_116_>
  40a224:	4c 89 ff             	mov    %r15,%rdi
  40a227:	4c 89 f0             	mov    %r14,%rax
  40a22a:	4c 8b 85 08 ff ff ff 	mov    -0xf8(%rbp),%r8
  40a231:	f3 0f 10 8d b4 fd ff ff 	movss  -0x24c(%rbp),%xmm1
  40a239:	f3 0f 10 95 b0 fd ff ff 	movss  -0x250(%rbp),%xmm2
  40a241:	f3 0f 10 b5 20 ff ff ff 	movss  -0xe0(%rbp),%xmm6
  40a249:	f3 0f 10 ad 1c ff ff ff 	movss  -0xe4(%rbp),%xmm5
  40a251:	f3 0f 10 a5 18 ff ff ff 	movss  -0xe8(%rbp),%xmm4
  40a259:	f3 0f 10 9d 14 ff ff ff 	movss  -0xec(%rbp),%xmm3
  40a261:	f3 0f 10 c2          	movss  %xmm2,%xmm0
  40a265:	f3 0f 10 95 10 ff ff ff 	movss  -0xf0(%rbp),%xmm2
  40a26d:	f3 44 0f 10 c1       	movss  %xmm1,%xmm8
  40a272:	f3 0f 10 8d 04 ff ff ff 	movss  -0xfc(%rbp),%xmm1
  40a27a:	48 83 ec f0          	sub    $0xfffffffffffffff0,%rsp
  40a27e:	48 8b 95 70 fd ff ff 	mov    -0x290(%rbp),%rdx
  40a285:	48 8b b5 78 fd ff ff 	mov    -0x288(%rbp),%rsi
  40a28c:	48 8b 8d 80 fd ff ff 	mov    -0x280(%rbp),%rcx
  40a293:	4c 89 ad 70 f5 ff ff 	mov    %r13,-0xa90(%rbp)
  40a29a:	4c 89 85 78 f5 ff ff 	mov    %r8,-0xa88(%rbp)
  40a2a1:	66 49 0f 6e f8       	movq   %r8,%xmm7
  40a2a6:	f3 0f 59 f8          	mulss  %xmm0,%xmm7
  40a2aa:	66 49 0f 7e f8       	movq   %xmm7,%r8
  40a2af:	45 89 c1             	mov    %r8d,%r9d
  40a2b2:	48 c7 85 70 f5 ff ff 01 00 00 00 	movq   $0x1,-0xa90(%rbp)
  40a2bd:	48 c7 85 70 f5 ff ff 00 00 80 3f 	movq   $0x3f800000,-0xa90(%rbp)
  40a2c8:	4c 89 a5 78 f5 ff ff 	mov    %r12,-0xa88(%rbp)
  40a2cf:	66 49 0f 6e fc       	movq   %r12,%xmm7
  40a2d4:	f3 44 0f 10 0d 43 6d 02 00 	movss  0x26d43(%rip),%xmm9        # 431020 <_IO_stdin_used+0x20>
  40a2dd:	f3 44 0f 5c cf       	subss  %xmm7,%xmm9
  40a2e2:	66 4d 0f 7e c8       	movq   %xmm9,%r8
  40a2e7:	45 89 c0             	mov    %r8d,%r8d
  40a2ea:	4c 89 8d 70 f5 ff ff 	mov    %r9,-0xa90(%rbp)
  40a2f1:	4c 89 85 78 f5 ff ff 	mov    %r8,-0xa88(%rbp)
  40a2f8:	66 4d 0f 6e c9       	movq   %r9,%xmm9
  40a2fd:	66 4d 0f 6e d0       	movq   %r8,%xmm10
  40a302:	f3 45 0f 59 ca       	mulss  %xmm10,%xmm9
  40a307:	49 89 c6             	mov    %rax,%r14
  40a30a:	66 4c 0f 7e c8       	movq   %xmm9,%rax
  40a30f:	89 c0                	mov    %eax,%eax
  40a311:	4c 89 b5 70 f5 ff ff 	mov    %r14,-0xa90(%rbp)
  40a318:	48 89 85 78 f5 ff ff 	mov    %rax,-0xa88(%rbp)
  40a31f:	66 4c 0f 6e c8       	movq   %rax,%xmm9
  40a324:	f3 45 0f 58 c1       	addss  %xmm9,%xmm8
  40a329:	66 4c 0f 7e c0       	movq   %xmm8,%rax
  40a32e:	41 89 c0             	mov    %eax,%r8d
  40a331:	4c 89 ad 70 f5 ff ff 	mov    %r13,-0xa90(%rbp)
  40a338:	4c 89 a5 78 f5 ff ff 	mov    %r12,-0xa88(%rbp)
  40a33f:	f3 0f 59 c7          	mulss  %xmm7,%xmm0
  40a343:	66 48 0f 7e c0       	movq   %xmm0,%rax
  40a348:	89 c0                	mov    %eax,%eax
  40a34a:	66 48 0f 6e c6       	movq   %rsi,%xmm0
  40a34f:	66 48 0f 6e f8       	movq   %rax,%xmm7
  40a354:	48 89 de             	mov    %rbx,%rsi
  40a357:	48 83 ee 01          	sub    $0x1,%rsi
  40a35b:	e8 50 d0 ff ff       	callq  4073b0 <p126_typed_FID_36_112_114_111_100_117_99_116_46_116_114_97_99_101_>
  40a360:	e9 95 0c 00 00       	jmpq   40affa <p113d_FID_36_100_105_114_101_99_116_46_116_114_97_99_101_+0x1b5a>
  40a365:	48 89 d8             	mov    %rbx,%rax
  40a368:	48 89 c3             	mov    %rax,%rbx
  40a36b:	e9 8a 0c 00 00       	jmpq   40affa <p113d_FID_36_100_105_114_101_99_116_46_116_114_97_99_101_+0x1b5a>
  40a370:	4d 89 f5             	mov    %r14,%r13
  40a373:	48 3d 97 00 00 00    	cmp    $0x97,%rax
  40a379:	74 14                	je     40a38f <p113d_FID_36_100_105_114_101_99_116_46_116_114_97_99_101_+0xeef>
  40a37b:	be 04 00 00 00       	mov    $0x4,%esi
  40a380:	e8 1b 0c 02 00       	callq  42afa0 <p111_rt_fail>
  40a385:	b8 00 00 00 00       	mov    $0x0,%eax
  40a38a:	e9 6b 0c 00 00       	jmpq   40affa <p113d_FID_36_100_105_114_101_99_116_46_116_114_97_99_101_+0x1b5a>
  40a38f:	49 89 d6             	mov    %rdx,%r14
  40a392:	48 8d 95 70 f5 ff ff 	lea    -0xa90(%rbp),%rdx
  40a399:	49 89 fc             	mov    %rdi,%r12
  40a39c:	e8 7f 5e 02 00       	callq  430220 <p125_rt_take3>
  40a3a1:	4d 89 f9             	mov    %r15,%r9
  40a3a4:	4c 89 f2             	mov    %r14,%rdx
  40a3a7:	4c 89 e7             	mov    %r12,%rdi
  40a3aa:	48 89 d8             	mov    %rbx,%rax
  40a3ad:	f3 0f 10 9d 00 ff ff ff 	movss  -0x100(%rbp),%xmm3
  40a3b5:	f3 0f 10 a5 f4 fe ff ff 	movss  -0x10c(%rbp),%xmm4
  40a3bd:	f3 0f 10 95 fc fe ff ff 	movss  -0x104(%rbp),%xmm2
  40a3c5:	f3 0f 10 ad f0 fe ff ff 	movss  -0x110(%rbp),%xmm5
  40a3cd:	f3 0f 10 8d f8 fe ff ff 	movss  -0x108(%rbp),%xmm1
  40a3d5:	f3 0f 10 b5 e4 fe ff ff 	movss  -0x11c(%rbp),%xmm6
  40a3dd:	48 8b 9d e8 fe ff ff 	mov    -0x118(%rbp),%rbx
  40a3e4:	4c 8b 85 70 f5 ff ff 	mov    -0xa90(%rbp),%r8
  40a3eb:	4c 8b b5 78 f5 ff ff 	mov    -0xa88(%rbp),%r14
  40a3f2:	48 8b b5 80 f5 ff ff 	mov    -0xa80(%rbp),%rsi
  40a3f9:	49 83 f8 01          	cmp    $0x1,%r8
  40a3fd:	0f 94 c1             	sete   %cl
  40a400:	0f b6 c9             	movzbl %cl,%ecx
  40a403:	49 c1 e8 28          	shr    $0x28,%r8
  40a407:	49 81 e0 ff ff 7f 00 	and    $0x7fffff,%r8
  40a40e:	49 81 f8 02 00 01 00 	cmp    $0x10002,%r8
  40a415:	41 0f 94 c0          	sete   %r8b
  40a419:	45 0f b6 c0          	movzbl %r8b,%r8d
  40a41d:	44 09 c1             	or     %r8d,%ecx
  40a420:	0f 85 d4 0b 00 00    	jne    40affa <p113d_FID_36_100_105_114_101_99_116_46_116_114_97_99_101_+0x1b5a>
  40a426:	83 f1 01             	xor    $0x1,%ecx
  40a429:	75 14                	jne    40a43f <p113d_FID_36_100_105_114_101_99_116_46_116_114_97_99_101_+0xf9f>
  40a42b:	be 04 00 00 00       	mov    $0x4,%esi
  40a430:	e8 6b 0b 02 00       	callq  42afa0 <p111_rt_fail>
  40a435:	b8 00 00 00 00       	mov    $0x0,%eax
  40a43a:	e9 bb 0b 00 00       	jmpq   40affa <p113d_FID_36_100_105_114_101_99_116_46_116_114_97_99_101_+0x1b5a>
  40a43f:	48 83 fe 00          	cmp    $0x0,%rsi
  40a443:	0f 94 c1             	sete   %cl
  40a446:	0f b6 c9             	movzbl %cl,%ecx
  40a449:	89 8d e0 fe ff ff    	mov    %ecx,-0x120(%rbp)
  40a44f:	49 89 f0             	mov    %rsi,%r8
  40a452:	49 83 e8 01          	sub    $0x1,%r8
  40a456:	49 89 f7             	mov    %rsi,%r15
  40a459:	49 83 ef 02          	sub    $0x2,%r15
  40a45d:	49 89 f4             	mov    %rsi,%r12
  40a460:	49 83 ec 03          	sub    $0x3,%r12
  40a464:	49 89 f3             	mov    %rsi,%r11
  40a467:	49 83 eb 04          	sub    $0x4,%r11
  40a46b:	49 89 f2             	mov    %rsi,%r10
  40a46e:	49 83 ea 05          	sub    $0x5,%r10
  40a472:	4c 89 95 c8 fe ff ff 	mov    %r10,-0x138(%rbp)
  40a479:	48 89 f1             	mov    %rsi,%rcx
  40a47c:	48 83 e9 06          	sub    $0x6,%rcx
  40a480:	48 89 8d b8 fe ff ff 	mov    %rcx,-0x148(%rbp)
  40a487:	48 89 f1             	mov    %rsi,%rcx
  40a48a:	48 83 e9 07          	sub    $0x7,%rcx
  40a48e:	48 89 8d b0 fe ff ff 	mov    %rcx,-0x150(%rbp)
  40a495:	4c 89 d1             	mov    %r10,%rcx
  40a498:	4c 8b 95 b8 fe ff ff 	mov    -0x148(%rbp),%r10
  40a49f:	83 bd e0 fe ff ff 00 	cmpl   $0x0,-0x120(%rbp)
  40a4a6:	75 73                	jne    40a51b <p113d_FID_36_100_105_114_101_99_116_46_116_114_97_99_101_+0x107b>
  40a4a8:	49 83 f8 00          	cmp    $0x0,%r8
  40a4ac:	74 66                	je     40a514 <p113d_FID_36_100_105_114_101_99_116_46_116_114_97_99_101_+0x1074>
  40a4ae:	49 83 ff 00          	cmp    $0x0,%r15
  40a4b2:	74 59                	je     40a50d <p113d_FID_36_100_105_114_101_99_116_46_116_114_97_99_101_+0x106d>
  40a4b4:	49 83 fc 00          	cmp    $0x0,%r12
  40a4b8:	74 4c                	je     40a506 <p113d_FID_36_100_105_114_101_99_116_46_116_114_97_99_101_+0x1066>
  40a4ba:	66 0f 1f 44 00 00    	nopw   0x0(%rax,%rax,1)
  40a4c0:	49 83 fb 00          	cmp    $0x0,%r11
  40a4c4:	74 39                	je     40a4ff <p113d_FID_36_100_105_114_101_99_116_46_116_114_97_99_101_+0x105f>
  40a4c6:	48 83 f9 00          	cmp    $0x0,%rcx
  40a4ca:	48 8b 8d b0 fe ff ff 	mov    -0x150(%rbp),%rcx
  40a4d1:	74 25                	je     40a4f8 <p113d_FID_36_100_105_114_101_99_116_46_116_114_97_99_101_+0x1058>
  40a4d3:	2e 2e 49 83 fa 00    	cs cs cmp $0x0,%r10
  40a4d9:	4c 8b 95 d8 fe ff ff 	mov    -0x128(%rbp),%r10
  40a4e0:	74 0f                	je     40a4f1 <p113d_FID_36_100_105_114_101_99_116_46_116_114_97_99_101_+0x1051>
  40a4e2:	48 83 f9 00          	cmp    $0x0,%rcx
  40a4e6:	b9 00 00 80 3f       	mov    $0x3f800000,%ecx
  40a4eb:	49 0f 45 ca          	cmovne %r10,%rcx
  40a4ef:	eb 31                	jmp    40a522 <p113d_FID_36_100_105_114_101_99_116_46_116_114_97_99_101_+0x1082>
  40a4f1:	b9 9a 99 99 3f       	mov    $0x3f99999a,%ecx
  40a4f6:	eb 2a                	jmp    40a522 <p113d_FID_36_100_105_114_101_99_116_46_116_114_97_99_101_+0x1082>
  40a4f8:	b9 cd cc cc 3e       	mov    $0x3ecccccd,%ecx
  40a4fd:	eb 23                	jmp    40a522 <p113d_FID_36_100_105_114_101_99_116_46_116_114_97_99_101_+0x1082>
  40a4ff:	b9 cd cc cc 3e       	mov    $0x3ecccccd,%ecx
  40a504:	eb 1c                	jmp    40a522 <p113d_FID_36_100_105_114_101_99_116_46_116_114_97_99_101_+0x1082>
  40a506:	b9 00 00 80 3f       	mov    $0x3f800000,%ecx
  40a50b:	eb 15                	jmp    40a522 <p113d_FID_36_100_105_114_101_99_116_46_116_114_97_99_101_+0x1082>
  40a50d:	b9 00 00 80 3f       	mov    $0x3f800000,%ecx
  40a512:	eb 0e                	jmp    40a522 <p113d_FID_36_100_105_114_101_99_116_46_116_114_97_99_101_+0x1082>
  40a514:	b9 00 00 80 3f       	mov    $0x3f800000,%ecx
  40a519:	eb 07                	jmp    40a522 <p113d_FID_36_100_105_114_101_99_116_46_116_114_97_99_101_+0x1082>
  40a51b:	2e 2e b9 00 40 1c 46 	cs cs mov $0x461c4000,%ecx
  40a522:	4c 89 b5 70 f5 ff ff 	mov    %r14,-0xa90(%rbp)
  40a529:	4c 89 8d 78 f5 ff ff 	mov    %r9,-0xa88(%rbp)
  40a530:	66 49 0f 6e c6       	movq   %r14,%xmm0
  40a535:	f3 0f 59 f0          	mulss  %xmm0,%xmm6
  40a539:	66 49 0f 7e f1       	movq   %xmm6,%r9
  40a53e:	45 89 c9             	mov    %r9d,%r9d
  40a541:	4c 89 8d 98 fe ff ff 	mov    %r9,-0x168(%rbp)
  40a548:	4c 8b 95 c8 fe ff ff 	mov    -0x138(%rbp),%r10
  40a54f:	4c 8b 8d d0 fe ff ff 	mov    -0x130(%rbp),%r9
  40a556:	4c 89 8d 70 f5 ff ff 	mov    %r9,-0xa90(%rbp)
  40a55d:	4c 8b 8d 98 fe ff ff 	mov    -0x168(%rbp),%r9
  40a564:	4c 89 8d 78 f5 ff ff 	mov    %r9,-0xa88(%rbp)
  40a56b:	4c 89 b5 70 f5 ff ff 	mov    %r14,-0xa90(%rbp)
  40a572:	48 89 95 78 f5 ff ff 	mov    %rdx,-0xa88(%rbp)
  40a579:	f3 0f 59 e8          	mulss  %xmm0,%xmm5
  40a57d:	66 48 0f 7e ea       	movq   %xmm5,%rdx
  40a582:	89 d2                	mov    %edx,%edx
  40a584:	48 89 95 88 fe ff ff 	mov    %rdx,-0x178(%rbp)
  40a58b:	4c 8b 8d b8 fe ff ff 	mov    -0x148(%rbp),%r9
  40a592:	48 8b 95 c0 fe ff ff 	mov    -0x140(%rbp),%rdx
  40a599:	48 89 95 70 f5 ff ff 	mov    %rdx,-0xa90(%rbp)
  40a5a0:	48 8b 95 88 fe ff ff 	mov    -0x178(%rbp),%rdx
  40a5a7:	48 89 95 78 f5 ff ff 	mov    %rdx,-0xa88(%rbp)
  40a5ae:	48 8b 95 b0 fe ff ff 	mov    -0x150(%rbp),%rdx
  40a5b5:	4c 89 b5 70 f5 ff ff 	mov    %r14,-0xa90(%rbp)
  40a5bc:	4c 89 ad 78 f5 ff ff 	mov    %r13,-0xa88(%rbp)
  40a5c3:	f3 0f 59 c4          	mulss  %xmm4,%xmm0
  40a5c7:	66 49 0f 7e c5       	movq   %xmm0,%r13
  40a5cc:	45 89 ee             	mov    %r13d,%r14d
  40a5cf:	4c 89 b5 60 fe ff ff 	mov    %r14,-0x1a0(%rbp)
  40a5d6:	4c 8b ad 98 fe ff ff 	mov    -0x168(%rbp),%r13
  40a5dd:	4c 8b b5 a8 fe ff ff 	mov    -0x158(%rbp),%r14
  40a5e4:	4c 89 b5 70 f5 ff ff 	mov    %r14,-0xa90(%rbp)
  40a5eb:	4c 8b b5 60 fe ff ff 	mov    -0x1a0(%rbp),%r14
  40a5f2:	4c 89 b5 78 f5 ff ff 	mov    %r14,-0xa88(%rbp)
  40a5f9:	4c 8b b5 a0 fe ff ff 	mov    -0x160(%rbp),%r14
  40a600:	48 83 fe 00          	cmp    $0x0,%rsi
  40a604:	74 6d                	je     40a673 <p113d_FID_36_100_105_114_101_99_116_46_116_114_97_99_101_+0x11d3>
  40a606:	49 83 f8 00          	cmp    $0x0,%r8
  40a60a:	74 5f                	je     40a66b <p113d_FID_36_100_105_114_101_99_116_46_116_114_97_99_101_+0x11cb>
  40a60c:	49 83 ff 00          	cmp    $0x0,%r15
  40a610:	74 51                	je     40a663 <p113d_FID_36_100_105_114_101_99_116_46_116_114_97_99_101_+0x11c3>
  40a612:	49 83 fc 00          	cmp    $0x0,%r12
  40a616:	74 43                	je     40a65b <p113d_FID_36_100_105_114_101_99_116_46_116_114_97_99_101_+0x11bb>
  40a618:	49 83 fb 00          	cmp    $0x0,%r11
  40a61c:	74 35                	je     40a653 <p113d_FID_36_100_105_114_101_99_116_46_116_114_97_99_101_+0x11b3>
  40a61e:	66 90                	xchg   %ax,%ax
  40a620:	49 83 fa 00          	cmp    $0x0,%r10
  40a624:	74 25                	je     40a64b <p113d_FID_36_100_105_114_101_99_116_46_116_114_97_99_101_+0x11ab>
  40a626:	49 83 f9 00          	cmp    $0x0,%r9
  40a62a:	74 17                	je     40a643 <p113d_FID_36_100_105_114_101_99_116_46_116_114_97_99_101_+0x11a3>
  40a62c:	48 83 fa 00          	cmp    $0x0,%rdx
  40a630:	41 bd 00 00 60 40    	mov    $0x40600000,%r13d
  40a636:	4d 0f 44 f5          	cmove  %r13,%r14
  40a63a:	4c 8b ad 98 fe ff ff 	mov    -0x168(%rbp),%r13
  40a641:	eb 36                	jmp    40a679 <p113d_FID_36_100_105_114_101_99_116_46_116_114_97_99_101_+0x11d9>
  40a643:	41 be 00 00 00 00    	mov    $0x0,%r14d
  40a649:	eb 2e                	jmp    40a679 <p113d_FID_36_100_105_114_101_99_116_46_116_114_97_99_101_+0x11d9>
  40a64b:	41 be 00 00 80 bf    	mov    $0xbf800000,%r14d
  40a651:	eb 26                	jmp    40a679 <p113d_FID_36_100_105_114_101_99_116_46_116_114_97_99_101_+0x11d9>
  40a653:	41 be 00 00 80 3f    	mov    $0x3f800000,%r14d
  40a659:	eb 1e                	jmp    40a679 <p113d_FID_36_100_105_114_101_99_116_46_116_114_97_99_101_+0x11d9>
  40a65b:	41 be 00 00 00 c0    	mov    $0xc0000000,%r14d
  40a661:	eb 16                	jmp    40a679 <p113d_FID_36_100_105_114_101_99_116_46_116_114_97_99_101_+0x11d9>
  40a663:	41 be 00 00 00 40    	mov    $0x40000000,%r14d
  40a669:	eb 0e                	jmp    40a679 <p113d_FID_36_100_105_114_101_99_116_46_116_114_97_99_101_+0x11d9>
  40a66b:	41 be 00 00 00 00    	mov    $0x0,%r14d
  40a671:	eb 06                	jmp    40a679 <p113d_FID_36_100_105_114_101_99_116_46_116_114_97_99_101_+0x11d9>
  40a673:	41 be 00 00 00 00    	mov    $0x0,%r14d
  40a679:	66 49 0f 6e c5       	movq   %r13,%xmm0
  40a67e:	f3 0f 58 c1          	addss  %xmm1,%xmm0
  40a682:	66 49 0f 7e c5       	movq   %xmm0,%r13
  40a687:	45 89 ed             	mov    %r13d,%r13d
  40a68a:	4c 89 ad 80 fe ff ff 	mov    %r13,-0x180(%rbp)
  40a691:	4c 89 ad 70 f5 ff ff 	mov    %r13,-0xa90(%rbp)
  40a698:	4c 89 b5 78 f5 ff ff 	mov    %r14,-0xa88(%rbp)
  40a69f:	66 49 0f 6e c5       	movq   %r13,%xmm0
  40a6a4:	f3 0f 11 85 18 fe ff ff 	movss  %xmm0,-0x1e8(%rbp)
  40a6ac:	66 49 0f 6e ce       	movq   %r14,%xmm1
  40a6b1:	0f 57 0d 58 69 02 00 	xorps  0x26958(%rip),%xmm1        # 431010 <_IO_stdin_used+0x10>
  40a6b8:	f3 0f 58 c8          	addss  %xmm0,%xmm1
  40a6bc:	66 49 0f 7e ce       	movq   %xmm1,%r14
  40a6c1:	45 89 f6             	mov    %r14d,%r14d
  40a6c4:	4c 89 b5 38 fe ff ff 	mov    %r14,-0x1c8(%rbp)
  40a6cb:	4c 89 b5 70 f5 ff ff 	mov    %r14,-0xa90(%rbp)
  40a6d2:	4c 8b b5 88 fe ff ff 	mov    -0x178(%rbp),%r14
  40a6d9:	48 89 8d 78 f5 ff ff 	mov    %rcx,-0xa88(%rbp)
  40a6e0:	48 83 fe 00          	cmp    $0x0,%rsi
  40a6e4:	0f 84 9a 00 00 00    	je     40a784 <p113d_FID_36_100_105_114_101_99_116_46_116_114_97_99_101_+0x12e4>
  40a6ea:	4c 8b b5 90 fe ff ff 	mov    -0x170(%rbp),%r14
  40a6f1:	49 83 f8 00          	cmp    $0x0,%r8
  40a6f5:	74 5b                	je     40a752 <p113d_FID_36_100_105_114_101_99_116_46_116_114_97_99_101_+0x12b2>
  40a6f7:	49 83 ff 00          	cmp    $0x0,%r15
  40a6fb:	74 4d                	je     40a74a <p113d_FID_36_100_105_114_101_99_116_46_116_114_97_99_101_+0x12aa>
  40a6fd:	0f 1f 00             	nopl   (%rax)
  40a700:	49 83 fc 00          	cmp    $0x0,%r12
  40a704:	74 3c                	je     40a742 <p113d_FID_36_100_105_114_101_99_116_46_116_114_97_99_101_+0x12a2>
  40a706:	49 83 fb 00          	cmp    $0x0,%r11
  40a70a:	74 2c                	je     40a738 <p113d_FID_36_100_105_114_101_99_116_46_116_114_97_99_101_+0x1298>
  40a70c:	49 83 fa 00          	cmp    $0x0,%r10
  40a710:	74 1e                	je     40a730 <p113d_FID_36_100_105_114_101_99_116_46_116_114_97_99_101_+0x1290>
  40a712:	49 83 f9 00          	cmp    $0x0,%r9
  40a716:	74 10                	je     40a728 <p113d_FID_36_100_105_114_101_99_116_46_116_114_97_99_101_+0x1288>
  40a718:	48 83 fa 00          	cmp    $0x0,%rdx
  40a71c:	41 bd cd cc 4c 3e    	mov    $0x3e4ccccd,%r13d
  40a722:	4d 0f 45 ee          	cmovne %r14,%r13
  40a726:	eb 30                	jmp    40a758 <p113d_FID_36_100_105_114_101_99_116_46_116_114_97_99_101_+0x12b8>
  40a728:	41 bd cd cc cc 3f    	mov    $0x3fcccccd,%r13d
  40a72e:	eb 28                	jmp    40a758 <p113d_FID_36_100_105_114_101_99_116_46_116_114_97_99_101_+0x12b8>
  40a730:	41 bd 9a 99 19 bf    	mov    $0xbf19999a,%r13d
  40a736:	eb 20                	jmp    40a758 <p113d_FID_36_100_105_114_101_99_116_46_116_114_97_99_101_+0x12b8>
  40a738:	2e 2e 41 bd 9a 99 19 bf 	cs cs mov $0xbf19999a,%r13d
  40a740:	eb 16                	jmp    40a758 <p113d_FID_36_100_105_114_101_99_116_46_116_114_97_99_101_+0x12b8>
  40a742:	41 bd 00 00 00 3f    	mov    $0x3f000000,%r13d
  40a748:	eb 0e                	jmp    40a758 <p113d_FID_36_100_105_114_101_99_116_46_116_114_97_99_101_+0x12b8>
  40a74a:	41 bd 00 00 00 3f    	mov    $0x3f000000,%r13d
  40a750:	eb 06                	jmp    40a758 <p113d_FID_36_100_105_114_101_99_116_46_116_114_97_99_101_+0x12b8>
  40a752:	41 bd 00 00 00 00    	mov    $0x0,%r13d
  40a758:	4d 89 ee             	mov    %r13,%r14
  40a75b:	4c 89 b5 78 fe ff ff 	mov    %r14,-0x188(%rbp)
  40a762:	4c 8b b5 88 fe ff ff 	mov    -0x178(%rbp),%r14
  40a769:	4c 8b ad 80 fe ff ff 	mov    -0x180(%rbp),%r13
  40a770:	f2 44 0f 10 bd 78 fe ff ff 	movsd  -0x188(%rbp),%xmm15
  40a779:	f2 44 0f 11 bd 70 fe ff ff 	movsd  %xmm15,-0x190(%rbp)
  40a782:	eb 15                	jmp    40a799 <p113d_FID_36_100_105_114_101_99_116_46_116_114_97_99_101_+0x12f9>
  40a784:	2e c7 85 70 fe ff ff 00 44 1c c6 	movl   $0xc61c4400,%cs:-0x190(%rbp)
  40a78f:	c7 85 74 fe ff ff 00 00 00 00 	movl   $0x0,-0x18c(%rbp)
  40a799:	66 49 0f 6e ce       	movq   %r14,%xmm1
  40a79e:	f3 0f 58 ca          	addss  %xmm2,%xmm1
  40a7a2:	66 49 0f 7e ce       	movq   %xmm1,%r14
  40a7a7:	45 89 f6             	mov    %r14d,%r14d
  40a7aa:	4c 89 b5 68 fe ff ff 	mov    %r14,-0x198(%rbp)
  40a7b1:	4c 89 b5 70 f5 ff ff 	mov    %r14,-0xa90(%rbp)
  40a7b8:	4c 8b b5 70 fe ff ff 	mov    -0x190(%rbp),%r14
  40a7bf:	4c 89 b5 78 f5 ff ff 	mov    %r14,-0xa88(%rbp)
  40a7c6:	4c 8b b5 68 fe ff ff 	mov    -0x198(%rbp),%r14
  40a7cd:	66 49 0f 6e ce       	movq   %r14,%xmm1
  40a7d2:	f3 0f 11 8d 00 fe ff ff 	movss  %xmm1,-0x200(%rbp)
  40a7da:	4c 8b b5 70 fe ff ff 	mov    -0x190(%rbp),%r14
  40a7e1:	66 49 0f 6e d6       	movq   %r14,%xmm2
  40a7e6:	0f 57 15 23 68 02 00 	xorps  0x26823(%rip),%xmm2        # 431010 <_IO_stdin_used+0x10>
  40a7ed:	f3 0f 58 d1          	addss  %xmm1,%xmm2
  40a7f1:	66 49 0f 7e d6       	movq   %xmm2,%r14
  40a7f6:	45 89 f6             	mov    %r14d,%r14d
  40a7f9:	4c 89 b5 40 fe ff ff 	mov    %r14,-0x1c0(%rbp)
  40a800:	4c 89 b5 70 f5 ff ff 	mov    %r14,-0xa90(%rbp)
  40a807:	4c 8b b5 68 fe ff ff 	mov    -0x198(%rbp),%r14
  40a80e:	48 89 8d 78 f5 ff ff 	mov    %rcx,-0xa88(%rbp)
  40a815:	48 83 fe 00          	cmp    $0x0,%rsi
  40a819:	48 8b b5 60 fe ff ff 	mov    -0x1a0(%rbp),%rsi
  40a820:	74 6a                	je     40a88c <p113d_FID_36_100_105_114_101_99_116_46_116_114_97_99_101_+0x13ec>
  40a822:	49 83 f8 00          	cmp    $0x0,%r8
  40a826:	4c 8b 85 58 fe ff ff 	mov    -0x1a8(%rbp),%r8
  40a82d:	74 56                	je     40a885 <p113d_FID_36_100_105_114_101_99_116_46_116_114_97_99_101_+0x13e5>
  40a82f:	49 83 ff 00          	cmp    $0x0,%r15
  40a833:	74 49                	je     40a87e <p113d_FID_36_100_105_114_101_99_116_46_116_114_97_99_101_+0x13de>
  40a835:	49 83 fc 00          	cmp    $0x0,%r12
  40a839:	74 3c                	je     40a877 <p113d_FID_36_100_105_114_101_99_116_46_116_114_97_99_101_+0x13d7>
  40a83b:	0f 1f 44 00 00       	nopl   0x0(%rax,%rax,1)
  40a840:	49 83 fb 00          	cmp    $0x0,%r11
  40a844:	74 2a                	je     40a870 <p113d_FID_36_100_105_114_101_99_116_46_116_114_97_99_101_+0x13d0>
  40a846:	49 83 fa 00          	cmp    $0x0,%r10
  40a84a:	74 1d                	je     40a869 <p113d_FID_36_100_105_114_101_99_116_46_116_114_97_99_101_+0x13c9>
  40a84c:	49 83 f9 00          	cmp    $0x0,%r9
  40a850:	74 10                	je     40a862 <p113d_FID_36_100_105_114_101_99_116_46_116_114_97_99_101_+0x13c2>
  40a852:	2e 48 83 fa 00       	cs cmp $0x0,%rdx
  40a857:	ba 00 00 00 41       	mov    $0x41000000,%edx
  40a85c:	49 0f 45 d0          	cmovne %r8,%rdx
  40a860:	eb 2f                	jmp    40a891 <p113d_FID_36_100_105_114_101_99_116_46_116_114_97_99_101_+0x13f1>
  40a862:	ba 00 00 e0 40       	mov    $0x40e00000,%edx
  40a867:	eb 28                	jmp    40a891 <p113d_FID_36_100_105_114_101_99_116_46_116_114_97_99_101_+0x13f1>
  40a869:	ba 00 00 60 40       	mov    $0x40600000,%edx
  40a86e:	eb 21                	jmp    40a891 <p113d_FID_36_100_105_114_101_99_116_46_116_114_97_99_101_+0x13f1>
  40a870:	ba 00 00 60 40       	mov    $0x40600000,%edx
  40a875:	eb 1a                	jmp    40a891 <p113d_FID_36_100_105_114_101_99_116_46_116_114_97_99_101_+0x13f1>
  40a877:	ba 00 00 c0 40       	mov    $0x40c00000,%edx
  40a87c:	eb 13                	jmp    40a891 <p113d_FID_36_100_105_114_101_99_116_46_116_114_97_99_101_+0x13f1>
  40a87e:	ba 00 00 c0 40       	mov    $0x40c00000,%edx
  40a883:	eb 0c                	jmp    40a891 <p113d_FID_36_100_105_114_101_99_116_46_116_114_97_99_101_+0x13f1>
  40a885:	ba 00 00 a0 40       	mov    $0x40a00000,%edx
  40a88a:	eb 05                	jmp    40a891 <p113d_FID_36_100_105_114_101_99_116_46_116_114_97_99_101_+0x13f1>
  40a88c:	ba 00 00 a0 40       	mov    $0x40a00000,%edx
  40a891:	66 48 0f 6e d6       	movq   %rsi,%xmm2
  40a896:	f3 0f 58 d3          	addss  %xmm3,%xmm2
  40a89a:	66 48 0f 7e d6       	movq   %xmm2,%rsi
  40a89f:	41 89 f4             	mov    %esi,%r12d
  40a8a2:	4c 89 a5 08 fe ff ff 	mov    %r12,-0x1f8(%rbp)
  40a8a9:	4c 89 a5 70 f5 ff ff 	mov    %r12,-0xa90(%rbp)
  40a8b0:	48 89 95 78 f5 ff ff 	mov    %rdx,-0xa88(%rbp)
  40a8b7:	f3 0f 10 d0          	movss  %xmm0,%xmm2
  40a8bb:	66 49 0f 6e c4       	movq   %r12,%xmm0
  40a8c0:	f3 0f 11 85 c4 fd ff ff 	movss  %xmm0,-0x23c(%rbp)
  40a8c8:	66 48 0f 6e da       	movq   %rdx,%xmm3
  40a8cd:	0f 57 1d 3c 67 02 00 	xorps  0x2673c(%rip),%xmm3        # 431010 <_IO_stdin_used+0x10>
  40a8d4:	f3 0f 58 d8          	addss  %xmm0,%xmm3
  40a8d8:	66 48 0f 7e da       	movq   %xmm3,%rdx
  40a8dd:	89 d2                	mov    %edx,%edx
  40a8df:	48 89 95 70 f5 ff ff 	mov    %rdx,-0xa90(%rbp)
  40a8e6:	48 89 8d 78 f5 ff ff 	mov    %rcx,-0xa88(%rbp)
  40a8ed:	66 48 0f 6e e2       	movq   %rdx,%xmm4
  40a8f2:	66 48 0f 6e d9       	movq   %rcx,%xmm3
  40a8f7:	f3 0f 11 9d 48 fe ff ff 	movss  %xmm3,-0x1b8(%rbp)
  40a8ff:	f3 44 0f 10 fb       	movss  %xmm3,%xmm15
  40a904:	f3 0f 10 dc          	movss  %xmm4,%xmm3
  40a908:	f3 41 0f 5e df       	divss  %xmm15,%xmm3
  40a90d:	66 48 0f 7e d9       	movq   %xmm3,%rcx
  40a912:	4d 89 e7             	mov    %r12,%r15
  40a915:	41 89 cc             	mov    %ecx,%r12d
  40a918:	4c 89 a5 f8 fd ff ff 	mov    %r12,-0x208(%rbp)
  40a91f:	48 c7 85 70 f5 ff ff 00 00 00 00 	movq   $0x0,-0xa90(%rbp)
  40a92a:	48 c7 85 70 f5 ff ff 03 00 00 00 	movq   $0x3,-0xa90(%rbp)
  40a935:	48 c7 85 70 f5 ff ff 00 00 00 00 	movq   $0x0,-0xa90(%rbp)
  40a940:	48 c7 85 78 f5 ff ff 00 00 40 40 	movq   $0x40400000,-0xa88(%rbp)
  40a94b:	b9 00 00 40 c0       	mov    $0xc0400000,%ecx
  40a950:	48 89 8d 70 f5 ff ff 	mov    %rcx,-0xa90(%rbp)
  40a957:	4c 89 ad 78 f5 ff ff 	mov    %r13,-0xa88(%rbp)
  40a95e:	0f 57 15 ab 66 02 00 	xorps  0x266ab(%rip),%xmm2        # 431010 <_IO_stdin_used+0x10>
  40a965:	f3 0f 58 15 c3 66 02 00 	addss  0x266c3(%rip),%xmm2        # 431030 <_IO_stdin_used+0x30>
  40a96d:	66 48 0f 7e d1       	movq   %xmm2,%rcx
  40a972:	41 89 c8             	mov    %ecx,%r8d
  40a975:	4c 89 85 20 fe ff ff 	mov    %r8,-0x1e0(%rbp)
  40a97c:	48 c7 85 70 f5 ff ff 08 00 00 00 	movq   $0x8,-0xa90(%rbp)
  40a987:	48 c7 85 70 f5 ff ff 00 00 00 41 	movq   $0x41000000,-0xa90(%rbp)
  40a992:	4c 89 b5 78 f5 ff ff 	mov    %r14,-0xa88(%rbp)
  40a999:	0f 57 0d 70 66 02 00 	xorps  0x26670(%rip),%xmm1        # 431010 <_IO_stdin_used+0x10>
  40a9a0:	f3 0f 58 0d 84 66 02 00 	addss  0x26684(%rip),%xmm1        # 43102c <_IO_stdin_used+0x2c>
  40a9a8:	66 48 0f 7e c9       	movq   %xmm1,%rcx
  40a9ad:	89 ce                	mov    %ecx,%esi
  40a9af:	48 89 b5 28 fe ff ff 	mov    %rsi,-0x1d8(%rbp)
  40a9b6:	48 c7 85 70 f5 ff ff 01 00 00 00 	movq   $0x1,-0xa90(%rbp)
  40a9c1:	48 c7 85 70 f5 ff ff 00 00 80 3f 	movq   $0x3f800000,-0xa90(%rbp)
  40a9cc:	4c 89 bd 78 f5 ff ff 	mov    %r15,-0xa88(%rbp)
  40a9d3:	0f 57 05 36 66 02 00 	xorps  0x26636(%rip),%xmm0        # 431010 <_IO_stdin_used+0x10>
  40a9da:	f3 0f 58 05 3e 66 02 00 	addss  0x2663e(%rip),%xmm0        # 431020 <_IO_stdin_used+0x20>
  40a9e2:	66 48 0f 7e c1       	movq   %xmm0,%rcx
  40a9e7:	41 89 ca             	mov    %ecx,%r10d
  40a9ea:	4c 89 95 30 fe ff ff 	mov    %r10,-0x1d0(%rbp)
  40a9f1:	4c 89 85 70 f5 ff ff 	mov    %r8,-0xa90(%rbp)
  40a9f8:	4c 89 85 78 f5 ff ff 	mov    %r8,-0xa88(%rbp)
  40a9ff:	66 49 0f 6e e8       	movq   %r8,%xmm5
  40aa04:	f3 0f 11 ad 4c fe ff ff 	movss  %xmm5,-0x1b4(%rbp)
  40aa0c:	f3 0f 10 c5          	movss  %xmm5,%xmm0
  40aa10:	f3 0f 59 c5          	mulss  %xmm5,%xmm0
  40aa14:	66 48 0f 7e c1       	movq   %xmm0,%rcx
  40aa19:	89 ca                	mov    %ecx,%edx
  40aa1b:	48 89 b5 70 f5 ff ff 	mov    %rsi,-0xa90(%rbp)
  40aa22:	48 89 b5 78 f5 ff ff 	mov    %rsi,-0xa88(%rbp)
  40aa29:	66 48 0f 6e e6       	movq   %rsi,%xmm4
  40aa2e:	f3 0f 11 a5 50 fe ff ff 	movss  %xmm4,-0x1b0(%rbp)
  40aa36:	f3 0f 10 c4          	movss  %xmm4,%xmm0
  40aa3a:	f3 0f 59 c4          	mulss  %xmm4,%xmm0
  40aa3e:	66 48 0f 7e c1       	movq   %xmm0,%rcx
  40aa43:	89 c9                	mov    %ecx,%ecx
  40aa45:	48 89 95 70 f5 ff ff 	mov    %rdx,-0xa90(%rbp)
  40aa4c:	48 89 8d 78 f5 ff ff 	mov    %rcx,-0xa88(%rbp)
  40aa53:	66 48 0f 6e c2       	movq   %rdx,%xmm0
  40aa58:	66 48 0f 6e c9       	movq   %rcx,%xmm1
  40aa5d:	f3 0f 58 c1          	addss  %xmm1,%xmm0
  40aa61:	66 48 0f 7e c1       	movq   %xmm0,%rcx
  40aa66:	89 ca                	mov    %ecx,%edx
  40aa68:	4c 89 95 70 f5 ff ff 	mov    %r10,-0xa90(%rbp)
  40aa6f:	4c 89 95 78 f5 ff ff 	mov    %r10,-0xa88(%rbp)
  40aa76:	66 49 0f 6e d2       	movq   %r10,%xmm2
  40aa7b:	f3 0f 11 95 54 fe ff ff 	movss  %xmm2,-0x1ac(%rbp)
  40aa83:	f3 0f 10 c2          	movss  %xmm2,%xmm0
  40aa87:	f3 0f 59 c2          	mulss  %xmm2,%xmm0
  40aa8b:	66 48 0f 7e c1       	movq   %xmm0,%rcx
  40aa90:	89 c9                	mov    %ecx,%ecx
  40aa92:	48 89 95 70 f5 ff ff 	mov    %rdx,-0xa90(%rbp)
  40aa99:	48 89 8d 78 f5 ff ff 	mov    %rcx,-0xa88(%rbp)
  40aaa0:	66 48 0f 6e c2       	movq   %rdx,%xmm0
  40aaa5:	66 48 0f 6e c9       	movq   %rcx,%xmm1
  40aaaa:	f3 0f 58 c1          	addss  %xmm1,%xmm0
  40aaae:	49 89 c4             	mov    %rax,%r12
  40aab1:	66 48 0f 7e c0       	movq   %xmm0,%rax
  40aab6:	89 c0                	mov    %eax,%eax
  40aab8:	48 89 85 70 f5 ff ff 	mov    %rax,-0xa90(%rbp)
  40aabf:	b9 01 00 00 00       	mov    $0x1,%ecx
  40aac4:	48 8d 95 70 f5 ff ff 	lea    -0xa90(%rbp),%rdx
  40aacb:	be 24 00 00 00       	mov    $0x24,%esi
  40aad0:	49 89 ff             	mov    %rdi,%r15
  40aad3:	e8 e8 04 02 00       	callq  42afc0 <p111_rt_op>
  40aad8:	4c 89 ff             	mov    %r15,%rdi
  40aadb:	48 89 c2             	mov    %rax,%rdx
  40aade:	4c 89 e0             	mov    %r12,%rax
  40aae1:	4c 8b 95 30 fe ff ff 	mov    -0x1d0(%rbp),%r10
  40aae8:	48 8b b5 28 fe ff ff 	mov    -0x1d8(%rbp),%rsi
  40aaef:	4c 8b 85 20 fe ff ff 	mov    -0x1e0(%rbp),%r8
  40aaf6:	4c 8b a5 f8 fd ff ff 	mov    -0x208(%rbp),%r12
  40aafd:	4c 8b 8d 40 fe ff ff 	mov    -0x1c0(%rbp),%r9
  40ab04:	48 8b 8d 38 fe ff ff 	mov    -0x1c8(%rbp),%rcx
  40ab0b:	4c 8b bd 08 fe ff ff 	mov    -0x1f8(%rbp),%r15
  40ab12:	f3 0f 10 95 54 fe ff ff 	movss  -0x1ac(%rbp),%xmm2
  40ab1a:	f3 0f 10 a5 50 fe ff ff 	movss  -0x1b0(%rbp),%xmm4
  40ab22:	f3 0f 10 ad 4c fe ff ff 	movss  -0x1b4(%rbp),%xmm5
  40ab2a:	f3 0f 10 9d 48 fe ff ff 	movss  -0x1b8(%rbp),%xmm3
  40ab32:	f3 0f 10 85 18 fe ff ff 	movss  -0x1e8(%rbp),%xmm0
  40ab3a:	4c 89 85 70 f5 ff ff 	mov    %r8,-0xa90(%rbp)
  40ab41:	48 89 95 78 f5 ff ff 	mov    %rdx,-0xa88(%rbp)
  40ab48:	66 48 0f 6e ca       	movq   %rdx,%xmm1
  40ab4d:	f3 0f 11 8d c0 fd ff ff 	movss  %xmm1,-0x240(%rbp)
  40ab55:	f3 0f 5e e9          	divss  %xmm1,%xmm5
  40ab59:	66 49 0f 7e e8       	movq   %xmm5,%r8
  40ab5e:	45 89 c0             	mov    %r8d,%r8d
  40ab61:	48 89 b5 70 f5 ff ff 	mov    %rsi,-0xa90(%rbp)
  40ab68:	48 89 95 78 f5 ff ff 	mov    %rdx,-0xa88(%rbp)
  40ab6f:	f3 0f 5e e1          	divss  %xmm1,%xmm4
  40ab73:	66 48 0f 7e e6       	movq   %xmm4,%rsi
  40ab78:	89 f6                	mov    %esi,%esi
  40ab7a:	4c 89 95 70 f5 ff ff 	mov    %r10,-0xa90(%rbp)
  40ab81:	48 89 95 78 f5 ff ff 	mov    %rdx,-0xa88(%rbp)
  40ab88:	f3 44 0f 10 f9       	movss  %xmm1,%xmm15
  40ab8d:	f3 0f 10 ca          	movss  %xmm2,%xmm1
  40ab91:	f3 41 0f 5e cf       	divss  %xmm15,%xmm1
  40ab96:	66 48 0f 7e ca       	movq   %xmm1,%rdx
  40ab9b:	89 d2                	mov    %edx,%edx
  40ab9d:	66 48 0f 6e c9       	movq   %rcx,%xmm1
  40aba2:	f3 0f 5e cb          	divss  %xmm3,%xmm1
  40aba6:	66 48 0f 7e c9       	movq   %xmm1,%rcx
  40abab:	89 c9                	mov    %ecx,%ecx
  40abad:	48 89 8d 10 fe ff ff 	mov    %rcx,-0x1f0(%rbp)
  40abb4:	48 89 8d 70 f5 ff ff 	mov    %rcx,-0xa90(%rbp)
  40abbb:	4c 89 85 78 f5 ff ff 	mov    %r8,-0xa88(%rbp)
  40abc2:	66 48 0f 6e c9       	movq   %rcx,%xmm1
  40abc7:	f3 0f 11 8d 1c fe ff ff 	movss  %xmm1,-0x1e4(%rbp)
  40abcf:	66 49 0f 6e d0       	movq   %r8,%xmm2
  40abd4:	f3 0f 11 95 e0 fd ff ff 	movss  %xmm2,-0x220(%rbp)
  40abdc:	f3 0f 59 d1          	mulss  %xmm1,%xmm2
  40abe0:	66 49 0f 7e d0       	movq   %xmm2,%r8
  40abe5:	45 89 c0             	mov    %r8d,%r8d
  40abe8:	66 49 0f 6e d1       	movq   %r9,%xmm2
  40abed:	f3 0f 5e d3          	divss  %xmm3,%xmm2
  40abf1:	66 49 0f 7e d1       	movq   %xmm2,%r9
  40abf6:	45 89 c9             	mov    %r9d,%r9d
  40abf9:	4c 89 8d f0 fd ff ff 	mov    %r9,-0x210(%rbp)
  40ac00:	4c 89 8d 70 f5 ff ff 	mov    %r9,-0xa90(%rbp)
  40ac07:	48 89 b5 78 f5 ff ff 	mov    %rsi,-0xa88(%rbp)
  40ac0e:	66 49 0f 6e d1       	movq   %r9,%xmm2
  40ac13:	f3 0f 11 95 04 fe ff ff 	movss  %xmm2,-0x1fc(%rbp)
  40ac1b:	66 48 0f 6e e6       	movq   %rsi,%xmm4
  40ac20:	f3 0f 11 a5 e4 fd ff ff 	movss  %xmm4,-0x21c(%rbp)
  40ac28:	f3 0f 59 d4          	mulss  %xmm4,%xmm2
  40ac2c:	66 48 0f 7e d6       	movq   %xmm2,%rsi
  40ac31:	89 f6                	mov    %esi,%esi
  40ac33:	4c 89 85 70 f5 ff ff 	mov    %r8,-0xa90(%rbp)
  40ac3a:	48 89 b5 78 f5 ff ff 	mov    %rsi,-0xa88(%rbp)
  40ac41:	66 49 0f 6e d0       	movq   %r8,%xmm2
  40ac46:	66 48 0f 6e de       	movq   %rsi,%xmm3
  40ac4b:	f3 0f 58 d3          	addss  %xmm3,%xmm2
  40ac4f:	66 48 0f 7e d6       	movq   %xmm2,%rsi
  40ac54:	89 f6                	mov    %esi,%esi
  40ac56:	4c 89 a5 70 f5 ff ff 	mov    %r12,-0xa90(%rbp)
  40ac5d:	48 89 95 78 f5 ff ff 	mov    %rdx,-0xa88(%rbp)
  40ac64:	66 49 0f 6e d4       	movq   %r12,%xmm2
  40ac69:	f3 0f 11 95 e8 fd ff ff 	movss  %xmm2,-0x218(%rbp)
  40ac71:	66 48 0f 6e ea       	movq   %rdx,%xmm5
  40ac76:	f3 0f 11 ad ec fd ff ff 	movss  %xmm5,-0x214(%rbp)
  40ac7e:	f3 0f 59 d5          	mulss  %xmm5,%xmm2
  40ac82:	66 48 0f 7e d2       	movq   %xmm2,%rdx
  40ac87:	89 d2                	mov    %edx,%edx
  40ac89:	48 89 b5 70 f5 ff ff 	mov    %rsi,-0xa90(%rbp)
  40ac90:	48 89 95 78 f5 ff ff 	mov    %rdx,-0xa88(%rbp)
  40ac97:	66 48 0f 6e d6       	movq   %rsi,%xmm2
  40ac9c:	66 48 0f 6e da       	movq   %rdx,%xmm3
  40aca1:	f3 0f 58 d3          	addss  %xmm3,%xmm2
  40aca5:	66 48 0f 7e d2       	movq   %xmm2,%rdx
  40acaa:	89 d6                	mov    %edx,%esi
  40acac:	66 48 0f 6e d6       	movq   %rsi,%xmm2
  40acb1:	f3 0f 10 1d 6b 63 02 00 	movss  0x2636b(%rip),%xmm3        # 431024 <_IO_stdin_used+0x24>
  40acb9:	0f 2e da             	ucomiss %xmm2,%xmm3
  40acbc:	0f 97 c2             	seta   %dl
  40acbf:	0f b6 d2             	movzbl %dl,%edx
  40acc2:	89 d2                	mov    %edx,%edx
  40acc4:	48 83 fa 01          	cmp    $0x1,%rdx
  40acc8:	49 89 c4             	mov    %rax,%r12
  40accb:	0f 94 c0             	sete   %al
  40acce:	0f b6 c0             	movzbl %al,%eax
  40acd1:	48 c1 ea 28          	shr    $0x28,%rdx
  40acd5:	48 81 e2 ff ff 7f 00 	and    $0x7fffff,%rdx
  40acdc:	48 81 fa 02 00 01 00 	cmp    $0x10002,%rdx
  40ace3:	0f 94 c2             	sete   %dl
  40ace6:	0f b6 d2             	movzbl %dl,%edx
  40ace9:	09 d0                	or     %edx,%eax
  40aceb:	75 4c                	jne    40ad39 <p113d_FID_36_100_105_114_101_99_116_46_116_114_97_99_101_+0x1899>
  40aced:	83 f0 01             	xor    $0x1,%eax
  40acf0:	75 38                	jne    40ad2a <p113d_FID_36_100_105_114_101_99_116_46_116_114_97_99_101_+0x188a>
  40acf2:	be 04 00 00 00       	mov    $0x4,%esi
  40acf7:	49 89 ff             	mov    %rdi,%r15
  40acfa:	e8 a1 02 02 00       	callq  42afa0 <p111_rt_fail>
  40acff:	4c 89 ff             	mov    %r15,%rdi
  40ad02:	4c 89 e0             	mov    %r12,%rax
  40ad05:	48 8b 8d 10 fe ff ff 	mov    -0x1f0(%rbp),%rcx
  40ad0c:	4c 8b a5 08 fe ff ff 	mov    -0x1f8(%rbp),%r12
  40ad13:	f3 0f 10 8d 1c fe ff ff 	movss  -0x1e4(%rbp),%xmm1
  40ad1b:	f3 0f 10 85 18 fe ff ff 	movss  -0x1e8(%rbp),%xmm0
  40ad23:	be 00 00 00 00       	mov    $0x0,%esi
  40ad28:	eb 06                	jmp    40ad30 <p113d_FID_36_100_105_114_101_99_116_46_116_114_97_99_101_+0x1890>
  40ad2a:	4c 89 e0             	mov    %r12,%rax
  40ad2d:	4d 89 fc             	mov    %r15,%r12
  40ad30:	48 89 b5 c8 fd ff ff 	mov    %rsi,-0x238(%rbp)
  40ad37:	eb 11                	jmp    40ad4a <p113d_FID_36_100_105_114_101_99_116_46_116_114_97_99_101_+0x18aa>
  40ad39:	4c 89 e0             	mov    %r12,%rax
  40ad3c:	4d 89 fc             	mov    %r15,%r12
  40ad3f:	48 c7 85 c8 fd ff ff 00 00 00 00 	movq   $0x0,-0x238(%rbp)
  40ad4a:	48 c7 85 70 f5 ff ff 6f 12 83 3a 	movq   $0x3a83126f,-0xa90(%rbp)
  40ad55:	48 89 8d 78 f5 ff ff 	mov    %rcx,-0xa88(%rbp)
  40ad5c:	f3 0f 59 0d c4 62 02 00 	mulss  0x262c4(%rip),%xmm1        # 431028 <_IO_stdin_used+0x28>
  40ad64:	66 48 0f 7e c9       	movq   %xmm1,%rcx
  40ad69:	89 c9                	mov    %ecx,%ecx
  40ad6b:	4c 89 ad 70 f5 ff ff 	mov    %r13,-0xa90(%rbp)
  40ad72:	48 89 8d 78 f5 ff ff 	mov    %rcx,-0xa88(%rbp)
  40ad79:	66 48 0f 6e c9       	movq   %rcx,%xmm1
  40ad7e:	f3 0f 58 c1          	addss  %xmm1,%xmm0
  40ad82:	49 89 c5             	mov    %rax,%r13
  40ad85:	66 48 0f 7e c0       	movq   %xmm0,%rax
  40ad8a:	89 c2                	mov    %eax,%edx
  40ad8c:	48 89 95 d0 fd ff ff 	mov    %rdx,-0x230(%rbp)
  40ad93:	f3 0f 10 0d a9 62 02 00 	movss  0x262a9(%rip),%xmm1        # 431044 <_IO_stdin_used+0x44>
  40ad9b:	f3 0f 10 05 99 62 02 00 	movss  0x26299(%rip),%xmm0        # 43103c <_IO_stdin_used+0x3c>
  40ada3:	49 89 ff             	mov    %rdi,%r15
  40ada6:	e8 a5 af ff ff       	callq  405d50 <p126_typed_FID_36_100_105_114_101_99_116_46_102_108_>
  40adab:	4c 89 ff             	mov    %r15,%rdi
  40adae:	48 89 c1             	mov    %rax,%rcx
  40adb1:	4c 89 e8             	mov    %r13,%rax
  40adb4:	4c 8b ad f8 fd ff ff 	mov    -0x208(%rbp),%r13
  40adbb:	48 8b 95 f0 fd ff ff 	mov    -0x210(%rbp),%rdx
  40adc2:	f3 0f 10 8d 04 fe ff ff 	movss  -0x1fc(%rbp),%xmm1
  40adca:	f3 0f 10 85 00 fe ff ff 	movss  -0x200(%rbp),%xmm0
  40add2:	48 89 8d 70 f5 ff ff 	mov    %rcx,-0xa90(%rbp)
  40add9:	48 89 95 78 f5 ff ff 	mov    %rdx,-0xa88(%rbp)
  40ade0:	66 48 0f 6e d1       	movq   %rcx,%xmm2
  40ade5:	f3 0f 59 ca          	mulss  %xmm2,%xmm1
  40ade9:	66 48 0f 7e c9       	movq   %xmm1,%rcx
  40adee:	89 c9                	mov    %ecx,%ecx
  40adf0:	4c 89 b5 70 f5 ff ff 	mov    %r14,-0xa90(%rbp)
  40adf7:	48 89 8d 78 f5 ff ff 	mov    %rcx,-0xa88(%rbp)
  40adfe:	66 48 0f 6e c9       	movq   %rcx,%xmm1
  40ae03:	f3 0f 58 c1          	addss  %xmm1,%xmm0
  40ae07:	49 89 c6             	mov    %rax,%r14
  40ae0a:	66 48 0f 7e c0       	movq   %xmm0,%rax
  40ae0f:	89 c1                	mov    %eax,%ecx
  40ae11:	48 89 8d d8 fd ff ff 	mov    %rcx,-0x228(%rbp)
  40ae18:	f3 0f 10 0d 24 62 02 00 	movss  0x26224(%rip),%xmm1        # 431044 <_IO_stdin_used+0x44>
  40ae20:	f3 0f 10 05 14 62 02 00 	movss  0x26214(%rip),%xmm0        # 43103c <_IO_stdin_used+0x3c>
  40ae28:	49 89 ff             	mov    %rdi,%r15
  40ae2b:	e8 20 af ff ff       	callq  405d50 <p126_typed_FID_36_100_105_114_101_99_116_46_102_108_>
  40ae30:	4c 89 ff             	mov    %r15,%rdi
  40ae33:	49 89 c0             	mov    %rax,%r8
  40ae36:	4c 89 f0             	mov    %r14,%rax
  40ae39:	48 8b b5 c8 fd ff ff 	mov    -0x238(%rbp),%rsi
  40ae40:	48 8b 8d d8 fd ff ff 	mov    -0x228(%rbp),%rcx
  40ae47:	48 8b 95 d0 fd ff ff 	mov    -0x230(%rbp),%rdx
  40ae4e:	f3 0f 10 ad ec fd ff ff 	movss  -0x214(%rbp),%xmm5
  40ae56:	f3 0f 10 8d e8 fd ff ff 	movss  -0x218(%rbp),%xmm1
  40ae5e:	f3 0f 10 a5 e4 fd ff ff 	movss  -0x21c(%rbp),%xmm4
  40ae66:	f3 0f 10 9d e0 fd ff ff 	movss  -0x220(%rbp),%xmm3
  40ae6e:	f3 0f 10 85 c4 fd ff ff 	movss  -0x23c(%rbp),%xmm0
  40ae76:	4c 89 85 70 f5 ff ff 	mov    %r8,-0xa90(%rbp)
  40ae7d:	4c 89 ad 78 f5 ff ff 	mov    %r13,-0xa88(%rbp)
  40ae84:	66 49 0f 6e d0       	movq   %r8,%xmm2
  40ae89:	f3 0f 59 ca          	mulss  %xmm2,%xmm1
  40ae8d:	66 49 0f 7e c8       	movq   %xmm1,%r8
  40ae92:	45 89 c0             	mov    %r8d,%r8d
  40ae95:	4c 89 a5 70 f5 ff ff 	mov    %r12,-0xa90(%rbp)
  40ae9c:	4c 89 85 78 f5 ff ff 	mov    %r8,-0xa88(%rbp)
  40aea3:	66 49 0f 6e c8       	movq   %r8,%xmm1
  40aea8:	f3 0f 58 c1          	addss  %xmm1,%xmm0
  40aeac:	49 89 c5             	mov    %rax,%r13
  40aeaf:	66 48 0f 7e c0       	movq   %xmm0,%rax
  40aeb4:	89 c0                	mov    %eax,%eax
  40aeb6:	48 c7 85 70 f5 ff ff 00 ca 9a 3b 	movq   $0x3b9aca00,-0xa90(%rbp)
  40aec1:	48 c7 85 70 f5 ff ff 00 ca 9a 3b 	movq   $0x3b9aca00,-0xa90(%rbp)
  40aecc:	66 48 0f 6e c2       	movq   %rdx,%xmm0
  40aed1:	66 48 0f 6e c9       	movq   %rcx,%xmm1
  40aed6:	66 48 0f 6e d0       	movq   %rax,%xmm2
  40aedb:	41 b8 00 00 00 00    	mov    $0x0,%r8d
  40aee1:	b9 28 6b 6e 4e       	mov    $0x4e6e6b28,%ecx
  40aee6:	ba 28 6b 6e 4e       	mov    $0x4e6e6b28,%edx
  40aeeb:	49 89 f7             	mov    %rsi,%r15
  40aeee:	be 09 00 00 00       	mov    $0x9,%esi
  40aef3:	49 89 fc             	mov    %rdi,%r12
  40aef6:	e8 05 bf ff ff       	callq  406e00 <p126_typed_FID_36_100_105_114_101_99_116_46_110_101_97_114_101_115_116_46_116_>
  40aefb:	4c 89 e7             	mov    %r12,%rdi
  40aefe:	48 89 85 b8 fd ff ff 	mov    %rax,-0x248(%rbp)
  40af05:	f3 0f 10 0d 33 61 02 00 	movss  0x26133(%rip),%xmm1        # 431040 <_IO_stdin_used+0x40>
  40af0d:	f3 0f 10 05 27 61 02 00 	movss  0x26127(%rip),%xmm0        # 43103c <_IO_stdin_used+0x3c>
  40af15:	49 89 fc             	mov    %rdi,%r12
  40af18:	e8 33 ae ff ff       	callq  405d50 <p126_typed_FID_36_100_105_114_101_99_116_46_102_108_>
  40af1d:	4c 89 e7             	mov    %r12,%rdi
  40af20:	49 89 c4             	mov    %rax,%r12
  40af23:	f3 0f 10 0d 0d 61 02 00 	movss  0x2610d(%rip),%xmm1        # 431038 <_IO_stdin_used+0x38>
  40af2b:	f3 0f 10 05 01 61 02 00 	movss  0x26101(%rip),%xmm0        # 431034 <_IO_stdin_used+0x34>
  40af33:	49 89 fe             	mov    %rdi,%r14
  40af36:	e8 15 ae ff ff       	callq  405d50 <p126_typed_FID_36_100_105_114_101_99_116_46_102_108_>
  40af3b:	4c 89 fe             	mov    %r15,%rsi
  40af3e:	4c 89 f7             	mov    %r14,%rdi
  40af41:	49 95                	xchg   %rax,%r13
  40af43:	49 89 c6             	mov    %rax,%r14
  40af46:	48 8b 85 b8 fd ff ff 	mov    -0x248(%rbp),%rax
  40af4d:	f3 0f 10 8d c0 fd ff ff 	movss  -0x240(%rbp),%xmm1
  40af55:	66 48 0f 6e c0       	movq   %rax,%xmm0
  40af5a:	e8 81 b4 ff ff       	callq  4063e0 <p126_typed_FID_36_100_105_114_101_99_116_46_115_104_97_100_101_>
  40af5f:	48 89 c1             	mov    %rax,%rcx
  40af62:	4c 89 f0             	mov    %r14,%rax
  40af65:	f3 0f 10 8d b4 fd ff ff 	movss  -0x24c(%rbp),%xmm1
  40af6d:	f3 0f 10 95 b0 fd ff ff 	movss  -0x250(%rbp),%xmm2
  40af75:	4c 89 ad 70 f5 ff ff 	mov    %r13,-0xa90(%rbp)
  40af7c:	48 89 8d 78 f5 ff ff 	mov    %rcx,-0xa88(%rbp)
  40af83:	66 49 0f 6e c5       	movq   %r13,%xmm0
  40af88:	66 48 0f 6e d9       	movq   %rcx,%xmm3
  40af8d:	f3 0f 59 c3          	mulss  %xmm3,%xmm0
  40af91:	66 48 0f 7e c1       	movq   %xmm0,%rcx
  40af96:	89 c9                	mov    %ecx,%ecx
  40af98:	4c 89 a5 70 f5 ff ff 	mov    %r12,-0xa90(%rbp)
  40af9f:	48 89 8d 78 f5 ff ff 	mov    %rcx,-0xa88(%rbp)
  40afa6:	66 49 0f 6e c4       	movq   %r12,%xmm0
  40afab:	66 48 0f 6e d9       	movq   %rcx,%xmm3
  40afb0:	f3 0f 58 c3          	addss  %xmm3,%xmm0
  40afb4:	66 48 0f 7e c1       	movq   %xmm0,%rcx
  40afb9:	89 c9                	mov    %ecx,%ecx
  40afbb:	48 89 9d 70 f5 ff ff 	mov    %rbx,-0xa90(%rbp)
  40afc2:	48 89 8d 78 f5 ff ff 	mov    %rcx,-0xa88(%rbp)
  40afc9:	66 48 0f 6e c1       	movq   %rcx,%xmm0
  40afce:	f3 0f 59 c2          	mulss  %xmm2,%xmm0
  40afd2:	48 89 c3             	mov    %rax,%rbx
  40afd5:	66 48 0f 7e c0       	movq   %xmm0,%rax
  40afda:	89 c0                	mov    %eax,%eax
  40afdc:	48 89 9d 70 f5 ff ff 	mov    %rbx,-0xa90(%rbp)
  40afe3:	48 89 85 78 f5 ff ff 	mov    %rax,-0xa88(%rbp)
  40afea:	66 48 0f 6e c0       	movq   %rax,%xmm0
  40afef:	f3 0f 58 c1          	addss  %xmm1,%xmm0
  40aff3:	66 48 0f 7e c0       	movq   %xmm0,%rax
  40aff8:	89 c0                	mov    %eax,%eax
  40affa:	41 5f                	pop    %r15
  40affc:	41 5e                	pop    %r14
  40affe:	41 5d                	pop    %r13
  40b000:	41 5c                	pop    %r12
  40b002:	5b                   	pop    %rbx
  40b003:	c9                   	leaveq 
  40b004:	c3                   	retq   
  40b005:	66 66 2e 0f 1f 84 00 00 00 00 00 	data16 nopw %cs:0x0(%rax,%rax,1)

