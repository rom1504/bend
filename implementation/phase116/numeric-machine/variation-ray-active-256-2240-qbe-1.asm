
/home/ai/bend2/build/publish/bend/selfhost/build/phase111/p114-final-screen01-variation-ray-active-256-2240-build/program:     file format elf64-x86-64


Disassembly of section .init:

Disassembly of section .plt:

Disassembly of section .text:

0000000000405fa0 <p113d_FID_36_112_114_111_100_117_99_116_46_110_101_97_114_101_115_116_>:
  405fa0:	f3 0f 1e fa          	endbr64 
  405fa4:	55                   	push   rbp
  405fa5:	48 89 e5             	mov    rbp,rsp
  405fa8:	48 81 ec e8 08 00 00 	sub    rsp,0x8e8
  405faf:	53                   	push   rbx
  405fb0:	41 54                	push   r12
  405fb2:	41 55                	push   r13
  405fb4:	41 56                	push   r14
  405fb6:	41 57                	push   r15
  405fb8:	48 8b 5d 48          	mov    rbx,QWORD PTR [rbp+0x48]
  405fbc:	4c 8b 65 40          	mov    r12,QWORD PTR [rbp+0x40]
  405fc0:	4c 8b 55 38          	mov    r10,QWORD PTR [rbp+0x38]
  405fc4:	48 8b 45 30          	mov    rax,QWORD PTR [rbp+0x30]
  405fc8:	4d 89 d3             	mov    r11,r10
  405fcb:	4c 8b 55 28          	mov    r10,QWORD PTR [rbp+0x28]
  405fcf:	4c 8b 6d 20          	mov    r13,QWORD PTR [rbp+0x20]
  405fd3:	4c 8b 75 18          	mov    r14,QWORD PTR [rbp+0x18]
  405fd7:	4c 8b 7d 10          	mov    r15,QWORD PTR [rbp+0x10]
  405fdb:	48 87 ca             	xchg   rdx,rcx
  405fde:	4c 87 c1             	xchg   rcx,r8
  405fe1:	49 87 d8             	xchg   r8,rbx
  405fe4:	48 89 b5 38 ff ff ff 	mov    QWORD PTR [rbp-0xc8],rsi
  405feb:	48 89 c6             	mov    rsi,rax
  405fee:	4c 89 c8             	mov    rax,r9
  405ff1:	41 b9 00 00 80 3f    	mov    r9d,0x3f800000
  405ff7:	4c 89 8d 70 ff ff ff 	mov    QWORD PTR [rbp-0x90],r9
  405ffe:	41 b9 00 00 00 41    	mov    r9d,0x41000000
  406004:	4c 89 8d 20 ff ff ff 	mov    QWORD PTR [rbp-0xe0],r9
  40600b:	41 b9 cd cc 4c 3e    	mov    r9d,0x3e4ccccd
  406011:	4c 89 8d 28 ff ff ff 	mov    QWORD PTR [rbp-0xd8],r9
  406018:	41 b9 00 00 60 c0    	mov    r9d,0xc0600000
  40601e:	4c 89 8d 30 ff ff ff 	mov    QWORD PTR [rbp-0xd0],r9
  406025:	4c 89 55 c8          	mov    QWORD PTR [rbp-0x38],r10
  406029:	48 89 75 d8          	mov    QWORD PTR [rbp-0x28],rsi
  40602d:	4c 89 9d 58 ff ff ff 	mov    QWORD PTR [rbp-0xa8],r11
  406034:	4c 89 a5 68 ff ff ff 	mov    QWORD PTR [rbp-0x98],r12
  40603b:	49 89 fc             	mov    r12,rdi
  40603e:	66 90                	xchg   ax,ax
  406040:	48 89 95 50 ff ff ff 	mov    QWORD PTR [rbp-0xb0],rdx
  406047:	48 89 8d 48 ff ff ff 	mov    QWORD PTR [rbp-0xb8],rcx
  40604e:	48 89 85 40 ff ff ff 	mov    QWORD PTR [rbp-0xc0],rax
  406055:	48 83 fb 00          	cmp    rbx,0x0
  406059:	4d 89 c3             	mov    r11,r8
  40605c:	41 0f 94 c0          	sete   r8b
  406060:	45 0f b6 c0          	movzx  r8d,r8b
  406064:	49 83 fb 01          	cmp    r11,0x1
  406068:	49 89 c2             	mov    r10,rax
  40606b:	0f 94 c0             	sete   al
  40606e:	0f b6 c0             	movzx  eax,al
  406071:	4c 89 de             	mov    rsi,r11
  406074:	48 c1 ee 28          	shr    rsi,0x28
  406078:	48 81 e6 ff ff 7f 00 	and    rsi,0x7fffff
  40607f:	48 81 fe 02 00 01 00 	cmp    rsi,0x10002
  406086:	40 0f 94 c6          	sete   sil
  40608a:	40 0f b6 f6          	movzx  esi,sil
  40608e:	89 c7                	mov    edi,eax
  406090:	09 f7                	or     edi,esi
  406092:	41 83 f8 00          	cmp    r8d,0x0
  406096:	0f 85 49 05 00 00    	jne    4065e5 <p113d_FID_36_112_114_111_100_117_99_116_46_110_101_97_114_101_115_116_+0x645>
  40609c:	49 89 d9             	mov    r9,rbx
  40609f:	48 83 eb 01          	sub    rbx,0x1
  4060a3:	83 f7 01             	xor    edi,0x1
  4060a6:	0f 85 5d 01 00 00    	jne    406209 <p113d_FID_36_112_114_111_100_117_99_116_46_110_101_97_114_101_115_116_+0x269>
  4060ac:	89 f1                	mov    ecx,esi
  4060ae:	09 c8                	or     eax,ecx
  4060b0:	0f 84 1e 01 00 00    	je     4061d4 <p113d_FID_36_112_114_111_100_117_99_116_46_110_101_97_114_101_115_116_+0x234>
  4060b6:	48 89 de             	mov    rsi,rbx
  4060b9:	4c 89 e7             	mov    rdi,r12
  4060bc:	e8 4f fd ff ff       	call   405e10 <p113d_FID_36_100_105_114_101_99_116_46_115_120_>
  4060c1:	48 89 45 e0          	mov    QWORD PTR [rbp-0x20],rax
  4060c5:	48 89 de             	mov    rsi,rbx
  4060c8:	4c 89 e7             	mov    rdi,r12
  4060cb:	e8 f0 fb ff ff       	call   405cc0 <p113d_FID_36_100_105_114_101_99_116_46_115_121_>
  4060d0:	48 89 45 e8          	mov    QWORD PTR [rbp-0x18],rax
  4060d4:	48 89 de             	mov    rsi,rbx
  4060d7:	4c 89 e7             	mov    rdi,r12
  4060da:	e8 31 fb ff ff       	call   405c10 <p113d_FID_36_100_105_114_101_99_116_46_115_122_>
  4060df:	48 89 45 f0          	mov    QWORD PTR [rbp-0x10],rax
  4060e3:	48 89 de             	mov    rsi,rbx
  4060e6:	4c 89 e7             	mov    rdi,r12
  4060e9:	e8 72 fa ff ff       	call   405b60 <p113d_FID_36_100_105_114_101_99_116_46_115_114_>
  4060ee:	49 89 c0             	mov    r8,rax
  4060f1:	48 8b 95 50 ff ff ff 	mov    rdx,QWORD PTR [rbp-0xb0]
  4060f8:	48 8b 8d 48 ff ff ff 	mov    rcx,QWORD PTR [rbp-0xb8]
  4060ff:	4c 8b 95 40 ff ff ff 	mov    r10,QWORD PTR [rbp-0xc0]
  406106:	48 89 cf             	mov    rdi,rcx
  406109:	48 8b 4d f0          	mov    rcx,QWORD PTR [rbp-0x10]
  40610d:	48 89 d0             	mov    rax,rdx
  406110:	48 8b 55 e8          	mov    rdx,QWORD PTR [rbp-0x18]
  406114:	48 8b 75 e0          	mov    rsi,QWORD PTR [rbp-0x20]
  406118:	48 83 ec 30          	sub    rsp,0x30
  40611c:	49 89 e1             	mov    r9,rsp
  40611f:	4d 89 69 20          	mov    QWORD PTR [r9+0x20],r13
  406123:	4d 89 71 18          	mov    QWORD PTR [r9+0x18],r14
  406127:	4d 89 79 10          	mov    QWORD PTR [r9+0x10],r15
  40612b:	4d 89 51 08          	mov    QWORD PTR [r9+0x8],r10
  40612f:	49 89 39             	mov    QWORD PTR [r9],rdi
  406132:	49 89 c1             	mov    r9,rax
  406135:	4c 89 e7             	mov    rdi,r12
  406138:	e8 53 f5 ff ff       	call   405690 <p113d_FID_36_100_105_114_101_99_116_46_105_115_101_99_116_53_>
  40613d:	48 89 45 d0          	mov    QWORD PTR [rbp-0x30],rax
  406141:	48 83 ec d0          	sub    rsp,0xffffffffffffffd0
  406145:	48 89 9d 20 f7 ff ff 	mov    QWORD PTR [rbp-0x8e0],rbx
  40614c:	b9 01 00 00 00       	mov    ecx,0x1
  406151:	48 8d 95 20 f7 ff ff 	lea    rdx,[rbp-0x8e0]
  406158:	be 19 00 00 00       	mov    esi,0x19
  40615d:	4c 89 e7             	mov    rdi,r12
  406160:	e8 cb 5b 02 00       	call   42bd30 <p111_rt_op>
  406165:	48 89 c6             	mov    rsi,rax
  406168:	4c 8b 8d 70 ff ff ff 	mov    r9,QWORD PTR [rbp-0x90]
  40616f:	48 8b 95 50 ff ff ff 	mov    rdx,QWORD PTR [rbp-0xb0]
  406176:	48 8b 8d 48 ff ff ff 	mov    rcx,QWORD PTR [rbp-0xb8]
  40617d:	48 8b 85 40 ff ff ff 	mov    rax,QWORD PTR [rbp-0xc0]
  406184:	4c 8b 55 c8          	mov    r10,QWORD PTR [rbp-0x38]
  406188:	48 89 f7             	mov    rdi,rsi
  40618b:	48 8b 75 d8          	mov    rsi,QWORD PTR [rbp-0x28]
  40618f:	4c 8b 5d d0          	mov    r11,QWORD PTR [rbp-0x30]
  406193:	4c 89 9d 20 f7 ff ff 	mov    QWORD PTR [rbp-0x8e0],r11
  40619a:	4c 89 95 28 f7 ff ff 	mov    QWORD PTR [rbp-0x8d8],r10
  4061a1:	66 49 0f 6e c3       	movq   xmm0,r11
  4061a6:	66 49 0f 6e ca       	movq   xmm1,r10
  4061ab:	0f 2e c8             	ucomiss xmm1,xmm0
  4061ae:	41 0f 97 c0          	seta   r8b
  4061b2:	45 0f b6 c0          	movzx  r8d,r8b
  4061b6:	45 89 c0             	mov    r8d,r8d
  4061b9:	4c 89 5d c8          	mov    QWORD PTR [rbp-0x38],r11
  4061bd:	48 89 7d d8          	mov    QWORD PTR [rbp-0x28],rdi
  4061c1:	4c 89 95 58 ff ff ff 	mov    QWORD PTR [rbp-0xa8],r10
  4061c8:	48 89 b5 68 ff ff ff 	mov    QWORD PTR [rbp-0x98],rsi
  4061cf:	e9 6c fe ff ff       	jmp    406040 <p113d_FID_36_112_114_111_100_117_99_116_46_110_101_97_114_101_115_116_+0xa0>
  4061d4:	48 8b 9d 38 ff ff ff 	mov    rbx,QWORD PTR [rbp-0xc8]
  4061db:	4c 89 e7             	mov    rdi,r12
  4061de:	be 04 00 00 00       	mov    esi,0x4
  4061e3:	e8 28 5b 02 00       	call   42bd10 <p111_rt_fail>
  4061e8:	48 c7 03 00 00 00 00 	mov    QWORD PTR [rbx],0x0
  4061ef:	48 c7 43 08 00 00 00 	mov    QWORD PTR [rbx+0x8],0x0
  4061f6:	00 
  4061f7:	48 c7 43 10 00 00 00 	mov    QWORD PTR [rbx+0x10],0x0
  4061fe:	00 
  4061ff:	b8 00 00 00 00       	mov    eax,0x0
  406204:	e9 75 04 00 00       	jmp    40667e <p113d_FID_36_112_114_111_100_117_99_116_46_110_101_97_114_101_115_116_+0x6de>
  406209:	4c 89 d0             	mov    rax,r10
  40620c:	48 83 fb 00          	cmp    rbx,0x0
  406210:	40 0f 94 c6          	sete   sil
  406214:	40 0f b6 f6          	movzx  esi,sil
  406218:	89 75 c0             	mov    DWORD PTR [rbp-0x40],esi
  40621b:	4d 89 c8             	mov    r8,r9
  40621e:	49 83 e8 02          	sub    r8,0x2
  406222:	4c 89 ce             	mov    rsi,r9
  406225:	48 83 ee 03          	sub    rsi,0x3
  406229:	49 89 c2             	mov    r10,rax
  40622c:	4c 89 c8             	mov    rax,r9
  40622f:	48 83 e8 04          	sub    rax,0x4
  406233:	4c 89 cf             	mov    rdi,r9
  406236:	48 83 ef 05          	sub    rdi,0x5
  40623a:	4d 89 cb             	mov    r11,r9
  40623d:	49 83 eb 06          	sub    r11,0x6
  406241:	4c 89 5d a0          	mov    QWORD PTR [rbp-0x60],r11
  406245:	4d 89 cb             	mov    r11,r9
  406248:	49 83 eb 07          	sub    r11,0x7
  40624c:	4c 89 5d a8          	mov    QWORD PTR [rbp-0x58],r11
  406250:	49 83 e9 08          	sub    r9,0x8
  406254:	4c 89 4d 90          	mov    QWORD PTR [rbp-0x70],r9
  406258:	4c 8b 5d a8          	mov    r11,QWORD PTR [rbp-0x58]
  40625c:	4c 8b 4d a0          	mov    r9,QWORD PTR [rbp-0x60]
  406260:	83 7d c0 00          	cmp    DWORD PTR [rbp-0x40],0x0
  406264:	0f 85 8a 00 00 00    	jne    4062f4 <p113d_FID_36_112_114_111_100_117_99_116_46_110_101_97_114_101_115_116_+0x354>
  40626a:	49 83 f8 00          	cmp    r8,0x0
  40626e:	74 61                	je     4062d1 <p113d_FID_36_112_114_111_100_117_99_116_46_110_101_97_114_101_115_116_+0x331>
  406270:	48 83 fe 00          	cmp    rsi,0x0
  406274:	74 53                	je     4062c9 <p113d_FID_36_112_114_111_100_117_99_116_46_110_101_97_114_101_115_116_+0x329>
  406276:	48 83 f8 00          	cmp    rax,0x0
  40627a:	74 45                	je     4062c1 <p113d_FID_36_112_114_111_100_117_99_116_46_110_101_97_114_101_115_116_+0x321>
  40627c:	48 83 ff 00          	cmp    rdi,0x0
  406280:	74 37                	je     4062b9 <p113d_FID_36_112_114_111_100_117_99_116_46_110_101_97_114_101_115_116_+0x319>
  406282:	49 83 f9 00          	cmp    r9,0x0
  406286:	4c 8b 4d 90          	mov    r9,QWORD PTR [rbp-0x70]
  40628a:	74 25                	je     4062b1 <p113d_FID_36_112_114_111_100_117_99_116_46_110_101_97_114_101_115_116_+0x311>
  40628c:	49 83 fb 00          	cmp    r11,0x0
  406290:	4c 8b 9d 30 ff ff ff 	mov    r11,QWORD PTR [rbp-0xd0]
  406297:	74 10                	je     4062a9 <p113d_FID_36_112_114_111_100_117_99_116_46_110_101_97_114_101_115_116_+0x309>
  406299:	49 83 f9 00          	cmp    r9,0x0
  40629d:	41 b9 00 00 60 40    	mov    r9d,0x40600000
  4062a3:	4d 0f 45 cb          	cmovne r9,r11
  4062a7:	eb 2e                	jmp    4062d7 <p113d_FID_36_112_114_111_100_117_99_116_46_110_101_97_114_101_115_116_+0x337>
  4062a9:	41 b9 00 00 00 00    	mov    r9d,0x0
  4062af:	eb 26                	jmp    4062d7 <p113d_FID_36_112_114_111_100_117_99_116_46_110_101_97_114_101_115_116_+0x337>
  4062b1:	41 b9 00 00 80 bf    	mov    r9d,0xbf800000
  4062b7:	eb 1e                	jmp    4062d7 <p113d_FID_36_112_114_111_100_117_99_116_46_110_101_97_114_101_115_116_+0x337>
  4062b9:	41 b9 00 00 80 3f    	mov    r9d,0x3f800000
  4062bf:	eb 16                	jmp    4062d7 <p113d_FID_36_112_114_111_100_117_99_116_46_110_101_97_114_101_115_116_+0x337>
  4062c1:	41 b9 00 00 00 c0    	mov    r9d,0xc0000000
  4062c7:	eb 0e                	jmp    4062d7 <p113d_FID_36_112_114_111_100_117_99_116_46_110_101_97_114_101_115_116_+0x337>
  4062c9:	41 b9 00 00 00 40    	mov    r9d,0x40000000
  4062cf:	eb 06                	jmp    4062d7 <p113d_FID_36_112_114_111_100_117_99_116_46_110_101_97_114_101_115_116_+0x337>
  4062d1:	41 b9 00 00 00 00    	mov    r9d,0x0
  4062d7:	4d 89 cb             	mov    r11,r9
  4062da:	4c 89 5d b8          	mov    QWORD PTR [rbp-0x48],r11
  4062de:	4c 8b 5d a8          	mov    r11,QWORD PTR [rbp-0x58]
  4062e2:	4c 8b 4d a0          	mov    r9,QWORD PTR [rbp-0x60]
  4062e6:	f2 44 0f 10 7d b8    	movsd  xmm15,QWORD PTR [rbp-0x48]
  4062ec:	f2 44 0f 11 7d 88    	movsd  QWORD PTR [rbp-0x78],xmm15
  4062f2:	eb 08                	jmp    4062fc <p113d_FID_36_112_114_111_100_117_99_116_46_110_101_97_114_101_115_116_+0x35c>
  4062f4:	48 c7 45 88 00 00 00 	mov    QWORD PTR [rbp-0x78],0x0
  4062fb:	00 
  4062fc:	48 83 fb 00          	cmp    rbx,0x0
  406300:	0f 84 8a 00 00 00    	je     406390 <p113d_FID_36_112_114_111_100_117_99_116_46_110_101_97_114_101_115_116_+0x3f0>
  406306:	49 83 f8 00          	cmp    r8,0x0
  40630a:	74 61                	je     40636d <p113d_FID_36_112_114_111_100_117_99_116_46_110_101_97_114_101_115_116_+0x3cd>
  40630c:	48 83 fe 00          	cmp    rsi,0x0
  406310:	74 53                	je     406365 <p113d_FID_36_112_114_111_100_117_99_116_46_110_101_97_114_101_115_116_+0x3c5>
  406312:	48 83 f8 00          	cmp    rax,0x0
  406316:	74 45                	je     40635d <p113d_FID_36_112_114_111_100_117_99_116_46_110_101_97_114_101_115_116_+0x3bd>
  406318:	48 83 ff 00          	cmp    rdi,0x0
  40631c:	74 37                	je     406355 <p113d_FID_36_112_114_111_100_117_99_116_46_110_101_97_114_101_115_116_+0x3b5>
  40631e:	49 83 f9 00          	cmp    r9,0x0
  406322:	4c 8b 4d 90          	mov    r9,QWORD PTR [rbp-0x70]
  406326:	74 25                	je     40634d <p113d_FID_36_112_114_111_100_117_99_116_46_110_101_97_114_101_115_116_+0x3ad>
  406328:	49 83 fb 00          	cmp    r11,0x0
  40632c:	4c 8b 9d 28 ff ff ff 	mov    r11,QWORD PTR [rbp-0xd8]
  406333:	74 10                	je     406345 <p113d_FID_36_112_114_111_100_117_99_116_46_110_101_97_114_101_115_116_+0x3a5>
  406335:	49 83 f9 00          	cmp    r9,0x0
  406339:	41 b9 cd cc 4c 3e    	mov    r9d,0x3e4ccccd
  40633f:	4d 0f 45 cb          	cmovne r9,r11
  406343:	eb 2e                	jmp    406373 <p113d_FID_36_112_114_111_100_117_99_116_46_110_101_97_114_101_115_116_+0x3d3>
  406345:	41 b9 cd cc cc 3f    	mov    r9d,0x3fcccccd
  40634b:	eb 26                	jmp    406373 <p113d_FID_36_112_114_111_100_117_99_116_46_110_101_97_114_101_115_116_+0x3d3>
  40634d:	41 b9 9a 99 19 bf    	mov    r9d,0xbf19999a
  406353:	eb 1e                	jmp    406373 <p113d_FID_36_112_114_111_100_117_99_116_46_110_101_97_114_101_115_116_+0x3d3>
  406355:	41 b9 9a 99 19 bf    	mov    r9d,0xbf19999a
  40635b:	eb 16                	jmp    406373 <p113d_FID_36_112_114_111_100_117_99_116_46_110_101_97_114_101_115_116_+0x3d3>
  40635d:	41 b9 00 00 00 3f    	mov    r9d,0x3f000000
  406363:	eb 0e                	jmp    406373 <p113d_FID_36_112_114_111_100_117_99_116_46_110_101_97_114_101_115_116_+0x3d3>
  406365:	41 b9 00 00 00 3f    	mov    r9d,0x3f000000
  40636b:	eb 06                	jmp    406373 <p113d_FID_36_112_114_111_100_117_99_116_46_110_101_97_114_101_115_116_+0x3d3>
  40636d:	41 b9 00 00 00 00    	mov    r9d,0x0
  406373:	4d 89 cb             	mov    r11,r9
  406376:	4c 89 5d b0          	mov    QWORD PTR [rbp-0x50],r11
  40637a:	4c 8b 5d a8          	mov    r11,QWORD PTR [rbp-0x58]
  40637e:	4c 8b 4d a0          	mov    r9,QWORD PTR [rbp-0x60]
  406382:	f2 44 0f 10 7d b0    	movsd  xmm15,QWORD PTR [rbp-0x50]
  406388:	f2 44 0f 11 7d 80    	movsd  QWORD PTR [rbp-0x80],xmm15
  40638e:	eb 0e                	jmp    40639e <p113d_FID_36_112_114_111_100_117_99_116_46_110_101_97_114_101_115_116_+0x3fe>
  406390:	c7 45 80 00 44 1c c6 	mov    DWORD PTR [rbp-0x80],0xc61c4400
  406397:	c7 45 84 00 00 00 00 	mov    DWORD PTR [rbp-0x7c],0x0
  40639e:	48 83 fb 00          	cmp    rbx,0x0
  4063a2:	0f 84 8d 00 00 00    	je     406435 <p113d_FID_36_112_114_111_100_117_99_116_46_110_101_97_114_101_115_116_+0x495>
  4063a8:	49 83 f8 00          	cmp    r8,0x0
  4063ac:	74 61                	je     40640f <p113d_FID_36_112_114_111_100_117_99_116_46_110_101_97_114_101_115_116_+0x46f>
  4063ae:	48 83 fe 00          	cmp    rsi,0x0
  4063b2:	74 53                	je     406407 <p113d_FID_36_112_114_111_100_117_99_116_46_110_101_97_114_101_115_116_+0x467>
  4063b4:	48 83 f8 00          	cmp    rax,0x0
  4063b8:	74 45                	je     4063ff <p113d_FID_36_112_114_111_100_117_99_116_46_110_101_97_114_101_115_116_+0x45f>
  4063ba:	48 83 ff 00          	cmp    rdi,0x0
  4063be:	74 37                	je     4063f7 <p113d_FID_36_112_114_111_100_117_99_116_46_110_101_97_114_101_115_116_+0x457>
  4063c0:	49 83 f9 00          	cmp    r9,0x0
  4063c4:	4c 8b 4d 90          	mov    r9,QWORD PTR [rbp-0x70]
  4063c8:	74 25                	je     4063ef <p113d_FID_36_112_114_111_100_117_99_116_46_110_101_97_114_101_115_116_+0x44f>
  4063ca:	49 83 fb 00          	cmp    r11,0x0
  4063ce:	4c 8b 9d 20 ff ff ff 	mov    r11,QWORD PTR [rbp-0xe0]
  4063d5:	74 10                	je     4063e7 <p113d_FID_36_112_114_111_100_117_99_116_46_110_101_97_114_101_115_116_+0x447>
  4063d7:	49 83 f9 00          	cmp    r9,0x0
  4063db:	41 b9 00 00 00 41    	mov    r9d,0x41000000
  4063e1:	4d 0f 45 cb          	cmovne r9,r11
  4063e5:	eb 2e                	jmp    406415 <p113d_FID_36_112_114_111_100_117_99_116_46_110_101_97_114_101_115_116_+0x475>
  4063e7:	41 b9 00 00 e0 40    	mov    r9d,0x40e00000
  4063ed:	eb 26                	jmp    406415 <p113d_FID_36_112_114_111_100_117_99_116_46_110_101_97_114_101_115_116_+0x475>
  4063ef:	41 b9 00 00 60 40    	mov    r9d,0x40600000
  4063f5:	eb 1e                	jmp    406415 <p113d_FID_36_112_114_111_100_117_99_116_46_110_101_97_114_101_115_116_+0x475>
  4063f7:	41 b9 00 00 60 40    	mov    r9d,0x40600000
  4063fd:	eb 16                	jmp    406415 <p113d_FID_36_112_114_111_100_117_99_116_46_110_101_97_114_101_115_116_+0x475>
  4063ff:	41 b9 00 00 c0 40    	mov    r9d,0x40c00000
  406405:	eb 0e                	jmp    406415 <p113d_FID_36_112_114_111_100_117_99_116_46_110_101_97_114_101_115_116_+0x475>
  406407:	41 b9 00 00 c0 40    	mov    r9d,0x40c00000
  40640d:	eb 06                	jmp    406415 <p113d_FID_36_112_114_111_100_117_99_116_46_110_101_97_114_101_115_116_+0x475>
  40640f:	41 b9 00 00 a0 40    	mov    r9d,0x40a00000
  406415:	4d 89 cb             	mov    r11,r9
  406418:	4c 89 5d 98          	mov    QWORD PTR [rbp-0x68],r11
  40641c:	4c 8b 5d a8          	mov    r11,QWORD PTR [rbp-0x58]
  406420:	4c 8b 4d a0          	mov    r9,QWORD PTR [rbp-0x60]
  406424:	f2 44 0f 10 7d 98    	movsd  xmm15,QWORD PTR [rbp-0x68]
  40642a:	f2 44 0f 11 bd 78 ff 	movsd  QWORD PTR [rbp-0x88],xmm15
  406431:	ff ff 
  406433:	eb 0b                	jmp    406440 <p113d_FID_36_112_114_111_100_117_99_116_46_110_101_97_114_101_115_116_+0x4a0>
  406435:	48 c7 85 78 ff ff ff 	mov    QWORD PTR [rbp-0x88],0x40a00000
  40643c:	00 00 a0 40 
  406440:	48 83 fb 00          	cmp    rbx,0x0
  406444:	0f 84 b8 00 00 00    	je     406502 <p113d_FID_36_112_114_111_100_117_99_116_46_110_101_97_114_101_115_116_+0x562>
  40644a:	49 83 f8 00          	cmp    r8,0x0
  40644e:	4c 8b 45 90          	mov    r8,QWORD PTR [rbp-0x70]
  406452:	0f 84 8d 00 00 00    	je     4064e5 <p113d_FID_36_112_114_111_100_117_99_116_46_110_101_97_114_101_115_116_+0x545>
  406458:	48 83 fe 00          	cmp    rsi,0x0
  40645c:	48 8b 75 88          	mov    rsi,QWORD PTR [rbp-0x78]
  406460:	74 6a                	je     4064cc <p113d_FID_36_112_114_111_100_117_99_116_46_110_101_97_114_101_115_116_+0x52c>
  406462:	48 83 f8 00          	cmp    rax,0x0
  406466:	48 89 d0             	mov    rax,rdx
  406469:	48 8b 55 80          	mov    rdx,QWORD PTR [rbp-0x80]
  40646d:	74 4b                	je     4064ba <p113d_FID_36_112_114_111_100_117_99_116_46_110_101_97_114_101_115_116_+0x51a>
  40646f:	48 83 ff 00          	cmp    rdi,0x0
  406473:	48 89 cf             	mov    rdi,rcx
  406476:	48 8b 8d 78 ff ff ff 	mov    rcx,QWORD PTR [rbp-0x88]
  40647d:	74 33                	je     4064b2 <p113d_FID_36_112_114_111_100_117_99_116_46_110_101_97_114_101_115_116_+0x512>
  40647f:	49 83 f9 00          	cmp    r9,0x0
  406483:	4c 8b 8d 70 ff ff ff 	mov    r9,QWORD PTR [rbp-0x90]
  40648a:	74 1e                	je     4064aa <p113d_FID_36_112_114_111_100_117_99_116_46_110_101_97_114_101_115_116_+0x50a>
  40648c:	49 83 fb 00          	cmp    r11,0x0
  406490:	74 10                	je     4064a2 <p113d_FID_36_112_114_111_100_117_99_116_46_110_101_97_114_101_115_116_+0x502>
  406492:	49 83 f8 00          	cmp    r8,0x0
  406496:	41 b8 00 00 80 3f    	mov    r8d,0x3f800000
  40649c:	4d 0f 45 c1          	cmovne r8,r9
  4064a0:	eb 7b                	jmp    40651d <p113d_FID_36_112_114_111_100_117_99_116_46_110_101_97_114_101_115_116_+0x57d>
  4064a2:	41 b8 9a 99 99 3f    	mov    r8d,0x3f99999a
  4064a8:	eb 73                	jmp    40651d <p113d_FID_36_112_114_111_100_117_99_116_46_110_101_97_114_101_115_116_+0x57d>
  4064aa:	41 b8 cd cc cc 3e    	mov    r8d,0x3ecccccd
  4064b0:	eb 6b                	jmp    40651d <p113d_FID_36_112_114_111_100_117_99_116_46_110_101_97_114_101_115_116_+0x57d>
  4064b2:	41 b8 cd cc cc 3e    	mov    r8d,0x3ecccccd
  4064b8:	eb 63                	jmp    40651d <p113d_FID_36_112_114_111_100_117_99_116_46_110_101_97_114_101_115_116_+0x57d>
  4064ba:	48 89 cf             	mov    rdi,rcx
  4064bd:	48 8b 8d 78 ff ff ff 	mov    rcx,QWORD PTR [rbp-0x88]
  4064c4:	41 b8 00 00 80 3f    	mov    r8d,0x3f800000
  4064ca:	eb 51                	jmp    40651d <p113d_FID_36_112_114_111_100_117_99_116_46_110_101_97_114_101_115_116_+0x57d>
  4064cc:	48 89 d0             	mov    rax,rdx
  4064cf:	48 8b 55 80          	mov    rdx,QWORD PTR [rbp-0x80]
  4064d3:	48 89 cf             	mov    rdi,rcx
  4064d6:	48 8b 8d 78 ff ff ff 	mov    rcx,QWORD PTR [rbp-0x88]
  4064dd:	41 b8 00 00 80 3f    	mov    r8d,0x3f800000
  4064e3:	eb 38                	jmp    40651d <p113d_FID_36_112_114_111_100_117_99_116_46_110_101_97_114_101_115_116_+0x57d>
  4064e5:	48 8b 75 88          	mov    rsi,QWORD PTR [rbp-0x78]
  4064e9:	48 89 d0             	mov    rax,rdx
  4064ec:	48 8b 55 80          	mov    rdx,QWORD PTR [rbp-0x80]
  4064f0:	48 89 cf             	mov    rdi,rcx
  4064f3:	48 8b 8d 78 ff ff ff 	mov    rcx,QWORD PTR [rbp-0x88]
  4064fa:	41 b8 00 00 80 3f    	mov    r8d,0x3f800000
  406500:	eb 1b                	jmp    40651d <p113d_FID_36_112_114_111_100_117_99_116_46_110_101_97_114_101_115_116_+0x57d>
  406502:	48 8b 75 88          	mov    rsi,QWORD PTR [rbp-0x78]
  406506:	48 89 d0             	mov    rax,rdx
  406509:	48 8b 55 80          	mov    rdx,QWORD PTR [rbp-0x80]
  40650d:	48 89 cf             	mov    rdi,rcx
  406510:	48 8b 8d 78 ff ff ff 	mov    rcx,QWORD PTR [rbp-0x88]
  406517:	41 b8 00 40 1c 46    	mov    r8d,0x461c4000
  40651d:	48 83 ec 30          	sub    rsp,0x30
  406521:	49 89 e1             	mov    r9,rsp
  406524:	4d 89 69 20          	mov    QWORD PTR [r9+0x20],r13
  406528:	4d 89 71 18          	mov    QWORD PTR [r9+0x18],r14
  40652c:	4d 89 79 10          	mov    QWORD PTR [r9+0x10],r15
  406530:	4d 89 51 08          	mov    QWORD PTR [r9+0x8],r10
  406534:	49 89 39             	mov    QWORD PTR [r9],rdi
  406537:	49 89 c1             	mov    r9,rax
  40653a:	4c 89 e7             	mov    rdi,r12
  40653d:	e8 4e f1 ff ff       	call   405690 <p113d_FID_36_100_105_114_101_99_116_46_105_115_101_99_116_53_>
  406542:	48 89 85 60 ff ff ff 	mov    QWORD PTR [rbp-0xa0],rax
  406549:	48 83 ec d0          	sub    rsp,0xffffffffffffffd0
  40654d:	48 89 9d 20 f7 ff ff 	mov    QWORD PTR [rbp-0x8e0],rbx
  406554:	b9 01 00 00 00       	mov    ecx,0x1
  406559:	48 8d 95 20 f7 ff ff 	lea    rdx,[rbp-0x8e0]
  406560:	be 19 00 00 00       	mov    esi,0x19
  406565:	4c 89 e7             	mov    rdi,r12
  406568:	e8 c3 57 02 00       	call   42bd30 <p111_rt_op>
  40656d:	48 89 c6             	mov    rsi,rax
  406570:	4c 8b 8d 70 ff ff ff 	mov    r9,QWORD PTR [rbp-0x90]
  406577:	48 8b 95 50 ff ff ff 	mov    rdx,QWORD PTR [rbp-0xb0]
  40657e:	48 8b 8d 48 ff ff ff 	mov    rcx,QWORD PTR [rbp-0xb8]
  406585:	48 8b 85 40 ff ff ff 	mov    rax,QWORD PTR [rbp-0xc0]
  40658c:	4c 8b 95 58 ff ff ff 	mov    r10,QWORD PTR [rbp-0xa8]
  406593:	48 89 f7             	mov    rdi,rsi
  406596:	48 8b b5 68 ff ff ff 	mov    rsi,QWORD PTR [rbp-0x98]
  40659d:	4c 8b 9d 60 ff ff ff 	mov    r11,QWORD PTR [rbp-0xa0]
  4065a4:	4c 89 9d 20 f7 ff ff 	mov    QWORD PTR [rbp-0x8e0],r11
  4065ab:	4c 89 95 28 f7 ff ff 	mov    QWORD PTR [rbp-0x8d8],r10
  4065b2:	66 49 0f 6e c3       	movq   xmm0,r11
  4065b7:	66 49 0f 6e ca       	movq   xmm1,r10
  4065bc:	0f 2e c8             	ucomiss xmm1,xmm0
  4065bf:	41 0f 97 c0          	seta   r8b
  4065c3:	45 0f b6 c0          	movzx  r8d,r8b
  4065c7:	45 89 c0             	mov    r8d,r8d
  4065ca:	4c 89 5d c8          	mov    QWORD PTR [rbp-0x38],r11
  4065ce:	48 89 7d d8          	mov    QWORD PTR [rbp-0x28],rdi
  4065d2:	4c 89 95 58 ff ff ff 	mov    QWORD PTR [rbp-0xa8],r10
  4065d9:	48 89 b5 68 ff ff ff 	mov    QWORD PTR [rbp-0x98],rsi
  4065e0:	e9 5b fa ff ff       	jmp    406040 <p113d_FID_36_112_114_111_100_117_99_116_46_110_101_97_114_101_115_116_+0xa0>
  4065e5:	4c 8b 5d c8          	mov    r11,QWORD PTR [rbp-0x38]
  4065e9:	4c 8b 95 58 ff ff ff 	mov    r10,QWORD PTR [rbp-0xa8]
  4065f0:	89 f1                	mov    ecx,esi
  4065f2:	48 8b b5 68 ff ff ff 	mov    rsi,QWORD PTR [rbp-0x98]
  4065f9:	89 fa                	mov    edx,edi
  4065fb:	48 8b 9d 38 ff ff ff 	mov    rbx,QWORD PTR [rbp-0xc8]
  406602:	4c 89 e7             	mov    rdi,r12
  406605:	4c 8b 65 d8          	mov    r12,QWORD PTR [rbp-0x28]
  406609:	83 f2 01             	xor    edx,0x1
  40660c:	75 52                	jne    406660 <p113d_FID_36_112_114_111_100_117_99_116_46_110_101_97_114_101_115_116_+0x6c0>
  40660e:	4d 89 da             	mov    r10,r11
  406611:	4c 89 e6             	mov    rsi,r12
  406614:	09 c8                	or     eax,ecx
  406616:	75 28                	jne    406640 <p113d_FID_36_112_114_111_100_117_99_116_46_110_101_97_114_101_115_116_+0x6a0>
  406618:	be 04 00 00 00       	mov    esi,0x4
  40661d:	e8 ee 56 02 00       	call   42bd10 <p111_rt_fail>
  406622:	48 c7 03 00 00 00 00 	mov    QWORD PTR [rbx],0x0
  406629:	48 c7 43 08 00 00 00 	mov    QWORD PTR [rbx+0x8],0x0
  406630:	00 
  406631:	48 c7 43 10 00 00 00 	mov    QWORD PTR [rbx+0x10],0x0
  406638:	00 
  406639:	b8 00 00 00 00       	mov    eax,0x0
  40663e:	eb 3e                	jmp    40667e <p113d_FID_36_112_114_111_100_117_99_116_46_110_101_97_114_101_115_116_+0x6de>
  406640:	89 f0                	mov    eax,esi
  406642:	48 83 f8 09          	cmp    rax,0x9
  406646:	0f 94 c0             	sete   al
  406649:	0f b6 c0             	movzx  eax,al
  40664c:	89 c0                	mov    eax,eax
  40664e:	48 89 03             	mov    QWORD PTR [rbx],rax
  406651:	4c 89 53 08          	mov    QWORD PTR [rbx+0x8],r10
  406655:	48 89 73 10          	mov    QWORD PTR [rbx+0x10],rsi
  406659:	b8 00 00 00 00       	mov    eax,0x0
  40665e:	eb 1e                	jmp    40667e <p113d_FID_36_112_114_111_100_117_99_116_46_110_101_97_114_101_115_116_+0x6de>
  406660:	89 f0                	mov    eax,esi
  406662:	48 83 f8 09          	cmp    rax,0x9
  406666:	0f 94 c0             	sete   al
  406669:	0f b6 c0             	movzx  eax,al
  40666c:	89 c0                	mov    eax,eax
  40666e:	48 89 03             	mov    QWORD PTR [rbx],rax
  406671:	4c 89 53 08          	mov    QWORD PTR [rbx+0x8],r10
  406675:	48 89 73 10          	mov    QWORD PTR [rbx+0x10],rsi
  406679:	b8 00 00 00 00       	mov    eax,0x0
  40667e:	41 5f                	pop    r15
  406680:	41 5e                	pop    r14
  406682:	41 5d                	pop    r13
  406684:	41 5c                	pop    r12
  406686:	5b                   	pop    rbx
  406687:	c9                   	leave  
  406688:	c3                   	ret    

Disassembly of section .fini:
