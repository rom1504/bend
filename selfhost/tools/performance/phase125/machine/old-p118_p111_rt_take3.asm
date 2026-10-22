0000000000008cf0 <p118_p111_rt_take3>:
    8cf0:	41 54                	push   %r12
    8cf2:	55                   	push   %rbp
    8cf3:	53                   	push   %rbx
    8cf4:	83 f9 03             	cmp    $0x3,%ecx
    8cf7:	74 0f                	je     8d08 <p118_p111_rt_take3+0x18>
    8cf9:	48 8d 3d 00 00 00 00 	lea    0x0(%rip),%rdi        # 8d00 <p118_p111_rt_take3+0x10>	8cfc: R_X86_64_PC32	.LC151-0x4
    8d00:	e8 5b 76 ff ff       	callq  360 <err_fail>
    8d05:	0f 1f 00             	nopl   (%rax)
    8d08:	48 89 f0             	mov    %rsi,%rax
    8d0b:	4c 8b 05 00 00 00 00 	mov    0x0(%rip),%r8        # 8d12 <p118_p111_rt_take3+0x22>	8d0e: R_X86_64_PC32	.bss+0x1001ac
    8d12:	48 c1 e8 28          	shr    $0x28,%rax
    8d16:	0f b7 c0             	movzwl %ax,%eax
    8d19:	49 39 40 18          	cmp    %rax,0x18(%r8)
    8d1d:	76 da                	jbe    8cf9 <p118_p111_rt_take3+0x9>
    8d1f:	49 8b 88 80 00 00 00 	mov    0x80(%r8),%rcx
    8d26:	80 3c 01 03          	cmpb   $0x3,(%rcx,%rax,1)
    8d2a:	75 cd                	jne    8cf9 <p118_p111_rt_take3+0x9>
    8d2c:	48 85 d2             	test   %rdx,%rdx
    8d2f:	0f 84 46 01 00 00    	je     8e7b <p118_p111_rt_take3+0x18b>
    8d35:	48 89 f0             	mov    %rsi,%rax
    8d38:	48 c1 e8 38          	shr    $0x38,%rax
    8d3c:	83 e0 7f             	and    $0x7f,%eax
    8d3f:	48 83 f8 02          	cmp    $0x2,%rax
    8d43:	0f 85 3e 01 00 00    	jne    8e87 <p118_p111_rt_take3+0x197>
    8d49:	4c 8b 0f             	mov    (%rdi),%r9
    8d4c:	48 89 fb             	mov    %rdi,%rbx
    8d4f:	48 bf ff ff ff ff ff 00 00 00 	movabs $0xffffffffff,%rdi
    8d59:	48 21 f7             	and    %rsi,%rdi
    8d5c:	48 85 f6             	test   %rsi,%rsi
    8d5f:	0f 88 8b 00 00 00    	js     8df0 <p118_p111_rt_take3+0x100>
    8d65:	49 8d 34 f9          	lea    (%r9,%rdi,8),%rsi
    8d69:	31 c0                	xor    %eax,%eax
    8d6b:	0f 1f 44 00 00       	nopl   0x0(%rax,%rax,1)
    8d70:	48 8b 0c 06          	mov    (%rsi,%rax,1),%rcx
    8d74:	48 89 0c 02          	mov    %rcx,(%rdx,%rax,1)
    8d78:	48 83 c0 08          	add    $0x8,%rax
    8d7c:	48 83 f8 18          	cmp    $0x18,%rax
    8d80:	75 ee                	jne    8d70 <p118_p111_rt_take3+0x80>
    8d82:	49 8b 40 40          	mov    0x40(%r8),%rax
    8d86:	48 83 c0 7f          	add    $0x7f,%rax
    8d8a:	48 83 e0 80          	and    $0xffffffffffffff80,%rax
    8d8e:	48 05 00 82 10 03    	add    $0x3108200,%rax
    8d94:	48 39 f8             	cmp    %rdi,%rax
    8d97:	76 0f                	jbe    8da8 <p118_p111_rt_take3+0xb8>
    8d99:	5b                   	pop    %rbx
    8d9a:	b8 03 00 00 00       	mov    $0x3,%eax
    8d9f:	5d                   	pop    %rbp
    8da0:	41 5c                	pop    %r12
    8da2:	c3                   	retq   
    8da3:	0f 1f 44 00 00       	nopl   0x0(%rax,%rax,1)
    8da8:	48 8b 73 08          	mov    0x8(%rbx),%rsi
    8dac:	4c 8b 03             	mov    (%rbx),%r8
    8daf:	8b 15 00 00 00 00    	mov    0x0(%rip),%edx        # 8db5 <p118_p111_rt_take3+0xc5>	8db1: R_X86_64_PC32	.bss+0x100264
    8db5:	48 8b 46 10          	mov    0x10(%rsi),%rax
    8db9:	49 89 04 f8          	mov    %rax,(%r8,%rdi,8)
    8dbd:	48 8b 86 10 01 00 00 	mov    0x110(%rsi),%rax
    8dc4:	48 89 7e 10          	mov    %rdi,0x10(%rsi)
    8dc8:	48 83 c0 04          	add    $0x4,%rax
    8dcc:	48 89 86 10 01 00 00 	mov    %rax,0x110(%rsi)
    8dd3:	48 39 d0             	cmp    %rdx,%rax
    8dd6:	0f 83 00 00 00 00    	jae    8ddc <p118_p111_rt_take3+0xec>	8dd8: R_X86_64_PC32	.text.unlikely+0x2340
    8ddc:	5b                   	pop    %rbx
    8ddd:	b8 03 00 00 00       	mov    $0x3,%eax
    8de2:	5d                   	pop    %rbp
    8de3:	41 5c                	pop    %r12
    8de5:	c3                   	retq   
    8de6:	66 2e 0f 1f 84 00 00 00 00 00 	nopw   %cs:0x0(%rax,%rax,1)
    8df0:	49 8d 2c f9          	lea    (%r9,%rdi,8),%rbp
    8df4:	4c 8b 5b 08          	mov    0x8(%rbx),%r11
    8df8:	44 8b 65 04          	mov    0x4(%rbp),%r12d
    8dfc:	44 8b 55 00          	mov    0x0(%rbp),%r10d
    8e00:	49 c1 e4 20          	shl    $0x20,%r12
    8e04:	4d 09 d4             	or     %r10,%r12
    8e07:	41 81 e2 ff ff ff 00 	and    $0xffffff,%r10d
    8e0e:	49 83 fa 01          	cmp    $0x1,%r10
    8e12:	74 62                	je     8e76 <p118_p111_rt_take3+0x186>
    8e14:	49 c1 ec 18          	shr    $0x18,%r12
    8e18:	31 c0                	xor    %eax,%eax
    8e1a:	4f 8d 04 e1          	lea    (%r9,%r12,8),%r8
    8e1e:	66 90                	xchg   %ax,%ax
    8e20:	49 8b 0c 00          	mov    (%r8,%rax,1),%rcx
    8e24:	48 89 0c 02          	mov    %rcx,(%rdx,%rax,1)
    8e28:	48 83 c0 08          	add    $0x8,%rax
    8e2c:	48 83 f8 18          	cmp    $0x18,%rax
    8e30:	75 ee                	jne    8e20 <p118_p111_rt_take3+0x130>
    8e32:	49 83 fa 01          	cmp    $0x1,%r10
    8e36:	0f 85 00 00 00 00    	jne    8e3c <p118_p111_rt_take3+0x14c>	8e38: R_X86_64_PC32	.text.unlikely+0x2364
    8e3c:	49 8b 03             	mov    (%r11),%rax
    8e3f:	8b 15 00 00 00 00    	mov    0x0(%rip),%edx        # 8e45 <p118_p111_rt_take3+0x155>	8e41: R_X86_64_PC32	.bss+0x100264
    8e45:	48 89 45 00          	mov    %rax,0x0(%rbp)
    8e49:	49 8b 83 00 01 00 00 	mov    0x100(%r11),%rax
    8e50:	49 89 3b             	mov    %rdi,(%r11)
    8e53:	48 83 c0 01          	add    $0x1,%rax
    8e57:	49 89 83 00 01 00 00 	mov    %rax,0x100(%r11)
    8e5e:	48 39 d0             	cmp    %rdx,%rax
    8e61:	0f 83 00 00 00 00    	jae    8e67 <p118_p111_rt_take3+0x177>	8e63: R_X86_64_PC32	.text.unlikely+0x2352
    8e67:	4c 8b 05 00 00 00 00 	mov    0x0(%rip),%r8        # 8e6e <p118_p111_rt_take3+0x17e>	8e6a: R_X86_64_PC32	.bss+0x1001ac
    8e6e:	4c 89 e7             	mov    %r12,%rdi
    8e71:	e9 0c ff ff ff       	jmpq   8d82 <p118_p111_rt_take3+0x92>
    8e76:	8b 45 00             	mov    0x0(%rbp),%eax
    8e79:	eb 99                	jmp    8e14 <p118_p111_rt_take3+0x124>
    8e7b:	48 8d 3d 00 00 00 00 	lea    0x0(%rip),%rdi        # 8e82 <p118_p111_rt_take3+0x192>	8e7e: R_X86_64_PC32	.LC149-0x4
    8e82:	e8 d9 74 ff ff       	callq  360 <err_fail>
    8e87:	48 8d 3d 00 00 00 00 	lea    0x0(%rip),%rdi        # 8e8e <p118_p111_rt_take3+0x19e>	8e8a: R_X86_64_PC32	.LC150-0x4
    8e8e:	e8 cd 74 ff ff       	callq  360 <err_fail>
    8e93:	66 66 2e 0f 1f 84 00 00 00 00 00 	data16 nopw %cs:0x0(%rax,%rax,1)
    8e9e:	66 90                	xchg   %ax,%ax

