
/home/ai/bend2/build/publish/bend/selfhost/build/phase108/successor-controls01/nt-reverse-build/program:     file format elf64-x86-64


Disassembly of section .init:

Disassembly of section .plt:

Disassembly of section .text:

0000000000404db0 <NF_FID_110_116_95_114_101_118_101_114_115_101_>:
  404db0:	f3 0f 1e fa          	endbr64 
  404db4:	55                   	push   %rbp
  404db5:	48 89 e5             	mov    %rsp,%rbp
  404db8:	48 83 ec 28          	sub    $0x28,%rsp
  404dbc:	53                   	push   %rbx
  404dbd:	41 54                	push   %r12
  404dbf:	41 55                	push   %r13
  404dc1:	41 56                	push   %r14
  404dc3:	41 57                	push   %r15
  404dc5:	4d 89 cf             	mov    %r9,%r15
  404dc8:	4c 89 c2             	mov    %r8,%rdx
  404dcb:	49 89 cc             	mov    %rcx,%r12
  404dce:	48 89 7d e0          	mov    %rdi,-0x20(%rbp)
  404dd2:	48 89 75 e8          	mov    %rsi,-0x18(%rbp)
  404dd6:	49 89 d5             	mov    %rdx,%r13
  404dd9:	bb 00 00 00 00       	mov    $0x0,%ebx
  404dde:	66 90                	xchg   %ax,%ax
  404de0:	83 c3 01             	add    $0x1,%ebx
  404de3:	4c 89 e8             	mov    %r13,%rax
  404de6:	48 c1 e8 28          	shr    $0x28,%rax
  404dea:	48 25 ff ff 00 00    	and    $0xffff,%rax
  404df0:	48 83 f8 11          	cmp    $0x11,%rax
  404df4:	0f 84 08 01 00 00    	je     404f02 <NF_FID_110_116_95_114_101_118_101_114_115_101_+0x152>
  404dfa:	48 83 f8 12          	cmp    $0x12,%rax
  404dfe:	0f 85 c9 00 00 00    	jne    404ecd <NF_FID_110_116_95_114_101_118_101_114_115_101_+0x11d>
  404e04:	bf 02 00 00 00       	mov    $0x2,%edi
  404e09:	e8 72 d9 ff ff       	callq  402780 <cls_fit>
  404e0e:	4d 89 e8             	mov    %r13,%r8
  404e11:	4c 89 e1             	mov    %r12,%rcx
  404e14:	89 c2                	mov    %eax,%edx
  404e16:	4d 89 c6             	mov    %r8,%r14
  404e19:	4c 8d 45 f0          	lea    -0x10(%rbp),%r8
  404e1d:	49 89 cd             	mov    %rcx,%r13
  404e20:	b9 02 00 00 00       	mov    $0x2,%ecx
  404e25:	41 89 d4             	mov    %edx,%r12d
  404e28:	4c 89 f2             	mov    %r14,%rdx
  404e2b:	48 8b 7d e0          	mov    -0x20(%rbp),%rdi
  404e2f:	48 8b 75 e8          	mov    -0x18(%rbp),%rsi
  404e33:	e8 e8 e6 ff ff       	callq  403520 <ctr_take>
  404e38:	44 89 e2             	mov    %r12d,%edx
  404e3b:	48 89 c1             	mov    %rax,%rcx
  404e3e:	48 8b 7d e0          	mov    -0x20(%rbp),%rdi
  404e42:	48 8b 75 e8          	mov    -0x18(%rbp),%rsi
  404e46:	e8 35 de ff ff       	callq  402c80 <spare_free>
  404e4b:	4c 8b 65 f0          	mov    -0x10(%rbp),%r12
  404e4f:	4c 8b 75 f8          	mov    -0x8(%rbp),%r14
  404e53:	bf 02 00 00 00       	mov    $0x2,%edi
  404e58:	e8 23 d9 ff ff       	callq  402780 <cls_fit>
  404e5d:	89 c2                	mov    %eax,%edx
  404e5f:	48 8b 7d e0          	mov    -0x20(%rbp),%rdi
  404e63:	48 8b 75 e8          	mov    -0x18(%rbp),%rsi
  404e67:	e8 24 dd ff ff       	callq  402b90 <heap_alloc>
  404e6c:	4c 89 e2             	mov    %r12,%rdx
  404e6f:	49 89 c4             	mov    %rax,%r12
  404e72:	48 8b 7d e0          	mov    -0x20(%rbp),%rdi
  404e76:	48 8b 75 e8          	mov    -0x18(%rbp),%rsi
  404e7a:	e8 41 df ff ff       	callq  402dc0 <rfc_seal>
  404e7f:	4d 89 f9             	mov    %r15,%r9
  404e82:	4c 89 e9             	mov    %r13,%rcx
  404e85:	49 89 cd             	mov    %rcx,%r13
  404e88:	48 8b 4d e0          	mov    -0x20(%rbp),%rcx
  404e8c:	4a 89 04 e1          	mov    %rax,(%rcx,%r12,8)
  404e90:	4c 89 ca             	mov    %r9,%rdx
  404e93:	48 8b 7d e0          	mov    -0x20(%rbp),%rdi
  404e97:	48 8b 75 e8          	mov    -0x18(%rbp),%rsi
  404e9b:	e8 20 df ff ff       	callq  402dc0 <rfc_seal>
  404ea0:	4d 89 f0             	mov    %r14,%r8
  404ea3:	4c 89 e9             	mov    %r13,%rcx
  404ea6:	48 8b 55 e0          	mov    -0x20(%rbp),%rdx
  404eaa:	4a 89 44 e2 08       	mov    %rax,0x8(%rdx,%r12,8)
  404eaf:	48 b8 00 00 00 00 00 	movabs $0x200120000000000,%rax
  404eb6:	12 00 02 
  404eb9:	4d 89 e1             	mov    %r12,%r9
  404ebc:	49 09 c1             	or     %rax,%r9
  404ebf:	49 89 cc             	mov    %rcx,%r12
  404ec2:	4d 89 c5             	mov    %r8,%r13
  404ec5:	4d 89 cf             	mov    %r9,%r15
  404ec8:	e9 13 ff ff ff       	jmpq   404de0 <NF_FID_110_116_95_114_101_118_101_114_115_101_+0x30>
  404ecd:	4c 89 ea             	mov    %r13,%rdx
  404ed0:	48 8b 7d e0          	mov    -0x20(%rbp),%rdi
  404ed4:	48 8b 75 e8          	mov    -0x18(%rbp),%rsi
  404ed8:	e8 13 e5 ff ff       	callq  4033f0 <term_sink>
  404edd:	4c 89 fa             	mov    %r15,%rdx
  404ee0:	48 8b 7d e0          	mov    -0x20(%rbp),%rdi
  404ee4:	48 8b 75 e8          	mov    -0x18(%rbp),%rsi
  404ee8:	e8 03 e5 ff ff       	callq  4033f0 <term_sink>
  404eed:	48 8b 7d e0          	mov    -0x20(%rbp),%rdi
  404ef1:	be 04 00 00 00       	mov    $0x4,%esi
  404ef6:	e8 35 d7 ff ff       	callq  402630 <err_post>
  404efb:	b8 00 00 00 00       	mov    $0x0,%eax
  404f00:	eb 09                	jmp    404f0b <NF_FID_110_116_95_114_101_118_101_114_115_101_+0x15b>
  404f02:	4d 89 3c 24          	mov    %r15,(%r12)
  404f06:	b8 01 00 00 00       	mov    $0x1,%eax
  404f0b:	41 5f                	pop    %r15
  404f0d:	41 5e                	pop    %r14
  404f0f:	41 5d                	pop    %r13
  404f11:	41 5c                	pop    %r12
  404f13:	5b                   	pop    %rbx
  404f14:	c9                   	leaveq 
  404f15:	c3                   	retq   

Disassembly of section .fini:
