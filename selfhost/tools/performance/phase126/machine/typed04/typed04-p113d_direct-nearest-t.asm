0000000000406e90 <p113d_FID_36_100_105_114_101_99_116_46_110_101_97_114_101_115_116_46_116_>:
  406e90:	f3 0f 1e fa          	endbr64 
  406e94:	55                   	push   %rbp
  406e95:	48 89 e5             	mov    %rsp,%rbp
  406e98:	53                   	push   %rbx
  406e99:	41 54                	push   %r12
  406e9b:	4c 8b 5d 30          	mov    0x30(%rbp),%r11
  406e9f:	48 8b 5d 28          	mov    0x28(%rbp),%rbx
  406ea3:	4c 8b 65 20          	mov    0x20(%rbp),%r12
  406ea7:	48 8b 45 18          	mov    0x18(%rbp),%rax
  406eab:	4c 8b 55 10          	mov    0x10(%rbp),%r10
  406eaf:	4d 87 c3             	xchg   %r8,%r11
  406eb2:	48 87 cb             	xchg   %rcx,%rbx
  406eb5:	49 87 d4             	xchg   %rdx,%r12
  406eb8:	66 49 0f 6e c4       	movq   %r12,%xmm0
  406ebd:	66 48 0f 6e cb       	movq   %rbx,%xmm1
  406ec2:	66 49 0f 6e d3       	movq   %r11,%xmm2
  406ec7:	66 49 0f 6e d9       	movq   %r9,%xmm3
  406ecc:	66 49 0f 6e e2       	movq   %r10,%xmm4
  406ed1:	66 48 0f 6e e8       	movq   %rax,%xmm5
  406ed6:	e8 05 00 00 00       	callq  406ee0 <p126_typed_FID_36_100_105_114_101_99_116_46_110_101_97_114_101_115_116_46_116_>
  406edb:	41 5c                	pop    %r12
  406edd:	5b                   	pop    %rbx
  406ede:	c9                   	leaveq 
  406edf:	c3                   	retq   

