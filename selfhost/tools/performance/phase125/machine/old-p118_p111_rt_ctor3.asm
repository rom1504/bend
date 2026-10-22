0000000000008be0 <p118_p111_rt_ctor3>:
    8be0:	41 57                	push   %r15
    8be2:	41 56                	push   %r14
    8be4:	41 55                	push   %r13
    8be6:	41 54                	push   %r12
    8be8:	55                   	push   %rbp
    8be9:	53                   	push   %rbx
    8bea:	48 83 ec 18          	sub    $0x18,%rsp
    8bee:	83 f9 03             	cmp    $0x3,%ecx
    8bf1:	74 0d                	je     8c00 <p118_p111_rt_ctor3+0x20>
    8bf3:	48 8d 3d 00 00 00 00 	lea    0x0(%rip),%rdi        # 8bfa <p118_p111_rt_ctor3+0x1a>	8bf6: R_X86_64_PC32	.LC147-0x4
    8bfa:	e8 61 77 ff ff       	callq  360 <err_fail>
    8bff:	90                   	nop
    8c00:	48 8b 1d 00 00 00 00 	mov    0x0(%rip),%rbx        # 8c07 <p118_p111_rt_ctor3+0x27>	8c03: R_X86_64_PC32	.bss+0x1001ac
    8c07:	89 f5                	mov    %esi,%ebp
    8c09:	48 3b 6b 18          	cmp    0x18(%rbx),%rbp
    8c0d:	73 e4                	jae    8bf3 <p118_p111_rt_ctor3+0x13>
    8c0f:	49 89 d4             	mov    %rdx,%r12
    8c12:	48 8b 93 80 00 00 00 	mov    0x80(%rbx),%rdx
    8c19:	80 3c 2a 03          	cmpb   $0x3,(%rdx,%rbp,1)
    8c1d:	75 d4                	jne    8bf3 <p118_p111_rt_ctor3+0x13>
    8c1f:	4d 85 e4             	test   %r12,%r12
    8c22:	0f 84 b2 00 00 00    	je     8cda <p118_p111_rt_ctor3+0xfa>
    8c28:	48 89 f8             	mov    %rdi,%rax
    8c2b:	48 8b 3f             	mov    (%rdi),%rdi
    8c2e:	4c 8b 70 08          	mov    0x8(%rax),%r14
    8c32:	4d 8b 6e 10          	mov    0x10(%r14),%r13
    8c36:	4d 85 ed             	test   %r13,%r13
    8c39:	0f 84 00 00 00 00    	je     8c3f <p118_p111_rt_ctor3+0x5f>	8c3b: R_X86_64_PC32	.text.unlikely+0x2321
    8c3f:	4a 8b 04 ef          	mov    (%rdi,%r13,8),%rax
    8c43:	49 83 ae 10 01 00 00 04 	subq   $0x4,0x110(%r14)
    8c4b:	49 89 46 10          	mov    %rax,0x10(%r14)
    8c4f:	f6 43 58 08          	testb  $0x8,0x58(%rbx)
    8c53:	74 4b                	je     8ca0 <p118_p111_rt_ctor3+0xc0>
    8c55:	48 8b 83 88 00 00 00 	mov    0x88(%rbx),%rax
    8c5c:	80 3c 28 00          	cmpb   $0x0,(%rax,%rbp,1)
    8c60:	75 3e                	jne    8ca0 <p118_p111_rt_ctor3+0xc0>
    8c62:	4a 8d 0c ef          	lea    (%rdi,%r13,8),%rcx
    8c66:	31 c0                	xor    %eax,%eax
    8c68:	49 8b 14 04          	mov    (%r12,%rax,1),%rdx
    8c6c:	48 89 14 01          	mov    %rdx,(%rcx,%rax,1)
    8c70:	48 83 c0 08          	add    $0x8,%rax
    8c74:	48 83 f8 18          	cmp    $0x18,%rax
    8c78:	75 ee                	jne    8c68 <p118_p111_rt_ctor3+0x88>
    8c7a:	48 89 e8             	mov    %rbp,%rax
    8c7d:	48 83 c4 18          	add    $0x18,%rsp
    8c81:	48 c1 e0 28          	shl    $0x28,%rax
    8c85:	5b                   	pop    %rbx
    8c86:	5d                   	pop    %rbp
    8c87:	4c 09 e8             	or     %r13,%rax
    8c8a:	41 5c                	pop    %r12
    8c8c:	41 5d                	pop    %r13
    8c8e:	48 0f ba e8 39       	bts    $0x39,%rax
    8c93:	41 5e                	pop    %r14
    8c95:	41 5f                	pop    %r15
    8c97:	c3                   	retq   
    8c98:	0f 1f 84 00 00 00 00 00 	nopl   0x0(%rax,%rax,1)
    8ca0:	4e 8d 3c ef          	lea    (%rdi,%r13,8),%r15
    8ca4:	31 db                	xor    %ebx,%ebx
    8ca6:	49 8b 14 1c          	mov    (%r12,%rbx,1),%rdx
    8caa:	48 89 d0             	mov    %rdx,%rax
    8cad:	48 c1 e8 38          	shr    $0x38,%rax
    8cb1:	83 e0 7f             	and    $0x7f,%eax
    8cb4:	48 83 f8 02          	cmp    $0x2,%rax
    8cb8:	74 16                	je     8cd0 <p118_p111_rt_ctor3+0xf0>
    8cba:	49 89 14 1f          	mov    %rdx,(%r15,%rbx,1)
    8cbe:	48 83 c3 08          	add    $0x8,%rbx
    8cc2:	48 83 fb 18          	cmp    $0x18,%rbx
    8cc6:	75 de                	jne    8ca6 <p118_p111_rt_ctor3+0xc6>
    8cc8:	eb b0                	jmp    8c7a <p118_p111_rt_ctor3+0x9a>
    8cca:	66 0f 1f 44 00 00    	nopw   0x0(%rax,%rax,1)
    8cd0:	48 85 d2             	test   %rdx,%rdx
    8cd3:	78 e5                	js     8cba <p118_p111_rt_ctor3+0xda>
    8cd5:	e9 00 00 00 00       	jmpq   8cda <p118_p111_rt_ctor3+0xfa>	8cd6: R_X86_64_PC32	.text.unlikely+0x2302
    8cda:	48 8d 3d 00 00 00 00 	lea    0x0(%rip),%rdi        # 8ce1 <p118_p111_rt_ctor3+0x101>	8cdd: R_X86_64_PC32	.LC146-0x4
    8ce1:	e8 7a 76 ff ff       	callq  360 <err_fail>
    8ce6:	66 2e 0f 1f 84 00 00 00 00 00 	nopw   %cs:0x0(%rax,%rax,1)

