0000000000009e30 <p125_rt_take1>:
    9e30:	41 54                	push   %r12
    9e32:	48 89 f0             	mov    %rsi,%rax
    9e35:	53                   	push   %rbx
    9e36:	48 89 fb             	mov    %rdi,%rbx
    9e39:	48 c1 e8 28          	shr    $0x28,%rax
    9e3d:	0f b7 c0             	movzwl %ax,%eax
    9e40:	48 83 ec 08          	sub    $0x8,%rsp
    9e44:	48 8b 3d 00 00 00 00 	mov    0x0(%rip),%rdi        # 9e4b <p125_rt_take1+0x1b>	9e47: R_X86_64_PC32	.bss+0x1001ac
    9e4b:	48 39 47 18          	cmp    %rax,0x18(%rdi)
    9e4f:	77 0f                	ja     9e60 <p125_rt_take1+0x30>
    9e51:	48 8d 3d 00 00 00 00 	lea    0x0(%rip),%rdi        # 9e58 <p125_rt_take1+0x28>	9e54: R_X86_64_PC32	.LC151-0x4
    9e58:	e8 03 65 ff ff       	callq  360 <err_fail>
    9e5d:	0f 1f 00             	nopl   (%rax)
    9e60:	48 89 d1             	mov    %rdx,%rcx
    9e63:	48 8b 97 80 00 00 00 	mov    0x80(%rdi),%rdx
    9e6a:	80 3c 02 01          	cmpb   $0x1,(%rdx,%rax,1)
    9e6e:	75 e1                	jne    9e51 <p125_rt_take1+0x21>
    9e70:	48 89 f0             	mov    %rsi,%rax
    9e73:	48 c1 e8 38          	shr    $0x38,%rax
    9e77:	83 e0 7f             	and    $0x7f,%eax
    9e7a:	48 83 f8 01          	cmp    $0x1,%rax
    9e7e:	74 58                	je     9ed8 <p125_rt_take1+0xa8>
    9e80:	48 83 f8 02          	cmp    $0x2,%rax
    9e84:	0f 85 23 01 00 00    	jne    9fad <p125_rt_take1+0x17d>
    9e8a:	48 ba ff ff ff ff ff 00 00 00 	movabs $0xffffffffff,%rdx
    9e94:	4c 8b 0b             	mov    (%rbx),%r9
    9e97:	48 21 f2             	and    %rsi,%rdx
    9e9a:	49 8d 04 d1          	lea    (%r9,%rdx,8),%rax
    9e9e:	48 85 f6             	test   %rsi,%rsi
    9ea1:	0f 88 99 00 00 00    	js     9f40 <p125_rt_take1+0x110>
    9ea7:	48 8b 00             	mov    (%rax),%rax
    9eaa:	48 89 01             	mov    %rax,(%rcx)
    9ead:	48 8b 47 40          	mov    0x40(%rdi),%rax
    9eb1:	48 83 c0 7f          	add    $0x7f,%rax
    9eb5:	48 83 e0 80          	and    $0xffffffffffffff80,%rax
    9eb9:	48 05 00 82 10 03    	add    $0x3108200,%rax
    9ebf:	48 39 d0             	cmp    %rdx,%rax
    9ec2:	76 34                	jbe    9ef8 <p125_rt_take1+0xc8>
    9ec4:	48 83 c4 08          	add    $0x8,%rsp
    9ec8:	b8 01 00 00 00       	mov    $0x1,%eax
    9ecd:	5b                   	pop    %rbx
    9ece:	41 5c                	pop    %r12
    9ed0:	c3                   	retq   
    9ed1:	0f 1f 80 00 00 00 00 	nopl   0x0(%rax)
    9ed8:	48 b8 ff ff ff ff ff 00 00 00 	movabs $0xffffffffff,%rax
    9ee2:	48 21 c6             	and    %rax,%rsi
    9ee5:	b8 01 00 00 00       	mov    $0x1,%eax
    9eea:	48 89 31             	mov    %rsi,(%rcx)
    9eed:	48 83 c4 08          	add    $0x8,%rsp
    9ef1:	5b                   	pop    %rbx
    9ef2:	41 5c                	pop    %r12
    9ef4:	c3                   	retq   
    9ef5:	0f 1f 00             	nopl   (%rax)
    9ef8:	48 8b 73 08          	mov    0x8(%rbx),%rsi
    9efc:	48 8b 3b             	mov    (%rbx),%rdi
    9eff:	48 8b 06             	mov    (%rsi),%rax
    9f02:	48 89 04 d7          	mov    %rax,(%rdi,%rdx,8)
    9f06:	48 8b 86 00 01 00 00 	mov    0x100(%rsi),%rax
    9f0d:	48 89 16             	mov    %rdx,(%rsi)
    9f10:	8b 15 00 00 00 00    	mov    0x0(%rip),%edx        # 9f16 <p125_rt_take1+0xe6>	9f12: R_X86_64_PC32	.bss+0x100264
    9f16:	48 83 c0 01          	add    $0x1,%rax
    9f1a:	48 89 86 00 01 00 00 	mov    %rax,0x100(%rsi)
    9f21:	48 39 d0             	cmp    %rdx,%rax
    9f24:	0f 83 00 00 00 00    	jae    9f2a <p125_rt_take1+0xfa>	9f26: R_X86_64_PC32	.text.unlikely+0x277d
    9f2a:	48 83 c4 08          	add    $0x8,%rsp
    9f2e:	b8 01 00 00 00       	mov    $0x1,%eax
    9f33:	5b                   	pop    %rbx
    9f34:	41 5c                	pop    %r12
    9f36:	c3                   	retq   
    9f37:	66 0f 1f 84 00 00 00 00 00 	nopw   0x0(%rax,%rax,1)
    9f40:	4c 8b 53 08          	mov    0x8(%rbx),%r10
    9f44:	8b 78 04             	mov    0x4(%rax),%edi
    9f47:	44 8b 00             	mov    (%rax),%r8d
    9f4a:	48 c1 e7 20          	shl    $0x20,%rdi
    9f4e:	4c 09 c7             	or     %r8,%rdi
    9f51:	49 89 fc             	mov    %rdi,%r12
    9f54:	81 e7 ff ff ff 00    	and    $0xffffff,%edi
    9f5a:	49 c1 ec 18          	shr    $0x18,%r12
    9f5e:	4f 8d 04 e1          	lea    (%r9,%r12,8),%r8
    9f62:	48 83 ff 01          	cmp    $0x1,%rdi
    9f66:	0f 85 00 00 00 00    	jne    9f6c <p125_rt_take1+0x13c>	9f68: R_X86_64_PC32	.text.unlikely+0x2789
    9f6c:	8b 30                	mov    (%rax),%esi
    9f6e:	49 8b 30             	mov    (%r8),%rsi
    9f71:	48 89 31             	mov    %rsi,(%rcx)
    9f74:	49 8b 0a             	mov    (%r10),%rcx
    9f77:	48 89 08             	mov    %rcx,(%rax)
    9f7a:	49 8b 82 00 01 00 00 	mov    0x100(%r10),%rax
    9f81:	49 89 12             	mov    %rdx,(%r10)
    9f84:	8b 15 00 00 00 00    	mov    0x0(%rip),%edx        # 9f8a <p125_rt_take1+0x15a>	9f86: R_X86_64_PC32	.bss+0x100264
    9f8a:	48 83 c0 01          	add    $0x1,%rax
    9f8e:	49 89 82 00 01 00 00 	mov    %rax,0x100(%r10)
    9f95:	48 39 d0             	cmp    %rdx,%rax
    9f98:	0f 83 00 00 00 00    	jae    9f9e <p125_rt_take1+0x16e>	9f9a: R_X86_64_PC32	.text.unlikely+0x276b
    9f9e:	48 8b 3d 00 00 00 00 	mov    0x0(%rip),%rdi        # 9fa5 <p125_rt_take1+0x175>	9fa1: R_X86_64_PC32	.bss+0x1001ac
    9fa5:	4c 89 e2             	mov    %r12,%rdx
    9fa8:	e9 00 ff ff ff       	jmpq   9ead <p125_rt_take1+0x7d>
    9fad:	48 8d 3d 00 00 00 00 	lea    0x0(%rip),%rdi        # 9fb4 <p125_rt_take1+0x184>	9fb0: R_X86_64_PC32	.LC150-0x4
    9fb4:	e8 a7 63 ff ff       	callq  360 <err_fail>
    9fb9:	0f 1f 80 00 00 00 00 	nopl   0x0(%rax)

