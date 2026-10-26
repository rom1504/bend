
selfhost/build/phase111/p143-integrated-n2/program:     file format elf64-x86-64


Disassembly of section .init:

Disassembly of section .plt:

Disassembly of section .text:

000000000042fb50 <p113d_FID_36_112_49_49_56_46_116_114_109_99_46_36_100_105_114_101_99_116_46_83_116_114_105_110_103_46_97_112_112_101_110_100_>:
  42fb50:	f3 0f 1e fa          	endbr64 
  42fb54:	55                   	push   %rbp
  42fb55:	48 89 e5             	mov    %rsp,%rbp
  42fb58:	48 81 ec 00 08 00 00 	sub    $0x800,%rsp
  42fb5f:	53                   	push   %rbx
  42fb60:	41 54                	push   %r12
  42fb62:	41 55                	push   %r13
  42fb64:	41 56                	push   %r14
  42fb66:	48 89 cb             	mov    %rcx,%rbx
  42fb69:	48 89 d1             	mov    %rdx,%rcx
  42fb6c:	4c 89 c2             	mov    %r8,%rdx
  42fb6f:	49 89 dd             	mov    %rbx,%r13
  42fb72:	49 89 d6             	mov    %rdx,%r14
  42fb75:	48 89 ca             	mov    %rcx,%rdx
  42fb78:	0f 1f 84 00 00 00 00 	nopl   0x0(%rax,%rax,1)
  42fb7f:	00 
  42fb80:	48 89 f0             	mov    %rsi,%rax
  42fb83:	48 c1 e8 28          	shr    $0x28,%rax
  42fb87:	48 25 ff ff 00 00    	and    $0xffff,%rax
  42fb8d:	48 83 f8 18          	cmp    $0x18,%rax
  42fb91:	0f 84 a6 00 00 00    	je     42fc3d <p113d_FID_36_112_49_49_56_46_116_114_109_99_46_36_100_105_114_101_99_116_46_83_116_114_105_110_103_46_97_112_112_101_110_100_+0xed>
  42fb97:	48 83 f8 19          	cmp    $0x19,%rax
  42fb9b:	75 75                	jne    42fc12 <p113d_FID_36_112_49_49_56_46_116_114_109_99_46_36_100_105_114_101_99_116_46_83_116_114_105_110_103_46_97_112_112_101_110_100_+0xc2>
  42fb9d:	49 89 d4             	mov    %rdx,%r12
  42fba0:	48 8d 95 00 f8 ff ff 	lea    -0x800(%rbp),%rdx
  42fba7:	48 89 fb             	mov    %rdi,%rbx
  42fbaa:	e8 51 90 b2 00       	callq  f58c00 <p125_rt_take2>
  42fbaf:	4d 89 f0             	mov    %r14,%r8
  42fbb2:	4c 89 e9             	mov    %r13,%rcx
  42fbb5:	4c 89 e2             	mov    %r12,%rdx
  42fbb8:	48 89 df             	mov    %rbx,%rdi
  42fbbb:	48 8b 85 00 f8 ff ff 	mov    -0x800(%rbp),%rax
  42fbc2:	48 8b b5 08 f8 ff ff 	mov    -0x7f8(%rbp),%rsi
  42fbc9:	48 89 85 00 f8 ff ff 	mov    %rax,-0x800(%rbp)
  42fbd0:	49 89 ce             	mov    %rcx,%r14
  42fbd3:	48 8d 8d 00 f8 ff ff 	lea    -0x800(%rbp),%rcx
  42fbda:	49 89 d5             	mov    %rdx,%r13
  42fbdd:	ba 19 00 00 00       	mov    $0x19,%edx
  42fbe2:	49 89 f4             	mov    %rsi,%r12
  42fbe5:	4c 89 c6             	mov    %r8,%rsi
  42fbe8:	48 89 fb             	mov    %rdi,%rbx
  42fbeb:	e8 b0 83 b2 00       	callq  f57fa0 <p118_rt_extend1>
  42fbf0:	4c 89 f1             	mov    %r14,%rcx
  42fbf3:	4c 89 ea             	mov    %r13,%rdx
  42fbf6:	4c 89 e6             	mov    %r12,%rsi
  42fbf9:	48 89 df             	mov    %rbx,%rdi
  42fbfc:	49 89 c0             	mov    %rax,%r8
  42fbff:	48 83 f9 00          	cmp    $0x0,%rcx
  42fc03:	49 0f 44 c8          	cmove  %r8,%rcx
  42fc07:	49 89 cd             	mov    %rcx,%r13
  42fc0a:	4d 89 c6             	mov    %r8,%r14
  42fc0d:	e9 6e ff ff ff       	jmpq   42fb80 <p113d_FID_36_112_49_49_56_46_116_114_109_99_46_36_100_105_114_101_99_116_46_83_116_114_105_110_103_46_97_112_112_101_110_100_+0x30>
  42fc12:	4c 89 ee             	mov    %r13,%rsi
  42fc15:	4d 89 f5             	mov    %r14,%r13
  42fc18:	49 89 f4             	mov    %rsi,%r12
  42fc1b:	be 04 00 00 00       	mov    $0x4,%esi
  42fc20:	48 89 fb             	mov    %rdi,%rbx
  42fc23:	e8 b8 3f b2 00       	callq  f53be0 <p111_rt_fail>
  42fc28:	4c 89 ea             	mov    %r13,%rdx
  42fc2b:	4c 89 e6             	mov    %r12,%rsi
  42fc2e:	48 89 df             	mov    %rbx,%rdi
  42fc31:	b9 00 00 00 00       	mov    $0x0,%ecx
  42fc36:	e8 e5 81 b2 00       	callq  f57e20 <p118_rt_finish>
  42fc3b:	eb 0e                	jmp    42fc4b <p113d_FID_36_112_49_49_56_46_116_114_109_99_46_36_100_105_114_101_99_116_46_83_116_114_105_110_103_46_97_112_112_101_110_100_+0xfb>
  42fc3d:	48 89 d1             	mov    %rdx,%rcx
  42fc40:	4c 89 ee             	mov    %r13,%rsi
  42fc43:	4c 89 f2             	mov    %r14,%rdx
  42fc46:	e8 d5 81 b2 00       	callq  f57e20 <p118_rt_finish>
  42fc4b:	41 5e                	pop    %r14
  42fc4d:	41 5d                	pop    %r13
  42fc4f:	41 5c                	pop    %r12
  42fc51:	5b                   	pop    %rbx
  42fc52:	c9                   	leaveq 
  42fc53:	c3                   	retq   

Disassembly of section .fini:
