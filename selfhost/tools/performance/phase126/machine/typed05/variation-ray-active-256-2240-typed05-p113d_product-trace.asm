0000000000407340 <p113d_FID_36_112_114_111_100_117_99_116_46_116_114_97_99_101_>:
  407340:	f3 0f 1e fa          	endbr64 
  407344:	55                   	push   %rbp
  407345:	48 89 e5             	mov    %rsp,%rbp
  407348:	53                   	push   %rbx
  407349:	41 54                	push   %r12
  40734b:	41 55                	push   %r13
  40734d:	41 56                	push   %r14
  40734f:	48 8b 45 40          	mov    0x40(%rbp),%rax
  407353:	4c 8b 75 38          	mov    0x38(%rbp),%r14
  407357:	4c 8b 55 30          	mov    0x30(%rbp),%r10
  40735b:	4c 8b 5d 28          	mov    0x28(%rbp),%r11
  40735f:	48 8b 5d 20          	mov    0x20(%rbp),%rbx
  407363:	4c 8b 65 18          	mov    0x18(%rbp),%r12
  407367:	4c 8b 6d 10          	mov    0x10(%rbp),%r13
  40736b:	4c 87 c1             	xchg   %r8,%rcx
  40736e:	4d 87 f0             	xchg   %r14,%r8
  407371:	66 49 0f 6e c6       	movq   %r14,%xmm0
  407376:	66 49 0f 6e c9       	movq   %r9,%xmm1
  40737b:	66 49 0f 6e d5       	movq   %r13,%xmm2
  407380:	66 49 0f 6e dc       	movq   %r12,%xmm3
  407385:	66 48 0f 6e e3       	movq   %rbx,%xmm4
  40738a:	66 49 0f 6e eb       	movq   %r11,%xmm5
  40738f:	66 49 0f 6e f2       	movq   %r10,%xmm6
  407394:	66 48 0f 6e f8       	movq   %rax,%xmm7
  407399:	e8 12 00 00 00       	callq  4073b0 <p126_typed_FID_36_112_114_111_100_117_99_116_46_116_114_97_99_101_>
  40739e:	41 5e                	pop    %r14
  4073a0:	41 5d                	pop    %r13
  4073a2:	41 5c                	pop    %r12
  4073a4:	5b                   	pop    %rbx
  4073a5:	c9                   	leaveq 
  4073a6:	c3                   	retq   
  4073a7:	66 0f 1f 84 00 00 00 00 00 	nopw   0x0(%rax,%rax,1)

