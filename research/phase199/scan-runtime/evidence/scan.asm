
selfhost/build/phase198/p199-scan-runtime01/scan.o:     file format elf64-x86-64


Disassembly of section .text:

0000000000000000 <p199_rt_u32_scan4>:
   0:	49 89 f1             	mov    r9,rsi
   3:	4c 89 c0             	mov    rax,r8
   6:	48 85 d2             	test   rdx,rdx
   9:	74 39                	je     44 <p199_rt_u32_scan4+0x44>
   b:	48 83 fe 02          	cmp    rsi,0x2
   f:	76 37                	jbe    48 <p199_rt_u32_scan4+0x48>
  11:	48 8d 46 01          	lea    rax,[rsi+0x1]
  15:	48 85 f0             	test   rax,rsi
  18:	75 2e                	jne    48 <p199_rt_u32_scan4+0x48>
  1a:	66 0f 1f 44 00 00    	nop    WORD PTR [rax+rax*1+0x0]
  20:	f6 c1 03             	test   cl,0x3
  23:	74 53                	je     78 <p199_rt_u32_scan4+0x78>
  25:	89 c8                	mov    eax,ecx
  27:	44 21 c8             	and    eax,r9d
  2a:	48 8d 04 87          	lea    rax,[rdi+rax*4]
  2e:	44 03 00             	add    r8d,DWORD PTR [rax]
  31:	44 89 c6             	mov    esi,r8d
  34:	31 ce                	xor    esi,ecx
  36:	83 c1 01             	add    ecx,0x1
  39:	89 30                	mov    DWORD PTR [rax],esi
  3b:	48 83 ea 01          	sub    rdx,0x1
  3f:	75 df                	jne    20 <p199_rt_u32_scan4+0x20>
  41:	44 89 c0             	mov    eax,r8d
  44:	c3                   	ret    
  45:	0f 1f 00             	nop    DWORD PTR [rax]
  48:	48 89 d6             	mov    rsi,rdx
  4b:	44 8d 14 11          	lea    r10d,[rcx+rdx*1]
  4f:	90                   	nop
  50:	44 89 d0             	mov    eax,r10d
  53:	29 f0                	sub    eax,esi
  55:	89 c2                	mov    edx,eax
  57:	44 21 ca             	and    edx,r9d
  5a:	48 8d 14 97          	lea    rdx,[rdi+rdx*4]
  5e:	44 03 02             	add    r8d,DWORD PTR [rdx]
  61:	44 31 c0             	xor    eax,r8d
  64:	89 02                	mov    DWORD PTR [rdx],eax
  66:	48 83 ee 01          	sub    rsi,0x1
  6a:	75 e4                	jne    50 <p199_rt_u32_scan4+0x50>
  6c:	44 89 c0             	mov    eax,r8d
  6f:	eb d3                	jmp    44 <p199_rt_u32_scan4+0x44>
  71:	0f 1f 80 00 00 00 00 	nop    DWORD PTR [rax+0x0]
  78:	66 41 0f 6e e8       	movd   xmm5,r8d
  7d:	66 0f 6e f1          	movd   xmm6,ecx
  81:	66 0f 70 de 00       	pshufd xmm3,xmm6,0x0
  86:	66 0f 70 cd 00       	pshufd xmm1,xmm5,0x0
  8b:	66 0f fe 1d 00 00 00 	paddd  xmm3,XMMWORD PTR [rip+0x0]        # 93 <p199_rt_u32_scan4+0x93>
  92:	00 
			8f: R_X86_64_PC32	.LC0-0x4
  93:	48 83 fa 03          	cmp    rdx,0x3
  97:	0f 86 7d 00 00 00    	jbe    11a <p199_rt_u32_scan4+0x11a>
  9d:	66 0f 6f 25 00 00 00 	movdqa xmm4,XMMWORD PTR [rip+0x0]        # a5 <p199_rt_u32_scan4+0xa5>
  a4:	00 
			a1: R_X86_64_PC32	.LC1-0x4
  a5:	48 89 d0             	mov    rax,rdx
  a8:	44 8d 14 11          	lea    r10d,[rcx+rdx*1]
  ac:	0f 1f 40 00          	nop    DWORD PTR [rax+0x0]
  b0:	44 89 d6             	mov    esi,r10d
  b3:	29 c6                	sub    esi,eax
  b5:	48 83 e8 04          	sub    rax,0x4
  b9:	4c 21 ce             	and    rsi,r9
  bc:	48 8d 34 b7          	lea    rsi,[rdi+rsi*4]
  c0:	f3 0f 6f 06          	movdqu xmm0,XMMWORD PTR [rsi]
  c4:	f3 0f 6f 16          	movdqu xmm2,XMMWORD PTR [rsi]
  c8:	66 0f 73 f8 04       	pslldq xmm0,0x4
  cd:	66 0f fe d0          	paddd  xmm2,xmm0
  d1:	66 0f 6f c2          	movdqa xmm0,xmm2
  d5:	66 0f 73 f8 08       	pslldq xmm0,0x8
  da:	66 0f fe c1          	paddd  xmm0,xmm1
  de:	66 0f 6f cb          	movdqa xmm1,xmm3
  e2:	66 0f fe dc          	paddd  xmm3,xmm4
  e6:	66 0f fe c2          	paddd  xmm0,xmm2
  ea:	66 0f ef c8          	pxor   xmm1,xmm0
  ee:	66 0f 70 c0 ff       	pshufd xmm0,xmm0,0xff
  f3:	0f 11 0e             	movups XMMWORD PTR [rsi],xmm1
  f6:	66 0f 6f c8          	movdqa xmm1,xmm0
  fa:	48 83 f8 03          	cmp    rax,0x3
  fe:	77 b0                	ja     b0 <p199_rt_u32_scan4+0xb0>
 100:	48 8d 42 fc          	lea    rax,[rdx-0x4]
 104:	66 41 0f 7e c0       	movd   r8d,xmm0
 109:	48 c1 e8 02          	shr    rax,0x2
 10d:	8d 4c 81 04          	lea    ecx,[rcx+rax*4+0x4]
 111:	83 e2 03             	and    edx,0x3
 114:	0f 84 27 ff ff ff    	je     41 <p199_rt_u32_scan4+0x41>
 11a:	89 c8                	mov    eax,ecx
 11c:	89 ce                	mov    esi,ecx
 11e:	44 21 c8             	and    eax,r9d
 121:	48 8d 04 87          	lea    rax,[rdi+rax*4]
 125:	44 03 00             	add    r8d,DWORD PTR [rax]
 128:	44 31 c6             	xor    esi,r8d
 12b:	89 30                	mov    DWORD PTR [rax],esi
 12d:	8d 41 01             	lea    eax,[rcx+0x1]
 130:	48 83 ea 01          	sub    rdx,0x1
 134:	0f 84 07 ff ff ff    	je     41 <p199_rt_u32_scan4+0x41>
 13a:	89 c6                	mov    esi,eax
 13c:	83 c1 02             	add    ecx,0x2
 13f:	44 21 ce             	and    esi,r9d
 142:	48 8d 34 b7          	lea    rsi,[rdi+rsi*4]
 146:	44 03 06             	add    r8d,DWORD PTR [rsi]
 149:	44 31 c0             	xor    eax,r8d
 14c:	89 06                	mov    DWORD PTR [rsi],eax
 14e:	48 83 fa 01          	cmp    rdx,0x1
 152:	0f 84 e9 fe ff ff    	je     41 <p199_rt_u32_scan4+0x41>
 158:	41 21 c9             	and    r9d,ecx
 15b:	4a 8d 04 8f          	lea    rax,[rdi+r9*4]
 15f:	44 03 00             	add    r8d,DWORD PTR [rax]
 162:	44 31 c1             	xor    ecx,r8d
 165:	89 08                	mov    DWORD PTR [rax],ecx
 167:	44 89 c0             	mov    eax,r8d
 16a:	e9 d5 fe ff ff       	jmp    44 <p199_rt_u32_scan4+0x44>
