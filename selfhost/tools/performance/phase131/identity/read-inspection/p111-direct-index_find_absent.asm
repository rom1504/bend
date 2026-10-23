
/home/ai/bend2/build/publish/bend/selfhost/build/phase111/p130-native01-n1/program:     file format elf64-x86-64


Disassembly of section .init:

Disassembly of section .plt:

Disassembly of section .text:

0000000000dc6c70 <p111_FID_36_100_105_114_101_99_116_46_105_110_100_101_120_95_102_105_110_100_95_97_98_115_101_110_116_>:
  dc6c70:	f3 0f 1e fa          	endbr64 
  dc6c74:	55                   	push   %rbp
  dc6c75:	48 89 e5             	mov    %rsp,%rbp
  dc6c78:	48 81 ec 08 10 00 00 	sub    $0x1008,%rsp
  dc6c7f:	53                   	push   %rbx
  dc6c80:	41 54                	push   %r12
  dc6c82:	41 55                	push   %r13
  dc6c84:	41 56                	push   %r14
  dc6c86:	41 57                	push   %r15
  dc6c88:	48 8b 77 28          	mov    0x28(%rdi),%rsi
  dc6c8c:	4c 8b 6f 30          	mov    0x30(%rdi),%r13
  dc6c90:	4c 8b 67 38          	mov    0x38(%rdi),%r12
  dc6c94:	48 8b 5f 40          	mov    0x40(%rdi),%rbx
  dc6c98:	49 89 de             	mov    %rbx,%r14
  dc6c9b:	48 8b 5f 48          	mov    0x48(%rdi),%rbx
  dc6c9f:	48 83 fb 01          	cmp    $0x1,%rbx
  dc6ca3:	0f 94 c0             	sete   %al
  dc6ca6:	0f b6 c0             	movzbl %al,%eax
  dc6ca9:	48 89 d9             	mov    %rbx,%rcx
  dc6cac:	48 c1 e9 28          	shr    $0x28,%rcx
  dc6cb0:	48 81 e1 ff ff 7f 00 	and    $0x7fffff,%rcx
  dc6cb7:	48 81 f9 02 00 01 00 	cmp    $0x10002,%rcx
  dc6cbe:	0f 94 c1             	sete   %cl
  dc6cc1:	0f b6 c9             	movzbl %cl,%ecx
  dc6cc4:	09 c8                	or     %ecx,%eax
  dc6cc6:	0f 85 c6 00 00 00    	jne    dc6d92 <p111_FID_36_100_105_114_101_99_116_46_105_110_100_101_120_95_102_105_110_100_95_97_98_115_101_110_116_+0x122>
  dc6ccc:	83 f0 01             	xor    $0x1,%eax
  dc6ccf:	75 49                	jne    dc6d1a <p111_FID_36_100_105_114_101_99_116_46_105_110_100_101_120_95_102_105_110_100_95_97_98_115_101_110_116_+0xaa>
  dc6cd1:	49 89 fc             	mov    %rdi,%r12
  dc6cd4:	e8 67 05 02 00       	callq  de7240 <p111_rt_sink>
  dc6cd9:	4c 89 ee             	mov    %r13,%rsi
  dc6cdc:	4c 89 e7             	mov    %r12,%rdi
  dc6cdf:	49 89 f6             	mov    %rsi,%r14
  dc6ce2:	49 89 fc             	mov    %rdi,%r12
  dc6ce5:	e8 56 05 02 00       	callq  de7240 <p111_rt_sink>
  dc6cea:	4c 89 e7             	mov    %r12,%rdi
  dc6ced:	48 89 9d 00 f0 ff ff 	mov    %rbx,-0x1000(%rbp)
  dc6cf4:	48 8b 47 10          	mov    0x10(%rdi),%rax
  dc6cf8:	48 89 18             	mov    %rbx,(%rax)
  dc6cfb:	48 c7 40 08 7b b9 00 	movq   $0xb97b,0x8(%rax)
  dc6d02:	00 
  dc6d03:	48 83 c0 10          	add    $0x10,%rax
  dc6d07:	48 89 47 10          	mov    %rax,0x10(%rdi)
  dc6d0b:	be 04 00 00 00       	mov    $0x4,%esi
  dc6d10:	e8 bb 0c 02 00       	callq  de79d0 <p111_rt_fail>
  dc6d15:	e9 b7 00 00 00       	jmpq   dc6dd1 <p111_FID_36_100_105_114_101_99_116_46_105_110_100_101_120_95_102_105_110_100_95_97_98_115_101_110_116_+0x161>
  dc6d1a:	4c 89 f3             	mov    %r14,%rbx
  dc6d1d:	4d 89 ee             	mov    %r13,%r14
  dc6d20:	49 89 fd             	mov    %rdi,%r13
  dc6d23:	e8 88 04 02 00       	callq  de71b0 <p111_rt_keep>
  dc6d28:	4c 89 f6             	mov    %r14,%rsi
  dc6d2b:	4c 89 ef             	mov    %r13,%rdi
  dc6d2e:	49 89 c5             	mov    %rax,%r13
  dc6d31:	49 89 f7             	mov    %rsi,%r15
  dc6d34:	4c 89 ee             	mov    %r13,%rsi
  dc6d37:	49 89 fe             	mov    %rdi,%r14
  dc6d3a:	e8 81 b6 7f ff       	callq  5c23c0 <p112w_FID_36_100_105_114_101_99_116_46_100_120_>
  dc6d3f:	4c 89 fe             	mov    %r15,%rsi
  dc6d42:	4c 89 f7             	mov    %r14,%rdi
  dc6d45:	4c 89 ad 00 f8 ff ff 	mov    %r13,-0x800(%rbp)
  dc6d4c:	48 89 b5 08 f8 ff ff 	mov    %rsi,-0x7f8(%rbp)
  dc6d53:	4c 89 a5 10 f8 ff ff 	mov    %r12,-0x7f0(%rbp)
  dc6d5a:	48 89 9d 18 f8 ff ff 	mov    %rbx,-0x7e8(%rbp)
  dc6d61:	b9 ff ff ff ff       	mov    $0xffffffff,%ecx
  dc6d66:	48 21 c8             	and    %rcx,%rax
  dc6d69:	48 83 f8 00          	cmp    $0x0,%rax
  dc6d6d:	0f 94 c0             	sete   %al
  dc6d70:	0f b6 c0             	movzbl %al,%eax
  dc6d73:	48 89 85 20 f8 ff ff 	mov    %rax,-0x7e0(%rbp)
  dc6d7a:	b9 05 00 00 00       	mov    $0x5,%ecx
  dc6d7f:	48 8d 95 00 f8 ff ff 	lea    -0x800(%rbp),%rdx
  dc6d86:	be 6d b9 00 00       	mov    $0xb96d,%esi
  dc6d8b:	e8 70 0a 02 00       	callq  de7800 <p111_rt_jump>
  dc6d90:	eb 3f                	jmp    dc6dd1 <p111_FID_36_100_105_114_101_99_116_46_105_110_100_101_120_95_102_105_110_100_95_97_98_115_101_110_116_+0x161>
  dc6d92:	4d 89 ec             	mov    %r13,%r12
  dc6d95:	48 89 fb             	mov    %rdi,%rbx
  dc6d98:	e8 a3 04 02 00       	callq  de7240 <p111_rt_sink>
  dc6d9d:	4c 89 e6             	mov    %r12,%rsi
  dc6da0:	48 89 df             	mov    %rbx,%rdi
  dc6da3:	48 89 fb             	mov    %rdi,%rbx
  dc6da6:	e8 95 04 02 00       	callq  de7240 <p111_rt_sink>
  dc6dab:	48 89 df             	mov    %rbx,%rdi
  dc6dae:	48 89 fb             	mov    %rdi,%rbx
  dc6db1:	e8 ca 38 80 ff       	callq  5ca680 <p112w_FID_109_105_115_115_105_110_103_>
  dc6db6:	48 89 df             	mov    %rbx,%rdi
  dc6db9:	48 89 85 00 f0 ff ff 	mov    %rax,-0x1000(%rbp)
  dc6dc0:	ba 01 00 00 00       	mov    $0x1,%edx
  dc6dc5:	48 8d b5 00 f0 ff ff 	lea    -0x1000(%rbp),%rsi
  dc6dcc:	e8 8f 0a 02 00       	callq  de7860 <p111_rt_return>
  dc6dd1:	41 5f                	pop    %r15
  dc6dd3:	41 5e                	pop    %r14
  dc6dd5:	41 5d                	pop    %r13
  dc6dd7:	41 5c                	pop    %r12
  dc6dd9:	5b                   	pop    %rbx
  dc6dda:	c9                   	leaveq 
  dc6ddb:	c3                   	retq   

Disassembly of section .fini:
