0000000000406db0 <p113d_FID_36_100_105_114_101_99_116_46_110_101_97_114_101_115_116_46_116_>:
  406db0:	f3 0f 1e fa          	endbr64 
  406db4:	55                   	push   %rbp
  406db5:	48 89 e5             	mov    %rsp,%rbp
  406db8:	53                   	push   %rbx
  406db9:	41 54                	push   %r12
  406dbb:	4c 8b 5d 30          	mov    0x30(%rbp),%r11
  406dbf:	48 8b 5d 28          	mov    0x28(%rbp),%rbx
  406dc3:	4c 8b 65 20          	mov    0x20(%rbp),%r12
  406dc7:	48 8b 45 18          	mov    0x18(%rbp),%rax
  406dcb:	4c 8b 55 10          	mov    0x10(%rbp),%r10
  406dcf:	4d 87 c3             	xchg   %r8,%r11
  406dd2:	48 87 cb             	xchg   %rcx,%rbx
  406dd5:	49 87 d4             	xchg   %rdx,%r12
  406dd8:	66 49 0f 6e c4       	movq   %r12,%xmm0
  406ddd:	66 48 0f 6e cb       	movq   %rbx,%xmm1
  406de2:	66 49 0f 6e d3       	movq   %r11,%xmm2
  406de7:	66 49 0f 6e d9       	movq   %r9,%xmm3
  406dec:	66 49 0f 6e e2       	movq   %r10,%xmm4
  406df1:	66 48 0f 6e e8       	movq   %rax,%xmm5
  406df6:	e8 05 00 00 00       	callq  406e00 <p126_typed_FID_36_100_105_114_101_99_116_46_110_101_97_114_101_115_116_46_116_>
  406dfb:	41 5c                	pop    %r12
  406dfd:	5b                   	pop    %rbx
  406dfe:	c9                   	leaveq 
  406dff:	c3                   	retq   

