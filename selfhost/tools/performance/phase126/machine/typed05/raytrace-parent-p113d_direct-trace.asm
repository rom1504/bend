000000000040ac90 <p113d_FID_36_100_105_114_101_99_116_46_116_114_97_99_101_>:
  40ac90:	f3 0f 1e fa          	endbr64 
  40ac94:	55                   	push   %rbp
  40ac95:	48 89 e5             	mov    %rsp,%rbp
  40ac98:	48 81 ec d8 0a 00 00 	sub    $0xad8,%rsp
  40ac9f:	53                   	push   %rbx
  40aca0:	41 54                	push   %r12
  40aca2:	41 55                	push   %r13
  40aca4:	41 56                	push   %r14
  40aca6:	41 57                	push   %r15
  40aca8:	48 8b 5d 30          	mov    0x30(%rbp),%rbx
  40acac:	48 89 9d b0 fe ff ff 	mov    %rbx,-0x150(%rbp)
  40acb3:	48 8b 45 28          	mov    0x28(%rbp),%rax
  40acb7:	4c 8b 65 20          	mov    0x20(%rbp),%r12
  40acbb:	4d 89 e5             	mov    %r12,%r13
  40acbe:	4c 8b 65 18          	mov    0x18(%rbp),%r12
  40acc2:	4c 8b 7d 10          	mov    0x10(%rbp),%r15
  40acc6:	4d 87 c8             	xchg   %r9,%r8
  40acc9:	49 89 ca             	mov    %rcx,%r10
  40accc:	48 89 f1             	mov    %rsi,%rcx
  40accf:	48 89 d6             	mov    %rdx,%rsi
  40acd2:	4c 89 e2             	mov    %r12,%rdx
  40acd5:	4c 89 85 70 fe ff ff 	mov    %r8,-0x190(%rbp)
  40acdc:	4c 89 8d 88 fe ff ff 	mov    %r9,-0x178(%rbp)
  40ace3:	4c 89 95 98 fe ff ff 	mov    %r10,-0x168(%rbp)
  40acea:	48 89 8d f0 fe ff ff 	mov    %rcx,-0x110(%rbp)
  40acf1:	48 83 f9 00          	cmp    $0x0,%rcx
  40acf5:	0f 94 c1             	sete   %cl
  40acf8:	0f b6 c9             	movzbl %cl,%ecx
  40acfb:	66 49 0f 6e f7       	movq   %r15,%xmm6
  40ad00:	f3 0f 11 b5 ac fe ff ff 	movss  %xmm6,-0x154(%rbp)
  40ad08:	66 49 0f 6e ca       	movq   %r10,%xmm1
  40ad0d:	f3 0f 11 8d c0 fe ff ff 	movss  %xmm1,-0x140(%rbp)
  40ad15:	66 48 0f 6e ea       	movq   %rdx,%xmm5
  40ad1a:	f3 0f 11 ad b8 fe ff ff 	movss  %xmm5,-0x148(%rbp)
  40ad22:	66 49 0f 6e d1       	movq   %r9,%xmm2
  40ad27:	f3 0f 11 95 c4 fe ff ff 	movss  %xmm2,-0x13c(%rbp)
  40ad2f:	66 49 0f 6e e5       	movq   %r13,%xmm4
  40ad34:	f3 0f 11 a5 bc fe ff ff 	movss  %xmm4,-0x144(%rbp)
  40ad3c:	66 49 0f 6e d8       	movq   %r8,%xmm3
  40ad41:	f3 0f 11 9d c8 fe ff ff 	movss  %xmm3,-0x138(%rbp)
  40ad49:	66 48 0f 6e d3       	movq   %rbx,%xmm2
  40ad4e:	f3 0f 11 95 70 fd ff ff 	movss  %xmm2,-0x290(%rbp)
  40ad56:	66 48 0f 6e c8       	movq   %rax,%xmm1
  40ad5b:	f3 0f 11 8d 74 fd ff ff 	movss  %xmm1,-0x28c(%rbp)
  40ad63:	48 89 c3             	mov    %rax,%rbx
  40ad66:	48 89 f0             	mov    %rsi,%rax
  40ad69:	48 c1 e8 28          	shr    $0x28,%rax
  40ad6d:	48 25 ff ff 00 00    	and    $0xffff,%rax
  40ad73:	41 b8 00 00 00 41    	mov    $0x41000000,%r8d
  40ad79:	4c 89 85 28 fe ff ff 	mov    %r8,-0x1d8(%rbp)
  40ad80:	41 b8 cd cc 4c 3e    	mov    $0x3e4ccccd,%r8d
  40ad86:	4c 89 85 58 fe ff ff 	mov    %r8,-0x1a8(%rbp)
  40ad8d:	41 b8 00 00 60 c0    	mov    $0xc0600000,%r8d
  40ad93:	4c 89 85 68 fe ff ff 	mov    %r8,-0x198(%rbp)
  40ad9a:	41 ba 00 00 80 3f    	mov    $0x3f800000,%r10d
  40ada0:	4c 89 95 a0 fe ff ff 	mov    %r10,-0x160(%rbp)
  40ada7:	83 f9 00             	cmp    $0x0,%ecx
  40adaa:	0f 85 96 0d 00 00    	jne    40bb46 <p113d_FID_36_100_105_114_101_99_116_46_116_114_97_99_101_+0xeb6>
  40adb0:	48 3d 97 00 00 00    	cmp    $0x97,%rax
  40adb6:	74 14                	je     40adcc <p113d_FID_36_100_105_114_101_99_116_46_116_114_97_99_101_+0x13c>
  40adb8:	be 04 00 00 00       	mov    $0x4,%esi
  40adbd:	e8 3e 35 02 00       	callq  42e300 <p111_rt_fail>
  40adc2:	b8 00 00 00 00       	mov    $0x0,%eax
  40adc7:	e9 fa 19 00 00       	jmpq   40c7c6 <p113d_FID_36_100_105_114_101_99_116_46_116_114_97_99_101_+0x1b36>
  40adcc:	49 89 d6             	mov    %rdx,%r14
  40adcf:	48 8d 95 30 f5 ff ff 	lea    -0xad0(%rbp),%rdx
  40add6:	49 89 fc             	mov    %rdi,%r12
  40add9:	e8 a2 87 02 00       	callq  433580 <p125_rt_take3>
  40adde:	4c 89 f2             	mov    %r14,%rdx
  40ade1:	4c 89 e7             	mov    %r12,%rdi
  40ade4:	48 89 d8             	mov    %rbx,%rax
  40ade7:	48 8b 8d 30 f5 ff ff 	mov    -0xad0(%rbp),%rcx
  40adee:	49 89 d6             	mov    %rdx,%r14
  40adf1:	48 8b 95 38 f5 ff ff 	mov    -0xac8(%rbp),%rdx
  40adf8:	48 89 55 f0          	mov    %rdx,-0x10(%rbp)
  40adfc:	48 8b b5 40 f5 ff ff 	mov    -0xac0(%rbp),%rsi
  40ae03:	48 89 b5 50 ff ff ff 	mov    %rsi,-0xb0(%rbp)
  40ae0a:	48 83 f9 01          	cmp    $0x1,%rcx
  40ae0e:	48 89 c3             	mov    %rax,%rbx
  40ae11:	0f 94 c0             	sete   %al
  40ae14:	0f b6 c0             	movzbl %al,%eax
  40ae17:	48 c1 e9 28          	shr    $0x28,%rcx
  40ae1b:	48 81 e1 ff ff 7f 00 	and    $0x7fffff,%rcx
  40ae22:	48 81 f9 02 00 01 00 	cmp    $0x10002,%rcx
  40ae29:	0f 94 c1             	sete   %cl
  40ae2c:	0f b6 c9             	movzbl %cl,%ecx
  40ae2f:	09 c8                	or     %ecx,%eax
  40ae31:	0f 85 04 0d 00 00    	jne    40bb3b <p113d_FID_36_100_105_114_101_99_116_46_116_114_97_99_101_+0xeab>
  40ae37:	83 f0 01             	xor    $0x1,%eax
  40ae3a:	75 14                	jne    40ae50 <p113d_FID_36_100_105_114_101_99_116_46_116_114_97_99_101_+0x1c0>
  40ae3c:	be 04 00 00 00       	mov    $0x4,%esi
  40ae41:	e8 ba 34 02 00       	callq  42e300 <p111_rt_fail>
  40ae46:	b8 00 00 00 00       	mov    $0x0,%eax
  40ae4b:	e9 76 19 00 00       	jmpq   40c7c6 <p113d_FID_36_100_105_114_101_99_116_46_116_114_97_99_101_+0x1b36>
  40ae50:	49 89 fc             	mov    %rdi,%r12
  40ae53:	e8 f8 b7 ff ff       	callq  406650 <p113d_FID_36_100_105_114_101_99_116_46_115_114_>
  40ae58:	4c 89 e7             	mov    %r12,%rdi
  40ae5b:	48 89 45 e0          	mov    %rax,-0x20(%rbp)
  40ae5f:	48 89 d8             	mov    %rbx,%rax
  40ae62:	f3 0f 10 9d c8 fe ff ff 	movss  -0x138(%rbp),%xmm3
  40ae6a:	f3 0f 10 a5 bc fe ff ff 	movss  -0x144(%rbp),%xmm4
  40ae72:	f3 0f 10 95 c4 fe ff ff 	movss  -0x13c(%rbp),%xmm2
  40ae7a:	f3 0f 10 ad b8 fe ff ff 	movss  -0x148(%rbp),%xmm5
  40ae82:	f3 0f 10 8d c0 fe ff ff 	movss  -0x140(%rbp),%xmm1
  40ae8a:	f3 0f 10 b5 ac fe ff ff 	movss  -0x154(%rbp),%xmm6
  40ae92:	48 8b b5 50 ff ff ff 	mov    -0xb0(%rbp),%rsi
  40ae99:	48 8b 4d f0          	mov    -0x10(%rbp),%rcx
  40ae9d:	48 8b 95 70 fe ff ff 	mov    -0x190(%rbp),%rdx
  40aea4:	4c 8b 8d 88 fe ff ff 	mov    -0x178(%rbp),%r9
  40aeab:	4c 8b 95 98 fe ff ff 	mov    -0x168(%rbp),%r10
  40aeb2:	48 89 8d 30 f5 ff ff 	mov    %rcx,-0xad0(%rbp)
  40aeb9:	4c 89 bd 38 f5 ff ff 	mov    %r15,-0xac8(%rbp)
  40aec0:	66 48 0f 6e c1       	movq   %rcx,%xmm0
  40aec5:	f3 0f 59 f0          	mulss  %xmm0,%xmm6
  40aec9:	66 49 0f 7e f0       	movq   %xmm6,%r8
  40aece:	45 89 c0             	mov    %r8d,%r8d
  40aed1:	4c 89 95 30 f5 ff ff 	mov    %r10,-0xad0(%rbp)
  40aed8:	4c 89 85 38 f5 ff ff 	mov    %r8,-0xac8(%rbp)
  40aedf:	66 49 0f 6e f0       	movq   %r8,%xmm6
  40aee4:	f3 0f 58 ce          	addss  %xmm6,%xmm1
  40aee8:	66 49 0f 7e c8       	movq   %xmm1,%r8
  40aeed:	45 89 c0             	mov    %r8d,%r8d
  40aef0:	4c 89 45 b0          	mov    %r8,-0x50(%rbp)
  40aef4:	48 89 8d 30 f5 ff ff 	mov    %rcx,-0xad0(%rbp)
  40aefb:	4c 89 b5 38 f5 ff ff 	mov    %r14,-0xac8(%rbp)
  40af02:	f3 0f 10 c8          	movss  %xmm0,%xmm1
  40af06:	f3 0f 59 cd          	mulss  %xmm5,%xmm1
  40af0a:	66 49 0f 7e c8       	movq   %xmm1,%r8
  40af0f:	45 89 c0             	mov    %r8d,%r8d
  40af12:	4c 89 8d 30 f5 ff ff 	mov    %r9,-0xad0(%rbp)
  40af19:	4c 89 85 38 f5 ff ff 	mov    %r8,-0xac8(%rbp)
  40af20:	66 49 0f 6e c8       	movq   %r8,%xmm1
  40af25:	f3 0f 58 ca          	addss  %xmm2,%xmm1
  40af29:	66 49 0f 7e c8       	movq   %xmm1,%r8
  40af2e:	45 89 c0             	mov    %r8d,%r8d
  40af31:	4c 89 45 a8          	mov    %r8,-0x58(%rbp)
  40af35:	48 89 8d 30 f5 ff ff 	mov    %rcx,-0xad0(%rbp)
  40af3c:	4c 89 ad 38 f5 ff ff 	mov    %r13,-0xac8(%rbp)
  40af43:	f3 0f 59 c4          	mulss  %xmm4,%xmm0
  40af47:	66 48 0f 7e c1       	movq   %xmm0,%rcx
  40af4c:	89 c9                	mov    %ecx,%ecx
  40af4e:	48 89 95 30 f5 ff ff 	mov    %rdx,-0xad0(%rbp)
  40af55:	48 89 8d 38 f5 ff ff 	mov    %rcx,-0xac8(%rbp)
  40af5c:	66 48 0f 6e c1       	movq   %rcx,%xmm0
  40af61:	f3 0f 58 c3          	addss  %xmm3,%xmm0
  40af65:	48 89 c3             	mov    %rax,%rbx
  40af68:	66 48 0f 7e c0       	movq   %xmm0,%rax
  40af6d:	41 89 c2             	mov    %eax,%r10d
  40af70:	4c 89 55 80          	mov    %r10,-0x80(%rbp)
  40af74:	49 89 fc             	mov    %rdi,%r12
  40af77:	e8 d4 b9 ff ff       	callq  406950 <p113d_FID_36_100_105_114_101_99_116_46_115_120_>
  40af7c:	4c 89 e7             	mov    %r12,%rdi
  40af7f:	48 89 c1             	mov    %rax,%rcx
  40af82:	48 89 d8             	mov    %rbx,%rax
  40af85:	48 8b 75 b0          	mov    -0x50(%rbp),%rsi
  40af89:	4c 8b 45 e0          	mov    -0x20(%rbp),%r8
  40af8d:	48 89 f2             	mov    %rsi,%rdx
  40af90:	48 8b b5 50 ff ff ff 	mov    -0xb0(%rbp),%rsi
  40af97:	48 89 95 30 f5 ff ff 	mov    %rdx,-0xad0(%rbp)
  40af9e:	48 89 8d 38 f5 ff ff 	mov    %rcx,-0xac8(%rbp)
  40afa5:	66 48 0f 6e c2       	movq   %rdx,%xmm0
  40afaa:	f3 0f 11 45 b8       	movss  %xmm0,-0x48(%rbp)
  40afaf:	66 48 0f 6e c9       	movq   %rcx,%xmm1
  40afb4:	f3 0f 5c c1          	subss  %xmm1,%xmm0
  40afb8:	66 48 0f 7e c1       	movq   %xmm0,%rcx
  40afbd:	89 c9                	mov    %ecx,%ecx
  40afbf:	48 89 8d 30 f5 ff ff 	mov    %rcx,-0xad0(%rbp)
  40afc6:	4c 89 85 38 f5 ff ff 	mov    %r8,-0xac8(%rbp)
  40afcd:	66 48 0f 6e c1       	movq   %rcx,%xmm0
  40afd2:	66 49 0f 6e e0       	movq   %r8,%xmm4
  40afd7:	f3 0f 11 65 e8       	movss  %xmm4,-0x18(%rbp)
  40afdc:	f3 0f 5e c4          	divss  %xmm4,%xmm0
  40afe0:	48 89 c3             	mov    %rax,%rbx
  40afe3:	66 48 0f 7e c0       	movq   %xmm0,%rax
  40afe8:	89 c1                	mov    %eax,%ecx
  40afea:	48 89 8d 28 ff ff ff 	mov    %rcx,-0xd8(%rbp)
  40aff1:	49 89 fc             	mov    %rdi,%r12
  40aff4:	e8 f7 b7 ff ff       	callq  4067f0 <p113d_FID_36_100_105_114_101_99_116_46_115_121_>
  40aff9:	4c 89 e7             	mov    %r12,%rdi
  40affc:	48 89 c1             	mov    %rax,%rcx
  40afff:	48 89 d8             	mov    %rbx,%rax
  40b002:	48 8b 75 a8          	mov    -0x58(%rbp),%rsi
  40b006:	f3 0f 10 65 e8       	movss  -0x18(%rbp),%xmm4
  40b00b:	4c 8b 45 e0          	mov    -0x20(%rbp),%r8
  40b00f:	48 89 f2             	mov    %rsi,%rdx
  40b012:	48 8b b5 50 ff ff ff 	mov    -0xb0(%rbp),%rsi
  40b019:	48 89 95 30 f5 ff ff 	mov    %rdx,-0xad0(%rbp)
  40b020:	48 89 8d 38 f5 ff ff 	mov    %rcx,-0xac8(%rbp)
  40b027:	66 48 0f 6e c2       	movq   %rdx,%xmm0
  40b02c:	f3 0f 11 45 a4       	movss  %xmm0,-0x5c(%rbp)
  40b031:	f3 0f 10 c8          	movss  %xmm0,%xmm1
  40b035:	66 48 0f 6e c1       	movq   %rcx,%xmm0
  40b03a:	0f 57 05 cf 8f 02 00 	xorps  0x28fcf(%rip),%xmm0        # 434010 <_IO_stdin_used+0x10>
  40b041:	f3 0f 58 c1          	addss  %xmm1,%xmm0
  40b045:	66 48 0f 7e c1       	movq   %xmm0,%rcx
  40b04a:	89 c9                	mov    %ecx,%ecx
  40b04c:	48 89 8d 30 f5 ff ff 	mov    %rcx,-0xad0(%rbp)
  40b053:	4c 89 85 38 f5 ff ff 	mov    %r8,-0xac8(%rbp)
  40b05a:	66 48 0f 6e c1       	movq   %rcx,%xmm0
  40b05f:	f3 0f 5e c4          	divss  %xmm4,%xmm0
  40b063:	48 89 c3             	mov    %rax,%rbx
  40b066:	66 48 0f 7e c0       	movq   %xmm0,%rax
  40b06b:	89 c0                	mov    %eax,%eax
  40b06d:	48 89 85 30 ff ff ff 	mov    %rax,-0xd0(%rbp)
  40b074:	49 89 fc             	mov    %rdi,%r12
  40b077:	e8 a4 b6 ff ff       	callq  406720 <p113d_FID_36_100_105_114_101_99_116_46_115_122_>
  40b07c:	4c 89 e7             	mov    %r12,%rdi
  40b07f:	48 89 c2             	mov    %rax,%rdx
  40b082:	48 89 d8             	mov    %rbx,%rax
  40b085:	4c 8b 55 80          	mov    -0x80(%rbp),%r10
  40b089:	48 8b 75 a8          	mov    -0x58(%rbp),%rsi
  40b08d:	48 8b 4d b0          	mov    -0x50(%rbp),%rcx
  40b091:	f3 0f 10 4d a4       	movss  -0x5c(%rbp),%xmm1
  40b096:	f3 0f 10 65 e8       	movss  -0x18(%rbp),%xmm4
  40b09b:	f3 0f 10 45 b8       	movss  -0x48(%rbp),%xmm0
  40b0a0:	4c 8b 45 e0          	mov    -0x20(%rbp),%r8
  40b0a4:	4c 89 95 30 f5 ff ff 	mov    %r10,-0xad0(%rbp)
  40b0ab:	48 89 95 38 f5 ff ff 	mov    %rdx,-0xac8(%rbp)
  40b0b2:	f3 0f 10 d0          	movss  %xmm0,%xmm2
  40b0b6:	66 49 0f 6e c2       	movq   %r10,%xmm0
  40b0bb:	f3 0f 11 45 a0       	movss  %xmm0,-0x60(%rbp)
  40b0c0:	66 48 0f 6e da       	movq   %rdx,%xmm3
  40b0c5:	0f 57 1d 44 8f 02 00 	xorps  0x28f44(%rip),%xmm3        # 434010 <_IO_stdin_used+0x10>
  40b0cc:	f3 0f 58 d8          	addss  %xmm0,%xmm3
  40b0d0:	66 48 0f 7e da       	movq   %xmm3,%rdx
  40b0d5:	89 d2                	mov    %edx,%edx
  40b0d7:	48 89 95 30 f5 ff ff 	mov    %rdx,-0xad0(%rbp)
  40b0de:	4c 89 85 38 f5 ff ff 	mov    %r8,-0xac8(%rbp)
  40b0e5:	66 48 0f 6e da       	movq   %rdx,%xmm3
  40b0ea:	f3 0f 5e dc          	divss  %xmm4,%xmm3
  40b0ee:	66 48 0f 7e da       	movq   %xmm3,%rdx
  40b0f3:	89 d2                	mov    %edx,%edx
  40b0f5:	48 89 95 38 ff ff ff 	mov    %rdx,-0xc8(%rbp)
  40b0fc:	48 c7 85 30 f5 ff ff 00 00 00 00 	movq   $0x0,-0xad0(%rbp)
  40b107:	48 c7 85 30 f5 ff ff 03 00 00 00 	movq   $0x3,-0xad0(%rbp)
  40b112:	48 c7 85 30 f5 ff ff 00 00 00 00 	movq   $0x0,-0xad0(%rbp)
  40b11d:	48 c7 85 38 f5 ff ff 00 00 40 40 	movq   $0x40400000,-0xac8(%rbp)
  40b128:	ba 00 00 40 c0       	mov    $0xc0400000,%edx
  40b12d:	48 89 95 30 f5 ff ff 	mov    %rdx,-0xad0(%rbp)
  40b134:	48 89 8d 38 f5 ff ff 	mov    %rcx,-0xac8(%rbp)
  40b13b:	0f 57 15 ce 8e 02 00 	xorps  0x28ece(%rip),%xmm2        # 434010 <_IO_stdin_used+0x10>
  40b142:	f3 0f 58 15 e6 8e 02 00 	addss  0x28ee6(%rip),%xmm2        # 434030 <_IO_stdin_used+0x30>
  40b14a:	66 48 0f 7e d1       	movq   %xmm2,%rcx
  40b14f:	41 89 c9             	mov    %ecx,%r9d
  40b152:	4c 89 4d c0          	mov    %r9,-0x40(%rbp)
  40b156:	48 c7 85 30 f5 ff ff 08 00 00 00 	movq   $0x8,-0xad0(%rbp)
  40b161:	48 c7 85 30 f5 ff ff 00 00 00 41 	movq   $0x41000000,-0xad0(%rbp)
  40b16c:	48 89 b5 38 f5 ff ff 	mov    %rsi,-0xac8(%rbp)
  40b173:	0f 57 0d 96 8e 02 00 	xorps  0x28e96(%rip),%xmm1        # 434010 <_IO_stdin_used+0x10>
  40b17a:	f3 0f 58 0d aa 8e 02 00 	addss  0x28eaa(%rip),%xmm1        # 43402c <_IO_stdin_used+0x2c>
  40b182:	66 48 0f 7e ca       	movq   %xmm1,%rdx
  40b187:	4c 89 d1             	mov    %r10,%rcx
  40b18a:	41 89 d2             	mov    %edx,%r10d
  40b18d:	4c 89 55 c8          	mov    %r10,-0x38(%rbp)
  40b191:	48 c7 85 30 f5 ff ff 01 00 00 00 	movq   $0x1,-0xad0(%rbp)
  40b19c:	48 c7 85 30 f5 ff ff 00 00 80 3f 	movq   $0x3f800000,-0xad0(%rbp)
  40b1a7:	48 89 8d 38 f5 ff ff 	mov    %rcx,-0xac8(%rbp)
  40b1ae:	0f 57 05 5b 8e 02 00 	xorps  0x28e5b(%rip),%xmm0        # 434010 <_IO_stdin_used+0x10>
  40b1b5:	f3 0f 58 05 63 8e 02 00 	addss  0x28e63(%rip),%xmm0        # 434020 <_IO_stdin_used+0x20>
  40b1bd:	66 48 0f 7e c1       	movq   %xmm0,%rcx
  40b1c2:	41 89 cb             	mov    %ecx,%r11d
  40b1c5:	4c 89 5d d0          	mov    %r11,-0x30(%rbp)
  40b1c9:	4c 89 8d 30 f5 ff ff 	mov    %r9,-0xad0(%rbp)
  40b1d0:	4c 89 8d 38 f5 ff ff 	mov    %r9,-0xac8(%rbp)
  40b1d7:	66 49 0f 6e d9       	movq   %r9,%xmm3
  40b1dc:	f3 0f 11 5d bc       	movss  %xmm3,-0x44(%rbp)
  40b1e1:	f3 0f 10 c3          	movss  %xmm3,%xmm0
  40b1e5:	f3 0f 59 c3          	mulss  %xmm3,%xmm0
  40b1e9:	66 48 0f 7e c1       	movq   %xmm0,%rcx
  40b1ee:	89 ca                	mov    %ecx,%edx
  40b1f0:	4c 89 95 30 f5 ff ff 	mov    %r10,-0xad0(%rbp)
  40b1f7:	4c 89 95 38 f5 ff ff 	mov    %r10,-0xac8(%rbp)
  40b1fe:	66 49 0f 6e d2       	movq   %r10,%xmm2
  40b203:	f3 0f 11 55 d8       	movss  %xmm2,-0x28(%rbp)
  40b208:	f3 0f 10 c2          	movss  %xmm2,%xmm0
  40b20c:	f3 0f 59 c2          	mulss  %xmm2,%xmm0
  40b210:	66 48 0f 7e c1       	movq   %xmm0,%rcx
  40b215:	89 c9                	mov    %ecx,%ecx
  40b217:	48 89 95 30 f5 ff ff 	mov    %rdx,-0xad0(%rbp)
  40b21e:	48 89 8d 38 f5 ff ff 	mov    %rcx,-0xac8(%rbp)
  40b225:	66 48 0f 6e c2       	movq   %rdx,%xmm0
  40b22a:	66 48 0f 6e c9       	movq   %rcx,%xmm1
  40b22f:	f3 0f 58 c1          	addss  %xmm1,%xmm0
  40b233:	66 48 0f 7e c1       	movq   %xmm0,%rcx
  40b238:	89 ca                	mov    %ecx,%edx
  40b23a:	4c 89 9d 30 f5 ff ff 	mov    %r11,-0xad0(%rbp)
  40b241:	4c 89 9d 38 f5 ff ff 	mov    %r11,-0xac8(%rbp)
  40b248:	66 49 0f 6e c3       	movq   %r11,%xmm0
  40b24d:	f3 0f 11 45 dc       	movss  %xmm0,-0x24(%rbp)
  40b252:	f3 0f 59 c0          	mulss  %xmm0,%xmm0
  40b256:	66 48 0f 7e c1       	movq   %xmm0,%rcx
  40b25b:	89 c9                	mov    %ecx,%ecx
  40b25d:	48 89 95 30 f5 ff ff 	mov    %rdx,-0xad0(%rbp)
  40b264:	48 89 8d 38 f5 ff ff 	mov    %rcx,-0xac8(%rbp)
  40b26b:	66 48 0f 6e c2       	movq   %rdx,%xmm0
  40b270:	66 48 0f 6e c9       	movq   %rcx,%xmm1
  40b275:	f3 0f 58 c1          	addss  %xmm1,%xmm0
  40b279:	48 89 c3             	mov    %rax,%rbx
  40b27c:	66 48 0f 7e c0       	movq   %xmm0,%rax
  40b281:	89 c0                	mov    %eax,%eax
  40b283:	48 89 85 30 f5 ff ff 	mov    %rax,-0xad0(%rbp)
  40b28a:	b9 01 00 00 00       	mov    $0x1,%ecx
  40b28f:	48 8d 95 30 f5 ff ff 	lea    -0xad0(%rbp),%rdx
  40b296:	be 24 00 00 00       	mov    $0x24,%esi
  40b29b:	49 89 fc             	mov    %rdi,%r12
  40b29e:	e8 7d 30 02 00       	callq  42e320 <p111_rt_op>
  40b2a3:	4c 89 e7             	mov    %r12,%rdi
  40b2a6:	48 89 c2             	mov    %rax,%rdx
  40b2a9:	48 89 d8             	mov    %rbx,%rax
  40b2ac:	4c 8b 5d d0          	mov    -0x30(%rbp),%r11
  40b2b0:	4c 8b 55 c8          	mov    -0x38(%rbp),%r10
  40b2b4:	4c 8b 4d c0          	mov    -0x40(%rbp),%r9
  40b2b8:	49 89 d0             	mov    %rdx,%r8
  40b2bb:	48 8b 95 38 ff ff ff 	mov    -0xc8(%rbp),%rdx
  40b2c2:	48 8b b5 30 ff ff ff 	mov    -0xd0(%rbp),%rsi
  40b2c9:	48 8b 8d 28 ff ff ff 	mov    -0xd8(%rbp),%rcx
  40b2d0:	f3 0f 10 45 dc       	movss  -0x24(%rbp),%xmm0
  40b2d5:	f3 0f 10 55 d8       	movss  -0x28(%rbp),%xmm2
  40b2da:	f3 0f 10 5d bc       	movss  -0x44(%rbp),%xmm3
  40b2df:	4c 89 85 68 ff ff ff 	mov    %r8,-0x98(%rbp)
  40b2e6:	4c 89 8d 30 f5 ff ff 	mov    %r9,-0xad0(%rbp)
  40b2ed:	4c 89 85 38 f5 ff ff 	mov    %r8,-0xac8(%rbp)
  40b2f4:	66 49 0f 6e c8       	movq   %r8,%xmm1
  40b2f9:	f3 0f 5e d9          	divss  %xmm1,%xmm3
  40b2fd:	66 49 0f 7e d9       	movq   %xmm3,%r9
  40b302:	45 89 c9             	mov    %r9d,%r9d
  40b305:	4c 89 4d 88          	mov    %r9,-0x78(%rbp)
  40b309:	4c 89 95 30 f5 ff ff 	mov    %r10,-0xad0(%rbp)
  40b310:	4c 89 85 38 f5 ff ff 	mov    %r8,-0xac8(%rbp)
  40b317:	f3 0f 5e d1          	divss  %xmm1,%xmm2
  40b31b:	49 89 ca             	mov    %rcx,%r10
  40b31e:	66 48 0f 7e d1       	movq   %xmm2,%rcx
  40b323:	89 c9                	mov    %ecx,%ecx
  40b325:	48 89 4d 90          	mov    %rcx,-0x70(%rbp)
  40b329:	4c 89 9d 30 f5 ff ff 	mov    %r11,-0xad0(%rbp)
  40b330:	4c 89 85 38 f5 ff ff 	mov    %r8,-0xac8(%rbp)
  40b337:	f3 0f 5e c1          	divss  %xmm1,%xmm0
  40b33b:	66 49 0f 7e c0       	movq   %xmm0,%r8
  40b340:	45 89 c0             	mov    %r8d,%r8d
  40b343:	4c 89 45 98          	mov    %r8,-0x68(%rbp)
  40b347:	4c 89 95 30 f5 ff ff 	mov    %r10,-0xad0(%rbp)
  40b34e:	4c 89 8d 38 f5 ff ff 	mov    %r9,-0xac8(%rbp)
  40b355:	66 49 0f 6e da       	movq   %r10,%xmm3
  40b35a:	f3 0f 11 9d cc fe ff ff 	movss  %xmm3,-0x134(%rbp)
  40b362:	66 49 0f 6e c1       	movq   %r9,%xmm0
  40b367:	f3 0f 59 c3          	mulss  %xmm3,%xmm0
  40b36b:	49 89 f1             	mov    %rsi,%r9
  40b36e:	66 48 0f 7e c6       	movq   %xmm0,%rsi
  40b373:	89 f6                	mov    %esi,%esi
  40b375:	4c 89 8d 30 f5 ff ff 	mov    %r9,-0xad0(%rbp)
  40b37c:	48 89 8d 38 f5 ff ff 	mov    %rcx,-0xac8(%rbp)
  40b383:	66 49 0f 6e d1       	movq   %r9,%xmm2
  40b388:	f3 0f 11 95 48 ff ff ff 	movss  %xmm2,-0xb8(%rbp)
  40b390:	66 48 0f 6e c1       	movq   %rcx,%xmm0
  40b395:	f3 0f 59 c2          	mulss  %xmm2,%xmm0
  40b399:	66 48 0f 7e c1       	movq   %xmm0,%rcx
  40b39e:	89 c9                	mov    %ecx,%ecx
  40b3a0:	48 89 b5 30 f5 ff ff 	mov    %rsi,-0xad0(%rbp)
  40b3a7:	48 89 8d 38 f5 ff ff 	mov    %rcx,-0xac8(%rbp)
  40b3ae:	66 48 0f 6e c6       	movq   %rsi,%xmm0
  40b3b3:	66 48 0f 6e c9       	movq   %rcx,%xmm1
  40b3b8:	f3 0f 58 c1          	addss  %xmm1,%xmm0
  40b3bc:	66 48 0f 7e c1       	movq   %xmm0,%rcx
  40b3c1:	49 89 d3             	mov    %rdx,%r11
  40b3c4:	89 ca                	mov    %ecx,%edx
  40b3c6:	4c 89 9d 30 f5 ff ff 	mov    %r11,-0xad0(%rbp)
  40b3cd:	4c 89 85 38 f5 ff ff 	mov    %r8,-0xac8(%rbp)
  40b3d4:	66 49 0f 6e c3       	movq   %r11,%xmm0
  40b3d9:	f3 0f 11 85 4c ff ff ff 	movss  %xmm0,-0xb4(%rbp)
  40b3e1:	66 49 0f 6e c8       	movq   %r8,%xmm1
  40b3e6:	f3 0f 59 c1          	mulss  %xmm1,%xmm0
  40b3ea:	66 48 0f 7e c1       	movq   %xmm0,%rcx
  40b3ef:	89 c9                	mov    %ecx,%ecx
  40b3f1:	48 89 95 30 f5 ff ff 	mov    %rdx,-0xad0(%rbp)
  40b3f8:	48 89 8d 38 f5 ff ff 	mov    %rcx,-0xac8(%rbp)
  40b3ff:	66 48 0f 6e c2       	movq   %rdx,%xmm0
  40b404:	66 48 0f 6e c9       	movq   %rcx,%xmm1
  40b409:	f3 0f 58 c1          	addss  %xmm1,%xmm0
  40b40d:	48 89 c3             	mov    %rax,%rbx
  40b410:	66 48 0f 7e c0       	movq   %xmm0,%rax
  40b415:	89 c6                	mov    %eax,%esi
  40b417:	49 89 fc             	mov    %rdi,%r12
  40b41a:	e8 c1 a8 ff ff       	callq  405ce0 <p113d_FID_36_100_105_114_101_99_116_46_102_109_97_120_48_>
  40b41f:	4c 89 f2             	mov    %r14,%rdx
  40b422:	4c 89 e7             	mov    %r12,%rdi
  40b425:	48 89 85 70 ff ff ff 	mov    %rax,-0x90(%rbp)
  40b42c:	49 89 d6             	mov    %rdx,%r14
  40b42f:	ba e8 03 00 00       	mov    $0x3e8,%edx
  40b434:	be 01 00 00 00       	mov    $0x1,%esi
  40b439:	49 89 fc             	mov    %rdi,%r12
  40b43c:	e8 2f a9 ff ff       	callq  405d70 <p113d_FID_36_100_105_114_101_99_116_46_102_108_>
  40b441:	4c 89 f2             	mov    %r14,%rdx
  40b444:	4c 89 e7             	mov    %r12,%rdi
  40b447:	48 89 c1             	mov    %rax,%rcx
  40b44a:	48 89 d8             	mov    %rbx,%rax
  40b44d:	4c 8b 85 28 ff ff ff 	mov    -0xd8(%rbp),%r8
  40b454:	48 8b 75 b0          	mov    -0x50(%rbp),%rsi
  40b458:	f3 0f 10 9d cc fe ff ff 	movss  -0x134(%rbp),%xmm3
  40b460:	f3 0f 10 45 b8       	movss  -0x48(%rbp),%xmm0
  40b465:	48 89 8d 30 f5 ff ff 	mov    %rcx,-0xad0(%rbp)
  40b46c:	4c 89 85 38 f5 ff ff 	mov    %r8,-0xac8(%rbp)
  40b473:	66 48 0f 6e c9       	movq   %rcx,%xmm1
  40b478:	f3 0f 59 cb          	mulss  %xmm3,%xmm1
  40b47c:	66 48 0f 7e c9       	movq   %xmm1,%rcx
  40b481:	89 c9                	mov    %ecx,%ecx
  40b483:	48 89 b5 30 f5 ff ff 	mov    %rsi,-0xad0(%rbp)
  40b48a:	48 89 8d 38 f5 ff ff 	mov    %rcx,-0xac8(%rbp)
  40b491:	66 48 0f 6e c9       	movq   %rcx,%xmm1
  40b496:	f3 0f 58 c1          	addss  %xmm1,%xmm0
  40b49a:	48 89 c3             	mov    %rax,%rbx
  40b49d:	66 48 0f 7e c0       	movq   %xmm0,%rax
  40b4a2:	41 89 c1             	mov    %eax,%r9d
  40b4a5:	4c 89 8d 40 ff ff ff 	mov    %r9,-0xc0(%rbp)
  40b4ac:	49 89 d6             	mov    %rdx,%r14
  40b4af:	ba e8 03 00 00       	mov    $0x3e8,%edx
  40b4b4:	be 01 00 00 00       	mov    $0x1,%esi
  40b4b9:	49 89 fc             	mov    %rdi,%r12
  40b4bc:	e8 af a8 ff ff       	callq  405d70 <p113d_FID_36_100_105_114_101_99_116_46_102_108_>
  40b4c1:	4c 89 f2             	mov    %r14,%rdx
  40b4c4:	4c 89 e7             	mov    %r12,%rdi
  40b4c7:	48 89 c1             	mov    %rax,%rcx
  40b4ca:	48 89 d8             	mov    %rbx,%rax
  40b4cd:	48 8b b5 30 ff ff ff 	mov    -0xd0(%rbp),%rsi
  40b4d4:	49 89 f0             	mov    %rsi,%r8
  40b4d7:	48 8b 75 a8          	mov    -0x58(%rbp),%rsi
  40b4db:	f3 0f 10 95 48 ff ff ff 	movss  -0xb8(%rbp),%xmm2
  40b4e3:	f3 0f 10 45 a4       	movss  -0x5c(%rbp),%xmm0
  40b4e8:	48 89 8d 30 f5 ff ff 	mov    %rcx,-0xad0(%rbp)
  40b4ef:	4c 89 85 38 f5 ff ff 	mov    %r8,-0xac8(%rbp)
  40b4f6:	66 48 0f 6e c9       	movq   %rcx,%xmm1
  40b4fb:	f3 0f 59 ca          	mulss  %xmm2,%xmm1
  40b4ff:	66 48 0f 7e c9       	movq   %xmm1,%rcx
  40b504:	89 c9                	mov    %ecx,%ecx
  40b506:	48 89 b5 30 f5 ff ff 	mov    %rsi,-0xad0(%rbp)
  40b50d:	48 89 8d 38 f5 ff ff 	mov    %rcx,-0xac8(%rbp)
  40b514:	66 48 0f 6e c9       	movq   %rcx,%xmm1
  40b519:	f3 0f 58 c1          	addss  %xmm1,%xmm0
  40b51d:	48 89 c3             	mov    %rax,%rbx
  40b520:	66 48 0f 7e c0       	movq   %xmm0,%rax
  40b525:	89 c0                	mov    %eax,%eax
  40b527:	48 89 85 e0 fe ff ff 	mov    %rax,-0x120(%rbp)
  40b52e:	49 89 d6             	mov    %rdx,%r14
  40b531:	ba e8 03 00 00       	mov    $0x3e8,%edx
  40b536:	be 01 00 00 00       	mov    $0x1,%esi
  40b53b:	49 89 fc             	mov    %rdi,%r12
  40b53e:	e8 2d a8 ff ff       	callq  405d70 <p113d_FID_36_100_105_114_101_99_116_46_102_108_>
  40b543:	4c 89 f2             	mov    %r14,%rdx
  40b546:	4c 89 e7             	mov    %r12,%rdi
  40b549:	48 89 c6             	mov    %rax,%rsi
  40b54c:	48 89 d8             	mov    %rbx,%rax
  40b54f:	48 89 c3             	mov    %rax,%rbx
  40b552:	48 8b 85 e0 fe ff ff 	mov    -0x120(%rbp),%rax
  40b559:	4c 8b 8d 40 ff ff ff 	mov    -0xc0(%rbp),%r9
  40b560:	4c 8b 45 98          	mov    -0x68(%rbp),%r8
  40b564:	48 8b 4d 90          	mov    -0x70(%rbp),%rcx
  40b568:	4d 89 cc             	mov    %r9,%r12
  40b56b:	4c 8b 4d 88          	mov    -0x78(%rbp),%r9
  40b56f:	4c 8b 9d 38 ff ff ff 	mov    -0xc8(%rbp),%r11
  40b576:	4c 8b 55 80          	mov    -0x80(%rbp),%r10
  40b57a:	f3 0f 10 85 4c ff ff ff 	movss  -0xb4(%rbp),%xmm0
  40b582:	f3 0f 10 c8          	movss  %xmm0,%xmm1
  40b586:	f3 0f 10 45 a0       	movss  -0x60(%rbp),%xmm0
  40b58b:	48 89 b5 30 f5 ff ff 	mov    %rsi,-0xad0(%rbp)
  40b592:	4c 89 9d 38 f5 ff ff 	mov    %r11,-0xac8(%rbp)
  40b599:	66 48 0f 6e d6       	movq   %rsi,%xmm2
  40b59e:	f3 0f 59 ca          	mulss  %xmm2,%xmm1
  40b5a2:	66 48 0f 7e ce       	movq   %xmm1,%rsi
  40b5a7:	89 f6                	mov    %esi,%esi
  40b5a9:	4c 89 95 30 f5 ff ff 	mov    %r10,-0xad0(%rbp)
  40b5b0:	48 89 b5 38 f5 ff ff 	mov    %rsi,-0xac8(%rbp)
  40b5b7:	66 48 0f 6e ce       	movq   %rsi,%xmm1
  40b5bc:	f3 0f 58 c1          	addss  %xmm1,%xmm0
  40b5c0:	66 48 0f 7e c6       	movq   %xmm0,%rsi
  40b5c5:	41 89 f3             	mov    %esi,%r11d
  40b5c8:	4c 89 9d e8 fe ff ff 	mov    %r11,-0x118(%rbp)
  40b5cf:	48 c7 85 30 f5 ff ff 00 ca 9a 3b 	movq   $0x3b9aca00,-0xad0(%rbp)
  40b5da:	48 c7 85 30 f5 ff ff 00 ca 9a 3b 	movq   $0x3b9aca00,-0xad0(%rbp)
  40b5e5:	48 83 ec 30          	sub    $0x30,%rsp
  40b5e9:	48 89 e6             	mov    %rsp,%rsi
  40b5ec:	48 c7 46 20 00 00 00 00 	movq   $0x0,0x20(%rsi)
  40b5f4:	48 c7 46 18 28 6b 6e 4e 	movq   $0x4e6e6b28,0x18(%rsi)
  40b5fc:	48 c7 46 10 28 6b 6e 4e 	movq   $0x4e6e6b28,0x10(%rsi)
  40b604:	4c 89 46 08          	mov    %r8,0x8(%rsi)
  40b608:	48 89 0e             	mov    %rcx,(%rsi)
  40b60b:	4d 89 d8             	mov    %r11,%r8
  40b60e:	48 89 c1             	mov    %rax,%rcx
  40b611:	49 89 d6             	mov    %rdx,%r14
  40b614:	4c 89 e2             	mov    %r12,%rdx
  40b617:	be 09 00 00 00       	mov    $0x9,%esi
  40b61c:	49 89 fc             	mov    %rdi,%r12
  40b61f:	e8 bc bb ff ff       	callq  4071e0 <p113d_FID_36_100_105_114_101_99_116_46_110_101_97_114_101_115_116_46_116_>
  40b624:	4c 89 f2             	mov    %r14,%rdx
  40b627:	4c 89 e7             	mov    %r12,%rdi
  40b62a:	48 89 85 78 ff ff ff 	mov    %rax,-0x88(%rbp)
  40b631:	48 83 ec d0          	sub    $0xffffffffffffffd0,%rsp
  40b635:	49 89 d6             	mov    %rdx,%r14
  40b638:	ba 0a 00 00 00       	mov    $0xa,%edx
  40b63d:	be 01 00 00 00       	mov    $0x1,%esi
  40b642:	49 89 fc             	mov    %rdi,%r12
  40b645:	e8 26 a7 ff ff       	callq  405d70 <p113d_FID_36_100_105_114_101_99_116_46_102_108_>
  40b64a:	4c 89 f2             	mov    %r14,%rdx
  40b64d:	4c 89 e7             	mov    %r12,%rdi
  40b650:	48 89 85 58 ff ff ff 	mov    %rax,-0xa8(%rbp)
  40b657:	49 89 d6             	mov    %rdx,%r14
  40b65a:	ba 64 00 00 00       	mov    $0x64,%edx
  40b65f:	be 55 00 00 00       	mov    $0x55,%esi
  40b664:	49 89 fc             	mov    %rdi,%r12
  40b667:	e8 04 a7 ff ff       	callq  405d70 <p113d_FID_36_100_105_114_101_99_116_46_102_108_>
  40b66c:	4c 89 f2             	mov    %r14,%rdx
  40b66f:	4c 89 e7             	mov    %r12,%rdi
  40b672:	48 89 85 60 ff ff ff 	mov    %rax,-0xa0(%rbp)
  40b679:	49 89 d6             	mov    %rdx,%r14
  40b67c:	48 8b 95 68 ff ff ff 	mov    -0x98(%rbp),%rdx
  40b683:	48 8b b5 78 ff ff ff 	mov    -0x88(%rbp),%rsi
  40b68a:	48 8b 8d 70 ff ff ff 	mov    -0x90(%rbp),%rcx
  40b691:	49 89 fc             	mov    %rdi,%r12
  40b694:	e8 37 af ff ff       	callq  4065d0 <p113d_FID_36_100_105_114_101_99_116_46_115_104_97_100_101_>
  40b699:	4c 89 f2             	mov    %r14,%rdx
  40b69c:	4c 89 e7             	mov    %r12,%rdi
  40b69f:	48 89 c1             	mov    %rax,%rcx
  40b6a2:	48 89 d8             	mov    %rbx,%rax
  40b6a5:	4c 8b 85 60 ff ff ff 	mov    -0xa0(%rbp),%r8
  40b6ac:	49 89 d6             	mov    %rdx,%r14
  40b6af:	48 8b 95 58 ff ff ff 	mov    -0xa8(%rbp),%rdx
  40b6b6:	48 8b b5 50 ff ff ff 	mov    -0xb0(%rbp),%rsi
  40b6bd:	4c 89 85 30 f5 ff ff 	mov    %r8,-0xad0(%rbp)
  40b6c4:	48 89 8d 38 f5 ff ff 	mov    %rcx,-0xac8(%rbp)
  40b6cb:	66 49 0f 6e c0       	movq   %r8,%xmm0
  40b6d0:	66 48 0f 6e c9       	movq   %rcx,%xmm1
  40b6d5:	f3 0f 59 c1          	mulss  %xmm1,%xmm0
  40b6d9:	66 48 0f 7e c1       	movq   %xmm0,%rcx
  40b6de:	89 c9                	mov    %ecx,%ecx
  40b6e0:	48 89 95 30 f5 ff ff 	mov    %rdx,-0xad0(%rbp)
  40b6e7:	48 89 8d 38 f5 ff ff 	mov    %rcx,-0xac8(%rbp)
  40b6ee:	66 48 0f 6e c2       	movq   %rdx,%xmm0
  40b6f3:	66 48 0f 6e c9       	movq   %rcx,%xmm1
  40b6f8:	f3 0f 58 c1          	addss  %xmm1,%xmm0
  40b6fc:	48 89 c3             	mov    %rax,%rbx
  40b6ff:	66 48 0f 7e c0       	movq   %xmm0,%rax
  40b704:	89 c1                	mov    %eax,%ecx
  40b706:	48 89 8d f8 fe ff ff 	mov    %rcx,-0x108(%rbp)
  40b70d:	49 89 fc             	mov    %rdi,%r12
  40b710:	e8 eb ad ff ff       	callq  406500 <p113d_FID_36_100_105_114_101_99_116_46_115_107_114_>
  40b715:	4d 89 f9             	mov    %r15,%r9
  40b718:	4c 89 f2             	mov    %r14,%rdx
  40b71b:	4c 89 e7             	mov    %r12,%rdi
  40b71e:	49 89 c7             	mov    %rax,%r15
  40b721:	48 89 d8             	mov    %rbx,%rax
  40b724:	49 89 c4             	mov    %rax,%r12
  40b727:	48 8b 85 e0 fe ff ff 	mov    -0x120(%rbp),%rax
  40b72e:	4d 89 ca             	mov    %r9,%r10
  40b731:	4c 8b 8d 40 ff ff ff 	mov    -0xc0(%rbp),%r9
  40b738:	49 89 d6             	mov    %rdx,%r14
  40b73b:	48 8b 95 38 ff ff ff 	mov    -0xc8(%rbp),%rdx
  40b742:	48 8b b5 30 ff ff ff 	mov    -0xd0(%rbp),%rsi
  40b749:	48 8b 8d 28 ff ff ff 	mov    -0xd8(%rbp),%rcx
  40b750:	f3 0f 10 85 4c ff ff ff 	movss  -0xb4(%rbp),%xmm0
  40b758:	f3 0f 10 95 48 ff ff ff 	movss  -0xb8(%rbp),%xmm2
  40b760:	f3 0f 10 9d cc fe ff ff 	movss  -0x134(%rbp),%xmm3
  40b768:	f3 0f 10 a5 bc fe ff ff 	movss  -0x144(%rbp),%xmm4
  40b770:	f3 0f 10 ad b8 fe ff ff 	movss  -0x148(%rbp),%xmm5
  40b778:	f3 0f 10 b5 ac fe ff ff 	movss  -0x154(%rbp),%xmm6
  40b780:	48 8b 9d b0 fe ff ff 	mov    -0x150(%rbp),%rbx
  40b787:	48 c7 85 30 f5 ff ff 02 00 00 00 	movq   $0x2,-0xad0(%rbp)
  40b792:	4c 89 95 30 f5 ff ff 	mov    %r10,-0xad0(%rbp)
  40b799:	48 89 8d 38 f5 ff ff 	mov    %rcx,-0xac8(%rbp)
  40b7a0:	f3 0f 10 ce          	movss  %xmm6,%xmm1
  40b7a4:	f3 0f 59 cb          	mulss  %xmm3,%xmm1
  40b7a8:	66 49 0f 7e c8       	movq   %xmm1,%r8
  40b7ad:	45 89 c3             	mov    %r8d,%r11d
  40b7b0:	4c 89 b5 30 f5 ff ff 	mov    %r14,-0xad0(%rbp)
  40b7b7:	48 89 b5 38 f5 ff ff 	mov    %rsi,-0xac8(%rbp)
  40b7be:	f3 0f 10 cd          	movss  %xmm5,%xmm1
  40b7c2:	f3 0f 59 ca          	mulss  %xmm2,%xmm1
  40b7c6:	66 49 0f 7e c8       	movq   %xmm1,%r8
  40b7cb:	45 89 c0             	mov    %r8d,%r8d
  40b7ce:	4c 89 9d 30 f5 ff ff 	mov    %r11,-0xad0(%rbp)
  40b7d5:	4c 89 85 38 f5 ff ff 	mov    %r8,-0xac8(%rbp)
  40b7dc:	66 49 0f 6e cb       	movq   %r11,%xmm1
  40b7e1:	66 49 0f 6e f8       	movq   %r8,%xmm7
  40b7e6:	f3 0f 58 cf          	addss  %xmm7,%xmm1
  40b7ea:	66 49 0f 7e c8       	movq   %xmm1,%r8
  40b7ef:	45 89 c0             	mov    %r8d,%r8d
  40b7f2:	4c 89 85 20 ff ff ff 	mov    %r8,-0xe0(%rbp)
  40b7f9:	4c 89 ad 30 f5 ff ff 	mov    %r13,-0xad0(%rbp)
  40b800:	48 89 95 38 f5 ff ff 	mov    %rdx,-0xac8(%rbp)
  40b807:	f3 0f 10 cc          	movss  %xmm4,%xmm1
  40b80b:	f3 0f 59 c8          	mulss  %xmm0,%xmm1
  40b80f:	66 49 0f 7e c8       	movq   %xmm1,%r8
  40b814:	45 89 c0             	mov    %r8d,%r8d
  40b817:	4c 89 85 18 ff ff ff 	mov    %r8,-0xe8(%rbp)
  40b81e:	4c 8b 85 20 ff ff ff 	mov    -0xe0(%rbp),%r8
  40b825:	4c 8b 9d e8 fe ff ff 	mov    -0x118(%rbp),%r11
  40b82c:	4c 89 85 30 f5 ff ff 	mov    %r8,-0xad0(%rbp)
  40b833:	4c 8b 85 18 ff ff ff 	mov    -0xe8(%rbp),%r8
  40b83a:	4c 89 85 38 f5 ff ff 	mov    %r8,-0xac8(%rbp)
  40b841:	4c 8b 85 20 ff ff ff 	mov    -0xe0(%rbp),%r8
  40b848:	66 49 0f 6e c8       	movq   %r8,%xmm1
  40b84d:	4c 8b 85 18 ff ff ff 	mov    -0xe8(%rbp),%r8
  40b854:	66 49 0f 6e f8       	movq   %r8,%xmm7
  40b859:	f3 0f 58 cf          	addss  %xmm7,%xmm1
  40b85d:	66 49 0f 7e c8       	movq   %xmm1,%r8
  40b862:	45 89 c0             	mov    %r8d,%r8d
  40b865:	48 c7 85 30 f5 ff ff 00 00 00 40 	movq   $0x40000000,-0xad0(%rbp)
  40b870:	4c 89 85 38 f5 ff ff 	mov    %r8,-0xac8(%rbp)
  40b877:	66 49 0f 6e c8       	movq   %r8,%xmm1
  40b87c:	f3 0f 59 0d b0 87 02 00 	mulss  0x287b0(%rip),%xmm1        # 434034 <_IO_stdin_used+0x34>
  40b884:	66 49 0f 7e c8       	movq   %xmm1,%r8
  40b889:	45 89 c0             	mov    %r8d,%r8d
  40b88c:	4c 89 85 30 f5 ff ff 	mov    %r8,-0xad0(%rbp)
  40b893:	48 89 8d 38 f5 ff ff 	mov    %rcx,-0xac8(%rbp)
  40b89a:	66 49 0f 6e c8       	movq   %r8,%xmm1
  40b89f:	f3 0f 59 d9          	mulss  %xmm1,%xmm3
  40b8a3:	66 48 0f 7e d9       	movq   %xmm3,%rcx
  40b8a8:	89 c9                	mov    %ecx,%ecx
  40b8aa:	4c 89 95 30 f5 ff ff 	mov    %r10,-0xad0(%rbp)
  40b8b1:	48 89 8d 38 f5 ff ff 	mov    %rcx,-0xac8(%rbp)
  40b8b8:	66 48 0f 6e d9       	movq   %rcx,%xmm3
  40b8bd:	0f 57 1d 4c 87 02 00 	xorps  0x2874c(%rip),%xmm3        # 434010 <_IO_stdin_used+0x10>
  40b8c4:	f3 0f 58 de          	addss  %xmm6,%xmm3
  40b8c8:	66 48 0f 7e d9       	movq   %xmm3,%rcx
  40b8cd:	89 c9                	mov    %ecx,%ecx
  40b8cf:	48 89 8d 00 ff ff ff 	mov    %rcx,-0x100(%rbp)
  40b8d6:	4c 89 85 30 f5 ff ff 	mov    %r8,-0xad0(%rbp)
  40b8dd:	48 89 b5 38 f5 ff ff 	mov    %rsi,-0xac8(%rbp)
  40b8e4:	f3 0f 59 d1          	mulss  %xmm1,%xmm2
  40b8e8:	66 48 0f 7e d6       	movq   %xmm2,%rsi
  40b8ed:	89 f6                	mov    %esi,%esi
  40b8ef:	4c 89 b5 30 f5 ff ff 	mov    %r14,-0xad0(%rbp)
  40b8f6:	48 89 b5 38 f5 ff ff 	mov    %rsi,-0xac8(%rbp)
  40b8fd:	66 48 0f 6e d6       	movq   %rsi,%xmm2
  40b902:	0f 57 15 07 87 02 00 	xorps  0x28707(%rip),%xmm2        # 434010 <_IO_stdin_used+0x10>
  40b909:	f3 0f 58 d5          	addss  %xmm5,%xmm2
  40b90d:	66 48 0f 7e d6       	movq   %xmm2,%rsi
  40b912:	89 f6                	mov    %esi,%esi
  40b914:	48 89 b5 08 ff ff ff 	mov    %rsi,-0xf8(%rbp)
  40b91b:	4c 89 85 30 f5 ff ff 	mov    %r8,-0xad0(%rbp)
  40b922:	48 89 95 38 f5 ff ff 	mov    %rdx,-0xac8(%rbp)
  40b929:	f3 0f 59 c1          	mulss  %xmm1,%xmm0
  40b92d:	66 48 0f 7e c2       	movq   %xmm0,%rdx
  40b932:	89 d2                	mov    %edx,%edx
  40b934:	4c 89 ad 30 f5 ff ff 	mov    %r13,-0xad0(%rbp)
  40b93b:	48 89 95 38 f5 ff ff 	mov    %rdx,-0xac8(%rbp)
  40b942:	66 48 0f 6e c2       	movq   %rdx,%xmm0
  40b947:	0f 57 05 c2 86 02 00 	xorps  0x286c2(%rip),%xmm0        # 434010 <_IO_stdin_used+0x10>
  40b94e:	f3 0f 58 c4          	addss  %xmm4,%xmm0
  40b952:	66 48 0f 7e c2       	movq   %xmm0,%rdx
  40b957:	41 89 d5             	mov    %edx,%r13d
  40b95a:	4c 89 ad 10 ff ff ff 	mov    %r13,-0xf0(%rbp)
  40b961:	48 c7 85 30 f5 ff ff 00 ca 9a 3b 	movq   $0x3b9aca00,-0xad0(%rbp)
  40b96c:	48 c7 85 30 f5 ff ff 00 ca 9a 3b 	movq   $0x3b9aca00,-0xad0(%rbp)
  40b977:	48 83 ec 40          	sub    $0x40,%rsp
  40b97b:	48 89 e2             	mov    %rsp,%rdx
  40b97e:	48 c7 42 38 00 00 00 00 	movq   $0x0,0x38(%rdx)
  40b986:	48 c7 42 30 09 00 00 00 	movq   $0x9,0x30(%rdx)
  40b98e:	48 c7 42 28 28 6b 6e 4e 	movq   $0x4e6e6b28,0x28(%rdx)
  40b996:	48 c7 42 20 09 00 00 00 	movq   $0x9,0x20(%rdx)
  40b99e:	48 c7 42 18 28 6b 6e 4e 	movq   $0x4e6e6b28,0x18(%rdx)
  40b9a6:	4c 89 6a 10          	mov    %r13,0x10(%rdx)
  40b9aa:	48 89 72 08          	mov    %rsi,0x8(%rdx)
  40b9ae:	48 89 0a             	mov    %rcx,(%rdx)
  40b9b1:	4d 89 ce             	mov    %r9,%r14
  40b9b4:	4d 89 d9             	mov    %r11,%r9
  40b9b7:	49 89 c0             	mov    %rax,%r8
  40b9ba:	4c 89 f1             	mov    %r14,%rcx
  40b9bd:	ba 09 00 00 00       	mov    $0x9,%edx
  40b9c2:	48 8d b5 30 fd ff ff 	lea    -0x2d0(%rbp),%rsi
  40b9c9:	49 89 fd             	mov    %rdi,%r13
  40b9cc:	e8 0f b1 ff ff       	callq  406ae0 <p113d_FID_36_112_114_111_100_117_99_116_46_110_101_97_114_101_115_116_>
  40b9d1:	4d 89 f1             	mov    %r14,%r9
  40b9d4:	4c 89 ef             	mov    %r13,%rdi
  40b9d7:	4c 89 e0             	mov    %r12,%rax
  40b9da:	4c 8b ad 10 ff ff ff 	mov    -0xf0(%rbp),%r13
  40b9e1:	4c 8b a5 08 ff ff ff 	mov    -0xf8(%rbp),%r12
  40b9e8:	49 89 da             	mov    %rbx,%r10
  40b9eb:	48 8b 9d 00 ff ff ff 	mov    -0x100(%rbp),%rbx
  40b9f2:	48 8b 8d f8 fe ff ff 	mov    -0x108(%rbp),%rcx
  40b9f9:	4c 8b 9d e8 fe ff ff 	mov    -0x118(%rbp),%r11
  40ba00:	49 89 c0             	mov    %rax,%r8
  40ba03:	48 8b 85 e0 fe ff ff 	mov    -0x120(%rbp),%rax
  40ba0a:	f3 0f 10 8d 74 fd ff ff 	movss  -0x28c(%rbp),%xmm1
  40ba12:	f3 0f 10 95 70 fd ff ff 	movss  -0x290(%rbp),%xmm2
  40ba1a:	48 8b b5 f0 fe ff ff 	mov    -0x110(%rbp),%rsi
  40ba21:	48 83 ec c0          	sub    $0xffffffffffffffc0,%rsp
  40ba25:	48 8b 95 30 fd ff ff 	mov    -0x2d0(%rbp),%rdx
  40ba2c:	4c 8b b5 38 fd ff ff 	mov    -0x2c8(%rbp),%r14
  40ba33:	4c 89 b5 d8 fe ff ff 	mov    %r14,-0x128(%rbp)
  40ba3a:	4c 8b b5 40 fd ff ff 	mov    -0x2c0(%rbp),%r14
  40ba41:	4c 89 b5 d0 fe ff ff 	mov    %r14,-0x130(%rbp)
  40ba48:	4c 89 95 30 f5 ff ff 	mov    %r10,-0xad0(%rbp)
  40ba4f:	48 89 8d 38 f5 ff ff 	mov    %rcx,-0xac8(%rbp)
  40ba56:	66 48 0f 6e c1       	movq   %rcx,%xmm0
  40ba5b:	f3 0f 59 c2          	mulss  %xmm2,%xmm0
  40ba5f:	66 48 0f 7e c1       	movq   %xmm0,%rcx
  40ba64:	89 c9                	mov    %ecx,%ecx
  40ba66:	48 c7 85 30 f5 ff ff 01 00 00 00 	movq   $0x1,-0xad0(%rbp)
  40ba71:	48 c7 85 30 f5 ff ff 00 00 80 3f 	movq   $0x3f800000,-0xad0(%rbp)
  40ba7c:	4c 89 bd 38 f5 ff ff 	mov    %r15,-0xac8(%rbp)
  40ba83:	66 49 0f 6e c7       	movq   %r15,%xmm0
  40ba88:	f3 0f 10 1d 90 85 02 00 	movss  0x28590(%rip),%xmm3        # 434020 <_IO_stdin_used+0x20>
  40ba90:	f3 0f 5c d8          	subss  %xmm0,%xmm3
  40ba94:	66 49 0f 7e de       	movq   %xmm3,%r14
  40ba99:	45 89 f6             	mov    %r14d,%r14d
  40ba9c:	48 89 8d 30 f5 ff ff 	mov    %rcx,-0xad0(%rbp)
  40baa3:	4c 89 b5 38 f5 ff ff 	mov    %r14,-0xac8(%rbp)
  40baaa:	66 48 0f 6e d9       	movq   %rcx,%xmm3
  40baaf:	48 8b 8d d8 fe ff ff 	mov    -0x128(%rbp),%rcx
  40bab6:	66 49 0f 6e e6       	movq   %r14,%xmm4
  40babb:	f3 0f 59 dc          	mulss  %xmm4,%xmm3
  40babf:	66 49 0f 7e de       	movq   %xmm3,%r14
  40bac4:	45 89 f6             	mov    %r14d,%r14d
  40bac7:	4c 89 85 30 f5 ff ff 	mov    %r8,-0xad0(%rbp)
  40bace:	4c 8b 85 d0 fe ff ff 	mov    -0x130(%rbp),%r8
  40bad5:	4c 89 b5 38 f5 ff ff 	mov    %r14,-0xac8(%rbp)
  40badc:	66 49 0f 6e de       	movq   %r14,%xmm3
  40bae1:	f3 0f 58 cb          	addss  %xmm3,%xmm1
  40bae5:	66 49 0f 7e ce       	movq   %xmm1,%r14
  40baea:	45 89 f6             	mov    %r14d,%r14d
  40baed:	4c 89 95 30 f5 ff ff 	mov    %r10,-0xad0(%rbp)
  40baf4:	4c 89 bd 38 f5 ff ff 	mov    %r15,-0xac8(%rbp)
  40bafb:	f3 0f 59 c2          	mulss  %xmm2,%xmm0
  40baff:	66 49 0f 7e c2       	movq   %xmm0,%r10
  40bb04:	45 89 d7             	mov    %r10d,%r15d
  40bb07:	48 83 ee 01          	sub    $0x1,%rsi
  40bb0b:	48 83 ec 40          	sub    $0x40,%rsp
  40bb0f:	49 89 e2             	mov    %rsp,%r10
  40bb12:	4d 89 7a 30          	mov    %r15,0x30(%r10)
  40bb16:	4d 89 72 28          	mov    %r14,0x28(%r10)
  40bb1a:	4d 89 6a 20          	mov    %r13,0x20(%r10)
  40bb1e:	4d 89 62 18          	mov    %r12,0x18(%r10)
  40bb22:	49 89 5a 10          	mov    %rbx,0x10(%r10)
  40bb26:	4d 89 5a 08          	mov    %r11,0x8(%r10)
  40bb2a:	49 89 02             	mov    %rax,(%r10)
  40bb2d:	e8 8e bc ff ff       	callq  4077c0 <p113d_FID_36_112_114_111_100_117_99_116_46_116_114_97_99_101_>
  40bb32:	48 83 ec c0          	sub    $0xffffffffffffffc0,%rsp
  40bb36:	e9 8b 0c 00 00       	jmpq   40c7c6 <p113d_FID_36_100_105_114_101_99_116_46_116_114_97_99_101_+0x1b36>
  40bb3b:	48 89 d8             	mov    %rbx,%rax
  40bb3e:	48 89 c3             	mov    %rax,%rbx
  40bb41:	e9 80 0c 00 00       	jmpq   40c7c6 <p113d_FID_36_100_105_114_101_99_116_46_116_114_97_99_101_+0x1b36>
  40bb46:	4d 89 ec             	mov    %r13,%r12
  40bb49:	48 3d 97 00 00 00    	cmp    $0x97,%rax
  40bb4f:	74 14                	je     40bb65 <p113d_FID_36_100_105_114_101_99_116_46_116_114_97_99_101_+0xed5>
  40bb51:	be 04 00 00 00       	mov    $0x4,%esi
  40bb56:	e8 a5 27 02 00       	callq  42e300 <p111_rt_fail>
  40bb5b:	b8 00 00 00 00       	mov    $0x0,%eax
  40bb60:	e9 61 0c 00 00       	jmpq   40c7c6 <p113d_FID_36_100_105_114_101_99_116_46_116_114_97_99_101_+0x1b36>
  40bb65:	49 89 d6             	mov    %rdx,%r14
  40bb68:	48 8d 95 30 f5 ff ff 	lea    -0xad0(%rbp),%rdx
  40bb6f:	49 89 fd             	mov    %rdi,%r13
  40bb72:	e8 09 7a 02 00       	callq  433580 <p125_rt_take3>
  40bb77:	4d 89 f9             	mov    %r15,%r9
  40bb7a:	4c 89 f2             	mov    %r14,%rdx
  40bb7d:	4c 89 ef             	mov    %r13,%rdi
  40bb80:	48 89 d8             	mov    %rbx,%rax
  40bb83:	f3 0f 10 9d c8 fe ff ff 	movss  -0x138(%rbp),%xmm3
  40bb8b:	f3 0f 10 a5 bc fe ff ff 	movss  -0x144(%rbp),%xmm4
  40bb93:	f3 0f 10 95 c4 fe ff ff 	movss  -0x13c(%rbp),%xmm2
  40bb9b:	f3 0f 10 ad b8 fe ff ff 	movss  -0x148(%rbp),%xmm5
  40bba3:	f3 0f 10 8d c0 fe ff ff 	movss  -0x140(%rbp),%xmm1
  40bbab:	f3 0f 10 b5 ac fe ff ff 	movss  -0x154(%rbp),%xmm6
  40bbb3:	48 8b 9d b0 fe ff ff 	mov    -0x150(%rbp),%rbx
  40bbba:	4c 8b 85 30 f5 ff ff 	mov    -0xad0(%rbp),%r8
  40bbc1:	4c 8b ad 38 f5 ff ff 	mov    -0xac8(%rbp),%r13
  40bbc8:	48 8b b5 40 f5 ff ff 	mov    -0xac0(%rbp),%rsi
  40bbcf:	49 83 f8 01          	cmp    $0x1,%r8
  40bbd3:	0f 94 c1             	sete   %cl
  40bbd6:	0f b6 c9             	movzbl %cl,%ecx
  40bbd9:	49 c1 e8 28          	shr    $0x28,%r8
  40bbdd:	49 81 e0 ff ff 7f 00 	and    $0x7fffff,%r8
  40bbe4:	49 81 f8 02 00 01 00 	cmp    $0x10002,%r8
  40bbeb:	41 0f 94 c0          	sete   %r8b
  40bbef:	45 0f b6 c0          	movzbl %r8b,%r8d
  40bbf3:	44 09 c1             	or     %r8d,%ecx
  40bbf6:	0f 85 ca 0b 00 00    	jne    40c7c6 <p113d_FID_36_100_105_114_101_99_116_46_116_114_97_99_101_+0x1b36>
  40bbfc:	2e 83 f1 01          	cs xor $0x1,%ecx
  40bc00:	75 14                	jne    40bc16 <p113d_FID_36_100_105_114_101_99_116_46_116_114_97_99_101_+0xf86>
  40bc02:	be 04 00 00 00       	mov    $0x4,%esi
  40bc07:	e8 f4 26 02 00       	callq  42e300 <p111_rt_fail>
  40bc0c:	b8 00 00 00 00       	mov    $0x0,%eax
  40bc11:	e9 b0 0b 00 00       	jmpq   40c7c6 <p113d_FID_36_100_105_114_101_99_116_46_116_114_97_99_101_+0x1b36>
  40bc16:	48 83 fe 00          	cmp    $0x0,%rsi
  40bc1a:	0f 94 c1             	sete   %cl
  40bc1d:	0f b6 c9             	movzbl %cl,%ecx
  40bc20:	89 8d a8 fe ff ff    	mov    %ecx,-0x158(%rbp)
  40bc26:	49 89 f0             	mov    %rsi,%r8
  40bc29:	49 83 e8 01          	sub    $0x1,%r8
  40bc2d:	49 89 f7             	mov    %rsi,%r15
  40bc30:	49 83 ef 02          	sub    $0x2,%r15
  40bc34:	49 89 f6             	mov    %rsi,%r14
  40bc37:	49 83 ee 03          	sub    $0x3,%r14
  40bc3b:	49 89 f3             	mov    %rsi,%r11
  40bc3e:	49 83 eb 04          	sub    $0x4,%r11
  40bc42:	49 89 f2             	mov    %rsi,%r10
  40bc45:	49 83 ea 05          	sub    $0x5,%r10
  40bc49:	4c 89 95 90 fe ff ff 	mov    %r10,-0x170(%rbp)
  40bc50:	48 89 f1             	mov    %rsi,%rcx
  40bc53:	48 83 e9 06          	sub    $0x6,%rcx
  40bc57:	48 89 8d 80 fe ff ff 	mov    %rcx,-0x180(%rbp)
  40bc5e:	48 89 f1             	mov    %rsi,%rcx
  40bc61:	48 83 e9 07          	sub    $0x7,%rcx
  40bc65:	48 89 8d 78 fe ff ff 	mov    %rcx,-0x188(%rbp)
  40bc6c:	4c 89 d1             	mov    %r10,%rcx
  40bc6f:	4c 8b 95 80 fe ff ff 	mov    -0x180(%rbp),%r10
  40bc76:	83 bd a8 fe ff ff 00 	cmpl   $0x0,-0x158(%rbp)
  40bc7d:	75 6d                	jne    40bcec <p113d_FID_36_100_105_114_101_99_116_46_116_114_97_99_101_+0x105c>
  40bc7f:	90                   	nop
  40bc80:	49 83 f8 00          	cmp    $0x0,%r8
  40bc84:	74 5f                	je     40bce5 <p113d_FID_36_100_105_114_101_99_116_46_116_114_97_99_101_+0x1055>
  40bc86:	49 83 ff 00          	cmp    $0x0,%r15
  40bc8a:	74 52                	je     40bcde <p113d_FID_36_100_105_114_101_99_116_46_116_114_97_99_101_+0x104e>
  40bc8c:	49 83 fe 00          	cmp    $0x0,%r14
  40bc90:	74 45                	je     40bcd7 <p113d_FID_36_100_105_114_101_99_116_46_116_114_97_99_101_+0x1047>
  40bc92:	49 83 fb 00          	cmp    $0x0,%r11
  40bc96:	74 38                	je     40bcd0 <p113d_FID_36_100_105_114_101_99_116_46_116_114_97_99_101_+0x1040>
  40bc98:	48 83 f9 00          	cmp    $0x0,%rcx
  40bc9c:	48 8b 8d 78 fe ff ff 	mov    -0x188(%rbp),%rcx
  40bca3:	74 24                	je     40bcc9 <p113d_FID_36_100_105_114_101_99_116_46_116_114_97_99_101_+0x1039>
  40bca5:	49 83 fa 00          	cmp    $0x0,%r10
  40bca9:	4c 8b 95 a0 fe ff ff 	mov    -0x160(%rbp),%r10
  40bcb0:	74 10                	je     40bcc2 <p113d_FID_36_100_105_114_101_99_116_46_116_114_97_99_101_+0x1032>
  40bcb2:	2e 48 83 f9 00       	cs cmp $0x0,%rcx
  40bcb7:	b9 00 00 80 3f       	mov    $0x3f800000,%ecx
  40bcbc:	49 0f 45 ca          	cmovne %r10,%rcx
  40bcc0:	eb 2f                	jmp    40bcf1 <p113d_FID_36_100_105_114_101_99_116_46_116_114_97_99_101_+0x1061>
  40bcc2:	b9 9a 99 99 3f       	mov    $0x3f99999a,%ecx
  40bcc7:	eb 28                	jmp    40bcf1 <p113d_FID_36_100_105_114_101_99_116_46_116_114_97_99_101_+0x1061>
  40bcc9:	b9 cd cc cc 3e       	mov    $0x3ecccccd,%ecx
  40bcce:	eb 21                	jmp    40bcf1 <p113d_FID_36_100_105_114_101_99_116_46_116_114_97_99_101_+0x1061>
  40bcd0:	b9 cd cc cc 3e       	mov    $0x3ecccccd,%ecx
  40bcd5:	eb 1a                	jmp    40bcf1 <p113d_FID_36_100_105_114_101_99_116_46_116_114_97_99_101_+0x1061>
  40bcd7:	b9 00 00 80 3f       	mov    $0x3f800000,%ecx
  40bcdc:	eb 13                	jmp    40bcf1 <p113d_FID_36_100_105_114_101_99_116_46_116_114_97_99_101_+0x1061>
  40bcde:	b9 00 00 80 3f       	mov    $0x3f800000,%ecx
  40bce3:	eb 0c                	jmp    40bcf1 <p113d_FID_36_100_105_114_101_99_116_46_116_114_97_99_101_+0x1061>
  40bce5:	b9 00 00 80 3f       	mov    $0x3f800000,%ecx
  40bcea:	eb 05                	jmp    40bcf1 <p113d_FID_36_100_105_114_101_99_116_46_116_114_97_99_101_+0x1061>
  40bcec:	b9 00 40 1c 46       	mov    $0x461c4000,%ecx
  40bcf1:	4c 89 ad 30 f5 ff ff 	mov    %r13,-0xad0(%rbp)
  40bcf8:	4c 89 8d 38 f5 ff ff 	mov    %r9,-0xac8(%rbp)
  40bcff:	66 49 0f 6e c5       	movq   %r13,%xmm0
  40bd04:	f3 0f 59 f0          	mulss  %xmm0,%xmm6
  40bd08:	66 49 0f 7e f1       	movq   %xmm6,%r9
  40bd0d:	45 89 c9             	mov    %r9d,%r9d
  40bd10:	4c 89 8d 60 fe ff ff 	mov    %r9,-0x1a0(%rbp)
  40bd17:	4c 8b 95 90 fe ff ff 	mov    -0x170(%rbp),%r10
  40bd1e:	4c 8b 8d 98 fe ff ff 	mov    -0x168(%rbp),%r9
  40bd25:	4c 89 8d 30 f5 ff ff 	mov    %r9,-0xad0(%rbp)
  40bd2c:	4c 8b 8d 60 fe ff ff 	mov    -0x1a0(%rbp),%r9
  40bd33:	4c 89 8d 38 f5 ff ff 	mov    %r9,-0xac8(%rbp)
  40bd3a:	4c 89 ad 30 f5 ff ff 	mov    %r13,-0xad0(%rbp)
  40bd41:	48 89 95 38 f5 ff ff 	mov    %rdx,-0xac8(%rbp)
  40bd48:	f3 0f 59 e8          	mulss  %xmm0,%xmm5
  40bd4c:	66 48 0f 7e ea       	movq   %xmm5,%rdx
  40bd51:	89 d2                	mov    %edx,%edx
  40bd53:	48 89 95 50 fe ff ff 	mov    %rdx,-0x1b0(%rbp)
  40bd5a:	4c 8b 8d 80 fe ff ff 	mov    -0x180(%rbp),%r9
  40bd61:	48 8b 95 88 fe ff ff 	mov    -0x178(%rbp),%rdx
  40bd68:	48 89 95 30 f5 ff ff 	mov    %rdx,-0xad0(%rbp)
  40bd6f:	48 8b 95 50 fe ff ff 	mov    -0x1b0(%rbp),%rdx
  40bd76:	48 89 95 38 f5 ff ff 	mov    %rdx,-0xac8(%rbp)
  40bd7d:	48 8b 95 78 fe ff ff 	mov    -0x188(%rbp),%rdx
  40bd84:	4c 89 ad 30 f5 ff ff 	mov    %r13,-0xad0(%rbp)
  40bd8b:	4c 89 a5 38 f5 ff ff 	mov    %r12,-0xac8(%rbp)
  40bd92:	f3 0f 59 c4          	mulss  %xmm4,%xmm0
  40bd96:	66 49 0f 7e c4       	movq   %xmm0,%r12
  40bd9b:	45 89 e5             	mov    %r12d,%r13d
  40bd9e:	4c 89 ad 30 fe ff ff 	mov    %r13,-0x1d0(%rbp)
  40bda5:	4c 8b a5 60 fe ff ff 	mov    -0x1a0(%rbp),%r12
  40bdac:	4c 8b ad 70 fe ff ff 	mov    -0x190(%rbp),%r13
  40bdb3:	4c 89 ad 30 f5 ff ff 	mov    %r13,-0xad0(%rbp)
  40bdba:	4c 8b ad 30 fe ff ff 	mov    -0x1d0(%rbp),%r13
  40bdc1:	4c 89 ad 38 f5 ff ff 	mov    %r13,-0xac8(%rbp)
  40bdc8:	4c 8b ad 68 fe ff ff 	mov    -0x198(%rbp),%r13
  40bdcf:	48 83 fe 00          	cmp    $0x0,%rsi
  40bdd3:	74 70                	je     40be45 <p113d_FID_36_100_105_114_101_99_116_46_116_114_97_99_101_+0x11b5>
  40bdd5:	49 83 f8 00          	cmp    $0x0,%r8
  40bdd9:	74 62                	je     40be3d <p113d_FID_36_100_105_114_101_99_116_46_116_114_97_99_101_+0x11ad>
  40bddb:	0f 1f 44 00 00       	nopl   0x0(%rax,%rax,1)
  40bde0:	49 83 ff 00          	cmp    $0x0,%r15
  40bde4:	74 4f                	je     40be35 <p113d_FID_36_100_105_114_101_99_116_46_116_114_97_99_101_+0x11a5>
  40bde6:	49 83 fe 00          	cmp    $0x0,%r14
  40bdea:	74 41                	je     40be2d <p113d_FID_36_100_105_114_101_99_116_46_116_114_97_99_101_+0x119d>
  40bdec:	49 83 fb 00          	cmp    $0x0,%r11
  40bdf0:	74 33                	je     40be25 <p113d_FID_36_100_105_114_101_99_116_46_116_114_97_99_101_+0x1195>
  40bdf2:	49 83 fa 00          	cmp    $0x0,%r10
  40bdf6:	74 25                	je     40be1d <p113d_FID_36_100_105_114_101_99_116_46_116_114_97_99_101_+0x118d>
  40bdf8:	49 83 f9 00          	cmp    $0x0,%r9
  40bdfc:	74 17                	je     40be15 <p113d_FID_36_100_105_114_101_99_116_46_116_114_97_99_101_+0x1185>
  40bdfe:	48 83 fa 00          	cmp    $0x0,%rdx
  40be02:	41 bc 00 00 60 40    	mov    $0x40600000,%r12d
  40be08:	4d 0f 44 ec          	cmove  %r12,%r13
  40be0c:	4c 8b a5 60 fe ff ff 	mov    -0x1a0(%rbp),%r12
  40be13:	eb 36                	jmp    40be4b <p113d_FID_36_100_105_114_101_99_116_46_116_114_97_99_101_+0x11bb>
  40be15:	41 bd 00 00 00 00    	mov    $0x0,%r13d
  40be1b:	eb 2e                	jmp    40be4b <p113d_FID_36_100_105_114_101_99_116_46_116_114_97_99_101_+0x11bb>
  40be1d:	41 bd 00 00 80 bf    	mov    $0xbf800000,%r13d
  40be23:	eb 26                	jmp    40be4b <p113d_FID_36_100_105_114_101_99_116_46_116_114_97_99_101_+0x11bb>
  40be25:	41 bd 00 00 80 3f    	mov    $0x3f800000,%r13d
  40be2b:	eb 1e                	jmp    40be4b <p113d_FID_36_100_105_114_101_99_116_46_116_114_97_99_101_+0x11bb>
  40be2d:	41 bd 00 00 00 c0    	mov    $0xc0000000,%r13d
  40be33:	eb 16                	jmp    40be4b <p113d_FID_36_100_105_114_101_99_116_46_116_114_97_99_101_+0x11bb>
  40be35:	41 bd 00 00 00 40    	mov    $0x40000000,%r13d
  40be3b:	eb 0e                	jmp    40be4b <p113d_FID_36_100_105_114_101_99_116_46_116_114_97_99_101_+0x11bb>
  40be3d:	41 bd 00 00 00 00    	mov    $0x0,%r13d
  40be43:	eb 06                	jmp    40be4b <p113d_FID_36_100_105_114_101_99_116_46_116_114_97_99_101_+0x11bb>
  40be45:	41 bd 00 00 00 00    	mov    $0x0,%r13d
  40be4b:	66 49 0f 6e c4       	movq   %r12,%xmm0
  40be50:	f3 0f 58 c1          	addss  %xmm1,%xmm0
  40be54:	66 49 0f 7e c4       	movq   %xmm0,%r12
  40be59:	45 89 e4             	mov    %r12d,%r12d
  40be5c:	4c 89 a5 48 fe ff ff 	mov    %r12,-0x1b8(%rbp)
  40be63:	4c 89 a5 30 f5 ff ff 	mov    %r12,-0xad0(%rbp)
  40be6a:	4c 89 ad 38 f5 ff ff 	mov    %r13,-0xac8(%rbp)
  40be71:	66 49 0f 6e c4       	movq   %r12,%xmm0
  40be76:	f3 0f 11 85 e8 fd ff ff 	movss  %xmm0,-0x218(%rbp)
  40be7e:	66 49 0f 6e cd       	movq   %r13,%xmm1
  40be83:	0f 57 0d 86 81 02 00 	xorps  0x28186(%rip),%xmm1        # 434010 <_IO_stdin_used+0x10>
  40be8a:	f3 0f 58 c8          	addss  %xmm0,%xmm1
  40be8e:	66 49 0f 7e cd       	movq   %xmm1,%r13
  40be93:	45 89 ed             	mov    %r13d,%r13d
  40be96:	4c 89 ad 08 fe ff ff 	mov    %r13,-0x1f8(%rbp)
  40be9d:	4c 89 ad 30 f5 ff ff 	mov    %r13,-0xad0(%rbp)
  40bea4:	4c 8b ad 50 fe ff ff 	mov    -0x1b0(%rbp),%r13
  40beab:	48 89 8d 38 f5 ff ff 	mov    %rcx,-0xac8(%rbp)
  40beb2:	48 83 fe 00          	cmp    $0x0,%rsi
  40beb6:	0f 84 9a 00 00 00    	je     40bf56 <p113d_FID_36_100_105_114_101_99_116_46_116_114_97_99_101_+0x12c6>
  40bebc:	4c 8b ad 58 fe ff ff 	mov    -0x1a8(%rbp),%r13
  40bec3:	49 83 f8 00          	cmp    $0x0,%r8
  40bec7:	74 5b                	je     40bf24 <p113d_FID_36_100_105_114_101_99_116_46_116_114_97_99_101_+0x1294>
  40bec9:	49 83 ff 00          	cmp    $0x0,%r15
  40becd:	74 4d                	je     40bf1c <p113d_FID_36_100_105_114_101_99_116_46_116_114_97_99_101_+0x128c>
  40becf:	49 83 fe 00          	cmp    $0x0,%r14
  40bed3:	74 3f                	je     40bf14 <p113d_FID_36_100_105_114_101_99_116_46_116_114_97_99_101_+0x1284>
  40bed5:	49 83 fb 00          	cmp    $0x0,%r11
  40bed9:	74 31                	je     40bf0c <p113d_FID_36_100_105_114_101_99_116_46_116_114_97_99_101_+0x127c>
  40bedb:	0f 1f 44 00 00       	nopl   0x0(%rax,%rax,1)
  40bee0:	49 83 fa 00          	cmp    $0x0,%r10
  40bee4:	74 1e                	je     40bf04 <p113d_FID_36_100_105_114_101_99_116_46_116_114_97_99_101_+0x1274>
  40bee6:	49 83 f9 00          	cmp    $0x0,%r9
  40beea:	74 10                	je     40befc <p113d_FID_36_100_105_114_101_99_116_46_116_114_97_99_101_+0x126c>
  40beec:	48 83 fa 00          	cmp    $0x0,%rdx
  40bef0:	41 bc cd cc 4c 3e    	mov    $0x3e4ccccd,%r12d
  40bef6:	4d 0f 45 e5          	cmovne %r13,%r12
  40befa:	eb 2e                	jmp    40bf2a <p113d_FID_36_100_105_114_101_99_116_46_116_114_97_99_101_+0x129a>
  40befc:	41 bc cd cc cc 3f    	mov    $0x3fcccccd,%r12d
  40bf02:	eb 26                	jmp    40bf2a <p113d_FID_36_100_105_114_101_99_116_46_116_114_97_99_101_+0x129a>
  40bf04:	41 bc 9a 99 19 bf    	mov    $0xbf19999a,%r12d
  40bf0a:	eb 1e                	jmp    40bf2a <p113d_FID_36_100_105_114_101_99_116_46_116_114_97_99_101_+0x129a>
  40bf0c:	41 bc 9a 99 19 bf    	mov    $0xbf19999a,%r12d
  40bf12:	eb 16                	jmp    40bf2a <p113d_FID_36_100_105_114_101_99_116_46_116_114_97_99_101_+0x129a>
  40bf14:	41 bc 00 00 00 3f    	mov    $0x3f000000,%r12d
  40bf1a:	eb 0e                	jmp    40bf2a <p113d_FID_36_100_105_114_101_99_116_46_116_114_97_99_101_+0x129a>
  40bf1c:	41 bc 00 00 00 3f    	mov    $0x3f000000,%r12d
  40bf22:	eb 06                	jmp    40bf2a <p113d_FID_36_100_105_114_101_99_116_46_116_114_97_99_101_+0x129a>
  40bf24:	41 bc 00 00 00 00    	mov    $0x0,%r12d
  40bf2a:	4d 89 e5             	mov    %r12,%r13
  40bf2d:	4c 89 ad 40 fe ff ff 	mov    %r13,-0x1c0(%rbp)
  40bf34:	4c 8b ad 50 fe ff ff 	mov    -0x1b0(%rbp),%r13
  40bf3b:	4c 8b a5 48 fe ff ff 	mov    -0x1b8(%rbp),%r12
  40bf42:	f2 44 0f 10 bd 40 fe ff ff 	movsd  -0x1c0(%rbp),%xmm15
  40bf4b:	f2 44 0f 11 bd 38 fe ff ff 	movsd  %xmm15,-0x1c8(%rbp)
  40bf54:	eb 14                	jmp    40bf6a <p113d_FID_36_100_105_114_101_99_116_46_116_114_97_99_101_+0x12da>
  40bf56:	c7 85 38 fe ff ff 00 44 1c c6 	movl   $0xc61c4400,-0x1c8(%rbp)
  40bf60:	c7 85 3c fe ff ff 00 00 00 00 	movl   $0x0,-0x1c4(%rbp)
  40bf6a:	66 49 0f 6e cd       	movq   %r13,%xmm1
  40bf6f:	f3 0f 58 ca          	addss  %xmm2,%xmm1
  40bf73:	66 49 0f 7e cd       	movq   %xmm1,%r13
  40bf78:	45 89 ed             	mov    %r13d,%r13d
  40bf7b:	4c 89 ad d8 fd ff ff 	mov    %r13,-0x228(%rbp)
  40bf82:	4c 89 ad 30 f5 ff ff 	mov    %r13,-0xad0(%rbp)
  40bf89:	4c 8b ad 38 fe ff ff 	mov    -0x1c8(%rbp),%r13
  40bf90:	4c 89 ad 38 f5 ff ff 	mov    %r13,-0xac8(%rbp)
  40bf97:	4c 8b ad d8 fd ff ff 	mov    -0x228(%rbp),%r13
  40bf9e:	66 49 0f 6e cd       	movq   %r13,%xmm1
  40bfa3:	f3 0f 11 8d d0 fd ff ff 	movss  %xmm1,-0x230(%rbp)
  40bfab:	4c 8b ad 38 fe ff ff 	mov    -0x1c8(%rbp),%r13
  40bfb2:	66 49 0f 6e d5       	movq   %r13,%xmm2
  40bfb7:	0f 57 15 52 80 02 00 	xorps  0x28052(%rip),%xmm2        # 434010 <_IO_stdin_used+0x10>
  40bfbe:	f3 0f 58 d1          	addss  %xmm1,%xmm2
  40bfc2:	66 49 0f 7e d5       	movq   %xmm2,%r13
  40bfc7:	45 89 ed             	mov    %r13d,%r13d
  40bfca:	4c 89 ad 10 fe ff ff 	mov    %r13,-0x1f0(%rbp)
  40bfd1:	4c 89 ad 30 f5 ff ff 	mov    %r13,-0xad0(%rbp)
  40bfd8:	4c 8b ad d8 fd ff ff 	mov    -0x228(%rbp),%r13
  40bfdf:	48 89 8d 38 f5 ff ff 	mov    %rcx,-0xac8(%rbp)
  40bfe6:	48 83 fe 00          	cmp    $0x0,%rsi
  40bfea:	48 8b b5 30 fe ff ff 	mov    -0x1d0(%rbp),%rsi
  40bff1:	74 6c                	je     40c05f <p113d_FID_36_100_105_114_101_99_116_46_116_114_97_99_101_+0x13cf>
  40bff3:	2e 2e 49 83 f8 00    	cs cs cmp $0x0,%r8
  40bff9:	4c 8b 85 28 fe ff ff 	mov    -0x1d8(%rbp),%r8
  40c000:	74 56                	je     40c058 <p113d_FID_36_100_105_114_101_99_116_46_116_114_97_99_101_+0x13c8>
  40c002:	49 83 ff 00          	cmp    $0x0,%r15
  40c006:	74 49                	je     40c051 <p113d_FID_36_100_105_114_101_99_116_46_116_114_97_99_101_+0x13c1>
  40c008:	49 83 fe 00          	cmp    $0x0,%r14
  40c00c:	74 3c                	je     40c04a <p113d_FID_36_100_105_114_101_99_116_46_116_114_97_99_101_+0x13ba>
  40c00e:	49 83 fb 00          	cmp    $0x0,%r11
  40c012:	74 2f                	je     40c043 <p113d_FID_36_100_105_114_101_99_116_46_116_114_97_99_101_+0x13b3>
  40c014:	49 83 fa 00          	cmp    $0x0,%r10
  40c018:	74 22                	je     40c03c <p113d_FID_36_100_105_114_101_99_116_46_116_114_97_99_101_+0x13ac>
  40c01a:	66 0f 1f 44 00 00    	nopw   0x0(%rax,%rax,1)
  40c020:	49 83 f9 00          	cmp    $0x0,%r9
  40c024:	74 0f                	je     40c035 <p113d_FID_36_100_105_114_101_99_116_46_116_114_97_99_101_+0x13a5>
  40c026:	48 83 fa 00          	cmp    $0x0,%rdx
  40c02a:	ba 00 00 00 41       	mov    $0x41000000,%edx
  40c02f:	49 0f 45 d0          	cmovne %r8,%rdx
  40c033:	eb 2f                	jmp    40c064 <p113d_FID_36_100_105_114_101_99_116_46_116_114_97_99_101_+0x13d4>
  40c035:	ba 00 00 e0 40       	mov    $0x40e00000,%edx
  40c03a:	eb 28                	jmp    40c064 <p113d_FID_36_100_105_114_101_99_116_46_116_114_97_99_101_+0x13d4>
  40c03c:	ba 00 00 60 40       	mov    $0x40600000,%edx
  40c041:	eb 21                	jmp    40c064 <p113d_FID_36_100_105_114_101_99_116_46_116_114_97_99_101_+0x13d4>
  40c043:	ba 00 00 60 40       	mov    $0x40600000,%edx
  40c048:	eb 1a                	jmp    40c064 <p113d_FID_36_100_105_114_101_99_116_46_116_114_97_99_101_+0x13d4>
  40c04a:	ba 00 00 c0 40       	mov    $0x40c00000,%edx
  40c04f:	eb 13                	jmp    40c064 <p113d_FID_36_100_105_114_101_99_116_46_116_114_97_99_101_+0x13d4>
  40c051:	ba 00 00 c0 40       	mov    $0x40c00000,%edx
  40c056:	eb 0c                	jmp    40c064 <p113d_FID_36_100_105_114_101_99_116_46_116_114_97_99_101_+0x13d4>
  40c058:	ba 00 00 a0 40       	mov    $0x40a00000,%edx
  40c05d:	eb 05                	jmp    40c064 <p113d_FID_36_100_105_114_101_99_116_46_116_114_97_99_101_+0x13d4>
  40c05f:	ba 00 00 a0 40       	mov    $0x40a00000,%edx
  40c064:	66 48 0f 6e d6       	movq   %rsi,%xmm2
  40c069:	f3 0f 58 d3          	addss  %xmm3,%xmm2
  40c06d:	66 48 0f 7e d6       	movq   %xmm2,%rsi
  40c072:	4d 89 ee             	mov    %r13,%r14
  40c075:	41 89 f5             	mov    %esi,%r13d
  40c078:	4c 89 ad c0 fd ff ff 	mov    %r13,-0x240(%rbp)
  40c07f:	4c 89 ad 30 f5 ff ff 	mov    %r13,-0xad0(%rbp)
  40c086:	48 89 95 38 f5 ff ff 	mov    %rdx,-0xac8(%rbp)
  40c08d:	f3 0f 10 d0          	movss  %xmm0,%xmm2
  40c091:	66 49 0f 6e c5       	movq   %r13,%xmm0
  40c096:	f3 0f 11 85 b8 fd ff ff 	movss  %xmm0,-0x248(%rbp)
  40c09e:	66 48 0f 6e da       	movq   %rdx,%xmm3
  40c0a3:	0f 57 1d 66 7f 02 00 	xorps  0x27f66(%rip),%xmm3        # 434010 <_IO_stdin_used+0x10>
  40c0aa:	f3 0f 58 d8          	addss  %xmm0,%xmm3
  40c0ae:	66 48 0f 7e da       	movq   %xmm3,%rdx
  40c0b3:	89 d2                	mov    %edx,%edx
  40c0b5:	48 89 95 30 f5 ff ff 	mov    %rdx,-0xad0(%rbp)
  40c0bc:	48 89 8d 38 f5 ff ff 	mov    %rcx,-0xac8(%rbp)
  40c0c3:	66 48 0f 6e e2       	movq   %rdx,%xmm4
  40c0c8:	66 48 0f 6e d9       	movq   %rcx,%xmm3
  40c0cd:	f3 0f 11 9d 18 fe ff ff 	movss  %xmm3,-0x1e8(%rbp)
  40c0d5:	f3 44 0f 10 fb       	movss  %xmm3,%xmm15
  40c0da:	f3 0f 10 dc          	movss  %xmm4,%xmm3
  40c0de:	f3 41 0f 5e df       	divss  %xmm15,%xmm3
  40c0e3:	66 48 0f 7e d9       	movq   %xmm3,%rcx
  40c0e8:	41 89 c8             	mov    %ecx,%r8d
  40c0eb:	4c 89 85 88 fd ff ff 	mov    %r8,-0x278(%rbp)
  40c0f2:	48 c7 85 30 f5 ff ff 00 00 00 00 	movq   $0x0,-0xad0(%rbp)
  40c0fd:	48 c7 85 30 f5 ff ff 03 00 00 00 	movq   $0x3,-0xad0(%rbp)
  40c108:	48 c7 85 30 f5 ff ff 00 00 00 00 	movq   $0x0,-0xad0(%rbp)
  40c113:	48 c7 85 38 f5 ff ff 00 00 40 40 	movq   $0x40400000,-0xac8(%rbp)
  40c11e:	b9 00 00 40 c0       	mov    $0xc0400000,%ecx
  40c123:	48 89 8d 30 f5 ff ff 	mov    %rcx,-0xad0(%rbp)
  40c12a:	4c 89 a5 38 f5 ff ff 	mov    %r12,-0xac8(%rbp)
  40c131:	0f 57 15 d8 7e 02 00 	xorps  0x27ed8(%rip),%xmm2        # 434010 <_IO_stdin_used+0x10>
  40c138:	f3 0f 58 15 f0 7e 02 00 	addss  0x27ef0(%rip),%xmm2        # 434030 <_IO_stdin_used+0x30>
  40c140:	66 48 0f 7e d1       	movq   %xmm2,%rcx
  40c145:	41 89 c9             	mov    %ecx,%r9d
  40c148:	4c 89 8d f0 fd ff ff 	mov    %r9,-0x210(%rbp)
  40c14f:	48 c7 85 30 f5 ff ff 08 00 00 00 	movq   $0x8,-0xad0(%rbp)
  40c15a:	48 c7 85 30 f5 ff ff 00 00 00 41 	movq   $0x41000000,-0xad0(%rbp)
  40c165:	4c 89 b5 38 f5 ff ff 	mov    %r14,-0xac8(%rbp)
  40c16c:	0f 57 0d 9d 7e 02 00 	xorps  0x27e9d(%rip),%xmm1        # 434010 <_IO_stdin_used+0x10>
  40c173:	f3 0f 58 0d b1 7e 02 00 	addss  0x27eb1(%rip),%xmm1        # 43402c <_IO_stdin_used+0x2c>
  40c17b:	66 48 0f 7e c9       	movq   %xmm1,%rcx
  40c180:	89 ce                	mov    %ecx,%esi
  40c182:	48 89 b5 f8 fd ff ff 	mov    %rsi,-0x208(%rbp)
  40c189:	48 c7 85 30 f5 ff ff 01 00 00 00 	movq   $0x1,-0xad0(%rbp)
  40c194:	48 c7 85 30 f5 ff ff 00 00 80 3f 	movq   $0x3f800000,-0xad0(%rbp)
  40c19f:	4c 89 ad 38 f5 ff ff 	mov    %r13,-0xac8(%rbp)
  40c1a6:	0f 57 05 63 7e 02 00 	xorps  0x27e63(%rip),%xmm0        # 434010 <_IO_stdin_used+0x10>
  40c1ad:	f3 0f 58 05 6b 7e 02 00 	addss  0x27e6b(%rip),%xmm0        # 434020 <_IO_stdin_used+0x20>
  40c1b5:	66 48 0f 7e c1       	movq   %xmm0,%rcx
  40c1ba:	41 89 ca             	mov    %ecx,%r10d
  40c1bd:	4c 89 95 00 fe ff ff 	mov    %r10,-0x200(%rbp)
  40c1c4:	4c 89 8d 30 f5 ff ff 	mov    %r9,-0xad0(%rbp)
  40c1cb:	4c 89 8d 38 f5 ff ff 	mov    %r9,-0xac8(%rbp)
  40c1d2:	66 49 0f 6e e9       	movq   %r9,%xmm5
  40c1d7:	f3 0f 11 ad 1c fe ff ff 	movss  %xmm5,-0x1e4(%rbp)
  40c1df:	f3 0f 10 c5          	movss  %xmm5,%xmm0
  40c1e3:	f3 0f 59 c5          	mulss  %xmm5,%xmm0
  40c1e7:	66 48 0f 7e c1       	movq   %xmm0,%rcx
  40c1ec:	89 ca                	mov    %ecx,%edx
  40c1ee:	48 89 b5 30 f5 ff ff 	mov    %rsi,-0xad0(%rbp)
  40c1f5:	48 89 b5 38 f5 ff ff 	mov    %rsi,-0xac8(%rbp)
  40c1fc:	66 48 0f 6e e6       	movq   %rsi,%xmm4
  40c201:	f3 0f 11 a5 20 fe ff ff 	movss  %xmm4,-0x1e0(%rbp)
  40c209:	f3 0f 10 c4          	movss  %xmm4,%xmm0
  40c20d:	f3 0f 59 c4          	mulss  %xmm4,%xmm0
  40c211:	66 48 0f 7e c1       	movq   %xmm0,%rcx
  40c216:	89 c9                	mov    %ecx,%ecx
  40c218:	48 89 95 30 f5 ff ff 	mov    %rdx,-0xad0(%rbp)
  40c21f:	48 89 8d 38 f5 ff ff 	mov    %rcx,-0xac8(%rbp)
  40c226:	66 48 0f 6e c2       	movq   %rdx,%xmm0
  40c22b:	66 48 0f 6e c9       	movq   %rcx,%xmm1
  40c230:	f3 0f 58 c1          	addss  %xmm1,%xmm0
  40c234:	66 48 0f 7e c1       	movq   %xmm0,%rcx
  40c239:	89 ca                	mov    %ecx,%edx
  40c23b:	4c 89 95 30 f5 ff ff 	mov    %r10,-0xad0(%rbp)
  40c242:	4c 89 95 38 f5 ff ff 	mov    %r10,-0xac8(%rbp)
  40c249:	66 49 0f 6e ca       	movq   %r10,%xmm1
  40c24e:	f3 0f 11 8d 24 fe ff ff 	movss  %xmm1,-0x1dc(%rbp)
  40c256:	f3 0f 10 c1          	movss  %xmm1,%xmm0
  40c25a:	f3 0f 59 c1          	mulss  %xmm1,%xmm0
  40c25e:	66 48 0f 7e c1       	movq   %xmm0,%rcx
  40c263:	89 c9                	mov    %ecx,%ecx
  40c265:	48 89 95 30 f5 ff ff 	mov    %rdx,-0xad0(%rbp)
  40c26c:	48 89 8d 38 f5 ff ff 	mov    %rcx,-0xac8(%rbp)
  40c273:	66 48 0f 6e c2       	movq   %rdx,%xmm0
  40c278:	66 48 0f 6e c9       	movq   %rcx,%xmm1
  40c27d:	f3 0f 58 c1          	addss  %xmm1,%xmm0
  40c281:	49 89 c5             	mov    %rax,%r13
  40c284:	66 48 0f 7e c0       	movq   %xmm0,%rax
  40c289:	89 c0                	mov    %eax,%eax
  40c28b:	48 89 85 30 f5 ff ff 	mov    %rax,-0xad0(%rbp)
  40c292:	b9 01 00 00 00       	mov    $0x1,%ecx
  40c297:	48 8d 95 30 f5 ff ff 	lea    -0xad0(%rbp),%rdx
  40c29e:	be 24 00 00 00       	mov    $0x24,%esi
  40c2a3:	49 89 ff             	mov    %rdi,%r15
  40c2a6:	e8 75 20 02 00       	callq  42e320 <p111_rt_op>
  40c2ab:	4c 89 ff             	mov    %r15,%rdi
  40c2ae:	48 89 c2             	mov    %rax,%rdx
  40c2b1:	4c 89 e8             	mov    %r13,%rax
  40c2b4:	4c 8b 95 00 fe ff ff 	mov    -0x200(%rbp),%r10
  40c2bb:	48 8b b5 f8 fd ff ff 	mov    -0x208(%rbp),%rsi
  40c2c2:	4c 8b 8d f0 fd ff ff 	mov    -0x210(%rbp),%r9
  40c2c9:	4c 8b 85 88 fd ff ff 	mov    -0x278(%rbp),%r8
  40c2d0:	4c 8b 9d 10 fe ff ff 	mov    -0x1f0(%rbp),%r11
  40c2d7:	48 8b 8d 08 fe ff ff 	mov    -0x1f8(%rbp),%rcx
  40c2de:	f3 0f 10 8d 24 fe ff ff 	movss  -0x1dc(%rbp),%xmm1
  40c2e6:	f3 0f 10 a5 20 fe ff ff 	movss  -0x1e0(%rbp),%xmm4
  40c2ee:	f3 0f 10 ad 1c fe ff ff 	movss  -0x1e4(%rbp),%xmm5
  40c2f6:	f3 0f 10 9d 18 fe ff ff 	movss  -0x1e8(%rbp),%xmm3
  40c2fe:	f3 0f 10 85 e8 fd ff ff 	movss  -0x218(%rbp),%xmm0
  40c306:	4c 89 8d 30 f5 ff ff 	mov    %r9,-0xad0(%rbp)
  40c30d:	48 89 95 38 f5 ff ff 	mov    %rdx,-0xac8(%rbp)
  40c314:	66 48 0f 6e d2       	movq   %rdx,%xmm2
  40c319:	f3 0f 5e ea          	divss  %xmm2,%xmm5
  40c31d:	66 49 0f 7e e9       	movq   %xmm5,%r9
  40c322:	45 89 c9             	mov    %r9d,%r9d
  40c325:	4c 89 8d 90 fd ff ff 	mov    %r9,-0x270(%rbp)
  40c32c:	48 89 b5 30 f5 ff ff 	mov    %rsi,-0xad0(%rbp)
  40c333:	48 89 95 38 f5 ff ff 	mov    %rdx,-0xac8(%rbp)
  40c33a:	f3 0f 5e e2          	divss  %xmm2,%xmm4
  40c33e:	66 48 0f 7e e6       	movq   %xmm4,%rsi
  40c343:	89 f6                	mov    %esi,%esi
  40c345:	48 89 b5 98 fd ff ff 	mov    %rsi,-0x268(%rbp)
  40c34c:	4c 89 95 30 f5 ff ff 	mov    %r10,-0xad0(%rbp)
  40c353:	48 89 95 38 f5 ff ff 	mov    %rdx,-0xac8(%rbp)
  40c35a:	f3 0f 5e ca          	divss  %xmm2,%xmm1
  40c35e:	66 49 0f 7e ca       	movq   %xmm1,%r10
  40c363:	45 89 d2             	mov    %r10d,%r10d
  40c366:	4c 89 95 a0 fd ff ff 	mov    %r10,-0x260(%rbp)
  40c36d:	66 48 0f 6e c9       	movq   %rcx,%xmm1
  40c372:	f3 0f 5e cb          	divss  %xmm3,%xmm1
  40c376:	66 48 0f 7e c9       	movq   %xmm1,%rcx
  40c37b:	89 c9                	mov    %ecx,%ecx
  40c37d:	48 89 8d e0 fd ff ff 	mov    %rcx,-0x220(%rbp)
  40c384:	48 89 8d 30 f5 ff ff 	mov    %rcx,-0xad0(%rbp)
  40c38b:	4c 89 8d 38 f5 ff ff 	mov    %r9,-0xac8(%rbp)
  40c392:	66 48 0f 6e c9       	movq   %rcx,%xmm1
  40c397:	f3 0f 11 8d ec fd ff ff 	movss  %xmm1,-0x214(%rbp)
  40c39f:	66 49 0f 6e d1       	movq   %r9,%xmm2
  40c3a4:	f3 0f 59 d1          	mulss  %xmm1,%xmm2
  40c3a8:	66 49 0f 7e d1       	movq   %xmm2,%r9
  40c3ad:	45 89 c9             	mov    %r9d,%r9d
  40c3b0:	66 49 0f 6e d3       	movq   %r11,%xmm2
  40c3b5:	f3 0f 5e d3          	divss  %xmm3,%xmm2
  40c3b9:	66 49 0f 7e d3       	movq   %xmm2,%r11
  40c3be:	45 89 db             	mov    %r11d,%r11d
  40c3c1:	4c 89 9d c8 fd ff ff 	mov    %r11,-0x238(%rbp)
  40c3c8:	4c 89 9d 30 f5 ff ff 	mov    %r11,-0xad0(%rbp)
  40c3cf:	48 89 b5 38 f5 ff ff 	mov    %rsi,-0xac8(%rbp)
  40c3d6:	66 49 0f 6e d3       	movq   %r11,%xmm2
  40c3db:	f3 0f 11 95 d4 fd ff ff 	movss  %xmm2,-0x22c(%rbp)
  40c3e3:	66 48 0f 6e de       	movq   %rsi,%xmm3
  40c3e8:	f3 0f 59 d3          	mulss  %xmm3,%xmm2
  40c3ec:	66 48 0f 7e d6       	movq   %xmm2,%rsi
  40c3f1:	89 f6                	mov    %esi,%esi
  40c3f3:	4c 89 8d 30 f5 ff ff 	mov    %r9,-0xad0(%rbp)
  40c3fa:	48 89 b5 38 f5 ff ff 	mov    %rsi,-0xac8(%rbp)
  40c401:	66 49 0f 6e d1       	movq   %r9,%xmm2
  40c406:	66 48 0f 6e de       	movq   %rsi,%xmm3
  40c40b:	f3 0f 58 d3          	addss  %xmm3,%xmm2
  40c40f:	4c 89 c6             	mov    %r8,%rsi
  40c412:	66 49 0f 7e d0       	movq   %xmm2,%r8
  40c417:	45 89 c0             	mov    %r8d,%r8d
  40c41a:	48 89 b5 30 f5 ff ff 	mov    %rsi,-0xad0(%rbp)
  40c421:	4c 89 95 38 f5 ff ff 	mov    %r10,-0xac8(%rbp)
  40c428:	66 48 0f 6e d6       	movq   %rsi,%xmm2
  40c42d:	f3 0f 11 95 bc fd ff ff 	movss  %xmm2,-0x244(%rbp)
  40c435:	66 49 0f 6e da       	movq   %r10,%xmm3
  40c43a:	f3 0f 59 d3          	mulss  %xmm3,%xmm2
  40c43e:	66 48 0f 7e d6       	movq   %xmm2,%rsi
  40c443:	89 f6                	mov    %esi,%esi
  40c445:	4c 89 85 30 f5 ff ff 	mov    %r8,-0xad0(%rbp)
  40c44c:	48 89 b5 38 f5 ff ff 	mov    %rsi,-0xac8(%rbp)
  40c453:	66 49 0f 6e d0       	movq   %r8,%xmm2
  40c458:	66 48 0f 6e de       	movq   %rsi,%xmm3
  40c45d:	f3 0f 58 d3          	addss  %xmm3,%xmm2
  40c461:	66 48 0f 7e d6       	movq   %xmm2,%rsi
  40c466:	89 f6                	mov    %esi,%esi
  40c468:	66 48 0f 6e d6       	movq   %rsi,%xmm2
  40c46d:	f3 0f 10 1d af 7b 02 00 	movss  0x27baf(%rip),%xmm3        # 434024 <_IO_stdin_used+0x24>
  40c475:	0f 2e da             	ucomiss %xmm2,%xmm3
  40c478:	41 0f 97 c0          	seta   %r8b
  40c47c:	45 0f b6 c0          	movzbl %r8b,%r8d
  40c480:	45 89 c0             	mov    %r8d,%r8d
  40c483:	49 83 f8 01          	cmp    $0x1,%r8
  40c487:	49 89 c5             	mov    %rax,%r13
  40c48a:	0f 94 c0             	sete   %al
  40c48d:	0f b6 c0             	movzbl %al,%eax
  40c490:	49 c1 e8 28          	shr    $0x28,%r8
  40c494:	49 81 e0 ff ff 7f 00 	and    $0x7fffff,%r8
  40c49b:	49 81 f8 02 00 01 00 	cmp    $0x10002,%r8
  40c4a2:	49 89 d7             	mov    %rdx,%r15
  40c4a5:	0f 94 c2             	sete   %dl
  40c4a8:	0f b6 d2             	movzbl %dl,%edx
  40c4ab:	09 d0                	or     %edx,%eax
  40c4ad:	75 53                	jne    40c502 <p113d_FID_36_100_105_114_101_99_116_46_116_114_97_99_101_+0x1872>
  40c4af:	83 f0 01             	xor    $0x1,%eax
  40c4b2:	75 3b                	jne    40c4ef <p113d_FID_36_100_105_114_101_99_116_46_116_114_97_99_101_+0x185f>
  40c4b4:	be 04 00 00 00       	mov    $0x4,%esi
  40c4b9:	49 89 fe             	mov    %rdi,%r14
  40c4bc:	e8 3f 1e 02 00       	callq  42e300 <p111_rt_fail>
  40c4c1:	4c 89 fa             	mov    %r15,%rdx
  40c4c4:	4c 89 f7             	mov    %r14,%rdi
  40c4c7:	4c 89 e8             	mov    %r13,%rax
  40c4ca:	48 8b 8d e0 fd ff ff 	mov    -0x220(%rbp),%rcx
  40c4d1:	4c 8b ad d8 fd ff ff 	mov    -0x228(%rbp),%r13
  40c4d8:	f3 0f 10 8d ec fd ff ff 	movss  -0x214(%rbp),%xmm1
  40c4e0:	f3 0f 10 85 e8 fd ff ff 	movss  -0x218(%rbp),%xmm0
  40c4e8:	be 00 00 00 00       	mov    $0x0,%esi
  40c4ed:	eb 0a                	jmp    40c4f9 <p113d_FID_36_100_105_114_101_99_116_46_116_114_97_99_101_+0x1869>
  40c4ef:	2e 4c 89 fa          	cs mov %r15,%rdx
  40c4f3:	4c 89 e8             	mov    %r13,%rax
  40c4f6:	4d 89 f5             	mov    %r14,%r13
  40c4f9:	48 89 b5 78 fd ff ff 	mov    %rsi,-0x288(%rbp)
  40c500:	eb 14                	jmp    40c516 <p113d_FID_36_100_105_114_101_99_116_46_116_114_97_99_101_+0x1886>
  40c502:	4c 89 fa             	mov    %r15,%rdx
  40c505:	4c 89 e8             	mov    %r13,%rax
  40c508:	4d 89 f5             	mov    %r14,%r13
  40c50b:	48 c7 85 78 fd ff ff 00 00 00 00 	movq   $0x0,-0x288(%rbp)
  40c516:	48 c7 85 30 f5 ff ff 6f 12 83 3a 	movq   $0x3a83126f,-0xad0(%rbp)
  40c521:	48 89 8d 38 f5 ff ff 	mov    %rcx,-0xac8(%rbp)
  40c528:	f3 0f 59 0d f8 7a 02 00 	mulss  0x27af8(%rip),%xmm1        # 434028 <_IO_stdin_used+0x28>
  40c530:	66 48 0f 7e c9       	movq   %xmm1,%rcx
  40c535:	89 c9                	mov    %ecx,%ecx
  40c537:	4c 89 a5 30 f5 ff ff 	mov    %r12,-0xad0(%rbp)
  40c53e:	48 89 8d 38 f5 ff ff 	mov    %rcx,-0xac8(%rbp)
  40c545:	66 48 0f 6e c9       	movq   %rcx,%xmm1
  40c54a:	f3 0f 58 c1          	addss  %xmm1,%xmm0
  40c54e:	49 89 c4             	mov    %rax,%r12
  40c551:	66 48 0f 7e c0       	movq   %xmm0,%rax
  40c556:	89 c0                	mov    %eax,%eax
  40c558:	48 89 85 a8 fd ff ff 	mov    %rax,-0x258(%rbp)
  40c55f:	49 89 d7             	mov    %rdx,%r15
  40c562:	ba e8 03 00 00       	mov    $0x3e8,%edx
  40c567:	be 01 00 00 00       	mov    $0x1,%esi
  40c56c:	49 89 fe             	mov    %rdi,%r14
  40c56f:	e8 fc 97 ff ff       	callq  405d70 <p113d_FID_36_100_105_114_101_99_116_46_102_108_>
  40c574:	4c 89 fa             	mov    %r15,%rdx
  40c577:	4c 89 f7             	mov    %r14,%rdi
  40c57a:	48 89 c1             	mov    %rax,%rcx
  40c57d:	4c 89 e0             	mov    %r12,%rax
  40c580:	48 8b b5 c8 fd ff ff 	mov    -0x238(%rbp),%rsi
  40c587:	4c 8b a5 c0 fd ff ff 	mov    -0x240(%rbp),%r12
  40c58e:	f3 0f 10 8d d4 fd ff ff 	movss  -0x22c(%rbp),%xmm1
  40c596:	f3 0f 10 85 d0 fd ff ff 	movss  -0x230(%rbp),%xmm0
  40c59e:	48 89 8d 30 f5 ff ff 	mov    %rcx,-0xad0(%rbp)
  40c5a5:	48 89 b5 38 f5 ff ff 	mov    %rsi,-0xac8(%rbp)
  40c5ac:	66 48 0f 6e d1       	movq   %rcx,%xmm2
  40c5b1:	f3 0f 59 ca          	mulss  %xmm2,%xmm1
  40c5b5:	66 48 0f 7e c9       	movq   %xmm1,%rcx
  40c5ba:	89 c9                	mov    %ecx,%ecx
  40c5bc:	4c 89 ad 30 f5 ff ff 	mov    %r13,-0xad0(%rbp)
  40c5c3:	48 89 8d 38 f5 ff ff 	mov    %rcx,-0xac8(%rbp)
  40c5ca:	66 48 0f 6e c9       	movq   %rcx,%xmm1
  40c5cf:	f3 0f 58 c1          	addss  %xmm1,%xmm0
  40c5d3:	49 89 c5             	mov    %rax,%r13
  40c5d6:	66 48 0f 7e c0       	movq   %xmm0,%rax
  40c5db:	89 c1                	mov    %eax,%ecx
  40c5dd:	48 89 8d b0 fd ff ff 	mov    %rcx,-0x250(%rbp)
  40c5e4:	49 89 d7             	mov    %rdx,%r15
  40c5e7:	ba e8 03 00 00       	mov    $0x3e8,%edx
  40c5ec:	be 01 00 00 00       	mov    $0x1,%esi
  40c5f1:	49 89 fe             	mov    %rdi,%r14
  40c5f4:	e8 77 97 ff ff       	callq  405d70 <p113d_FID_36_100_105_114_101_99_116_46_102_108_>
  40c5f9:	4c 89 fa             	mov    %r15,%rdx
  40c5fc:	4c 89 f7             	mov    %r14,%rdi
  40c5ff:	48 89 c6             	mov    %rax,%rsi
  40c602:	4c 89 e8             	mov    %r13,%rax
  40c605:	48 8b 8d b0 fd ff ff 	mov    -0x250(%rbp),%rcx
  40c60c:	49 89 d5             	mov    %rdx,%r13
  40c60f:	48 8b 95 a8 fd ff ff 	mov    -0x258(%rbp),%rdx
  40c616:	4c 8b 95 a0 fd ff ff 	mov    -0x260(%rbp),%r10
  40c61d:	49 89 c6             	mov    %rax,%r14
  40c620:	48 8b 85 98 fd ff ff 	mov    -0x268(%rbp),%rax
  40c627:	4c 8b 8d 90 fd ff ff 	mov    -0x270(%rbp),%r9
  40c62e:	4c 8b 85 88 fd ff ff 	mov    -0x278(%rbp),%r8
  40c635:	f3 0f 10 8d bc fd ff ff 	movss  -0x244(%rbp),%xmm1
  40c63d:	f3 0f 10 85 b8 fd ff ff 	movss  -0x248(%rbp),%xmm0
  40c645:	48 89 b5 30 f5 ff ff 	mov    %rsi,-0xad0(%rbp)
  40c64c:	4c 89 85 38 f5 ff ff 	mov    %r8,-0xac8(%rbp)
  40c653:	66 48 0f 6e d6       	movq   %rsi,%xmm2
  40c658:	f3 0f 59 ca          	mulss  %xmm2,%xmm1
  40c65c:	66 48 0f 7e ce       	movq   %xmm1,%rsi
  40c661:	89 f6                	mov    %esi,%esi
  40c663:	4c 89 a5 30 f5 ff ff 	mov    %r12,-0xad0(%rbp)
  40c66a:	48 89 b5 38 f5 ff ff 	mov    %rsi,-0xac8(%rbp)
  40c671:	66 48 0f 6e ce       	movq   %rsi,%xmm1
  40c676:	f3 0f 58 c1          	addss  %xmm1,%xmm0
  40c67a:	66 48 0f 7e c6       	movq   %xmm0,%rsi
  40c67f:	41 89 f0             	mov    %esi,%r8d
  40c682:	48 c7 85 30 f5 ff ff 00 ca 9a 3b 	movq   $0x3b9aca00,-0xad0(%rbp)
  40c68d:	48 c7 85 30 f5 ff ff 00 ca 9a 3b 	movq   $0x3b9aca00,-0xad0(%rbp)
  40c698:	48 83 ec 30          	sub    $0x30,%rsp
  40c69c:	48 89 e6             	mov    %rsp,%rsi
  40c69f:	48 c7 46 20 00 00 00 00 	movq   $0x0,0x20(%rsi)
  40c6a7:	48 c7 46 18 28 6b 6e 4e 	movq   $0x4e6e6b28,0x18(%rsi)
  40c6af:	48 c7 46 10 28 6b 6e 4e 	movq   $0x4e6e6b28,0x10(%rsi)
  40c6b7:	4c 89 56 08          	mov    %r10,0x8(%rsi)
  40c6bb:	48 89 06             	mov    %rax,(%rsi)
  40c6be:	be 09 00 00 00       	mov    $0x9,%esi
  40c6c3:	49 89 fc             	mov    %rdi,%r12
  40c6c6:	e8 15 ab ff ff       	callq  4071e0 <p113d_FID_36_100_105_114_101_99_116_46_110_101_97_114_101_115_116_46_116_>
  40c6cb:	4c 89 ea             	mov    %r13,%rdx
  40c6ce:	4c 89 e7             	mov    %r12,%rdi
  40c6d1:	48 89 85 80 fd ff ff 	mov    %rax,-0x280(%rbp)
  40c6d8:	48 83 ec d0          	sub    $0xffffffffffffffd0,%rsp
  40c6dc:	49 89 d5             	mov    %rdx,%r13
  40c6df:	ba 0a 00 00 00       	mov    $0xa,%edx
  40c6e4:	be 01 00 00 00       	mov    $0x1,%esi
  40c6e9:	49 89 fc             	mov    %rdi,%r12
  40c6ec:	e8 7f 96 ff ff       	callq  405d70 <p113d_FID_36_100_105_114_101_99_116_46_102_108_>
  40c6f1:	4c 89 ea             	mov    %r13,%rdx
  40c6f4:	4c 89 e7             	mov    %r12,%rdi
  40c6f7:	49 89 c4             	mov    %rax,%r12
  40c6fa:	49 89 d7             	mov    %rdx,%r15
  40c6fd:	ba 64 00 00 00       	mov    $0x64,%edx
  40c702:	be 55 00 00 00       	mov    $0x55,%esi
  40c707:	49 89 fd             	mov    %rdi,%r13
  40c70a:	e8 61 96 ff ff       	callq  405d70 <p113d_FID_36_100_105_114_101_99_116_46_102_108_>
  40c70f:	4c 89 fa             	mov    %r15,%rdx
  40c712:	4c 89 ef             	mov    %r13,%rdi
  40c715:	49 89 c5             	mov    %rax,%r13
  40c718:	48 8b 8d 78 fd ff ff 	mov    -0x288(%rbp),%rcx
  40c71f:	48 8b b5 80 fd ff ff 	mov    -0x280(%rbp),%rsi
  40c726:	e8 a5 9e ff ff       	callq  4065d0 <p113d_FID_36_100_105_114_101_99_116_46_115_104_97_100_101_>
  40c72b:	48 89 c1             	mov    %rax,%rcx
  40c72e:	4c 89 f0             	mov    %r14,%rax
  40c731:	f3 0f 10 8d 74 fd ff ff 	movss  -0x28c(%rbp),%xmm1
  40c739:	f3 0f 10 95 70 fd ff ff 	movss  -0x290(%rbp),%xmm2
  40c741:	4c 89 ad 30 f5 ff ff 	mov    %r13,-0xad0(%rbp)
  40c748:	48 89 8d 38 f5 ff ff 	mov    %rcx,-0xac8(%rbp)
  40c74f:	66 49 0f 6e c5       	movq   %r13,%xmm0
  40c754:	66 48 0f 6e d9       	movq   %rcx,%xmm3
  40c759:	f3 0f 59 c3          	mulss  %xmm3,%xmm0
  40c75d:	66 48 0f 7e c1       	movq   %xmm0,%rcx
  40c762:	89 c9                	mov    %ecx,%ecx
  40c764:	4c 89 a5 30 f5 ff ff 	mov    %r12,-0xad0(%rbp)
  40c76b:	48 89 8d 38 f5 ff ff 	mov    %rcx,-0xac8(%rbp)
  40c772:	66 49 0f 6e c4       	movq   %r12,%xmm0
  40c777:	66 48 0f 6e d9       	movq   %rcx,%xmm3
  40c77c:	f3 0f 58 c3          	addss  %xmm3,%xmm0
  40c780:	66 48 0f 7e c1       	movq   %xmm0,%rcx
  40c785:	89 c9                	mov    %ecx,%ecx
  40c787:	48 89 9d 30 f5 ff ff 	mov    %rbx,-0xad0(%rbp)
  40c78e:	48 89 8d 38 f5 ff ff 	mov    %rcx,-0xac8(%rbp)
  40c795:	66 48 0f 6e c1       	movq   %rcx,%xmm0
  40c79a:	f3 0f 59 c2          	mulss  %xmm2,%xmm0
  40c79e:	48 89 c3             	mov    %rax,%rbx
  40c7a1:	66 48 0f 7e c0       	movq   %xmm0,%rax
  40c7a6:	89 c0                	mov    %eax,%eax
  40c7a8:	48 89 9d 30 f5 ff ff 	mov    %rbx,-0xad0(%rbp)
  40c7af:	48 89 85 38 f5 ff ff 	mov    %rax,-0xac8(%rbp)
  40c7b6:	66 48 0f 6e c0       	movq   %rax,%xmm0
  40c7bb:	f3 0f 58 c1          	addss  %xmm1,%xmm0
  40c7bf:	66 48 0f 7e c0       	movq   %xmm0,%rax
  40c7c4:	89 c0                	mov    %eax,%eax
  40c7c6:	41 5f                	pop    %r15
  40c7c8:	41 5e                	pop    %r14
  40c7ca:	41 5d                	pop    %r13
  40c7cc:	41 5c                	pop    %r12
  40c7ce:	5b                   	pop    %rbx
  40c7cf:	c9                   	leaveq 
  40c7d0:	c3                   	retq   
  40c7d1:	66 66 2e 0f 1f 84 00 00 00 00 00 	data16 nopw %cs:0x0(%rax,%rax,1)
  40c7dc:	0f 1f 40 00          	nopl   0x0(%rax)

