0000000000408c10 <p113d_FID_36_100_105_114_101_99_116_46_112_105_120_101_108_>:
  408c10:	f3 0f 1e fa          	endbr64 
  408c14:	2e 55                	cs push %rbp
  408c16:	48 89 e5             	mov    %rsp,%rbp
  408c19:	48 81 ec 18 09 00 00 	sub    $0x918,%rsp
  408c20:	53                   	push   %rbx
  408c21:	41 54                	push   %r12
  408c23:	41 55                	push   %r13
  408c25:	41 56                	push   %r14
  408c27:	41 57                	push   %r15
  408c29:	4d 89 c5             	mov    %r8,%r13
  408c2c:	49 89 cc             	mov    %rcx,%r12
  408c2f:	48 89 fb             	mov    %rdi,%rbx
  408c32:	48 89 b5 f0 f6 ff ff 	mov    %rsi,-0x910(%rbp)
  408c39:	89 f0                	mov    %esi,%eax
  408c3b:	f3 48 0f 2a c0       	cvtsi2ss %rax,%xmm0
  408c40:	66 48 0f 7e c0       	movq   %xmm0,%rax
  408c45:	41 89 c6             	mov    %eax,%r14d
  408c48:	48 89 95 f0 f6 ff ff 	mov    %rdx,-0x910(%rbp)
  408c4f:	89 d0                	mov    %edx,%eax
  408c51:	f3 48 0f 2a c0       	cvtsi2ss %rax,%xmm0
  408c56:	66 48 0f 7e c0       	movq   %xmm0,%rax
  408c5b:	41 89 c7             	mov    %eax,%r15d
  408c5e:	4c 89 b5 f0 f6 ff ff 	mov    %r14,-0x910(%rbp)
  408c65:	48 c7 85 f8 f6 ff ff 00 00 80 3e 	movq   $0x3e800000,-0x908(%rbp)
  408c70:	66 49 0f 6e c6       	movq   %r14,%xmm0
  408c75:	f3 0f 11 45 cc       	movss  %xmm0,-0x34(%rbp)
  408c7a:	f3 0f 58 05 ca 83 02 00 	addss  0x283ca(%rip),%xmm0        # 43104c <_IO_stdin_used+0x4c>
  408c82:	66 48 0f 7e c0       	movq   %xmm0,%rax
  408c87:	89 c1                	mov    %eax,%ecx
  408c89:	48 89 4d 98          	mov    %rcx,-0x68(%rbp)
  408c8d:	48 89 8d f0 f6 ff ff 	mov    %rcx,-0x910(%rbp)
  408c94:	4c 89 a5 f8 f6 ff ff 	mov    %r12,-0x908(%rbp)
  408c9b:	66 48 0f 6e c1       	movq   %rcx,%xmm0
  408ca0:	66 49 0f 6e d4       	movq   %r12,%xmm2
  408ca5:	f3 0f 11 55 94       	movss  %xmm2,-0x6c(%rbp)
  408caa:	f3 0f 5c c2          	subss  %xmm2,%xmm0
  408cae:	66 48 0f 7e c0       	movq   %xmm0,%rax
  408cb3:	89 c0                	mov    %eax,%eax
  408cb5:	48 89 45 a0          	mov    %rax,-0x60(%rbp)
  408cb9:	48 89 85 f0 f6 ff ff 	mov    %rax,-0x910(%rbp)
  408cc0:	4c 89 a5 f8 f6 ff ff 	mov    %r12,-0x908(%rbp)
  408cc7:	66 48 0f 6e c0       	movq   %rax,%xmm0
  408ccc:	f3 0f 5e c2          	divss  %xmm2,%xmm0
  408cd0:	66 48 0f 7e c0       	movq   %xmm0,%rax
  408cd5:	89 c1                	mov    %eax,%ecx
  408cd7:	4c 89 bd f0 f6 ff ff 	mov    %r15,-0x910(%rbp)
  408cde:	48 c7 85 f8 f6 ff ff 00 00 80 3e 	movq   $0x3e800000,-0x908(%rbp)
  408ce9:	66 49 0f 6e df       	movq   %r15,%xmm3
  408cee:	f3 0f 11 5d a8       	movss  %xmm3,-0x58(%rbp)
  408cf3:	f3 0f 10 c3          	movss  %xmm3,%xmm0
  408cf7:	f3 0f 58 05 4d 83 02 00 	addss  0x2834d(%rip),%xmm0        # 43104c <_IO_stdin_used+0x4c>
  408cff:	66 48 0f 7e c0       	movq   %xmm0,%rax
  408d04:	89 c2                	mov    %eax,%edx
  408d06:	48 89 55 d0          	mov    %rdx,-0x30(%rbp)
  408d0a:	4c 89 ad f0 f6 ff ff 	mov    %r13,-0x910(%rbp)
  408d11:	48 89 95 f8 f6 ff ff 	mov    %rdx,-0x908(%rbp)
  408d18:	66 49 0f 6e cd       	movq   %r13,%xmm1
  408d1d:	f3 0f 11 4d ac       	movss  %xmm1,-0x54(%rbp)
  408d22:	66 48 0f 6e c2       	movq   %rdx,%xmm0
  408d27:	0f 57 05 e2 82 02 00 	xorps  0x282e2(%rip),%xmm0        # 431010 <_IO_stdin_used+0x10>
  408d2e:	f3 0f 58 c1          	addss  %xmm1,%xmm0
  408d32:	66 48 0f 7e c0       	movq   %xmm0,%rax
  408d37:	89 c0                	mov    %eax,%eax
  408d39:	48 89 45 d8          	mov    %rax,-0x28(%rbp)
  408d3d:	48 89 85 f0 f6 ff ff 	mov    %rax,-0x910(%rbp)
  408d44:	4c 89 a5 f8 f6 ff ff 	mov    %r12,-0x908(%rbp)
  408d4b:	66 48 0f 6e c0       	movq   %rax,%xmm0
  408d50:	f3 0f 5e c2          	divss  %xmm2,%xmm0
  408d54:	66 48 0f 7e c0       	movq   %xmm0,%rax
  408d59:	89 c0                	mov    %eax,%eax
  408d5b:	66 48 0f 6e d1       	movq   %rcx,%xmm2
  408d60:	f3 0f 11 55 90       	movss  %xmm2,-0x70(%rbp)
  408d65:	f3 0f 10 c2          	movss  %xmm2,%xmm0
  408d69:	f3 0f 59 c2          	mulss  %xmm2,%xmm0
  408d6d:	f3 0f 11 45 b0       	movss  %xmm0,-0x50(%rbp)
  408d72:	66 48 0f 6e c8       	movq   %rax,%xmm1
  408d77:	f3 0f 11 4d c8       	movss  %xmm1,-0x38(%rbp)
  408d7c:	f3 0f 59 c9          	mulss  %xmm1,%xmm1
  408d80:	f3 0f 11 4d e0       	movss  %xmm1,-0x20(%rbp)
  408d85:	f3 0f 58 c1          	addss  %xmm1,%xmm0
  408d89:	f3 0f 58 05 8f 82 02 00 	addss  0x2828f(%rip),%xmm0        # 431020 <_IO_stdin_used+0x20>
  408d91:	f3 0f 5a c0          	cvtss2sd %xmm0,%xmm0
  408d95:	e8 26 97 ff ff       	callq  4024c0 <sqrt@plt>
  408d9a:	4d 89 f1             	mov    %r14,%r9
  408d9d:	4d 89 e8             	mov    %r13,%r8
  408da0:	4c 89 e1             	mov    %r12,%rcx
  408da3:	48 89 df             	mov    %rbx,%rdi
  408da6:	f3 0f 10 4d c8       	movss  -0x38(%rbp),%xmm1
  408dab:	f3 0f 10 55 90       	movss  -0x70(%rbp),%xmm2
  408db0:	f2 0f 5a c0          	cvtsd2ss %xmm0,%xmm0
  408db4:	f3 0f 5e d0          	divss  %xmm0,%xmm2
  408db8:	66 48 0f 7e d0       	movq   %xmm2,%rax
  408dbd:	89 c0                	mov    %eax,%eax
  408dbf:	f3 0f 10 e1          	movss  %xmm1,%xmm4
  408dc3:	f3 0f 5e e0          	divss  %xmm0,%xmm4
  408dc7:	66 48 0f 7e e2       	movq   %xmm4,%rdx
  408dcc:	89 d6                	mov    %edx,%esi
  408dce:	48 89 75 e8          	mov    %rsi,-0x18(%rbp)
  408dd2:	f3 0f 10 2d 46 82 02 00 	movss  0x28246(%rip),%xmm5        # 431020 <_IO_stdin_used+0x20>
  408dda:	f3 0f 5e e8          	divss  %xmm0,%xmm5
  408dde:	66 48 0f 7e ea       	movq   %xmm5,%rdx
  408de3:	89 d2                	mov    %edx,%edx
  408de5:	48 89 55 f0          	mov    %rdx,-0x10(%rbp)
  408de9:	66 48 0f 6e c0       	movq   %rax,%xmm0
  408dee:	f3 0f 11 45 e4       	movss  %xmm0,-0x1c(%rbp)
  408df3:	48 83 ec 10          	sub    $0x10,%rsp
  408df7:	48 89 e0             	mov    %rsp,%rax
  408dfa:	48 c7 40 08 00 00 00 00 	movq   $0x0,0x8(%rax)
  408e02:	48 c7 00 09 00 00 00 	movq   $0x9,(%rax)
  408e09:	4d 89 ce             	mov    %r9,%r14
  408e0c:	41 b9 28 6b 6e 4e    	mov    $0x4e6e6b28,%r9d
  408e12:	4d 89 c5             	mov    %r8,%r13
  408e15:	41 b8 09 00 00 00    	mov    $0x9,%r8d
  408e1b:	49 89 cc             	mov    %rcx,%r12
  408e1e:	b9 28 6b 6e 4e       	mov    $0x4e6e6b28,%ecx
  408e23:	f3 0f 10 d8          	movss  %xmm0,%xmm3
  408e27:	f3 0f 10 15 f5 81 02 00 	movss  0x281f5(%rip),%xmm2        # 431024 <_IO_stdin_used+0x24>
  408e2f:	f3 0f 10 0d ed 81 02 00 	movss  0x281ed(%rip),%xmm1        # 431024 <_IO_stdin_used+0x24>
  408e37:	f3 0f 10 05 e5 81 02 00 	movss  0x281e5(%rip),%xmm0        # 431024 <_IO_stdin_used+0x24>
  408e3f:	ba 09 00 00 00       	mov    $0x9,%edx
  408e44:	48 8d b5 f0 fe ff ff 	lea    -0x110(%rbp),%rsi
  408e4b:	48 89 fb             	mov    %rdi,%rbx
  408e4e:	e8 ed d9 ff ff       	callq  406840 <p126_typed_FID_36_112_114_111_100_117_99_116_46_110_101_97_114_101_115_116_>
  408e53:	4d 89 f1             	mov    %r14,%r9
  408e56:	4d 89 e8             	mov    %r13,%r8
  408e59:	4c 89 e1             	mov    %r12,%rcx
  408e5c:	48 89 df             	mov    %rbx,%rdi
  408e5f:	48 8b 45 f0          	mov    -0x10(%rbp),%rax
  408e63:	48 8b 75 e8          	mov    -0x18(%rbp),%rsi
  408e67:	f3 0f 10 65 e4       	movss  -0x1c(%rbp),%xmm4
  408e6c:	48 83 ec f0          	sub    $0xfffffffffffffff0,%rsp
  408e70:	48 8b 95 f0 fe ff ff 	mov    -0x110(%rbp),%rdx
  408e77:	4d 89 ce             	mov    %r9,%r14
  408e7a:	4c 8b 8d f8 fe ff ff 	mov    -0x108(%rbp),%r9
  408e81:	49 89 cc             	mov    %rcx,%r12
  408e84:	48 8b 8d 00 ff ff ff 	mov    -0x100(%rbp),%rcx
  408e8b:	66 49 0f 6e c1       	movq   %r9,%xmm0
  408e90:	66 48 0f 6e ee       	movq   %rsi,%xmm5
  408e95:	66 48 0f 6e f0       	movq   %rax,%xmm6
  408e9a:	f3 0f 10 3d 7e 81 02 00 	movss  0x2817e(%rip),%xmm7        # 431020 <_IO_stdin_used+0x20>
  408ea2:	4d 89 c5             	mov    %r8,%r13
  408ea5:	41 b8 00 00 00 00    	mov    $0x0,%r8d
  408eab:	f3 0f 10 1d 71 81 02 00 	movss  0x28171(%rip),%xmm3        # 431024 <_IO_stdin_used+0x24>
  408eb3:	f3 0f 10 15 69 81 02 00 	movss  0x28169(%rip),%xmm2        # 431024 <_IO_stdin_used+0x24>
  408ebb:	f3 0f 10 0d 61 81 02 00 	movss  0x28161(%rip),%xmm1        # 431024 <_IO_stdin_used+0x24>
  408ec3:	be 04 00 00 00       	mov    $0x4,%esi
  408ec8:	48 89 fb             	mov    %rdi,%rbx
  408ecb:	e8 20 e6 ff ff       	callq  4074f0 <p126_typed_FID_36_112_114_111_100_117_99_116_46_116_114_97_99_101_>
  408ed0:	4c 89 e1             	mov    %r12,%rcx
  408ed3:	48 89 df             	mov    %rbx,%rdi
  408ed6:	48 89 85 68 ff ff ff 	mov    %rax,-0x98(%rbp)
  408edd:	49 89 cc             	mov    %rcx,%r12
  408ee0:	48 8b 4d d8          	mov    -0x28(%rbp),%rcx
  408ee4:	48 8b 55 d0          	mov    -0x30(%rbp),%rdx
  408ee8:	f3 0f 10 4d e0       	movss  -0x20(%rbp),%xmm1
  408eed:	f3 0f 10 55 94       	movss  -0x6c(%rbp),%xmm2
  408ef2:	f3 0f 10 45 cc       	movss  -0x34(%rbp),%xmm0
  408ef7:	4c 89 b5 f0 f6 ff ff 	mov    %r14,-0x910(%rbp)
  408efe:	48 c7 85 f8 f6 ff ff 00 00 40 3f 	movq   $0x3f400000,-0x908(%rbp)
  408f09:	f3 0f 58 05 3f 81 02 00 	addss  0x2813f(%rip),%xmm0        # 431050 <_IO_stdin_used+0x50>
  408f11:	66 48 0f 7e c0       	movq   %xmm0,%rax
  408f16:	48 89 fb             	mov    %rdi,%rbx
  408f19:	89 c7                	mov    %eax,%edi
  408f1b:	48 89 bd 48 ff ff ff 	mov    %rdi,-0xb8(%rbp)
  408f22:	48 89 bd f0 f6 ff ff 	mov    %rdi,-0x910(%rbp)
  408f29:	4c 89 a5 f8 f6 ff ff 	mov    %r12,-0x908(%rbp)
  408f30:	66 48 0f 6e c7       	movq   %rdi,%xmm0
  408f35:	f3 0f 5c c2          	subss  %xmm2,%xmm0
  408f39:	66 48 0f 7e c0       	movq   %xmm0,%rax
  408f3e:	89 c6                	mov    %eax,%esi
  408f40:	48 89 b5 50 ff ff ff 	mov    %rsi,-0xb0(%rbp)
  408f47:	48 89 b5 f0 f6 ff ff 	mov    %rsi,-0x910(%rbp)
  408f4e:	4c 89 a5 f8 f6 ff ff 	mov    %r12,-0x908(%rbp)
  408f55:	66 48 0f 6e c6       	movq   %rsi,%xmm0
  408f5a:	f3 0f 5e c2          	divss  %xmm2,%xmm0
  408f5e:	66 48 0f 7e c0       	movq   %xmm0,%rax
  408f63:	89 c0                	mov    %eax,%eax
  408f65:	4c 89 bd f0 f6 ff ff 	mov    %r15,-0x910(%rbp)
  408f6c:	48 c7 85 f8 f6 ff ff 00 00 80 3e 	movq   $0x3e800000,-0x908(%rbp)
  408f77:	4c 89 ad f0 f6 ff ff 	mov    %r13,-0x910(%rbp)
  408f7e:	48 89 95 f8 f6 ff ff 	mov    %rdx,-0x908(%rbp)
  408f85:	48 89 8d f0 f6 ff ff 	mov    %rcx,-0x910(%rbp)
  408f8c:	4c 89 a5 f8 f6 ff ff 	mov    %r12,-0x908(%rbp)
  408f93:	66 48 0f 6e d0       	movq   %rax,%xmm2
  408f98:	f3 0f 11 95 3c ff ff ff 	movss  %xmm2,-0xc4(%rbp)
  408fa0:	f3 0f 10 c2          	movss  %xmm2,%xmm0
  408fa4:	f3 0f 59 c2          	mulss  %xmm2,%xmm0
  408fa8:	f3 0f 11 85 44 ff ff ff 	movss  %xmm0,-0xbc(%rbp)
  408fb0:	f3 0f 58 c1          	addss  %xmm1,%xmm0
  408fb4:	f3 0f 58 05 64 80 02 00 	addss  0x28064(%rip),%xmm0        # 431020 <_IO_stdin_used+0x20>
  408fbc:	f3 0f 5a c0          	cvtss2sd %xmm0,%xmm0
  408fc0:	e8 fb 94 ff ff       	callq  4024c0 <sqrt@plt>
  408fc5:	4d 89 f1             	mov    %r14,%r9
  408fc8:	4d 89 e8             	mov    %r13,%r8
  408fcb:	4c 89 e1             	mov    %r12,%rcx
  408fce:	48 89 df             	mov    %rbx,%rdi
  408fd1:	f3 0f 10 95 3c ff ff ff 	movss  -0xc4(%rbp),%xmm2
  408fd9:	f3 0f 10 4d c8       	movss  -0x38(%rbp),%xmm1
  408fde:	f2 0f 5a c0          	cvtsd2ss %xmm0,%xmm0
  408fe2:	f3 0f 5e d0          	divss  %xmm0,%xmm2
  408fe6:	66 48 0f 7e d0       	movq   %xmm2,%rax
  408feb:	89 c0                	mov    %eax,%eax
  408fed:	f3 0f 10 e1          	movss  %xmm1,%xmm4
  408ff1:	f3 0f 5e e0          	divss  %xmm0,%xmm4
  408ff5:	66 48 0f 7e e2       	movq   %xmm4,%rdx
  408ffa:	89 d6                	mov    %edx,%esi
  408ffc:	48 89 75 b8          	mov    %rsi,-0x48(%rbp)
  409000:	f3 0f 10 2d 18 80 02 00 	movss  0x28018(%rip),%xmm5        # 431020 <_IO_stdin_used+0x20>
  409008:	f3 0f 5e e8          	divss  %xmm0,%xmm5
  40900c:	66 48 0f 7e ea       	movq   %xmm5,%rdx
  409011:	89 d2                	mov    %edx,%edx
  409013:	48 89 55 c0          	mov    %rdx,-0x40(%rbp)
  409017:	66 48 0f 6e c0       	movq   %rax,%xmm0
  40901c:	f3 0f 11 45 b4       	movss  %xmm0,-0x4c(%rbp)
  409021:	48 83 ec 10          	sub    $0x10,%rsp
  409025:	48 89 e0             	mov    %rsp,%rax
  409028:	48 c7 40 08 00 00 00 00 	movq   $0x0,0x8(%rax)
  409030:	48 c7 00 09 00 00 00 	movq   $0x9,(%rax)
  409037:	4d 89 ce             	mov    %r9,%r14
  40903a:	41 b9 28 6b 6e 4e    	mov    $0x4e6e6b28,%r9d
  409040:	4d 89 c5             	mov    %r8,%r13
  409043:	41 b8 09 00 00 00    	mov    $0x9,%r8d
  409049:	49 89 cc             	mov    %rcx,%r12
  40904c:	b9 28 6b 6e 4e       	mov    $0x4e6e6b28,%ecx
  409051:	f3 0f 10 d8          	movss  %xmm0,%xmm3
  409055:	f3 0f 10 15 c7 7f 02 00 	movss  0x27fc7(%rip),%xmm2        # 431024 <_IO_stdin_used+0x24>
  40905d:	f3 0f 10 0d bf 7f 02 00 	movss  0x27fbf(%rip),%xmm1        # 431024 <_IO_stdin_used+0x24>
  409065:	f3 0f 10 05 b7 7f 02 00 	movss  0x27fb7(%rip),%xmm0        # 431024 <_IO_stdin_used+0x24>
  40906d:	ba 09 00 00 00       	mov    $0x9,%edx
  409072:	48 8d b5 f0 fe ff ff 	lea    -0x110(%rbp),%rsi
  409079:	48 89 fb             	mov    %rdi,%rbx
  40907c:	e8 bf d7 ff ff       	callq  406840 <p126_typed_FID_36_112_114_111_100_117_99_116_46_110_101_97_114_101_115_116_>
  409081:	4d 89 f1             	mov    %r14,%r9
  409084:	4d 89 e8             	mov    %r13,%r8
  409087:	4c 89 e1             	mov    %r12,%rcx
  40908a:	48 89 df             	mov    %rbx,%rdi
  40908d:	48 8b 45 c0          	mov    -0x40(%rbp),%rax
  409091:	48 8b 75 b8          	mov    -0x48(%rbp),%rsi
  409095:	f3 0f 10 65 b4       	movss  -0x4c(%rbp),%xmm4
  40909a:	48 83 ec f0          	sub    $0xfffffffffffffff0,%rsp
  40909e:	48 8b 95 f0 fe ff ff 	mov    -0x110(%rbp),%rdx
  4090a5:	4d 89 ce             	mov    %r9,%r14
  4090a8:	4c 8b 8d f8 fe ff ff 	mov    -0x108(%rbp),%r9
  4090af:	49 89 cc             	mov    %rcx,%r12
  4090b2:	48 8b 8d 00 ff ff ff 	mov    -0x100(%rbp),%rcx
  4090b9:	66 49 0f 6e c1       	movq   %r9,%xmm0
  4090be:	66 48 0f 6e ee       	movq   %rsi,%xmm5
  4090c3:	66 48 0f 6e f0       	movq   %rax,%xmm6
  4090c8:	f3 0f 10 3d 50 7f 02 00 	movss  0x27f50(%rip),%xmm7        # 431020 <_IO_stdin_used+0x20>
  4090d0:	4d 89 c5             	mov    %r8,%r13
  4090d3:	41 b8 00 00 00 00    	mov    $0x0,%r8d
  4090d9:	f3 0f 10 1d 43 7f 02 00 	movss  0x27f43(%rip),%xmm3        # 431024 <_IO_stdin_used+0x24>
  4090e1:	f3 0f 10 15 3b 7f 02 00 	movss  0x27f3b(%rip),%xmm2        # 431024 <_IO_stdin_used+0x24>
  4090e9:	f3 0f 10 0d 33 7f 02 00 	movss  0x27f33(%rip),%xmm1        # 431024 <_IO_stdin_used+0x24>
  4090f1:	be 04 00 00 00       	mov    $0x4,%esi
  4090f6:	48 89 fb             	mov    %rdi,%rbx
  4090f9:	e8 f2 e3 ff ff       	callq  4074f0 <p126_typed_FID_36_112_114_111_100_117_99_116_46_116_114_97_99_101_>
  4090fe:	4c 89 e1             	mov    %r12,%rcx
  409101:	48 89 85 70 ff ff ff 	mov    %rax,-0x90(%rbp)
  409108:	48 8b 45 a0          	mov    -0x60(%rbp),%rax
  40910c:	49 89 cc             	mov    %rcx,%r12
  40910f:	48 8b 4d 98          	mov    -0x68(%rbp),%rcx
  409113:	f3 0f 10 45 b0       	movss  -0x50(%rbp),%xmm0
  409118:	f3 0f 10 4d ac       	movss  -0x54(%rbp),%xmm1
  40911d:	f3 0f 10 5d a8       	movss  -0x58(%rbp),%xmm3
  409122:	f3 0f 10 55 94       	movss  -0x6c(%rbp),%xmm2
  409127:	4c 89 b5 f0 f6 ff ff 	mov    %r14,-0x910(%rbp)
  40912e:	48 c7 85 f8 f6 ff ff 00 00 80 3e 	movq   $0x3e800000,-0x908(%rbp)
  409139:	48 89 8d f0 f6 ff ff 	mov    %rcx,-0x910(%rbp)
  409140:	4c 89 a5 f8 f6 ff ff 	mov    %r12,-0x908(%rbp)
  409147:	48 89 85 f0 f6 ff ff 	mov    %rax,-0x910(%rbp)
  40914e:	4c 89 a5 f8 f6 ff ff 	mov    %r12,-0x908(%rbp)
  409155:	4c 89 bd f0 f6 ff ff 	mov    %r15,-0x910(%rbp)
  40915c:	48 c7 85 f8 f6 ff ff 00 00 40 3f 	movq   $0x3f400000,-0x908(%rbp)
  409167:	f3 0f 58 1d e1 7e 02 00 	addss  0x27ee1(%rip),%xmm3        # 431050 <_IO_stdin_used+0x50>
  40916f:	66 48 0f 7e d8       	movq   %xmm3,%rax
  409174:	89 c2                	mov    %eax,%edx
  409176:	48 89 95 58 ff ff ff 	mov    %rdx,-0xa8(%rbp)
  40917d:	4c 89 ad f0 f6 ff ff 	mov    %r13,-0x910(%rbp)
  409184:	48 89 95 f8 f6 ff ff 	mov    %rdx,-0x908(%rbp)
  40918b:	66 48 0f 6e da       	movq   %rdx,%xmm3
  409190:	f3 0f 5c cb          	subss  %xmm3,%xmm1
  409194:	66 48 0f 7e c8       	movq   %xmm1,%rax
  409199:	89 c0                	mov    %eax,%eax
  40919b:	48 89 85 60 ff ff ff 	mov    %rax,-0xa0(%rbp)
  4091a2:	48 89 85 f0 f6 ff ff 	mov    %rax,-0x910(%rbp)
  4091a9:	4c 89 a5 f8 f6 ff ff 	mov    %r12,-0x908(%rbp)
  4091b0:	66 48 0f 6e c8       	movq   %rax,%xmm1
  4091b5:	f3 0f 5e ca          	divss  %xmm2,%xmm1
  4091b9:	66 48 0f 7e c8       	movq   %xmm1,%rax
  4091be:	89 c0                	mov    %eax,%eax
  4091c0:	66 48 0f 6e c8       	movq   %rax,%xmm1
  4091c5:	f3 0f 11 8d 40 ff ff ff 	movss  %xmm1,-0xc0(%rbp)
  4091cd:	f3 0f 59 c9          	mulss  %xmm1,%xmm1
  4091d1:	f3 0f 11 8d 78 ff ff ff 	movss  %xmm1,-0x88(%rbp)
  4091d9:	f3 0f 58 c1          	addss  %xmm1,%xmm0
  4091dd:	f3 0f 58 05 3b 7e 02 00 	addss  0x27e3b(%rip),%xmm0        # 431020 <_IO_stdin_used+0x20>
  4091e5:	f3 0f 5a c0          	cvtss2sd %xmm0,%xmm0
  4091e9:	e8 d2 92 ff ff       	callq  4024c0 <sqrt@plt>
  4091ee:	4d 89 f1             	mov    %r14,%r9
  4091f1:	4d 89 e8             	mov    %r13,%r8
  4091f4:	4c 89 e1             	mov    %r12,%rcx
  4091f7:	48 89 df             	mov    %rbx,%rdi
  4091fa:	f3 0f 10 8d 40 ff ff ff 	movss  -0xc0(%rbp),%xmm1
  409202:	f3 0f 10 55 90       	movss  -0x70(%rbp),%xmm2
  409207:	f2 0f 5a c0          	cvtsd2ss %xmm0,%xmm0
  40920b:	f3 0f 5e d0          	divss  %xmm0,%xmm2
  40920f:	66 48 0f 7e d0       	movq   %xmm2,%rax
  409214:	89 c0                	mov    %eax,%eax
  409216:	f3 0f 10 e1          	movss  %xmm1,%xmm4
  40921a:	f3 0f 5e e0          	divss  %xmm0,%xmm4
  40921e:	66 48 0f 7e e2       	movq   %xmm4,%rdx
  409223:	89 d6                	mov    %edx,%esi
  409225:	48 89 75 80          	mov    %rsi,-0x80(%rbp)
  409229:	f3 0f 10 2d ef 7d 02 00 	movss  0x27def(%rip),%xmm5        # 431020 <_IO_stdin_used+0x20>
  409231:	f3 0f 5e e8          	divss  %xmm0,%xmm5
  409235:	66 48 0f 7e ea       	movq   %xmm5,%rdx
  40923a:	89 d2                	mov    %edx,%edx
  40923c:	48 89 55 88          	mov    %rdx,-0x78(%rbp)
  409240:	66 48 0f 6e c0       	movq   %rax,%xmm0
  409245:	f3 0f 11 85 7c ff ff ff 	movss  %xmm0,-0x84(%rbp)
  40924d:	48 83 ec 10          	sub    $0x10,%rsp
  409251:	48 89 e0             	mov    %rsp,%rax
  409254:	48 c7 40 08 00 00 00 00 	movq   $0x0,0x8(%rax)
  40925c:	48 c7 00 09 00 00 00 	movq   $0x9,(%rax)
  409263:	4d 89 ce             	mov    %r9,%r14
  409266:	41 b9 28 6b 6e 4e    	mov    $0x4e6e6b28,%r9d
  40926c:	4d 89 c5             	mov    %r8,%r13
  40926f:	41 b8 09 00 00 00    	mov    $0x9,%r8d
  409275:	49 89 cc             	mov    %rcx,%r12
  409278:	b9 28 6b 6e 4e       	mov    $0x4e6e6b28,%ecx
  40927d:	f3 0f 10 d8          	movss  %xmm0,%xmm3
  409281:	f3 0f 10 15 9b 7d 02 00 	movss  0x27d9b(%rip),%xmm2        # 431024 <_IO_stdin_used+0x24>
  409289:	f3 0f 10 0d 93 7d 02 00 	movss  0x27d93(%rip),%xmm1        # 431024 <_IO_stdin_used+0x24>
  409291:	f3 0f 10 05 8b 7d 02 00 	movss  0x27d8b(%rip),%xmm0        # 431024 <_IO_stdin_used+0x24>
  409299:	ba 09 00 00 00       	mov    $0x9,%edx
  40929e:	48 8d b5 f0 fe ff ff 	lea    -0x110(%rbp),%rsi
  4092a5:	48 89 fb             	mov    %rdi,%rbx
  4092a8:	e8 93 d5 ff ff       	callq  406840 <p126_typed_FID_36_112_114_111_100_117_99_116_46_110_101_97_114_101_115_116_>
  4092ad:	4d 89 f1             	mov    %r14,%r9
  4092b0:	4d 89 e8             	mov    %r13,%r8
  4092b3:	4c 89 e1             	mov    %r12,%rcx
  4092b6:	48 89 df             	mov    %rbx,%rdi
  4092b9:	48 8b 45 88          	mov    -0x78(%rbp),%rax
  4092bd:	48 8b 75 80          	mov    -0x80(%rbp),%rsi
  4092c1:	f3 0f 10 a5 7c ff ff ff 	movss  -0x84(%rbp),%xmm4
  4092c9:	48 83 ec f0          	sub    $0xfffffffffffffff0,%rsp
  4092cd:	48 8b 95 f0 fe ff ff 	mov    -0x110(%rbp),%rdx
  4092d4:	4d 89 ce             	mov    %r9,%r14
  4092d7:	4c 8b 8d f8 fe ff ff 	mov    -0x108(%rbp),%r9
  4092de:	49 89 cc             	mov    %rcx,%r12
  4092e1:	48 8b 8d 00 ff ff ff 	mov    -0x100(%rbp),%rcx
  4092e8:	66 49 0f 6e c1       	movq   %r9,%xmm0
  4092ed:	66 48 0f 6e ee       	movq   %rsi,%xmm5
  4092f2:	66 48 0f 6e f0       	movq   %rax,%xmm6
  4092f7:	f3 0f 10 3d 21 7d 02 00 	movss  0x27d21(%rip),%xmm7        # 431020 <_IO_stdin_used+0x20>
  4092ff:	4d 89 c5             	mov    %r8,%r13
  409302:	41 b8 00 00 00 00    	mov    $0x0,%r8d
  409308:	f3 0f 10 1d 14 7d 02 00 	movss  0x27d14(%rip),%xmm3        # 431024 <_IO_stdin_used+0x24>
  409310:	f3 0f 10 15 0c 7d 02 00 	movss  0x27d0c(%rip),%xmm2        # 431024 <_IO_stdin_used+0x24>
  409318:	f3 0f 10 0d 04 7d 02 00 	movss  0x27d04(%rip),%xmm1        # 431024 <_IO_stdin_used+0x24>
  409320:	be 04 00 00 00       	mov    $0x4,%esi
  409325:	48 89 fb             	mov    %rdi,%rbx
  409328:	e8 c3 e1 ff ff       	callq  4074f0 <p126_typed_FID_36_112_114_111_100_117_99_116_46_116_114_97_99_101_>
  40932d:	4d 89 f1             	mov    %r14,%r9
  409330:	4d 89 e8             	mov    %r13,%r8
  409333:	4c 89 e1             	mov    %r12,%rcx
  409336:	48 89 df             	mov    %rbx,%rdi
  409339:	48 89 c3             	mov    %rax,%rbx
  40933c:	48 8b 85 60 ff ff ff 	mov    -0xa0(%rbp),%rax
  409343:	48 8b 95 58 ff ff ff 	mov    -0xa8(%rbp),%rdx
  40934a:	48 8b b5 50 ff ff ff 	mov    -0xb0(%rbp),%rsi
  409351:	49 89 fe             	mov    %rdi,%r14
  409354:	48 8b bd 48 ff ff ff 	mov    -0xb8(%rbp),%rdi
  40935b:	f3 0f 10 8d 78 ff ff ff 	movss  -0x88(%rbp),%xmm1
  409363:	4c 8b a5 70 ff ff ff 	mov    -0x90(%rbp),%r12
  40936a:	f3 0f 10 85 44 ff ff ff 	movss  -0xbc(%rbp),%xmm0
  409372:	4c 8b ad 68 ff ff ff 	mov    -0x98(%rbp),%r13
  409379:	4c 89 8d f0 f6 ff ff 	mov    %r9,-0x910(%rbp)
  409380:	48 c7 85 f8 f6 ff ff 00 00 40 3f 	movq   $0x3f400000,-0x908(%rbp)
  40938b:	48 89 bd f0 f6 ff ff 	mov    %rdi,-0x910(%rbp)
  409392:	48 89 8d f8 f6 ff ff 	mov    %rcx,-0x908(%rbp)
  409399:	48 89 b5 f0 f6 ff ff 	mov    %rsi,-0x910(%rbp)
  4093a0:	48 89 8d f8 f6 ff ff 	mov    %rcx,-0x908(%rbp)
  4093a7:	4c 89 bd f0 f6 ff ff 	mov    %r15,-0x910(%rbp)
  4093ae:	48 c7 85 f8 f6 ff ff 00 00 40 3f 	movq   $0x3f400000,-0x908(%rbp)
  4093b9:	4c 89 85 f0 f6 ff ff 	mov    %r8,-0x910(%rbp)
  4093c0:	48 89 95 f8 f6 ff ff 	mov    %rdx,-0x908(%rbp)
  4093c7:	48 89 85 f0 f6 ff ff 	mov    %rax,-0x910(%rbp)
  4093ce:	48 89 8d f8 f6 ff ff 	mov    %rcx,-0x908(%rbp)
  4093d5:	f3 0f 58 c1          	addss  %xmm1,%xmm0
  4093d9:	f3 0f 58 05 3f 7c 02 00 	addss  0x27c3f(%rip),%xmm0        # 431020 <_IO_stdin_used+0x20>
  4093e1:	f3 0f 5a c0          	cvtss2sd %xmm0,%xmm0
  4093e5:	e8 d6 90 ff ff       	callq  4024c0 <sqrt@plt>
  4093ea:	4c 89 f7             	mov    %r14,%rdi
  4093ed:	f3 0f 10 8d 40 ff ff ff 	movss  -0xc0(%rbp),%xmm1
  4093f5:	f3 0f 10 95 3c ff ff ff 	movss  -0xc4(%rbp),%xmm2
  4093fd:	f2 0f 5a c0          	cvtsd2ss %xmm0,%xmm0
  409401:	f3 0f 5e d0          	divss  %xmm0,%xmm2
  409405:	66 48 0f 7e d0       	movq   %xmm2,%rax
  40940a:	89 c0                	mov    %eax,%eax
  40940c:	f3 0f 10 e1          	movss  %xmm1,%xmm4
  409410:	f3 0f 5e e0          	divss  %xmm0,%xmm4
  409414:	66 48 0f 7e e1       	movq   %xmm4,%rcx
  409419:	41 89 ce             	mov    %ecx,%r14d
  40941c:	f3 0f 10 2d fc 7b 02 00 	movss  0x27bfc(%rip),%xmm5        # 431020 <_IO_stdin_used+0x20>
  409424:	f3 0f 5e e8          	divss  %xmm0,%xmm5
  409428:	66 48 0f 7e e9       	movq   %xmm5,%rcx
  40942d:	89 c9                	mov    %ecx,%ecx
  40942f:	48 89 8d 30 ff ff ff 	mov    %rcx,-0xd0(%rbp)
  409436:	66 48 0f 6e c0       	movq   %rax,%xmm0
  40943b:	f3 0f 11 85 38 ff ff ff 	movss  %xmm0,-0xc8(%rbp)
  409443:	48 83 ec 10          	sub    $0x10,%rsp
  409447:	48 89 e0             	mov    %rsp,%rax
  40944a:	48 c7 40 08 00 00 00 00 	movq   $0x0,0x8(%rax)
  409452:	48 c7 00 09 00 00 00 	movq   $0x9,(%rax)
  409459:	41 b9 28 6b 6e 4e    	mov    $0x4e6e6b28,%r9d
  40945f:	41 b8 09 00 00 00    	mov    $0x9,%r8d
  409465:	b9 28 6b 6e 4e       	mov    $0x4e6e6b28,%ecx
  40946a:	f3 0f 10 d8          	movss  %xmm0,%xmm3
  40946e:	f3 0f 10 15 ae 7b 02 00 	movss  0x27bae(%rip),%xmm2        # 431024 <_IO_stdin_used+0x24>
  409476:	f3 0f 10 0d a6 7b 02 00 	movss  0x27ba6(%rip),%xmm1        # 431024 <_IO_stdin_used+0x24>
  40947e:	f3 0f 10 05 9e 7b 02 00 	movss  0x27b9e(%rip),%xmm0        # 431024 <_IO_stdin_used+0x24>
  409486:	ba 09 00 00 00       	mov    $0x9,%edx
  40948b:	48 8d b5 f0 fe ff ff 	lea    -0x110(%rbp),%rsi
  409492:	49 89 ff             	mov    %rdi,%r15
  409495:	e8 a6 d3 ff ff       	callq  406840 <p126_typed_FID_36_112_114_111_100_117_99_116_46_110_101_97_114_101_115_116_>
  40949a:	4c 89 ff             	mov    %r15,%rdi
  40949d:	48 8b 85 30 ff ff ff 	mov    -0xd0(%rbp),%rax
  4094a4:	f3 0f 10 a5 38 ff ff ff 	movss  -0xc8(%rbp),%xmm4
  4094ac:	48 83 ec f0          	sub    $0xfffffffffffffff0,%rsp
  4094b0:	48 8b 95 f0 fe ff ff 	mov    -0x110(%rbp),%rdx
  4094b7:	48 8b b5 f8 fe ff ff 	mov    -0x108(%rbp),%rsi
  4094be:	48 8b 8d 00 ff ff ff 	mov    -0x100(%rbp),%rcx
  4094c5:	66 48 0f 6e c6       	movq   %rsi,%xmm0
  4094ca:	66 49 0f 6e ee       	movq   %r14,%xmm5
  4094cf:	66 48 0f 6e f0       	movq   %rax,%xmm6
  4094d4:	f3 0f 10 3d 44 7b 02 00 	movss  0x27b44(%rip),%xmm7        # 431020 <_IO_stdin_used+0x20>
  4094dc:	41 b8 00 00 00 00    	mov    $0x0,%r8d
  4094e2:	f3 0f 10 1d 3a 7b 02 00 	movss  0x27b3a(%rip),%xmm3        # 431024 <_IO_stdin_used+0x24>
  4094ea:	f3 0f 10 15 32 7b 02 00 	movss  0x27b32(%rip),%xmm2        # 431024 <_IO_stdin_used+0x24>
  4094f2:	f3 0f 10 0d 2a 7b 02 00 	movss  0x27b2a(%rip),%xmm1        # 431024 <_IO_stdin_used+0x24>
  4094fa:	be 04 00 00 00       	mov    $0x4,%esi
  4094ff:	49 89 fe             	mov    %rdi,%r14
  409502:	e8 e9 df ff ff       	callq  4074f0 <p126_typed_FID_36_112_114_111_100_117_99_116_46_116_114_97_99_101_>
  409507:	4c 89 f7             	mov    %r14,%rdi
  40950a:	48 c7 85 f0 f6 ff ff ff 00 00 00 	movq   $0xff,-0x910(%rbp)
  409515:	4c 89 ad f0 f6 ff ff 	mov    %r13,-0x910(%rbp)
  40951c:	4c 89 a5 f8 f6 ff ff 	mov    %r12,-0x908(%rbp)
  409523:	66 49 0f 6e c5       	movq   %r13,%xmm0
  409528:	66 49 0f 6e cc       	movq   %r12,%xmm1
  40952d:	f3 0f 58 c1          	addss  %xmm1,%xmm0
  409531:	66 48 0f 7e c1       	movq   %xmm0,%rcx
  409536:	89 c9                	mov    %ecx,%ecx
  409538:	48 89 9d f0 f6 ff ff 	mov    %rbx,-0x910(%rbp)
  40953f:	48 89 85 f8 f6 ff ff 	mov    %rax,-0x908(%rbp)
  409546:	66 48 0f 6e c3       	movq   %rbx,%xmm0
  40954b:	66 48 0f 6e c8       	movq   %rax,%xmm1
  409550:	f3 0f 58 c1          	addss  %xmm1,%xmm0
  409554:	66 48 0f 7e c0       	movq   %xmm0,%rax
  409559:	89 c0                	mov    %eax,%eax
  40955b:	48 89 8d f0 f6 ff ff 	mov    %rcx,-0x910(%rbp)
  409562:	48 89 85 f8 f6 ff ff 	mov    %rax,-0x908(%rbp)
  409569:	66 48 0f 6e c1       	movq   %rcx,%xmm0
  40956e:	66 48 0f 6e c8       	movq   %rax,%xmm1
  409573:	f3 0f 58 c1          	addss  %xmm1,%xmm0
  409577:	66 48 0f 7e c0       	movq   %xmm0,%rax
  40957c:	89 c0                	mov    %eax,%eax
  40957e:	48 89 85 f0 f6 ff ff 	mov    %rax,-0x910(%rbp)
  409585:	48 c7 85 f8 f6 ff ff 00 00 80 3e 	movq   $0x3e800000,-0x908(%rbp)
  409590:	66 48 0f 6e c0       	movq   %rax,%xmm0
  409595:	f3 0f 59 05 af 7a 02 00 	mulss  0x27aaf(%rip),%xmm0        # 43104c <_IO_stdin_used+0x4c>
  40959d:	66 48 0f 7e c0       	movq   %xmm0,%rax
  4095a2:	89 c0                	mov    %eax,%eax
  4095a4:	66 48 0f 6e c0       	movq   %rax,%xmm0
  4095a9:	f3 0f 10 0d 73 7a 02 00 	movss  0x27a73(%rip),%xmm1        # 431024 <_IO_stdin_used+0x24>
  4095b1:	0f 2e c8             	ucomiss %xmm0,%xmm1
  4095b4:	0f 97 c1             	seta   %cl
  4095b7:	0f b6 c9             	movzbl %cl,%ecx
  4095ba:	89 ca                	mov    %ecx,%edx
  4095bc:	48 83 fa 01          	cmp    $0x1,%rdx
  4095c0:	0f 94 c1             	sete   %cl
  4095c3:	0f b6 c9             	movzbl %cl,%ecx
  4095c6:	48 c1 ea 28          	shr    $0x28,%rdx
  4095ca:	48 81 e2 ff ff 7f 00 	and    $0x7fffff,%rdx
  4095d1:	48 81 fa 02 00 01 00 	cmp    $0x10002,%rdx
  4095d8:	0f 94 c2             	sete   %dl
  4095db:	0f b6 d2             	movzbl %dl,%edx
  4095de:	09 d1                	or     %edx,%ecx
  4095e0:	75 68                	jne    40964a <p113d_FID_36_100_105_114_101_99_116_46_112_105_120_101_108_+0xa3a>
  4095e2:	83 f1 01             	xor    $0x1,%ecx
  4095e5:	75 11                	jne    4095f8 <p113d_FID_36_100_105_114_101_99_116_46_112_105_120_101_108_+0x9e8>
  4095e7:	be 04 00 00 00       	mov    $0x4,%esi
  4095ec:	e8 af 1d 02 00       	callq  42b3a0 <p111_rt_fail>
  4095f1:	b8 00 00 00 00       	mov    $0x0,%eax
  4095f6:	eb 57                	jmp    40964f <p113d_FID_36_100_105_114_101_99_116_46_112_105_120_101_108_+0xa3f>
  4095f8:	0f 2e 05 21 7a 02 00 	ucomiss 0x27a21(%rip),%xmm0        # 431020 <_IO_stdin_used+0x20>
  4095ff:	0f 97 c1             	seta   %cl
  409602:	0f b6 c9             	movzbl %cl,%ecx
  409605:	89 ca                	mov    %ecx,%edx
  409607:	48 83 fa 01          	cmp    $0x1,%rdx
  40960b:	0f 94 c1             	sete   %cl
  40960e:	0f b6 c9             	movzbl %cl,%ecx
  409611:	48 c1 ea 28          	shr    $0x28,%rdx
  409615:	48 81 e2 ff ff 7f 00 	and    $0x7fffff,%rdx
  40961c:	48 81 fa 02 00 01 00 	cmp    $0x10002,%rdx
  409623:	0f 94 c2             	sete   %dl
  409626:	0f b6 d2             	movzbl %dl,%edx
  409629:	09 d1                	or     %edx,%ecx
  40962b:	75 16                	jne    409643 <p113d_FID_36_100_105_114_101_99_116_46_112_105_120_101_108_+0xa33>
  40962d:	83 f1 01             	xor    $0x1,%ecx
  409630:	75 1d                	jne    40964f <p113d_FID_36_100_105_114_101_99_116_46_112_105_120_101_108_+0xa3f>
  409632:	be 04 00 00 00       	mov    $0x4,%esi
  409637:	e8 64 1d 02 00       	callq  42b3a0 <p111_rt_fail>
  40963c:	b8 00 00 00 00       	mov    $0x0,%eax
  409641:	eb 0c                	jmp    40964f <p113d_FID_36_100_105_114_101_99_116_46_112_105_120_101_108_+0xa3f>
  409643:	b8 00 00 80 3f       	mov    $0x3f800000,%eax
  409648:	eb 05                	jmp    40964f <p113d_FID_36_100_105_114_101_99_116_46_112_105_120_101_108_+0xa3f>
  40964a:	b8 00 00 00 00       	mov    $0x0,%eax
  40964f:	48 c7 85 f0 f6 ff ff 00 00 7f 43 	movq   $0x437f0000,-0x910(%rbp)
  40965a:	48 89 85 f8 f6 ff ff 	mov    %rax,-0x908(%rbp)
  409661:	66 48 0f 6e c0       	movq   %rax,%xmm0
  409666:	f3 0f 59 05 ea 79 02 00 	mulss  0x279ea(%rip),%xmm0        # 431058 <_IO_stdin_used+0x58>
  40966e:	66 48 0f 7e c0       	movq   %xmm0,%rax
  409673:	89 c0                	mov    %eax,%eax
  409675:	48 89 85 f0 f6 ff ff 	mov    %rax,-0x910(%rbp)
  40967c:	66 48 0f 6e c0       	movq   %rax,%xmm0
  409681:	0f 2e 05 9c 79 02 00 	ucomiss 0x2799c(%rip),%xmm0        # 431024 <_IO_stdin_used+0x24>
  409688:	0f 93 c0             	setae  %al
  40968b:	0f b6 c0             	movzbl %al,%eax
  40968e:	f3 0f 10 0d be 79 02 00 	movss  0x279be(%rip),%xmm1        # 431054 <_IO_stdin_used+0x54>
  409696:	0f 2e c8             	ucomiss %xmm0,%xmm1
  409699:	0f 97 c1             	seta   %cl
  40969c:	0f b6 c9             	movzbl %cl,%ecx
  40969f:	85 c1                	test   %eax,%ecx
  4096a1:	f3 48 0f 2c c0       	cvttss2si %xmm0,%rax
  4096a6:	89 c0                	mov    %eax,%eax
  4096a8:	b9 00 00 00 00       	mov    $0x0,%ecx
  4096ad:	48 0f 44 c1          	cmove  %rcx,%rax
  4096b1:	41 5f                	pop    %r15
  4096b3:	41 5e                	pop    %r14
  4096b5:	41 5d                	pop    %r13
  4096b7:	41 5c                	pop    %r12
  4096b9:	5b                   	pop    %rbx
  4096ba:	c9                   	leaveq 
  4096bb:	c3                   	retq   
  4096bc:	0f 1f 40 00          	nopl   0x0(%rax)

