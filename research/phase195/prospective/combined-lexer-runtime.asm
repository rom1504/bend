
/home/ai/bend2/build/publish/bend/selfhost/build/phase195/combined-dev-build01/lexer/machine/program:     file format elf64-x86-64


Disassembly of section .init:

Disassembly of section .plt:

Disassembly of section .text:

000000000041c170 <p111_rt_op>:
  41c170:	push   r15
  41c172:	push   r14
  41c174:	push   r13
  41c176:	push   r12
  41c178:	push   rbp
  41c179:	push   rbx
  41c17a:	sub    rsp,0x58
  41c17e:	mov    r12,QWORD PTR [rdi+0x8]
  41c182:	mov    rbp,QWORD PTR [rdi]
  41c185:	cmp    esi,0x56
  41c188:	ja     41d31e <p111_rt_op+0x11ae>
  41c18e:	lea    rdi,[rip+0x7f07]        # 42409c <_IO_stdin_used+0x109c>
  41c195:	mov    rbx,rdx
  41c198:	mov    edx,esi
  41c19a:	movsxd rax,DWORD PTR [rdi+rdx*4]
  41c19e:	add    rax,rdi
  41c1a1:	jmp    rax
  41c1a3:	nop    DWORD PTR [rax+rax*1+0x0]
  41c1a8:	cmp    esi,0x54
  41c1ab:	je     41d0de <p111_rt_op+0xf6e>
  41c1b1:	cmp    ecx,0x3
  41c1b4:	jne    41d002 <p111_rt_op+0xe92>
  41c1ba:	sub    esi,0x4c
  41c1bd:	xor    r8d,r8d
  41c1c0:	movabs rdx,0xffffffffff
  41c1ca:	mov    r10,QWORD PTR [rbx]
  41c1cd:	mov    edi,DWORD PTR [rbx+0x10]
  41c1d0:	mov    r11,QWORD PTR [rbx+0x8]
  41c1d4:	and    rdx,r10
  41c1d7:	lea    r9,[rdx*8+0x0]
  41c1df:	test   r10,r10
  41c1e2:	js     41d26d <p111_rt_op+0x10fd>
  41c1e8:	mov    rcx,r10
  41c1eb:	mov    edx,0x1
  41c1f0:	shr    rcx,0x28
  41c1f4:	and    ecx,0x1f
  41c1f7:	shl    rdx,cl
  41c1fa:	mov    rcx,r10
  41c1fd:	mov    r10d,esi
  41c200:	lea    eax,[rdx-0x1]
  41c203:	shr    rcx,0x38
  41c207:	and    eax,r11d
  41c20a:	and    ecx,0x7f
  41c20d:	lea    edx,[rax+rax*1]
  41c210:	shl    rax,0x2
  41c214:	shl    rdx,0x2
  41c218:	cmp    rcx,0x4
  41c21c:	cmove  rdx,rax
  41c220:	add    rdx,r9
  41c223:	lea    r9,[rip+0x7fce]        # 4241f8 <_IO_stdin_used+0x11f8>
  41c22a:	add    rdx,rbp
  41c22d:	mov    ecx,DWORD PTR [rdx]
  41c22f:	cmp    esi,0x9
  41c232:	ja     41d08f <p111_rt_op+0xf1f>
  41c238:	movsxd rax,DWORD PTR [r9+r10*4]
  41c23c:	add    rax,r9
  41c23f:	jmp    rax
  41c241:	nop    DWORD PTR [rax+0x0]
  41c248:	cmp    ecx,0x1
  41c24b:	jne    41d002 <p111_rt_op+0xe92>
  41c251:	mov    r12,QWORD PTR [rbx]
  41c254:	add    rsp,0x58
  41c258:	mov    rax,r12
  41c25b:	pop    rbx
  41c25c:	pop    rbp
  41c25d:	pop    r12
  41c25f:	pop    r13
  41c261:	pop    r14
  41c263:	pop    r15
  41c265:	ret    
  41c266:	nop    WORD PTR cs:[rax+rax*1+0x0]
  41c270:	cmp    ecx,0x2
  41c273:	jne    41d002 <p111_rt_op+0xe92>
  41c279:	xor    r12d,r12d
  41c27c:	mov    eax,DWORD PTR [rbx+0x8]
  41c27f:	cmp    DWORD PTR [rbx],eax
  41c281:	setne  r12b
  41c285:	jmp    41c254 <p111_rt_op+0xe4>
  41c287:	nop    WORD PTR [rax+rax*1+0x0]
  41c290:	cmp    ecx,0x2
  41c293:	jne    41d002 <p111_rt_op+0xe92>
  41c299:	xor    r12d,r12d
  41c29c:	mov    eax,DWORD PTR [rbx+0x8]
  41c29f:	cmp    DWORD PTR [rbx],eax
  41c2a1:	sete   r12b
  41c2a5:	jmp    41c254 <p111_rt_op+0xe4>
  41c2a7:	nop    WORD PTR [rax+rax*1+0x0]
  41c2b0:	cmp    ecx,0x2
  41c2b3:	jne    41d002 <p111_rt_op+0xe92>
  41c2b9:	mov    r12,QWORD PTR [rbx+0x8]
  41c2bd:	imul   r12d,DWORD PTR [rbx]
  41c2c1:	jmp    41c254 <p111_rt_op+0xe4>
  41c2c3:	nop    DWORD PTR [rax+rax*1+0x0]
  41c2c8:	cmp    ecx,0x2
  41c2cb:	jne    41d002 <p111_rt_op+0xe92>
  41c2d1:	mov    r12,QWORD PTR [rbx+0x8]
  41c2d5:	xor    r12d,DWORD PTR [rbx]
  41c2d8:	jmp    41c254 <p111_rt_op+0xe4>
  41c2dd:	nop    DWORD PTR [rax]
  41c2e0:	cmp    ecx,0x2
  41c2e3:	jne    41d002 <p111_rt_op+0xe92>
  41c2e9:	mov    r12,QWORD PTR [rbx+0x8]
  41c2ed:	or     r12d,DWORD PTR [rbx]
  41c2f0:	jmp    41c254 <p111_rt_op+0xe4>
  41c2f5:	nop    DWORD PTR [rax]
  41c2f8:	cmp    ecx,0x2
  41c2fb:	jne    41d002 <p111_rt_op+0xe92>
  41c301:	mov    r12,QWORD PTR [rbx+0x8]
  41c305:	and    r12d,DWORD PTR [rbx]
  41c308:	jmp    41c254 <p111_rt_op+0xe4>
  41c30d:	nop    DWORD PTR [rax]
  41c310:	cmp    ecx,0x2
  41c313:	jne    41d002 <p111_rt_op+0xe92>
  41c319:	mov    r12,QWORD PTR [rbx]
  41c31c:	sub    r12d,DWORD PTR [rbx+0x8]
  41c320:	jmp    41c254 <p111_rt_op+0xe4>
  41c325:	nop    DWORD PTR [rax]
  41c328:	cmp    ecx,0x2
  41c32b:	jne    41d002 <p111_rt_op+0xe92>
  41c331:	mov    r12,QWORD PTR [rbx+0x8]
  41c335:	add    r12d,DWORD PTR [rbx]
  41c338:	jmp    41c254 <p111_rt_op+0xe4>
  41c33d:	nop    DWORD PTR [rax]
  41c340:	cmp    ecx,0x2
  41c343:	jne    41d002 <p111_rt_op+0xe92>
  41c349:	xor    r12d,r12d
  41c34c:	mov    eax,DWORD PTR [rbx+0x8]
  41c34f:	cmp    DWORD PTR [rbx],eax
  41c351:	setbe  r12b
  41c355:	jmp    41c254 <p111_rt_op+0xe4>
  41c35a:	nop    WORD PTR [rax+rax*1+0x0]
  41c360:	cmp    ecx,0x2
  41c363:	jne    41d002 <p111_rt_op+0xe92>
  41c369:	xor    r12d,r12d
  41c36c:	mov    eax,DWORD PTR [rbx+0x8]
  41c36f:	cmp    DWORD PTR [rbx],eax
  41c371:	setb   r12b
  41c375:	jmp    41c254 <p111_rt_op+0xe4>
  41c37a:	nop    WORD PTR [rax+rax*1+0x0]
  41c380:	cmp    ecx,0x2
  41c383:	jne    41d002 <p111_rt_op+0xe92>
  41c389:	xor    r12d,r12d
  41c38c:	movss  xmm0,DWORD PTR [rbx+0x8]
  41c391:	ucomiss xmm0,DWORD PTR [rbx]
  41c394:	mov    eax,0x1
  41c399:	setp   r12b
  41c39d:	cmovne r12,rax
  41c3a1:	jmp    41c254 <p111_rt_op+0xe4>
  41c3a6:	nop    WORD PTR cs:[rax+rax*1+0x0]
  41c3b0:	cmp    ecx,0x2
  41c3b3:	jne    41d002 <p111_rt_op+0xe92>
  41c3b9:	xor    r12d,r12d
  41c3bc:	movss  xmm0,DWORD PTR [rbx+0x8]
  41c3c1:	comiss xmm0,DWORD PTR [rbx]
  41c3c4:	setae  r12b
  41c3c8:	jmp    41c254 <p111_rt_op+0xe4>
  41c3cd:	nop    DWORD PTR [rax]
  41c3d0:	cmp    ecx,0x2
  41c3d3:	jne    41d002 <p111_rt_op+0xe92>
  41c3d9:	xor    r12d,r12d
  41c3dc:	movss  xmm0,DWORD PTR [rbx+0x8]
  41c3e1:	comiss xmm0,DWORD PTR [rbx]
  41c3e4:	seta   r12b
  41c3e8:	jmp    41c254 <p111_rt_op+0xe4>
  41c3ed:	nop    DWORD PTR [rax]
  41c3f0:	cmp    ecx,0x2
  41c3f3:	jne    41d002 <p111_rt_op+0xe92>
  41c3f9:	mov    r8,QWORD PTR [rbx+0x8]
  41c3fd:	mov    rcx,QWORD PTR [rbx]
  41c400:	test   r8,r8
  41c403:	je     41c413 <p111_rt_op+0x2a3>
  41c405:	mov    rax,rcx
  41c408:	xor    edx,edx
  41c40a:	div    r8
  41c40d:	mov    rcx,rdx
  41c410:	mov    r8,rax
  41c413:	mov    rdx,r8
  41c416:	add    rsp,0x58
  41c41a:	mov    rdi,rbp
  41c41d:	mov    rsi,r12
  41c420:	pop    rbx
  41c421:	pop    rbp
  41c422:	pop    r12
  41c424:	pop    r13
  41c426:	pop    r14
  41c428:	pop    r15
  41c42a:	jmp    419490 <p111_tuple>
  41c42f:	nop
  41c430:	cmp    ecx,0x2
  41c433:	jne    41d002 <p111_rt_op+0xe92>
  41c439:	mov    rax,QWORD PTR [rbx]
  41c43c:	mov    r12d,0x1
  41c442:	cmp    rax,0x1
  41c446:	je     41c472 <p111_rt_op+0x302>
  41c448:	mov    rdx,rax
  41c44b:	xor    r12d,r12d
  41c44e:	shr    rdx,0x38
  41c452:	and    edx,0x7f
  41c455:	cmp    rdx,0x1
  41c459:	jne    41c472 <p111_rt_op+0x302>
  41c45b:	shr    rax,0x28
  41c45f:	mov    edx,DWORD PTR [rip+0x10ead3]        # 52af38 <p111_core_cids+0x38>
  41c465:	xor    r12d,r12d
  41c468:	movzx  eax,ax
  41c46b:	cmp    rax,rdx
  41c46e:	sete   r12b
  41c472:	mov    rax,QWORD PTR [rbx+0x8]
  41c476:	cmp    rax,0x1
  41c47a:	je     41d0f5 <p111_rt_op+0xf85>
  41c480:	mov    rdx,rax
  41c483:	shr    rdx,0x38
  41c487:	and    edx,0x7f
  41c48a:	cmp    rdx,0x1
  41c48e:	jne    41c4b0 <p111_rt_op+0x340>
  41c490:	shr    rax,0x28
  41c494:	mov    edx,DWORD PTR [rip+0x10ea9e]        # 52af38 <p111_core_cids+0x38>
  41c49a:	movzx  eax,ax
  41c49d:	cmp    rax,rdx
  41c4a0:	sete   al
  41c4a3:	movzx  eax,al
  41c4a6:	xor    r12d,eax
  41c4a9:	nop    DWORD PTR [rax+0x0]
  41c4b0:	movsxd r12,r12d
  41c4b3:	jmp    41c254 <p111_rt_op+0xe4>
  41c4b8:	nop    DWORD PTR [rax+rax*1+0x0]
  41c4c0:	cmp    ecx,0x3
  41c4c3:	jne    41d002 <p111_rt_op+0xe92>
  41c4c9:	mov    rdx,QWORD PTR [rbx]
  41c4cc:	mov    eax,0x1
  41c4d1:	mov    r8,QWORD PTR [rbx+0x10]
  41c4d5:	mov    rcx,rdx
  41c4d8:	shr    rcx,0x28
  41c4dc:	and    ecx,0x1f
  41c4df:	shl    rax,cl
  41c4e2:	movabs rcx,0xffffffffff
  41c4ec:	and    rcx,rdx
  41c4ef:	sub    eax,0x1
  41c4f2:	and    eax,DWORD PTR [rbx+0x8]
  41c4f5:	mov    r14,rcx
  41c4f8:	test   rdx,rdx
  41c4fb:	js     41d240 <p111_rt_op+0x10d0>
  41c501:	mov    r9,QWORD PTR [rip+0x10ea48]        # 52af50 <p111_program_active>
  41c508:	mov    r13d,eax
  41c50b:	test   BYTE PTR [r9+0x58],0x2
  41c510:	je     41d0fe <p111_rt_op+0xf8e>
  41c516:	lea    rax,[r13*4+0x0]
  41c51e:	lea    rax,[rax+r14*8]
  41c522:	add    rax,rbp
  41c525:	mov    r15d,DWORD PTR [rax]
  41c528:	mov    DWORD PTR [rax],r8d
  41c52b:	mov    rcx,r15
  41c52e:	mov    rdx,QWORD PTR [rbx]
  41c531:	jmp    41c416 <p111_rt_op+0x2a6>
  41c536:	nop    WORD PTR cs:[rax+rax*1+0x0]
  41c540:	cmp    ecx,0x3
  41c543:	jne    41d002 <p111_rt_op+0xe92>
  41c549:	mov    rdx,QWORD PTR [rbx]
  41c54c:	mov    eax,0x1
  41c551:	mov    r13,QWORD PTR [rbx+0x10]
  41c555:	mov    rcx,rdx
  41c558:	shr    rcx,0x28
  41c55c:	and    ecx,0x1f
  41c55f:	shl    rax,cl
  41c562:	movabs rcx,0xffffffffff
  41c56c:	and    rcx,rdx
  41c56f:	sub    eax,0x1
  41c572:	and    eax,DWORD PTR [rbx+0x8]
  41c575:	mov    r15,rcx
  41c578:	test   rdx,rdx
  41c57b:	js     41d213 <p111_rt_op+0x10a3>
  41c581:	mov    r8,QWORD PTR [rip+0x10e9c8]        # 52af50 <p111_program_active>
  41c588:	mov    r14d,eax
  41c58b:	test   BYTE PTR [r8+0x58],0x2
  41c590:	je     41d127 <p111_rt_op+0xfb7>
  41c596:	lea    rax,[r14*4+0x0]
  41c59e:	lea    rax,[rax+r15*8]
  41c5a2:	mov    DWORD PTR [rbp+rax*1+0x0],r13d
  41c5a7:	jmp    41c251 <p111_rt_op+0xe1>
  41c5ac:	nop    DWORD PTR [rax+0x0]
  41c5b0:	cmp    ecx,0x1
  41c5b3:	jne    41d002 <p111_rt_op+0xe92>
  41c5b9:	mov    rdx,QWORD PTR [rbx]
  41c5bc:	mov    eax,0x1
  41c5c1:	mov    rcx,rdx
  41c5c4:	shr    rcx,0x28
  41c5c8:	and    ecx,0x1f
  41c5cb:	shl    rax,cl
  41c5ce:	mov    rcx,rax
  41c5d1:	jmp    41c416 <p111_rt_op+0x2a6>
  41c5d6:	nop    WORD PTR cs:[rax+rax*1+0x0]
  41c5e0:	cmp    ecx,0x1
  41c5e3:	jne    41d002 <p111_rt_op+0xe92>
  41c5e9:	pxor   xmm0,xmm0
  41c5ed:	cvtss2sd xmm0,DWORD PTR [rbx]
  41c5f1:	call   4022f0 <log10@plt>
  41c5f6:	cvtsd2ss xmm0,xmm0
  41c5fa:	movd   r12d,xmm0
  41c5ff:	jmp    41c254 <p111_rt_op+0xe4>
  41c604:	nop    DWORD PTR [rax+0x0]
  41c608:	cmp    ecx,0x1
  41c60b:	jne    41d002 <p111_rt_op+0xe92>
  41c611:	pxor   xmm0,xmm0
  41c615:	cvtss2sd xmm0,DWORD PTR [rbx]
  41c619:	call   402050 <log2@plt>
  41c61e:	cvtsd2ss xmm0,xmm0
  41c622:	movd   r12d,xmm0
  41c627:	jmp    41c254 <p111_rt_op+0xe4>
  41c62c:	nop    DWORD PTR [rax+0x0]
  41c630:	cmp    ecx,0x1
  41c633:	jne    41d002 <p111_rt_op+0xe92>
  41c639:	pxor   xmm0,xmm0
  41c63d:	cvtss2sd xmm0,DWORD PTR [rbx]
  41c641:	call   402230 <log@plt>
  41c646:	cvtsd2ss xmm0,xmm0
  41c64a:	movd   r12d,xmm0
  41c64f:	jmp    41c254 <p111_rt_op+0xe4>
  41c654:	nop    DWORD PTR [rax+0x0]
  41c658:	cmp    ecx,0x1
  41c65b:	jne    41d002 <p111_rt_op+0xe92>
  41c661:	mov    rax,QWORD PTR [rbx]
  41c664:	test   rax,rax
  41c667:	js     41d0b5 <p111_rt_op+0xf45>
  41c66d:	pxor   xmm0,xmm0
  41c671:	cvtsi2ss xmm0,rax
  41c676:	nop    WORD PTR cs:[rax+rax*1+0x0]
  41c680:	movd   r12d,xmm0
  41c685:	jmp    41c254 <p111_rt_op+0xe4>
  41c68a:	nop    WORD PTR [rax+rax*1+0x0]
  41c690:	cmp    ecx,0x2
  41c693:	jne    41d002 <p111_rt_op+0xe92>
  41c699:	mov    rdx,QWORD PTR [rbx]
  41c69c:	mov    rax,QWORD PTR [rbx+0x8]
  41c6a0:	mov    r12,rdx
  41c6a3:	sub    r12,rax
  41c6a6:	cmp    rdx,rax
  41c6a9:	mov    eax,0x0
  41c6ae:	cmovb  r12,rax
  41c6b2:	jmp    41c254 <p111_rt_op+0xe4>
  41c6b7:	nop    WORD PTR [rax+rax*1+0x0]
  41c6c0:	cmp    ecx,0x2
  41c6c3:	jne    41d002 <p111_rt_op+0xe92>
  41c6c9:	movabs rax,0xffffffffffff
  41c6d3:	mov    r12,QWORD PTR [rbx+0x8]
  41c6d7:	add    r12,QWORD PTR [rbx]
  41c6da:	cmp    r12,rax
  41c6dd:	jbe    41c254 <p111_rt_op+0xe4>
  41c6e3:	call   418be0 <nat_chk.part.0>
  41c6e8:	nop    DWORD PTR [rax+rax*1+0x0]
  41c6f0:	cmp    ecx,0x1
  41c6f3:	jne    41d002 <p111_rt_op+0xe92>
  41c6f9:	movss  xmm0,DWORD PTR [rbx]
  41c6fd:	ucomiss xmm0,xmm0
  41c700:	jp     41d1fc <p111_rt_op+0x108c>
  41c706:	lea    r13,[rsp+0x20]
  41c70b:	mov    rdi,r13
  41c70e:	call   418bf0 <f32_text.part.0>
  41c713:	mov    rsi,r12
  41c716:	movsxd rcx,eax
  41c719:	mov    rdx,r13
  41c71c:	mov    rdi,rbp
  41c71f:	call   41a800 <io_str>
  41c724:	mov    r12,rax
  41c727:	jmp    41c254 <p111_rt_op+0xe4>
  41c72c:	nop    DWORD PTR [rax+0x0]
  41c730:	cmp    ecx,0x1
  41c733:	jne    41d002 <p111_rt_op+0xe92>
  41c739:	movss  xmm0,DWORD PTR [rbx]
  41c73d:	comiss xmm0,DWORD PTR [rip+0x7cf0]        # 424434 <hex.3+0x14>
  41c744:	jb     41d0ad <p111_rt_op+0xf3d>
  41c74a:	movss  xmm1,DWORD PTR [rip+0x7cee]        # 424440 <hex.3+0x20>
  41c752:	comiss xmm1,xmm0
  41c755:	jbe    41d0ad <p111_rt_op+0xf3d>
  41c75b:	cvttss2si r12,xmm0
  41c760:	mov    r12d,r12d
  41c763:	jmp    41c254 <p111_rt_op+0xe4>
  41c768:	nop    DWORD PTR [rax+rax*1+0x0]
  41c770:	cmp    ecx,0x2
  41c773:	jne    41d002 <p111_rt_op+0xe92>
  41c779:	pxor   xmm0,xmm0
  41c77d:	pxor   xmm1,xmm1
  41c781:	cvtss2sd xmm0,DWORD PTR [rbx]
  41c785:	cvtss2sd xmm1,DWORD PTR [rbx+0x8]
  41c78a:	call   402240 <fmod@plt>
  41c78f:	cvtsd2ss xmm0,xmm0
  41c793:	movd   r12d,xmm0
  41c798:	jmp    41c254 <p111_rt_op+0xe4>
  41c79d:	nop    DWORD PTR [rax]
  41c7a0:	cmp    ecx,0x1
  41c7a3:	jne    41d002 <p111_rt_op+0xe92>
  41c7a9:	mov    r12d,DWORD PTR [rbx]
  41c7ac:	movd   xmm0,r12d
  41c7b1:	xorps  xmm0,XMMWORD PTR [rip+0x7ca8]        # 424460 <hex.3+0x40>
  41c7b8:	movd   r12d,xmm0
  41c7bd:	jmp    41c254 <p111_rt_op+0xe4>
  41c7c2:	nop    WORD PTR [rax+rax*1+0x0]
  41c7c8:	cmp    ecx,0x2
  41c7cb:	jne    41d002 <p111_rt_op+0xe92>
  41c7d1:	pxor   xmm0,xmm0
  41c7d5:	pxor   xmm1,xmm1
  41c7d9:	cvtss2sd xmm0,DWORD PTR [rbx]
  41c7dd:	cvtss2sd xmm1,DWORD PTR [rbx+0x8]
  41c7e2:	call   4023c0 <atan2@plt>
  41c7e7:	cvtsd2ss xmm0,xmm0
  41c7eb:	movd   r12d,xmm0
  41c7f0:	jmp    41c254 <p111_rt_op+0xe4>
  41c7f5:	nop    DWORD PTR [rax]
  41c7f8:	cmp    ecx,0x2
  41c7fb:	jne    41d002 <p111_rt_op+0xe92>
  41c801:	pxor   xmm0,xmm0
  41c805:	pxor   xmm1,xmm1
  41c809:	cvtss2sd xmm0,DWORD PTR [rbx]
  41c80d:	cvtss2sd xmm1,DWORD PTR [rbx+0x8]
  41c812:	call   402150 <pow@plt>
  41c817:	cvtsd2ss xmm0,xmm0
  41c81b:	movd   r12d,xmm0
  41c820:	jmp    41c254 <p111_rt_op+0xe4>
  41c825:	nop    DWORD PTR [rax]
  41c828:	cmp    ecx,0x1
  41c82b:	jne    41d002 <p111_rt_op+0xe92>
  41c831:	mov    r12d,DWORD PTR [rbx]
  41c834:	movd   xmm0,r12d
  41c839:	andps  xmm0,XMMWORD PTR [rip+0x7c10]        # 424450 <hex.3+0x30>
  41c840:	movd   r12d,xmm0
  41c845:	jmp    41c254 <p111_rt_op+0xe4>
  41c84a:	nop    WORD PTR [rax+rax*1+0x0]
  41c850:	cmp    ecx,0x1
  41c853:	jne    41d002 <p111_rt_op+0xe92>
  41c859:	mov    eax,DWORD PTR [rbx]
  41c85b:	movss  xmm1,DWORD PTR [rip+0x7bed]        # 424450 <hex.3+0x30>
  41c863:	movss  xmm3,DWORD PTR [rip+0x7bcd]        # 424438 <hex.3+0x18>
  41c86b:	movd   xmm2,eax
  41c86f:	movd   xmm0,eax
  41c873:	andps  xmm2,xmm1
  41c876:	ucomiss xmm3,xmm2
  41c879:	jbe    41c680 <p111_rt_op+0x510>
  41c87f:	cvttss2si edx,xmm0
  41c883:	pxor   xmm0,xmm0
  41c887:	movd   xmm2,eax
  41c88b:	andnps xmm1,xmm2
  41c88e:	cvtsi2ss xmm0,edx
  41c892:	orps   xmm0,xmm1
  41c895:	jmp    41c680 <p111_rt_op+0x510>
  41c89a:	nop    WORD PTR [rax+rax*1+0x0]
  41c8a0:	cmp    ecx,0x1
  41c8a3:	jne    41d002 <p111_rt_op+0xe92>
  41c8a9:	movss  xmm0,DWORD PTR [rbx]
  41c8ad:	movss  xmm2,DWORD PTR [rip+0x7b9b]        # 424450 <hex.3+0x30>
  41c8b5:	movss  xmm3,DWORD PTR [rip+0x7b7b]        # 424438 <hex.3+0x18>
  41c8bd:	movaps xmm1,xmm0
  41c8c0:	andps  xmm1,xmm2
  41c8c3:	ucomiss xmm3,xmm1
  41c8c6:	jbe    41c680 <p111_rt_op+0x510>
  41c8cc:	cvttss2si eax,xmm0
  41c8d0:	pxor   xmm1,xmm1
  41c8d4:	movaps xmm3,xmm0
  41c8d7:	movss  xmm4,DWORD PTR [rip+0x7b5d]        # 42443c <hex.3+0x1c>
  41c8df:	andnps xmm2,xmm0
  41c8e2:	cvtsi2ss xmm1,eax
  41c8e6:	cmpnless xmm3,xmm1
  41c8eb:	andps  xmm3,xmm4
  41c8ee:	addss  xmm1,xmm3
  41c8f2:	orps   xmm1,xmm2
  41c8f5:	movaps xmm0,xmm1
  41c8f8:	jmp    41c680 <p111_rt_op+0x510>
  41c8fd:	nop    DWORD PTR [rax]
  41c900:	cmp    ecx,0x1
  41c903:	jne    41d002 <p111_rt_op+0xe92>
  41c909:	movss  xmm0,DWORD PTR [rbx]
  41c90d:	movss  xmm2,DWORD PTR [rip+0x7b3b]        # 424450 <hex.3+0x30>
  41c915:	movss  xmm3,DWORD PTR [rip+0x7b1b]        # 424438 <hex.3+0x18>
  41c91d:	movaps xmm1,xmm0
  41c920:	andps  xmm1,xmm2
  41c923:	ucomiss xmm3,xmm1
  41c926:	jbe    41c680 <p111_rt_op+0x510>
  41c92c:	cvttss2si eax,xmm0
  41c930:	pxor   xmm1,xmm1
  41c934:	movss  xmm4,DWORD PTR [rip+0x7b00]        # 42443c <hex.3+0x1c>
  41c93c:	andnps xmm2,xmm0
  41c93f:	cvtsi2ss xmm1,eax
  41c943:	movaps xmm3,xmm1
  41c946:	cmpnless xmm3,xmm0
  41c94b:	andps  xmm3,xmm4
  41c94e:	subss  xmm1,xmm3
  41c952:	orps   xmm1,xmm2
  41c955:	movaps xmm0,xmm1
  41c958:	jmp    41c680 <p111_rt_op+0x510>
  41c95d:	nop    DWORD PTR [rax]
  41c960:	cmp    ecx,0x1
  41c963:	jne    41d002 <p111_rt_op+0xe92>
  41c969:	pxor   xmm0,xmm0
  41c96d:	cvtss2sd xmm0,DWORD PTR [rbx]
  41c971:	call   4024a0 <tanh@plt>
  41c976:	cvtsd2ss xmm0,xmm0
  41c97a:	movd   r12d,xmm0
  41c97f:	jmp    41c254 <p111_rt_op+0xe4>
  41c984:	nop    DWORD PTR [rax+0x0]
  41c988:	cmp    ecx,0x1
  41c98b:	jne    41d002 <p111_rt_op+0xe92>
  41c991:	pxor   xmm0,xmm0
  41c995:	cvtss2sd xmm0,DWORD PTR [rbx]
  41c999:	call   402340 <cosh@plt>
  41c99e:	cvtsd2ss xmm0,xmm0
  41c9a2:	movd   r12d,xmm0
  41c9a7:	jmp    41c254 <p111_rt_op+0xe4>
  41c9ac:	nop    DWORD PTR [rax+0x0]
  41c9b0:	cmp    ecx,0x1
  41c9b3:	jne    41d002 <p111_rt_op+0xe92>
  41c9b9:	pxor   xmm0,xmm0
  41c9bd:	cvtss2sd xmm0,DWORD PTR [rbx]
  41c9c1:	call   402360 <sinh@plt>
  41c9c6:	cvtsd2ss xmm0,xmm0
  41c9ca:	movd   r12d,xmm0
  41c9cf:	jmp    41c254 <p111_rt_op+0xe4>
  41c9d4:	nop    DWORD PTR [rax+0x0]
  41c9d8:	cmp    ecx,0x1
  41c9db:	jne    41d002 <p111_rt_op+0xe92>
  41c9e1:	pxor   xmm0,xmm0
  41c9e5:	cvtss2sd xmm0,DWORD PTR [rbx]
  41c9e9:	call   402140 <atan@plt>
  41c9ee:	cvtsd2ss xmm0,xmm0
  41c9f2:	movd   r12d,xmm0
  41c9f7:	jmp    41c254 <p111_rt_op+0xe4>
  41c9fc:	nop    DWORD PTR [rax+0x0]
  41ca00:	cmp    ecx,0x1
  41ca03:	jne    41d002 <p111_rt_op+0xe92>
  41ca09:	pxor   xmm0,xmm0
  41ca0d:	cvtss2sd xmm0,DWORD PTR [rbx]
  41ca11:	call   402280 <acos@plt>
  41ca16:	cvtsd2ss xmm0,xmm0
  41ca1a:	movd   r12d,xmm0
  41ca1f:	jmp    41c254 <p111_rt_op+0xe4>
  41ca24:	nop    DWORD PTR [rax+0x0]
  41ca28:	cmp    ecx,0x1
  41ca2b:	jne    41d002 <p111_rt_op+0xe92>
  41ca31:	pxor   xmm0,xmm0
  41ca35:	cvtss2sd xmm0,DWORD PTR [rbx]
  41ca39:	call   4024b0 <asin@plt>
  41ca3e:	cvtsd2ss xmm0,xmm0
  41ca42:	movd   r12d,xmm0
  41ca47:	jmp    41c254 <p111_rt_op+0xe4>
  41ca4c:	nop    DWORD PTR [rax+0x0]
  41ca50:	cmp    ecx,0x1
  41ca53:	jne    41d002 <p111_rt_op+0xe92>
  41ca59:	pxor   xmm0,xmm0
  41ca5d:	cvtss2sd xmm0,DWORD PTR [rbx]
  41ca61:	call   4023a0 <tan@plt>
  41ca66:	cvtsd2ss xmm0,xmm0
  41ca6a:	movd   r12d,xmm0
  41ca6f:	jmp    41c254 <p111_rt_op+0xe4>
  41ca74:	nop    DWORD PTR [rax+0x0]
  41ca78:	cmp    ecx,0x1
  41ca7b:	jne    41d002 <p111_rt_op+0xe92>
  41ca81:	pxor   xmm0,xmm0
  41ca85:	cvtss2sd xmm0,DWORD PTR [rbx]
  41ca89:	call   402260 <cos@plt>
  41ca8e:	cvtsd2ss xmm0,xmm0
  41ca92:	movd   r12d,xmm0
  41ca97:	jmp    41c254 <p111_rt_op+0xe4>
  41ca9c:	nop    DWORD PTR [rax+0x0]
  41caa0:	cmp    ecx,0x1
  41caa3:	jne    41d002 <p111_rt_op+0xe92>
  41caa9:	pxor   xmm0,xmm0
  41caad:	cvtss2sd xmm0,DWORD PTR [rbx]
  41cab1:	call   402480 <sin@plt>
  41cab6:	cvtsd2ss xmm0,xmm0
  41caba:	movd   r12d,xmm0
  41cabf:	jmp    41c254 <p111_rt_op+0xe4>
  41cac4:	nop    DWORD PTR [rax+0x0]
  41cac8:	cmp    ecx,0x2
  41cacb:	jne    41d002 <p111_rt_op+0xe92>
  41cad1:	xor    r12d,r12d
  41cad4:	movss  xmm0,DWORD PTR [rbx+0x8]
  41cad9:	ucomiss xmm0,DWORD PTR [rbx]
  41cadc:	mov    eax,0x0
  41cae1:	setnp  r12b
  41cae5:	cmovne r12,rax
  41cae9:	jmp    41c254 <p111_rt_op+0xe4>
  41caee:	xchg   ax,ax
  41caf0:	cmp    ecx,0x2
  41caf3:	jne    41d002 <p111_rt_op+0xe92>
  41caf9:	movss  xmm0,DWORD PTR [rbx]
  41cafd:	divss  xmm0,DWORD PTR [rbx+0x8]
  41cb02:	movd   r12d,xmm0
  41cb07:	jmp    41c254 <p111_rt_op+0xe4>
  41cb0c:	nop    DWORD PTR [rax+0x0]
  41cb10:	cmp    ecx,0x2
  41cb13:	jne    41d002 <p111_rt_op+0xe92>
  41cb19:	movss  xmm0,DWORD PTR [rbx+0x8]
  41cb1e:	mulss  xmm0,DWORD PTR [rbx]
  41cb22:	movd   r12d,xmm0
  41cb27:	jmp    41c254 <p111_rt_op+0xe4>
  41cb2c:	nop    DWORD PTR [rax+0x0]
  41cb30:	cmp    ecx,0x2
  41cb33:	jne    41d002 <p111_rt_op+0xe92>
  41cb39:	movss  xmm0,DWORD PTR [rbx]
  41cb3d:	subss  xmm0,DWORD PTR [rbx+0x8]
  41cb42:	movd   r12d,xmm0
  41cb47:	jmp    41c254 <p111_rt_op+0xe4>
  41cb4c:	nop    DWORD PTR [rax+0x0]
  41cb50:	cmp    ecx,0x2
  41cb53:	jne    41d002 <p111_rt_op+0xe92>
  41cb59:	mov    eax,DWORD PTR [rbx+0x8]
  41cb5c:	cmp    DWORD PTR [rbx],eax
  41cb5e:	seta   al
  41cb61:	setae  dl
  41cb64:	movzx  eax,al
  41cb67:	movzx  edx,dl
  41cb6a:	add    rax,rdx
  41cb6d:	je     41d098 <p111_rt_op+0xf28>
  41cb73:	cmp    rax,0x1
  41cb77:	je     41cddd <p111_rt_op+0xc6d>
  41cb7d:	mov    r12d,DWORD PTR [rip+0x10e3c0]        # 52af44 <p111_core_cids+0x44>
  41cb84:	shl    r12,0x28
  41cb88:	bts    r12,0x38
  41cb8d:	jmp    41c254 <p111_rt_op+0xe4>
  41cb92:	nop    WORD PTR [rax+rax*1+0x0]
  41cb98:	cmp    ecx,0x1
  41cb9b:	jne    41d002 <p111_rt_op+0xe92>
  41cba1:	mov    eax,DWORD PTR [rbx]
  41cba3:	xor    r12d,r12d
  41cba6:	test   eax,eax
  41cba8:	sete   r12b
  41cbac:	jmp    41c254 <p111_rt_op+0xe4>
  41cbb1:	nop    DWORD PTR [rax+0x0]
  41cbb8:	cmp    ecx,0x1
  41cbbb:	jne    41d002 <p111_rt_op+0xe92>
  41cbc1:	mov    r12,QWORD PTR [rbx]
  41cbc4:	not    r12d
  41cbc7:	jmp    41c254 <p111_rt_op+0xe4>
  41cbcc:	nop    DWORD PTR [rax+0x0]
  41cbd0:	cmp    ecx,0x2
  41cbd3:	jne    41d002 <p111_rt_op+0xe92>
  41cbd9:	mov    rax,QWORD PTR [rbx+0x8]
  41cbdd:	mov    r12,QWORD PTR [rbx]
  41cbe0:	mov    ecx,eax
  41cbe2:	test   eax,eax
  41cbe4:	je     41c254 <p111_rt_op+0xe4>
  41cbea:	mov    eax,r12d
  41cbed:	xor    edx,edx
  41cbef:	div    ecx
  41cbf1:	mov    r12,rdx
  41cbf4:	jmp    41c254 <p111_rt_op+0xe4>
  41cbf9:	nop    DWORD PTR [rax+0x0]
  41cc00:	cmp    ecx,0x2
  41cc03:	jne    41d002 <p111_rt_op+0xe92>
  41cc09:	mov    rax,QWORD PTR [rbx+0x8]
  41cc0d:	xor    r12d,r12d
  41cc10:	mov    ecx,eax
  41cc12:	test   eax,eax
  41cc14:	je     41c254 <p111_rt_op+0xe4>
  41cc1a:	mov    rax,QWORD PTR [rbx]
  41cc1d:	xor    edx,edx
  41cc1f:	div    ecx
  41cc21:	mov    r12,rax
  41cc24:	jmp    41c254 <p111_rt_op+0xe4>
  41cc29:	nop    DWORD PTR [rax+0x0]
  41cc30:	cmp    ecx,0x2
  41cc33:	jne    41d002 <p111_rt_op+0xe92>
  41cc39:	mov    rcx,QWORD PTR [rbx+0x8]
  41cc3d:	xor    r12d,r12d
  41cc40:	cmp    rcx,0x1f
  41cc44:	ja     41c254 <p111_rt_op+0xe4>
  41cc4a:	mov    r12,QWORD PTR [rbx]
  41cc4d:	shr    r12d,cl
  41cc50:	jmp    41c254 <p111_rt_op+0xe4>
  41cc55:	nop    DWORD PTR [rax]
  41cc58:	cmp    ecx,0x2
  41cc5b:	jne    41d002 <p111_rt_op+0xe92>
  41cc61:	mov    rcx,QWORD PTR [rbx+0x8]
  41cc65:	xor    r12d,r12d
  41cc68:	cmp    rcx,0x1f
  41cc6c:	ja     41c254 <p111_rt_op+0xe4>
  41cc72:	mov    r12,QWORD PTR [rbx]
  41cc75:	shl    r12d,cl
  41cc78:	jmp    41c254 <p111_rt_op+0xe4>
  41cc7d:	nop    DWORD PTR [rax]
  41cc80:	cmp    ecx,0x1
  41cc83:	jne    41d002 <p111_rt_op+0xe92>
  41cc89:	mov    r12,QWORD PTR [rbx]
  41cc8c:	shr    r12d,1
  41cc8f:	jmp    41c254 <p111_rt_op+0xe4>
  41cc94:	nop    DWORD PTR [rax+0x0]
  41cc98:	cmp    ecx,0x1
  41cc9b:	jne    41d002 <p111_rt_op+0xe92>
  41cca1:	mov    r12,QWORD PTR [rbx]
  41cca4:	add    r12d,r12d
  41cca7:	jmp    41c254 <p111_rt_op+0xe4>
  41ccac:	nop    DWORD PTR [rax+0x0]
  41ccb0:	cmp    ecx,0x1
  41ccb3:	jne    41d002 <p111_rt_op+0xe92>
  41ccb9:	mov    rax,QWORD PTR [rbx]
  41ccbc:	lea    r12d,[rax+0x1]
  41ccc0:	jmp    41c254 <p111_rt_op+0xe4>
  41ccc5:	nop    DWORD PTR [rax]
  41ccc8:	cmp    ecx,0x2
  41cccb:	jne    41d002 <p111_rt_op+0xe92>
  41ccd1:	xor    r12d,r12d
  41ccd4:	mov    eax,DWORD PTR [rbx+0x8]
  41ccd7:	cmp    DWORD PTR [rbx],eax
  41ccd9:	setae  r12b
  41ccdd:	jmp    41c254 <p111_rt_op+0xe4>
  41cce2:	nop    WORD PTR [rax+rax*1+0x0]
  41cce8:	cmp    ecx,0x2
  41cceb:	jne    41d002 <p111_rt_op+0xe92>
  41ccf1:	xor    r12d,r12d
  41ccf4:	mov    eax,DWORD PTR [rbx+0x8]
  41ccf7:	cmp    DWORD PTR [rbx],eax
  41ccf9:	seta   r12b
  41ccfd:	jmp    41c254 <p111_rt_op+0xe4>
  41cd02:	nop    WORD PTR [rax+rax*1+0x0]
  41cd08:	cmp    ecx,0x2
  41cd0b:	jne    41d002 <p111_rt_op+0xe92>
  41cd11:	mov    rax,QWORD PTR [rbx]
  41cd14:	mov    r12d,0x1
  41cd1a:	cmp    rax,0x1
  41cd1e:	je     41cd4a <p111_rt_op+0xbda>
  41cd20:	mov    rdx,rax
  41cd23:	xor    r12d,r12d
  41cd26:	shr    rdx,0x38
  41cd2a:	and    edx,0x7f
  41cd2d:	cmp    rdx,0x1
  41cd31:	jne    41cd4a <p111_rt_op+0xbda>
  41cd33:	shr    rax,0x28
  41cd37:	mov    edx,DWORD PTR [rip+0x10e1fb]        # 52af38 <p111_core_cids+0x38>
  41cd3d:	xor    r12d,r12d
  41cd40:	movzx  eax,ax
  41cd43:	cmp    rax,rdx
  41cd46:	sete   r12b
  41cd4a:	mov    rax,QWORD PTR [rbx+0x8]
  41cd4e:	cmp    rax,0x1
  41cd52:	je     41d0d3 <p111_rt_op+0xf63>
  41cd58:	mov    rdx,rax
  41cd5b:	shr    rdx,0x38
  41cd5f:	and    edx,0x7f
  41cd62:	cmp    rdx,0x1
  41cd66:	jne    41c4b0 <p111_rt_op+0x340>
  41cd6c:	shr    rax,0x28
  41cd70:	mov    edx,DWORD PTR [rip+0x10e1c2]        # 52af38 <p111_core_cids+0x38>
  41cd76:	movzx  eax,ax
  41cd79:	cmp    rax,rdx
  41cd7c:	sete   al
  41cd7f:	movzx  eax,al
  41cd82:	or     r12d,eax
  41cd85:	jmp    41c4b0 <p111_rt_op+0x340>
  41cd8a:	nop    WORD PTR [rax+rax*1+0x0]
  41cd90:	cmp    ecx,0x2
  41cd93:	jne    41d002 <p111_rt_op+0xe92>
  41cd99:	xor    r12d,r12d
  41cd9c:	mov    rax,QWORD PTR [rbx+0x8]
  41cda0:	cmp    QWORD PTR [rbx],rax
  41cda3:	setb   r12b
  41cda7:	jmp    41c254 <p111_rt_op+0xe4>
  41cdac:	nop    DWORD PTR [rax+0x0]
  41cdb0:	cmp    ecx,0x2
  41cdb3:	jne    41d002 <p111_rt_op+0xe92>
  41cdb9:	mov    rax,QWORD PTR [rbx+0x8]
  41cdbd:	cmp    QWORD PTR [rbx],rax
  41cdc0:	seta   al
  41cdc3:	setae  dl
  41cdc6:	movzx  eax,al
  41cdc9:	movzx  edx,dl
  41cdcc:	add    eax,edx
  41cdce:	je     41d098 <p111_rt_op+0xf28>
  41cdd4:	cmp    eax,0x1
  41cdd7:	jne    41cb7d <p111_rt_op+0xa0d>
  41cddd:	mov    r12d,DWORD PTR [rip+0x10e15c]        # 52af40 <p111_core_cids+0x40>
  41cde4:	shl    r12,0x28
  41cde8:	bts    r12,0x38
  41cded:	jmp    41c254 <p111_rt_op+0xe4>
  41cdf2:	nop    WORD PTR [rax+rax*1+0x0]
  41cdf8:	cmp    ecx,0x1
  41cdfb:	jne    41d002 <p111_rt_op+0xe92>
  41ce01:	movabs rax,0xffffffffffff
  41ce0b:	mov    r12,QWORD PTR [rbx]
  41ce0e:	add    r12,r12
  41ce11:	cmp    r12,rax
  41ce14:	jbe    41c254 <p111_rt_op+0xe4>
  41ce1a:	jmp    41c6e3 <p111_rt_op+0x573>
  41ce1f:	nop
  41ce20:	cmp    ecx,0x2
  41ce23:	jne    41d002 <p111_rt_op+0xe92>
  41ce29:	mov    r12,QWORD PTR [rbx+0x8]
  41ce2d:	mov    rcx,QWORD PTR [rbx]
  41ce30:	test   r12,r12
  41ce33:	je     41c254 <p111_rt_op+0xe4>
  41ce39:	movabs rsi,0xffffffffffff
  41ce43:	xor    edx,edx
  41ce45:	mov    rax,rsi
  41ce48:	div    r12
  41ce4b:	cmp    rcx,rax
  41ce4e:	ja     41c6e3 <p111_rt_op+0x573>
  41ce54:	imul   r12,rcx
  41ce58:	cmp    r12,rsi
  41ce5b:	jbe    41c254 <p111_rt_op+0xe4>
  41ce61:	jmp    41c6e3 <p111_rt_op+0x573>
  41ce66:	nop    WORD PTR cs:[rax+rax*1+0x0]
  41ce70:	cmp    ecx,0x1
  41ce73:	jne    41d002 <p111_rt_op+0xe92>
  41ce79:	mov    eax,DWORD PTR [rbx]
  41ce7b:	pxor   xmm0,xmm0
  41ce7f:	cvtsi2ss xmm0,rax
  41ce84:	movd   r12d,xmm0
  41ce89:	jmp    41c254 <p111_rt_op+0xe4>
  41ce8e:	xchg   ax,ax
  41ce90:	cmp    ecx,0x2
  41ce93:	jne    41d002 <p111_rt_op+0xe92>
  41ce99:	movss  xmm0,DWORD PTR [rbx+0x8]
  41ce9e:	addss  xmm0,DWORD PTR [rbx]
  41cea2:	movd   r12d,xmm0
  41cea7:	jmp    41c254 <p111_rt_op+0xe4>
  41ceac:	nop    DWORD PTR [rax+0x0]
  41ceb0:	cmp    ecx,0x1
  41ceb3:	jne    41d002 <p111_rt_op+0xe92>
  41ceb9:	mov    r12d,DWORD PTR [rbx]
  41cebc:	jmp    41c254 <p111_rt_op+0xe4>
  41cec1:	nop    DWORD PTR [rax+0x0]
  41cec8:	cmp    ecx,0x2
  41cecb:	jne    41d002 <p111_rt_op+0xe92>
  41ced1:	mov    rsi,QWORD PTR [rbx]
  41ced4:	mov    eax,0x1
  41ced9:	movabs rdx,0xffffffffff
  41cee3:	mov    rcx,rsi
  41cee6:	and    rdx,rsi
  41cee9:	shr    rcx,0x28
  41ceed:	and    ecx,0x1f
  41cef0:	shl    rax,cl
  41cef3:	sub    eax,0x1
  41cef6:	and    eax,DWORD PTR [rbx+0x8]
  41cef9:	test   rsi,rsi
  41cefc:	js     41d29e <p111_rt_op+0x112e>
  41cf02:	mov    rcx,QWORD PTR [rip+0x10e047]        # 52af50 <p111_program_active>
  41cf09:	test   BYTE PTR [rcx+0x58],0x2
  41cf0d:	je     41d1ac <p111_rt_op+0x103c>
  41cf13:	shl    rax,0x2
  41cf17:	lea    rax,[rax+rdx*8]
  41cf1b:	mov    r13d,DWORD PTR [rbp+rax*1+0x0]
  41cf20:	mov    rcx,r13
  41cf23:	jmp    41c52e <p111_rt_op+0x3be>
  41cf28:	nop    DWORD PTR [rax+rax*1+0x0]
  41cf30:	cmp    ecx,0x2
  41cf33:	jne    41d002 <p111_rt_op+0xe92>
  41cf39:	mov    rax,QWORD PTR [rbx+0x8]
  41cf3d:	mov    rcx,QWORD PTR [rbx]
  41cf40:	mov    rsi,r12
  41cf43:	lea    r8,[rsp+0x20]
  41cf48:	mov    rdi,rbp
  41cf4b:	mov    QWORD PTR [rsp+0x20],rax
  41cf50:	mov    rax,QWORD PTR [rip+0x10dff9]        # 52af50 <p111_program_active>
  41cf57:	mov    rdx,QWORD PTR [rax+0x58]
  41cf5b:	shr    rdx,1
  41cf5e:	xor    rdx,0x1
  41cf62:	and    edx,0x1
  41cf65:	call   419f20 <blk_new.constprop.0>
  41cf6a:	mov    r12,rax
  41cf6d:	jmp    41c254 <p111_rt_op+0xe4>
  41cf72:	nop    WORD PTR [rax+rax*1+0x0]
  41cf78:	cmp    ecx,0x1
  41cf7b:	jne    41d002 <p111_rt_op+0xe92>
  41cf81:	pxor   xmm0,xmm0
  41cf85:	cvtss2sd xmm0,DWORD PTR [rbx]
  41cf89:	call   402540 <exp@plt>
  41cf8e:	cvtsd2ss xmm0,xmm0
  41cf92:	jmp    41c680 <p111_rt_op+0x510>
  41cf97:	nop    WORD PTR [rax+rax*1+0x0]
  41cfa0:	cmp    ecx,0x1
  41cfa3:	jne    41d002 <p111_rt_op+0xe92>
  41cfa5:	movss  xmm0,DWORD PTR [rbx]
  41cfa9:	pxor   xmm1,xmm1
  41cfad:	ucomiss xmm1,xmm0
  41cfb0:	ja     41d344 <p111_rt_op+0x11d4>
  41cfb6:	sqrtss xmm0,xmm0
  41cfba:	jmp    41c680 <p111_rt_op+0x510>
  41cfbf:	nop
  41cfc0:	cmp    ecx,0x2
  41cfc3:	jne    41d002 <p111_rt_op+0xe92>
  41cfc5:	xor    r12d,r12d
  41cfc8:	movss  xmm0,DWORD PTR [rbx]
  41cfcc:	comiss xmm0,DWORD PTR [rbx+0x8]
  41cfd0:	setae  r12b
  41cfd4:	jmp    41c254 <p111_rt_op+0xe4>
  41cfd9:	nop    DWORD PTR [rax+0x0]
  41cfe0:	cmp    ecx,0x2
  41cfe3:	jne    41d002 <p111_rt_op+0xe92>
  41cfe5:	xor    r12d,r12d
  41cfe8:	movss  xmm0,DWORD PTR [rbx]
  41cfec:	comiss xmm0,DWORD PTR [rbx+0x8]
  41cff0:	seta   r12b
  41cff4:	jmp    41c254 <p111_rt_op+0xe4>
  41cff9:	sub    ecx,0x1
  41cffc:	je     4045fe <p111_rt_op.cold>
  41d002:	lea    rdi,[rip+0x67f7]        # 423800 <_IO_stdin_used+0x800>
  41d009:	call   417a90 <err_fail>
  41d00e:	sub    ecx,0x1
  41d011:	jne    41d002 <p111_rt_op+0xe92>
  41d013:	jmp    404697 <p111_rt_op.cold+0x99>
  41d018:	nop    DWORD PTR [rax+rax*1+0x0]
  41d020:	movd   xmm5,ecx
  41d024:	movd   xmm6,edi
  41d028:	addss  xmm5,xmm6
  41d02c:	movd   r11d,xmm5
  41d031:	nop    DWORD PTR [rax+0x0]
  41d038:	mov    eax,ecx
  41d03a:	lock cmpxchg DWORD PTR [rdx],r11d
  41d03f:	je     41c52e <p111_rt_op+0x3be>
  41d045:	mov    ecx,eax
  41d047:	jmp    41c22f <p111_rt_op+0xbf>
  41d04c:	nop    DWORD PTR [rax+0x0]
  41d050:	mov    r11d,edi
  41d053:	and    r11d,ecx
  41d056:	jmp    41d038 <p111_rt_op+0xec8>
  41d058:	cmp    edi,ecx
  41d05a:	mov    r11d,ecx
  41d05d:	cmovae r11d,edi
  41d061:	jmp    41d038 <p111_rt_op+0xec8>
  41d063:	cmp    edi,ecx
  41d065:	mov    r11d,ecx
  41d068:	cmovbe r11d,edi
  41d06c:	jmp    41d038 <p111_rt_op+0xec8>
  41d06e:	lea    r11d,[rdi+rcx*1]
  41d072:	jmp    41d038 <p111_rt_op+0xec8>
  41d074:	mov    r11d,edi
  41d077:	xor    r11d,ecx
  41d07a:	jmp    41d038 <p111_rt_op+0xec8>
  41d07c:	mov    r11d,edi
  41d07f:	or     r11d,ecx
  41d082:	jmp    41d038 <p111_rt_op+0xec8>
  41d084:	cmp    edi,ecx
  41d086:	mov    r11d,ecx
  41d089:	cmove  r11d,r8d
  41d08d:	jmp    41d038 <p111_rt_op+0xec8>
  41d08f:	mov    r11d,edi
  41d092:	jmp    41d038 <p111_rt_op+0xec8>
  41d094:	nop    DWORD PTR [rax+0x0]
  41d098:	mov    r12d,DWORD PTR [rip+0x10de9d]        # 52af3c <p111_core_cids+0x3c>
  41d09f:	shl    r12,0x28
  41d0a3:	bts    r12,0x38
  41d0a8:	jmp    41c254 <p111_rt_op+0xe4>
  41d0ad:	xor    r12d,r12d
  41d0b0:	jmp    41c254 <p111_rt_op+0xe4>
  41d0b5:	mov    rdx,rax
  41d0b8:	and    eax,0x1
  41d0bb:	pxor   xmm0,xmm0
  41d0bf:	shr    rdx,1
  41d0c2:	or     rdx,rax
  41d0c5:	cvtsi2ss xmm0,rdx
  41d0ca:	addss  xmm0,xmm0
  41d0ce:	jmp    41c680 <p111_rt_op+0x510>
  41d0d3:	mov    r12d,0x1
  41d0d9:	jmp    41c4b0 <p111_rt_op+0x340>
  41d0de:	cmp    ecx,0x4
  41d0e1:	jne    41d002 <p111_rt_op+0xe92>
  41d0e7:	mov    r8d,DWORD PTR [rbx+0x18]
  41d0eb:	mov    esi,0x8
  41d0f0:	jmp    41c1c0 <p111_rt_op+0x50>
  41d0f5:	xor    r12d,0x1
  41d0f9:	jmp    41c4b0 <p111_rt_op+0x340>
  41d0fe:	lea    rax,[r13+r14*1+0x0]
  41d103:	lea    r10,[rbp+rax*8+0x0]
  41d108:	mov    rax,r8
  41d10b:	shr    rax,0x38
  41d10f:	mov    r15,QWORD PTR [r10]
  41d112:	and    eax,0x7f
  41d115:	cmp    rax,0x2
  41d119:	je     41d2c4 <p111_rt_op+0x1154>
  41d11f:	mov    QWORD PTR [r10],r8
  41d122:	jmp    41c52b <p111_rt_op+0x3bb>
  41d127:	lea    rax,[r14+r15*1]
  41d12b:	lea    r9,[rbp+rax*8+0x0]
  41d130:	mov    rdx,QWORD PTR [r9]
  41d133:	mov    rax,rdx
  41d136:	shr    rax,0x38
  41d13a:	test   al,0x7e
  41d13c:	je     41d190 <p111_rt_op+0x1020>
  41d13e:	cmp    rdx,0xffffffffffffffff
  41d142:	je     41d190 <p111_rt_op+0x1020>
  41d144:	movabs rcx,0xffffffffff
  41d14e:	mov    rax,QWORD PTR [r8+0x40]
  41d152:	and    rcx,rdx
  41d155:	add    rax,0x7f
  41d159:	and    rax,0xffffffffffffff80
  41d15d:	add    rax,0x3108200
  41d163:	cmp    rcx,rax
  41d166:	jb     41d190 <p111_rt_op+0x1020>
  41d168:	mov    rdi,rbp
  41d16b:	mov    rsi,r12
  41d16e:	mov    QWORD PTR [rsp+0x8],r9
  41d173:	mov    QWORD PTR [rsp],r8
  41d177:	call   41a0c0 <term_drop>
  41d17c:	mov    r8,QWORD PTR [rsp]
  41d180:	mov    r9,QWORD PTR [rsp+0x8]
  41d185:	test   BYTE PTR [r8+0x58],0x2
  41d18a:	jne    41c596 <p111_rt_op+0x426>
  41d190:	mov    rax,r13
  41d193:	shr    rax,0x38
  41d197:	and    eax,0x7f
  41d19a:	cmp    rax,0x2
  41d19e:	je     41d2d8 <p111_rt_op+0x1168>
  41d1a4:	mov    QWORD PTR [r9],r13
  41d1a7:	jmp    41c251 <p111_rt_op+0xe1>
  41d1ac:	add    rax,rdx
  41d1af:	lea    r14,[rbp+rax*8+0x0]
  41d1b4:	mov    r13,QWORD PTR [r14]
  41d1b7:	test   r13,r13
  41d1ba:	js     41d2f0 <p111_rt_op+0x1180>
  41d1c0:	mov    rax,r13
  41d1c3:	shr    rax,0x38
  41d1c7:	test   al,0x7e
  41d1c9:	je     41cf20 <p111_rt_op+0xdb0>
  41d1cf:	movabs rdx,0xffffffffff
  41d1d9:	mov    rax,QWORD PTR [rcx+0x40]
  41d1dd:	and    rdx,r13
  41d1e0:	add    rax,0x7f
  41d1e4:	and    rax,0xffffffffffffff80
  41d1e8:	add    rax,0x3108200
  41d1ee:	cmp    rdx,rax
  41d1f1:	jae    40470b <p111_rt_op.cold+0x10d>
  41d1f7:	jmp    41cf20 <p111_rt_op+0xdb0>
  41d1fc:	mov    DWORD PTR [rsp+0x20],0x6e616e
  41d204:	mov    eax,0x3
  41d209:	lea    r13,[rsp+0x20]
  41d20e:	jmp    41c713 <p111_rt_op+0x5a3>
  41d213:	lea    rsi,[rbp+rcx*8+0x0]
  41d218:	mov    ecx,DWORD PTR [rsi+0x4]
  41d21b:	mov    edx,DWORD PTR [rsi]
  41d21d:	shl    rcx,0x20
  41d221:	or     rcx,rdx
  41d224:	and    edx,0xffffff
  41d22a:	cmp    rdx,0x1
  41d22e:	je     41d32a <p111_rt_op+0x11ba>
  41d234:	shr    rcx,0x18
  41d238:	mov    r15,rcx
  41d23b:	jmp    41c581 <p111_rt_op+0x411>
  41d240:	lea    rsi,[rbp+rcx*8+0x0]
  41d245:	mov    ecx,DWORD PTR [rsi+0x4]
  41d248:	mov    edx,DWORD PTR [rsi]
  41d24a:	shl    rcx,0x20
  41d24e:	or     rcx,rdx
  41d251:	and    edx,0xffffff
  41d257:	cmp    rdx,0x1
  41d25b:	je     41d335 <p111_rt_op+0x11c5>
  41d261:	shr    rcx,0x18
  41d265:	mov    r14,rcx
  41d268:	jmp    41c501 <p111_rt_op+0x391>
  41d26d:	add    r9,rbp
  41d270:	mov    edx,DWORD PTR [r9+0x4]
  41d274:	mov    eax,DWORD PTR [r9]
  41d277:	shl    rdx,0x20
  41d27b:	or     rdx,rax
  41d27e:	and    eax,0xffffff
  41d283:	cmp    rax,0x1
  41d287:	je     41d33c <p111_rt_op+0x11cc>
  41d28d:	shr    rdx,0x18
  41d291:	lea    r9,[rdx*8+0x0]
  41d299:	jmp    41c1e8 <p111_rt_op+0x78>
  41d29e:	lea    rsi,[rbp+rdx*8+0x0]
  41d2a3:	mov    edx,DWORD PTR [rsi+0x4]
  41d2a6:	mov    ecx,DWORD PTR [rsi]
  41d2a8:	shl    rdx,0x20
  41d2ac:	or     rdx,rcx
  41d2af:	and    ecx,0xffffff
  41d2b5:	cmp    rcx,0x1
  41d2b9:	je     41d331 <p111_rt_op+0x11c1>
  41d2bb:	shr    rdx,0x18
  41d2bf:	jmp    41cf02 <p111_rt_op+0xd92>
  41d2c4:	test   r8,r8
  41d2c7:	js     41d11f <p111_rt_op+0xfaf>
  41d2cd:	jmp    4046c4 <p111_rt_op.cold+0xc6>
  41d2d2:	nop    WORD PTR [rax+rax*1+0x0]
  41d2d8:	test   r13,r13
  41d2db:	js     41d1a4 <p111_rt_op+0x1034>
  41d2e1:	jmp    404743 <p111_rt_op.cold+0x145>
  41d2e6:	nop    WORD PTR cs:[rax+rax*1+0x0]
  41d2f0:	movabs rax,0xffffffffff
  41d2fa:	and    rax,r13
  41d2fd:	lea    rdx,[rbp+rax*8+0x0]
  41d302:	mov    eax,DWORD PTR [rdx]
  41d304:	lea    ecx,[rax+0x1]
  41d307:	and    eax,0xffffff
  41d30c:	mov    DWORD PTR [rdx],ecx
  41d30e:	cmp    eax,0xfffffd
  41d313:	jbe    41cf20 <p111_rt_op+0xdb0>
  41d319:	call   418bd0 <rfc_bump.part.0>
  41d31e:	lea    rdi,[rip+0x6503]        # 423828 <_IO_stdin_used+0x828>
  41d325:	call   417a90 <err_fail>
  41d32a:	mov    edx,DWORD PTR [rsi]
  41d32c:	jmp    41d234 <p111_rt_op+0x10c4>
  41d331:	mov    ecx,DWORD PTR [rsi]
  41d333:	jmp    41d2bb <p111_rt_op+0x114b>
  41d335:	mov    edx,DWORD PTR [rsi]
  41d337:	jmp    41d261 <p111_rt_op+0x10f1>
  41d33c:	mov    eax,DWORD PTR [r9]
  41d33f:	jmp    41d28d <p111_rt_op+0x111d>
  41d344:	call   402350 <sqrtf@plt>
  41d349:	jmp    41c680 <p111_rt_op+0x510>

Disassembly of section .fini:
