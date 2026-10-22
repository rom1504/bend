0000000000009d90 <p125_rt_ctor1>:
    9d90:	41 57                	push   %r15
    9d92:	41 56                	push   %r14
    9d94:	41 55                	push   %r13
    9d96:	41 54                	push   %r12
    9d98:	55                   	push   %rbp
    9d99:	48 89 d5             	mov    %rdx,%rbp
    9d9c:	53                   	push   %rbx
    9d9d:	89 f3                	mov    %esi,%ebx
    9d9f:	48 83 ec 08          	sub    $0x8,%rsp
    9da3:	4c 8b 7f 08          	mov    0x8(%rdi),%r15
    9da7:	4c 8b 37             	mov    (%rdi),%r14
    9daa:	4d 8b 27             	mov    (%r15),%r12
    9dad:	4d 85 e4             	test   %r12,%r12
    9db0:	0f 84 00 00 00 00    	je     9db6 <p125_rt_ctor1+0x26>	9db2: R_X86_64_PC32	.text.unlikely+0x273a
    9db6:	4f 8d 2c e6          	lea    (%r14,%r12,8),%r13
    9dba:	49 8b 45 00          	mov    0x0(%r13),%rax
    9dbe:	49 83 af 00 01 00 00 01 	subq   $0x1,0x100(%r15)
    9dc6:	49 89 07             	mov    %rax,(%r15)
    9dc9:	48 8b 05 00 00 00 00 	mov    0x0(%rip),%rax        # 9dd0 <p125_rt_ctor1+0x40>	9dcc: R_X86_64_PC32	.bss+0x1001ac
    9dd0:	48 8b 55 00          	mov    0x0(%rbp),%rdx
    9dd4:	f6 40 58 08          	testb  $0x8,0x58(%rax)
    9dd8:	74 36                	je     9e10 <p125_rt_ctor1+0x80>
    9dda:	48 8b 80 88 00 00 00 	mov    0x88(%rax),%rax
    9de1:	80 3c 18 00          	cmpb   $0x0,(%rax,%rbx,1)
    9de5:	75 29                	jne    9e10 <p125_rt_ctor1+0x80>
    9de7:	48 89 d8             	mov    %rbx,%rax
    9dea:	49 89 55 00          	mov    %rdx,0x0(%r13)
    9dee:	48 83 c4 08          	add    $0x8,%rsp
    9df2:	48 c1 e0 28          	shl    $0x28,%rax
    9df6:	5b                   	pop    %rbx
    9df7:	5d                   	pop    %rbp
    9df8:	4c 09 e0             	or     %r12,%rax
    9dfb:	41 5c                	pop    %r12
    9dfd:	41 5d                	pop    %r13
    9dff:	48 0f ba e8 39       	bts    $0x39,%rax
    9e04:	41 5e                	pop    %r14
    9e06:	41 5f                	pop    %r15
    9e08:	c3                   	retq   
    9e09:	0f 1f 80 00 00 00 00 	nopl   0x0(%rax)
    9e10:	48 89 d0             	mov    %rdx,%rax
    9e13:	48 c1 e8 38          	shr    $0x38,%rax
    9e17:	83 e0 7f             	and    $0x7f,%eax
    9e1a:	48 83 f8 02          	cmp    $0x2,%rax
    9e1e:	75 c7                	jne    9de7 <p125_rt_ctor1+0x57>
    9e20:	48 85 d2             	test   %rdx,%rdx
    9e23:	78 c2                	js     9de7 <p125_rt_ctor1+0x57>
    9e25:	e9 00 00 00 00       	jmpq   9e2a <p125_rt_ctor1+0x9a>	9e26: R_X86_64_PC32	.text.unlikely+0x2753
    9e2a:	66 0f 1f 44 00 00    	nopw   0x0(%rax,%rax,1)

