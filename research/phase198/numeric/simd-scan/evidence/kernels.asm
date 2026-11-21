0000000000401290 <scalar>:
  401290:	41 89 c8             	mov    r8d,ecx
  401293:	48 85 f6             	test   rsi,rsi
  401296:	74 23                	je     4012bb <scalar+0x2b>
  401298:	8d 0c 32             	lea    ecx,[rdx+rsi*1]
  40129b:	0f 1f 44 00 00       	nop    DWORD PTR [rax+rax*1+0x0]
  4012a0:	89 c8                	mov    eax,ecx
  4012a2:	29 f0                	sub    eax,esi
  4012a4:	89 c2                	mov    edx,eax
  4012a6:	83 e2 7f             	and    edx,0x7f
  4012a9:	48 8d 14 97          	lea    rdx,[rdi+rdx*4]
  4012ad:	44 03 02             	add    r8d,DWORD PTR [rdx]
  4012b0:	44 31 c0             	xor    eax,r8d
  4012b3:	89 02                	mov    DWORD PTR [rdx],eax
  4012b5:	48 83 ee 01          	sub    rsi,0x1
  4012b9:	75 e5                	jne    4012a0 <scalar+0x10>
  4012bb:	44 89 c0             	mov    eax,r8d
  4012be:	c3                   	ret    
  4012bf:	90                   	nop

00000000004012c0 <simd4>:
  4012c0:	48 85 f6             	test   rsi,rsi
  4012c3:	75 2c                	jne    4012f1 <simd4+0x31>
  4012c5:	e9 1e 01 00 00       	jmp    4013e8 <simd4+0x128>
  4012ca:	66 0f 1f 44 00 00    	nop    WORD PTR [rax+rax*1+0x0]
  4012d0:	89 d0                	mov    eax,edx
  4012d2:	83 e0 7f             	and    eax,0x7f
  4012d5:	48 8d 04 87          	lea    rax,[rdi+rax*4]
  4012d9:	03 08                	add    ecx,DWORD PTR [rax]
  4012db:	41 89 c8             	mov    r8d,ecx
  4012de:	41 31 d0             	xor    r8d,edx
  4012e1:	83 c2 01             	add    edx,0x1
  4012e4:	44 89 00             	mov    DWORD PTR [rax],r8d
  4012e7:	48 83 ee 01          	sub    rsi,0x1
  4012eb:	0f 84 f7 00 00 00    	je     4013e8 <simd4+0x128>
  4012f1:	f6 c2 03             	test   dl,0x3
  4012f4:	75 da                	jne    4012d0 <simd4+0x10>
  4012f6:	66 0f 6e e9          	movd   xmm5,ecx
  4012fa:	66 0f 6e f2          	movd   xmm6,edx
  4012fe:	66 0f 70 de 00       	pshufd xmm3,xmm6,0x0
  401303:	66 0f 70 cd 00       	pshufd xmm1,xmm5,0x0
  401308:	66 0f fe 1d f0 0d 00 	paddd  xmm3,XMMWORD PTR [rip+0xdf0]        # 402100 <_IO_stdin_used+0x100>
  40130f:	00 
  401310:	48 83 fe 03          	cmp    rsi,0x3
  401314:	0f 86 d1 00 00 00    	jbe    4013eb <simd4+0x12b>
  40131a:	66 0f 6f 25 ee 0d 00 	movdqa xmm4,XMMWORD PTR [rip+0xdee]        # 402110 <_IO_stdin_used+0x110>
  401321:	00 
  401322:	48 89 f0             	mov    rax,rsi
  401325:	44 8d 04 32          	lea    r8d,[rdx+rsi*1]
  401329:	0f 1f 80 00 00 00 00 	nop    DWORD PTR [rax+0x0]
  401330:	44 89 c1             	mov    ecx,r8d
  401333:	29 c1                	sub    ecx,eax
  401335:	48 83 e8 04          	sub    rax,0x4
  401339:	83 e1 7f             	and    ecx,0x7f
  40133c:	48 8d 0c 8f          	lea    rcx,[rdi+rcx*4]
  401340:	f3 0f 6f 01          	movdqu xmm0,XMMWORD PTR [rcx]
  401344:	f3 0f 6f 11          	movdqu xmm2,XMMWORD PTR [rcx]
  401348:	66 0f 73 f8 04       	pslldq xmm0,0x4
  40134d:	66 0f fe d0          	paddd  xmm2,xmm0
  401351:	66 0f 6f c2          	movdqa xmm0,xmm2
  401355:	66 0f 73 f8 08       	pslldq xmm0,0x8
  40135a:	66 0f fe c1          	paddd  xmm0,xmm1
  40135e:	66 0f 6f cb          	movdqa xmm1,xmm3
  401362:	66 0f fe dc          	paddd  xmm3,xmm4
  401366:	66 0f fe c2          	paddd  xmm0,xmm2
  40136a:	66 0f ef c8          	pxor   xmm1,xmm0
  40136e:	66 0f 70 c0 ff       	pshufd xmm0,xmm0,0xff
  401373:	0f 11 09             	movups XMMWORD PTR [rcx],xmm1
  401376:	66 0f 6f c8          	movdqa xmm1,xmm0
  40137a:	48 83 f8 03          	cmp    rax,0x3
  40137e:	77 b0                	ja     401330 <simd4+0x70>
  401380:	48 8d 46 fc          	lea    rax,[rsi-0x4]
  401384:	48 c1 e8 02          	shr    rax,0x2
  401388:	8d 54 82 04          	lea    edx,[rdx+rax*4+0x4]
  40138c:	66 0f 7e c0          	movd   eax,xmm0
  401390:	83 e6 03             	and    esi,0x3
  401393:	74 4b                	je     4013e0 <simd4+0x120>
  401395:	89 d1                	mov    ecx,edx
  401397:	41 89 d0             	mov    r8d,edx
  40139a:	83 e1 7f             	and    ecx,0x7f
  40139d:	48 8d 0c 8f          	lea    rcx,[rdi+rcx*4]
  4013a1:	03 01                	add    eax,DWORD PTR [rcx]
  4013a3:	41 31 c0             	xor    r8d,eax
  4013a6:	44 89 01             	mov    DWORD PTR [rcx],r8d
  4013a9:	8d 4a 01             	lea    ecx,[rdx+0x1]
  4013ac:	48 83 ee 01          	sub    rsi,0x1
  4013b0:	74 2e                	je     4013e0 <simd4+0x120>
  4013b2:	41 89 c8             	mov    r8d,ecx
  4013b5:	83 c2 02             	add    edx,0x2
  4013b8:	41 83 e0 7f          	and    r8d,0x7f
  4013bc:	4e 8d 04 87          	lea    r8,[rdi+r8*4]
  4013c0:	41 03 00             	add    eax,DWORD PTR [r8]
  4013c3:	31 c1                	xor    ecx,eax
  4013c5:	41 89 08             	mov    DWORD PTR [r8],ecx
  4013c8:	48 83 fe 01          	cmp    rsi,0x1
  4013cc:	74 12                	je     4013e0 <simd4+0x120>
  4013ce:	89 d1                	mov    ecx,edx
  4013d0:	83 e1 7f             	and    ecx,0x7f
  4013d3:	48 8d 0c 8f          	lea    rcx,[rdi+rcx*4]
  4013d7:	03 01                	add    eax,DWORD PTR [rcx]
  4013d9:	31 c2                	xor    edx,eax
  4013db:	89 11                	mov    DWORD PTR [rcx],edx
  4013dd:	c3                   	ret    
  4013de:	66 90                	xchg   ax,ax
  4013e0:	c3                   	ret    
  4013e1:	0f 1f 80 00 00 00 00 	nop    DWORD PTR [rax+0x0]
  4013e8:	89 c8                	mov    eax,ecx
  4013ea:	c3                   	ret    
  4013eb:	89 c8                	mov    eax,ecx
  4013ed:	eb a6                	jmp    401395 <simd4+0xd5>
  4013ef:	90                   	nop

