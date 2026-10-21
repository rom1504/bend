
/home/ai/bend2/build/publish/bend/selfhost/build/phase99/phase102-runtime-products04/variation-ray-active-256-2240/candidate.program:     file format elf64-x86-64


Disassembly of section .text:

0000000000014d20 <NF_FID_110_101_97_114_101_115_116_46_116_>:
   14d20:	55                   	push   rbp
   14d21:	41 57                	push   r15
   14d23:	41 56                	push   r14
   14d25:	41 55                	push   r13
   14d27:	41 54                	push   r12
   14d29:	53                   	push   rbx
   14d2a:	48 83 ec 28          	sub    rsp,0x28
   14d2e:	48 89 54 24 20       	mov    QWORD PTR [rsp+0x20],rdx
   14d33:	44 8b b4 24 88 00 00 	mov    r14d,DWORD PTR [rsp+0x88]
   14d3a:	00 
   14d3b:	8b 9c 24 80 00 00 00 	mov    ebx,DWORD PTR [rsp+0x80]
   14d42:	83 bc 24 90 00 00 00 	cmp    DWORD PTR [rsp+0x90],0x1
   14d49:	01 
   14d4a:	0f 94 c0             	sete   al
   14d4d:	48 85 c9             	test   rcx,rcx
   14d50:	0f 84 74 0e 00 00    	je     15bca <NF_FID_110_101_97_114_101_115_116_46_116_+0xeaa>
   14d56:	48 89 f5             	mov    rbp,rsi
   14d59:	49 89 ff             	mov    r15,rdi
   14d5c:	49 ba 80 ff ff ff ff 	movabs r10,0xffffffff80
   14d63:	00 00 00 
   14d66:	66 41 0f 6e f0       	movd   xmm6,r8d
   14d6b:	66 41 0f 6e f9       	movd   xmm7,r9d
   14d70:	f3 44 0f 10 44 24 60 	movss  xmm8,DWORD PTR [rsp+0x60]
   14d77:	f3 44 0f 10 4c 24 68 	movss  xmm9,DWORD PTR [rsp+0x68]
   14d7e:	f3 44 0f 10 54 24 70 	movss  xmm10,DWORD PTR [rsp+0x70]
   14d85:	f3 44 0f 10 5c 24 78 	movss  xmm11,DWORD PTR [rsp+0x78]
   14d8c:	49 8d 52 7f          	lea    rdx,[r10+0x7f]
   14d90:	48 89 54 24 18       	mov    QWORD PTR [rsp+0x18],rdx
   14d95:	f3 44 0f 10 25 ea d1 	movss  xmm12,DWORD PTR [rip+0xfffffffffffed1ea]        # 1f88 <_IO_stdin_used-0x50>
   14d9c:	fe ff 
   14d9e:	f3 44 0f 10 2d d1 d1 	movss  xmm13,DWORD PTR [rip+0xfffffffffffed1d1]        # 1f78 <_IO_stdin_used-0x60>
   14da5:	fe ff 
   14da7:	f3 44 0f 10 35 c0 d1 	movss  xmm14,DWORD PTR [rip+0xfffffffffffed1c0]        # 1f70 <_IO_stdin_used-0x68>
   14dae:	fe ff 
   14db0:	45 0f 57 ff          	xorps  xmm15,xmm15
   14db4:	66 0f 7e 74 24 08    	movd   DWORD PTR [rsp+0x8],xmm6
   14dba:	66 0f 7e 7c 24 04    	movd   DWORD PTR [rsp+0x4],xmm7
   14dc0:	48 89 74 24 10       	mov    QWORD PTR [rsp+0x10],rsi
   14dc5:	eb 2b                	jmp    14df2 <NF_FID_110_101_97_114_101_115_116_46_116_+0xd2>
   14dc7:	66 0f 1f 84 00 00 00 	nop    WORD PTR [rax+rax*1+0x0]
   14dce:	00 00 
   14dd0:	41 89 de             	mov    r14d,ebx
   14dd3:	66 41 0f 6e c5       	movd   xmm0,r13d
   14dd8:	66 41 0f 6e ce       	movd   xmm1,r14d
   14ddd:	0f 2e c8             	ucomiss xmm1,xmm0
   14de0:	0f 97 c0             	seta   al
   14de3:	4c 89 e1             	mov    rcx,r12
   14de6:	44 89 eb             	mov    ebx,r13d
   14de9:	4d 85 e4             	test   r12,r12
   14dec:	0f 84 db 0d 00 00    	je     15bcd <NF_FID_110_101_97_114_101_115_116_46_116_+0xead>
   14df2:	4c 8d 61 ff          	lea    r12,[rcx-0x1]
   14df6:	a8 01                	test   al,0x1
   14df8:	0f 84 a2 00 00 00    	je     14ea0 <NF_FID_110_101_97_114_101_115_116_46_116_+0x180>
   14dfe:	4d 85 e4             	test   r12,r12
   14e01:	0f 88 34 01 00 00    	js     14f3b <NF_FID_110_101_97_114_101_115_116_46_116_+0x21b>
   14e07:	48 b8 00 00 00 00 00 	movabs rax,0x200000000000000
   14e0e:	00 00 02 
   14e11:	48 ff c0             	inc    rax
   14e14:	48 39 c1             	cmp    rcx,rax
   14e17:	0f 92 c0             	setb   al
   14e1a:	4c 89 e1             	mov    rcx,r12
   14e1d:	4c 21 d1             	and    rcx,r10
   14e20:	48 81 f9 80 81 10 03 	cmp    rcx,0x3108180
   14e27:	0f 92 c1             	setb   cl
   14e2a:	08 c1                	or     cl,al
   14e2c:	0f 85 43 01 00 00    	jne    14f75 <NF_FID_110_101_97_114_101_115_116_46_116_+0x255>
   14e32:	4c 89 ff             	mov    rdi,r15
   14e35:	48 89 ee             	mov    rsi,rbp
   14e38:	4c 89 e2             	mov    rdx,r12
   14e3b:	b9 02 00 00 00       	mov    ecx,0x2
   14e40:	e8 b9 25 00 00       	call   173fe <rfc_wrap>
   14e45:	45 0f 57 ff          	xorps  xmm15,xmm15
   14e49:	f3 44 0f 10 35 1e d1 	movss  xmm14,DWORD PTR [rip+0xfffffffffffed11e]        # 1f70 <_IO_stdin_used-0x68>
   14e50:	fe ff 
   14e52:	f3 44 0f 10 2d 1d d1 	movss  xmm13,DWORD PTR [rip+0xfffffffffffed11d]        # 1f78 <_IO_stdin_used-0x60>
   14e59:	fe ff 
   14e5b:	f3 44 0f 10 25 24 d1 	movss  xmm12,DWORD PTR [rip+0xfffffffffffed124]        # 1f88 <_IO_stdin_used-0x50>
   14e62:	fe ff 
   14e64:	f3 44 0f 10 5c 24 78 	movss  xmm11,DWORD PTR [rsp+0x78]
   14e6b:	f3 44 0f 10 54 24 70 	movss  xmm10,DWORD PTR [rsp+0x70]
   14e72:	f3 44 0f 10 4c 24 68 	movss  xmm9,DWORD PTR [rsp+0x68]
   14e79:	f3 44 0f 10 44 24 60 	movss  xmm8,DWORD PTR [rsp+0x60]
   14e80:	66 0f 6e 7c 24 04    	movd   xmm7,DWORD PTR [rsp+0x4]
   14e86:	66 0f 6e 74 24 08    	movd   xmm6,DWORD PTR [rsp+0x8]
   14e8c:	49 89 c4             	mov    r12,rax
   14e8f:	48 23 44 24 18       	and    rax,QWORD PTR [rsp+0x18]
   14e94:	e9 c3 00 00 00       	jmp    14f5c <NF_FID_110_101_97_114_101_115_116_46_116_+0x23c>
   14e99:	0f 1f 80 00 00 00 00 	nop    DWORD PTR [rax+0x0]
   14ea0:	4d 85 e4             	test   r12,r12
   14ea3:	0f 88 2c 01 00 00    	js     14fd5 <NF_FID_110_101_97_114_101_115_116_46_116_+0x2b5>
   14ea9:	48 b8 00 00 00 00 00 	movabs rax,0x200000000000000
   14eb0:	00 00 02 
   14eb3:	48 ff c0             	inc    rax
   14eb6:	48 39 c1             	cmp    rcx,rax
   14eb9:	0f 92 c0             	setb   al
   14ebc:	4c 89 e1             	mov    rcx,r12
   14ebf:	4c 21 d1             	and    rcx,r10
   14ec2:	48 81 f9 80 81 10 03 	cmp    rcx,0x3108180
   14ec9:	0f 92 c1             	setb   cl
   14ecc:	08 c1                	or     cl,al
   14ece:	0f 85 3b 01 00 00    	jne    1500f <NF_FID_110_101_97_114_101_115_116_46_116_+0x2ef>
   14ed4:	4c 89 ff             	mov    rdi,r15
   14ed7:	48 89 ee             	mov    rsi,rbp
   14eda:	4c 89 e2             	mov    rdx,r12
   14edd:	b9 02 00 00 00       	mov    ecx,0x2
   14ee2:	e8 17 25 00 00       	call   173fe <rfc_wrap>
   14ee7:	45 0f 57 ff          	xorps  xmm15,xmm15
   14eeb:	f3 44 0f 10 35 7c d0 	movss  xmm14,DWORD PTR [rip+0xfffffffffffed07c]        # 1f70 <_IO_stdin_used-0x68>
   14ef2:	fe ff 
   14ef4:	f3 44 0f 10 2d 7b d0 	movss  xmm13,DWORD PTR [rip+0xfffffffffffed07b]        # 1f78 <_IO_stdin_used-0x60>
   14efb:	fe ff 
   14efd:	f3 44 0f 10 25 82 d0 	movss  xmm12,DWORD PTR [rip+0xfffffffffffed082]        # 1f88 <_IO_stdin_used-0x50>
   14f04:	fe ff 
   14f06:	f3 44 0f 10 5c 24 78 	movss  xmm11,DWORD PTR [rsp+0x78]
   14f0d:	f3 44 0f 10 54 24 70 	movss  xmm10,DWORD PTR [rsp+0x70]
   14f14:	f3 44 0f 10 4c 24 68 	movss  xmm9,DWORD PTR [rsp+0x68]
   14f1b:	f3 44 0f 10 44 24 60 	movss  xmm8,DWORD PTR [rsp+0x60]
   14f22:	66 0f 6e 7c 24 04    	movd   xmm7,DWORD PTR [rsp+0x4]
   14f28:	66 0f 6e 74 24 08    	movd   xmm6,DWORD PTR [rsp+0x8]
   14f2e:	49 89 c4             	mov    r12,rax
   14f31:	48 23 44 24 18       	and    rax,QWORD PTR [rsp+0x18]
   14f36:	e9 bb 00 00 00       	jmp    14ff6 <NF_FID_110_101_97_114_101_115_116_46_116_+0x2d6>
   14f3b:	4c 89 e0             	mov    rax,r12
   14f3e:	48 23 44 24 18       	and    rax,QWORD PTR [rsp+0x18]
   14f43:	b9 01 00 00 00       	mov    ecx,0x1
   14f48:	f0 41 0f c1 0c c7    	lock xadd DWORD PTR [r15+rax*8],ecx
   14f4e:	f7 d1                	not    ecx
   14f50:	f7 c1 fe ff ff 00    	test   ecx,0xfffffe
   14f56:	0f 84 93 0c 00 00    	je     15bef <NF_FID_110_101_97_114_101_115_116_46_116_+0xecf>
   14f5c:	b9 01 00 00 00       	mov    ecx,0x1
   14f61:	f0 41 0f c1 0c c7    	lock xadd DWORD PTR [r15+rax*8],ecx
   14f67:	f7 d1                	not    ecx
   14f69:	f7 c1 fe ff ff 00    	test   ecx,0xfffffe
   14f6f:	0f 84 7a 0c 00 00    	je     15bef <NF_FID_110_101_97_114_101_115_116_46_116_+0xecf>
   14f75:	49 83 fc 07          	cmp    r12,0x7
   14f79:	0f 87 92 01 00 00    	ja     15111 <NF_FID_110_101_97_114_101_115_116_46_116_+0x3f1>
   14f7f:	48 8d 0d c6 d3 fe ff 	lea    rcx,[rip+0xfffffffffffed3c6]        # 234c <_IO_stdin_used+0x374>
   14f86:	4a 63 04 a1          	movsxd rax,DWORD PTR [rcx+r12*4]
   14f8a:	48 01 c8             	add    rax,rcx
   14f8d:	41 0f 28 e5          	movaps xmm4,xmm13
   14f91:	41 0f 28 c6          	movaps xmm0,xmm14
   14f95:	41 0f 28 d4          	movaps xmm2,xmm12
   14f99:	ff e0                	jmp    rax
   14f9b:	0f 57 e4             	xorps  xmm4,xmm4
   14f9e:	49 83 fc 06          	cmp    r12,0x6
   14fa2:	0f 87 21 03 00 00    	ja     152c9 <NF_FID_110_101_97_114_101_115_116_46_116_+0x5a9>
   14fa8:	48 8d 0d bd d3 fe ff 	lea    rcx,[rip+0xfffffffffffed3bd]        # 236c <_IO_stdin_used+0x394>
   14faf:	4a 63 04 a1          	movsxd rax,DWORD PTR [rcx+r12*4]
   14fb3:	48 01 c8             	add    rax,rcx
   14fb6:	ff e0                	jmp    rax
   14fb8:	f3 0f 10 0d c0 cf fe 	movss  xmm1,DWORD PTR [rip+0xfffffffffffecfc0]        # 1f80 <_IO_stdin_used-0x58>
   14fbf:	ff 
   14fc0:	f3 0f 10 15 00 d0 fe 	movss  xmm2,DWORD PTR [rip+0xfffffffffffed000]        # 1fc8 <_IO_stdin_used-0x10>
   14fc7:	ff 
   14fc8:	f3 0f 10 05 f0 cf fe 	movss  xmm0,DWORD PTR [rip+0xfffffffffffecff0]        # 1fc0 <_IO_stdin_used-0x18>
   14fcf:	ff 
   14fd0:	e9 de 08 00 00       	jmp    158b3 <NF_FID_110_101_97_114_101_115_116_46_116_+0xb93>
   14fd5:	4c 89 e0             	mov    rax,r12
   14fd8:	48 23 44 24 18       	and    rax,QWORD PTR [rsp+0x18]
   14fdd:	b9 01 00 00 00       	mov    ecx,0x1
   14fe2:	f0 41 0f c1 0c c7    	lock xadd DWORD PTR [r15+rax*8],ecx
   14fe8:	f7 d1                	not    ecx
   14fea:	f7 c1 fe ff ff 00    	test   ecx,0xfffffe
   14ff0:	0f 84 f9 0b 00 00    	je     15bef <NF_FID_110_101_97_114_101_115_116_46_116_+0xecf>
   14ff6:	b9 01 00 00 00       	mov    ecx,0x1
   14ffb:	f0 41 0f c1 0c c7    	lock xadd DWORD PTR [r15+rax*8],ecx
   15001:	f7 d1                	not    ecx
   15003:	f7 c1 fe ff ff 00    	test   ecx,0xfffffe
   15009:	0f 84 e0 0b 00 00    	je     15bef <NF_FID_110_101_97_114_101_115_116_46_116_+0xecf>
   1500f:	49 83 fc 07          	cmp    r12,0x7
   15013:	0f 87 bb 01 00 00    	ja     151d4 <NF_FID_110_101_97_114_101_115_116_46_116_+0x4b4>
   15019:	48 8d 0d f0 d2 fe ff 	lea    rcx,[rip+0xfffffffffffed2f0]        # 2310 <_IO_stdin_used+0x338>
   15020:	4a 63 04 a1          	movsxd rax,DWORD PTR [rcx+r12*4]
   15024:	48 01 c8             	add    rax,rcx
   15027:	41 0f 28 e5          	movaps xmm4,xmm13
   1502b:	41 0f 28 c6          	movaps xmm0,xmm14
   1502f:	41 0f 28 d4          	movaps xmm2,xmm12
   15033:	ff e0                	jmp    rax
   15035:	0f 57 e4             	xorps  xmm4,xmm4
   15038:	49 83 fc 06          	cmp    r12,0x6
   1503c:	0f 87 d8 03 00 00    	ja     1541a <NF_FID_110_101_97_114_101_115_116_46_116_+0x6fa>
   15042:	48 8d 0d e7 d2 fe ff 	lea    rcx,[rip+0xfffffffffffed2e7]        # 2330 <_IO_stdin_used+0x358>
   15049:	4a 63 04 a1          	movsxd rax,DWORD PTR [rcx+r12*4]
   1504d:	48 01 c8             	add    rax,rcx
   15050:	ff e0                	jmp    rax
   15052:	f3 0f 10 0d 26 cf fe 	movss  xmm1,DWORD PTR [rip+0xfffffffffffecf26]        # 1f80 <_IO_stdin_used-0x58>
   15059:	ff 
   1505a:	f3 0f 10 15 66 cf fe 	movss  xmm2,DWORD PTR [rip+0xfffffffffffecf66]        # 1fc8 <_IO_stdin_used-0x10>
   15061:	ff 
   15062:	f3 0f 10 05 56 cf fe 	movss  xmm0,DWORD PTR [rip+0xfffffffffffecf56]        # 1fc0 <_IO_stdin_used-0x18>
   15069:	ff 
   1506a:	e9 74 05 00 00       	jmp    155e3 <NF_FID_110_101_97_114_101_115_116_46_116_+0x8c3>
   1506f:	41 bc 03 00 00 00    	mov    r12d,0x3
   15075:	f3 0f 10 0d 2b cf fe 	movss  xmm1,DWORD PTR [rip+0xfffffffffffecf2b]        # 1fa8 <_IO_stdin_used-0x30>
   1507c:	ff 
   1507d:	f3 0f 10 15 07 cf fe 	movss  xmm2,DWORD PTR [rip+0xfffffffffffecf07]        # 1f8c <_IO_stdin_used-0x4c>
   15084:	ff 
   15085:	e9 25 08 00 00       	jmp    158af <NF_FID_110_101_97_114_101_115_116_46_116_+0xb8f>
   1508a:	41 bc 03 00 00 00    	mov    r12d,0x3
   15090:	f3 0f 10 0d 10 cf fe 	movss  xmm1,DWORD PTR [rip+0xfffffffffffecf10]        # 1fa8 <_IO_stdin_used-0x30>
   15097:	ff 
   15098:	f3 0f 10 15 ec ce fe 	movss  xmm2,DWORD PTR [rip+0xfffffffffffeceec]        # 1f8c <_IO_stdin_used-0x4c>
   1509f:	ff 
   150a0:	e9 eb 04 00 00       	jmp    15590 <NF_FID_110_101_97_114_101_115_116_46_116_+0x870>
   150a5:	f3 0f 10 0d 0f cf fe 	movss  xmm1,DWORD PTR [rip+0xfffffffffffecf0f]        # 1fbc <_IO_stdin_used-0x1c>
   150ac:	ff 
   150ad:	f3 0f 10 25 3f cf fe 	movss  xmm4,DWORD PTR [rip+0xfffffffffffecf3f]        # 1ff4 <_IO_stdin_used+0x1c>
   150b4:	ff 
   150b5:	e9 ed 07 00 00       	jmp    158a7 <NF_FID_110_101_97_114_101_115_116_46_116_+0xb87>
   150ba:	f3 0f 10 0d fa ce fe 	movss  xmm1,DWORD PTR [rip+0xfffffffffffecefa]        # 1fbc <_IO_stdin_used-0x1c>
   150c1:	ff 
   150c2:	f3 0f 10 25 2a cf fe 	movss  xmm4,DWORD PTR [rip+0xfffffffffffecf2a]        # 1ff4 <_IO_stdin_used+0x1c>
   150c9:	ff 
   150ca:	f3 0f 10 15 aa ce fe 	movss  xmm2,DWORD PTR [rip+0xfffffffffffeceaa]        # 1f7c <_IO_stdin_used-0x5c>
   150d1:	ff 
   150d2:	e9 b9 04 00 00       	jmp    15590 <NF_FID_110_101_97_114_101_115_116_46_116_+0x870>
   150d7:	f3 0f 10 0d c9 ce fe 	movss  xmm1,DWORD PTR [rip+0xfffffffffffecec9]        # 1fa8 <_IO_stdin_used-0x30>
   150de:	ff 
   150df:	f3 0f 10 25 c5 ce fe 	movss  xmm4,DWORD PTR [rip+0xfffffffffffecec5]        # 1fac <_IO_stdin_used-0x2c>
   150e6:	ff 
   150e7:	f3 0f 10 15 9d ce fe 	movss  xmm2,DWORD PTR [rip+0xfffffffffffece9d]        # 1f8c <_IO_stdin_used-0x4c>
   150ee:	ff 
   150ef:	e9 bb 07 00 00       	jmp    158af <NF_FID_110_101_97_114_101_115_116_46_116_+0xb8f>
   150f4:	f3 0f 10 0d ac ce fe 	movss  xmm1,DWORD PTR [rip+0xfffffffffffeceac]        # 1fa8 <_IO_stdin_used-0x30>
   150fb:	ff 
   150fc:	f3 0f 10 25 a8 ce fe 	movss  xmm4,DWORD PTR [rip+0xfffffffffffecea8]        # 1fac <_IO_stdin_used-0x2c>
   15103:	ff 
   15104:	f3 0f 10 15 80 ce fe 	movss  xmm2,DWORD PTR [rip+0xfffffffffffece80]        # 1f8c <_IO_stdin_used-0x4c>
   1510b:	ff 
   1510c:	e9 7f 04 00 00       	jmp    15590 <NF_FID_110_101_97_114_101_115_116_46_116_+0x870>
   15111:	49 8d 54 24 f8       	lea    rdx,[r12-0x8]
   15116:	48 b8 00 00 00 00 00 	movabs rax,0x7e00000000000000
   1511d:	00 00 7e 
   15120:	48 85 c2             	test   rdx,rax
   15123:	0f 94 c0             	sete   al
   15126:	48 89 d1             	mov    rcx,rdx
   15129:	4c 21 d1             	and    rcx,r10
   1512c:	48 81 f9 80 81 10 03 	cmp    rcx,0x3108180
   15133:	0f 92 c1             	setb   cl
   15136:	08 c1                	or     cl,al
   15138:	75 5c                	jne    15196 <NF_FID_110_101_97_114_101_115_116_46_116_+0x476>
   1513a:	4c 89 ff             	mov    rdi,r15
   1513d:	48 89 ee             	mov    rsi,rbp
   15140:	e8 9b 20 ff ff       	call   71e0 <term_drop>
   15145:	45 0f 57 ff          	xorps  xmm15,xmm15
   15149:	f3 44 0f 10 35 1e ce 	movss  xmm14,DWORD PTR [rip+0xfffffffffffece1e]        # 1f70 <_IO_stdin_used-0x68>
   15150:	fe ff 
   15152:	f3 44 0f 10 2d 1d ce 	movss  xmm13,DWORD PTR [rip+0xfffffffffffece1d]        # 1f78 <_IO_stdin_used-0x60>
   15159:	fe ff 
   1515b:	f3 44 0f 10 25 24 ce 	movss  xmm12,DWORD PTR [rip+0xfffffffffffece24]        # 1f88 <_IO_stdin_used-0x50>
   15162:	fe ff 
   15164:	f3 44 0f 10 5c 24 78 	movss  xmm11,DWORD PTR [rsp+0x78]
   1516b:	f3 44 0f 10 54 24 70 	movss  xmm10,DWORD PTR [rsp+0x70]
   15172:	f3 44 0f 10 4c 24 68 	movss  xmm9,DWORD PTR [rsp+0x68]
   15179:	f3 44 0f 10 44 24 60 	movss  xmm8,DWORD PTR [rsp+0x60]
   15180:	66 0f 6e 7c 24 04    	movd   xmm7,DWORD PTR [rsp+0x4]
   15186:	66 0f 6e 74 24 08    	movd   xmm6,DWORD PTR [rsp+0x8]
   1518c:	49 ba 80 ff ff ff ff 	movabs r10,0xffffffff80
   15193:	00 00 00 
   15196:	4d 85 e4             	test   r12,r12
   15199:	0f 88 7a 05 00 00    	js     15719 <NF_FID_110_101_97_114_101_115_116_46_116_+0x9f9>
   1519f:	48 b8 00 00 00 00 00 	movabs rax,0x200000000000000
   151a6:	00 00 02 
   151a9:	49 39 c4             	cmp    r12,rax
   151ac:	0f 92 c0             	setb   al
   151af:	4c 89 e1             	mov    rcx,r12
   151b2:	4c 21 d1             	and    rcx,r10
   151b5:	48 81 f9 80 81 10 03 	cmp    rcx,0x3108180
   151bc:	0f 92 c1             	setb   cl
   151bf:	08 c1                	or     cl,al
   151c1:	0f 84 3f 09 00 00    	je     15b06 <NF_FID_110_101_97_114_101_115_116_46_116_+0xde6>
   151c7:	f3 0f 10 25 e9 cd fe 	movss  xmm4,DWORD PTR [rip+0xfffffffffffecde9]        # 1fb8 <_IO_stdin_used-0x20>
   151ce:	ff 
   151cf:	e9 ca fd ff ff       	jmp    14f9e <NF_FID_110_101_97_114_101_115_116_46_116_+0x27e>
   151d4:	49 8d 54 24 f8       	lea    rdx,[r12-0x8]
   151d9:	48 b8 00 00 00 00 00 	movabs rax,0x7e00000000000000
   151e0:	00 00 7e 
   151e3:	48 85 c2             	test   rdx,rax
   151e6:	0f 94 c0             	sete   al
   151e9:	48 89 d1             	mov    rcx,rdx
   151ec:	4c 21 d1             	and    rcx,r10
   151ef:	48 81 f9 80 81 10 03 	cmp    rcx,0x3108180
   151f6:	0f 92 c1             	setb   cl
   151f9:	08 c1                	or     cl,al
   151fb:	75 5c                	jne    15259 <NF_FID_110_101_97_114_101_115_116_46_116_+0x539>
   151fd:	4c 89 ff             	mov    rdi,r15
   15200:	48 89 ee             	mov    rsi,rbp
   15203:	e8 d8 1f ff ff       	call   71e0 <term_drop>
   15208:	45 0f 57 ff          	xorps  xmm15,xmm15
   1520c:	f3 44 0f 10 35 5b cd 	movss  xmm14,DWORD PTR [rip+0xfffffffffffecd5b]        # 1f70 <_IO_stdin_used-0x68>
   15213:	fe ff 
   15215:	f3 44 0f 10 2d 5a cd 	movss  xmm13,DWORD PTR [rip+0xfffffffffffecd5a]        # 1f78 <_IO_stdin_used-0x60>
   1521c:	fe ff 
   1521e:	f3 44 0f 10 25 61 cd 	movss  xmm12,DWORD PTR [rip+0xfffffffffffecd61]        # 1f88 <_IO_stdin_used-0x50>
   15225:	fe ff 
   15227:	f3 44 0f 10 5c 24 78 	movss  xmm11,DWORD PTR [rsp+0x78]
   1522e:	f3 44 0f 10 54 24 70 	movss  xmm10,DWORD PTR [rsp+0x70]
   15235:	f3 44 0f 10 4c 24 68 	movss  xmm9,DWORD PTR [rsp+0x68]
   1523c:	f3 44 0f 10 44 24 60 	movss  xmm8,DWORD PTR [rsp+0x60]
   15243:	66 0f 6e 7c 24 04    	movd   xmm7,DWORD PTR [rsp+0x4]
   15249:	66 0f 6e 74 24 08    	movd   xmm6,DWORD PTR [rsp+0x8]
   1524f:	49 ba 80 ff ff ff ff 	movabs r10,0xffffffff80
   15256:	00 00 00 
   15259:	4d 85 e4             	test   r12,r12
   1525c:	0f 88 e5 04 00 00    	js     15747 <NF_FID_110_101_97_114_101_115_116_46_116_+0xa27>
   15262:	48 b8 00 00 00 00 00 	movabs rax,0x200000000000000
   15269:	00 00 02 
   1526c:	49 39 c4             	cmp    r12,rax
   1526f:	0f 92 c0             	setb   al
   15272:	4c 89 e1             	mov    rcx,r12
   15275:	4c 21 d1             	and    rcx,r10
   15278:	48 81 f9 80 81 10 03 	cmp    rcx,0x3108180
   1527f:	0f 92 c1             	setb   cl
   15282:	08 c1                	or     cl,al
   15284:	0f 84 de 08 00 00    	je     15b68 <NF_FID_110_101_97_114_101_115_116_46_116_+0xe48>
   1528a:	f3 0f 10 25 26 cd fe 	movss  xmm4,DWORD PTR [rip+0xfffffffffffecd26]        # 1fb8 <_IO_stdin_used-0x20>
   15291:	ff 
   15292:	e9 a1 fd ff ff       	jmp    15038 <NF_FID_110_101_97_114_101_115_116_46_116_+0x318>
   15297:	0f 28 c4             	movaps xmm0,xmm4
   1529a:	41 bc 04 00 00 00    	mov    r12d,0x4
   152a0:	f3 0f 10 0d f8 cc fe 	movss  xmm1,DWORD PTR [rip+0xfffffffffffeccf8]        # 1fa0 <_IO_stdin_used-0x38>
   152a7:	ff 
   152a8:	0f 28 e0             	movaps xmm4,xmm0
   152ab:	e9 fa 02 00 00       	jmp    155aa <NF_FID_110_101_97_114_101_115_116_46_116_+0x88a>
   152b0:	0f 28 c4             	movaps xmm0,xmm4
   152b3:	41 bc 04 00 00 00    	mov    r12d,0x4
   152b9:	f3 0f 10 0d df cc fe 	movss  xmm1,DWORD PTR [rip+0xfffffffffffeccdf]        # 1fa0 <_IO_stdin_used-0x38>
   152c0:	ff 
   152c1:	0f 28 e0             	movaps xmm4,xmm0
   152c4:	e9 0a 03 00 00       	jmp    155d3 <NF_FID_110_101_97_114_101_115_116_46_116_+0x8b3>
   152c9:	4d 8d 6c 24 f8       	lea    r13,[r12-0x8]
   152ce:	4d 89 ee             	mov    r14,r13
   152d1:	48 b8 00 00 00 00 00 	movabs rax,0x7e00000000000000
   152d8:	00 00 7e 
   152db:	49 21 c6             	and    r14,rax
   152de:	0f 94 c0             	sete   al
   152e1:	4c 89 ed             	mov    rbp,r13
   152e4:	4c 21 d5             	and    rbp,r10
   152e7:	48 81 fd 80 81 10 03 	cmp    rbp,0x3108180
   152ee:	0f 92 c1             	setb   cl
   152f1:	08 c1                	or     cl,al
   152f3:	f3 0f 11 64 24 0c    	movss  DWORD PTR [rsp+0xc],xmm4
   152f9:	75 67                	jne    15362 <NF_FID_110_101_97_114_101_115_116_46_116_+0x642>
   152fb:	4c 89 ff             	mov    rdi,r15
   152fe:	48 8b 74 24 10       	mov    rsi,QWORD PTR [rsp+0x10]
   15303:	4c 89 ea             	mov    rdx,r13
   15306:	e8 d5 1e ff ff       	call   71e0 <term_drop>
   1530b:	f3 0f 10 64 24 0c    	movss  xmm4,DWORD PTR [rsp+0xc]
   15311:	45 0f 57 ff          	xorps  xmm15,xmm15
   15315:	f3 44 0f 10 35 52 cc 	movss  xmm14,DWORD PTR [rip+0xfffffffffffecc52]        # 1f70 <_IO_stdin_used-0x68>
   1531c:	fe ff 
   1531e:	f3 44 0f 10 2d 51 cc 	movss  xmm13,DWORD PTR [rip+0xfffffffffffecc51]        # 1f78 <_IO_stdin_used-0x60>
   15325:	fe ff 
   15327:	f3 44 0f 10 25 58 cc 	movss  xmm12,DWORD PTR [rip+0xfffffffffffecc58]        # 1f88 <_IO_stdin_used-0x50>
   1532e:	fe ff 
   15330:	f3 44 0f 10 5c 24 78 	movss  xmm11,DWORD PTR [rsp+0x78]
   15337:	f3 44 0f 10 54 24 70 	movss  xmm10,DWORD PTR [rsp+0x70]
   1533e:	f3 44 0f 10 4c 24 68 	movss  xmm9,DWORD PTR [rsp+0x68]
   15345:	f3 44 0f 10 44 24 60 	movss  xmm8,DWORD PTR [rsp+0x60]
   1534c:	66 0f 6e 7c 24 04    	movd   xmm7,DWORD PTR [rsp+0x4]
   15352:	66 0f 6e 74 24 08    	movd   xmm6,DWORD PTR [rsp+0x8]
   15358:	49 ba 80 ff ff ff ff 	movabs r10,0xffffffff80
   1535f:	00 00 00 
   15362:	4d 85 e4             	test   r12,r12
   15365:	0f 88 0a 04 00 00    	js     15775 <NF_FID_110_101_97_114_101_115_116_46_116_+0xa55>
   1536b:	48 b8 00 00 00 00 00 	movabs rax,0x200000000000000
   15372:	00 00 02 
   15375:	49 39 c4             	cmp    r12,rax
   15378:	0f 92 c0             	setb   al
   1537b:	4c 89 e1             	mov    rcx,r12
   1537e:	4c 21 d1             	and    rcx,r10
   15381:	48 81 f9 80 81 10 03 	cmp    rcx,0x3108180
   15388:	0f 92 c1             	setb   cl
   1538b:	08 c1                	or     cl,al
   1538d:	0f 85 03 04 00 00    	jne    15796 <NF_FID_110_101_97_114_101_115_116_46_116_+0xa76>
   15393:	4c 89 ff             	mov    rdi,r15
   15396:	48 8b 74 24 10       	mov    rsi,QWORD PTR [rsp+0x10]
   1539b:	4c 89 e2             	mov    rdx,r12
   1539e:	b9 02 00 00 00       	mov    ecx,0x2
   153a3:	e8 56 20 00 00       	call   173fe <rfc_wrap>
   153a8:	f3 0f 10 64 24 0c    	movss  xmm4,DWORD PTR [rsp+0xc]
   153ae:	45 0f 57 ff          	xorps  xmm15,xmm15
   153b2:	f3 44 0f 10 35 b5 cb 	movss  xmm14,DWORD PTR [rip+0xfffffffffffecbb5]        # 1f70 <_IO_stdin_used-0x68>
   153b9:	fe ff 
   153bb:	f3 44 0f 10 2d b4 cb 	movss  xmm13,DWORD PTR [rip+0xfffffffffffecbb4]        # 1f78 <_IO_stdin_used-0x60>
   153c2:	fe ff 
   153c4:	f3 44 0f 10 25 bb cb 	movss  xmm12,DWORD PTR [rip+0xfffffffffffecbbb]        # 1f88 <_IO_stdin_used-0x50>
   153cb:	fe ff 
   153cd:	f3 44 0f 10 5c 24 78 	movss  xmm11,DWORD PTR [rsp+0x78]
   153d4:	f3 44 0f 10 54 24 70 	movss  xmm10,DWORD PTR [rsp+0x70]
   153db:	f3 44 0f 10 4c 24 68 	movss  xmm9,DWORD PTR [rsp+0x68]
   153e2:	f3 44 0f 10 44 24 60 	movss  xmm8,DWORD PTR [rsp+0x60]
   153e9:	66 0f 6e 7c 24 04    	movd   xmm7,DWORD PTR [rsp+0x4]
   153ef:	66 0f 6e 74 24 08    	movd   xmm6,DWORD PTR [rsp+0x8]
   153f5:	49 89 c4             	mov    r12,rax
   153f8:	49 89 c5             	mov    r13,rax
   153fb:	49 83 c5 f8          	add    r13,0xfffffffffffffff8
   153ff:	4d 89 ee             	mov    r14,r13
   15402:	48 b8 00 00 00 00 00 	movabs rax,0x7e00000000000000
   15409:	00 00 7e 
   1540c:	49 21 c6             	and    r14,rax
   1540f:	4c 89 ed             	mov    rbp,r13
   15412:	4c 21 d5             	and    rbp,r10
   15415:	e9 7c 03 00 00       	jmp    15796 <NF_FID_110_101_97_114_101_115_116_46_116_+0xa76>
   1541a:	49 8d 6c 24 f8       	lea    rbp,[r12-0x8]
   1541f:	48 89 eb             	mov    rbx,rbp
   15422:	48 b8 00 00 00 00 00 	movabs rax,0x7e00000000000000
   15429:	00 00 7e 
   1542c:	48 21 c3             	and    rbx,rax
   1542f:	0f 94 c0             	sete   al
   15432:	49 89 ed             	mov    r13,rbp
   15435:	4d 21 d5             	and    r13,r10
   15438:	49 81 fd 80 81 10 03 	cmp    r13,0x3108180
   1543f:	0f 92 c1             	setb   cl
   15442:	08 c1                	or     cl,al
   15444:	f3 0f 11 64 24 0c    	movss  DWORD PTR [rsp+0xc],xmm4
   1544a:	75 67                	jne    154b3 <NF_FID_110_101_97_114_101_115_116_46_116_+0x793>
   1544c:	4c 89 ff             	mov    rdi,r15
   1544f:	48 8b 74 24 10       	mov    rsi,QWORD PTR [rsp+0x10]
   15454:	48 89 ea             	mov    rdx,rbp
   15457:	e8 84 1d ff ff       	call   71e0 <term_drop>
   1545c:	f3 0f 10 64 24 0c    	movss  xmm4,DWORD PTR [rsp+0xc]
   15462:	45 0f 57 ff          	xorps  xmm15,xmm15
   15466:	f3 44 0f 10 35 01 cb 	movss  xmm14,DWORD PTR [rip+0xfffffffffffecb01]        # 1f70 <_IO_stdin_used-0x68>
   1546d:	fe ff 
   1546f:	f3 44 0f 10 2d 00 cb 	movss  xmm13,DWORD PTR [rip+0xfffffffffffecb00]        # 1f78 <_IO_stdin_used-0x60>
   15476:	fe ff 
   15478:	f3 44 0f 10 25 07 cb 	movss  xmm12,DWORD PTR [rip+0xfffffffffffecb07]        # 1f88 <_IO_stdin_used-0x50>
   1547f:	fe ff 
   15481:	f3 44 0f 10 5c 24 78 	movss  xmm11,DWORD PTR [rsp+0x78]
   15488:	f3 44 0f 10 54 24 70 	movss  xmm10,DWORD PTR [rsp+0x70]
   1548f:	f3 44 0f 10 4c 24 68 	movss  xmm9,DWORD PTR [rsp+0x68]
   15496:	f3 44 0f 10 44 24 60 	movss  xmm8,DWORD PTR [rsp+0x60]
   1549d:	66 0f 6e 7c 24 04    	movd   xmm7,DWORD PTR [rsp+0x4]
   154a3:	66 0f 6e 74 24 08    	movd   xmm6,DWORD PTR [rsp+0x8]
   154a9:	49 ba 80 ff ff ff ff 	movabs r10,0xffffffff80
   154b0:	00 00 00 
   154b3:	4d 85 e4             	test   r12,r12
   154b6:	0f 88 f3 04 00 00    	js     159af <NF_FID_110_101_97_114_101_115_116_46_116_+0xc8f>
   154bc:	48 b8 00 00 00 00 00 	movabs rax,0x200000000000000
   154c3:	00 00 02 
   154c6:	49 39 c4             	cmp    r12,rax
   154c9:	0f 92 c0             	setb   al
   154cc:	4c 89 e1             	mov    rcx,r12
   154cf:	4c 21 d1             	and    rcx,r10
   154d2:	48 81 f9 80 81 10 03 	cmp    rcx,0x3108180
   154d9:	0f 92 c1             	setb   cl
   154dc:	08 c1                	or     cl,al
   154de:	0f 85 ec 04 00 00    	jne    159d0 <NF_FID_110_101_97_114_101_115_116_46_116_+0xcb0>
   154e4:	4c 89 ff             	mov    rdi,r15
   154e7:	48 8b 74 24 10       	mov    rsi,QWORD PTR [rsp+0x10]
   154ec:	4c 89 e2             	mov    rdx,r12
   154ef:	b9 02 00 00 00       	mov    ecx,0x2
   154f4:	e8 05 1f 00 00       	call   173fe <rfc_wrap>
   154f9:	f3 0f 10 64 24 0c    	movss  xmm4,DWORD PTR [rsp+0xc]
   154ff:	45 0f 57 ff          	xorps  xmm15,xmm15
   15503:	f3 44 0f 10 35 64 ca 	movss  xmm14,DWORD PTR [rip+0xfffffffffffeca64]        # 1f70 <_IO_stdin_used-0x68>
   1550a:	fe ff 
   1550c:	f3 44 0f 10 2d 63 ca 	movss  xmm13,DWORD PTR [rip+0xfffffffffffeca63]        # 1f78 <_IO_stdin_used-0x60>
   15513:	fe ff 
   15515:	f3 44 0f 10 25 6a ca 	movss  xmm12,DWORD PTR [rip+0xfffffffffffeca6a]        # 1f88 <_IO_stdin_used-0x50>
   1551c:	fe ff 
   1551e:	f3 44 0f 10 5c 24 78 	movss  xmm11,DWORD PTR [rsp+0x78]
   15525:	f3 44 0f 10 54 24 70 	movss  xmm10,DWORD PTR [rsp+0x70]
   1552c:	f3 44 0f 10 4c 24 68 	movss  xmm9,DWORD PTR [rsp+0x68]
   15533:	f3 44 0f 10 44 24 60 	movss  xmm8,DWORD PTR [rsp+0x60]
   1553a:	66 0f 6e 7c 24 04    	movd   xmm7,DWORD PTR [rsp+0x4]
   15540:	66 0f 6e 74 24 08    	movd   xmm6,DWORD PTR [rsp+0x8]
   15546:	49 89 c4             	mov    r12,rax
   15549:	48 89 c5             	mov    rbp,rax
   1554c:	48 83 c5 f8          	add    rbp,0xfffffffffffffff8
   15550:	48 89 eb             	mov    rbx,rbp
   15553:	48 b8 00 00 00 00 00 	movabs rax,0x7e00000000000000
   1555a:	00 00 7e 
   1555d:	48 21 c3             	and    rbx,rax
   15560:	49 89 ed             	mov    r13,rbp
   15563:	4d 21 d5             	and    r13,r10
   15566:	e9 65 04 00 00       	jmp    159d0 <NF_FID_110_101_97_114_101_115_116_46_116_+0xcb0>
   1556b:	0f 57 c9             	xorps  xmm1,xmm1
   1556e:	f3 0f 10 15 52 ca fe 	movss  xmm2,DWORD PTR [rip+0xfffffffffffeca52]        # 1fc8 <_IO_stdin_used-0x10>
   15575:	ff 
   15576:	e9 34 03 00 00       	jmp    158af <NF_FID_110_101_97_114_101_115_116_46_116_+0xb8f>
   1557b:	0f 57 c9             	xorps  xmm1,xmm1
   1557e:	f3 0f 10 15 42 ca fe 	movss  xmm2,DWORD PTR [rip+0xfffffffffffeca42]        # 1fc8 <_IO_stdin_used-0x10>
   15585:	ff 
   15586:	66 2e 0f 1f 84 00 00 	nop    WORD PTR cs:[rax+rax*1+0x0]
   1558d:	00 00 00 
   15590:	41 0f 28 c6          	movaps xmm0,xmm14
   15594:	eb 4d                	jmp    155e3 <NF_FID_110_101_97_114_101_115_116_46_116_+0x8c3>
   15596:	0f 28 d4             	movaps xmm2,xmm4
   15599:	41 bc 05 00 00 00    	mov    r12d,0x5
   1559f:	f3 0f 10 0d f9 c9 fe 	movss  xmm1,DWORD PTR [rip+0xfffffffffffec9f9]        # 1fa0 <_IO_stdin_used-0x38>
   155a6:	ff 
   155a7:	0f 28 e2             	movaps xmm4,xmm2
   155aa:	f3 0f 10 15 42 ca fe 	movss  xmm2,DWORD PTR [rip+0xfffffffffffeca42]        # 1ff4 <_IO_stdin_used+0x1c>
   155b1:	ff 
   155b2:	f3 0f 10 05 22 ca fe 	movss  xmm0,DWORD PTR [rip+0xfffffffffffeca22]        # 1fdc <_IO_stdin_used+0x4>
   155b9:	ff 
   155ba:	e9 f4 02 00 00       	jmp    158b3 <NF_FID_110_101_97_114_101_115_116_46_116_+0xb93>
   155bf:	0f 28 d4             	movaps xmm2,xmm4
   155c2:	41 bc 05 00 00 00    	mov    r12d,0x5
   155c8:	f3 0f 10 0d d0 c9 fe 	movss  xmm1,DWORD PTR [rip+0xfffffffffffec9d0]        # 1fa0 <_IO_stdin_used-0x38>
   155cf:	ff 
   155d0:	0f 28 e2             	movaps xmm4,xmm2
   155d3:	f3 0f 10 15 19 ca fe 	movss  xmm2,DWORD PTR [rip+0xfffffffffffeca19]        # 1ff4 <_IO_stdin_used+0x1c>
   155da:	ff 
   155db:	f3 0f 10 05 f9 c9 fe 	movss  xmm0,DWORD PTR [rip+0xfffffffffffec9f9]        # 1fdc <_IO_stdin_used+0x4>
   155e2:	ff 
   155e3:	66 0f 6f de          	movdqa xmm3,xmm6
   155e7:	f3 0f 5c dc          	subss  xmm3,xmm4
   155eb:	66 0f 6f e7          	movdqa xmm4,xmm7
   155ef:	f3 0f 5c e1          	subss  xmm4,xmm1
   155f3:	41 0f 28 c8          	movaps xmm1,xmm8
   155f7:	f3 0f 5c ca          	subss  xmm1,xmm2
   155fb:	0f 28 d3             	movaps xmm2,xmm3
   155fe:	f3 41 0f 59 d1       	mulss  xmm2,xmm9
   15603:	0f 28 ec             	movaps xmm5,xmm4
   15606:	f3 41 0f 59 ea       	mulss  xmm5,xmm10
   1560b:	f3 0f 58 ea          	addss  xmm5,xmm2
   1560f:	0f 28 d1             	movaps xmm2,xmm1
   15612:	f3 41 0f 59 d3       	mulss  xmm2,xmm11
   15617:	f3 0f 58 d5          	addss  xmm2,xmm5
   1561b:	f3 0f 11 54 24 0c    	movss  DWORD PTR [rsp+0xc],xmm2
   15621:	f3 0f 59 d2          	mulss  xmm2,xmm2
   15625:	f3 0f 59 db          	mulss  xmm3,xmm3
   15629:	f3 0f 59 e4          	mulss  xmm4,xmm4
   1562d:	f3 0f 58 e3          	addss  xmm4,xmm3
   15631:	f3 0f 59 c9          	mulss  xmm1,xmm1
   15635:	f3 0f 58 cc          	addss  xmm1,xmm4
   15639:	f3 0f 5c c1          	subss  xmm0,xmm1
   1563d:	f3 0f 58 c2          	addss  xmm0,xmm2
   15641:	41 bd 28 6b 6e 4e    	mov    r13d,0x4e6e6b28
   15647:	44 0f 2e f8          	ucomiss xmm15,xmm0
   1564b:	0f 87 82 f7 ff ff    	ja     14dd3 <NF_FID_110_101_97_114_101_115_116_46_116_+0xb3>
   15651:	41 0f 2e c7          	ucomiss xmm0,xmm15
   15655:	72 06                	jb     1565d <NF_FID_110_101_97_114_101_115_116_46_116_+0x93d>
   15657:	f3 0f 51 c0          	sqrtss xmm0,xmm0
   1565b:	eb 56                	jmp    156b3 <NF_FID_110_101_97_114_101_115_116_46_116_+0x993>
   1565d:	e8 be 2c 00 00       	call   18320 <sqrtf@plt>
   15662:	45 0f 57 ff          	xorps  xmm15,xmm15
   15666:	f3 44 0f 10 35 01 c9 	movss  xmm14,DWORD PTR [rip+0xfffffffffffec901]        # 1f70 <_IO_stdin_used-0x68>
   1566d:	fe ff 
   1566f:	f3 44 0f 10 2d 00 c9 	movss  xmm13,DWORD PTR [rip+0xfffffffffffec900]        # 1f78 <_IO_stdin_used-0x60>
   15676:	fe ff 
   15678:	f3 44 0f 10 25 07 c9 	movss  xmm12,DWORD PTR [rip+0xfffffffffffec907]        # 1f88 <_IO_stdin_used-0x50>
   1567f:	fe ff 
   15681:	f3 44 0f 10 5c 24 78 	movss  xmm11,DWORD PTR [rsp+0x78]
   15688:	f3 44 0f 10 54 24 70 	movss  xmm10,DWORD PTR [rsp+0x70]
   1568f:	f3 44 0f 10 4c 24 68 	movss  xmm9,DWORD PTR [rsp+0x68]
   15696:	f3 44 0f 10 44 24 60 	movss  xmm8,DWORD PTR [rsp+0x60]
   1569d:	66 0f 6e 7c 24 04    	movd   xmm7,DWORD PTR [rsp+0x4]
   156a3:	66 0f 6e 74 24 08    	movd   xmm6,DWORD PTR [rsp+0x8]
   156a9:	49 ba 80 ff ff ff ff 	movabs r10,0xffffffff80
   156b0:	00 00 00 
   156b3:	f3 0f 10 54 24 0c    	movss  xmm2,DWORD PTR [rsp+0xc]
   156b9:	0f 57 c9             	xorps  xmm1,xmm1
   156bc:	f3 0f 5c ca          	subss  xmm1,xmm2
   156c0:	f3 0f 5c c8          	subss  xmm1,xmm0
   156c4:	f3 0f 10 05 2c c9 fe 	movss  xmm0,DWORD PTR [rip+0xfffffffffffec92c]        # 1ff8 <_IO_stdin_used+0x20>
   156cb:	ff 
   156cc:	0f 2e c1             	ucomiss xmm0,xmm1
   156cf:	0f 87 fe f6 ff ff    	ja     14dd3 <NF_FID_110_101_97_114_101_115_116_46_116_+0xb3>
   156d5:	66 41 0f 7e cd       	movd   r13d,xmm1
   156da:	e9 f4 f6 ff ff       	jmp    14dd3 <NF_FID_110_101_97_114_101_115_116_46_116_+0xb3>
   156df:	f3 0f 10 0d e5 c8 fe 	movss  xmm1,DWORD PTR [rip+0xfffffffffffec8e5]        # 1fcc <_IO_stdin_used-0xc>
   156e6:	ff 
   156e7:	f3 0f 10 15 e1 c8 fe 	movss  xmm2,DWORD PTR [rip+0xfffffffffffec8e1]        # 1fd0 <_IO_stdin_used-0x8>
   156ee:	ff 
   156ef:	f3 0f 10 05 f1 c8 fe 	movss  xmm0,DWORD PTR [rip+0xfffffffffffec8f1]        # 1fe8 <_IO_stdin_used+0x10>
   156f6:	ff 
   156f7:	e9 b7 01 00 00       	jmp    158b3 <NF_FID_110_101_97_114_101_115_116_46_116_+0xb93>
   156fc:	f3 0f 10 0d c8 c8 fe 	movss  xmm1,DWORD PTR [rip+0xfffffffffffec8c8]        # 1fcc <_IO_stdin_used-0xc>
   15703:	ff 
   15704:	f3 0f 10 15 c4 c8 fe 	movss  xmm2,DWORD PTR [rip+0xfffffffffffec8c4]        # 1fd0 <_IO_stdin_used-0x8>
   1570b:	ff 
   1570c:	f3 0f 10 05 d4 c8 fe 	movss  xmm0,DWORD PTR [rip+0xfffffffffffec8d4]        # 1fe8 <_IO_stdin_used+0x10>
   15713:	ff 
   15714:	e9 ca fe ff ff       	jmp    155e3 <NF_FID_110_101_97_114_101_115_116_46_116_+0x8c3>
   15719:	4c 89 e0             	mov    rax,r12
   1571c:	48 23 44 24 18       	and    rax,QWORD PTR [rsp+0x18]
   15721:	b9 01 00 00 00       	mov    ecx,0x1
   15726:	f0 41 0f c1 0c c7    	lock xadd DWORD PTR [r15+rax*8],ecx
   1572c:	f7 d1                	not    ecx
   1572e:	f3 0f 10 25 82 c8 fe 	movss  xmm4,DWORD PTR [rip+0xfffffffffffec882]        # 1fb8 <_IO_stdin_used-0x20>
   15735:	ff 
   15736:	f7 c1 fe ff ff 00    	test   ecx,0xfffffe
   1573c:	0f 85 5c f8 ff ff    	jne    14f9e <NF_FID_110_101_97_114_101_115_116_46_116_+0x27e>
   15742:	e9 a8 04 00 00       	jmp    15bef <NF_FID_110_101_97_114_101_115_116_46_116_+0xecf>
   15747:	4c 89 e0             	mov    rax,r12
   1574a:	48 23 44 24 18       	and    rax,QWORD PTR [rsp+0x18]
   1574f:	b9 01 00 00 00       	mov    ecx,0x1
   15754:	f0 41 0f c1 0c c7    	lock xadd DWORD PTR [r15+rax*8],ecx
   1575a:	f7 d1                	not    ecx
   1575c:	f3 0f 10 25 54 c8 fe 	movss  xmm4,DWORD PTR [rip+0xfffffffffffec854]        # 1fb8 <_IO_stdin_used-0x20>
   15763:	ff 
   15764:	f7 c1 fe ff ff 00    	test   ecx,0xfffffe
   1576a:	0f 85 c8 f8 ff ff    	jne    15038 <NF_FID_110_101_97_114_101_115_116_46_116_+0x318>
   15770:	e9 7a 04 00 00       	jmp    15bef <NF_FID_110_101_97_114_101_115_116_46_116_+0xecf>
   15775:	4c 89 e0             	mov    rax,r12
   15778:	48 23 44 24 18       	and    rax,QWORD PTR [rsp+0x18]
   1577d:	b9 01 00 00 00       	mov    ecx,0x1
   15782:	f0 41 0f c1 0c c7    	lock xadd DWORD PTR [r15+rax*8],ecx
   15788:	f7 d1                	not    ecx
   1578a:	f7 c1 fe ff ff 00    	test   ecx,0xfffffe
   15790:	0f 84 59 04 00 00    	je     15bef <NF_FID_110_101_97_114_101_115_116_46_116_+0xecf>
   15796:	4d 85 f6             	test   r14,r14
   15799:	0f 94 c0             	sete   al
   1579c:	48 81 fd 80 81 10 03 	cmp    rbp,0x3108180
   157a3:	0f 92 c1             	setb   cl
   157a6:	08 c1                	or     cl,al
   157a8:	48 8b 6c 24 10       	mov    rbp,QWORD PTR [rsp+0x10]
   157ad:	75 65                	jne    15814 <NF_FID_110_101_97_114_101_115_116_46_116_+0xaf4>
   157af:	4c 89 ff             	mov    rdi,r15
   157b2:	48 89 ee             	mov    rsi,rbp
   157b5:	4c 89 ea             	mov    rdx,r13
   157b8:	e8 23 1a ff ff       	call   71e0 <term_drop>
   157bd:	f3 0f 10 64 24 0c    	movss  xmm4,DWORD PTR [rsp+0xc]
   157c3:	45 0f 57 ff          	xorps  xmm15,xmm15
   157c7:	f3 44 0f 10 35 a0 c7 	movss  xmm14,DWORD PTR [rip+0xfffffffffffec7a0]        # 1f70 <_IO_stdin_used-0x68>
   157ce:	fe ff 
   157d0:	f3 44 0f 10 2d 9f c7 	movss  xmm13,DWORD PTR [rip+0xfffffffffffec79f]        # 1f78 <_IO_stdin_used-0x60>
   157d7:	fe ff 
   157d9:	f3 44 0f 10 25 a6 c7 	movss  xmm12,DWORD PTR [rip+0xfffffffffffec7a6]        # 1f88 <_IO_stdin_used-0x50>
   157e0:	fe ff 
   157e2:	f3 44 0f 10 5c 24 78 	movss  xmm11,DWORD PTR [rsp+0x78]
   157e9:	f3 44 0f 10 54 24 70 	movss  xmm10,DWORD PTR [rsp+0x70]
   157f0:	f3 44 0f 10 4c 24 68 	movss  xmm9,DWORD PTR [rsp+0x68]
   157f7:	f3 44 0f 10 44 24 60 	movss  xmm8,DWORD PTR [rsp+0x60]
   157fe:	66 0f 6e 7c 24 04    	movd   xmm7,DWORD PTR [rsp+0x4]
   15804:	66 0f 6e 74 24 08    	movd   xmm6,DWORD PTR [rsp+0x8]
   1580a:	49 ba 80 ff ff ff ff 	movabs r10,0xffffffff80
   15811:	00 00 00 
   15814:	49 8d 54 24 f8       	lea    rdx,[r12-0x8]
   15819:	48 b8 00 00 00 00 00 	movabs rax,0x7e00000000000000
   15820:	00 00 7e 
   15823:	48 85 c2             	test   rdx,rax
   15826:	0f 94 c0             	sete   al
   15829:	48 89 d1             	mov    rcx,rdx
   1582c:	4c 21 d1             	and    rcx,r10
   1582f:	48 81 f9 80 81 10 03 	cmp    rcx,0x3108180
   15836:	0f 92 c1             	setb   cl
   15839:	08 c1                	or     cl,al
   1583b:	75 62                	jne    1589f <NF_FID_110_101_97_114_101_115_116_46_116_+0xb7f>
   1583d:	4c 89 ff             	mov    rdi,r15
   15840:	48 89 ee             	mov    rsi,rbp
   15843:	e8 98 19 ff ff       	call   71e0 <term_drop>
   15848:	f3 0f 10 64 24 0c    	movss  xmm4,DWORD PTR [rsp+0xc]
   1584e:	45 0f 57 ff          	xorps  xmm15,xmm15
   15852:	f3 44 0f 10 35 15 c7 	movss  xmm14,DWORD PTR [rip+0xfffffffffffec715]        # 1f70 <_IO_stdin_used-0x68>
   15859:	fe ff 
   1585b:	f3 44 0f 10 2d 14 c7 	movss  xmm13,DWORD PTR [rip+0xfffffffffffec714]        # 1f78 <_IO_stdin_used-0x60>
   15862:	fe ff 
   15864:	f3 44 0f 10 25 1b c7 	movss  xmm12,DWORD PTR [rip+0xfffffffffffec71b]        # 1f88 <_IO_stdin_used-0x50>
   1586b:	fe ff 
   1586d:	f3 44 0f 10 5c 24 78 	movss  xmm11,DWORD PTR [rsp+0x78]
   15874:	f3 44 0f 10 54 24 70 	movss  xmm10,DWORD PTR [rsp+0x70]
   1587b:	f3 44 0f 10 4c 24 68 	movss  xmm9,DWORD PTR [rsp+0x68]
   15882:	f3 44 0f 10 44 24 60 	movss  xmm8,DWORD PTR [rsp+0x60]
   15889:	66 0f 6e 7c 24 04    	movd   xmm7,DWORD PTR [rsp+0x4]
   1588f:	66 0f 6e 74 24 08    	movd   xmm6,DWORD PTR [rsp+0x8]
   15895:	49 ba 80 ff ff ff ff 	movabs r10,0xffffffff80
   1589c:	00 00 00 
   1589f:	f3 0f 10 0d 15 c7 fe 	movss  xmm1,DWORD PTR [rip+0xfffffffffffec715]        # 1fbc <_IO_stdin_used-0x1c>
   158a6:	ff 
   158a7:	f3 0f 10 15 cd c6 fe 	movss  xmm2,DWORD PTR [rip+0xfffffffffffec6cd]        # 1f7c <_IO_stdin_used-0x5c>
   158ae:	ff 
   158af:	41 0f 28 c6          	movaps xmm0,xmm14
   158b3:	66 0f 6f de          	movdqa xmm3,xmm6
   158b7:	f3 0f 5c dc          	subss  xmm3,xmm4
   158bb:	66 0f 6f e7          	movdqa xmm4,xmm7
   158bf:	f3 0f 5c e1          	subss  xmm4,xmm1
   158c3:	41 0f 28 c8          	movaps xmm1,xmm8
   158c7:	f3 0f 5c ca          	subss  xmm1,xmm2
   158cb:	0f 28 d3             	movaps xmm2,xmm3
   158ce:	f3 41 0f 59 d1       	mulss  xmm2,xmm9
   158d3:	0f 28 ec             	movaps xmm5,xmm4
   158d6:	f3 41 0f 59 ea       	mulss  xmm5,xmm10
   158db:	f3 0f 58 ea          	addss  xmm5,xmm2
   158df:	0f 28 d1             	movaps xmm2,xmm1
   158e2:	f3 41 0f 59 d3       	mulss  xmm2,xmm11
   158e7:	f3 0f 58 d5          	addss  xmm2,xmm5
   158eb:	f3 0f 11 54 24 0c    	movss  DWORD PTR [rsp+0xc],xmm2
   158f1:	f3 0f 59 d2          	mulss  xmm2,xmm2
   158f5:	f3 0f 59 db          	mulss  xmm3,xmm3
   158f9:	f3 0f 59 e4          	mulss  xmm4,xmm4
   158fd:	f3 0f 58 e3          	addss  xmm4,xmm3
   15901:	f3 0f 59 c9          	mulss  xmm1,xmm1
   15905:	f3 0f 58 cc          	addss  xmm1,xmm4
   15909:	f3 0f 5c c1          	subss  xmm0,xmm1
   1590d:	f3 0f 58 c2          	addss  xmm0,xmm2
   15911:	41 bd 28 6b 6e 4e    	mov    r13d,0x4e6e6b28
   15917:	44 0f 2e f8          	ucomiss xmm15,xmm0
   1591b:	0f 87 af f4 ff ff    	ja     14dd0 <NF_FID_110_101_97_114_101_115_116_46_116_+0xb0>
   15921:	41 0f 2e c7          	ucomiss xmm0,xmm15
   15925:	72 06                	jb     1592d <NF_FID_110_101_97_114_101_115_116_46_116_+0xc0d>
   15927:	f3 0f 51 c0          	sqrtss xmm0,xmm0
   1592b:	eb 56                	jmp    15983 <NF_FID_110_101_97_114_101_115_116_46_116_+0xc63>
   1592d:	e8 ee 29 00 00       	call   18320 <sqrtf@plt>
   15932:	45 0f 57 ff          	xorps  xmm15,xmm15
   15936:	f3 44 0f 10 35 31 c6 	movss  xmm14,DWORD PTR [rip+0xfffffffffffec631]        # 1f70 <_IO_stdin_used-0x68>
   1593d:	fe ff 
   1593f:	f3 44 0f 10 2d 30 c6 	movss  xmm13,DWORD PTR [rip+0xfffffffffffec630]        # 1f78 <_IO_stdin_used-0x60>
   15946:	fe ff 
   15948:	f3 44 0f 10 25 37 c6 	movss  xmm12,DWORD PTR [rip+0xfffffffffffec637]        # 1f88 <_IO_stdin_used-0x50>
   1594f:	fe ff 
   15951:	f3 44 0f 10 5c 24 78 	movss  xmm11,DWORD PTR [rsp+0x78]
   15958:	f3 44 0f 10 54 24 70 	movss  xmm10,DWORD PTR [rsp+0x70]
   1595f:	f3 44 0f 10 4c 24 68 	movss  xmm9,DWORD PTR [rsp+0x68]
   15966:	f3 44 0f 10 44 24 60 	movss  xmm8,DWORD PTR [rsp+0x60]
   1596d:	66 0f 6e 7c 24 04    	movd   xmm7,DWORD PTR [rsp+0x4]
   15973:	66 0f 6e 74 24 08    	movd   xmm6,DWORD PTR [rsp+0x8]
   15979:	49 ba 80 ff ff ff ff 	movabs r10,0xffffffff80
   15980:	00 00 00 
   15983:	f3 0f 10 54 24 0c    	movss  xmm2,DWORD PTR [rsp+0xc]
   15989:	0f 57 c9             	xorps  xmm1,xmm1
   1598c:	f3 0f 5c ca          	subss  xmm1,xmm2
   15990:	f3 0f 5c c8          	subss  xmm1,xmm0
   15994:	f3 0f 10 05 5c c6 fe 	movss  xmm0,DWORD PTR [rip+0xfffffffffffec65c]        # 1ff8 <_IO_stdin_used+0x20>
   1599b:	ff 
   1599c:	0f 2e c1             	ucomiss xmm0,xmm1
   1599f:	0f 87 2b f4 ff ff    	ja     14dd0 <NF_FID_110_101_97_114_101_115_116_46_116_+0xb0>
   159a5:	66 41 0f 7e cd       	movd   r13d,xmm1
   159aa:	e9 21 f4 ff ff       	jmp    14dd0 <NF_FID_110_101_97_114_101_115_116_46_116_+0xb0>
   159af:	4c 89 e0             	mov    rax,r12
   159b2:	48 23 44 24 18       	and    rax,QWORD PTR [rsp+0x18]
   159b7:	b9 01 00 00 00       	mov    ecx,0x1
   159bc:	f0 41 0f c1 0c c7    	lock xadd DWORD PTR [r15+rax*8],ecx
   159c2:	f7 d1                	not    ecx
   159c4:	f7 c1 fe ff ff 00    	test   ecx,0xfffffe
   159ca:	0f 84 1f 02 00 00    	je     15bef <NF_FID_110_101_97_114_101_115_116_46_116_+0xecf>
   159d0:	48 85 db             	test   rbx,rbx
   159d3:	0f 94 c0             	sete   al
   159d6:	49 81 fd 80 81 10 03 	cmp    r13,0x3108180
   159dd:	0f 92 c1             	setb   cl
   159e0:	08 c1                	or     cl,al
   159e2:	75 67                	jne    15a4b <NF_FID_110_101_97_114_101_115_116_46_116_+0xd2b>
   159e4:	4c 89 ff             	mov    rdi,r15
   159e7:	48 8b 74 24 10       	mov    rsi,QWORD PTR [rsp+0x10]
   159ec:	48 89 ea             	mov    rdx,rbp
   159ef:	e8 ec 17 ff ff       	call   71e0 <term_drop>
   159f4:	f3 0f 10 64 24 0c    	movss  xmm4,DWORD PTR [rsp+0xc]
   159fa:	45 0f 57 ff          	xorps  xmm15,xmm15
   159fe:	f3 44 0f 10 35 69 c5 	movss  xmm14,DWORD PTR [rip+0xfffffffffffec569]        # 1f70 <_IO_stdin_used-0x68>
   15a05:	fe ff 
   15a07:	f3 44 0f 10 2d 68 c5 	movss  xmm13,DWORD PTR [rip+0xfffffffffffec568]        # 1f78 <_IO_stdin_used-0x60>
   15a0e:	fe ff 
   15a10:	f3 44 0f 10 25 6f c5 	movss  xmm12,DWORD PTR [rip+0xfffffffffffec56f]        # 1f88 <_IO_stdin_used-0x50>
   15a17:	fe ff 
   15a19:	f3 44 0f 10 5c 24 78 	movss  xmm11,DWORD PTR [rsp+0x78]
   15a20:	f3 44 0f 10 54 24 70 	movss  xmm10,DWORD PTR [rsp+0x70]
   15a27:	f3 44 0f 10 4c 24 68 	movss  xmm9,DWORD PTR [rsp+0x68]
   15a2e:	f3 44 0f 10 44 24 60 	movss  xmm8,DWORD PTR [rsp+0x60]
   15a35:	66 0f 6e 7c 24 04    	movd   xmm7,DWORD PTR [rsp+0x4]
   15a3b:	66 0f 6e 74 24 08    	movd   xmm6,DWORD PTR [rsp+0x8]
   15a41:	49 ba 80 ff ff ff ff 	movabs r10,0xffffffff80
   15a48:	00 00 00 
   15a4b:	49 8d 54 24 f8       	lea    rdx,[r12-0x8]
   15a50:	48 b8 00 00 00 00 00 	movabs rax,0x7e00000000000000
   15a57:	00 00 7e 
   15a5a:	48 85 c2             	test   rdx,rax
   15a5d:	0f 94 c0             	sete   al
   15a60:	48 89 d1             	mov    rcx,rdx
   15a63:	4c 21 d1             	and    rcx,r10
   15a66:	48 81 f9 80 81 10 03 	cmp    rcx,0x3108180
   15a6d:	0f 92 c1             	setb   cl
   15a70:	08 c1                	or     cl,al
   15a72:	74 1e                	je     15a92 <NF_FID_110_101_97_114_101_115_116_46_116_+0xd72>
   15a74:	f3 0f 10 0d 40 c5 fe 	movss  xmm1,DWORD PTR [rip+0xfffffffffffec540]        # 1fbc <_IO_stdin_used-0x1c>
   15a7b:	ff 
   15a7c:	f3 0f 10 15 f8 c4 fe 	movss  xmm2,DWORD PTR [rip+0xfffffffffffec4f8]        # 1f7c <_IO_stdin_used-0x5c>
   15a83:	ff 
   15a84:	41 0f 28 c6          	movaps xmm0,xmm14
   15a88:	48 8b 6c 24 10       	mov    rbp,QWORD PTR [rsp+0x10]
   15a8d:	e9 51 fb ff ff       	jmp    155e3 <NF_FID_110_101_97_114_101_115_116_46_116_+0x8c3>
   15a92:	4c 89 ff             	mov    rdi,r15
   15a95:	48 8b 6c 24 10       	mov    rbp,QWORD PTR [rsp+0x10]
   15a9a:	48 89 ee             	mov    rsi,rbp
   15a9d:	e8 3e 17 ff ff       	call   71e0 <term_drop>
   15aa2:	f3 0f 10 64 24 0c    	movss  xmm4,DWORD PTR [rsp+0xc]
   15aa8:	45 0f 57 ff          	xorps  xmm15,xmm15
   15aac:	f3 44 0f 10 35 bb c4 	movss  xmm14,DWORD PTR [rip+0xfffffffffffec4bb]        # 1f70 <_IO_stdin_used-0x68>
   15ab3:	fe ff 
   15ab5:	f3 44 0f 10 2d ba c4 	movss  xmm13,DWORD PTR [rip+0xfffffffffffec4ba]        # 1f78 <_IO_stdin_used-0x60>
   15abc:	fe ff 
   15abe:	f3 44 0f 10 25 c1 c4 	movss  xmm12,DWORD PTR [rip+0xfffffffffffec4c1]        # 1f88 <_IO_stdin_used-0x50>
   15ac5:	fe ff 
   15ac7:	f3 44 0f 10 5c 24 78 	movss  xmm11,DWORD PTR [rsp+0x78]
   15ace:	f3 44 0f 10 54 24 70 	movss  xmm10,DWORD PTR [rsp+0x70]
   15ad5:	f3 44 0f 10 4c 24 68 	movss  xmm9,DWORD PTR [rsp+0x68]
   15adc:	f3 44 0f 10 44 24 60 	movss  xmm8,DWORD PTR [rsp+0x60]
   15ae3:	66 0f 6e 7c 24 04    	movd   xmm7,DWORD PTR [rsp+0x4]
   15ae9:	66 0f 6e 74 24 08    	movd   xmm6,DWORD PTR [rsp+0x8]
   15aef:	49 ba 80 ff ff ff ff 	movabs r10,0xffffffff80
   15af6:	00 00 00 
   15af9:	f3 0f 10 0d bb c4 fe 	movss  xmm1,DWORD PTR [rip+0xfffffffffffec4bb]        # 1fbc <_IO_stdin_used-0x1c>
   15b00:	ff 
   15b01:	e9 c4 f5 ff ff       	jmp    150ca <NF_FID_110_101_97_114_101_115_116_46_116_+0x3aa>
   15b06:	4c 89 ff             	mov    rdi,r15
   15b09:	48 89 ee             	mov    rsi,rbp
   15b0c:	4c 89 e2             	mov    rdx,r12
   15b0f:	b9 02 00 00 00       	mov    ecx,0x2
   15b14:	e8 e5 18 00 00       	call   173fe <rfc_wrap>
   15b19:	45 0f 57 ff          	xorps  xmm15,xmm15
   15b1d:	f3 44 0f 10 35 4a c4 	movss  xmm14,DWORD PTR [rip+0xfffffffffffec44a]        # 1f70 <_IO_stdin_used-0x68>
   15b24:	fe ff 
   15b26:	f3 44 0f 10 2d 49 c4 	movss  xmm13,DWORD PTR [rip+0xfffffffffffec449]        # 1f78 <_IO_stdin_used-0x60>
   15b2d:	fe ff 
   15b2f:	f3 44 0f 10 25 50 c4 	movss  xmm12,DWORD PTR [rip+0xfffffffffffec450]        # 1f88 <_IO_stdin_used-0x50>
   15b36:	fe ff 
   15b38:	f3 44 0f 10 5c 24 78 	movss  xmm11,DWORD PTR [rsp+0x78]
   15b3f:	f3 44 0f 10 54 24 70 	movss  xmm10,DWORD PTR [rsp+0x70]
   15b46:	f3 44 0f 10 4c 24 68 	movss  xmm9,DWORD PTR [rsp+0x68]
   15b4d:	f3 44 0f 10 44 24 60 	movss  xmm8,DWORD PTR [rsp+0x60]
   15b54:	66 0f 6e 7c 24 04    	movd   xmm7,DWORD PTR [rsp+0x4]
   15b5a:	66 0f 6e 74 24 08    	movd   xmm6,DWORD PTR [rsp+0x8]
   15b60:	49 89 c4             	mov    r12,rax
   15b63:	e9 5f f6 ff ff       	jmp    151c7 <NF_FID_110_101_97_114_101_115_116_46_116_+0x4a7>
   15b68:	4c 89 ff             	mov    rdi,r15
   15b6b:	48 89 ee             	mov    rsi,rbp
   15b6e:	4c 89 e2             	mov    rdx,r12
   15b71:	b9 02 00 00 00       	mov    ecx,0x2
   15b76:	e8 83 18 00 00       	call   173fe <rfc_wrap>
   15b7b:	45 0f 57 ff          	xorps  xmm15,xmm15
   15b7f:	f3 44 0f 10 35 e8 c3 	movss  xmm14,DWORD PTR [rip+0xfffffffffffec3e8]        # 1f70 <_IO_stdin_used-0x68>
   15b86:	fe ff 
   15b88:	f3 44 0f 10 2d e7 c3 	movss  xmm13,DWORD PTR [rip+0xfffffffffffec3e7]        # 1f78 <_IO_stdin_used-0x60>
   15b8f:	fe ff 
   15b91:	f3 44 0f 10 25 ee c3 	movss  xmm12,DWORD PTR [rip+0xfffffffffffec3ee]        # 1f88 <_IO_stdin_used-0x50>
   15b98:	fe ff 
   15b9a:	f3 44 0f 10 5c 24 78 	movss  xmm11,DWORD PTR [rsp+0x78]
   15ba1:	f3 44 0f 10 54 24 70 	movss  xmm10,DWORD PTR [rsp+0x70]
   15ba8:	f3 44 0f 10 4c 24 68 	movss  xmm9,DWORD PTR [rsp+0x68]
   15baf:	f3 44 0f 10 44 24 60 	movss  xmm8,DWORD PTR [rsp+0x60]
   15bb6:	66 0f 6e 7c 24 04    	movd   xmm7,DWORD PTR [rsp+0x4]
   15bbc:	66 0f 6e 74 24 08    	movd   xmm6,DWORD PTR [rsp+0x8]
   15bc2:	49 89 c4             	mov    r12,rax
   15bc5:	e9 c0 f6 ff ff       	jmp    1528a <NF_FID_110_101_97_114_101_115_116_46_116_+0x56a>
   15bca:	41 89 dd             	mov    r13d,ebx
   15bcd:	84 c0                	test   al,al
   15bcf:	45 0f 45 f5          	cmovne r14d,r13d
   15bd3:	48 8b 44 24 20       	mov    rax,QWORD PTR [rsp+0x20]
   15bd8:	4c 89 30             	mov    QWORD PTR [rax],r14
   15bdb:	b8 01 00 00 00       	mov    eax,0x1
   15be0:	48 83 c4 28          	add    rsp,0x28
   15be4:	5b                   	pop    rbx
   15be5:	41 5c                	pop    r12
   15be7:	41 5d                	pop    r13
   15be9:	41 5e                	pop    r14
   15beb:	41 5f                	pop    r15
   15bed:	5d                   	pop    rbp
   15bee:	c3                   	ret    
   15bef:	48 8d 3d 62 d3 fe ff 	lea    rdi,[rip+0xfffffffffffed362]        # 2f58 <FID_RESW_T+0x848>
   15bf6:	e8 75 13 00 00       	call   16f70 <err_fail>

Disassembly of section .init:

Disassembly of section .fini:

Disassembly of section .plt:
