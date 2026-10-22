0000000000008fb0 <p118_p111_rt_take4>:
    8fb0:	41 54                	push   %r12
    8fb2:	55                   	push   %rbp
    8fb3:	53                   	push   %rbx
    8fb4:	83 f9 04             	cmp    $0x4,%ecx
    8fb7:	74 0f                	je     8fc8 <p118_p111_rt_take4+0x18>
    8fb9:	48 8d 3d 00 00 00 00 	lea    0x0(%rip),%rdi        # 8fc0 <p118_p111_rt_take4+0x10>	8fbc: R_X86_64_PC32	.LC151-0x4
    8fc0:	e8 9b 73 ff ff       	callq  360 <err_fail>
    8fc5:	0f 1f 00             	nopl   (%rax)
    8fc8:	48 89 f0             	mov    %rsi,%rax
    8fcb:	4c 8b 05 00 00 00 00 	mov    0x0(%rip),%r8        # 8fd2 <p118_p111_rt_take4+0x22>	8fce: R_X86_64_PC32	.bss+0x1001ac
    8fd2:	48 c1 e8 28          	shr    $0x28,%rax
    8fd6:	0f b7 c0             	movzwl %ax,%eax
    8fd9:	49 39 40 18          	cmp    %rax,0x18(%r8)
    8fdd:	76 da                	jbe    8fb9 <p118_p111_rt_take4+0x9>
    8fdf:	49 8b 88 80 00 00 00 	mov    0x80(%r8),%rcx
    8fe6:	80 3c 01 04          	cmpb   $0x4,(%rcx,%rax,1)
    8fea:	75 cd                	jne    8fb9 <p118_p111_rt_take4+0x9>
    8fec:	48 85 d2             	test   %rdx,%rdx
    8fef:	0f 84 46 01 00 00    	je     913b <p118_p111_rt_take4+0x18b>
    8ff5:	48 89 f0             	mov    %rsi,%rax
    8ff8:	48 c1 e8 38          	shr    $0x38,%rax
    8ffc:	83 e0 7f             	and    $0x7f,%eax
    8fff:	48 83 f8 02          	cmp    $0x2,%rax
    9003:	0f 85 3e 01 00 00    	jne    9147 <p118_p111_rt_take4+0x197>
    9009:	4c 8b 0f             	mov    (%rdi),%r9
    900c:	48 89 fb             	mov    %rdi,%rbx
    900f:	48 bf ff ff ff ff ff 00 00 00 	movabs $0xffffffffff,%rdi
    9019:	48 21 f7             	and    %rsi,%rdi
    901c:	48 85 f6             	test   %rsi,%rsi
    901f:	0f 88 8b 00 00 00    	js     90b0 <p118_p111_rt_take4+0x100>
    9025:	49 8d 34 f9          	lea    (%r9,%rdi,8),%rsi
    9029:	31 c0                	xor    %eax,%eax
    902b:	0f 1f 44 00 00       	nopl   0x0(%rax,%rax,1)
    9030:	48 8b 0c 06          	mov    (%rsi,%rax,1),%rcx
    9034:	48 89 0c 02          	mov    %rcx,(%rdx,%rax,1)
    9038:	48 83 c0 08          	add    $0x8,%rax
    903c:	48 83 f8 20          	cmp    $0x20,%rax
    9040:	75 ee                	jne    9030 <p118_p111_rt_take4+0x80>
    9042:	49 8b 40 40          	mov    0x40(%r8),%rax
    9046:	48 83 c0 7f          	add    $0x7f,%rax
    904a:	48 83 e0 80          	and    $0xffffffffffffff80,%rax
    904e:	48 05 00 82 10 03    	add    $0x3108200,%rax
    9054:	48 39 f8             	cmp    %rdi,%rax
    9057:	76 0f                	jbe    9068 <p118_p111_rt_take4+0xb8>
    9059:	5b                   	pop    %rbx
    905a:	b8 04 00 00 00       	mov    $0x4,%eax
    905f:	5d                   	pop    %rbp
    9060:	41 5c                	pop    %r12
    9062:	c3                   	retq   
    9063:	0f 1f 44 00 00       	nopl   0x0(%rax,%rax,1)
    9068:	48 8b 73 08          	mov    0x8(%rbx),%rsi
    906c:	4c 8b 03             	mov    (%rbx),%r8
    906f:	8b 15 00 00 00 00    	mov    0x0(%rip),%edx        # 9075 <p118_p111_rt_take4+0xc5>	9071: R_X86_64_PC32	.bss+0x100264
    9075:	48 8b 46 10          	mov    0x10(%rsi),%rax
    9079:	49 89 04 f8          	mov    %rax,(%r8,%rdi,8)
    907d:	48 8b 86 10 01 00 00 	mov    0x110(%rsi),%rax
    9084:	48 89 7e 10          	mov    %rdi,0x10(%rsi)
    9088:	48 83 c0 04          	add    $0x4,%rax
    908c:	48 89 86 10 01 00 00 	mov    %rax,0x110(%rsi)
    9093:	48 39 d0             	cmp    %rdx,%rax
    9096:	0f 83 00 00 00 00    	jae    909c <p118_p111_rt_take4+0xec>	9098: R_X86_64_PC32	.text.unlikely+0x23c7
    909c:	5b                   	pop    %rbx
    909d:	b8 04 00 00 00       	mov    $0x4,%eax
    90a2:	5d                   	pop    %rbp
    90a3:	41 5c                	pop    %r12
    90a5:	c3                   	retq   
    90a6:	66 2e 0f 1f 84 00 00 00 00 00 	nopw   %cs:0x0(%rax,%rax,1)
    90b0:	49 8d 2c f9          	lea    (%r9,%rdi,8),%rbp
    90b4:	4c 8b 5b 08          	mov    0x8(%rbx),%r11
    90b8:	44 8b 65 04          	mov    0x4(%rbp),%r12d
    90bc:	44 8b 55 00          	mov    0x0(%rbp),%r10d
    90c0:	49 c1 e4 20          	shl    $0x20,%r12
    90c4:	4d 09 d4             	or     %r10,%r12
    90c7:	41 81 e2 ff ff ff 00 	and    $0xffffff,%r10d
    90ce:	49 83 fa 01          	cmp    $0x1,%r10
    90d2:	74 62                	je     9136 <p118_p111_rt_take4+0x186>
    90d4:	49 c1 ec 18          	shr    $0x18,%r12
    90d8:	31 c0                	xor    %eax,%eax
    90da:	4f 8d 04 e1          	lea    (%r9,%r12,8),%r8
    90de:	66 90                	xchg   %ax,%ax
    90e0:	49 8b 0c 00          	mov    (%r8,%rax,1),%rcx
    90e4:	48 89 0c 02          	mov    %rcx,(%rdx,%rax,1)
    90e8:	48 83 c0 08          	add    $0x8,%rax
    90ec:	48 83 f8 20          	cmp    $0x20,%rax
    90f0:	75 ee                	jne    90e0 <p118_p111_rt_take4+0x130>
    90f2:	49 83 fa 01          	cmp    $0x1,%r10
    90f6:	0f 85 00 00 00 00    	jne    90fc <p118_p111_rt_take4+0x14c>	90f8: R_X86_64_PC32	.text.unlikely+0x23eb
    90fc:	49 8b 03             	mov    (%r11),%rax
    90ff:	8b 15 00 00 00 00    	mov    0x0(%rip),%edx        # 9105 <p118_p111_rt_take4+0x155>	9101: R_X86_64_PC32	.bss+0x100264
    9105:	48 89 45 00          	mov    %rax,0x0(%rbp)
    9109:	49 8b 83 00 01 00 00 	mov    0x100(%r11),%rax
    9110:	49 89 3b             	mov    %rdi,(%r11)
    9113:	48 83 c0 01          	add    $0x1,%rax
    9117:	49 89 83 00 01 00 00 	mov    %rax,0x100(%r11)
    911e:	48 39 d0             	cmp    %rdx,%rax
    9121:	0f 83 00 00 00 00    	jae    9127 <p118_p111_rt_take4+0x177>	9123: R_X86_64_PC32	.text.unlikely+0x23d9
    9127:	4c 8b 05 00 00 00 00 	mov    0x0(%rip),%r8        # 912e <p118_p111_rt_take4+0x17e>	912a: R_X86_64_PC32	.bss+0x1001ac
    912e:	4c 89 e7             	mov    %r12,%rdi
    9131:	e9 0c ff ff ff       	jmpq   9042 <p118_p111_rt_take4+0x92>
    9136:	8b 45 00             	mov    0x0(%rbp),%eax
    9139:	eb 99                	jmp    90d4 <p118_p111_rt_take4+0x124>
    913b:	48 8d 3d 00 00 00 00 	lea    0x0(%rip),%rdi        # 9142 <p118_p111_rt_take4+0x192>	913e: R_X86_64_PC32	.LC149-0x4
    9142:	e8 19 72 ff ff       	callq  360 <err_fail>
    9147:	48 8d 3d 00 00 00 00 	lea    0x0(%rip),%rdi        # 914e <p118_p111_rt_take4+0x19e>	914a: R_X86_64_PC32	.LC150-0x4
    914e:	e8 0d 72 ff ff       	callq  360 <err_fail>
    9153:	66 66 2e 0f 1f 84 00 00 00 00 00 	data16 nopw %cs:0x0(%rax,%rax,1)
    915e:	66 90                	xchg   %ax,%ax

