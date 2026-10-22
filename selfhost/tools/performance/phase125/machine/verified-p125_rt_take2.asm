000000000000a0b0 <p125_rt_take2>:
    a0b0:	41 54                	push   %r12
    a0b2:	48 89 d0             	mov    %rdx,%rax
    a0b5:	48 89 f2             	mov    %rsi,%rdx
    a0b8:	53                   	push   %rbx
    a0b9:	48 c1 ea 28          	shr    $0x28,%rdx
    a0bd:	0f b7 d2             	movzwl %dx,%edx
    a0c0:	48 83 ec 08          	sub    $0x8,%rsp
    a0c4:	48 8b 0d 00 00 00 00 	mov    0x0(%rip),%rcx        # a0cb <p125_rt_take2+0x1b>	a0c7: R_X86_64_PC32	.bss+0x1001ac
    a0cb:	48 39 51 18          	cmp    %rdx,0x18(%rcx)
    a0cf:	77 0f                	ja     a0e0 <p125_rt_take2+0x30>
    a0d1:	48 8d 3d 00 00 00 00 	lea    0x0(%rip),%rdi        # a0d8 <p125_rt_take2+0x28>	a0d4: R_X86_64_PC32	.LC151-0x4
    a0d8:	e8 83 62 ff ff       	callq  360 <err_fail>
    a0dd:	0f 1f 00             	nopl   (%rax)
    a0e0:	48 89 fb             	mov    %rdi,%rbx
    a0e3:	48 8b b9 80 00 00 00 	mov    0x80(%rcx),%rdi
    a0ea:	80 3c 17 02          	cmpb   $0x2,(%rdi,%rdx,1)
    a0ee:	75 e1                	jne    a0d1 <p125_rt_take2+0x21>
    a0f0:	48 89 f2             	mov    %rsi,%rdx
    a0f3:	48 c1 ea 38          	shr    $0x38,%rdx
    a0f7:	83 e2 7f             	and    $0x7f,%edx
    a0fa:	48 83 fa 02          	cmp    $0x2,%rdx
    a0fe:	0f 85 27 01 00 00    	jne    a22b <p125_rt_take2+0x17b>
    a104:	48 ba ff ff ff ff ff 00 00 00 	movabs $0xffffffffff,%rdx
    a10e:	48 8b 3b             	mov    (%rbx),%rdi
    a111:	48 21 f2             	and    %rsi,%rdx
    a114:	4c 8d 0c d5 00 00 00 00 	lea    0x0(,%rdx,8),%r9
    a11c:	4e 8d 04 0f          	lea    (%rdi,%r9,1),%r8
    a120:	48 85 f6             	test   %rsi,%rsi
    a123:	0f 88 7f 00 00 00    	js     a1a8 <p125_rt_take2+0xf8>
    a129:	49 8b 30             	mov    (%r8),%rsi
    a12c:	48 89 30             	mov    %rsi,(%rax)
    a12f:	4a 8b 74 0f 08       	mov    0x8(%rdi,%r9,1),%rsi
    a134:	48 89 70 08          	mov    %rsi,0x8(%rax)
    a138:	48 8b 41 40          	mov    0x40(%rcx),%rax
    a13c:	48 83 c0 7f          	add    $0x7f,%rax
    a140:	48 83 e0 80          	and    $0xffffffffffffff80,%rax
    a144:	48 05 00 82 10 03    	add    $0x3108200,%rax
    a14a:	48 39 d0             	cmp    %rdx,%rax
    a14d:	76 11                	jbe    a160 <p125_rt_take2+0xb0>
    a14f:	48 83 c4 08          	add    $0x8,%rsp
    a153:	b8 02 00 00 00       	mov    $0x2,%eax
    a158:	5b                   	pop    %rbx
    a159:	41 5c                	pop    %r12
    a15b:	c3                   	retq   
    a15c:	0f 1f 40 00          	nopl   0x0(%rax)
    a160:	48 8b 73 08          	mov    0x8(%rbx),%rsi
    a164:	48 8b 3b             	mov    (%rbx),%rdi
    a167:	48 8b 46 08          	mov    0x8(%rsi),%rax
    a16b:	48 89 04 d7          	mov    %rax,(%rdi,%rdx,8)
    a16f:	48 8b 86 08 01 00 00 	mov    0x108(%rsi),%rax
    a176:	48 89 56 08          	mov    %rdx,0x8(%rsi)
    a17a:	8b 15 00 00 00 00    	mov    0x0(%rip),%edx        # a180 <p125_rt_take2+0xd0>	a17c: R_X86_64_PC32	.bss+0x100264
    a180:	48 83 c0 02          	add    $0x2,%rax
    a184:	48 89 86 08 01 00 00 	mov    %rax,0x108(%rsi)
    a18b:	48 39 d0             	cmp    %rdx,%rax
    a18e:	0f 83 00 00 00 00    	jae    a194 <p125_rt_take2+0xe4>	a190: R_X86_64_PC32	.text.unlikely+0x282f
    a194:	48 83 c4 08          	add    $0x8,%rsp
    a198:	b8 02 00 00 00       	mov    $0x2,%eax
    a19d:	5b                   	pop    %rbx
    a19e:	41 5c                	pop    %r12
    a1a0:	c3                   	retq   
    a1a1:	0f 1f 80 00 00 00 00 	nopl   0x0(%rax)
    a1a8:	4c 8b 4b 08          	mov    0x8(%rbx),%r9
    a1ac:	41 8b 48 04          	mov    0x4(%r8),%ecx
    a1b0:	45 8b 10             	mov    (%r8),%r10d
    a1b3:	48 c1 e1 20          	shl    $0x20,%rcx
    a1b7:	4c 09 d1             	or     %r10,%rcx
    a1ba:	49 89 cc             	mov    %rcx,%r12
    a1bd:	81 e1 ff ff ff 00    	and    $0xffffff,%ecx
    a1c3:	49 c1 ec 18          	shr    $0x18,%r12
    a1c7:	4e 8d 14 e5 00 00 00 00 	lea    0x0(,%r12,8),%r10
    a1cf:	4e 8d 1c 17          	lea    (%rdi,%r10,1),%r11
    a1d3:	4d 8d 54 3a 08       	lea    0x8(%r10,%rdi,1),%r10
    a1d8:	48 83 f9 01          	cmp    $0x1,%rcx
    a1dc:	0f 85 00 00 00 00    	jne    a1e2 <p125_rt_take2+0x132>	a1de: R_X86_64_PC32	.text.unlikely+0x2800
    a1e2:	41 8b 08             	mov    (%r8),%ecx
    a1e5:	49 8b 0b             	mov    (%r11),%rcx
    a1e8:	48 89 08             	mov    %rcx,(%rax)
    a1eb:	49 8b 0a             	mov    (%r10),%rcx
    a1ee:	48 89 48 08          	mov    %rcx,0x8(%rax)
    a1f2:	49 8b 01             	mov    (%r9),%rax
    a1f5:	49 89 00             	mov    %rax,(%r8)
    a1f8:	49 8b 81 00 01 00 00 	mov    0x100(%r9),%rax
    a1ff:	49 89 11             	mov    %rdx,(%r9)
    a202:	8b 15 00 00 00 00    	mov    0x0(%rip),%edx        # a208 <p125_rt_take2+0x158>	a204: R_X86_64_PC32	.bss+0x100264
    a208:	48 83 c0 01          	add    $0x1,%rax
    a20c:	49 89 81 00 01 00 00 	mov    %rax,0x100(%r9)
    a213:	48 39 d0             	cmp    %rdx,%rax
    a216:	0f 83 00 00 00 00    	jae    a21c <p125_rt_take2+0x16c>	a218: R_X86_64_PC32	.text.unlikely+0x283e
    a21c:	48 8b 0d 00 00 00 00 	mov    0x0(%rip),%rcx        # a223 <p125_rt_take2+0x173>	a21f: R_X86_64_PC32	.bss+0x1001ac
    a223:	4c 89 e2             	mov    %r12,%rdx
    a226:	e9 0d ff ff ff       	jmpq   a138 <p125_rt_take2+0x88>
    a22b:	48 8d 3d 00 00 00 00 	lea    0x0(%rip),%rdi        # a232 <p125_rt_take2+0x182>	a22e: R_X86_64_PC32	.LC150-0x4
    a232:	e8 29 61 ff ff       	callq  360 <err_fail>
    a237:	66 0f 1f 84 00 00 00 00 00 	nopw   0x0(%rax,%rax,1)

