
/home/ai/bend2/build/publish/bend/selfhost/build/phase111/p131-read-lookup01-identity-original-build/program:     file format elf64-x86-64


Disassembly of section .init:

Disassembly of section .plt:

Disassembly of section .text:

00000000004138c0 <p111_FID_36_100_105_114_101_99_116_46_105_110_100_101_120_95_102_105_110_100_95_108_101_97_102_>:
  4138c0:	f3 0f 1e fa          	endbr64 
  4138c4:	55                   	push   %rbp
  4138c5:	48 89 e5             	mov    %rsp,%rbp
  4138c8:	48 81 ec 00 18 00 00 	sub    $0x1800,%rsp
  4138cf:	53                   	push   %rbx
  4138d0:	41 54                	push   %r12
  4138d2:	41 55                	push   %r13
  4138d4:	41 56                	push   %r14
  4138d6:	48 8b 77 28          	mov    0x28(%rdi),%rsi
  4138da:	4c 8b 67 30          	mov    0x30(%rdi),%r12
  4138de:	48 8b 57 38          	mov    0x38(%rdi),%rdx
  4138e2:	48 8b 4f 40          	mov    0x40(%rdi),%rcx
  4138e6:	48 8b 5f 48          	mov    0x48(%rdi),%rbx
  4138ea:	48 83 fb 01          	cmp    $0x1,%rbx
  4138ee:	0f 94 c0             	sete   %al
  4138f1:	0f b6 c0             	movzbl %al,%eax
  4138f4:	49 89 d8             	mov    %rbx,%r8
  4138f7:	49 c1 e8 28          	shr    $0x28,%r8
  4138fb:	49 81 e0 ff ff 7f 00 	and    $0x7fffff,%r8
  413902:	49 81 f8 02 00 01 00 	cmp    $0x10002,%r8
  413909:	41 0f 94 c0          	sete   %r8b
  41390d:	45 0f b6 c0          	movzbl %r8b,%r8d
  413911:	44 09 c0             	or     %r8d,%eax
  413914:	41 b8 ff ff ff ff    	mov    $0xffffffff,%r8d
  41391a:	49 89 d5             	mov    %rdx,%r13
  41391d:	4d 21 c5             	and    %r8,%r13
  413920:	83 f8 00             	cmp    $0x0,%eax
  413923:	0f 85 f9 00 00 00    	jne    413a22 <p111_FID_36_100_105_114_101_99_116_46_105_110_100_101_120_95_102_105_110_100_95_108_101_97_102_+0x162>
  413929:	83 f0 01             	xor    $0x1,%eax
  41392c:	83 f8 00             	cmp    $0x0,%eax
  41392f:	75 46                	jne    413977 <p111_FID_36_100_105_114_101_99_116_46_105_110_100_101_120_95_102_105_110_100_95_108_101_97_102_+0xb7>
  413931:	49 89 fd             	mov    %rdi,%r13
  413934:	e8 87 14 01 00       	callq  424dc0 <p111_rt_sink>
  413939:	4c 89 ef             	mov    %r13,%rdi
  41393c:	4c 89 e6             	mov    %r12,%rsi
  41393f:	49 89 fc             	mov    %rdi,%r12
  413942:	e8 79 14 01 00       	callq  424dc0 <p111_rt_sink>
  413947:	4c 89 e7             	mov    %r12,%rdi
  41394a:	48 89 9d 00 e8 ff ff 	mov    %rbx,-0x1800(%rbp)
  413951:	48 8b 47 10          	mov    0x10(%rdi),%rax
  413955:	48 89 18             	mov    %rbx,(%rax)
  413958:	48 c7 40 08 01 01 00 	movq   $0x101,0x8(%rax)
  41395f:	00 
  413960:	48 83 c0 10          	add    $0x10,%rax
  413964:	48 89 47 10          	mov    %rax,0x10(%rdi)
  413968:	be 04 00 00 00       	mov    $0x4,%esi
  41396d:	e8 de 1b 01 00       	callq  425550 <p111_rt_fail>
  413972:	e9 06 01 00 00       	jmpq   413a7d <p111_FID_36_100_105_114_101_99_116_46_105_110_100_101_120_95_102_105_110_100_95_108_101_97_102_+0x1bd>
  413977:	2e 4c 89 eb          	cs mov %r13,%rbx
  41397b:	4c 89 a5 00 e8 ff ff 	mov    %r12,-0x1800(%rbp)
  413982:	48 89 95 08 e8 ff ff 	mov    %rdx,-0x17f8(%rbp)
  413989:	48 89 8d 10 e8 ff ff 	mov    %rcx,-0x17f0(%rbp)
  413990:	48 8b 47 10          	mov    0x10(%rdi),%rax
  413994:	4c 89 20             	mov    %r12,(%rax)
  413997:	48 89 50 08          	mov    %rdx,0x8(%rax)
  41399b:	48 89 48 10          	mov    %rcx,0x10(%rax)
  41399f:	48 c7 40 18 fe 00 00 	movq   $0xfe,0x18(%rax)
  4139a6:	00 
  4139a7:	48 83 c0 20          	add    $0x20,%rax
  4139ab:	48 89 47 10          	mov    %rax,0x10(%rdi)
  4139af:	49 89 fc             	mov    %rdi,%r12
  4139b2:	e8 79 13 01 00       	callq  424d30 <p111_rt_keep>
  4139b7:	4c 89 e7             	mov    %r12,%rdi
  4139ba:	48 89 c6             	mov    %rax,%rsi
  4139bd:	48 89 b5 00 e8 ff ff 	mov    %rsi,-0x1800(%rbp)
  4139c4:	48 8b 47 10          	mov    0x10(%rdi),%rax
  4139c8:	48 89 30             	mov    %rsi,(%rax)
  4139cb:	48 c7 40 08 ff 00 00 	movq   $0xff,0x8(%rax)
  4139d2:	00 
  4139d3:	48 83 c0 10          	add    $0x10,%rax
  4139d7:	48 89 47 10          	mov    %rax,0x10(%rdi)
  4139db:	49 89 fc             	mov    %rdi,%r12
  4139de:	e8 ed 8e ff ff       	callq  40c8d0 <p112w_FID_36_100_105_114_101_99_116_46_100_120_>
  4139e3:	4c 89 e7             	mov    %r12,%rdi
  4139e6:	b9 ff ff ff ff       	mov    $0xffffffff,%ecx
  4139eb:	48 21 c8             	and    %rcx,%rax
  4139ee:	48 21 d8             	and    %rbx,%rax
  4139f1:	b9 ff ff ff ff       	mov    $0xffffffff,%ecx
  4139f6:	48 21 c8             	and    %rcx,%rax
  4139f9:	48 83 f8 00          	cmp    $0x0,%rax
  4139fd:	0f 94 c0             	sete   %al
  413a00:	0f b6 c0             	movzbl %al,%eax
  413a03:	48 89 85 00 f8 ff ff 	mov    %rax,-0x800(%rbp)
  413a0a:	b9 01 00 00 00       	mov    $0x1,%ecx
  413a0f:	48 8d 95 00 f8 ff ff 	lea    -0x800(%rbp),%rdx
  413a16:	be c7 01 00 00       	mov    $0x1c7,%esi
  413a1b:	e8 60 19 01 00       	callq  425380 <p111_rt_jump>
  413a20:	eb 5b                	jmp    413a7d <p111_FID_36_100_105_114_101_99_116_46_105_110_100_101_120_95_102_105_110_100_95_108_101_97_102_+0x1bd>
  413a22:	4c 89 eb             	mov    %r13,%rbx
  413a25:	49 89 fd             	mov    %rdi,%r13
  413a28:	e8 03 13 01 00       	callq  424d30 <p111_rt_keep>
  413a2d:	4c 89 ef             	mov    %r13,%rdi
  413a30:	49 89 c5             	mov    %rax,%r13
  413a33:	4c 89 ee             	mov    %r13,%rsi
  413a36:	49 89 fe             	mov    %rdi,%r14
  413a39:	e8 c2 8a ff ff       	callq  40c500 <p112w_FID_36_100_105_114_101_99_116_46_100_97_>
  413a3e:	4c 89 f7             	mov    %r14,%rdi
  413a41:	4c 89 ad 00 f0 ff ff 	mov    %r13,-0x1000(%rbp)
  413a48:	4c 89 a5 08 f0 ff ff 	mov    %r12,-0xff8(%rbp)
  413a4f:	b9 ff ff ff ff       	mov    $0xffffffff,%ecx
  413a54:	48 21 c8             	and    %rcx,%rax
  413a57:	48 39 d8             	cmp    %rbx,%rax
  413a5a:	0f 94 c0             	sete   %al
  413a5d:	0f b6 c0             	movzbl %al,%eax
  413a60:	48 89 85 10 f0 ff ff 	mov    %rax,-0xff0(%rbp)
  413a67:	b9 03 00 00 00       	mov    $0x3,%ecx
  413a6c:	48 8d 95 00 f0 ff ff 	lea    -0x1000(%rbp),%rdx
  413a73:	be f3 00 00 00       	mov    $0xf3,%esi
  413a78:	e8 03 19 01 00       	callq  425380 <p111_rt_jump>
  413a7d:	41 5e                	pop    %r14
  413a7f:	41 5d                	pop    %r13
  413a81:	41 5c                	pop    %r12
  413a83:	5b                   	pop    %rbx
  413a84:	c9                   	leaveq 
  413a85:	c3                   	retq   

Disassembly of section .fini:
