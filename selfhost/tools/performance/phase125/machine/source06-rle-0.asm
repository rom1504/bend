0000000000405ae0 <p113d_FID_36_112_49_49_56_46_116_114_109_99_46_36_100_105_114_101_99_116_46_108_99_111_110_99_97_116_>:
  405ae0:	f3 0f 1e fa          	endbr64 
  405ae4:	55                   	push   %rbp
  405ae5:	48 89 e5             	mov    %rsp,%rbp
  405ae8:	48 81 ec 00 08 00 00 	sub    $0x800,%rsp
  405aef:	53                   	push   %rbx
  405af0:	41 54                	push   %r12
  405af2:	41 55                	push   %r13
  405af4:	41 56                	push   %r14
  405af6:	48 89 cb             	mov    %rcx,%rbx
  405af9:	48 89 d1             	mov    %rdx,%rcx
  405afc:	4c 89 c2             	mov    %r8,%rdx
  405aff:	49 89 dd             	mov    %rbx,%r13
  405b02:	49 89 d6             	mov    %rdx,%r14
  405b05:	48 89 ca             	mov    %rcx,%rdx
  405b08:	0f 1f 84 00 00 00 00 00 	nopl   0x0(%rax,%rax,1)
  405b10:	2e 2e 2e 48 89 f0    	cs cs cs mov %rsi,%rax
  405b16:	48 c1 e8 28          	shr    $0x28,%rax
  405b1a:	48 25 ff ff 00 00    	and    $0xffff,%rax
  405b20:	48 83 f8 11          	cmp    $0x11,%rax
  405b24:	0f 84 a6 00 00 00    	je     405bd0 <p113d_FID_36_112_49_49_56_46_116_114_109_99_46_36_100_105_114_101_99_116_46_108_99_111_110_99_97_116_+0xf0>
  405b2a:	48 83 f8 12          	cmp    $0x12,%rax
  405b2e:	75 75                	jne    405ba5 <p113d_FID_36_112_49_49_56_46_116_114_109_99_46_36_100_105_114_101_99_116_46_108_99_111_110_99_97_116_+0xc5>
  405b30:	49 89 d4             	mov    %rdx,%r12
  405b33:	48 8d 95 00 f8 ff ff 	lea    -0x800(%rbp),%rdx
  405b3a:	48 89 fb             	mov    %rdi,%rbx
  405b3d:	e8 de 7d 01 00       	callq  41d920 <p125_rt_take2>
  405b42:	4d 89 f0             	mov    %r14,%r8
  405b45:	4c 89 e9             	mov    %r13,%rcx
  405b48:	4c 89 e2             	mov    %r12,%rdx
  405b4b:	48 89 df             	mov    %rbx,%rdi
  405b4e:	48 8b 85 00 f8 ff ff 	mov    -0x800(%rbp),%rax
  405b55:	48 8b b5 08 f8 ff ff 	mov    -0x7f8(%rbp),%rsi
  405b5c:	48 89 85 00 f8 ff ff 	mov    %rax,-0x800(%rbp)
  405b63:	49 89 ce             	mov    %rcx,%r14
  405b66:	48 8d 8d 00 f8 ff ff 	lea    -0x800(%rbp),%rcx
  405b6d:	49 89 d5             	mov    %rdx,%r13
  405b70:	ba 12 00 00 00       	mov    $0x12,%edx
  405b75:	49 89 f4             	mov    %rsi,%r12
  405b78:	4c 89 c6             	mov    %r8,%rsi
  405b7b:	48 89 fb             	mov    %rdi,%rbx
  405b7e:	e8 3d 71 01 00       	callq  41ccc0 <p118_rt_extend1>
  405b83:	4c 89 f1             	mov    %r14,%rcx
  405b86:	4c 89 ea             	mov    %r13,%rdx
  405b89:	4c 89 e6             	mov    %r12,%rsi
  405b8c:	48 89 df             	mov    %rbx,%rdi
  405b8f:	49 89 c0             	mov    %rax,%r8
  405b92:	48 83 f9 00          	cmp    $0x0,%rcx
  405b96:	49 0f 44 c8          	cmove  %r8,%rcx
  405b9a:	49 89 cd             	mov    %rcx,%r13
  405b9d:	4d 89 c6             	mov    %r8,%r14
  405ba0:	e9 6b ff ff ff       	jmpq   405b10 <p113d_FID_36_112_49_49_56_46_116_114_109_99_46_36_100_105_114_101_99_116_46_108_99_111_110_99_97_116_+0x30>
  405ba5:	4c 89 ee             	mov    %r13,%rsi
  405ba8:	4d 89 f5             	mov    %r14,%r13
  405bab:	49 89 f4             	mov    %rsi,%r12
  405bae:	be 04 00 00 00       	mov    $0x4,%esi
  405bb3:	48 89 fb             	mov    %rdi,%rbx
  405bb6:	e8 45 2d 01 00       	callq  418900 <p111_rt_fail>
  405bbb:	4c 89 ea             	mov    %r13,%rdx
  405bbe:	4c 89 e6             	mov    %r12,%rsi
  405bc1:	48 89 df             	mov    %rbx,%rdi
  405bc4:	b9 00 00 00 00       	mov    $0x0,%ecx
  405bc9:	e8 72 6f 01 00       	callq  41cb40 <p118_rt_finish>
  405bce:	eb 0e                	jmp    405bde <p113d_FID_36_112_49_49_56_46_116_114_109_99_46_36_100_105_114_101_99_116_46_108_99_111_110_99_97_116_+0xfe>
  405bd0:	48 89 d1             	mov    %rdx,%rcx
  405bd3:	4c 89 ee             	mov    %r13,%rsi
  405bd6:	4c 89 f2             	mov    %r14,%rdx
  405bd9:	e8 62 6f 01 00       	callq  41cb40 <p118_rt_finish>
  405bde:	41 5e                	pop    %r14
  405be0:	41 5d                	pop    %r13
  405be2:	41 5c                	pop    %r12
  405be4:	5b                   	pop    %rbx
  405be5:	c9                   	leaveq 
  405be6:	c3                   	retq   
  405be7:	66 0f 1f 84 00 00 00 00 00 	nopw   0x0(%rax,%rax,1)

