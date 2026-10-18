
/home/ai/bend2/build/publish/bend/selfhost/build/phase108/successor-controls01/non-tail-list-build/program:     file format elf64-x86-64


Disassembly of section .init:

Disassembly of section .plt:

Disassembly of section .text:

0000000000406ab0 <WL_FID_36_100_105_114_101_99_116_46_98_117_109_112_>:
  406ab0:	f3 0f 1e fa          	endbr64 
  406ab4:	55                   	push   %rbp
  406ab5:	48 89 e5             	mov    %rsp,%rbp
  406ab8:	48 83 ec 48          	sub    $0x48,%rsp
  406abc:	53                   	push   %rbx
  406abd:	41 54                	push   %r12
  406abf:	41 55                	push   %r13
  406ac1:	41 56                	push   %r14
  406ac3:	41 57                	push   %r15
  406ac5:	4c 8b 2f             	mov    (%rdi),%r13
  406ac8:	4c 89 6d c0          	mov    %r13,-0x40(%rbp)
  406acc:	4c 8b 67 08          	mov    0x8(%rdi),%r12
  406ad0:	4c 89 65 f8          	mov    %r12,-0x8(%rbp)
  406ad4:	4c 89 65 c8          	mov    %r12,-0x38(%rbp)
  406ad8:	4c 8b 77 10          	mov    0x10(%rdi),%r14
  406adc:	8b 5f 18             	mov    0x18(%rdi),%ebx
  406adf:	48 8b 57 28          	mov    0x28(%rdi),%rdx
  406ae3:	48 89 d0             	mov    %rdx,%rax
  406ae6:	48 c1 e8 28          	shr    $0x28,%rax
  406aea:	48 25 ff ff 00 00    	and    $0xffff,%rax
  406af0:	48 83 f8 11          	cmp    $0x11,%rax
  406af4:	0f 94 c1             	sete   %cl
  406af7:	0f b6 c9             	movzbl %cl,%ecx
  406afa:	83 f9 00             	cmp    $0x0,%ecx
  406afd:	0f 85 85 01 00 00    	jne    406c88 <WL_FID_36_100_105_114_101_99_116_46_98_117_109_112_+0x1d8>
  406b03:	48 83 f8 12          	cmp    $0x12,%rax
  406b07:	0f 94 c0             	sete   %al
  406b0a:	0f b6 c0             	movzbl %al,%eax
  406b0d:	83 f8 00             	cmp    $0x0,%eax
  406b10:	75 6d                	jne    406b7f <WL_FID_36_100_105_114_101_99_116_46_98_117_109_112_+0xcf>
  406b12:	83 fb 00             	cmp    $0x0,%ebx
  406b15:	75 43                	jne    406b5a <WL_FID_36_100_105_114_101_99_116_46_98_117_109_112_+0xaa>
  406b17:	49 8b 4e e8          	mov    -0x18(%r14),%rcx
  406b1b:	4d 8b 46 f0          	mov    -0x10(%r14),%r8
  406b1f:	41 b9 01 00 00 00    	mov    $0x1,%r9d
  406b25:	49 89 d7             	mov    %rdx,%r15
  406b28:	ba 18 00 00 00       	mov    $0x18,%edx
  406b2d:	48 8b 7d c0          	mov    -0x40(%rbp),%rdi
  406b31:	48 8b 75 c8          	mov    -0x38(%rbp),%rsi
  406b35:	e8 e6 da ff ff       	callq  404620 <task_node>
  406b3a:	4d 89 7c c5 00       	mov    %r15,0x0(%r13,%rax,8)
  406b3f:	48 b9 00 00 00 00 00 	movabs $0x500180000000000,%rcx
  406b46:	18 00 05 
  406b49:	48 09 c8             	or     %rcx,%rax
  406b4c:	49 89 46 e8          	mov    %rax,-0x18(%r14)
  406b50:	49 c7 46 f0 01 00 00 	movq   $0x1,-0x10(%r14)
  406b57:	00 
  406b58:	eb 0e                	jmp    406b68 <WL_FID_36_100_105_114_101_99_116_46_98_117_109_112_+0xb8>
  406b5a:	49 89 d7             	mov    %rdx,%r15
  406b5d:	4d 89 3e             	mov    %r15,(%r14)
  406b60:	49 c7 46 08 18 00 00 	movq   $0x18,0x8(%r14)
  406b67:	00 
  406b68:	be 04 00 00 00       	mov    $0x4,%esi
  406b6d:	4c 89 ef             	mov    %r13,%rdi
  406b70:	e8 bb ba ff ff       	callq  402630 <err_post>
  406b75:	b8 00 00 00 00       	mov    $0x0,%eax
  406b7a:	e9 56 01 00 00       	jmpq   406cd5 <WL_FID_36_100_105_114_101_99_116_46_98_117_109_112_+0x225>
  406b7f:	49 89 d7             	mov    %rdx,%r15
  406b82:	49 89 fc             	mov    %rdi,%r12
  406b85:	bf 02 00 00 00       	mov    $0x2,%edi
  406b8a:	e8 f1 bb ff ff       	callq  402780 <cls_fit>
  406b8f:	4c 89 fa             	mov    %r15,%rdx
  406b92:	4c 89 e7             	mov    %r12,%rdi
  406b95:	89 45 f0             	mov    %eax,-0x10(%rbp)
  406b98:	4c 8b 65 f8          	mov    -0x8(%rbp),%r12
  406b9c:	4c 8d 45 d0          	lea    -0x30(%rbp),%r8
  406ba0:	b9 02 00 00 00       	mov    $0x2,%ecx
  406ba5:	49 89 ff             	mov    %rdi,%r15
  406ba8:	48 8b 7d c0          	mov    -0x40(%rbp),%rdi
  406bac:	48 8b 75 c8          	mov    -0x38(%rbp),%rsi
  406bb0:	e8 6b c9 ff ff       	callq  403520 <ctr_take>
  406bb5:	4c 89 ff             	mov    %r15,%rdi
  406bb8:	48 89 c1             	mov    %rax,%rcx
  406bbb:	8b 55 f0             	mov    -0x10(%rbp),%edx
  406bbe:	49 89 ff             	mov    %rdi,%r15
  406bc1:	48 8b 7d c0          	mov    -0x40(%rbp),%rdi
  406bc5:	48 8b 75 c8          	mov    -0x38(%rbp),%rsi
  406bc9:	e8 b2 c0 ff ff       	callq  402c80 <spare_free>
  406bce:	4c 89 ff             	mov    %r15,%rdi
  406bd1:	48 8b 55 d0          	mov    -0x30(%rbp),%rdx
  406bd5:	48 89 55 e0          	mov    %rdx,-0x20(%rbp)
  406bd9:	48 8b 45 d8          	mov    -0x28(%rbp),%rax
  406bdd:	48 89 45 e8          	mov    %rax,-0x18(%rbp)
  406be1:	83 fb 00             	cmp    $0x0,%ebx
  406be4:	75 51                	jne    406c37 <WL_FID_36_100_105_114_101_99_116_46_98_117_109_112_+0x187>
  406be6:	49 8b 4e e8          	mov    -0x18(%r14),%rcx
  406bea:	4d 8b 46 f0          	mov    -0x10(%r14),%r8
  406bee:	41 b9 01 00 00 00    	mov    $0x1,%r9d
  406bf4:	ba 17 00 00 00       	mov    $0x17,%edx
  406bf9:	49 89 ff             	mov    %rdi,%r15
  406bfc:	48 8b 7d c0          	mov    -0x40(%rbp),%rdi
  406c00:	48 8b 75 c8          	mov    -0x38(%rbp),%rsi
  406c04:	e8 17 da ff ff       	callq  404620 <task_node>
  406c09:	4c 89 ff             	mov    %r15,%rdi
  406c0c:	48 89 c1             	mov    %rax,%rcx
  406c0f:	48 8b 45 e8          	mov    -0x18(%rbp),%rax
  406c13:	48 8b 55 e0          	mov    -0x20(%rbp),%rdx
  406c17:	49 89 54 cd 00       	mov    %rdx,0x0(%r13,%rcx,8)
  406c1c:	48 ba 00 00 00 00 00 	movabs $0x500170000000000,%rdx
  406c23:	17 00 05 
  406c26:	48 09 d1             	or     %rdx,%rcx
  406c29:	49 89 4e e8          	mov    %rcx,-0x18(%r14)
  406c2d:	49 c7 46 f0 01 00 00 	movq   $0x1,-0x10(%r14)
  406c34:	00 
  406c35:	eb 12                	jmp    406c49 <WL_FID_36_100_105_114_101_99_116_46_98_117_109_112_+0x199>
  406c37:	48 89 d1             	mov    %rdx,%rcx
  406c3a:	49 89 0e             	mov    %rcx,(%r14)
  406c3d:	49 c7 46 08 17 00 00 	movq   $0x17,0x8(%r14)
  406c44:	00 
  406c45:	49 83 c6 10          	add    $0x10,%r14
  406c49:	4c 89 2f             	mov    %r13,(%rdi)
  406c4c:	4c 89 67 08          	mov    %r12,0x8(%rdi)
  406c50:	4c 89 77 10          	mov    %r14,0x10(%rdi)
  406c54:	89 5f 18             	mov    %ebx,0x18(%rdi)
  406c57:	c7 47 1c 00 00 00 00 	movl   $0x0,0x1c(%rdi)
  406c5e:	48 89 47 28          	mov    %rax,0x28(%rdi)
  406c62:	48 c7 47 30 00 00 00 	movq   $0x0,0x30(%rdi)
  406c69:	00 
  406c6a:	48 c7 47 38 00 00 00 	movq   $0x0,0x38(%rdi)
  406c71:	00 
  406c72:	48 c7 47 40 00 00 00 	movq   $0x0,0x40(%rdi)
  406c79:	00 
  406c7a:	c7 47 20 16 00 00 00 	movl   $0x16,0x20(%rdi)
  406c81:	b8 00 00 00 00       	mov    $0x0,%eax
  406c86:	eb 4d                	jmp    406cd5 <WL_FID_36_100_105_114_101_99_116_46_98_117_109_112_+0x225>
  406c88:	4c 89 f0             	mov    %r14,%rax
  406c8b:	48 83 e8 08          	sub    $0x8,%rax
  406c8f:	4c 89 2f             	mov    %r13,(%rdi)
  406c92:	4c 89 67 08          	mov    %r12,0x8(%rdi)
  406c96:	48 89 47 10          	mov    %rax,0x10(%rdi)
  406c9a:	89 5f 18             	mov    %ebx,0x18(%rdi)
  406c9d:	c7 47 1c 01 00 00 00 	movl   $0x1,0x1c(%rdi)
  406ca4:	48 b9 00 00 00 00 00 	movabs $0x100110000000000,%rcx
  406cab:	11 00 01 
  406cae:	48 89 4f 28          	mov    %rcx,0x28(%rdi)
  406cb2:	48 c7 47 30 00 00 00 	movq   $0x0,0x30(%rdi)
  406cb9:	00 
  406cba:	48 c7 47 38 00 00 00 	movq   $0x0,0x38(%rdi)
  406cc1:	00 
  406cc2:	48 c7 47 40 00 00 00 	movq   $0x0,0x40(%rdi)
  406cc9:	00 
  406cca:	48 8b 00             	mov    (%rax),%rax
  406ccd:	89 47 20             	mov    %eax,0x20(%rdi)
  406cd0:	b8 00 00 00 00       	mov    $0x0,%eax
  406cd5:	41 5f                	pop    %r15
  406cd7:	41 5e                	pop    %r14
  406cd9:	41 5d                	pop    %r13
  406cdb:	41 5c                	pop    %r12
  406cdd:	5b                   	pop    %rbx
  406cde:	c9                   	leaveq 
  406cdf:	c3                   	retq   

Disassembly of section .fini:
