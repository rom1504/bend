
/home/ai/bend2/build/publish/bend/selfhost/build/phase108/successor-controls01/nt-reverse-build/program:     file format elf64-x86-64


Disassembly of section .init:

Disassembly of section .plt:

Disassembly of section .text:

0000000000404be0 <NF_FID_83_116_114_105_110_103_46_114_101_118_101_114_115_101_46_103_111_>:
  404be0:	f3 0f 1e fa          	endbr64 
  404be4:	55                   	push   %rbp
  404be5:	48 89 e5             	mov    %rsp,%rbp
  404be8:	48 83 ec 28          	sub    $0x28,%rsp
  404bec:	53                   	push   %rbx
  404bed:	41 54                	push   %r12
  404bef:	41 55                	push   %r13
  404bf1:	41 56                	push   %r14
  404bf3:	41 57                	push   %r15
  404bf5:	4d 89 cf             	mov    %r9,%r15
  404bf8:	4c 89 c2             	mov    %r8,%rdx
  404bfb:	49 89 cc             	mov    %rcx,%r12
  404bfe:	48 89 7d e0          	mov    %rdi,-0x20(%rbp)
  404c02:	48 89 75 e8          	mov    %rsi,-0x18(%rbp)
  404c06:	49 89 d5             	mov    %rdx,%r13
  404c09:	bb 00 00 00 00       	mov    $0x0,%ebx
  404c0e:	66 90                	xchg   %ax,%ax
  404c10:	83 c3 01             	add    $0x1,%ebx
  404c13:	4c 89 e8             	mov    %r13,%rax
  404c16:	48 c1 e8 28          	shr    $0x28,%rax
  404c1a:	48 25 ff ff 00 00    	and    $0xffff,%rax
  404c20:	48 83 f8 18          	cmp    $0x18,%rax
  404c24:	0f 84 08 01 00 00    	je     404d32 <NF_FID_83_116_114_105_110_103_46_114_101_118_101_114_115_101_46_103_111_+0x152>
  404c2a:	48 83 f8 19          	cmp    $0x19,%rax
  404c2e:	0f 85 c9 00 00 00    	jne    404cfd <NF_FID_83_116_114_105_110_103_46_114_101_118_101_114_115_101_46_103_111_+0x11d>
  404c34:	bf 02 00 00 00       	mov    $0x2,%edi
  404c39:	e8 42 db ff ff       	callq  402780 <cls_fit>
  404c3e:	4d 89 e8             	mov    %r13,%r8
  404c41:	4c 89 e1             	mov    %r12,%rcx
  404c44:	89 c2                	mov    %eax,%edx
  404c46:	4d 89 c6             	mov    %r8,%r14
  404c49:	4c 8d 45 f0          	lea    -0x10(%rbp),%r8
  404c4d:	49 89 cd             	mov    %rcx,%r13
  404c50:	b9 02 00 00 00       	mov    $0x2,%ecx
  404c55:	41 89 d4             	mov    %edx,%r12d
  404c58:	4c 89 f2             	mov    %r14,%rdx
  404c5b:	48 8b 7d e0          	mov    -0x20(%rbp),%rdi
  404c5f:	48 8b 75 e8          	mov    -0x18(%rbp),%rsi
  404c63:	e8 b8 e8 ff ff       	callq  403520 <ctr_take>
  404c68:	44 89 e2             	mov    %r12d,%edx
  404c6b:	48 89 c1             	mov    %rax,%rcx
  404c6e:	48 8b 7d e0          	mov    -0x20(%rbp),%rdi
  404c72:	48 8b 75 e8          	mov    -0x18(%rbp),%rsi
  404c76:	e8 05 e0 ff ff       	callq  402c80 <spare_free>
  404c7b:	4c 8b 65 f0          	mov    -0x10(%rbp),%r12
  404c7f:	4c 8b 75 f8          	mov    -0x8(%rbp),%r14
  404c83:	bf 02 00 00 00       	mov    $0x2,%edi
  404c88:	e8 f3 da ff ff       	callq  402780 <cls_fit>
  404c8d:	89 c2                	mov    %eax,%edx
  404c8f:	48 8b 7d e0          	mov    -0x20(%rbp),%rdi
  404c93:	48 8b 75 e8          	mov    -0x18(%rbp),%rsi
  404c97:	e8 f4 de ff ff       	callq  402b90 <heap_alloc>
  404c9c:	4c 89 e2             	mov    %r12,%rdx
  404c9f:	49 89 c4             	mov    %rax,%r12
  404ca2:	48 8b 7d e0          	mov    -0x20(%rbp),%rdi
  404ca6:	48 8b 75 e8          	mov    -0x18(%rbp),%rsi
  404caa:	e8 11 e1 ff ff       	callq  402dc0 <rfc_seal>
  404caf:	4d 89 f9             	mov    %r15,%r9
  404cb2:	4c 89 e9             	mov    %r13,%rcx
  404cb5:	49 89 cd             	mov    %rcx,%r13
  404cb8:	48 8b 4d e0          	mov    -0x20(%rbp),%rcx
  404cbc:	4a 89 04 e1          	mov    %rax,(%rcx,%r12,8)
  404cc0:	4c 89 ca             	mov    %r9,%rdx
  404cc3:	48 8b 7d e0          	mov    -0x20(%rbp),%rdi
  404cc7:	48 8b 75 e8          	mov    -0x18(%rbp),%rsi
  404ccb:	e8 f0 e0 ff ff       	callq  402dc0 <rfc_seal>
  404cd0:	4d 89 f0             	mov    %r14,%r8
  404cd3:	4c 89 e9             	mov    %r13,%rcx
  404cd6:	48 8b 55 e0          	mov    -0x20(%rbp),%rdx
  404cda:	4a 89 44 e2 08       	mov    %rax,0x8(%rdx,%r12,8)
  404cdf:	48 b8 00 00 00 00 00 	movabs $0x200190000000000,%rax
  404ce6:	19 00 02 
  404ce9:	4d 89 e1             	mov    %r12,%r9
  404cec:	49 09 c1             	or     %rax,%r9
  404cef:	49 89 cc             	mov    %rcx,%r12
  404cf2:	4d 89 c5             	mov    %r8,%r13
  404cf5:	4d 89 cf             	mov    %r9,%r15
  404cf8:	e9 13 ff ff ff       	jmpq   404c10 <NF_FID_83_116_114_105_110_103_46_114_101_118_101_114_115_101_46_103_111_+0x30>
  404cfd:	4c 89 ea             	mov    %r13,%rdx
  404d00:	48 8b 7d e0          	mov    -0x20(%rbp),%rdi
  404d04:	48 8b 75 e8          	mov    -0x18(%rbp),%rsi
  404d08:	e8 e3 e6 ff ff       	callq  4033f0 <term_sink>
  404d0d:	4c 89 fa             	mov    %r15,%rdx
  404d10:	48 8b 7d e0          	mov    -0x20(%rbp),%rdi
  404d14:	48 8b 75 e8          	mov    -0x18(%rbp),%rsi
  404d18:	e8 d3 e6 ff ff       	callq  4033f0 <term_sink>
  404d1d:	48 8b 7d e0          	mov    -0x20(%rbp),%rdi
  404d21:	be 04 00 00 00       	mov    $0x4,%esi
  404d26:	e8 05 d9 ff ff       	callq  402630 <err_post>
  404d2b:	b8 00 00 00 00       	mov    $0x0,%eax
  404d30:	eb 09                	jmp    404d3b <NF_FID_83_116_114_105_110_103_46_114_101_118_101_114_115_101_46_103_111_+0x15b>
  404d32:	4d 89 3c 24          	mov    %r15,(%r12)
  404d36:	b8 01 00 00 00       	mov    $0x1,%eax
  404d3b:	41 5f                	pop    %r15
  404d3d:	41 5e                	pop    %r14
  404d3f:	41 5d                	pop    %r13
  404d41:	41 5c                	pop    %r12
  404d43:	5b                   	pop    %rbx
  404d44:	c9                   	leaveq 
  404d45:	c3                   	retq   

Disassembly of section .fini:
