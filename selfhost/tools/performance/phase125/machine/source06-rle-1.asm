0000000000405bf0 <p113d_FID_36_100_105_114_101_99_116_46_108_99_111_110_99_97_116_>:
  405bf0:	f3 0f 1e fa          	endbr64 
  405bf4:	55                   	push   %rbp
  405bf5:	48 89 e5             	mov    %rsp,%rbp
  405bf8:	48 83 ec 08          	sub    $0x8,%rsp
  405bfc:	53                   	push   %rbx
  405bfd:	41 54                	push   %r12
  405bff:	41 55                	push   %r13
  405c01:	41 b8 12 00 00 00    	mov    $0x12,%r8d
  405c07:	b9 11 00 00 00       	mov    $0x11,%ecx
  405c0c:	49 89 d5             	mov    %rdx,%r13
  405c0f:	49 89 f4             	mov    %rsi,%r12
  405c12:	48 89 fb             	mov    %rdi,%rbx
  405c15:	e8 c6 78 01 00       	callq  41d4e0 <p125_rt_concat_typed>
  405c1a:	4c 89 ea             	mov    %r13,%rdx
  405c1d:	4c 89 e6             	mov    %r12,%rsi
  405c20:	48 89 df             	mov    %rbx,%rdi
  405c23:	48 83 f8 00          	cmp    $0x0,%rax
  405c27:	75 10                	jne    405c39 <p113d_FID_36_100_105_114_101_99_116_46_108_99_111_110_99_97_116_+0x49>
  405c29:	41 b8 00 00 00 00    	mov    $0x0,%r8d
  405c2f:	b9 00 00 00 00       	mov    $0x0,%ecx
  405c34:	e8 a7 fe ff ff       	callq  405ae0 <p113d_FID_36_112_49_49_56_46_116_114_109_99_46_36_100_105_114_101_99_116_46_108_99_111_110_99_97_116_>
  405c39:	41 5d                	pop    %r13
  405c3b:	41 5c                	pop    %r12
  405c3d:	5b                   	pop    %rbx
  405c3e:	c9                   	leaveq 
  405c3f:	c3                   	retq   

