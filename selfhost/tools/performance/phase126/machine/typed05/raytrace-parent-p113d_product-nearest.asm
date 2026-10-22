0000000000406ae0 <p113d_FID_36_112_114_111_100_117_99_116_46_110_101_97_114_101_115_116_>:
  406ae0:	f3 0f 1e fa          	endbr64 
  406ae4:	55                   	push   %rbp
  406ae5:	48 89 e5             	mov    %rsp,%rbp
  406ae8:	48 81 ec e8 08 00 00 	sub    $0x8e8,%rsp
  406aef:	53                   	push   %rbx
  406af0:	41 54                	push   %r12
  406af2:	41 55                	push   %r13
  406af4:	41 56                	push   %r14
  406af6:	41 57                	push   %r15
  406af8:	48 8b 5d 48          	mov    0x48(%rbp),%rbx
  406afc:	4c 8b 65 40          	mov    0x40(%rbp),%r12
  406b00:	4c 8b 55 38          	mov    0x38(%rbp),%r10
  406b04:	48 8b 45 30          	mov    0x30(%rbp),%rax
  406b08:	4d 89 d3             	mov    %r10,%r11
  406b0b:	4c 8b 55 28          	mov    0x28(%rbp),%r10
  406b0f:	4c 8b 6d 20          	mov    0x20(%rbp),%r13
  406b13:	4c 8b 75 18          	mov    0x18(%rbp),%r14
  406b17:	4c 8b 7d 10          	mov    0x10(%rbp),%r15
  406b1b:	48 87 ca             	xchg   %rcx,%rdx
  406b1e:	4c 87 c1             	xchg   %r8,%rcx
  406b21:	49 87 d8             	xchg   %rbx,%r8
  406b24:	48 89 b5 38 ff ff ff 	mov    %rsi,-0xc8(%rbp)
  406b2b:	48 89 c6             	mov    %rax,%rsi
  406b2e:	4c 89 c8             	mov    %r9,%rax
  406b31:	41 b9 00 00 80 3f    	mov    $0x3f800000,%r9d
  406b37:	4c 89 8d 70 ff ff ff 	mov    %r9,-0x90(%rbp)
  406b3e:	41 b9 00 00 00 41    	mov    $0x41000000,%r9d
  406b44:	4c 89 8d 20 ff ff ff 	mov    %r9,-0xe0(%rbp)
  406b4b:	41 b9 cd cc 4c 3e    	mov    $0x3e4ccccd,%r9d
  406b51:	4c 89 8d 28 ff ff ff 	mov    %r9,-0xd8(%rbp)
  406b58:	41 b9 00 00 60 c0    	mov    $0xc0600000,%r9d
  406b5e:	4c 89 8d 30 ff ff ff 	mov    %r9,-0xd0(%rbp)
  406b65:	4c 89 55 c8          	mov    %r10,-0x38(%rbp)
  406b69:	48 89 75 d8          	mov    %rsi,-0x28(%rbp)
  406b6d:	4c 89 9d 58 ff ff ff 	mov    %r11,-0xa8(%rbp)
  406b74:	4c 89 a5 68 ff ff ff 	mov    %r12,-0x98(%rbp)
  406b7b:	49 89 fc             	mov    %rdi,%r12
  406b7e:	66 90                	xchg   %ax,%ax
  406b80:	48 89 95 50 ff ff ff 	mov    %rdx,-0xb0(%rbp)
  406b87:	48 89 8d 48 ff ff ff 	mov    %rcx,-0xb8(%rbp)
  406b8e:	48 89 85 40 ff ff ff 	mov    %rax,-0xc0(%rbp)
  406b95:	48 83 fb 00          	cmp    $0x0,%rbx
  406b99:	4d 89 c3             	mov    %r8,%r11
  406b9c:	41 0f 94 c0          	sete   %r8b
  406ba0:	45 0f b6 c0          	movzbl %r8b,%r8d
  406ba4:	49 83 fb 01          	cmp    $0x1,%r11
  406ba8:	49 89 c2             	mov    %rax,%r10
  406bab:	0f 94 c0             	sete   %al
  406bae:	0f b6 c0             	movzbl %al,%eax
  406bb1:	4c 89 de             	mov    %r11,%rsi
  406bb4:	48 c1 ee 28          	shr    $0x28,%rsi
  406bb8:	48 81 e6 ff ff 7f 00 	and    $0x7fffff,%rsi
  406bbf:	48 81 fe 02 00 01 00 	cmp    $0x10002,%rsi
  406bc6:	40 0f 94 c6          	sete   %sil
  406bca:	40 0f b6 f6          	movzbl %sil,%esi
  406bce:	89 c7                	mov    %eax,%edi
  406bd0:	09 f7                	or     %esi,%edi
  406bd2:	41 83 f8 00          	cmp    $0x0,%r8d
  406bd6:	0f 85 5f 05 00 00    	jne    40713b <p113d_FID_36_112_114_111_100_117_99_116_46_110_101_97_114_101_115_116_+0x65b>
  406bdc:	49 89 d9             	mov    %rbx,%r9
  406bdf:	48 83 eb 01          	sub    $0x1,%rbx
  406be3:	83 f7 01             	xor    $0x1,%edi
  406be6:	0f 85 5d 01 00 00    	jne    406d49 <p113d_FID_36_112_114_111_100_117_99_116_46_110_101_97_114_101_115_116_+0x269>
  406bec:	89 f1                	mov    %esi,%ecx
  406bee:	09 c8                	or     %ecx,%eax
  406bf0:	0f 84 1e 01 00 00    	je     406d14 <p113d_FID_36_112_114_111_100_117_99_116_46_110_101_97_114_101_115_116_+0x234>
  406bf6:	48 89 de             	mov    %rbx,%rsi
  406bf9:	4c 89 e7             	mov    %r12,%rdi
  406bfc:	e8 4f fd ff ff       	callq  406950 <p113d_FID_36_100_105_114_101_99_116_46_115_120_>
  406c01:	48 89 45 e0          	mov    %rax,-0x20(%rbp)
  406c05:	48 89 de             	mov    %rbx,%rsi
  406c08:	4c 89 e7             	mov    %r12,%rdi
  406c0b:	e8 e0 fb ff ff       	callq  4067f0 <p113d_FID_36_100_105_114_101_99_116_46_115_121_>
  406c10:	48 89 45 e8          	mov    %rax,-0x18(%rbp)
  406c14:	48 89 de             	mov    %rbx,%rsi
  406c17:	4c 89 e7             	mov    %r12,%rdi
  406c1a:	e8 01 fb ff ff       	callq  406720 <p113d_FID_36_100_105_114_101_99_116_46_115_122_>
  406c1f:	48 89 45 f0          	mov    %rax,-0x10(%rbp)
  406c23:	48 89 de             	mov    %rbx,%rsi
  406c26:	4c 89 e7             	mov    %r12,%rdi
  406c29:	e8 22 fa ff ff       	callq  406650 <p113d_FID_36_100_105_114_101_99_116_46_115_114_>
  406c2e:	49 89 c0             	mov    %rax,%r8
  406c31:	48 8b 95 50 ff ff ff 	mov    -0xb0(%rbp),%rdx
  406c38:	48 8b 8d 48 ff ff ff 	mov    -0xb8(%rbp),%rcx
  406c3f:	4c 8b 95 40 ff ff ff 	mov    -0xc0(%rbp),%r10
  406c46:	48 89 cf             	mov    %rcx,%rdi
  406c49:	48 8b 4d f0          	mov    -0x10(%rbp),%rcx
  406c4d:	48 89 d0             	mov    %rdx,%rax
  406c50:	48 8b 55 e8          	mov    -0x18(%rbp),%rdx
  406c54:	48 8b 75 e0          	mov    -0x20(%rbp),%rsi
  406c58:	48 83 ec 30          	sub    $0x30,%rsp
  406c5c:	49 89 e1             	mov    %rsp,%r9
  406c5f:	4d 89 69 20          	mov    %r13,0x20(%r9)
  406c63:	4d 89 71 18          	mov    %r14,0x18(%r9)
  406c67:	4d 89 79 10          	mov    %r15,0x10(%r9)
  406c6b:	4d 89 51 08          	mov    %r10,0x8(%r9)
  406c6f:	49 89 39             	mov    %rdi,(%r9)
  406c72:	49 89 c1             	mov    %rax,%r9
  406c75:	4c 89 e7             	mov    %r12,%rdi
  406c78:	e8 e3 f4 ff ff       	callq  406160 <p113d_FID_36_100_105_114_101_99_116_46_105_115_101_99_116_53_>
  406c7d:	48 89 45 d0          	mov    %rax,-0x30(%rbp)
  406c81:	48 83 ec d0          	sub    $0xffffffffffffffd0,%rsp
  406c85:	48 89 9d 20 f7 ff ff 	mov    %rbx,-0x8e0(%rbp)
  406c8c:	b9 01 00 00 00       	mov    $0x1,%ecx
  406c91:	48 8d 95 20 f7 ff ff 	lea    -0x8e0(%rbp),%rdx
  406c98:	be 19 00 00 00       	mov    $0x19,%esi
  406c9d:	4c 89 e7             	mov    %r12,%rdi
  406ca0:	e8 7b 76 02 00       	callq  42e320 <p111_rt_op>
  406ca5:	48 89 c6             	mov    %rax,%rsi
  406ca8:	4c 8b 8d 70 ff ff ff 	mov    -0x90(%rbp),%r9
  406caf:	48 8b 95 50 ff ff ff 	mov    -0xb0(%rbp),%rdx
  406cb6:	48 8b 8d 48 ff ff ff 	mov    -0xb8(%rbp),%rcx
  406cbd:	48 8b 85 40 ff ff ff 	mov    -0xc0(%rbp),%rax
  406cc4:	4c 8b 55 c8          	mov    -0x38(%rbp),%r10
  406cc8:	48 89 f7             	mov    %rsi,%rdi
  406ccb:	48 8b 75 d8          	mov    -0x28(%rbp),%rsi
  406ccf:	4c 8b 5d d0          	mov    -0x30(%rbp),%r11
  406cd3:	4c 89 9d 20 f7 ff ff 	mov    %r11,-0x8e0(%rbp)
  406cda:	4c 89 95 28 f7 ff ff 	mov    %r10,-0x8d8(%rbp)
  406ce1:	66 49 0f 6e c3       	movq   %r11,%xmm0
  406ce6:	66 49 0f 6e ca       	movq   %r10,%xmm1
  406ceb:	0f 2e c8             	ucomiss %xmm0,%xmm1
  406cee:	41 0f 97 c0          	seta   %r8b
  406cf2:	45 0f b6 c0          	movzbl %r8b,%r8d
  406cf6:	45 89 c0             	mov    %r8d,%r8d
  406cf9:	4c 89 5d c8          	mov    %r11,-0x38(%rbp)
  406cfd:	48 89 7d d8          	mov    %rdi,-0x28(%rbp)
  406d01:	4c 89 95 58 ff ff ff 	mov    %r10,-0xa8(%rbp)
  406d08:	48 89 b5 68 ff ff ff 	mov    %rsi,-0x98(%rbp)
  406d0f:	e9 6c fe ff ff       	jmpq   406b80 <p113d_FID_36_112_114_111_100_117_99_116_46_110_101_97_114_101_115_116_+0xa0>
  406d14:	48 8b 9d 38 ff ff ff 	mov    -0xc8(%rbp),%rbx
  406d1b:	4c 89 e7             	mov    %r12,%rdi
  406d1e:	be 04 00 00 00       	mov    $0x4,%esi
  406d23:	e8 d8 75 02 00       	callq  42e300 <p111_rt_fail>
  406d28:	48 c7 03 00 00 00 00 	movq   $0x0,(%rbx)
  406d2f:	48 c7 43 08 00 00 00 00 	movq   $0x0,0x8(%rbx)
  406d37:	48 c7 43 10 00 00 00 00 	movq   $0x0,0x10(%rbx)
  406d3f:	b8 00 00 00 00       	mov    $0x0,%eax
  406d44:	e9 8b 04 00 00       	jmpq   4071d4 <p113d_FID_36_112_114_111_100_117_99_116_46_110_101_97_114_101_115_116_+0x6f4>
  406d49:	4c 89 d0             	mov    %r10,%rax
  406d4c:	48 83 fb 00          	cmp    $0x0,%rbx
  406d50:	40 0f 94 c6          	sete   %sil
  406d54:	40 0f b6 f6          	movzbl %sil,%esi
  406d58:	89 75 c0             	mov    %esi,-0x40(%rbp)
  406d5b:	4d 89 c8             	mov    %r9,%r8
  406d5e:	49 83 e8 02          	sub    $0x2,%r8
  406d62:	4c 89 ce             	mov    %r9,%rsi
  406d65:	48 83 ee 03          	sub    $0x3,%rsi
  406d69:	49 89 c2             	mov    %rax,%r10
  406d6c:	4c 89 c8             	mov    %r9,%rax
  406d6f:	48 83 e8 04          	sub    $0x4,%rax
  406d73:	4c 89 cf             	mov    %r9,%rdi
  406d76:	48 83 ef 05          	sub    $0x5,%rdi
  406d7a:	4d 89 cb             	mov    %r9,%r11
  406d7d:	49 83 eb 06          	sub    $0x6,%r11
  406d81:	4c 89 5d a0          	mov    %r11,-0x60(%rbp)
  406d85:	4d 89 cb             	mov    %r9,%r11
  406d88:	49 83 eb 07          	sub    $0x7,%r11
  406d8c:	4c 89 5d a8          	mov    %r11,-0x58(%rbp)
  406d90:	49 83 e9 08          	sub    $0x8,%r9
  406d94:	4c 89 4d 90          	mov    %r9,-0x70(%rbp)
  406d98:	4c 8b 5d a8          	mov    -0x58(%rbp),%r11
  406d9c:	4c 8b 4d a0          	mov    -0x60(%rbp),%r9
  406da0:	83 7d c0 00          	cmpl   $0x0,-0x40(%rbp)
  406da4:	0f 85 8e 00 00 00    	jne    406e38 <p113d_FID_36_112_114_111_100_117_99_116_46_110_101_97_114_101_115_116_+0x358>
  406daa:	49 83 f8 00          	cmp    $0x0,%r8
  406dae:	74 65                	je     406e15 <p113d_FID_36_112_114_111_100_117_99_116_46_110_101_97_114_101_115_116_+0x335>
  406db0:	48 83 fe 00          	cmp    $0x0,%rsi
  406db4:	74 57                	je     406e0d <p113d_FID_36_112_114_111_100_117_99_116_46_110_101_97_114_101_115_116_+0x32d>
  406db6:	48 83 f8 00          	cmp    $0x0,%rax
  406dba:	74 49                	je     406e05 <p113d_FID_36_112_114_111_100_117_99_116_46_110_101_97_114_101_115_116_+0x325>
  406dbc:	0f 1f 40 00          	nopl   0x0(%rax)
  406dc0:	48 83 ff 00          	cmp    $0x0,%rdi
  406dc4:	74 37                	je     406dfd <p113d_FID_36_112_114_111_100_117_99_116_46_110_101_97_114_101_115_116_+0x31d>
  406dc6:	49 83 f9 00          	cmp    $0x0,%r9
  406dca:	4c 8b 4d 90          	mov    -0x70(%rbp),%r9
  406dce:	74 25                	je     406df5 <p113d_FID_36_112_114_111_100_117_99_116_46_110_101_97_114_101_115_116_+0x315>
  406dd0:	49 83 fb 00          	cmp    $0x0,%r11
  406dd4:	4c 8b 9d 30 ff ff ff 	mov    -0xd0(%rbp),%r11
  406ddb:	74 10                	je     406ded <p113d_FID_36_112_114_111_100_117_99_116_46_110_101_97_114_101_115_116_+0x30d>
  406ddd:	49 83 f9 00          	cmp    $0x0,%r9
  406de1:	41 b9 00 00 60 40    	mov    $0x40600000,%r9d
  406de7:	4d 0f 45 cb          	cmovne %r11,%r9
  406deb:	eb 2e                	jmp    406e1b <p113d_FID_36_112_114_111_100_117_99_116_46_110_101_97_114_101_115_116_+0x33b>
  406ded:	41 b9 00 00 00 00    	mov    $0x0,%r9d
  406df3:	eb 26                	jmp    406e1b <p113d_FID_36_112_114_111_100_117_99_116_46_110_101_97_114_101_115_116_+0x33b>
  406df5:	41 b9 00 00 80 bf    	mov    $0xbf800000,%r9d
  406dfb:	eb 1e                	jmp    406e1b <p113d_FID_36_112_114_111_100_117_99_116_46_110_101_97_114_101_115_116_+0x33b>
  406dfd:	41 b9 00 00 80 3f    	mov    $0x3f800000,%r9d
  406e03:	eb 16                	jmp    406e1b <p113d_FID_36_112_114_111_100_117_99_116_46_110_101_97_114_101_115_116_+0x33b>
  406e05:	41 b9 00 00 00 c0    	mov    $0xc0000000,%r9d
  406e0b:	eb 0e                	jmp    406e1b <p113d_FID_36_112_114_111_100_117_99_116_46_110_101_97_114_101_115_116_+0x33b>
  406e0d:	41 b9 00 00 00 40    	mov    $0x40000000,%r9d
  406e13:	eb 06                	jmp    406e1b <p113d_FID_36_112_114_111_100_117_99_116_46_110_101_97_114_101_115_116_+0x33b>
  406e15:	41 b9 00 00 00 00    	mov    $0x0,%r9d
  406e1b:	4d 89 cb             	mov    %r9,%r11
  406e1e:	4c 89 5d b8          	mov    %r11,-0x48(%rbp)
  406e22:	4c 8b 5d a8          	mov    -0x58(%rbp),%r11
  406e26:	4c 8b 4d a0          	mov    -0x60(%rbp),%r9
  406e2a:	f2 44 0f 10 7d b8    	movsd  -0x48(%rbp),%xmm15
  406e30:	f2 44 0f 11 7d 88    	movsd  %xmm15,-0x78(%rbp)
  406e36:	eb 08                	jmp    406e40 <p113d_FID_36_112_114_111_100_117_99_116_46_110_101_97_114_101_115_116_+0x360>
  406e38:	48 c7 45 88 00 00 00 00 	movq   $0x0,-0x78(%rbp)
  406e40:	48 83 fb 00          	cmp    $0x0,%rbx
  406e44:	0f 84 8e 00 00 00    	je     406ed8 <p113d_FID_36_112_114_111_100_117_99_116_46_110_101_97_114_101_115_116_+0x3f8>
  406e4a:	49 83 f8 00          	cmp    $0x0,%r8
  406e4e:	74 65                	je     406eb5 <p113d_FID_36_112_114_111_100_117_99_116_46_110_101_97_114_101_115_116_+0x3d5>
  406e50:	48 83 fe 00          	cmp    $0x0,%rsi
  406e54:	74 57                	je     406ead <p113d_FID_36_112_114_111_100_117_99_116_46_110_101_97_114_101_115_116_+0x3cd>
  406e56:	48 83 f8 00          	cmp    $0x0,%rax
  406e5a:	74 49                	je     406ea5 <p113d_FID_36_112_114_111_100_117_99_116_46_110_101_97_114_101_115_116_+0x3c5>
  406e5c:	0f 1f 40 00          	nopl   0x0(%rax)
  406e60:	48 83 ff 00          	cmp    $0x0,%rdi
  406e64:	74 37                	je     406e9d <p113d_FID_36_112_114_111_100_117_99_116_46_110_101_97_114_101_115_116_+0x3bd>
  406e66:	49 83 f9 00          	cmp    $0x0,%r9
  406e6a:	4c 8b 4d 90          	mov    -0x70(%rbp),%r9
  406e6e:	74 25                	je     406e95 <p113d_FID_36_112_114_111_100_117_99_116_46_110_101_97_114_101_115_116_+0x3b5>
  406e70:	49 83 fb 00          	cmp    $0x0,%r11
  406e74:	4c 8b 9d 28 ff ff ff 	mov    -0xd8(%rbp),%r11
  406e7b:	74 10                	je     406e8d <p113d_FID_36_112_114_111_100_117_99_116_46_110_101_97_114_101_115_116_+0x3ad>
  406e7d:	49 83 f9 00          	cmp    $0x0,%r9
  406e81:	41 b9 cd cc 4c 3e    	mov    $0x3e4ccccd,%r9d
  406e87:	4d 0f 45 cb          	cmovne %r11,%r9
  406e8b:	eb 2e                	jmp    406ebb <p113d_FID_36_112_114_111_100_117_99_116_46_110_101_97_114_101_115_116_+0x3db>
  406e8d:	41 b9 cd cc cc 3f    	mov    $0x3fcccccd,%r9d
  406e93:	eb 26                	jmp    406ebb <p113d_FID_36_112_114_111_100_117_99_116_46_110_101_97_114_101_115_116_+0x3db>
  406e95:	41 b9 9a 99 19 bf    	mov    $0xbf19999a,%r9d
  406e9b:	eb 1e                	jmp    406ebb <p113d_FID_36_112_114_111_100_117_99_116_46_110_101_97_114_101_115_116_+0x3db>
  406e9d:	41 b9 9a 99 19 bf    	mov    $0xbf19999a,%r9d
  406ea3:	eb 16                	jmp    406ebb <p113d_FID_36_112_114_111_100_117_99_116_46_110_101_97_114_101_115_116_+0x3db>
  406ea5:	41 b9 00 00 00 3f    	mov    $0x3f000000,%r9d
  406eab:	eb 0e                	jmp    406ebb <p113d_FID_36_112_114_111_100_117_99_116_46_110_101_97_114_101_115_116_+0x3db>
  406ead:	41 b9 00 00 00 3f    	mov    $0x3f000000,%r9d
  406eb3:	eb 06                	jmp    406ebb <p113d_FID_36_112_114_111_100_117_99_116_46_110_101_97_114_101_115_116_+0x3db>
  406eb5:	41 b9 00 00 00 00    	mov    $0x0,%r9d
  406ebb:	4d 89 cb             	mov    %r9,%r11
  406ebe:	4c 89 5d b0          	mov    %r11,-0x50(%rbp)
  406ec2:	4c 8b 5d a8          	mov    -0x58(%rbp),%r11
  406ec6:	4c 8b 4d a0          	mov    -0x60(%rbp),%r9
  406eca:	f2 44 0f 10 7d b0    	movsd  -0x50(%rbp),%xmm15
  406ed0:	f2 44 0f 11 7d 80    	movsd  %xmm15,-0x80(%rbp)
  406ed6:	eb 0e                	jmp    406ee6 <p113d_FID_36_112_114_111_100_117_99_116_46_110_101_97_114_101_115_116_+0x406>
  406ed8:	c7 45 80 00 44 1c c6 	movl   $0xc61c4400,-0x80(%rbp)
  406edf:	c7 45 84 00 00 00 00 	movl   $0x0,-0x7c(%rbp)
  406ee6:	48 83 fb 00          	cmp    $0x0,%rbx
  406eea:	0f 84 92 00 00 00    	je     406f82 <p113d_FID_36_112_114_111_100_117_99_116_46_110_101_97_114_101_115_116_+0x4a2>
  406ef0:	49 83 f8 00          	cmp    $0x0,%r8
  406ef4:	74 65                	je     406f5b <p113d_FID_36_112_114_111_100_117_99_116_46_110_101_97_114_101_115_116_+0x47b>
  406ef6:	48 83 fe 00          	cmp    $0x0,%rsi
  406efa:	74 57                	je     406f53 <p113d_FID_36_112_114_111_100_117_99_116_46_110_101_97_114_101_115_116_+0x473>
  406efc:	0f 1f 40 00          	nopl   0x0(%rax)
  406f00:	48 83 f8 00          	cmp    $0x0,%rax
  406f04:	74 45                	je     406f4b <p113d_FID_36_112_114_111_100_117_99_116_46_110_101_97_114_101_115_116_+0x46b>
  406f06:	48 83 ff 00          	cmp    $0x0,%rdi
  406f0a:	74 37                	je     406f43 <p113d_FID_36_112_114_111_100_117_99_116_46_110_101_97_114_101_115_116_+0x463>
  406f0c:	49 83 f9 00          	cmp    $0x0,%r9
  406f10:	4c 8b 4d 90          	mov    -0x70(%rbp),%r9
  406f14:	74 25                	je     406f3b <p113d_FID_36_112_114_111_100_117_99_116_46_110_101_97_114_101_115_116_+0x45b>
  406f16:	49 83 fb 00          	cmp    $0x0,%r11
  406f1a:	4c 8b 9d 20 ff ff ff 	mov    -0xe0(%rbp),%r11
  406f21:	74 10                	je     406f33 <p113d_FID_36_112_114_111_100_117_99_116_46_110_101_97_114_101_115_116_+0x453>
  406f23:	49 83 f9 00          	cmp    $0x0,%r9
  406f27:	41 b9 00 00 00 41    	mov    $0x41000000,%r9d
  406f2d:	4d 0f 45 cb          	cmovne %r11,%r9
  406f31:	eb 2f                	jmp    406f62 <p113d_FID_36_112_114_111_100_117_99_116_46_110_101_97_114_101_115_116_+0x482>
  406f33:	41 b9 00 00 e0 40    	mov    $0x40e00000,%r9d
  406f39:	eb 27                	jmp    406f62 <p113d_FID_36_112_114_111_100_117_99_116_46_110_101_97_114_101_115_116_+0x482>
  406f3b:	41 b9 00 00 60 40    	mov    $0x40600000,%r9d
  406f41:	eb 1f                	jmp    406f62 <p113d_FID_36_112_114_111_100_117_99_116_46_110_101_97_114_101_115_116_+0x482>
  406f43:	41 b9 00 00 60 40    	mov    $0x40600000,%r9d
  406f49:	eb 17                	jmp    406f62 <p113d_FID_36_112_114_111_100_117_99_116_46_110_101_97_114_101_115_116_+0x482>
  406f4b:	41 b9 00 00 c0 40    	mov    $0x40c00000,%r9d
  406f51:	eb 0f                	jmp    406f62 <p113d_FID_36_112_114_111_100_117_99_116_46_110_101_97_114_101_115_116_+0x482>
  406f53:	41 b9 00 00 c0 40    	mov    $0x40c00000,%r9d
  406f59:	eb 07                	jmp    406f62 <p113d_FID_36_112_114_111_100_117_99_116_46_110_101_97_114_101_115_116_+0x482>
  406f5b:	2e 41 b9 00 00 a0 40 	cs mov $0x40a00000,%r9d
  406f62:	4d 89 cb             	mov    %r9,%r11
  406f65:	4c 89 5d 98          	mov    %r11,-0x68(%rbp)
  406f69:	4c 8b 5d a8          	mov    -0x58(%rbp),%r11
  406f6d:	4c 8b 4d a0          	mov    -0x60(%rbp),%r9
  406f71:	f2 44 0f 10 7d 98    	movsd  -0x68(%rbp),%xmm15
  406f77:	f2 44 0f 11 bd 78 ff ff ff 	movsd  %xmm15,-0x88(%rbp)
  406f80:	eb 0b                	jmp    406f8d <p113d_FID_36_112_114_111_100_117_99_116_46_110_101_97_114_101_115_116_+0x4ad>
  406f82:	48 c7 85 78 ff ff ff 00 00 a0 40 	movq   $0x40a00000,-0x88(%rbp)
  406f8d:	48 83 fb 00          	cmp    $0x0,%rbx
  406f91:	0f 84 c1 00 00 00    	je     407058 <p113d_FID_36_112_114_111_100_117_99_116_46_110_101_97_114_101_115_116_+0x578>
  406f97:	2e 49 83 f8 00       	cs cmp $0x0,%r8
  406f9c:	4c 8b 45 90          	mov    -0x70(%rbp),%r8
  406fa0:	0f 84 95 00 00 00    	je     40703b <p113d_FID_36_112_114_111_100_117_99_116_46_110_101_97_114_101_115_116_+0x55b>
  406fa6:	48 83 fe 00          	cmp    $0x0,%rsi
  406faa:	48 8b 75 88          	mov    -0x78(%rbp),%rsi
  406fae:	74 72                	je     407022 <p113d_FID_36_112_114_111_100_117_99_116_46_110_101_97_114_101_115_116_+0x542>
  406fb0:	48 83 f8 00          	cmp    $0x0,%rax
  406fb4:	48 89 d0             	mov    %rdx,%rax
  406fb7:	48 8b 55 80          	mov    -0x80(%rbp),%rdx
  406fbb:	74 51                	je     40700e <p113d_FID_36_112_114_111_100_117_99_116_46_110_101_97_114_101_115_116_+0x52e>
  406fbd:	48 83 ff 00          	cmp    $0x0,%rdi
  406fc1:	48 89 cf             	mov    %rcx,%rdi
  406fc4:	48 8b 8d 78 ff ff ff 	mov    -0x88(%rbp),%rcx
  406fcb:	74 39                	je     407006 <p113d_FID_36_112_114_111_100_117_99_116_46_110_101_97_114_101_115_116_+0x526>
  406fcd:	49 83 f9 00          	cmp    $0x0,%r9
  406fd1:	4c 8b 8d 70 ff ff ff 	mov    -0x90(%rbp),%r9
  406fd8:	74 24                	je     406ffe <p113d_FID_36_112_114_111_100_117_99_116_46_110_101_97_114_101_115_116_+0x51e>
  406fda:	66 0f 1f 44 00 00    	nopw   0x0(%rax,%rax,1)
  406fe0:	49 83 fb 00          	cmp    $0x0,%r11
  406fe4:	74 10                	je     406ff6 <p113d_FID_36_112_114_111_100_117_99_116_46_110_101_97_114_101_115_116_+0x516>
  406fe6:	49 83 f8 00          	cmp    $0x0,%r8
  406fea:	41 b8 00 00 80 3f    	mov    $0x3f800000,%r8d
  406ff0:	4d 0f 45 c1          	cmovne %r9,%r8
  406ff4:	eb 7d                	jmp    407073 <p113d_FID_36_112_114_111_100_117_99_116_46_110_101_97_114_101_115_116_+0x593>
  406ff6:	41 b8 9a 99 99 3f    	mov    $0x3f99999a,%r8d
  406ffc:	eb 75                	jmp    407073 <p113d_FID_36_112_114_111_100_117_99_116_46_110_101_97_114_101_115_116_+0x593>
  406ffe:	41 b8 cd cc cc 3e    	mov    $0x3ecccccd,%r8d
  407004:	eb 6d                	jmp    407073 <p113d_FID_36_112_114_111_100_117_99_116_46_110_101_97_114_101_115_116_+0x593>
  407006:	41 b8 cd cc cc 3e    	mov    $0x3ecccccd,%r8d
  40700c:	eb 65                	jmp    407073 <p113d_FID_36_112_114_111_100_117_99_116_46_110_101_97_114_101_115_116_+0x593>
  40700e:	2e 2e 48 89 cf       	cs cs mov %rcx,%rdi
  407013:	48 8b 8d 78 ff ff ff 	mov    -0x88(%rbp),%rcx
  40701a:	41 b8 00 00 80 3f    	mov    $0x3f800000,%r8d
  407020:	eb 51                	jmp    407073 <p113d_FID_36_112_114_111_100_117_99_116_46_110_101_97_114_101_115_116_+0x593>
  407022:	48 89 d0             	mov    %rdx,%rax
  407025:	48 8b 55 80          	mov    -0x80(%rbp),%rdx
  407029:	48 89 cf             	mov    %rcx,%rdi
  40702c:	48 8b 8d 78 ff ff ff 	mov    -0x88(%rbp),%rcx
  407033:	41 b8 00 00 80 3f    	mov    $0x3f800000,%r8d
  407039:	eb 38                	jmp    407073 <p113d_FID_36_112_114_111_100_117_99_116_46_110_101_97_114_101_115_116_+0x593>
  40703b:	48 8b 75 88          	mov    -0x78(%rbp),%rsi
  40703f:	48 89 d0             	mov    %rdx,%rax
  407042:	48 8b 55 80          	mov    -0x80(%rbp),%rdx
  407046:	48 89 cf             	mov    %rcx,%rdi
  407049:	48 8b 8d 78 ff ff ff 	mov    -0x88(%rbp),%rcx
  407050:	41 b8 00 00 80 3f    	mov    $0x3f800000,%r8d
  407056:	eb 1b                	jmp    407073 <p113d_FID_36_112_114_111_100_117_99_116_46_110_101_97_114_101_115_116_+0x593>
  407058:	48 8b 75 88          	mov    -0x78(%rbp),%rsi
  40705c:	48 89 d0             	mov    %rdx,%rax
  40705f:	48 8b 55 80          	mov    -0x80(%rbp),%rdx
  407063:	48 89 cf             	mov    %rcx,%rdi
  407066:	48 8b 8d 78 ff ff ff 	mov    -0x88(%rbp),%rcx
  40706d:	41 b8 00 40 1c 46    	mov    $0x461c4000,%r8d
  407073:	48 83 ec 30          	sub    $0x30,%rsp
  407077:	49 89 e1             	mov    %rsp,%r9
  40707a:	4d 89 69 20          	mov    %r13,0x20(%r9)
  40707e:	4d 89 71 18          	mov    %r14,0x18(%r9)
  407082:	4d 89 79 10          	mov    %r15,0x10(%r9)
  407086:	4d 89 51 08          	mov    %r10,0x8(%r9)
  40708a:	49 89 39             	mov    %rdi,(%r9)
  40708d:	49 89 c1             	mov    %rax,%r9
  407090:	4c 89 e7             	mov    %r12,%rdi
  407093:	e8 c8 f0 ff ff       	callq  406160 <p113d_FID_36_100_105_114_101_99_116_46_105_115_101_99_116_53_>
  407098:	48 89 85 60 ff ff ff 	mov    %rax,-0xa0(%rbp)
  40709f:	48 83 ec d0          	sub    $0xffffffffffffffd0,%rsp
  4070a3:	48 89 9d 20 f7 ff ff 	mov    %rbx,-0x8e0(%rbp)
  4070aa:	b9 01 00 00 00       	mov    $0x1,%ecx
  4070af:	48 8d 95 20 f7 ff ff 	lea    -0x8e0(%rbp),%rdx
  4070b6:	be 19 00 00 00       	mov    $0x19,%esi
  4070bb:	4c 89 e7             	mov    %r12,%rdi
  4070be:	e8 5d 72 02 00       	callq  42e320 <p111_rt_op>
  4070c3:	48 89 c6             	mov    %rax,%rsi
  4070c6:	4c 8b 8d 70 ff ff ff 	mov    -0x90(%rbp),%r9
  4070cd:	48 8b 95 50 ff ff ff 	mov    -0xb0(%rbp),%rdx
  4070d4:	48 8b 8d 48 ff ff ff 	mov    -0xb8(%rbp),%rcx
  4070db:	48 8b 85 40 ff ff ff 	mov    -0xc0(%rbp),%rax
  4070e2:	4c 8b 95 58 ff ff ff 	mov    -0xa8(%rbp),%r10
  4070e9:	48 89 f7             	mov    %rsi,%rdi
  4070ec:	48 8b b5 68 ff ff ff 	mov    -0x98(%rbp),%rsi
  4070f3:	4c 8b 9d 60 ff ff ff 	mov    -0xa0(%rbp),%r11
  4070fa:	4c 89 9d 20 f7 ff ff 	mov    %r11,-0x8e0(%rbp)
  407101:	4c 89 95 28 f7 ff ff 	mov    %r10,-0x8d8(%rbp)
  407108:	66 49 0f 6e c3       	movq   %r11,%xmm0
  40710d:	66 49 0f 6e ca       	movq   %r10,%xmm1
  407112:	0f 2e c8             	ucomiss %xmm0,%xmm1
  407115:	41 0f 97 c0          	seta   %r8b
  407119:	45 0f b6 c0          	movzbl %r8b,%r8d
  40711d:	45 89 c0             	mov    %r8d,%r8d
  407120:	4c 89 5d c8          	mov    %r11,-0x38(%rbp)
  407124:	48 89 7d d8          	mov    %rdi,-0x28(%rbp)
  407128:	4c 89 95 58 ff ff ff 	mov    %r10,-0xa8(%rbp)
  40712f:	48 89 b5 68 ff ff ff 	mov    %rsi,-0x98(%rbp)
  407136:	e9 45 fa ff ff       	jmpq   406b80 <p113d_FID_36_112_114_111_100_117_99_116_46_110_101_97_114_101_115_116_+0xa0>
  40713b:	4c 8b 5d c8          	mov    -0x38(%rbp),%r11
  40713f:	4c 8b 95 58 ff ff ff 	mov    -0xa8(%rbp),%r10
  407146:	89 f1                	mov    %esi,%ecx
  407148:	48 8b b5 68 ff ff ff 	mov    -0x98(%rbp),%rsi
  40714f:	89 fa                	mov    %edi,%edx
  407151:	48 8b 9d 38 ff ff ff 	mov    -0xc8(%rbp),%rbx
  407158:	4c 89 e7             	mov    %r12,%rdi
  40715b:	4c 8b 65 d8          	mov    -0x28(%rbp),%r12
  40715f:	83 f2 01             	xor    $0x1,%edx
  407162:	75 52                	jne    4071b6 <p113d_FID_36_112_114_111_100_117_99_116_46_110_101_97_114_101_115_116_+0x6d6>
  407164:	4d 89 da             	mov    %r11,%r10
  407167:	4c 89 e6             	mov    %r12,%rsi
  40716a:	09 c8                	or     %ecx,%eax
  40716c:	75 28                	jne    407196 <p113d_FID_36_112_114_111_100_117_99_116_46_110_101_97_114_101_115_116_+0x6b6>
  40716e:	be 04 00 00 00       	mov    $0x4,%esi
  407173:	e8 88 71 02 00       	callq  42e300 <p111_rt_fail>
  407178:	48 c7 03 00 00 00 00 	movq   $0x0,(%rbx)
  40717f:	48 c7 43 08 00 00 00 00 	movq   $0x0,0x8(%rbx)
  407187:	48 c7 43 10 00 00 00 00 	movq   $0x0,0x10(%rbx)
  40718f:	b8 00 00 00 00       	mov    $0x0,%eax
  407194:	eb 3e                	jmp    4071d4 <p113d_FID_36_112_114_111_100_117_99_116_46_110_101_97_114_101_115_116_+0x6f4>
  407196:	89 f0                	mov    %esi,%eax
  407198:	48 83 f8 09          	cmp    $0x9,%rax
  40719c:	0f 94 c0             	sete   %al
  40719f:	0f b6 c0             	movzbl %al,%eax
  4071a2:	89 c0                	mov    %eax,%eax
  4071a4:	48 89 03             	mov    %rax,(%rbx)
  4071a7:	4c 89 53 08          	mov    %r10,0x8(%rbx)
  4071ab:	48 89 73 10          	mov    %rsi,0x10(%rbx)
  4071af:	b8 00 00 00 00       	mov    $0x0,%eax
  4071b4:	eb 1e                	jmp    4071d4 <p113d_FID_36_112_114_111_100_117_99_116_46_110_101_97_114_101_115_116_+0x6f4>
  4071b6:	89 f0                	mov    %esi,%eax
  4071b8:	48 83 f8 09          	cmp    $0x9,%rax
  4071bc:	0f 94 c0             	sete   %al
  4071bf:	0f b6 c0             	movzbl %al,%eax
  4071c2:	89 c0                	mov    %eax,%eax
  4071c4:	48 89 03             	mov    %rax,(%rbx)
  4071c7:	4c 89 53 08          	mov    %r10,0x8(%rbx)
  4071cb:	48 89 73 10          	mov    %rsi,0x10(%rbx)
  4071cf:	b8 00 00 00 00       	mov    $0x0,%eax
  4071d4:	41 5f                	pop    %r15
  4071d6:	41 5e                	pop    %r14
  4071d8:	41 5d                	pop    %r13
  4071da:	41 5c                	pop    %r12
  4071dc:	5b                   	pop    %rbx
  4071dd:	c9                   	leaveq 
  4071de:	c3                   	retq   
  4071df:	90                   	nop

