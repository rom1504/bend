
/home/ai/bend2/build/publish/bend/selfhost/build/phase99/phase102-runtime-products04/variation-ray-active-256-2240/candidate.program:     file format elf64-x86-64


Disassembly of section .text:

00000000000134c0 <NF_FID_36_112_114_111_100_117_99_116_46_110_101_97_114_101_115_116_>:
   134c0:	55                   	push   rbp
   134c1:	41 57                	push   r15
   134c3:	41 56                	push   r14
   134c5:	41 55                	push   r13
   134c7:	41 54                	push   r12
   134c9:	53                   	push   rbx
   134ca:	48 83 ec 38          	sub    rsp,0x38
   134ce:	48 89 74 24 18       	mov    QWORD PTR [rsp+0x18],rsi
   134d3:	8b 84 24 b0 00 00 00 	mov    eax,DWORD PTR [rsp+0xb0]
   134da:	8b ac 24 a8 00 00 00 	mov    ebp,DWORD PTR [rsp+0xa8]
   134e1:	44 8b b4 24 a0 00 00 	mov    r14d,DWORD PTR [rsp+0xa0]
   134e8:	00 
   134e9:	8b 9c 24 98 00 00 00 	mov    ebx,DWORD PTR [rsp+0x98]
   134f0:	44 8b bc 24 90 00 00 	mov    r15d,DWORD PTR [rsp+0x90]
   134f7:	00 
   134f8:	48 85 c9             	test   rcx,rcx
   134fb:	0f 84 02 0f 00 00    	je     14403 <NF_FID_36_112_114_111_100_117_99_116_46_110_101_97_114_101_115_116_+0xf43>
   13501:	48 89 54 24 30       	mov    QWORD PTR [rsp+0x30],rdx
   13506:	49 ba 00 00 00 00 00 	movabs r10,0x200000000000000
   1350d:	00 00 02 
   13510:	48 ba 80 ff ff ff ff 	movabs rdx,0xffffffff80
   13517:	00 00 00 
   1351a:	66 41 0f 6e f0       	movd   xmm6,r8d
   1351f:	49 89 d0             	mov    r8,rdx
   13522:	66 41 0f 6e f9       	movd   xmm7,r9d
   13527:	f3 44 0f 10 44 24 70 	movss  xmm8,DWORD PTR [rsp+0x70]
   1352e:	f3 44 0f 10 4c 24 78 	movss  xmm9,DWORD PTR [rsp+0x78]
   13535:	f3 44 0f 10 94 24 80 	movss  xmm10,DWORD PTR [rsp+0x80]
   1353c:	00 00 00 
   1353f:	f3 44 0f 10 9c 24 88 	movss  xmm11,DWORD PTR [rsp+0x88]
   13546:	00 00 00 
   13549:	4c 8d 4a 7f          	lea    r9,[rdx+0x7f]
   1354d:	f3 44 0f 10 25 1a ea 	movss  xmm12,DWORD PTR [rip+0xfffffffffffeea1a]        # 1f70 <_IO_stdin_used-0x68>
   13554:	fe ff 
   13556:	45 0f 57 ed          	xorps  xmm13,xmm13
   1355a:	48 89 7c 24 28       	mov    QWORD PTR [rsp+0x28],rdi
   1355f:	66 0f 7e 74 24 10    	movd   DWORD PTR [rsp+0x10],xmm6
   13565:	66 0f 7e 7c 24 0c    	movd   DWORD PTR [rsp+0xc],xmm7
   1356b:	4c 89 4c 24 20       	mov    QWORD PTR [rsp+0x20],r9
   13570:	eb 52                	jmp    135c4 <NF_FID_36_112_114_111_100_117_99_116_46_110_101_97_114_101_115_116_+0x104>
   13572:	66 66 66 66 66 2e 0f 	data16 data16 data16 data16 nop WORD PTR cs:[rax+rax*1+0x0]
   13579:	1f 84 00 00 00 00 00 
   13580:	4c 89 e0             	mov    rax,r12
   13583:	4c 21 c8             	and    rax,r9
   13586:	b9 01 00 00 00       	mov    ecx,0x1
   1358b:	f0 0f c1 0c c7       	lock xadd DWORD PTR [rdi+rax*8],ecx
   13590:	f7 d1                	not    ecx
   13592:	45 89 ee             	mov    r14d,r13d
   13595:	89 dd                	mov    ebp,ebx
   13597:	f7 c1 fe ff ff 00    	test   ecx,0xfffffe
   1359d:	0f 84 90 0e 00 00    	je     14433 <NF_FID_36_112_114_111_100_117_99_116_46_110_101_97_114_101_115_116_+0xf73>
   135a3:	66 41 0f 6e c7       	movd   xmm0,r15d
   135a8:	66 41 0f 6e ce       	movd   xmm1,r14d
   135ad:	31 c0                	xor    eax,eax
   135af:	0f 2e c8             	ucomiss xmm1,xmm0
   135b2:	0f 97 c0             	seta   al
   135b5:	4c 89 e1             	mov    rcx,r12
   135b8:	44 89 e3             	mov    ebx,r12d
   135bb:	4d 85 e4             	test   r12,r12
   135be:	0f 84 38 0e 00 00    	je     143fc <NF_FID_36_112_114_111_100_117_99_116_46_110_101_97_114_101_115_116_+0xf3c>
   135c4:	4c 8d 61 ff          	lea    r12,[rcx-0x1]
   135c8:	85 c0                	test   eax,eax
   135ca:	0f 84 90 00 00 00    	je     13660 <NF_FID_36_112_114_111_100_117_99_116_46_110_101_97_114_101_115_116_+0x1a0>
   135d0:	45 89 fd             	mov    r13d,r15d
   135d3:	4d 85 e4             	test   r12,r12
   135d6:	0f 88 14 01 00 00    	js     136f0 <NF_FID_36_112_114_111_100_117_99_116_46_110_101_97_114_101_115_116_+0x230>
   135dc:	49 8d 42 01          	lea    rax,[r10+0x1]
   135e0:	48 39 c1             	cmp    rcx,rax
   135e3:	0f 92 c0             	setb   al
   135e6:	4c 89 e1             	mov    rcx,r12
   135e9:	4c 21 c1             	and    rcx,r8
   135ec:	48 81 f9 80 81 10 03 	cmp    rcx,0x3108180
   135f3:	0f 92 c1             	setb   cl
   135f6:	08 c1                	or     cl,al
   135f8:	0f 85 28 01 00 00    	jne    13726 <NF_FID_36_112_114_111_100_117_99_116_46_110_101_97_114_101_115_116_+0x266>
   135fe:	48 8b 74 24 18       	mov    rsi,QWORD PTR [rsp+0x18]
   13603:	4c 89 e2             	mov    rdx,r12
   13606:	b9 02 00 00 00       	mov    ecx,0x2
   1360b:	e8 ee 3d 00 00       	call   173fe <rfc_wrap>
   13610:	45 0f 57 ed          	xorps  xmm13,xmm13
   13614:	f3 44 0f 10 25 53 e9 	movss  xmm12,DWORD PTR [rip+0xfffffffffffee953]        # 1f70 <_IO_stdin_used-0x68>
   1361b:	fe ff 
   1361d:	f3 44 0f 10 9c 24 88 	movss  xmm11,DWORD PTR [rsp+0x88]
   13624:	00 00 00 
   13627:	f3 44 0f 10 94 24 80 	movss  xmm10,DWORD PTR [rsp+0x80]
   1362e:	00 00 00 
   13631:	f3 44 0f 10 4c 24 78 	movss  xmm9,DWORD PTR [rsp+0x78]
   13638:	f3 44 0f 10 44 24 70 	movss  xmm8,DWORD PTR [rsp+0x70]
   1363f:	66 0f 6e 7c 24 0c    	movd   xmm7,DWORD PTR [rsp+0xc]
   13645:	66 0f 6e 74 24 10    	movd   xmm6,DWORD PTR [rsp+0x10]
   1364b:	49 89 c4             	mov    r12,rax
   1364e:	4c 21 c8             	and    rax,r9
   13651:	e9 b8 00 00 00       	jmp    1370e <NF_FID_36_112_114_111_100_117_99_116_46_110_101_97_114_101_115_116_+0x24e>
   13656:	66 2e 0f 1f 84 00 00 	nop    WORD PTR cs:[rax+rax*1+0x0]
   1365d:	00 00 00 
   13660:	4d 85 e4             	test   r12,r12
   13663:	0f 88 25 01 00 00    	js     1378e <NF_FID_36_112_114_111_100_117_99_116_46_110_101_97_114_101_115_116_+0x2ce>
   13669:	49 8d 42 01          	lea    rax,[r10+0x1]
   1366d:	48 39 c1             	cmp    rcx,rax
   13670:	0f 92 c0             	setb   al
   13673:	4c 89 e1             	mov    rcx,r12
   13676:	4c 21 c1             	and    rcx,r8
   13679:	48 81 f9 80 81 10 03 	cmp    rcx,0x3108180
   13680:	0f 92 c1             	setb   cl
   13683:	08 c1                	or     cl,al
   13685:	0f 85 39 01 00 00    	jne    137c4 <NF_FID_36_112_114_111_100_117_99_116_46_110_101_97_114_101_115_116_+0x304>
   1368b:	48 8b 74 24 18       	mov    rsi,QWORD PTR [rsp+0x18]
   13690:	4c 89 e2             	mov    rdx,r12
   13693:	b9 02 00 00 00       	mov    ecx,0x2
   13698:	e8 61 3d 00 00       	call   173fe <rfc_wrap>
   1369d:	45 0f 57 ed          	xorps  xmm13,xmm13
   136a1:	f3 44 0f 10 25 c6 e8 	movss  xmm12,DWORD PTR [rip+0xfffffffffffee8c6]        # 1f70 <_IO_stdin_used-0x68>
   136a8:	fe ff 
   136aa:	f3 44 0f 10 9c 24 88 	movss  xmm11,DWORD PTR [rsp+0x88]
   136b1:	00 00 00 
   136b4:	f3 44 0f 10 94 24 80 	movss  xmm10,DWORD PTR [rsp+0x80]
   136bb:	00 00 00 
   136be:	f3 44 0f 10 4c 24 78 	movss  xmm9,DWORD PTR [rsp+0x78]
   136c5:	f3 44 0f 10 44 24 70 	movss  xmm8,DWORD PTR [rsp+0x70]
   136cc:	66 0f 6e 7c 24 0c    	movd   xmm7,DWORD PTR [rsp+0xc]
   136d2:	66 0f 6e 74 24 10    	movd   xmm6,DWORD PTR [rsp+0x10]
   136d8:	49 89 c4             	mov    r12,rax
   136db:	4c 21 c8             	and    rax,r9
   136de:	e9 c9 00 00 00       	jmp    137ac <NF_FID_36_112_114_111_100_117_99_116_46_110_101_97_114_101_115_116_+0x2ec>
   136e3:	66 66 66 66 2e 0f 1f 	data16 data16 data16 nop WORD PTR cs:[rax+rax*1+0x0]
   136ea:	84 00 00 00 00 00 
   136f0:	4c 89 e0             	mov    rax,r12
   136f3:	4c 21 c8             	and    rax,r9
   136f6:	b9 01 00 00 00       	mov    ecx,0x1
   136fb:	f0 0f c1 0c c7       	lock xadd DWORD PTR [rdi+rax*8],ecx
   13700:	f7 d1                	not    ecx
   13702:	f7 c1 fe ff ff 00    	test   ecx,0xfffffe
   13708:	0f 84 25 0d 00 00    	je     14433 <NF_FID_36_112_114_111_100_117_99_116_46_110_101_97_114_101_115_116_+0xf73>
   1370e:	b9 01 00 00 00       	mov    ecx,0x1
   13713:	f0 0f c1 0c c7       	lock xadd DWORD PTR [rdi+rax*8],ecx
   13718:	f7 d1                	not    ecx
   1371a:	f7 c1 fe ff ff 00    	test   ecx,0xfffffe
   13720:	0f 84 0d 0d 00 00    	je     14433 <NF_FID_36_112_114_111_100_117_99_116_46_110_101_97_114_101_115_116_+0xf73>
   13726:	49 83 fc 07          	cmp    r12,0x7
   1372a:	0f 87 49 01 00 00    	ja     13879 <NF_FID_36_112_114_111_100_117_99_116_46_110_101_97_114_101_115_116_+0x3b9>
   13730:	48 8d 0d e9 ea fe ff 	lea    rcx,[rip+0xfffffffffffeeae9]        # 2220 <_IO_stdin_used+0x248>
   13737:	4a 63 04 a1          	movsxd rax,DWORD PTR [rcx+r12*4]
   1373b:	48 01 c8             	add    rax,rcx
   1373e:	f3 0f 10 25 32 e8 fe 	movss  xmm4,DWORD PTR [rip+0xfffffffffffee832]        # 1f78 <_IO_stdin_used-0x60>
   13745:	ff 
   13746:	41 0f 28 c4          	movaps xmm0,xmm12
   1374a:	f3 0f 10 15 36 e8 fe 	movss  xmm2,DWORD PTR [rip+0xfffffffffffee836]        # 1f88 <_IO_stdin_used-0x50>
   13751:	ff 
   13752:	ff e0                	jmp    rax
   13754:	0f 57 e4             	xorps  xmm4,xmm4
   13757:	49 83 fc 06          	cmp    r12,0x6
   1375b:	0f 87 fe 02 00 00    	ja     13a5f <NF_FID_36_112_114_111_100_117_99_116_46_110_101_97_114_101_115_116_+0x59f>
   13761:	48 8d 0d d8 ea fe ff 	lea    rcx,[rip+0xfffffffffffeead8]        # 2240 <_IO_stdin_used+0x268>
   13768:	4a 63 04 a1          	movsxd rax,DWORD PTR [rcx+r12*4]
   1376c:	48 01 c8             	add    rax,rcx
   1376f:	ff e0                	jmp    rax
   13771:	f3 0f 10 0d 07 e8 fe 	movss  xmm1,DWORD PTR [rip+0xfffffffffffee807]        # 1f80 <_IO_stdin_used-0x58>
   13778:	ff 
   13779:	f3 0f 10 15 47 e8 fe 	movss  xmm2,DWORD PTR [rip+0xfffffffffffee847]        # 1fc8 <_IO_stdin_used-0x10>
   13780:	ff 
   13781:	f3 0f 10 05 37 e8 fe 	movss  xmm0,DWORD PTR [rip+0xfffffffffffee837]        # 1fc0 <_IO_stdin_used-0x18>
   13788:	ff 
   13789:	e9 aa 07 00 00       	jmp    13f38 <NF_FID_36_112_114_111_100_117_99_116_46_110_101_97_114_101_115_116_+0xa78>
   1378e:	4c 89 e0             	mov    rax,r12
   13791:	4c 21 c8             	and    rax,r9
   13794:	b9 01 00 00 00       	mov    ecx,0x1
   13799:	f0 0f c1 0c c7       	lock xadd DWORD PTR [rdi+rax*8],ecx
   1379e:	f7 d1                	not    ecx
   137a0:	f7 c1 fe ff ff 00    	test   ecx,0xfffffe
   137a6:	0f 84 87 0c 00 00    	je     14433 <NF_FID_36_112_114_111_100_117_99_116_46_110_101_97_114_101_115_116_+0xf73>
   137ac:	b9 01 00 00 00       	mov    ecx,0x1
   137b1:	f0 0f c1 0c c7       	lock xadd DWORD PTR [rdi+rax*8],ecx
   137b6:	f7 d1                	not    ecx
   137b8:	f7 c1 fe ff ff 00    	test   ecx,0xfffffe
   137be:	0f 84 6f 0c 00 00    	je     14433 <NF_FID_36_112_114_111_100_117_99_116_46_110_101_97_114_101_115_116_+0xf73>
   137c4:	49 83 fc 07          	cmp    r12,0x7
   137c8:	0f 87 b8 01 00 00    	ja     13986 <NF_FID_36_112_114_111_100_117_99_116_46_110_101_97_114_101_115_116_+0x4c6>
   137ce:	48 8d 0d 87 ea fe ff 	lea    rcx,[rip+0xfffffffffffeea87]        # 225c <_IO_stdin_used+0x284>
   137d5:	4a 63 04 a1          	movsxd rax,DWORD PTR [rcx+r12*4]
   137d9:	48 01 c8             	add    rax,rcx
   137dc:	f3 0f 10 25 94 e7 fe 	movss  xmm4,DWORD PTR [rip+0xfffffffffffee794]        # 1f78 <_IO_stdin_used-0x60>
   137e3:	ff 
   137e4:	41 0f 28 c4          	movaps xmm0,xmm12
   137e8:	f3 0f 10 15 98 e7 fe 	movss  xmm2,DWORD PTR [rip+0xfffffffffffee798]        # 1f88 <_IO_stdin_used-0x50>
   137ef:	ff 
   137f0:	ff e0                	jmp    rax
   137f2:	0f 57 e4             	xorps  xmm4,xmm4
   137f5:	49 83 fc 06          	cmp    r12,0x6
   137f9:	0f 87 37 04 00 00    	ja     13c36 <NF_FID_36_112_114_111_100_117_99_116_46_110_101_97_114_101_115_116_+0x776>
   137ff:	48 8d 0d 76 ea fe ff 	lea    rcx,[rip+0xfffffffffffeea76]        # 227c <_IO_stdin_used+0x2a4>
   13806:	4a 63 04 a1          	movsxd rax,DWORD PTR [rcx+r12*4]
   1380a:	48 01 c8             	add    rax,rcx
   1380d:	ff e0                	jmp    rax
   1380f:	f3 0f 10 0d 69 e7 fe 	movss  xmm1,DWORD PTR [rip+0xfffffffffffee769]        # 1f80 <_IO_stdin_used-0x58>
   13816:	ff 
   13817:	f3 0f 10 15 a9 e7 fe 	movss  xmm2,DWORD PTR [rip+0xfffffffffffee7a9]        # 1fc8 <_IO_stdin_used-0x10>
   1381e:	ff 
   1381f:	f3 0f 10 05 99 e7 fe 	movss  xmm0,DWORD PTR [rip+0xfffffffffffee799]        # 1fc0 <_IO_stdin_used-0x18>
   13826:	ff 
   13827:	e9 86 09 00 00       	jmp    141b2 <NF_FID_36_112_114_111_100_117_99_116_46_110_101_97_114_101_115_116_+0xcf2>
   1382c:	41 bc 03 00 00 00    	mov    r12d,0x3
   13832:	f3 0f 10 0d 6e e7 fe 	movss  xmm1,DWORD PTR [rip+0xfffffffffffee76e]        # 1fa8 <_IO_stdin_used-0x30>
   13839:	ff 
   1383a:	f3 0f 10 15 4a e7 fe 	movss  xmm2,DWORD PTR [rip+0xfffffffffffee74a]        # 1f8c <_IO_stdin_used-0x4c>
   13841:	ff 
   13842:	e9 ed 06 00 00       	jmp    13f34 <NF_FID_36_112_114_111_100_117_99_116_46_110_101_97_114_101_115_116_+0xa74>
   13847:	f3 0f 10 0d 6d e7 fe 	movss  xmm1,DWORD PTR [rip+0xfffffffffffee76d]        # 1fbc <_IO_stdin_used-0x1c>
   1384e:	ff 
   1384f:	f3 0f 10 25 9d e7 fe 	movss  xmm4,DWORD PTR [rip+0xfffffffffffee79d]        # 1ff4 <_IO_stdin_used+0x1c>
   13856:	ff 
   13857:	e9 d0 06 00 00       	jmp    13f2c <NF_FID_36_112_114_111_100_117_99_116_46_110_101_97_114_101_115_116_+0xa6c>
   1385c:	f3 0f 10 0d 44 e7 fe 	movss  xmm1,DWORD PTR [rip+0xfffffffffffee744]        # 1fa8 <_IO_stdin_used-0x30>
   13863:	ff 
   13864:	f3 0f 10 25 40 e7 fe 	movss  xmm4,DWORD PTR [rip+0xfffffffffffee740]        # 1fac <_IO_stdin_used-0x2c>
   1386b:	ff 
   1386c:	f3 0f 10 15 18 e7 fe 	movss  xmm2,DWORD PTR [rip+0xfffffffffffee718]        # 1f8c <_IO_stdin_used-0x4c>
   13873:	ff 
   13874:	e9 bb 06 00 00       	jmp    13f34 <NF_FID_36_112_114_111_100_117_99_116_46_110_101_97_114_101_115_116_+0xa74>
   13879:	49 8d 54 24 f8       	lea    rdx,[r12-0x8]
   1387e:	48 b8 00 00 00 00 00 	movabs rax,0x7e00000000000000
   13885:	00 00 7e 
   13888:	48 85 c2             	test   rdx,rax
   1388b:	0f 94 c0             	sete   al
   1388e:	48 89 d1             	mov    rcx,rdx
   13891:	4c 21 c1             	and    rcx,r8
   13894:	48 81 f9 80 81 10 03 	cmp    rcx,0x3108180
   1389b:	0f 92 c1             	setb   cl
   1389e:	08 c1                	or     cl,al
   138a0:	75 63                	jne    13905 <NF_FID_36_112_114_111_100_117_99_116_46_110_101_97_114_101_115_116_+0x445>
   138a2:	48 8b 74 24 18       	mov    rsi,QWORD PTR [rsp+0x18]
   138a7:	e8 34 39 ff ff       	call   71e0 <term_drop>
   138ac:	45 0f 57 ed          	xorps  xmm13,xmm13
   138b0:	f3 44 0f 10 25 b7 e6 	movss  xmm12,DWORD PTR [rip+0xfffffffffffee6b7]        # 1f70 <_IO_stdin_used-0x68>
   138b7:	fe ff 
   138b9:	4c 8b 4c 24 20       	mov    r9,QWORD PTR [rsp+0x20]
   138be:	f3 44 0f 10 9c 24 88 	movss  xmm11,DWORD PTR [rsp+0x88]
   138c5:	00 00 00 
   138c8:	f3 44 0f 10 94 24 80 	movss  xmm10,DWORD PTR [rsp+0x80]
   138cf:	00 00 00 
   138d2:	f3 44 0f 10 4c 24 78 	movss  xmm9,DWORD PTR [rsp+0x78]
   138d9:	f3 44 0f 10 44 24 70 	movss  xmm8,DWORD PTR [rsp+0x70]
   138e0:	66 0f 6e 7c 24 0c    	movd   xmm7,DWORD PTR [rsp+0xc]
   138e6:	66 0f 6e 74 24 10    	movd   xmm6,DWORD PTR [rsp+0x10]
   138ec:	49 b8 80 ff ff ff ff 	movabs r8,0xffffffff80
   138f3:	00 00 00 
   138f6:	49 ba 00 00 00 00 00 	movabs r10,0x200000000000000
   138fd:	00 00 02 
   13900:	48 8b 7c 24 28       	mov    rdi,QWORD PTR [rsp+0x28]
   13905:	4d 85 e4             	test   r12,r12
   13908:	0f 88 e4 02 00 00    	js     13bf2 <NF_FID_36_112_114_111_100_117_99_116_46_110_101_97_114_101_115_116_+0x732>
   1390e:	4d 39 d4             	cmp    r12,r10
   13911:	0f 92 c0             	setb   al
   13914:	4c 89 e1             	mov    rcx,r12
   13917:	4c 21 c1             	and    rcx,r8
   1391a:	48 81 f9 80 81 10 03 	cmp    rcx,0x3108180
   13921:	0f 92 c1             	setb   cl
   13924:	08 c1                	or     cl,al
   13926:	0f 84 26 0a 00 00    	je     14352 <NF_FID_36_112_114_111_100_117_99_116_46_110_101_97_114_101_115_116_+0xe92>
   1392c:	f3 0f 10 25 84 e6 fe 	movss  xmm4,DWORD PTR [rip+0xfffffffffffee684]        # 1fb8 <_IO_stdin_used-0x20>
   13933:	ff 
   13934:	e9 1e fe ff ff       	jmp    13757 <NF_FID_36_112_114_111_100_117_99_116_46_110_101_97_114_101_115_116_+0x297>
   13939:	41 bc 03 00 00 00    	mov    r12d,0x3
   1393f:	f3 0f 10 0d 61 e6 fe 	movss  xmm1,DWORD PTR [rip+0xfffffffffffee661]        # 1fa8 <_IO_stdin_used-0x30>
   13946:	ff 
   13947:	f3 0f 10 15 3d e6 fe 	movss  xmm2,DWORD PTR [rip+0xfffffffffffee63d]        # 1f8c <_IO_stdin_used-0x4c>
   1394e:	ff 
   1394f:	e9 5a 08 00 00       	jmp    141ae <NF_FID_36_112_114_111_100_117_99_116_46_110_101_97_114_101_115_116_+0xcee>
   13954:	f3 0f 10 0d 60 e6 fe 	movss  xmm1,DWORD PTR [rip+0xfffffffffffee660]        # 1fbc <_IO_stdin_used-0x1c>
   1395b:	ff 
   1395c:	f3 0f 10 25 90 e6 fe 	movss  xmm4,DWORD PTR [rip+0xfffffffffffee690]        # 1ff4 <_IO_stdin_used+0x1c>
   13963:	ff 
   13964:	e9 3d 08 00 00       	jmp    141a6 <NF_FID_36_112_114_111_100_117_99_116_46_110_101_97_114_101_115_116_+0xce6>
   13969:	f3 0f 10 0d 37 e6 fe 	movss  xmm1,DWORD PTR [rip+0xfffffffffffee637]        # 1fa8 <_IO_stdin_used-0x30>
   13970:	ff 
   13971:	f3 0f 10 25 33 e6 fe 	movss  xmm4,DWORD PTR [rip+0xfffffffffffee633]        # 1fac <_IO_stdin_used-0x2c>
   13978:	ff 
   13979:	f3 0f 10 15 0b e6 fe 	movss  xmm2,DWORD PTR [rip+0xfffffffffffee60b]        # 1f8c <_IO_stdin_used-0x4c>
   13980:	ff 
   13981:	e9 28 08 00 00       	jmp    141ae <NF_FID_36_112_114_111_100_117_99_116_46_110_101_97_114_101_115_116_+0xcee>
   13986:	49 8d 54 24 f8       	lea    rdx,[r12-0x8]
   1398b:	48 b8 00 00 00 00 00 	movabs rax,0x7e00000000000000
   13992:	00 00 7e 
   13995:	48 85 c2             	test   rdx,rax
   13998:	0f 94 c0             	sete   al
   1399b:	48 89 d1             	mov    rcx,rdx
   1399e:	4c 21 c1             	and    rcx,r8
   139a1:	48 81 f9 80 81 10 03 	cmp    rcx,0x3108180
   139a8:	0f 92 c1             	setb   cl
   139ab:	08 c1                	or     cl,al
   139ad:	75 63                	jne    13a12 <NF_FID_36_112_114_111_100_117_99_116_46_110_101_97_114_101_115_116_+0x552>
   139af:	48 8b 74 24 18       	mov    rsi,QWORD PTR [rsp+0x18]
   139b4:	e8 27 38 ff ff       	call   71e0 <term_drop>
   139b9:	45 0f 57 ed          	xorps  xmm13,xmm13
   139bd:	f3 44 0f 10 25 aa e5 	movss  xmm12,DWORD PTR [rip+0xfffffffffffee5aa]        # 1f70 <_IO_stdin_used-0x68>
   139c4:	fe ff 
   139c6:	4c 8b 4c 24 20       	mov    r9,QWORD PTR [rsp+0x20]
   139cb:	f3 44 0f 10 9c 24 88 	movss  xmm11,DWORD PTR [rsp+0x88]
   139d2:	00 00 00 
   139d5:	f3 44 0f 10 94 24 80 	movss  xmm10,DWORD PTR [rsp+0x80]
   139dc:	00 00 00 
   139df:	f3 44 0f 10 4c 24 78 	movss  xmm9,DWORD PTR [rsp+0x78]
   139e6:	f3 44 0f 10 44 24 70 	movss  xmm8,DWORD PTR [rsp+0x70]
   139ed:	66 0f 6e 7c 24 0c    	movd   xmm7,DWORD PTR [rsp+0xc]
   139f3:	66 0f 6e 74 24 10    	movd   xmm6,DWORD PTR [rsp+0x10]
   139f9:	49 b8 80 ff ff ff ff 	movabs r8,0xffffffff80
   13a00:	00 00 00 
   13a03:	49 ba 00 00 00 00 00 	movabs r10,0x200000000000000
   13a0a:	00 00 02 
   13a0d:	48 8b 7c 24 28       	mov    rdi,QWORD PTR [rsp+0x28]
   13a12:	4d 85 e4             	test   r12,r12
   13a15:	0f 88 ae 03 00 00    	js     13dc9 <NF_FID_36_112_114_111_100_117_99_116_46_110_101_97_114_101_115_116_+0x909>
   13a1b:	4d 39 d4             	cmp    r12,r10
   13a1e:	0f 92 c0             	setb   al
   13a21:	4c 89 e1             	mov    rcx,r12
   13a24:	4c 21 c1             	and    rcx,r8
   13a27:	48 81 f9 80 81 10 03 	cmp    rcx,0x3108180
   13a2e:	0f 92 c1             	setb   cl
   13a31:	08 c1                	or     cl,al
   13a33:	0f 84 6e 09 00 00    	je     143a7 <NF_FID_36_112_114_111_100_117_99_116_46_110_101_97_114_101_115_116_+0xee7>
   13a39:	f3 0f 10 25 77 e5 fe 	movss  xmm4,DWORD PTR [rip+0xfffffffffffee577]        # 1fb8 <_IO_stdin_used-0x20>
   13a40:	ff 
   13a41:	e9 af fd ff ff       	jmp    137f5 <NF_FID_36_112_114_111_100_117_99_116_46_110_101_97_114_101_115_116_+0x335>
   13a46:	0f 28 c4             	movaps xmm0,xmm4
   13a49:	41 bc 04 00 00 00    	mov    r12d,0x4
   13a4f:	f3 0f 10 0d 49 e5 fe 	movss  xmm1,DWORD PTR [rip+0xfffffffffffee549]        # 1fa0 <_IO_stdin_used-0x38>
   13a56:	ff 
   13a57:	0f 28 e0             	movaps xmm4,xmm0
   13a5a:	e9 61 01 00 00       	jmp    13bc0 <NF_FID_36_112_114_111_100_117_99_116_46_110_101_97_114_101_115_116_+0x700>
   13a5f:	4d 8d 74 24 f8       	lea    r14,[r12-0x8]
   13a64:	4d 89 f7             	mov    r15,r14
   13a67:	48 b8 00 00 00 00 00 	movabs rax,0x7e00000000000000
   13a6e:	00 00 7e 
   13a71:	49 21 c7             	and    r15,rax
   13a74:	0f 94 c0             	sete   al
   13a77:	4c 89 f5             	mov    rbp,r14
   13a7a:	4c 21 c5             	and    rbp,r8
   13a7d:	48 81 fd 80 81 10 03 	cmp    rbp,0x3108180
   13a84:	0f 92 c1             	setb   cl
   13a87:	08 c1                	or     cl,al
   13a89:	f3 0f 11 64 24 14    	movss  DWORD PTR [rsp+0x14],xmm4
   13a8f:	75 6c                	jne    13afd <NF_FID_36_112_114_111_100_117_99_116_46_110_101_97_114_101_115_116_+0x63d>
   13a91:	48 8b 74 24 18       	mov    rsi,QWORD PTR [rsp+0x18]
   13a96:	4c 89 f2             	mov    rdx,r14
   13a99:	e8 42 37 ff ff       	call   71e0 <term_drop>
   13a9e:	f3 0f 10 64 24 14    	movss  xmm4,DWORD PTR [rsp+0x14]
   13aa4:	45 0f 57 ed          	xorps  xmm13,xmm13
   13aa8:	f3 44 0f 10 25 bf e4 	movss  xmm12,DWORD PTR [rip+0xfffffffffffee4bf]        # 1f70 <_IO_stdin_used-0x68>
   13aaf:	fe ff 
   13ab1:	4c 8b 4c 24 20       	mov    r9,QWORD PTR [rsp+0x20]
   13ab6:	f3 44 0f 10 9c 24 88 	movss  xmm11,DWORD PTR [rsp+0x88]
   13abd:	00 00 00 
   13ac0:	f3 44 0f 10 94 24 80 	movss  xmm10,DWORD PTR [rsp+0x80]
   13ac7:	00 00 00 
   13aca:	f3 44 0f 10 4c 24 78 	movss  xmm9,DWORD PTR [rsp+0x78]
   13ad1:	f3 44 0f 10 44 24 70 	movss  xmm8,DWORD PTR [rsp+0x70]
   13ad8:	66 0f 6e 7c 24 0c    	movd   xmm7,DWORD PTR [rsp+0xc]
   13ade:	66 0f 6e 74 24 10    	movd   xmm6,DWORD PTR [rsp+0x10]
   13ae4:	49 b8 80 ff ff ff ff 	movabs r8,0xffffffff80
   13aeb:	00 00 00 
   13aee:	49 ba 00 00 00 00 00 	movabs r10,0x200000000000000
   13af5:	00 00 02 
   13af8:	48 8b 7c 24 28       	mov    rdi,QWORD PTR [rsp+0x28]
   13afd:	4d 85 e4             	test   r12,r12
   13b00:	0f 88 ee 02 00 00    	js     13df4 <NF_FID_36_112_114_111_100_117_99_116_46_110_101_97_114_101_115_116_+0x934>
   13b06:	4d 39 d4             	cmp    r12,r10
   13b09:	0f 92 c0             	setb   al
   13b0c:	4c 89 e1             	mov    rcx,r12
   13b0f:	4c 21 c1             	and    rcx,r8
   13b12:	48 81 f9 80 81 10 03 	cmp    rcx,0x3108180
   13b19:	0f 92 c1             	setb   cl
   13b1c:	08 c1                	or     cl,al
   13b1e:	0f 85 ee 02 00 00    	jne    13e12 <NF_FID_36_112_114_111_100_117_99_116_46_110_101_97_114_101_115_116_+0x952>
   13b24:	48 8b 74 24 18       	mov    rsi,QWORD PTR [rsp+0x18]
   13b29:	4c 89 e2             	mov    rdx,r12
   13b2c:	b9 02 00 00 00       	mov    ecx,0x2
   13b31:	e8 c8 38 00 00       	call   173fe <rfc_wrap>
   13b36:	f3 0f 10 64 24 14    	movss  xmm4,DWORD PTR [rsp+0x14]
   13b3c:	45 0f 57 ed          	xorps  xmm13,xmm13
   13b40:	f3 44 0f 10 25 27 e4 	movss  xmm12,DWORD PTR [rip+0xfffffffffffee427]        # 1f70 <_IO_stdin_used-0x68>
   13b47:	fe ff 
   13b49:	f3 44 0f 10 9c 24 88 	movss  xmm11,DWORD PTR [rsp+0x88]
   13b50:	00 00 00 
   13b53:	f3 44 0f 10 94 24 80 	movss  xmm10,DWORD PTR [rsp+0x80]
   13b5a:	00 00 00 
   13b5d:	f3 44 0f 10 4c 24 78 	movss  xmm9,DWORD PTR [rsp+0x78]
   13b64:	f3 44 0f 10 44 24 70 	movss  xmm8,DWORD PTR [rsp+0x70]
   13b6b:	66 0f 6e 7c 24 0c    	movd   xmm7,DWORD PTR [rsp+0xc]
   13b71:	66 0f 6e 74 24 10    	movd   xmm6,DWORD PTR [rsp+0x10]
   13b77:	49 89 c4             	mov    r12,rax
   13b7a:	49 89 c6             	mov    r14,rax
   13b7d:	49 83 c6 f8          	add    r14,0xfffffffffffffff8
   13b81:	4d 89 f7             	mov    r15,r14
   13b84:	48 b8 00 00 00 00 00 	movabs rax,0x7e00000000000000
   13b8b:	00 00 7e 
   13b8e:	49 21 c7             	and    r15,rax
   13b91:	4c 89 f5             	mov    rbp,r14
   13b94:	4c 21 c5             	and    rbp,r8
   13b97:	e9 76 02 00 00       	jmp    13e12 <NF_FID_36_112_114_111_100_117_99_116_46_110_101_97_114_101_115_116_+0x952>
   13b9c:	0f 57 c9             	xorps  xmm1,xmm1
   13b9f:	f3 0f 10 15 21 e4 fe 	movss  xmm2,DWORD PTR [rip+0xfffffffffffee421]        # 1fc8 <_IO_stdin_used-0x10>
   13ba6:	ff 
   13ba7:	e9 88 03 00 00       	jmp    13f34 <NF_FID_36_112_114_111_100_117_99_116_46_110_101_97_114_101_115_116_+0xa74>
   13bac:	0f 28 d4             	movaps xmm2,xmm4
   13baf:	41 bc 05 00 00 00    	mov    r12d,0x5
   13bb5:	f3 0f 10 0d e3 e3 fe 	movss  xmm1,DWORD PTR [rip+0xfffffffffffee3e3]        # 1fa0 <_IO_stdin_used-0x38>
   13bbc:	ff 
   13bbd:	0f 28 e2             	movaps xmm4,xmm2
   13bc0:	f3 0f 10 15 2c e4 fe 	movss  xmm2,DWORD PTR [rip+0xfffffffffffee42c]        # 1ff4 <_IO_stdin_used+0x1c>
   13bc7:	ff 
   13bc8:	f3 0f 10 05 0c e4 fe 	movss  xmm0,DWORD PTR [rip+0xfffffffffffee40c]        # 1fdc <_IO_stdin_used+0x4>
   13bcf:	ff 
   13bd0:	e9 63 03 00 00       	jmp    13f38 <NF_FID_36_112_114_111_100_117_99_116_46_110_101_97_114_101_115_116_+0xa78>
   13bd5:	f3 0f 10 0d ef e3 fe 	movss  xmm1,DWORD PTR [rip+0xfffffffffffee3ef]        # 1fcc <_IO_stdin_used-0xc>
   13bdc:	ff 
   13bdd:	f3 0f 10 15 eb e3 fe 	movss  xmm2,DWORD PTR [rip+0xfffffffffffee3eb]        # 1fd0 <_IO_stdin_used-0x8>
   13be4:	ff 
   13be5:	f3 0f 10 05 fb e3 fe 	movss  xmm0,DWORD PTR [rip+0xfffffffffffee3fb]        # 1fe8 <_IO_stdin_used+0x10>
   13bec:	ff 
   13bed:	e9 46 03 00 00       	jmp    13f38 <NF_FID_36_112_114_111_100_117_99_116_46_110_101_97_114_101_115_116_+0xa78>
   13bf2:	4c 89 e0             	mov    rax,r12
   13bf5:	4c 21 c8             	and    rax,r9
   13bf8:	b9 01 00 00 00       	mov    ecx,0x1
   13bfd:	f0 0f c1 0c c7       	lock xadd DWORD PTR [rdi+rax*8],ecx
   13c02:	f7 d1                	not    ecx
   13c04:	f3 0f 10 25 ac e3 fe 	movss  xmm4,DWORD PTR [rip+0xfffffffffffee3ac]        # 1fb8 <_IO_stdin_used-0x20>
   13c0b:	ff 
   13c0c:	f7 c1 fe ff ff 00    	test   ecx,0xfffffe
   13c12:	0f 85 3f fb ff ff    	jne    13757 <NF_FID_36_112_114_111_100_117_99_116_46_110_101_97_114_101_115_116_+0x297>
   13c18:	e9 16 08 00 00       	jmp    14433 <NF_FID_36_112_114_111_100_117_99_116_46_110_101_97_114_101_115_116_+0xf73>
   13c1d:	0f 28 c4             	movaps xmm0,xmm4
   13c20:	41 bc 04 00 00 00    	mov    r12d,0x4
   13c26:	f3 0f 10 0d 72 e3 fe 	movss  xmm1,DWORD PTR [rip+0xfffffffffffee372]        # 1fa0 <_IO_stdin_used-0x38>
   13c2d:	ff 
   13c2e:	0f 28 e0             	movaps xmm4,xmm0
   13c31:	e9 61 01 00 00       	jmp    13d97 <NF_FID_36_112_114_111_100_117_99_116_46_110_101_97_114_101_115_116_+0x8d7>
   13c36:	4d 8d 6c 24 f8       	lea    r13,[r12-0x8]
   13c3b:	4c 89 eb             	mov    rbx,r13
   13c3e:	48 b8 00 00 00 00 00 	movabs rax,0x7e00000000000000
   13c45:	00 00 7e 
   13c48:	48 21 c3             	and    rbx,rax
   13c4b:	0f 94 c0             	sete   al
   13c4e:	4d 89 ef             	mov    r15,r13
   13c51:	4d 21 c7             	and    r15,r8
   13c54:	49 81 ff 80 81 10 03 	cmp    r15,0x3108180
   13c5b:	0f 92 c1             	setb   cl
   13c5e:	08 c1                	or     cl,al
   13c60:	f3 0f 11 64 24 14    	movss  DWORD PTR [rsp+0x14],xmm4
   13c66:	75 6c                	jne    13cd4 <NF_FID_36_112_114_111_100_117_99_116_46_110_101_97_114_101_115_116_+0x814>
   13c68:	48 8b 74 24 18       	mov    rsi,QWORD PTR [rsp+0x18]
   13c6d:	4c 89 ea             	mov    rdx,r13
   13c70:	e8 6b 35 ff ff       	call   71e0 <term_drop>
   13c75:	f3 0f 10 64 24 14    	movss  xmm4,DWORD PTR [rsp+0x14]
   13c7b:	45 0f 57 ed          	xorps  xmm13,xmm13
   13c7f:	f3 44 0f 10 25 e8 e2 	movss  xmm12,DWORD PTR [rip+0xfffffffffffee2e8]        # 1f70 <_IO_stdin_used-0x68>
   13c86:	fe ff 
   13c88:	4c 8b 4c 24 20       	mov    r9,QWORD PTR [rsp+0x20]
   13c8d:	f3 44 0f 10 9c 24 88 	movss  xmm11,DWORD PTR [rsp+0x88]
   13c94:	00 00 00 
   13c97:	f3 44 0f 10 94 24 80 	movss  xmm10,DWORD PTR [rsp+0x80]
   13c9e:	00 00 00 
   13ca1:	f3 44 0f 10 4c 24 78 	movss  xmm9,DWORD PTR [rsp+0x78]
   13ca8:	f3 44 0f 10 44 24 70 	movss  xmm8,DWORD PTR [rsp+0x70]
   13caf:	66 0f 6e 7c 24 0c    	movd   xmm7,DWORD PTR [rsp+0xc]
   13cb5:	66 0f 6e 74 24 10    	movd   xmm6,DWORD PTR [rsp+0x10]
   13cbb:	49 b8 80 ff ff ff ff 	movabs r8,0xffffffff80
   13cc2:	00 00 00 
   13cc5:	49 ba 00 00 00 00 00 	movabs r10,0x200000000000000
   13ccc:	00 00 02 
   13ccf:	48 8b 7c 24 28       	mov    rdi,QWORD PTR [rsp+0x28]
   13cd4:	4d 85 e4             	test   r12,r12
   13cd7:	0f 88 91 03 00 00    	js     1406e <NF_FID_36_112_114_111_100_117_99_116_46_110_101_97_114_101_115_116_+0xbae>
   13cdd:	4d 39 d4             	cmp    r12,r10
   13ce0:	0f 92 c0             	setb   al
   13ce3:	4c 89 e1             	mov    rcx,r12
   13ce6:	4c 21 c1             	and    rcx,r8
   13ce9:	48 81 f9 80 81 10 03 	cmp    rcx,0x3108180
   13cf0:	0f 92 c1             	setb   cl
   13cf3:	08 c1                	or     cl,al
   13cf5:	0f 85 91 03 00 00    	jne    1408c <NF_FID_36_112_114_111_100_117_99_116_46_110_101_97_114_101_115_116_+0xbcc>
   13cfb:	48 8b 74 24 18       	mov    rsi,QWORD PTR [rsp+0x18]
   13d00:	4c 89 e2             	mov    rdx,r12
   13d03:	b9 02 00 00 00       	mov    ecx,0x2
   13d08:	e8 f1 36 00 00       	call   173fe <rfc_wrap>
   13d0d:	f3 0f 10 64 24 14    	movss  xmm4,DWORD PTR [rsp+0x14]
   13d13:	45 0f 57 ed          	xorps  xmm13,xmm13
   13d17:	f3 44 0f 10 25 50 e2 	movss  xmm12,DWORD PTR [rip+0xfffffffffffee250]        # 1f70 <_IO_stdin_used-0x68>
   13d1e:	fe ff 
   13d20:	f3 44 0f 10 9c 24 88 	movss  xmm11,DWORD PTR [rsp+0x88]
   13d27:	00 00 00 
   13d2a:	f3 44 0f 10 94 24 80 	movss  xmm10,DWORD PTR [rsp+0x80]
   13d31:	00 00 00 
   13d34:	f3 44 0f 10 4c 24 78 	movss  xmm9,DWORD PTR [rsp+0x78]
   13d3b:	f3 44 0f 10 44 24 70 	movss  xmm8,DWORD PTR [rsp+0x70]
   13d42:	66 0f 6e 7c 24 0c    	movd   xmm7,DWORD PTR [rsp+0xc]
   13d48:	66 0f 6e 74 24 10    	movd   xmm6,DWORD PTR [rsp+0x10]
   13d4e:	49 89 c4             	mov    r12,rax
   13d51:	49 89 c5             	mov    r13,rax
   13d54:	49 83 c5 f8          	add    r13,0xfffffffffffffff8
   13d58:	4c 89 eb             	mov    rbx,r13
   13d5b:	48 b8 00 00 00 00 00 	movabs rax,0x7e00000000000000
   13d62:	00 00 7e 
   13d65:	48 21 c3             	and    rbx,rax
   13d68:	4d 89 ef             	mov    r15,r13
   13d6b:	4d 21 c7             	and    r15,r8
   13d6e:	e9 19 03 00 00       	jmp    1408c <NF_FID_36_112_114_111_100_117_99_116_46_110_101_97_114_101_115_116_+0xbcc>
   13d73:	0f 57 c9             	xorps  xmm1,xmm1
   13d76:	f3 0f 10 15 4a e2 fe 	movss  xmm2,DWORD PTR [rip+0xfffffffffffee24a]        # 1fc8 <_IO_stdin_used-0x10>
   13d7d:	ff 
   13d7e:	e9 2b 04 00 00       	jmp    141ae <NF_FID_36_112_114_111_100_117_99_116_46_110_101_97_114_101_115_116_+0xcee>
   13d83:	0f 28 d4             	movaps xmm2,xmm4
   13d86:	41 bc 05 00 00 00    	mov    r12d,0x5
   13d8c:	f3 0f 10 0d 0c e2 fe 	movss  xmm1,DWORD PTR [rip+0xfffffffffffee20c]        # 1fa0 <_IO_stdin_used-0x38>
   13d93:	ff 
   13d94:	0f 28 e2             	movaps xmm4,xmm2
   13d97:	f3 0f 10 15 55 e2 fe 	movss  xmm2,DWORD PTR [rip+0xfffffffffffee255]        # 1ff4 <_IO_stdin_used+0x1c>
   13d9e:	ff 
   13d9f:	f3 0f 10 05 35 e2 fe 	movss  xmm0,DWORD PTR [rip+0xfffffffffffee235]        # 1fdc <_IO_stdin_used+0x4>
   13da6:	ff 
   13da7:	e9 06 04 00 00       	jmp    141b2 <NF_FID_36_112_114_111_100_117_99_116_46_110_101_97_114_101_115_116_+0xcf2>
   13dac:	f3 0f 10 0d 18 e2 fe 	movss  xmm1,DWORD PTR [rip+0xfffffffffffee218]        # 1fcc <_IO_stdin_used-0xc>
   13db3:	ff 
   13db4:	f3 0f 10 15 14 e2 fe 	movss  xmm2,DWORD PTR [rip+0xfffffffffffee214]        # 1fd0 <_IO_stdin_used-0x8>
   13dbb:	ff 
   13dbc:	f3 0f 10 05 24 e2 fe 	movss  xmm0,DWORD PTR [rip+0xfffffffffffee224]        # 1fe8 <_IO_stdin_used+0x10>
   13dc3:	ff 
   13dc4:	e9 e9 03 00 00       	jmp    141b2 <NF_FID_36_112_114_111_100_117_99_116_46_110_101_97_114_101_115_116_+0xcf2>
   13dc9:	4c 89 e0             	mov    rax,r12
   13dcc:	4c 21 c8             	and    rax,r9
   13dcf:	b9 01 00 00 00       	mov    ecx,0x1
   13dd4:	f0 0f c1 0c c7       	lock xadd DWORD PTR [rdi+rax*8],ecx
   13dd9:	f7 d1                	not    ecx
   13ddb:	f3 0f 10 25 d5 e1 fe 	movss  xmm4,DWORD PTR [rip+0xfffffffffffee1d5]        # 1fb8 <_IO_stdin_used-0x20>
   13de2:	ff 
   13de3:	f7 c1 fe ff ff 00    	test   ecx,0xfffffe
   13de9:	0f 85 06 fa ff ff    	jne    137f5 <NF_FID_36_112_114_111_100_117_99_116_46_110_101_97_114_101_115_116_+0x335>
   13def:	e9 3f 06 00 00       	jmp    14433 <NF_FID_36_112_114_111_100_117_99_116_46_110_101_97_114_101_115_116_+0xf73>
   13df4:	4c 89 e0             	mov    rax,r12
   13df7:	4c 21 c8             	and    rax,r9
   13dfa:	b9 01 00 00 00       	mov    ecx,0x1
   13dff:	f0 0f c1 0c c7       	lock xadd DWORD PTR [rdi+rax*8],ecx
   13e04:	f7 d1                	not    ecx
   13e06:	f7 c1 fe ff ff 00    	test   ecx,0xfffffe
   13e0c:	0f 84 21 06 00 00    	je     14433 <NF_FID_36_112_114_111_100_117_99_116_46_110_101_97_114_101_115_116_+0xf73>
   13e12:	4d 85 ff             	test   r15,r15
   13e15:	0f 94 c0             	sete   al
   13e18:	48 81 fd 80 81 10 03 	cmp    rbp,0x3108180
   13e1f:	0f 92 c1             	setb   cl
   13e22:	08 c1                	or     cl,al
   13e24:	75 6c                	jne    13e92 <NF_FID_36_112_114_111_100_117_99_116_46_110_101_97_114_101_115_116_+0x9d2>
   13e26:	48 8b 74 24 18       	mov    rsi,QWORD PTR [rsp+0x18]
   13e2b:	4c 89 f2             	mov    rdx,r14
   13e2e:	e8 ad 33 ff ff       	call   71e0 <term_drop>
   13e33:	f3 0f 10 64 24 14    	movss  xmm4,DWORD PTR [rsp+0x14]
   13e39:	45 0f 57 ed          	xorps  xmm13,xmm13
   13e3d:	f3 44 0f 10 25 2a e1 	movss  xmm12,DWORD PTR [rip+0xfffffffffffee12a]        # 1f70 <_IO_stdin_used-0x68>
   13e44:	fe ff 
   13e46:	4c 8b 4c 24 20       	mov    r9,QWORD PTR [rsp+0x20]
   13e4b:	f3 44 0f 10 9c 24 88 	movss  xmm11,DWORD PTR [rsp+0x88]
   13e52:	00 00 00 
   13e55:	f3 44 0f 10 94 24 80 	movss  xmm10,DWORD PTR [rsp+0x80]
   13e5c:	00 00 00 
   13e5f:	f3 44 0f 10 4c 24 78 	movss  xmm9,DWORD PTR [rsp+0x78]
   13e66:	f3 44 0f 10 44 24 70 	movss  xmm8,DWORD PTR [rsp+0x70]
   13e6d:	66 0f 6e 7c 24 0c    	movd   xmm7,DWORD PTR [rsp+0xc]
   13e73:	66 0f 6e 74 24 10    	movd   xmm6,DWORD PTR [rsp+0x10]
   13e79:	49 b8 80 ff ff ff ff 	movabs r8,0xffffffff80
   13e80:	00 00 00 
   13e83:	49 ba 00 00 00 00 00 	movabs r10,0x200000000000000
   13e8a:	00 00 02 
   13e8d:	48 8b 7c 24 28       	mov    rdi,QWORD PTR [rsp+0x28]
   13e92:	49 8d 54 24 f8       	lea    rdx,[r12-0x8]
   13e97:	48 b8 00 00 00 00 00 	movabs rax,0x7e00000000000000
   13e9e:	00 00 7e 
   13ea1:	48 85 c2             	test   rdx,rax
   13ea4:	0f 94 c0             	sete   al
   13ea7:	48 89 d1             	mov    rcx,rdx
   13eaa:	4c 21 c1             	and    rcx,r8
   13ead:	48 81 f9 80 81 10 03 	cmp    rcx,0x3108180
   13eb4:	0f 92 c1             	setb   cl
   13eb7:	08 c1                	or     cl,al
   13eb9:	75 69                	jne    13f24 <NF_FID_36_112_114_111_100_117_99_116_46_110_101_97_114_101_115_116_+0xa64>
   13ebb:	48 8b 74 24 18       	mov    rsi,QWORD PTR [rsp+0x18]
   13ec0:	e8 1b 33 ff ff       	call   71e0 <term_drop>
   13ec5:	f3 0f 10 64 24 14    	movss  xmm4,DWORD PTR [rsp+0x14]
   13ecb:	45 0f 57 ed          	xorps  xmm13,xmm13
   13ecf:	f3 44 0f 10 25 98 e0 	movss  xmm12,DWORD PTR [rip+0xfffffffffffee098]        # 1f70 <_IO_stdin_used-0x68>
   13ed6:	fe ff 
   13ed8:	4c 8b 4c 24 20       	mov    r9,QWORD PTR [rsp+0x20]
   13edd:	f3 44 0f 10 9c 24 88 	movss  xmm11,DWORD PTR [rsp+0x88]
   13ee4:	00 00 00 
   13ee7:	f3 44 0f 10 94 24 80 	movss  xmm10,DWORD PTR [rsp+0x80]
   13eee:	00 00 00 
   13ef1:	f3 44 0f 10 4c 24 78 	movss  xmm9,DWORD PTR [rsp+0x78]
   13ef8:	f3 44 0f 10 44 24 70 	movss  xmm8,DWORD PTR [rsp+0x70]
   13eff:	66 0f 6e 7c 24 0c    	movd   xmm7,DWORD PTR [rsp+0xc]
   13f05:	66 0f 6e 74 24 10    	movd   xmm6,DWORD PTR [rsp+0x10]
   13f0b:	49 b8 80 ff ff ff ff 	movabs r8,0xffffffff80
   13f12:	00 00 00 
   13f15:	49 ba 00 00 00 00 00 	movabs r10,0x200000000000000
   13f1c:	00 00 02 
   13f1f:	48 8b 7c 24 28       	mov    rdi,QWORD PTR [rsp+0x28]
   13f24:	f3 0f 10 0d 90 e0 fe 	movss  xmm1,DWORD PTR [rip+0xfffffffffffee090]        # 1fbc <_IO_stdin_used-0x1c>
   13f2b:	ff 
   13f2c:	f3 0f 10 15 48 e0 fe 	movss  xmm2,DWORD PTR [rip+0xfffffffffffee048]        # 1f7c <_IO_stdin_used-0x5c>
   13f33:	ff 
   13f34:	41 0f 28 c4          	movaps xmm0,xmm12
   13f38:	66 0f 6f de          	movdqa xmm3,xmm6
   13f3c:	f3 0f 5c dc          	subss  xmm3,xmm4
   13f40:	66 0f 6f e7          	movdqa xmm4,xmm7
   13f44:	f3 0f 5c e1          	subss  xmm4,xmm1
   13f48:	41 0f 28 c8          	movaps xmm1,xmm8
   13f4c:	f3 0f 5c ca          	subss  xmm1,xmm2
   13f50:	0f 28 d3             	movaps xmm2,xmm3
   13f53:	f3 41 0f 59 d1       	mulss  xmm2,xmm9
   13f58:	0f 28 ec             	movaps xmm5,xmm4
   13f5b:	f3 41 0f 59 ea       	mulss  xmm5,xmm10
   13f60:	f3 0f 58 ea          	addss  xmm5,xmm2
   13f64:	44 0f 28 f1          	movaps xmm14,xmm1
   13f68:	f3 45 0f 59 f3       	mulss  xmm14,xmm11
   13f6d:	f3 44 0f 58 f5       	addss  xmm14,xmm5
   13f72:	41 0f 28 d6          	movaps xmm2,xmm14
   13f76:	f3 41 0f 59 d6       	mulss  xmm2,xmm14
   13f7b:	f3 0f 59 db          	mulss  xmm3,xmm3
   13f7f:	f3 0f 59 e4          	mulss  xmm4,xmm4
   13f83:	f3 0f 58 e3          	addss  xmm4,xmm3
   13f87:	f3 0f 59 c9          	mulss  xmm1,xmm1
   13f8b:	f3 0f 58 cc          	addss  xmm1,xmm4
   13f8f:	f3 0f 5c c1          	subss  xmm0,xmm1
   13f93:	f3 0f 58 c2          	addss  xmm0,xmm2
   13f97:	41 bf 28 6b 6e 4e    	mov    r15d,0x4e6e6b28
   13f9d:	44 0f 2e e8          	ucomiss xmm13,xmm0
   13fa1:	0f 87 96 00 00 00    	ja     1403d <NF_FID_36_112_114_111_100_117_99_116_46_110_101_97_114_101_115_116_+0xb7d>
   13fa7:	41 0f 2e c5          	ucomiss xmm0,xmm13
   13fab:	72 06                	jb     13fb3 <NF_FID_36_112_114_111_100_117_99_116_46_110_101_97_114_101_115_116_+0xaf3>
   13fad:	f3 0f 51 c0          	sqrtss xmm0,xmm0
   13fb1:	eb 6c                	jmp    1401f <NF_FID_36_112_114_111_100_117_99_116_46_110_101_97_114_101_115_116_+0xb5f>
   13fb3:	f3 44 0f 11 74 24 14 	movss  DWORD PTR [rsp+0x14],xmm14
   13fba:	e8 61 43 00 00       	call   18320 <sqrtf@plt>
   13fbf:	f3 44 0f 10 74 24 14 	movss  xmm14,DWORD PTR [rsp+0x14]
   13fc6:	45 0f 57 ed          	xorps  xmm13,xmm13
   13fca:	f3 44 0f 10 25 9d df 	movss  xmm12,DWORD PTR [rip+0xfffffffffffedf9d]        # 1f70 <_IO_stdin_used-0x68>
   13fd1:	fe ff 
   13fd3:	4c 8b 4c 24 20       	mov    r9,QWORD PTR [rsp+0x20]
   13fd8:	f3 44 0f 10 9c 24 88 	movss  xmm11,DWORD PTR [rsp+0x88]
   13fdf:	00 00 00 
   13fe2:	f3 44 0f 10 94 24 80 	movss  xmm10,DWORD PTR [rsp+0x80]
   13fe9:	00 00 00 
   13fec:	f3 44 0f 10 4c 24 78 	movss  xmm9,DWORD PTR [rsp+0x78]
   13ff3:	f3 44 0f 10 44 24 70 	movss  xmm8,DWORD PTR [rsp+0x70]
   13ffa:	66 0f 6e 7c 24 0c    	movd   xmm7,DWORD PTR [rsp+0xc]
   14000:	66 0f 6e 74 24 10    	movd   xmm6,DWORD PTR [rsp+0x10]
   14006:	49 b8 80 ff ff ff ff 	movabs r8,0xffffffff80
   1400d:	00 00 00 
   14010:	49 ba 00 00 00 00 00 	movabs r10,0x200000000000000
   14017:	00 00 02 
   1401a:	48 8b 7c 24 28       	mov    rdi,QWORD PTR [rsp+0x28]
   1401f:	0f 57 c9             	xorps  xmm1,xmm1
   14022:	f3 41 0f 5c ce       	subss  xmm1,xmm14
   14027:	f3 0f 5c c8          	subss  xmm1,xmm0
   1402b:	f3 0f 10 05 c5 df fe 	movss  xmm0,DWORD PTR [rip+0xfffffffffffedfc5]        # 1ff8 <_IO_stdin_used+0x20>
   14032:	ff 
   14033:	0f 2e c1             	ucomiss xmm0,xmm1
   14036:	77 05                	ja     1403d <NF_FID_36_112_114_111_100_117_99_116_46_110_101_97_114_101_115_116_+0xb7d>
   14038:	66 41 0f 7e cf       	movd   r15d,xmm1
   1403d:	4d 85 e4             	test   r12,r12
   14040:	0f 88 3a f5 ff ff    	js     13580 <NF_FID_36_112_114_111_100_117_99_116_46_110_101_97_114_101_115_116_+0xc0>
   14046:	4d 39 d4             	cmp    r12,r10
   14049:	0f 92 c0             	setb   al
   1404c:	4c 89 e1             	mov    rcx,r12
   1404f:	4c 21 c1             	and    rcx,r8
   14052:	48 81 f9 80 81 10 03 	cmp    rcx,0x3108180
   14059:	0f 92 c1             	setb   cl
   1405c:	08 c1                	or     cl,al
   1405e:	45 89 ee             	mov    r14d,r13d
   14061:	89 dd                	mov    ebp,ebx
   14063:	0f 85 3a f5 ff ff    	jne    135a3 <NF_FID_36_112_114_111_100_117_99_116_46_110_101_97_114_101_115_116_+0xe3>
   14069:	e9 6c 02 00 00       	jmp    142da <NF_FID_36_112_114_111_100_117_99_116_46_110_101_97_114_101_115_116_+0xe1a>
   1406e:	4c 89 e0             	mov    rax,r12
   14071:	4c 21 c8             	and    rax,r9
   14074:	b9 01 00 00 00       	mov    ecx,0x1
   14079:	f0 0f c1 0c c7       	lock xadd DWORD PTR [rdi+rax*8],ecx
   1407e:	f7 d1                	not    ecx
   14080:	f7 c1 fe ff ff 00    	test   ecx,0xfffffe
   14086:	0f 84 a7 03 00 00    	je     14433 <NF_FID_36_112_114_111_100_117_99_116_46_110_101_97_114_101_115_116_+0xf73>
   1408c:	48 85 db             	test   rbx,rbx
   1408f:	0f 94 c0             	sete   al
   14092:	49 81 ff 80 81 10 03 	cmp    r15,0x3108180
   14099:	0f 92 c1             	setb   cl
   1409c:	08 c1                	or     cl,al
   1409e:	75 6c                	jne    1410c <NF_FID_36_112_114_111_100_117_99_116_46_110_101_97_114_101_115_116_+0xc4c>
   140a0:	48 8b 74 24 18       	mov    rsi,QWORD PTR [rsp+0x18]
   140a5:	4c 89 ea             	mov    rdx,r13
   140a8:	e8 33 31 ff ff       	call   71e0 <term_drop>
   140ad:	f3 0f 10 64 24 14    	movss  xmm4,DWORD PTR [rsp+0x14]
   140b3:	45 0f 57 ed          	xorps  xmm13,xmm13
   140b7:	f3 44 0f 10 25 b0 de 	movss  xmm12,DWORD PTR [rip+0xfffffffffffedeb0]        # 1f70 <_IO_stdin_used-0x68>
   140be:	fe ff 
   140c0:	4c 8b 4c 24 20       	mov    r9,QWORD PTR [rsp+0x20]
   140c5:	f3 44 0f 10 9c 24 88 	movss  xmm11,DWORD PTR [rsp+0x88]
   140cc:	00 00 00 
   140cf:	f3 44 0f 10 94 24 80 	movss  xmm10,DWORD PTR [rsp+0x80]
   140d6:	00 00 00 
   140d9:	f3 44 0f 10 4c 24 78 	movss  xmm9,DWORD PTR [rsp+0x78]
   140e0:	f3 44 0f 10 44 24 70 	movss  xmm8,DWORD PTR [rsp+0x70]
   140e7:	66 0f 6e 7c 24 0c    	movd   xmm7,DWORD PTR [rsp+0xc]
   140ed:	66 0f 6e 74 24 10    	movd   xmm6,DWORD PTR [rsp+0x10]
   140f3:	49 b8 80 ff ff ff ff 	movabs r8,0xffffffff80
   140fa:	00 00 00 
   140fd:	49 ba 00 00 00 00 00 	movabs r10,0x200000000000000
   14104:	00 00 02 
   14107:	48 8b 7c 24 28       	mov    rdi,QWORD PTR [rsp+0x28]
   1410c:	49 8d 54 24 f8       	lea    rdx,[r12-0x8]
   14111:	48 b8 00 00 00 00 00 	movabs rax,0x7e00000000000000
   14118:	00 00 7e 
   1411b:	48 85 c2             	test   rdx,rax
   1411e:	0f 94 c0             	sete   al
   14121:	48 89 d1             	mov    rcx,rdx
   14124:	4c 21 c1             	and    rcx,r8
   14127:	48 81 f9 80 81 10 03 	cmp    rcx,0x3108180
   1412e:	0f 92 c1             	setb   cl
   14131:	08 c1                	or     cl,al
   14133:	75 69                	jne    1419e <NF_FID_36_112_114_111_100_117_99_116_46_110_101_97_114_101_115_116_+0xcde>
   14135:	48 8b 74 24 18       	mov    rsi,QWORD PTR [rsp+0x18]
   1413a:	e8 a1 30 ff ff       	call   71e0 <term_drop>
   1413f:	f3 0f 10 64 24 14    	movss  xmm4,DWORD PTR [rsp+0x14]
   14145:	45 0f 57 ed          	xorps  xmm13,xmm13
   14149:	f3 44 0f 10 25 1e de 	movss  xmm12,DWORD PTR [rip+0xfffffffffffede1e]        # 1f70 <_IO_stdin_used-0x68>
   14150:	fe ff 
   14152:	4c 8b 4c 24 20       	mov    r9,QWORD PTR [rsp+0x20]
   14157:	f3 44 0f 10 9c 24 88 	movss  xmm11,DWORD PTR [rsp+0x88]
   1415e:	00 00 00 
   14161:	f3 44 0f 10 94 24 80 	movss  xmm10,DWORD PTR [rsp+0x80]
   14168:	00 00 00 
   1416b:	f3 44 0f 10 4c 24 78 	movss  xmm9,DWORD PTR [rsp+0x78]
   14172:	f3 44 0f 10 44 24 70 	movss  xmm8,DWORD PTR [rsp+0x70]
   14179:	66 0f 6e 7c 24 0c    	movd   xmm7,DWORD PTR [rsp+0xc]
   1417f:	66 0f 6e 74 24 10    	movd   xmm6,DWORD PTR [rsp+0x10]
   14185:	49 b8 80 ff ff ff ff 	movabs r8,0xffffffff80
   1418c:	00 00 00 
   1418f:	49 ba 00 00 00 00 00 	movabs r10,0x200000000000000
   14196:	00 00 02 
   14199:	48 8b 7c 24 28       	mov    rdi,QWORD PTR [rsp+0x28]
   1419e:	f3 0f 10 0d 16 de fe 	movss  xmm1,DWORD PTR [rip+0xfffffffffffede16]        # 1fbc <_IO_stdin_used-0x1c>
   141a5:	ff 
   141a6:	f3 0f 10 15 ce dd fe 	movss  xmm2,DWORD PTR [rip+0xfffffffffffeddce]        # 1f7c <_IO_stdin_used-0x5c>
   141ad:	ff 
   141ae:	41 0f 28 c4          	movaps xmm0,xmm12
   141b2:	66 0f 6f de          	movdqa xmm3,xmm6
   141b6:	f3 0f 5c dc          	subss  xmm3,xmm4
   141ba:	66 0f 6f e7          	movdqa xmm4,xmm7
   141be:	f3 0f 5c e1          	subss  xmm4,xmm1
   141c2:	41 0f 28 c8          	movaps xmm1,xmm8
   141c6:	f3 0f 5c ca          	subss  xmm1,xmm2
   141ca:	0f 28 d3             	movaps xmm2,xmm3
   141cd:	f3 41 0f 59 d1       	mulss  xmm2,xmm9
   141d2:	0f 28 ec             	movaps xmm5,xmm4
   141d5:	f3 41 0f 59 ea       	mulss  xmm5,xmm10
   141da:	f3 0f 58 ea          	addss  xmm5,xmm2
   141de:	44 0f 28 f1          	movaps xmm14,xmm1
   141e2:	f3 45 0f 59 f3       	mulss  xmm14,xmm11
   141e7:	f3 44 0f 58 f5       	addss  xmm14,xmm5
   141ec:	41 0f 28 d6          	movaps xmm2,xmm14
   141f0:	f3 41 0f 59 d6       	mulss  xmm2,xmm14
   141f5:	f3 0f 59 db          	mulss  xmm3,xmm3
   141f9:	f3 0f 59 e4          	mulss  xmm4,xmm4
   141fd:	f3 0f 58 e3          	addss  xmm4,xmm3
   14201:	f3 0f 59 c9          	mulss  xmm1,xmm1
   14205:	f3 0f 58 cc          	addss  xmm1,xmm4
   14209:	f3 0f 5c c1          	subss  xmm0,xmm1
   1420d:	f3 0f 58 c2          	addss  xmm0,xmm2
   14211:	41 bf 28 6b 6e 4e    	mov    r15d,0x4e6e6b28
   14217:	44 0f 2e e8          	ucomiss xmm13,xmm0
   1421b:	0f 87 96 00 00 00    	ja     142b7 <NF_FID_36_112_114_111_100_117_99_116_46_110_101_97_114_101_115_116_+0xdf7>
   14221:	41 0f 2e c5          	ucomiss xmm0,xmm13
   14225:	72 06                	jb     1422d <NF_FID_36_112_114_111_100_117_99_116_46_110_101_97_114_101_115_116_+0xd6d>
   14227:	f3 0f 51 c0          	sqrtss xmm0,xmm0
   1422b:	eb 6c                	jmp    14299 <NF_FID_36_112_114_111_100_117_99_116_46_110_101_97_114_101_115_116_+0xdd9>
   1422d:	f3 44 0f 11 74 24 14 	movss  DWORD PTR [rsp+0x14],xmm14
   14234:	e8 e7 40 00 00       	call   18320 <sqrtf@plt>
   14239:	f3 44 0f 10 74 24 14 	movss  xmm14,DWORD PTR [rsp+0x14]
   14240:	45 0f 57 ed          	xorps  xmm13,xmm13
   14244:	f3 44 0f 10 25 23 dd 	movss  xmm12,DWORD PTR [rip+0xfffffffffffedd23]        # 1f70 <_IO_stdin_used-0x68>
   1424b:	fe ff 
   1424d:	4c 8b 4c 24 20       	mov    r9,QWORD PTR [rsp+0x20]
   14252:	f3 44 0f 10 9c 24 88 	movss  xmm11,DWORD PTR [rsp+0x88]
   14259:	00 00 00 
   1425c:	f3 44 0f 10 94 24 80 	movss  xmm10,DWORD PTR [rsp+0x80]
   14263:	00 00 00 
   14266:	f3 44 0f 10 4c 24 78 	movss  xmm9,DWORD PTR [rsp+0x78]
   1426d:	f3 44 0f 10 44 24 70 	movss  xmm8,DWORD PTR [rsp+0x70]
   14274:	66 0f 6e 7c 24 0c    	movd   xmm7,DWORD PTR [rsp+0xc]
   1427a:	66 0f 6e 74 24 10    	movd   xmm6,DWORD PTR [rsp+0x10]
   14280:	49 b8 80 ff ff ff ff 	movabs r8,0xffffffff80
   14287:	00 00 00 
   1428a:	49 ba 00 00 00 00 00 	movabs r10,0x200000000000000
   14291:	00 00 02 
   14294:	48 8b 7c 24 28       	mov    rdi,QWORD PTR [rsp+0x28]
   14299:	0f 57 c9             	xorps  xmm1,xmm1
   1429c:	f3 41 0f 5c ce       	subss  xmm1,xmm14
   142a1:	f3 0f 5c c8          	subss  xmm1,xmm0
   142a5:	f3 0f 10 05 4b dd fe 	movss  xmm0,DWORD PTR [rip+0xfffffffffffedd4b]        # 1ff8 <_IO_stdin_used+0x20>
   142ac:	ff 
   142ad:	0f 2e c1             	ucomiss xmm0,xmm1
   142b0:	77 05                	ja     142b7 <NF_FID_36_112_114_111_100_117_99_116_46_110_101_97_114_101_115_116_+0xdf7>
   142b2:	66 41 0f 7e cf       	movd   r15d,xmm1
   142b7:	4d 85 e4             	test   r12,r12
   142ba:	78 73                	js     1432f <NF_FID_36_112_114_111_100_117_99_116_46_110_101_97_114_101_115_116_+0xe6f>
   142bc:	4d 39 d4             	cmp    r12,r10
   142bf:	0f 92 c0             	setb   al
   142c2:	4c 89 e1             	mov    rcx,r12
   142c5:	4c 21 c1             	and    rcx,r8
   142c8:	48 81 f9 80 81 10 03 	cmp    rcx,0x3108180
   142cf:	0f 92 c1             	setb   cl
   142d2:	08 c1                	or     cl,al
   142d4:	0f 85 c9 f2 ff ff    	jne    135a3 <NF_FID_36_112_114_111_100_117_99_116_46_110_101_97_114_101_115_116_+0xe3>
   142da:	48 8b 74 24 18       	mov    rsi,QWORD PTR [rsp+0x18]
   142df:	4c 89 e2             	mov    rdx,r12
   142e2:	b9 02 00 00 00       	mov    ecx,0x2
   142e7:	e8 12 31 00 00       	call   173fe <rfc_wrap>
   142ec:	45 0f 57 ed          	xorps  xmm13,xmm13
   142f0:	f3 44 0f 10 25 77 dc 	movss  xmm12,DWORD PTR [rip+0xfffffffffffedc77]        # 1f70 <_IO_stdin_used-0x68>
   142f7:	fe ff 
   142f9:	f3 44 0f 10 9c 24 88 	movss  xmm11,DWORD PTR [rsp+0x88]
   14300:	00 00 00 
   14303:	f3 44 0f 10 94 24 80 	movss  xmm10,DWORD PTR [rsp+0x80]
   1430a:	00 00 00 
   1430d:	f3 44 0f 10 4c 24 78 	movss  xmm9,DWORD PTR [rsp+0x78]
   14314:	f3 44 0f 10 44 24 70 	movss  xmm8,DWORD PTR [rsp+0x70]
   1431b:	66 0f 6e 7c 24 0c    	movd   xmm7,DWORD PTR [rsp+0xc]
   14321:	66 0f 6e 74 24 10    	movd   xmm6,DWORD PTR [rsp+0x10]
   14327:	49 89 c4             	mov    r12,rax
   1432a:	e9 74 f2 ff ff       	jmp    135a3 <NF_FID_36_112_114_111_100_117_99_116_46_110_101_97_114_101_115_116_+0xe3>
   1432f:	4c 89 e0             	mov    rax,r12
   14332:	4c 21 c8             	and    rax,r9
   14335:	b9 01 00 00 00       	mov    ecx,0x1
   1433a:	f0 0f c1 0c c7       	lock xadd DWORD PTR [rdi+rax*8],ecx
   1433f:	f7 d1                	not    ecx
   14341:	f7 c1 fe ff ff 00    	test   ecx,0xfffffe
   14347:	0f 85 56 f2 ff ff    	jne    135a3 <NF_FID_36_112_114_111_100_117_99_116_46_110_101_97_114_101_115_116_+0xe3>
   1434d:	e9 e1 00 00 00       	jmp    14433 <NF_FID_36_112_114_111_100_117_99_116_46_110_101_97_114_101_115_116_+0xf73>
   14352:	48 8b 74 24 18       	mov    rsi,QWORD PTR [rsp+0x18]
   14357:	4c 89 e2             	mov    rdx,r12
   1435a:	b9 02 00 00 00       	mov    ecx,0x2
   1435f:	e8 9a 30 00 00       	call   173fe <rfc_wrap>
   14364:	45 0f 57 ed          	xorps  xmm13,xmm13
   14368:	f3 44 0f 10 25 ff db 	movss  xmm12,DWORD PTR [rip+0xfffffffffffedbff]        # 1f70 <_IO_stdin_used-0x68>
   1436f:	fe ff 
   14371:	f3 44 0f 10 9c 24 88 	movss  xmm11,DWORD PTR [rsp+0x88]
   14378:	00 00 00 
   1437b:	f3 44 0f 10 94 24 80 	movss  xmm10,DWORD PTR [rsp+0x80]
   14382:	00 00 00 
   14385:	f3 44 0f 10 4c 24 78 	movss  xmm9,DWORD PTR [rsp+0x78]
   1438c:	f3 44 0f 10 44 24 70 	movss  xmm8,DWORD PTR [rsp+0x70]
   14393:	66 0f 6e 7c 24 0c    	movd   xmm7,DWORD PTR [rsp+0xc]
   14399:	66 0f 6e 74 24 10    	movd   xmm6,DWORD PTR [rsp+0x10]
   1439f:	49 89 c4             	mov    r12,rax
   143a2:	e9 85 f5 ff ff       	jmp    1392c <NF_FID_36_112_114_111_100_117_99_116_46_110_101_97_114_101_115_116_+0x46c>
   143a7:	48 8b 74 24 18       	mov    rsi,QWORD PTR [rsp+0x18]
   143ac:	4c 89 e2             	mov    rdx,r12
   143af:	b9 02 00 00 00       	mov    ecx,0x2
   143b4:	e8 45 30 00 00       	call   173fe <rfc_wrap>
   143b9:	45 0f 57 ed          	xorps  xmm13,xmm13
   143bd:	f3 44 0f 10 25 aa db 	movss  xmm12,DWORD PTR [rip+0xfffffffffffedbaa]        # 1f70 <_IO_stdin_used-0x68>
   143c4:	fe ff 
   143c6:	f3 44 0f 10 9c 24 88 	movss  xmm11,DWORD PTR [rsp+0x88]
   143cd:	00 00 00 
   143d0:	f3 44 0f 10 94 24 80 	movss  xmm10,DWORD PTR [rsp+0x80]
   143d7:	00 00 00 
   143da:	f3 44 0f 10 4c 24 78 	movss  xmm9,DWORD PTR [rsp+0x78]
   143e1:	f3 44 0f 10 44 24 70 	movss  xmm8,DWORD PTR [rsp+0x70]
   143e8:	66 0f 6e 7c 24 0c    	movd   xmm7,DWORD PTR [rsp+0xc]
   143ee:	66 0f 6e 74 24 10    	movd   xmm6,DWORD PTR [rsp+0x10]
   143f4:	49 89 c4             	mov    r12,rax
   143f7:	e9 3d f6 ff ff       	jmp    13a39 <NF_FID_36_112_114_111_100_117_99_116_46_110_101_97_114_101_115_116_+0x579>
   143fc:	31 db                	xor    ebx,ebx
   143fe:	48 8b 54 24 30       	mov    rdx,QWORD PTR [rsp+0x30]
   14403:	85 c0                	test   eax,eax
   14405:	0f 44 dd             	cmove  ebx,ebp
   14408:	45 0f 44 fe          	cmove  r15d,r14d
   1440c:	31 c0                	xor    eax,eax
   1440e:	83 fb 09             	cmp    ebx,0x9
   14411:	0f 94 c0             	sete   al
   14414:	48 89 02             	mov    QWORD PTR [rdx],rax
   14417:	4c 89 7a 08          	mov    QWORD PTR [rdx+0x8],r15
   1441b:	48 89 5a 10          	mov    QWORD PTR [rdx+0x10],rbx
   1441f:	b8 01 00 00 00       	mov    eax,0x1
   14424:	48 83 c4 38          	add    rsp,0x38
   14428:	5b                   	pop    rbx
   14429:	41 5c                	pop    r12
   1442b:	41 5d                	pop    r13
   1442d:	41 5e                	pop    r14
   1442f:	41 5f                	pop    r15
   14431:	5d                   	pop    rbp
   14432:	c3                   	ret    
   14433:	48 8d 3d 1e eb fe ff 	lea    rdi,[rip+0xfffffffffffeeb1e]        # 2f58 <FID_RESW_T+0x848>
   1443a:	e8 31 2b 00 00       	call   16f70 <err_fail>

Disassembly of section .init:

Disassembly of section .fini:

Disassembly of section .plt:
