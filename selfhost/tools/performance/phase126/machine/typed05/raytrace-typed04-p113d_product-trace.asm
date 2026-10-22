0000000000407480 <p113d_FID_36_112_114_111_100_117_99_116_46_116_114_97_99_101_>:
  407480:	f3 0f 1e fa          	endbr64 
  407484:	55                   	push   %rbp
  407485:	48 89 e5             	mov    %rsp,%rbp
  407488:	53                   	push   %rbx
  407489:	41 54                	push   %r12
  40748b:	41 55                	push   %r13
  40748d:	41 56                	push   %r14
  40748f:	48 8b 45 40          	mov    0x40(%rbp),%rax
  407493:	4c 8b 75 38          	mov    0x38(%rbp),%r14
  407497:	4c 8b 55 30          	mov    0x30(%rbp),%r10
  40749b:	4c 8b 5d 28          	mov    0x28(%rbp),%r11
  40749f:	48 8b 5d 20          	mov    0x20(%rbp),%rbx
  4074a3:	4c 8b 65 18          	mov    0x18(%rbp),%r12
  4074a7:	4c 8b 6d 10          	mov    0x10(%rbp),%r13
  4074ab:	4c 87 c1             	xchg   %r8,%rcx
  4074ae:	4d 87 f0             	xchg   %r14,%r8
  4074b1:	66 49 0f 6e c6       	movq   %r14,%xmm0
  4074b6:	66 49 0f 6e c9       	movq   %r9,%xmm1
  4074bb:	66 49 0f 6e d5       	movq   %r13,%xmm2
  4074c0:	66 49 0f 6e dc       	movq   %r12,%xmm3
  4074c5:	66 48 0f 6e e3       	movq   %rbx,%xmm4
  4074ca:	66 49 0f 6e eb       	movq   %r11,%xmm5
  4074cf:	66 49 0f 6e f2       	movq   %r10,%xmm6
  4074d4:	66 48 0f 6e f8       	movq   %rax,%xmm7
  4074d9:	e8 12 00 00 00       	callq  4074f0 <p126_typed_FID_36_112_114_111_100_117_99_116_46_116_114_97_99_101_>
  4074de:	41 5e                	pop    %r14
  4074e0:	41 5d                	pop    %r13
  4074e2:	41 5c                	pop    %r12
  4074e4:	5b                   	pop    %rbx
  4074e5:	c9                   	leaveq 
  4074e6:	c3                   	retq   
  4074e7:	66 0f 1f 84 00 00 00 00 00 	nopw   0x0(%rax,%rax,1)

