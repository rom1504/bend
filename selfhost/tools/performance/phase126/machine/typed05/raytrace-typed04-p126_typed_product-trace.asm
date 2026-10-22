00000000004074f0 <p126_typed_FID_36_112_114_111_100_117_99_116_46_116_114_97_99_101_>:
  4074f0:	f3 0f 1e fa          	endbr64 
  4074f4:	55                   	push   %rbp
  4074f5:	48 89 e5             	mov    %rsp,%rbp
  4074f8:	48 81 ec 98 01 00 00 	sub    $0x198,%rsp
  4074ff:	53                   	push   %rbx
  407500:	41 54                	push   %r12
  407502:	41 55                	push   %r13
  407504:	41 56                	push   %r14
  407506:	41 57                	push   %r15
  407508:	4c 89 c0             	mov    %r8,%rax
  40750b:	f3 44 0f 10 fe       	movss  %xmm6,%xmm15
  407510:	f3 0f 10 f1          	movss  %xmm1,%xmm6
  407514:	f3 41 0f 10 cf       	movss  %xmm15,%xmm1
  407519:	48 89 cb             	mov    %rcx,%rbx
  40751c:	b9 00 00 00 41       	mov    $0x41000000,%ecx
  407521:	48 89 8d f8 fe ff ff 	mov    %rcx,-0x108(%rbp)
  407528:	41 be cd cc 4c 3e    	mov    $0x3e4ccccd,%r14d
  40752e:	4c 89 b5 00 ff ff ff 	mov    %r14,-0x100(%rbp)
  407535:	41 bd 00 00 60 c0    	mov    $0xc0600000,%r13d
  40753b:	4c 89 ad 08 ff ff ff 	mov    %r13,-0xf8(%rbp)
  407542:	41 bc 00 00 80 3f    	mov    $0x3f800000,%r12d
  407548:	4c 89 a5 10 ff ff ff 	mov    %r12,-0xf0(%rbp)
  40754f:	48 89 d9             	mov    %rbx,%rcx
  407552:	f3 0f 11 75 ec       	movss  %xmm6,-0x14(%rbp)
  407557:	f3 0f 10 f1          	movss  %xmm1,%xmm6
  40755b:	49 89 c0             	mov    %rax,%r8
  40755e:	66 90                	xchg   %ax,%ax
  407560:	f3 0f 11 45 e8       	movss  %xmm0,-0x18(%rbp)
  407565:	f3 0f 11 65 e4       	movss  %xmm4,-0x1c(%rbp)
  40756a:	f3 0f 11 6d e0       	movss  %xmm5,-0x20(%rbp)
  40756f:	66 48 0f 7e c0       	movq   %xmm0,%rax
  407574:	41 89 c5             	mov    %eax,%r13d
  407577:	66 48 0f 7e d0       	movq   %xmm2,%rax
  40757c:	41 89 c4             	mov    %eax,%r12d
  40757f:	66 48 0f 7e d8       	movq   %xmm3,%rax
  407584:	41 89 c3             	mov    %eax,%r11d
  407587:	66 48 0f 7e e0       	movq   %xmm4,%rax
  40758c:	41 89 c2             	mov    %eax,%r10d
  40758f:	66 48 0f 7e e8       	movq   %xmm5,%rax
  407594:	41 89 c1             	mov    %eax,%r9d
  407597:	66 48 0f 7e f0       	movq   %xmm6,%rax
  40759c:	89 c3                	mov    %eax,%ebx
  40759e:	66 48 0f 7e f8       	movq   %xmm7,%rax
  4075a3:	89 c0                	mov    %eax,%eax
  4075a5:	48 83 fe 00          	cmp    $0x0,%rsi
  4075a9:	49 89 f6             	mov    %rsi,%r14
  4075ac:	40 0f 94 c6          	sete   %sil
  4075b0:	40 0f b6 f6          	movzbl %sil,%esi
  4075b4:	66 49 0f 6e c5       	movq   %r13,%xmm0
  4075b9:	f3 0f 11 45 dc       	movss  %xmm0,-0x24(%rbp)
  4075be:	66 49 0f 6e cc       	movq   %r12,%xmm1
  4075c3:	f3 0f 11 4d f0       	movss  %xmm1,-0x10(%rbp)
  4075c8:	f3 0f 10 c8          	movss  %xmm0,%xmm1
  4075cc:	66 48 0f 6e c3       	movq   %rbx,%xmm0
  4075d1:	f3 0f 11 85 44 ff ff ff 	movss  %xmm0,-0xbc(%rbp)
  4075d9:	f3 0f 59 c1          	mulss  %xmm1,%xmm0
  4075dd:	66 49 0f 6e cb       	movq   %r11,%xmm1
  4075e2:	f3 0f 58 c1          	addss  %xmm1,%xmm0
  4075e6:	f3 0f 11 45 c4       	movss  %xmm0,-0x3c(%rbp)
  4075eb:	66 49 0f 7e c3       	movq   %xmm0,%r11
  4075f0:	45 89 db             	mov    %r11d,%r11d
  4075f3:	66 49 0f 6e d3       	movq   %r11,%xmm2
  4075f8:	f3 0f 11 95 bc fe ff ff 	movss  %xmm2,-0x144(%rbp)
  407600:	f3 0f 10 05 18 ba 02 00 	movss  0x2ba18(%rip),%xmm0        # 433020 <_IO_stdin_used+0x20>
  407608:	f3 0f 5c c2          	subss  %xmm2,%xmm0
  40760c:	66 49 0f 7e c3       	movq   %xmm0,%r11
  407611:	45 89 db             	mov    %r11d,%r11d
  407614:	66 49 0f 6e cb       	movq   %r11,%xmm1
  407619:	f3 0f 11 8d f0 fe ff ff 	movss  %xmm1,-0x110(%rbp)
  407621:	f3 0f 59 c8          	mulss  %xmm0,%xmm1
  407625:	f3 0f 11 4d c8       	movss  %xmm1,-0x38(%rbp)
  40762a:	66 49 0f 6e da       	movq   %r10,%xmm3
  40762f:	f3 0f 11 9d 48 ff ff ff 	movss  %xmm3,-0xb8(%rbp)
  407637:	66 49 0f 6e e1       	movq   %r9,%xmm4
  40763c:	f3 0f 11 a5 4c ff ff ff 	movss  %xmm4,-0xb4(%rbp)
  407644:	66 48 0f 6e c0       	movq   %rax,%xmm0
  407649:	f3 0f 11 85 b0 fe ff ff 	movss  %xmm0,-0x150(%rbp)
  407651:	66 49 0f 6e f8       	movq   %r8,%xmm7
  407656:	f3 0f 11 bd b4 fe ff ff 	movss  %xmm7,-0x14c(%rbp)
  40765e:	48 83 fa 01          	cmp    $0x1,%rdx
  407662:	49 89 cd             	mov    %rcx,%r13
  407665:	0f 94 c1             	sete   %cl
  407668:	0f b6 c9             	movzbl %cl,%ecx
  40766b:	48 89 d0             	mov    %rdx,%rax
  40766e:	48 c1 e8 28          	shr    $0x28,%rax
  407672:	48 25 ff ff 7f 00    	and    $0x7fffff,%rax
  407678:	48 3d 02 00 01 00    	cmp    $0x10002,%rax
  40767e:	0f 94 c2             	sete   %dl
  407681:	0f b6 d2             	movzbl %dl,%edx
  407684:	89 c8                	mov    %ecx,%eax
  407686:	09 d0                	or     %edx,%eax
  407688:	83 fe 00             	cmp    $0x0,%esi
  40768b:	0f 85 14 06 00 00    	jne    407ca5 <p126_typed_FID_36_112_114_111_100_117_99_116_46_116_114_97_99_101_+0x7b5>
  407691:	09 d1                	or     %edx,%ecx
  407693:	0f 85 01 06 00 00    	jne    407c9a <p126_typed_FID_36_112_114_111_100_117_99_116_46_116_114_97_99_101_+0x7aa>
  407699:	2e 2e 2e 2e 83 f0 01 	cs cs cs cs xor $0x1,%eax
  4076a0:	0f 84 e0 05 00 00    	je     407c86 <p126_typed_FID_36_112_114_111_100_117_99_116_46_116_114_97_99_101_+0x796>
  4076a6:	4c 89 ee             	mov    %r13,%rsi
  4076a9:	48 89 fb             	mov    %rdi,%rbx
  4076ac:	e8 cf ed ff ff       	callq  406480 <p113d_FID_36_100_105_114_101_99_116_46_115_114_>
  4076b1:	48 89 df             	mov    %rbx,%rdi
  4076b4:	48 89 c3             	mov    %rax,%rbx
  4076b7:	f3 0f 10 45 e8       	movss  -0x18(%rbp),%xmm0
  4076bc:	f3 0f 10 4d ec       	movss  -0x14(%rbp),%xmm1
  4076c1:	f3 0f 10 65 e4       	movss  -0x1c(%rbp),%xmm4
  4076c6:	f3 0f 10 6d e0       	movss  -0x20(%rbp),%xmm5
  4076cb:	f3 0f 10 f1          	movss  %xmm1,%xmm6
  4076cf:	f3 0f 10 4d f0       	movss  -0x10(%rbp),%xmm1
  4076d4:	f3 0f 10 d0          	movss  %xmm0,%xmm2
  4076d8:	f3 0f 10 45 dc       	movss  -0x24(%rbp),%xmm0
  4076dd:	f3 0f 59 d4          	mulss  %xmm4,%xmm2
  4076e1:	f3 0f 58 d6          	addss  %xmm6,%xmm2
  4076e5:	f3 0f 11 55 d8       	movss  %xmm2,-0x28(%rbp)
  4076ea:	66 48 0f 7e d0       	movq   %xmm2,%rax
  4076ef:	41 89 c7             	mov    %eax,%r15d
  4076f2:	f3 0f 59 c5          	mulss  %xmm5,%xmm0
  4076f6:	f3 0f 58 c1          	addss  %xmm1,%xmm0
  4076fa:	f3 0f 11 45 cc       	movss  %xmm0,-0x34(%rbp)
  4076ff:	66 48 0f 7e c0       	movq   %xmm0,%rax
  407704:	89 c0                	mov    %eax,%eax
  407706:	48 89 45 d0          	mov    %rax,-0x30(%rbp)
  40770a:	4c 89 ee             	mov    %r13,%rsi
  40770d:	49 89 fc             	mov    %rdi,%r12
  407710:	e8 db ef ff ff       	callq  4066f0 <p113d_FID_36_100_105_114_101_99_116_46_115_120_>
  407715:	4c 89 e7             	mov    %r12,%rdi
  407718:	48 89 c1             	mov    %rax,%rcx
  40771b:	48 8b 45 d0          	mov    -0x30(%rbp),%rax
  40771f:	f3 0f 10 45 d8       	movss  -0x28(%rbp),%xmm0
  407724:	66 48 0f 6e c9       	movq   %rcx,%xmm1
  407729:	f3 0f 5c c1          	subss  %xmm1,%xmm0
  40772d:	66 48 0f 6e d3       	movq   %rbx,%xmm2
  407732:	f3 0f 11 55 c0       	movss  %xmm2,-0x40(%rbp)
  407737:	f3 0f 5e c2          	divss  %xmm2,%xmm0
  40773b:	48 89 c3             	mov    %rax,%rbx
  40773e:	66 48 0f 7e c0       	movq   %xmm0,%rax
  407743:	41 89 c4             	mov    %eax,%r12d
  407746:	4c 89 65 b0          	mov    %r12,-0x50(%rbp)
  40774a:	4c 89 ee             	mov    %r13,%rsi
  40774d:	49 89 fc             	mov    %rdi,%r12
  407750:	e8 cb ee ff ff       	callq  406620 <p113d_FID_36_100_105_114_101_99_116_46_115_121_>
  407755:	4c 89 e7             	mov    %r12,%rdi
  407758:	48 89 c1             	mov    %rax,%rcx
  40775b:	48 89 d8             	mov    %rbx,%rax
  40775e:	f3 0f 10 55 c0       	movss  -0x40(%rbp),%xmm2
  407763:	f3 0f 10 45 cc       	movss  -0x34(%rbp),%xmm0
  407768:	66 48 0f 6e c9       	movq   %rcx,%xmm1
  40776d:	f3 0f 5c c1          	subss  %xmm1,%xmm0
  407771:	f3 0f 5e c2          	divss  %xmm2,%xmm0
  407775:	49 89 c4             	mov    %rax,%r12
  407778:	66 48 0f 7e c0       	movq   %xmm0,%rax
  40777d:	89 c3                	mov    %eax,%ebx
  40777f:	48 89 5d b8          	mov    %rbx,-0x48(%rbp)
  407783:	4c 89 ee             	mov    %r13,%rsi
  407786:	48 89 fb             	mov    %rdi,%rbx
  407789:	e8 c2 ed ff ff       	callq  406550 <p113d_FID_36_100_105_114_101_99_116_46_115_122_>
  40778e:	4c 89 e9             	mov    %r13,%rcx
  407791:	48 89 c2             	mov    %rax,%rdx
  407794:	4c 89 e0             	mov    %r12,%rax
  407797:	4c 8b 65 b8          	mov    -0x48(%rbp),%r12
  40779b:	4c 8b 6d b0          	mov    -0x50(%rbp),%r13
  40779f:	f3 0f 10 4d c8       	movss  -0x38(%rbp),%xmm1
  4077a4:	f3 0f 10 55 c0       	movss  -0x40(%rbp),%xmm2
  4077a9:	f3 0f 10 45 c4       	movss  -0x3c(%rbp),%xmm0
  4077ae:	66 48 0f 6e da       	movq   %rdx,%xmm3
  4077b3:	f3 0f 5c c3          	subss  %xmm3,%xmm0
  4077b7:	f3 0f 5e c2          	divss  %xmm2,%xmm0
  4077bb:	66 48 0f 7e c2       	movq   %xmm0,%rdx
  4077c0:	89 d2                	mov    %edx,%edx
  4077c2:	48 89 55 98          	mov    %rdx,-0x68(%rbp)
  4077c6:	66 49 0f 6e c7       	movq   %r15,%xmm0
  4077cb:	f3 0f 11 45 94       	movss  %xmm0,-0x6c(%rbp)
  4077d0:	0f 57 05 39 b8 02 00 	xorps  0x2b839(%rip),%xmm0        # 433010 <_IO_stdin_used+0x10>
  4077d7:	f3 0f 58 05 51 b8 02 00 	addss  0x2b851(%rip),%xmm0        # 433030 <_IO_stdin_used+0x30>
  4077df:	49 89 cf             	mov    %rcx,%r15
  4077e2:	66 48 0f 7e c1       	movq   %xmm0,%rcx
  4077e7:	89 ce                	mov    %ecx,%esi
  4077e9:	48 89 75 a0          	mov    %rsi,-0x60(%rbp)
  4077ed:	66 48 0f 6e d0       	movq   %rax,%xmm2
  4077f2:	f3 0f 11 55 90       	movss  %xmm2,-0x70(%rbp)
  4077f7:	0f 57 15 12 b8 02 00 	xorps  0x2b812(%rip),%xmm2        # 433010 <_IO_stdin_used+0x10>
  4077fe:	f3 0f 58 15 26 b8 02 00 	addss  0x2b826(%rip),%xmm2        # 43302c <_IO_stdin_used+0x2c>
  407806:	66 48 0f 7e d0       	movq   %xmm2,%rax
  40780b:	89 c2                	mov    %eax,%edx
  40780d:	48 89 55 a8          	mov    %rdx,-0x58(%rbp)
  407811:	f3 0f 59 c0          	mulss  %xmm0,%xmm0
  407815:	f3 0f 59 d2          	mulss  %xmm2,%xmm2
  407819:	f3 0f 58 c2          	addss  %xmm2,%xmm0
  40781d:	f3 0f 58 c1          	addss  %xmm1,%xmm0
  407821:	f3 0f 5a c0          	cvtss2sd %xmm0,%xmm0
  407825:	e8 96 ac ff ff       	callq  4024c0 <sqrt@plt>
  40782a:	4c 89 f9             	mov    %r15,%rcx
  40782d:	48 89 df             	mov    %rbx,%rdi
  407830:	48 8b 55 a8          	mov    -0x58(%rbp),%rdx
  407834:	48 8b 75 a0          	mov    -0x60(%rbp),%rsi
  407838:	48 8b 45 98          	mov    -0x68(%rbp),%rax
  40783c:	f3 0f 10 8d f0 fe ff ff 	movss  -0x110(%rbp),%xmm1
  407844:	f2 0f 5a d8          	cvtsd2ss %xmm0,%xmm3
  407848:	66 49 0f 7e d8       	movq   %xmm3,%r8
  40784d:	45 89 c0             	mov    %r8d,%r8d
  407850:	4c 89 85 70 ff ff ff 	mov    %r8,-0x90(%rbp)
  407857:	66 48 0f 6e c6       	movq   %rsi,%xmm0
  40785c:	f3 0f 5e c3          	divss  %xmm3,%xmm0
  407860:	66 48 0f 7e c6       	movq   %xmm0,%rsi
  407865:	89 f3                	mov    %esi,%ebx
  407867:	66 48 0f 6e d2       	movq   %rdx,%xmm2
  40786c:	f3 0f 5e d3          	divss  %xmm3,%xmm2
  407870:	66 48 0f 7e d2       	movq   %xmm2,%rdx
  407875:	89 d2                	mov    %edx,%edx
  407877:	48 89 95 78 ff ff ff 	mov    %rdx,-0x88(%rbp)
  40787e:	f3 0f 5e cb          	divss  %xmm3,%xmm1
  407882:	49 89 cf             	mov    %rcx,%r15
  407885:	66 48 0f 7e c9       	movq   %xmm1,%rcx
  40788a:	89 c9                	mov    %ecx,%ecx
  40788c:	48 89 4d 80          	mov    %rcx,-0x80(%rbp)
  407890:	66 49 0f 6e f5       	movq   %r13,%xmm6
  407895:	f3 0f 11 b5 38 ff ff ff 	movss  %xmm6,-0xc8(%rbp)
  40789d:	f3 0f 59 c6          	mulss  %xmm6,%xmm0
  4078a1:	66 49 0f 6e ec       	movq   %r12,%xmm5
  4078a6:	f3 0f 11 ad 3c ff ff ff 	movss  %xmm5,-0xc4(%rbp)
  4078ae:	f3 0f 59 d5          	mulss  %xmm5,%xmm2
  4078b2:	f3 0f 58 c2          	addss  %xmm2,%xmm0
  4078b6:	66 48 0f 6e d8       	movq   %rax,%xmm3
  4078bb:	f3 0f 11 9d 40 ff ff ff 	movss  %xmm3,-0xc0(%rbp)
  4078c3:	f3 0f 59 cb          	mulss  %xmm3,%xmm1
  4078c7:	f3 0f 58 c1          	addss  %xmm1,%xmm0
  4078cb:	66 48 0f 7e c0       	movq   %xmm0,%rax
  4078d0:	89 c6                	mov    %eax,%esi
  4078d2:	49 89 fc             	mov    %rdi,%r12
  4078d5:	e8 e6 e3 ff ff       	callq  405cc0 <p113d_FID_36_100_105_114_101_99_116_46_102_109_97_120_48_>
  4078da:	4c 89 e7             	mov    %r12,%rdi
  4078dd:	49 89 c5             	mov    %rax,%r13
  4078e0:	f3 0f 10 0d 5c b7 02 00 	movss  0x2b75c(%rip),%xmm1        # 433044 <_IO_stdin_used+0x44>
  4078e8:	f3 0f 10 05 4c b7 02 00 	movss  0x2b74c(%rip),%xmm0        # 43303c <_IO_stdin_used+0x3c>
  4078f0:	49 89 fc             	mov    %rdi,%r12
  4078f3:	e8 58 e4 ff ff       	callq  405d50 <p126_typed_FID_36_100_105_114_101_99_116_46_102_108_>
  4078f8:	4c 89 e7             	mov    %r12,%rdi
  4078fb:	f3 0f 10 b5 38 ff ff ff 	movss  -0xc8(%rbp),%xmm6
  407903:	f3 0f 10 45 94       	movss  -0x6c(%rbp),%xmm0
  407908:	66 48 0f 6e c8       	movq   %rax,%xmm1
  40790d:	f3 0f 59 ce          	mulss  %xmm6,%xmm1
  407911:	f3 0f 58 c1          	addss  %xmm1,%xmm0
  407915:	f3 0f 11 45 88       	movss  %xmm0,-0x78(%rbp)
  40791a:	66 48 0f 7e c0       	movq   %xmm0,%rax
  40791f:	89 c0                	mov    %eax,%eax
  407921:	48 89 85 50 ff ff ff 	mov    %rax,-0xb0(%rbp)
  407928:	f3 0f 10 0d 14 b7 02 00 	movss  0x2b714(%rip),%xmm1        # 433044 <_IO_stdin_used+0x44>
  407930:	f3 0f 10 05 04 b7 02 00 	movss  0x2b704(%rip),%xmm0        # 43303c <_IO_stdin_used+0x3c>
  407938:	49 89 fc             	mov    %rdi,%r12
  40793b:	e8 10 e4 ff ff       	callq  405d50 <p126_typed_FID_36_100_105_114_101_99_116_46_102_108_>
  407940:	4c 89 e7             	mov    %r12,%rdi
  407943:	f3 0f 10 ad 3c ff ff ff 	movss  -0xc4(%rbp),%xmm5
  40794b:	f3 0f 10 45 90       	movss  -0x70(%rbp),%xmm0
  407950:	66 48 0f 6e c8       	movq   %rax,%xmm1
  407955:	f3 0f 59 cd          	mulss  %xmm5,%xmm1
  407959:	f3 0f 58 c8          	addss  %xmm0,%xmm1
  40795d:	f3 0f 11 4d 8c       	movss  %xmm1,-0x74(%rbp)
  407962:	66 48 0f 7e c8       	movq   %xmm1,%rax
  407967:	41 89 c4             	mov    %eax,%r12d
  40796a:	4c 89 a5 58 ff ff ff 	mov    %r12,-0xa8(%rbp)
  407971:	f3 0f 10 0d cb b6 02 00 	movss  0x2b6cb(%rip),%xmm1        # 433044 <_IO_stdin_used+0x44>
  407979:	f3 0f 10 05 bb b6 02 00 	movss  0x2b6bb(%rip),%xmm0        # 43303c <_IO_stdin_used+0x3c>
  407981:	49 89 fc             	mov    %rdi,%r12
  407984:	e8 c7 e3 ff ff       	callq  405d50 <p126_typed_FID_36_100_105_114_101_99_116_46_102_108_>
  407989:	4c 89 f9             	mov    %r15,%rcx
  40798c:	4c 89 ee             	mov    %r13,%rsi
  40798f:	4c 89 e7             	mov    %r12,%rdi
  407992:	49 89 c0             	mov    %rax,%r8
  407995:	48 8b 45 80          	mov    -0x80(%rbp),%rax
  407999:	48 8b 95 78 ff ff ff 	mov    -0x88(%rbp),%rdx
  4079a0:	f3 0f 10 4d 8c       	movss  -0x74(%rbp),%xmm1
  4079a5:	f3 0f 10 45 88       	movss  -0x78(%rbp),%xmm0
  4079aa:	f3 0f 10 9d 40 ff ff ff 	movss  -0xc0(%rbp),%xmm3
  4079b2:	f3 0f 10 95 bc fe ff ff 	movss  -0x144(%rbp),%xmm2
  4079ba:	66 49 0f 6e e0       	movq   %r8,%xmm4
  4079bf:	f3 0f 59 dc          	mulss  %xmm4,%xmm3
  4079c3:	f3 0f 58 d3          	addss  %xmm3,%xmm2
  4079c7:	66 49 0f 7e d0       	movq   %xmm2,%r8
  4079cc:	45 89 c4             	mov    %r8d,%r12d
  4079cf:	4c 89 a5 60 ff ff ff 	mov    %r12,-0xa0(%rbp)
  4079d6:	66 48 0f 6e db       	movq   %rbx,%xmm3
  4079db:	66 48 0f 6e e2       	movq   %rdx,%xmm4
  4079e0:	66 48 0f 6e e8       	movq   %rax,%xmm5
  4079e5:	41 b8 00 00 00 00    	mov    $0x0,%r8d
  4079eb:	49 89 cf             	mov    %rcx,%r15
  4079ee:	b9 28 6b 6e 4e       	mov    $0x4e6e6b28,%ecx
  4079f3:	ba 28 6b 6e 4e       	mov    $0x4e6e6b28,%edx
  4079f8:	49 89 f4             	mov    %rsi,%r12
  4079fb:	be 09 00 00 00       	mov    $0x9,%esi
  407a00:	48 89 fb             	mov    %rdi,%rbx
  407a03:	e8 d8 f4 ff ff       	callq  406ee0 <p126_typed_FID_36_100_105_114_101_99_116_46_110_101_97_114_101_115_116_46_116_>
  407a08:	48 89 df             	mov    %rbx,%rdi
  407a0b:	49 89 c5             	mov    %rax,%r13
  407a0e:	f3 0f 10 0d 2a b6 02 00 	movss  0x2b62a(%rip),%xmm1        # 433040 <_IO_stdin_used+0x40>
  407a16:	f3 0f 10 05 1e b6 02 00 	movss  0x2b61e(%rip),%xmm0        # 43303c <_IO_stdin_used+0x3c>
  407a1e:	48 89 fb             	mov    %rdi,%rbx
  407a21:	e8 2a e3 ff ff       	callq  405d50 <p126_typed_FID_36_100_105_114_101_99_116_46_102_108_>
  407a26:	48 89 df             	mov    %rbx,%rdi
  407a29:	48 89 85 68 ff ff ff 	mov    %rax,-0x98(%rbp)
  407a30:	f3 0f 10 0d 00 b6 02 00 	movss  0x2b600(%rip),%xmm1        # 433038 <_IO_stdin_used+0x38>
  407a38:	f3 0f 10 05 f4 b5 02 00 	movss  0x2b5f4(%rip),%xmm0        # 433034 <_IO_stdin_used+0x34>
  407a40:	48 89 fb             	mov    %rdi,%rbx
  407a43:	e8 08 e3 ff ff       	callq  405d50 <p126_typed_FID_36_100_105_114_101_99_116_46_102_108_>
  407a48:	4c 89 e6             	mov    %r12,%rsi
  407a4b:	48 89 df             	mov    %rbx,%rdi
  407a4e:	49 89 c4             	mov    %rax,%r12
  407a51:	48 8b 85 70 ff ff ff 	mov    -0x90(%rbp),%rax
  407a58:	48 8b 9d 68 ff ff ff 	mov    -0x98(%rbp),%rbx
  407a5f:	66 49 0f 6e c5       	movq   %r13,%xmm0
  407a64:	66 48 0f 6e c8       	movq   %rax,%xmm1
  407a69:	49 89 fd             	mov    %rdi,%r13
  407a6c:	e8 af e9 ff ff       	callq  406420 <p126_typed_FID_36_100_105_114_101_99_116_46_115_104_97_100_101_>
  407a71:	4c 89 f9             	mov    %r15,%rcx
  407a74:	4c 89 f6             	mov    %r14,%rsi
  407a77:	4c 89 ef             	mov    %r13,%rdi
  407a7a:	48 89 c2             	mov    %rax,%rdx
  407a7d:	4c 8b b5 60 ff ff ff 	mov    -0xa0(%rbp),%r14
  407a84:	4c 8b bd 58 ff ff ff 	mov    -0xa8(%rbp),%r15
  407a8b:	48 8b 85 50 ff ff ff 	mov    -0xb0(%rbp),%rax
  407a92:	66 49 0f 6e c4       	movq   %r12,%xmm0
  407a97:	66 48 0f 6e ca       	movq   %rdx,%xmm1
  407a9c:	f3 0f 59 c1          	mulss  %xmm1,%xmm0
  407aa0:	66 48 0f 6e cb       	movq   %rbx,%xmm1
  407aa5:	f3 0f 58 c1          	addss  %xmm1,%xmm0
  407aa9:	48 89 c3             	mov    %rax,%rbx
  407aac:	66 48 0f 7e c0       	movq   %xmm0,%rax
  407ab1:	41 89 c5             	mov    %eax,%r13d
  407ab4:	4c 89 ad 30 ff ff ff 	mov    %r13,-0xd0(%rbp)
  407abb:	49 89 f5             	mov    %rsi,%r13
  407abe:	48 89 ce             	mov    %rcx,%rsi
  407ac1:	49 89 fc             	mov    %rdi,%r12
  407ac4:	e8 67 e8 ff ff       	callq  406330 <p113d_FID_36_100_105_114_101_99_116_46_115_107_114_>
  407ac9:	4c 89 ee             	mov    %r13,%rsi
  407acc:	4c 89 e7             	mov    %r12,%rdi
  407acf:	49 89 c4             	mov    %rax,%r12
  407ad2:	48 89 d8             	mov    %rbx,%rax
  407ad5:	4c 8b ad 30 ff ff ff 	mov    -0xd0(%rbp),%r13
  407adc:	f3 0f 10 a5 4c ff ff ff 	movss  -0xb4(%rbp),%xmm4
  407ae4:	f3 0f 10 9d 48 ff ff ff 	movss  -0xb8(%rbp),%xmm3
  407aec:	f3 0f 10 8d 40 ff ff ff 	movss  -0xc0(%rbp),%xmm1
  407af4:	f3 0f 10 ad 3c ff ff ff 	movss  -0xc4(%rbp),%xmm5
  407afc:	f3 0f 10 b5 38 ff ff ff 	movss  -0xc8(%rbp),%xmm6
  407b04:	f3 0f 10 85 44 ff ff ff 	movss  -0xbc(%rbp),%xmm0
  407b0c:	f3 0f 10 d6          	movss  %xmm6,%xmm2
  407b10:	f3 0f 59 d3          	mulss  %xmm3,%xmm2
  407b14:	f3 0f 10 fd          	movss  %xmm5,%xmm7
  407b18:	f3 0f 59 fc          	mulss  %xmm4,%xmm7
  407b1c:	f3 0f 58 d7          	addss  %xmm7,%xmm2
  407b20:	f3 0f 10 f8          	movss  %xmm0,%xmm7
  407b24:	f3 0f 59 f9          	mulss  %xmm1,%xmm7
  407b28:	f3 0f 58 d7          	addss  %xmm7,%xmm2
  407b2c:	f3 0f 59 15 14 b5 02 00 	mulss  0x2b514(%rip),%xmm2        # 433048 <_IO_stdin_used+0x48>
  407b34:	f3 0f 59 f2          	mulss  %xmm2,%xmm6
  407b38:	f3 0f 5c de          	subss  %xmm6,%xmm3
  407b3c:	66 48 0f 7e d9       	movq   %xmm3,%rcx
  407b41:	89 cb                	mov    %ecx,%ebx
  407b43:	f3 0f 59 ea          	mulss  %xmm2,%xmm5
  407b47:	f3 0f 5c e5          	subss  %xmm5,%xmm4
  407b4b:	66 48 0f 7e e1       	movq   %xmm4,%rcx
  407b50:	89 c9                	mov    %ecx,%ecx
  407b52:	48 89 8d 18 ff ff ff 	mov    %rcx,-0xe8(%rbp)
  407b59:	f3 0f 59 ca          	mulss  %xmm2,%xmm1
  407b5d:	f3 0f 10 f0          	movss  %xmm0,%xmm6
  407b61:	f3 0f 5c f1          	subss  %xmm1,%xmm6
  407b65:	f3 0f 11 b5 20 ff ff ff 	movss  %xmm6,-0xe0(%rbp)
  407b6d:	66 48 0f 6e c0       	movq   %rax,%xmm0
  407b72:	f3 0f 11 85 24 ff ff ff 	movss  %xmm0,-0xdc(%rbp)
  407b7a:	66 49 0f 6e d7       	movq   %r15,%xmm2
  407b7f:	f3 0f 11 95 28 ff ff ff 	movss  %xmm2,-0xd8(%rbp)
  407b87:	f3 0f 10 ca          	movss  %xmm2,%xmm1
  407b8b:	66 49 0f 6e d6       	movq   %r14,%xmm2
  407b90:	f3 0f 11 95 2c ff ff ff 	movss  %xmm2,-0xd4(%rbp)
  407b98:	48 83 ec 10          	sub    $0x10,%rsp
  407b9c:	48 89 e0             	mov    %rsp,%rax
  407b9f:	48 c7 40 08 00 00 00 00 	movq   $0x0,0x8(%rax)
  407ba7:	48 c7 00 09 00 00 00 	movq   $0x9,(%rax)
  407bae:	41 b9 28 6b 6e 4e    	mov    $0x4e6e6b28,%r9d
  407bb4:	41 b8 09 00 00 00    	mov    $0x9,%r8d
  407bba:	b9 28 6b 6e 4e       	mov    $0x4e6e6b28,%ecx
  407bbf:	f3 0f 10 ee          	movss  %xmm6,%xmm5
  407bc3:	ba 09 00 00 00       	mov    $0x9,%edx
  407bc8:	49 89 f7             	mov    %rsi,%r15
  407bcb:	48 8d b5 70 fe ff ff 	lea    -0x190(%rbp),%rsi
  407bd2:	49 89 fe             	mov    %rdi,%r14
  407bd5:	e8 66 ec ff ff       	callq  406840 <p126_typed_FID_36_112_114_111_100_117_99_116_46_110_101_97_114_101_115_116_>
  407bda:	4c 89 fe             	mov    %r15,%rsi
  407bdd:	4c 89 f7             	mov    %r14,%rdi
  407be0:	48 8b 85 18 ff ff ff 	mov    -0xe8(%rbp),%rax
  407be7:	f3 0f 10 bd b4 fe ff ff 	movss  -0x14c(%rbp),%xmm7
  407bef:	f3 0f 10 85 b0 fe ff ff 	movss  -0x150(%rbp),%xmm0
  407bf7:	f3 0f 10 9d 2c ff ff ff 	movss  -0xd4(%rbp),%xmm3
  407bff:	f3 0f 10 95 28 ff ff ff 	movss  -0xd8(%rbp),%xmm2
  407c07:	f3 0f 10 8d 24 ff ff ff 	movss  -0xdc(%rbp),%xmm1
  407c0f:	f3 0f 10 b5 20 ff ff ff 	movss  -0xe0(%rbp),%xmm6
  407c17:	48 83 ec f0          	sub    $0xfffffffffffffff0,%rsp
  407c1b:	48 8b 95 70 fe ff ff 	mov    -0x190(%rbp),%rdx
  407c22:	4c 8b 8d 78 fe ff ff 	mov    -0x188(%rbp),%r9
  407c29:	48 8b 8d 80 fe ff ff 	mov    -0x180(%rbp),%rcx
  407c30:	66 49 0f 6e e5       	movq   %r13,%xmm4
  407c35:	f3 0f 10 e8          	movss  %xmm0,%xmm5
  407c39:	f3 0f 59 ec          	mulss  %xmm4,%xmm5
  407c3d:	66 49 0f 6e e4       	movq   %r12,%xmm4
  407c42:	f3 44 0f 10 05 d5 b3 02 00 	movss  0x2b3d5(%rip),%xmm8        # 433020 <_IO_stdin_used+0x20>
  407c4b:	f3 44 0f 5c c4       	subss  %xmm4,%xmm8
  407c50:	f3 41 0f 59 e8       	mulss  %xmm8,%xmm5
  407c55:	f3 0f 58 ef          	addss  %xmm7,%xmm5
  407c59:	66 49 0f 7e e8       	movq   %xmm5,%r8
  407c5e:	45 89 c0             	mov    %r8d,%r8d
  407c61:	f3 0f 10 f8          	movss  %xmm0,%xmm7
  407c65:	f3 0f 59 fc          	mulss  %xmm4,%xmm7
  407c69:	66 49 0f 6e c1       	movq   %r9,%xmm0
  407c6e:	66 48 0f 6e e3       	movq   %rbx,%xmm4
  407c73:	66 48 0f 6e e8       	movq   %rax,%xmm5
  407c78:	48 83 ee 01          	sub    $0x1,%rsi
  407c7c:	f3 0f 11 4d ec       	movss  %xmm1,-0x14(%rbp)
  407c81:	e9 da f8 ff ff       	jmpq   407560 <p126_typed_FID_36_112_114_111_100_117_99_116_46_116_114_97_99_101_+0x70>
  407c86:	be 04 00 00 00       	mov    $0x4,%esi
  407c8b:	e8 70 51 02 00       	callq  42ce00 <p111_rt_fail>
  407c90:	b8 00 00 00 00       	mov    $0x0,%eax
  407c95:	e9 39 06 00 00       	jmpq   4082d3 <p126_typed_FID_36_112_114_111_100_117_99_116_46_116_114_97_99_101_+0xde3>
  407c9a:	2e 2e 2e 4c 89 c0    	cs cs cs mov %r8,%rax
  407ca0:	e9 2e 06 00 00       	jmpq   4082d3 <p126_typed_FID_36_112_114_111_100_117_99_116_46_116_114_97_99_101_+0xde3>
  407ca5:	2e 2e 2e 2e 4c 8b a5 10 ff ff ff 	cs cs cs mov %cs:-0xf0(%rbp),%r12
  407cb0:	2e 2e 4c 8b b5 00 ff ff ff 	cs mov %cs:-0x100(%rbp),%r14
  407cb9:	4c 89 eb             	mov    %r13,%rbx
  407cbc:	4c 8b ad 08 ff ff ff 	mov    -0xf8(%rbp),%r13
  407cc3:	f3 0f 10 75 ec       	movss  -0x14(%rbp),%xmm6
  407cc8:	89 d6                	mov    %edx,%esi
  407cca:	48 8b 95 f8 fe ff ff 	mov    -0x108(%rbp),%rdx
  407cd1:	49 90                	xchg   %rax,%r8
  407cd3:	49 87 c8             	xchg   %rcx,%r8
  407cd6:	f3 0f 10 a5 4c ff ff ff 	movss  -0xb4(%rbp),%xmm4
  407cde:	f3 0f 10 85 48 ff ff ff 	movss  -0xb8(%rbp),%xmm0
  407ce6:	f3 0f 10 4d c8       	movss  -0x38(%rbp),%xmm1
  407ceb:	f3 0f 10 ad bc fe ff ff 	movss  -0x144(%rbp),%xmm5
  407cf3:	f3 0f 10 55 f0       	movss  -0x10(%rbp),%xmm2
  407cf8:	f3 0f 10 5d dc       	movss  -0x24(%rbp),%xmm3
  407cfd:	44 09 c6             	or     %r8d,%esi
  407d00:	0f 85 cd 05 00 00    	jne    4082d3 <p126_typed_FID_36_112_114_111_100_117_99_116_46_116_114_97_99_101_+0xde3>
  407d06:	89 c8                	mov    %ecx,%eax
  407d08:	83 f0 01             	xor    $0x1,%eax
  407d0b:	75 18                	jne    407d25 <p126_typed_FID_36_112_114_111_100_117_99_116_46_116_114_97_99_101_+0x835>
  407d0d:	2e 2e 2e 2e be 04 00 00 00 	cs cs cs cs mov $0x4,%esi
  407d16:	e8 e5 50 02 00       	callq  42ce00 <p111_rt_fail>
  407d1b:	b8 00 00 00 00       	mov    $0x0,%eax
  407d20:	e9 ae 05 00 00       	jmpq   4082d3 <p126_typed_FID_36_112_114_111_100_117_99_116_46_116_114_97_99_101_+0xde3>
  407d25:	48 83 fb 00          	cmp    $0x0,%rbx
  407d29:	0f 94 c0             	sete   %al
  407d2c:	0f b6 c0             	movzbl %al,%eax
  407d2f:	49 89 db             	mov    %rbx,%r11
  407d32:	49 83 eb 01          	sub    $0x1,%r11
  407d36:	49 89 da             	mov    %rbx,%r10
  407d39:	49 83 ea 02          	sub    $0x2,%r10
  407d3d:	49 89 d9             	mov    %rbx,%r9
  407d40:	49 83 e9 03          	sub    $0x3,%r9
  407d44:	49 89 d8             	mov    %rbx,%r8
  407d47:	49 83 e8 04          	sub    $0x4,%r8
  407d4b:	49 89 ff             	mov    %rdi,%r15
  407d4e:	48 89 df             	mov    %rbx,%rdi
  407d51:	48 83 ef 05          	sub    $0x5,%rdi
  407d55:	48 89 de             	mov    %rbx,%rsi
  407d58:	48 83 ee 06          	sub    $0x6,%rsi
  407d5c:	48 89 d9             	mov    %rbx,%rcx
  407d5f:	48 83 e9 07          	sub    $0x7,%rcx
  407d63:	83 f8 00             	cmp    $0x0,%eax
  407d66:	75 64                	jne    407dcc <p126_typed_FID_36_112_114_111_100_117_99_116_46_116_114_97_99_101_+0x8dc>
  407d68:	49 83 fb 00          	cmp    $0x0,%r11
  407d6c:	74 57                	je     407dc5 <p126_typed_FID_36_112_114_111_100_117_99_116_46_116_114_97_99_101_+0x8d5>
  407d6e:	49 83 fa 00          	cmp    $0x0,%r10
  407d72:	74 4a                	je     407dbe <p126_typed_FID_36_112_114_111_100_117_99_116_46_116_114_97_99_101_+0x8ce>
  407d74:	49 83 f9 00          	cmp    $0x0,%r9
  407d78:	74 3d                	je     407db7 <p126_typed_FID_36_112_114_111_100_117_99_116_46_116_114_97_99_101_+0x8c7>
  407d7a:	66 0f 1f 44 00 00    	nopw   0x0(%rax,%rax,1)
  407d80:	49 83 f8 00          	cmp    $0x0,%r8
  407d84:	74 2a                	je     407db0 <p126_typed_FID_36_112_114_111_100_117_99_116_46_116_114_97_99_101_+0x8c0>
  407d86:	48 83 ff 00          	cmp    $0x0,%rdi
  407d8a:	74 1d                	je     407da9 <p126_typed_FID_36_112_114_111_100_117_99_116_46_116_114_97_99_101_+0x8b9>
  407d8c:	48 83 fe 00          	cmp    $0x0,%rsi
  407d90:	74 10                	je     407da2 <p126_typed_FID_36_112_114_111_100_117_99_116_46_116_114_97_99_101_+0x8b2>
  407d92:	2e 48 83 f9 00       	cs cmp $0x0,%rcx
  407d97:	b8 00 00 80 3f       	mov    $0x3f800000,%eax
  407d9c:	49 0f 45 c4          	cmovne %r12,%rax
  407da0:	eb 2f                	jmp    407dd1 <p126_typed_FID_36_112_114_111_100_117_99_116_46_116_114_97_99_101_+0x8e1>
  407da2:	b8 9a 99 99 3f       	mov    $0x3f99999a,%eax
  407da7:	eb 28                	jmp    407dd1 <p126_typed_FID_36_112_114_111_100_117_99_116_46_116_114_97_99_101_+0x8e1>
  407da9:	b8 cd cc cc 3e       	mov    $0x3ecccccd,%eax
  407dae:	eb 21                	jmp    407dd1 <p126_typed_FID_36_112_114_111_100_117_99_116_46_116_114_97_99_101_+0x8e1>
  407db0:	b8 cd cc cc 3e       	mov    $0x3ecccccd,%eax
  407db5:	eb 1a                	jmp    407dd1 <p126_typed_FID_36_112_114_111_100_117_99_116_46_116_114_97_99_101_+0x8e1>
  407db7:	b8 00 00 80 3f       	mov    $0x3f800000,%eax
  407dbc:	eb 13                	jmp    407dd1 <p126_typed_FID_36_112_114_111_100_117_99_116_46_116_114_97_99_101_+0x8e1>
  407dbe:	b8 00 00 80 3f       	mov    $0x3f800000,%eax
  407dc3:	eb 0c                	jmp    407dd1 <p126_typed_FID_36_112_114_111_100_117_99_116_46_116_114_97_99_101_+0x8e1>
  407dc5:	b8 00 00 80 3f       	mov    $0x3f800000,%eax
  407dca:	eb 05                	jmp    407dd1 <p126_typed_FID_36_112_114_111_100_117_99_116_46_116_114_97_99_101_+0x8e1>
  407dcc:	b8 00 40 1c 46       	mov    $0x461c4000,%eax
  407dd1:	48 83 fb 00          	cmp    $0x0,%rbx
  407dd5:	74 6b                	je     407e42 <p126_typed_FID_36_112_114_111_100_117_99_116_46_116_114_97_99_101_+0x952>
  407dd7:	49 83 fb 00          	cmp    $0x0,%r11
  407ddb:	74 59                	je     407e36 <p126_typed_FID_36_112_114_111_100_117_99_116_46_116_114_97_99_101_+0x946>
  407ddd:	0f 1f 00             	nopl   (%rax)
  407de0:	49 83 fa 00          	cmp    $0x0,%r10
  407de4:	74 48                	je     407e2e <p126_typed_FID_36_112_114_111_100_117_99_116_46_116_114_97_99_101_+0x93e>
  407de6:	49 83 f9 00          	cmp    $0x0,%r9
  407dea:	74 3a                	je     407e26 <p126_typed_FID_36_112_114_111_100_117_99_116_46_116_114_97_99_101_+0x936>
  407dec:	49 83 f8 00          	cmp    $0x0,%r8
  407df0:	74 2c                	je     407e1e <p126_typed_FID_36_112_114_111_100_117_99_116_46_116_114_97_99_101_+0x92e>
  407df2:	48 83 ff 00          	cmp    $0x0,%rdi
  407df6:	74 1e                	je     407e16 <p126_typed_FID_36_112_114_111_100_117_99_116_46_116_114_97_99_101_+0x926>
  407df8:	48 83 fe 00          	cmp    $0x0,%rsi
  407dfc:	74 10                	je     407e0e <p126_typed_FID_36_112_114_111_100_117_99_116_46_116_114_97_99_101_+0x91e>
  407dfe:	48 83 f9 00          	cmp    $0x0,%rcx
  407e02:	41 bc 00 00 60 40    	mov    $0x40600000,%r12d
  407e08:	4d 0f 45 e5          	cmovne %r13,%r12
  407e0c:	eb 2f                	jmp    407e3d <p126_typed_FID_36_112_114_111_100_117_99_116_46_116_114_97_99_101_+0x94d>
  407e0e:	41 bc 00 00 00 00    	mov    $0x0,%r12d
  407e14:	eb 27                	jmp    407e3d <p126_typed_FID_36_112_114_111_100_117_99_116_46_116_114_97_99_101_+0x94d>
  407e16:	41 bc 00 00 80 bf    	mov    $0xbf800000,%r12d
  407e1c:	eb 1f                	jmp    407e3d <p126_typed_FID_36_112_114_111_100_117_99_116_46_116_114_97_99_101_+0x94d>
  407e1e:	41 bc 00 00 80 3f    	mov    $0x3f800000,%r12d
  407e24:	eb 17                	jmp    407e3d <p126_typed_FID_36_112_114_111_100_117_99_116_46_116_114_97_99_101_+0x94d>
  407e26:	41 bc 00 00 00 c0    	mov    $0xc0000000,%r12d
  407e2c:	eb 0f                	jmp    407e3d <p126_typed_FID_36_112_114_111_100_117_99_116_46_116_114_97_99_101_+0x94d>
  407e2e:	41 bc 00 00 00 40    	mov    $0x40000000,%r12d
  407e34:	eb 07                	jmp    407e3d <p126_typed_FID_36_112_114_111_100_117_99_116_46_116_114_97_99_101_+0x94d>
  407e36:	2e 41 bc 00 00 00 00 	cs mov $0x0,%r12d
  407e3d:	4d 89 e5             	mov    %r12,%r13
  407e40:	eb 06                	jmp    407e48 <p126_typed_FID_36_112_114_111_100_117_99_116_46_116_114_97_99_101_+0x958>
  407e42:	41 bd 00 00 00 00    	mov    $0x0,%r13d
  407e48:	48 83 fb 00          	cmp    $0x0,%rbx
  407e4c:	74 6c                	je     407eba <p126_typed_FID_36_112_114_111_100_117_99_116_46_116_114_97_99_101_+0x9ca>
  407e4e:	49 83 fb 00          	cmp    $0x0,%r11
  407e52:	74 5e                	je     407eb2 <p126_typed_FID_36_112_114_111_100_117_99_116_46_116_114_97_99_101_+0x9c2>
  407e54:	49 83 fa 00          	cmp    $0x0,%r10
  407e58:	74 50                	je     407eaa <p126_typed_FID_36_112_114_111_100_117_99_116_46_116_114_97_99_101_+0x9ba>
  407e5a:	66 0f 1f 44 00 00    	nopw   0x0(%rax,%rax,1)
  407e60:	49 83 f9 00          	cmp    $0x0,%r9
  407e64:	74 3c                	je     407ea2 <p126_typed_FID_36_112_114_111_100_117_99_116_46_116_114_97_99_101_+0x9b2>
  407e66:	49 83 f8 00          	cmp    $0x0,%r8
  407e6a:	74 2c                	je     407e98 <p126_typed_FID_36_112_114_111_100_117_99_116_46_116_114_97_99_101_+0x9a8>
  407e6c:	48 83 ff 00          	cmp    $0x0,%rdi
  407e70:	74 1e                	je     407e90 <p126_typed_FID_36_112_114_111_100_117_99_116_46_116_114_97_99_101_+0x9a0>
  407e72:	48 83 fe 00          	cmp    $0x0,%rsi
  407e76:	74 10                	je     407e88 <p126_typed_FID_36_112_114_111_100_117_99_116_46_116_114_97_99_101_+0x998>
  407e78:	48 83 f9 00          	cmp    $0x0,%rcx
  407e7c:	41 bc cd cc 4c 3e    	mov    $0x3e4ccccd,%r12d
  407e82:	4d 0f 45 e6          	cmovne %r14,%r12
  407e86:	eb 38                	jmp    407ec0 <p126_typed_FID_36_112_114_111_100_117_99_116_46_116_114_97_99_101_+0x9d0>
  407e88:	41 bc cd cc cc 3f    	mov    $0x3fcccccd,%r12d
  407e8e:	eb 30                	jmp    407ec0 <p126_typed_FID_36_112_114_111_100_117_99_116_46_116_114_97_99_101_+0x9d0>
  407e90:	41 bc 9a 99 19 bf    	mov    $0xbf19999a,%r12d
  407e96:	eb 28                	jmp    407ec0 <p126_typed_FID_36_112_114_111_100_117_99_116_46_116_114_97_99_101_+0x9d0>
  407e98:	2e 2e 41 bc 9a 99 19 bf 	cs cs mov $0xbf19999a,%r12d
  407ea0:	eb 1e                	jmp    407ec0 <p126_typed_FID_36_112_114_111_100_117_99_116_46_116_114_97_99_101_+0x9d0>
  407ea2:	41 bc 00 00 00 3f    	mov    $0x3f000000,%r12d
  407ea8:	eb 16                	jmp    407ec0 <p126_typed_FID_36_112_114_111_100_117_99_116_46_116_114_97_99_101_+0x9d0>
  407eaa:	41 bc 00 00 00 3f    	mov    $0x3f000000,%r12d
  407eb0:	eb 0e                	jmp    407ec0 <p126_typed_FID_36_112_114_111_100_117_99_116_46_116_114_97_99_101_+0x9d0>
  407eb2:	41 bc 00 00 00 00    	mov    $0x0,%r12d
  407eb8:	eb 06                	jmp    407ec0 <p126_typed_FID_36_112_114_111_100_117_99_116_46_116_114_97_99_101_+0x9d0>
  407eba:	41 bc 00 44 1c c6    	mov    $0xc61c4400,%r12d
  407ec0:	48 83 fb 00          	cmp    $0x0,%rbx
  407ec4:	74 5f                	je     407f25 <p126_typed_FID_36_112_114_111_100_117_99_116_46_116_114_97_99_101_+0xa35>
  407ec6:	49 83 fb 00          	cmp    $0x0,%r11
  407eca:	74 52                	je     407f1e <p126_typed_FID_36_112_114_111_100_117_99_116_46_116_114_97_99_101_+0xa2e>
  407ecc:	49 83 fa 00          	cmp    $0x0,%r10
  407ed0:	74 45                	je     407f17 <p126_typed_FID_36_112_114_111_100_117_99_116_46_116_114_97_99_101_+0xa27>
  407ed2:	49 83 f9 00          	cmp    $0x0,%r9
  407ed6:	74 38                	je     407f10 <p126_typed_FID_36_112_114_111_100_117_99_116_46_116_114_97_99_101_+0xa20>
  407ed8:	49 83 f8 00          	cmp    $0x0,%r8
  407edc:	74 2b                	je     407f09 <p126_typed_FID_36_112_114_111_100_117_99_116_46_116_114_97_99_101_+0xa19>
  407ede:	66 90                	xchg   %ax,%ax
  407ee0:	48 83 ff 00          	cmp    $0x0,%rdi
  407ee4:	74 1c                	je     407f02 <p126_typed_FID_36_112_114_111_100_117_99_116_46_116_114_97_99_101_+0xa12>
  407ee6:	48 83 fe 00          	cmp    $0x0,%rsi
  407eea:	74 0f                	je     407efb <p126_typed_FID_36_112_114_111_100_117_99_116_46_116_114_97_99_101_+0xa0b>
  407eec:	48 83 f9 00          	cmp    $0x0,%rcx
  407ef0:	b9 00 00 00 41       	mov    $0x41000000,%ecx
  407ef5:	48 0f 45 ca          	cmovne %rdx,%rcx
  407ef9:	eb 31                	jmp    407f2c <p126_typed_FID_36_112_114_111_100_117_99_116_46_116_114_97_99_101_+0xa3c>
  407efb:	b9 00 00 e0 40       	mov    $0x40e00000,%ecx
  407f00:	eb 2a                	jmp    407f2c <p126_typed_FID_36_112_114_111_100_117_99_116_46_116_114_97_99_101_+0xa3c>
  407f02:	b9 00 00 60 40       	mov    $0x40600000,%ecx
  407f07:	eb 23                	jmp    407f2c <p126_typed_FID_36_112_114_111_100_117_99_116_46_116_114_97_99_101_+0xa3c>
  407f09:	b9 00 00 60 40       	mov    $0x40600000,%ecx
  407f0e:	eb 1c                	jmp    407f2c <p126_typed_FID_36_112_114_111_100_117_99_116_46_116_114_97_99_101_+0xa3c>
  407f10:	b9 00 00 c0 40       	mov    $0x40c00000,%ecx
  407f15:	eb 15                	jmp    407f2c <p126_typed_FID_36_112_114_111_100_117_99_116_46_116_114_97_99_101_+0xa3c>
  407f17:	b9 00 00 c0 40       	mov    $0x40c00000,%ecx
  407f1c:	eb 0e                	jmp    407f2c <p126_typed_FID_36_112_114_111_100_117_99_116_46_116_114_97_99_101_+0xa3c>
  407f1e:	b9 00 00 a0 40       	mov    $0x40a00000,%ecx
  407f23:	eb 07                	jmp    407f2c <p126_typed_FID_36_112_114_111_100_117_99_116_46_116_114_97_99_101_+0xa3c>
  407f25:	2e 2e b9 00 00 a0 40 	cs cs mov $0x40a00000,%ecx
  407f2c:	66 48 0f 6e f9       	movq   %rcx,%xmm7
  407f31:	0f 57 3d d8 b0 02 00 	xorps  0x2b0d8(%rip),%xmm7        # 433010 <_IO_stdin_used+0x10>
  407f38:	f3 0f 58 fd          	addss  %xmm5,%xmm7
  407f3c:	66 48 0f 6e e8       	movq   %rax,%xmm5
  407f41:	f3 0f 11 ad f4 fe ff ff 	movss  %xmm5,-0x10c(%rbp)
  407f49:	f3 44 0f 10 fd       	movss  %xmm5,%xmm15
  407f4e:	f3 0f 10 ef          	movss  %xmm7,%xmm5
  407f52:	f3 41 0f 5e ef       	divss  %xmm15,%xmm5
  407f57:	66 48 0f 7e e8       	movq   %xmm5,%rax
  407f5c:	89 c3                	mov    %eax,%ebx
  407f5e:	f3 0f 59 c3          	mulss  %xmm3,%xmm0
  407f62:	66 48 0f 7e f0       	movq   %xmm6,%rax
  407f67:	89 c0                	mov    %eax,%eax
  407f69:	66 48 0f 6e e8       	movq   %rax,%xmm5
  407f6e:	f3 0f 58 c5          	addss  %xmm5,%xmm0
  407f72:	66 48 0f 7e c0       	movq   %xmm0,%rax
  407f77:	89 c0                	mov    %eax,%eax
  407f79:	66 48 0f 6e c0       	movq   %rax,%xmm0
  407f7e:	f3 0f 11 85 e0 fe ff ff 	movss  %xmm0,-0x120(%rbp)
  407f86:	0f 57 05 83 b0 02 00 	xorps  0x2b083(%rip),%xmm0        # 433010 <_IO_stdin_used+0x10>
  407f8d:	f3 0f 58 05 9b b0 02 00 	addss  0x2b09b(%rip),%xmm0        # 433030 <_IO_stdin_used+0x30>
  407f95:	66 48 0f 7e c0       	movq   %xmm0,%rax
  407f9a:	41 89 c6             	mov    %eax,%r14d
  407f9d:	f3 0f 59 dc          	mulss  %xmm4,%xmm3
  407fa1:	f3 0f 58 d3          	addss  %xmm3,%xmm2
  407fa5:	66 48 0f 7e d0       	movq   %xmm2,%rax
  407faa:	89 c0                	mov    %eax,%eax
  407fac:	66 48 0f 6e d0       	movq   %rax,%xmm2
  407fb1:	f3 0f 11 95 d8 fe ff ff 	movss  %xmm2,-0x128(%rbp)
  407fb9:	0f 57 15 50 b0 02 00 	xorps  0x2b050(%rip),%xmm2        # 433010 <_IO_stdin_used+0x10>
  407fc0:	f3 0f 58 15 64 b0 02 00 	addss  0x2b064(%rip),%xmm2        # 43302c <_IO_stdin_used+0x2c>
  407fc8:	66 48 0f 7e d0       	movq   %xmm2,%rax
  407fcd:	89 c0                	mov    %eax,%eax
  407fcf:	48 89 85 e8 fe ff ff 	mov    %rax,-0x118(%rbp)
  407fd6:	f3 0f 59 c0          	mulss  %xmm0,%xmm0
  407fda:	f3 0f 59 d2          	mulss  %xmm2,%xmm2
  407fde:	f3 0f 58 c2          	addss  %xmm2,%xmm0
  407fe2:	f3 0f 58 c1          	addss  %xmm1,%xmm0
  407fe6:	f3 0f 5a c0          	cvtss2sd %xmm0,%xmm0
  407fea:	e8 d1 a4 ff ff       	callq  4024c0 <sqrt@plt>
  407fef:	4c 89 ff             	mov    %r15,%rdi
  407ff2:	f2 0f 10 c8          	movsd  %xmm0,%xmm1
  407ff6:	48 8b 85 e8 fe ff ff 	mov    -0x118(%rbp),%rax
  407ffd:	f3 0f 10 ad f0 fe ff ff 	movss  -0x110(%rbp),%xmm5
  408005:	f3 0f 10 85 d8 fe ff ff 	movss  -0x128(%rbp),%xmm0
  40800d:	f3 0f 10 b5 f4 fe ff ff 	movss  -0x10c(%rbp),%xmm6
  408015:	f3 0f 10 d8          	movss  %xmm0,%xmm3
  408019:	f3 0f 10 85 e0 fe ff ff 	movss  -0x120(%rbp),%xmm0
  408021:	f2 0f 5a c9          	cvtsd2ss %xmm1,%xmm1
  408025:	f3 0f 11 8d b8 fe ff ff 	movss  %xmm1,-0x148(%rbp)
  40802d:	66 49 0f 6e d6       	movq   %r14,%xmm2
  408032:	f3 0f 5e d1          	divss  %xmm1,%xmm2
  408036:	f3 0f 11 95 c0 fe ff ff 	movss  %xmm2,-0x140(%rbp)
  40803e:	66 48 0f 6e e0       	movq   %rax,%xmm4
  408043:	f3 0f 5e e1          	divss  %xmm1,%xmm4
  408047:	f3 0f 11 a5 c4 fe ff ff 	movss  %xmm4,-0x13c(%rbp)
  40804f:	f3 0f 5e e9          	divss  %xmm1,%xmm5
  408053:	f3 0f 11 ad c8 fe ff ff 	movss  %xmm5,-0x138(%rbp)
  40805b:	66 49 0f 6e cd       	movq   %r13,%xmm1
  408060:	0f 57 0d a9 af 02 00 	xorps  0x2afa9(%rip),%xmm1        # 433010 <_IO_stdin_used+0x10>
  408067:	f3 0f 58 c8          	addss  %xmm0,%xmm1
  40806b:	f3 0f 5e ce          	divss  %xmm6,%xmm1
  40806f:	66 48 0f 7e c8       	movq   %xmm1,%rax
  408074:	89 c0                	mov    %eax,%eax
  408076:	66 48 0f 6e c8       	movq   %rax,%xmm1
  40807b:	f3 0f 11 8d e4 fe ff ff 	movss  %xmm1,-0x11c(%rbp)
  408083:	f3 0f 59 d1          	mulss  %xmm1,%xmm2
  408087:	66 49 0f 6e fc       	movq   %r12,%xmm7
  40808c:	f3 0f 5c df          	subss  %xmm7,%xmm3
  408090:	f3 0f 5e de          	divss  %xmm6,%xmm3
  408094:	66 48 0f 7e d8       	movq   %xmm3,%rax
  408099:	89 c0                	mov    %eax,%eax
  40809b:	66 48 0f 6e d8       	movq   %rax,%xmm3
  4080a0:	f3 0f 11 9d dc fe ff ff 	movss  %xmm3,-0x124(%rbp)
  4080a8:	f3 0f 59 dc          	mulss  %xmm4,%xmm3
  4080ac:	f3 0f 58 d3          	addss  %xmm3,%xmm2
  4080b0:	66 48 0f 6e f3       	movq   %rbx,%xmm6
  4080b5:	f3 0f 11 b5 cc fe ff ff 	movss  %xmm6,-0x134(%rbp)
  4080bd:	f3 0f 10 dd          	movss  %xmm5,%xmm3
  4080c1:	f3 0f 59 de          	mulss  %xmm6,%xmm3
  4080c5:	f3 0f 58 d3          	addss  %xmm3,%xmm2
  4080c9:	f3 0f 10 1d 53 af 02 00 	movss  0x2af53(%rip),%xmm3        # 433024 <_IO_stdin_used+0x24>
  4080d1:	0f 2e da             	ucomiss %xmm2,%xmm3
  4080d4:	0f 97 c0             	seta   %al
  4080d7:	0f b6 c0             	movzbl %al,%eax
  4080da:	89 c1                	mov    %eax,%ecx
  4080dc:	48 83 f9 01          	cmp    $0x1,%rcx
  4080e0:	0f 94 c0             	sete   %al
  4080e3:	0f b6 c0             	movzbl %al,%eax
  4080e6:	48 c1 e9 28          	shr    $0x28,%rcx
  4080ea:	48 81 e1 ff ff 7f 00 	and    $0x7fffff,%rcx
  4080f1:	48 81 f9 02 00 01 00 	cmp    $0x10002,%rcx
  4080f8:	0f 94 c1             	sete   %cl
  4080fb:	0f b6 c9             	movzbl %cl,%ecx
  4080fe:	09 c8                	or     %ecx,%eax
  408100:	75 35                	jne    408137 <p126_typed_FID_36_112_114_111_100_117_99_116_46_116_114_97_99_101_+0xc47>
  408102:	83 f0 01             	xor    $0x1,%eax
  408105:	75 27                	jne    40812e <p126_typed_FID_36_112_114_111_100_117_99_116_46_116_114_97_99_101_+0xc3e>
  408107:	be 04 00 00 00       	mov    $0x4,%esi
  40810c:	48 89 fb             	mov    %rdi,%rbx
  40810f:	e8 ec 4c 02 00       	callq  42ce00 <p111_rt_fail>
  408114:	48 89 df             	mov    %rbx,%rdi
  408117:	f3 0f 10 8d e4 fe ff ff 	movss  -0x11c(%rbp),%xmm1
  40811f:	f3 0f 10 85 e0 fe ff ff 	movss  -0x120(%rbp),%xmm0
  408127:	be 00 00 00 00       	mov    $0x0,%esi
  40812c:	eb 0e                	jmp    40813c <p126_typed_FID_36_112_114_111_100_117_99_116_46_116_114_97_99_101_+0xc4c>
  40812e:	66 48 0f 7e d0       	movq   %xmm2,%rax
  408133:	89 c6                	mov    %eax,%esi
  408135:	eb 05                	jmp    40813c <p126_typed_FID_36_112_114_111_100_117_99_116_46_116_114_97_99_101_+0xc4c>
  408137:	be 00 00 00 00       	mov    $0x0,%esi
  40813c:	49 89 f4             	mov    %rsi,%r12
  40813f:	f3 0f 59 0d e1 ae 02 00 	mulss  0x2aee1(%rip),%xmm1        # 433028 <_IO_stdin_used+0x28>
  408147:	f3 0f 58 c1          	addss  %xmm1,%xmm0
  40814b:	f3 0f 11 85 d0 fe ff ff 	movss  %xmm0,-0x130(%rbp)
  408153:	f3 0f 10 0d e9 ae 02 00 	movss  0x2aee9(%rip),%xmm1        # 433044 <_IO_stdin_used+0x44>
  40815b:	f3 0f 10 05 d9 ae 02 00 	movss  0x2aed9(%rip),%xmm0        # 43303c <_IO_stdin_used+0x3c>
  408163:	48 89 fb             	mov    %rdi,%rbx
  408166:	e8 e5 db ff ff       	callq  405d50 <p126_typed_FID_36_100_105_114_101_99_116_46_102_108_>
  40816b:	48 89 df             	mov    %rbx,%rdi
  40816e:	f3 0f 10 8d dc fe ff ff 	movss  -0x124(%rbp),%xmm1
  408176:	f3 0f 10 85 d8 fe ff ff 	movss  -0x128(%rbp),%xmm0
  40817e:	66 48 0f 6e d0       	movq   %rax,%xmm2
  408183:	f3 0f 59 ca          	mulss  %xmm2,%xmm1
  408187:	f3 0f 58 c8          	addss  %xmm0,%xmm1
  40818b:	f3 0f 11 8d d4 fe ff ff 	movss  %xmm1,-0x12c(%rbp)
  408193:	f3 0f 10 0d a9 ae 02 00 	movss  0x2aea9(%rip),%xmm1        # 433044 <_IO_stdin_used+0x44>
  40819b:	f3 0f 10 05 99 ae 02 00 	movss  0x2ae99(%rip),%xmm0        # 43303c <_IO_stdin_used+0x3c>
  4081a3:	48 89 fb             	mov    %rdi,%rbx
  4081a6:	e8 a5 db ff ff       	callq  405d50 <p126_typed_FID_36_100_105_114_101_99_116_46_102_108_>
  4081ab:	4c 89 e6             	mov    %r12,%rsi
  4081ae:	48 89 df             	mov    %rbx,%rdi
  4081b1:	f3 0f 10 95 bc fe ff ff 	movss  -0x144(%rbp),%xmm2
  4081b9:	f3 0f 10 8d d4 fe ff ff 	movss  -0x12c(%rbp),%xmm1
  4081c1:	f3 0f 10 85 d0 fe ff ff 	movss  -0x130(%rbp),%xmm0
  4081c9:	f3 0f 10 b5 cc fe ff ff 	movss  -0x134(%rbp),%xmm6
  4081d1:	f3 0f 10 ad c8 fe ff ff 	movss  -0x138(%rbp),%xmm5
  4081d9:	f3 0f 10 a5 c4 fe ff ff 	movss  -0x13c(%rbp),%xmm4
  4081e1:	f3 0f 10 9d c0 fe ff ff 	movss  -0x140(%rbp),%xmm3
  4081e9:	66 48 0f 6e f8       	movq   %rax,%xmm7
  4081ee:	f3 0f 59 f7          	mulss  %xmm7,%xmm6
  4081f2:	f3 0f 58 d6          	addss  %xmm6,%xmm2
  4081f6:	66 48 0f 7e d8       	movq   %xmm3,%rax
  4081fb:	89 c0                	mov    %eax,%eax
  4081fd:	66 48 0f 6e d8       	movq   %rax,%xmm3
  408202:	66 48 0f 7e e0       	movq   %xmm4,%rax
  408207:	89 c0                	mov    %eax,%eax
  408209:	66 48 0f 6e e0       	movq   %rax,%xmm4
  40820e:	66 48 0f 7e e8       	movq   %xmm5,%rax
  408213:	89 c0                	mov    %eax,%eax
  408215:	66 48 0f 6e e8       	movq   %rax,%xmm5
  40821a:	41 b8 00 00 00 00    	mov    $0x0,%r8d
  408220:	b9 28 6b 6e 4e       	mov    $0x4e6e6b28,%ecx
  408225:	ba 28 6b 6e 4e       	mov    $0x4e6e6b28,%edx
  40822a:	49 89 f6             	mov    %rsi,%r14
  40822d:	be 09 00 00 00       	mov    $0x9,%esi
  408232:	48 89 fb             	mov    %rdi,%rbx
  408235:	e8 a6 ec ff ff       	callq  406ee0 <p126_typed_FID_36_100_105_114_101_99_116_46_110_101_97_114_101_115_116_46_116_>
  40823a:	48 89 df             	mov    %rbx,%rdi
  40823d:	49 89 c5             	mov    %rax,%r13
  408240:	f3 0f 10 0d f8 ad 02 00 	movss  0x2adf8(%rip),%xmm1        # 433040 <_IO_stdin_used+0x40>
  408248:	f3 0f 10 05 ec ad 02 00 	movss  0x2adec(%rip),%xmm0        # 43303c <_IO_stdin_used+0x3c>
  408250:	48 89 fb             	mov    %rdi,%rbx
  408253:	e8 f8 da ff ff       	callq  405d50 <p126_typed_FID_36_100_105_114_101_99_116_46_102_108_>
  408258:	48 89 df             	mov    %rbx,%rdi
  40825b:	48 89 c3             	mov    %rax,%rbx
  40825e:	f3 0f 10 0d d2 ad 02 00 	movss  0x2add2(%rip),%xmm1        # 433038 <_IO_stdin_used+0x38>
  408266:	f3 0f 10 05 c6 ad 02 00 	movss  0x2adc6(%rip),%xmm0        # 433034 <_IO_stdin_used+0x34>
  40826e:	49 89 fc             	mov    %rdi,%r12
  408271:	e8 da da ff ff       	callq  405d50 <p126_typed_FID_36_100_105_114_101_99_116_46_102_108_>
  408276:	4c 89 f6             	mov    %r14,%rsi
  408279:	4c 89 e7             	mov    %r12,%rdi
  40827c:	49 89 c4             	mov    %rax,%r12
  40827f:	f3 0f 10 8d b8 fe ff ff 	movss  -0x148(%rbp),%xmm1
  408287:	66 49 0f 6e c5       	movq   %r13,%xmm0
  40828c:	66 48 0f 7e c8       	movq   %xmm1,%rax
  408291:	89 c0                	mov    %eax,%eax
  408293:	66 48 0f 6e c8       	movq   %rax,%xmm1
  408298:	e8 83 e1 ff ff       	callq  406420 <p126_typed_FID_36_100_105_114_101_99_116_46_115_104_97_100_101_>
  40829d:	f3 0f 10 bd b4 fe ff ff 	movss  -0x14c(%rbp),%xmm7
  4082a5:	f3 0f 10 85 b0 fe ff ff 	movss  -0x150(%rbp),%xmm0
  4082ad:	66 49 0f 6e cc       	movq   %r12,%xmm1
  4082b2:	66 48 0f 6e d0       	movq   %rax,%xmm2
  4082b7:	f3 0f 59 ca          	mulss  %xmm2,%xmm1
  4082bb:	66 48 0f 6e d3       	movq   %rbx,%xmm2
  4082c0:	f3 0f 58 ca          	addss  %xmm2,%xmm1
  4082c4:	f3 0f 59 c1          	mulss  %xmm1,%xmm0
  4082c8:	f3 0f 58 c7          	addss  %xmm7,%xmm0
  4082cc:	66 48 0f 7e c0       	movq   %xmm0,%rax
  4082d1:	89 c0                	mov    %eax,%eax
  4082d3:	41 5f                	pop    %r15
  4082d5:	41 5e                	pop    %r14
  4082d7:	41 5d                	pop    %r13
  4082d9:	41 5c                	pop    %r12
  4082db:	5b                   	pop    %rbx
  4082dc:	c9                   	leaveq 
  4082dd:	c3                   	retq   
  4082de:	66 90                	xchg   %ax,%ax

