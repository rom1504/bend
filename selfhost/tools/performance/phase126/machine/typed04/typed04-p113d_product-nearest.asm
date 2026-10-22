00000000004067c0 <p113d_FID_36_112_114_111_100_117_99_116_46_110_101_97_114_101_115_116_>:
  4067c0:	f3 0f 1e fa          	endbr64 
  4067c4:	55                   	push   %rbp
  4067c5:	48 89 e5             	mov    %rsp,%rbp
  4067c8:	48 83 ec 08          	sub    $0x8,%rsp
  4067cc:	53                   	push   %rbx
  4067cd:	41 54                	push   %r12
  4067cf:	41 55                	push   %r13
  4067d1:	41 56                	push   %r14
  4067d3:	41 57                	push   %r15
  4067d5:	4c 8b 5d 48          	mov    0x48(%rbp),%r11
  4067d9:	48 8b 45 40          	mov    0x40(%rbp),%rax
  4067dd:	4c 8b 6d 38          	mov    0x38(%rbp),%r13
  4067e1:	4c 8b 75 30          	mov    0x30(%rbp),%r14
  4067e5:	4c 8b 7d 28          	mov    0x28(%rbp),%r15
  4067e9:	4c 8b 55 20          	mov    0x20(%rbp),%r10
  4067ed:	48 8b 5d 18          	mov    0x18(%rbp),%rbx
  4067f1:	4c 8b 65 10          	mov    0x10(%rbp),%r12
  4067f5:	4d 87 cd             	xchg   %r9,%r13
  4067f8:	4d 87 c6             	xchg   %r8,%r14
  4067fb:	49 87 cf             	xchg   %rcx,%r15
  4067fe:	66 49 0f 6e c7       	movq   %r15,%xmm0
  406803:	66 49 0f 6e ce       	movq   %r14,%xmm1
  406808:	66 49 0f 6e d5       	movq   %r13,%xmm2
  40680d:	66 49 0f 6e dc       	movq   %r12,%xmm3
  406812:	66 48 0f 6e e3       	movq   %rbx,%xmm4
  406817:	66 49 0f 6e ea       	movq   %r10,%xmm5
  40681c:	48 83 ec 10          	sub    $0x10,%rsp
  406820:	49 89 e2             	mov    %rsp,%r10
  406823:	4d 89 5a 08          	mov    %r11,0x8(%r10)
  406827:	49 89 02             	mov    %rax,(%r10)
  40682a:	e8 11 00 00 00       	callq  406840 <p126_typed_FID_36_112_114_111_100_117_99_116_46_110_101_97_114_101_115_116_>
  40682f:	48 83 ec f0          	sub    $0xfffffffffffffff0,%rsp
  406833:	41 5f                	pop    %r15
  406835:	41 5e                	pop    %r14
  406837:	41 5d                	pop    %r13
  406839:	41 5c                	pop    %r12
  40683b:	5b                   	pop    %rbx
  40683c:	c9                   	leaveq 
  40683d:	c3                   	retq   
  40683e:	66 90                	xchg   %ax,%ax

