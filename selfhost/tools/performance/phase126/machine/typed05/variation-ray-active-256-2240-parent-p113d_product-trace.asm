00000000004077c0 <p113d_FID_36_112_114_111_100_117_99_116_46_116_114_97_99_101_>:
  4077c0:	f3 0f 1e fa          	endbr64 
  4077c4:	55                   	push   %rbp
  4077c5:	48 89 e5             	mov    %rsp,%rbp
  4077c8:	48 81 ec b8 0a 00 00 	sub    $0xab8,%rsp
  4077cf:	53                   	push   %rbx
  4077d0:	41 54                	push   %r12
  4077d2:	41 55                	push   %r13
  4077d4:	41 56                	push   %r14
  4077d6:	41 57                	push   %r15
  4077d8:	4c 8b 7d 40          	mov    0x40(%rbp),%r15
  4077dc:	48 8b 45 38          	mov    0x38(%rbp),%rax
  4077e0:	4c 8b 65 30          	mov    0x30(%rbp),%r12
  4077e4:	4c 8b 5d 28          	mov    0x28(%rbp),%r11
  4077e8:	4c 8b 55 20          	mov    0x20(%rbp),%r10
  4077ec:	49 89 c5             	mov    %rax,%r13
  4077ef:	48 8b 45 18          	mov    0x18(%rbp),%rax
  4077f3:	4c 8b 75 10          	mov    0x10(%rbp),%r14
  4077f7:	48 89 cb             	mov    %rcx,%rbx
  4077fa:	48 89 d1             	mov    %rdx,%rcx
  4077fd:	4c 89 ca             	mov    %r9,%rdx
  407800:	4d 89 d9             	mov    %r11,%r9
  407803:	4c 87 f6             	xchg   %r14,%rsi
  407806:	4d 87 c6             	xchg   %r8,%r14
  407809:	41 bb 00 00 00 41    	mov    $0x41000000,%r11d
  40780f:	4c 89 9d 50 fe ff ff 	mov    %r11,-0x1b0(%rbp)
  407816:	41 bb cd cc 4c 3e    	mov    $0x3e4ccccd,%r11d
  40781c:	4c 89 9d 98 fe ff ff 	mov    %r11,-0x168(%rbp)
  407823:	41 bb 00 00 60 c0    	mov    $0xc0600000,%r11d
  407829:	4c 89 9d a0 fe ff ff 	mov    %r11,-0x160(%rbp)
  407830:	41 bb 00 00 80 3f    	mov    $0x3f800000,%r11d
  407836:	4c 89 9d 00 ff ff ff 	mov    %r11,-0x100(%rbp)
  40783d:	4d 89 cb             	mov    %r9,%r11
  407840:	49 89 d1             	mov    %rdx,%r9
  407843:	4c 89 f2             	mov    %r14,%rdx
  407846:	4d 89 ee             	mov    %r13,%r14
  407849:	49 89 f5             	mov    %rsi,%r13
  40784c:	49 87 df             	xchg   %rbx,%r15
  40784f:	48 87 fb             	xchg   %rdi,%rbx
  407852:	66 66 2e 0f 1f 84 00 00 00 00 00 	data16 nopw %cs:0x0(%rax,%rax,1)
  40785d:	0f 1f 00             	nopl   (%rax)
  407860:	4c 89 85 30 ff ff ff 	mov    %r8,-0xd0(%rbp)
  407867:	4c 89 8d e0 fe ff ff 	mov    %r9,-0x120(%rbp)
  40786e:	4c 89 ad f8 fe ff ff 	mov    %r13,-0x108(%rbp)
  407875:	48 89 85 f0 fe ff ff 	mov    %rax,-0x110(%rbp)
  40787c:	4c 89 95 60 ff ff ff 	mov    %r10,-0xa0(%rbp)
  407883:	4c 89 9d 58 ff ff ff 	mov    %r11,-0xa8(%rbp)
  40788a:	4c 89 65 90          	mov    %r12,-0x70(%rbp)
  40788e:	4c 89 b5 f8 fd ff ff 	mov    %r14,-0x208(%rbp)
  407895:	48 89 bd 20 fe ff ff 	mov    %rdi,-0x1e0(%rbp)
  40789c:	49 83 f8 00          	cmp    $0x0,%r8
  4078a0:	40 0f 94 c6          	sete   %sil
  4078a4:	40 0f b6 f6          	movzbl %sil,%esi
  4078a8:	66 49 0f 6e cf       	movq   %r15,%xmm1
  4078ad:	66 49 0f 6e ea       	movq   %r10,%xmm5
  4078b2:	f3 0f 11 6d 80       	movss  %xmm5,-0x80(%rbp)
  4078b7:	f3 0f 10 c1          	movss  %xmm1,%xmm0
  4078bb:	f3 0f 59 c5          	mulss  %xmm5,%xmm0
  4078bf:	66 49 0f 7e c0       	movq   %xmm0,%r8
  4078c4:	66 49 0f 6e c1       	movq   %r9,%xmm0
  4078c9:	45 89 c0             	mov    %r8d,%r8d
  4078cc:	4c 89 85 d8 fe ff ff 	mov    %r8,-0x128(%rbp)
  4078d3:	66 49 0f 6e d0       	movq   %r8,%xmm2
  4078d8:	f3 0f 58 c2          	addss  %xmm2,%xmm0
  4078dc:	66 49 0f 7e c1       	movq   %xmm0,%r9
  4078e1:	66 49 0f 6e db       	movq   %r11,%xmm3
  4078e6:	f3 0f 11 5d 84       	movss  %xmm3,-0x7c(%rbp)
  4078eb:	f3 0f 10 c1          	movss  %xmm1,%xmm0
  4078ef:	f3 0f 59 c3          	mulss  %xmm3,%xmm0
  4078f3:	66 49 0f 7e c0       	movq   %xmm0,%r8
  4078f8:	66 49 0f 6e c5       	movq   %r13,%xmm0
  4078fd:	45 89 c0             	mov    %r8d,%r8d
  407900:	4c 89 85 d0 fe ff ff 	mov    %r8,-0x130(%rbp)
  407907:	66 49 0f 6e d0       	movq   %r8,%xmm2
  40790c:	f3 0f 58 c2          	addss  %xmm2,%xmm0
  407910:	66 49 0f 7e c0       	movq   %xmm0,%r8
  407915:	66 49 0f 6e c4       	movq   %r12,%xmm0
  40791a:	f3 0f 11 45 88       	movss  %xmm0,-0x78(%rbp)
  40791f:	f3 0f 59 c1          	mulss  %xmm1,%xmm0
  407923:	49 89 c2             	mov    %rax,%r10
  407926:	66 48 0f 7e c0       	movq   %xmm0,%rax
  40792b:	66 49 0f 6e c2       	movq   %r10,%xmm0
  407930:	89 c0                	mov    %eax,%eax
  407932:	48 89 85 c8 fe ff ff 	mov    %rax,-0x138(%rbp)
  407939:	66 48 0f 6e c8       	movq   %rax,%xmm1
  40793e:	f3 0f 58 c1          	addss  %xmm1,%xmm0
  407942:	66 48 0f 7e c0       	movq   %xmm0,%rax
  407947:	45 89 cc             	mov    %r9d,%r12d
  40794a:	4c 89 65 e8          	mov    %r12,-0x18(%rbp)
  40794e:	66 49 0f 6e c4       	movq   %r12,%xmm0
  407953:	f3 0f 11 85 08 fe ff ff 	movss  %xmm0,-0x1f8(%rbp)
  40795b:	45 89 c5             	mov    %r8d,%r13d
  40795e:	4c 89 6d e0          	mov    %r13,-0x20(%rbp)
  407962:	66 49 0f 6e cd       	movq   %r13,%xmm1
  407967:	f3 0f 11 8d f0 fd ff ff 	movss  %xmm1,-0x210(%rbp)
  40796f:	89 c0                	mov    %eax,%eax
  407971:	48 89 45 c0          	mov    %rax,-0x40(%rbp)
  407975:	f3 0f 10 d0          	movss  %xmm0,%xmm2
  407979:	66 48 0f 6e c0       	movq   %rax,%xmm0
  40797e:	f3 0f 11 85 d8 fd ff ff 	movss  %xmm0,-0x228(%rbp)
  407986:	0f 57 15 83 a6 02 00 	xorps  0x2a683(%rip),%xmm2        # 432010 <_IO_stdin_used+0x10>
  40798d:	f3 0f 58 15 9b a6 02 00 	addss  0x2a69b(%rip),%xmm2        # 432030 <_IO_stdin_used+0x30>
  407995:	66 49 0f 7e d1       	movq   %xmm2,%r9
  40799a:	0f 57 0d 6f a6 02 00 	xorps  0x2a66f(%rip),%xmm1        # 432010 <_IO_stdin_used+0x10>
  4079a1:	f3 0f 58 0d 83 a6 02 00 	addss  0x2a683(%rip),%xmm1        # 43202c <_IO_stdin_used+0x2c>
  4079a9:	66 49 0f 7e c8       	movq   %xmm1,%r8
  4079ae:	0f 57 05 5b a6 02 00 	xorps  0x2a65b(%rip),%xmm0        # 432010 <_IO_stdin_used+0x10>
  4079b5:	f3 0f 58 05 63 a6 02 00 	addss  0x2a663(%rip),%xmm0        # 432020 <_IO_stdin_used+0x20>
  4079bd:	66 48 0f 7e c0       	movq   %xmm0,%rax
  4079c2:	45 89 c9             	mov    %r9d,%r9d
  4079c5:	4c 89 4d f0          	mov    %r9,-0x10(%rbp)
  4079c9:	66 49 0f 6e d9       	movq   %r9,%xmm3
  4079ce:	f3 0f 11 9d 38 fe ff ff 	movss  %xmm3,-0x1c8(%rbp)
  4079d6:	f3 0f 10 c3          	movss  %xmm3,%xmm0
  4079da:	f3 0f 59 c3          	mulss  %xmm3,%xmm0
  4079de:	66 49 0f 7e c1       	movq   %xmm0,%r9
  4079e3:	45 89 c0             	mov    %r8d,%r8d
  4079e6:	4c 89 85 10 fe ff ff 	mov    %r8,-0x1f0(%rbp)
  4079ed:	66 49 0f 6e d0       	movq   %r8,%xmm2
  4079f2:	f3 0f 11 95 3c fe ff ff 	movss  %xmm2,-0x1c4(%rbp)
  4079fa:	f3 0f 10 c2          	movss  %xmm2,%xmm0
  4079fe:	f3 0f 59 c2          	mulss  %xmm2,%xmm0
  407a02:	66 49 0f 7e c0       	movq   %xmm0,%r8
  407a07:	45 89 cb             	mov    %r9d,%r11d
  407a0a:	4c 89 9d c0 fe ff ff 	mov    %r11,-0x140(%rbp)
  407a11:	66 49 0f 6e c3       	movq   %r11,%xmm0
  407a16:	45 89 c2             	mov    %r8d,%r10d
  407a19:	4c 89 95 b8 fe ff ff 	mov    %r10,-0x148(%rbp)
  407a20:	66 49 0f 6e ca       	movq   %r10,%xmm1
  407a25:	f3 0f 58 c1          	addss  %xmm1,%xmm0
  407a29:	66 49 0f 7e c0       	movq   %xmm0,%r8
  407a2e:	89 c0                	mov    %eax,%eax
  407a30:	48 89 85 18 fe ff ff 	mov    %rax,-0x1e8(%rbp)
  407a37:	66 48 0f 6e c0       	movq   %rax,%xmm0
  407a3c:	f3 0f 11 85 40 fe ff ff 	movss  %xmm0,-0x1c0(%rbp)
  407a44:	f3 0f 59 c0          	mulss  %xmm0,%xmm0
  407a48:	66 48 0f 7e c0       	movq   %xmm0,%rax
  407a4d:	45 89 c0             	mov    %r8d,%r8d
  407a50:	4c 89 85 b0 fe ff ff 	mov    %r8,-0x150(%rbp)
  407a57:	66 49 0f 6e c0       	movq   %r8,%xmm0
  407a5c:	89 c0                	mov    %eax,%eax
  407a5e:	48 89 85 a8 fe ff ff 	mov    %rax,-0x158(%rbp)
  407a65:	66 48 0f 6e c8       	movq   %rax,%xmm1
  407a6a:	f3 0f 58 c1          	addss  %xmm1,%xmm0
  407a6e:	48 89 f8             	mov    %rdi,%rax
  407a71:	66 48 0f 7e c7       	movq   %xmm0,%rdi
  407a76:	66 48 0f 6e c0       	movq   %rax,%xmm0
  407a7b:	f3 0f 11 85 90 fd ff ff 	movss  %xmm0,-0x270(%rbp)
  407a83:	66 49 0f 6e d6       	movq   %r14,%xmm2
  407a88:	f3 0f 11 95 94 fd ff ff 	movss  %xmm2,-0x26c(%rbp)
  407a90:	48 83 f9 01          	cmp    $0x1,%rcx
  407a94:	48 89 c8             	mov    %rcx,%rax
  407a97:	0f 94 c1             	sete   %cl
  407a9a:	0f b6 c9             	movzbl %cl,%ecx
  407a9d:	48 c1 e8 28          	shr    $0x28,%rax
  407aa1:	48 25 ff ff 7f 00    	and    $0x7fffff,%rax
  407aa7:	48 3d 02 00 01 00    	cmp    $0x10002,%rax
  407aad:	49 89 d6             	mov    %rdx,%r14
  407ab0:	0f 94 c2             	sete   %dl
  407ab3:	0f b6 d2             	movzbl %dl,%edx
  407ab6:	89 95 10 ff ff ff    	mov    %edx,-0xf0(%rbp)
  407abc:	89 c8                	mov    %ecx,%eax
  407abe:	09 d0                	or     %edx,%eax
  407ac0:	89 85 0c ff ff ff    	mov    %eax,-0xf4(%rbp)
  407ac6:	89 ff                	mov    %edi,%edi
  407ac8:	48 89 bd 90 fe ff ff 	mov    %rdi,-0x170(%rbp)
  407acf:	83 fe 00             	cmp    $0x0,%esi
  407ad2:	0f 85 0d 0b 00 00    	jne    4085e5 <p113d_FID_36_112_114_111_100_117_99_116_46_116_114_97_99_101_+0xe25>
  407ad8:	09 d1                	or     %edx,%ecx
  407ada:	66 0f 1f 44 00 00    	nopw   0x0(%rax,%rax,1)
  407ae0:	0f 85 f0 0a 00 00    	jne    4085d6 <p113d_FID_36_112_114_111_100_117_99_116_46_116_114_97_99_101_+0xe16>
  407ae6:	83 f0 01             	xor    $0x1,%eax
  407ae9:	0f 84 d0 0a 00 00    	je     4085bf <p113d_FID_36_112_114_111_100_117_99_116_46_116_114_97_99_101_+0xdff>
  407aef:	4c 89 f6             	mov    %r14,%rsi
  407af2:	48 89 df             	mov    %rbx,%rdi
  407af5:	e8 56 eb ff ff       	callq  406650 <p113d_FID_36_100_105_114_101_99_116_46_115_114_>
  407afa:	4c 89 fa             	mov    %r15,%rdx
  407afd:	49 89 c1             	mov    %rax,%r9
  407b00:	4d 89 cf             	mov    %r9,%r15
  407b03:	4c 8b 8d e0 fe ff ff 	mov    -0x120(%rbp),%r9
  407b0a:	48 8b bd f8 fe ff ff 	mov    -0x108(%rbp),%rdi
  407b11:	48 8b 85 f0 fe ff ff 	mov    -0x110(%rbp),%rax
  407b18:	4c 8b 95 60 ff ff ff 	mov    -0xa0(%rbp),%r10
  407b1f:	4c 8b 9d 58 ff ff ff 	mov    -0xa8(%rbp),%r11
  407b26:	48 8b 4d 90          	mov    -0x70(%rbp),%rcx
  407b2a:	48 8b b5 d0 fe ff ff 	mov    -0x130(%rbp),%rsi
  407b31:	4c 8b 85 d8 fe ff ff 	mov    -0x128(%rbp),%r8
  407b38:	4c 89 7d f8          	mov    %r15,-0x8(%rbp)
  407b3c:	48 89 95 50 f5 ff ff 	mov    %rdx,-0xab0(%rbp)
  407b43:	4c 89 95 58 f5 ff ff 	mov    %r10,-0xaa8(%rbp)
  407b4a:	49 89 c2             	mov    %rax,%r10
  407b4d:	48 8b 85 c8 fe ff ff 	mov    -0x138(%rbp),%rax
  407b54:	4c 89 8d 50 f5 ff ff 	mov    %r9,-0xab0(%rbp)
  407b5b:	4c 89 85 58 f5 ff ff 	mov    %r8,-0xaa8(%rbp)
  407b62:	48 89 95 50 f5 ff ff 	mov    %rdx,-0xab0(%rbp)
  407b69:	4c 89 9d 58 f5 ff ff 	mov    %r11,-0xaa8(%rbp)
  407b70:	48 89 bd 50 f5 ff ff 	mov    %rdi,-0xab0(%rbp)
  407b77:	48 89 b5 58 f5 ff ff 	mov    %rsi,-0xaa8(%rbp)
  407b7e:	48 89 95 50 f5 ff ff 	mov    %rdx,-0xab0(%rbp)
  407b85:	48 89 8d 58 f5 ff ff 	mov    %rcx,-0xaa8(%rbp)
  407b8c:	4c 89 95 50 f5 ff ff 	mov    %r10,-0xab0(%rbp)
  407b93:	48 89 85 58 f5 ff ff 	mov    %rax,-0xaa8(%rbp)
  407b9a:	4c 89 f6             	mov    %r14,%rsi
  407b9d:	48 89 df             	mov    %rbx,%rdi
  407ba0:	e8 ab ed ff ff       	callq  406950 <p113d_FID_36_100_105_114_101_99_116_46_115_120_>
  407ba5:	4d 89 f9             	mov    %r15,%r9
  407ba8:	f3 0f 10 85 08 fe ff ff 	movss  -0x1f8(%rbp),%xmm0
  407bb0:	4c 89 a5 50 f5 ff ff 	mov    %r12,-0xab0(%rbp)
  407bb7:	48 89 85 58 f5 ff ff 	mov    %rax,-0xaa8(%rbp)
  407bbe:	66 48 0f 6e c8       	movq   %rax,%xmm1
  407bc3:	f3 0f 5c c1          	subss  %xmm1,%xmm0
  407bc7:	66 48 0f 7e c0       	movq   %xmm0,%rax
  407bcc:	89 c0                	mov    %eax,%eax
  407bce:	48 89 85 50 f5 ff ff 	mov    %rax,-0xab0(%rbp)
  407bd5:	4c 89 8d 58 f5 ff ff 	mov    %r9,-0xaa8(%rbp)
  407bdc:	66 48 0f 6e c0       	movq   %rax,%xmm0
  407be1:	66 49 0f 6e c9       	movq   %r9,%xmm1
  407be6:	f3 0f 11 4d 8c       	movss  %xmm1,-0x74(%rbp)
  407beb:	f3 0f 5e c1          	divss  %xmm1,%xmm0
  407bef:	66 48 0f 7e c0       	movq   %xmm0,%rax
  407bf4:	41 89 c7             	mov    %eax,%r15d
  407bf7:	4c 89 f6             	mov    %r14,%rsi
  407bfa:	48 89 df             	mov    %rbx,%rdi
  407bfd:	e8 ee eb ff ff       	callq  4067f0 <p113d_FID_36_100_105_114_101_99_116_46_115_121_>
  407c02:	f3 0f 10 85 f0 fd ff ff 	movss  -0x210(%rbp),%xmm0
  407c0a:	f3 0f 10 4d 8c       	movss  -0x74(%rbp),%xmm1
  407c0f:	4c 8b 4d f8          	mov    -0x8(%rbp),%r9
  407c13:	4c 89 ad 50 f5 ff ff 	mov    %r13,-0xab0(%rbp)
  407c1a:	48 89 85 58 f5 ff ff 	mov    %rax,-0xaa8(%rbp)
  407c21:	66 48 0f 6e d0       	movq   %rax,%xmm2
  407c26:	f3 0f 5c c2          	subss  %xmm2,%xmm0
  407c2a:	66 48 0f 7e c0       	movq   %xmm0,%rax
  407c2f:	89 c0                	mov    %eax,%eax
  407c31:	48 89 85 50 f5 ff ff 	mov    %rax,-0xab0(%rbp)
  407c38:	4c 89 8d 58 f5 ff ff 	mov    %r9,-0xaa8(%rbp)
  407c3f:	66 48 0f 6e c0       	movq   %rax,%xmm0
  407c44:	f3 0f 5e c1          	divss  %xmm1,%xmm0
  407c48:	66 48 0f 7e c0       	movq   %xmm0,%rax
  407c4d:	89 c6                	mov    %eax,%esi
  407c4f:	49 89 f5             	mov    %rsi,%r13
  407c52:	4c 89 f6             	mov    %r14,%rsi
  407c55:	48 89 df             	mov    %rbx,%rdi
  407c58:	e8 c3 ea ff ff       	callq  406720 <p113d_FID_36_100_105_114_101_99_116_46_115_122_>
  407c5d:	4c 89 f2             	mov    %r14,%rdx
  407c60:	4c 89 ee             	mov    %r13,%rsi
  407c63:	48 89 c1             	mov    %rax,%rcx
  407c66:	4c 8b 95 b8 fe ff ff 	mov    -0x148(%rbp),%r10
  407c6d:	4c 8b 9d c0 fe ff ff 	mov    -0x140(%rbp),%r11
  407c74:	4c 8b 85 18 fe ff ff 	mov    -0x1e8(%rbp),%r8
  407c7b:	48 8b bd 10 fe ff ff 	mov    -0x1f0(%rbp),%rdi
  407c82:	4c 8b 6d f0          	mov    -0x10(%rbp),%r13
  407c86:	4c 8b 75 c0          	mov    -0x40(%rbp),%r14
  407c8a:	48 8b 45 e0          	mov    -0x20(%rbp),%rax
  407c8e:	f3 0f 10 85 d8 fd ff ff 	movss  -0x228(%rbp),%xmm0
  407c96:	f3 0f 10 4d 8c       	movss  -0x74(%rbp),%xmm1
  407c9b:	4c 8b 4d f8          	mov    -0x8(%rbp),%r9
  407c9f:	4c 89 b5 50 f5 ff ff 	mov    %r14,-0xab0(%rbp)
  407ca6:	48 89 8d 58 f5 ff ff 	mov    %rcx,-0xaa8(%rbp)
  407cad:	66 48 0f 6e d1       	movq   %rcx,%xmm2
  407cb2:	f3 0f 5c c2          	subss  %xmm2,%xmm0
  407cb6:	66 48 0f 7e c1       	movq   %xmm0,%rcx
  407cbb:	89 c9                	mov    %ecx,%ecx
  407cbd:	48 89 8d 50 f5 ff ff 	mov    %rcx,-0xab0(%rbp)
  407cc4:	4c 89 8d 58 f5 ff ff 	mov    %r9,-0xaa8(%rbp)
  407ccb:	66 48 0f 6e c1       	movq   %rcx,%xmm0
  407cd0:	f3 0f 5e c1          	divss  %xmm1,%xmm0
  407cd4:	66 48 0f 7e c1       	movq   %xmm0,%rcx
  407cd9:	89 c9                	mov    %ecx,%ecx
  407cdb:	48 c7 85 50 f5 ff ff 00 00 00 00 	movq   $0x0,-0xab0(%rbp)
  407ce6:	48 c7 85 50 f5 ff ff 03 00 00 00 	movq   $0x3,-0xab0(%rbp)
  407cf1:	48 c7 85 50 f5 ff ff 00 00 00 00 	movq   $0x0,-0xab0(%rbp)
  407cfc:	48 c7 85 58 f5 ff ff 00 00 40 40 	movq   $0x40400000,-0xaa8(%rbp)
  407d07:	41 b9 00 00 40 c0    	mov    $0xc0400000,%r9d
  407d0d:	4c 89 8d 50 f5 ff ff 	mov    %r9,-0xab0(%rbp)
  407d14:	4d 89 c1             	mov    %r8,%r9
  407d17:	4c 8b 85 b0 fe ff ff 	mov    -0x150(%rbp),%r8
  407d1e:	4c 89 a5 58 f5 ff ff 	mov    %r12,-0xaa8(%rbp)
  407d25:	49 89 fc             	mov    %rdi,%r12
  407d28:	48 8b bd a8 fe ff ff 	mov    -0x158(%rbp),%rdi
  407d2f:	48 c7 85 50 f5 ff ff 08 00 00 00 	movq   $0x8,-0xab0(%rbp)
  407d3a:	48 c7 85 50 f5 ff ff 00 00 00 41 	movq   $0x41000000,-0xab0(%rbp)
  407d45:	48 89 85 58 f5 ff ff 	mov    %rax,-0xaa8(%rbp)
  407d4c:	48 8b 85 90 fe ff ff 	mov    -0x170(%rbp),%rax
  407d53:	48 c7 85 50 f5 ff ff 01 00 00 00 	movq   $0x1,-0xab0(%rbp)
  407d5e:	48 c7 85 50 f5 ff ff 00 00 80 3f 	movq   $0x3f800000,-0xab0(%rbp)
  407d69:	4c 89 b5 58 f5 ff ff 	mov    %r14,-0xaa8(%rbp)
  407d70:	4c 89 ad 50 f5 ff ff 	mov    %r13,-0xab0(%rbp)
  407d77:	4c 89 ad 58 f5 ff ff 	mov    %r13,-0xaa8(%rbp)
  407d7e:	4c 89 a5 50 f5 ff ff 	mov    %r12,-0xab0(%rbp)
  407d85:	4c 89 a5 58 f5 ff ff 	mov    %r12,-0xaa8(%rbp)
  407d8c:	4c 89 9d 50 f5 ff ff 	mov    %r11,-0xab0(%rbp)
  407d93:	4c 89 95 58 f5 ff ff 	mov    %r10,-0xaa8(%rbp)
  407d9a:	4c 89 8d 50 f5 ff ff 	mov    %r9,-0xab0(%rbp)
  407da1:	4c 89 8d 58 f5 ff ff 	mov    %r9,-0xaa8(%rbp)
  407da8:	4c 89 85 50 f5 ff ff 	mov    %r8,-0xab0(%rbp)
  407daf:	48 89 bd 58 f5 ff ff 	mov    %rdi,-0xaa8(%rbp)
  407db6:	48 89 85 50 f5 ff ff 	mov    %rax,-0xab0(%rbp)
  407dbd:	49 89 ce             	mov    %rcx,%r14
  407dc0:	b9 01 00 00 00       	mov    $0x1,%ecx
  407dc5:	49 89 d5             	mov    %rdx,%r13
  407dc8:	48 8d 95 50 f5 ff ff 	lea    -0xab0(%rbp),%rdx
  407dcf:	49 89 f4             	mov    %rsi,%r12
  407dd2:	be 24 00 00 00       	mov    $0x24,%esi
  407dd7:	48 89 df             	mov    %rbx,%rdi
  407dda:	e8 e1 4a 02 00       	callq  42c8c0 <p111_rt_op>
  407ddf:	4d 89 f8             	mov    %r15,%r8
  407de2:	4c 89 f1             	mov    %r14,%rcx
  407de5:	4c 89 ea             	mov    %r13,%rdx
  407de8:	4c 89 e6             	mov    %r12,%rsi
  407deb:	4d 89 c7             	mov    %r8,%r15
  407dee:	4c 8b 85 18 fe ff ff 	mov    -0x1e8(%rbp),%r8
  407df5:	48 8b bd 10 fe ff ff 	mov    -0x1f0(%rbp),%rdi
  407dfc:	4c 8b 65 f0          	mov    -0x10(%rbp),%r12
  407e00:	f3 0f 10 85 40 fe ff ff 	movss  -0x1c0(%rbp),%xmm0
  407e08:	f3 0f 10 95 3c fe ff ff 	movss  -0x1c4(%rbp),%xmm2
  407e10:	f3 0f 10 9d 38 fe ff ff 	movss  -0x1c8(%rbp),%xmm3
  407e18:	48 89 45 a8          	mov    %rax,-0x58(%rbp)
  407e1c:	4c 89 a5 50 f5 ff ff 	mov    %r12,-0xab0(%rbp)
  407e23:	48 89 85 58 f5 ff ff 	mov    %rax,-0xaa8(%rbp)
  407e2a:	66 48 0f 6e c8       	movq   %rax,%xmm1
  407e2f:	f3 0f 5e d9          	divss  %xmm1,%xmm3
  407e33:	66 49 0f 7e d9       	movq   %xmm3,%r9
  407e38:	45 89 c9             	mov    %r9d,%r9d
  407e3b:	4c 89 4d c8          	mov    %r9,-0x38(%rbp)
  407e3f:	48 89 bd 50 f5 ff ff 	mov    %rdi,-0xab0(%rbp)
  407e46:	48 89 85 58 f5 ff ff 	mov    %rax,-0xaa8(%rbp)
  407e4d:	f3 0f 5e d1          	divss  %xmm1,%xmm2
  407e51:	66 48 0f 7e d7       	movq   %xmm2,%rdi
  407e56:	89 ff                	mov    %edi,%edi
  407e58:	48 89 7d d0          	mov    %rdi,-0x30(%rbp)
  407e5c:	4c 89 85 50 f5 ff ff 	mov    %r8,-0xab0(%rbp)
  407e63:	48 89 85 58 f5 ff ff 	mov    %rax,-0xaa8(%rbp)
  407e6a:	f3 0f 5e c1          	divss  %xmm1,%xmm0
  407e6e:	66 48 0f 7e c0       	movq   %xmm0,%rax
  407e73:	41 89 c3             	mov    %eax,%r11d
  407e76:	4c 89 5d d8          	mov    %r11,-0x28(%rbp)
  407e7a:	4c 89 bd 50 f5 ff ff 	mov    %r15,-0xab0(%rbp)
  407e81:	4c 89 8d 58 f5 ff ff 	mov    %r9,-0xaa8(%rbp)
  407e88:	66 49 0f 6e f7       	movq   %r15,%xmm6
  407e8d:	f3 0f 11 b5 14 ff ff ff 	movss  %xmm6,-0xec(%rbp)
  407e95:	66 49 0f 6e c1       	movq   %r9,%xmm0
  407e9a:	f3 0f 59 c6          	mulss  %xmm6,%xmm0
  407e9e:	66 48 0f 7e c0       	movq   %xmm0,%rax
  407ea3:	49 89 d5             	mov    %rdx,%r13
  407ea6:	89 c2                	mov    %eax,%edx
  407ea8:	48 89 b5 50 f5 ff ff 	mov    %rsi,-0xab0(%rbp)
  407eaf:	48 89 bd 58 f5 ff ff 	mov    %rdi,-0xaa8(%rbp)
  407eb6:	66 48 0f 6e e6       	movq   %rsi,%xmm4
  407ebb:	f3 0f 11 a5 78 ff ff ff 	movss  %xmm4,-0x88(%rbp)
  407ec3:	66 48 0f 6e c7       	movq   %rdi,%xmm0
  407ec8:	f3 0f 59 c4          	mulss  %xmm4,%xmm0
  407ecc:	66 48 0f 7e c0       	movq   %xmm0,%rax
  407ed1:	89 c0                	mov    %eax,%eax
  407ed3:	48 89 95 50 f5 ff ff 	mov    %rdx,-0xab0(%rbp)
  407eda:	48 89 85 58 f5 ff ff 	mov    %rax,-0xaa8(%rbp)
  407ee1:	66 48 0f 6e c2       	movq   %rdx,%xmm0
  407ee6:	66 48 0f 6e c8       	movq   %rax,%xmm1
  407eeb:	f3 0f 58 c1          	addss  %xmm1,%xmm0
  407eef:	66 48 0f 7e c0       	movq   %xmm0,%rax
  407ef4:	49 89 ce             	mov    %rcx,%r14
  407ef7:	89 c1                	mov    %eax,%ecx
  407ef9:	4c 89 b5 50 f5 ff ff 	mov    %r14,-0xab0(%rbp)
  407f00:	4c 89 9d 58 f5 ff ff 	mov    %r11,-0xaa8(%rbp)
  407f07:	66 49 0f 6e ce       	movq   %r14,%xmm1
  407f0c:	f3 0f 11 8d 7c ff ff ff 	movss  %xmm1,-0x84(%rbp)
  407f14:	66 49 0f 6e c3       	movq   %r11,%xmm0
  407f19:	f3 0f 59 c1          	mulss  %xmm1,%xmm0
  407f1d:	66 48 0f 7e c0       	movq   %xmm0,%rax
  407f22:	89 c0                	mov    %eax,%eax
  407f24:	48 89 8d 50 f5 ff ff 	mov    %rcx,-0xab0(%rbp)
  407f2b:	48 89 85 58 f5 ff ff 	mov    %rax,-0xaa8(%rbp)
  407f32:	66 48 0f 6e c1       	movq   %rcx,%xmm0
  407f37:	66 48 0f 6e c8       	movq   %rax,%xmm1
  407f3c:	f3 0f 58 c1          	addss  %xmm1,%xmm0
  407f40:	66 48 0f 7e c0       	movq   %xmm0,%rax
  407f45:	49 89 f4             	mov    %rsi,%r12
  407f48:	89 c6                	mov    %eax,%esi
  407f4a:	48 89 df             	mov    %rbx,%rdi
  407f4d:	e8 8e dd ff ff       	callq  405ce0 <p113d_FID_36_100_105_114_101_99_116_46_102_109_97_120_48_>
  407f52:	4c 89 ea             	mov    %r13,%rdx
  407f55:	4c 89 e6             	mov    %r12,%rsi
  407f58:	48 89 45 b0          	mov    %rax,-0x50(%rbp)
  407f5c:	49 89 d5             	mov    %rdx,%r13
  407f5f:	ba e8 03 00 00       	mov    $0x3e8,%edx
  407f64:	49 89 f4             	mov    %rsi,%r12
  407f67:	be 01 00 00 00       	mov    $0x1,%esi
  407f6c:	48 89 df             	mov    %rbx,%rdi
  407f6f:	e8 fc dd ff ff       	callq  405d70 <p113d_FID_36_100_105_114_101_99_116_46_102_108_>
  407f74:	4c 89 ea             	mov    %r13,%rdx
  407f77:	4c 89 e6             	mov    %r12,%rsi
  407f7a:	4c 8b 65 e8          	mov    -0x18(%rbp),%r12
  407f7e:	f3 0f 10 b5 14 ff ff ff 	movss  -0xec(%rbp),%xmm6
  407f86:	f3 0f 10 85 08 fe ff ff 	movss  -0x1f8(%rbp),%xmm0
  407f8e:	48 89 85 50 f5 ff ff 	mov    %rax,-0xab0(%rbp)
  407f95:	4c 89 bd 58 f5 ff ff 	mov    %r15,-0xaa8(%rbp)
  407f9c:	66 48 0f 6e c8       	movq   %rax,%xmm1
  407fa1:	f3 0f 59 ce          	mulss  %xmm6,%xmm1
  407fa5:	66 48 0f 7e c8       	movq   %xmm1,%rax
  407faa:	89 c0                	mov    %eax,%eax
  407fac:	4c 89 a5 50 f5 ff ff 	mov    %r12,-0xab0(%rbp)
  407fb3:	48 89 85 58 f5 ff ff 	mov    %rax,-0xaa8(%rbp)
  407fba:	66 48 0f 6e c8       	movq   %rax,%xmm1
  407fbf:	f3 0f 58 c1          	addss  %xmm1,%xmm0
  407fc3:	66 48 0f 7e c0       	movq   %xmm0,%rax
  407fc8:	41 89 c4             	mov    %eax,%r12d
  407fcb:	4c 89 a5 68 ff ff ff 	mov    %r12,-0x98(%rbp)
  407fd2:	49 89 d5             	mov    %rdx,%r13
  407fd5:	ba e8 03 00 00       	mov    $0x3e8,%edx
  407fda:	49 89 f4             	mov    %rsi,%r12
  407fdd:	be 01 00 00 00       	mov    $0x1,%esi
  407fe2:	48 89 df             	mov    %rbx,%rdi
  407fe5:	e8 86 dd ff ff       	callq  405d70 <p113d_FID_36_100_105_114_101_99_116_46_102_108_>
  407fea:	4c 89 ea             	mov    %r13,%rdx
  407fed:	4c 89 e6             	mov    %r12,%rsi
  407ff0:	4c 8b 65 e0          	mov    -0x20(%rbp),%r12
  407ff4:	f3 0f 10 a5 78 ff ff ff 	movss  -0x88(%rbp),%xmm4
  407ffc:	f3 0f 10 85 f0 fd ff ff 	movss  -0x210(%rbp),%xmm0
  408004:	48 89 85 50 f5 ff ff 	mov    %rax,-0xab0(%rbp)
  40800b:	48 89 b5 58 f5 ff ff 	mov    %rsi,-0xaa8(%rbp)
  408012:	66 48 0f 6e c8       	movq   %rax,%xmm1
  408017:	f3 0f 59 cc          	mulss  %xmm4,%xmm1
  40801b:	66 48 0f 7e c8       	movq   %xmm1,%rax
  408020:	89 c0                	mov    %eax,%eax
  408022:	4c 89 a5 50 f5 ff ff 	mov    %r12,-0xab0(%rbp)
  408029:	48 89 85 58 f5 ff ff 	mov    %rax,-0xaa8(%rbp)
  408030:	66 48 0f 6e c8       	movq   %rax,%xmm1
  408035:	f3 0f 58 c1          	addss  %xmm1,%xmm0
  408039:	66 48 0f 7e c0       	movq   %xmm0,%rax
  40803e:	41 89 c5             	mov    %eax,%r13d
  408041:	4c 89 ad 70 ff ff ff 	mov    %r13,-0x90(%rbp)
  408048:	49 89 d5             	mov    %rdx,%r13
  40804b:	ba e8 03 00 00       	mov    $0x3e8,%edx
  408050:	49 89 f4             	mov    %rsi,%r12
  408053:	be 01 00 00 00       	mov    $0x1,%esi
  408058:	48 89 df             	mov    %rbx,%rdi
  40805b:	e8 10 dd ff ff       	callq  405d70 <p113d_FID_36_100_105_114_101_99_116_46_102_108_>
  408060:	4d 89 f8             	mov    %r15,%r8
  408063:	4c 89 f1             	mov    %r14,%rcx
  408066:	4c 89 ea             	mov    %r13,%rdx
  408069:	4c 89 e6             	mov    %r12,%rsi
  40806c:	4c 8b ad 70 ff ff ff 	mov    -0x90(%rbp),%r13
  408073:	4c 8b a5 68 ff ff ff 	mov    -0x98(%rbp),%r12
  40807a:	4c 8b 5d d8          	mov    -0x28(%rbp),%r11
  40807e:	48 8b 7d d0          	mov    -0x30(%rbp),%rdi
  408082:	4c 8b 4d c8          	mov    -0x38(%rbp),%r9
  408086:	4c 8b 75 c0          	mov    -0x40(%rbp),%r14
  40808a:	f3 0f 10 8d 7c ff ff ff 	movss  -0x84(%rbp),%xmm1
  408092:	f3 0f 10 85 d8 fd ff ff 	movss  -0x228(%rbp),%xmm0
  40809a:	48 89 85 50 f5 ff ff 	mov    %rax,-0xab0(%rbp)
  4080a1:	48 89 8d 58 f5 ff ff 	mov    %rcx,-0xaa8(%rbp)
  4080a8:	66 48 0f 6e d0       	movq   %rax,%xmm2
  4080ad:	f3 0f 59 ca          	mulss  %xmm2,%xmm1
  4080b1:	66 48 0f 7e c8       	movq   %xmm1,%rax
  4080b6:	89 c0                	mov    %eax,%eax
  4080b8:	4c 89 b5 50 f5 ff ff 	mov    %r14,-0xab0(%rbp)
  4080bf:	48 89 85 58 f5 ff ff 	mov    %rax,-0xaa8(%rbp)
  4080c6:	66 48 0f 6e c8       	movq   %rax,%xmm1
  4080cb:	f3 0f 58 c1          	addss  %xmm1,%xmm0
  4080cf:	66 48 0f 7e c0       	movq   %xmm0,%rax
  4080d4:	89 c0                	mov    %eax,%eax
  4080d6:	48 89 85 28 ff ff ff 	mov    %rax,-0xd8(%rbp)
  4080dd:	48 c7 85 50 f5 ff ff 00 ca 9a 3b 	movq   $0x3b9aca00,-0xab0(%rbp)
  4080e8:	48 c7 85 50 f5 ff ff 00 ca 9a 3b 	movq   $0x3b9aca00,-0xab0(%rbp)
  4080f3:	48 83 ec 30          	sub    $0x30,%rsp
  4080f7:	49 89 e2             	mov    %rsp,%r10
  4080fa:	49 c7 42 20 00 00 00 00 	movq   $0x0,0x20(%r10)
  408102:	49 c7 42 18 28 6b 6e 4e 	movq   $0x4e6e6b28,0x18(%r10)
  40810a:	49 c7 42 10 28 6b 6e 4e 	movq   $0x4e6e6b28,0x10(%r10)
  408112:	4d 89 5a 08          	mov    %r11,0x8(%r10)
  408116:	49 89 3a             	mov    %rdi,(%r10)
  408119:	4d 89 c6             	mov    %r8,%r14
  40811c:	49 89 c0             	mov    %rax,%r8
  40811f:	49 89 cf             	mov    %rcx,%r15
  408122:	4c 89 e9             	mov    %r13,%rcx
  408125:	49 89 d5             	mov    %rdx,%r13
  408128:	4c 89 e2             	mov    %r12,%rdx
  40812b:	49 89 f4             	mov    %rsi,%r12
  40812e:	be 09 00 00 00       	mov    $0x9,%esi
  408133:	48 89 df             	mov    %rbx,%rdi
  408136:	e8 a5 f0 ff ff       	callq  4071e0 <p113d_FID_36_100_105_114_101_99_116_46_110_101_97_114_101_115_116_46_116_>
  40813b:	4c 89 ea             	mov    %r13,%rdx
  40813e:	4c 89 e6             	mov    %r12,%rsi
  408141:	48 89 45 b8          	mov    %rax,-0x48(%rbp)
  408145:	48 83 ec d0          	sub    $0xffffffffffffffd0,%rsp
  408149:	49 89 d5             	mov    %rdx,%r13
  40814c:	ba 0a 00 00 00       	mov    $0xa,%edx
  408151:	49 89 f4             	mov    %rsi,%r12
  408154:	be 01 00 00 00       	mov    $0x1,%esi
  408159:	48 89 df             	mov    %rbx,%rdi
  40815c:	e8 0f dc ff ff       	callq  405d70 <p113d_FID_36_100_105_114_101_99_116_46_102_108_>
  408161:	4c 89 ea             	mov    %r13,%rdx
  408164:	4c 89 e6             	mov    %r12,%rsi
  408167:	48 89 45 98          	mov    %rax,-0x68(%rbp)
  40816b:	49 89 d5             	mov    %rdx,%r13
  40816e:	ba 64 00 00 00       	mov    $0x64,%edx
  408173:	49 89 f4             	mov    %rsi,%r12
  408176:	be 55 00 00 00       	mov    $0x55,%esi
  40817b:	48 89 df             	mov    %rbx,%rdi
  40817e:	e8 ed db ff ff       	callq  405d70 <p113d_FID_36_100_105_114_101_99_116_46_102_108_>
  408183:	4c 89 f9             	mov    %r15,%rcx
  408186:	4c 89 ea             	mov    %r13,%rdx
  408189:	4c 89 e6             	mov    %r12,%rsi
  40818c:	48 89 45 a0          	mov    %rax,-0x60(%rbp)
  408190:	49 89 d5             	mov    %rdx,%r13
  408193:	48 8b 55 a8          	mov    -0x58(%rbp),%rdx
  408197:	49 89 f4             	mov    %rsi,%r12
  40819a:	48 8b 75 b8          	mov    -0x48(%rbp),%rsi
  40819e:	49 89 cf             	mov    %rcx,%r15
  4081a1:	48 8b 4d b0          	mov    -0x50(%rbp),%rcx
  4081a5:	48 89 df             	mov    %rbx,%rdi
  4081a8:	e8 23 e4 ff ff       	callq  4065d0 <p113d_FID_36_100_105_114_101_99_116_46_115_104_97_100_101_>
  4081ad:	4c 89 f9             	mov    %r15,%rcx
  4081b0:	4c 89 ea             	mov    %r13,%rdx
  4081b3:	4c 89 e6             	mov    %r12,%rsi
  4081b6:	4c 8b 7d 90          	mov    -0x70(%rbp),%r15
  4081ba:	48 8b 7d a0          	mov    -0x60(%rbp),%rdi
  4081be:	49 89 cd             	mov    %rcx,%r13
  4081c1:	48 8b 4d 98          	mov    -0x68(%rbp),%rcx
  4081c5:	48 89 bd 50 f5 ff ff 	mov    %rdi,-0xab0(%rbp)
  4081cc:	48 89 85 58 f5 ff ff 	mov    %rax,-0xaa8(%rbp)
  4081d3:	66 48 0f 6e c7       	movq   %rdi,%xmm0
  4081d8:	66 48 0f 6e c8       	movq   %rax,%xmm1
  4081dd:	f3 0f 59 c1          	mulss  %xmm1,%xmm0
  4081e1:	66 48 0f 7e c0       	movq   %xmm0,%rax
  4081e6:	89 c0                	mov    %eax,%eax
  4081e8:	48 89 8d 50 f5 ff ff 	mov    %rcx,-0xab0(%rbp)
  4081ef:	48 89 85 58 f5 ff ff 	mov    %rax,-0xaa8(%rbp)
  4081f6:	66 48 0f 6e c1       	movq   %rcx,%xmm0
  4081fb:	66 48 0f 6e c8       	movq   %rax,%xmm1
  408200:	f3 0f 58 c1          	addss  %xmm1,%xmm0
  408204:	66 48 0f 7e c0       	movq   %xmm0,%rax
  408209:	89 c0                	mov    %eax,%eax
  40820b:	48 89 85 38 ff ff ff 	mov    %rax,-0xc8(%rbp)
  408212:	49 89 f4             	mov    %rsi,%r12
  408215:	48 89 d6             	mov    %rdx,%rsi
  408218:	48 89 df             	mov    %rbx,%rdi
  40821b:	e8 e0 e2 ff ff       	callq  406500 <p113d_FID_36_100_105_114_101_99_116_46_115_107_114_>
  408220:	4d 89 f0             	mov    %r14,%r8
  408223:	4c 89 e9             	mov    %r13,%rcx
  408226:	4c 89 e6             	mov    %r12,%rsi
  408229:	49 89 c6             	mov    %rax,%r14
  40822c:	4c 8b 95 60 ff ff ff 	mov    -0xa0(%rbp),%r10
  408233:	4c 8b 9d 58 ff ff ff 	mov    -0xa8(%rbp),%r11
  40823a:	48 8b bd 20 fe ff ff 	mov    -0x1e0(%rbp),%rdi
  408241:	48 8b 85 28 ff ff ff 	mov    -0xd8(%rbp),%rax
  408248:	4c 8b ad 70 ff ff ff 	mov    -0x90(%rbp),%r13
  40824f:	4c 8b a5 68 ff ff ff 	mov    -0x98(%rbp),%r12
  408256:	f3 0f 10 8d 7c ff ff ff 	movss  -0x84(%rbp),%xmm1
  40825e:	f3 0f 10 a5 78 ff ff ff 	movss  -0x88(%rbp),%xmm4
  408266:	f3 0f 10 b5 14 ff ff ff 	movss  -0xec(%rbp),%xmm6
  40826e:	f3 0f 10 45 88       	movss  -0x78(%rbp),%xmm0
  408273:	f3 0f 10 5d 84       	movss  -0x7c(%rbp),%xmm3
  408278:	f3 0f 10 6d 80       	movss  -0x80(%rbp),%xmm5
  40827d:	48 c7 85 50 f5 ff ff 02 00 00 00 	movq   $0x2,-0xab0(%rbp)
  408288:	4c 89 95 50 f5 ff ff 	mov    %r10,-0xab0(%rbp)
  40828f:	4c 89 85 58 f5 ff ff 	mov    %r8,-0xaa8(%rbp)
  408296:	f3 0f 10 d5          	movss  %xmm5,%xmm2
  40829a:	f3 0f 59 d6          	mulss  %xmm6,%xmm2
  40829e:	66 48 0f 7e d2       	movq   %xmm2,%rdx
  4082a3:	41 89 d1             	mov    %edx,%r9d
  4082a6:	4c 89 9d 50 f5 ff ff 	mov    %r11,-0xab0(%rbp)
  4082ad:	48 89 b5 58 f5 ff ff 	mov    %rsi,-0xaa8(%rbp)
  4082b4:	f3 0f 10 d3          	movss  %xmm3,%xmm2
  4082b8:	f3 0f 59 d4          	mulss  %xmm4,%xmm2
  4082bc:	66 48 0f 7e d2       	movq   %xmm2,%rdx
  4082c1:	89 d2                	mov    %edx,%edx
  4082c3:	4c 89 8d 50 f5 ff ff 	mov    %r9,-0xab0(%rbp)
  4082ca:	48 89 95 58 f5 ff ff 	mov    %rdx,-0xaa8(%rbp)
  4082d1:	66 49 0f 6e d1       	movq   %r9,%xmm2
  4082d6:	66 48 0f 6e fa       	movq   %rdx,%xmm7
  4082db:	f3 0f 58 d7          	addss  %xmm7,%xmm2
  4082df:	66 48 0f 7e d2       	movq   %xmm2,%rdx
  4082e4:	41 89 d1             	mov    %edx,%r9d
  4082e7:	4c 89 bd 50 f5 ff ff 	mov    %r15,-0xab0(%rbp)
  4082ee:	48 89 8d 58 f5 ff ff 	mov    %rcx,-0xaa8(%rbp)
  4082f5:	f3 0f 10 d0          	movss  %xmm0,%xmm2
  4082f9:	f3 0f 59 d1          	mulss  %xmm1,%xmm2
  4082fd:	66 48 0f 7e d2       	movq   %xmm2,%rdx
  408302:	89 d2                	mov    %edx,%edx
  408304:	4c 89 8d 50 f5 ff ff 	mov    %r9,-0xab0(%rbp)
  40830b:	48 89 95 58 f5 ff ff 	mov    %rdx,-0xaa8(%rbp)
  408312:	66 49 0f 6e d1       	movq   %r9,%xmm2
  408317:	66 48 0f 6e fa       	movq   %rdx,%xmm7
  40831c:	f3 0f 58 d7          	addss  %xmm7,%xmm2
  408320:	66 48 0f 7e d2       	movq   %xmm2,%rdx
  408325:	89 d2                	mov    %edx,%edx
  408327:	48 c7 85 50 f5 ff ff 00 00 00 40 	movq   $0x40000000,-0xab0(%rbp)
  408332:	48 89 95 58 f5 ff ff 	mov    %rdx,-0xaa8(%rbp)
  408339:	66 48 0f 6e d2       	movq   %rdx,%xmm2
  40833e:	f3 0f 59 15 ee 9c 02 00 	mulss  0x29cee(%rip),%xmm2        # 432034 <_IO_stdin_used+0x34>
  408346:	66 48 0f 7e d2       	movq   %xmm2,%rdx
  40834b:	89 d2                	mov    %edx,%edx
  40834d:	48 89 95 50 f5 ff ff 	mov    %rdx,-0xab0(%rbp)
  408354:	4c 89 85 58 f5 ff ff 	mov    %r8,-0xaa8(%rbp)
  40835b:	66 48 0f 6e d2       	movq   %rdx,%xmm2
  408360:	f3 0f 59 f2          	mulss  %xmm2,%xmm6
  408364:	66 49 0f 7e f0       	movq   %xmm6,%r8
  408369:	45 89 c0             	mov    %r8d,%r8d
  40836c:	4c 89 95 50 f5 ff ff 	mov    %r10,-0xab0(%rbp)
  408373:	4c 89 85 58 f5 ff ff 	mov    %r8,-0xaa8(%rbp)
  40837a:	66 49 0f 6e f0       	movq   %r8,%xmm6
  40837f:	f3 0f 5c ee          	subss  %xmm6,%xmm5
  408383:	66 49 0f 7e e8       	movq   %xmm5,%r8
  408388:	45 89 c2             	mov    %r8d,%r10d
  40838b:	4c 89 95 40 ff ff ff 	mov    %r10,-0xc0(%rbp)
  408392:	48 89 95 50 f5 ff ff 	mov    %rdx,-0xab0(%rbp)
  408399:	48 89 b5 58 f5 ff ff 	mov    %rsi,-0xaa8(%rbp)
  4083a0:	f3 0f 59 e2          	mulss  %xmm2,%xmm4
  4083a4:	66 48 0f 7e e6       	movq   %xmm4,%rsi
  4083a9:	89 f6                	mov    %esi,%esi
  4083ab:	4c 89 9d 50 f5 ff ff 	mov    %r11,-0xab0(%rbp)
  4083b2:	48 89 b5 58 f5 ff ff 	mov    %rsi,-0xaa8(%rbp)
  4083b9:	66 48 0f 6e e6       	movq   %rsi,%xmm4
  4083be:	f3 0f 5c dc          	subss  %xmm4,%xmm3
  4083c2:	66 48 0f 7e de       	movq   %xmm3,%rsi
  4083c7:	41 89 f3             	mov    %esi,%r11d
  4083ca:	4c 89 9d 48 ff ff ff 	mov    %r11,-0xb8(%rbp)
  4083d1:	48 89 95 50 f5 ff ff 	mov    %rdx,-0xab0(%rbp)
  4083d8:	48 89 8d 58 f5 ff ff 	mov    %rcx,-0xaa8(%rbp)
  4083df:	f3 0f 59 ca          	mulss  %xmm2,%xmm1
  4083e3:	66 48 0f 7e c9       	movq   %xmm1,%rcx
  4083e8:	89 c9                	mov    %ecx,%ecx
  4083ea:	4c 89 bd 50 f5 ff ff 	mov    %r15,-0xab0(%rbp)
  4083f1:	48 89 8d 58 f5 ff ff 	mov    %rcx,-0xaa8(%rbp)
  4083f8:	66 48 0f 6e c9       	movq   %rcx,%xmm1
  4083fd:	f3 0f 5c c1          	subss  %xmm1,%xmm0
  408401:	66 48 0f 7e c1       	movq   %xmm0,%rcx
  408406:	41 89 cf             	mov    %ecx,%r15d
  408409:	4c 89 bd 50 ff ff ff 	mov    %r15,-0xb0(%rbp)
  408410:	48 c7 85 50 f5 ff ff 00 ca 9a 3b 	movq   $0x3b9aca00,-0xab0(%rbp)
  40841b:	48 c7 85 50 f5 ff ff 00 ca 9a 3b 	movq   $0x3b9aca00,-0xab0(%rbp)
  408426:	48 83 ec 40          	sub    $0x40,%rsp
  40842a:	48 89 e1             	mov    %rsp,%rcx
  40842d:	48 c7 41 38 00 00 00 00 	movq   $0x0,0x38(%rcx)
  408435:	48 c7 41 30 09 00 00 00 	movq   $0x9,0x30(%rcx)
  40843d:	48 c7 41 28 28 6b 6e 4e 	movq   $0x4e6e6b28,0x28(%rcx)
  408445:	48 c7 41 20 09 00 00 00 	movq   $0x9,0x20(%rcx)
  40844d:	48 c7 41 18 28 6b 6e 4e 	movq   $0x4e6e6b28,0x18(%rcx)
  408455:	4c 89 79 10          	mov    %r15,0x10(%rcx)
  408459:	4c 89 59 08          	mov    %r11,0x8(%rcx)
  40845d:	4c 89 11             	mov    %r10,(%rcx)
  408460:	49 89 c1             	mov    %rax,%r9
  408463:	4d 89 e8             	mov    %r13,%r8
  408466:	4c 89 e1             	mov    %r12,%rcx
  408469:	ba 09 00 00 00       	mov    $0x9,%edx
  40846e:	48 8d b5 50 fd ff ff 	lea    -0x2b0(%rbp),%rsi
  408475:	49 89 ff             	mov    %rdi,%r15
  408478:	48 89 df             	mov    %rbx,%rdi
  40847b:	e8 60 e6 ff ff       	callq  406ae0 <p113d_FID_36_112_114_111_100_117_99_116_46_110_101_97_114_101_115_116_>
  408480:	4d 89 f9             	mov    %r15,%r9
  408483:	4c 89 f7             	mov    %r14,%rdi
  408486:	4c 8b 85 30 ff ff ff 	mov    -0xd0(%rbp),%r8
  40848d:	48 8b b5 f8 fd ff ff 	mov    -0x208(%rbp),%rsi
  408494:	4c 8b b5 50 ff ff ff 	mov    -0xb0(%rbp),%r14
  40849b:	4c 8b 9d 48 ff ff ff 	mov    -0xb8(%rbp),%r11
  4084a2:	4c 8b 95 40 ff ff ff 	mov    -0xc0(%rbp),%r10
  4084a9:	48 8b 95 38 ff ff ff 	mov    -0xc8(%rbp),%rdx
  4084b0:	48 8b 85 28 ff ff ff 	mov    -0xd8(%rbp),%rax
  4084b7:	f3 0f 10 95 94 fd ff ff 	movss  -0x26c(%rbp),%xmm2
  4084bf:	f3 0f 10 85 90 fd ff ff 	movss  -0x270(%rbp),%xmm0
  4084c7:	48 83 ec c0          	sub    $0xffffffffffffffc0,%rsp
  4084cb:	48 8b 8d 50 fd ff ff 	mov    -0x2b0(%rbp),%rcx
  4084d2:	4c 8b bd 58 fd ff ff 	mov    -0x2a8(%rbp),%r15
  4084d9:	4c 89 bd 20 ff ff ff 	mov    %r15,-0xe0(%rbp)
  4084e0:	4c 8b bd 60 fd ff ff 	mov    -0x2a0(%rbp),%r15
  4084e7:	4c 89 bd 18 ff ff ff 	mov    %r15,-0xe8(%rbp)
  4084ee:	4c 89 8d 50 f5 ff ff 	mov    %r9,-0xab0(%rbp)
  4084f5:	48 89 95 58 f5 ff ff 	mov    %rdx,-0xaa8(%rbp)
  4084fc:	66 48 0f 6e ca       	movq   %rdx,%xmm1
  408501:	f3 0f 59 c8          	mulss  %xmm0,%xmm1
  408505:	66 48 0f 7e ca       	movq   %xmm1,%rdx
  40850a:	41 89 d7             	mov    %edx,%r15d
  40850d:	48 c7 85 50 f5 ff ff 01 00 00 00 	movq   $0x1,-0xab0(%rbp)
  408518:	48 c7 85 50 f5 ff ff 00 00 80 3f 	movq   $0x3f800000,-0xab0(%rbp)
  408523:	48 89 bd 58 f5 ff ff 	mov    %rdi,-0xaa8(%rbp)
  40852a:	66 48 0f 6e cf       	movq   %rdi,%xmm1
  40852f:	f3 0f 10 1d e9 9a 02 00 	movss  0x29ae9(%rip),%xmm3        # 432020 <_IO_stdin_used+0x20>
  408537:	f3 0f 5c d9          	subss  %xmm1,%xmm3
  40853b:	66 48 0f 7e da       	movq   %xmm3,%rdx
  408540:	89 d2                	mov    %edx,%edx
  408542:	4c 89 bd 50 f5 ff ff 	mov    %r15,-0xab0(%rbp)
  408549:	48 89 95 58 f5 ff ff 	mov    %rdx,-0xaa8(%rbp)
  408550:	66 49 0f 6e df       	movq   %r15,%xmm3
  408555:	4c 8b bd 20 ff ff ff 	mov    -0xe0(%rbp),%r15
  40855c:	66 48 0f 6e e2       	movq   %rdx,%xmm4
  408561:	f3 0f 59 dc          	mulss  %xmm4,%xmm3
  408565:	48 89 f2             	mov    %rsi,%rdx
  408568:	66 48 0f 7e de       	movq   %xmm3,%rsi
  40856d:	89 f6                	mov    %esi,%esi
  40856f:	48 89 95 50 f5 ff ff 	mov    %rdx,-0xab0(%rbp)
  408576:	48 8b 95 18 ff ff ff 	mov    -0xe8(%rbp),%rdx
  40857d:	48 89 b5 58 f5 ff ff 	mov    %rsi,-0xaa8(%rbp)
  408584:	66 48 0f 6e de       	movq   %rsi,%xmm3
  408589:	f3 0f 58 d3          	addss  %xmm3,%xmm2
  40858d:	66 48 0f 7e d6       	movq   %xmm2,%rsi
  408592:	89 f6                	mov    %esi,%esi
  408594:	4c 89 8d 50 f5 ff ff 	mov    %r9,-0xab0(%rbp)
  40859b:	48 89 bd 58 f5 ff ff 	mov    %rdi,-0xaa8(%rbp)
  4085a2:	f3 0f 59 c1          	mulss  %xmm1,%xmm0
  4085a6:	66 48 0f 7e c7       	movq   %xmm0,%rdi
  4085ab:	89 ff                	mov    %edi,%edi
  4085ad:	49 83 e8 01          	sub    $0x1,%r8
  4085b1:	4d 89 e1             	mov    %r12,%r9
  4085b4:	4d 89 f4             	mov    %r14,%r12
  4085b7:	49 89 f6             	mov    %rsi,%r14
  4085ba:	e9 a1 f2 ff ff       	jmpq   407860 <p113d_FID_36_112_114_111_100_117_99_116_46_116_114_97_99_101_+0xa0>
  4085bf:	48 89 df             	mov    %rbx,%rdi
  4085c2:	be 04 00 00 00       	mov    $0x4,%esi
  4085c7:	e8 d4 42 02 00       	callq  42c8a0 <p111_rt_fail>
  4085cc:	b8 00 00 00 00       	mov    $0x0,%eax
  4085d1:	e9 60 0b 00 00       	jmpq   409136 <p113d_FID_36_112_114_111_100_117_99_116_46_116_114_97_99_101_+0x1976>
  4085d6:	2e 2e 2e 48 8b 85 f8 fd ff ff 	cs cs mov %cs:-0x208(%rbp),%rax
  4085e0:	e9 51 0b 00 00       	jmpq   409136 <p113d_FID_36_112_114_111_100_117_99_116_46_116_114_97_99_101_+0x1976>
  4085e5:	4d 89 f8             	mov    %r15,%r8
  4085e8:	48 8b 95 60 ff ff ff 	mov    -0xa0(%rbp),%rdx
  4085ef:	4c 8b 8d 58 ff ff ff 	mov    -0xa8(%rbp),%r9
  4085f6:	48 8b 85 f8 fd ff ff 	mov    -0x208(%rbp),%rax
  4085fd:	4c 8b 95 18 fe ff ff 	mov    -0x1e8(%rbp),%r10
  408604:	4c 8b 9d 10 fe ff ff 	mov    -0x1f0(%rbp),%r11
  40860b:	4c 8b 7d f0          	mov    -0x10(%rbp),%r15
  40860f:	89 ce                	mov    %ecx,%esi
  408611:	48 8b 4d 90          	mov    -0x70(%rbp),%rcx
  408615:	f3 0f 10 85 d8 fd ff ff 	movss  -0x228(%rbp),%xmm0
  40861d:	f3 0f 10 8d f0 fd ff ff 	movss  -0x210(%rbp),%xmm1
  408625:	f3 0f 10 95 08 fe ff ff 	movss  -0x1f8(%rbp),%xmm2
  40862d:	48 89 df             	mov    %rbx,%rdi
  408630:	48 8b 5d c0          	mov    -0x40(%rbp),%rbx
  408634:	0b b5 10 ff ff ff    	or     -0xf0(%rbp),%esi
  40863a:	48 8b b5 f0 fe ff ff 	mov    -0x110(%rbp),%rsi
  408641:	0f 85 ef 0a 00 00    	jne    409136 <p113d_FID_36_112_114_111_100_117_99_116_46_116_114_97_99_101_+0x1976>
  408647:	48 89 f0             	mov    %rsi,%rax
  40864a:	8b b5 0c ff ff ff    	mov    -0xf4(%rbp),%esi
  408650:	83 f6 01             	xor    $0x1,%esi
  408653:	75 14                	jne    408669 <p113d_FID_36_112_114_111_100_117_99_116_46_116_114_97_99_101_+0xea9>
  408655:	be 04 00 00 00       	mov    $0x4,%esi
  40865a:	e8 41 42 02 00       	callq  42c8a0 <p111_rt_fail>
  40865f:	b8 00 00 00 00       	mov    $0x0,%eax
  408664:	e9 cd 0a 00 00       	jmpq   409136 <p113d_FID_36_112_114_111_100_117_99_116_46_116_114_97_99_101_+0x1976>
  408669:	49 83 fe 00          	cmp    $0x0,%r14
  40866d:	40 0f 94 c6          	sete   %sil
  408671:	40 0f b6 f6          	movzbl %sil,%esi
  408675:	89 b5 08 ff ff ff    	mov    %esi,-0xf8(%rbp)
  40867b:	4c 89 f6             	mov    %r14,%rsi
  40867e:	48 83 ee 01          	sub    $0x1,%rsi
  408682:	48 89 b5 88 fe ff ff 	mov    %rsi,-0x178(%rbp)
  408689:	4c 89 f6             	mov    %r14,%rsi
  40868c:	48 83 ee 02          	sub    $0x2,%rsi
  408690:	48 89 b5 80 fe ff ff 	mov    %rsi,-0x180(%rbp)
  408697:	4c 89 f6             	mov    %r14,%rsi
  40869a:	48 83 ee 03          	sub    $0x3,%rsi
  40869e:	48 89 b5 78 fe ff ff 	mov    %rsi,-0x188(%rbp)
  4086a5:	4c 89 f6             	mov    %r14,%rsi
  4086a8:	48 83 ee 04          	sub    $0x4,%rsi
  4086ac:	48 89 b5 70 fe ff ff 	mov    %rsi,-0x190(%rbp)
  4086b3:	4c 89 f6             	mov    %r14,%rsi
  4086b6:	48 83 ee 05          	sub    $0x5,%rsi
  4086ba:	48 89 b5 68 fe ff ff 	mov    %rsi,-0x198(%rbp)
  4086c1:	4c 89 f6             	mov    %r14,%rsi
  4086c4:	48 83 ee 06          	sub    $0x6,%rsi
  4086c8:	48 89 b5 60 fe ff ff 	mov    %rsi,-0x1a0(%rbp)
  4086cf:	4c 89 f6             	mov    %r14,%rsi
  4086d2:	48 83 ee 07          	sub    $0x7,%rsi
  4086d6:	48 89 b5 58 fe ff ff 	mov    %rsi,-0x1a8(%rbp)
  4086dd:	48 8b b5 f8 fe ff ff 	mov    -0x108(%rbp),%rsi
  4086e4:	83 bd 08 ff ff ff 00 	cmpl   $0x0,-0xf8(%rbp)
  4086eb:	0f 85 bf 00 00 00    	jne    4087b0 <p113d_FID_36_112_114_111_100_117_99_116_46_116_114_97_99_101_+0xff0>
  4086f1:	48 8b b5 80 fe ff ff 	mov    -0x180(%rbp),%rsi
  4086f8:	48 8b 85 88 fe ff ff 	mov    -0x178(%rbp),%rax
  4086ff:	48 83 f8 00          	cmp    $0x0,%rax
  408703:	48 8b 85 78 fe ff ff 	mov    -0x188(%rbp),%rax
  40870a:	74 76                	je     408782 <p113d_FID_36_112_114_111_100_117_99_116_46_116_114_97_99_101_+0xfc2>
  40870c:	48 83 fe 00          	cmp    $0x0,%rsi
  408710:	48 8b b5 70 fe ff ff 	mov    -0x190(%rbp),%rsi
  408717:	74 61                	je     40877a <p113d_FID_36_112_114_111_100_117_99_116_46_116_114_97_99_101_+0xfba>
  408719:	48 83 f8 00          	cmp    $0x0,%rax
  40871d:	48 8b 85 68 fe ff ff 	mov    -0x198(%rbp),%rax
  408724:	74 4d                	je     408773 <p113d_FID_36_112_114_111_100_117_99_116_46_116_114_97_99_101_+0xfb3>
  408726:	48 83 fe 00          	cmp    $0x0,%rsi
  40872a:	48 8b b5 60 fe ff ff 	mov    -0x1a0(%rbp),%rsi
  408731:	74 39                	je     40876c <p113d_FID_36_112_114_111_100_117_99_116_46_116_114_97_99_101_+0xfac>
  408733:	2e 2e 48 83 f8 00    	cs cs cmp $0x0,%rax
  408739:	48 8b 85 58 fe ff ff 	mov    -0x1a8(%rbp),%rax
  408740:	74 23                	je     408765 <p113d_FID_36_112_114_111_100_117_99_116_46_116_114_97_99_101_+0xfa5>
  408742:	48 83 fe 00          	cmp    $0x0,%rsi
  408746:	48 8b b5 00 ff ff ff 	mov    -0x100(%rbp),%rsi
  40874d:	74 0f                	je     40875e <p113d_FID_36_112_114_111_100_117_99_116_46_116_114_97_99_101_+0xf9e>
  40874f:	48 83 f8 00          	cmp    $0x0,%rax
  408753:	b8 00 00 80 3f       	mov    $0x3f800000,%eax
  408758:	48 0f 45 c6          	cmovne %rsi,%rax
  40875c:	eb 29                	jmp    408787 <p113d_FID_36_112_114_111_100_117_99_116_46_116_114_97_99_101_+0xfc7>
  40875e:	b8 9a 99 99 3f       	mov    $0x3f99999a,%eax
  408763:	eb 22                	jmp    408787 <p113d_FID_36_112_114_111_100_117_99_116_46_116_114_97_99_101_+0xfc7>
  408765:	b8 cd cc cc 3e       	mov    $0x3ecccccd,%eax
  40876a:	eb 1b                	jmp    408787 <p113d_FID_36_112_114_111_100_117_99_116_46_116_114_97_99_101_+0xfc7>
  40876c:	b8 cd cc cc 3e       	mov    $0x3ecccccd,%eax
  408771:	eb 14                	jmp    408787 <p113d_FID_36_112_114_111_100_117_99_116_46_116_114_97_99_101_+0xfc7>
  408773:	b8 00 00 80 3f       	mov    $0x3f800000,%eax
  408778:	eb 0d                	jmp    408787 <p113d_FID_36_112_114_111_100_117_99_116_46_116_114_97_99_101_+0xfc7>
  40877a:	2e b8 00 00 80 3f    	cs mov $0x3f800000,%eax
  408780:	eb 05                	jmp    408787 <p113d_FID_36_112_114_111_100_117_99_116_46_116_114_97_99_101_+0xfc7>
  408782:	b8 00 00 80 3f       	mov    $0x3f800000,%eax
  408787:	48 89 85 e8 fe ff ff 	mov    %rax,-0x118(%rbp)
  40878e:	48 8b b5 f8 fe ff ff 	mov    -0x108(%rbp),%rsi
  408795:	48 8b 85 f0 fe ff ff 	mov    -0x110(%rbp),%rax
  40879c:	f2 44 0f 10 bd e8 fe ff ff 	movsd  -0x118(%rbp),%xmm15
  4087a5:	f2 44 0f 11 bd 48 fe ff ff 	movsd  %xmm15,-0x1b8(%rbp)
  4087ae:	eb 0e                	jmp    4087be <p113d_FID_36_112_114_111_100_117_99_116_46_116_114_97_99_101_+0xffe>
  4087b0:	2e 2e 2e 48 c7 85 48 fe ff ff 00 40 1c 46 	cs cs movq $0x461c4000,%cs:-0x1b8(%rbp)
  4087be:	2e 2e 2e 2e 4c 89 85 50 f5 ff ff 	cs cs cs mov %r8,%cs:-0xab0(%rbp)
  4087c9:	2e 48 89 95 58 f5 ff ff 	mov    %rdx,%cs:-0xaa8(%rbp)
  4087d1:	48 8b 95 e0 fe ff ff 	mov    -0x120(%rbp),%rdx
  4087d8:	48 89 95 50 f5 ff ff 	mov    %rdx,-0xab0(%rbp)
  4087df:	48 8b 95 d8 fe ff ff 	mov    -0x128(%rbp),%rdx
  4087e6:	48 89 95 58 f5 ff ff 	mov    %rdx,-0xaa8(%rbp)
  4087ed:	48 8b 95 d0 fe ff ff 	mov    -0x130(%rbp),%rdx
  4087f4:	4c 89 85 50 f5 ff ff 	mov    %r8,-0xab0(%rbp)
  4087fb:	4c 89 8d 58 f5 ff ff 	mov    %r9,-0xaa8(%rbp)
  408802:	4c 8b 8d c8 fe ff ff 	mov    -0x138(%rbp),%r9
  408809:	48 89 b5 50 f5 ff ff 	mov    %rsi,-0xab0(%rbp)
  408810:	4c 89 de             	mov    %r11,%rsi
  408813:	4c 8b 9d c0 fe ff ff 	mov    -0x140(%rbp),%r11
  40881a:	48 89 95 58 f5 ff ff 	mov    %rdx,-0xaa8(%rbp)
  408821:	48 8b 95 b8 fe ff ff 	mov    -0x148(%rbp),%rdx
  408828:	4c 89 85 50 f5 ff ff 	mov    %r8,-0xab0(%rbp)
  40882f:	4c 8b 85 b0 fe ff ff 	mov    -0x150(%rbp),%r8
  408836:	48 89 8d 58 f5 ff ff 	mov    %rcx,-0xaa8(%rbp)
  40883d:	48 8b 8d a8 fe ff ff 	mov    -0x158(%rbp),%rcx
  408844:	48 89 85 50 f5 ff ff 	mov    %rax,-0xab0(%rbp)
  40884b:	48 8b 85 90 fe ff ff 	mov    -0x170(%rbp),%rax
  408852:	4c 89 8d 58 f5 ff ff 	mov    %r9,-0xaa8(%rbp)
  408859:	4c 8b 8d 88 fe ff ff 	mov    -0x178(%rbp),%r9
  408860:	49 83 fe 00          	cmp    $0x0,%r14
  408864:	0f 84 a2 00 00 00    	je     40890c <p113d_FID_36_112_114_111_100_117_99_116_46_116_114_97_99_101_+0x114c>
  40886a:	49 83 f9 00          	cmp    $0x0,%r9
  40886e:	4c 8b 8d 80 fe ff ff 	mov    -0x180(%rbp),%r9
  408875:	0f 84 89 00 00 00    	je     408904 <p113d_FID_36_112_114_111_100_117_99_116_46_116_114_97_99_101_+0x1144>
  40887b:	49 83 f9 00          	cmp    $0x0,%r9
  40887f:	4c 8b 8d 78 fe ff ff 	mov    -0x188(%rbp),%r9
  408886:	74 74                	je     4088fc <p113d_FID_36_112_114_111_100_117_99_116_46_116_114_97_99_101_+0x113c>
  408888:	49 83 f9 00          	cmp    $0x0,%r9
  40888c:	4c 8b 8d 70 fe ff ff 	mov    -0x190(%rbp),%r9
  408893:	74 5f                	je     4088f4 <p113d_FID_36_112_114_111_100_117_99_116_46_116_114_97_99_101_+0x1134>
  408895:	49 83 f9 00          	cmp    $0x0,%r9
  408899:	4c 8b 8d 68 fe ff ff 	mov    -0x198(%rbp),%r9
  4088a0:	74 4a                	je     4088ec <p113d_FID_36_112_114_111_100_117_99_116_46_116_114_97_99_101_+0x112c>
  4088a2:	49 83 f9 00          	cmp    $0x0,%r9
  4088a6:	4c 8b 8d 60 fe ff ff 	mov    -0x1a0(%rbp),%r9
  4088ad:	74 35                	je     4088e4 <p113d_FID_36_112_114_111_100_117_99_116_46_116_114_97_99_101_+0x1124>
  4088af:	49 83 f9 00          	cmp    $0x0,%r9
  4088b3:	4c 8b 8d 58 fe ff ff 	mov    -0x1a8(%rbp),%r9
  4088ba:	74 20                	je     4088dc <p113d_FID_36_112_114_111_100_117_99_116_46_116_114_97_99_101_+0x111c>
  4088bc:	4c 89 c8             	mov    %r9,%rax
  4088bf:	4c 8b 8d a0 fe ff ff 	mov    -0x160(%rbp),%r9
  4088c6:	48 83 f8 00          	cmp    $0x0,%rax
  4088ca:	b8 00 00 60 40       	mov    $0x40600000,%eax
  4088cf:	4c 0f 44 c8          	cmove  %rax,%r9
  4088d3:	48 8b 85 90 fe ff ff 	mov    -0x170(%rbp),%rax
  4088da:	eb 36                	jmp    408912 <p113d_FID_36_112_114_111_100_117_99_116_46_116_114_97_99_101_+0x1152>
  4088dc:	41 b9 00 00 00 00    	mov    $0x0,%r9d
  4088e2:	eb 2e                	jmp    408912 <p113d_FID_36_112_114_111_100_117_99_116_46_116_114_97_99_101_+0x1152>
  4088e4:	41 b9 00 00 80 bf    	mov    $0xbf800000,%r9d
  4088ea:	eb 26                	jmp    408912 <p113d_FID_36_112_114_111_100_117_99_116_46_116_114_97_99_101_+0x1152>
  4088ec:	41 b9 00 00 80 3f    	mov    $0x3f800000,%r9d
  4088f2:	eb 1e                	jmp    408912 <p113d_FID_36_112_114_111_100_117_99_116_46_116_114_97_99_101_+0x1152>
  4088f4:	41 b9 00 00 00 c0    	mov    $0xc0000000,%r9d
  4088fa:	eb 16                	jmp    408912 <p113d_FID_36_112_114_111_100_117_99_116_46_116_114_97_99_101_+0x1152>
  4088fc:	41 b9 00 00 00 40    	mov    $0x40000000,%r9d
  408902:	eb 0e                	jmp    408912 <p113d_FID_36_112_114_111_100_117_99_116_46_116_114_97_99_101_+0x1152>
  408904:	41 b9 00 00 00 00    	mov    $0x0,%r9d
  40890a:	eb 06                	jmp    408912 <p113d_FID_36_112_114_111_100_117_99_116_46_116_114_97_99_101_+0x1152>
  40890c:	41 b9 00 00 00 00    	mov    $0x0,%r9d
  408912:	4c 89 a5 50 f5 ff ff 	mov    %r12,-0xab0(%rbp)
  408919:	4c 89 8d 58 f5 ff ff 	mov    %r9,-0xaa8(%rbp)
  408920:	66 49 0f 6e d9       	movq   %r9,%xmm3
  408925:	f3 0f 5c d3          	subss  %xmm3,%xmm2
  408929:	66 49 0f 7e d1       	movq   %xmm2,%r9
  40892e:	45 89 c9             	mov    %r9d,%r9d
  408931:	4c 89 8d 28 fe ff ff 	mov    %r9,-0x1d8(%rbp)
  408938:	4c 89 8d 50 f5 ff ff 	mov    %r9,-0xab0(%rbp)
  40893f:	4c 8b 8d 48 fe ff ff 	mov    -0x1b8(%rbp),%r9
  408946:	4c 89 8d 58 f5 ff ff 	mov    %r9,-0xaa8(%rbp)
  40894d:	4c 8b 8d 88 fe ff ff 	mov    -0x178(%rbp),%r9
  408954:	49 83 fe 00          	cmp    $0x0,%r14
  408958:	0f 84 a4 00 00 00    	je     408a02 <p113d_FID_36_112_114_111_100_117_99_116_46_116_114_97_99_101_+0x1242>
  40895e:	49 83 f9 00          	cmp    $0x0,%r9
  408962:	4c 8b 8d 80 fe ff ff 	mov    -0x180(%rbp),%r9
  408969:	0f 84 8b 00 00 00    	je     4089fa <p113d_FID_36_112_114_111_100_117_99_116_46_116_114_97_99_101_+0x123a>
  40896f:	49 83 f9 00          	cmp    $0x0,%r9
  408973:	4c 8b 8d 78 fe ff ff 	mov    -0x188(%rbp),%r9
  40897a:	74 76                	je     4089f2 <p113d_FID_36_112_114_111_100_117_99_116_46_116_114_97_99_101_+0x1232>
  40897c:	49 83 f9 00          	cmp    $0x0,%r9
  408980:	4c 8b 8d 70 fe ff ff 	mov    -0x190(%rbp),%r9
  408987:	74 61                	je     4089ea <p113d_FID_36_112_114_111_100_117_99_116_46_116_114_97_99_101_+0x122a>
  408989:	49 83 f9 00          	cmp    $0x0,%r9
  40898d:	4c 8b 8d 68 fe ff ff 	mov    -0x198(%rbp),%r9
  408994:	74 4c                	je     4089e2 <p113d_FID_36_112_114_111_100_117_99_116_46_116_114_97_99_101_+0x1222>
  408996:	49 83 f9 00          	cmp    $0x0,%r9
  40899a:	4c 8b 8d 60 fe ff ff 	mov    -0x1a0(%rbp),%r9
  4089a1:	74 35                	je     4089d8 <p113d_FID_36_112_114_111_100_117_99_116_46_116_114_97_99_101_+0x1218>
  4089a3:	49 83 f9 00          	cmp    $0x0,%r9
  4089a7:	4c 8b 8d 58 fe ff ff 	mov    -0x1a8(%rbp),%r9
  4089ae:	74 20                	je     4089d0 <p113d_FID_36_112_114_111_100_117_99_116_46_116_114_97_99_101_+0x1210>
  4089b0:	4c 89 c8             	mov    %r9,%rax
  4089b3:	4c 8b 8d 98 fe ff ff 	mov    -0x168(%rbp),%r9
  4089ba:	48 83 f8 00          	cmp    $0x0,%rax
  4089be:	b8 cd cc 4c 3e       	mov    $0x3e4ccccd,%eax
  4089c3:	4c 0f 44 c8          	cmove  %rax,%r9
  4089c7:	48 8b 85 90 fe ff ff 	mov    -0x170(%rbp),%rax
  4089ce:	eb 38                	jmp    408a08 <p113d_FID_36_112_114_111_100_117_99_116_46_116_114_97_99_101_+0x1248>
  4089d0:	41 b9 cd cc cc 3f    	mov    $0x3fcccccd,%r9d
  4089d6:	eb 30                	jmp    408a08 <p113d_FID_36_112_114_111_100_117_99_116_46_116_114_97_99_101_+0x1248>
  4089d8:	2e 2e 41 b9 9a 99 19 bf 	cs cs mov $0xbf19999a,%r9d
  4089e0:	eb 26                	jmp    408a08 <p113d_FID_36_112_114_111_100_117_99_116_46_116_114_97_99_101_+0x1248>
  4089e2:	41 b9 9a 99 19 bf    	mov    $0xbf19999a,%r9d
  4089e8:	eb 1e                	jmp    408a08 <p113d_FID_36_112_114_111_100_117_99_116_46_116_114_97_99_101_+0x1248>
  4089ea:	41 b9 00 00 00 3f    	mov    $0x3f000000,%r9d
  4089f0:	eb 16                	jmp    408a08 <p113d_FID_36_112_114_111_100_117_99_116_46_116_114_97_99_101_+0x1248>
  4089f2:	41 b9 00 00 00 3f    	mov    $0x3f000000,%r9d
  4089f8:	eb 0e                	jmp    408a08 <p113d_FID_36_112_114_111_100_117_99_116_46_116_114_97_99_101_+0x1248>
  4089fa:	41 b9 00 00 00 00    	mov    $0x0,%r9d
  408a00:	eb 06                	jmp    408a08 <p113d_FID_36_112_114_111_100_117_99_116_46_116_114_97_99_101_+0x1248>
  408a02:	41 b9 00 44 1c c6    	mov    $0xc61c4400,%r9d
  408a08:	4c 89 ad 50 f5 ff ff 	mov    %r13,-0xab0(%rbp)
  408a0f:	4c 89 8d 58 f5 ff ff 	mov    %r9,-0xaa8(%rbp)
  408a16:	66 49 0f 6e d1       	movq   %r9,%xmm2
  408a1b:	f3 0f 5c ca          	subss  %xmm2,%xmm1
  408a1f:	66 49 0f 7e c9       	movq   %xmm1,%r9
  408a24:	45 89 c9             	mov    %r9d,%r9d
  408a27:	4c 89 8d 30 fe ff ff 	mov    %r9,-0x1d0(%rbp)
  408a2e:	4c 89 8d 50 f5 ff ff 	mov    %r9,-0xab0(%rbp)
  408a35:	4c 8b 8d 48 fe ff ff 	mov    -0x1b8(%rbp),%r9
  408a3c:	4c 89 8d 58 f5 ff ff 	mov    %r9,-0xaa8(%rbp)
  408a43:	49 83 fe 00          	cmp    $0x0,%r14
  408a47:	4c 8b b5 88 fe ff ff 	mov    -0x178(%rbp),%r14
  408a4e:	0f 84 a6 00 00 00    	je     408afa <p113d_FID_36_112_114_111_100_117_99_116_46_116_114_97_99_101_+0x133a>
  408a54:	2e 49 83 fe 00       	cs cmp $0x0,%r14
  408a59:	4c 8b b5 80 fe ff ff 	mov    -0x180(%rbp),%r14
  408a60:	0f 84 8c 00 00 00    	je     408af2 <p113d_FID_36_112_114_111_100_117_99_116_46_116_114_97_99_101_+0x1332>
  408a66:	49 83 fe 00          	cmp    $0x0,%r14
  408a6a:	4c 8b b5 78 fe ff ff 	mov    -0x188(%rbp),%r14
  408a71:	74 77                	je     408aea <p113d_FID_36_112_114_111_100_117_99_116_46_116_114_97_99_101_+0x132a>
  408a73:	2e 2e 49 83 fe 00    	cs cs cmp $0x0,%r14
  408a79:	4c 8b b5 70 fe ff ff 	mov    -0x190(%rbp),%r14
  408a80:	74 60                	je     408ae2 <p113d_FID_36_112_114_111_100_117_99_116_46_116_114_97_99_101_+0x1322>
  408a82:	49 83 fe 00          	cmp    $0x0,%r14
  408a86:	4c 8b b5 68 fe ff ff 	mov    -0x198(%rbp),%r14
  408a8d:	74 4b                	je     408ada <p113d_FID_36_112_114_111_100_117_99_116_46_116_114_97_99_101_+0x131a>
  408a8f:	49 83 fe 00          	cmp    $0x0,%r14
  408a93:	4c 8b b5 60 fe ff ff 	mov    -0x1a0(%rbp),%r14
  408a9a:	74 36                	je     408ad2 <p113d_FID_36_112_114_111_100_117_99_116_46_116_114_97_99_101_+0x1312>
  408a9c:	49 83 fe 00          	cmp    $0x0,%r14
  408aa0:	4c 8b b5 58 fe ff ff 	mov    -0x1a8(%rbp),%r14
  408aa7:	74 21                	je     408aca <p113d_FID_36_112_114_111_100_117_99_116_46_116_114_97_99_101_+0x130a>
  408aa9:	4d 89 f1             	mov    %r14,%r9
  408aac:	4c 8b b5 50 fe ff ff 	mov    -0x1b0(%rbp),%r14
  408ab3:	49 83 f9 00          	cmp    $0x0,%r9
  408ab7:	41 b9 00 00 00 41    	mov    $0x41000000,%r9d
  408abd:	4d 0f 44 f1          	cmove  %r9,%r14
  408ac1:	4c 8b 8d 48 fe ff ff 	mov    -0x1b8(%rbp),%r9
  408ac8:	eb 36                	jmp    408b00 <p113d_FID_36_112_114_111_100_117_99_116_46_116_114_97_99_101_+0x1340>
  408aca:	41 be 00 00 e0 40    	mov    $0x40e00000,%r14d
  408ad0:	eb 2e                	jmp    408b00 <p113d_FID_36_112_114_111_100_117_99_116_46_116_114_97_99_101_+0x1340>
  408ad2:	41 be 00 00 60 40    	mov    $0x40600000,%r14d
  408ad8:	eb 26                	jmp    408b00 <p113d_FID_36_112_114_111_100_117_99_116_46_116_114_97_99_101_+0x1340>
  408ada:	41 be 00 00 60 40    	mov    $0x40600000,%r14d
  408ae0:	eb 1e                	jmp    408b00 <p113d_FID_36_112_114_111_100_117_99_116_46_116_114_97_99_101_+0x1340>
  408ae2:	41 be 00 00 c0 40    	mov    $0x40c00000,%r14d
  408ae8:	eb 16                	jmp    408b00 <p113d_FID_36_112_114_111_100_117_99_116_46_116_114_97_99_101_+0x1340>
  408aea:	41 be 00 00 c0 40    	mov    $0x40c00000,%r14d
  408af0:	eb 0e                	jmp    408b00 <p113d_FID_36_112_114_111_100_117_99_116_46_116_114_97_99_101_+0x1340>
  408af2:	41 be 00 00 a0 40    	mov    $0x40a00000,%r14d
  408af8:	eb 06                	jmp    408b00 <p113d_FID_36_112_114_111_100_117_99_116_46_116_114_97_99_101_+0x1340>
  408afa:	41 be 00 00 a0 40    	mov    $0x40a00000,%r14d
  408b00:	48 89 9d 50 f5 ff ff 	mov    %rbx,-0xab0(%rbp)
  408b07:	4c 89 b5 58 f5 ff ff 	mov    %r14,-0xaa8(%rbp)
  408b0e:	66 49 0f 6e ce       	movq   %r14,%xmm1
  408b13:	f3 0f 5c c1          	subss  %xmm1,%xmm0
  408b17:	66 49 0f 7e c6       	movq   %xmm0,%r14
  408b1c:	45 89 f6             	mov    %r14d,%r14d
  408b1f:	4c 89 b5 50 f5 ff ff 	mov    %r14,-0xab0(%rbp)
  408b26:	4c 89 8d 58 f5 ff ff 	mov    %r9,-0xaa8(%rbp)
  408b2d:	66 49 0f 6e c6       	movq   %r14,%xmm0
  408b32:	66 49 0f 6e d9       	movq   %r9,%xmm3
  408b37:	f3 0f 11 9d 44 fe ff ff 	movss  %xmm3,-0x1bc(%rbp)
  408b3f:	f3 0f 5e c3          	divss  %xmm3,%xmm0
  408b43:	66 49 0f 7e c1       	movq   %xmm0,%r9
  408b48:	45 89 c9             	mov    %r9d,%r9d
  408b4b:	4c 89 8d a8 fd ff ff 	mov    %r9,-0x258(%rbp)
  408b52:	48 c7 85 50 f5 ff ff 00 00 00 00 	movq   $0x0,-0xab0(%rbp)
  408b5d:	48 c7 85 50 f5 ff ff 03 00 00 00 	movq   $0x3,-0xab0(%rbp)
  408b68:	48 c7 85 50 f5 ff ff 00 00 00 00 	movq   $0x0,-0xab0(%rbp)
  408b73:	48 c7 85 58 f5 ff ff 00 00 40 40 	movq   $0x40400000,-0xaa8(%rbp)
  408b7e:	41 b9 00 00 40 c0    	mov    $0xc0400000,%r9d
  408b84:	4c 89 8d 50 f5 ff ff 	mov    %r9,-0xab0(%rbp)
  408b8b:	4c 89 a5 58 f5 ff ff 	mov    %r12,-0xaa8(%rbp)
  408b92:	48 c7 85 50 f5 ff ff 08 00 00 00 	movq   $0x8,-0xab0(%rbp)
  408b9d:	48 c7 85 50 f5 ff ff 00 00 00 41 	movq   $0x41000000,-0xab0(%rbp)
  408ba8:	4c 89 ad 58 f5 ff ff 	mov    %r13,-0xaa8(%rbp)
  408baf:	48 c7 85 50 f5 ff ff 01 00 00 00 	movq   $0x1,-0xab0(%rbp)
  408bba:	48 c7 85 50 f5 ff ff 00 00 80 3f 	movq   $0x3f800000,-0xab0(%rbp)
  408bc5:	48 89 9d 58 f5 ff ff 	mov    %rbx,-0xaa8(%rbp)
  408bcc:	4c 89 bd 50 f5 ff ff 	mov    %r15,-0xab0(%rbp)
  408bd3:	4c 89 bd 58 f5 ff ff 	mov    %r15,-0xaa8(%rbp)
  408bda:	48 89 b5 50 f5 ff ff 	mov    %rsi,-0xab0(%rbp)
  408be1:	48 89 b5 58 f5 ff ff 	mov    %rsi,-0xaa8(%rbp)
  408be8:	4c 89 9d 50 f5 ff ff 	mov    %r11,-0xab0(%rbp)
  408bef:	48 89 95 58 f5 ff ff 	mov    %rdx,-0xaa8(%rbp)
  408bf6:	4c 89 95 50 f5 ff ff 	mov    %r10,-0xab0(%rbp)
  408bfd:	4c 89 95 58 f5 ff ff 	mov    %r10,-0xaa8(%rbp)
  408c04:	4c 89 85 50 f5 ff ff 	mov    %r8,-0xab0(%rbp)
  408c0b:	48 89 8d 58 f5 ff ff 	mov    %rcx,-0xaa8(%rbp)
  408c12:	48 89 85 50 f5 ff ff 	mov    %rax,-0xab0(%rbp)
  408c19:	b9 01 00 00 00       	mov    $0x1,%ecx
  408c1e:	48 8d 95 50 f5 ff ff 	lea    -0xab0(%rbp),%rdx
  408c25:	be 24 00 00 00       	mov    $0x24,%esi
  408c2a:	49 89 fe             	mov    %rdi,%r14
  408c2d:	e8 8e 3c 02 00       	callq  42c8c0 <p111_rt_op>
  408c32:	4c 89 f7             	mov    %r14,%rdi
  408c35:	48 89 c2             	mov    %rax,%rdx
  408c38:	48 8b 85 f8 fd ff ff 	mov    -0x208(%rbp),%rax
  408c3f:	4c 8b b5 20 fe ff ff 	mov    -0x1e0(%rbp),%r14
  408c46:	4c 8b 95 18 fe ff ff 	mov    -0x1e8(%rbp),%r10
  408c4d:	4c 8b 9d 10 fe ff ff 	mov    -0x1f0(%rbp),%r11
  408c54:	4c 8b 85 a8 fd ff ff 	mov    -0x258(%rbp),%r8
  408c5b:	4c 8b 8d 30 fe ff ff 	mov    -0x1d0(%rbp),%r9
  408c62:	48 8b 8d 28 fe ff ff 	mov    -0x1d8(%rbp),%rcx
  408c69:	f3 0f 10 8d 40 fe ff ff 	movss  -0x1c0(%rbp),%xmm1
  408c71:	f3 0f 10 a5 3c fe ff ff 	movss  -0x1c4(%rbp),%xmm4
  408c79:	f3 0f 10 ad 38 fe ff ff 	movss  -0x1c8(%rbp),%xmm5
  408c81:	f3 0f 10 85 08 fe ff ff 	movss  -0x1f8(%rbp),%xmm0
  408c89:	f3 0f 10 9d 44 fe ff ff 	movss  -0x1bc(%rbp),%xmm3
  408c91:	48 89 95 e0 fd ff ff 	mov    %rdx,-0x220(%rbp)
  408c98:	4c 89 bd 50 f5 ff ff 	mov    %r15,-0xab0(%rbp)
  408c9f:	48 89 95 58 f5 ff ff 	mov    %rdx,-0xaa8(%rbp)
  408ca6:	66 48 0f 6e d2       	movq   %rdx,%xmm2
  408cab:	f3 0f 5e ea          	divss  %xmm2,%xmm5
  408caf:	66 48 0f 7e ee       	movq   %xmm5,%rsi
  408cb4:	89 f6                	mov    %esi,%esi
  408cb6:	48 89 b5 b0 fd ff ff 	mov    %rsi,-0x250(%rbp)
  408cbd:	4c 89 9d 50 f5 ff ff 	mov    %r11,-0xab0(%rbp)
  408cc4:	48 89 95 58 f5 ff ff 	mov    %rdx,-0xaa8(%rbp)
  408ccb:	f3 0f 5e e2          	divss  %xmm2,%xmm4
  408ccf:	49 89 d7             	mov    %rdx,%r15
  408cd2:	66 48 0f 7e e2       	movq   %xmm4,%rdx
  408cd7:	89 d2                	mov    %edx,%edx
  408cd9:	48 89 95 b8 fd ff ff 	mov    %rdx,-0x248(%rbp)
  408ce0:	4c 89 95 50 f5 ff ff 	mov    %r10,-0xab0(%rbp)
  408ce7:	4c 89 bd 58 f5 ff ff 	mov    %r15,-0xaa8(%rbp)
  408cee:	f3 0f 5e ca          	divss  %xmm2,%xmm1
  408cf2:	66 49 0f 7e ca       	movq   %xmm1,%r10
  408cf7:	45 89 d2             	mov    %r10d,%r10d
  408cfa:	4c 89 95 c0 fd ff ff 	mov    %r10,-0x240(%rbp)
  408d01:	66 48 0f 6e c9       	movq   %rcx,%xmm1
  408d06:	f3 0f 5e cb          	divss  %xmm3,%xmm1
  408d0a:	66 48 0f 7e c9       	movq   %xmm1,%rcx
  408d0f:	89 c9                	mov    %ecx,%ecx
  408d11:	48 89 8d 00 fe ff ff 	mov    %rcx,-0x200(%rbp)
  408d18:	48 89 8d 50 f5 ff ff 	mov    %rcx,-0xab0(%rbp)
  408d1f:	48 89 b5 58 f5 ff ff 	mov    %rsi,-0xaa8(%rbp)
  408d26:	66 48 0f 6e c9       	movq   %rcx,%xmm1
  408d2b:	f3 0f 11 8d 0c fe ff ff 	movss  %xmm1,-0x1f4(%rbp)
  408d33:	66 48 0f 6e d6       	movq   %rsi,%xmm2
  408d38:	f3 0f 59 d1          	mulss  %xmm1,%xmm2
  408d3c:	66 48 0f 7e d6       	movq   %xmm2,%rsi
  408d41:	89 f6                	mov    %esi,%esi
  408d43:	66 49 0f 6e d1       	movq   %r9,%xmm2
  408d48:	f3 0f 5e d3          	divss  %xmm3,%xmm2
  408d4c:	66 49 0f 7e d1       	movq   %xmm2,%r9
  408d51:	45 89 c9             	mov    %r9d,%r9d
  408d54:	4c 89 8d e8 fd ff ff 	mov    %r9,-0x218(%rbp)
  408d5b:	4c 89 8d 50 f5 ff ff 	mov    %r9,-0xab0(%rbp)
  408d62:	48 89 95 58 f5 ff ff 	mov    %rdx,-0xaa8(%rbp)
  408d69:	66 49 0f 6e d1       	movq   %r9,%xmm2
  408d6e:	f3 0f 11 95 f4 fd ff ff 	movss  %xmm2,-0x20c(%rbp)
  408d76:	66 48 0f 6e da       	movq   %rdx,%xmm3
  408d7b:	f3 0f 59 d3          	mulss  %xmm3,%xmm2
  408d7f:	66 48 0f 7e d2       	movq   %xmm2,%rdx
  408d84:	89 d2                	mov    %edx,%edx
  408d86:	48 89 b5 50 f5 ff ff 	mov    %rsi,-0xab0(%rbp)
  408d8d:	48 89 95 58 f5 ff ff 	mov    %rdx,-0xaa8(%rbp)
  408d94:	66 48 0f 6e d6       	movq   %rsi,%xmm2
  408d99:	66 48 0f 6e da       	movq   %rdx,%xmm3
  408d9e:	f3 0f 58 d3          	addss  %xmm3,%xmm2
  408da2:	66 48 0f 7e d2       	movq   %xmm2,%rdx
  408da7:	89 d6                	mov    %edx,%esi
  408da9:	4c 89 85 50 f5 ff ff 	mov    %r8,-0xab0(%rbp)
  408db0:	4c 89 95 58 f5 ff ff 	mov    %r10,-0xaa8(%rbp)
  408db7:	66 49 0f 6e d0       	movq   %r8,%xmm2
  408dbc:	f3 0f 11 95 dc fd ff ff 	movss  %xmm2,-0x224(%rbp)
  408dc4:	66 49 0f 6e da       	movq   %r10,%xmm3
  408dc9:	f3 0f 59 d3          	mulss  %xmm3,%xmm2
  408dcd:	66 48 0f 7e d2       	movq   %xmm2,%rdx
  408dd2:	89 d2                	mov    %edx,%edx
  408dd4:	48 89 b5 50 f5 ff ff 	mov    %rsi,-0xab0(%rbp)
  408ddb:	48 89 95 58 f5 ff ff 	mov    %rdx,-0xaa8(%rbp)
  408de2:	66 48 0f 6e d6       	movq   %rsi,%xmm2
  408de7:	66 48 0f 6e da       	movq   %rdx,%xmm3
  408dec:	f3 0f 58 d3          	addss  %xmm3,%xmm2
  408df0:	66 48 0f 7e d2       	movq   %xmm2,%rdx
  408df5:	89 d2                	mov    %edx,%edx
  408df7:	66 48 0f 6e d2       	movq   %rdx,%xmm2
  408dfc:	f3 0f 10 1d 20 92 02 00 	movss  0x29220(%rip),%xmm3        # 432024 <_IO_stdin_used+0x24>
  408e04:	0f 2e da             	ucomiss %xmm2,%xmm3
  408e07:	40 0f 97 c6          	seta   %sil
  408e0b:	40 0f b6 f6          	movzbl %sil,%esi
  408e0f:	41 89 f0             	mov    %esi,%r8d
  408e12:	49 83 f8 01          	cmp    $0x1,%r8
  408e16:	40 0f 94 c6          	sete   %sil
  408e1a:	40 0f b6 f6          	movzbl %sil,%esi
  408e1e:	49 c1 e8 28          	shr    $0x28,%r8
  408e22:	49 81 e0 ff ff 7f 00 	and    $0x7fffff,%r8
  408e29:	49 81 f8 02 00 01 00 	cmp    $0x10002,%r8
  408e30:	41 0f 94 c0          	sete   %r8b
  408e34:	45 0f b6 c0          	movzbl %r8b,%r8d
  408e38:	44 09 c6             	or     %r8d,%esi
  408e3b:	75 41                	jne    408e7e <p113d_FID_36_112_114_111_100_117_99_116_46_116_114_97_99_101_+0x16be>
  408e3d:	83 f6 01             	xor    $0x1,%esi
  408e40:	75 33                	jne    408e75 <p113d_FID_36_112_114_111_100_117_99_116_46_116_114_97_99_101_+0x16b5>
  408e42:	be 04 00 00 00       	mov    $0x4,%esi
  408e47:	49 89 ff             	mov    %rdi,%r15
  408e4a:	e8 51 3a 02 00       	callq  42c8a0 <p111_rt_fail>
  408e4f:	4c 89 ff             	mov    %r15,%rdi
  408e52:	48 8b 85 f8 fd ff ff 	mov    -0x208(%rbp),%rax
  408e59:	48 8b 8d 00 fe ff ff 	mov    -0x200(%rbp),%rcx
  408e60:	f3 0f 10 85 08 fe ff ff 	movss  -0x1f8(%rbp),%xmm0
  408e68:	f3 0f 10 8d 0c fe ff ff 	movss  -0x1f4(%rbp),%xmm1
  408e70:	ba 00 00 00 00       	mov    $0x0,%edx
  408e75:	48 89 95 98 fd ff ff 	mov    %rdx,-0x268(%rbp)
  408e7c:	eb 0b                	jmp    408e89 <p113d_FID_36_112_114_111_100_117_99_116_46_116_114_97_99_101_+0x16c9>
  408e7e:	48 c7 85 98 fd ff ff 00 00 00 00 	movq   $0x0,-0x268(%rbp)
  408e89:	48 c7 85 50 f5 ff ff 6f 12 83 3a 	movq   $0x3a83126f,-0xab0(%rbp)
  408e94:	48 89 8d 58 f5 ff ff 	mov    %rcx,-0xaa8(%rbp)
  408e9b:	f3 0f 59 0d 85 91 02 00 	mulss  0x29185(%rip),%xmm1        # 432028 <_IO_stdin_used+0x28>
  408ea3:	66 48 0f 7e c9       	movq   %xmm1,%rcx
  408ea8:	89 c9                	mov    %ecx,%ecx
  408eaa:	4c 89 a5 50 f5 ff ff 	mov    %r12,-0xab0(%rbp)
  408eb1:	48 89 8d 58 f5 ff ff 	mov    %rcx,-0xaa8(%rbp)
  408eb8:	66 48 0f 6e c9       	movq   %rcx,%xmm1
  408ebd:	f3 0f 58 c1          	addss  %xmm1,%xmm0
  408ec1:	49 89 c4             	mov    %rax,%r12
  408ec4:	66 48 0f 7e c0       	movq   %xmm0,%rax
  408ec9:	89 c2                	mov    %eax,%edx
  408ecb:	48 89 95 c8 fd ff ff 	mov    %rdx,-0x238(%rbp)
  408ed2:	ba e8 03 00 00       	mov    $0x3e8,%edx
  408ed7:	be 01 00 00 00       	mov    $0x1,%esi
  408edc:	49 89 ff             	mov    %rdi,%r15
  408edf:	e8 8c ce ff ff       	callq  405d70 <p113d_FID_36_100_105_114_101_99_116_46_102_108_>
  408ee4:	4c 89 ff             	mov    %r15,%rdi
  408ee7:	48 89 c1             	mov    %rax,%rcx
  408eea:	4c 89 e0             	mov    %r12,%rax
  408eed:	48 8b 95 e0 fd ff ff 	mov    -0x220(%rbp),%rdx
  408ef4:	48 8b b5 e8 fd ff ff 	mov    -0x218(%rbp),%rsi
  408efb:	f3 0f 10 8d f0 fd ff ff 	movss  -0x210(%rbp),%xmm1
  408f03:	f3 0f 10 85 f4 fd ff ff 	movss  -0x20c(%rbp),%xmm0
  408f0b:	48 89 8d 50 f5 ff ff 	mov    %rcx,-0xab0(%rbp)
  408f12:	48 89 b5 58 f5 ff ff 	mov    %rsi,-0xaa8(%rbp)
  408f19:	66 48 0f 6e d1       	movq   %rcx,%xmm2
  408f1e:	f3 0f 59 c2          	mulss  %xmm2,%xmm0
  408f22:	66 48 0f 7e c1       	movq   %xmm0,%rcx
  408f27:	89 c9                	mov    %ecx,%ecx
  408f29:	4c 89 ad 50 f5 ff ff 	mov    %r13,-0xab0(%rbp)
  408f30:	48 89 8d 58 f5 ff ff 	mov    %rcx,-0xaa8(%rbp)
  408f37:	66 48 0f 6e c1       	movq   %rcx,%xmm0
  408f3c:	f3 0f 58 c1          	addss  %xmm1,%xmm0
  408f40:	49 89 c4             	mov    %rax,%r12
  408f43:	66 48 0f 7e c0       	movq   %xmm0,%rax
  408f48:	89 c1                	mov    %eax,%ecx
  408f4a:	48 89 8d d0 fd ff ff 	mov    %rcx,-0x230(%rbp)
  408f51:	49 89 d7             	mov    %rdx,%r15
  408f54:	ba e8 03 00 00       	mov    $0x3e8,%edx
  408f59:	be 01 00 00 00       	mov    $0x1,%esi
  408f5e:	49 89 fd             	mov    %rdi,%r13
  408f61:	e8 0a ce ff ff       	callq  405d70 <p113d_FID_36_100_105_114_101_99_116_46_102_108_>
  408f66:	4c 89 fa             	mov    %r15,%rdx
  408f69:	4c 89 ef             	mov    %r13,%rdi
  408f6c:	48 89 c6             	mov    %rax,%rsi
  408f6f:	4c 89 e0             	mov    %r12,%rax
  408f72:	48 8b 8d d0 fd ff ff 	mov    -0x230(%rbp),%rcx
  408f79:	49 89 d4             	mov    %rdx,%r12
  408f7c:	48 8b 95 c8 fd ff ff 	mov    -0x238(%rbp),%rdx
  408f83:	4c 8b 95 c0 fd ff ff 	mov    -0x240(%rbp),%r10
  408f8a:	49 89 c5             	mov    %rax,%r13
  408f8d:	48 8b 85 b8 fd ff ff 	mov    -0x248(%rbp),%rax
  408f94:	4c 8b 8d b0 fd ff ff 	mov    -0x250(%rbp),%r9
  408f9b:	4c 8b 85 a8 fd ff ff 	mov    -0x258(%rbp),%r8
  408fa2:	f3 0f 10 85 d8 fd ff ff 	movss  -0x228(%rbp),%xmm0
  408faa:	f3 0f 10 8d dc fd ff ff 	movss  -0x224(%rbp),%xmm1
  408fb2:	48 89 b5 50 f5 ff ff 	mov    %rsi,-0xab0(%rbp)
  408fb9:	4c 89 85 58 f5 ff ff 	mov    %r8,-0xaa8(%rbp)
  408fc0:	66 48 0f 6e d6       	movq   %rsi,%xmm2
  408fc5:	f3 0f 59 ca          	mulss  %xmm2,%xmm1
  408fc9:	66 48 0f 7e ce       	movq   %xmm1,%rsi
  408fce:	89 f6                	mov    %esi,%esi
  408fd0:	48 89 9d 50 f5 ff ff 	mov    %rbx,-0xab0(%rbp)
  408fd7:	48 89 b5 58 f5 ff ff 	mov    %rsi,-0xaa8(%rbp)
  408fde:	66 48 0f 6e ce       	movq   %rsi,%xmm1
  408fe3:	f3 0f 58 c1          	addss  %xmm1,%xmm0
  408fe7:	66 48 0f 7e c6       	movq   %xmm0,%rsi
  408fec:	41 89 f0             	mov    %esi,%r8d
  408fef:	48 c7 85 50 f5 ff ff 00 ca 9a 3b 	movq   $0x3b9aca00,-0xab0(%rbp)
  408ffa:	48 c7 85 50 f5 ff ff 00 ca 9a 3b 	movq   $0x3b9aca00,-0xab0(%rbp)
  409005:	48 83 ec 30          	sub    $0x30,%rsp
  409009:	48 89 e6             	mov    %rsp,%rsi
  40900c:	48 c7 46 20 00 00 00 00 	movq   $0x0,0x20(%rsi)
  409014:	48 c7 46 18 28 6b 6e 4e 	movq   $0x4e6e6b28,0x18(%rsi)
  40901c:	48 c7 46 10 28 6b 6e 4e 	movq   $0x4e6e6b28,0x10(%rsi)
  409024:	4c 89 56 08          	mov    %r10,0x8(%rsi)
  409028:	48 89 06             	mov    %rax,(%rsi)
  40902b:	be 09 00 00 00       	mov    $0x9,%esi
  409030:	48 89 fb             	mov    %rdi,%rbx
  409033:	e8 a8 e1 ff ff       	callq  4071e0 <p113d_FID_36_100_105_114_101_99_116_46_110_101_97_114_101_115_116_46_116_>
  409038:	4c 89 e2             	mov    %r12,%rdx
  40903b:	48 89 df             	mov    %rbx,%rdi
  40903e:	48 89 85 a0 fd ff ff 	mov    %rax,-0x260(%rbp)
  409045:	48 83 ec d0          	sub    $0xffffffffffffffd0,%rsp
  409049:	49 89 d4             	mov    %rdx,%r12
  40904c:	ba 0a 00 00 00       	mov    $0xa,%edx
  409051:	be 01 00 00 00       	mov    $0x1,%esi
  409056:	48 89 fb             	mov    %rdi,%rbx
  409059:	e8 12 cd ff ff       	callq  405d70 <p113d_FID_36_100_105_114_101_99_116_46_102_108_>
  40905e:	4c 89 e2             	mov    %r12,%rdx
  409061:	48 89 df             	mov    %rbx,%rdi
  409064:	48 89 c3             	mov    %rax,%rbx
  409067:	49 89 d7             	mov    %rdx,%r15
  40906a:	ba 64 00 00 00       	mov    $0x64,%edx
  40906f:	be 55 00 00 00       	mov    $0x55,%esi
  409074:	49 89 fc             	mov    %rdi,%r12
  409077:	e8 f4 cc ff ff       	callq  405d70 <p113d_FID_36_100_105_114_101_99_116_46_102_108_>
  40907c:	4c 89 fa             	mov    %r15,%rdx
  40907f:	4c 89 e7             	mov    %r12,%rdi
  409082:	49 89 c4             	mov    %rax,%r12
  409085:	48 8b 8d 98 fd ff ff 	mov    -0x268(%rbp),%rcx
  40908c:	48 8b b5 a0 fd ff ff 	mov    -0x260(%rbp),%rsi
  409093:	e8 38 d5 ff ff       	callq  4065d0 <p113d_FID_36_100_105_114_101_99_116_46_115_104_97_100_101_>
  409098:	4c 89 f7             	mov    %r14,%rdi
  40909b:	48 89 c1             	mov    %rax,%rcx
  40909e:	4c 89 e8             	mov    %r13,%rax
  4090a1:	f3 0f 10 95 94 fd ff ff 	movss  -0x26c(%rbp),%xmm2
  4090a9:	f3 0f 10 85 90 fd ff ff 	movss  -0x270(%rbp),%xmm0
  4090b1:	4c 89 a5 50 f5 ff ff 	mov    %r12,-0xab0(%rbp)
  4090b8:	48 89 8d 58 f5 ff ff 	mov    %rcx,-0xaa8(%rbp)
  4090bf:	66 49 0f 6e cc       	movq   %r12,%xmm1
  4090c4:	66 48 0f 6e d9       	movq   %rcx,%xmm3
  4090c9:	f3 0f 59 cb          	mulss  %xmm3,%xmm1
  4090cd:	66 48 0f 7e c9       	movq   %xmm1,%rcx
  4090d2:	89 c9                	mov    %ecx,%ecx
  4090d4:	48 89 9d 50 f5 ff ff 	mov    %rbx,-0xab0(%rbp)
  4090db:	48 89 8d 58 f5 ff ff 	mov    %rcx,-0xaa8(%rbp)
  4090e2:	66 48 0f 6e cb       	movq   %rbx,%xmm1
  4090e7:	66 48 0f 6e d9       	movq   %rcx,%xmm3
  4090ec:	f3 0f 58 cb          	addss  %xmm3,%xmm1
  4090f0:	66 48 0f 7e c9       	movq   %xmm1,%rcx
  4090f5:	89 c9                	mov    %ecx,%ecx
  4090f7:	48 89 bd 50 f5 ff ff 	mov    %rdi,-0xab0(%rbp)
  4090fe:	48 89 8d 58 f5 ff ff 	mov    %rcx,-0xaa8(%rbp)
  409105:	66 48 0f 6e c9       	movq   %rcx,%xmm1
  40910a:	f3 0f 59 c1          	mulss  %xmm1,%xmm0
  40910e:	48 89 c3             	mov    %rax,%rbx
  409111:	66 48 0f 7e c0       	movq   %xmm0,%rax
  409116:	89 c0                	mov    %eax,%eax
  409118:	48 89 9d 50 f5 ff ff 	mov    %rbx,-0xab0(%rbp)
  40911f:	48 89 85 58 f5 ff ff 	mov    %rax,-0xaa8(%rbp)
  409126:	66 48 0f 6e c0       	movq   %rax,%xmm0
  40912b:	f3 0f 58 c2          	addss  %xmm2,%xmm0
  40912f:	66 48 0f 7e c0       	movq   %xmm0,%rax
  409134:	89 c0                	mov    %eax,%eax
  409136:	41 5f                	pop    %r15
  409138:	41 5e                	pop    %r14
  40913a:	41 5d                	pop    %r13
  40913c:	41 5c                	pop    %r12
  40913e:	5b                   	pop    %rbx
  40913f:	c9                   	leaveq 
  409140:	c3                   	retq   
  409141:	66 66 2e 0f 1f 84 00 00 00 00 00 	data16 nopw %cs:0x0(%rax,%rax,1)
  40914c:	0f 1f 40 00          	nopl   0x0(%rax)

