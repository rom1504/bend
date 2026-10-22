000000000040adc0 <p113d_FID_36_100_105_114_101_99_116_46_116_114_97_99_101_>:
  40adc0:	f3 0f 1e fa          	endbr64 
  40adc4:	2e 2e 2e 2e 2e 55    	cs cs cs cs cs push %rbp
  40adca:	2e 2e 2e 2e 48 89 e5 	cs cs cs cs mov %rsp,%rbp
  40add1:	48 81 ec d8 0a 00 00 	sub    $0xad8,%rsp
  40add8:	53                   	push   %rbx
  40add9:	41 54                	push   %r12
  40addb:	41 55                	push   %r13
  40addd:	41 56                	push   %r14
  40addf:	41 57                	push   %r15
  40ade1:	48 8b 5d 30          	mov    0x30(%rbp),%rbx
  40ade5:	48 89 9d b0 fe ff ff 	mov    %rbx,-0x150(%rbp)
  40adec:	48 8b 45 28          	mov    0x28(%rbp),%rax
  40adf0:	4c 8b 65 20          	mov    0x20(%rbp),%r12
  40adf4:	4d 89 e5             	mov    %r12,%r13
  40adf7:	4c 8b 65 18          	mov    0x18(%rbp),%r12
  40adfb:	4c 8b 7d 10          	mov    0x10(%rbp),%r15
  40adff:	4d 87 c8             	xchg   %r9,%r8
  40ae02:	49 89 ca             	mov    %rcx,%r10
  40ae05:	48 89 f1             	mov    %rsi,%rcx
  40ae08:	48 89 d6             	mov    %rdx,%rsi
  40ae0b:	4c 89 e2             	mov    %r12,%rdx
  40ae0e:	4c 89 85 70 fe ff ff 	mov    %r8,-0x190(%rbp)
  40ae15:	4c 89 8d 88 fe ff ff 	mov    %r9,-0x178(%rbp)
  40ae1c:	4c 89 95 98 fe ff ff 	mov    %r10,-0x168(%rbp)
  40ae23:	48 89 8d f0 fe ff ff 	mov    %rcx,-0x110(%rbp)
  40ae2a:	48 83 f9 00          	cmp    $0x0,%rcx
  40ae2e:	0f 94 c1             	sete   %cl
  40ae31:	0f b6 c9             	movzbl %cl,%ecx
  40ae34:	66 49 0f 6e f7       	movq   %r15,%xmm6
  40ae39:	f3 0f 11 b5 ac fe ff ff 	movss  %xmm6,-0x154(%rbp)
  40ae41:	66 49 0f 6e ca       	movq   %r10,%xmm1
  40ae46:	f3 0f 11 8d c0 fe ff ff 	movss  %xmm1,-0x140(%rbp)
  40ae4e:	66 48 0f 6e ea       	movq   %rdx,%xmm5
  40ae53:	f3 0f 11 ad b8 fe ff ff 	movss  %xmm5,-0x148(%rbp)
  40ae5b:	66 49 0f 6e d1       	movq   %r9,%xmm2
  40ae60:	f3 0f 11 95 c4 fe ff ff 	movss  %xmm2,-0x13c(%rbp)
  40ae68:	66 49 0f 6e e5       	movq   %r13,%xmm4
  40ae6d:	f3 0f 11 a5 bc fe ff ff 	movss  %xmm4,-0x144(%rbp)
  40ae75:	66 49 0f 6e d8       	movq   %r8,%xmm3
  40ae7a:	f3 0f 11 9d c8 fe ff ff 	movss  %xmm3,-0x138(%rbp)
  40ae82:	66 48 0f 6e d3       	movq   %rbx,%xmm2
  40ae87:	f3 0f 11 95 70 fd ff ff 	movss  %xmm2,-0x290(%rbp)
  40ae8f:	66 48 0f 6e c8       	movq   %rax,%xmm1
  40ae94:	f3 0f 11 8d 74 fd ff ff 	movss  %xmm1,-0x28c(%rbp)
  40ae9c:	48 89 c3             	mov    %rax,%rbx
  40ae9f:	48 89 f0             	mov    %rsi,%rax
  40aea2:	48 c1 e8 28          	shr    $0x28,%rax
  40aea6:	48 25 ff ff 00 00    	and    $0xffff,%rax
  40aeac:	41 b8 00 00 00 41    	mov    $0x41000000,%r8d
  40aeb2:	4c 89 85 28 fe ff ff 	mov    %r8,-0x1d8(%rbp)
  40aeb9:	41 b8 cd cc 4c 3e    	mov    $0x3e4ccccd,%r8d
  40aebf:	4c 89 85 58 fe ff ff 	mov    %r8,-0x1a8(%rbp)
  40aec6:	41 b8 00 00 60 c0    	mov    $0xc0600000,%r8d
  40aecc:	4c 89 85 68 fe ff ff 	mov    %r8,-0x198(%rbp)
  40aed3:	41 ba 00 00 80 3f    	mov    $0x3f800000,%r10d
  40aed9:	4c 89 95 a0 fe ff ff 	mov    %r10,-0x160(%rbp)
  40aee0:	83 f9 00             	cmp    $0x0,%ecx
  40aee3:	0f 85 96 0d 00 00    	jne    40bc7f <p113d_FID_36_100_105_114_101_99_116_46_116_114_97_99_101_+0xebf>
  40aee9:	48 3d 97 00 00 00    	cmp    $0x97,%rax
  40aeef:	74 14                	je     40af05 <p113d_FID_36_100_105_114_101_99_116_46_116_114_97_99_101_+0x145>
  40aef1:	be 04 00 00 00       	mov    $0x4,%esi
  40aef6:	e8 a5 19 02 00       	callq  42c8a0 <p111_rt_fail>
  40aefb:	b8 00 00 00 00       	mov    $0x0,%eax
  40af00:	e9 f8 19 00 00       	jmpq   40c8fd <p113d_FID_36_100_105_114_101_99_116_46_116_114_97_99_101_+0x1b3d>
  40af05:	49 89 d6             	mov    %rdx,%r14
  40af08:	48 8d 95 30 f5 ff ff 	lea    -0xad0(%rbp),%rdx
  40af0f:	49 89 fc             	mov    %rdi,%r12
  40af12:	e8 09 6c 02 00       	callq  431b20 <p125_rt_take3>
  40af17:	4c 89 f2             	mov    %r14,%rdx
  40af1a:	4c 89 e7             	mov    %r12,%rdi
  40af1d:	48 89 d8             	mov    %rbx,%rax
  40af20:	48 8b 8d 30 f5 ff ff 	mov    -0xad0(%rbp),%rcx
  40af27:	49 89 d6             	mov    %rdx,%r14
  40af2a:	48 8b 95 38 f5 ff ff 	mov    -0xac8(%rbp),%rdx
  40af31:	48 89 55 f0          	mov    %rdx,-0x10(%rbp)
  40af35:	48 8b b5 40 f5 ff ff 	mov    -0xac0(%rbp),%rsi
  40af3c:	48 89 b5 50 ff ff ff 	mov    %rsi,-0xb0(%rbp)
  40af43:	48 83 f9 01          	cmp    $0x1,%rcx
  40af47:	48 89 c3             	mov    %rax,%rbx
  40af4a:	0f 94 c0             	sete   %al
  40af4d:	0f b6 c0             	movzbl %al,%eax
  40af50:	48 c1 e9 28          	shr    $0x28,%rcx
  40af54:	48 81 e1 ff ff 7f 00 	and    $0x7fffff,%rcx
  40af5b:	48 81 f9 02 00 01 00 	cmp    $0x10002,%rcx
  40af62:	0f 94 c1             	sete   %cl
  40af65:	0f b6 c9             	movzbl %cl,%ecx
  40af68:	09 c8                	or     %ecx,%eax
  40af6a:	0f 85 04 0d 00 00    	jne    40bc74 <p113d_FID_36_100_105_114_101_99_116_46_116_114_97_99_101_+0xeb4>
  40af70:	83 f0 01             	xor    $0x1,%eax
  40af73:	75 14                	jne    40af89 <p113d_FID_36_100_105_114_101_99_116_46_116_114_97_99_101_+0x1c9>
  40af75:	be 04 00 00 00       	mov    $0x4,%esi
  40af7a:	e8 21 19 02 00       	callq  42c8a0 <p111_rt_fail>
  40af7f:	b8 00 00 00 00       	mov    $0x0,%eax
  40af84:	e9 74 19 00 00       	jmpq   40c8fd <p113d_FID_36_100_105_114_101_99_116_46_116_114_97_99_101_+0x1b3d>
  40af89:	49 89 fc             	mov    %rdi,%r12
  40af8c:	e8 bf b6 ff ff       	callq  406650 <p113d_FID_36_100_105_114_101_99_116_46_115_114_>
  40af91:	4c 89 e7             	mov    %r12,%rdi
  40af94:	48 89 45 e0          	mov    %rax,-0x20(%rbp)
  40af98:	48 89 d8             	mov    %rbx,%rax
  40af9b:	f3 0f 10 9d c8 fe ff ff 	movss  -0x138(%rbp),%xmm3
  40afa3:	f3 0f 10 a5 bc fe ff ff 	movss  -0x144(%rbp),%xmm4
  40afab:	f3 0f 10 95 c4 fe ff ff 	movss  -0x13c(%rbp),%xmm2
  40afb3:	f3 0f 10 ad b8 fe ff ff 	movss  -0x148(%rbp),%xmm5
  40afbb:	f3 0f 10 8d c0 fe ff ff 	movss  -0x140(%rbp),%xmm1
  40afc3:	f3 0f 10 b5 ac fe ff ff 	movss  -0x154(%rbp),%xmm6
  40afcb:	48 8b b5 50 ff ff ff 	mov    -0xb0(%rbp),%rsi
  40afd2:	48 8b 4d f0          	mov    -0x10(%rbp),%rcx
  40afd6:	48 8b 95 70 fe ff ff 	mov    -0x190(%rbp),%rdx
  40afdd:	4c 8b 8d 88 fe ff ff 	mov    -0x178(%rbp),%r9
  40afe4:	4c 8b 95 98 fe ff ff 	mov    -0x168(%rbp),%r10
  40afeb:	48 89 8d 30 f5 ff ff 	mov    %rcx,-0xad0(%rbp)
  40aff2:	4c 89 bd 38 f5 ff ff 	mov    %r15,-0xac8(%rbp)
  40aff9:	66 48 0f 6e c1       	movq   %rcx,%xmm0
  40affe:	f3 0f 59 f0          	mulss  %xmm0,%xmm6
  40b002:	66 49 0f 7e f0       	movq   %xmm6,%r8
  40b007:	45 89 c0             	mov    %r8d,%r8d
  40b00a:	4c 89 95 30 f5 ff ff 	mov    %r10,-0xad0(%rbp)
  40b011:	4c 89 85 38 f5 ff ff 	mov    %r8,-0xac8(%rbp)
  40b018:	66 49 0f 6e f0       	movq   %r8,%xmm6
  40b01d:	f3 0f 58 ce          	addss  %xmm6,%xmm1
  40b021:	66 49 0f 7e c8       	movq   %xmm1,%r8
  40b026:	45 89 c0             	mov    %r8d,%r8d
  40b029:	4c 89 45 b0          	mov    %r8,-0x50(%rbp)
  40b02d:	48 89 8d 30 f5 ff ff 	mov    %rcx,-0xad0(%rbp)
  40b034:	4c 89 b5 38 f5 ff ff 	mov    %r14,-0xac8(%rbp)
  40b03b:	f3 0f 10 c8          	movss  %xmm0,%xmm1
  40b03f:	f3 0f 59 cd          	mulss  %xmm5,%xmm1
  40b043:	66 49 0f 7e c8       	movq   %xmm1,%r8
  40b048:	45 89 c0             	mov    %r8d,%r8d
  40b04b:	4c 89 8d 30 f5 ff ff 	mov    %r9,-0xad0(%rbp)
  40b052:	4c 89 85 38 f5 ff ff 	mov    %r8,-0xac8(%rbp)
  40b059:	66 49 0f 6e c8       	movq   %r8,%xmm1
  40b05e:	f3 0f 58 ca          	addss  %xmm2,%xmm1
  40b062:	66 49 0f 7e c8       	movq   %xmm1,%r8
  40b067:	45 89 c0             	mov    %r8d,%r8d
  40b06a:	4c 89 45 a8          	mov    %r8,-0x58(%rbp)
  40b06e:	48 89 8d 30 f5 ff ff 	mov    %rcx,-0xad0(%rbp)
  40b075:	4c 89 ad 38 f5 ff ff 	mov    %r13,-0xac8(%rbp)
  40b07c:	f3 0f 59 c4          	mulss  %xmm4,%xmm0
  40b080:	66 48 0f 7e c1       	movq   %xmm0,%rcx
  40b085:	89 c9                	mov    %ecx,%ecx
  40b087:	48 89 95 30 f5 ff ff 	mov    %rdx,-0xad0(%rbp)
  40b08e:	48 89 8d 38 f5 ff ff 	mov    %rcx,-0xac8(%rbp)
  40b095:	66 48 0f 6e c1       	movq   %rcx,%xmm0
  40b09a:	f3 0f 58 c3          	addss  %xmm3,%xmm0
  40b09e:	48 89 c3             	mov    %rax,%rbx
  40b0a1:	66 48 0f 7e c0       	movq   %xmm0,%rax
  40b0a6:	41 89 c2             	mov    %eax,%r10d
  40b0a9:	4c 89 55 80          	mov    %r10,-0x80(%rbp)
  40b0ad:	49 89 fc             	mov    %rdi,%r12
  40b0b0:	e8 9b b8 ff ff       	callq  406950 <p113d_FID_36_100_105_114_101_99_116_46_115_120_>
  40b0b5:	4c 89 e7             	mov    %r12,%rdi
  40b0b8:	48 89 c1             	mov    %rax,%rcx
  40b0bb:	48 89 d8             	mov    %rbx,%rax
  40b0be:	48 8b 75 b0          	mov    -0x50(%rbp),%rsi
  40b0c2:	4c 8b 45 e0          	mov    -0x20(%rbp),%r8
  40b0c6:	48 89 f2             	mov    %rsi,%rdx
  40b0c9:	48 8b b5 50 ff ff ff 	mov    -0xb0(%rbp),%rsi
  40b0d0:	48 89 95 30 f5 ff ff 	mov    %rdx,-0xad0(%rbp)
  40b0d7:	48 89 8d 38 f5 ff ff 	mov    %rcx,-0xac8(%rbp)
  40b0de:	66 48 0f 6e c2       	movq   %rdx,%xmm0
  40b0e3:	f3 0f 11 45 b8       	movss  %xmm0,-0x48(%rbp)
  40b0e8:	66 48 0f 6e c9       	movq   %rcx,%xmm1
  40b0ed:	f3 0f 5c c1          	subss  %xmm1,%xmm0
  40b0f1:	66 48 0f 7e c1       	movq   %xmm0,%rcx
  40b0f6:	89 c9                	mov    %ecx,%ecx
  40b0f8:	48 89 8d 30 f5 ff ff 	mov    %rcx,-0xad0(%rbp)
  40b0ff:	4c 89 85 38 f5 ff ff 	mov    %r8,-0xac8(%rbp)
  40b106:	66 48 0f 6e c1       	movq   %rcx,%xmm0
  40b10b:	66 49 0f 6e e0       	movq   %r8,%xmm4
  40b110:	f3 0f 11 65 e8       	movss  %xmm4,-0x18(%rbp)
  40b115:	f3 0f 5e c4          	divss  %xmm4,%xmm0
  40b119:	48 89 c3             	mov    %rax,%rbx
  40b11c:	66 48 0f 7e c0       	movq   %xmm0,%rax
  40b121:	89 c1                	mov    %eax,%ecx
  40b123:	48 89 8d 28 ff ff ff 	mov    %rcx,-0xd8(%rbp)
  40b12a:	49 89 fc             	mov    %rdi,%r12
  40b12d:	e8 be b6 ff ff       	callq  4067f0 <p113d_FID_36_100_105_114_101_99_116_46_115_121_>
  40b132:	4c 89 e7             	mov    %r12,%rdi
  40b135:	48 89 c1             	mov    %rax,%rcx
  40b138:	48 89 d8             	mov    %rbx,%rax
  40b13b:	48 8b 75 a8          	mov    -0x58(%rbp),%rsi
  40b13f:	f3 0f 10 65 e8       	movss  -0x18(%rbp),%xmm4
  40b144:	4c 8b 45 e0          	mov    -0x20(%rbp),%r8
  40b148:	48 89 f2             	mov    %rsi,%rdx
  40b14b:	48 8b b5 50 ff ff ff 	mov    -0xb0(%rbp),%rsi
  40b152:	48 89 95 30 f5 ff ff 	mov    %rdx,-0xad0(%rbp)
  40b159:	48 89 8d 38 f5 ff ff 	mov    %rcx,-0xac8(%rbp)
  40b160:	66 48 0f 6e c2       	movq   %rdx,%xmm0
  40b165:	f3 0f 11 45 a4       	movss  %xmm0,-0x5c(%rbp)
  40b16a:	f3 0f 10 c8          	movss  %xmm0,%xmm1
  40b16e:	66 48 0f 6e c1       	movq   %rcx,%xmm0
  40b173:	0f 57 05 96 6e 02 00 	xorps  0x26e96(%rip),%xmm0        # 432010 <_IO_stdin_used+0x10>
  40b17a:	f3 0f 58 c1          	addss  %xmm1,%xmm0
  40b17e:	66 48 0f 7e c1       	movq   %xmm0,%rcx
  40b183:	89 c9                	mov    %ecx,%ecx
  40b185:	48 89 8d 30 f5 ff ff 	mov    %rcx,-0xad0(%rbp)
  40b18c:	4c 89 85 38 f5 ff ff 	mov    %r8,-0xac8(%rbp)
  40b193:	66 48 0f 6e c1       	movq   %rcx,%xmm0
  40b198:	f3 0f 5e c4          	divss  %xmm4,%xmm0
  40b19c:	48 89 c3             	mov    %rax,%rbx
  40b19f:	66 48 0f 7e c0       	movq   %xmm0,%rax
  40b1a4:	89 c0                	mov    %eax,%eax
  40b1a6:	48 89 85 30 ff ff ff 	mov    %rax,-0xd0(%rbp)
  40b1ad:	49 89 fc             	mov    %rdi,%r12
  40b1b0:	e8 6b b5 ff ff       	callq  406720 <p113d_FID_36_100_105_114_101_99_116_46_115_122_>
  40b1b5:	4c 89 e7             	mov    %r12,%rdi
  40b1b8:	48 89 c2             	mov    %rax,%rdx
  40b1bb:	48 89 d8             	mov    %rbx,%rax
  40b1be:	4c 8b 55 80          	mov    -0x80(%rbp),%r10
  40b1c2:	48 8b 75 a8          	mov    -0x58(%rbp),%rsi
  40b1c6:	48 8b 4d b0          	mov    -0x50(%rbp),%rcx
  40b1ca:	f3 0f 10 4d a4       	movss  -0x5c(%rbp),%xmm1
  40b1cf:	f3 0f 10 65 e8       	movss  -0x18(%rbp),%xmm4
  40b1d4:	f3 0f 10 45 b8       	movss  -0x48(%rbp),%xmm0
  40b1d9:	4c 8b 45 e0          	mov    -0x20(%rbp),%r8
  40b1dd:	4c 89 95 30 f5 ff ff 	mov    %r10,-0xad0(%rbp)
  40b1e4:	48 89 95 38 f5 ff ff 	mov    %rdx,-0xac8(%rbp)
  40b1eb:	f3 0f 10 d0          	movss  %xmm0,%xmm2
  40b1ef:	66 49 0f 6e c2       	movq   %r10,%xmm0
  40b1f4:	f3 0f 11 45 a0       	movss  %xmm0,-0x60(%rbp)
  40b1f9:	66 48 0f 6e da       	movq   %rdx,%xmm3
  40b1fe:	0f 57 1d 0b 6e 02 00 	xorps  0x26e0b(%rip),%xmm3        # 432010 <_IO_stdin_used+0x10>
  40b205:	f3 0f 58 d8          	addss  %xmm0,%xmm3
  40b209:	66 48 0f 7e da       	movq   %xmm3,%rdx
  40b20e:	89 d2                	mov    %edx,%edx
  40b210:	48 89 95 30 f5 ff ff 	mov    %rdx,-0xad0(%rbp)
  40b217:	4c 89 85 38 f5 ff ff 	mov    %r8,-0xac8(%rbp)
  40b21e:	66 48 0f 6e da       	movq   %rdx,%xmm3
  40b223:	f3 0f 5e dc          	divss  %xmm4,%xmm3
  40b227:	66 48 0f 7e da       	movq   %xmm3,%rdx
  40b22c:	89 d2                	mov    %edx,%edx
  40b22e:	48 89 95 38 ff ff ff 	mov    %rdx,-0xc8(%rbp)
  40b235:	48 c7 85 30 f5 ff ff 00 00 00 00 	movq   $0x0,-0xad0(%rbp)
  40b240:	48 c7 85 30 f5 ff ff 03 00 00 00 	movq   $0x3,-0xad0(%rbp)
  40b24b:	48 c7 85 30 f5 ff ff 00 00 00 00 	movq   $0x0,-0xad0(%rbp)
  40b256:	48 c7 85 38 f5 ff ff 00 00 40 40 	movq   $0x40400000,-0xac8(%rbp)
  40b261:	ba 00 00 40 c0       	mov    $0xc0400000,%edx
  40b266:	48 89 95 30 f5 ff ff 	mov    %rdx,-0xad0(%rbp)
  40b26d:	48 89 8d 38 f5 ff ff 	mov    %rcx,-0xac8(%rbp)
  40b274:	0f 57 15 95 6d 02 00 	xorps  0x26d95(%rip),%xmm2        # 432010 <_IO_stdin_used+0x10>
  40b27b:	f3 0f 58 15 ad 6d 02 00 	addss  0x26dad(%rip),%xmm2        # 432030 <_IO_stdin_used+0x30>
  40b283:	66 48 0f 7e d1       	movq   %xmm2,%rcx
  40b288:	41 89 c9             	mov    %ecx,%r9d
  40b28b:	4c 89 4d c0          	mov    %r9,-0x40(%rbp)
  40b28f:	48 c7 85 30 f5 ff ff 08 00 00 00 	movq   $0x8,-0xad0(%rbp)
  40b29a:	48 c7 85 30 f5 ff ff 00 00 00 41 	movq   $0x41000000,-0xad0(%rbp)
  40b2a5:	48 89 b5 38 f5 ff ff 	mov    %rsi,-0xac8(%rbp)
  40b2ac:	0f 57 0d 5d 6d 02 00 	xorps  0x26d5d(%rip),%xmm1        # 432010 <_IO_stdin_used+0x10>
  40b2b3:	f3 0f 58 0d 71 6d 02 00 	addss  0x26d71(%rip),%xmm1        # 43202c <_IO_stdin_used+0x2c>
  40b2bb:	66 48 0f 7e ca       	movq   %xmm1,%rdx
  40b2c0:	4c 89 d1             	mov    %r10,%rcx
  40b2c3:	41 89 d2             	mov    %edx,%r10d
  40b2c6:	4c 89 55 c8          	mov    %r10,-0x38(%rbp)
  40b2ca:	48 c7 85 30 f5 ff ff 01 00 00 00 	movq   $0x1,-0xad0(%rbp)
  40b2d5:	48 c7 85 30 f5 ff ff 00 00 80 3f 	movq   $0x3f800000,-0xad0(%rbp)
  40b2e0:	48 89 8d 38 f5 ff ff 	mov    %rcx,-0xac8(%rbp)
  40b2e7:	0f 57 05 22 6d 02 00 	xorps  0x26d22(%rip),%xmm0        # 432010 <_IO_stdin_used+0x10>
  40b2ee:	f3 0f 58 05 2a 6d 02 00 	addss  0x26d2a(%rip),%xmm0        # 432020 <_IO_stdin_used+0x20>
  40b2f6:	66 48 0f 7e c1       	movq   %xmm0,%rcx
  40b2fb:	41 89 cb             	mov    %ecx,%r11d
  40b2fe:	4c 89 5d d0          	mov    %r11,-0x30(%rbp)
  40b302:	4c 89 8d 30 f5 ff ff 	mov    %r9,-0xad0(%rbp)
  40b309:	4c 89 8d 38 f5 ff ff 	mov    %r9,-0xac8(%rbp)
  40b310:	66 49 0f 6e d9       	movq   %r9,%xmm3
  40b315:	f3 0f 11 5d bc       	movss  %xmm3,-0x44(%rbp)
  40b31a:	f3 0f 10 c3          	movss  %xmm3,%xmm0
  40b31e:	f3 0f 59 c3          	mulss  %xmm3,%xmm0
  40b322:	66 48 0f 7e c1       	movq   %xmm0,%rcx
  40b327:	89 ca                	mov    %ecx,%edx
  40b329:	4c 89 95 30 f5 ff ff 	mov    %r10,-0xad0(%rbp)
  40b330:	4c 89 95 38 f5 ff ff 	mov    %r10,-0xac8(%rbp)
  40b337:	66 49 0f 6e d2       	movq   %r10,%xmm2
  40b33c:	f3 0f 11 55 d8       	movss  %xmm2,-0x28(%rbp)
  40b341:	f3 0f 10 c2          	movss  %xmm2,%xmm0
  40b345:	f3 0f 59 c2          	mulss  %xmm2,%xmm0
  40b349:	66 48 0f 7e c1       	movq   %xmm0,%rcx
  40b34e:	89 c9                	mov    %ecx,%ecx
  40b350:	48 89 95 30 f5 ff ff 	mov    %rdx,-0xad0(%rbp)
  40b357:	48 89 8d 38 f5 ff ff 	mov    %rcx,-0xac8(%rbp)
  40b35e:	66 48 0f 6e c2       	movq   %rdx,%xmm0
  40b363:	66 48 0f 6e c9       	movq   %rcx,%xmm1
  40b368:	f3 0f 58 c1          	addss  %xmm1,%xmm0
  40b36c:	66 48 0f 7e c1       	movq   %xmm0,%rcx
  40b371:	89 ca                	mov    %ecx,%edx
  40b373:	4c 89 9d 30 f5 ff ff 	mov    %r11,-0xad0(%rbp)
  40b37a:	4c 89 9d 38 f5 ff ff 	mov    %r11,-0xac8(%rbp)
  40b381:	66 49 0f 6e c3       	movq   %r11,%xmm0
  40b386:	f3 0f 11 45 dc       	movss  %xmm0,-0x24(%rbp)
  40b38b:	f3 0f 59 c0          	mulss  %xmm0,%xmm0
  40b38f:	66 48 0f 7e c1       	movq   %xmm0,%rcx
  40b394:	89 c9                	mov    %ecx,%ecx
  40b396:	48 89 95 30 f5 ff ff 	mov    %rdx,-0xad0(%rbp)
  40b39d:	48 89 8d 38 f5 ff ff 	mov    %rcx,-0xac8(%rbp)
  40b3a4:	66 48 0f 6e c2       	movq   %rdx,%xmm0
  40b3a9:	66 48 0f 6e c9       	movq   %rcx,%xmm1
  40b3ae:	f3 0f 58 c1          	addss  %xmm1,%xmm0
  40b3b2:	48 89 c3             	mov    %rax,%rbx
  40b3b5:	66 48 0f 7e c0       	movq   %xmm0,%rax
  40b3ba:	89 c0                	mov    %eax,%eax
  40b3bc:	48 89 85 30 f5 ff ff 	mov    %rax,-0xad0(%rbp)
  40b3c3:	b9 01 00 00 00       	mov    $0x1,%ecx
  40b3c8:	48 8d 95 30 f5 ff ff 	lea    -0xad0(%rbp),%rdx
  40b3cf:	be 24 00 00 00       	mov    $0x24,%esi
  40b3d4:	49 89 fc             	mov    %rdi,%r12
  40b3d7:	e8 e4 14 02 00       	callq  42c8c0 <p111_rt_op>
  40b3dc:	4c 89 e7             	mov    %r12,%rdi
  40b3df:	48 89 c2             	mov    %rax,%rdx
  40b3e2:	48 89 d8             	mov    %rbx,%rax
  40b3e5:	4c 8b 5d d0          	mov    -0x30(%rbp),%r11
  40b3e9:	4c 8b 55 c8          	mov    -0x38(%rbp),%r10
  40b3ed:	4c 8b 4d c0          	mov    -0x40(%rbp),%r9
  40b3f1:	49 89 d0             	mov    %rdx,%r8
  40b3f4:	48 8b 95 38 ff ff ff 	mov    -0xc8(%rbp),%rdx
  40b3fb:	48 8b b5 30 ff ff ff 	mov    -0xd0(%rbp),%rsi
  40b402:	48 8b 8d 28 ff ff ff 	mov    -0xd8(%rbp),%rcx
  40b409:	f3 0f 10 45 dc       	movss  -0x24(%rbp),%xmm0
  40b40e:	f3 0f 10 55 d8       	movss  -0x28(%rbp),%xmm2
  40b413:	f3 0f 10 5d bc       	movss  -0x44(%rbp),%xmm3
  40b418:	4c 89 85 68 ff ff ff 	mov    %r8,-0x98(%rbp)
  40b41f:	4c 89 8d 30 f5 ff ff 	mov    %r9,-0xad0(%rbp)
  40b426:	4c 89 85 38 f5 ff ff 	mov    %r8,-0xac8(%rbp)
  40b42d:	66 49 0f 6e c8       	movq   %r8,%xmm1
  40b432:	f3 0f 5e d9          	divss  %xmm1,%xmm3
  40b436:	66 49 0f 7e d9       	movq   %xmm3,%r9
  40b43b:	45 89 c9             	mov    %r9d,%r9d
  40b43e:	4c 89 4d 88          	mov    %r9,-0x78(%rbp)
  40b442:	4c 89 95 30 f5 ff ff 	mov    %r10,-0xad0(%rbp)
  40b449:	4c 89 85 38 f5 ff ff 	mov    %r8,-0xac8(%rbp)
  40b450:	f3 0f 5e d1          	divss  %xmm1,%xmm2
  40b454:	49 89 ca             	mov    %rcx,%r10
  40b457:	66 48 0f 7e d1       	movq   %xmm2,%rcx
  40b45c:	89 c9                	mov    %ecx,%ecx
  40b45e:	48 89 4d 90          	mov    %rcx,-0x70(%rbp)
  40b462:	4c 89 9d 30 f5 ff ff 	mov    %r11,-0xad0(%rbp)
  40b469:	4c 89 85 38 f5 ff ff 	mov    %r8,-0xac8(%rbp)
  40b470:	f3 0f 5e c1          	divss  %xmm1,%xmm0
  40b474:	66 49 0f 7e c0       	movq   %xmm0,%r8
  40b479:	45 89 c0             	mov    %r8d,%r8d
  40b47c:	4c 89 45 98          	mov    %r8,-0x68(%rbp)
  40b480:	4c 89 95 30 f5 ff ff 	mov    %r10,-0xad0(%rbp)
  40b487:	4c 89 8d 38 f5 ff ff 	mov    %r9,-0xac8(%rbp)
  40b48e:	66 49 0f 6e da       	movq   %r10,%xmm3
  40b493:	f3 0f 11 9d cc fe ff ff 	movss  %xmm3,-0x134(%rbp)
  40b49b:	66 49 0f 6e c1       	movq   %r9,%xmm0
  40b4a0:	f3 0f 59 c3          	mulss  %xmm3,%xmm0
  40b4a4:	49 89 f1             	mov    %rsi,%r9
  40b4a7:	66 48 0f 7e c6       	movq   %xmm0,%rsi
  40b4ac:	89 f6                	mov    %esi,%esi
  40b4ae:	4c 89 8d 30 f5 ff ff 	mov    %r9,-0xad0(%rbp)
  40b4b5:	48 89 8d 38 f5 ff ff 	mov    %rcx,-0xac8(%rbp)
  40b4bc:	66 49 0f 6e d1       	movq   %r9,%xmm2
  40b4c1:	f3 0f 11 95 48 ff ff ff 	movss  %xmm2,-0xb8(%rbp)
  40b4c9:	66 48 0f 6e c1       	movq   %rcx,%xmm0
  40b4ce:	f3 0f 59 c2          	mulss  %xmm2,%xmm0
  40b4d2:	66 48 0f 7e c1       	movq   %xmm0,%rcx
  40b4d7:	89 c9                	mov    %ecx,%ecx
  40b4d9:	48 89 b5 30 f5 ff ff 	mov    %rsi,-0xad0(%rbp)
  40b4e0:	48 89 8d 38 f5 ff ff 	mov    %rcx,-0xac8(%rbp)
  40b4e7:	66 48 0f 6e c6       	movq   %rsi,%xmm0
  40b4ec:	66 48 0f 6e c9       	movq   %rcx,%xmm1
  40b4f1:	f3 0f 58 c1          	addss  %xmm1,%xmm0
  40b4f5:	66 48 0f 7e c1       	movq   %xmm0,%rcx
  40b4fa:	49 89 d3             	mov    %rdx,%r11
  40b4fd:	89 ca                	mov    %ecx,%edx
  40b4ff:	4c 89 9d 30 f5 ff ff 	mov    %r11,-0xad0(%rbp)
  40b506:	4c 89 85 38 f5 ff ff 	mov    %r8,-0xac8(%rbp)
  40b50d:	66 49 0f 6e c3       	movq   %r11,%xmm0
  40b512:	f3 0f 11 85 4c ff ff ff 	movss  %xmm0,-0xb4(%rbp)
  40b51a:	66 49 0f 6e c8       	movq   %r8,%xmm1
  40b51f:	f3 0f 59 c1          	mulss  %xmm1,%xmm0
  40b523:	66 48 0f 7e c1       	movq   %xmm0,%rcx
  40b528:	89 c9                	mov    %ecx,%ecx
  40b52a:	48 89 95 30 f5 ff ff 	mov    %rdx,-0xad0(%rbp)
  40b531:	48 89 8d 38 f5 ff ff 	mov    %rcx,-0xac8(%rbp)
  40b538:	66 48 0f 6e c2       	movq   %rdx,%xmm0
  40b53d:	66 48 0f 6e c9       	movq   %rcx,%xmm1
  40b542:	f3 0f 58 c1          	addss  %xmm1,%xmm0
  40b546:	48 89 c3             	mov    %rax,%rbx
  40b549:	66 48 0f 7e c0       	movq   %xmm0,%rax
  40b54e:	89 c6                	mov    %eax,%esi
  40b550:	49 89 fc             	mov    %rdi,%r12
  40b553:	e8 88 a7 ff ff       	callq  405ce0 <p113d_FID_36_100_105_114_101_99_116_46_102_109_97_120_48_>
  40b558:	4c 89 f2             	mov    %r14,%rdx
  40b55b:	4c 89 e7             	mov    %r12,%rdi
  40b55e:	48 89 85 70 ff ff ff 	mov    %rax,-0x90(%rbp)
  40b565:	49 89 d6             	mov    %rdx,%r14
  40b568:	ba e8 03 00 00       	mov    $0x3e8,%edx
  40b56d:	be 01 00 00 00       	mov    $0x1,%esi
  40b572:	49 89 fc             	mov    %rdi,%r12
  40b575:	e8 f6 a7 ff ff       	callq  405d70 <p113d_FID_36_100_105_114_101_99_116_46_102_108_>
  40b57a:	4c 89 f2             	mov    %r14,%rdx
  40b57d:	4c 89 e7             	mov    %r12,%rdi
  40b580:	48 89 c1             	mov    %rax,%rcx
  40b583:	48 89 d8             	mov    %rbx,%rax
  40b586:	4c 8b 85 28 ff ff ff 	mov    -0xd8(%rbp),%r8
  40b58d:	48 8b 75 b0          	mov    -0x50(%rbp),%rsi
  40b591:	f3 0f 10 9d cc fe ff ff 	movss  -0x134(%rbp),%xmm3
  40b599:	f3 0f 10 45 b8       	movss  -0x48(%rbp),%xmm0
  40b59e:	48 89 8d 30 f5 ff ff 	mov    %rcx,-0xad0(%rbp)
  40b5a5:	4c 89 85 38 f5 ff ff 	mov    %r8,-0xac8(%rbp)
  40b5ac:	66 48 0f 6e c9       	movq   %rcx,%xmm1
  40b5b1:	f3 0f 59 cb          	mulss  %xmm3,%xmm1
  40b5b5:	66 48 0f 7e c9       	movq   %xmm1,%rcx
  40b5ba:	89 c9                	mov    %ecx,%ecx
  40b5bc:	48 89 b5 30 f5 ff ff 	mov    %rsi,-0xad0(%rbp)
  40b5c3:	48 89 8d 38 f5 ff ff 	mov    %rcx,-0xac8(%rbp)
  40b5ca:	66 48 0f 6e c9       	movq   %rcx,%xmm1
  40b5cf:	f3 0f 58 c1          	addss  %xmm1,%xmm0
  40b5d3:	48 89 c3             	mov    %rax,%rbx
  40b5d6:	66 48 0f 7e c0       	movq   %xmm0,%rax
  40b5db:	41 89 c1             	mov    %eax,%r9d
  40b5de:	4c 89 8d 40 ff ff ff 	mov    %r9,-0xc0(%rbp)
  40b5e5:	49 89 d6             	mov    %rdx,%r14
  40b5e8:	ba e8 03 00 00       	mov    $0x3e8,%edx
  40b5ed:	be 01 00 00 00       	mov    $0x1,%esi
  40b5f2:	49 89 fc             	mov    %rdi,%r12
  40b5f5:	e8 76 a7 ff ff       	callq  405d70 <p113d_FID_36_100_105_114_101_99_116_46_102_108_>
  40b5fa:	4c 89 f2             	mov    %r14,%rdx
  40b5fd:	4c 89 e7             	mov    %r12,%rdi
  40b600:	48 89 c1             	mov    %rax,%rcx
  40b603:	48 89 d8             	mov    %rbx,%rax
  40b606:	48 8b b5 30 ff ff ff 	mov    -0xd0(%rbp),%rsi
  40b60d:	49 89 f0             	mov    %rsi,%r8
  40b610:	48 8b 75 a8          	mov    -0x58(%rbp),%rsi
  40b614:	f3 0f 10 95 48 ff ff ff 	movss  -0xb8(%rbp),%xmm2
  40b61c:	f3 0f 10 45 a4       	movss  -0x5c(%rbp),%xmm0
  40b621:	48 89 8d 30 f5 ff ff 	mov    %rcx,-0xad0(%rbp)
  40b628:	4c 89 85 38 f5 ff ff 	mov    %r8,-0xac8(%rbp)
  40b62f:	66 48 0f 6e c9       	movq   %rcx,%xmm1
  40b634:	f3 0f 59 ca          	mulss  %xmm2,%xmm1
  40b638:	66 48 0f 7e c9       	movq   %xmm1,%rcx
  40b63d:	89 c9                	mov    %ecx,%ecx
  40b63f:	48 89 b5 30 f5 ff ff 	mov    %rsi,-0xad0(%rbp)
  40b646:	48 89 8d 38 f5 ff ff 	mov    %rcx,-0xac8(%rbp)
  40b64d:	66 48 0f 6e c9       	movq   %rcx,%xmm1
  40b652:	f3 0f 58 c1          	addss  %xmm1,%xmm0
  40b656:	48 89 c3             	mov    %rax,%rbx
  40b659:	66 48 0f 7e c0       	movq   %xmm0,%rax
  40b65e:	89 c0                	mov    %eax,%eax
  40b660:	48 89 85 e0 fe ff ff 	mov    %rax,-0x120(%rbp)
  40b667:	49 89 d6             	mov    %rdx,%r14
  40b66a:	ba e8 03 00 00       	mov    $0x3e8,%edx
  40b66f:	be 01 00 00 00       	mov    $0x1,%esi
  40b674:	49 89 fc             	mov    %rdi,%r12
  40b677:	e8 f4 a6 ff ff       	callq  405d70 <p113d_FID_36_100_105_114_101_99_116_46_102_108_>
  40b67c:	4c 89 f2             	mov    %r14,%rdx
  40b67f:	4c 89 e7             	mov    %r12,%rdi
  40b682:	48 89 c6             	mov    %rax,%rsi
  40b685:	48 89 d8             	mov    %rbx,%rax
  40b688:	48 89 c3             	mov    %rax,%rbx
  40b68b:	48 8b 85 e0 fe ff ff 	mov    -0x120(%rbp),%rax
  40b692:	4c 8b 8d 40 ff ff ff 	mov    -0xc0(%rbp),%r9
  40b699:	4c 8b 45 98          	mov    -0x68(%rbp),%r8
  40b69d:	48 8b 4d 90          	mov    -0x70(%rbp),%rcx
  40b6a1:	4d 89 cc             	mov    %r9,%r12
  40b6a4:	4c 8b 4d 88          	mov    -0x78(%rbp),%r9
  40b6a8:	4c 8b 9d 38 ff ff ff 	mov    -0xc8(%rbp),%r11
  40b6af:	4c 8b 55 80          	mov    -0x80(%rbp),%r10
  40b6b3:	f3 0f 10 85 4c ff ff ff 	movss  -0xb4(%rbp),%xmm0
  40b6bb:	f3 0f 10 c8          	movss  %xmm0,%xmm1
  40b6bf:	f3 0f 10 45 a0       	movss  -0x60(%rbp),%xmm0
  40b6c4:	48 89 b5 30 f5 ff ff 	mov    %rsi,-0xad0(%rbp)
  40b6cb:	4c 89 9d 38 f5 ff ff 	mov    %r11,-0xac8(%rbp)
  40b6d2:	66 48 0f 6e d6       	movq   %rsi,%xmm2
  40b6d7:	f3 0f 59 ca          	mulss  %xmm2,%xmm1
  40b6db:	66 48 0f 7e ce       	movq   %xmm1,%rsi
  40b6e0:	89 f6                	mov    %esi,%esi
  40b6e2:	4c 89 95 30 f5 ff ff 	mov    %r10,-0xad0(%rbp)
  40b6e9:	48 89 b5 38 f5 ff ff 	mov    %rsi,-0xac8(%rbp)
  40b6f0:	66 48 0f 6e ce       	movq   %rsi,%xmm1
  40b6f5:	f3 0f 58 c1          	addss  %xmm1,%xmm0
  40b6f9:	66 48 0f 7e c6       	movq   %xmm0,%rsi
  40b6fe:	41 89 f3             	mov    %esi,%r11d
  40b701:	4c 89 9d e8 fe ff ff 	mov    %r11,-0x118(%rbp)
  40b708:	48 c7 85 30 f5 ff ff 00 ca 9a 3b 	movq   $0x3b9aca00,-0xad0(%rbp)
  40b713:	48 c7 85 30 f5 ff ff 00 ca 9a 3b 	movq   $0x3b9aca00,-0xad0(%rbp)
  40b71e:	48 83 ec 30          	sub    $0x30,%rsp
  40b722:	48 89 e6             	mov    %rsp,%rsi
  40b725:	48 c7 46 20 00 00 00 00 	movq   $0x0,0x20(%rsi)
  40b72d:	48 c7 46 18 28 6b 6e 4e 	movq   $0x4e6e6b28,0x18(%rsi)
  40b735:	48 c7 46 10 28 6b 6e 4e 	movq   $0x4e6e6b28,0x10(%rsi)
  40b73d:	4c 89 46 08          	mov    %r8,0x8(%rsi)
  40b741:	48 89 0e             	mov    %rcx,(%rsi)
  40b744:	4d 89 d8             	mov    %r11,%r8
  40b747:	48 89 c1             	mov    %rax,%rcx
  40b74a:	49 89 d6             	mov    %rdx,%r14
  40b74d:	4c 89 e2             	mov    %r12,%rdx
  40b750:	be 09 00 00 00       	mov    $0x9,%esi
  40b755:	49 89 fc             	mov    %rdi,%r12
  40b758:	e8 83 ba ff ff       	callq  4071e0 <p113d_FID_36_100_105_114_101_99_116_46_110_101_97_114_101_115_116_46_116_>
  40b75d:	4c 89 f2             	mov    %r14,%rdx
  40b760:	4c 89 e7             	mov    %r12,%rdi
  40b763:	48 89 85 78 ff ff ff 	mov    %rax,-0x88(%rbp)
  40b76a:	48 83 ec d0          	sub    $0xffffffffffffffd0,%rsp
  40b76e:	49 89 d6             	mov    %rdx,%r14
  40b771:	ba 0a 00 00 00       	mov    $0xa,%edx
  40b776:	be 01 00 00 00       	mov    $0x1,%esi
  40b77b:	49 89 fc             	mov    %rdi,%r12
  40b77e:	e8 ed a5 ff ff       	callq  405d70 <p113d_FID_36_100_105_114_101_99_116_46_102_108_>
  40b783:	4c 89 f2             	mov    %r14,%rdx
  40b786:	4c 89 e7             	mov    %r12,%rdi
  40b789:	48 89 85 58 ff ff ff 	mov    %rax,-0xa8(%rbp)
  40b790:	49 89 d6             	mov    %rdx,%r14
  40b793:	ba 64 00 00 00       	mov    $0x64,%edx
  40b798:	be 55 00 00 00       	mov    $0x55,%esi
  40b79d:	49 89 fc             	mov    %rdi,%r12
  40b7a0:	e8 cb a5 ff ff       	callq  405d70 <p113d_FID_36_100_105_114_101_99_116_46_102_108_>
  40b7a5:	4c 89 f2             	mov    %r14,%rdx
  40b7a8:	4c 89 e7             	mov    %r12,%rdi
  40b7ab:	48 89 85 60 ff ff ff 	mov    %rax,-0xa0(%rbp)
  40b7b2:	49 89 d6             	mov    %rdx,%r14
  40b7b5:	48 8b 95 68 ff ff ff 	mov    -0x98(%rbp),%rdx
  40b7bc:	48 8b b5 78 ff ff ff 	mov    -0x88(%rbp),%rsi
  40b7c3:	48 8b 8d 70 ff ff ff 	mov    -0x90(%rbp),%rcx
  40b7ca:	49 89 fc             	mov    %rdi,%r12
  40b7cd:	e8 fe ad ff ff       	callq  4065d0 <p113d_FID_36_100_105_114_101_99_116_46_115_104_97_100_101_>
  40b7d2:	4c 89 f2             	mov    %r14,%rdx
  40b7d5:	4c 89 e7             	mov    %r12,%rdi
  40b7d8:	48 89 c1             	mov    %rax,%rcx
  40b7db:	48 89 d8             	mov    %rbx,%rax
  40b7de:	4c 8b 85 60 ff ff ff 	mov    -0xa0(%rbp),%r8
  40b7e5:	49 89 d6             	mov    %rdx,%r14
  40b7e8:	48 8b 95 58 ff ff ff 	mov    -0xa8(%rbp),%rdx
  40b7ef:	48 8b b5 50 ff ff ff 	mov    -0xb0(%rbp),%rsi
  40b7f6:	4c 89 85 30 f5 ff ff 	mov    %r8,-0xad0(%rbp)
  40b7fd:	48 89 8d 38 f5 ff ff 	mov    %rcx,-0xac8(%rbp)
  40b804:	66 49 0f 6e c0       	movq   %r8,%xmm0
  40b809:	66 48 0f 6e c9       	movq   %rcx,%xmm1
  40b80e:	f3 0f 59 c1          	mulss  %xmm1,%xmm0
  40b812:	66 48 0f 7e c1       	movq   %xmm0,%rcx
  40b817:	89 c9                	mov    %ecx,%ecx
  40b819:	48 89 95 30 f5 ff ff 	mov    %rdx,-0xad0(%rbp)
  40b820:	48 89 8d 38 f5 ff ff 	mov    %rcx,-0xac8(%rbp)
  40b827:	66 48 0f 6e c2       	movq   %rdx,%xmm0
  40b82c:	66 48 0f 6e c9       	movq   %rcx,%xmm1
  40b831:	f3 0f 58 c1          	addss  %xmm1,%xmm0
  40b835:	48 89 c3             	mov    %rax,%rbx
  40b838:	66 48 0f 7e c0       	movq   %xmm0,%rax
  40b83d:	89 c1                	mov    %eax,%ecx
  40b83f:	48 89 8d f8 fe ff ff 	mov    %rcx,-0x108(%rbp)
  40b846:	49 89 fc             	mov    %rdi,%r12
  40b849:	e8 b2 ac ff ff       	callq  406500 <p113d_FID_36_100_105_114_101_99_116_46_115_107_114_>
  40b84e:	4d 89 f9             	mov    %r15,%r9
  40b851:	4c 89 f2             	mov    %r14,%rdx
  40b854:	4c 89 e7             	mov    %r12,%rdi
  40b857:	49 89 c7             	mov    %rax,%r15
  40b85a:	48 89 d8             	mov    %rbx,%rax
  40b85d:	49 89 c4             	mov    %rax,%r12
  40b860:	48 8b 85 e0 fe ff ff 	mov    -0x120(%rbp),%rax
  40b867:	4d 89 ca             	mov    %r9,%r10
  40b86a:	4c 8b 8d 40 ff ff ff 	mov    -0xc0(%rbp),%r9
  40b871:	49 89 d6             	mov    %rdx,%r14
  40b874:	48 8b 95 38 ff ff ff 	mov    -0xc8(%rbp),%rdx
  40b87b:	48 8b b5 30 ff ff ff 	mov    -0xd0(%rbp),%rsi
  40b882:	48 8b 8d 28 ff ff ff 	mov    -0xd8(%rbp),%rcx
  40b889:	f3 0f 10 85 4c ff ff ff 	movss  -0xb4(%rbp),%xmm0
  40b891:	f3 0f 10 95 48 ff ff ff 	movss  -0xb8(%rbp),%xmm2
  40b899:	f3 0f 10 9d cc fe ff ff 	movss  -0x134(%rbp),%xmm3
  40b8a1:	f3 0f 10 a5 bc fe ff ff 	movss  -0x144(%rbp),%xmm4
  40b8a9:	f3 0f 10 ad b8 fe ff ff 	movss  -0x148(%rbp),%xmm5
  40b8b1:	f3 0f 10 b5 ac fe ff ff 	movss  -0x154(%rbp),%xmm6
  40b8b9:	48 8b 9d b0 fe ff ff 	mov    -0x150(%rbp),%rbx
  40b8c0:	48 c7 85 30 f5 ff ff 02 00 00 00 	movq   $0x2,-0xad0(%rbp)
  40b8cb:	4c 89 95 30 f5 ff ff 	mov    %r10,-0xad0(%rbp)
  40b8d2:	48 89 8d 38 f5 ff ff 	mov    %rcx,-0xac8(%rbp)
  40b8d9:	f3 0f 10 ce          	movss  %xmm6,%xmm1
  40b8dd:	f3 0f 59 cb          	mulss  %xmm3,%xmm1
  40b8e1:	66 49 0f 7e c8       	movq   %xmm1,%r8
  40b8e6:	45 89 c3             	mov    %r8d,%r11d
  40b8e9:	4c 89 b5 30 f5 ff ff 	mov    %r14,-0xad0(%rbp)
  40b8f0:	48 89 b5 38 f5 ff ff 	mov    %rsi,-0xac8(%rbp)
  40b8f7:	f3 0f 10 cd          	movss  %xmm5,%xmm1
  40b8fb:	f3 0f 59 ca          	mulss  %xmm2,%xmm1
  40b8ff:	66 49 0f 7e c8       	movq   %xmm1,%r8
  40b904:	45 89 c0             	mov    %r8d,%r8d
  40b907:	4c 89 9d 30 f5 ff ff 	mov    %r11,-0xad0(%rbp)
  40b90e:	4c 89 85 38 f5 ff ff 	mov    %r8,-0xac8(%rbp)
  40b915:	66 49 0f 6e cb       	movq   %r11,%xmm1
  40b91a:	66 49 0f 6e f8       	movq   %r8,%xmm7
  40b91f:	f3 0f 58 cf          	addss  %xmm7,%xmm1
  40b923:	66 49 0f 7e c8       	movq   %xmm1,%r8
  40b928:	45 89 c0             	mov    %r8d,%r8d
  40b92b:	4c 89 85 20 ff ff ff 	mov    %r8,-0xe0(%rbp)
  40b932:	4c 89 ad 30 f5 ff ff 	mov    %r13,-0xad0(%rbp)
  40b939:	48 89 95 38 f5 ff ff 	mov    %rdx,-0xac8(%rbp)
  40b940:	f3 0f 10 cc          	movss  %xmm4,%xmm1
  40b944:	f3 0f 59 c8          	mulss  %xmm0,%xmm1
  40b948:	66 49 0f 7e c8       	movq   %xmm1,%r8
  40b94d:	45 89 c0             	mov    %r8d,%r8d
  40b950:	4c 89 85 18 ff ff ff 	mov    %r8,-0xe8(%rbp)
  40b957:	4c 8b 85 20 ff ff ff 	mov    -0xe0(%rbp),%r8
  40b95e:	4c 8b 9d e8 fe ff ff 	mov    -0x118(%rbp),%r11
  40b965:	4c 89 85 30 f5 ff ff 	mov    %r8,-0xad0(%rbp)
  40b96c:	4c 8b 85 18 ff ff ff 	mov    -0xe8(%rbp),%r8
  40b973:	4c 89 85 38 f5 ff ff 	mov    %r8,-0xac8(%rbp)
  40b97a:	4c 8b 85 20 ff ff ff 	mov    -0xe0(%rbp),%r8
  40b981:	66 49 0f 6e c8       	movq   %r8,%xmm1
  40b986:	4c 8b 85 18 ff ff ff 	mov    -0xe8(%rbp),%r8
  40b98d:	66 49 0f 6e f8       	movq   %r8,%xmm7
  40b992:	f3 0f 58 cf          	addss  %xmm7,%xmm1
  40b996:	66 49 0f 7e c8       	movq   %xmm1,%r8
  40b99b:	45 89 c0             	mov    %r8d,%r8d
  40b99e:	48 c7 85 30 f5 ff ff 00 00 00 40 	movq   $0x40000000,-0xad0(%rbp)
  40b9a9:	4c 89 85 38 f5 ff ff 	mov    %r8,-0xac8(%rbp)
  40b9b0:	66 49 0f 6e c8       	movq   %r8,%xmm1
  40b9b5:	f3 0f 59 0d 77 66 02 00 	mulss  0x26677(%rip),%xmm1        # 432034 <_IO_stdin_used+0x34>
  40b9bd:	66 49 0f 7e c8       	movq   %xmm1,%r8
  40b9c2:	45 89 c0             	mov    %r8d,%r8d
  40b9c5:	4c 89 85 30 f5 ff ff 	mov    %r8,-0xad0(%rbp)
  40b9cc:	48 89 8d 38 f5 ff ff 	mov    %rcx,-0xac8(%rbp)
  40b9d3:	66 49 0f 6e c8       	movq   %r8,%xmm1
  40b9d8:	f3 0f 59 d9          	mulss  %xmm1,%xmm3
  40b9dc:	66 48 0f 7e d9       	movq   %xmm3,%rcx
  40b9e1:	89 c9                	mov    %ecx,%ecx
  40b9e3:	4c 89 95 30 f5 ff ff 	mov    %r10,-0xad0(%rbp)
  40b9ea:	48 89 8d 38 f5 ff ff 	mov    %rcx,-0xac8(%rbp)
  40b9f1:	66 48 0f 6e d9       	movq   %rcx,%xmm3
  40b9f6:	0f 57 1d 13 66 02 00 	xorps  0x26613(%rip),%xmm3        # 432010 <_IO_stdin_used+0x10>
  40b9fd:	f3 0f 58 de          	addss  %xmm6,%xmm3
  40ba01:	66 48 0f 7e d9       	movq   %xmm3,%rcx
  40ba06:	89 c9                	mov    %ecx,%ecx
  40ba08:	48 89 8d 00 ff ff ff 	mov    %rcx,-0x100(%rbp)
  40ba0f:	4c 89 85 30 f5 ff ff 	mov    %r8,-0xad0(%rbp)
  40ba16:	48 89 b5 38 f5 ff ff 	mov    %rsi,-0xac8(%rbp)
  40ba1d:	f3 0f 59 d1          	mulss  %xmm1,%xmm2
  40ba21:	66 48 0f 7e d6       	movq   %xmm2,%rsi
  40ba26:	89 f6                	mov    %esi,%esi
  40ba28:	4c 89 b5 30 f5 ff ff 	mov    %r14,-0xad0(%rbp)
  40ba2f:	48 89 b5 38 f5 ff ff 	mov    %rsi,-0xac8(%rbp)
  40ba36:	66 48 0f 6e d6       	movq   %rsi,%xmm2
  40ba3b:	0f 57 15 ce 65 02 00 	xorps  0x265ce(%rip),%xmm2        # 432010 <_IO_stdin_used+0x10>
  40ba42:	f3 0f 58 d5          	addss  %xmm5,%xmm2
  40ba46:	66 48 0f 7e d6       	movq   %xmm2,%rsi
  40ba4b:	89 f6                	mov    %esi,%esi
  40ba4d:	48 89 b5 08 ff ff ff 	mov    %rsi,-0xf8(%rbp)
  40ba54:	4c 89 85 30 f5 ff ff 	mov    %r8,-0xad0(%rbp)
  40ba5b:	48 89 95 38 f5 ff ff 	mov    %rdx,-0xac8(%rbp)
  40ba62:	f3 0f 59 c1          	mulss  %xmm1,%xmm0
  40ba66:	66 48 0f 7e c2       	movq   %xmm0,%rdx
  40ba6b:	89 d2                	mov    %edx,%edx
  40ba6d:	4c 89 ad 30 f5 ff ff 	mov    %r13,-0xad0(%rbp)
  40ba74:	48 89 95 38 f5 ff ff 	mov    %rdx,-0xac8(%rbp)
  40ba7b:	66 48 0f 6e c2       	movq   %rdx,%xmm0
  40ba80:	0f 57 05 89 65 02 00 	xorps  0x26589(%rip),%xmm0        # 432010 <_IO_stdin_used+0x10>
  40ba87:	f3 0f 58 c4          	addss  %xmm4,%xmm0
  40ba8b:	66 48 0f 7e c2       	movq   %xmm0,%rdx
  40ba90:	41 89 d5             	mov    %edx,%r13d
  40ba93:	4c 89 ad 10 ff ff ff 	mov    %r13,-0xf0(%rbp)
  40ba9a:	48 c7 85 30 f5 ff ff 00 ca 9a 3b 	movq   $0x3b9aca00,-0xad0(%rbp)
  40baa5:	48 c7 85 30 f5 ff ff 00 ca 9a 3b 	movq   $0x3b9aca00,-0xad0(%rbp)
  40bab0:	48 83 ec 40          	sub    $0x40,%rsp
  40bab4:	48 89 e2             	mov    %rsp,%rdx
  40bab7:	48 c7 42 38 00 00 00 00 	movq   $0x0,0x38(%rdx)
  40babf:	48 c7 42 30 09 00 00 00 	movq   $0x9,0x30(%rdx)
  40bac7:	48 c7 42 28 28 6b 6e 4e 	movq   $0x4e6e6b28,0x28(%rdx)
  40bacf:	48 c7 42 20 09 00 00 00 	movq   $0x9,0x20(%rdx)
  40bad7:	48 c7 42 18 28 6b 6e 4e 	movq   $0x4e6e6b28,0x18(%rdx)
  40badf:	4c 89 6a 10          	mov    %r13,0x10(%rdx)
  40bae3:	48 89 72 08          	mov    %rsi,0x8(%rdx)
  40bae7:	48 89 0a             	mov    %rcx,(%rdx)
  40baea:	4d 89 ce             	mov    %r9,%r14
  40baed:	4d 89 d9             	mov    %r11,%r9
  40baf0:	49 89 c0             	mov    %rax,%r8
  40baf3:	4c 89 f1             	mov    %r14,%rcx
  40baf6:	ba 09 00 00 00       	mov    $0x9,%edx
  40bafb:	48 8d b5 30 fd ff ff 	lea    -0x2d0(%rbp),%rsi
  40bb02:	49 89 fd             	mov    %rdi,%r13
  40bb05:	e8 d6 af ff ff       	callq  406ae0 <p113d_FID_36_112_114_111_100_117_99_116_46_110_101_97_114_101_115_116_>
  40bb0a:	4d 89 f1             	mov    %r14,%r9
  40bb0d:	4c 89 ef             	mov    %r13,%rdi
  40bb10:	4c 89 e0             	mov    %r12,%rax
  40bb13:	4c 8b ad 10 ff ff ff 	mov    -0xf0(%rbp),%r13
  40bb1a:	4c 8b a5 08 ff ff ff 	mov    -0xf8(%rbp),%r12
  40bb21:	49 89 da             	mov    %rbx,%r10
  40bb24:	48 8b 9d 00 ff ff ff 	mov    -0x100(%rbp),%rbx
  40bb2b:	48 8b 8d f8 fe ff ff 	mov    -0x108(%rbp),%rcx
  40bb32:	4c 8b 9d e8 fe ff ff 	mov    -0x118(%rbp),%r11
  40bb39:	49 89 c0             	mov    %rax,%r8
  40bb3c:	48 8b 85 e0 fe ff ff 	mov    -0x120(%rbp),%rax
  40bb43:	f3 0f 10 8d 74 fd ff ff 	movss  -0x28c(%rbp),%xmm1
  40bb4b:	f3 0f 10 95 70 fd ff ff 	movss  -0x290(%rbp),%xmm2
  40bb53:	48 8b b5 f0 fe ff ff 	mov    -0x110(%rbp),%rsi
  40bb5a:	48 83 ec c0          	sub    $0xffffffffffffffc0,%rsp
  40bb5e:	48 8b 95 30 fd ff ff 	mov    -0x2d0(%rbp),%rdx
  40bb65:	4c 8b b5 38 fd ff ff 	mov    -0x2c8(%rbp),%r14
  40bb6c:	4c 89 b5 d8 fe ff ff 	mov    %r14,-0x128(%rbp)
  40bb73:	4c 8b b5 40 fd ff ff 	mov    -0x2c0(%rbp),%r14
  40bb7a:	4c 89 b5 d0 fe ff ff 	mov    %r14,-0x130(%rbp)
  40bb81:	4c 89 95 30 f5 ff ff 	mov    %r10,-0xad0(%rbp)
  40bb88:	48 89 8d 38 f5 ff ff 	mov    %rcx,-0xac8(%rbp)
  40bb8f:	66 48 0f 6e c1       	movq   %rcx,%xmm0
  40bb94:	f3 0f 59 c2          	mulss  %xmm2,%xmm0
  40bb98:	66 48 0f 7e c1       	movq   %xmm0,%rcx
  40bb9d:	89 c9                	mov    %ecx,%ecx
  40bb9f:	48 c7 85 30 f5 ff ff 01 00 00 00 	movq   $0x1,-0xad0(%rbp)
  40bbaa:	48 c7 85 30 f5 ff ff 00 00 80 3f 	movq   $0x3f800000,-0xad0(%rbp)
  40bbb5:	4c 89 bd 38 f5 ff ff 	mov    %r15,-0xac8(%rbp)
  40bbbc:	66 49 0f 6e c7       	movq   %r15,%xmm0
  40bbc1:	f3 0f 10 1d 57 64 02 00 	movss  0x26457(%rip),%xmm3        # 432020 <_IO_stdin_used+0x20>
  40bbc9:	f3 0f 5c d8          	subss  %xmm0,%xmm3
  40bbcd:	66 49 0f 7e de       	movq   %xmm3,%r14
  40bbd2:	45 89 f6             	mov    %r14d,%r14d
  40bbd5:	48 89 8d 30 f5 ff ff 	mov    %rcx,-0xad0(%rbp)
  40bbdc:	4c 89 b5 38 f5 ff ff 	mov    %r14,-0xac8(%rbp)
  40bbe3:	66 48 0f 6e d9       	movq   %rcx,%xmm3
  40bbe8:	48 8b 8d d8 fe ff ff 	mov    -0x128(%rbp),%rcx
  40bbef:	66 49 0f 6e e6       	movq   %r14,%xmm4
  40bbf4:	f3 0f 59 dc          	mulss  %xmm4,%xmm3
  40bbf8:	66 49 0f 7e de       	movq   %xmm3,%r14
  40bbfd:	45 89 f6             	mov    %r14d,%r14d
  40bc00:	4c 89 85 30 f5 ff ff 	mov    %r8,-0xad0(%rbp)
  40bc07:	4c 8b 85 d0 fe ff ff 	mov    -0x130(%rbp),%r8
  40bc0e:	4c 89 b5 38 f5 ff ff 	mov    %r14,-0xac8(%rbp)
  40bc15:	66 49 0f 6e de       	movq   %r14,%xmm3
  40bc1a:	f3 0f 58 cb          	addss  %xmm3,%xmm1
  40bc1e:	66 49 0f 7e ce       	movq   %xmm1,%r14
  40bc23:	45 89 f6             	mov    %r14d,%r14d
  40bc26:	4c 89 95 30 f5 ff ff 	mov    %r10,-0xad0(%rbp)
  40bc2d:	4c 89 bd 38 f5 ff ff 	mov    %r15,-0xac8(%rbp)
  40bc34:	f3 0f 59 c2          	mulss  %xmm2,%xmm0
  40bc38:	66 49 0f 7e c2       	movq   %xmm0,%r10
  40bc3d:	45 89 d7             	mov    %r10d,%r15d
  40bc40:	48 83 ee 01          	sub    $0x1,%rsi
  40bc44:	48 83 ec 40          	sub    $0x40,%rsp
  40bc48:	49 89 e2             	mov    %rsp,%r10
  40bc4b:	4d 89 7a 30          	mov    %r15,0x30(%r10)
  40bc4f:	4d 89 72 28          	mov    %r14,0x28(%r10)
  40bc53:	4d 89 6a 20          	mov    %r13,0x20(%r10)
  40bc57:	4d 89 62 18          	mov    %r12,0x18(%r10)
  40bc5b:	49 89 5a 10          	mov    %rbx,0x10(%r10)
  40bc5f:	4d 89 5a 08          	mov    %r11,0x8(%r10)
  40bc63:	49 89 02             	mov    %rax,(%r10)
  40bc66:	e8 55 bb ff ff       	callq  4077c0 <p113d_FID_36_112_114_111_100_117_99_116_46_116_114_97_99_101_>
  40bc6b:	48 83 ec c0          	sub    $0xffffffffffffffc0,%rsp
  40bc6f:	e9 89 0c 00 00       	jmpq   40c8fd <p113d_FID_36_100_105_114_101_99_116_46_116_114_97_99_101_+0x1b3d>
  40bc74:	48 89 d8             	mov    %rbx,%rax
  40bc77:	48 89 c3             	mov    %rax,%rbx
  40bc7a:	e9 7e 0c 00 00       	jmpq   40c8fd <p113d_FID_36_100_105_114_101_99_116_46_116_114_97_99_101_+0x1b3d>
  40bc7f:	4d 89 ec             	mov    %r13,%r12
  40bc82:	48 3d 97 00 00 00    	cmp    $0x97,%rax
  40bc88:	74 14                	je     40bc9e <p113d_FID_36_100_105_114_101_99_116_46_116_114_97_99_101_+0xede>
  40bc8a:	be 04 00 00 00       	mov    $0x4,%esi
  40bc8f:	e8 0c 0c 02 00       	callq  42c8a0 <p111_rt_fail>
  40bc94:	b8 00 00 00 00       	mov    $0x0,%eax
  40bc99:	e9 5f 0c 00 00       	jmpq   40c8fd <p113d_FID_36_100_105_114_101_99_116_46_116_114_97_99_101_+0x1b3d>
  40bc9e:	49 89 d6             	mov    %rdx,%r14
  40bca1:	48 8d 95 30 f5 ff ff 	lea    -0xad0(%rbp),%rdx
  40bca8:	49 89 fd             	mov    %rdi,%r13
  40bcab:	e8 70 5e 02 00       	callq  431b20 <p125_rt_take3>
  40bcb0:	4d 89 f9             	mov    %r15,%r9
  40bcb3:	4c 89 f2             	mov    %r14,%rdx
  40bcb6:	4c 89 ef             	mov    %r13,%rdi
  40bcb9:	48 89 d8             	mov    %rbx,%rax
  40bcbc:	f3 0f 10 9d c8 fe ff ff 	movss  -0x138(%rbp),%xmm3
  40bcc4:	f3 0f 10 a5 bc fe ff ff 	movss  -0x144(%rbp),%xmm4
  40bccc:	f3 0f 10 95 c4 fe ff ff 	movss  -0x13c(%rbp),%xmm2
  40bcd4:	f3 0f 10 ad b8 fe ff ff 	movss  -0x148(%rbp),%xmm5
  40bcdc:	f3 0f 10 8d c0 fe ff ff 	movss  -0x140(%rbp),%xmm1
  40bce4:	f3 0f 10 b5 ac fe ff ff 	movss  -0x154(%rbp),%xmm6
  40bcec:	48 8b 9d b0 fe ff ff 	mov    -0x150(%rbp),%rbx
  40bcf3:	4c 8b 85 30 f5 ff ff 	mov    -0xad0(%rbp),%r8
  40bcfa:	4c 8b ad 38 f5 ff ff 	mov    -0xac8(%rbp),%r13
  40bd01:	48 8b b5 40 f5 ff ff 	mov    -0xac0(%rbp),%rsi
  40bd08:	49 83 f8 01          	cmp    $0x1,%r8
  40bd0c:	0f 94 c1             	sete   %cl
  40bd0f:	0f b6 c9             	movzbl %cl,%ecx
  40bd12:	49 c1 e8 28          	shr    $0x28,%r8
  40bd16:	49 81 e0 ff ff 7f 00 	and    $0x7fffff,%r8
  40bd1d:	49 81 f8 02 00 01 00 	cmp    $0x10002,%r8
  40bd24:	41 0f 94 c0          	sete   %r8b
  40bd28:	45 0f b6 c0          	movzbl %r8b,%r8d
  40bd2c:	44 09 c1             	or     %r8d,%ecx
  40bd2f:	0f 85 c8 0b 00 00    	jne    40c8fd <p113d_FID_36_100_105_114_101_99_116_46_116_114_97_99_101_+0x1b3d>
  40bd35:	83 f1 01             	xor    $0x1,%ecx
  40bd38:	75 14                	jne    40bd4e <p113d_FID_36_100_105_114_101_99_116_46_116_114_97_99_101_+0xf8e>
  40bd3a:	be 04 00 00 00       	mov    $0x4,%esi
  40bd3f:	e8 5c 0b 02 00       	callq  42c8a0 <p111_rt_fail>
  40bd44:	b8 00 00 00 00       	mov    $0x0,%eax
  40bd49:	e9 af 0b 00 00       	jmpq   40c8fd <p113d_FID_36_100_105_114_101_99_116_46_116_114_97_99_101_+0x1b3d>
  40bd4e:	48 83 fe 00          	cmp    $0x0,%rsi
  40bd52:	0f 94 c1             	sete   %cl
  40bd55:	0f b6 c9             	movzbl %cl,%ecx
  40bd58:	89 8d a8 fe ff ff    	mov    %ecx,-0x158(%rbp)
  40bd5e:	49 89 f0             	mov    %rsi,%r8
  40bd61:	49 83 e8 01          	sub    $0x1,%r8
  40bd65:	49 89 f7             	mov    %rsi,%r15
  40bd68:	49 83 ef 02          	sub    $0x2,%r15
  40bd6c:	49 89 f6             	mov    %rsi,%r14
  40bd6f:	49 83 ee 03          	sub    $0x3,%r14
  40bd73:	49 89 f3             	mov    %rsi,%r11
  40bd76:	49 83 eb 04          	sub    $0x4,%r11
  40bd7a:	49 89 f2             	mov    %rsi,%r10
  40bd7d:	49 83 ea 05          	sub    $0x5,%r10
  40bd81:	4c 89 95 90 fe ff ff 	mov    %r10,-0x170(%rbp)
  40bd88:	48 89 f1             	mov    %rsi,%rcx
  40bd8b:	48 83 e9 06          	sub    $0x6,%rcx
  40bd8f:	48 89 8d 80 fe ff ff 	mov    %rcx,-0x180(%rbp)
  40bd96:	48 89 f1             	mov    %rsi,%rcx
  40bd99:	48 83 e9 07          	sub    $0x7,%rcx
  40bd9d:	48 89 8d 78 fe ff ff 	mov    %rcx,-0x188(%rbp)
  40bda4:	4c 89 d1             	mov    %r10,%rcx
  40bda7:	4c 8b 95 80 fe ff ff 	mov    -0x180(%rbp),%r10
  40bdae:	83 bd a8 fe ff ff 00 	cmpl   $0x0,-0x158(%rbp)
  40bdb5:	75 6e                	jne    40be25 <p113d_FID_36_100_105_114_101_99_116_46_116_114_97_99_101_+0x1065>
  40bdb7:	49 83 f8 00          	cmp    $0x0,%r8
  40bdbb:	74 61                	je     40be1e <p113d_FID_36_100_105_114_101_99_116_46_116_114_97_99_101_+0x105e>
  40bdbd:	0f 1f 00             	nopl   (%rax)
  40bdc0:	49 83 ff 00          	cmp    $0x0,%r15
  40bdc4:	74 51                	je     40be17 <p113d_FID_36_100_105_114_101_99_116_46_116_114_97_99_101_+0x1057>
  40bdc6:	49 83 fe 00          	cmp    $0x0,%r14
  40bdca:	74 44                	je     40be10 <p113d_FID_36_100_105_114_101_99_116_46_116_114_97_99_101_+0x1050>
  40bdcc:	49 83 fb 00          	cmp    $0x0,%r11
  40bdd0:	74 37                	je     40be09 <p113d_FID_36_100_105_114_101_99_116_46_116_114_97_99_101_+0x1049>
  40bdd2:	48 83 f9 00          	cmp    $0x0,%rcx
  40bdd6:	48 8b 8d 78 fe ff ff 	mov    -0x188(%rbp),%rcx
  40bddd:	74 23                	je     40be02 <p113d_FID_36_100_105_114_101_99_116_46_116_114_97_99_101_+0x1042>
  40bddf:	49 83 fa 00          	cmp    $0x0,%r10
  40bde3:	4c 8b 95 a0 fe ff ff 	mov    -0x160(%rbp),%r10
  40bdea:	74 0f                	je     40bdfb <p113d_FID_36_100_105_114_101_99_116_46_116_114_97_99_101_+0x103b>
  40bdec:	48 83 f9 00          	cmp    $0x0,%rcx
  40bdf0:	b9 00 00 80 3f       	mov    $0x3f800000,%ecx
  40bdf5:	49 0f 45 ca          	cmovne %r10,%rcx
  40bdf9:	eb 2f                	jmp    40be2a <p113d_FID_36_100_105_114_101_99_116_46_116_114_97_99_101_+0x106a>
  40bdfb:	b9 9a 99 99 3f       	mov    $0x3f99999a,%ecx
  40be00:	eb 28                	jmp    40be2a <p113d_FID_36_100_105_114_101_99_116_46_116_114_97_99_101_+0x106a>
  40be02:	b9 cd cc cc 3e       	mov    $0x3ecccccd,%ecx
  40be07:	eb 21                	jmp    40be2a <p113d_FID_36_100_105_114_101_99_116_46_116_114_97_99_101_+0x106a>
  40be09:	b9 cd cc cc 3e       	mov    $0x3ecccccd,%ecx
  40be0e:	eb 1a                	jmp    40be2a <p113d_FID_36_100_105_114_101_99_116_46_116_114_97_99_101_+0x106a>
  40be10:	b9 00 00 80 3f       	mov    $0x3f800000,%ecx
  40be15:	eb 13                	jmp    40be2a <p113d_FID_36_100_105_114_101_99_116_46_116_114_97_99_101_+0x106a>
  40be17:	b9 00 00 80 3f       	mov    $0x3f800000,%ecx
  40be1c:	eb 0c                	jmp    40be2a <p113d_FID_36_100_105_114_101_99_116_46_116_114_97_99_101_+0x106a>
  40be1e:	b9 00 00 80 3f       	mov    $0x3f800000,%ecx
  40be23:	eb 05                	jmp    40be2a <p113d_FID_36_100_105_114_101_99_116_46_116_114_97_99_101_+0x106a>
  40be25:	b9 00 40 1c 46       	mov    $0x461c4000,%ecx
  40be2a:	4c 89 ad 30 f5 ff ff 	mov    %r13,-0xad0(%rbp)
  40be31:	4c 89 8d 38 f5 ff ff 	mov    %r9,-0xac8(%rbp)
  40be38:	66 49 0f 6e c5       	movq   %r13,%xmm0
  40be3d:	f3 0f 59 f0          	mulss  %xmm0,%xmm6
  40be41:	66 49 0f 7e f1       	movq   %xmm6,%r9
  40be46:	45 89 c9             	mov    %r9d,%r9d
  40be49:	4c 89 8d 60 fe ff ff 	mov    %r9,-0x1a0(%rbp)
  40be50:	4c 8b 95 90 fe ff ff 	mov    -0x170(%rbp),%r10
  40be57:	4c 8b 8d 98 fe ff ff 	mov    -0x168(%rbp),%r9
  40be5e:	4c 89 8d 30 f5 ff ff 	mov    %r9,-0xad0(%rbp)
  40be65:	4c 8b 8d 60 fe ff ff 	mov    -0x1a0(%rbp),%r9
  40be6c:	4c 89 8d 38 f5 ff ff 	mov    %r9,-0xac8(%rbp)
  40be73:	4c 89 ad 30 f5 ff ff 	mov    %r13,-0xad0(%rbp)
  40be7a:	48 89 95 38 f5 ff ff 	mov    %rdx,-0xac8(%rbp)
  40be81:	f3 0f 59 e8          	mulss  %xmm0,%xmm5
  40be85:	66 48 0f 7e ea       	movq   %xmm5,%rdx
  40be8a:	89 d2                	mov    %edx,%edx
  40be8c:	48 89 95 50 fe ff ff 	mov    %rdx,-0x1b0(%rbp)
  40be93:	4c 8b 8d 80 fe ff ff 	mov    -0x180(%rbp),%r9
  40be9a:	48 8b 95 88 fe ff ff 	mov    -0x178(%rbp),%rdx
  40bea1:	48 89 95 30 f5 ff ff 	mov    %rdx,-0xad0(%rbp)
  40bea8:	48 8b 95 50 fe ff ff 	mov    -0x1b0(%rbp),%rdx
  40beaf:	48 89 95 38 f5 ff ff 	mov    %rdx,-0xac8(%rbp)
  40beb6:	48 8b 95 78 fe ff ff 	mov    -0x188(%rbp),%rdx
  40bebd:	4c 89 ad 30 f5 ff ff 	mov    %r13,-0xad0(%rbp)
  40bec4:	4c 89 a5 38 f5 ff ff 	mov    %r12,-0xac8(%rbp)
  40becb:	f3 0f 59 c4          	mulss  %xmm4,%xmm0
  40becf:	66 49 0f 7e c4       	movq   %xmm0,%r12
  40bed4:	45 89 e5             	mov    %r12d,%r13d
  40bed7:	4c 89 ad 30 fe ff ff 	mov    %r13,-0x1d0(%rbp)
  40bede:	4c 8b a5 60 fe ff ff 	mov    -0x1a0(%rbp),%r12
  40bee5:	4c 8b ad 70 fe ff ff 	mov    -0x190(%rbp),%r13
  40beec:	4c 89 ad 30 f5 ff ff 	mov    %r13,-0xad0(%rbp)
  40bef3:	4c 8b ad 30 fe ff ff 	mov    -0x1d0(%rbp),%r13
  40befa:	4c 89 ad 38 f5 ff ff 	mov    %r13,-0xac8(%rbp)
  40bf01:	4c 8b ad 68 fe ff ff 	mov    -0x198(%rbp),%r13
  40bf08:	48 83 fe 00          	cmp    $0x0,%rsi
  40bf0c:	74 71                	je     40bf7f <p113d_FID_36_100_105_114_101_99_116_46_116_114_97_99_101_+0x11bf>
  40bf0e:	49 83 f8 00          	cmp    $0x0,%r8
  40bf12:	74 63                	je     40bf77 <p113d_FID_36_100_105_114_101_99_116_46_116_114_97_99_101_+0x11b7>
  40bf14:	49 83 ff 00          	cmp    $0x0,%r15
  40bf18:	74 55                	je     40bf6f <p113d_FID_36_100_105_114_101_99_116_46_116_114_97_99_101_+0x11af>
  40bf1a:	66 0f 1f 44 00 00    	nopw   0x0(%rax,%rax,1)
  40bf20:	49 83 fe 00          	cmp    $0x0,%r14
  40bf24:	74 41                	je     40bf67 <p113d_FID_36_100_105_114_101_99_116_46_116_114_97_99_101_+0x11a7>
  40bf26:	49 83 fb 00          	cmp    $0x0,%r11
  40bf2a:	74 33                	je     40bf5f <p113d_FID_36_100_105_114_101_99_116_46_116_114_97_99_101_+0x119f>
  40bf2c:	49 83 fa 00          	cmp    $0x0,%r10
  40bf30:	74 25                	je     40bf57 <p113d_FID_36_100_105_114_101_99_116_46_116_114_97_99_101_+0x1197>
  40bf32:	49 83 f9 00          	cmp    $0x0,%r9
  40bf36:	74 17                	je     40bf4f <p113d_FID_36_100_105_114_101_99_116_46_116_114_97_99_101_+0x118f>
  40bf38:	48 83 fa 00          	cmp    $0x0,%rdx
  40bf3c:	41 bc 00 00 60 40    	mov    $0x40600000,%r12d
  40bf42:	4d 0f 44 ec          	cmove  %r12,%r13
  40bf46:	4c 8b a5 60 fe ff ff 	mov    -0x1a0(%rbp),%r12
  40bf4d:	eb 36                	jmp    40bf85 <p113d_FID_36_100_105_114_101_99_116_46_116_114_97_99_101_+0x11c5>
  40bf4f:	41 bd 00 00 00 00    	mov    $0x0,%r13d
  40bf55:	eb 2e                	jmp    40bf85 <p113d_FID_36_100_105_114_101_99_116_46_116_114_97_99_101_+0x11c5>
  40bf57:	41 bd 00 00 80 bf    	mov    $0xbf800000,%r13d
  40bf5d:	eb 26                	jmp    40bf85 <p113d_FID_36_100_105_114_101_99_116_46_116_114_97_99_101_+0x11c5>
  40bf5f:	41 bd 00 00 80 3f    	mov    $0x3f800000,%r13d
  40bf65:	eb 1e                	jmp    40bf85 <p113d_FID_36_100_105_114_101_99_116_46_116_114_97_99_101_+0x11c5>
  40bf67:	41 bd 00 00 00 c0    	mov    $0xc0000000,%r13d
  40bf6d:	eb 16                	jmp    40bf85 <p113d_FID_36_100_105_114_101_99_116_46_116_114_97_99_101_+0x11c5>
  40bf6f:	41 bd 00 00 00 40    	mov    $0x40000000,%r13d
  40bf75:	eb 0e                	jmp    40bf85 <p113d_FID_36_100_105_114_101_99_116_46_116_114_97_99_101_+0x11c5>
  40bf77:	41 bd 00 00 00 00    	mov    $0x0,%r13d
  40bf7d:	eb 06                	jmp    40bf85 <p113d_FID_36_100_105_114_101_99_116_46_116_114_97_99_101_+0x11c5>
  40bf7f:	41 bd 00 00 00 00    	mov    $0x0,%r13d
  40bf85:	66 49 0f 6e c4       	movq   %r12,%xmm0
  40bf8a:	f3 0f 58 c1          	addss  %xmm1,%xmm0
  40bf8e:	66 49 0f 7e c4       	movq   %xmm0,%r12
  40bf93:	45 89 e4             	mov    %r12d,%r12d
  40bf96:	4c 89 a5 48 fe ff ff 	mov    %r12,-0x1b8(%rbp)
  40bf9d:	4c 89 a5 30 f5 ff ff 	mov    %r12,-0xad0(%rbp)
  40bfa4:	4c 89 ad 38 f5 ff ff 	mov    %r13,-0xac8(%rbp)
  40bfab:	66 49 0f 6e c4       	movq   %r12,%xmm0
  40bfb0:	f3 0f 11 85 e8 fd ff ff 	movss  %xmm0,-0x218(%rbp)
  40bfb8:	66 49 0f 6e cd       	movq   %r13,%xmm1
  40bfbd:	0f 57 0d 4c 60 02 00 	xorps  0x2604c(%rip),%xmm1        # 432010 <_IO_stdin_used+0x10>
  40bfc4:	f3 0f 58 c8          	addss  %xmm0,%xmm1
  40bfc8:	66 49 0f 7e cd       	movq   %xmm1,%r13
  40bfcd:	45 89 ed             	mov    %r13d,%r13d
  40bfd0:	4c 89 ad 08 fe ff ff 	mov    %r13,-0x1f8(%rbp)
  40bfd7:	4c 89 ad 30 f5 ff ff 	mov    %r13,-0xad0(%rbp)
  40bfde:	4c 8b ad 50 fe ff ff 	mov    -0x1b0(%rbp),%r13
  40bfe5:	48 89 8d 38 f5 ff ff 	mov    %rcx,-0xac8(%rbp)
  40bfec:	48 83 fe 00          	cmp    $0x0,%rsi
  40bff0:	0f 84 9a 00 00 00    	je     40c090 <p113d_FID_36_100_105_114_101_99_116_46_116_114_97_99_101_+0x12d0>
  40bff6:	2e 2e 2e 4c 8b ad 58 fe ff ff 	cs cs mov %cs:-0x1a8(%rbp),%r13
  40c000:	49 83 f8 00          	cmp    $0x0,%r8
  40c004:	74 58                	je     40c05e <p113d_FID_36_100_105_114_101_99_116_46_116_114_97_99_101_+0x129e>
  40c006:	49 83 ff 00          	cmp    $0x0,%r15
  40c00a:	74 4a                	je     40c056 <p113d_FID_36_100_105_114_101_99_116_46_116_114_97_99_101_+0x1296>
  40c00c:	49 83 fe 00          	cmp    $0x0,%r14
  40c010:	74 3c                	je     40c04e <p113d_FID_36_100_105_114_101_99_116_46_116_114_97_99_101_+0x128e>
  40c012:	49 83 fb 00          	cmp    $0x0,%r11
  40c016:	74 2e                	je     40c046 <p113d_FID_36_100_105_114_101_99_116_46_116_114_97_99_101_+0x1286>
  40c018:	49 83 fa 00          	cmp    $0x0,%r10
  40c01c:	74 20                	je     40c03e <p113d_FID_36_100_105_114_101_99_116_46_116_114_97_99_101_+0x127e>
  40c01e:	66 90                	xchg   %ax,%ax
  40c020:	49 83 f9 00          	cmp    $0x0,%r9
  40c024:	74 10                	je     40c036 <p113d_FID_36_100_105_114_101_99_116_46_116_114_97_99_101_+0x1276>
  40c026:	48 83 fa 00          	cmp    $0x0,%rdx
  40c02a:	41 bc cd cc 4c 3e    	mov    $0x3e4ccccd,%r12d
  40c030:	4d 0f 45 e5          	cmovne %r13,%r12
  40c034:	eb 2e                	jmp    40c064 <p113d_FID_36_100_105_114_101_99_116_46_116_114_97_99_101_+0x12a4>
  40c036:	41 bc cd cc cc 3f    	mov    $0x3fcccccd,%r12d
  40c03c:	eb 26                	jmp    40c064 <p113d_FID_36_100_105_114_101_99_116_46_116_114_97_99_101_+0x12a4>
  40c03e:	41 bc 9a 99 19 bf    	mov    $0xbf19999a,%r12d
  40c044:	eb 1e                	jmp    40c064 <p113d_FID_36_100_105_114_101_99_116_46_116_114_97_99_101_+0x12a4>
  40c046:	41 bc 9a 99 19 bf    	mov    $0xbf19999a,%r12d
  40c04c:	eb 16                	jmp    40c064 <p113d_FID_36_100_105_114_101_99_116_46_116_114_97_99_101_+0x12a4>
  40c04e:	41 bc 00 00 00 3f    	mov    $0x3f000000,%r12d
  40c054:	eb 0e                	jmp    40c064 <p113d_FID_36_100_105_114_101_99_116_46_116_114_97_99_101_+0x12a4>
  40c056:	41 bc 00 00 00 3f    	mov    $0x3f000000,%r12d
  40c05c:	eb 06                	jmp    40c064 <p113d_FID_36_100_105_114_101_99_116_46_116_114_97_99_101_+0x12a4>
  40c05e:	41 bc 00 00 00 00    	mov    $0x0,%r12d
  40c064:	4d 89 e5             	mov    %r12,%r13
  40c067:	4c 89 ad 40 fe ff ff 	mov    %r13,-0x1c0(%rbp)
  40c06e:	4c 8b ad 50 fe ff ff 	mov    -0x1b0(%rbp),%r13
  40c075:	4c 8b a5 48 fe ff ff 	mov    -0x1b8(%rbp),%r12
  40c07c:	f2 44 0f 10 bd 40 fe ff ff 	movsd  -0x1c0(%rbp),%xmm15
  40c085:	f2 44 0f 11 bd 38 fe ff ff 	movsd  %xmm15,-0x1c8(%rbp)
  40c08e:	eb 14                	jmp    40c0a4 <p113d_FID_36_100_105_114_101_99_116_46_116_114_97_99_101_+0x12e4>
  40c090:	c7 85 38 fe ff ff 00 44 1c c6 	movl   $0xc61c4400,-0x1c8(%rbp)
  40c09a:	c7 85 3c fe ff ff 00 00 00 00 	movl   $0x0,-0x1c4(%rbp)
  40c0a4:	66 49 0f 6e cd       	movq   %r13,%xmm1
  40c0a9:	f3 0f 58 ca          	addss  %xmm2,%xmm1
  40c0ad:	66 49 0f 7e cd       	movq   %xmm1,%r13
  40c0b2:	45 89 ed             	mov    %r13d,%r13d
  40c0b5:	4c 89 ad d8 fd ff ff 	mov    %r13,-0x228(%rbp)
  40c0bc:	4c 89 ad 30 f5 ff ff 	mov    %r13,-0xad0(%rbp)
  40c0c3:	4c 8b ad 38 fe ff ff 	mov    -0x1c8(%rbp),%r13
  40c0ca:	4c 89 ad 38 f5 ff ff 	mov    %r13,-0xac8(%rbp)
  40c0d1:	4c 8b ad d8 fd ff ff 	mov    -0x228(%rbp),%r13
  40c0d8:	66 49 0f 6e cd       	movq   %r13,%xmm1
  40c0dd:	f3 0f 11 8d d0 fd ff ff 	movss  %xmm1,-0x230(%rbp)
  40c0e5:	4c 8b ad 38 fe ff ff 	mov    -0x1c8(%rbp),%r13
  40c0ec:	66 49 0f 6e d5       	movq   %r13,%xmm2
  40c0f1:	0f 57 15 18 5f 02 00 	xorps  0x25f18(%rip),%xmm2        # 432010 <_IO_stdin_used+0x10>
  40c0f8:	f3 0f 58 d1          	addss  %xmm1,%xmm2
  40c0fc:	66 49 0f 7e d5       	movq   %xmm2,%r13
  40c101:	45 89 ed             	mov    %r13d,%r13d
  40c104:	4c 89 ad 10 fe ff ff 	mov    %r13,-0x1f0(%rbp)
  40c10b:	4c 89 ad 30 f5 ff ff 	mov    %r13,-0xad0(%rbp)
  40c112:	4c 8b ad d8 fd ff ff 	mov    -0x228(%rbp),%r13
  40c119:	48 89 8d 38 f5 ff ff 	mov    %rcx,-0xac8(%rbp)
  40c120:	48 83 fe 00          	cmp    $0x0,%rsi
  40c124:	48 8b b5 30 fe ff ff 	mov    -0x1d0(%rbp),%rsi
  40c12b:	74 6a                	je     40c197 <p113d_FID_36_100_105_114_101_99_116_46_116_114_97_99_101_+0x13d7>
  40c12d:	49 83 f8 00          	cmp    $0x0,%r8
  40c131:	4c 8b 85 28 fe ff ff 	mov    -0x1d8(%rbp),%r8
  40c138:	74 56                	je     40c190 <p113d_FID_36_100_105_114_101_99_116_46_116_114_97_99_101_+0x13d0>
  40c13a:	66 0f 1f 44 00 00    	nopw   0x0(%rax,%rax,1)
  40c140:	49 83 ff 00          	cmp    $0x0,%r15
  40c144:	74 43                	je     40c189 <p113d_FID_36_100_105_114_101_99_116_46_116_114_97_99_101_+0x13c9>
  40c146:	49 83 fe 00          	cmp    $0x0,%r14
  40c14a:	74 36                	je     40c182 <p113d_FID_36_100_105_114_101_99_116_46_116_114_97_99_101_+0x13c2>
  40c14c:	49 83 fb 00          	cmp    $0x0,%r11
  40c150:	74 29                	je     40c17b <p113d_FID_36_100_105_114_101_99_116_46_116_114_97_99_101_+0x13bb>
  40c152:	49 83 fa 00          	cmp    $0x0,%r10
  40c156:	74 1c                	je     40c174 <p113d_FID_36_100_105_114_101_99_116_46_116_114_97_99_101_+0x13b4>
  40c158:	49 83 f9 00          	cmp    $0x0,%r9
  40c15c:	74 0f                	je     40c16d <p113d_FID_36_100_105_114_101_99_116_46_116_114_97_99_101_+0x13ad>
  40c15e:	48 83 fa 00          	cmp    $0x0,%rdx
  40c162:	ba 00 00 00 41       	mov    $0x41000000,%edx
  40c167:	49 0f 45 d0          	cmovne %r8,%rdx
  40c16b:	eb 2f                	jmp    40c19c <p113d_FID_36_100_105_114_101_99_116_46_116_114_97_99_101_+0x13dc>
  40c16d:	ba 00 00 e0 40       	mov    $0x40e00000,%edx
  40c172:	eb 28                	jmp    40c19c <p113d_FID_36_100_105_114_101_99_116_46_116_114_97_99_101_+0x13dc>
  40c174:	ba 00 00 60 40       	mov    $0x40600000,%edx
  40c179:	eb 21                	jmp    40c19c <p113d_FID_36_100_105_114_101_99_116_46_116_114_97_99_101_+0x13dc>
  40c17b:	ba 00 00 60 40       	mov    $0x40600000,%edx
  40c180:	eb 1a                	jmp    40c19c <p113d_FID_36_100_105_114_101_99_116_46_116_114_97_99_101_+0x13dc>
  40c182:	ba 00 00 c0 40       	mov    $0x40c00000,%edx
  40c187:	eb 13                	jmp    40c19c <p113d_FID_36_100_105_114_101_99_116_46_116_114_97_99_101_+0x13dc>
  40c189:	ba 00 00 c0 40       	mov    $0x40c00000,%edx
  40c18e:	eb 0c                	jmp    40c19c <p113d_FID_36_100_105_114_101_99_116_46_116_114_97_99_101_+0x13dc>
  40c190:	ba 00 00 a0 40       	mov    $0x40a00000,%edx
  40c195:	eb 05                	jmp    40c19c <p113d_FID_36_100_105_114_101_99_116_46_116_114_97_99_101_+0x13dc>
  40c197:	ba 00 00 a0 40       	mov    $0x40a00000,%edx
  40c19c:	66 48 0f 6e d6       	movq   %rsi,%xmm2
  40c1a1:	f3 0f 58 d3          	addss  %xmm3,%xmm2
  40c1a5:	66 48 0f 7e d6       	movq   %xmm2,%rsi
  40c1aa:	4d 89 ee             	mov    %r13,%r14
  40c1ad:	41 89 f5             	mov    %esi,%r13d
  40c1b0:	4c 89 ad c0 fd ff ff 	mov    %r13,-0x240(%rbp)
  40c1b7:	4c 89 ad 30 f5 ff ff 	mov    %r13,-0xad0(%rbp)
  40c1be:	48 89 95 38 f5 ff ff 	mov    %rdx,-0xac8(%rbp)
  40c1c5:	f3 0f 10 d0          	movss  %xmm0,%xmm2
  40c1c9:	66 49 0f 6e c5       	movq   %r13,%xmm0
  40c1ce:	f3 0f 11 85 b8 fd ff ff 	movss  %xmm0,-0x248(%rbp)
  40c1d6:	66 48 0f 6e da       	movq   %rdx,%xmm3
  40c1db:	0f 57 1d 2e 5e 02 00 	xorps  0x25e2e(%rip),%xmm3        # 432010 <_IO_stdin_used+0x10>
  40c1e2:	f3 0f 58 d8          	addss  %xmm0,%xmm3
  40c1e6:	66 48 0f 7e da       	movq   %xmm3,%rdx
  40c1eb:	89 d2                	mov    %edx,%edx
  40c1ed:	48 89 95 30 f5 ff ff 	mov    %rdx,-0xad0(%rbp)
  40c1f4:	48 89 8d 38 f5 ff ff 	mov    %rcx,-0xac8(%rbp)
  40c1fb:	66 48 0f 6e e2       	movq   %rdx,%xmm4
  40c200:	66 48 0f 6e d9       	movq   %rcx,%xmm3
  40c205:	f3 0f 11 9d 18 fe ff ff 	movss  %xmm3,-0x1e8(%rbp)
  40c20d:	f3 44 0f 10 fb       	movss  %xmm3,%xmm15
  40c212:	f3 0f 10 dc          	movss  %xmm4,%xmm3
  40c216:	f3 41 0f 5e df       	divss  %xmm15,%xmm3
  40c21b:	66 48 0f 7e d9       	movq   %xmm3,%rcx
  40c220:	41 89 c8             	mov    %ecx,%r8d
  40c223:	4c 89 85 88 fd ff ff 	mov    %r8,-0x278(%rbp)
  40c22a:	48 c7 85 30 f5 ff ff 00 00 00 00 	movq   $0x0,-0xad0(%rbp)
  40c235:	48 c7 85 30 f5 ff ff 03 00 00 00 	movq   $0x3,-0xad0(%rbp)
  40c240:	48 c7 85 30 f5 ff ff 00 00 00 00 	movq   $0x0,-0xad0(%rbp)
  40c24b:	48 c7 85 38 f5 ff ff 00 00 40 40 	movq   $0x40400000,-0xac8(%rbp)
  40c256:	b9 00 00 40 c0       	mov    $0xc0400000,%ecx
  40c25b:	48 89 8d 30 f5 ff ff 	mov    %rcx,-0xad0(%rbp)
  40c262:	4c 89 a5 38 f5 ff ff 	mov    %r12,-0xac8(%rbp)
  40c269:	0f 57 15 a0 5d 02 00 	xorps  0x25da0(%rip),%xmm2        # 432010 <_IO_stdin_used+0x10>
  40c270:	f3 0f 58 15 b8 5d 02 00 	addss  0x25db8(%rip),%xmm2        # 432030 <_IO_stdin_used+0x30>
  40c278:	66 48 0f 7e d1       	movq   %xmm2,%rcx
  40c27d:	41 89 c9             	mov    %ecx,%r9d
  40c280:	4c 89 8d f0 fd ff ff 	mov    %r9,-0x210(%rbp)
  40c287:	48 c7 85 30 f5 ff ff 08 00 00 00 	movq   $0x8,-0xad0(%rbp)
  40c292:	48 c7 85 30 f5 ff ff 00 00 00 41 	movq   $0x41000000,-0xad0(%rbp)
  40c29d:	4c 89 b5 38 f5 ff ff 	mov    %r14,-0xac8(%rbp)
  40c2a4:	0f 57 0d 65 5d 02 00 	xorps  0x25d65(%rip),%xmm1        # 432010 <_IO_stdin_used+0x10>
  40c2ab:	f3 0f 58 0d 79 5d 02 00 	addss  0x25d79(%rip),%xmm1        # 43202c <_IO_stdin_used+0x2c>
  40c2b3:	66 48 0f 7e c9       	movq   %xmm1,%rcx
  40c2b8:	89 ce                	mov    %ecx,%esi
  40c2ba:	48 89 b5 f8 fd ff ff 	mov    %rsi,-0x208(%rbp)
  40c2c1:	48 c7 85 30 f5 ff ff 01 00 00 00 	movq   $0x1,-0xad0(%rbp)
  40c2cc:	48 c7 85 30 f5 ff ff 00 00 80 3f 	movq   $0x3f800000,-0xad0(%rbp)
  40c2d7:	4c 89 ad 38 f5 ff ff 	mov    %r13,-0xac8(%rbp)
  40c2de:	0f 57 05 2b 5d 02 00 	xorps  0x25d2b(%rip),%xmm0        # 432010 <_IO_stdin_used+0x10>
  40c2e5:	f3 0f 58 05 33 5d 02 00 	addss  0x25d33(%rip),%xmm0        # 432020 <_IO_stdin_used+0x20>
  40c2ed:	66 48 0f 7e c1       	movq   %xmm0,%rcx
  40c2f2:	41 89 ca             	mov    %ecx,%r10d
  40c2f5:	4c 89 95 00 fe ff ff 	mov    %r10,-0x200(%rbp)
  40c2fc:	4c 89 8d 30 f5 ff ff 	mov    %r9,-0xad0(%rbp)
  40c303:	4c 89 8d 38 f5 ff ff 	mov    %r9,-0xac8(%rbp)
  40c30a:	66 49 0f 6e e9       	movq   %r9,%xmm5
  40c30f:	f3 0f 11 ad 1c fe ff ff 	movss  %xmm5,-0x1e4(%rbp)
  40c317:	f3 0f 10 c5          	movss  %xmm5,%xmm0
  40c31b:	f3 0f 59 c5          	mulss  %xmm5,%xmm0
  40c31f:	66 48 0f 7e c1       	movq   %xmm0,%rcx
  40c324:	89 ca                	mov    %ecx,%edx
  40c326:	48 89 b5 30 f5 ff ff 	mov    %rsi,-0xad0(%rbp)
  40c32d:	48 89 b5 38 f5 ff ff 	mov    %rsi,-0xac8(%rbp)
  40c334:	66 48 0f 6e e6       	movq   %rsi,%xmm4
  40c339:	f3 0f 11 a5 20 fe ff ff 	movss  %xmm4,-0x1e0(%rbp)
  40c341:	f3 0f 10 c4          	movss  %xmm4,%xmm0
  40c345:	f3 0f 59 c4          	mulss  %xmm4,%xmm0
  40c349:	66 48 0f 7e c1       	movq   %xmm0,%rcx
  40c34e:	89 c9                	mov    %ecx,%ecx
  40c350:	48 89 95 30 f5 ff ff 	mov    %rdx,-0xad0(%rbp)
  40c357:	48 89 8d 38 f5 ff ff 	mov    %rcx,-0xac8(%rbp)
  40c35e:	66 48 0f 6e c2       	movq   %rdx,%xmm0
  40c363:	66 48 0f 6e c9       	movq   %rcx,%xmm1
  40c368:	f3 0f 58 c1          	addss  %xmm1,%xmm0
  40c36c:	66 48 0f 7e c1       	movq   %xmm0,%rcx
  40c371:	89 ca                	mov    %ecx,%edx
  40c373:	4c 89 95 30 f5 ff ff 	mov    %r10,-0xad0(%rbp)
  40c37a:	4c 89 95 38 f5 ff ff 	mov    %r10,-0xac8(%rbp)
  40c381:	66 49 0f 6e ca       	movq   %r10,%xmm1
  40c386:	f3 0f 11 8d 24 fe ff ff 	movss  %xmm1,-0x1dc(%rbp)
  40c38e:	f3 0f 10 c1          	movss  %xmm1,%xmm0
  40c392:	f3 0f 59 c1          	mulss  %xmm1,%xmm0
  40c396:	66 48 0f 7e c1       	movq   %xmm0,%rcx
  40c39b:	89 c9                	mov    %ecx,%ecx
  40c39d:	48 89 95 30 f5 ff ff 	mov    %rdx,-0xad0(%rbp)
  40c3a4:	48 89 8d 38 f5 ff ff 	mov    %rcx,-0xac8(%rbp)
  40c3ab:	66 48 0f 6e c2       	movq   %rdx,%xmm0
  40c3b0:	66 48 0f 6e c9       	movq   %rcx,%xmm1
  40c3b5:	f3 0f 58 c1          	addss  %xmm1,%xmm0
  40c3b9:	49 89 c5             	mov    %rax,%r13
  40c3bc:	66 48 0f 7e c0       	movq   %xmm0,%rax
  40c3c1:	89 c0                	mov    %eax,%eax
  40c3c3:	48 89 85 30 f5 ff ff 	mov    %rax,-0xad0(%rbp)
  40c3ca:	b9 01 00 00 00       	mov    $0x1,%ecx
  40c3cf:	48 8d 95 30 f5 ff ff 	lea    -0xad0(%rbp),%rdx
  40c3d6:	be 24 00 00 00       	mov    $0x24,%esi
  40c3db:	49 89 ff             	mov    %rdi,%r15
  40c3de:	e8 dd 04 02 00       	callq  42c8c0 <p111_rt_op>
  40c3e3:	4c 89 ff             	mov    %r15,%rdi
  40c3e6:	48 89 c2             	mov    %rax,%rdx
  40c3e9:	4c 89 e8             	mov    %r13,%rax
  40c3ec:	4c 8b 95 00 fe ff ff 	mov    -0x200(%rbp),%r10
  40c3f3:	48 8b b5 f8 fd ff ff 	mov    -0x208(%rbp),%rsi
  40c3fa:	4c 8b 8d f0 fd ff ff 	mov    -0x210(%rbp),%r9
  40c401:	4c 8b 85 88 fd ff ff 	mov    -0x278(%rbp),%r8
  40c408:	4c 8b 9d 10 fe ff ff 	mov    -0x1f0(%rbp),%r11
  40c40f:	48 8b 8d 08 fe ff ff 	mov    -0x1f8(%rbp),%rcx
  40c416:	f3 0f 10 8d 24 fe ff ff 	movss  -0x1dc(%rbp),%xmm1
  40c41e:	f3 0f 10 a5 20 fe ff ff 	movss  -0x1e0(%rbp),%xmm4
  40c426:	f3 0f 10 ad 1c fe ff ff 	movss  -0x1e4(%rbp),%xmm5
  40c42e:	f3 0f 10 9d 18 fe ff ff 	movss  -0x1e8(%rbp),%xmm3
  40c436:	f3 0f 10 85 e8 fd ff ff 	movss  -0x218(%rbp),%xmm0
  40c43e:	4c 89 8d 30 f5 ff ff 	mov    %r9,-0xad0(%rbp)
  40c445:	48 89 95 38 f5 ff ff 	mov    %rdx,-0xac8(%rbp)
  40c44c:	66 48 0f 6e d2       	movq   %rdx,%xmm2
  40c451:	f3 0f 5e ea          	divss  %xmm2,%xmm5
  40c455:	66 49 0f 7e e9       	movq   %xmm5,%r9
  40c45a:	45 89 c9             	mov    %r9d,%r9d
  40c45d:	4c 89 8d 90 fd ff ff 	mov    %r9,-0x270(%rbp)
  40c464:	48 89 b5 30 f5 ff ff 	mov    %rsi,-0xad0(%rbp)
  40c46b:	48 89 95 38 f5 ff ff 	mov    %rdx,-0xac8(%rbp)
  40c472:	f3 0f 5e e2          	divss  %xmm2,%xmm4
  40c476:	66 48 0f 7e e6       	movq   %xmm4,%rsi
  40c47b:	89 f6                	mov    %esi,%esi
  40c47d:	48 89 b5 98 fd ff ff 	mov    %rsi,-0x268(%rbp)
  40c484:	4c 89 95 30 f5 ff ff 	mov    %r10,-0xad0(%rbp)
  40c48b:	48 89 95 38 f5 ff ff 	mov    %rdx,-0xac8(%rbp)
  40c492:	f3 0f 5e ca          	divss  %xmm2,%xmm1
  40c496:	66 49 0f 7e ca       	movq   %xmm1,%r10
  40c49b:	45 89 d2             	mov    %r10d,%r10d
  40c49e:	4c 89 95 a0 fd ff ff 	mov    %r10,-0x260(%rbp)
  40c4a5:	66 48 0f 6e c9       	movq   %rcx,%xmm1
  40c4aa:	f3 0f 5e cb          	divss  %xmm3,%xmm1
  40c4ae:	66 48 0f 7e c9       	movq   %xmm1,%rcx
  40c4b3:	89 c9                	mov    %ecx,%ecx
  40c4b5:	48 89 8d e0 fd ff ff 	mov    %rcx,-0x220(%rbp)
  40c4bc:	48 89 8d 30 f5 ff ff 	mov    %rcx,-0xad0(%rbp)
  40c4c3:	4c 89 8d 38 f5 ff ff 	mov    %r9,-0xac8(%rbp)
  40c4ca:	66 48 0f 6e c9       	movq   %rcx,%xmm1
  40c4cf:	f3 0f 11 8d ec fd ff ff 	movss  %xmm1,-0x214(%rbp)
  40c4d7:	66 49 0f 6e d1       	movq   %r9,%xmm2
  40c4dc:	f3 0f 59 d1          	mulss  %xmm1,%xmm2
  40c4e0:	66 49 0f 7e d1       	movq   %xmm2,%r9
  40c4e5:	45 89 c9             	mov    %r9d,%r9d
  40c4e8:	66 49 0f 6e d3       	movq   %r11,%xmm2
  40c4ed:	f3 0f 5e d3          	divss  %xmm3,%xmm2
  40c4f1:	66 49 0f 7e d3       	movq   %xmm2,%r11
  40c4f6:	45 89 db             	mov    %r11d,%r11d
  40c4f9:	4c 89 9d c8 fd ff ff 	mov    %r11,-0x238(%rbp)
  40c500:	4c 89 9d 30 f5 ff ff 	mov    %r11,-0xad0(%rbp)
  40c507:	48 89 b5 38 f5 ff ff 	mov    %rsi,-0xac8(%rbp)
  40c50e:	66 49 0f 6e d3       	movq   %r11,%xmm2
  40c513:	f3 0f 11 95 d4 fd ff ff 	movss  %xmm2,-0x22c(%rbp)
  40c51b:	66 48 0f 6e de       	movq   %rsi,%xmm3
  40c520:	f3 0f 59 d3          	mulss  %xmm3,%xmm2
  40c524:	66 48 0f 7e d6       	movq   %xmm2,%rsi
  40c529:	89 f6                	mov    %esi,%esi
  40c52b:	4c 89 8d 30 f5 ff ff 	mov    %r9,-0xad0(%rbp)
  40c532:	48 89 b5 38 f5 ff ff 	mov    %rsi,-0xac8(%rbp)
  40c539:	66 49 0f 6e d1       	movq   %r9,%xmm2
  40c53e:	66 48 0f 6e de       	movq   %rsi,%xmm3
  40c543:	f3 0f 58 d3          	addss  %xmm3,%xmm2
  40c547:	4c 89 c6             	mov    %r8,%rsi
  40c54a:	66 49 0f 7e d0       	movq   %xmm2,%r8
  40c54f:	45 89 c0             	mov    %r8d,%r8d
  40c552:	48 89 b5 30 f5 ff ff 	mov    %rsi,-0xad0(%rbp)
  40c559:	4c 89 95 38 f5 ff ff 	mov    %r10,-0xac8(%rbp)
  40c560:	66 48 0f 6e d6       	movq   %rsi,%xmm2
  40c565:	f3 0f 11 95 bc fd ff ff 	movss  %xmm2,-0x244(%rbp)
  40c56d:	66 49 0f 6e da       	movq   %r10,%xmm3
  40c572:	f3 0f 59 d3          	mulss  %xmm3,%xmm2
  40c576:	66 48 0f 7e d6       	movq   %xmm2,%rsi
  40c57b:	89 f6                	mov    %esi,%esi
  40c57d:	4c 89 85 30 f5 ff ff 	mov    %r8,-0xad0(%rbp)
  40c584:	48 89 b5 38 f5 ff ff 	mov    %rsi,-0xac8(%rbp)
  40c58b:	66 49 0f 6e d0       	movq   %r8,%xmm2
  40c590:	66 48 0f 6e de       	movq   %rsi,%xmm3
  40c595:	f3 0f 58 d3          	addss  %xmm3,%xmm2
  40c599:	66 48 0f 7e d6       	movq   %xmm2,%rsi
  40c59e:	89 f6                	mov    %esi,%esi
  40c5a0:	66 48 0f 6e d6       	movq   %rsi,%xmm2
  40c5a5:	f3 0f 10 1d 77 5a 02 00 	movss  0x25a77(%rip),%xmm3        # 432024 <_IO_stdin_used+0x24>
  40c5ad:	0f 2e da             	ucomiss %xmm2,%xmm3
  40c5b0:	41 0f 97 c0          	seta   %r8b
  40c5b4:	45 0f b6 c0          	movzbl %r8b,%r8d
  40c5b8:	45 89 c0             	mov    %r8d,%r8d
  40c5bb:	49 83 f8 01          	cmp    $0x1,%r8
  40c5bf:	49 89 c5             	mov    %rax,%r13
  40c5c2:	0f 94 c0             	sete   %al
  40c5c5:	0f b6 c0             	movzbl %al,%eax
  40c5c8:	49 c1 e8 28          	shr    $0x28,%r8
  40c5cc:	49 81 e0 ff ff 7f 00 	and    $0x7fffff,%r8
  40c5d3:	49 81 f8 02 00 01 00 	cmp    $0x10002,%r8
  40c5da:	49 89 d7             	mov    %rdx,%r15
  40c5dd:	0f 94 c2             	sete   %dl
  40c5e0:	0f b6 d2             	movzbl %dl,%edx
  40c5e3:	09 d0                	or     %edx,%eax
  40c5e5:	75 52                	jne    40c639 <p113d_FID_36_100_105_114_101_99_116_46_116_114_97_99_101_+0x1879>
  40c5e7:	83 f0 01             	xor    $0x1,%eax
  40c5ea:	75 3b                	jne    40c627 <p113d_FID_36_100_105_114_101_99_116_46_116_114_97_99_101_+0x1867>
  40c5ec:	be 04 00 00 00       	mov    $0x4,%esi
  40c5f1:	49 89 fe             	mov    %rdi,%r14
  40c5f4:	e8 a7 02 02 00       	callq  42c8a0 <p111_rt_fail>
  40c5f9:	4c 89 fa             	mov    %r15,%rdx
  40c5fc:	4c 89 f7             	mov    %r14,%rdi
  40c5ff:	4c 89 e8             	mov    %r13,%rax
  40c602:	48 8b 8d e0 fd ff ff 	mov    -0x220(%rbp),%rcx
  40c609:	4c 8b ad d8 fd ff ff 	mov    -0x228(%rbp),%r13
  40c610:	f3 0f 10 8d ec fd ff ff 	movss  -0x214(%rbp),%xmm1
  40c618:	f3 0f 10 85 e8 fd ff ff 	movss  -0x218(%rbp),%xmm0
  40c620:	be 00 00 00 00       	mov    $0x0,%esi
  40c625:	eb 09                	jmp    40c630 <p113d_FID_36_100_105_114_101_99_116_46_116_114_97_99_101_+0x1870>
  40c627:	4c 89 fa             	mov    %r15,%rdx
  40c62a:	4c 89 e8             	mov    %r13,%rax
  40c62d:	4d 89 f5             	mov    %r14,%r13
  40c630:	48 89 b5 78 fd ff ff 	mov    %rsi,-0x288(%rbp)
  40c637:	eb 14                	jmp    40c64d <p113d_FID_36_100_105_114_101_99_116_46_116_114_97_99_101_+0x188d>
  40c639:	4c 89 fa             	mov    %r15,%rdx
  40c63c:	4c 89 e8             	mov    %r13,%rax
  40c63f:	4d 89 f5             	mov    %r14,%r13
  40c642:	48 c7 85 78 fd ff ff 00 00 00 00 	movq   $0x0,-0x288(%rbp)
  40c64d:	48 c7 85 30 f5 ff ff 6f 12 83 3a 	movq   $0x3a83126f,-0xad0(%rbp)
  40c658:	48 89 8d 38 f5 ff ff 	mov    %rcx,-0xac8(%rbp)
  40c65f:	f3 0f 59 0d c1 59 02 00 	mulss  0x259c1(%rip),%xmm1        # 432028 <_IO_stdin_used+0x28>
  40c667:	66 48 0f 7e c9       	movq   %xmm1,%rcx
  40c66c:	89 c9                	mov    %ecx,%ecx
  40c66e:	4c 89 a5 30 f5 ff ff 	mov    %r12,-0xad0(%rbp)
  40c675:	48 89 8d 38 f5 ff ff 	mov    %rcx,-0xac8(%rbp)
  40c67c:	66 48 0f 6e c9       	movq   %rcx,%xmm1
  40c681:	f3 0f 58 c1          	addss  %xmm1,%xmm0
  40c685:	49 89 c4             	mov    %rax,%r12
  40c688:	66 48 0f 7e c0       	movq   %xmm0,%rax
  40c68d:	89 c0                	mov    %eax,%eax
  40c68f:	48 89 85 a8 fd ff ff 	mov    %rax,-0x258(%rbp)
  40c696:	49 89 d7             	mov    %rdx,%r15
  40c699:	ba e8 03 00 00       	mov    $0x3e8,%edx
  40c69e:	be 01 00 00 00       	mov    $0x1,%esi
  40c6a3:	49 89 fe             	mov    %rdi,%r14
  40c6a6:	e8 c5 96 ff ff       	callq  405d70 <p113d_FID_36_100_105_114_101_99_116_46_102_108_>
  40c6ab:	4c 89 fa             	mov    %r15,%rdx
  40c6ae:	4c 89 f7             	mov    %r14,%rdi
  40c6b1:	48 89 c1             	mov    %rax,%rcx
  40c6b4:	4c 89 e0             	mov    %r12,%rax
  40c6b7:	48 8b b5 c8 fd ff ff 	mov    -0x238(%rbp),%rsi
  40c6be:	4c 8b a5 c0 fd ff ff 	mov    -0x240(%rbp),%r12
  40c6c5:	f3 0f 10 8d d4 fd ff ff 	movss  -0x22c(%rbp),%xmm1
  40c6cd:	f3 0f 10 85 d0 fd ff ff 	movss  -0x230(%rbp),%xmm0
  40c6d5:	48 89 8d 30 f5 ff ff 	mov    %rcx,-0xad0(%rbp)
  40c6dc:	48 89 b5 38 f5 ff ff 	mov    %rsi,-0xac8(%rbp)
  40c6e3:	66 48 0f 6e d1       	movq   %rcx,%xmm2
  40c6e8:	f3 0f 59 ca          	mulss  %xmm2,%xmm1
  40c6ec:	66 48 0f 7e c9       	movq   %xmm1,%rcx
  40c6f1:	89 c9                	mov    %ecx,%ecx
  40c6f3:	4c 89 ad 30 f5 ff ff 	mov    %r13,-0xad0(%rbp)
  40c6fa:	48 89 8d 38 f5 ff ff 	mov    %rcx,-0xac8(%rbp)
  40c701:	66 48 0f 6e c9       	movq   %rcx,%xmm1
  40c706:	f3 0f 58 c1          	addss  %xmm1,%xmm0
  40c70a:	49 89 c5             	mov    %rax,%r13
  40c70d:	66 48 0f 7e c0       	movq   %xmm0,%rax
  40c712:	89 c1                	mov    %eax,%ecx
  40c714:	48 89 8d b0 fd ff ff 	mov    %rcx,-0x250(%rbp)
  40c71b:	49 89 d7             	mov    %rdx,%r15
  40c71e:	ba e8 03 00 00       	mov    $0x3e8,%edx
  40c723:	be 01 00 00 00       	mov    $0x1,%esi
  40c728:	49 89 fe             	mov    %rdi,%r14
  40c72b:	e8 40 96 ff ff       	callq  405d70 <p113d_FID_36_100_105_114_101_99_116_46_102_108_>
  40c730:	4c 89 fa             	mov    %r15,%rdx
  40c733:	4c 89 f7             	mov    %r14,%rdi
  40c736:	48 89 c6             	mov    %rax,%rsi
  40c739:	4c 89 e8             	mov    %r13,%rax
  40c73c:	48 8b 8d b0 fd ff ff 	mov    -0x250(%rbp),%rcx
  40c743:	49 89 d5             	mov    %rdx,%r13
  40c746:	48 8b 95 a8 fd ff ff 	mov    -0x258(%rbp),%rdx
  40c74d:	4c 8b 95 a0 fd ff ff 	mov    -0x260(%rbp),%r10
  40c754:	49 89 c6             	mov    %rax,%r14
  40c757:	48 8b 85 98 fd ff ff 	mov    -0x268(%rbp),%rax
  40c75e:	4c 8b 8d 90 fd ff ff 	mov    -0x270(%rbp),%r9
  40c765:	4c 8b 85 88 fd ff ff 	mov    -0x278(%rbp),%r8
  40c76c:	f3 0f 10 8d bc fd ff ff 	movss  -0x244(%rbp),%xmm1
  40c774:	f3 0f 10 85 b8 fd ff ff 	movss  -0x248(%rbp),%xmm0
  40c77c:	48 89 b5 30 f5 ff ff 	mov    %rsi,-0xad0(%rbp)
  40c783:	4c 89 85 38 f5 ff ff 	mov    %r8,-0xac8(%rbp)
  40c78a:	66 48 0f 6e d6       	movq   %rsi,%xmm2
  40c78f:	f3 0f 59 ca          	mulss  %xmm2,%xmm1
  40c793:	66 48 0f 7e ce       	movq   %xmm1,%rsi
  40c798:	89 f6                	mov    %esi,%esi
  40c79a:	4c 89 a5 30 f5 ff ff 	mov    %r12,-0xad0(%rbp)
  40c7a1:	48 89 b5 38 f5 ff ff 	mov    %rsi,-0xac8(%rbp)
  40c7a8:	66 48 0f 6e ce       	movq   %rsi,%xmm1
  40c7ad:	f3 0f 58 c1          	addss  %xmm1,%xmm0
  40c7b1:	66 48 0f 7e c6       	movq   %xmm0,%rsi
  40c7b6:	41 89 f0             	mov    %esi,%r8d
  40c7b9:	48 c7 85 30 f5 ff ff 00 ca 9a 3b 	movq   $0x3b9aca00,-0xad0(%rbp)
  40c7c4:	48 c7 85 30 f5 ff ff 00 ca 9a 3b 	movq   $0x3b9aca00,-0xad0(%rbp)
  40c7cf:	48 83 ec 30          	sub    $0x30,%rsp
  40c7d3:	48 89 e6             	mov    %rsp,%rsi
  40c7d6:	48 c7 46 20 00 00 00 00 	movq   $0x0,0x20(%rsi)
  40c7de:	48 c7 46 18 28 6b 6e 4e 	movq   $0x4e6e6b28,0x18(%rsi)
  40c7e6:	48 c7 46 10 28 6b 6e 4e 	movq   $0x4e6e6b28,0x10(%rsi)
  40c7ee:	4c 89 56 08          	mov    %r10,0x8(%rsi)
  40c7f2:	48 89 06             	mov    %rax,(%rsi)
  40c7f5:	be 09 00 00 00       	mov    $0x9,%esi
  40c7fa:	49 89 fc             	mov    %rdi,%r12
  40c7fd:	e8 de a9 ff ff       	callq  4071e0 <p113d_FID_36_100_105_114_101_99_116_46_110_101_97_114_101_115_116_46_116_>
  40c802:	4c 89 ea             	mov    %r13,%rdx
  40c805:	4c 89 e7             	mov    %r12,%rdi
  40c808:	48 89 85 80 fd ff ff 	mov    %rax,-0x280(%rbp)
  40c80f:	48 83 ec d0          	sub    $0xffffffffffffffd0,%rsp
  40c813:	49 89 d5             	mov    %rdx,%r13
  40c816:	ba 0a 00 00 00       	mov    $0xa,%edx
  40c81b:	be 01 00 00 00       	mov    $0x1,%esi
  40c820:	49 89 fc             	mov    %rdi,%r12
  40c823:	e8 48 95 ff ff       	callq  405d70 <p113d_FID_36_100_105_114_101_99_116_46_102_108_>
  40c828:	4c 89 ea             	mov    %r13,%rdx
  40c82b:	4c 89 e7             	mov    %r12,%rdi
  40c82e:	49 89 c4             	mov    %rax,%r12
  40c831:	49 89 d7             	mov    %rdx,%r15
  40c834:	ba 64 00 00 00       	mov    $0x64,%edx
  40c839:	be 55 00 00 00       	mov    $0x55,%esi
  40c83e:	49 89 fd             	mov    %rdi,%r13
  40c841:	e8 2a 95 ff ff       	callq  405d70 <p113d_FID_36_100_105_114_101_99_116_46_102_108_>
  40c846:	4c 89 fa             	mov    %r15,%rdx
  40c849:	4c 89 ef             	mov    %r13,%rdi
  40c84c:	49 89 c5             	mov    %rax,%r13
  40c84f:	48 8b 8d 78 fd ff ff 	mov    -0x288(%rbp),%rcx
  40c856:	48 8b b5 80 fd ff ff 	mov    -0x280(%rbp),%rsi
  40c85d:	e8 6e 9d ff ff       	callq  4065d0 <p113d_FID_36_100_105_114_101_99_116_46_115_104_97_100_101_>
  40c862:	48 89 c1             	mov    %rax,%rcx
  40c865:	4c 89 f0             	mov    %r14,%rax
  40c868:	f3 0f 10 8d 74 fd ff ff 	movss  -0x28c(%rbp),%xmm1
  40c870:	f3 0f 10 95 70 fd ff ff 	movss  -0x290(%rbp),%xmm2
  40c878:	4c 89 ad 30 f5 ff ff 	mov    %r13,-0xad0(%rbp)
  40c87f:	48 89 8d 38 f5 ff ff 	mov    %rcx,-0xac8(%rbp)
  40c886:	66 49 0f 6e c5       	movq   %r13,%xmm0
  40c88b:	66 48 0f 6e d9       	movq   %rcx,%xmm3
  40c890:	f3 0f 59 c3          	mulss  %xmm3,%xmm0
  40c894:	66 48 0f 7e c1       	movq   %xmm0,%rcx
  40c899:	89 c9                	mov    %ecx,%ecx
  40c89b:	4c 89 a5 30 f5 ff ff 	mov    %r12,-0xad0(%rbp)
  40c8a2:	48 89 8d 38 f5 ff ff 	mov    %rcx,-0xac8(%rbp)
  40c8a9:	66 49 0f 6e c4       	movq   %r12,%xmm0
  40c8ae:	66 48 0f 6e d9       	movq   %rcx,%xmm3
  40c8b3:	f3 0f 58 c3          	addss  %xmm3,%xmm0
  40c8b7:	66 48 0f 7e c1       	movq   %xmm0,%rcx
  40c8bc:	89 c9                	mov    %ecx,%ecx
  40c8be:	48 89 9d 30 f5 ff ff 	mov    %rbx,-0xad0(%rbp)
  40c8c5:	48 89 8d 38 f5 ff ff 	mov    %rcx,-0xac8(%rbp)
  40c8cc:	66 48 0f 6e c1       	movq   %rcx,%xmm0
  40c8d1:	f3 0f 59 c2          	mulss  %xmm2,%xmm0
  40c8d5:	48 89 c3             	mov    %rax,%rbx
  40c8d8:	66 48 0f 7e c0       	movq   %xmm0,%rax
  40c8dd:	89 c0                	mov    %eax,%eax
  40c8df:	48 89 9d 30 f5 ff ff 	mov    %rbx,-0xad0(%rbp)
  40c8e6:	48 89 85 38 f5 ff ff 	mov    %rax,-0xac8(%rbp)
  40c8ed:	66 48 0f 6e c0       	movq   %rax,%xmm0
  40c8f2:	f3 0f 58 c1          	addss  %xmm1,%xmm0
  40c8f6:	66 48 0f 7e c0       	movq   %xmm0,%rax
  40c8fb:	89 c0                	mov    %eax,%eax
  40c8fd:	41 5f                	pop    %r15
  40c8ff:	41 5e                	pop    %r14
  40c901:	41 5d                	pop    %r13
  40c903:	41 5c                	pop    %r12
  40c905:	5b                   	pop    %rbx
  40c906:	c9                   	leaveq 
  40c907:	c3                   	retq   
  40c908:	0f 1f 84 00 00 00 00 00 	nopl   0x0(%rax,%rax,1)

