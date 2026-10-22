0000000000406780 <p113d_FID_36_112_114_111_100_117_99_116_46_110_101_97_114_101_115_116_>:
  406780:	f3 0f 1e fa          	endbr64 
  406784:	55                   	push   %rbp
  406785:	48 89 e5             	mov    %rsp,%rbp
  406788:	48 83 ec 08          	sub    $0x8,%rsp
  40678c:	53                   	push   %rbx
  40678d:	41 54                	push   %r12
  40678f:	41 55                	push   %r13
  406791:	41 56                	push   %r14
  406793:	41 57                	push   %r15
  406795:	4c 8b 5d 48          	mov    0x48(%rbp),%r11
  406799:	48 8b 45 40          	mov    0x40(%rbp),%rax
  40679d:	4c 8b 6d 38          	mov    0x38(%rbp),%r13
  4067a1:	4c 8b 75 30          	mov    0x30(%rbp),%r14
  4067a5:	4c 8b 7d 28          	mov    0x28(%rbp),%r15
  4067a9:	4c 8b 55 20          	mov    0x20(%rbp),%r10
  4067ad:	48 8b 5d 18          	mov    0x18(%rbp),%rbx
  4067b1:	4c 8b 65 10          	mov    0x10(%rbp),%r12
  4067b5:	4d 87 cd             	xchg   %r9,%r13
  4067b8:	4d 87 c6             	xchg   %r8,%r14
  4067bb:	49 87 cf             	xchg   %rcx,%r15
  4067be:	66 49 0f 6e c7       	movq   %r15,%xmm0
  4067c3:	66 49 0f 6e ce       	movq   %r14,%xmm1
  4067c8:	66 49 0f 6e d5       	movq   %r13,%xmm2
  4067cd:	66 49 0f 6e dc       	movq   %r12,%xmm3
  4067d2:	66 48 0f 6e e3       	movq   %rbx,%xmm4
  4067d7:	66 49 0f 6e ea       	movq   %r10,%xmm5
  4067dc:	48 83 ec 10          	sub    $0x10,%rsp
  4067e0:	49 89 e2             	mov    %rsp,%r10
  4067e3:	4d 89 5a 08          	mov    %r11,0x8(%r10)
  4067e7:	49 89 02             	mov    %rax,(%r10)
  4067ea:	e8 11 00 00 00       	callq  406800 <p126_typed_FID_36_112_114_111_100_117_99_116_46_110_101_97_114_101_115_116_>
  4067ef:	48 83 ec f0          	sub    $0xfffffffffffffff0,%rsp
  4067f3:	41 5f                	pop    %r15
  4067f5:	41 5e                	pop    %r14
  4067f7:	41 5d                	pop    %r13
  4067f9:	41 5c                	pop    %r12
  4067fb:	5b                   	pop    %rbx
  4067fc:	c9                   	leaveq 
  4067fd:	c3                   	retq   
  4067fe:	66 90                	xchg   %ax,%ax

