0000000000008ea0 <p118_p111_rt_ctor4>:
    8ea0:	41 57                	push   %r15
    8ea2:	41 56                	push   %r14
    8ea4:	41 55                	push   %r13
    8ea6:	41 54                	push   %r12
    8ea8:	55                   	push   %rbp
    8ea9:	53                   	push   %rbx
    8eaa:	48 83 ec 18          	sub    $0x18,%rsp
    8eae:	83 f9 04             	cmp    $0x4,%ecx
    8eb1:	74 0d                	je     8ec0 <p118_p111_rt_ctor4+0x20>
    8eb3:	48 8d 3d 00 00 00 00 	lea    0x0(%rip),%rdi        # 8eba <p118_p111_rt_ctor4+0x1a>	8eb6: R_X86_64_PC32	.LC147-0x4
    8eba:	e8 a1 74 ff ff       	callq  360 <err_fail>
    8ebf:	90                   	nop
    8ec0:	48 8b 1d 00 00 00 00 	mov    0x0(%rip),%rbx        # 8ec7 <p118_p111_rt_ctor4+0x27>	8ec3: R_X86_64_PC32	.bss+0x1001ac
    8ec7:	89 f5                	mov    %esi,%ebp
    8ec9:	48 3b 6b 18          	cmp    0x18(%rbx),%rbp
    8ecd:	73 e4                	jae    8eb3 <p118_p111_rt_ctor4+0x13>
    8ecf:	49 89 d4             	mov    %rdx,%r12
    8ed2:	48 8b 93 80 00 00 00 	mov    0x80(%rbx),%rdx
    8ed9:	80 3c 2a 04          	cmpb   $0x4,(%rdx,%rbp,1)
    8edd:	75 d4                	jne    8eb3 <p118_p111_rt_ctor4+0x13>
    8edf:	4d 85 e4             	test   %r12,%r12
    8ee2:	0f 84 b2 00 00 00    	je     8f9a <p118_p111_rt_ctor4+0xfa>
    8ee8:	48 89 f8             	mov    %rdi,%rax
    8eeb:	48 8b 3f             	mov    (%rdi),%rdi
    8eee:	4c 8b 70 08          	mov    0x8(%rax),%r14
    8ef2:	4d 8b 6e 10          	mov    0x10(%r14),%r13
    8ef6:	4d 85 ed             	test   %r13,%r13
    8ef9:	0f 84 00 00 00 00    	je     8eff <p118_p111_rt_ctor4+0x5f>	8efb: R_X86_64_PC32	.text.unlikely+0x23a8
    8eff:	4a 8b 04 ef          	mov    (%rdi,%r13,8),%rax
    8f03:	49 83 ae 10 01 00 00 04 	subq   $0x4,0x110(%r14)
    8f0b:	49 89 46 10          	mov    %rax,0x10(%r14)
    8f0f:	f6 43 58 08          	testb  $0x8,0x58(%rbx)
    8f13:	74 4b                	je     8f60 <p118_p111_rt_ctor4+0xc0>
    8f15:	48 8b 83 88 00 00 00 	mov    0x88(%rbx),%rax
    8f1c:	80 3c 28 00          	cmpb   $0x0,(%rax,%rbp,1)
    8f20:	75 3e                	jne    8f60 <p118_p111_rt_ctor4+0xc0>
    8f22:	4a 8d 0c ef          	lea    (%rdi,%r13,8),%rcx
    8f26:	31 c0                	xor    %eax,%eax
    8f28:	49 8b 14 04          	mov    (%r12,%rax,1),%rdx
    8f2c:	48 89 14 01          	mov    %rdx,(%rcx,%rax,1)
    8f30:	48 83 c0 08          	add    $0x8,%rax
    8f34:	48 83 f8 20          	cmp    $0x20,%rax
    8f38:	75 ee                	jne    8f28 <p118_p111_rt_ctor4+0x88>
    8f3a:	48 89 e8             	mov    %rbp,%rax
    8f3d:	48 83 c4 18          	add    $0x18,%rsp
    8f41:	48 c1 e0 28          	shl    $0x28,%rax
    8f45:	5b                   	pop    %rbx
    8f46:	5d                   	pop    %rbp
    8f47:	4c 09 e8             	or     %r13,%rax
    8f4a:	41 5c                	pop    %r12
    8f4c:	41 5d                	pop    %r13
    8f4e:	48 0f ba e8 39       	bts    $0x39,%rax
    8f53:	41 5e                	pop    %r14
    8f55:	41 5f                	pop    %r15
    8f57:	c3                   	retq   
    8f58:	0f 1f 84 00 00 00 00 00 	nopl   0x0(%rax,%rax,1)
    8f60:	4e 8d 3c ef          	lea    (%rdi,%r13,8),%r15
    8f64:	31 db                	xor    %ebx,%ebx
    8f66:	49 8b 14 1c          	mov    (%r12,%rbx,1),%rdx
    8f6a:	48 89 d0             	mov    %rdx,%rax
    8f6d:	48 c1 e8 38          	shr    $0x38,%rax
    8f71:	83 e0 7f             	and    $0x7f,%eax
    8f74:	48 83 f8 02          	cmp    $0x2,%rax
    8f78:	74 16                	je     8f90 <p118_p111_rt_ctor4+0xf0>
    8f7a:	49 89 14 1f          	mov    %rdx,(%r15,%rbx,1)
    8f7e:	48 83 c3 08          	add    $0x8,%rbx
    8f82:	48 83 fb 20          	cmp    $0x20,%rbx
    8f86:	75 de                	jne    8f66 <p118_p111_rt_ctor4+0xc6>
    8f88:	eb b0                	jmp    8f3a <p118_p111_rt_ctor4+0x9a>
    8f8a:	66 0f 1f 44 00 00    	nopw   0x0(%rax,%rax,1)
    8f90:	48 85 d2             	test   %rdx,%rdx
    8f93:	78 e5                	js     8f7a <p118_p111_rt_ctor4+0xda>
    8f95:	e9 00 00 00 00       	jmpq   8f9a <p118_p111_rt_ctor4+0xfa>	8f96: R_X86_64_PC32	.text.unlikely+0x2389
    8f9a:	48 8d 3d 00 00 00 00 	lea    0x0(%rip),%rdi        # 8fa1 <p118_p111_rt_ctor4+0x101>	8f9d: R_X86_64_PC32	.LC146-0x4
    8fa1:	e8 ba 73 ff ff       	callq  360 <err_fail>
    8fa6:	66 2e 0f 1f 84 00 00 00 00 00 	nopw   %cs:0x0(%rax,%rax,1)

