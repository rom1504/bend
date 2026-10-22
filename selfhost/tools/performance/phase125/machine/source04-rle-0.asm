0000000000405920 <p113d_FID_36_112_49_49_56_46_116_114_109_99_46_36_100_105_114_101_99_116_46_108_99_111_110_99_97_116_>:
  405920:	f3 0f 1e fa          	endbr64 
  405924:	55                   	push   %rbp
  405925:	48 89 e5             	mov    %rsp,%rbp
  405928:	48 81 ec 00 08 00 00 	sub    $0x800,%rsp
  40592f:	53                   	push   %rbx
  405930:	41 54                	push   %r12
  405932:	41 55                	push   %r13
  405934:	41 56                	push   %r14
  405936:	48 89 cb             	mov    %rcx,%rbx
  405939:	48 89 d1             	mov    %rdx,%rcx
  40593c:	4c 89 c2             	mov    %r8,%rdx
  40593f:	49 89 d6             	mov    %rdx,%r14
  405942:	48 89 ca             	mov    %rcx,%rdx
  405945:	48 89 d9             	mov    %rbx,%rcx
  405948:	0f 1f 84 00 00 00 00 00 	nopl   0x0(%rax,%rax,1)
  405950:	2e 2e 2e 48 89 f0    	cs cs cs mov %rsi,%rax
  405956:	48 c1 e8 28          	shr    $0x28,%rax
  40595a:	48 25 ff ff 00 00    	and    $0xffff,%rax
  405960:	48 83 f8 11          	cmp    $0x11,%rax
  405964:	0f 84 ab 00 00 00    	je     405a15 <p113d_FID_36_112_49_49_56_46_116_114_109_99_46_36_100_105_114_101_99_116_46_108_99_111_110_99_97_116_+0xf5>
  40596a:	48 83 f8 12          	cmp    $0x12,%rax
  40596e:	75 7a                	jne    4059ea <p113d_FID_36_112_49_49_56_46_116_114_109_99_46_36_100_105_114_101_99_116_46_108_99_111_110_99_97_116_+0xca>
  405970:	49 89 cd             	mov    %rcx,%r13
  405973:	b9 02 00 00 00       	mov    $0x2,%ecx
  405978:	49 89 d4             	mov    %rdx,%r12
  40597b:	48 8d 95 00 f8 ff ff 	lea    -0x800(%rbp),%rdx
  405982:	48 89 fb             	mov    %rdi,%rbx
  405985:	e8 36 69 01 00       	callq  41c2c0 <p118_p111_rt_take2>
  40598a:	4d 89 f0             	mov    %r14,%r8
  40598d:	4c 89 e9             	mov    %r13,%rcx
  405990:	4c 89 e2             	mov    %r12,%rdx
  405993:	48 89 df             	mov    %rbx,%rdi
  405996:	48 8b 85 00 f8 ff ff 	mov    -0x800(%rbp),%rax
  40599d:	48 8b b5 08 f8 ff ff 	mov    -0x7f8(%rbp),%rsi
  4059a4:	48 89 85 00 f8 ff ff 	mov    %rax,-0x800(%rbp)
  4059ab:	49 89 ce             	mov    %rcx,%r14
  4059ae:	48 8d 8d 00 f8 ff ff 	lea    -0x800(%rbp),%rcx
  4059b5:	49 89 d5             	mov    %rdx,%r13
  4059b8:	ba 12 00 00 00       	mov    $0x12,%edx
  4059bd:	49 89 f4             	mov    %rsi,%r12
  4059c0:	4c 89 c6             	mov    %r8,%rsi
  4059c3:	48 89 fb             	mov    %rdi,%rbx
  4059c6:	e8 15 73 01 00       	callq  41cce0 <p118_rt_extend1>
  4059cb:	4c 89 f1             	mov    %r14,%rcx
  4059ce:	4c 89 ea             	mov    %r13,%rdx
  4059d1:	4c 89 e6             	mov    %r12,%rsi
  4059d4:	48 89 df             	mov    %rbx,%rdi
  4059d7:	49 89 c0             	mov    %rax,%r8
  4059da:	48 83 f9 00          	cmp    $0x0,%rcx
  4059de:	49 0f 44 c8          	cmove  %r8,%rcx
  4059e2:	4d 89 c6             	mov    %r8,%r14
  4059e5:	e9 66 ff ff ff       	jmpq   405950 <p113d_FID_36_112_49_49_56_46_116_114_109_99_46_36_100_105_114_101_99_116_46_108_99_111_110_99_97_116_+0x30>
  4059ea:	48 89 ce             	mov    %rcx,%rsi
  4059ed:	4d 89 f5             	mov    %r14,%r13
  4059f0:	49 89 f4             	mov    %rsi,%r12
  4059f3:	be 04 00 00 00       	mov    $0x4,%esi
  4059f8:	48 89 fb             	mov    %rdi,%rbx
  4059fb:	e8 20 2f 01 00       	callq  418920 <p111_rt_fail>
  405a00:	4c 89 ea             	mov    %r13,%rdx
  405a03:	4c 89 e6             	mov    %r12,%rsi
  405a06:	48 89 df             	mov    %rbx,%rdi
  405a09:	b9 00 00 00 00       	mov    $0x0,%ecx
  405a0e:	e8 4d 71 01 00       	callq  41cb60 <p118_rt_finish>
  405a13:	eb 0e                	jmp    405a23 <p113d_FID_36_112_49_49_56_46_116_114_109_99_46_36_100_105_114_101_99_116_46_108_99_111_110_99_97_116_+0x103>
  405a15:	48 89 ce             	mov    %rcx,%rsi
  405a18:	48 89 d1             	mov    %rdx,%rcx
  405a1b:	4c 89 f2             	mov    %r14,%rdx
  405a1e:	e8 3d 71 01 00       	callq  41cb60 <p118_rt_finish>
  405a23:	41 5e                	pop    %r14
  405a25:	41 5d                	pop    %r13
  405a27:	41 5c                	pop    %r12
  405a29:	5b                   	pop    %rbx
  405a2a:	c9                   	leaveq 
  405a2b:	c3                   	retq   
  405a2c:	0f 1f 40 00          	nopl   0x0(%rax)

