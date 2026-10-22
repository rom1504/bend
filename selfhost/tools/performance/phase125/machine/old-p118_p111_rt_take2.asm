0000000000008a30 <p118_p111_rt_take2>:
    8a30:	41 54                	push   %r12
    8a32:	53                   	push   %rbx
    8a33:	48 83 ec 08          	sub    $0x8,%rsp
    8a37:	83 f9 02             	cmp    $0x2,%ecx
    8a3a:	74 14                	je     8a50 <p118_p111_rt_take2+0x20>
    8a3c:	48 8d 3d 00 00 00 00 	lea    0x0(%rip),%rdi        # 8a43 <p118_p111_rt_take2+0x13>	8a3f: R_X86_64_PC32	.LC151-0x4
    8a43:	e8 18 79 ff ff       	callq  360 <err_fail>
    8a48:	0f 1f 84 00 00 00 00 00 	nopl   0x0(%rax,%rax,1)
    8a50:	48 89 d0             	mov    %rdx,%rax
    8a53:	4c 8b 0d 00 00 00 00 	mov    0x0(%rip),%r9        # 8a5a <p118_p111_rt_take2+0x2a>	8a56: R_X86_64_PC32	.bss+0x1001ac
    8a5a:	48 89 f2             	mov    %rsi,%rdx
    8a5d:	48 c1 ea 28          	shr    $0x28,%rdx
    8a61:	0f b7 d2             	movzwl %dx,%edx
    8a64:	49 39 51 18          	cmp    %rdx,0x18(%r9)
    8a68:	76 d2                	jbe    8a3c <p118_p111_rt_take2+0xc>
    8a6a:	49 8b 89 80 00 00 00 	mov    0x80(%r9),%rcx
    8a71:	80 3c 11 02          	cmpb   $0x2,(%rcx,%rdx,1)
    8a75:	75 c5                	jne    8a3c <p118_p111_rt_take2+0xc>
    8a77:	48 85 c0             	test   %rax,%rax
    8a7a:	0f 84 3b 01 00 00    	je     8bbb <p118_p111_rt_take2+0x18b>
    8a80:	48 89 f2             	mov    %rsi,%rdx
    8a83:	48 c1 ea 38          	shr    $0x38,%rdx
    8a87:	83 e2 7f             	and    $0x7f,%edx
    8a8a:	48 83 fa 02          	cmp    $0x2,%rdx
    8a8e:	0f 85 33 01 00 00    	jne    8bc7 <p118_p111_rt_take2+0x197>
    8a94:	48 ba ff ff ff ff ff 00 00 00 	movabs $0xffffffffff,%rdx
    8a9e:	48 89 fb             	mov    %rdi,%rbx
    8aa1:	48 8b 3f             	mov    (%rdi),%rdi
    8aa4:	48 21 f2             	and    %rsi,%rdx
    8aa7:	4c 8d 04 d5 00 00 00 00 	lea    0x0(,%rdx,8),%r8
    8aaf:	4a 8d 0c 07          	lea    (%rdi,%r8,1),%rcx
    8ab3:	48 85 f6             	test   %rsi,%rsi
    8ab6:	0f 88 7c 00 00 00    	js     8b38 <p118_p111_rt_take2+0x108>
    8abc:	48 8b 09             	mov    (%rcx),%rcx
    8abf:	48 89 08             	mov    %rcx,(%rax)
    8ac2:	4a 8b 4c 07 08       	mov    0x8(%rdi,%r8,1),%rcx
    8ac7:	48 89 48 08          	mov    %rcx,0x8(%rax)
    8acb:	49 8b 41 40          	mov    0x40(%r9),%rax
    8acf:	48 83 c0 7f          	add    $0x7f,%rax
    8ad3:	48 83 e0 80          	and    $0xffffffffffffff80,%rax
    8ad7:	48 05 00 82 10 03    	add    $0x3108200,%rax
    8add:	48 39 d0             	cmp    %rdx,%rax
    8ae0:	76 0e                	jbe    8af0 <p118_p111_rt_take2+0xc0>
    8ae2:	48 83 c4 08          	add    $0x8,%rsp
    8ae6:	b8 02 00 00 00       	mov    $0x2,%eax
    8aeb:	5b                   	pop    %rbx
    8aec:	41 5c                	pop    %r12
    8aee:	c3                   	retq   
    8aef:	90                   	nop
    8af0:	48 8b 73 08          	mov    0x8(%rbx),%rsi
    8af4:	48 8b 3b             	mov    (%rbx),%rdi
    8af7:	48 8b 46 08          	mov    0x8(%rsi),%rax
    8afb:	48 89 04 d7          	mov    %rax,(%rdi,%rdx,8)
    8aff:	48 8b 86 08 01 00 00 	mov    0x108(%rsi),%rax
    8b06:	48 89 56 08          	mov    %rdx,0x8(%rsi)
    8b0a:	8b 15 00 00 00 00    	mov    0x0(%rip),%edx        # 8b10 <p118_p111_rt_take2+0xe0>	8b0c: R_X86_64_PC32	.bss+0x100264
    8b10:	48 83 c0 02          	add    $0x2,%rax
    8b14:	48 89 86 08 01 00 00 	mov    %rax,0x108(%rsi)
    8b1b:	48 39 d0             	cmp    %rdx,%rax
    8b1e:	0f 83 00 00 00 00    	jae    8b24 <p118_p111_rt_take2+0xf4>	8b20: R_X86_64_PC32	.text.unlikely+0x22b5
    8b24:	48 83 c4 08          	add    $0x8,%rsp
    8b28:	b8 02 00 00 00       	mov    $0x2,%eax
    8b2d:	5b                   	pop    %rbx
    8b2e:	41 5c                	pop    %r12
    8b30:	c3                   	retq   
    8b31:	0f 1f 80 00 00 00 00 	nopl   0x0(%rax)
    8b38:	4c 8b 4b 08          	mov    0x8(%rbx),%r9
    8b3c:	44 8b 41 04          	mov    0x4(%rcx),%r8d
    8b40:	44 8b 11             	mov    (%rcx),%r10d
    8b43:	49 c1 e0 20          	shl    $0x20,%r8
    8b47:	4d 09 d0             	or     %r10,%r8
    8b4a:	4d 89 c4             	mov    %r8,%r12
    8b4d:	41 81 e0 ff ff ff 00 	and    $0xffffff,%r8d
    8b54:	49 c1 ec 18          	shr    $0x18,%r12
    8b58:	4e 8d 14 e5 00 00 00 00 	lea    0x0(,%r12,8),%r10
    8b60:	4e 8d 1c 17          	lea    (%rdi,%r10,1),%r11
    8b64:	4d 8d 54 3a 08       	lea    0x8(%r10,%rdi,1),%r10
    8b69:	49 83 f8 01          	cmp    $0x1,%r8
    8b6d:	0f 85 00 00 00 00    	jne    8b73 <p118_p111_rt_take2+0x143>	8b6f: R_X86_64_PC32	.text.unlikely+0x22c4
    8b73:	8b 31                	mov    (%rcx),%esi
    8b75:	49 8b 33             	mov    (%r11),%rsi
    8b78:	48 89 30             	mov    %rsi,(%rax)
    8b7b:	49 8b 32             	mov    (%r10),%rsi
    8b7e:	48 89 70 08          	mov    %rsi,0x8(%rax)
    8b82:	49 8b 01             	mov    (%r9),%rax
    8b85:	48 89 01             	mov    %rax,(%rcx)
    8b88:	49 8b 81 00 01 00 00 	mov    0x100(%r9),%rax
    8b8f:	49 89 11             	mov    %rdx,(%r9)
    8b92:	8b 15 00 00 00 00    	mov    0x0(%rip),%edx        # 8b98 <p118_p111_rt_take2+0x168>	8b94: R_X86_64_PC32	.bss+0x100264
    8b98:	48 83 c0 01          	add    $0x1,%rax
    8b9c:	49 89 81 00 01 00 00 	mov    %rax,0x100(%r9)
    8ba3:	48 39 d0             	cmp    %rdx,%rax
    8ba6:	0f 83 00 00 00 00    	jae    8bac <p118_p111_rt_take2+0x17c>	8ba8: R_X86_64_PC32	.text.unlikely+0x22f3
    8bac:	4c 8b 0d 00 00 00 00 	mov    0x0(%rip),%r9        # 8bb3 <p118_p111_rt_take2+0x183>	8baf: R_X86_64_PC32	.bss+0x1001ac
    8bb3:	4c 89 e2             	mov    %r12,%rdx
    8bb6:	e9 10 ff ff ff       	jmpq   8acb <p118_p111_rt_take2+0x9b>
    8bbb:	48 8d 3d 00 00 00 00 	lea    0x0(%rip),%rdi        # 8bc2 <p118_p111_rt_take2+0x192>	8bbe: R_X86_64_PC32	.LC149-0x4
    8bc2:	e8 99 77 ff ff       	callq  360 <err_fail>
    8bc7:	48 8d 3d 00 00 00 00 	lea    0x0(%rip),%rdi        # 8bce <p118_p111_rt_take2+0x19e>	8bca: R_X86_64_PC32	.LC150-0x4
    8bce:	e8 8d 77 ff ff       	callq  360 <err_fail>
    8bd3:	66 66 2e 0f 1f 84 00 00 00 00 00 	data16 nopw %cs:0x0(%rax,%rax,1)
    8bde:	66 90                	xchg   %ax,%ax

