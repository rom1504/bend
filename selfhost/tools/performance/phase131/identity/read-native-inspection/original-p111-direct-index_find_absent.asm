
/home/ai/bend2/build/publish/bend/selfhost/build/phase111/p131-read-lookup01-identity-original-build/program:     file format elf64-x86-64


Disassembly of section .init:

Disassembly of section .plt:

Disassembly of section .text:

0000000000413ef0 <p111_FID_36_100_105_114_101_99_116_46_105_110_100_101_120_95_102_105_110_100_95_97_98_115_101_110_116_>:
  413ef0:	f3 0f 1e fa          	endbr64 
  413ef4:	55                   	push   %rbp
  413ef5:	48 89 e5             	mov    %rsp,%rbp
  413ef8:	48 81 ec 08 10 00 00 	sub    $0x1008,%rsp
  413eff:	53                   	push   %rbx
  413f00:	41 54                	push   %r12
  413f02:	41 55                	push   %r13
  413f04:	41 56                	push   %r14
  413f06:	41 57                	push   %r15
  413f08:	48 8b 77 28          	mov    0x28(%rdi),%rsi
  413f0c:	4c 8b 6f 30          	mov    0x30(%rdi),%r13
  413f10:	4c 8b 67 38          	mov    0x38(%rdi),%r12
  413f14:	48 8b 5f 40          	mov    0x40(%rdi),%rbx
  413f18:	49 89 de             	mov    %rbx,%r14
  413f1b:	48 8b 5f 48          	mov    0x48(%rdi),%rbx
  413f1f:	48 83 fb 01          	cmp    $0x1,%rbx
  413f23:	0f 94 c0             	sete   %al
  413f26:	0f b6 c0             	movzbl %al,%eax
  413f29:	48 89 d9             	mov    %rbx,%rcx
  413f2c:	48 c1 e9 28          	shr    $0x28,%rcx
  413f30:	48 81 e1 ff ff 7f 00 	and    $0x7fffff,%rcx
  413f37:	48 81 f9 02 00 01 00 	cmp    $0x10002,%rcx
  413f3e:	0f 94 c1             	sete   %cl
  413f41:	0f b6 c9             	movzbl %cl,%ecx
  413f44:	09 c8                	or     %ecx,%eax
  413f46:	0f 85 c6 00 00 00    	jne    414012 <p111_FID_36_100_105_114_101_99_116_46_105_110_100_101_120_95_102_105_110_100_95_97_98_115_101_110_116_+0x122>
  413f4c:	83 f0 01             	xor    $0x1,%eax
  413f4f:	75 49                	jne    413f9a <p111_FID_36_100_105_114_101_99_116_46_105_110_100_101_120_95_102_105_110_100_95_97_98_115_101_110_116_+0xaa>
  413f51:	49 89 fc             	mov    %rdi,%r12
  413f54:	e8 67 0e 01 00       	callq  424dc0 <p111_rt_sink>
  413f59:	4c 89 ee             	mov    %r13,%rsi
  413f5c:	4c 89 e7             	mov    %r12,%rdi
  413f5f:	49 89 f6             	mov    %rsi,%r14
  413f62:	49 89 fc             	mov    %rdi,%r12
  413f65:	e8 56 0e 01 00       	callq  424dc0 <p111_rt_sink>
  413f6a:	4c 89 e7             	mov    %r12,%rdi
  413f6d:	48 89 9d 00 f0 ff ff 	mov    %rbx,-0x1000(%rbp)
  413f74:	48 8b 47 10          	mov    0x10(%rdi),%rax
  413f78:	48 89 18             	mov    %rbx,(%rax)
  413f7b:	48 c7 40 08 0a 01 00 	movq   $0x10a,0x8(%rax)
  413f82:	00 
  413f83:	48 83 c0 10          	add    $0x10,%rax
  413f87:	48 89 47 10          	mov    %rax,0x10(%rdi)
  413f8b:	be 04 00 00 00       	mov    $0x4,%esi
  413f90:	e8 bb 15 01 00       	callq  425550 <p111_rt_fail>
  413f95:	e9 b7 00 00 00       	jmpq   414051 <p111_FID_36_100_105_114_101_99_116_46_105_110_100_101_120_95_102_105_110_100_95_97_98_115_101_110_116_+0x161>
  413f9a:	4c 89 f3             	mov    %r14,%rbx
  413f9d:	4d 89 ee             	mov    %r13,%r14
  413fa0:	49 89 fd             	mov    %rdi,%r13
  413fa3:	e8 88 0d 01 00       	callq  424d30 <p111_rt_keep>
  413fa8:	4c 89 f6             	mov    %r14,%rsi
  413fab:	4c 89 ef             	mov    %r13,%rdi
  413fae:	49 89 c5             	mov    %rax,%r13
  413fb1:	49 89 f7             	mov    %rsi,%r15
  413fb4:	4c 89 ee             	mov    %r13,%rsi
  413fb7:	49 89 fe             	mov    %rdi,%r14
  413fba:	e8 11 89 ff ff       	callq  40c8d0 <p112w_FID_36_100_105_114_101_99_116_46_100_120_>
  413fbf:	4c 89 fe             	mov    %r15,%rsi
  413fc2:	4c 89 f7             	mov    %r14,%rdi
  413fc5:	4c 89 ad 00 f8 ff ff 	mov    %r13,-0x800(%rbp)
  413fcc:	48 89 b5 08 f8 ff ff 	mov    %rsi,-0x7f8(%rbp)
  413fd3:	4c 89 a5 10 f8 ff ff 	mov    %r12,-0x7f0(%rbp)
  413fda:	48 89 9d 18 f8 ff ff 	mov    %rbx,-0x7e8(%rbp)
  413fe1:	b9 ff ff ff ff       	mov    $0xffffffff,%ecx
  413fe6:	48 21 c8             	and    %rcx,%rax
  413fe9:	48 83 f8 00          	cmp    $0x0,%rax
  413fed:	0f 94 c0             	sete   %al
  413ff0:	0f b6 c0             	movzbl %al,%eax
  413ff3:	48 89 85 20 f8 ff ff 	mov    %rax,-0x7e0(%rbp)
  413ffa:	b9 05 00 00 00       	mov    $0x5,%ecx
  413fff:	48 8d 95 00 f8 ff ff 	lea    -0x800(%rbp),%rdx
  414006:	be fc 00 00 00       	mov    $0xfc,%esi
  41400b:	e8 70 13 01 00       	callq  425380 <p111_rt_jump>
  414010:	eb 3f                	jmp    414051 <p111_FID_36_100_105_114_101_99_116_46_105_110_100_101_120_95_102_105_110_100_95_97_98_115_101_110_116_+0x161>
  414012:	4d 89 ec             	mov    %r13,%r12
  414015:	48 89 fb             	mov    %rdi,%rbx
  414018:	e8 a3 0d 01 00       	callq  424dc0 <p111_rt_sink>
  41401d:	4c 89 e6             	mov    %r12,%rsi
  414020:	48 89 df             	mov    %rbx,%rdi
  414023:	48 89 fb             	mov    %rdi,%rbx
  414026:	e8 95 0d 01 00       	callq  424dc0 <p111_rt_sink>
  41402b:	48 89 df             	mov    %rbx,%rdi
  41402e:	48 89 fb             	mov    %rdi,%rbx
  414031:	e8 2a 9b ff ff       	callq  40db60 <p112w_FID_109_105_115_115_105_110_103_>
  414036:	48 89 df             	mov    %rbx,%rdi
  414039:	48 89 85 00 f0 ff ff 	mov    %rax,-0x1000(%rbp)
  414040:	ba 01 00 00 00       	mov    $0x1,%edx
  414045:	48 8d b5 00 f0 ff ff 	lea    -0x1000(%rbp),%rsi
  41404c:	e8 8f 13 01 00       	callq  4253e0 <p111_rt_return>
  414051:	41 5f                	pop    %r15
  414053:	41 5e                	pop    %r14
  414055:	41 5d                	pop    %r13
  414057:	41 5c                	pop    %r12
  414059:	5b                   	pop    %rbx
  41405a:	c9                   	leaveq 
  41405b:	c3                   	retq   

Disassembly of section .fini:
