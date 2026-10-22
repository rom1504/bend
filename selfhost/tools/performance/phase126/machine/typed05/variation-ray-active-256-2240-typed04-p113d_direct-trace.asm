00000000004098a0 <p113d_FID_36_100_105_114_101_99_116_46_116_114_97_99_101_>:
  4098a0:	f3 0f 1e fa          	endbr64 
  4098a4:	55                   	push   %rbp
  4098a5:	48 89 e5             	mov    %rsp,%rbp
  4098a8:	48 81 ec 98 0a 00 00 	sub    $0xa98,%rsp
  4098af:	53                   	push   %rbx
  4098b0:	41 54                	push   %r12
  4098b2:	41 55                	push   %r13
  4098b4:	41 56                	push   %r14
  4098b6:	41 57                	push   %r15
  4098b8:	48 8b 5d 30          	mov    0x30(%rbp),%rbx
  4098bc:	48 89 9d e8 fe ff ff 	mov    %rbx,-0x118(%rbp)
  4098c3:	48 8b 45 28          	mov    0x28(%rbp),%rax
  4098c7:	4c 8b 75 20          	mov    0x20(%rbp),%r14
  4098cb:	4c 8b 65 18          	mov    0x18(%rbp),%r12
  4098cf:	4c 8b 7d 10          	mov    0x10(%rbp),%r15
  4098d3:	4d 89 c2             	mov    %r8,%r10
  4098d6:	4d 89 c8             	mov    %r9,%r8
  4098d9:	49 89 cb             	mov    %rcx,%r11
  4098dc:	48 87 d6             	xchg   %rdx,%rsi
  4098df:	4c 87 e2             	xchg   %r12,%rdx
  4098e2:	4c 89 85 a8 fe ff ff 	mov    %r8,-0x158(%rbp)
  4098e9:	4c 89 95 c0 fe ff ff 	mov    %r10,-0x140(%rbp)
  4098f0:	4c 89 9d d0 fe ff ff 	mov    %r11,-0x130(%rbp)
  4098f7:	4c 89 a5 40 ff ff ff 	mov    %r12,-0xc0(%rbp)
  4098fe:	49 83 fc 00          	cmp    $0x0,%r12
  409902:	0f 94 c1             	sete   %cl
  409905:	0f b6 c9             	movzbl %cl,%ecx
  409908:	66 49 0f 6e f7       	movq   %r15,%xmm6
  40990d:	f3 0f 11 b5 e4 fe ff ff 	movss  %xmm6,-0x11c(%rbp)
  409915:	66 49 0f 6e cb       	movq   %r11,%xmm1
  40991a:	f3 0f 11 8d f8 fe ff ff 	movss  %xmm1,-0x108(%rbp)
  409922:	66 48 0f 6e ea       	movq   %rdx,%xmm5
  409927:	f3 0f 11 ad f0 fe ff ff 	movss  %xmm5,-0x110(%rbp)
  40992f:	66 49 0f 6e d2       	movq   %r10,%xmm2
  409934:	f3 0f 11 95 fc fe ff ff 	movss  %xmm2,-0x104(%rbp)
  40993c:	66 49 0f 6e e6       	movq   %r14,%xmm4
  409941:	f3 0f 11 a5 f4 fe ff ff 	movss  %xmm4,-0x10c(%rbp)
  409949:	66 49 0f 6e d8       	movq   %r8,%xmm3
  40994e:	f3 0f 11 9d 00 ff ff ff 	movss  %xmm3,-0x100(%rbp)
  409956:	66 48 0f 6e d3       	movq   %rbx,%xmm2
  40995b:	f3 0f 11 95 b0 fd ff ff 	movss  %xmm2,-0x250(%rbp)
  409963:	66 48 0f 6e c8       	movq   %rax,%xmm1
  409968:	f3 0f 11 8d b4 fd ff ff 	movss  %xmm1,-0x24c(%rbp)
  409970:	48 89 c3             	mov    %rax,%rbx
  409973:	48 89 f0             	mov    %rsi,%rax
  409976:	48 c1 e8 28          	shr    $0x28,%rax
  40997a:	48 25 ff ff 00 00    	and    $0xffff,%rax
  409980:	41 b8 00 00 00 41    	mov    $0x41000000,%r8d
  409986:	4c 89 85 58 fe ff ff 	mov    %r8,-0x1a8(%rbp)
  40998d:	41 b8 cd cc 4c 3e    	mov    $0x3e4ccccd,%r8d
  409993:	4c 89 85 90 fe ff ff 	mov    %r8,-0x170(%rbp)
  40999a:	41 b8 00 00 60 c0    	mov    $0xc0600000,%r8d
  4099a0:	4c 89 85 a0 fe ff ff 	mov    %r8,-0x160(%rbp)
  4099a7:	41 ba 00 00 80 3f    	mov    $0x3f800000,%r10d
  4099ad:	4c 89 95 d8 fe ff ff 	mov    %r10,-0x128(%rbp)
  4099b4:	83 f9 00             	cmp    $0x0,%ecx
  4099b7:	0f 85 b3 0d 00 00    	jne    40a770 <p113d_FID_36_100_105_114_101_99_116_46_116_114_97_99_101_+0xed0>
  4099bd:	0f 1f 00             	nopl   (%rax)
  4099c0:	48 3d 97 00 00 00    	cmp    $0x97,%rax
  4099c6:	74 14                	je     4099dc <p113d_FID_36_100_105_114_101_99_116_46_116_114_97_99_101_+0x13c>
  4099c8:	be 04 00 00 00       	mov    $0x4,%esi
  4099cd:	e8 ce 19 02 00       	callq  42b3a0 <p111_rt_fail>
  4099d2:	b8 00 00 00 00       	mov    $0x0,%eax
  4099d7:	e9 1e 1a 00 00       	jmpq   40b3fa <p113d_FID_36_100_105_114_101_99_116_46_116_114_97_99_101_+0x1b5a>
  4099dc:	49 89 d5             	mov    %rdx,%r13
  4099df:	48 8d 95 70 f5 ff ff 	lea    -0xa90(%rbp),%rdx
  4099e6:	49 89 fc             	mov    %rdi,%r12
  4099e9:	e8 32 6c 02 00       	callq  430620 <p125_rt_take3>
  4099ee:	4c 89 ea             	mov    %r13,%rdx
  4099f1:	4c 89 e7             	mov    %r12,%rdi
  4099f4:	48 89 d8             	mov    %rbx,%rax
  4099f7:	48 8b 8d 70 f5 ff ff 	mov    -0xa90(%rbp),%rcx
  4099fe:	49 89 d5             	mov    %rdx,%r13
  409a01:	48 8b 95 78 f5 ff ff 	mov    -0xa88(%rbp),%rdx
  409a08:	48 89 55 f0          	mov    %rdx,-0x10(%rbp)
  409a0c:	48 8b b5 80 f5 ff ff 	mov    -0xa80(%rbp),%rsi
  409a13:	48 89 b5 50 ff ff ff 	mov    %rsi,-0xb0(%rbp)
  409a1a:	48 83 f9 01          	cmp    $0x1,%rcx
  409a1e:	48 89 c3             	mov    %rax,%rbx
  409a21:	0f 94 c0             	sete   %al
  409a24:	0f b6 c0             	movzbl %al,%eax
  409a27:	48 c1 e9 28          	shr    $0x28,%rcx
  409a2b:	48 81 e1 ff ff 7f 00 	and    $0x7fffff,%rcx
  409a32:	48 81 f9 02 00 01 00 	cmp    $0x10002,%rcx
  409a39:	0f 94 c1             	sete   %cl
  409a3c:	0f b6 c9             	movzbl %cl,%ecx
  409a3f:	09 c8                	or     %ecx,%eax
  409a41:	0f 85 1e 0d 00 00    	jne    40a765 <p113d_FID_36_100_105_114_101_99_116_46_116_114_97_99_101_+0xec5>
  409a47:	83 f0 01             	xor    $0x1,%eax
  409a4a:	75 19                	jne    409a65 <p113d_FID_36_100_105_114_101_99_116_46_116_114_97_99_101_+0x1c5>
  409a4c:	2e 2e 2e 2e 2e be 04 00 00 00 	cs cs cs cs cs mov $0x4,%esi
  409a56:	e8 45 19 02 00       	callq  42b3a0 <p111_rt_fail>
  409a5b:	b8 00 00 00 00       	mov    $0x0,%eax
  409a60:	e9 95 19 00 00       	jmpq   40b3fa <p113d_FID_36_100_105_114_101_99_116_46_116_114_97_99_101_+0x1b5a>
  409a65:	2e 2e 2e 2e 49 89 fc 	cs cs cs cs mov %rdi,%r12
  409a6c:	e8 0f ca ff ff       	callq  406480 <p113d_FID_36_100_105_114_101_99_116_46_115_114_>
  409a71:	2e 4d 89 f9          	cs mov %r15,%r9
  409a75:	4c 89 e7             	mov    %r12,%rdi
  409a78:	48 89 45 e0          	mov    %rax,-0x20(%rbp)
  409a7c:	48 89 d8             	mov    %rbx,%rax
  409a7f:	f3 0f 10 9d 00 ff ff ff 	movss  -0x100(%rbp),%xmm3
  409a87:	f3 0f 10 a5 f4 fe ff ff 	movss  -0x10c(%rbp),%xmm4
  409a8f:	f3 0f 10 95 fc fe ff ff 	movss  -0x104(%rbp),%xmm2
  409a97:	f3 0f 10 ad f0 fe ff ff 	movss  -0x110(%rbp),%xmm5
  409a9f:	f3 0f 10 8d f8 fe ff ff 	movss  -0x108(%rbp),%xmm1
  409aa7:	f3 0f 10 b5 e4 fe ff ff 	movss  -0x11c(%rbp),%xmm6
  409aaf:	48 8b b5 50 ff ff ff 	mov    -0xb0(%rbp),%rsi
  409ab6:	48 8b 4d f0          	mov    -0x10(%rbp),%rcx
  409aba:	48 8b 95 a8 fe ff ff 	mov    -0x158(%rbp),%rdx
  409ac1:	4c 8b 95 c0 fe ff ff 	mov    -0x140(%rbp),%r10
  409ac8:	4c 8b 9d d0 fe ff ff 	mov    -0x130(%rbp),%r11
  409acf:	48 89 8d 70 f5 ff ff 	mov    %rcx,-0xa90(%rbp)
  409ad6:	4c 89 8d 78 f5 ff ff 	mov    %r9,-0xa88(%rbp)
  409add:	66 48 0f 6e c1       	movq   %rcx,%xmm0
  409ae2:	f3 0f 59 f0          	mulss  %xmm0,%xmm6
  409ae6:	66 49 0f 7e f0       	movq   %xmm6,%r8
  409aeb:	45 89 c0             	mov    %r8d,%r8d
  409aee:	4c 89 9d 70 f5 ff ff 	mov    %r11,-0xa90(%rbp)
  409af5:	4c 89 85 78 f5 ff ff 	mov    %r8,-0xa88(%rbp)
  409afc:	66 49 0f 6e f0       	movq   %r8,%xmm6
  409b01:	f3 0f 58 ce          	addss  %xmm6,%xmm1
  409b05:	66 49 0f 7e c8       	movq   %xmm1,%r8
  409b0a:	45 89 c0             	mov    %r8d,%r8d
  409b0d:	4c 89 45 b0          	mov    %r8,-0x50(%rbp)
  409b11:	48 89 8d 70 f5 ff ff 	mov    %rcx,-0xa90(%rbp)
  409b18:	4c 89 ad 78 f5 ff ff 	mov    %r13,-0xa88(%rbp)
  409b1f:	f3 0f 10 c8          	movss  %xmm0,%xmm1
  409b23:	f3 0f 59 cd          	mulss  %xmm5,%xmm1
  409b27:	66 49 0f 7e c8       	movq   %xmm1,%r8
  409b2c:	45 89 c0             	mov    %r8d,%r8d
  409b2f:	4c 89 95 70 f5 ff ff 	mov    %r10,-0xa90(%rbp)
  409b36:	4c 89 85 78 f5 ff ff 	mov    %r8,-0xa88(%rbp)
  409b3d:	66 49 0f 6e c8       	movq   %r8,%xmm1
  409b42:	f3 0f 58 ca          	addss  %xmm2,%xmm1
  409b46:	66 49 0f 7e c8       	movq   %xmm1,%r8
  409b4b:	45 89 c0             	mov    %r8d,%r8d
  409b4e:	4c 89 45 a8          	mov    %r8,-0x58(%rbp)
  409b52:	48 89 8d 70 f5 ff ff 	mov    %rcx,-0xa90(%rbp)
  409b59:	4c 89 b5 78 f5 ff ff 	mov    %r14,-0xa88(%rbp)
  409b60:	f3 0f 59 c4          	mulss  %xmm4,%xmm0
  409b64:	66 48 0f 7e c1       	movq   %xmm0,%rcx
  409b69:	89 c9                	mov    %ecx,%ecx
  409b6b:	48 89 95 70 f5 ff ff 	mov    %rdx,-0xa90(%rbp)
  409b72:	48 89 8d 78 f5 ff ff 	mov    %rcx,-0xa88(%rbp)
  409b79:	66 48 0f 6e c1       	movq   %rcx,%xmm0
  409b7e:	f3 0f 58 c3          	addss  %xmm3,%xmm0
  409b82:	48 89 c3             	mov    %rax,%rbx
  409b85:	66 48 0f 7e c0       	movq   %xmm0,%rax
  409b8a:	4d 89 cf             	mov    %r9,%r15
  409b8d:	41 89 c1             	mov    %eax,%r9d
  409b90:	4c 89 4d 80          	mov    %r9,-0x80(%rbp)
  409b94:	49 89 fc             	mov    %rdi,%r12
  409b97:	e8 54 cb ff ff       	callq  4066f0 <p113d_FID_36_100_105_114_101_99_116_46_115_120_>
  409b9c:	4c 89 ea             	mov    %r13,%rdx
  409b9f:	4c 89 e7             	mov    %r12,%rdi
  409ba2:	48 89 c1             	mov    %rax,%rcx
  409ba5:	48 89 d8             	mov    %rbx,%rax
  409ba8:	49 89 d5             	mov    %rdx,%r13
  409bab:	48 8b 55 b0          	mov    -0x50(%rbp),%rdx
  409baf:	4c 8b 55 e0          	mov    -0x20(%rbp),%r10
  409bb3:	48 8b b5 50 ff ff ff 	mov    -0xb0(%rbp),%rsi
  409bba:	48 89 95 70 f5 ff ff 	mov    %rdx,-0xa90(%rbp)
  409bc1:	48 89 8d 78 f5 ff ff 	mov    %rcx,-0xa88(%rbp)
  409bc8:	66 48 0f 6e c2       	movq   %rdx,%xmm0
  409bcd:	f3 0f 11 45 b8       	movss  %xmm0,-0x48(%rbp)
  409bd2:	66 48 0f 6e c9       	movq   %rcx,%xmm1
  409bd7:	f3 0f 5c c1          	subss  %xmm1,%xmm0
  409bdb:	66 48 0f 7e c1       	movq   %xmm0,%rcx
  409be0:	89 c9                	mov    %ecx,%ecx
  409be2:	48 89 8d 70 f5 ff ff 	mov    %rcx,-0xa90(%rbp)
  409be9:	4c 89 95 78 f5 ff ff 	mov    %r10,-0xa88(%rbp)
  409bf0:	66 48 0f 6e c1       	movq   %rcx,%xmm0
  409bf5:	66 49 0f 6e e2       	movq   %r10,%xmm4
  409bfa:	f3 0f 11 65 e8       	movss  %xmm4,-0x18(%rbp)
  409bff:	f3 0f 5e c4          	divss  %xmm4,%xmm0
  409c03:	48 89 c3             	mov    %rax,%rbx
  409c06:	66 48 0f 7e c0       	movq   %xmm0,%rax
  409c0b:	89 c0                	mov    %eax,%eax
  409c0d:	48 89 85 28 ff ff ff 	mov    %rax,-0xd8(%rbp)
  409c14:	49 89 fc             	mov    %rdi,%r12
  409c17:	e8 04 ca ff ff       	callq  406620 <p113d_FID_36_100_105_114_101_99_116_46_115_121_>
  409c1c:	4d 89 f9             	mov    %r15,%r9
  409c1f:	4c 89 ea             	mov    %r13,%rdx
  409c22:	4c 89 e7             	mov    %r12,%rdi
  409c25:	48 89 c1             	mov    %rax,%rcx
  409c28:	48 89 d8             	mov    %rbx,%rax
  409c2b:	49 89 d5             	mov    %rdx,%r13
  409c2e:	48 8b 55 a8          	mov    -0x58(%rbp),%rdx
  409c32:	f3 0f 10 65 e8       	movss  -0x18(%rbp),%xmm4
  409c37:	4c 8b 55 e0          	mov    -0x20(%rbp),%r10
  409c3b:	48 8b b5 50 ff ff ff 	mov    -0xb0(%rbp),%rsi
  409c42:	48 89 95 70 f5 ff ff 	mov    %rdx,-0xa90(%rbp)
  409c49:	48 89 8d 78 f5 ff ff 	mov    %rcx,-0xa88(%rbp)
  409c50:	66 48 0f 6e c2       	movq   %rdx,%xmm0
  409c55:	f3 0f 11 45 a4       	movss  %xmm0,-0x5c(%rbp)
  409c5a:	f3 0f 10 c8          	movss  %xmm0,%xmm1
  409c5e:	66 48 0f 6e c1       	movq   %rcx,%xmm0
  409c63:	0f 57 05 a6 73 02 00 	xorps  0x273a6(%rip),%xmm0        # 431010 <_IO_stdin_used+0x10>
  409c6a:	f3 0f 58 c1          	addss  %xmm1,%xmm0
  409c6e:	66 48 0f 7e c1       	movq   %xmm0,%rcx
  409c73:	89 c9                	mov    %ecx,%ecx
  409c75:	48 89 8d 70 f5 ff ff 	mov    %rcx,-0xa90(%rbp)
  409c7c:	4c 89 95 78 f5 ff ff 	mov    %r10,-0xa88(%rbp)
  409c83:	66 48 0f 6e c1       	movq   %rcx,%xmm0
  409c88:	f3 0f 5e c4          	divss  %xmm4,%xmm0
  409c8c:	48 89 c3             	mov    %rax,%rbx
  409c8f:	66 48 0f 7e c0       	movq   %xmm0,%rax
  409c94:	4d 89 cf             	mov    %r9,%r15
  409c97:	41 89 c1             	mov    %eax,%r9d
  409c9a:	4c 89 8d 30 ff ff ff 	mov    %r9,-0xd0(%rbp)
  409ca1:	49 89 fc             	mov    %rdi,%r12
  409ca4:	e8 a7 c8 ff ff       	callq  406550 <p113d_FID_36_100_105_114_101_99_116_46_115_122_>
  409ca9:	4d 89 f9             	mov    %r15,%r9
  409cac:	4c 89 ea             	mov    %r13,%rdx
  409caf:	4c 89 e7             	mov    %r12,%rdi
  409cb2:	49 89 c0             	mov    %rax,%r8
  409cb5:	48 89 d8             	mov    %rbx,%rax
  409cb8:	4d 89 cf             	mov    %r9,%r15
  409cbb:	4c 8b 4d 80          	mov    -0x80(%rbp),%r9
  409cbf:	48 8b 4d a8          	mov    -0x58(%rbp),%rcx
  409cc3:	48 8b 75 b0          	mov    -0x50(%rbp),%rsi
  409cc7:	f3 0f 10 4d a4       	movss  -0x5c(%rbp),%xmm1
  409ccc:	f3 0f 10 65 e8       	movss  -0x18(%rbp),%xmm4
  409cd1:	f3 0f 10 45 b8       	movss  -0x48(%rbp),%xmm0
  409cd6:	4c 8b 55 e0          	mov    -0x20(%rbp),%r10
  409cda:	4c 89 8d 70 f5 ff ff 	mov    %r9,-0xa90(%rbp)
  409ce1:	4c 89 85 78 f5 ff ff 	mov    %r8,-0xa88(%rbp)
  409ce8:	f3 0f 10 d0          	movss  %xmm0,%xmm2
  409cec:	66 49 0f 6e c1       	movq   %r9,%xmm0
  409cf1:	f3 0f 11 85 7c ff ff ff 	movss  %xmm0,-0x84(%rbp)
  409cf9:	66 49 0f 6e d8       	movq   %r8,%xmm3
  409cfe:	0f 57 1d 0b 73 02 00 	xorps  0x2730b(%rip),%xmm3        # 431010 <_IO_stdin_used+0x10>
  409d05:	f3 0f 58 d8          	addss  %xmm0,%xmm3
  409d09:	66 49 0f 7e d8       	movq   %xmm3,%r8
  409d0e:	45 89 c0             	mov    %r8d,%r8d
  409d11:	4c 89 85 70 f5 ff ff 	mov    %r8,-0xa90(%rbp)
  409d18:	4c 89 95 78 f5 ff ff 	mov    %r10,-0xa88(%rbp)
  409d1f:	66 49 0f 6e d8       	movq   %r8,%xmm3
  409d24:	f3 0f 5e dc          	divss  %xmm4,%xmm3
  409d28:	66 49 0f 7e d8       	movq   %xmm3,%r8
  409d2d:	45 89 c0             	mov    %r8d,%r8d
  409d30:	4c 89 85 38 ff ff ff 	mov    %r8,-0xc8(%rbp)
  409d37:	48 c7 85 70 f5 ff ff 00 00 00 00 	movq   $0x0,-0xa90(%rbp)
  409d42:	48 c7 85 70 f5 ff ff 03 00 00 00 	movq   $0x3,-0xa90(%rbp)
  409d4d:	48 c7 85 70 f5 ff ff 00 00 00 00 	movq   $0x0,-0xa90(%rbp)
  409d58:	48 c7 85 78 f5 ff ff 00 00 40 40 	movq   $0x40400000,-0xa88(%rbp)
  409d63:	41 b8 00 00 40 c0    	mov    $0xc0400000,%r8d
  409d69:	4c 89 85 70 f5 ff ff 	mov    %r8,-0xa90(%rbp)
  409d70:	48 89 b5 78 f5 ff ff 	mov    %rsi,-0xa88(%rbp)
  409d77:	0f 57 15 92 72 02 00 	xorps  0x27292(%rip),%xmm2        # 431010 <_IO_stdin_used+0x10>
  409d7e:	f3 0f 58 15 aa 72 02 00 	addss  0x272aa(%rip),%xmm2        # 431030 <_IO_stdin_used+0x30>
  409d86:	66 48 0f 7e d6       	movq   %xmm2,%rsi
  409d8b:	41 89 f0             	mov    %esi,%r8d
  409d8e:	4c 89 45 c0          	mov    %r8,-0x40(%rbp)
  409d92:	48 c7 85 70 f5 ff ff 08 00 00 00 	movq   $0x8,-0xa90(%rbp)
  409d9d:	48 c7 85 70 f5 ff ff 00 00 00 41 	movq   $0x41000000,-0xa90(%rbp)
  409da8:	48 89 8d 78 f5 ff ff 	mov    %rcx,-0xa88(%rbp)
  409daf:	0f 57 0d 5a 72 02 00 	xorps  0x2725a(%rip),%xmm1        # 431010 <_IO_stdin_used+0x10>
  409db6:	f3 0f 58 0d 6e 72 02 00 	addss  0x2726e(%rip),%xmm1        # 43102c <_IO_stdin_used+0x2c>
  409dbe:	66 48 0f 7e c9       	movq   %xmm1,%rcx
  409dc3:	41 89 cb             	mov    %ecx,%r11d
  409dc6:	4c 89 5d c8          	mov    %r11,-0x38(%rbp)
  409dca:	48 c7 85 70 f5 ff ff 01 00 00 00 	movq   $0x1,-0xa90(%rbp)
  409dd5:	48 c7 85 70 f5 ff ff 00 00 80 3f 	movq   $0x3f800000,-0xa90(%rbp)
  409de0:	4c 89 8d 78 f5 ff ff 	mov    %r9,-0xa88(%rbp)
  409de7:	0f 57 05 22 72 02 00 	xorps  0x27222(%rip),%xmm0        # 431010 <_IO_stdin_used+0x10>
  409dee:	f3 0f 58 05 2a 72 02 00 	addss  0x2722a(%rip),%xmm0        # 431020 <_IO_stdin_used+0x20>
  409df6:	66 48 0f 7e c1       	movq   %xmm0,%rcx
  409dfb:	89 cb                	mov    %ecx,%ebx
  409dfd:	48 89 5d d0          	mov    %rbx,-0x30(%rbp)
  409e01:	4c 89 85 70 f5 ff ff 	mov    %r8,-0xa90(%rbp)
  409e08:	4c 89 85 78 f5 ff ff 	mov    %r8,-0xa88(%rbp)
  409e0f:	66 49 0f 6e d8       	movq   %r8,%xmm3
  409e14:	f3 0f 11 5d bc       	movss  %xmm3,-0x44(%rbp)
  409e19:	f3 0f 10 c3          	movss  %xmm3,%xmm0
  409e1d:	f3 0f 59 c3          	mulss  %xmm3,%xmm0
  409e21:	66 48 0f 7e c1       	movq   %xmm0,%rcx
  409e26:	89 ce                	mov    %ecx,%esi
  409e28:	4c 89 9d 70 f5 ff ff 	mov    %r11,-0xa90(%rbp)
  409e2f:	4c 89 9d 78 f5 ff ff 	mov    %r11,-0xa88(%rbp)
  409e36:	66 49 0f 6e d3       	movq   %r11,%xmm2
  409e3b:	f3 0f 11 55 d8       	movss  %xmm2,-0x28(%rbp)
  409e40:	f3 0f 10 c2          	movss  %xmm2,%xmm0
  409e44:	f3 0f 59 c2          	mulss  %xmm2,%xmm0
  409e48:	66 48 0f 7e c1       	movq   %xmm0,%rcx
  409e4d:	89 c9                	mov    %ecx,%ecx
  409e4f:	48 89 b5 70 f5 ff ff 	mov    %rsi,-0xa90(%rbp)
  409e56:	48 89 8d 78 f5 ff ff 	mov    %rcx,-0xa88(%rbp)
  409e5d:	66 48 0f 6e c6       	movq   %rsi,%xmm0
  409e62:	66 48 0f 6e c9       	movq   %rcx,%xmm1
  409e67:	f3 0f 58 c1          	addss  %xmm1,%xmm0
  409e6b:	66 48 0f 7e c1       	movq   %xmm0,%rcx
  409e70:	89 ce                	mov    %ecx,%esi
  409e72:	48 89 9d 70 f5 ff ff 	mov    %rbx,-0xa90(%rbp)
  409e79:	48 89 9d 78 f5 ff ff 	mov    %rbx,-0xa88(%rbp)
  409e80:	66 48 0f 6e c3       	movq   %rbx,%xmm0
  409e85:	f3 0f 11 45 dc       	movss  %xmm0,-0x24(%rbp)
  409e8a:	f3 0f 59 c0          	mulss  %xmm0,%xmm0
  409e8e:	66 48 0f 7e c1       	movq   %xmm0,%rcx
  409e93:	89 c9                	mov    %ecx,%ecx
  409e95:	48 89 b5 70 f5 ff ff 	mov    %rsi,-0xa90(%rbp)
  409e9c:	48 89 8d 78 f5 ff ff 	mov    %rcx,-0xa88(%rbp)
  409ea3:	66 48 0f 6e c6       	movq   %rsi,%xmm0
  409ea8:	66 48 0f 6e c9       	movq   %rcx,%xmm1
  409ead:	f3 0f 58 c1          	addss  %xmm1,%xmm0
  409eb1:	48 89 c3             	mov    %rax,%rbx
  409eb4:	66 48 0f 7e c0       	movq   %xmm0,%rax
  409eb9:	89 c0                	mov    %eax,%eax
  409ebb:	48 89 85 70 f5 ff ff 	mov    %rax,-0xa90(%rbp)
  409ec2:	b9 01 00 00 00       	mov    $0x1,%ecx
  409ec7:	49 89 d5             	mov    %rdx,%r13
  409eca:	48 8d 95 70 f5 ff ff 	lea    -0xa90(%rbp),%rdx
  409ed1:	be 24 00 00 00       	mov    $0x24,%esi
  409ed6:	49 89 fc             	mov    %rdi,%r12
  409ed9:	e8 e2 14 02 00       	callq  42b3c0 <p111_rt_op>
  409ede:	4d 89 f9             	mov    %r15,%r9
  409ee1:	4c 89 ea             	mov    %r13,%rdx
  409ee4:	4c 89 e7             	mov    %r12,%rdi
  409ee7:	49 89 c2             	mov    %rax,%r10
  409eea:	48 89 d8             	mov    %rbx,%rax
  409eed:	48 8b 5d d0          	mov    -0x30(%rbp),%rbx
  409ef1:	4c 8b 5d c8          	mov    -0x38(%rbp),%r11
  409ef5:	4c 8b 45 c0          	mov    -0x40(%rbp),%r8
  409ef9:	48 8b 8d 38 ff ff ff 	mov    -0xc8(%rbp),%rcx
  409f00:	4d 89 cf             	mov    %r9,%r15
  409f03:	4c 8b 8d 30 ff ff ff 	mov    -0xd0(%rbp),%r9
  409f0a:	48 8b b5 28 ff ff ff 	mov    -0xd8(%rbp),%rsi
  409f11:	f3 0f 10 45 dc       	movss  -0x24(%rbp),%xmm0
  409f16:	f3 0f 10 55 d8       	movss  -0x28(%rbp),%xmm2
  409f1b:	f3 0f 10 5d bc       	movss  -0x44(%rbp),%xmm3
  409f20:	4c 89 85 70 f5 ff ff 	mov    %r8,-0xa90(%rbp)
  409f27:	4c 89 95 78 f5 ff ff 	mov    %r10,-0xa88(%rbp)
  409f2e:	66 49 0f 6e ca       	movq   %r10,%xmm1
  409f33:	f3 0f 11 8d 78 ff ff ff 	movss  %xmm1,-0x88(%rbp)
  409f3b:	f3 0f 5e d9          	divss  %xmm1,%xmm3
  409f3f:	66 49 0f 7e d8       	movq   %xmm3,%r8
  409f44:	45 89 c0             	mov    %r8d,%r8d
  409f47:	4c 89 9d 70 f5 ff ff 	mov    %r11,-0xa90(%rbp)
  409f4e:	4c 89 95 78 f5 ff ff 	mov    %r10,-0xa88(%rbp)
  409f55:	f3 0f 5e d1          	divss  %xmm1,%xmm2
  409f59:	49 89 f3             	mov    %rsi,%r11
  409f5c:	66 48 0f 7e d6       	movq   %xmm2,%rsi
  409f61:	89 f6                	mov    %esi,%esi
  409f63:	48 89 9d 70 f5 ff ff 	mov    %rbx,-0xa90(%rbp)
  409f6a:	4c 89 95 78 f5 ff ff 	mov    %r10,-0xa88(%rbp)
  409f71:	f3 0f 5e c1          	divss  %xmm1,%xmm0
  409f75:	49 89 ca             	mov    %rcx,%r10
  409f78:	66 48 0f 7e c1       	movq   %xmm0,%rcx
  409f7d:	89 c9                	mov    %ecx,%ecx
  409f7f:	4c 89 9d 70 f5 ff ff 	mov    %r11,-0xa90(%rbp)
  409f86:	4c 89 85 78 f5 ff ff 	mov    %r8,-0xa88(%rbp)
  409f8d:	66 4d 0f 6e cb       	movq   %r11,%xmm9
  409f92:	f3 44 0f 11 8d 24 ff ff ff 	movss  %xmm9,-0xdc(%rbp)
  409f9b:	66 49 0f 6e d8       	movq   %r8,%xmm3
  409fa0:	f3 0f 11 5d 98       	movss  %xmm3,-0x68(%rbp)
  409fa5:	f3 41 0f 10 c1       	movss  %xmm9,%xmm0
  409faa:	f3 0f 59 c3          	mulss  %xmm3,%xmm0
  409fae:	66 49 0f 7e c0       	movq   %xmm0,%r8
  409fb3:	45 89 c0             	mov    %r8d,%r8d
  409fb6:	4c 89 8d 70 f5 ff ff 	mov    %r9,-0xa90(%rbp)
  409fbd:	48 89 b5 78 f5 ff ff 	mov    %rsi,-0xa88(%rbp)
  409fc4:	66 49 0f 6e f9       	movq   %r9,%xmm7
  409fc9:	f3 0f 11 bd 48 ff ff ff 	movss  %xmm7,-0xb8(%rbp)
  409fd1:	66 48 0f 6e e6       	movq   %rsi,%xmm4
  409fd6:	f3 0f 11 65 9c       	movss  %xmm4,-0x64(%rbp)
  409fdb:	f3 0f 10 c7          	movss  %xmm7,%xmm0
  409fdf:	f3 0f 59 c4          	mulss  %xmm4,%xmm0
  409fe3:	66 48 0f 7e c6       	movq   %xmm0,%rsi
  409fe8:	89 f6                	mov    %esi,%esi
  409fea:	4c 89 85 70 f5 ff ff 	mov    %r8,-0xa90(%rbp)
  409ff1:	48 89 b5 78 f5 ff ff 	mov    %rsi,-0xa88(%rbp)
  409ff8:	66 49 0f 6e c0       	movq   %r8,%xmm0
  409ffd:	66 48 0f 6e ce       	movq   %rsi,%xmm1
  40a002:	f3 0f 58 c1          	addss  %xmm1,%xmm0
  40a006:	49 89 d5             	mov    %rdx,%r13
  40a009:	66 48 0f 7e c2       	movq   %xmm0,%rdx
  40a00e:	89 d2                	mov    %edx,%edx
  40a010:	4c 89 95 70 f5 ff ff 	mov    %r10,-0xa90(%rbp)
  40a017:	48 89 8d 78 f5 ff ff 	mov    %rcx,-0xa88(%rbp)
  40a01e:	66 49 0f 6e ca       	movq   %r10,%xmm1
  40a023:	f3 0f 11 8d 4c ff ff ff 	movss  %xmm1,-0xb4(%rbp)
  40a02b:	66 48 0f 6e e9       	movq   %rcx,%xmm5
  40a030:	f3 0f 11 6d a0       	movss  %xmm5,-0x60(%rbp)
  40a035:	f3 0f 10 c1          	movss  %xmm1,%xmm0
  40a039:	f3 0f 59 c5          	mulss  %xmm5,%xmm0
  40a03d:	66 48 0f 7e c1       	movq   %xmm0,%rcx
  40a042:	89 c9                	mov    %ecx,%ecx
  40a044:	48 89 95 70 f5 ff ff 	mov    %rdx,-0xa90(%rbp)
  40a04b:	48 89 8d 78 f5 ff ff 	mov    %rcx,-0xa88(%rbp)
  40a052:	66 48 0f 6e c2       	movq   %rdx,%xmm0
  40a057:	66 48 0f 6e c9       	movq   %rcx,%xmm1
  40a05c:	f3 0f 58 c1          	addss  %xmm1,%xmm0
  40a060:	48 89 c3             	mov    %rax,%rbx
  40a063:	66 48 0f 7e c0       	movq   %xmm0,%rax
  40a068:	89 c6                	mov    %eax,%esi
  40a06a:	49 89 fc             	mov    %rdi,%r12
  40a06d:	e8 4e bc ff ff       	callq  405cc0 <p113d_FID_36_100_105_114_101_99_116_46_102_109_97_120_48_>
  40a072:	4c 89 e7             	mov    %r12,%rdi
  40a075:	48 89 85 68 ff ff ff 	mov    %rax,-0x98(%rbp)
  40a07c:	f3 0f 10 0d c0 6f 02 00 	movss  0x26fc0(%rip),%xmm1        # 431044 <_IO_stdin_used+0x44>
  40a084:	f3 0f 10 05 b0 6f 02 00 	movss  0x26fb0(%rip),%xmm0        # 43103c <_IO_stdin_used+0x3c>
  40a08c:	49 89 fc             	mov    %rdi,%r12
  40a08f:	e8 bc bc ff ff       	callq  405d50 <p126_typed_FID_36_100_105_114_101_99_116_46_102_108_>
  40a094:	4c 89 ea             	mov    %r13,%rdx
  40a097:	4c 89 e7             	mov    %r12,%rdi
  40a09a:	48 89 c1             	mov    %rax,%rcx
  40a09d:	48 89 d8             	mov    %rbx,%rax
  40a0a0:	48 8b b5 28 ff ff ff 	mov    -0xd8(%rbp),%rsi
  40a0a7:	49 89 d5             	mov    %rdx,%r13
  40a0aa:	48 8b 55 b0          	mov    -0x50(%rbp),%rdx
  40a0ae:	f3 44 0f 10 8d 24 ff ff ff 	movss  -0xdc(%rbp),%xmm9
  40a0b7:	f3 0f 10 45 b8       	movss  -0x48(%rbp),%xmm0
  40a0bc:	48 89 8d 70 f5 ff ff 	mov    %rcx,-0xa90(%rbp)
  40a0c3:	48 89 b5 78 f5 ff ff 	mov    %rsi,-0xa88(%rbp)
  40a0ca:	66 48 0f 6e c9       	movq   %rcx,%xmm1
  40a0cf:	f3 41 0f 59 c9       	mulss  %xmm9,%xmm1
  40a0d4:	66 48 0f 7e c9       	movq   %xmm1,%rcx
  40a0d9:	89 c9                	mov    %ecx,%ecx
  40a0db:	48 89 95 70 f5 ff ff 	mov    %rdx,-0xa90(%rbp)
  40a0e2:	48 89 8d 78 f5 ff ff 	mov    %rcx,-0xa88(%rbp)
  40a0e9:	66 48 0f 6e c9       	movq   %rcx,%xmm1
  40a0ee:	f3 0f 58 c1          	addss  %xmm1,%xmm0
  40a0f2:	48 89 c3             	mov    %rax,%rbx
  40a0f5:	66 48 0f 7e c0       	movq   %xmm0,%rax
  40a0fa:	89 c6                	mov    %eax,%esi
  40a0fc:	48 89 75 88          	mov    %rsi,-0x78(%rbp)
  40a100:	f3 0f 10 0d 3c 6f 02 00 	movss  0x26f3c(%rip),%xmm1        # 431044 <_IO_stdin_used+0x44>
  40a108:	f3 0f 10 05 2c 6f 02 00 	movss  0x26f2c(%rip),%xmm0        # 43103c <_IO_stdin_used+0x3c>
  40a110:	49 89 fc             	mov    %rdi,%r12
  40a113:	e8 38 bc ff ff       	callq  405d50 <p126_typed_FID_36_100_105_114_101_99_116_46_102_108_>
  40a118:	4d 89 f9             	mov    %r15,%r9
  40a11b:	4c 89 ea             	mov    %r13,%rdx
  40a11e:	4c 89 e7             	mov    %r12,%rdi
  40a121:	48 89 c1             	mov    %rax,%rcx
  40a124:	48 89 d8             	mov    %rbx,%rax
  40a127:	4d 89 cf             	mov    %r9,%r15
  40a12a:	4c 8b 8d 30 ff ff ff 	mov    -0xd0(%rbp),%r9
  40a131:	49 89 d5             	mov    %rdx,%r13
  40a134:	48 8b 55 a8          	mov    -0x58(%rbp),%rdx
  40a138:	f3 0f 10 bd 48 ff ff ff 	movss  -0xb8(%rbp),%xmm7
  40a140:	f3 0f 10 45 a4       	movss  -0x5c(%rbp),%xmm0
  40a145:	48 89 8d 70 f5 ff ff 	mov    %rcx,-0xa90(%rbp)
  40a14c:	4c 89 8d 78 f5 ff ff 	mov    %r9,-0xa88(%rbp)
  40a153:	66 48 0f 6e c9       	movq   %rcx,%xmm1
  40a158:	f3 0f 59 cf          	mulss  %xmm7,%xmm1
  40a15c:	66 48 0f 7e c9       	movq   %xmm1,%rcx
  40a161:	89 c9                	mov    %ecx,%ecx
  40a163:	48 89 95 70 f5 ff ff 	mov    %rdx,-0xa90(%rbp)
  40a16a:	48 89 8d 78 f5 ff ff 	mov    %rcx,-0xa88(%rbp)
  40a171:	66 48 0f 6e c9       	movq   %rcx,%xmm1
  40a176:	f3 0f 58 c1          	addss  %xmm1,%xmm0
  40a17a:	48 89 c3             	mov    %rax,%rbx
  40a17d:	66 48 0f 7e c0       	movq   %xmm0,%rax
  40a182:	89 c1                	mov    %eax,%ecx
  40a184:	48 89 4d 90          	mov    %rcx,-0x70(%rbp)
  40a188:	f3 0f 10 0d b4 6e 02 00 	movss  0x26eb4(%rip),%xmm1        # 431044 <_IO_stdin_used+0x44>
  40a190:	f3 0f 10 05 a4 6e 02 00 	movss  0x26ea4(%rip),%xmm0        # 43103c <_IO_stdin_used+0x3c>
  40a198:	49 89 fc             	mov    %rdi,%r12
  40a19b:	e8 b0 bb ff ff       	callq  405d50 <p126_typed_FID_36_100_105_114_101_99_116_46_102_108_>
  40a1a0:	4d 89 f9             	mov    %r15,%r9
  40a1a3:	4c 89 ea             	mov    %r13,%rdx
  40a1a6:	4c 89 e7             	mov    %r12,%rdi
  40a1a9:	49 89 c0             	mov    %rax,%r8
  40a1ac:	48 89 d8             	mov    %rbx,%rax
  40a1af:	48 8b 4d 90          	mov    -0x70(%rbp),%rcx
  40a1b3:	48 8b 75 88          	mov    -0x78(%rbp),%rsi
  40a1b7:	4c 8b 95 38 ff ff ff 	mov    -0xc8(%rbp),%r10
  40a1be:	4d 89 cf             	mov    %r9,%r15
  40a1c1:	4c 8b 4d 80          	mov    -0x80(%rbp),%r9
  40a1c5:	f3 0f 10 6d a0       	movss  -0x60(%rbp),%xmm5
  40a1ca:	f3 0f 10 8d 4c ff ff ff 	movss  -0xb4(%rbp),%xmm1
  40a1d2:	f3 0f 10 65 9c       	movss  -0x64(%rbp),%xmm4
  40a1d7:	f3 0f 10 5d 98       	movss  -0x68(%rbp),%xmm3
  40a1dc:	f3 0f 10 85 7c ff ff ff 	movss  -0x84(%rbp),%xmm0
  40a1e4:	4c 89 85 70 f5 ff ff 	mov    %r8,-0xa90(%rbp)
  40a1eb:	4c 89 95 78 f5 ff ff 	mov    %r10,-0xa88(%rbp)
  40a1f2:	66 49 0f 6e d0       	movq   %r8,%xmm2
  40a1f7:	f3 0f 59 ca          	mulss  %xmm2,%xmm1
  40a1fb:	66 49 0f 7e c8       	movq   %xmm1,%r8
  40a200:	45 89 c0             	mov    %r8d,%r8d
  40a203:	4c 89 8d 70 f5 ff ff 	mov    %r9,-0xa90(%rbp)
  40a20a:	4c 89 85 78 f5 ff ff 	mov    %r8,-0xa88(%rbp)
  40a211:	66 49 0f 6e c8       	movq   %r8,%xmm1
  40a216:	f3 0f 58 c1          	addss  %xmm1,%xmm0
  40a21a:	48 89 c3             	mov    %rax,%rbx
  40a21d:	66 48 0f 7e c0       	movq   %xmm0,%rax
  40a222:	89 c0                	mov    %eax,%eax
  40a224:	48 c7 85 70 f5 ff ff 00 ca 9a 3b 	movq   $0x3b9aca00,-0xa90(%rbp)
  40a22f:	48 c7 85 70 f5 ff ff 00 ca 9a 3b 	movq   $0x3b9aca00,-0xa90(%rbp)
  40a23a:	66 48 0f 6e c6       	movq   %rsi,%xmm0
  40a23f:	f3 0f 11 85 04 ff ff ff 	movss  %xmm0,-0xfc(%rbp)
  40a247:	66 48 0f 6e d1       	movq   %rcx,%xmm2
  40a24c:	f3 0f 11 95 10 ff ff ff 	movss  %xmm2,-0xf0(%rbp)
  40a254:	f3 0f 10 ca          	movss  %xmm2,%xmm1
  40a258:	66 48 0f 6e d0       	movq   %rax,%xmm2
  40a25d:	f3 0f 11 95 14 ff ff ff 	movss  %xmm2,-0xec(%rbp)
  40a265:	41 b8 00 00 00 00    	mov    $0x0,%r8d
  40a26b:	b9 28 6b 6e 4e       	mov    $0x4e6e6b28,%ecx
  40a270:	49 89 d5             	mov    %rdx,%r13
  40a273:	ba 28 6b 6e 4e       	mov    $0x4e6e6b28,%edx
  40a278:	be 09 00 00 00       	mov    $0x9,%esi
  40a27d:	49 89 fc             	mov    %rdi,%r12
  40a280:	e8 5b cc ff ff       	callq  406ee0 <p126_typed_FID_36_100_105_114_101_99_116_46_110_101_97_114_101_115_116_46_116_>
  40a285:	4c 89 e7             	mov    %r12,%rdi
  40a288:	48 89 85 70 ff ff ff 	mov    %rax,-0x90(%rbp)
  40a28f:	f3 0f 10 0d a9 6d 02 00 	movss  0x26da9(%rip),%xmm1        # 431040 <_IO_stdin_used+0x40>
  40a297:	f3 0f 10 05 9d 6d 02 00 	movss  0x26d9d(%rip),%xmm0        # 43103c <_IO_stdin_used+0x3c>
  40a29f:	49 89 fc             	mov    %rdi,%r12
  40a2a2:	e8 a9 ba ff ff       	callq  405d50 <p126_typed_FID_36_100_105_114_101_99_116_46_102_108_>
  40a2a7:	4c 89 e7             	mov    %r12,%rdi
  40a2aa:	48 89 85 58 ff ff ff 	mov    %rax,-0xa8(%rbp)
  40a2b1:	f3 0f 10 0d 7f 6d 02 00 	movss  0x26d7f(%rip),%xmm1        # 431038 <_IO_stdin_used+0x38>
  40a2b9:	f3 0f 10 05 73 6d 02 00 	movss  0x26d73(%rip),%xmm0        # 431034 <_IO_stdin_used+0x34>
  40a2c1:	49 89 fc             	mov    %rdi,%r12
  40a2c4:	e8 87 ba ff ff       	callq  405d50 <p126_typed_FID_36_100_105_114_101_99_116_46_102_108_>
  40a2c9:	4c 89 e7             	mov    %r12,%rdi
  40a2cc:	48 89 85 60 ff ff ff 	mov    %rax,-0xa0(%rbp)
  40a2d3:	48 89 d8             	mov    %rbx,%rax
  40a2d6:	48 89 c3             	mov    %rax,%rbx
  40a2d9:	48 8b 85 70 ff ff ff 	mov    -0x90(%rbp),%rax
  40a2e0:	48 8b b5 68 ff ff ff 	mov    -0x98(%rbp),%rsi
  40a2e7:	f3 0f 10 8d 78 ff ff ff 	movss  -0x88(%rbp),%xmm1
  40a2ef:	66 48 0f 6e c0       	movq   %rax,%xmm0
  40a2f4:	49 89 fc             	mov    %rdi,%r12
  40a2f7:	e8 24 c1 ff ff       	callq  406420 <p126_typed_FID_36_100_105_114_101_99_116_46_115_104_97_100_101_>
  40a2fc:	4c 89 ea             	mov    %r13,%rdx
  40a2ff:	4c 89 e7             	mov    %r12,%rdi
  40a302:	48 89 c1             	mov    %rax,%rcx
  40a305:	48 89 d8             	mov    %rbx,%rax
  40a308:	4c 8b 85 60 ff ff ff 	mov    -0xa0(%rbp),%r8
  40a30f:	49 89 d5             	mov    %rdx,%r13
  40a312:	48 8b 95 58 ff ff ff 	mov    -0xa8(%rbp),%rdx
  40a319:	48 8b b5 50 ff ff ff 	mov    -0xb0(%rbp),%rsi
  40a320:	4c 89 85 70 f5 ff ff 	mov    %r8,-0xa90(%rbp)
  40a327:	48 89 8d 78 f5 ff ff 	mov    %rcx,-0xa88(%rbp)
  40a32e:	66 49 0f 6e c0       	movq   %r8,%xmm0
  40a333:	66 48 0f 6e c9       	movq   %rcx,%xmm1
  40a338:	f3 0f 59 c1          	mulss  %xmm1,%xmm0
  40a33c:	66 48 0f 7e c1       	movq   %xmm0,%rcx
  40a341:	89 c9                	mov    %ecx,%ecx
  40a343:	48 89 95 70 f5 ff ff 	mov    %rdx,-0xa90(%rbp)
  40a34a:	48 89 8d 78 f5 ff ff 	mov    %rcx,-0xa88(%rbp)
  40a351:	66 48 0f 6e c2       	movq   %rdx,%xmm0
  40a356:	66 48 0f 6e c9       	movq   %rcx,%xmm1
  40a35b:	f3 0f 58 c1          	addss  %xmm1,%xmm0
  40a35f:	48 89 c3             	mov    %rax,%rbx
  40a362:	66 48 0f 7e c0       	movq   %xmm0,%rax
  40a367:	41 89 c0             	mov    %eax,%r8d
  40a36a:	4c 89 85 08 ff ff ff 	mov    %r8,-0xf8(%rbp)
  40a371:	49 89 fc             	mov    %rdi,%r12
  40a374:	e8 b7 bf ff ff       	callq  406330 <p113d_FID_36_100_105_114_101_99_116_46_115_107_114_>
  40a379:	4d 89 f9             	mov    %r15,%r9
  40a37c:	4c 89 ea             	mov    %r13,%rdx
  40a37f:	4c 89 e7             	mov    %r12,%rdi
  40a382:	49 89 c4             	mov    %rax,%r12
  40a385:	48 89 d8             	mov    %rbx,%rax
  40a388:	48 8b 8d 38 ff ff ff 	mov    -0xc8(%rbp),%rcx
  40a38f:	4d 89 cf             	mov    %r9,%r15
  40a392:	4c 8b 8d 30 ff ff ff 	mov    -0xd0(%rbp),%r9
  40a399:	48 8b b5 28 ff ff ff 	mov    -0xd8(%rbp),%rsi
  40a3a0:	f3 0f 10 9d 14 ff ff ff 	movss  -0xec(%rbp),%xmm3
  40a3a8:	f3 0f 10 95 10 ff ff ff 	movss  -0xf0(%rbp),%xmm2
  40a3b0:	f3 0f 10 8d 04 ff ff ff 	movss  -0xfc(%rbp),%xmm1
  40a3b8:	f3 0f 10 c1          	movss  %xmm1,%xmm0
  40a3bc:	f3 0f 10 8d 4c ff ff ff 	movss  -0xb4(%rbp),%xmm1
  40a3c4:	f3 0f 10 bd 48 ff ff ff 	movss  -0xb8(%rbp),%xmm7
  40a3cc:	f3 44 0f 10 8d 24 ff ff ff 	movss  -0xdc(%rbp),%xmm9
  40a3d5:	f3 0f 10 a5 f4 fe ff ff 	movss  -0x10c(%rbp),%xmm4
  40a3dd:	f3 0f 10 ad f0 fe ff ff 	movss  -0x110(%rbp),%xmm5
  40a3e5:	f3 0f 10 b5 e4 fe ff ff 	movss  -0x11c(%rbp),%xmm6
  40a3ed:	48 8b 9d e8 fe ff ff 	mov    -0x118(%rbp),%rbx
  40a3f4:	49 89 dd             	mov    %rbx,%r13
  40a3f7:	48 8b 9d 40 ff ff ff 	mov    -0xc0(%rbp),%rbx
  40a3fe:	48 c7 85 70 f5 ff ff 02 00 00 00 	movq   $0x2,-0xa90(%rbp)
  40a409:	4c 89 bd 70 f5 ff ff 	mov    %r15,-0xa90(%rbp)
  40a410:	48 89 b5 78 f5 ff ff 	mov    %rsi,-0xa88(%rbp)
  40a417:	f3 44 0f 10 c6       	movss  %xmm6,%xmm8
  40a41c:	f3 45 0f 59 c1       	mulss  %xmm9,%xmm8
  40a421:	66 4d 0f 7e c0       	movq   %xmm8,%r8
  40a426:	45 89 c2             	mov    %r8d,%r10d
  40a429:	48 89 95 70 f5 ff ff 	mov    %rdx,-0xa90(%rbp)
  40a430:	4c 89 8d 78 f5 ff ff 	mov    %r9,-0xa88(%rbp)
  40a437:	f3 44 0f 10 c5       	movss  %xmm5,%xmm8
  40a43c:	f3 44 0f 59 c7       	mulss  %xmm7,%xmm8
  40a441:	66 4d 0f 7e c0       	movq   %xmm8,%r8
  40a446:	45 89 c0             	mov    %r8d,%r8d
  40a449:	4c 89 95 70 f5 ff ff 	mov    %r10,-0xa90(%rbp)
  40a450:	4c 89 85 78 f5 ff ff 	mov    %r8,-0xa88(%rbp)
  40a457:	66 4d 0f 6e c2       	movq   %r10,%xmm8
  40a45c:	66 4d 0f 6e d0       	movq   %r8,%xmm10
  40a461:	f3 45 0f 58 c2       	addss  %xmm10,%xmm8
  40a466:	66 4d 0f 7e c0       	movq   %xmm8,%r8
  40a46b:	45 89 c2             	mov    %r8d,%r10d
  40a46e:	4c 89 b5 70 f5 ff ff 	mov    %r14,-0xa90(%rbp)
  40a475:	48 89 8d 78 f5 ff ff 	mov    %rcx,-0xa88(%rbp)
  40a47c:	f3 44 0f 10 c4       	movss  %xmm4,%xmm8
  40a481:	f3 44 0f 59 c1       	mulss  %xmm1,%xmm8
  40a486:	66 4d 0f 7e c0       	movq   %xmm8,%r8
  40a48b:	45 89 c0             	mov    %r8d,%r8d
  40a48e:	4c 89 95 70 f5 ff ff 	mov    %r10,-0xa90(%rbp)
  40a495:	4c 89 85 78 f5 ff ff 	mov    %r8,-0xa88(%rbp)
  40a49c:	66 4d 0f 6e c2       	movq   %r10,%xmm8
  40a4a1:	66 4d 0f 6e d0       	movq   %r8,%xmm10
  40a4a6:	f3 45 0f 58 c2       	addss  %xmm10,%xmm8
  40a4ab:	66 4d 0f 7e c0       	movq   %xmm8,%r8
  40a4b0:	45 89 c0             	mov    %r8d,%r8d
  40a4b3:	48 c7 85 70 f5 ff ff 00 00 00 40 	movq   $0x40000000,-0xa90(%rbp)
  40a4be:	4c 89 85 78 f5 ff ff 	mov    %r8,-0xa88(%rbp)
  40a4c5:	f3 44 0f 10 c6       	movss  %xmm6,%xmm8
  40a4ca:	66 49 0f 6e f0       	movq   %r8,%xmm6
  40a4cf:	f3 0f 59 35 71 6b 02 00 	mulss  0x26b71(%rip),%xmm6        # 431048 <_IO_stdin_used+0x48>
  40a4d7:	66 49 0f 7e f0       	movq   %xmm6,%r8
  40a4dc:	45 89 c0             	mov    %r8d,%r8d
  40a4df:	4c 89 85 70 f5 ff ff 	mov    %r8,-0xa90(%rbp)
  40a4e6:	48 89 b5 78 f5 ff ff 	mov    %rsi,-0xa88(%rbp)
  40a4ed:	f3 0f 10 f5          	movss  %xmm5,%xmm6
  40a4f1:	66 49 0f 6e e8       	movq   %r8,%xmm5
  40a4f6:	f3 44 0f 59 cd       	mulss  %xmm5,%xmm9
  40a4fb:	66 4c 0f 7e ce       	movq   %xmm9,%rsi
  40a500:	89 f6                	mov    %esi,%esi
  40a502:	4c 89 bd 70 f5 ff ff 	mov    %r15,-0xa90(%rbp)
  40a509:	48 89 b5 78 f5 ff ff 	mov    %rsi,-0xa88(%rbp)
  40a510:	66 4c 0f 6e ce       	movq   %rsi,%xmm9
  40a515:	f3 45 0f 5c c1       	subss  %xmm9,%xmm8
  40a51a:	66 4c 0f 7e c6       	movq   %xmm8,%rsi
  40a51f:	89 f6                	mov    %esi,%esi
  40a521:	4c 89 85 70 f5 ff ff 	mov    %r8,-0xa90(%rbp)
  40a528:	4c 89 8d 78 f5 ff ff 	mov    %r9,-0xa88(%rbp)
  40a52f:	f3 0f 59 fd          	mulss  %xmm5,%xmm7
  40a533:	49 89 d7             	mov    %rdx,%r15
  40a536:	66 48 0f 7e fa       	movq   %xmm7,%rdx
  40a53b:	89 d2                	mov    %edx,%edx
  40a53d:	4c 89 bd 70 f5 ff ff 	mov    %r15,-0xa90(%rbp)
  40a544:	48 89 95 78 f5 ff ff 	mov    %rdx,-0xa88(%rbp)
  40a54b:	66 48 0f 6e fa       	movq   %rdx,%xmm7
  40a550:	f3 0f 5c f7          	subss  %xmm7,%xmm6
  40a554:	66 48 0f 7e f2       	movq   %xmm6,%rdx
  40a559:	89 d2                	mov    %edx,%edx
  40a55b:	4c 89 85 70 f5 ff ff 	mov    %r8,-0xa90(%rbp)
  40a562:	48 89 8d 78 f5 ff ff 	mov    %rcx,-0xa88(%rbp)
  40a569:	f3 0f 59 cd          	mulss  %xmm5,%xmm1
  40a56d:	66 48 0f 7e c9       	movq   %xmm1,%rcx
  40a572:	89 c9                	mov    %ecx,%ecx
  40a574:	4c 89 b5 70 f5 ff ff 	mov    %r14,-0xa90(%rbp)
  40a57b:	48 89 8d 78 f5 ff ff 	mov    %rcx,-0xa88(%rbp)
  40a582:	f3 0f 10 ca          	movss  %xmm2,%xmm1
  40a586:	66 48 0f 6e d1       	movq   %rcx,%xmm2
  40a58b:	0f 57 15 7e 6a 02 00 	xorps  0x26a7e(%rip),%xmm2        # 431010 <_IO_stdin_used+0x10>
  40a592:	f3 0f 58 d4          	addss  %xmm4,%xmm2
  40a596:	66 48 0f 7e d1       	movq   %xmm2,%rcx
  40a59b:	89 c9                	mov    %ecx,%ecx
  40a59d:	48 c7 85 70 f5 ff ff 00 ca 9a 3b 	movq   $0x3b9aca00,-0xa90(%rbp)
  40a5a8:	48 c7 85 70 f5 ff ff 00 ca 9a 3b 	movq   $0x3b9aca00,-0xa90(%rbp)
  40a5b3:	f3 0f 10 d3          	movss  %xmm3,%xmm2
  40a5b7:	66 48 0f 6e de       	movq   %rsi,%xmm3
  40a5bc:	f3 0f 11 9d 18 ff ff ff 	movss  %xmm3,-0xe8(%rbp)
  40a5c4:	66 48 0f 6e ea       	movq   %rdx,%xmm5
  40a5c9:	f3 0f 11 ad 1c ff ff ff 	movss  %xmm5,-0xe4(%rbp)
  40a5d1:	66 48 0f 6e f1       	movq   %rcx,%xmm6
  40a5d6:	f3 0f 11 b5 20 ff ff ff 	movss  %xmm6,-0xe0(%rbp)
  40a5de:	49 89 c6             	mov    %rax,%r14
  40a5e1:	48 83 ec 10          	sub    $0x10,%rsp
  40a5e5:	48 89 e0             	mov    %rsp,%rax
  40a5e8:	48 c7 40 08 00 00 00 00 	movq   $0x0,0x8(%rax)
  40a5f0:	48 c7 00 09 00 00 00 	movq   $0x9,(%rax)
  40a5f7:	41 b9 28 6b 6e 4e    	mov    $0x4e6e6b28,%r9d
  40a5fd:	41 b8 09 00 00 00    	mov    $0x9,%r8d
  40a603:	b9 28 6b 6e 4e       	mov    $0x4e6e6b28,%ecx
  40a608:	f3 0f 10 e5          	movss  %xmm5,%xmm4
  40a60c:	f3 0f 10 ee          	movss  %xmm6,%xmm5
  40a610:	ba 09 00 00 00       	mov    $0x9,%edx
  40a615:	48 8d b5 70 fd ff ff 	lea    -0x290(%rbp),%rsi
  40a61c:	49 89 ff             	mov    %rdi,%r15
  40a61f:	e8 1c c2 ff ff       	callq  406840 <p126_typed_FID_36_112_114_111_100_117_99_116_46_110_101_97_114_101_115_116_>
  40a624:	4c 89 ff             	mov    %r15,%rdi
  40a627:	4c 89 f0             	mov    %r14,%rax
  40a62a:	4c 8b 85 08 ff ff ff 	mov    -0xf8(%rbp),%r8
  40a631:	f3 0f 10 8d b4 fd ff ff 	movss  -0x24c(%rbp),%xmm1
  40a639:	f3 0f 10 95 b0 fd ff ff 	movss  -0x250(%rbp),%xmm2
  40a641:	f3 0f 10 b5 20 ff ff ff 	movss  -0xe0(%rbp),%xmm6
  40a649:	f3 0f 10 ad 1c ff ff ff 	movss  -0xe4(%rbp),%xmm5
  40a651:	f3 0f 10 a5 18 ff ff ff 	movss  -0xe8(%rbp),%xmm4
  40a659:	f3 0f 10 9d 14 ff ff ff 	movss  -0xec(%rbp),%xmm3
  40a661:	f3 0f 10 c2          	movss  %xmm2,%xmm0
  40a665:	f3 0f 10 95 10 ff ff ff 	movss  -0xf0(%rbp),%xmm2
  40a66d:	f3 44 0f 10 c1       	movss  %xmm1,%xmm8
  40a672:	f3 0f 10 8d 04 ff ff ff 	movss  -0xfc(%rbp),%xmm1
  40a67a:	48 83 ec f0          	sub    $0xfffffffffffffff0,%rsp
  40a67e:	48 8b 95 70 fd ff ff 	mov    -0x290(%rbp),%rdx
  40a685:	48 8b b5 78 fd ff ff 	mov    -0x288(%rbp),%rsi
  40a68c:	48 8b 8d 80 fd ff ff 	mov    -0x280(%rbp),%rcx
  40a693:	4c 89 ad 70 f5 ff ff 	mov    %r13,-0xa90(%rbp)
  40a69a:	4c 89 85 78 f5 ff ff 	mov    %r8,-0xa88(%rbp)
  40a6a1:	66 49 0f 6e f8       	movq   %r8,%xmm7
  40a6a6:	f3 0f 59 f8          	mulss  %xmm0,%xmm7
  40a6aa:	66 49 0f 7e f8       	movq   %xmm7,%r8
  40a6af:	45 89 c1             	mov    %r8d,%r9d
  40a6b2:	48 c7 85 70 f5 ff ff 01 00 00 00 	movq   $0x1,-0xa90(%rbp)
  40a6bd:	48 c7 85 70 f5 ff ff 00 00 80 3f 	movq   $0x3f800000,-0xa90(%rbp)
  40a6c8:	4c 89 a5 78 f5 ff ff 	mov    %r12,-0xa88(%rbp)
  40a6cf:	66 49 0f 6e fc       	movq   %r12,%xmm7
  40a6d4:	f3 44 0f 10 0d 43 69 02 00 	movss  0x26943(%rip),%xmm9        # 431020 <_IO_stdin_used+0x20>
  40a6dd:	f3 44 0f 5c cf       	subss  %xmm7,%xmm9
  40a6e2:	66 4d 0f 7e c8       	movq   %xmm9,%r8
  40a6e7:	45 89 c0             	mov    %r8d,%r8d
  40a6ea:	4c 89 8d 70 f5 ff ff 	mov    %r9,-0xa90(%rbp)
  40a6f1:	4c 89 85 78 f5 ff ff 	mov    %r8,-0xa88(%rbp)
  40a6f8:	66 4d 0f 6e c9       	movq   %r9,%xmm9
  40a6fd:	66 4d 0f 6e d0       	movq   %r8,%xmm10
  40a702:	f3 45 0f 59 ca       	mulss  %xmm10,%xmm9
  40a707:	49 89 c6             	mov    %rax,%r14
  40a70a:	66 4c 0f 7e c8       	movq   %xmm9,%rax
  40a70f:	89 c0                	mov    %eax,%eax
  40a711:	4c 89 b5 70 f5 ff ff 	mov    %r14,-0xa90(%rbp)
  40a718:	48 89 85 78 f5 ff ff 	mov    %rax,-0xa88(%rbp)
  40a71f:	66 4c 0f 6e c8       	movq   %rax,%xmm9
  40a724:	f3 45 0f 58 c1       	addss  %xmm9,%xmm8
  40a729:	66 4c 0f 7e c0       	movq   %xmm8,%rax
  40a72e:	41 89 c0             	mov    %eax,%r8d
  40a731:	4c 89 ad 70 f5 ff ff 	mov    %r13,-0xa90(%rbp)
  40a738:	4c 89 a5 78 f5 ff ff 	mov    %r12,-0xa88(%rbp)
  40a73f:	f3 0f 59 c7          	mulss  %xmm7,%xmm0
  40a743:	66 48 0f 7e c0       	movq   %xmm0,%rax
  40a748:	89 c0                	mov    %eax,%eax
  40a74a:	66 48 0f 6e c6       	movq   %rsi,%xmm0
  40a74f:	66 48 0f 6e f8       	movq   %rax,%xmm7
  40a754:	48 89 de             	mov    %rbx,%rsi
  40a757:	48 83 ee 01          	sub    $0x1,%rsi
  40a75b:	e8 90 cd ff ff       	callq  4074f0 <p126_typed_FID_36_112_114_111_100_117_99_116_46_116_114_97_99_101_>
  40a760:	e9 95 0c 00 00       	jmpq   40b3fa <p113d_FID_36_100_105_114_101_99_116_46_116_114_97_99_101_+0x1b5a>
  40a765:	48 89 d8             	mov    %rbx,%rax
  40a768:	48 89 c3             	mov    %rax,%rbx
  40a76b:	e9 8a 0c 00 00       	jmpq   40b3fa <p113d_FID_36_100_105_114_101_99_116_46_116_114_97_99_101_+0x1b5a>
  40a770:	4d 89 f5             	mov    %r14,%r13
  40a773:	48 3d 97 00 00 00    	cmp    $0x97,%rax
  40a779:	74 14                	je     40a78f <p113d_FID_36_100_105_114_101_99_116_46_116_114_97_99_101_+0xeef>
  40a77b:	be 04 00 00 00       	mov    $0x4,%esi
  40a780:	e8 1b 0c 02 00       	callq  42b3a0 <p111_rt_fail>
  40a785:	b8 00 00 00 00       	mov    $0x0,%eax
  40a78a:	e9 6b 0c 00 00       	jmpq   40b3fa <p113d_FID_36_100_105_114_101_99_116_46_116_114_97_99_101_+0x1b5a>
  40a78f:	49 89 d6             	mov    %rdx,%r14
  40a792:	48 8d 95 70 f5 ff ff 	lea    -0xa90(%rbp),%rdx
  40a799:	49 89 fc             	mov    %rdi,%r12
  40a79c:	e8 7f 5e 02 00       	callq  430620 <p125_rt_take3>
  40a7a1:	4d 89 f9             	mov    %r15,%r9
  40a7a4:	4c 89 f2             	mov    %r14,%rdx
  40a7a7:	4c 89 e7             	mov    %r12,%rdi
  40a7aa:	48 89 d8             	mov    %rbx,%rax
  40a7ad:	f3 0f 10 9d 00 ff ff ff 	movss  -0x100(%rbp),%xmm3
  40a7b5:	f3 0f 10 a5 f4 fe ff ff 	movss  -0x10c(%rbp),%xmm4
  40a7bd:	f3 0f 10 95 fc fe ff ff 	movss  -0x104(%rbp),%xmm2
  40a7c5:	f3 0f 10 ad f0 fe ff ff 	movss  -0x110(%rbp),%xmm5
  40a7cd:	f3 0f 10 8d f8 fe ff ff 	movss  -0x108(%rbp),%xmm1
  40a7d5:	f3 0f 10 b5 e4 fe ff ff 	movss  -0x11c(%rbp),%xmm6
  40a7dd:	48 8b 9d e8 fe ff ff 	mov    -0x118(%rbp),%rbx
  40a7e4:	4c 8b 85 70 f5 ff ff 	mov    -0xa90(%rbp),%r8
  40a7eb:	4c 8b b5 78 f5 ff ff 	mov    -0xa88(%rbp),%r14
  40a7f2:	48 8b b5 80 f5 ff ff 	mov    -0xa80(%rbp),%rsi
  40a7f9:	49 83 f8 01          	cmp    $0x1,%r8
  40a7fd:	0f 94 c1             	sete   %cl
  40a800:	0f b6 c9             	movzbl %cl,%ecx
  40a803:	49 c1 e8 28          	shr    $0x28,%r8
  40a807:	49 81 e0 ff ff 7f 00 	and    $0x7fffff,%r8
  40a80e:	49 81 f8 02 00 01 00 	cmp    $0x10002,%r8
  40a815:	41 0f 94 c0          	sete   %r8b
  40a819:	45 0f b6 c0          	movzbl %r8b,%r8d
  40a81d:	44 09 c1             	or     %r8d,%ecx
  40a820:	0f 85 d4 0b 00 00    	jne    40b3fa <p113d_FID_36_100_105_114_101_99_116_46_116_114_97_99_101_+0x1b5a>
  40a826:	83 f1 01             	xor    $0x1,%ecx
  40a829:	75 14                	jne    40a83f <p113d_FID_36_100_105_114_101_99_116_46_116_114_97_99_101_+0xf9f>
  40a82b:	be 04 00 00 00       	mov    $0x4,%esi
  40a830:	e8 6b 0b 02 00       	callq  42b3a0 <p111_rt_fail>
  40a835:	b8 00 00 00 00       	mov    $0x0,%eax
  40a83a:	e9 bb 0b 00 00       	jmpq   40b3fa <p113d_FID_36_100_105_114_101_99_116_46_116_114_97_99_101_+0x1b5a>
  40a83f:	48 83 fe 00          	cmp    $0x0,%rsi
  40a843:	0f 94 c1             	sete   %cl
  40a846:	0f b6 c9             	movzbl %cl,%ecx
  40a849:	89 8d e0 fe ff ff    	mov    %ecx,-0x120(%rbp)
  40a84f:	49 89 f0             	mov    %rsi,%r8
  40a852:	49 83 e8 01          	sub    $0x1,%r8
  40a856:	49 89 f7             	mov    %rsi,%r15
  40a859:	49 83 ef 02          	sub    $0x2,%r15
  40a85d:	49 89 f4             	mov    %rsi,%r12
  40a860:	49 83 ec 03          	sub    $0x3,%r12
  40a864:	49 89 f3             	mov    %rsi,%r11
  40a867:	49 83 eb 04          	sub    $0x4,%r11
  40a86b:	49 89 f2             	mov    %rsi,%r10
  40a86e:	49 83 ea 05          	sub    $0x5,%r10
  40a872:	4c 89 95 c8 fe ff ff 	mov    %r10,-0x138(%rbp)
  40a879:	48 89 f1             	mov    %rsi,%rcx
  40a87c:	48 83 e9 06          	sub    $0x6,%rcx
  40a880:	48 89 8d b8 fe ff ff 	mov    %rcx,-0x148(%rbp)
  40a887:	48 89 f1             	mov    %rsi,%rcx
  40a88a:	48 83 e9 07          	sub    $0x7,%rcx
  40a88e:	48 89 8d b0 fe ff ff 	mov    %rcx,-0x150(%rbp)
  40a895:	4c 89 d1             	mov    %r10,%rcx
  40a898:	4c 8b 95 b8 fe ff ff 	mov    -0x148(%rbp),%r10
  40a89f:	83 bd e0 fe ff ff 00 	cmpl   $0x0,-0x120(%rbp)
  40a8a6:	75 73                	jne    40a91b <p113d_FID_36_100_105_114_101_99_116_46_116_114_97_99_101_+0x107b>
  40a8a8:	49 83 f8 00          	cmp    $0x0,%r8
  40a8ac:	74 66                	je     40a914 <p113d_FID_36_100_105_114_101_99_116_46_116_114_97_99_101_+0x1074>
  40a8ae:	49 83 ff 00          	cmp    $0x0,%r15
  40a8b2:	74 59                	je     40a90d <p113d_FID_36_100_105_114_101_99_116_46_116_114_97_99_101_+0x106d>
  40a8b4:	49 83 fc 00          	cmp    $0x0,%r12
  40a8b8:	74 4c                	je     40a906 <p113d_FID_36_100_105_114_101_99_116_46_116_114_97_99_101_+0x1066>
  40a8ba:	66 0f 1f 44 00 00    	nopw   0x0(%rax,%rax,1)
  40a8c0:	49 83 fb 00          	cmp    $0x0,%r11
  40a8c4:	74 39                	je     40a8ff <p113d_FID_36_100_105_114_101_99_116_46_116_114_97_99_101_+0x105f>
  40a8c6:	48 83 f9 00          	cmp    $0x0,%rcx
  40a8ca:	48 8b 8d b0 fe ff ff 	mov    -0x150(%rbp),%rcx
  40a8d1:	74 25                	je     40a8f8 <p113d_FID_36_100_105_114_101_99_116_46_116_114_97_99_101_+0x1058>
  40a8d3:	2e 2e 49 83 fa 00    	cs cs cmp $0x0,%r10
  40a8d9:	4c 8b 95 d8 fe ff ff 	mov    -0x128(%rbp),%r10
  40a8e0:	74 0f                	je     40a8f1 <p113d_FID_36_100_105_114_101_99_116_46_116_114_97_99_101_+0x1051>
  40a8e2:	48 83 f9 00          	cmp    $0x0,%rcx
  40a8e6:	b9 00 00 80 3f       	mov    $0x3f800000,%ecx
  40a8eb:	49 0f 45 ca          	cmovne %r10,%rcx
  40a8ef:	eb 31                	jmp    40a922 <p113d_FID_36_100_105_114_101_99_116_46_116_114_97_99_101_+0x1082>
  40a8f1:	b9 9a 99 99 3f       	mov    $0x3f99999a,%ecx
  40a8f6:	eb 2a                	jmp    40a922 <p113d_FID_36_100_105_114_101_99_116_46_116_114_97_99_101_+0x1082>
  40a8f8:	b9 cd cc cc 3e       	mov    $0x3ecccccd,%ecx
  40a8fd:	eb 23                	jmp    40a922 <p113d_FID_36_100_105_114_101_99_116_46_116_114_97_99_101_+0x1082>
  40a8ff:	b9 cd cc cc 3e       	mov    $0x3ecccccd,%ecx
  40a904:	eb 1c                	jmp    40a922 <p113d_FID_36_100_105_114_101_99_116_46_116_114_97_99_101_+0x1082>
  40a906:	b9 00 00 80 3f       	mov    $0x3f800000,%ecx
  40a90b:	eb 15                	jmp    40a922 <p113d_FID_36_100_105_114_101_99_116_46_116_114_97_99_101_+0x1082>
  40a90d:	b9 00 00 80 3f       	mov    $0x3f800000,%ecx
  40a912:	eb 0e                	jmp    40a922 <p113d_FID_36_100_105_114_101_99_116_46_116_114_97_99_101_+0x1082>
  40a914:	b9 00 00 80 3f       	mov    $0x3f800000,%ecx
  40a919:	eb 07                	jmp    40a922 <p113d_FID_36_100_105_114_101_99_116_46_116_114_97_99_101_+0x1082>
  40a91b:	2e 2e b9 00 40 1c 46 	cs cs mov $0x461c4000,%ecx
  40a922:	4c 89 b5 70 f5 ff ff 	mov    %r14,-0xa90(%rbp)
  40a929:	4c 89 8d 78 f5 ff ff 	mov    %r9,-0xa88(%rbp)
  40a930:	66 49 0f 6e c6       	movq   %r14,%xmm0
  40a935:	f3 0f 59 f0          	mulss  %xmm0,%xmm6
  40a939:	66 49 0f 7e f1       	movq   %xmm6,%r9
  40a93e:	45 89 c9             	mov    %r9d,%r9d
  40a941:	4c 89 8d 98 fe ff ff 	mov    %r9,-0x168(%rbp)
  40a948:	4c 8b 95 c8 fe ff ff 	mov    -0x138(%rbp),%r10
  40a94f:	4c 8b 8d d0 fe ff ff 	mov    -0x130(%rbp),%r9
  40a956:	4c 89 8d 70 f5 ff ff 	mov    %r9,-0xa90(%rbp)
  40a95d:	4c 8b 8d 98 fe ff ff 	mov    -0x168(%rbp),%r9
  40a964:	4c 89 8d 78 f5 ff ff 	mov    %r9,-0xa88(%rbp)
  40a96b:	4c 89 b5 70 f5 ff ff 	mov    %r14,-0xa90(%rbp)
  40a972:	48 89 95 78 f5 ff ff 	mov    %rdx,-0xa88(%rbp)
  40a979:	f3 0f 59 e8          	mulss  %xmm0,%xmm5
  40a97d:	66 48 0f 7e ea       	movq   %xmm5,%rdx
  40a982:	89 d2                	mov    %edx,%edx
  40a984:	48 89 95 88 fe ff ff 	mov    %rdx,-0x178(%rbp)
  40a98b:	4c 8b 8d b8 fe ff ff 	mov    -0x148(%rbp),%r9
  40a992:	48 8b 95 c0 fe ff ff 	mov    -0x140(%rbp),%rdx
  40a999:	48 89 95 70 f5 ff ff 	mov    %rdx,-0xa90(%rbp)
  40a9a0:	48 8b 95 88 fe ff ff 	mov    -0x178(%rbp),%rdx
  40a9a7:	48 89 95 78 f5 ff ff 	mov    %rdx,-0xa88(%rbp)
  40a9ae:	48 8b 95 b0 fe ff ff 	mov    -0x150(%rbp),%rdx
  40a9b5:	4c 89 b5 70 f5 ff ff 	mov    %r14,-0xa90(%rbp)
  40a9bc:	4c 89 ad 78 f5 ff ff 	mov    %r13,-0xa88(%rbp)
  40a9c3:	f3 0f 59 c4          	mulss  %xmm4,%xmm0
  40a9c7:	66 49 0f 7e c5       	movq   %xmm0,%r13
  40a9cc:	45 89 ee             	mov    %r13d,%r14d
  40a9cf:	4c 89 b5 60 fe ff ff 	mov    %r14,-0x1a0(%rbp)
  40a9d6:	4c 8b ad 98 fe ff ff 	mov    -0x168(%rbp),%r13
  40a9dd:	4c 8b b5 a8 fe ff ff 	mov    -0x158(%rbp),%r14
  40a9e4:	4c 89 b5 70 f5 ff ff 	mov    %r14,-0xa90(%rbp)
  40a9eb:	4c 8b b5 60 fe ff ff 	mov    -0x1a0(%rbp),%r14
  40a9f2:	4c 89 b5 78 f5 ff ff 	mov    %r14,-0xa88(%rbp)
  40a9f9:	4c 8b b5 a0 fe ff ff 	mov    -0x160(%rbp),%r14
  40aa00:	48 83 fe 00          	cmp    $0x0,%rsi
  40aa04:	74 6d                	je     40aa73 <p113d_FID_36_100_105_114_101_99_116_46_116_114_97_99_101_+0x11d3>
  40aa06:	49 83 f8 00          	cmp    $0x0,%r8
  40aa0a:	74 5f                	je     40aa6b <p113d_FID_36_100_105_114_101_99_116_46_116_114_97_99_101_+0x11cb>
  40aa0c:	49 83 ff 00          	cmp    $0x0,%r15
  40aa10:	74 51                	je     40aa63 <p113d_FID_36_100_105_114_101_99_116_46_116_114_97_99_101_+0x11c3>
  40aa12:	49 83 fc 00          	cmp    $0x0,%r12
  40aa16:	74 43                	je     40aa5b <p113d_FID_36_100_105_114_101_99_116_46_116_114_97_99_101_+0x11bb>
  40aa18:	49 83 fb 00          	cmp    $0x0,%r11
  40aa1c:	74 35                	je     40aa53 <p113d_FID_36_100_105_114_101_99_116_46_116_114_97_99_101_+0x11b3>
  40aa1e:	66 90                	xchg   %ax,%ax
  40aa20:	49 83 fa 00          	cmp    $0x0,%r10
  40aa24:	74 25                	je     40aa4b <p113d_FID_36_100_105_114_101_99_116_46_116_114_97_99_101_+0x11ab>
  40aa26:	49 83 f9 00          	cmp    $0x0,%r9
  40aa2a:	74 17                	je     40aa43 <p113d_FID_36_100_105_114_101_99_116_46_116_114_97_99_101_+0x11a3>
  40aa2c:	48 83 fa 00          	cmp    $0x0,%rdx
  40aa30:	41 bd 00 00 60 40    	mov    $0x40600000,%r13d
  40aa36:	4d 0f 44 f5          	cmove  %r13,%r14
  40aa3a:	4c 8b ad 98 fe ff ff 	mov    -0x168(%rbp),%r13
  40aa41:	eb 36                	jmp    40aa79 <p113d_FID_36_100_105_114_101_99_116_46_116_114_97_99_101_+0x11d9>
  40aa43:	41 be 00 00 00 00    	mov    $0x0,%r14d
  40aa49:	eb 2e                	jmp    40aa79 <p113d_FID_36_100_105_114_101_99_116_46_116_114_97_99_101_+0x11d9>
  40aa4b:	41 be 00 00 80 bf    	mov    $0xbf800000,%r14d
  40aa51:	eb 26                	jmp    40aa79 <p113d_FID_36_100_105_114_101_99_116_46_116_114_97_99_101_+0x11d9>
  40aa53:	41 be 00 00 80 3f    	mov    $0x3f800000,%r14d
  40aa59:	eb 1e                	jmp    40aa79 <p113d_FID_36_100_105_114_101_99_116_46_116_114_97_99_101_+0x11d9>
  40aa5b:	41 be 00 00 00 c0    	mov    $0xc0000000,%r14d
  40aa61:	eb 16                	jmp    40aa79 <p113d_FID_36_100_105_114_101_99_116_46_116_114_97_99_101_+0x11d9>
  40aa63:	41 be 00 00 00 40    	mov    $0x40000000,%r14d
  40aa69:	eb 0e                	jmp    40aa79 <p113d_FID_36_100_105_114_101_99_116_46_116_114_97_99_101_+0x11d9>
  40aa6b:	41 be 00 00 00 00    	mov    $0x0,%r14d
  40aa71:	eb 06                	jmp    40aa79 <p113d_FID_36_100_105_114_101_99_116_46_116_114_97_99_101_+0x11d9>
  40aa73:	41 be 00 00 00 00    	mov    $0x0,%r14d
  40aa79:	66 49 0f 6e c5       	movq   %r13,%xmm0
  40aa7e:	f3 0f 58 c1          	addss  %xmm1,%xmm0
  40aa82:	66 49 0f 7e c5       	movq   %xmm0,%r13
  40aa87:	45 89 ed             	mov    %r13d,%r13d
  40aa8a:	4c 89 ad 80 fe ff ff 	mov    %r13,-0x180(%rbp)
  40aa91:	4c 89 ad 70 f5 ff ff 	mov    %r13,-0xa90(%rbp)
  40aa98:	4c 89 b5 78 f5 ff ff 	mov    %r14,-0xa88(%rbp)
  40aa9f:	66 49 0f 6e c5       	movq   %r13,%xmm0
  40aaa4:	f3 0f 11 85 18 fe ff ff 	movss  %xmm0,-0x1e8(%rbp)
  40aaac:	66 49 0f 6e ce       	movq   %r14,%xmm1
  40aab1:	0f 57 0d 58 65 02 00 	xorps  0x26558(%rip),%xmm1        # 431010 <_IO_stdin_used+0x10>
  40aab8:	f3 0f 58 c8          	addss  %xmm0,%xmm1
  40aabc:	66 49 0f 7e ce       	movq   %xmm1,%r14
  40aac1:	45 89 f6             	mov    %r14d,%r14d
  40aac4:	4c 89 b5 38 fe ff ff 	mov    %r14,-0x1c8(%rbp)
  40aacb:	4c 89 b5 70 f5 ff ff 	mov    %r14,-0xa90(%rbp)
  40aad2:	4c 8b b5 88 fe ff ff 	mov    -0x178(%rbp),%r14
  40aad9:	48 89 8d 78 f5 ff ff 	mov    %rcx,-0xa88(%rbp)
  40aae0:	48 83 fe 00          	cmp    $0x0,%rsi
  40aae4:	0f 84 9a 00 00 00    	je     40ab84 <p113d_FID_36_100_105_114_101_99_116_46_116_114_97_99_101_+0x12e4>
  40aaea:	4c 8b b5 90 fe ff ff 	mov    -0x170(%rbp),%r14
  40aaf1:	49 83 f8 00          	cmp    $0x0,%r8
  40aaf5:	74 5b                	je     40ab52 <p113d_FID_36_100_105_114_101_99_116_46_116_114_97_99_101_+0x12b2>
  40aaf7:	49 83 ff 00          	cmp    $0x0,%r15
  40aafb:	74 4d                	je     40ab4a <p113d_FID_36_100_105_114_101_99_116_46_116_114_97_99_101_+0x12aa>
  40aafd:	0f 1f 00             	nopl   (%rax)
  40ab00:	49 83 fc 00          	cmp    $0x0,%r12
  40ab04:	74 3c                	je     40ab42 <p113d_FID_36_100_105_114_101_99_116_46_116_114_97_99_101_+0x12a2>
  40ab06:	49 83 fb 00          	cmp    $0x0,%r11
  40ab0a:	74 2c                	je     40ab38 <p113d_FID_36_100_105_114_101_99_116_46_116_114_97_99_101_+0x1298>
  40ab0c:	49 83 fa 00          	cmp    $0x0,%r10
  40ab10:	74 1e                	je     40ab30 <p113d_FID_36_100_105_114_101_99_116_46_116_114_97_99_101_+0x1290>
  40ab12:	49 83 f9 00          	cmp    $0x0,%r9
  40ab16:	74 10                	je     40ab28 <p113d_FID_36_100_105_114_101_99_116_46_116_114_97_99_101_+0x1288>
  40ab18:	48 83 fa 00          	cmp    $0x0,%rdx
  40ab1c:	41 bd cd cc 4c 3e    	mov    $0x3e4ccccd,%r13d
  40ab22:	4d 0f 45 ee          	cmovne %r14,%r13
  40ab26:	eb 30                	jmp    40ab58 <p113d_FID_36_100_105_114_101_99_116_46_116_114_97_99_101_+0x12b8>
  40ab28:	41 bd cd cc cc 3f    	mov    $0x3fcccccd,%r13d
  40ab2e:	eb 28                	jmp    40ab58 <p113d_FID_36_100_105_114_101_99_116_46_116_114_97_99_101_+0x12b8>
  40ab30:	41 bd 9a 99 19 bf    	mov    $0xbf19999a,%r13d
  40ab36:	eb 20                	jmp    40ab58 <p113d_FID_36_100_105_114_101_99_116_46_116_114_97_99_101_+0x12b8>
  40ab38:	2e 2e 41 bd 9a 99 19 bf 	cs cs mov $0xbf19999a,%r13d
  40ab40:	eb 16                	jmp    40ab58 <p113d_FID_36_100_105_114_101_99_116_46_116_114_97_99_101_+0x12b8>
  40ab42:	41 bd 00 00 00 3f    	mov    $0x3f000000,%r13d
  40ab48:	eb 0e                	jmp    40ab58 <p113d_FID_36_100_105_114_101_99_116_46_116_114_97_99_101_+0x12b8>
  40ab4a:	41 bd 00 00 00 3f    	mov    $0x3f000000,%r13d
  40ab50:	eb 06                	jmp    40ab58 <p113d_FID_36_100_105_114_101_99_116_46_116_114_97_99_101_+0x12b8>
  40ab52:	41 bd 00 00 00 00    	mov    $0x0,%r13d
  40ab58:	4d 89 ee             	mov    %r13,%r14
  40ab5b:	4c 89 b5 78 fe ff ff 	mov    %r14,-0x188(%rbp)
  40ab62:	4c 8b b5 88 fe ff ff 	mov    -0x178(%rbp),%r14
  40ab69:	4c 8b ad 80 fe ff ff 	mov    -0x180(%rbp),%r13
  40ab70:	f2 44 0f 10 bd 78 fe ff ff 	movsd  -0x188(%rbp),%xmm15
  40ab79:	f2 44 0f 11 bd 70 fe ff ff 	movsd  %xmm15,-0x190(%rbp)
  40ab82:	eb 15                	jmp    40ab99 <p113d_FID_36_100_105_114_101_99_116_46_116_114_97_99_101_+0x12f9>
  40ab84:	2e c7 85 70 fe ff ff 00 44 1c c6 	movl   $0xc61c4400,%cs:-0x190(%rbp)
  40ab8f:	c7 85 74 fe ff ff 00 00 00 00 	movl   $0x0,-0x18c(%rbp)
  40ab99:	66 49 0f 6e ce       	movq   %r14,%xmm1
  40ab9e:	f3 0f 58 ca          	addss  %xmm2,%xmm1
  40aba2:	66 49 0f 7e ce       	movq   %xmm1,%r14
  40aba7:	45 89 f6             	mov    %r14d,%r14d
  40abaa:	4c 89 b5 68 fe ff ff 	mov    %r14,-0x198(%rbp)
  40abb1:	4c 89 b5 70 f5 ff ff 	mov    %r14,-0xa90(%rbp)
  40abb8:	4c 8b b5 70 fe ff ff 	mov    -0x190(%rbp),%r14
  40abbf:	4c 89 b5 78 f5 ff ff 	mov    %r14,-0xa88(%rbp)
  40abc6:	4c 8b b5 68 fe ff ff 	mov    -0x198(%rbp),%r14
  40abcd:	66 49 0f 6e ce       	movq   %r14,%xmm1
  40abd2:	f3 0f 11 8d 00 fe ff ff 	movss  %xmm1,-0x200(%rbp)
  40abda:	4c 8b b5 70 fe ff ff 	mov    -0x190(%rbp),%r14
  40abe1:	66 49 0f 6e d6       	movq   %r14,%xmm2
  40abe6:	0f 57 15 23 64 02 00 	xorps  0x26423(%rip),%xmm2        # 431010 <_IO_stdin_used+0x10>
  40abed:	f3 0f 58 d1          	addss  %xmm1,%xmm2
  40abf1:	66 49 0f 7e d6       	movq   %xmm2,%r14
  40abf6:	45 89 f6             	mov    %r14d,%r14d
  40abf9:	4c 89 b5 40 fe ff ff 	mov    %r14,-0x1c0(%rbp)
  40ac00:	4c 89 b5 70 f5 ff ff 	mov    %r14,-0xa90(%rbp)
  40ac07:	4c 8b b5 68 fe ff ff 	mov    -0x198(%rbp),%r14
  40ac0e:	48 89 8d 78 f5 ff ff 	mov    %rcx,-0xa88(%rbp)
  40ac15:	48 83 fe 00          	cmp    $0x0,%rsi
  40ac19:	48 8b b5 60 fe ff ff 	mov    -0x1a0(%rbp),%rsi
  40ac20:	74 6a                	je     40ac8c <p113d_FID_36_100_105_114_101_99_116_46_116_114_97_99_101_+0x13ec>
  40ac22:	49 83 f8 00          	cmp    $0x0,%r8
  40ac26:	4c 8b 85 58 fe ff ff 	mov    -0x1a8(%rbp),%r8
  40ac2d:	74 56                	je     40ac85 <p113d_FID_36_100_105_114_101_99_116_46_116_114_97_99_101_+0x13e5>
  40ac2f:	49 83 ff 00          	cmp    $0x0,%r15
  40ac33:	74 49                	je     40ac7e <p113d_FID_36_100_105_114_101_99_116_46_116_114_97_99_101_+0x13de>
  40ac35:	49 83 fc 00          	cmp    $0x0,%r12
  40ac39:	74 3c                	je     40ac77 <p113d_FID_36_100_105_114_101_99_116_46_116_114_97_99_101_+0x13d7>
  40ac3b:	0f 1f 44 00 00       	nopl   0x0(%rax,%rax,1)
  40ac40:	49 83 fb 00          	cmp    $0x0,%r11
  40ac44:	74 2a                	je     40ac70 <p113d_FID_36_100_105_114_101_99_116_46_116_114_97_99_101_+0x13d0>
  40ac46:	49 83 fa 00          	cmp    $0x0,%r10
  40ac4a:	74 1d                	je     40ac69 <p113d_FID_36_100_105_114_101_99_116_46_116_114_97_99_101_+0x13c9>
  40ac4c:	49 83 f9 00          	cmp    $0x0,%r9
  40ac50:	74 10                	je     40ac62 <p113d_FID_36_100_105_114_101_99_116_46_116_114_97_99_101_+0x13c2>
  40ac52:	2e 48 83 fa 00       	cs cmp $0x0,%rdx
  40ac57:	ba 00 00 00 41       	mov    $0x41000000,%edx
  40ac5c:	49 0f 45 d0          	cmovne %r8,%rdx
  40ac60:	eb 2f                	jmp    40ac91 <p113d_FID_36_100_105_114_101_99_116_46_116_114_97_99_101_+0x13f1>
  40ac62:	ba 00 00 e0 40       	mov    $0x40e00000,%edx
  40ac67:	eb 28                	jmp    40ac91 <p113d_FID_36_100_105_114_101_99_116_46_116_114_97_99_101_+0x13f1>
  40ac69:	ba 00 00 60 40       	mov    $0x40600000,%edx
  40ac6e:	eb 21                	jmp    40ac91 <p113d_FID_36_100_105_114_101_99_116_46_116_114_97_99_101_+0x13f1>
  40ac70:	ba 00 00 60 40       	mov    $0x40600000,%edx
  40ac75:	eb 1a                	jmp    40ac91 <p113d_FID_36_100_105_114_101_99_116_46_116_114_97_99_101_+0x13f1>
  40ac77:	ba 00 00 c0 40       	mov    $0x40c00000,%edx
  40ac7c:	eb 13                	jmp    40ac91 <p113d_FID_36_100_105_114_101_99_116_46_116_114_97_99_101_+0x13f1>
  40ac7e:	ba 00 00 c0 40       	mov    $0x40c00000,%edx
  40ac83:	eb 0c                	jmp    40ac91 <p113d_FID_36_100_105_114_101_99_116_46_116_114_97_99_101_+0x13f1>
  40ac85:	ba 00 00 a0 40       	mov    $0x40a00000,%edx
  40ac8a:	eb 05                	jmp    40ac91 <p113d_FID_36_100_105_114_101_99_116_46_116_114_97_99_101_+0x13f1>
  40ac8c:	ba 00 00 a0 40       	mov    $0x40a00000,%edx
  40ac91:	66 48 0f 6e d6       	movq   %rsi,%xmm2
  40ac96:	f3 0f 58 d3          	addss  %xmm3,%xmm2
  40ac9a:	66 48 0f 7e d6       	movq   %xmm2,%rsi
  40ac9f:	41 89 f4             	mov    %esi,%r12d
  40aca2:	4c 89 a5 08 fe ff ff 	mov    %r12,-0x1f8(%rbp)
  40aca9:	4c 89 a5 70 f5 ff ff 	mov    %r12,-0xa90(%rbp)
  40acb0:	48 89 95 78 f5 ff ff 	mov    %rdx,-0xa88(%rbp)
  40acb7:	f3 0f 10 d0          	movss  %xmm0,%xmm2
  40acbb:	66 49 0f 6e c4       	movq   %r12,%xmm0
  40acc0:	f3 0f 11 85 c4 fd ff ff 	movss  %xmm0,-0x23c(%rbp)
  40acc8:	66 48 0f 6e da       	movq   %rdx,%xmm3
  40accd:	0f 57 1d 3c 63 02 00 	xorps  0x2633c(%rip),%xmm3        # 431010 <_IO_stdin_used+0x10>
  40acd4:	f3 0f 58 d8          	addss  %xmm0,%xmm3
  40acd8:	66 48 0f 7e da       	movq   %xmm3,%rdx
  40acdd:	89 d2                	mov    %edx,%edx
  40acdf:	48 89 95 70 f5 ff ff 	mov    %rdx,-0xa90(%rbp)
  40ace6:	48 89 8d 78 f5 ff ff 	mov    %rcx,-0xa88(%rbp)
  40aced:	66 48 0f 6e e2       	movq   %rdx,%xmm4
  40acf2:	66 48 0f 6e d9       	movq   %rcx,%xmm3
  40acf7:	f3 0f 11 9d 48 fe ff ff 	movss  %xmm3,-0x1b8(%rbp)
  40acff:	f3 44 0f 10 fb       	movss  %xmm3,%xmm15
  40ad04:	f3 0f 10 dc          	movss  %xmm4,%xmm3
  40ad08:	f3 41 0f 5e df       	divss  %xmm15,%xmm3
  40ad0d:	66 48 0f 7e d9       	movq   %xmm3,%rcx
  40ad12:	4d 89 e7             	mov    %r12,%r15
  40ad15:	41 89 cc             	mov    %ecx,%r12d
  40ad18:	4c 89 a5 f8 fd ff ff 	mov    %r12,-0x208(%rbp)
  40ad1f:	48 c7 85 70 f5 ff ff 00 00 00 00 	movq   $0x0,-0xa90(%rbp)
  40ad2a:	48 c7 85 70 f5 ff ff 03 00 00 00 	movq   $0x3,-0xa90(%rbp)
  40ad35:	48 c7 85 70 f5 ff ff 00 00 00 00 	movq   $0x0,-0xa90(%rbp)
  40ad40:	48 c7 85 78 f5 ff ff 00 00 40 40 	movq   $0x40400000,-0xa88(%rbp)
  40ad4b:	b9 00 00 40 c0       	mov    $0xc0400000,%ecx
  40ad50:	48 89 8d 70 f5 ff ff 	mov    %rcx,-0xa90(%rbp)
  40ad57:	4c 89 ad 78 f5 ff ff 	mov    %r13,-0xa88(%rbp)
  40ad5e:	0f 57 15 ab 62 02 00 	xorps  0x262ab(%rip),%xmm2        # 431010 <_IO_stdin_used+0x10>
  40ad65:	f3 0f 58 15 c3 62 02 00 	addss  0x262c3(%rip),%xmm2        # 431030 <_IO_stdin_used+0x30>
  40ad6d:	66 48 0f 7e d1       	movq   %xmm2,%rcx
  40ad72:	41 89 c8             	mov    %ecx,%r8d
  40ad75:	4c 89 85 20 fe ff ff 	mov    %r8,-0x1e0(%rbp)
  40ad7c:	48 c7 85 70 f5 ff ff 08 00 00 00 	movq   $0x8,-0xa90(%rbp)
  40ad87:	48 c7 85 70 f5 ff ff 00 00 00 41 	movq   $0x41000000,-0xa90(%rbp)
  40ad92:	4c 89 b5 78 f5 ff ff 	mov    %r14,-0xa88(%rbp)
  40ad99:	0f 57 0d 70 62 02 00 	xorps  0x26270(%rip),%xmm1        # 431010 <_IO_stdin_used+0x10>
  40ada0:	f3 0f 58 0d 84 62 02 00 	addss  0x26284(%rip),%xmm1        # 43102c <_IO_stdin_used+0x2c>
  40ada8:	66 48 0f 7e c9       	movq   %xmm1,%rcx
  40adad:	89 ce                	mov    %ecx,%esi
  40adaf:	48 89 b5 28 fe ff ff 	mov    %rsi,-0x1d8(%rbp)
  40adb6:	48 c7 85 70 f5 ff ff 01 00 00 00 	movq   $0x1,-0xa90(%rbp)
  40adc1:	48 c7 85 70 f5 ff ff 00 00 80 3f 	movq   $0x3f800000,-0xa90(%rbp)
  40adcc:	4c 89 bd 78 f5 ff ff 	mov    %r15,-0xa88(%rbp)
  40add3:	0f 57 05 36 62 02 00 	xorps  0x26236(%rip),%xmm0        # 431010 <_IO_stdin_used+0x10>
  40adda:	f3 0f 58 05 3e 62 02 00 	addss  0x2623e(%rip),%xmm0        # 431020 <_IO_stdin_used+0x20>
  40ade2:	66 48 0f 7e c1       	movq   %xmm0,%rcx
  40ade7:	41 89 ca             	mov    %ecx,%r10d
  40adea:	4c 89 95 30 fe ff ff 	mov    %r10,-0x1d0(%rbp)
  40adf1:	4c 89 85 70 f5 ff ff 	mov    %r8,-0xa90(%rbp)
  40adf8:	4c 89 85 78 f5 ff ff 	mov    %r8,-0xa88(%rbp)
  40adff:	66 49 0f 6e e8       	movq   %r8,%xmm5
  40ae04:	f3 0f 11 ad 4c fe ff ff 	movss  %xmm5,-0x1b4(%rbp)
  40ae0c:	f3 0f 10 c5          	movss  %xmm5,%xmm0
  40ae10:	f3 0f 59 c5          	mulss  %xmm5,%xmm0
  40ae14:	66 48 0f 7e c1       	movq   %xmm0,%rcx
  40ae19:	89 ca                	mov    %ecx,%edx
  40ae1b:	48 89 b5 70 f5 ff ff 	mov    %rsi,-0xa90(%rbp)
  40ae22:	48 89 b5 78 f5 ff ff 	mov    %rsi,-0xa88(%rbp)
  40ae29:	66 48 0f 6e e6       	movq   %rsi,%xmm4
  40ae2e:	f3 0f 11 a5 50 fe ff ff 	movss  %xmm4,-0x1b0(%rbp)
  40ae36:	f3 0f 10 c4          	movss  %xmm4,%xmm0
  40ae3a:	f3 0f 59 c4          	mulss  %xmm4,%xmm0
  40ae3e:	66 48 0f 7e c1       	movq   %xmm0,%rcx
  40ae43:	89 c9                	mov    %ecx,%ecx
  40ae45:	48 89 95 70 f5 ff ff 	mov    %rdx,-0xa90(%rbp)
  40ae4c:	48 89 8d 78 f5 ff ff 	mov    %rcx,-0xa88(%rbp)
  40ae53:	66 48 0f 6e c2       	movq   %rdx,%xmm0
  40ae58:	66 48 0f 6e c9       	movq   %rcx,%xmm1
  40ae5d:	f3 0f 58 c1          	addss  %xmm1,%xmm0
  40ae61:	66 48 0f 7e c1       	movq   %xmm0,%rcx
  40ae66:	89 ca                	mov    %ecx,%edx
  40ae68:	4c 89 95 70 f5 ff ff 	mov    %r10,-0xa90(%rbp)
  40ae6f:	4c 89 95 78 f5 ff ff 	mov    %r10,-0xa88(%rbp)
  40ae76:	66 49 0f 6e d2       	movq   %r10,%xmm2
  40ae7b:	f3 0f 11 95 54 fe ff ff 	movss  %xmm2,-0x1ac(%rbp)
  40ae83:	f3 0f 10 c2          	movss  %xmm2,%xmm0
  40ae87:	f3 0f 59 c2          	mulss  %xmm2,%xmm0
  40ae8b:	66 48 0f 7e c1       	movq   %xmm0,%rcx
  40ae90:	89 c9                	mov    %ecx,%ecx
  40ae92:	48 89 95 70 f5 ff ff 	mov    %rdx,-0xa90(%rbp)
  40ae99:	48 89 8d 78 f5 ff ff 	mov    %rcx,-0xa88(%rbp)
  40aea0:	66 48 0f 6e c2       	movq   %rdx,%xmm0
  40aea5:	66 48 0f 6e c9       	movq   %rcx,%xmm1
  40aeaa:	f3 0f 58 c1          	addss  %xmm1,%xmm0
  40aeae:	49 89 c4             	mov    %rax,%r12
  40aeb1:	66 48 0f 7e c0       	movq   %xmm0,%rax
  40aeb6:	89 c0                	mov    %eax,%eax
  40aeb8:	48 89 85 70 f5 ff ff 	mov    %rax,-0xa90(%rbp)
  40aebf:	b9 01 00 00 00       	mov    $0x1,%ecx
  40aec4:	48 8d 95 70 f5 ff ff 	lea    -0xa90(%rbp),%rdx
  40aecb:	be 24 00 00 00       	mov    $0x24,%esi
  40aed0:	49 89 ff             	mov    %rdi,%r15
  40aed3:	e8 e8 04 02 00       	callq  42b3c0 <p111_rt_op>
  40aed8:	4c 89 ff             	mov    %r15,%rdi
  40aedb:	48 89 c2             	mov    %rax,%rdx
  40aede:	4c 89 e0             	mov    %r12,%rax
  40aee1:	4c 8b 95 30 fe ff ff 	mov    -0x1d0(%rbp),%r10
  40aee8:	48 8b b5 28 fe ff ff 	mov    -0x1d8(%rbp),%rsi
  40aeef:	4c 8b 85 20 fe ff ff 	mov    -0x1e0(%rbp),%r8
  40aef6:	4c 8b a5 f8 fd ff ff 	mov    -0x208(%rbp),%r12
  40aefd:	4c 8b 8d 40 fe ff ff 	mov    -0x1c0(%rbp),%r9
  40af04:	48 8b 8d 38 fe ff ff 	mov    -0x1c8(%rbp),%rcx
  40af0b:	4c 8b bd 08 fe ff ff 	mov    -0x1f8(%rbp),%r15
  40af12:	f3 0f 10 95 54 fe ff ff 	movss  -0x1ac(%rbp),%xmm2
  40af1a:	f3 0f 10 a5 50 fe ff ff 	movss  -0x1b0(%rbp),%xmm4
  40af22:	f3 0f 10 ad 4c fe ff ff 	movss  -0x1b4(%rbp),%xmm5
  40af2a:	f3 0f 10 9d 48 fe ff ff 	movss  -0x1b8(%rbp),%xmm3
  40af32:	f3 0f 10 85 18 fe ff ff 	movss  -0x1e8(%rbp),%xmm0
  40af3a:	4c 89 85 70 f5 ff ff 	mov    %r8,-0xa90(%rbp)
  40af41:	48 89 95 78 f5 ff ff 	mov    %rdx,-0xa88(%rbp)
  40af48:	66 48 0f 6e ca       	movq   %rdx,%xmm1
  40af4d:	f3 0f 11 8d c0 fd ff ff 	movss  %xmm1,-0x240(%rbp)
  40af55:	f3 0f 5e e9          	divss  %xmm1,%xmm5
  40af59:	66 49 0f 7e e8       	movq   %xmm5,%r8
  40af5e:	45 89 c0             	mov    %r8d,%r8d
  40af61:	48 89 b5 70 f5 ff ff 	mov    %rsi,-0xa90(%rbp)
  40af68:	48 89 95 78 f5 ff ff 	mov    %rdx,-0xa88(%rbp)
  40af6f:	f3 0f 5e e1          	divss  %xmm1,%xmm4
  40af73:	66 48 0f 7e e6       	movq   %xmm4,%rsi
  40af78:	89 f6                	mov    %esi,%esi
  40af7a:	4c 89 95 70 f5 ff ff 	mov    %r10,-0xa90(%rbp)
  40af81:	48 89 95 78 f5 ff ff 	mov    %rdx,-0xa88(%rbp)
  40af88:	f3 44 0f 10 f9       	movss  %xmm1,%xmm15
  40af8d:	f3 0f 10 ca          	movss  %xmm2,%xmm1
  40af91:	f3 41 0f 5e cf       	divss  %xmm15,%xmm1
  40af96:	66 48 0f 7e ca       	movq   %xmm1,%rdx
  40af9b:	89 d2                	mov    %edx,%edx
  40af9d:	66 48 0f 6e c9       	movq   %rcx,%xmm1
  40afa2:	f3 0f 5e cb          	divss  %xmm3,%xmm1
  40afa6:	66 48 0f 7e c9       	movq   %xmm1,%rcx
  40afab:	89 c9                	mov    %ecx,%ecx
  40afad:	48 89 8d 10 fe ff ff 	mov    %rcx,-0x1f0(%rbp)
  40afb4:	48 89 8d 70 f5 ff ff 	mov    %rcx,-0xa90(%rbp)
  40afbb:	4c 89 85 78 f5 ff ff 	mov    %r8,-0xa88(%rbp)
  40afc2:	66 48 0f 6e c9       	movq   %rcx,%xmm1
  40afc7:	f3 0f 11 8d 1c fe ff ff 	movss  %xmm1,-0x1e4(%rbp)
  40afcf:	66 49 0f 6e d0       	movq   %r8,%xmm2
  40afd4:	f3 0f 11 95 e0 fd ff ff 	movss  %xmm2,-0x220(%rbp)
  40afdc:	f3 0f 59 d1          	mulss  %xmm1,%xmm2
  40afe0:	66 49 0f 7e d0       	movq   %xmm2,%r8
  40afe5:	45 89 c0             	mov    %r8d,%r8d
  40afe8:	66 49 0f 6e d1       	movq   %r9,%xmm2
  40afed:	f3 0f 5e d3          	divss  %xmm3,%xmm2
  40aff1:	66 49 0f 7e d1       	movq   %xmm2,%r9
  40aff6:	45 89 c9             	mov    %r9d,%r9d
  40aff9:	4c 89 8d f0 fd ff ff 	mov    %r9,-0x210(%rbp)
  40b000:	4c 89 8d 70 f5 ff ff 	mov    %r9,-0xa90(%rbp)
  40b007:	48 89 b5 78 f5 ff ff 	mov    %rsi,-0xa88(%rbp)
  40b00e:	66 49 0f 6e d1       	movq   %r9,%xmm2
  40b013:	f3 0f 11 95 04 fe ff ff 	movss  %xmm2,-0x1fc(%rbp)
  40b01b:	66 48 0f 6e e6       	movq   %rsi,%xmm4
  40b020:	f3 0f 11 a5 e4 fd ff ff 	movss  %xmm4,-0x21c(%rbp)
  40b028:	f3 0f 59 d4          	mulss  %xmm4,%xmm2
  40b02c:	66 48 0f 7e d6       	movq   %xmm2,%rsi
  40b031:	89 f6                	mov    %esi,%esi
  40b033:	4c 89 85 70 f5 ff ff 	mov    %r8,-0xa90(%rbp)
  40b03a:	48 89 b5 78 f5 ff ff 	mov    %rsi,-0xa88(%rbp)
  40b041:	66 49 0f 6e d0       	movq   %r8,%xmm2
  40b046:	66 48 0f 6e de       	movq   %rsi,%xmm3
  40b04b:	f3 0f 58 d3          	addss  %xmm3,%xmm2
  40b04f:	66 48 0f 7e d6       	movq   %xmm2,%rsi
  40b054:	89 f6                	mov    %esi,%esi
  40b056:	4c 89 a5 70 f5 ff ff 	mov    %r12,-0xa90(%rbp)
  40b05d:	48 89 95 78 f5 ff ff 	mov    %rdx,-0xa88(%rbp)
  40b064:	66 49 0f 6e d4       	movq   %r12,%xmm2
  40b069:	f3 0f 11 95 e8 fd ff ff 	movss  %xmm2,-0x218(%rbp)
  40b071:	66 48 0f 6e ea       	movq   %rdx,%xmm5
  40b076:	f3 0f 11 ad ec fd ff ff 	movss  %xmm5,-0x214(%rbp)
  40b07e:	f3 0f 59 d5          	mulss  %xmm5,%xmm2
  40b082:	66 48 0f 7e d2       	movq   %xmm2,%rdx
  40b087:	89 d2                	mov    %edx,%edx
  40b089:	48 89 b5 70 f5 ff ff 	mov    %rsi,-0xa90(%rbp)
  40b090:	48 89 95 78 f5 ff ff 	mov    %rdx,-0xa88(%rbp)
  40b097:	66 48 0f 6e d6       	movq   %rsi,%xmm2
  40b09c:	66 48 0f 6e da       	movq   %rdx,%xmm3
  40b0a1:	f3 0f 58 d3          	addss  %xmm3,%xmm2
  40b0a5:	66 48 0f 7e d2       	movq   %xmm2,%rdx
  40b0aa:	89 d6                	mov    %edx,%esi
  40b0ac:	66 48 0f 6e d6       	movq   %rsi,%xmm2
  40b0b1:	f3 0f 10 1d 6b 5f 02 00 	movss  0x25f6b(%rip),%xmm3        # 431024 <_IO_stdin_used+0x24>
  40b0b9:	0f 2e da             	ucomiss %xmm2,%xmm3
  40b0bc:	0f 97 c2             	seta   %dl
  40b0bf:	0f b6 d2             	movzbl %dl,%edx
  40b0c2:	89 d2                	mov    %edx,%edx
  40b0c4:	48 83 fa 01          	cmp    $0x1,%rdx
  40b0c8:	49 89 c4             	mov    %rax,%r12
  40b0cb:	0f 94 c0             	sete   %al
  40b0ce:	0f b6 c0             	movzbl %al,%eax
  40b0d1:	48 c1 ea 28          	shr    $0x28,%rdx
  40b0d5:	48 81 e2 ff ff 7f 00 	and    $0x7fffff,%rdx
  40b0dc:	48 81 fa 02 00 01 00 	cmp    $0x10002,%rdx
  40b0e3:	0f 94 c2             	sete   %dl
  40b0e6:	0f b6 d2             	movzbl %dl,%edx
  40b0e9:	09 d0                	or     %edx,%eax
  40b0eb:	75 4c                	jne    40b139 <p113d_FID_36_100_105_114_101_99_116_46_116_114_97_99_101_+0x1899>
  40b0ed:	83 f0 01             	xor    $0x1,%eax
  40b0f0:	75 38                	jne    40b12a <p113d_FID_36_100_105_114_101_99_116_46_116_114_97_99_101_+0x188a>
  40b0f2:	be 04 00 00 00       	mov    $0x4,%esi
  40b0f7:	49 89 ff             	mov    %rdi,%r15
  40b0fa:	e8 a1 02 02 00       	callq  42b3a0 <p111_rt_fail>
  40b0ff:	4c 89 ff             	mov    %r15,%rdi
  40b102:	4c 89 e0             	mov    %r12,%rax
  40b105:	48 8b 8d 10 fe ff ff 	mov    -0x1f0(%rbp),%rcx
  40b10c:	4c 8b a5 08 fe ff ff 	mov    -0x1f8(%rbp),%r12
  40b113:	f3 0f 10 8d 1c fe ff ff 	movss  -0x1e4(%rbp),%xmm1
  40b11b:	f3 0f 10 85 18 fe ff ff 	movss  -0x1e8(%rbp),%xmm0
  40b123:	be 00 00 00 00       	mov    $0x0,%esi
  40b128:	eb 06                	jmp    40b130 <p113d_FID_36_100_105_114_101_99_116_46_116_114_97_99_101_+0x1890>
  40b12a:	4c 89 e0             	mov    %r12,%rax
  40b12d:	4d 89 fc             	mov    %r15,%r12
  40b130:	48 89 b5 c8 fd ff ff 	mov    %rsi,-0x238(%rbp)
  40b137:	eb 11                	jmp    40b14a <p113d_FID_36_100_105_114_101_99_116_46_116_114_97_99_101_+0x18aa>
  40b139:	4c 89 e0             	mov    %r12,%rax
  40b13c:	4d 89 fc             	mov    %r15,%r12
  40b13f:	48 c7 85 c8 fd ff ff 00 00 00 00 	movq   $0x0,-0x238(%rbp)
  40b14a:	48 c7 85 70 f5 ff ff 6f 12 83 3a 	movq   $0x3a83126f,-0xa90(%rbp)
  40b155:	48 89 8d 78 f5 ff ff 	mov    %rcx,-0xa88(%rbp)
  40b15c:	f3 0f 59 0d c4 5e 02 00 	mulss  0x25ec4(%rip),%xmm1        # 431028 <_IO_stdin_used+0x28>
  40b164:	66 48 0f 7e c9       	movq   %xmm1,%rcx
  40b169:	89 c9                	mov    %ecx,%ecx
  40b16b:	4c 89 ad 70 f5 ff ff 	mov    %r13,-0xa90(%rbp)
  40b172:	48 89 8d 78 f5 ff ff 	mov    %rcx,-0xa88(%rbp)
  40b179:	66 48 0f 6e c9       	movq   %rcx,%xmm1
  40b17e:	f3 0f 58 c1          	addss  %xmm1,%xmm0
  40b182:	49 89 c5             	mov    %rax,%r13
  40b185:	66 48 0f 7e c0       	movq   %xmm0,%rax
  40b18a:	89 c2                	mov    %eax,%edx
  40b18c:	48 89 95 d0 fd ff ff 	mov    %rdx,-0x230(%rbp)
  40b193:	f3 0f 10 0d a9 5e 02 00 	movss  0x25ea9(%rip),%xmm1        # 431044 <_IO_stdin_used+0x44>
  40b19b:	f3 0f 10 05 99 5e 02 00 	movss  0x25e99(%rip),%xmm0        # 43103c <_IO_stdin_used+0x3c>
  40b1a3:	49 89 ff             	mov    %rdi,%r15
  40b1a6:	e8 a5 ab ff ff       	callq  405d50 <p126_typed_FID_36_100_105_114_101_99_116_46_102_108_>
  40b1ab:	4c 89 ff             	mov    %r15,%rdi
  40b1ae:	48 89 c1             	mov    %rax,%rcx
  40b1b1:	4c 89 e8             	mov    %r13,%rax
  40b1b4:	4c 8b ad f8 fd ff ff 	mov    -0x208(%rbp),%r13
  40b1bb:	48 8b 95 f0 fd ff ff 	mov    -0x210(%rbp),%rdx
  40b1c2:	f3 0f 10 8d 04 fe ff ff 	movss  -0x1fc(%rbp),%xmm1
  40b1ca:	f3 0f 10 85 00 fe ff ff 	movss  -0x200(%rbp),%xmm0
  40b1d2:	48 89 8d 70 f5 ff ff 	mov    %rcx,-0xa90(%rbp)
  40b1d9:	48 89 95 78 f5 ff ff 	mov    %rdx,-0xa88(%rbp)
  40b1e0:	66 48 0f 6e d1       	movq   %rcx,%xmm2
  40b1e5:	f3 0f 59 ca          	mulss  %xmm2,%xmm1
  40b1e9:	66 48 0f 7e c9       	movq   %xmm1,%rcx
  40b1ee:	89 c9                	mov    %ecx,%ecx
  40b1f0:	4c 89 b5 70 f5 ff ff 	mov    %r14,-0xa90(%rbp)
  40b1f7:	48 89 8d 78 f5 ff ff 	mov    %rcx,-0xa88(%rbp)
  40b1fe:	66 48 0f 6e c9       	movq   %rcx,%xmm1
  40b203:	f3 0f 58 c1          	addss  %xmm1,%xmm0
  40b207:	49 89 c6             	mov    %rax,%r14
  40b20a:	66 48 0f 7e c0       	movq   %xmm0,%rax
  40b20f:	89 c1                	mov    %eax,%ecx
  40b211:	48 89 8d d8 fd ff ff 	mov    %rcx,-0x228(%rbp)
  40b218:	f3 0f 10 0d 24 5e 02 00 	movss  0x25e24(%rip),%xmm1        # 431044 <_IO_stdin_used+0x44>
  40b220:	f3 0f 10 05 14 5e 02 00 	movss  0x25e14(%rip),%xmm0        # 43103c <_IO_stdin_used+0x3c>
  40b228:	49 89 ff             	mov    %rdi,%r15
  40b22b:	e8 20 ab ff ff       	callq  405d50 <p126_typed_FID_36_100_105_114_101_99_116_46_102_108_>
  40b230:	4c 89 ff             	mov    %r15,%rdi
  40b233:	49 89 c0             	mov    %rax,%r8
  40b236:	4c 89 f0             	mov    %r14,%rax
  40b239:	48 8b b5 c8 fd ff ff 	mov    -0x238(%rbp),%rsi
  40b240:	48 8b 8d d8 fd ff ff 	mov    -0x228(%rbp),%rcx
  40b247:	48 8b 95 d0 fd ff ff 	mov    -0x230(%rbp),%rdx
  40b24e:	f3 0f 10 ad ec fd ff ff 	movss  -0x214(%rbp),%xmm5
  40b256:	f3 0f 10 8d e8 fd ff ff 	movss  -0x218(%rbp),%xmm1
  40b25e:	f3 0f 10 a5 e4 fd ff ff 	movss  -0x21c(%rbp),%xmm4
  40b266:	f3 0f 10 9d e0 fd ff ff 	movss  -0x220(%rbp),%xmm3
  40b26e:	f3 0f 10 85 c4 fd ff ff 	movss  -0x23c(%rbp),%xmm0
  40b276:	4c 89 85 70 f5 ff ff 	mov    %r8,-0xa90(%rbp)
  40b27d:	4c 89 ad 78 f5 ff ff 	mov    %r13,-0xa88(%rbp)
  40b284:	66 49 0f 6e d0       	movq   %r8,%xmm2
  40b289:	f3 0f 59 ca          	mulss  %xmm2,%xmm1
  40b28d:	66 49 0f 7e c8       	movq   %xmm1,%r8
  40b292:	45 89 c0             	mov    %r8d,%r8d
  40b295:	4c 89 a5 70 f5 ff ff 	mov    %r12,-0xa90(%rbp)
  40b29c:	4c 89 85 78 f5 ff ff 	mov    %r8,-0xa88(%rbp)
  40b2a3:	66 49 0f 6e c8       	movq   %r8,%xmm1
  40b2a8:	f3 0f 58 c1          	addss  %xmm1,%xmm0
  40b2ac:	49 89 c5             	mov    %rax,%r13
  40b2af:	66 48 0f 7e c0       	movq   %xmm0,%rax
  40b2b4:	89 c0                	mov    %eax,%eax
  40b2b6:	48 c7 85 70 f5 ff ff 00 ca 9a 3b 	movq   $0x3b9aca00,-0xa90(%rbp)
  40b2c1:	48 c7 85 70 f5 ff ff 00 ca 9a 3b 	movq   $0x3b9aca00,-0xa90(%rbp)
  40b2cc:	66 48 0f 6e c2       	movq   %rdx,%xmm0
  40b2d1:	66 48 0f 6e c9       	movq   %rcx,%xmm1
  40b2d6:	66 48 0f 6e d0       	movq   %rax,%xmm2
  40b2db:	41 b8 00 00 00 00    	mov    $0x0,%r8d
  40b2e1:	b9 28 6b 6e 4e       	mov    $0x4e6e6b28,%ecx
  40b2e6:	ba 28 6b 6e 4e       	mov    $0x4e6e6b28,%edx
  40b2eb:	49 89 f7             	mov    %rsi,%r15
  40b2ee:	be 09 00 00 00       	mov    $0x9,%esi
  40b2f3:	49 89 fc             	mov    %rdi,%r12
  40b2f6:	e8 e5 bb ff ff       	callq  406ee0 <p126_typed_FID_36_100_105_114_101_99_116_46_110_101_97_114_101_115_116_46_116_>
  40b2fb:	4c 89 e7             	mov    %r12,%rdi
  40b2fe:	48 89 85 b8 fd ff ff 	mov    %rax,-0x248(%rbp)
  40b305:	f3 0f 10 0d 33 5d 02 00 	movss  0x25d33(%rip),%xmm1        # 431040 <_IO_stdin_used+0x40>
  40b30d:	f3 0f 10 05 27 5d 02 00 	movss  0x25d27(%rip),%xmm0        # 43103c <_IO_stdin_used+0x3c>
  40b315:	49 89 fc             	mov    %rdi,%r12
  40b318:	e8 33 aa ff ff       	callq  405d50 <p126_typed_FID_36_100_105_114_101_99_116_46_102_108_>
  40b31d:	4c 89 e7             	mov    %r12,%rdi
  40b320:	49 89 c4             	mov    %rax,%r12
  40b323:	f3 0f 10 0d 0d 5d 02 00 	movss  0x25d0d(%rip),%xmm1        # 431038 <_IO_stdin_used+0x38>
  40b32b:	f3 0f 10 05 01 5d 02 00 	movss  0x25d01(%rip),%xmm0        # 431034 <_IO_stdin_used+0x34>
  40b333:	49 89 fe             	mov    %rdi,%r14
  40b336:	e8 15 aa ff ff       	callq  405d50 <p126_typed_FID_36_100_105_114_101_99_116_46_102_108_>
  40b33b:	4c 89 fe             	mov    %r15,%rsi
  40b33e:	4c 89 f7             	mov    %r14,%rdi
  40b341:	49 95                	xchg   %rax,%r13
  40b343:	49 89 c6             	mov    %rax,%r14
  40b346:	48 8b 85 b8 fd ff ff 	mov    -0x248(%rbp),%rax
  40b34d:	f3 0f 10 8d c0 fd ff ff 	movss  -0x240(%rbp),%xmm1
  40b355:	66 48 0f 6e c0       	movq   %rax,%xmm0
  40b35a:	e8 c1 b0 ff ff       	callq  406420 <p126_typed_FID_36_100_105_114_101_99_116_46_115_104_97_100_101_>
  40b35f:	48 89 c1             	mov    %rax,%rcx
  40b362:	4c 89 f0             	mov    %r14,%rax
  40b365:	f3 0f 10 8d b4 fd ff ff 	movss  -0x24c(%rbp),%xmm1
  40b36d:	f3 0f 10 95 b0 fd ff ff 	movss  -0x250(%rbp),%xmm2
  40b375:	4c 89 ad 70 f5 ff ff 	mov    %r13,-0xa90(%rbp)
  40b37c:	48 89 8d 78 f5 ff ff 	mov    %rcx,-0xa88(%rbp)
  40b383:	66 49 0f 6e c5       	movq   %r13,%xmm0
  40b388:	66 48 0f 6e d9       	movq   %rcx,%xmm3
  40b38d:	f3 0f 59 c3          	mulss  %xmm3,%xmm0
  40b391:	66 48 0f 7e c1       	movq   %xmm0,%rcx
  40b396:	89 c9                	mov    %ecx,%ecx
  40b398:	4c 89 a5 70 f5 ff ff 	mov    %r12,-0xa90(%rbp)
  40b39f:	48 89 8d 78 f5 ff ff 	mov    %rcx,-0xa88(%rbp)
  40b3a6:	66 49 0f 6e c4       	movq   %r12,%xmm0
  40b3ab:	66 48 0f 6e d9       	movq   %rcx,%xmm3
  40b3b0:	f3 0f 58 c3          	addss  %xmm3,%xmm0
  40b3b4:	66 48 0f 7e c1       	movq   %xmm0,%rcx
  40b3b9:	89 c9                	mov    %ecx,%ecx
  40b3bb:	48 89 9d 70 f5 ff ff 	mov    %rbx,-0xa90(%rbp)
  40b3c2:	48 89 8d 78 f5 ff ff 	mov    %rcx,-0xa88(%rbp)
  40b3c9:	66 48 0f 6e c1       	movq   %rcx,%xmm0
  40b3ce:	f3 0f 59 c2          	mulss  %xmm2,%xmm0
  40b3d2:	48 89 c3             	mov    %rax,%rbx
  40b3d5:	66 48 0f 7e c0       	movq   %xmm0,%rax
  40b3da:	89 c0                	mov    %eax,%eax
  40b3dc:	48 89 9d 70 f5 ff ff 	mov    %rbx,-0xa90(%rbp)
  40b3e3:	48 89 85 78 f5 ff ff 	mov    %rax,-0xa88(%rbp)
  40b3ea:	66 48 0f 6e c0       	movq   %rax,%xmm0
  40b3ef:	f3 0f 58 c1          	addss  %xmm1,%xmm0
  40b3f3:	66 48 0f 7e c0       	movq   %xmm0,%rax
  40b3f8:	89 c0                	mov    %eax,%eax
  40b3fa:	41 5f                	pop    %r15
  40b3fc:	41 5e                	pop    %r14
  40b3fe:	41 5d                	pop    %r13
  40b400:	41 5c                	pop    %r12
  40b402:	5b                   	pop    %rbx
  40b403:	c9                   	leaveq 
  40b404:	c3                   	retq   
  40b405:	66 66 2e 0f 1f 84 00 00 00 00 00 	data16 nopw %cs:0x0(%rax,%rax,1)

