0000000000406090 <p113d_FID_36_100_105_114_101_99_116_46_105_115_101_99_116_53_>:
  406090:	f3 0f 1e fa          	endbr64 
  406094:	55                   	push   %rbp
  406095:	48 89 e5             	mov    %rsp,%rbp
  406098:	53                   	push   %rbx
  406099:	41 54                	push   %r12
  40609b:	48 8b 45 30          	mov    0x30(%rbp),%rax
  40609f:	4c 8b 55 28          	mov    0x28(%rbp),%r10
  4060a3:	4c 8b 5d 20          	mov    0x20(%rbp),%r11
  4060a7:	48 8b 5d 18          	mov    0x18(%rbp),%rbx
  4060ab:	4c 8b 65 10          	mov    0x10(%rbp),%r12
  4060af:	4c 87 c2             	xchg   %r8,%rdx
  4060b2:	48 87 ce             	xchg   %rcx,%rsi
  4060b5:	4c 87 c9             	xchg   %r9,%rcx
  4060b8:	66 49 0f 6e c1       	movq   %r9,%xmm0
  4060bd:	66 49 0f 6e c8       	movq   %r8,%xmm1
  4060c2:	66 48 0f 6e d6       	movq   %rsi,%xmm2
  4060c7:	66 48 0f 6e da       	movq   %rdx,%xmm3
  4060cc:	66 48 0f 6e e1       	movq   %rcx,%xmm4
  4060d1:	66 49 0f 6e ec       	movq   %r12,%xmm5
  4060d6:	66 48 0f 6e f3       	movq   %rbx,%xmm6
  4060db:	66 49 0f 6e fb       	movq   %r11,%xmm7
  4060e0:	66 4d 0f 6e c2       	movq   %r10,%xmm8
  4060e5:	66 4c 0f 6e c8       	movq   %rax,%xmm9
  4060ea:	48 83 ec 10          	sub    $0x10,%rsp
  4060ee:	48 89 e0             	mov    %rsp,%rax
  4060f1:	66 44 0f d6 48 08    	movq   %xmm9,0x8(%rax)
  4060f7:	66 44 0f d6 00       	movq   %xmm8,(%rax)
  4060fc:	e8 0f 00 00 00       	callq  406110 <p126_typed_FID_36_100_105_114_101_99_116_46_105_115_101_99_116_53_>
  406101:	48 83 ec f0          	sub    $0xfffffffffffffff0,%rsp
  406105:	41 5c                	pop    %r12
  406107:	5b                   	pop    %rbx
  406108:	c9                   	leaveq 
  406109:	c3                   	retq   
  40610a:	66 0f 1f 44 00 00    	nopw   0x0(%rax,%rax,1)

