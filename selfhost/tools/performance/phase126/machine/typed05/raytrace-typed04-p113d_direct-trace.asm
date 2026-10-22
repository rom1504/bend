0000000000409770 <p113d_FID_36_100_105_114_101_99_116_46_116_114_97_99_101_>:
  409770:	f3 0f 1e fa          	endbr64 
  409774:	55                   	push   %rbp
  409775:	48 89 e5             	mov    %rsp,%rbp
  409778:	48 81 ec 98 0a 00 00 	sub    $0xa98,%rsp
  40977f:	53                   	push   %rbx
  409780:	41 54                	push   %r12
  409782:	41 55                	push   %r13
  409784:	41 56                	push   %r14
  409786:	41 57                	push   %r15
  409788:	48 8b 5d 30          	mov    0x30(%rbp),%rbx
  40978c:	48 89 9d e8 fe ff ff 	mov    %rbx,-0x118(%rbp)
  409793:	48 8b 45 28          	mov    0x28(%rbp),%rax
  409797:	4c 8b 75 20          	mov    0x20(%rbp),%r14
  40979b:	4c 8b 65 18          	mov    0x18(%rbp),%r12
  40979f:	4c 8b 7d 10          	mov    0x10(%rbp),%r15
  4097a3:	4d 89 c2             	mov    %r8,%r10
  4097a6:	4d 89 c8             	mov    %r9,%r8
  4097a9:	49 89 cb             	mov    %rcx,%r11
  4097ac:	48 87 d6             	xchg   %rdx,%rsi
  4097af:	4c 87 e2             	xchg   %r12,%rdx
  4097b2:	4c 89 85 a8 fe ff ff 	mov    %r8,-0x158(%rbp)
  4097b9:	4c 89 95 c0 fe ff ff 	mov    %r10,-0x140(%rbp)
  4097c0:	4c 89 9d d0 fe ff ff 	mov    %r11,-0x130(%rbp)
  4097c7:	4c 89 a5 40 ff ff ff 	mov    %r12,-0xc0(%rbp)
  4097ce:	49 83 fc 00          	cmp    $0x0,%r12
  4097d2:	0f 94 c1             	sete   %cl
  4097d5:	0f b6 c9             	movzbl %cl,%ecx
  4097d8:	66 49 0f 6e f7       	movq   %r15,%xmm6
  4097dd:	f3 0f 11 b5 e4 fe ff ff 	movss  %xmm6,-0x11c(%rbp)
  4097e5:	66 49 0f 6e cb       	movq   %r11,%xmm1
  4097ea:	f3 0f 11 8d f8 fe ff ff 	movss  %xmm1,-0x108(%rbp)
  4097f2:	66 48 0f 6e ea       	movq   %rdx,%xmm5
  4097f7:	f3 0f 11 ad f0 fe ff ff 	movss  %xmm5,-0x110(%rbp)
  4097ff:	66 49 0f 6e d2       	movq   %r10,%xmm2
  409804:	f3 0f 11 95 fc fe ff ff 	movss  %xmm2,-0x104(%rbp)
  40980c:	66 49 0f 6e e6       	movq   %r14,%xmm4
  409811:	f3 0f 11 a5 f4 fe ff ff 	movss  %xmm4,-0x10c(%rbp)
  409819:	66 49 0f 6e d8       	movq   %r8,%xmm3
  40981e:	f3 0f 11 9d 00 ff ff ff 	movss  %xmm3,-0x100(%rbp)
  409826:	66 48 0f 6e d3       	movq   %rbx,%xmm2
  40982b:	f3 0f 11 95 b0 fd ff ff 	movss  %xmm2,-0x250(%rbp)
  409833:	66 48 0f 6e c8       	movq   %rax,%xmm1
  409838:	f3 0f 11 8d b4 fd ff ff 	movss  %xmm1,-0x24c(%rbp)
  409840:	48 89 c3             	mov    %rax,%rbx
  409843:	48 89 f0             	mov    %rsi,%rax
  409846:	48 c1 e8 28          	shr    $0x28,%rax
  40984a:	48 25 ff ff 00 00    	and    $0xffff,%rax
  409850:	41 b8 00 00 00 41    	mov    $0x41000000,%r8d
  409856:	4c 89 85 58 fe ff ff 	mov    %r8,-0x1a8(%rbp)
  40985d:	41 b8 cd cc 4c 3e    	mov    $0x3e4ccccd,%r8d
  409863:	4c 89 85 90 fe ff ff 	mov    %r8,-0x170(%rbp)
  40986a:	41 b8 00 00 60 c0    	mov    $0xc0600000,%r8d
  409870:	4c 89 85 a0 fe ff ff 	mov    %r8,-0x160(%rbp)
  409877:	41 ba 00 00 80 3f    	mov    $0x3f800000,%r10d
  40987d:	4c 89 95 d8 fe ff ff 	mov    %r10,-0x128(%rbp)
  409884:	83 f9 00             	cmp    $0x0,%ecx
  409887:	0f 85 a6 0d 00 00    	jne    40a633 <p113d_FID_36_100_105_114_101_99_116_46_116_114_97_99_101_+0xec3>
  40988d:	48 3d 97 00 00 00    	cmp    $0x97,%rax
  409893:	74 14                	je     4098a9 <p113d_FID_36_100_105_114_101_99_116_46_116_114_97_99_101_+0x139>
  409895:	be 04 00 00 00       	mov    $0x4,%esi
  40989a:	e8 61 35 02 00       	callq  42ce00 <p111_rt_fail>
  40989f:	b8 00 00 00 00       	mov    $0x0,%eax
  4098a4:	e9 11 1a 00 00       	jmpq   40b2ba <p113d_FID_36_100_105_114_101_99_116_46_116_114_97_99_101_+0x1b4a>
  4098a9:	49 89 d5             	mov    %rdx,%r13
  4098ac:	48 8d 95 70 f5 ff ff 	lea    -0xa90(%rbp),%rdx
  4098b3:	49 89 fc             	mov    %rdi,%r12
  4098b6:	e8 c5 87 02 00       	callq  432080 <p125_rt_take3>
  4098bb:	4c 89 ea             	mov    %r13,%rdx
  4098be:	4c 89 e7             	mov    %r12,%rdi
  4098c1:	48 89 d8             	mov    %rbx,%rax
  4098c4:	48 8b 8d 70 f5 ff ff 	mov    -0xa90(%rbp),%rcx
  4098cb:	49 89 d5             	mov    %rdx,%r13
  4098ce:	48 8b 95 78 f5 ff ff 	mov    -0xa88(%rbp),%rdx
  4098d5:	48 89 55 f0          	mov    %rdx,-0x10(%rbp)
  4098d9:	48 8b b5 80 f5 ff ff 	mov    -0xa80(%rbp),%rsi
  4098e0:	48 89 b5 50 ff ff ff 	mov    %rsi,-0xb0(%rbp)
  4098e7:	48 83 f9 01          	cmp    $0x1,%rcx
  4098eb:	48 89 c3             	mov    %rax,%rbx
  4098ee:	0f 94 c0             	sete   %al
  4098f1:	0f b6 c0             	movzbl %al,%eax
  4098f4:	48 c1 e9 28          	shr    $0x28,%rcx
  4098f8:	48 81 e1 ff ff 7f 00 	and    $0x7fffff,%rcx
  4098ff:	48 81 f9 02 00 01 00 	cmp    $0x10002,%rcx
  409906:	0f 94 c1             	sete   %cl
  409909:	0f b6 c9             	movzbl %cl,%ecx
  40990c:	09 c8                	or     %ecx,%eax
  40990e:	0f 85 14 0d 00 00    	jne    40a628 <p113d_FID_36_100_105_114_101_99_116_46_116_114_97_99_101_+0xeb8>
  409914:	83 f0 01             	xor    $0x1,%eax
  409917:	75 14                	jne    40992d <p113d_FID_36_100_105_114_101_99_116_46_116_114_97_99_101_+0x1bd>
  409919:	be 04 00 00 00       	mov    $0x4,%esi
  40991e:	e8 dd 34 02 00       	callq  42ce00 <p111_rt_fail>
  409923:	b8 00 00 00 00       	mov    $0x0,%eax
  409928:	e9 8d 19 00 00       	jmpq   40b2ba <p113d_FID_36_100_105_114_101_99_116_46_116_114_97_99_101_+0x1b4a>
  40992d:	49 89 fc             	mov    %rdi,%r12
  409930:	e8 4b cb ff ff       	callq  406480 <p113d_FID_36_100_105_114_101_99_116_46_115_114_>
  409935:	4d 89 f9             	mov    %r15,%r9
  409938:	4c 89 e7             	mov    %r12,%rdi
  40993b:	48 89 45 e0          	mov    %rax,-0x20(%rbp)
  40993f:	48 89 d8             	mov    %rbx,%rax
  409942:	f3 0f 10 9d 00 ff ff ff 	movss  -0x100(%rbp),%xmm3
  40994a:	f3 0f 10 a5 f4 fe ff ff 	movss  -0x10c(%rbp),%xmm4
  409952:	f3 0f 10 95 fc fe ff ff 	movss  -0x104(%rbp),%xmm2
  40995a:	f3 0f 10 ad f0 fe ff ff 	movss  -0x110(%rbp),%xmm5
  409962:	f3 0f 10 8d f8 fe ff ff 	movss  -0x108(%rbp),%xmm1
  40996a:	f3 0f 10 b5 e4 fe ff ff 	movss  -0x11c(%rbp),%xmm6
  409972:	48 8b b5 50 ff ff ff 	mov    -0xb0(%rbp),%rsi
  409979:	48 8b 4d f0          	mov    -0x10(%rbp),%rcx
  40997d:	48 8b 95 a8 fe ff ff 	mov    -0x158(%rbp),%rdx
  409984:	4c 8b 95 c0 fe ff ff 	mov    -0x140(%rbp),%r10
  40998b:	4c 8b 9d d0 fe ff ff 	mov    -0x130(%rbp),%r11
  409992:	48 89 8d 70 f5 ff ff 	mov    %rcx,-0xa90(%rbp)
  409999:	4c 89 8d 78 f5 ff ff 	mov    %r9,-0xa88(%rbp)
  4099a0:	66 48 0f 6e c1       	movq   %rcx,%xmm0
  4099a5:	f3 0f 59 f0          	mulss  %xmm0,%xmm6
  4099a9:	66 49 0f 7e f0       	movq   %xmm6,%r8
  4099ae:	45 89 c0             	mov    %r8d,%r8d
  4099b1:	4c 89 9d 70 f5 ff ff 	mov    %r11,-0xa90(%rbp)
  4099b8:	4c 89 85 78 f5 ff ff 	mov    %r8,-0xa88(%rbp)
  4099bf:	66 49 0f 6e f0       	movq   %r8,%xmm6
  4099c4:	f3 0f 58 ce          	addss  %xmm6,%xmm1
  4099c8:	66 49 0f 7e c8       	movq   %xmm1,%r8
  4099cd:	45 89 c0             	mov    %r8d,%r8d
  4099d0:	4c 89 45 b0          	mov    %r8,-0x50(%rbp)
  4099d4:	48 89 8d 70 f5 ff ff 	mov    %rcx,-0xa90(%rbp)
  4099db:	4c 89 ad 78 f5 ff ff 	mov    %r13,-0xa88(%rbp)
  4099e2:	f3 0f 10 c8          	movss  %xmm0,%xmm1
  4099e6:	f3 0f 59 cd          	mulss  %xmm5,%xmm1
  4099ea:	66 49 0f 7e c8       	movq   %xmm1,%r8
  4099ef:	45 89 c0             	mov    %r8d,%r8d
  4099f2:	4c 89 95 70 f5 ff ff 	mov    %r10,-0xa90(%rbp)
  4099f9:	4c 89 85 78 f5 ff ff 	mov    %r8,-0xa88(%rbp)
  409a00:	66 49 0f 6e c8       	movq   %r8,%xmm1
  409a05:	f3 0f 58 ca          	addss  %xmm2,%xmm1
  409a09:	66 49 0f 7e c8       	movq   %xmm1,%r8
  409a0e:	45 89 c0             	mov    %r8d,%r8d
  409a11:	4c 89 45 a8          	mov    %r8,-0x58(%rbp)
  409a15:	48 89 8d 70 f5 ff ff 	mov    %rcx,-0xa90(%rbp)
  409a1c:	4c 89 b5 78 f5 ff ff 	mov    %r14,-0xa88(%rbp)
  409a23:	f3 0f 59 c4          	mulss  %xmm4,%xmm0
  409a27:	66 48 0f 7e c1       	movq   %xmm0,%rcx
  409a2c:	89 c9                	mov    %ecx,%ecx
  409a2e:	48 89 95 70 f5 ff ff 	mov    %rdx,-0xa90(%rbp)
  409a35:	48 89 8d 78 f5 ff ff 	mov    %rcx,-0xa88(%rbp)
  409a3c:	66 48 0f 6e c1       	movq   %rcx,%xmm0
  409a41:	f3 0f 58 c3          	addss  %xmm3,%xmm0
  409a45:	48 89 c3             	mov    %rax,%rbx
  409a48:	66 48 0f 7e c0       	movq   %xmm0,%rax
  409a4d:	4d 89 cf             	mov    %r9,%r15
  409a50:	41 89 c1             	mov    %eax,%r9d
  409a53:	4c 89 4d 80          	mov    %r9,-0x80(%rbp)
  409a57:	49 89 fc             	mov    %rdi,%r12
  409a5a:	e8 91 cc ff ff       	callq  4066f0 <p113d_FID_36_100_105_114_101_99_116_46_115_120_>
  409a5f:	4c 89 ea             	mov    %r13,%rdx
  409a62:	4c 89 e7             	mov    %r12,%rdi
  409a65:	48 89 c1             	mov    %rax,%rcx
  409a68:	48 89 d8             	mov    %rbx,%rax
  409a6b:	49 89 d5             	mov    %rdx,%r13
  409a6e:	48 8b 55 b0          	mov    -0x50(%rbp),%rdx
  409a72:	4c 8b 55 e0          	mov    -0x20(%rbp),%r10
  409a76:	48 8b b5 50 ff ff ff 	mov    -0xb0(%rbp),%rsi
  409a7d:	48 89 95 70 f5 ff ff 	mov    %rdx,-0xa90(%rbp)
  409a84:	48 89 8d 78 f5 ff ff 	mov    %rcx,-0xa88(%rbp)
  409a8b:	66 48 0f 6e c2       	movq   %rdx,%xmm0
  409a90:	f3 0f 11 45 b8       	movss  %xmm0,-0x48(%rbp)
  409a95:	66 48 0f 6e c9       	movq   %rcx,%xmm1
  409a9a:	f3 0f 5c c1          	subss  %xmm1,%xmm0
  409a9e:	66 48 0f 7e c1       	movq   %xmm0,%rcx
  409aa3:	89 c9                	mov    %ecx,%ecx
  409aa5:	48 89 8d 70 f5 ff ff 	mov    %rcx,-0xa90(%rbp)
  409aac:	4c 89 95 78 f5 ff ff 	mov    %r10,-0xa88(%rbp)
  409ab3:	66 48 0f 6e c1       	movq   %rcx,%xmm0
  409ab8:	66 49 0f 6e e2       	movq   %r10,%xmm4
  409abd:	f3 0f 11 65 e8       	movss  %xmm4,-0x18(%rbp)
  409ac2:	f3 0f 5e c4          	divss  %xmm4,%xmm0
  409ac6:	48 89 c3             	mov    %rax,%rbx
  409ac9:	66 48 0f 7e c0       	movq   %xmm0,%rax
  409ace:	89 c0                	mov    %eax,%eax
  409ad0:	48 89 85 28 ff ff ff 	mov    %rax,-0xd8(%rbp)
  409ad7:	49 89 fc             	mov    %rdi,%r12
  409ada:	e8 41 cb ff ff       	callq  406620 <p113d_FID_36_100_105_114_101_99_116_46_115_121_>
  409adf:	4d 89 f9             	mov    %r15,%r9
  409ae2:	4c 89 ea             	mov    %r13,%rdx
  409ae5:	4c 89 e7             	mov    %r12,%rdi
  409ae8:	48 89 c1             	mov    %rax,%rcx
  409aeb:	48 89 d8             	mov    %rbx,%rax
  409aee:	49 89 d5             	mov    %rdx,%r13
  409af1:	48 8b 55 a8          	mov    -0x58(%rbp),%rdx
  409af5:	f3 0f 10 65 e8       	movss  -0x18(%rbp),%xmm4
  409afa:	4c 8b 55 e0          	mov    -0x20(%rbp),%r10
  409afe:	48 8b b5 50 ff ff ff 	mov    -0xb0(%rbp),%rsi
  409b05:	48 89 95 70 f5 ff ff 	mov    %rdx,-0xa90(%rbp)
  409b0c:	48 89 8d 78 f5 ff ff 	mov    %rcx,-0xa88(%rbp)
  409b13:	66 48 0f 6e c2       	movq   %rdx,%xmm0
  409b18:	f3 0f 11 45 a4       	movss  %xmm0,-0x5c(%rbp)
  409b1d:	f3 0f 10 c8          	movss  %xmm0,%xmm1
  409b21:	66 48 0f 6e c1       	movq   %rcx,%xmm0
  409b26:	0f 57 05 e3 94 02 00 	xorps  0x294e3(%rip),%xmm0        # 433010 <_IO_stdin_used+0x10>
  409b2d:	f3 0f 58 c1          	addss  %xmm1,%xmm0
  409b31:	66 48 0f 7e c1       	movq   %xmm0,%rcx
  409b36:	89 c9                	mov    %ecx,%ecx
  409b38:	48 89 8d 70 f5 ff ff 	mov    %rcx,-0xa90(%rbp)
  409b3f:	4c 89 95 78 f5 ff ff 	mov    %r10,-0xa88(%rbp)
  409b46:	66 48 0f 6e c1       	movq   %rcx,%xmm0
  409b4b:	f3 0f 5e c4          	divss  %xmm4,%xmm0
  409b4f:	48 89 c3             	mov    %rax,%rbx
  409b52:	66 48 0f 7e c0       	movq   %xmm0,%rax
  409b57:	4d 89 cf             	mov    %r9,%r15
  409b5a:	41 89 c1             	mov    %eax,%r9d
  409b5d:	4c 89 8d 30 ff ff ff 	mov    %r9,-0xd0(%rbp)
  409b64:	49 89 fc             	mov    %rdi,%r12
  409b67:	e8 e4 c9 ff ff       	callq  406550 <p113d_FID_36_100_105_114_101_99_116_46_115_122_>
  409b6c:	4d 89 f9             	mov    %r15,%r9
  409b6f:	4c 89 ea             	mov    %r13,%rdx
  409b72:	4c 89 e7             	mov    %r12,%rdi
  409b75:	49 89 c0             	mov    %rax,%r8
  409b78:	48 89 d8             	mov    %rbx,%rax
  409b7b:	4d 89 cf             	mov    %r9,%r15
  409b7e:	4c 8b 4d 80          	mov    -0x80(%rbp),%r9
  409b82:	48 8b 4d a8          	mov    -0x58(%rbp),%rcx
  409b86:	48 8b 75 b0          	mov    -0x50(%rbp),%rsi
  409b8a:	f3 0f 10 4d a4       	movss  -0x5c(%rbp),%xmm1
  409b8f:	f3 0f 10 65 e8       	movss  -0x18(%rbp),%xmm4
  409b94:	f3 0f 10 45 b8       	movss  -0x48(%rbp),%xmm0
  409b99:	4c 8b 55 e0          	mov    -0x20(%rbp),%r10
  409b9d:	4c 89 8d 70 f5 ff ff 	mov    %r9,-0xa90(%rbp)
  409ba4:	4c 89 85 78 f5 ff ff 	mov    %r8,-0xa88(%rbp)
  409bab:	f3 0f 10 d0          	movss  %xmm0,%xmm2
  409baf:	66 49 0f 6e c1       	movq   %r9,%xmm0
  409bb4:	f3 0f 11 85 7c ff ff ff 	movss  %xmm0,-0x84(%rbp)
  409bbc:	66 49 0f 6e d8       	movq   %r8,%xmm3
  409bc1:	0f 57 1d 48 94 02 00 	xorps  0x29448(%rip),%xmm3        # 433010 <_IO_stdin_used+0x10>
  409bc8:	f3 0f 58 d8          	addss  %xmm0,%xmm3
  409bcc:	66 49 0f 7e d8       	movq   %xmm3,%r8
  409bd1:	45 89 c0             	mov    %r8d,%r8d
  409bd4:	4c 89 85 70 f5 ff ff 	mov    %r8,-0xa90(%rbp)
  409bdb:	4c 89 95 78 f5 ff ff 	mov    %r10,-0xa88(%rbp)
  409be2:	66 49 0f 6e d8       	movq   %r8,%xmm3
  409be7:	f3 0f 5e dc          	divss  %xmm4,%xmm3
  409beb:	66 49 0f 7e d8       	movq   %xmm3,%r8
  409bf0:	45 89 c0             	mov    %r8d,%r8d
  409bf3:	4c 89 85 38 ff ff ff 	mov    %r8,-0xc8(%rbp)
  409bfa:	48 c7 85 70 f5 ff ff 00 00 00 00 	movq   $0x0,-0xa90(%rbp)
  409c05:	48 c7 85 70 f5 ff ff 03 00 00 00 	movq   $0x3,-0xa90(%rbp)
  409c10:	48 c7 85 70 f5 ff ff 00 00 00 00 	movq   $0x0,-0xa90(%rbp)
  409c1b:	48 c7 85 78 f5 ff ff 00 00 40 40 	movq   $0x40400000,-0xa88(%rbp)
  409c26:	41 b8 00 00 40 c0    	mov    $0xc0400000,%r8d
  409c2c:	4c 89 85 70 f5 ff ff 	mov    %r8,-0xa90(%rbp)
  409c33:	48 89 b5 78 f5 ff ff 	mov    %rsi,-0xa88(%rbp)
  409c3a:	0f 57 15 cf 93 02 00 	xorps  0x293cf(%rip),%xmm2        # 433010 <_IO_stdin_used+0x10>
  409c41:	f3 0f 58 15 e7 93 02 00 	addss  0x293e7(%rip),%xmm2        # 433030 <_IO_stdin_used+0x30>
  409c49:	66 48 0f 7e d6       	movq   %xmm2,%rsi
  409c4e:	41 89 f0             	mov    %esi,%r8d
  409c51:	4c 89 45 c0          	mov    %r8,-0x40(%rbp)
  409c55:	48 c7 85 70 f5 ff ff 08 00 00 00 	movq   $0x8,-0xa90(%rbp)
  409c60:	48 c7 85 70 f5 ff ff 00 00 00 41 	movq   $0x41000000,-0xa90(%rbp)
  409c6b:	48 89 8d 78 f5 ff ff 	mov    %rcx,-0xa88(%rbp)
  409c72:	0f 57 0d 97 93 02 00 	xorps  0x29397(%rip),%xmm1        # 433010 <_IO_stdin_used+0x10>
  409c79:	f3 0f 58 0d ab 93 02 00 	addss  0x293ab(%rip),%xmm1        # 43302c <_IO_stdin_used+0x2c>
  409c81:	66 48 0f 7e c9       	movq   %xmm1,%rcx
  409c86:	41 89 cb             	mov    %ecx,%r11d
  409c89:	4c 89 5d c8          	mov    %r11,-0x38(%rbp)
  409c8d:	48 c7 85 70 f5 ff ff 01 00 00 00 	movq   $0x1,-0xa90(%rbp)
  409c98:	48 c7 85 70 f5 ff ff 00 00 80 3f 	movq   $0x3f800000,-0xa90(%rbp)
  409ca3:	4c 89 8d 78 f5 ff ff 	mov    %r9,-0xa88(%rbp)
  409caa:	0f 57 05 5f 93 02 00 	xorps  0x2935f(%rip),%xmm0        # 433010 <_IO_stdin_used+0x10>
  409cb1:	f3 0f 58 05 67 93 02 00 	addss  0x29367(%rip),%xmm0        # 433020 <_IO_stdin_used+0x20>
  409cb9:	66 48 0f 7e c1       	movq   %xmm0,%rcx
  409cbe:	89 cb                	mov    %ecx,%ebx
  409cc0:	48 89 5d d0          	mov    %rbx,-0x30(%rbp)
  409cc4:	4c 89 85 70 f5 ff ff 	mov    %r8,-0xa90(%rbp)
  409ccb:	4c 89 85 78 f5 ff ff 	mov    %r8,-0xa88(%rbp)
  409cd2:	66 49 0f 6e d8       	movq   %r8,%xmm3
  409cd7:	f3 0f 11 5d bc       	movss  %xmm3,-0x44(%rbp)
  409cdc:	f3 0f 10 c3          	movss  %xmm3,%xmm0
  409ce0:	f3 0f 59 c3          	mulss  %xmm3,%xmm0
  409ce4:	66 48 0f 7e c1       	movq   %xmm0,%rcx
  409ce9:	89 ce                	mov    %ecx,%esi
  409ceb:	4c 89 9d 70 f5 ff ff 	mov    %r11,-0xa90(%rbp)
  409cf2:	4c 89 9d 78 f5 ff ff 	mov    %r11,-0xa88(%rbp)
  409cf9:	66 49 0f 6e d3       	movq   %r11,%xmm2
  409cfe:	f3 0f 11 55 d8       	movss  %xmm2,-0x28(%rbp)
  409d03:	f3 0f 10 c2          	movss  %xmm2,%xmm0
  409d07:	f3 0f 59 c2          	mulss  %xmm2,%xmm0
  409d0b:	66 48 0f 7e c1       	movq   %xmm0,%rcx
  409d10:	89 c9                	mov    %ecx,%ecx
  409d12:	48 89 b5 70 f5 ff ff 	mov    %rsi,-0xa90(%rbp)
  409d19:	48 89 8d 78 f5 ff ff 	mov    %rcx,-0xa88(%rbp)
  409d20:	66 48 0f 6e c6       	movq   %rsi,%xmm0
  409d25:	66 48 0f 6e c9       	movq   %rcx,%xmm1
  409d2a:	f3 0f 58 c1          	addss  %xmm1,%xmm0
  409d2e:	66 48 0f 7e c1       	movq   %xmm0,%rcx
  409d33:	89 ce                	mov    %ecx,%esi
  409d35:	48 89 9d 70 f5 ff ff 	mov    %rbx,-0xa90(%rbp)
  409d3c:	48 89 9d 78 f5 ff ff 	mov    %rbx,-0xa88(%rbp)
  409d43:	66 48 0f 6e c3       	movq   %rbx,%xmm0
  409d48:	f3 0f 11 45 dc       	movss  %xmm0,-0x24(%rbp)
  409d4d:	f3 0f 59 c0          	mulss  %xmm0,%xmm0
  409d51:	66 48 0f 7e c1       	movq   %xmm0,%rcx
  409d56:	89 c9                	mov    %ecx,%ecx
  409d58:	48 89 b5 70 f5 ff ff 	mov    %rsi,-0xa90(%rbp)
  409d5f:	48 89 8d 78 f5 ff ff 	mov    %rcx,-0xa88(%rbp)
  409d66:	66 48 0f 6e c6       	movq   %rsi,%xmm0
  409d6b:	66 48 0f 6e c9       	movq   %rcx,%xmm1
  409d70:	f3 0f 58 c1          	addss  %xmm1,%xmm0
  409d74:	48 89 c3             	mov    %rax,%rbx
  409d77:	66 48 0f 7e c0       	movq   %xmm0,%rax
  409d7c:	89 c0                	mov    %eax,%eax
  409d7e:	48 89 85 70 f5 ff ff 	mov    %rax,-0xa90(%rbp)
  409d85:	b9 01 00 00 00       	mov    $0x1,%ecx
  409d8a:	49 89 d5             	mov    %rdx,%r13
  409d8d:	48 8d 95 70 f5 ff ff 	lea    -0xa90(%rbp),%rdx
  409d94:	be 24 00 00 00       	mov    $0x24,%esi
  409d99:	49 89 fc             	mov    %rdi,%r12
  409d9c:	e8 7f 30 02 00       	callq  42ce20 <p111_rt_op>
  409da1:	4d 89 f9             	mov    %r15,%r9
  409da4:	4c 89 ea             	mov    %r13,%rdx
  409da7:	4c 89 e7             	mov    %r12,%rdi
  409daa:	49 89 c2             	mov    %rax,%r10
  409dad:	48 89 d8             	mov    %rbx,%rax
  409db0:	48 8b 5d d0          	mov    -0x30(%rbp),%rbx
  409db4:	4c 8b 5d c8          	mov    -0x38(%rbp),%r11
  409db8:	4c 8b 45 c0          	mov    -0x40(%rbp),%r8
  409dbc:	48 8b 8d 38 ff ff ff 	mov    -0xc8(%rbp),%rcx
  409dc3:	4d 89 cf             	mov    %r9,%r15
  409dc6:	4c 8b 8d 30 ff ff ff 	mov    -0xd0(%rbp),%r9
  409dcd:	48 8b b5 28 ff ff ff 	mov    -0xd8(%rbp),%rsi
  409dd4:	f3 0f 10 45 dc       	movss  -0x24(%rbp),%xmm0
  409dd9:	f3 0f 10 55 d8       	movss  -0x28(%rbp),%xmm2
  409dde:	f3 0f 10 5d bc       	movss  -0x44(%rbp),%xmm3
  409de3:	4c 89 85 70 f5 ff ff 	mov    %r8,-0xa90(%rbp)
  409dea:	4c 89 95 78 f5 ff ff 	mov    %r10,-0xa88(%rbp)
  409df1:	66 49 0f 6e ca       	movq   %r10,%xmm1
  409df6:	f3 0f 11 8d 78 ff ff ff 	movss  %xmm1,-0x88(%rbp)
  409dfe:	f3 0f 5e d9          	divss  %xmm1,%xmm3
  409e02:	66 49 0f 7e d8       	movq   %xmm3,%r8
  409e07:	45 89 c0             	mov    %r8d,%r8d
  409e0a:	4c 89 9d 70 f5 ff ff 	mov    %r11,-0xa90(%rbp)
  409e11:	4c 89 95 78 f5 ff ff 	mov    %r10,-0xa88(%rbp)
  409e18:	f3 0f 5e d1          	divss  %xmm1,%xmm2
  409e1c:	49 89 f3             	mov    %rsi,%r11
  409e1f:	66 48 0f 7e d6       	movq   %xmm2,%rsi
  409e24:	89 f6                	mov    %esi,%esi
  409e26:	48 89 9d 70 f5 ff ff 	mov    %rbx,-0xa90(%rbp)
  409e2d:	4c 89 95 78 f5 ff ff 	mov    %r10,-0xa88(%rbp)
  409e34:	f3 0f 5e c1          	divss  %xmm1,%xmm0
  409e38:	49 89 ca             	mov    %rcx,%r10
  409e3b:	66 48 0f 7e c1       	movq   %xmm0,%rcx
  409e40:	89 c9                	mov    %ecx,%ecx
  409e42:	4c 89 9d 70 f5 ff ff 	mov    %r11,-0xa90(%rbp)
  409e49:	4c 89 85 78 f5 ff ff 	mov    %r8,-0xa88(%rbp)
  409e50:	66 4d 0f 6e cb       	movq   %r11,%xmm9
  409e55:	f3 44 0f 11 8d 24 ff ff ff 	movss  %xmm9,-0xdc(%rbp)
  409e5e:	66 49 0f 6e d8       	movq   %r8,%xmm3
  409e63:	f3 0f 11 5d 98       	movss  %xmm3,-0x68(%rbp)
  409e68:	f3 41 0f 10 c1       	movss  %xmm9,%xmm0
  409e6d:	f3 0f 59 c3          	mulss  %xmm3,%xmm0
  409e71:	66 49 0f 7e c0       	movq   %xmm0,%r8
  409e76:	45 89 c0             	mov    %r8d,%r8d
  409e79:	4c 89 8d 70 f5 ff ff 	mov    %r9,-0xa90(%rbp)
  409e80:	48 89 b5 78 f5 ff ff 	mov    %rsi,-0xa88(%rbp)
  409e87:	66 49 0f 6e f9       	movq   %r9,%xmm7
  409e8c:	f3 0f 11 bd 48 ff ff ff 	movss  %xmm7,-0xb8(%rbp)
  409e94:	66 48 0f 6e e6       	movq   %rsi,%xmm4
  409e99:	f3 0f 11 65 9c       	movss  %xmm4,-0x64(%rbp)
  409e9e:	f3 0f 10 c7          	movss  %xmm7,%xmm0
  409ea2:	f3 0f 59 c4          	mulss  %xmm4,%xmm0
  409ea6:	66 48 0f 7e c6       	movq   %xmm0,%rsi
  409eab:	89 f6                	mov    %esi,%esi
  409ead:	4c 89 85 70 f5 ff ff 	mov    %r8,-0xa90(%rbp)
  409eb4:	48 89 b5 78 f5 ff ff 	mov    %rsi,-0xa88(%rbp)
  409ebb:	66 49 0f 6e c0       	movq   %r8,%xmm0
  409ec0:	66 48 0f 6e ce       	movq   %rsi,%xmm1
  409ec5:	f3 0f 58 c1          	addss  %xmm1,%xmm0
  409ec9:	49 89 d5             	mov    %rdx,%r13
  409ecc:	66 48 0f 7e c2       	movq   %xmm0,%rdx
  409ed1:	89 d2                	mov    %edx,%edx
  409ed3:	4c 89 95 70 f5 ff ff 	mov    %r10,-0xa90(%rbp)
  409eda:	48 89 8d 78 f5 ff ff 	mov    %rcx,-0xa88(%rbp)
  409ee1:	66 49 0f 6e ca       	movq   %r10,%xmm1
  409ee6:	f3 0f 11 8d 4c ff ff ff 	movss  %xmm1,-0xb4(%rbp)
  409eee:	66 48 0f 6e e9       	movq   %rcx,%xmm5
  409ef3:	f3 0f 11 6d a0       	movss  %xmm5,-0x60(%rbp)
  409ef8:	f3 0f 10 c1          	movss  %xmm1,%xmm0
  409efc:	f3 0f 59 c5          	mulss  %xmm5,%xmm0
  409f00:	66 48 0f 7e c1       	movq   %xmm0,%rcx
  409f05:	89 c9                	mov    %ecx,%ecx
  409f07:	48 89 95 70 f5 ff ff 	mov    %rdx,-0xa90(%rbp)
  409f0e:	48 89 8d 78 f5 ff ff 	mov    %rcx,-0xa88(%rbp)
  409f15:	66 48 0f 6e c2       	movq   %rdx,%xmm0
  409f1a:	66 48 0f 6e c9       	movq   %rcx,%xmm1
  409f1f:	f3 0f 58 c1          	addss  %xmm1,%xmm0
  409f23:	48 89 c3             	mov    %rax,%rbx
  409f26:	66 48 0f 7e c0       	movq   %xmm0,%rax
  409f2b:	89 c6                	mov    %eax,%esi
  409f2d:	49 89 fc             	mov    %rdi,%r12
  409f30:	e8 8b bd ff ff       	callq  405cc0 <p113d_FID_36_100_105_114_101_99_116_46_102_109_97_120_48_>
  409f35:	4c 89 e7             	mov    %r12,%rdi
  409f38:	48 89 85 68 ff ff ff 	mov    %rax,-0x98(%rbp)
  409f3f:	f3 0f 10 0d fd 90 02 00 	movss  0x290fd(%rip),%xmm1        # 433044 <_IO_stdin_used+0x44>
  409f47:	f3 0f 10 05 ed 90 02 00 	movss  0x290ed(%rip),%xmm0        # 43303c <_IO_stdin_used+0x3c>
  409f4f:	49 89 fc             	mov    %rdi,%r12
  409f52:	e8 f9 bd ff ff       	callq  405d50 <p126_typed_FID_36_100_105_114_101_99_116_46_102_108_>
  409f57:	4c 89 ea             	mov    %r13,%rdx
  409f5a:	4c 89 e7             	mov    %r12,%rdi
  409f5d:	48 89 c1             	mov    %rax,%rcx
  409f60:	48 89 d8             	mov    %rbx,%rax
  409f63:	48 8b b5 28 ff ff ff 	mov    -0xd8(%rbp),%rsi
  409f6a:	49 89 d5             	mov    %rdx,%r13
  409f6d:	48 8b 55 b0          	mov    -0x50(%rbp),%rdx
  409f71:	f3 44 0f 10 8d 24 ff ff ff 	movss  -0xdc(%rbp),%xmm9
  409f7a:	f3 0f 10 45 b8       	movss  -0x48(%rbp),%xmm0
  409f7f:	48 89 8d 70 f5 ff ff 	mov    %rcx,-0xa90(%rbp)
  409f86:	48 89 b5 78 f5 ff ff 	mov    %rsi,-0xa88(%rbp)
  409f8d:	66 48 0f 6e c9       	movq   %rcx,%xmm1
  409f92:	f3 41 0f 59 c9       	mulss  %xmm9,%xmm1
  409f97:	66 48 0f 7e c9       	movq   %xmm1,%rcx
  409f9c:	89 c9                	mov    %ecx,%ecx
  409f9e:	48 89 95 70 f5 ff ff 	mov    %rdx,-0xa90(%rbp)
  409fa5:	48 89 8d 78 f5 ff ff 	mov    %rcx,-0xa88(%rbp)
  409fac:	66 48 0f 6e c9       	movq   %rcx,%xmm1
  409fb1:	f3 0f 58 c1          	addss  %xmm1,%xmm0
  409fb5:	48 89 c3             	mov    %rax,%rbx
  409fb8:	66 48 0f 7e c0       	movq   %xmm0,%rax
  409fbd:	89 c6                	mov    %eax,%esi
  409fbf:	48 89 75 88          	mov    %rsi,-0x78(%rbp)
  409fc3:	f3 0f 10 0d 79 90 02 00 	movss  0x29079(%rip),%xmm1        # 433044 <_IO_stdin_used+0x44>
  409fcb:	f3 0f 10 05 69 90 02 00 	movss  0x29069(%rip),%xmm0        # 43303c <_IO_stdin_used+0x3c>
  409fd3:	49 89 fc             	mov    %rdi,%r12
  409fd6:	e8 75 bd ff ff       	callq  405d50 <p126_typed_FID_36_100_105_114_101_99_116_46_102_108_>
  409fdb:	4d 89 f9             	mov    %r15,%r9
  409fde:	4c 89 ea             	mov    %r13,%rdx
  409fe1:	4c 89 e7             	mov    %r12,%rdi
  409fe4:	48 89 c1             	mov    %rax,%rcx
  409fe7:	48 89 d8             	mov    %rbx,%rax
  409fea:	4d 89 cf             	mov    %r9,%r15
  409fed:	4c 8b 8d 30 ff ff ff 	mov    -0xd0(%rbp),%r9
  409ff4:	49 89 d5             	mov    %rdx,%r13
  409ff7:	48 8b 55 a8          	mov    -0x58(%rbp),%rdx
  409ffb:	f3 0f 10 bd 48 ff ff ff 	movss  -0xb8(%rbp),%xmm7
  40a003:	f3 0f 10 45 a4       	movss  -0x5c(%rbp),%xmm0
  40a008:	48 89 8d 70 f5 ff ff 	mov    %rcx,-0xa90(%rbp)
  40a00f:	4c 89 8d 78 f5 ff ff 	mov    %r9,-0xa88(%rbp)
  40a016:	66 48 0f 6e c9       	movq   %rcx,%xmm1
  40a01b:	f3 0f 59 cf          	mulss  %xmm7,%xmm1
  40a01f:	66 48 0f 7e c9       	movq   %xmm1,%rcx
  40a024:	89 c9                	mov    %ecx,%ecx
  40a026:	48 89 95 70 f5 ff ff 	mov    %rdx,-0xa90(%rbp)
  40a02d:	48 89 8d 78 f5 ff ff 	mov    %rcx,-0xa88(%rbp)
  40a034:	66 48 0f 6e c9       	movq   %rcx,%xmm1
  40a039:	f3 0f 58 c1          	addss  %xmm1,%xmm0
  40a03d:	48 89 c3             	mov    %rax,%rbx
  40a040:	66 48 0f 7e c0       	movq   %xmm0,%rax
  40a045:	89 c1                	mov    %eax,%ecx
  40a047:	48 89 4d 90          	mov    %rcx,-0x70(%rbp)
  40a04b:	f3 0f 10 0d f1 8f 02 00 	movss  0x28ff1(%rip),%xmm1        # 433044 <_IO_stdin_used+0x44>
  40a053:	f3 0f 10 05 e1 8f 02 00 	movss  0x28fe1(%rip),%xmm0        # 43303c <_IO_stdin_used+0x3c>
  40a05b:	49 89 fc             	mov    %rdi,%r12
  40a05e:	e8 ed bc ff ff       	callq  405d50 <p126_typed_FID_36_100_105_114_101_99_116_46_102_108_>
  40a063:	4d 89 f9             	mov    %r15,%r9
  40a066:	4c 89 ea             	mov    %r13,%rdx
  40a069:	4c 89 e7             	mov    %r12,%rdi
  40a06c:	49 89 c0             	mov    %rax,%r8
  40a06f:	48 89 d8             	mov    %rbx,%rax
  40a072:	48 8b 4d 90          	mov    -0x70(%rbp),%rcx
  40a076:	48 8b 75 88          	mov    -0x78(%rbp),%rsi
  40a07a:	4c 8b 95 38 ff ff ff 	mov    -0xc8(%rbp),%r10
  40a081:	4d 89 cf             	mov    %r9,%r15
  40a084:	4c 8b 4d 80          	mov    -0x80(%rbp),%r9
  40a088:	f3 0f 10 6d a0       	movss  -0x60(%rbp),%xmm5
  40a08d:	f3 0f 10 8d 4c ff ff ff 	movss  -0xb4(%rbp),%xmm1
  40a095:	f3 0f 10 65 9c       	movss  -0x64(%rbp),%xmm4
  40a09a:	f3 0f 10 5d 98       	movss  -0x68(%rbp),%xmm3
  40a09f:	f3 0f 10 85 7c ff ff ff 	movss  -0x84(%rbp),%xmm0
  40a0a7:	4c 89 85 70 f5 ff ff 	mov    %r8,-0xa90(%rbp)
  40a0ae:	4c 89 95 78 f5 ff ff 	mov    %r10,-0xa88(%rbp)
  40a0b5:	66 49 0f 6e d0       	movq   %r8,%xmm2
  40a0ba:	f3 0f 59 ca          	mulss  %xmm2,%xmm1
  40a0be:	66 49 0f 7e c8       	movq   %xmm1,%r8
  40a0c3:	45 89 c0             	mov    %r8d,%r8d
  40a0c6:	4c 89 8d 70 f5 ff ff 	mov    %r9,-0xa90(%rbp)
  40a0cd:	4c 89 85 78 f5 ff ff 	mov    %r8,-0xa88(%rbp)
  40a0d4:	66 49 0f 6e c8       	movq   %r8,%xmm1
  40a0d9:	f3 0f 58 c1          	addss  %xmm1,%xmm0
  40a0dd:	48 89 c3             	mov    %rax,%rbx
  40a0e0:	66 48 0f 7e c0       	movq   %xmm0,%rax
  40a0e5:	89 c0                	mov    %eax,%eax
  40a0e7:	48 c7 85 70 f5 ff ff 00 ca 9a 3b 	movq   $0x3b9aca00,-0xa90(%rbp)
  40a0f2:	48 c7 85 70 f5 ff ff 00 ca 9a 3b 	movq   $0x3b9aca00,-0xa90(%rbp)
  40a0fd:	66 48 0f 6e c6       	movq   %rsi,%xmm0
  40a102:	f3 0f 11 85 04 ff ff ff 	movss  %xmm0,-0xfc(%rbp)
  40a10a:	66 48 0f 6e d1       	movq   %rcx,%xmm2
  40a10f:	f3 0f 11 95 10 ff ff ff 	movss  %xmm2,-0xf0(%rbp)
  40a117:	f3 0f 10 ca          	movss  %xmm2,%xmm1
  40a11b:	66 48 0f 6e d0       	movq   %rax,%xmm2
  40a120:	f3 0f 11 95 14 ff ff ff 	movss  %xmm2,-0xec(%rbp)
  40a128:	41 b8 00 00 00 00    	mov    $0x0,%r8d
  40a12e:	b9 28 6b 6e 4e       	mov    $0x4e6e6b28,%ecx
  40a133:	49 89 d5             	mov    %rdx,%r13
  40a136:	ba 28 6b 6e 4e       	mov    $0x4e6e6b28,%edx
  40a13b:	be 09 00 00 00       	mov    $0x9,%esi
  40a140:	49 89 fc             	mov    %rdi,%r12
  40a143:	e8 98 cd ff ff       	callq  406ee0 <p126_typed_FID_36_100_105_114_101_99_116_46_110_101_97_114_101_115_116_46_116_>
  40a148:	4c 89 e7             	mov    %r12,%rdi
  40a14b:	48 89 85 70 ff ff ff 	mov    %rax,-0x90(%rbp)
  40a152:	f3 0f 10 0d e6 8e 02 00 	movss  0x28ee6(%rip),%xmm1        # 433040 <_IO_stdin_used+0x40>
  40a15a:	f3 0f 10 05 da 8e 02 00 	movss  0x28eda(%rip),%xmm0        # 43303c <_IO_stdin_used+0x3c>
  40a162:	49 89 fc             	mov    %rdi,%r12
  40a165:	e8 e6 bb ff ff       	callq  405d50 <p126_typed_FID_36_100_105_114_101_99_116_46_102_108_>
  40a16a:	4c 89 e7             	mov    %r12,%rdi
  40a16d:	48 89 85 58 ff ff ff 	mov    %rax,-0xa8(%rbp)
  40a174:	f3 0f 10 0d bc 8e 02 00 	movss  0x28ebc(%rip),%xmm1        # 433038 <_IO_stdin_used+0x38>
  40a17c:	f3 0f 10 05 b0 8e 02 00 	movss  0x28eb0(%rip),%xmm0        # 433034 <_IO_stdin_used+0x34>
  40a184:	49 89 fc             	mov    %rdi,%r12
  40a187:	e8 c4 bb ff ff       	callq  405d50 <p126_typed_FID_36_100_105_114_101_99_116_46_102_108_>
  40a18c:	4c 89 e7             	mov    %r12,%rdi
  40a18f:	48 89 85 60 ff ff ff 	mov    %rax,-0xa0(%rbp)
  40a196:	48 89 d8             	mov    %rbx,%rax
  40a199:	48 89 c3             	mov    %rax,%rbx
  40a19c:	48 8b 85 70 ff ff ff 	mov    -0x90(%rbp),%rax
  40a1a3:	48 8b b5 68 ff ff ff 	mov    -0x98(%rbp),%rsi
  40a1aa:	f3 0f 10 8d 78 ff ff ff 	movss  -0x88(%rbp),%xmm1
  40a1b2:	66 48 0f 6e c0       	movq   %rax,%xmm0
  40a1b7:	49 89 fc             	mov    %rdi,%r12
  40a1ba:	e8 61 c2 ff ff       	callq  406420 <p126_typed_FID_36_100_105_114_101_99_116_46_115_104_97_100_101_>
  40a1bf:	4c 89 ea             	mov    %r13,%rdx
  40a1c2:	4c 89 e7             	mov    %r12,%rdi
  40a1c5:	48 89 c1             	mov    %rax,%rcx
  40a1c8:	48 89 d8             	mov    %rbx,%rax
  40a1cb:	4c 8b 85 60 ff ff ff 	mov    -0xa0(%rbp),%r8
  40a1d2:	49 89 d5             	mov    %rdx,%r13
  40a1d5:	48 8b 95 58 ff ff ff 	mov    -0xa8(%rbp),%rdx
  40a1dc:	48 8b b5 50 ff ff ff 	mov    -0xb0(%rbp),%rsi
  40a1e3:	4c 89 85 70 f5 ff ff 	mov    %r8,-0xa90(%rbp)
  40a1ea:	48 89 8d 78 f5 ff ff 	mov    %rcx,-0xa88(%rbp)
  40a1f1:	66 49 0f 6e c0       	movq   %r8,%xmm0
  40a1f6:	66 48 0f 6e c9       	movq   %rcx,%xmm1
  40a1fb:	f3 0f 59 c1          	mulss  %xmm1,%xmm0
  40a1ff:	66 48 0f 7e c1       	movq   %xmm0,%rcx
  40a204:	89 c9                	mov    %ecx,%ecx
  40a206:	48 89 95 70 f5 ff ff 	mov    %rdx,-0xa90(%rbp)
  40a20d:	48 89 8d 78 f5 ff ff 	mov    %rcx,-0xa88(%rbp)
  40a214:	66 48 0f 6e c2       	movq   %rdx,%xmm0
  40a219:	66 48 0f 6e c9       	movq   %rcx,%xmm1
  40a21e:	f3 0f 58 c1          	addss  %xmm1,%xmm0
  40a222:	48 89 c3             	mov    %rax,%rbx
  40a225:	66 48 0f 7e c0       	movq   %xmm0,%rax
  40a22a:	41 89 c0             	mov    %eax,%r8d
  40a22d:	4c 89 85 08 ff ff ff 	mov    %r8,-0xf8(%rbp)
  40a234:	49 89 fc             	mov    %rdi,%r12
  40a237:	e8 f4 c0 ff ff       	callq  406330 <p113d_FID_36_100_105_114_101_99_116_46_115_107_114_>
  40a23c:	4d 89 f9             	mov    %r15,%r9
  40a23f:	4c 89 ea             	mov    %r13,%rdx
  40a242:	4c 89 e7             	mov    %r12,%rdi
  40a245:	49 89 c4             	mov    %rax,%r12
  40a248:	48 89 d8             	mov    %rbx,%rax
  40a24b:	48 8b 8d 38 ff ff ff 	mov    -0xc8(%rbp),%rcx
  40a252:	4d 89 cf             	mov    %r9,%r15
  40a255:	4c 8b 8d 30 ff ff ff 	mov    -0xd0(%rbp),%r9
  40a25c:	48 8b b5 28 ff ff ff 	mov    -0xd8(%rbp),%rsi
  40a263:	f3 0f 10 9d 14 ff ff ff 	movss  -0xec(%rbp),%xmm3
  40a26b:	f3 0f 10 95 10 ff ff ff 	movss  -0xf0(%rbp),%xmm2
  40a273:	f3 0f 10 8d 04 ff ff ff 	movss  -0xfc(%rbp),%xmm1
  40a27b:	f3 0f 10 c1          	movss  %xmm1,%xmm0
  40a27f:	f3 0f 10 8d 4c ff ff ff 	movss  -0xb4(%rbp),%xmm1
  40a287:	f3 0f 10 bd 48 ff ff ff 	movss  -0xb8(%rbp),%xmm7
  40a28f:	f3 44 0f 10 8d 24 ff ff ff 	movss  -0xdc(%rbp),%xmm9
  40a298:	f3 0f 10 a5 f4 fe ff ff 	movss  -0x10c(%rbp),%xmm4
  40a2a0:	f3 0f 10 ad f0 fe ff ff 	movss  -0x110(%rbp),%xmm5
  40a2a8:	f3 0f 10 b5 e4 fe ff ff 	movss  -0x11c(%rbp),%xmm6
  40a2b0:	48 8b 9d e8 fe ff ff 	mov    -0x118(%rbp),%rbx
  40a2b7:	49 89 dd             	mov    %rbx,%r13
  40a2ba:	48 8b 9d 40 ff ff ff 	mov    -0xc0(%rbp),%rbx
  40a2c1:	48 c7 85 70 f5 ff ff 02 00 00 00 	movq   $0x2,-0xa90(%rbp)
  40a2cc:	4c 89 bd 70 f5 ff ff 	mov    %r15,-0xa90(%rbp)
  40a2d3:	48 89 b5 78 f5 ff ff 	mov    %rsi,-0xa88(%rbp)
  40a2da:	f3 44 0f 10 c6       	movss  %xmm6,%xmm8
  40a2df:	f3 45 0f 59 c1       	mulss  %xmm9,%xmm8
  40a2e4:	66 4d 0f 7e c0       	movq   %xmm8,%r8
  40a2e9:	45 89 c2             	mov    %r8d,%r10d
  40a2ec:	48 89 95 70 f5 ff ff 	mov    %rdx,-0xa90(%rbp)
  40a2f3:	4c 89 8d 78 f5 ff ff 	mov    %r9,-0xa88(%rbp)
  40a2fa:	f3 44 0f 10 c5       	movss  %xmm5,%xmm8
  40a2ff:	f3 44 0f 59 c7       	mulss  %xmm7,%xmm8
  40a304:	66 4d 0f 7e c0       	movq   %xmm8,%r8
  40a309:	45 89 c0             	mov    %r8d,%r8d
  40a30c:	4c 89 95 70 f5 ff ff 	mov    %r10,-0xa90(%rbp)
  40a313:	4c 89 85 78 f5 ff ff 	mov    %r8,-0xa88(%rbp)
  40a31a:	66 4d 0f 6e c2       	movq   %r10,%xmm8
  40a31f:	66 4d 0f 6e d0       	movq   %r8,%xmm10
  40a324:	f3 45 0f 58 c2       	addss  %xmm10,%xmm8
  40a329:	66 4d 0f 7e c0       	movq   %xmm8,%r8
  40a32e:	45 89 c2             	mov    %r8d,%r10d
  40a331:	4c 89 b5 70 f5 ff ff 	mov    %r14,-0xa90(%rbp)
  40a338:	48 89 8d 78 f5 ff ff 	mov    %rcx,-0xa88(%rbp)
  40a33f:	f3 44 0f 10 c4       	movss  %xmm4,%xmm8
  40a344:	f3 44 0f 59 c1       	mulss  %xmm1,%xmm8
  40a349:	66 4d 0f 7e c0       	movq   %xmm8,%r8
  40a34e:	45 89 c0             	mov    %r8d,%r8d
  40a351:	4c 89 95 70 f5 ff ff 	mov    %r10,-0xa90(%rbp)
  40a358:	4c 89 85 78 f5 ff ff 	mov    %r8,-0xa88(%rbp)
  40a35f:	66 4d 0f 6e c2       	movq   %r10,%xmm8
  40a364:	66 4d 0f 6e d0       	movq   %r8,%xmm10
  40a369:	f3 45 0f 58 c2       	addss  %xmm10,%xmm8
  40a36e:	66 4d 0f 7e c0       	movq   %xmm8,%r8
  40a373:	45 89 c0             	mov    %r8d,%r8d
  40a376:	48 c7 85 70 f5 ff ff 00 00 00 40 	movq   $0x40000000,-0xa90(%rbp)
  40a381:	4c 89 85 78 f5 ff ff 	mov    %r8,-0xa88(%rbp)
  40a388:	f3 44 0f 10 c6       	movss  %xmm6,%xmm8
  40a38d:	66 49 0f 6e f0       	movq   %r8,%xmm6
  40a392:	f3 0f 59 35 ae 8c 02 00 	mulss  0x28cae(%rip),%xmm6        # 433048 <_IO_stdin_used+0x48>
  40a39a:	66 49 0f 7e f0       	movq   %xmm6,%r8
  40a39f:	45 89 c0             	mov    %r8d,%r8d
  40a3a2:	4c 89 85 70 f5 ff ff 	mov    %r8,-0xa90(%rbp)
  40a3a9:	48 89 b5 78 f5 ff ff 	mov    %rsi,-0xa88(%rbp)
  40a3b0:	f3 0f 10 f5          	movss  %xmm5,%xmm6
  40a3b4:	66 49 0f 6e e8       	movq   %r8,%xmm5
  40a3b9:	f3 44 0f 59 cd       	mulss  %xmm5,%xmm9
  40a3be:	66 4c 0f 7e ce       	movq   %xmm9,%rsi
  40a3c3:	89 f6                	mov    %esi,%esi
  40a3c5:	4c 89 bd 70 f5 ff ff 	mov    %r15,-0xa90(%rbp)
  40a3cc:	48 89 b5 78 f5 ff ff 	mov    %rsi,-0xa88(%rbp)
  40a3d3:	66 4c 0f 6e ce       	movq   %rsi,%xmm9
  40a3d8:	f3 45 0f 5c c1       	subss  %xmm9,%xmm8
  40a3dd:	66 4c 0f 7e c6       	movq   %xmm8,%rsi
  40a3e2:	89 f6                	mov    %esi,%esi
  40a3e4:	4c 89 85 70 f5 ff ff 	mov    %r8,-0xa90(%rbp)
  40a3eb:	4c 89 8d 78 f5 ff ff 	mov    %r9,-0xa88(%rbp)
  40a3f2:	f3 0f 59 fd          	mulss  %xmm5,%xmm7
  40a3f6:	49 89 d7             	mov    %rdx,%r15
  40a3f9:	66 48 0f 7e fa       	movq   %xmm7,%rdx
  40a3fe:	89 d2                	mov    %edx,%edx
  40a400:	4c 89 bd 70 f5 ff ff 	mov    %r15,-0xa90(%rbp)
  40a407:	48 89 95 78 f5 ff ff 	mov    %rdx,-0xa88(%rbp)
  40a40e:	66 48 0f 6e fa       	movq   %rdx,%xmm7
  40a413:	f3 0f 5c f7          	subss  %xmm7,%xmm6
  40a417:	66 48 0f 7e f2       	movq   %xmm6,%rdx
  40a41c:	89 d2                	mov    %edx,%edx
  40a41e:	4c 89 85 70 f5 ff ff 	mov    %r8,-0xa90(%rbp)
  40a425:	48 89 8d 78 f5 ff ff 	mov    %rcx,-0xa88(%rbp)
  40a42c:	f3 0f 59 cd          	mulss  %xmm5,%xmm1
  40a430:	66 48 0f 7e c9       	movq   %xmm1,%rcx
  40a435:	89 c9                	mov    %ecx,%ecx
  40a437:	4c 89 b5 70 f5 ff ff 	mov    %r14,-0xa90(%rbp)
  40a43e:	48 89 8d 78 f5 ff ff 	mov    %rcx,-0xa88(%rbp)
  40a445:	f3 0f 10 ca          	movss  %xmm2,%xmm1
  40a449:	66 48 0f 6e d1       	movq   %rcx,%xmm2
  40a44e:	0f 57 15 bb 8b 02 00 	xorps  0x28bbb(%rip),%xmm2        # 433010 <_IO_stdin_used+0x10>
  40a455:	f3 0f 58 d4          	addss  %xmm4,%xmm2
  40a459:	66 48 0f 7e d1       	movq   %xmm2,%rcx
  40a45e:	89 c9                	mov    %ecx,%ecx
  40a460:	48 c7 85 70 f5 ff ff 00 ca 9a 3b 	movq   $0x3b9aca00,-0xa90(%rbp)
  40a46b:	48 c7 85 70 f5 ff ff 00 ca 9a 3b 	movq   $0x3b9aca00,-0xa90(%rbp)
  40a476:	f3 0f 10 d3          	movss  %xmm3,%xmm2
  40a47a:	66 48 0f 6e de       	movq   %rsi,%xmm3
  40a47f:	f3 0f 11 9d 18 ff ff ff 	movss  %xmm3,-0xe8(%rbp)
  40a487:	66 48 0f 6e ea       	movq   %rdx,%xmm5
  40a48c:	f3 0f 11 ad 1c ff ff ff 	movss  %xmm5,-0xe4(%rbp)
  40a494:	66 48 0f 6e f1       	movq   %rcx,%xmm6
  40a499:	f3 0f 11 b5 20 ff ff ff 	movss  %xmm6,-0xe0(%rbp)
  40a4a1:	49 89 c6             	mov    %rax,%r14
  40a4a4:	48 83 ec 10          	sub    $0x10,%rsp
  40a4a8:	48 89 e0             	mov    %rsp,%rax
  40a4ab:	48 c7 40 08 00 00 00 00 	movq   $0x0,0x8(%rax)
  40a4b3:	48 c7 00 09 00 00 00 	movq   $0x9,(%rax)
  40a4ba:	41 b9 28 6b 6e 4e    	mov    $0x4e6e6b28,%r9d
  40a4c0:	41 b8 09 00 00 00    	mov    $0x9,%r8d
  40a4c6:	b9 28 6b 6e 4e       	mov    $0x4e6e6b28,%ecx
  40a4cb:	f3 0f 10 e5          	movss  %xmm5,%xmm4
  40a4cf:	f3 0f 10 ee          	movss  %xmm6,%xmm5
  40a4d3:	ba 09 00 00 00       	mov    $0x9,%edx
  40a4d8:	48 8d b5 70 fd ff ff 	lea    -0x290(%rbp),%rsi
  40a4df:	49 89 ff             	mov    %rdi,%r15
  40a4e2:	e8 59 c3 ff ff       	callq  406840 <p126_typed_FID_36_112_114_111_100_117_99_116_46_110_101_97_114_101_115_116_>
  40a4e7:	4c 89 ff             	mov    %r15,%rdi
  40a4ea:	4c 89 f0             	mov    %r14,%rax
  40a4ed:	4c 8b 85 08 ff ff ff 	mov    -0xf8(%rbp),%r8
  40a4f4:	f3 0f 10 8d b4 fd ff ff 	movss  -0x24c(%rbp),%xmm1
  40a4fc:	f3 0f 10 95 b0 fd ff ff 	movss  -0x250(%rbp),%xmm2
  40a504:	f3 0f 10 b5 20 ff ff ff 	movss  -0xe0(%rbp),%xmm6
  40a50c:	f3 0f 10 ad 1c ff ff ff 	movss  -0xe4(%rbp),%xmm5
  40a514:	f3 0f 10 a5 18 ff ff ff 	movss  -0xe8(%rbp),%xmm4
  40a51c:	f3 0f 10 9d 14 ff ff ff 	movss  -0xec(%rbp),%xmm3
  40a524:	f3 0f 10 c2          	movss  %xmm2,%xmm0
  40a528:	f3 0f 10 95 10 ff ff ff 	movss  -0xf0(%rbp),%xmm2
  40a530:	f3 44 0f 10 c1       	movss  %xmm1,%xmm8
  40a535:	f3 0f 10 8d 04 ff ff ff 	movss  -0xfc(%rbp),%xmm1
  40a53d:	48 83 ec f0          	sub    $0xfffffffffffffff0,%rsp
  40a541:	48 8b 95 70 fd ff ff 	mov    -0x290(%rbp),%rdx
  40a548:	48 8b b5 78 fd ff ff 	mov    -0x288(%rbp),%rsi
  40a54f:	48 8b 8d 80 fd ff ff 	mov    -0x280(%rbp),%rcx
  40a556:	4c 89 ad 70 f5 ff ff 	mov    %r13,-0xa90(%rbp)
  40a55d:	4c 89 85 78 f5 ff ff 	mov    %r8,-0xa88(%rbp)
  40a564:	66 49 0f 6e f8       	movq   %r8,%xmm7
  40a569:	f3 0f 59 f8          	mulss  %xmm0,%xmm7
  40a56d:	66 49 0f 7e f8       	movq   %xmm7,%r8
  40a572:	45 89 c1             	mov    %r8d,%r9d
  40a575:	48 c7 85 70 f5 ff ff 01 00 00 00 	movq   $0x1,-0xa90(%rbp)
  40a580:	48 c7 85 70 f5 ff ff 00 00 80 3f 	movq   $0x3f800000,-0xa90(%rbp)
  40a58b:	4c 89 a5 78 f5 ff ff 	mov    %r12,-0xa88(%rbp)
  40a592:	66 49 0f 6e fc       	movq   %r12,%xmm7
  40a597:	f3 44 0f 10 0d 80 8a 02 00 	movss  0x28a80(%rip),%xmm9        # 433020 <_IO_stdin_used+0x20>
  40a5a0:	f3 44 0f 5c cf       	subss  %xmm7,%xmm9
  40a5a5:	66 4d 0f 7e c8       	movq   %xmm9,%r8
  40a5aa:	45 89 c0             	mov    %r8d,%r8d
  40a5ad:	4c 89 8d 70 f5 ff ff 	mov    %r9,-0xa90(%rbp)
  40a5b4:	4c 89 85 78 f5 ff ff 	mov    %r8,-0xa88(%rbp)
  40a5bb:	66 4d 0f 6e c9       	movq   %r9,%xmm9
  40a5c0:	66 4d 0f 6e d0       	movq   %r8,%xmm10
  40a5c5:	f3 45 0f 59 ca       	mulss  %xmm10,%xmm9
  40a5ca:	49 89 c6             	mov    %rax,%r14
  40a5cd:	66 4c 0f 7e c8       	movq   %xmm9,%rax
  40a5d2:	89 c0                	mov    %eax,%eax
  40a5d4:	4c 89 b5 70 f5 ff ff 	mov    %r14,-0xa90(%rbp)
  40a5db:	48 89 85 78 f5 ff ff 	mov    %rax,-0xa88(%rbp)
  40a5e2:	66 4c 0f 6e c8       	movq   %rax,%xmm9
  40a5e7:	f3 45 0f 58 c1       	addss  %xmm9,%xmm8
  40a5ec:	66 4c 0f 7e c0       	movq   %xmm8,%rax
  40a5f1:	41 89 c0             	mov    %eax,%r8d
  40a5f4:	4c 89 ad 70 f5 ff ff 	mov    %r13,-0xa90(%rbp)
  40a5fb:	4c 89 a5 78 f5 ff ff 	mov    %r12,-0xa88(%rbp)
  40a602:	f3 0f 59 c7          	mulss  %xmm7,%xmm0
  40a606:	66 48 0f 7e c0       	movq   %xmm0,%rax
  40a60b:	89 c0                	mov    %eax,%eax
  40a60d:	66 48 0f 6e c6       	movq   %rsi,%xmm0
  40a612:	66 48 0f 6e f8       	movq   %rax,%xmm7
  40a617:	48 89 de             	mov    %rbx,%rsi
  40a61a:	48 83 ee 01          	sub    $0x1,%rsi
  40a61e:	e8 cd ce ff ff       	callq  4074f0 <p126_typed_FID_36_112_114_111_100_117_99_116_46_116_114_97_99_101_>
  40a623:	e9 92 0c 00 00       	jmpq   40b2ba <p113d_FID_36_100_105_114_101_99_116_46_116_114_97_99_101_+0x1b4a>
  40a628:	48 89 d8             	mov    %rbx,%rax
  40a62b:	48 89 c3             	mov    %rax,%rbx
  40a62e:	e9 87 0c 00 00       	jmpq   40b2ba <p113d_FID_36_100_105_114_101_99_116_46_116_114_97_99_101_+0x1b4a>
  40a633:	4d 89 f5             	mov    %r14,%r13
  40a636:	48 3d 97 00 00 00    	cmp    $0x97,%rax
  40a63c:	74 14                	je     40a652 <p113d_FID_36_100_105_114_101_99_116_46_116_114_97_99_101_+0xee2>
  40a63e:	be 04 00 00 00       	mov    $0x4,%esi
  40a643:	e8 b8 27 02 00       	callq  42ce00 <p111_rt_fail>
  40a648:	b8 00 00 00 00       	mov    $0x0,%eax
  40a64d:	e9 68 0c 00 00       	jmpq   40b2ba <p113d_FID_36_100_105_114_101_99_116_46_116_114_97_99_101_+0x1b4a>
  40a652:	49 89 d6             	mov    %rdx,%r14
  40a655:	48 8d 95 70 f5 ff ff 	lea    -0xa90(%rbp),%rdx
  40a65c:	49 89 fc             	mov    %rdi,%r12
  40a65f:	e8 1c 7a 02 00       	callq  432080 <p125_rt_take3>
  40a664:	4d 89 f9             	mov    %r15,%r9
  40a667:	4c 89 f2             	mov    %r14,%rdx
  40a66a:	4c 89 e7             	mov    %r12,%rdi
  40a66d:	48 89 d8             	mov    %rbx,%rax
  40a670:	f3 0f 10 9d 00 ff ff ff 	movss  -0x100(%rbp),%xmm3
  40a678:	f3 0f 10 a5 f4 fe ff ff 	movss  -0x10c(%rbp),%xmm4
  40a680:	f3 0f 10 95 fc fe ff ff 	movss  -0x104(%rbp),%xmm2
  40a688:	f3 0f 10 ad f0 fe ff ff 	movss  -0x110(%rbp),%xmm5
  40a690:	f3 0f 10 8d f8 fe ff ff 	movss  -0x108(%rbp),%xmm1
  40a698:	f3 0f 10 b5 e4 fe ff ff 	movss  -0x11c(%rbp),%xmm6
  40a6a0:	48 8b 9d e8 fe ff ff 	mov    -0x118(%rbp),%rbx
  40a6a7:	4c 8b 85 70 f5 ff ff 	mov    -0xa90(%rbp),%r8
  40a6ae:	4c 8b b5 78 f5 ff ff 	mov    -0xa88(%rbp),%r14
  40a6b5:	48 8b b5 80 f5 ff ff 	mov    -0xa80(%rbp),%rsi
  40a6bc:	49 83 f8 01          	cmp    $0x1,%r8
  40a6c0:	0f 94 c1             	sete   %cl
  40a6c3:	0f b6 c9             	movzbl %cl,%ecx
  40a6c6:	49 c1 e8 28          	shr    $0x28,%r8
  40a6ca:	49 81 e0 ff ff 7f 00 	and    $0x7fffff,%r8
  40a6d1:	49 81 f8 02 00 01 00 	cmp    $0x10002,%r8
  40a6d8:	41 0f 94 c0          	sete   %r8b
  40a6dc:	45 0f b6 c0          	movzbl %r8b,%r8d
  40a6e0:	44 09 c1             	or     %r8d,%ecx
  40a6e3:	0f 85 d1 0b 00 00    	jne    40b2ba <p113d_FID_36_100_105_114_101_99_116_46_116_114_97_99_101_+0x1b4a>
  40a6e9:	83 f1 01             	xor    $0x1,%ecx
  40a6ec:	75 17                	jne    40a705 <p113d_FID_36_100_105_114_101_99_116_46_116_114_97_99_101_+0xf95>
  40a6ee:	2e 2e 2e be 04 00 00 00 	cs cs cs mov $0x4,%esi
  40a6f6:	e8 05 27 02 00       	callq  42ce00 <p111_rt_fail>
  40a6fb:	b8 00 00 00 00       	mov    $0x0,%eax
  40a700:	e9 b5 0b 00 00       	jmpq   40b2ba <p113d_FID_36_100_105_114_101_99_116_46_116_114_97_99_101_+0x1b4a>
  40a705:	48 83 fe 00          	cmp    $0x0,%rsi
  40a709:	0f 94 c1             	sete   %cl
  40a70c:	0f b6 c9             	movzbl %cl,%ecx
  40a70f:	89 8d e0 fe ff ff    	mov    %ecx,-0x120(%rbp)
  40a715:	49 89 f0             	mov    %rsi,%r8
  40a718:	49 83 e8 01          	sub    $0x1,%r8
  40a71c:	49 89 f7             	mov    %rsi,%r15
  40a71f:	49 83 ef 02          	sub    $0x2,%r15
  40a723:	49 89 f4             	mov    %rsi,%r12
  40a726:	49 83 ec 03          	sub    $0x3,%r12
  40a72a:	49 89 f3             	mov    %rsi,%r11
  40a72d:	49 83 eb 04          	sub    $0x4,%r11
  40a731:	49 89 f2             	mov    %rsi,%r10
  40a734:	49 83 ea 05          	sub    $0x5,%r10
  40a738:	4c 89 95 c8 fe ff ff 	mov    %r10,-0x138(%rbp)
  40a73f:	48 89 f1             	mov    %rsi,%rcx
  40a742:	48 83 e9 06          	sub    $0x6,%rcx
  40a746:	48 89 8d b8 fe ff ff 	mov    %rcx,-0x148(%rbp)
  40a74d:	48 89 f1             	mov    %rsi,%rcx
  40a750:	48 83 e9 07          	sub    $0x7,%rcx
  40a754:	48 89 8d b0 fe ff ff 	mov    %rcx,-0x150(%rbp)
  40a75b:	4c 89 d1             	mov    %r10,%rcx
  40a75e:	4c 8b 95 b8 fe ff ff 	mov    -0x148(%rbp),%r10
  40a765:	83 bd e0 fe ff ff 00 	cmpl   $0x0,-0x120(%rbp)
  40a76c:	75 71                	jne    40a7df <p113d_FID_36_100_105_114_101_99_116_46_116_114_97_99_101_+0x106f>
  40a76e:	49 83 f8 00          	cmp    $0x0,%r8
  40a772:	74 64                	je     40a7d8 <p113d_FID_36_100_105_114_101_99_116_46_116_114_97_99_101_+0x1068>
  40a774:	49 83 ff 00          	cmp    $0x0,%r15
  40a778:	74 57                	je     40a7d1 <p113d_FID_36_100_105_114_101_99_116_46_116_114_97_99_101_+0x1061>
  40a77a:	66 0f 1f 44 00 00    	nopw   0x0(%rax,%rax,1)
  40a780:	49 83 fc 00          	cmp    $0x0,%r12
  40a784:	74 44                	je     40a7ca <p113d_FID_36_100_105_114_101_99_116_46_116_114_97_99_101_+0x105a>
  40a786:	49 83 fb 00          	cmp    $0x0,%r11
  40a78a:	74 37                	je     40a7c3 <p113d_FID_36_100_105_114_101_99_116_46_116_114_97_99_101_+0x1053>
  40a78c:	48 83 f9 00          	cmp    $0x0,%rcx
  40a790:	48 8b 8d b0 fe ff ff 	mov    -0x150(%rbp),%rcx
  40a797:	74 23                	je     40a7bc <p113d_FID_36_100_105_114_101_99_116_46_116_114_97_99_101_+0x104c>
  40a799:	49 83 fa 00          	cmp    $0x0,%r10
  40a79d:	4c 8b 95 d8 fe ff ff 	mov    -0x128(%rbp),%r10
  40a7a4:	74 0f                	je     40a7b5 <p113d_FID_36_100_105_114_101_99_116_46_116_114_97_99_101_+0x1045>
  40a7a6:	48 83 f9 00          	cmp    $0x0,%rcx
  40a7aa:	b9 00 00 80 3f       	mov    $0x3f800000,%ecx
  40a7af:	49 0f 45 ca          	cmovne %r10,%rcx
  40a7b3:	eb 2f                	jmp    40a7e4 <p113d_FID_36_100_105_114_101_99_116_46_116_114_97_99_101_+0x1074>
  40a7b5:	b9 9a 99 99 3f       	mov    $0x3f99999a,%ecx
  40a7ba:	eb 28                	jmp    40a7e4 <p113d_FID_36_100_105_114_101_99_116_46_116_114_97_99_101_+0x1074>
  40a7bc:	b9 cd cc cc 3e       	mov    $0x3ecccccd,%ecx
  40a7c1:	eb 21                	jmp    40a7e4 <p113d_FID_36_100_105_114_101_99_116_46_116_114_97_99_101_+0x1074>
  40a7c3:	b9 cd cc cc 3e       	mov    $0x3ecccccd,%ecx
  40a7c8:	eb 1a                	jmp    40a7e4 <p113d_FID_36_100_105_114_101_99_116_46_116_114_97_99_101_+0x1074>
  40a7ca:	b9 00 00 80 3f       	mov    $0x3f800000,%ecx
  40a7cf:	eb 13                	jmp    40a7e4 <p113d_FID_36_100_105_114_101_99_116_46_116_114_97_99_101_+0x1074>
  40a7d1:	b9 00 00 80 3f       	mov    $0x3f800000,%ecx
  40a7d6:	eb 0c                	jmp    40a7e4 <p113d_FID_36_100_105_114_101_99_116_46_116_114_97_99_101_+0x1074>
  40a7d8:	b9 00 00 80 3f       	mov    $0x3f800000,%ecx
  40a7dd:	eb 05                	jmp    40a7e4 <p113d_FID_36_100_105_114_101_99_116_46_116_114_97_99_101_+0x1074>
  40a7df:	b9 00 40 1c 46       	mov    $0x461c4000,%ecx
  40a7e4:	4c 89 b5 70 f5 ff ff 	mov    %r14,-0xa90(%rbp)
  40a7eb:	4c 89 8d 78 f5 ff ff 	mov    %r9,-0xa88(%rbp)
  40a7f2:	66 49 0f 6e c6       	movq   %r14,%xmm0
  40a7f7:	f3 0f 59 f0          	mulss  %xmm0,%xmm6
  40a7fb:	66 49 0f 7e f1       	movq   %xmm6,%r9
  40a800:	45 89 c9             	mov    %r9d,%r9d
  40a803:	4c 89 8d 98 fe ff ff 	mov    %r9,-0x168(%rbp)
  40a80a:	4c 8b 95 c8 fe ff ff 	mov    -0x138(%rbp),%r10
  40a811:	4c 8b 8d d0 fe ff ff 	mov    -0x130(%rbp),%r9
  40a818:	4c 89 8d 70 f5 ff ff 	mov    %r9,-0xa90(%rbp)
  40a81f:	4c 8b 8d 98 fe ff ff 	mov    -0x168(%rbp),%r9
  40a826:	4c 89 8d 78 f5 ff ff 	mov    %r9,-0xa88(%rbp)
  40a82d:	4c 89 b5 70 f5 ff ff 	mov    %r14,-0xa90(%rbp)
  40a834:	48 89 95 78 f5 ff ff 	mov    %rdx,-0xa88(%rbp)
  40a83b:	f3 0f 59 e8          	mulss  %xmm0,%xmm5
  40a83f:	66 48 0f 7e ea       	movq   %xmm5,%rdx
  40a844:	89 d2                	mov    %edx,%edx
  40a846:	48 89 95 88 fe ff ff 	mov    %rdx,-0x178(%rbp)
  40a84d:	4c 8b 8d b8 fe ff ff 	mov    -0x148(%rbp),%r9
  40a854:	48 8b 95 c0 fe ff ff 	mov    -0x140(%rbp),%rdx
  40a85b:	48 89 95 70 f5 ff ff 	mov    %rdx,-0xa90(%rbp)
  40a862:	48 8b 95 88 fe ff ff 	mov    -0x178(%rbp),%rdx
  40a869:	48 89 95 78 f5 ff ff 	mov    %rdx,-0xa88(%rbp)
  40a870:	48 8b 95 b0 fe ff ff 	mov    -0x150(%rbp),%rdx
  40a877:	4c 89 b5 70 f5 ff ff 	mov    %r14,-0xa90(%rbp)
  40a87e:	4c 89 ad 78 f5 ff ff 	mov    %r13,-0xa88(%rbp)
  40a885:	f3 0f 59 c4          	mulss  %xmm4,%xmm0
  40a889:	66 49 0f 7e c5       	movq   %xmm0,%r13
  40a88e:	45 89 ee             	mov    %r13d,%r14d
  40a891:	4c 89 b5 60 fe ff ff 	mov    %r14,-0x1a0(%rbp)
  40a898:	4c 8b ad 98 fe ff ff 	mov    -0x168(%rbp),%r13
  40a89f:	4c 8b b5 a8 fe ff ff 	mov    -0x158(%rbp),%r14
  40a8a6:	4c 89 b5 70 f5 ff ff 	mov    %r14,-0xa90(%rbp)
  40a8ad:	4c 8b b5 60 fe ff ff 	mov    -0x1a0(%rbp),%r14
  40a8b4:	4c 89 b5 78 f5 ff ff 	mov    %r14,-0xa88(%rbp)
  40a8bb:	4c 8b b5 a0 fe ff ff 	mov    -0x160(%rbp),%r14
  40a8c2:	48 83 fe 00          	cmp    $0x0,%rsi
  40a8c6:	74 72                	je     40a93a <p113d_FID_36_100_105_114_101_99_116_46_116_114_97_99_101_+0x11ca>
  40a8c8:	49 83 f8 00          	cmp    $0x0,%r8
  40a8cc:	74 64                	je     40a932 <p113d_FID_36_100_105_114_101_99_116_46_116_114_97_99_101_+0x11c2>
  40a8ce:	49 83 ff 00          	cmp    $0x0,%r15
  40a8d2:	74 56                	je     40a92a <p113d_FID_36_100_105_114_101_99_116_46_116_114_97_99_101_+0x11ba>
  40a8d4:	49 83 fc 00          	cmp    $0x0,%r12
  40a8d8:	74 48                	je     40a922 <p113d_FID_36_100_105_114_101_99_116_46_116_114_97_99_101_+0x11b2>
  40a8da:	66 0f 1f 44 00 00    	nopw   0x0(%rax,%rax,1)
  40a8e0:	49 83 fb 00          	cmp    $0x0,%r11
  40a8e4:	74 33                	je     40a919 <p113d_FID_36_100_105_114_101_99_116_46_116_114_97_99_101_+0x11a9>
  40a8e6:	49 83 fa 00          	cmp    $0x0,%r10
  40a8ea:	74 25                	je     40a911 <p113d_FID_36_100_105_114_101_99_116_46_116_114_97_99_101_+0x11a1>
  40a8ec:	49 83 f9 00          	cmp    $0x0,%r9
  40a8f0:	74 17                	je     40a909 <p113d_FID_36_100_105_114_101_99_116_46_116_114_97_99_101_+0x1199>
  40a8f2:	48 83 fa 00          	cmp    $0x0,%rdx
  40a8f6:	41 bd 00 00 60 40    	mov    $0x40600000,%r13d
  40a8fc:	4d 0f 44 f5          	cmove  %r13,%r14
  40a900:	4c 8b ad 98 fe ff ff 	mov    -0x168(%rbp),%r13
  40a907:	eb 37                	jmp    40a940 <p113d_FID_36_100_105_114_101_99_116_46_116_114_97_99_101_+0x11d0>
  40a909:	41 be 00 00 00 00    	mov    $0x0,%r14d
  40a90f:	eb 2f                	jmp    40a940 <p113d_FID_36_100_105_114_101_99_116_46_116_114_97_99_101_+0x11d0>
  40a911:	41 be 00 00 80 bf    	mov    $0xbf800000,%r14d
  40a917:	eb 27                	jmp    40a940 <p113d_FID_36_100_105_114_101_99_116_46_116_114_97_99_101_+0x11d0>
  40a919:	2e 41 be 00 00 80 3f 	cs mov $0x3f800000,%r14d
  40a920:	eb 1e                	jmp    40a940 <p113d_FID_36_100_105_114_101_99_116_46_116_114_97_99_101_+0x11d0>
  40a922:	41 be 00 00 00 c0    	mov    $0xc0000000,%r14d
  40a928:	eb 16                	jmp    40a940 <p113d_FID_36_100_105_114_101_99_116_46_116_114_97_99_101_+0x11d0>
  40a92a:	41 be 00 00 00 40    	mov    $0x40000000,%r14d
  40a930:	eb 0e                	jmp    40a940 <p113d_FID_36_100_105_114_101_99_116_46_116_114_97_99_101_+0x11d0>
  40a932:	41 be 00 00 00 00    	mov    $0x0,%r14d
  40a938:	eb 06                	jmp    40a940 <p113d_FID_36_100_105_114_101_99_116_46_116_114_97_99_101_+0x11d0>
  40a93a:	41 be 00 00 00 00    	mov    $0x0,%r14d
  40a940:	66 49 0f 6e c5       	movq   %r13,%xmm0
  40a945:	f3 0f 58 c1          	addss  %xmm1,%xmm0
  40a949:	66 49 0f 7e c5       	movq   %xmm0,%r13
  40a94e:	45 89 ed             	mov    %r13d,%r13d
  40a951:	4c 89 ad 80 fe ff ff 	mov    %r13,-0x180(%rbp)
  40a958:	4c 89 ad 70 f5 ff ff 	mov    %r13,-0xa90(%rbp)
  40a95f:	4c 89 b5 78 f5 ff ff 	mov    %r14,-0xa88(%rbp)
  40a966:	66 49 0f 6e c5       	movq   %r13,%xmm0
  40a96b:	f3 0f 11 85 18 fe ff ff 	movss  %xmm0,-0x1e8(%rbp)
  40a973:	66 49 0f 6e ce       	movq   %r14,%xmm1
  40a978:	0f 57 0d 91 86 02 00 	xorps  0x28691(%rip),%xmm1        # 433010 <_IO_stdin_used+0x10>
  40a97f:	f3 0f 58 c8          	addss  %xmm0,%xmm1
  40a983:	66 49 0f 7e ce       	movq   %xmm1,%r14
  40a988:	45 89 f6             	mov    %r14d,%r14d
  40a98b:	4c 89 b5 38 fe ff ff 	mov    %r14,-0x1c8(%rbp)
  40a992:	4c 89 b5 70 f5 ff ff 	mov    %r14,-0xa90(%rbp)
  40a999:	4c 8b b5 88 fe ff ff 	mov    -0x178(%rbp),%r14
  40a9a0:	48 89 8d 78 f5 ff ff 	mov    %rcx,-0xa88(%rbp)
  40a9a7:	48 83 fe 00          	cmp    $0x0,%rsi
  40a9ab:	0f 84 97 00 00 00    	je     40aa48 <p113d_FID_36_100_105_114_101_99_116_46_116_114_97_99_101_+0x12d8>
  40a9b1:	4c 8b b5 90 fe ff ff 	mov    -0x170(%rbp),%r14
  40a9b8:	49 83 f8 00          	cmp    $0x0,%r8
  40a9bc:	74 58                	je     40aa16 <p113d_FID_36_100_105_114_101_99_116_46_116_114_97_99_101_+0x12a6>
  40a9be:	66 90                	xchg   %ax,%ax
  40a9c0:	49 83 ff 00          	cmp    $0x0,%r15
  40a9c4:	74 48                	je     40aa0e <p113d_FID_36_100_105_114_101_99_116_46_116_114_97_99_101_+0x129e>
  40a9c6:	49 83 fc 00          	cmp    $0x0,%r12
  40a9ca:	74 3a                	je     40aa06 <p113d_FID_36_100_105_114_101_99_116_46_116_114_97_99_101_+0x1296>
  40a9cc:	49 83 fb 00          	cmp    $0x0,%r11
  40a9d0:	74 2c                	je     40a9fe <p113d_FID_36_100_105_114_101_99_116_46_116_114_97_99_101_+0x128e>
  40a9d2:	49 83 fa 00          	cmp    $0x0,%r10
  40a9d6:	74 1e                	je     40a9f6 <p113d_FID_36_100_105_114_101_99_116_46_116_114_97_99_101_+0x1286>
  40a9d8:	49 83 f9 00          	cmp    $0x0,%r9
  40a9dc:	74 10                	je     40a9ee <p113d_FID_36_100_105_114_101_99_116_46_116_114_97_99_101_+0x127e>
  40a9de:	48 83 fa 00          	cmp    $0x0,%rdx
  40a9e2:	41 bd cd cc 4c 3e    	mov    $0x3e4ccccd,%r13d
  40a9e8:	4d 0f 45 ee          	cmovne %r14,%r13
  40a9ec:	eb 2e                	jmp    40aa1c <p113d_FID_36_100_105_114_101_99_116_46_116_114_97_99_101_+0x12ac>
  40a9ee:	41 bd cd cc cc 3f    	mov    $0x3fcccccd,%r13d
  40a9f4:	eb 26                	jmp    40aa1c <p113d_FID_36_100_105_114_101_99_116_46_116_114_97_99_101_+0x12ac>
  40a9f6:	41 bd 9a 99 19 bf    	mov    $0xbf19999a,%r13d
  40a9fc:	eb 1e                	jmp    40aa1c <p113d_FID_36_100_105_114_101_99_116_46_116_114_97_99_101_+0x12ac>
  40a9fe:	41 bd 9a 99 19 bf    	mov    $0xbf19999a,%r13d
  40aa04:	eb 16                	jmp    40aa1c <p113d_FID_36_100_105_114_101_99_116_46_116_114_97_99_101_+0x12ac>
  40aa06:	41 bd 00 00 00 3f    	mov    $0x3f000000,%r13d
  40aa0c:	eb 0e                	jmp    40aa1c <p113d_FID_36_100_105_114_101_99_116_46_116_114_97_99_101_+0x12ac>
  40aa0e:	41 bd 00 00 00 3f    	mov    $0x3f000000,%r13d
  40aa14:	eb 06                	jmp    40aa1c <p113d_FID_36_100_105_114_101_99_116_46_116_114_97_99_101_+0x12ac>
  40aa16:	41 bd 00 00 00 00    	mov    $0x0,%r13d
  40aa1c:	4d 89 ee             	mov    %r13,%r14
  40aa1f:	4c 89 b5 78 fe ff ff 	mov    %r14,-0x188(%rbp)
  40aa26:	4c 8b b5 88 fe ff ff 	mov    -0x178(%rbp),%r14
  40aa2d:	4c 8b ad 80 fe ff ff 	mov    -0x180(%rbp),%r13
  40aa34:	f2 44 0f 10 bd 78 fe ff ff 	movsd  -0x188(%rbp),%xmm15
  40aa3d:	f2 44 0f 11 bd 70 fe ff ff 	movsd  %xmm15,-0x190(%rbp)
  40aa46:	eb 14                	jmp    40aa5c <p113d_FID_36_100_105_114_101_99_116_46_116_114_97_99_101_+0x12ec>
  40aa48:	c7 85 70 fe ff ff 00 44 1c c6 	movl   $0xc61c4400,-0x190(%rbp)
  40aa52:	c7 85 74 fe ff ff 00 00 00 00 	movl   $0x0,-0x18c(%rbp)
  40aa5c:	66 49 0f 6e ce       	movq   %r14,%xmm1
  40aa61:	f3 0f 58 ca          	addss  %xmm2,%xmm1
  40aa65:	66 49 0f 7e ce       	movq   %xmm1,%r14
  40aa6a:	45 89 f6             	mov    %r14d,%r14d
  40aa6d:	4c 89 b5 68 fe ff ff 	mov    %r14,-0x198(%rbp)
  40aa74:	4c 89 b5 70 f5 ff ff 	mov    %r14,-0xa90(%rbp)
  40aa7b:	4c 8b b5 70 fe ff ff 	mov    -0x190(%rbp),%r14
  40aa82:	4c 89 b5 78 f5 ff ff 	mov    %r14,-0xa88(%rbp)
  40aa89:	4c 8b b5 68 fe ff ff 	mov    -0x198(%rbp),%r14
  40aa90:	66 49 0f 6e ce       	movq   %r14,%xmm1
  40aa95:	f3 0f 11 8d 00 fe ff ff 	movss  %xmm1,-0x200(%rbp)
  40aa9d:	4c 8b b5 70 fe ff ff 	mov    -0x190(%rbp),%r14
  40aaa4:	66 49 0f 6e d6       	movq   %r14,%xmm2
  40aaa9:	0f 57 15 60 85 02 00 	xorps  0x28560(%rip),%xmm2        # 433010 <_IO_stdin_used+0x10>
  40aab0:	f3 0f 58 d1          	addss  %xmm1,%xmm2
  40aab4:	66 49 0f 7e d6       	movq   %xmm2,%r14
  40aab9:	45 89 f6             	mov    %r14d,%r14d
  40aabc:	4c 89 b5 40 fe ff ff 	mov    %r14,-0x1c0(%rbp)
  40aac3:	4c 89 b5 70 f5 ff ff 	mov    %r14,-0xa90(%rbp)
  40aaca:	4c 8b b5 68 fe ff ff 	mov    -0x198(%rbp),%r14
  40aad1:	48 89 8d 78 f5 ff ff 	mov    %rcx,-0xa88(%rbp)
  40aad8:	48 83 fe 00          	cmp    $0x0,%rsi
  40aadc:	48 8b b5 60 fe ff ff 	mov    -0x1a0(%rbp),%rsi
  40aae3:	74 67                	je     40ab4c <p113d_FID_36_100_105_114_101_99_116_46_116_114_97_99_101_+0x13dc>
  40aae5:	49 83 f8 00          	cmp    $0x0,%r8
  40aae9:	4c 8b 85 58 fe ff ff 	mov    -0x1a8(%rbp),%r8
  40aaf0:	74 53                	je     40ab45 <p113d_FID_36_100_105_114_101_99_116_46_116_114_97_99_101_+0x13d5>
  40aaf2:	49 83 ff 00          	cmp    $0x0,%r15
  40aaf6:	74 46                	je     40ab3e <p113d_FID_36_100_105_114_101_99_116_46_116_114_97_99_101_+0x13ce>
  40aaf8:	49 83 fc 00          	cmp    $0x0,%r12
  40aafc:	74 39                	je     40ab37 <p113d_FID_36_100_105_114_101_99_116_46_116_114_97_99_101_+0x13c7>
  40aafe:	66 90                	xchg   %ax,%ax
  40ab00:	49 83 fb 00          	cmp    $0x0,%r11
  40ab04:	74 2a                	je     40ab30 <p113d_FID_36_100_105_114_101_99_116_46_116_114_97_99_101_+0x13c0>
  40ab06:	49 83 fa 00          	cmp    $0x0,%r10
  40ab0a:	74 1d                	je     40ab29 <p113d_FID_36_100_105_114_101_99_116_46_116_114_97_99_101_+0x13b9>
  40ab0c:	49 83 f9 00          	cmp    $0x0,%r9
  40ab10:	74 10                	je     40ab22 <p113d_FID_36_100_105_114_101_99_116_46_116_114_97_99_101_+0x13b2>
  40ab12:	2e 48 83 fa 00       	cs cmp $0x0,%rdx
  40ab17:	ba 00 00 00 41       	mov    $0x41000000,%edx
  40ab1c:	49 0f 45 d0          	cmovne %r8,%rdx
  40ab20:	eb 2f                	jmp    40ab51 <p113d_FID_36_100_105_114_101_99_116_46_116_114_97_99_101_+0x13e1>
  40ab22:	ba 00 00 e0 40       	mov    $0x40e00000,%edx
  40ab27:	eb 28                	jmp    40ab51 <p113d_FID_36_100_105_114_101_99_116_46_116_114_97_99_101_+0x13e1>
  40ab29:	ba 00 00 60 40       	mov    $0x40600000,%edx
  40ab2e:	eb 21                	jmp    40ab51 <p113d_FID_36_100_105_114_101_99_116_46_116_114_97_99_101_+0x13e1>
  40ab30:	ba 00 00 60 40       	mov    $0x40600000,%edx
  40ab35:	eb 1a                	jmp    40ab51 <p113d_FID_36_100_105_114_101_99_116_46_116_114_97_99_101_+0x13e1>
  40ab37:	ba 00 00 c0 40       	mov    $0x40c00000,%edx
  40ab3c:	eb 13                	jmp    40ab51 <p113d_FID_36_100_105_114_101_99_116_46_116_114_97_99_101_+0x13e1>
  40ab3e:	ba 00 00 c0 40       	mov    $0x40c00000,%edx
  40ab43:	eb 0c                	jmp    40ab51 <p113d_FID_36_100_105_114_101_99_116_46_116_114_97_99_101_+0x13e1>
  40ab45:	ba 00 00 a0 40       	mov    $0x40a00000,%edx
  40ab4a:	eb 05                	jmp    40ab51 <p113d_FID_36_100_105_114_101_99_116_46_116_114_97_99_101_+0x13e1>
  40ab4c:	ba 00 00 a0 40       	mov    $0x40a00000,%edx
  40ab51:	66 48 0f 6e d6       	movq   %rsi,%xmm2
  40ab56:	f3 0f 58 d3          	addss  %xmm3,%xmm2
  40ab5a:	66 48 0f 7e d6       	movq   %xmm2,%rsi
  40ab5f:	41 89 f4             	mov    %esi,%r12d
  40ab62:	4c 89 a5 08 fe ff ff 	mov    %r12,-0x1f8(%rbp)
  40ab69:	4c 89 a5 70 f5 ff ff 	mov    %r12,-0xa90(%rbp)
  40ab70:	48 89 95 78 f5 ff ff 	mov    %rdx,-0xa88(%rbp)
  40ab77:	f3 0f 10 d0          	movss  %xmm0,%xmm2
  40ab7b:	66 49 0f 6e c4       	movq   %r12,%xmm0
  40ab80:	f3 0f 11 85 c4 fd ff ff 	movss  %xmm0,-0x23c(%rbp)
  40ab88:	66 48 0f 6e da       	movq   %rdx,%xmm3
  40ab8d:	0f 57 1d 7c 84 02 00 	xorps  0x2847c(%rip),%xmm3        # 433010 <_IO_stdin_used+0x10>
  40ab94:	f3 0f 58 d8          	addss  %xmm0,%xmm3
  40ab98:	66 48 0f 7e da       	movq   %xmm3,%rdx
  40ab9d:	89 d2                	mov    %edx,%edx
  40ab9f:	48 89 95 70 f5 ff ff 	mov    %rdx,-0xa90(%rbp)
  40aba6:	48 89 8d 78 f5 ff ff 	mov    %rcx,-0xa88(%rbp)
  40abad:	66 48 0f 6e e2       	movq   %rdx,%xmm4
  40abb2:	66 48 0f 6e d9       	movq   %rcx,%xmm3
  40abb7:	f3 0f 11 9d 48 fe ff ff 	movss  %xmm3,-0x1b8(%rbp)
  40abbf:	f3 44 0f 10 fb       	movss  %xmm3,%xmm15
  40abc4:	f3 0f 10 dc          	movss  %xmm4,%xmm3
  40abc8:	f3 41 0f 5e df       	divss  %xmm15,%xmm3
  40abcd:	66 48 0f 7e d9       	movq   %xmm3,%rcx
  40abd2:	4d 89 e7             	mov    %r12,%r15
  40abd5:	41 89 cc             	mov    %ecx,%r12d
  40abd8:	4c 89 a5 f8 fd ff ff 	mov    %r12,-0x208(%rbp)
  40abdf:	48 c7 85 70 f5 ff ff 00 00 00 00 	movq   $0x0,-0xa90(%rbp)
  40abea:	48 c7 85 70 f5 ff ff 03 00 00 00 	movq   $0x3,-0xa90(%rbp)
  40abf5:	48 c7 85 70 f5 ff ff 00 00 00 00 	movq   $0x0,-0xa90(%rbp)
  40ac00:	48 c7 85 78 f5 ff ff 00 00 40 40 	movq   $0x40400000,-0xa88(%rbp)
  40ac0b:	b9 00 00 40 c0       	mov    $0xc0400000,%ecx
  40ac10:	48 89 8d 70 f5 ff ff 	mov    %rcx,-0xa90(%rbp)
  40ac17:	4c 89 ad 78 f5 ff ff 	mov    %r13,-0xa88(%rbp)
  40ac1e:	0f 57 15 eb 83 02 00 	xorps  0x283eb(%rip),%xmm2        # 433010 <_IO_stdin_used+0x10>
  40ac25:	f3 0f 58 15 03 84 02 00 	addss  0x28403(%rip),%xmm2        # 433030 <_IO_stdin_used+0x30>
  40ac2d:	66 48 0f 7e d1       	movq   %xmm2,%rcx
  40ac32:	41 89 c8             	mov    %ecx,%r8d
  40ac35:	4c 89 85 20 fe ff ff 	mov    %r8,-0x1e0(%rbp)
  40ac3c:	48 c7 85 70 f5 ff ff 08 00 00 00 	movq   $0x8,-0xa90(%rbp)
  40ac47:	48 c7 85 70 f5 ff ff 00 00 00 41 	movq   $0x41000000,-0xa90(%rbp)
  40ac52:	4c 89 b5 78 f5 ff ff 	mov    %r14,-0xa88(%rbp)
  40ac59:	0f 57 0d b0 83 02 00 	xorps  0x283b0(%rip),%xmm1        # 433010 <_IO_stdin_used+0x10>
  40ac60:	f3 0f 58 0d c4 83 02 00 	addss  0x283c4(%rip),%xmm1        # 43302c <_IO_stdin_used+0x2c>
  40ac68:	66 48 0f 7e c9       	movq   %xmm1,%rcx
  40ac6d:	89 ce                	mov    %ecx,%esi
  40ac6f:	48 89 b5 28 fe ff ff 	mov    %rsi,-0x1d8(%rbp)
  40ac76:	48 c7 85 70 f5 ff ff 01 00 00 00 	movq   $0x1,-0xa90(%rbp)
  40ac81:	48 c7 85 70 f5 ff ff 00 00 80 3f 	movq   $0x3f800000,-0xa90(%rbp)
  40ac8c:	4c 89 bd 78 f5 ff ff 	mov    %r15,-0xa88(%rbp)
  40ac93:	0f 57 05 76 83 02 00 	xorps  0x28376(%rip),%xmm0        # 433010 <_IO_stdin_used+0x10>
  40ac9a:	f3 0f 58 05 7e 83 02 00 	addss  0x2837e(%rip),%xmm0        # 433020 <_IO_stdin_used+0x20>
  40aca2:	66 48 0f 7e c1       	movq   %xmm0,%rcx
  40aca7:	41 89 ca             	mov    %ecx,%r10d
  40acaa:	4c 89 95 30 fe ff ff 	mov    %r10,-0x1d0(%rbp)
  40acb1:	4c 89 85 70 f5 ff ff 	mov    %r8,-0xa90(%rbp)
  40acb8:	4c 89 85 78 f5 ff ff 	mov    %r8,-0xa88(%rbp)
  40acbf:	66 49 0f 6e e8       	movq   %r8,%xmm5
  40acc4:	f3 0f 11 ad 4c fe ff ff 	movss  %xmm5,-0x1b4(%rbp)
  40accc:	f3 0f 10 c5          	movss  %xmm5,%xmm0
  40acd0:	f3 0f 59 c5          	mulss  %xmm5,%xmm0
  40acd4:	66 48 0f 7e c1       	movq   %xmm0,%rcx
  40acd9:	89 ca                	mov    %ecx,%edx
  40acdb:	48 89 b5 70 f5 ff ff 	mov    %rsi,-0xa90(%rbp)
  40ace2:	48 89 b5 78 f5 ff ff 	mov    %rsi,-0xa88(%rbp)
  40ace9:	66 48 0f 6e e6       	movq   %rsi,%xmm4
  40acee:	f3 0f 11 a5 50 fe ff ff 	movss  %xmm4,-0x1b0(%rbp)
  40acf6:	f3 0f 10 c4          	movss  %xmm4,%xmm0
  40acfa:	f3 0f 59 c4          	mulss  %xmm4,%xmm0
  40acfe:	66 48 0f 7e c1       	movq   %xmm0,%rcx
  40ad03:	89 c9                	mov    %ecx,%ecx
  40ad05:	48 89 95 70 f5 ff ff 	mov    %rdx,-0xa90(%rbp)
  40ad0c:	48 89 8d 78 f5 ff ff 	mov    %rcx,-0xa88(%rbp)
  40ad13:	66 48 0f 6e c2       	movq   %rdx,%xmm0
  40ad18:	66 48 0f 6e c9       	movq   %rcx,%xmm1
  40ad1d:	f3 0f 58 c1          	addss  %xmm1,%xmm0
  40ad21:	66 48 0f 7e c1       	movq   %xmm0,%rcx
  40ad26:	89 ca                	mov    %ecx,%edx
  40ad28:	4c 89 95 70 f5 ff ff 	mov    %r10,-0xa90(%rbp)
  40ad2f:	4c 89 95 78 f5 ff ff 	mov    %r10,-0xa88(%rbp)
  40ad36:	66 49 0f 6e d2       	movq   %r10,%xmm2
  40ad3b:	f3 0f 11 95 54 fe ff ff 	movss  %xmm2,-0x1ac(%rbp)
  40ad43:	f3 0f 10 c2          	movss  %xmm2,%xmm0
  40ad47:	f3 0f 59 c2          	mulss  %xmm2,%xmm0
  40ad4b:	66 48 0f 7e c1       	movq   %xmm0,%rcx
  40ad50:	89 c9                	mov    %ecx,%ecx
  40ad52:	48 89 95 70 f5 ff ff 	mov    %rdx,-0xa90(%rbp)
  40ad59:	48 89 8d 78 f5 ff ff 	mov    %rcx,-0xa88(%rbp)
  40ad60:	66 48 0f 6e c2       	movq   %rdx,%xmm0
  40ad65:	66 48 0f 6e c9       	movq   %rcx,%xmm1
  40ad6a:	f3 0f 58 c1          	addss  %xmm1,%xmm0
  40ad6e:	49 89 c4             	mov    %rax,%r12
  40ad71:	66 48 0f 7e c0       	movq   %xmm0,%rax
  40ad76:	89 c0                	mov    %eax,%eax
  40ad78:	48 89 85 70 f5 ff ff 	mov    %rax,-0xa90(%rbp)
  40ad7f:	b9 01 00 00 00       	mov    $0x1,%ecx
  40ad84:	48 8d 95 70 f5 ff ff 	lea    -0xa90(%rbp),%rdx
  40ad8b:	be 24 00 00 00       	mov    $0x24,%esi
  40ad90:	49 89 ff             	mov    %rdi,%r15
  40ad93:	e8 88 20 02 00       	callq  42ce20 <p111_rt_op>
  40ad98:	4c 89 ff             	mov    %r15,%rdi
  40ad9b:	48 89 c2             	mov    %rax,%rdx
  40ad9e:	4c 89 e0             	mov    %r12,%rax
  40ada1:	4c 8b 95 30 fe ff ff 	mov    -0x1d0(%rbp),%r10
  40ada8:	48 8b b5 28 fe ff ff 	mov    -0x1d8(%rbp),%rsi
  40adaf:	4c 8b 85 20 fe ff ff 	mov    -0x1e0(%rbp),%r8
  40adb6:	4c 8b a5 f8 fd ff ff 	mov    -0x208(%rbp),%r12
  40adbd:	4c 8b 8d 40 fe ff ff 	mov    -0x1c0(%rbp),%r9
  40adc4:	48 8b 8d 38 fe ff ff 	mov    -0x1c8(%rbp),%rcx
  40adcb:	4c 8b bd 08 fe ff ff 	mov    -0x1f8(%rbp),%r15
  40add2:	f3 0f 10 95 54 fe ff ff 	movss  -0x1ac(%rbp),%xmm2
  40adda:	f3 0f 10 a5 50 fe ff ff 	movss  -0x1b0(%rbp),%xmm4
  40ade2:	f3 0f 10 ad 4c fe ff ff 	movss  -0x1b4(%rbp),%xmm5
  40adea:	f3 0f 10 9d 48 fe ff ff 	movss  -0x1b8(%rbp),%xmm3
  40adf2:	f3 0f 10 85 18 fe ff ff 	movss  -0x1e8(%rbp),%xmm0
  40adfa:	4c 89 85 70 f5 ff ff 	mov    %r8,-0xa90(%rbp)
  40ae01:	48 89 95 78 f5 ff ff 	mov    %rdx,-0xa88(%rbp)
  40ae08:	66 48 0f 6e ca       	movq   %rdx,%xmm1
  40ae0d:	f3 0f 11 8d c0 fd ff ff 	movss  %xmm1,-0x240(%rbp)
  40ae15:	f3 0f 5e e9          	divss  %xmm1,%xmm5
  40ae19:	66 49 0f 7e e8       	movq   %xmm5,%r8
  40ae1e:	45 89 c0             	mov    %r8d,%r8d
  40ae21:	48 89 b5 70 f5 ff ff 	mov    %rsi,-0xa90(%rbp)
  40ae28:	48 89 95 78 f5 ff ff 	mov    %rdx,-0xa88(%rbp)
  40ae2f:	f3 0f 5e e1          	divss  %xmm1,%xmm4
  40ae33:	66 48 0f 7e e6       	movq   %xmm4,%rsi
  40ae38:	89 f6                	mov    %esi,%esi
  40ae3a:	4c 89 95 70 f5 ff ff 	mov    %r10,-0xa90(%rbp)
  40ae41:	48 89 95 78 f5 ff ff 	mov    %rdx,-0xa88(%rbp)
  40ae48:	f3 44 0f 10 f9       	movss  %xmm1,%xmm15
  40ae4d:	f3 0f 10 ca          	movss  %xmm2,%xmm1
  40ae51:	f3 41 0f 5e cf       	divss  %xmm15,%xmm1
  40ae56:	66 48 0f 7e ca       	movq   %xmm1,%rdx
  40ae5b:	89 d2                	mov    %edx,%edx
  40ae5d:	66 48 0f 6e c9       	movq   %rcx,%xmm1
  40ae62:	f3 0f 5e cb          	divss  %xmm3,%xmm1
  40ae66:	66 48 0f 7e c9       	movq   %xmm1,%rcx
  40ae6b:	89 c9                	mov    %ecx,%ecx
  40ae6d:	48 89 8d 10 fe ff ff 	mov    %rcx,-0x1f0(%rbp)
  40ae74:	48 89 8d 70 f5 ff ff 	mov    %rcx,-0xa90(%rbp)
  40ae7b:	4c 89 85 78 f5 ff ff 	mov    %r8,-0xa88(%rbp)
  40ae82:	66 48 0f 6e c9       	movq   %rcx,%xmm1
  40ae87:	f3 0f 11 8d 1c fe ff ff 	movss  %xmm1,-0x1e4(%rbp)
  40ae8f:	66 49 0f 6e d0       	movq   %r8,%xmm2
  40ae94:	f3 0f 11 95 e0 fd ff ff 	movss  %xmm2,-0x220(%rbp)
  40ae9c:	f3 0f 59 d1          	mulss  %xmm1,%xmm2
  40aea0:	66 49 0f 7e d0       	movq   %xmm2,%r8
  40aea5:	45 89 c0             	mov    %r8d,%r8d
  40aea8:	66 49 0f 6e d1       	movq   %r9,%xmm2
  40aead:	f3 0f 5e d3          	divss  %xmm3,%xmm2
  40aeb1:	66 49 0f 7e d1       	movq   %xmm2,%r9
  40aeb6:	45 89 c9             	mov    %r9d,%r9d
  40aeb9:	4c 89 8d f0 fd ff ff 	mov    %r9,-0x210(%rbp)
  40aec0:	4c 89 8d 70 f5 ff ff 	mov    %r9,-0xa90(%rbp)
  40aec7:	48 89 b5 78 f5 ff ff 	mov    %rsi,-0xa88(%rbp)
  40aece:	66 49 0f 6e d1       	movq   %r9,%xmm2
  40aed3:	f3 0f 11 95 04 fe ff ff 	movss  %xmm2,-0x1fc(%rbp)
  40aedb:	66 48 0f 6e e6       	movq   %rsi,%xmm4
  40aee0:	f3 0f 11 a5 e4 fd ff ff 	movss  %xmm4,-0x21c(%rbp)
  40aee8:	f3 0f 59 d4          	mulss  %xmm4,%xmm2
  40aeec:	66 48 0f 7e d6       	movq   %xmm2,%rsi
  40aef1:	89 f6                	mov    %esi,%esi
  40aef3:	4c 89 85 70 f5 ff ff 	mov    %r8,-0xa90(%rbp)
  40aefa:	48 89 b5 78 f5 ff ff 	mov    %rsi,-0xa88(%rbp)
  40af01:	66 49 0f 6e d0       	movq   %r8,%xmm2
  40af06:	66 48 0f 6e de       	movq   %rsi,%xmm3
  40af0b:	f3 0f 58 d3          	addss  %xmm3,%xmm2
  40af0f:	66 48 0f 7e d6       	movq   %xmm2,%rsi
  40af14:	89 f6                	mov    %esi,%esi
  40af16:	4c 89 a5 70 f5 ff ff 	mov    %r12,-0xa90(%rbp)
  40af1d:	48 89 95 78 f5 ff ff 	mov    %rdx,-0xa88(%rbp)
  40af24:	66 49 0f 6e d4       	movq   %r12,%xmm2
  40af29:	f3 0f 11 95 e8 fd ff ff 	movss  %xmm2,-0x218(%rbp)
  40af31:	66 48 0f 6e ea       	movq   %rdx,%xmm5
  40af36:	f3 0f 11 ad ec fd ff ff 	movss  %xmm5,-0x214(%rbp)
  40af3e:	f3 0f 59 d5          	mulss  %xmm5,%xmm2
  40af42:	66 48 0f 7e d2       	movq   %xmm2,%rdx
  40af47:	89 d2                	mov    %edx,%edx
  40af49:	48 89 b5 70 f5 ff ff 	mov    %rsi,-0xa90(%rbp)
  40af50:	48 89 95 78 f5 ff ff 	mov    %rdx,-0xa88(%rbp)
  40af57:	66 48 0f 6e d6       	movq   %rsi,%xmm2
  40af5c:	66 48 0f 6e da       	movq   %rdx,%xmm3
  40af61:	f3 0f 58 d3          	addss  %xmm3,%xmm2
  40af65:	66 48 0f 7e d2       	movq   %xmm2,%rdx
  40af6a:	89 d6                	mov    %edx,%esi
  40af6c:	66 48 0f 6e d6       	movq   %rsi,%xmm2
  40af71:	f3 0f 10 1d ab 80 02 00 	movss  0x280ab(%rip),%xmm3        # 433024 <_IO_stdin_used+0x24>
  40af79:	0f 2e da             	ucomiss %xmm2,%xmm3
  40af7c:	0f 97 c2             	seta   %dl
  40af7f:	0f b6 d2             	movzbl %dl,%edx
  40af82:	89 d2                	mov    %edx,%edx
  40af84:	48 83 fa 01          	cmp    $0x1,%rdx
  40af88:	49 89 c4             	mov    %rax,%r12
  40af8b:	0f 94 c0             	sete   %al
  40af8e:	0f b6 c0             	movzbl %al,%eax
  40af91:	48 c1 ea 28          	shr    $0x28,%rdx
  40af95:	48 81 e2 ff ff 7f 00 	and    $0x7fffff,%rdx
  40af9c:	48 81 fa 02 00 01 00 	cmp    $0x10002,%rdx
  40afa3:	0f 94 c2             	sete   %dl
  40afa6:	0f b6 d2             	movzbl %dl,%edx
  40afa9:	09 d0                	or     %edx,%eax
  40afab:	75 4c                	jne    40aff9 <p113d_FID_36_100_105_114_101_99_116_46_116_114_97_99_101_+0x1889>
  40afad:	83 f0 01             	xor    $0x1,%eax
  40afb0:	75 38                	jne    40afea <p113d_FID_36_100_105_114_101_99_116_46_116_114_97_99_101_+0x187a>
  40afb2:	be 04 00 00 00       	mov    $0x4,%esi
  40afb7:	49 89 ff             	mov    %rdi,%r15
  40afba:	e8 41 1e 02 00       	callq  42ce00 <p111_rt_fail>
  40afbf:	4c 89 ff             	mov    %r15,%rdi
  40afc2:	4c 89 e0             	mov    %r12,%rax
  40afc5:	48 8b 8d 10 fe ff ff 	mov    -0x1f0(%rbp),%rcx
  40afcc:	4c 8b a5 08 fe ff ff 	mov    -0x1f8(%rbp),%r12
  40afd3:	f3 0f 10 8d 1c fe ff ff 	movss  -0x1e4(%rbp),%xmm1
  40afdb:	f3 0f 10 85 18 fe ff ff 	movss  -0x1e8(%rbp),%xmm0
  40afe3:	be 00 00 00 00       	mov    $0x0,%esi
  40afe8:	eb 06                	jmp    40aff0 <p113d_FID_36_100_105_114_101_99_116_46_116_114_97_99_101_+0x1880>
  40afea:	4c 89 e0             	mov    %r12,%rax
  40afed:	4d 89 fc             	mov    %r15,%r12
  40aff0:	48 89 b5 c8 fd ff ff 	mov    %rsi,-0x238(%rbp)
  40aff7:	eb 11                	jmp    40b00a <p113d_FID_36_100_105_114_101_99_116_46_116_114_97_99_101_+0x189a>
  40aff9:	4c 89 e0             	mov    %r12,%rax
  40affc:	4d 89 fc             	mov    %r15,%r12
  40afff:	48 c7 85 c8 fd ff ff 00 00 00 00 	movq   $0x0,-0x238(%rbp)
  40b00a:	48 c7 85 70 f5 ff ff 6f 12 83 3a 	movq   $0x3a83126f,-0xa90(%rbp)
  40b015:	48 89 8d 78 f5 ff ff 	mov    %rcx,-0xa88(%rbp)
  40b01c:	f3 0f 59 0d 04 80 02 00 	mulss  0x28004(%rip),%xmm1        # 433028 <_IO_stdin_used+0x28>
  40b024:	66 48 0f 7e c9       	movq   %xmm1,%rcx
  40b029:	89 c9                	mov    %ecx,%ecx
  40b02b:	4c 89 ad 70 f5 ff ff 	mov    %r13,-0xa90(%rbp)
  40b032:	48 89 8d 78 f5 ff ff 	mov    %rcx,-0xa88(%rbp)
  40b039:	66 48 0f 6e c9       	movq   %rcx,%xmm1
  40b03e:	f3 0f 58 c1          	addss  %xmm1,%xmm0
  40b042:	49 89 c5             	mov    %rax,%r13
  40b045:	66 48 0f 7e c0       	movq   %xmm0,%rax
  40b04a:	89 c2                	mov    %eax,%edx
  40b04c:	48 89 95 d0 fd ff ff 	mov    %rdx,-0x230(%rbp)
  40b053:	f3 0f 10 0d e9 7f 02 00 	movss  0x27fe9(%rip),%xmm1        # 433044 <_IO_stdin_used+0x44>
  40b05b:	f3 0f 10 05 d9 7f 02 00 	movss  0x27fd9(%rip),%xmm0        # 43303c <_IO_stdin_used+0x3c>
  40b063:	49 89 ff             	mov    %rdi,%r15
  40b066:	e8 e5 ac ff ff       	callq  405d50 <p126_typed_FID_36_100_105_114_101_99_116_46_102_108_>
  40b06b:	4c 89 ff             	mov    %r15,%rdi
  40b06e:	48 89 c1             	mov    %rax,%rcx
  40b071:	4c 89 e8             	mov    %r13,%rax
  40b074:	4c 8b ad f8 fd ff ff 	mov    -0x208(%rbp),%r13
  40b07b:	48 8b 95 f0 fd ff ff 	mov    -0x210(%rbp),%rdx
  40b082:	f3 0f 10 8d 04 fe ff ff 	movss  -0x1fc(%rbp),%xmm1
  40b08a:	f3 0f 10 85 00 fe ff ff 	movss  -0x200(%rbp),%xmm0
  40b092:	48 89 8d 70 f5 ff ff 	mov    %rcx,-0xa90(%rbp)
  40b099:	48 89 95 78 f5 ff ff 	mov    %rdx,-0xa88(%rbp)
  40b0a0:	66 48 0f 6e d1       	movq   %rcx,%xmm2
  40b0a5:	f3 0f 59 ca          	mulss  %xmm2,%xmm1
  40b0a9:	66 48 0f 7e c9       	movq   %xmm1,%rcx
  40b0ae:	89 c9                	mov    %ecx,%ecx
  40b0b0:	4c 89 b5 70 f5 ff ff 	mov    %r14,-0xa90(%rbp)
  40b0b7:	48 89 8d 78 f5 ff ff 	mov    %rcx,-0xa88(%rbp)
  40b0be:	66 48 0f 6e c9       	movq   %rcx,%xmm1
  40b0c3:	f3 0f 58 c1          	addss  %xmm1,%xmm0
  40b0c7:	49 89 c6             	mov    %rax,%r14
  40b0ca:	66 48 0f 7e c0       	movq   %xmm0,%rax
  40b0cf:	89 c1                	mov    %eax,%ecx
  40b0d1:	48 89 8d d8 fd ff ff 	mov    %rcx,-0x228(%rbp)
  40b0d8:	f3 0f 10 0d 64 7f 02 00 	movss  0x27f64(%rip),%xmm1        # 433044 <_IO_stdin_used+0x44>
  40b0e0:	f3 0f 10 05 54 7f 02 00 	movss  0x27f54(%rip),%xmm0        # 43303c <_IO_stdin_used+0x3c>
  40b0e8:	49 89 ff             	mov    %rdi,%r15
  40b0eb:	e8 60 ac ff ff       	callq  405d50 <p126_typed_FID_36_100_105_114_101_99_116_46_102_108_>
  40b0f0:	4c 89 ff             	mov    %r15,%rdi
  40b0f3:	49 89 c0             	mov    %rax,%r8
  40b0f6:	4c 89 f0             	mov    %r14,%rax
  40b0f9:	48 8b b5 c8 fd ff ff 	mov    -0x238(%rbp),%rsi
  40b100:	48 8b 8d d8 fd ff ff 	mov    -0x228(%rbp),%rcx
  40b107:	48 8b 95 d0 fd ff ff 	mov    -0x230(%rbp),%rdx
  40b10e:	f3 0f 10 ad ec fd ff ff 	movss  -0x214(%rbp),%xmm5
  40b116:	f3 0f 10 8d e8 fd ff ff 	movss  -0x218(%rbp),%xmm1
  40b11e:	f3 0f 10 a5 e4 fd ff ff 	movss  -0x21c(%rbp),%xmm4
  40b126:	f3 0f 10 9d e0 fd ff ff 	movss  -0x220(%rbp),%xmm3
  40b12e:	f3 0f 10 85 c4 fd ff ff 	movss  -0x23c(%rbp),%xmm0
  40b136:	4c 89 85 70 f5 ff ff 	mov    %r8,-0xa90(%rbp)
  40b13d:	4c 89 ad 78 f5 ff ff 	mov    %r13,-0xa88(%rbp)
  40b144:	66 49 0f 6e d0       	movq   %r8,%xmm2
  40b149:	f3 0f 59 ca          	mulss  %xmm2,%xmm1
  40b14d:	66 49 0f 7e c8       	movq   %xmm1,%r8
  40b152:	45 89 c0             	mov    %r8d,%r8d
  40b155:	4c 89 a5 70 f5 ff ff 	mov    %r12,-0xa90(%rbp)
  40b15c:	4c 89 85 78 f5 ff ff 	mov    %r8,-0xa88(%rbp)
  40b163:	66 49 0f 6e c8       	movq   %r8,%xmm1
  40b168:	f3 0f 58 c1          	addss  %xmm1,%xmm0
  40b16c:	49 89 c5             	mov    %rax,%r13
  40b16f:	66 48 0f 7e c0       	movq   %xmm0,%rax
  40b174:	89 c0                	mov    %eax,%eax
  40b176:	48 c7 85 70 f5 ff ff 00 ca 9a 3b 	movq   $0x3b9aca00,-0xa90(%rbp)
  40b181:	48 c7 85 70 f5 ff ff 00 ca 9a 3b 	movq   $0x3b9aca00,-0xa90(%rbp)
  40b18c:	66 48 0f 6e c2       	movq   %rdx,%xmm0
  40b191:	66 48 0f 6e c9       	movq   %rcx,%xmm1
  40b196:	66 48 0f 6e d0       	movq   %rax,%xmm2
  40b19b:	41 b8 00 00 00 00    	mov    $0x0,%r8d
  40b1a1:	b9 28 6b 6e 4e       	mov    $0x4e6e6b28,%ecx
  40b1a6:	ba 28 6b 6e 4e       	mov    $0x4e6e6b28,%edx
  40b1ab:	49 89 f7             	mov    %rsi,%r15
  40b1ae:	be 09 00 00 00       	mov    $0x9,%esi
  40b1b3:	49 89 fc             	mov    %rdi,%r12
  40b1b6:	e8 25 bd ff ff       	callq  406ee0 <p126_typed_FID_36_100_105_114_101_99_116_46_110_101_97_114_101_115_116_46_116_>
  40b1bb:	4c 89 e7             	mov    %r12,%rdi
  40b1be:	48 89 85 b8 fd ff ff 	mov    %rax,-0x248(%rbp)
  40b1c5:	f3 0f 10 0d 73 7e 02 00 	movss  0x27e73(%rip),%xmm1        # 433040 <_IO_stdin_used+0x40>
  40b1cd:	f3 0f 10 05 67 7e 02 00 	movss  0x27e67(%rip),%xmm0        # 43303c <_IO_stdin_used+0x3c>
  40b1d5:	49 89 fc             	mov    %rdi,%r12
  40b1d8:	e8 73 ab ff ff       	callq  405d50 <p126_typed_FID_36_100_105_114_101_99_116_46_102_108_>
  40b1dd:	4c 89 e7             	mov    %r12,%rdi
  40b1e0:	49 89 c4             	mov    %rax,%r12
  40b1e3:	f3 0f 10 0d 4d 7e 02 00 	movss  0x27e4d(%rip),%xmm1        # 433038 <_IO_stdin_used+0x38>
  40b1eb:	f3 0f 10 05 41 7e 02 00 	movss  0x27e41(%rip),%xmm0        # 433034 <_IO_stdin_used+0x34>
  40b1f3:	49 89 fe             	mov    %rdi,%r14
  40b1f6:	e8 55 ab ff ff       	callq  405d50 <p126_typed_FID_36_100_105_114_101_99_116_46_102_108_>
  40b1fb:	4c 89 fe             	mov    %r15,%rsi
  40b1fe:	4c 89 f7             	mov    %r14,%rdi
  40b201:	49 95                	xchg   %rax,%r13
  40b203:	49 89 c6             	mov    %rax,%r14
  40b206:	48 8b 85 b8 fd ff ff 	mov    -0x248(%rbp),%rax
  40b20d:	f3 0f 10 8d c0 fd ff ff 	movss  -0x240(%rbp),%xmm1
  40b215:	66 48 0f 6e c0       	movq   %rax,%xmm0
  40b21a:	e8 01 b2 ff ff       	callq  406420 <p126_typed_FID_36_100_105_114_101_99_116_46_115_104_97_100_101_>
  40b21f:	48 89 c1             	mov    %rax,%rcx
  40b222:	4c 89 f0             	mov    %r14,%rax
  40b225:	f3 0f 10 8d b4 fd ff ff 	movss  -0x24c(%rbp),%xmm1
  40b22d:	f3 0f 10 95 b0 fd ff ff 	movss  -0x250(%rbp),%xmm2
  40b235:	4c 89 ad 70 f5 ff ff 	mov    %r13,-0xa90(%rbp)
  40b23c:	48 89 8d 78 f5 ff ff 	mov    %rcx,-0xa88(%rbp)
  40b243:	66 49 0f 6e c5       	movq   %r13,%xmm0
  40b248:	66 48 0f 6e d9       	movq   %rcx,%xmm3
  40b24d:	f3 0f 59 c3          	mulss  %xmm3,%xmm0
  40b251:	66 48 0f 7e c1       	movq   %xmm0,%rcx
  40b256:	89 c9                	mov    %ecx,%ecx
  40b258:	4c 89 a5 70 f5 ff ff 	mov    %r12,-0xa90(%rbp)
  40b25f:	48 89 8d 78 f5 ff ff 	mov    %rcx,-0xa88(%rbp)
  40b266:	66 49 0f 6e c4       	movq   %r12,%xmm0
  40b26b:	66 48 0f 6e d9       	movq   %rcx,%xmm3
  40b270:	f3 0f 58 c3          	addss  %xmm3,%xmm0
  40b274:	66 48 0f 7e c1       	movq   %xmm0,%rcx
  40b279:	89 c9                	mov    %ecx,%ecx
  40b27b:	48 89 9d 70 f5 ff ff 	mov    %rbx,-0xa90(%rbp)
  40b282:	48 89 8d 78 f5 ff ff 	mov    %rcx,-0xa88(%rbp)
  40b289:	66 48 0f 6e c1       	movq   %rcx,%xmm0
  40b28e:	f3 0f 59 c2          	mulss  %xmm2,%xmm0
  40b292:	48 89 c3             	mov    %rax,%rbx
  40b295:	66 48 0f 7e c0       	movq   %xmm0,%rax
  40b29a:	89 c0                	mov    %eax,%eax
  40b29c:	48 89 9d 70 f5 ff ff 	mov    %rbx,-0xa90(%rbp)
  40b2a3:	48 89 85 78 f5 ff ff 	mov    %rax,-0xa88(%rbp)
  40b2aa:	66 48 0f 6e c0       	movq   %rax,%xmm0
  40b2af:	f3 0f 58 c1          	addss  %xmm1,%xmm0
  40b2b3:	66 48 0f 7e c0       	movq   %xmm0,%rax
  40b2b8:	89 c0                	mov    %eax,%eax
  40b2ba:	41 5f                	pop    %r15
  40b2bc:	41 5e                	pop    %r14
  40b2be:	41 5d                	pop    %r13
  40b2c0:	41 5c                	pop    %r12
  40b2c2:	5b                   	pop    %rbx
  40b2c3:	c9                   	leaveq 
  40b2c4:	c3                   	retq   
  40b2c5:	66 66 2e 0f 1f 84 00 00 00 00 00 	data16 nopw %cs:0x0(%rax,%rax,1)

