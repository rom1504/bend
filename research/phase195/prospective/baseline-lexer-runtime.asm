
/home/ai/bend2/build/publish/bend/selfhost/build/phase194/native45-02/lexer/machine/program:     file format elf64-x86-64


Disassembly of section .init:

Disassembly of section .plt:

Disassembly of section .text:

000000000041c2a0 <p111_rt_op>:
  41c2a0:	push   r15
  41c2a2:	push   r14
  41c2a4:	push   r13
  41c2a6:	push   r12
  41c2a8:	push   rbp
  41c2a9:	push   rbx
  41c2aa:	sub    rsp,0x58
  41c2ae:	mov    r12,QWORD PTR [rdi+0x8]
  41c2b2:	mov    rbp,QWORD PTR [rdi]
  41c2b5:	cmp    esi,0x56
  41c2b8:	ja     41d44e <p111_rt_op+0x11ae>
  41c2be:	lea    rdi,[rip+0x7dd7]        # 42409c <_IO_stdin_used+0x109c>
  41c2c5:	mov    rbx,rdx
  41c2c8:	mov    edx,esi
  41c2ca:	movsxd rax,DWORD PTR [rdi+rdx*4]
  41c2ce:	add    rax,rdi
  41c2d1:	jmp    rax
  41c2d3:	nop    DWORD PTR [rax+rax*1+0x0]
  41c2d8:	cmp    esi,0x54
  41c2db:	je     41d20e <p111_rt_op+0xf6e>
  41c2e1:	cmp    ecx,0x3
  41c2e4:	jne    41d132 <p111_rt_op+0xe92>
  41c2ea:	sub    esi,0x4c
  41c2ed:	xor    r8d,r8d
  41c2f0:	movabs rdx,0xffffffffff
  41c2fa:	mov    r10,QWORD PTR [rbx]
  41c2fd:	mov    edi,DWORD PTR [rbx+0x10]
  41c300:	mov    r11,QWORD PTR [rbx+0x8]
  41c304:	and    rdx,r10
  41c307:	lea    r9,[rdx*8+0x0]
  41c30f:	test   r10,r10
  41c312:	js     41d39d <p111_rt_op+0x10fd>
  41c318:	mov    rcx,r10
  41c31b:	mov    edx,0x1
  41c320:	shr    rcx,0x28
  41c324:	and    ecx,0x1f
  41c327:	shl    rdx,cl
  41c32a:	mov    rcx,r10
  41c32d:	mov    r10d,esi
  41c330:	lea    eax,[rdx-0x1]
  41c333:	shr    rcx,0x38
  41c337:	and    eax,r11d
  41c33a:	and    ecx,0x7f
  41c33d:	lea    edx,[rax+rax*1]
  41c340:	shl    rax,0x2
  41c344:	shl    rdx,0x2
  41c348:	cmp    rcx,0x4
  41c34c:	cmove  rdx,rax
  41c350:	add    rdx,r9
  41c353:	lea    r9,[rip+0x7e9e]        # 4241f8 <_IO_stdin_used+0x11f8>
  41c35a:	add    rdx,rbp
  41c35d:	mov    ecx,DWORD PTR [rdx]
  41c35f:	cmp    esi,0x9
  41c362:	ja     41d1bf <p111_rt_op+0xf1f>
  41c368:	movsxd rax,DWORD PTR [r9+r10*4]
  41c36c:	add    rax,r9
  41c36f:	jmp    rax
  41c371:	nop    DWORD PTR [rax+0x0]
  41c378:	cmp    ecx,0x1
  41c37b:	jne    41d132 <p111_rt_op+0xe92>
  41c381:	mov    r12,QWORD PTR [rbx]
  41c384:	add    rsp,0x58
  41c388:	mov    rax,r12
  41c38b:	pop    rbx
  41c38c:	pop    rbp
  41c38d:	pop    r12
  41c38f:	pop    r13
  41c391:	pop    r14
  41c393:	pop    r15
  41c395:	ret    
  41c396:	nop    WORD PTR cs:[rax+rax*1+0x0]
  41c3a0:	cmp    ecx,0x2
  41c3a3:	jne    41d132 <p111_rt_op+0xe92>
  41c3a9:	xor    r12d,r12d
  41c3ac:	mov    eax,DWORD PTR [rbx+0x8]
  41c3af:	cmp    DWORD PTR [rbx],eax
  41c3b1:	setne  r12b
  41c3b5:	jmp    41c384 <p111_rt_op+0xe4>
  41c3b7:	nop    WORD PTR [rax+rax*1+0x0]
  41c3c0:	cmp    ecx,0x2
  41c3c3:	jne    41d132 <p111_rt_op+0xe92>
  41c3c9:	xor    r12d,r12d
  41c3cc:	mov    eax,DWORD PTR [rbx+0x8]
  41c3cf:	cmp    DWORD PTR [rbx],eax
  41c3d1:	sete   r12b
  41c3d5:	jmp    41c384 <p111_rt_op+0xe4>
  41c3d7:	nop    WORD PTR [rax+rax*1+0x0]
  41c3e0:	cmp    ecx,0x2
  41c3e3:	jne    41d132 <p111_rt_op+0xe92>
  41c3e9:	mov    r12,QWORD PTR [rbx+0x8]
  41c3ed:	imul   r12d,DWORD PTR [rbx]
  41c3f1:	jmp    41c384 <p111_rt_op+0xe4>
  41c3f3:	nop    DWORD PTR [rax+rax*1+0x0]
  41c3f8:	cmp    ecx,0x2
  41c3fb:	jne    41d132 <p111_rt_op+0xe92>
  41c401:	mov    r12,QWORD PTR [rbx+0x8]
  41c405:	xor    r12d,DWORD PTR [rbx]
  41c408:	jmp    41c384 <p111_rt_op+0xe4>
  41c40d:	nop    DWORD PTR [rax]
  41c410:	cmp    ecx,0x2
  41c413:	jne    41d132 <p111_rt_op+0xe92>
  41c419:	mov    r12,QWORD PTR [rbx+0x8]
  41c41d:	or     r12d,DWORD PTR [rbx]
  41c420:	jmp    41c384 <p111_rt_op+0xe4>
  41c425:	nop    DWORD PTR [rax]
  41c428:	cmp    ecx,0x2
  41c42b:	jne    41d132 <p111_rt_op+0xe92>
  41c431:	mov    r12,QWORD PTR [rbx+0x8]
  41c435:	and    r12d,DWORD PTR [rbx]
  41c438:	jmp    41c384 <p111_rt_op+0xe4>
  41c43d:	nop    DWORD PTR [rax]
  41c440:	cmp    ecx,0x2
  41c443:	jne    41d132 <p111_rt_op+0xe92>
  41c449:	mov    r12,QWORD PTR [rbx]
  41c44c:	sub    r12d,DWORD PTR [rbx+0x8]
  41c450:	jmp    41c384 <p111_rt_op+0xe4>
  41c455:	nop    DWORD PTR [rax]
  41c458:	cmp    ecx,0x2
  41c45b:	jne    41d132 <p111_rt_op+0xe92>
  41c461:	mov    r12,QWORD PTR [rbx+0x8]
  41c465:	add    r12d,DWORD PTR [rbx]
  41c468:	jmp    41c384 <p111_rt_op+0xe4>
  41c46d:	nop    DWORD PTR [rax]
  41c470:	cmp    ecx,0x2
  41c473:	jne    41d132 <p111_rt_op+0xe92>
  41c479:	xor    r12d,r12d
  41c47c:	mov    eax,DWORD PTR [rbx+0x8]
  41c47f:	cmp    DWORD PTR [rbx],eax
  41c481:	setbe  r12b
  41c485:	jmp    41c384 <p111_rt_op+0xe4>
  41c48a:	nop    WORD PTR [rax+rax*1+0x0]
  41c490:	cmp    ecx,0x2
  41c493:	jne    41d132 <p111_rt_op+0xe92>
  41c499:	xor    r12d,r12d
  41c49c:	mov    eax,DWORD PTR [rbx+0x8]
  41c49f:	cmp    DWORD PTR [rbx],eax
  41c4a1:	setb   r12b
  41c4a5:	jmp    41c384 <p111_rt_op+0xe4>
  41c4aa:	nop    WORD PTR [rax+rax*1+0x0]
  41c4b0:	cmp    ecx,0x2
  41c4b3:	jne    41d132 <p111_rt_op+0xe92>
  41c4b9:	xor    r12d,r12d
  41c4bc:	movss  xmm0,DWORD PTR [rbx+0x8]
  41c4c1:	ucomiss xmm0,DWORD PTR [rbx]
  41c4c4:	mov    eax,0x1
  41c4c9:	setp   r12b
  41c4cd:	cmovne r12,rax
  41c4d1:	jmp    41c384 <p111_rt_op+0xe4>
  41c4d6:	nop    WORD PTR cs:[rax+rax*1+0x0]
  41c4e0:	cmp    ecx,0x2
  41c4e3:	jne    41d132 <p111_rt_op+0xe92>
  41c4e9:	xor    r12d,r12d
  41c4ec:	movss  xmm0,DWORD PTR [rbx+0x8]
  41c4f1:	comiss xmm0,DWORD PTR [rbx]
  41c4f4:	setae  r12b
  41c4f8:	jmp    41c384 <p111_rt_op+0xe4>
  41c4fd:	nop    DWORD PTR [rax]
  41c500:	cmp    ecx,0x2
  41c503:	jne    41d132 <p111_rt_op+0xe92>
  41c509:	xor    r12d,r12d
  41c50c:	movss  xmm0,DWORD PTR [rbx+0x8]
  41c511:	comiss xmm0,DWORD PTR [rbx]
  41c514:	seta   r12b
  41c518:	jmp    41c384 <p111_rt_op+0xe4>
  41c51d:	nop    DWORD PTR [rax]
  41c520:	cmp    ecx,0x2
  41c523:	jne    41d132 <p111_rt_op+0xe92>
  41c529:	mov    r8,QWORD PTR [rbx+0x8]
  41c52d:	mov    rcx,QWORD PTR [rbx]
  41c530:	test   r8,r8
  41c533:	je     41c543 <p111_rt_op+0x2a3>
  41c535:	mov    rax,rcx
  41c538:	xor    edx,edx
  41c53a:	div    r8
  41c53d:	mov    rcx,rdx
  41c540:	mov    r8,rax
  41c543:	mov    rdx,r8
  41c546:	add    rsp,0x58
  41c54a:	mov    rdi,rbp
  41c54d:	mov    rsi,r12
  41c550:	pop    rbx
  41c551:	pop    rbp
  41c552:	pop    r12
  41c554:	pop    r13
  41c556:	pop    r14
  41c558:	pop    r15
  41c55a:	jmp    4195c0 <p111_tuple>
  41c55f:	nop
  41c560:	cmp    ecx,0x2
  41c563:	jne    41d132 <p111_rt_op+0xe92>
  41c569:	mov    rax,QWORD PTR [rbx]
  41c56c:	mov    r12d,0x1
  41c572:	cmp    rax,0x1
  41c576:	je     41c5a2 <p111_rt_op+0x302>
  41c578:	mov    rdx,rax
  41c57b:	xor    r12d,r12d
  41c57e:	shr    rdx,0x38
  41c582:	and    edx,0x7f
  41c585:	cmp    rdx,0x1
  41c589:	jne    41c5a2 <p111_rt_op+0x302>
  41c58b:	shr    rax,0x28
  41c58f:	mov    edx,DWORD PTR [rip+0x10e9a3]        # 52af38 <p111_core_cids+0x38>
  41c595:	xor    r12d,r12d
  41c598:	movzx  eax,ax
  41c59b:	cmp    rax,rdx
  41c59e:	sete   r12b
  41c5a2:	mov    rax,QWORD PTR [rbx+0x8]
  41c5a6:	cmp    rax,0x1
  41c5aa:	je     41d225 <p111_rt_op+0xf85>
  41c5b0:	mov    rdx,rax
  41c5b3:	shr    rdx,0x38
  41c5b7:	and    edx,0x7f
  41c5ba:	cmp    rdx,0x1
  41c5be:	jne    41c5e0 <p111_rt_op+0x340>
  41c5c0:	shr    rax,0x28
  41c5c4:	mov    edx,DWORD PTR [rip+0x10e96e]        # 52af38 <p111_core_cids+0x38>
  41c5ca:	movzx  eax,ax
  41c5cd:	cmp    rax,rdx
  41c5d0:	sete   al
  41c5d3:	movzx  eax,al
  41c5d6:	xor    r12d,eax
  41c5d9:	nop    DWORD PTR [rax+0x0]
  41c5e0:	movsxd r12,r12d
  41c5e3:	jmp    41c384 <p111_rt_op+0xe4>
  41c5e8:	nop    DWORD PTR [rax+rax*1+0x0]
  41c5f0:	cmp    ecx,0x3
  41c5f3:	jne    41d132 <p111_rt_op+0xe92>
  41c5f9:	mov    rdx,QWORD PTR [rbx]
  41c5fc:	mov    eax,0x1
  41c601:	mov    r8,QWORD PTR [rbx+0x10]
  41c605:	mov    rcx,rdx
  41c608:	shr    rcx,0x28
  41c60c:	and    ecx,0x1f
  41c60f:	shl    rax,cl
  41c612:	movabs rcx,0xffffffffff
  41c61c:	and    rcx,rdx
  41c61f:	sub    eax,0x1
  41c622:	and    eax,DWORD PTR [rbx+0x8]
  41c625:	mov    r14,rcx
  41c628:	test   rdx,rdx
  41c62b:	js     41d370 <p111_rt_op+0x10d0>
  41c631:	mov    r9,QWORD PTR [rip+0x10e918]        # 52af50 <p111_program_active>
  41c638:	mov    r13d,eax
  41c63b:	test   BYTE PTR [r9+0x58],0x2
  41c640:	je     41d22e <p111_rt_op+0xf8e>
  41c646:	lea    rax,[r13*4+0x0]
  41c64e:	lea    rax,[rax+r14*8]
  41c652:	add    rax,rbp
  41c655:	mov    r15d,DWORD PTR [rax]
  41c658:	mov    DWORD PTR [rax],r8d
  41c65b:	mov    rcx,r15
  41c65e:	mov    rdx,QWORD PTR [rbx]
  41c661:	jmp    41c546 <p111_rt_op+0x2a6>
  41c666:	nop    WORD PTR cs:[rax+rax*1+0x0]
  41c670:	cmp    ecx,0x3
  41c673:	jne    41d132 <p111_rt_op+0xe92>
  41c679:	mov    rdx,QWORD PTR [rbx]
  41c67c:	mov    eax,0x1
  41c681:	mov    r13,QWORD PTR [rbx+0x10]
  41c685:	mov    rcx,rdx
  41c688:	shr    rcx,0x28
  41c68c:	and    ecx,0x1f
  41c68f:	shl    rax,cl
  41c692:	movabs rcx,0xffffffffff
  41c69c:	and    rcx,rdx
  41c69f:	sub    eax,0x1
  41c6a2:	and    eax,DWORD PTR [rbx+0x8]
  41c6a5:	mov    r15,rcx
  41c6a8:	test   rdx,rdx
  41c6ab:	js     41d343 <p111_rt_op+0x10a3>
  41c6b1:	mov    r8,QWORD PTR [rip+0x10e898]        # 52af50 <p111_program_active>
  41c6b8:	mov    r14d,eax
  41c6bb:	test   BYTE PTR [r8+0x58],0x2
  41c6c0:	je     41d257 <p111_rt_op+0xfb7>
  41c6c6:	lea    rax,[r14*4+0x0]
  41c6ce:	lea    rax,[rax+r15*8]
  41c6d2:	mov    DWORD PTR [rbp+rax*1+0x0],r13d
  41c6d7:	jmp    41c381 <p111_rt_op+0xe1>
  41c6dc:	nop    DWORD PTR [rax+0x0]
  41c6e0:	cmp    ecx,0x1
  41c6e3:	jne    41d132 <p111_rt_op+0xe92>
  41c6e9:	mov    rdx,QWORD PTR [rbx]
  41c6ec:	mov    eax,0x1
  41c6f1:	mov    rcx,rdx
  41c6f4:	shr    rcx,0x28
  41c6f8:	and    ecx,0x1f
  41c6fb:	shl    rax,cl
  41c6fe:	mov    rcx,rax
  41c701:	jmp    41c546 <p111_rt_op+0x2a6>
  41c706:	nop    WORD PTR cs:[rax+rax*1+0x0]
  41c710:	cmp    ecx,0x1
  41c713:	jne    41d132 <p111_rt_op+0xe92>
  41c719:	pxor   xmm0,xmm0
  41c71d:	cvtss2sd xmm0,DWORD PTR [rbx]
  41c721:	call   4022f0 <log10@plt>
  41c726:	cvtsd2ss xmm0,xmm0
  41c72a:	movd   r12d,xmm0
  41c72f:	jmp    41c384 <p111_rt_op+0xe4>
  41c734:	nop    DWORD PTR [rax+0x0]
  41c738:	cmp    ecx,0x1
  41c73b:	jne    41d132 <p111_rt_op+0xe92>
  41c741:	pxor   xmm0,xmm0
  41c745:	cvtss2sd xmm0,DWORD PTR [rbx]
  41c749:	call   402050 <log2@plt>
  41c74e:	cvtsd2ss xmm0,xmm0
  41c752:	movd   r12d,xmm0
  41c757:	jmp    41c384 <p111_rt_op+0xe4>
  41c75c:	nop    DWORD PTR [rax+0x0]
  41c760:	cmp    ecx,0x1
  41c763:	jne    41d132 <p111_rt_op+0xe92>
  41c769:	pxor   xmm0,xmm0
  41c76d:	cvtss2sd xmm0,DWORD PTR [rbx]
  41c771:	call   402230 <log@plt>
  41c776:	cvtsd2ss xmm0,xmm0
  41c77a:	movd   r12d,xmm0
  41c77f:	jmp    41c384 <p111_rt_op+0xe4>
  41c784:	nop    DWORD PTR [rax+0x0]
  41c788:	cmp    ecx,0x1
  41c78b:	jne    41d132 <p111_rt_op+0xe92>
  41c791:	mov    rax,QWORD PTR [rbx]
  41c794:	test   rax,rax
  41c797:	js     41d1e5 <p111_rt_op+0xf45>
  41c79d:	pxor   xmm0,xmm0
  41c7a1:	cvtsi2ss xmm0,rax
  41c7a6:	nop    WORD PTR cs:[rax+rax*1+0x0]
  41c7b0:	movd   r12d,xmm0
  41c7b5:	jmp    41c384 <p111_rt_op+0xe4>
  41c7ba:	nop    WORD PTR [rax+rax*1+0x0]
  41c7c0:	cmp    ecx,0x2
  41c7c3:	jne    41d132 <p111_rt_op+0xe92>
  41c7c9:	mov    rdx,QWORD PTR [rbx]
  41c7cc:	mov    rax,QWORD PTR [rbx+0x8]
  41c7d0:	mov    r12,rdx
  41c7d3:	sub    r12,rax
  41c7d6:	cmp    rdx,rax
  41c7d9:	mov    eax,0x0
  41c7de:	cmovb  r12,rax
  41c7e2:	jmp    41c384 <p111_rt_op+0xe4>
  41c7e7:	nop    WORD PTR [rax+rax*1+0x0]
  41c7f0:	cmp    ecx,0x2
  41c7f3:	jne    41d132 <p111_rt_op+0xe92>
  41c7f9:	movabs rax,0xffffffffffff
  41c803:	mov    r12,QWORD PTR [rbx+0x8]
  41c807:	add    r12,QWORD PTR [rbx]
  41c80a:	cmp    r12,rax
  41c80d:	jbe    41c384 <p111_rt_op+0xe4>
  41c813:	call   418d10 <nat_chk.part.0>
  41c818:	nop    DWORD PTR [rax+rax*1+0x0]
  41c820:	cmp    ecx,0x1
  41c823:	jne    41d132 <p111_rt_op+0xe92>
  41c829:	movss  xmm0,DWORD PTR [rbx]
  41c82d:	ucomiss xmm0,xmm0
  41c830:	jp     41d32c <p111_rt_op+0x108c>
  41c836:	lea    r13,[rsp+0x20]
  41c83b:	mov    rdi,r13
  41c83e:	call   418d20 <f32_text.part.0>
  41c843:	mov    rsi,r12
  41c846:	movsxd rcx,eax
  41c849:	mov    rdx,r13
  41c84c:	mov    rdi,rbp
  41c84f:	call   41a930 <io_str>
  41c854:	mov    r12,rax
  41c857:	jmp    41c384 <p111_rt_op+0xe4>
  41c85c:	nop    DWORD PTR [rax+0x0]
  41c860:	cmp    ecx,0x1
  41c863:	jne    41d132 <p111_rt_op+0xe92>
  41c869:	movss  xmm0,DWORD PTR [rbx]
  41c86d:	comiss xmm0,DWORD PTR [rip+0x7bc0]        # 424434 <hex.3+0x14>
  41c874:	jb     41d1dd <p111_rt_op+0xf3d>
  41c87a:	movss  xmm1,DWORD PTR [rip+0x7bbe]        # 424440 <hex.3+0x20>
  41c882:	comiss xmm1,xmm0
  41c885:	jbe    41d1dd <p111_rt_op+0xf3d>
  41c88b:	cvttss2si r12,xmm0
  41c890:	mov    r12d,r12d
  41c893:	jmp    41c384 <p111_rt_op+0xe4>
  41c898:	nop    DWORD PTR [rax+rax*1+0x0]
  41c8a0:	cmp    ecx,0x2
  41c8a3:	jne    41d132 <p111_rt_op+0xe92>
  41c8a9:	pxor   xmm0,xmm0
  41c8ad:	pxor   xmm1,xmm1
  41c8b1:	cvtss2sd xmm0,DWORD PTR [rbx]
  41c8b5:	cvtss2sd xmm1,DWORD PTR [rbx+0x8]
  41c8ba:	call   402240 <fmod@plt>
  41c8bf:	cvtsd2ss xmm0,xmm0
  41c8c3:	movd   r12d,xmm0
  41c8c8:	jmp    41c384 <p111_rt_op+0xe4>
  41c8cd:	nop    DWORD PTR [rax]
  41c8d0:	cmp    ecx,0x1
  41c8d3:	jne    41d132 <p111_rt_op+0xe92>
  41c8d9:	mov    r12d,DWORD PTR [rbx]
  41c8dc:	movd   xmm0,r12d
  41c8e1:	xorps  xmm0,XMMWORD PTR [rip+0x7b78]        # 424460 <hex.3+0x40>
  41c8e8:	movd   r12d,xmm0
  41c8ed:	jmp    41c384 <p111_rt_op+0xe4>
  41c8f2:	nop    WORD PTR [rax+rax*1+0x0]
  41c8f8:	cmp    ecx,0x2
  41c8fb:	jne    41d132 <p111_rt_op+0xe92>
  41c901:	pxor   xmm0,xmm0
  41c905:	pxor   xmm1,xmm1
  41c909:	cvtss2sd xmm0,DWORD PTR [rbx]
  41c90d:	cvtss2sd xmm1,DWORD PTR [rbx+0x8]
  41c912:	call   4023c0 <atan2@plt>
  41c917:	cvtsd2ss xmm0,xmm0
  41c91b:	movd   r12d,xmm0
  41c920:	jmp    41c384 <p111_rt_op+0xe4>
  41c925:	nop    DWORD PTR [rax]
  41c928:	cmp    ecx,0x2
  41c92b:	jne    41d132 <p111_rt_op+0xe92>
  41c931:	pxor   xmm0,xmm0
  41c935:	pxor   xmm1,xmm1
  41c939:	cvtss2sd xmm0,DWORD PTR [rbx]
  41c93d:	cvtss2sd xmm1,DWORD PTR [rbx+0x8]
  41c942:	call   402150 <pow@plt>
  41c947:	cvtsd2ss xmm0,xmm0
  41c94b:	movd   r12d,xmm0
  41c950:	jmp    41c384 <p111_rt_op+0xe4>
  41c955:	nop    DWORD PTR [rax]
  41c958:	cmp    ecx,0x1
  41c95b:	jne    41d132 <p111_rt_op+0xe92>
  41c961:	mov    r12d,DWORD PTR [rbx]
  41c964:	movd   xmm0,r12d
  41c969:	andps  xmm0,XMMWORD PTR [rip+0x7ae0]        # 424450 <hex.3+0x30>
  41c970:	movd   r12d,xmm0
  41c975:	jmp    41c384 <p111_rt_op+0xe4>
  41c97a:	nop    WORD PTR [rax+rax*1+0x0]
  41c980:	cmp    ecx,0x1
  41c983:	jne    41d132 <p111_rt_op+0xe92>
  41c989:	mov    eax,DWORD PTR [rbx]
  41c98b:	movss  xmm1,DWORD PTR [rip+0x7abd]        # 424450 <hex.3+0x30>
  41c993:	movss  xmm3,DWORD PTR [rip+0x7a9d]        # 424438 <hex.3+0x18>
  41c99b:	movd   xmm2,eax
  41c99f:	movd   xmm0,eax
  41c9a3:	andps  xmm2,xmm1
  41c9a6:	ucomiss xmm3,xmm2
  41c9a9:	jbe    41c7b0 <p111_rt_op+0x510>
  41c9af:	cvttss2si edx,xmm0
  41c9b3:	pxor   xmm0,xmm0
  41c9b7:	movd   xmm2,eax
  41c9bb:	andnps xmm1,xmm2
  41c9be:	cvtsi2ss xmm0,edx
  41c9c2:	orps   xmm0,xmm1
  41c9c5:	jmp    41c7b0 <p111_rt_op+0x510>
  41c9ca:	nop    WORD PTR [rax+rax*1+0x0]
  41c9d0:	cmp    ecx,0x1
  41c9d3:	jne    41d132 <p111_rt_op+0xe92>
  41c9d9:	movss  xmm0,DWORD PTR [rbx]
  41c9dd:	movss  xmm2,DWORD PTR [rip+0x7a6b]        # 424450 <hex.3+0x30>
  41c9e5:	movss  xmm3,DWORD PTR [rip+0x7a4b]        # 424438 <hex.3+0x18>
  41c9ed:	movaps xmm1,xmm0
  41c9f0:	andps  xmm1,xmm2
  41c9f3:	ucomiss xmm3,xmm1
  41c9f6:	jbe    41c7b0 <p111_rt_op+0x510>
  41c9fc:	cvttss2si eax,xmm0
  41ca00:	pxor   xmm1,xmm1
  41ca04:	movaps xmm3,xmm0
  41ca07:	movss  xmm4,DWORD PTR [rip+0x7a2d]        # 42443c <hex.3+0x1c>
  41ca0f:	andnps xmm2,xmm0
  41ca12:	cvtsi2ss xmm1,eax
  41ca16:	cmpnless xmm3,xmm1
  41ca1b:	andps  xmm3,xmm4
  41ca1e:	addss  xmm1,xmm3
  41ca22:	orps   xmm1,xmm2
  41ca25:	movaps xmm0,xmm1
  41ca28:	jmp    41c7b0 <p111_rt_op+0x510>
  41ca2d:	nop    DWORD PTR [rax]
  41ca30:	cmp    ecx,0x1
  41ca33:	jne    41d132 <p111_rt_op+0xe92>
  41ca39:	movss  xmm0,DWORD PTR [rbx]
  41ca3d:	movss  xmm2,DWORD PTR [rip+0x7a0b]        # 424450 <hex.3+0x30>
  41ca45:	movss  xmm3,DWORD PTR [rip+0x79eb]        # 424438 <hex.3+0x18>
  41ca4d:	movaps xmm1,xmm0
  41ca50:	andps  xmm1,xmm2
  41ca53:	ucomiss xmm3,xmm1
  41ca56:	jbe    41c7b0 <p111_rt_op+0x510>
  41ca5c:	cvttss2si eax,xmm0
  41ca60:	pxor   xmm1,xmm1
  41ca64:	movss  xmm4,DWORD PTR [rip+0x79d0]        # 42443c <hex.3+0x1c>
  41ca6c:	andnps xmm2,xmm0
  41ca6f:	cvtsi2ss xmm1,eax
  41ca73:	movaps xmm3,xmm1
  41ca76:	cmpnless xmm3,xmm0
  41ca7b:	andps  xmm3,xmm4
  41ca7e:	subss  xmm1,xmm3
  41ca82:	orps   xmm1,xmm2
  41ca85:	movaps xmm0,xmm1
  41ca88:	jmp    41c7b0 <p111_rt_op+0x510>
  41ca8d:	nop    DWORD PTR [rax]
  41ca90:	cmp    ecx,0x1
  41ca93:	jne    41d132 <p111_rt_op+0xe92>
  41ca99:	pxor   xmm0,xmm0
  41ca9d:	cvtss2sd xmm0,DWORD PTR [rbx]
  41caa1:	call   4024a0 <tanh@plt>
  41caa6:	cvtsd2ss xmm0,xmm0
  41caaa:	movd   r12d,xmm0
  41caaf:	jmp    41c384 <p111_rt_op+0xe4>
  41cab4:	nop    DWORD PTR [rax+0x0]
  41cab8:	cmp    ecx,0x1
  41cabb:	jne    41d132 <p111_rt_op+0xe92>
  41cac1:	pxor   xmm0,xmm0
  41cac5:	cvtss2sd xmm0,DWORD PTR [rbx]
  41cac9:	call   402340 <cosh@plt>
  41cace:	cvtsd2ss xmm0,xmm0
  41cad2:	movd   r12d,xmm0
  41cad7:	jmp    41c384 <p111_rt_op+0xe4>
  41cadc:	nop    DWORD PTR [rax+0x0]
  41cae0:	cmp    ecx,0x1
  41cae3:	jne    41d132 <p111_rt_op+0xe92>
  41cae9:	pxor   xmm0,xmm0
  41caed:	cvtss2sd xmm0,DWORD PTR [rbx]
  41caf1:	call   402360 <sinh@plt>
  41caf6:	cvtsd2ss xmm0,xmm0
  41cafa:	movd   r12d,xmm0
  41caff:	jmp    41c384 <p111_rt_op+0xe4>
  41cb04:	nop    DWORD PTR [rax+0x0]
  41cb08:	cmp    ecx,0x1
  41cb0b:	jne    41d132 <p111_rt_op+0xe92>
  41cb11:	pxor   xmm0,xmm0
  41cb15:	cvtss2sd xmm0,DWORD PTR [rbx]
  41cb19:	call   402140 <atan@plt>
  41cb1e:	cvtsd2ss xmm0,xmm0
  41cb22:	movd   r12d,xmm0
  41cb27:	jmp    41c384 <p111_rt_op+0xe4>
  41cb2c:	nop    DWORD PTR [rax+0x0]
  41cb30:	cmp    ecx,0x1
  41cb33:	jne    41d132 <p111_rt_op+0xe92>
  41cb39:	pxor   xmm0,xmm0
  41cb3d:	cvtss2sd xmm0,DWORD PTR [rbx]
  41cb41:	call   402280 <acos@plt>
  41cb46:	cvtsd2ss xmm0,xmm0
  41cb4a:	movd   r12d,xmm0
  41cb4f:	jmp    41c384 <p111_rt_op+0xe4>
  41cb54:	nop    DWORD PTR [rax+0x0]
  41cb58:	cmp    ecx,0x1
  41cb5b:	jne    41d132 <p111_rt_op+0xe92>
  41cb61:	pxor   xmm0,xmm0
  41cb65:	cvtss2sd xmm0,DWORD PTR [rbx]
  41cb69:	call   4024b0 <asin@plt>
  41cb6e:	cvtsd2ss xmm0,xmm0
  41cb72:	movd   r12d,xmm0
  41cb77:	jmp    41c384 <p111_rt_op+0xe4>
  41cb7c:	nop    DWORD PTR [rax+0x0]
  41cb80:	cmp    ecx,0x1
  41cb83:	jne    41d132 <p111_rt_op+0xe92>
  41cb89:	pxor   xmm0,xmm0
  41cb8d:	cvtss2sd xmm0,DWORD PTR [rbx]
  41cb91:	call   4023a0 <tan@plt>
  41cb96:	cvtsd2ss xmm0,xmm0
  41cb9a:	movd   r12d,xmm0
  41cb9f:	jmp    41c384 <p111_rt_op+0xe4>
  41cba4:	nop    DWORD PTR [rax+0x0]
  41cba8:	cmp    ecx,0x1
  41cbab:	jne    41d132 <p111_rt_op+0xe92>
  41cbb1:	pxor   xmm0,xmm0
  41cbb5:	cvtss2sd xmm0,DWORD PTR [rbx]
  41cbb9:	call   402260 <cos@plt>
  41cbbe:	cvtsd2ss xmm0,xmm0
  41cbc2:	movd   r12d,xmm0
  41cbc7:	jmp    41c384 <p111_rt_op+0xe4>
  41cbcc:	nop    DWORD PTR [rax+0x0]
  41cbd0:	cmp    ecx,0x1
  41cbd3:	jne    41d132 <p111_rt_op+0xe92>
  41cbd9:	pxor   xmm0,xmm0
  41cbdd:	cvtss2sd xmm0,DWORD PTR [rbx]
  41cbe1:	call   402480 <sin@plt>
  41cbe6:	cvtsd2ss xmm0,xmm0
  41cbea:	movd   r12d,xmm0
  41cbef:	jmp    41c384 <p111_rt_op+0xe4>
  41cbf4:	nop    DWORD PTR [rax+0x0]
  41cbf8:	cmp    ecx,0x2
  41cbfb:	jne    41d132 <p111_rt_op+0xe92>
  41cc01:	xor    r12d,r12d
  41cc04:	movss  xmm0,DWORD PTR [rbx+0x8]
  41cc09:	ucomiss xmm0,DWORD PTR [rbx]
  41cc0c:	mov    eax,0x0
  41cc11:	setnp  r12b
  41cc15:	cmovne r12,rax
  41cc19:	jmp    41c384 <p111_rt_op+0xe4>
  41cc1e:	xchg   ax,ax
  41cc20:	cmp    ecx,0x2
  41cc23:	jne    41d132 <p111_rt_op+0xe92>
  41cc29:	movss  xmm0,DWORD PTR [rbx]
  41cc2d:	divss  xmm0,DWORD PTR [rbx+0x8]
  41cc32:	movd   r12d,xmm0
  41cc37:	jmp    41c384 <p111_rt_op+0xe4>
  41cc3c:	nop    DWORD PTR [rax+0x0]
  41cc40:	cmp    ecx,0x2
  41cc43:	jne    41d132 <p111_rt_op+0xe92>
  41cc49:	movss  xmm0,DWORD PTR [rbx+0x8]
  41cc4e:	mulss  xmm0,DWORD PTR [rbx]
  41cc52:	movd   r12d,xmm0
  41cc57:	jmp    41c384 <p111_rt_op+0xe4>
  41cc5c:	nop    DWORD PTR [rax+0x0]
  41cc60:	cmp    ecx,0x2
  41cc63:	jne    41d132 <p111_rt_op+0xe92>
  41cc69:	movss  xmm0,DWORD PTR [rbx]
  41cc6d:	subss  xmm0,DWORD PTR [rbx+0x8]
  41cc72:	movd   r12d,xmm0
  41cc77:	jmp    41c384 <p111_rt_op+0xe4>
  41cc7c:	nop    DWORD PTR [rax+0x0]
  41cc80:	cmp    ecx,0x2
  41cc83:	jne    41d132 <p111_rt_op+0xe92>
  41cc89:	mov    eax,DWORD PTR [rbx+0x8]
  41cc8c:	cmp    DWORD PTR [rbx],eax
  41cc8e:	seta   al
  41cc91:	setae  dl
  41cc94:	movzx  eax,al
  41cc97:	movzx  edx,dl
  41cc9a:	add    rax,rdx
  41cc9d:	je     41d1c8 <p111_rt_op+0xf28>
  41cca3:	cmp    rax,0x1
  41cca7:	je     41cf0d <p111_rt_op+0xc6d>
  41ccad:	mov    r12d,DWORD PTR [rip+0x10e290]        # 52af44 <p111_core_cids+0x44>
  41ccb4:	shl    r12,0x28
  41ccb8:	bts    r12,0x38
  41ccbd:	jmp    41c384 <p111_rt_op+0xe4>
  41ccc2:	nop    WORD PTR [rax+rax*1+0x0]
  41ccc8:	cmp    ecx,0x1
  41cccb:	jne    41d132 <p111_rt_op+0xe92>
  41ccd1:	mov    eax,DWORD PTR [rbx]
  41ccd3:	xor    r12d,r12d
  41ccd6:	test   eax,eax
  41ccd8:	sete   r12b
  41ccdc:	jmp    41c384 <p111_rt_op+0xe4>
  41cce1:	nop    DWORD PTR [rax+0x0]
  41cce8:	cmp    ecx,0x1
  41cceb:	jne    41d132 <p111_rt_op+0xe92>
  41ccf1:	mov    r12,QWORD PTR [rbx]
  41ccf4:	not    r12d
  41ccf7:	jmp    41c384 <p111_rt_op+0xe4>
  41ccfc:	nop    DWORD PTR [rax+0x0]
  41cd00:	cmp    ecx,0x2
  41cd03:	jne    41d132 <p111_rt_op+0xe92>
  41cd09:	mov    rax,QWORD PTR [rbx+0x8]
  41cd0d:	mov    r12,QWORD PTR [rbx]
  41cd10:	mov    ecx,eax
  41cd12:	test   eax,eax
  41cd14:	je     41c384 <p111_rt_op+0xe4>
  41cd1a:	mov    eax,r12d
  41cd1d:	xor    edx,edx
  41cd1f:	div    ecx
  41cd21:	mov    r12,rdx
  41cd24:	jmp    41c384 <p111_rt_op+0xe4>
  41cd29:	nop    DWORD PTR [rax+0x0]
  41cd30:	cmp    ecx,0x2
  41cd33:	jne    41d132 <p111_rt_op+0xe92>
  41cd39:	mov    rax,QWORD PTR [rbx+0x8]
  41cd3d:	xor    r12d,r12d
  41cd40:	mov    ecx,eax
  41cd42:	test   eax,eax
  41cd44:	je     41c384 <p111_rt_op+0xe4>
  41cd4a:	mov    rax,QWORD PTR [rbx]
  41cd4d:	xor    edx,edx
  41cd4f:	div    ecx
  41cd51:	mov    r12,rax
  41cd54:	jmp    41c384 <p111_rt_op+0xe4>
  41cd59:	nop    DWORD PTR [rax+0x0]
  41cd60:	cmp    ecx,0x2
  41cd63:	jne    41d132 <p111_rt_op+0xe92>
  41cd69:	mov    rcx,QWORD PTR [rbx+0x8]
  41cd6d:	xor    r12d,r12d
  41cd70:	cmp    rcx,0x1f
  41cd74:	ja     41c384 <p111_rt_op+0xe4>
  41cd7a:	mov    r12,QWORD PTR [rbx]
  41cd7d:	shr    r12d,cl
  41cd80:	jmp    41c384 <p111_rt_op+0xe4>
  41cd85:	nop    DWORD PTR [rax]
  41cd88:	cmp    ecx,0x2
  41cd8b:	jne    41d132 <p111_rt_op+0xe92>
  41cd91:	mov    rcx,QWORD PTR [rbx+0x8]
  41cd95:	xor    r12d,r12d
  41cd98:	cmp    rcx,0x1f
  41cd9c:	ja     41c384 <p111_rt_op+0xe4>
  41cda2:	mov    r12,QWORD PTR [rbx]
  41cda5:	shl    r12d,cl
  41cda8:	jmp    41c384 <p111_rt_op+0xe4>
  41cdad:	nop    DWORD PTR [rax]
  41cdb0:	cmp    ecx,0x1
  41cdb3:	jne    41d132 <p111_rt_op+0xe92>
  41cdb9:	mov    r12,QWORD PTR [rbx]
  41cdbc:	shr    r12d,1
  41cdbf:	jmp    41c384 <p111_rt_op+0xe4>
  41cdc4:	nop    DWORD PTR [rax+0x0]
  41cdc8:	cmp    ecx,0x1
  41cdcb:	jne    41d132 <p111_rt_op+0xe92>
  41cdd1:	mov    r12,QWORD PTR [rbx]
  41cdd4:	add    r12d,r12d
  41cdd7:	jmp    41c384 <p111_rt_op+0xe4>
  41cddc:	nop    DWORD PTR [rax+0x0]
  41cde0:	cmp    ecx,0x1
  41cde3:	jne    41d132 <p111_rt_op+0xe92>
  41cde9:	mov    rax,QWORD PTR [rbx]
  41cdec:	lea    r12d,[rax+0x1]
  41cdf0:	jmp    41c384 <p111_rt_op+0xe4>
  41cdf5:	nop    DWORD PTR [rax]
  41cdf8:	cmp    ecx,0x2
  41cdfb:	jne    41d132 <p111_rt_op+0xe92>
  41ce01:	xor    r12d,r12d
  41ce04:	mov    eax,DWORD PTR [rbx+0x8]
  41ce07:	cmp    DWORD PTR [rbx],eax
  41ce09:	setae  r12b
  41ce0d:	jmp    41c384 <p111_rt_op+0xe4>
  41ce12:	nop    WORD PTR [rax+rax*1+0x0]
  41ce18:	cmp    ecx,0x2
  41ce1b:	jne    41d132 <p111_rt_op+0xe92>
  41ce21:	xor    r12d,r12d
  41ce24:	mov    eax,DWORD PTR [rbx+0x8]
  41ce27:	cmp    DWORD PTR [rbx],eax
  41ce29:	seta   r12b
  41ce2d:	jmp    41c384 <p111_rt_op+0xe4>
  41ce32:	nop    WORD PTR [rax+rax*1+0x0]
  41ce38:	cmp    ecx,0x2
  41ce3b:	jne    41d132 <p111_rt_op+0xe92>
  41ce41:	mov    rax,QWORD PTR [rbx]
  41ce44:	mov    r12d,0x1
  41ce4a:	cmp    rax,0x1
  41ce4e:	je     41ce7a <p111_rt_op+0xbda>
  41ce50:	mov    rdx,rax
  41ce53:	xor    r12d,r12d
  41ce56:	shr    rdx,0x38
  41ce5a:	and    edx,0x7f
  41ce5d:	cmp    rdx,0x1
  41ce61:	jne    41ce7a <p111_rt_op+0xbda>
  41ce63:	shr    rax,0x28
  41ce67:	mov    edx,DWORD PTR [rip+0x10e0cb]        # 52af38 <p111_core_cids+0x38>
  41ce6d:	xor    r12d,r12d
  41ce70:	movzx  eax,ax
  41ce73:	cmp    rax,rdx
  41ce76:	sete   r12b
  41ce7a:	mov    rax,QWORD PTR [rbx+0x8]
  41ce7e:	cmp    rax,0x1
  41ce82:	je     41d203 <p111_rt_op+0xf63>
  41ce88:	mov    rdx,rax
  41ce8b:	shr    rdx,0x38
  41ce8f:	and    edx,0x7f
  41ce92:	cmp    rdx,0x1
  41ce96:	jne    41c5e0 <p111_rt_op+0x340>
  41ce9c:	shr    rax,0x28
  41cea0:	mov    edx,DWORD PTR [rip+0x10e092]        # 52af38 <p111_core_cids+0x38>
  41cea6:	movzx  eax,ax
  41cea9:	cmp    rax,rdx
  41ceac:	sete   al
  41ceaf:	movzx  eax,al
  41ceb2:	or     r12d,eax
  41ceb5:	jmp    41c5e0 <p111_rt_op+0x340>
  41ceba:	nop    WORD PTR [rax+rax*1+0x0]
  41cec0:	cmp    ecx,0x2
  41cec3:	jne    41d132 <p111_rt_op+0xe92>
  41cec9:	xor    r12d,r12d
  41cecc:	mov    rax,QWORD PTR [rbx+0x8]
  41ced0:	cmp    QWORD PTR [rbx],rax
  41ced3:	setb   r12b
  41ced7:	jmp    41c384 <p111_rt_op+0xe4>
  41cedc:	nop    DWORD PTR [rax+0x0]
  41cee0:	cmp    ecx,0x2
  41cee3:	jne    41d132 <p111_rt_op+0xe92>
  41cee9:	mov    rax,QWORD PTR [rbx+0x8]
  41ceed:	cmp    QWORD PTR [rbx],rax
  41cef0:	seta   al
  41cef3:	setae  dl
  41cef6:	movzx  eax,al
  41cef9:	movzx  edx,dl
  41cefc:	add    eax,edx
  41cefe:	je     41d1c8 <p111_rt_op+0xf28>
  41cf04:	cmp    eax,0x1
  41cf07:	jne    41ccad <p111_rt_op+0xa0d>
  41cf0d:	mov    r12d,DWORD PTR [rip+0x10e02c]        # 52af40 <p111_core_cids+0x40>
  41cf14:	shl    r12,0x28
  41cf18:	bts    r12,0x38
  41cf1d:	jmp    41c384 <p111_rt_op+0xe4>
  41cf22:	nop    WORD PTR [rax+rax*1+0x0]
  41cf28:	cmp    ecx,0x1
  41cf2b:	jne    41d132 <p111_rt_op+0xe92>
  41cf31:	movabs rax,0xffffffffffff
  41cf3b:	mov    r12,QWORD PTR [rbx]
  41cf3e:	add    r12,r12
  41cf41:	cmp    r12,rax
  41cf44:	jbe    41c384 <p111_rt_op+0xe4>
  41cf4a:	jmp    41c813 <p111_rt_op+0x573>
  41cf4f:	nop
  41cf50:	cmp    ecx,0x2
  41cf53:	jne    41d132 <p111_rt_op+0xe92>
  41cf59:	mov    r12,QWORD PTR [rbx+0x8]
  41cf5d:	mov    rcx,QWORD PTR [rbx]
  41cf60:	test   r12,r12
  41cf63:	je     41c384 <p111_rt_op+0xe4>
  41cf69:	movabs rsi,0xffffffffffff
  41cf73:	xor    edx,edx
  41cf75:	mov    rax,rsi
  41cf78:	div    r12
  41cf7b:	cmp    rcx,rax
  41cf7e:	ja     41c813 <p111_rt_op+0x573>
  41cf84:	imul   r12,rcx
  41cf88:	cmp    r12,rsi
  41cf8b:	jbe    41c384 <p111_rt_op+0xe4>
  41cf91:	jmp    41c813 <p111_rt_op+0x573>
  41cf96:	nop    WORD PTR cs:[rax+rax*1+0x0]
  41cfa0:	cmp    ecx,0x1
  41cfa3:	jne    41d132 <p111_rt_op+0xe92>
  41cfa9:	mov    eax,DWORD PTR [rbx]
  41cfab:	pxor   xmm0,xmm0
  41cfaf:	cvtsi2ss xmm0,rax
  41cfb4:	movd   r12d,xmm0
  41cfb9:	jmp    41c384 <p111_rt_op+0xe4>
  41cfbe:	xchg   ax,ax
  41cfc0:	cmp    ecx,0x2
  41cfc3:	jne    41d132 <p111_rt_op+0xe92>
  41cfc9:	movss  xmm0,DWORD PTR [rbx+0x8]
  41cfce:	addss  xmm0,DWORD PTR [rbx]
  41cfd2:	movd   r12d,xmm0
  41cfd7:	jmp    41c384 <p111_rt_op+0xe4>
  41cfdc:	nop    DWORD PTR [rax+0x0]
  41cfe0:	cmp    ecx,0x1
  41cfe3:	jne    41d132 <p111_rt_op+0xe92>
  41cfe9:	mov    r12d,DWORD PTR [rbx]
  41cfec:	jmp    41c384 <p111_rt_op+0xe4>
  41cff1:	nop    DWORD PTR [rax+0x0]
  41cff8:	cmp    ecx,0x2
  41cffb:	jne    41d132 <p111_rt_op+0xe92>
  41d001:	mov    rsi,QWORD PTR [rbx]
  41d004:	mov    eax,0x1
  41d009:	movabs rdx,0xffffffffff
  41d013:	mov    rcx,rsi
  41d016:	and    rdx,rsi
  41d019:	shr    rcx,0x28
  41d01d:	and    ecx,0x1f
  41d020:	shl    rax,cl
  41d023:	sub    eax,0x1
  41d026:	and    eax,DWORD PTR [rbx+0x8]
  41d029:	test   rsi,rsi
  41d02c:	js     41d3ce <p111_rt_op+0x112e>
  41d032:	mov    rcx,QWORD PTR [rip+0x10df17]        # 52af50 <p111_program_active>
  41d039:	test   BYTE PTR [rcx+0x58],0x2
  41d03d:	je     41d2dc <p111_rt_op+0x103c>
  41d043:	shl    rax,0x2
  41d047:	lea    rax,[rax+rdx*8]
  41d04b:	mov    r13d,DWORD PTR [rbp+rax*1+0x0]
  41d050:	mov    rcx,r13
  41d053:	jmp    41c65e <p111_rt_op+0x3be>
  41d058:	nop    DWORD PTR [rax+rax*1+0x0]
  41d060:	cmp    ecx,0x2
  41d063:	jne    41d132 <p111_rt_op+0xe92>
  41d069:	mov    rax,QWORD PTR [rbx+0x8]
  41d06d:	mov    rcx,QWORD PTR [rbx]
  41d070:	mov    rsi,r12
  41d073:	lea    r8,[rsp+0x20]
  41d078:	mov    rdi,rbp
  41d07b:	mov    QWORD PTR [rsp+0x20],rax
  41d080:	mov    rax,QWORD PTR [rip+0x10dec9]        # 52af50 <p111_program_active>
  41d087:	mov    rdx,QWORD PTR [rax+0x58]
  41d08b:	shr    rdx,1
  41d08e:	xor    rdx,0x1
  41d092:	and    edx,0x1
  41d095:	call   41a050 <blk_new.constprop.0>
  41d09a:	mov    r12,rax
  41d09d:	jmp    41c384 <p111_rt_op+0xe4>
  41d0a2:	nop    WORD PTR [rax+rax*1+0x0]
  41d0a8:	cmp    ecx,0x1
  41d0ab:	jne    41d132 <p111_rt_op+0xe92>
  41d0b1:	pxor   xmm0,xmm0
  41d0b5:	cvtss2sd xmm0,DWORD PTR [rbx]
  41d0b9:	call   402540 <exp@plt>
  41d0be:	cvtsd2ss xmm0,xmm0
  41d0c2:	jmp    41c7b0 <p111_rt_op+0x510>
  41d0c7:	nop    WORD PTR [rax+rax*1+0x0]
  41d0d0:	cmp    ecx,0x1
  41d0d3:	jne    41d132 <p111_rt_op+0xe92>
  41d0d5:	movss  xmm0,DWORD PTR [rbx]
  41d0d9:	pxor   xmm1,xmm1
  41d0dd:	ucomiss xmm1,xmm0
  41d0e0:	ja     41d474 <p111_rt_op+0x11d4>
  41d0e6:	sqrtss xmm0,xmm0
  41d0ea:	jmp    41c7b0 <p111_rt_op+0x510>
  41d0ef:	nop
  41d0f0:	cmp    ecx,0x2
  41d0f3:	jne    41d132 <p111_rt_op+0xe92>
  41d0f5:	xor    r12d,r12d
  41d0f8:	movss  xmm0,DWORD PTR [rbx]
  41d0fc:	comiss xmm0,DWORD PTR [rbx+0x8]
  41d100:	setae  r12b
  41d104:	jmp    41c384 <p111_rt_op+0xe4>
  41d109:	nop    DWORD PTR [rax+0x0]
  41d110:	cmp    ecx,0x2
  41d113:	jne    41d132 <p111_rt_op+0xe92>
  41d115:	xor    r12d,r12d
  41d118:	movss  xmm0,DWORD PTR [rbx]
  41d11c:	comiss xmm0,DWORD PTR [rbx+0x8]
  41d120:	seta   r12b
  41d124:	jmp    41c384 <p111_rt_op+0xe4>
  41d129:	sub    ecx,0x1
  41d12c:	je     4045fe <p111_rt_op.cold>
  41d132:	lea    rdi,[rip+0x66c7]        # 423800 <_IO_stdin_used+0x800>
  41d139:	call   417bc0 <err_fail>
  41d13e:	sub    ecx,0x1
  41d141:	jne    41d132 <p111_rt_op+0xe92>
  41d143:	jmp    404697 <p111_rt_op.cold+0x99>
  41d148:	nop    DWORD PTR [rax+rax*1+0x0]
  41d150:	movd   xmm5,ecx
  41d154:	movd   xmm6,edi
  41d158:	addss  xmm5,xmm6
  41d15c:	movd   r11d,xmm5
  41d161:	nop    DWORD PTR [rax+0x0]
  41d168:	mov    eax,ecx
  41d16a:	lock cmpxchg DWORD PTR [rdx],r11d
  41d16f:	je     41c65e <p111_rt_op+0x3be>
  41d175:	mov    ecx,eax
  41d177:	jmp    41c35f <p111_rt_op+0xbf>
  41d17c:	nop    DWORD PTR [rax+0x0]
  41d180:	mov    r11d,edi
  41d183:	and    r11d,ecx
  41d186:	jmp    41d168 <p111_rt_op+0xec8>
  41d188:	cmp    edi,ecx
  41d18a:	mov    r11d,ecx
  41d18d:	cmovae r11d,edi
  41d191:	jmp    41d168 <p111_rt_op+0xec8>
  41d193:	cmp    edi,ecx
  41d195:	mov    r11d,ecx
  41d198:	cmovbe r11d,edi
  41d19c:	jmp    41d168 <p111_rt_op+0xec8>
  41d19e:	lea    r11d,[rdi+rcx*1]
  41d1a2:	jmp    41d168 <p111_rt_op+0xec8>
  41d1a4:	mov    r11d,edi
  41d1a7:	xor    r11d,ecx
  41d1aa:	jmp    41d168 <p111_rt_op+0xec8>
  41d1ac:	mov    r11d,edi
  41d1af:	or     r11d,ecx
  41d1b2:	jmp    41d168 <p111_rt_op+0xec8>
  41d1b4:	cmp    edi,ecx
  41d1b6:	mov    r11d,ecx
  41d1b9:	cmove  r11d,r8d
  41d1bd:	jmp    41d168 <p111_rt_op+0xec8>
  41d1bf:	mov    r11d,edi
  41d1c2:	jmp    41d168 <p111_rt_op+0xec8>
  41d1c4:	nop    DWORD PTR [rax+0x0]
  41d1c8:	mov    r12d,DWORD PTR [rip+0x10dd6d]        # 52af3c <p111_core_cids+0x3c>
  41d1cf:	shl    r12,0x28
  41d1d3:	bts    r12,0x38
  41d1d8:	jmp    41c384 <p111_rt_op+0xe4>
  41d1dd:	xor    r12d,r12d
  41d1e0:	jmp    41c384 <p111_rt_op+0xe4>
  41d1e5:	mov    rdx,rax
  41d1e8:	and    eax,0x1
  41d1eb:	pxor   xmm0,xmm0
  41d1ef:	shr    rdx,1
  41d1f2:	or     rdx,rax
  41d1f5:	cvtsi2ss xmm0,rdx
  41d1fa:	addss  xmm0,xmm0
  41d1fe:	jmp    41c7b0 <p111_rt_op+0x510>
  41d203:	mov    r12d,0x1
  41d209:	jmp    41c5e0 <p111_rt_op+0x340>
  41d20e:	cmp    ecx,0x4
  41d211:	jne    41d132 <p111_rt_op+0xe92>
  41d217:	mov    r8d,DWORD PTR [rbx+0x18]
  41d21b:	mov    esi,0x8
  41d220:	jmp    41c2f0 <p111_rt_op+0x50>
  41d225:	xor    r12d,0x1
  41d229:	jmp    41c5e0 <p111_rt_op+0x340>
  41d22e:	lea    rax,[r13+r14*1+0x0]
  41d233:	lea    r10,[rbp+rax*8+0x0]
  41d238:	mov    rax,r8
  41d23b:	shr    rax,0x38
  41d23f:	mov    r15,QWORD PTR [r10]
  41d242:	and    eax,0x7f
  41d245:	cmp    rax,0x2
  41d249:	je     41d3f4 <p111_rt_op+0x1154>
  41d24f:	mov    QWORD PTR [r10],r8
  41d252:	jmp    41c65b <p111_rt_op+0x3bb>
  41d257:	lea    rax,[r14+r15*1]
  41d25b:	lea    r9,[rbp+rax*8+0x0]
  41d260:	mov    rdx,QWORD PTR [r9]
  41d263:	mov    rax,rdx
  41d266:	shr    rax,0x38
  41d26a:	test   al,0x7e
  41d26c:	je     41d2c0 <p111_rt_op+0x1020>
  41d26e:	cmp    rdx,0xffffffffffffffff
  41d272:	je     41d2c0 <p111_rt_op+0x1020>
  41d274:	movabs rcx,0xffffffffff
  41d27e:	mov    rax,QWORD PTR [r8+0x40]
  41d282:	and    rcx,rdx
  41d285:	add    rax,0x7f
  41d289:	and    rax,0xffffffffffffff80
  41d28d:	add    rax,0x3108200
  41d293:	cmp    rcx,rax
  41d296:	jb     41d2c0 <p111_rt_op+0x1020>
  41d298:	mov    rdi,rbp
  41d29b:	mov    rsi,r12
  41d29e:	mov    QWORD PTR [rsp+0x8],r9
  41d2a3:	mov    QWORD PTR [rsp],r8
  41d2a7:	call   41a1f0 <term_drop>
  41d2ac:	mov    r8,QWORD PTR [rsp]
  41d2b0:	mov    r9,QWORD PTR [rsp+0x8]
  41d2b5:	test   BYTE PTR [r8+0x58],0x2
  41d2ba:	jne    41c6c6 <p111_rt_op+0x426>
  41d2c0:	mov    rax,r13
  41d2c3:	shr    rax,0x38
  41d2c7:	and    eax,0x7f
  41d2ca:	cmp    rax,0x2
  41d2ce:	je     41d408 <p111_rt_op+0x1168>
  41d2d4:	mov    QWORD PTR [r9],r13
  41d2d7:	jmp    41c381 <p111_rt_op+0xe1>
  41d2dc:	add    rax,rdx
  41d2df:	lea    r14,[rbp+rax*8+0x0]
  41d2e4:	mov    r13,QWORD PTR [r14]
  41d2e7:	test   r13,r13
  41d2ea:	js     41d420 <p111_rt_op+0x1180>
  41d2f0:	mov    rax,r13
  41d2f3:	shr    rax,0x38
  41d2f7:	test   al,0x7e
  41d2f9:	je     41d050 <p111_rt_op+0xdb0>
  41d2ff:	movabs rdx,0xffffffffff
  41d309:	mov    rax,QWORD PTR [rcx+0x40]
  41d30d:	and    rdx,r13
  41d310:	add    rax,0x7f
  41d314:	and    rax,0xffffffffffffff80
  41d318:	add    rax,0x3108200
  41d31e:	cmp    rdx,rax
  41d321:	jae    40470b <p111_rt_op.cold+0x10d>
  41d327:	jmp    41d050 <p111_rt_op+0xdb0>
  41d32c:	mov    DWORD PTR [rsp+0x20],0x6e616e
  41d334:	mov    eax,0x3
  41d339:	lea    r13,[rsp+0x20]
  41d33e:	jmp    41c843 <p111_rt_op+0x5a3>
  41d343:	lea    rsi,[rbp+rcx*8+0x0]
  41d348:	mov    ecx,DWORD PTR [rsi+0x4]
  41d34b:	mov    edx,DWORD PTR [rsi]
  41d34d:	shl    rcx,0x20
  41d351:	or     rcx,rdx
  41d354:	and    edx,0xffffff
  41d35a:	cmp    rdx,0x1
  41d35e:	je     41d45a <p111_rt_op+0x11ba>
  41d364:	shr    rcx,0x18
  41d368:	mov    r15,rcx
  41d36b:	jmp    41c6b1 <p111_rt_op+0x411>
  41d370:	lea    rsi,[rbp+rcx*8+0x0]
  41d375:	mov    ecx,DWORD PTR [rsi+0x4]
  41d378:	mov    edx,DWORD PTR [rsi]
  41d37a:	shl    rcx,0x20
  41d37e:	or     rcx,rdx
  41d381:	and    edx,0xffffff
  41d387:	cmp    rdx,0x1
  41d38b:	je     41d465 <p111_rt_op+0x11c5>
  41d391:	shr    rcx,0x18
  41d395:	mov    r14,rcx
  41d398:	jmp    41c631 <p111_rt_op+0x391>
  41d39d:	add    r9,rbp
  41d3a0:	mov    edx,DWORD PTR [r9+0x4]
  41d3a4:	mov    eax,DWORD PTR [r9]
  41d3a7:	shl    rdx,0x20
  41d3ab:	or     rdx,rax
  41d3ae:	and    eax,0xffffff
  41d3b3:	cmp    rax,0x1
  41d3b7:	je     41d46c <p111_rt_op+0x11cc>
  41d3bd:	shr    rdx,0x18
  41d3c1:	lea    r9,[rdx*8+0x0]
  41d3c9:	jmp    41c318 <p111_rt_op+0x78>
  41d3ce:	lea    rsi,[rbp+rdx*8+0x0]
  41d3d3:	mov    edx,DWORD PTR [rsi+0x4]
  41d3d6:	mov    ecx,DWORD PTR [rsi]
  41d3d8:	shl    rdx,0x20
  41d3dc:	or     rdx,rcx
  41d3df:	and    ecx,0xffffff
  41d3e5:	cmp    rcx,0x1
  41d3e9:	je     41d461 <p111_rt_op+0x11c1>
  41d3eb:	shr    rdx,0x18
  41d3ef:	jmp    41d032 <p111_rt_op+0xd92>
  41d3f4:	test   r8,r8
  41d3f7:	js     41d24f <p111_rt_op+0xfaf>
  41d3fd:	jmp    4046c4 <p111_rt_op.cold+0xc6>
  41d402:	nop    WORD PTR [rax+rax*1+0x0]
  41d408:	test   r13,r13
  41d40b:	js     41d2d4 <p111_rt_op+0x1034>
  41d411:	jmp    404743 <p111_rt_op.cold+0x145>
  41d416:	nop    WORD PTR cs:[rax+rax*1+0x0]
  41d420:	movabs rax,0xffffffffff
  41d42a:	and    rax,r13
  41d42d:	lea    rdx,[rbp+rax*8+0x0]
  41d432:	mov    eax,DWORD PTR [rdx]
  41d434:	lea    ecx,[rax+0x1]
  41d437:	and    eax,0xffffff
  41d43c:	mov    DWORD PTR [rdx],ecx
  41d43e:	cmp    eax,0xfffffd
  41d443:	jbe    41d050 <p111_rt_op+0xdb0>
  41d449:	call   418d00 <rfc_bump.part.0>
  41d44e:	lea    rdi,[rip+0x63d3]        # 423828 <_IO_stdin_used+0x828>
  41d455:	call   417bc0 <err_fail>
  41d45a:	mov    edx,DWORD PTR [rsi]
  41d45c:	jmp    41d364 <p111_rt_op+0x10c4>
  41d461:	mov    ecx,DWORD PTR [rsi]
  41d463:	jmp    41d3eb <p111_rt_op+0x114b>
  41d465:	mov    edx,DWORD PTR [rsi]
  41d467:	jmp    41d391 <p111_rt_op+0x10f1>
  41d46c:	mov    eax,DWORD PTR [r9]
  41d46f:	jmp    41d3bd <p111_rt_op+0x111d>
  41d474:	call   402350 <sqrtf@plt>
  41d479:	jmp    41c7b0 <p111_rt_op+0x510>

Disassembly of section .fini:
