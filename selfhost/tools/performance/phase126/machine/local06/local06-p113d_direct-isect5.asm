0000000000406020 <p113d_FID_36_100_105_114_101_99_116_46_105_115_101_99_116_53_>:
  406020:	f3 0f 1e fa          	endbr64 
  406024:	55                   	push   %rbp
  406025:	48 89 e5             	mov    %rsp,%rbp
  406028:	48 83 ec 18          	sub    $0x18,%rsp
  40602c:	53                   	push   %rbx
  40602d:	41 54                	push   %r12
  40602f:	41 55                	push   %r13
  406031:	4c 8b 55 30          	mov    0x30(%rbp),%r10
  406035:	4c 8b 5d 28          	mov    0x28(%rbp),%r11
  406039:	48 8b 5d 20          	mov    0x20(%rbp),%rbx
  40603d:	4c 8b 65 18          	mov    0x18(%rbp),%r12
  406041:	4c 8b 6d 10          	mov    0x10(%rbp),%r13
  406045:	4c 89 c0             	mov    %r8,%rax
  406048:	4d 89 c8             	mov    %r9,%r8
  40604b:	66 49 0f 6e c0       	movq   %r8,%xmm0
  406050:	66 48 0f 6e ce       	movq   %rsi,%xmm1
  406055:	f3 0f 10 d0          	movss  %xmm0,%xmm2
  406059:	f3 0f 5c d1          	subss  %xmm1,%xmm2
  40605d:	66 49 0f 6e c5       	movq   %r13,%xmm0
  406062:	66 48 0f 6e ca       	movq   %rdx,%xmm1
  406067:	f3 0f 10 e0          	movss  %xmm0,%xmm4
  40606b:	f3 0f 5c e1          	subss  %xmm1,%xmm4
  40606f:	66 49 0f 6e c4       	movq   %r12,%xmm0
  406074:	66 48 0f 6e c9       	movq   %rcx,%xmm1
  406079:	f3 0f 10 d8          	movss  %xmm0,%xmm3
  40607d:	f3 0f 5c d9          	subss  %xmm1,%xmm3
  406081:	66 48 0f 6e c3       	movq   %rbx,%xmm0
  406086:	f3 0f 59 c2          	mulss  %xmm2,%xmm0
  40608a:	66 49 0f 6e cb       	movq   %r11,%xmm1
  40608f:	f3 0f 59 cc          	mulss  %xmm4,%xmm1
  406093:	f3 0f 58 c1          	addss  %xmm1,%xmm0
  406097:	66 49 0f 6e ca       	movq   %r10,%xmm1
  40609c:	f3 0f 59 cb          	mulss  %xmm3,%xmm1
  4060a0:	f3 0f 58 c8          	addss  %xmm0,%xmm1
  4060a4:	f3 0f 10 c1          	movss  %xmm1,%xmm0
  4060a8:	f3 0f 59 c1          	mulss  %xmm1,%xmm0
  4060ac:	f3 0f 59 d2          	mulss  %xmm2,%xmm2
  4060b0:	f3 0f 59 e4          	mulss  %xmm4,%xmm4
  4060b4:	f3 0f 58 d4          	addss  %xmm4,%xmm2
  4060b8:	f3 0f 59 db          	mulss  %xmm3,%xmm3
  4060bc:	f3 0f 58 d3          	addss  %xmm3,%xmm2
  4060c0:	66 48 0f 6e d8       	movq   %rax,%xmm3
  4060c5:	f3 0f 59 db          	mulss  %xmm3,%xmm3
  4060c9:	f3 0f 5c d3          	subss  %xmm3,%xmm2
  4060cd:	f3 0f 5c c2          	subss  %xmm2,%xmm0
  4060d1:	f3 0f 10 15 4b af 02 00 	movss  0x2af4b(%rip),%xmm2        # 431024 <_IO_stdin_used+0x24>
  4060d9:	0f 2e d0             	ucomiss %xmm0,%xmm2
  4060dc:	0f 97 c0             	seta   %al
  4060df:	0f b6 c0             	movzbl %al,%eax
  4060e2:	89 c1                	mov    %eax,%ecx
  4060e4:	48 83 f9 01          	cmp    $0x1,%rcx
  4060e8:	0f 94 c0             	sete   %al
  4060eb:	0f b6 c0             	movzbl %al,%eax
  4060ee:	48 c1 e9 28          	shr    $0x28,%rcx
  4060f2:	48 81 e1 ff ff 7f 00 	and    $0x7fffff,%rcx
  4060f9:	48 81 f9 02 00 01 00 	cmp    $0x10002,%rcx
  406100:	0f 94 c1             	sete   %cl
  406103:	0f b6 c9             	movzbl %cl,%ecx
  406106:	09 c8                	or     %ecx,%eax
  406108:	0f 85 af 00 00 00    	jne    4061bd <p113d_FID_36_100_105_114_101_99_116_46_105_115_101_99_116_53_+0x19d>
  40610e:	83 f0 01             	xor    $0x1,%eax
  406111:	75 17                	jne    40612a <p113d_FID_36_100_105_114_101_99_116_46_105_115_101_99_116_53_+0x10a>
  406113:	be 04 00 00 00       	mov    $0x4,%esi
  406118:	48 89 fb             	mov    %rdi,%rbx
  40611b:	e8 80 4e 02 00       	callq  42afa0 <p111_rt_fail>
  406120:	b8 00 00 00 00       	mov    $0x0,%eax
  406125:	e9 98 00 00 00       	jmpq   4061c2 <p113d_FID_36_100_105_114_101_99_116_46_105_115_101_99_116_53_+0x1a2>
  40612a:	48 89 fb             	mov    %rdi,%rbx
  40612d:	0f 57 0d dc ae 02 00 	xorps  0x2aedc(%rip),%xmm1        # 431010 <_IO_stdin_used+0x10>
  406134:	f3 0f 58 0d e8 ae 02 00 	addss  0x2aee8(%rip),%xmm1        # 431024 <_IO_stdin_used+0x24>
  40613c:	f3 0f 11 4d f0       	movss  %xmm1,-0x10(%rbp)
  406141:	f3 0f 5a c0          	cvtss2sd %xmm0,%xmm0
  406145:	e8 76 c3 ff ff       	callq  4024c0 <sqrt@plt>
  40614a:	48 89 df             	mov    %rbx,%rdi
  40614d:	f2 0f 10 c8          	movsd  %xmm0,%xmm1
  406151:	f3 0f 10 45 f0       	movss  -0x10(%rbp),%xmm0
  406156:	f2 0f 5a c9          	cvtsd2ss %xmm1,%xmm1
  40615a:	f3 0f 5c c1          	subss  %xmm1,%xmm0
  40615e:	f3 0f 10 0d c2 ae 02 00 	movss  0x2aec2(%rip),%xmm1        # 431028 <_IO_stdin_used+0x28>
  406166:	0f 2e c8             	ucomiss %xmm0,%xmm1
  406169:	0f 97 c0             	seta   %al
  40616c:	0f b6 c0             	movzbl %al,%eax
  40616f:	89 c1                	mov    %eax,%ecx
  406171:	48 83 f9 01          	cmp    $0x1,%rcx
  406175:	0f 94 c0             	sete   %al
  406178:	0f b6 c0             	movzbl %al,%eax
  40617b:	48 c1 e9 28          	shr    $0x28,%rcx
  40617f:	48 81 e1 ff ff 7f 00 	and    $0x7fffff,%rcx
  406186:	48 81 f9 02 00 01 00 	cmp    $0x10002,%rcx
  40618d:	0f 94 c1             	sete   %cl
  406190:	0f b6 c9             	movzbl %cl,%ecx
  406193:	09 c8                	or     %ecx,%eax
  406195:	75 1f                	jne    4061b6 <p113d_FID_36_100_105_114_101_99_116_46_105_115_101_99_116_53_+0x196>
  406197:	83 f0 01             	xor    $0x1,%eax
  40619a:	75 11                	jne    4061ad <p113d_FID_36_100_105_114_101_99_116_46_105_115_101_99_116_53_+0x18d>
  40619c:	be 04 00 00 00       	mov    $0x4,%esi
  4061a1:	e8 fa 4d 02 00       	callq  42afa0 <p111_rt_fail>
  4061a6:	b8 00 00 00 00       	mov    $0x0,%eax
  4061ab:	eb 15                	jmp    4061c2 <p113d_FID_36_100_105_114_101_99_116_46_105_115_101_99_116_53_+0x1a2>
  4061ad:	66 48 0f 7e c0       	movq   %xmm0,%rax
  4061b2:	89 c0                	mov    %eax,%eax
  4061b4:	eb 0c                	jmp    4061c2 <p113d_FID_36_100_105_114_101_99_116_46_105_115_101_99_116_53_+0x1a2>
  4061b6:	b8 28 6b 6e 4e       	mov    $0x4e6e6b28,%eax
  4061bb:	eb 05                	jmp    4061c2 <p113d_FID_36_100_105_114_101_99_116_46_105_115_101_99_116_53_+0x1a2>
  4061bd:	b8 28 6b 6e 4e       	mov    $0x4e6e6b28,%eax
  4061c2:	41 5d                	pop    %r13
  4061c4:	41 5c                	pop    %r12
  4061c6:	5b                   	pop    %rbx
  4061c7:	c9                   	leaveq 
  4061c8:	c3                   	retq   
  4061c9:	0f 1f 80 00 00 00 00 	nopl   0x0(%rax)

