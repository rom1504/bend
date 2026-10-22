0000000000009fc0 <p125_rt_ctor2>:
    9fc0:	41 57                	push   %r15
    9fc2:	41 56                	push   %r14
    9fc4:	41 55                	push   %r13
    9fc6:	49 89 d5             	mov    %rdx,%r13
    9fc9:	41 54                	push   %r12
    9fcb:	55                   	push   %rbp
    9fcc:	53                   	push   %rbx
    9fcd:	89 f3                	mov    %esi,%ebx
    9fcf:	48 83 ec 08          	sub    $0x8,%rsp
    9fd3:	4c 8b 67 08          	mov    0x8(%rdi),%r12
    9fd7:	4c 8b 37             	mov    (%rdi),%r14
    9fda:	49 8b 6c 24 08       	mov    0x8(%r12),%rbp
    9fdf:	48 85 ed             	test   %rbp,%rbp
    9fe2:	0f 84 00 00 00 00    	je     9fe8 <p125_rt_ctor2+0x28>	9fe4: R_X86_64_PC32	.text.unlikely+0x27e4
    9fe8:	49 8d 0c ee          	lea    (%r14,%rbp,8),%rcx
    9fec:	48 8b 01             	mov    (%rcx),%rax
    9fef:	49 83 ac 24 08 01 00 00 02 	subq   $0x2,0x108(%r12)
    9ff8:	49 89 44 24 08       	mov    %rax,0x8(%r12)
    9ffd:	48 8b 05 00 00 00 00 	mov    0x0(%rip),%rax        # a004 <p125_rt_ctor2+0x44>	a000: R_X86_64_PC32	.bss+0x1001ac
    a004:	49 8b 55 00          	mov    0x0(%r13),%rdx
    a008:	f6 40 58 08          	testb  $0x8,0x58(%rax)
    a00c:	74 22                	je     a030 <p125_rt_ctor2+0x70>
    a00e:	48 8b 80 88 00 00 00 	mov    0x88(%rax),%rax
    a015:	80 3c 18 00          	cmpb   $0x0,(%rax,%rbx,1)
    a019:	75 15                	jne    a030 <p125_rt_ctor2+0x70>
    a01b:	48 89 11             	mov    %rdx,(%rcx)
    a01e:	49 8b 45 08          	mov    0x8(%r13),%rax
    a022:	49 89 44 ee 08       	mov    %rax,0x8(%r14,%rbp,8)
    a027:	eb 3b                	jmp    a064 <p125_rt_ctor2+0xa4>
    a029:	0f 1f 80 00 00 00 00 	nopl   0x0(%rax)
    a030:	48 89 d0             	mov    %rdx,%rax
    a033:	4d 8d 3c ee          	lea    (%r14,%rbp,8),%r15
    a037:	48 c1 e8 38          	shr    $0x38,%rax
    a03b:	83 e0 7f             	and    $0x7f,%eax
    a03e:	48 83 f8 02          	cmp    $0x2,%rax
    a042:	74 54                	je     a098 <p125_rt_ctor2+0xd8>
    a044:	49 89 17             	mov    %rdx,(%r15)
    a047:	49 8b 55 08          	mov    0x8(%r13),%rdx
    a04b:	4d 8d 6c ee 08       	lea    0x8(%r14,%rbp,8),%r13
    a050:	48 89 d0             	mov    %rdx,%rax
    a053:	48 c1 e8 38          	shr    $0x38,%rax
    a057:	83 e0 7f             	and    $0x7f,%eax
    a05a:	48 83 f8 02          	cmp    $0x2,%rax
    a05e:	74 28                	je     a088 <p125_rt_ctor2+0xc8>
    a060:	49 89 55 00          	mov    %rdx,0x0(%r13)
    a064:	48 89 d8             	mov    %rbx,%rax
    a067:	48 83 c4 08          	add    $0x8,%rsp
    a06b:	48 c1 e0 28          	shl    $0x28,%rax
    a06f:	5b                   	pop    %rbx
    a070:	48 09 e8             	or     %rbp,%rax
    a073:	5d                   	pop    %rbp
    a074:	41 5c                	pop    %r12
    a076:	48 0f ba e8 39       	bts    $0x39,%rax
    a07b:	41 5d                	pop    %r13
    a07d:	41 5e                	pop    %r14
    a07f:	41 5f                	pop    %r15
    a081:	c3                   	retq   
    a082:	66 0f 1f 44 00 00    	nopw   0x0(%rax,%rax,1)
    a088:	48 85 d2             	test   %rdx,%rdx
    a08b:	78 d3                	js     a060 <p125_rt_ctor2+0xa0>
    a08d:	e9 00 00 00 00       	jmpq   a092 <p125_rt_ctor2+0xd2>	a08e: R_X86_64_PC32	.text.unlikely+0x27b4
    a092:	66 0f 1f 44 00 00    	nopw   0x0(%rax,%rax,1)
    a098:	48 85 d2             	test   %rdx,%rdx
    a09b:	78 a7                	js     a044 <p125_rt_ctor2+0x84>
    a09d:	e9 00 00 00 00       	jmpq   a0a2 <p125_rt_ctor2+0xe2>	a09e: R_X86_64_PC32	.text.unlikely+0x27cc
    a0a2:	66 66 2e 0f 1f 84 00 00 00 00 00 	data16 nopw %cs:0x0(%rax,%rax,1)
    a0ad:	0f 1f 00             	nopl   (%rax)

