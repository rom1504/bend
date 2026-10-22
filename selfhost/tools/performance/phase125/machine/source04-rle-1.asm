0000000000405a30 <p113d_FID_36_100_105_114_101_99_116_46_108_99_111_110_99_97_116_>:
  405a30:	f3 0f 1e fa          	endbr64 
  405a34:	55                   	push   %rbp
  405a35:	48 89 e5             	mov    %rsp,%rbp
  405a38:	48 83 ec 08          	sub    $0x8,%rsp
  405a3c:	53                   	push   %rbx
  405a3d:	41 54                	push   %r12
  405a3f:	41 55                	push   %r13
  405a41:	41 b8 12 00 00 00    	mov    $0x12,%r8d
  405a47:	b9 11 00 00 00       	mov    $0x11,%ecx
  405a4c:	49 89 d5             	mov    %rdx,%r13
  405a4f:	49 89 f4             	mov    %rsi,%r12
  405a52:	48 89 fb             	mov    %rdi,%rbx
  405a55:	e8 a6 7a 01 00       	callq  41d500 <p125_rt_concat_typed>
  405a5a:	4c 89 ea             	mov    %r13,%rdx
  405a5d:	4c 89 e6             	mov    %r12,%rsi
  405a60:	48 89 df             	mov    %rbx,%rdi
  405a63:	48 83 f8 00          	cmp    $0x0,%rax
  405a67:	75 10                	jne    405a79 <p113d_FID_36_100_105_114_101_99_116_46_108_99_111_110_99_97_116_+0x49>
  405a69:	41 b8 00 00 00 00    	mov    $0x0,%r8d
  405a6f:	b9 00 00 00 00       	mov    $0x0,%ecx
  405a74:	e8 a7 fe ff ff       	callq  405920 <p113d_FID_36_112_49_49_56_46_116_114_109_99_46_36_100_105_114_101_99_116_46_108_99_111_110_99_97_116_>
  405a79:	41 5d                	pop    %r13
  405a7b:	41 5c                	pop    %r12
  405a7d:	5b                   	pop    %rbx
  405a7e:	c9                   	leaveq 
  405a7f:	c3                   	retq   

