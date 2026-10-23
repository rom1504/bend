
/home/ai/bend2/build/publish/bend/selfhost/build/phase126/runtime-divmod01/runtime.o:     file format elf64-x86-64


Disassembly of section .text:

0000000000009330 <p118_rt_borrow_fields>:
    9330:	48 83 ec 08          	sub    $0x8,%rsp
    9334:	48 8b 05 00 00 00 00 	mov    0x0(%rip),%rax        # 933b <p118_rt_borrow_fields+0xb>
    933b:	89 c9                	mov    %ecx,%ecx
    933d:	48 3b 48 18          	cmp    0x18(%rax),%rcx
    9341:	72 0d                	jb     9350 <p118_rt_borrow_fields+0x20>
    9343:	48 8d 3d 00 00 00 00 	lea    0x0(%rip),%rdi        # 934a <p118_rt_borrow_fields+0x1a>
    934a:	e8 11 70 ff ff       	callq  360 <err_fail>
    934f:	90                   	nop
    9350:	49 89 f9             	mov    %rdi,%r9
    9353:	48 89 f7             	mov    %rsi,%rdi
    9356:	48 89 d6             	mov    %rdx,%rsi
    9359:	48 89 fa             	mov    %rdi,%rdx
    935c:	48 c1 ea 28          	shr    $0x28,%rdx
    9360:	0f b7 d2             	movzwl %dx,%edx
    9363:	48 39 d1             	cmp    %rdx,%rcx
    9366:	75 db                	jne    9343 <p118_rt_borrow_fields+0x13>
    9368:	48 8b 80 80 00 00 00 	mov    0x80(%rax),%rax
    936f:	0f b6 04 08          	movzbl (%rax,%rcx,1),%eax
    9373:	44 39 c0             	cmp    %r8d,%eax
    9376:	75 cb                	jne    9343 <p118_rt_borrow_fields+0x13>
    9378:	45 85 c0             	test   %r8d,%r8d
    937b:	74 63                	je     93e0 <p118_rt_borrow_fields+0xb0>
    937d:	48 85 f6             	test   %rsi,%rsi
    9380:	74 c1                	je     9343 <p118_rt_borrow_fields+0x13>
    9382:	45 85 c0             	test   %r8d,%r8d
    9385:	74 59                	je     93e0 <p118_rt_borrow_fields+0xb0>
    9387:	48 89 f8             	mov    %rdi,%rax
    938a:	48 c1 e8 38          	shr    $0x38,%rax
    938e:	83 e0 7f             	and    $0x7f,%eax
    9391:	41 83 f8 01          	cmp    $0x1,%r8d
    9395:	74 59                	je     93f0 <p118_rt_borrow_fields+0xc0>
    9397:	48 83 f8 02          	cmp    $0x2,%rax
    939b:	0f 85 9b 00 00 00    	jne    943c <p118_rt_borrow_fields+0x10c>
    93a1:	48 b8 ff ff ff ff ff 	movabs $0xffffffffff,%rax
    93a8:	00 00 00 
    93ab:	49 8b 11             	mov    (%r9),%rdx
    93ae:	48 21 f8             	and    %rdi,%rax
    93b1:	48 85 ff             	test   %rdi,%rdi
    93b4:	78 5a                	js     9410 <p118_rt_borrow_fields+0xe0>
    93b6:	48 8d 0c c2          	lea    (%rdx,%rax,8),%rcx
    93ba:	41 8d 78 ff          	lea    -0x1(%r8),%edi
    93be:	31 c0                	xor    %eax,%eax
    93c0:	48 8b 14 c1          	mov    (%rcx,%rax,8),%rdx
    93c4:	48 89 14 c6          	mov    %rdx,(%rsi,%rax,8)
    93c8:	48 89 c2             	mov    %rax,%rdx
    93cb:	48 83 c0 01          	add    $0x1,%rax
    93cf:	48 39 d7             	cmp    %rdx,%rdi
    93d2:	75 ec                	jne    93c0 <p118_rt_borrow_fields+0x90>
    93d4:	44 89 c0             	mov    %r8d,%eax
    93d7:	48 83 c4 08          	add    $0x8,%rsp
    93db:	c3                   	retq   
    93dc:	0f 1f 40 00          	nopl   0x0(%rax)
    93e0:	31 c0                	xor    %eax,%eax
    93e2:	48 83 c4 08          	add    $0x8,%rsp
    93e6:	c3                   	retq   
    93e7:	66 0f 1f 84 00 00 00 	nopw   0x0(%rax,%rax,1)
    93ee:	00 00 
    93f0:	48 83 f8 01          	cmp    $0x1,%rax
    93f4:	75 a1                	jne    9397 <p118_rt_borrow_fields+0x67>
    93f6:	48 b8 ff ff ff ff ff 	movabs $0xffffffffff,%rax
    93fd:	00 00 00 
    9400:	48 21 c7             	and    %rax,%rdi
    9403:	48 89 3e             	mov    %rdi,(%rsi)
    9406:	eb cc                	jmp    93d4 <p118_rt_borrow_fields+0xa4>
    9408:	0f 1f 84 00 00 00 00 	nopl   0x0(%rax,%rax,1)
    940f:	00 
    9410:	48 8d 0c c2          	lea    (%rdx,%rax,8),%rcx
    9414:	8b 41 04             	mov    0x4(%rcx),%eax
    9417:	8b 11                	mov    (%rcx),%edx
    9419:	48 c1 e0 20          	shl    $0x20,%rax
    941d:	48 09 d0             	or     %rdx,%rax
    9420:	81 e2 ff ff ff 00    	and    $0xffffff,%edx
    9426:	48 83 fa 01          	cmp    $0x1,%rdx
    942a:	74 0c                	je     9438 <p118_rt_borrow_fields+0x108>
    942c:	49 8b 11             	mov    (%r9),%rdx
    942f:	48 c1 e8 18          	shr    $0x18,%rax
    9433:	e9 7e ff ff ff       	jmpq   93b6 <p118_rt_borrow_fields+0x86>
    9438:	8b 11                	mov    (%rcx),%edx
    943a:	eb f0                	jmp    942c <p118_rt_borrow_fields+0xfc>
    943c:	48 8d 3d 00 00 00 00 	lea    0x0(%rip),%rdi        # 9443 <p118_rt_borrow_fields+0x113>
    9443:	e8 18 6f ff ff       	callq  360 <err_fail>

Disassembly of section .text.unlikely:
