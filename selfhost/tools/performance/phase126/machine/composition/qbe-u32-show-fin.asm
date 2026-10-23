
selfhost/build/phase111/p125-broad06-coverage-record-aggregation-256-build/program:     file format elf64-x86-64


Disassembly of section .init:

Disassembly of section .plt:

Disassembly of section .text:

0000000000427a80 <p111_FID_36_100_105_114_101_99_116_46_85_51_50_46_115_104_111_119_46_102_105_110_>:
  427a80:	f3 0f 1e fa          	endbr64 
  427a84:	55                   	push   %rbp
  427a85:	48 89 e5             	mov    %rsp,%rbp
  427a88:	48 81 ec 00 08 00 00 	sub    $0x800,%rsp
  427a8f:	53                   	push   %rbx
  427a90:	41 54                	push   %r12
  427a92:	41 55                	push   %r13
  427a94:	41 56                	push   %r14
  427a96:	4c 8b 6f 28          	mov    0x28(%rdi),%r13
  427a9a:	48 8b 5f 30          	mov    0x30(%rdi),%rbx
  427a9e:	48 8b 47 38          	mov    0x38(%rdi),%rax
  427aa2:	49 89 dc             	mov    %rbx,%r12
  427aa5:	48 8b 5f 40          	mov    0x40(%rdi),%rbx
  427aa9:	48 83 fb 01          	cmp    $0x1,%rbx
  427aad:	0f 94 c1             	sete   %cl
  427ab0:	0f b6 c9             	movzbl %cl,%ecx
  427ab3:	48 89 da             	mov    %rbx,%rdx
  427ab6:	48 c1 ea 28          	shr    $0x28,%rdx
  427aba:	48 81 e2 ff ff 7f 00 	and    $0x7fffff,%rdx
  427ac1:	48 81 fa 02 00 01 00 	cmp    $0x10002,%rdx
  427ac8:	0f 94 c2             	sete   %dl
  427acb:	0f b6 d2             	movzbl %dl,%edx
  427ace:	09 d1                	or     %edx,%ecx
  427ad0:	0f 85 1c 01 00 00    	jne    427bf2 <p111_FID_36_100_105_114_101_99_116_46_85_51_50_46_115_104_111_119_46_102_105_110_+0x172>
  427ad6:	83 f1 01             	xor    $0x1,%ecx
  427ad9:	75 3b                	jne    427b16 <p111_FID_36_100_105_114_101_99_116_46_85_51_50_46_115_104_111_119_46_102_105_110_+0x96>
  427adb:	4c 89 e6             	mov    %r12,%rsi
  427ade:	49 89 fc             	mov    %rdi,%r12
  427ae1:	e8 5a 76 00 00       	callq  42f140 <p111_rt_sink>
  427ae6:	4c 89 e7             	mov    %r12,%rdi
  427ae9:	48 89 9d 00 f8 ff ff 	mov    %rbx,-0x800(%rbp)
  427af0:	48 8b 47 10          	mov    0x10(%rdi),%rax
  427af4:	48 89 18             	mov    %rbx,(%rax)
  427af7:	48 c7 40 08 10 03 00 	movq   $0x310,0x8(%rax)
  427afe:	00 
  427aff:	48 83 c0 10          	add    $0x10,%rax
  427b03:	48 89 47 10          	mov    %rax,0x10(%rdi)
  427b07:	be 04 00 00 00       	mov    $0x4,%esi
  427b0c:	e8 bf 7d 00 00       	callq  42f8d0 <p111_rt_fail>
  427b11:	e9 f7 00 00 00       	jmpq   427c0d <p111_FID_36_100_105_114_101_99_116_46_85_51_50_46_115_104_111_119_46_102_105_110_+0x18d>
  427b16:	4c 89 e3             	mov    %r12,%rbx
  427b19:	4d 89 ec             	mov    %r13,%r12
  427b1c:	48 89 85 00 f8 ff ff 	mov    %rax,-0x800(%rbp)
  427b23:	48 c7 85 08 f8 ff ff 	movq   $0xa,-0x7f8(%rbp)
  427b2a:	0a 00 00 00 
  427b2e:	be 0a 00 00 00       	mov    $0xa,%esi
  427b33:	48 89 c1             	mov    %rax,%rcx
  427b36:	ba 00 00 00 00       	mov    $0x0,%edx
  427b3b:	f7 f6                	div    %esi
  427b3d:	48 91                	xchg   %rax,%rcx
  427b3f:	89 c9                	mov    %ecx,%ecx
  427b41:	49 89 dd             	mov    %rbx,%r13
  427b44:	48 89 cb             	mov    %rcx,%rbx
  427b47:	48 89 85 00 f8 ff ff 	mov    %rax,-0x800(%rbp)
  427b4e:	48 c7 85 08 f8 ff ff 	movq   $0xa,-0x7f8(%rbp)
  427b55:	0a 00 00 00 
  427b59:	b9 0a 00 00 00       	mov    $0xa,%ecx
  427b5e:	ba 00 00 00 00       	mov    $0x0,%edx
  427b63:	f7 f1                	div    %ecx
  427b65:	89 d0                	mov    %edx,%eax
  427b67:	89 c0                	mov    %eax,%eax
  427b69:	b9 ff ff ff ff       	mov    $0xffffffff,%ecx
  427b6e:	48 21 c8             	and    %rcx,%rax
  427b71:	48 83 c0 30          	add    $0x30,%rax
  427b75:	b9 ff ff ff ff       	mov    $0xffffffff,%ecx
  427b7a:	48 21 c8             	and    %rcx,%rax
  427b7d:	48 89 85 00 f8 ff ff 	mov    %rax,-0x800(%rbp)
  427b84:	b9 01 00 00 00       	mov    $0x1,%ecx
  427b89:	48 8d 95 00 f8 ff ff 	lea    -0x800(%rbp),%rdx
  427b90:	be 05 00 00 00       	mov    $0x5,%esi
  427b95:	49 89 fe             	mov    %rdi,%r14
  427b98:	e8 d3 8e 00 00       	callq  430a70 <p111_rt_special_ctor>
  427b9d:	4c 89 f7             	mov    %r14,%rdi
  427ba0:	48 89 85 00 f8 ff ff 	mov    %rax,-0x800(%rbp)
  427ba7:	4c 89 ad 08 f8 ff ff 	mov    %r13,-0x7f8(%rbp)
  427bae:	48 8d 95 00 f8 ff ff 	lea    -0x800(%rbp),%rdx
  427bb5:	be 19 00 00 00       	mov    $0x19,%esi
  427bba:	49 89 fd             	mov    %rdi,%r13
  427bbd:	e8 3e cc 00 00       	callq  434800 <p125_rt_ctor2>
  427bc2:	4c 89 ef             	mov    %r13,%rdi
  427bc5:	4c 89 a5 00 f8 ff ff 	mov    %r12,-0x800(%rbp)
  427bcc:	48 89 9d 08 f8 ff ff 	mov    %rbx,-0x7f8(%rbp)
  427bd3:	48 89 85 10 f8 ff ff 	mov    %rax,-0x7f0(%rbp)
  427bda:	b9 03 00 00 00       	mov    $0x3,%ecx
  427bdf:	48 8d 95 00 f8 ff ff 	lea    -0x800(%rbp),%rdx
  427be6:	be 15 03 00 00       	mov    $0x315,%esi
  427beb:	e8 10 7b 00 00       	callq  42f700 <p111_rt_jump>
  427bf0:	eb 1b                	jmp    427c0d <p111_FID_36_100_105_114_101_99_116_46_85_51_50_46_115_104_111_119_46_102_105_110_+0x18d>
  427bf2:	4c 89 e3             	mov    %r12,%rbx
  427bf5:	48 89 9d 00 f8 ff ff 	mov    %rbx,-0x800(%rbp)
  427bfc:	ba 01 00 00 00       	mov    $0x1,%edx
  427c01:	48 8d b5 00 f8 ff ff 	lea    -0x800(%rbp),%rsi
  427c08:	e8 53 7b 00 00       	callq  42f760 <p111_rt_return>
  427c0d:	41 5e                	pop    %r14
  427c0f:	41 5d                	pop    %r13
  427c11:	41 5c                	pop    %r12
  427c13:	5b                   	pop    %rbx
  427c14:	c9                   	leaveq 
  427c15:	c3                   	retq   

Disassembly of section .fini:
