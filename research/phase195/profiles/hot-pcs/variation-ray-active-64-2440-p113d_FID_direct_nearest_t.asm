
/home/ai/bend2/build/publish/bend/selfhost/build/phase194/native45-02/variation-ray-active-64-2440/machine/program:     file format elf64-x86-64


Disassembly of section .init:

Disassembly of section .plt:

Disassembly of section .text:

000000000040b083 <p113d_FID_36_100_105_114_101_99_116_46_110_101_97_114_101_115_116_46_116_>:
  40b083:	push   rbp
  40b084:	mov    rbp,rsp
  40b087:	sub    rsp,0xcf0
  40b08e:	mov    QWORD PTR [rbp-0x10],r12
  40b092:	mov    QWORD PTR [rbp-0x8],rbx
  40b096:	mov    QWORD PTR [rbp-0x18],r13
  40b09a:	mov    QWORD PTR [rbp-0x20],r14
  40b09e:	mov    QWORD PTR [rbp-0x28],r15
  40b0a2:	mov    rax,rdi
  40b0a5:	mov    r12,rax
  40b0a8:	mov    rax,rsi
  40b0ab:	mov    rbx,rax
  40b0ae:	mov    rax,rdx
  40b0b1:	mov    r13,rax
  40b0b4:	mov    rax,rcx
  40b0b7:	mov    r14,rax
  40b0ba:	mov    rax,r8
  40b0bd:	mov    r15,rax
  40b0c0:	mov    rax,r9
  40b0c3:	mov    QWORD PTR [rbp-0x50],rax
  40b0c7:	mov    rax,QWORD PTR [rbp+0x10]
  40b0cb:	mov    QWORD PTR [rbp-0x58],rax
  40b0cf:	mov    rax,QWORD PTR [rbp+0x18]
  40b0d3:	mov    QWORD PTR [rbp-0x60],rax
  40b0d7:	mov    rax,QWORD PTR [rbp+0x20]
  40b0db:	mov    QWORD PTR [rbp-0x68],rax
  40b0df:	mov    rax,QWORD PTR [rbp+0x28]
  40b0e3:	mov    QWORD PTR [rbp-0x70],rax
  40b0e7:	mov    rax,QWORD PTR [rbp+0x30]
  40b0eb:	mov    rsi,rax
  40b0ee:	mov    rdi,rbx
  40b0f1:	cmp    rdi,0x0
  40b0f8:	sete   dil
  40b0fc:	movzx  edi,dil
  40b100:	mov    r10,rdi
  40b103:	test   r10d,r10d
  40b106:	je     40b222 <p113d_FID_36_100_105_114_101_99_116_46_110_101_97_114_101_115_116_46_116_+0x19f>
  40b10c:	mov    r8,rsi
  40b10f:	cmp    r8,0x1
  40b116:	sete   r8b
  40b11a:	movzx  r8d,r8b
  40b11e:	mov    rdi,rsi
  40b121:	shr    rdi,0x28
  40b125:	and    rdi,0x7fffff
  40b12c:	movabs rdx,0x2
  40b136:	or     rdx,0x10000
  40b13d:	cmp    rdi,rdx
  40b140:	sete   dil
  40b144:	movzx  edi,dil
  40b148:	or     edi,r8d
  40b14b:	xor    edi,0x1
  40b151:	mov    r10,rdi
  40b154:	test   r10d,r10d
  40b157:	je     40b17a <p113d_FID_36_100_105_114_101_99_116_46_110_101_97_114_101_115_116_46_116_+0xf7>
  40b15d:	mov    rax,QWORD PTR [rbp-0x70]
  40b161:	mov    r12,QWORD PTR [rbp-0x10]
  40b165:	mov    rbx,QWORD PTR [rbp-0x8]
  40b169:	mov    r13,QWORD PTR [rbp-0x18]
  40b16d:	mov    r14,QWORD PTR [rbp-0x20]
  40b171:	mov    r15,QWORD PTR [rbp-0x28]
  40b175:	mov    rsp,rbp
  40b178:	pop    rbp
  40b179:	ret    
  40b17a:	mov    r8,rsi
  40b17d:	cmp    r8,0x1
  40b184:	sete   r8b
  40b188:	movzx  r8d,r8b
  40b18c:	mov    rdi,rsi
  40b18f:	shr    rdi,0x28
  40b193:	and    rdi,0x7fffff
  40b19a:	movabs rdx,0x2
  40b1a4:	or     rdx,0x10000
  40b1ab:	cmp    rdi,rdx
  40b1ae:	sete   dil
  40b1b2:	movzx  edi,dil
  40b1b6:	or     edi,r8d
  40b1b9:	mov    r10,rdi
  40b1bc:	test   r10d,r10d
  40b1bf:	je     40b1e2 <p113d_FID_36_100_105_114_101_99_116_46_110_101_97_114_101_115_116_46_116_+0x15f>
  40b1c5:	mov    rax,QWORD PTR [rbp-0x68]
  40b1c9:	mov    r12,QWORD PTR [rbp-0x10]
  40b1cd:	mov    rbx,QWORD PTR [rbp-0x8]
  40b1d1:	mov    r13,QWORD PTR [rbp-0x18]
  40b1d5:	mov    r14,QWORD PTR [rbp-0x20]
  40b1d9:	mov    r15,QWORD PTR [rbp-0x28]
  40b1dd:	mov    rsp,rbp
  40b1e0:	pop    rbp
  40b1e1:	ret    
  40b1e2:	mov    rdi,r12
  40b1e5:	movabs rsi,0x4
  40b1ef:	mov    esi,esi
  40b1f1:	xor    eax,eax
  40b1f3:	call   420a90 <p111_rt_fail>
  40b1f8:	mov    QWORD PTR [rbp-0x948],rax
  40b1ff:	movabs rax,0x0
  40b209:	mov    r12,QWORD PTR [rbp-0x10]
  40b20d:	mov    rbx,QWORD PTR [rbp-0x8]
  40b211:	mov    r13,QWORD PTR [rbp-0x18]
  40b215:	mov    r14,QWORD PTR [rbp-0x20]
  40b219:	mov    r15,QWORD PTR [rbp-0x28]
  40b21d:	mov    rsp,rbp
  40b220:	pop    rbp
  40b221:	ret    
  40b222:	mov    rdi,rbx
  40b225:	cmp    rdi,0x0
  40b22c:	setne  dil
  40b230:	movzx  edi,dil
  40b234:	mov    r10,rdi
  40b237:	test   r10d,r10d
  40b23a:	je     40baf0 <p113d_FID_36_100_105_114_101_99_116_46_110_101_97_114_101_115_116_46_116_+0xa6d>
  40b240:	sub    rbx,0x1
  40b247:	mov    r8,rsi
  40b24a:	cmp    r8,0x1
  40b251:	sete   r8b
  40b255:	movzx  r8d,r8b
  40b259:	mov    rdi,rsi
  40b25c:	shr    rdi,0x28
  40b260:	and    rdi,0x7fffff
  40b267:	movabs rdx,0x2
  40b271:	or     rdx,0x10000
  40b278:	cmp    rdi,rdx
  40b27b:	sete   dil
  40b27f:	movzx  edi,dil
  40b283:	or     edi,r8d
  40b286:	xor    edi,0x1
  40b28c:	mov    r10,rdi
  40b28f:	test   r10d,r10d
  40b292:	je     40b658 <p113d_FID_36_100_105_114_101_99_116_46_110_101_97_114_101_115_116_46_116_+0x5d5>
  40b298:	mov    rdi,r12
  40b29b:	mov    rsi,rbx
  40b29e:	xor    eax,eax
  40b2a0:	call   408ea5 <p113d_FID_36_100_105_114_101_99_116_46_115_120_>
  40b2a5:	mov    QWORD PTR [rbp-0x958],rax
  40b2ac:	mov    rdi,r12
  40b2af:	mov    rsi,rbx
  40b2b2:	xor    eax,eax
  40b2b4:	call   408d77 <p113d_FID_36_100_105_114_101_99_116_46_115_121_>
  40b2b9:	mov    QWORD PTR [rbp-0x960],rax
  40b2c0:	mov    rdi,r12
  40b2c3:	mov    rsi,rbx
  40b2c6:	xor    eax,eax
  40b2c8:	call   408c49 <p113d_FID_36_100_105_114_101_99_116_46_115_122_>
  40b2cd:	mov    QWORD PTR [rbp-0x968],rax
  40b2d4:	mov    rdi,r12
  40b2d7:	mov    rsi,rbx
  40b2da:	xor    eax,eax
  40b2dc:	call   408b1b <p113d_FID_36_100_105_114_101_99_116_46_115_114_>
  40b2e1:	mov    r9,rax
  40b2e4:	movd   xmm1,DWORD PTR [rbp-0x958]
  40b2ec:	movd   xmm2,r13d
  40b2f1:	subss  xmm2,xmm1
  40b2f5:	movaps xmm3,xmm2
  40b2f8:	movd   xmm1,DWORD PTR [rbp-0x960]
  40b300:	movd   xmm2,r14d
  40b305:	subss  xmm2,xmm1
  40b309:	movaps xmm4,xmm2
  40b30c:	movd   xmm1,DWORD PTR [rbp-0x968]
  40b314:	movd   xmm2,r15d
  40b319:	subss  xmm2,xmm1
  40b31d:	movaps xmm5,xmm2
  40b320:	movd   xmm1,DWORD PTR [rbp-0x50]
  40b325:	movaps xmm2,xmm3
  40b328:	mulss  xmm2,xmm1
  40b32c:	movaps xmm6,xmm2
  40b32f:	movd   xmm1,DWORD PTR [rbp-0x58]
  40b334:	movaps xmm2,xmm4
  40b337:	mulss  xmm2,xmm1
  40b33b:	movaps xmm7,xmm6
  40b33e:	addss  xmm7,xmm2
  40b342:	movaps xmm2,xmm7
  40b345:	movd   xmm1,DWORD PTR [rbp-0x60]
  40b34a:	movaps xmm6,xmm5
  40b34d:	mulss  xmm6,xmm1
  40b351:	movaps xmm7,xmm2
  40b354:	addss  xmm7,xmm6
  40b358:	movd   r10d,xmm7
  40b35d:	mov    QWORD PTR [rbp-0x9e0],r10
  40b364:	movaps xmm2,xmm7
  40b367:	mulss  xmm2,xmm7
  40b36b:	movaps xmm6,xmm2
  40b36e:	movaps xmm2,xmm3
  40b371:	mulss  xmm2,xmm3
  40b375:	movaps xmm3,xmm2
  40b378:	movaps xmm2,xmm4
  40b37b:	mulss  xmm2,xmm4
  40b37f:	movaps xmm4,xmm3
  40b382:	addss  xmm4,xmm2
  40b386:	movaps xmm2,xmm4
  40b389:	movaps xmm3,xmm5
  40b38c:	mulss  xmm3,xmm5
  40b390:	movaps xmm4,xmm2
  40b393:	addss  xmm4,xmm3
  40b397:	movaps xmm2,xmm4
  40b39a:	movd   xmm1,r9d
  40b39f:	movd   xmm3,r9d
  40b3a4:	mulss  xmm3,xmm1
  40b3a8:	movaps xmm4,xmm2
  40b3ab:	subss  xmm4,xmm3
  40b3af:	movaps xmm2,xmm6
  40b3b2:	subss  xmm2,xmm4
  40b3b6:	movd   esi,xmm2
  40b3ba:	movabs r10,0x0
  40b3c4:	movd   xmm0,r10d
  40b3c9:	movd   r10d,xmm0
  40b3ce:	pxor   xmm0,xmm0
  40b3d2:	cvtsi2ss xmm0,r10
  40b3d7:	movd   r10d,xmm0
  40b3dc:	movd   xmm2,r10d
  40b3e1:	movd   xmm0,esi
  40b3e5:	movaps xmm1,xmm2
  40b3e8:	ucomiss xmm0,xmm1
  40b3eb:	setb   r10b
  40b3ef:	setnp  r11b
  40b3f3:	and    r10b,r11b
  40b3f6:	movzx  r10d,r10b
  40b3fa:	mov    QWORD PTR [rbp-0xa60],r10
  40b401:	cmp    r10,0x1
  40b408:	sete   r10b
  40b40c:	movzx  r10d,r10b
  40b410:	mov    QWORD PTR [rbp-0xa78],r10
  40b417:	test   r10d,r10d
  40b41a:	je     40b45e <p113d_FID_36_100_105_114_101_99_116_46_110_101_97_114_101_115_116_46_116_+0x3db>
  40b420:	lea    r10,[rbp-0xa70]
  40b427:	movabs r11,0x3b9aca00
  40b431:	mov    QWORD PTR [r10],r11
  40b434:	movabs r10,0x3b9aca00
  40b43e:	movd   xmm0,r10d
  40b443:	movd   r10d,xmm0
  40b448:	pxor   xmm0,xmm0
  40b44c:	cvtsi2ss xmm0,r10
  40b451:	movd   r10d,xmm0
  40b456:	mov    rdi,r10
  40b459:	jmp    40b620 <p113d_FID_36_100_105_114_101_99_116_46_110_101_97_114_101_115_116_46_116_+0x59d>
  40b45e:	lea    r10,[rbp-0xa70]
  40b465:	movabs r11,0x0
  40b46f:	mov    QWORD PTR [r10],r11
  40b472:	movabs r10,0x0
  40b47c:	movd   xmm0,r10d
  40b481:	movd   r10d,xmm0
  40b486:	pxor   xmm0,xmm0
  40b48a:	cvtsi2ss xmm0,r10
  40b48f:	movd   r10d,xmm0
  40b494:	mov    rdi,r10
  40b497:	lea    r10,[rbp-0xa70]
  40b49e:	mov    r11,rdi
  40b4a1:	mov    QWORD PTR [r10],r11
  40b4a4:	lea    r10,[rbp-0xa70]
  40b4ab:	mov    r11,QWORD PTR [rbp-0x9e0]
  40b4b2:	mov    QWORD PTR [r10+0x8],r11
  40b4b6:	movd   xmm1,DWORD PTR [rbp-0x9e0]
  40b4be:	movd   xmm0,edi
  40b4c2:	subss  xmm0,xmm1
  40b4c6:	movd   edi,xmm0
  40b4ca:	mov    r10,rdi
  40b4cd:	mov    QWORD PTR [rbp-0xa90],r10
  40b4d4:	lea    r10,[rbp-0xa70]
  40b4db:	mov    r11,rsi
  40b4de:	mov    QWORD PTR [r10],r11
  40b4e1:	mov    rdi,r12
  40b4e4:	movabs rsi,0x24
  40b4ee:	mov    esi,esi
  40b4f0:	lea    rdx,[rbp-0xa70]
  40b4f7:	movabs rcx,0x1
  40b501:	mov    ecx,ecx
  40b503:	xor    eax,eax
  40b505:	call   420ab0 <p111_rt_op>
  40b50a:	mov    rdi,rax
  40b50d:	lea    r10,[rbp-0xa70]
  40b514:	mov    r11,QWORD PTR [rbp-0xa90]
  40b51b:	mov    QWORD PTR [r10],r11
  40b51e:	lea    r10,[rbp-0xa70]
  40b525:	mov    r11,rdi
  40b528:	mov    QWORD PTR [r10+0x8],r11
  40b52c:	movd   xmm1,edi
  40b530:	movd   xmm0,DWORD PTR [rbp-0xa90]
  40b538:	subss  xmm0,xmm1
  40b53c:	movd   edi,xmm0
  40b540:	movabs r10,0x1
  40b54a:	movd   xmm0,r10d
  40b54f:	movd   r10d,xmm0
  40b554:	pxor   xmm0,xmm0
  40b558:	cvtsi2ss xmm0,r10
  40b55d:	movd   r10d,xmm0
  40b562:	movd   xmm2,r10d
  40b567:	movaps xmm3,xmm2
  40b56a:	movabs r10,0x3e8
  40b574:	movd   xmm0,r10d
  40b579:	movd   r10d,xmm0
  40b57e:	pxor   xmm0,xmm0
  40b582:	cvtsi2ss xmm0,r10
  40b587:	movd   r10d,xmm0
  40b58c:	movd   xmm2,r10d
  40b591:	movaps xmm4,xmm3
  40b594:	divss  xmm4,xmm2
  40b598:	movd   xmm0,edi
  40b59c:	movaps xmm1,xmm4
  40b59f:	ucomiss xmm0,xmm1
  40b5a2:	setb   r10b
  40b5a6:	setnp  r11b
  40b5aa:	and    r10b,r11b
  40b5ad:	movzx  r10d,r10b
  40b5b1:	mov    QWORD PTR [rbp-0xac0],r10
  40b5b8:	cmp    r10,0x1
  40b5bf:	sete   r10b
  40b5c3:	movzx  r10d,r10b
  40b5c7:	mov    QWORD PTR [rbp-0xac8],r10
  40b5ce:	test   r10d,r10d
  40b5d1:	je     40b60f <p113d_FID_36_100_105_114_101_99_116_46_110_101_97_114_101_115_116_46_116_+0x58c>
  40b5d7:	movabs r10,0x3b9aca00
  40b5e1:	movd   xmm0,r10d
  40b5e6:	movd   r10d,xmm0
  40b5eb:	pxor   xmm0,xmm0
  40b5ef:	cvtsi2ss xmm0,r10
  40b5f4:	movd   r10d,xmm0
  40b5f9:	movd   xmm2,r10d
  40b5fe:	movd   r10d,xmm2
  40b603:	mov    QWORD PTR [rbp-0xad8],r10
  40b60a:	jmp    40b619 <p113d_FID_36_100_105_114_101_99_116_46_110_101_97_114_101_115_116_46_116_+0x596>
  40b60f:	mov    r10,rdi
  40b612:	mov    QWORD PTR [rbp-0xad8],r10
  40b619:	mov    rdi,QWORD PTR [rbp-0xad8]
  40b620:	mov    r10,rdi
  40b623:	mov    QWORD PTR [rbp-0xae0],r10
  40b62a:	movd   xmm0,edi
  40b62e:	movd   xmm1,DWORD PTR [rbp-0x70]
  40b633:	ucomiss xmm0,xmm1
  40b636:	setb   r10b
  40b63a:	setnp  r11b
  40b63e:	and    r10b,r11b
  40b641:	movzx  r10d,r10b
  40b645:	mov    rsi,r10
  40b648:	mov    r10,QWORD PTR [rbp-0xae0]
  40b64f:	mov    QWORD PTR [rbp-0x68],r10
  40b653:	jmp    40b0ee <p113d_FID_36_100_105_114_101_99_116_46_110_101_97_114_101_115_116_46_116_+0x6b>
  40b658:	mov    r8,rsi
  40b65b:	cmp    r8,0x1
  40b662:	sete   r8b
  40b666:	movzx  r8d,r8b
  40b66a:	mov    rdi,rsi
  40b66d:	shr    rdi,0x28
  40b671:	and    rdi,0x7fffff
  40b678:	movabs rdx,0x2
  40b682:	or     rdx,0x10000
  40b689:	cmp    rdi,rdx
  40b68c:	sete   dil
  40b690:	movzx  edi,dil
  40b694:	or     edi,r8d
  40b697:	mov    r10,rdi
  40b69a:	test   r10d,r10d
  40b69d:	je     40bab0 <p113d_FID_36_100_105_114_101_99_116_46_110_101_97_114_101_115_116_46_116_+0xa2d>
  40b6a3:	mov    rdi,r12
  40b6a6:	mov    rsi,rbx
  40b6a9:	xor    eax,eax
  40b6ab:	call   408ea5 <p113d_FID_36_100_105_114_101_99_116_46_115_120_>
  40b6b0:	mov    QWORD PTR [rbp-0xaf0],rax
  40b6b7:	mov    rdi,r12
  40b6ba:	mov    rsi,rbx
  40b6bd:	xor    eax,eax
  40b6bf:	call   408d77 <p113d_FID_36_100_105_114_101_99_116_46_115_121_>
  40b6c4:	mov    QWORD PTR [rbp-0xaf8],rax
  40b6cb:	mov    rdi,r12
  40b6ce:	mov    rsi,rbx
  40b6d1:	xor    eax,eax
  40b6d3:	call   408c49 <p113d_FID_36_100_105_114_101_99_116_46_115_122_>
  40b6d8:	mov    QWORD PTR [rbp-0xb00],rax
  40b6df:	mov    rdi,r12
  40b6e2:	mov    rsi,rbx
  40b6e5:	xor    eax,eax
  40b6e7:	call   408b1b <p113d_FID_36_100_105_114_101_99_116_46_115_114_>
  40b6ec:	mov    QWORD PTR [rbp-0xb08],rax
  40b6f3:	movd   xmm1,DWORD PTR [rbp-0xaf0]
  40b6fb:	movd   xmm2,r13d
  40b700:	subss  xmm2,xmm1
  40b704:	movaps xmm3,xmm2
  40b707:	movd   xmm1,DWORD PTR [rbp-0xaf8]
  40b70f:	movd   xmm2,r14d
  40b714:	subss  xmm2,xmm1
  40b718:	movaps xmm4,xmm2
  40b71b:	movd   xmm1,DWORD PTR [rbp-0xb00]
  40b723:	movd   xmm2,r15d
  40b728:	subss  xmm2,xmm1
  40b72c:	movaps xmm5,xmm2
  40b72f:	movd   xmm1,DWORD PTR [rbp-0x50]
  40b734:	movaps xmm2,xmm3
  40b737:	mulss  xmm2,xmm1
  40b73b:	movaps xmm6,xmm2
  40b73e:	movd   xmm1,DWORD PTR [rbp-0x58]
  40b743:	movaps xmm2,xmm4
  40b746:	mulss  xmm2,xmm1
  40b74a:	movaps xmm7,xmm6
  40b74d:	addss  xmm7,xmm2
  40b751:	movaps xmm2,xmm7
  40b754:	movd   xmm1,DWORD PTR [rbp-0x60]
  40b759:	movaps xmm6,xmm5
  40b75c:	mulss  xmm6,xmm1
  40b760:	movaps xmm7,xmm2
  40b763:	addss  xmm7,xmm6
  40b767:	movd   r10d,xmm7
  40b76c:	mov    QWORD PTR [rbp-0xb78],r10
  40b773:	movaps xmm2,xmm7
  40b776:	mulss  xmm2,xmm7
  40b77a:	movaps xmm6,xmm2
  40b77d:	movaps xmm2,xmm3
  40b780:	mulss  xmm2,xmm3
  40b784:	movaps xmm3,xmm2
  40b787:	movaps xmm2,xmm4
  40b78a:	mulss  xmm2,xmm4
  40b78e:	movaps xmm4,xmm3
  40b791:	addss  xmm4,xmm2
  40b795:	movaps xmm2,xmm4
  40b798:	movaps xmm3,xmm5
  40b79b:	mulss  xmm3,xmm5
  40b79f:	movaps xmm4,xmm2
  40b7a2:	addss  xmm4,xmm3
  40b7a6:	movaps xmm2,xmm4
  40b7a9:	movd   xmm1,DWORD PTR [rbp-0xb08]
  40b7b1:	movd   xmm3,DWORD PTR [rbp-0xb08]
  40b7b9:	mulss  xmm3,xmm1
  40b7bd:	movaps xmm4,xmm2
  40b7c0:	subss  xmm4,xmm3
  40b7c4:	movaps xmm2,xmm6
  40b7c7:	subss  xmm2,xmm4
  40b7cb:	movd   r10d,xmm2
  40b7d0:	mov    QWORD PTR [rbp-0xbe8],r10
  40b7d7:	movabs r10,0x0
  40b7e1:	movd   xmm0,r10d
  40b7e6:	movd   r10d,xmm0
  40b7eb:	pxor   xmm0,xmm0
  40b7ef:	cvtsi2ss xmm0,r10
  40b7f4:	movd   r10d,xmm0
  40b7f9:	movd   xmm2,r10d
  40b7fe:	movd   xmm0,DWORD PTR [rbp-0xbe8]
  40b806:	movaps xmm1,xmm2
  40b809:	ucomiss xmm0,xmm1
  40b80c:	setb   r10b
  40b810:	setnp  r11b
  40b814:	and    r10b,r11b
  40b817:	movzx  r10d,r10b
  40b81b:	mov    QWORD PTR [rbp-0xbf8],r10
  40b822:	cmp    r10,0x1
  40b829:	sete   r10b
  40b82d:	movzx  r10d,r10b
  40b831:	mov    QWORD PTR [rbp-0xc10],r10
  40b838:	test   r10d,r10d
  40b83b:	je     40b889 <p113d_FID_36_100_105_114_101_99_116_46_110_101_97_114_101_115_116_46_116_+0x806>
  40b841:	lea    r10,[rbp-0xc08]
  40b848:	movabs r11,0x3b9aca00
  40b852:	mov    QWORD PTR [r10],r11
  40b855:	movabs r10,0x3b9aca00
  40b85f:	movd   xmm0,r10d
  40b864:	movd   r10d,xmm0
  40b869:	pxor   xmm0,xmm0
  40b86d:	cvtsi2ss xmm0,r10
  40b872:	movd   r10d,xmm0
  40b877:	mov    rdi,r10
  40b87a:	mov    r10,rdi
  40b87d:	mov    QWORD PTR [rbp-0xc20],r10
  40b884:	jmp    40ba68 <p113d_FID_36_100_105_114_101_99_116_46_110_101_97_114_101_115_116_46_116_+0x9e5>
  40b889:	lea    r10,[rbp-0xc08]
  40b890:	movabs r11,0x0
  40b89a:	mov    QWORD PTR [r10],r11
  40b89d:	movabs r10,0x0
  40b8a7:	movd   xmm0,r10d
  40b8ac:	movd   r10d,xmm0
  40b8b1:	pxor   xmm0,xmm0
  40b8b5:	cvtsi2ss xmm0,r10
  40b8ba:	movd   r10d,xmm0
  40b8bf:	mov    rdi,r10
  40b8c2:	lea    r10,[rbp-0xc08]
  40b8c9:	mov    r11,rdi
  40b8cc:	mov    QWORD PTR [r10],r11
  40b8cf:	lea    r10,[rbp-0xc08]
  40b8d6:	mov    r11,QWORD PTR [rbp-0xb78]
  40b8dd:	mov    QWORD PTR [r10+0x8],r11
  40b8e1:	movd   xmm1,DWORD PTR [rbp-0xb78]
  40b8e9:	movd   xmm0,edi
  40b8ed:	subss  xmm0,xmm1
  40b8f1:	movd   edi,xmm0
  40b8f5:	mov    r10,rdi
  40b8f8:	mov    QWORD PTR [rbp-0xc28],r10
  40b8ff:	lea    r10,[rbp-0xc08]
  40b906:	mov    r11,QWORD PTR [rbp-0xbe8]
  40b90d:	mov    QWORD PTR [r10],r11
  40b910:	mov    rdi,r12
  40b913:	movabs rsi,0x24
  40b91d:	mov    esi,esi
  40b91f:	lea    rdx,[rbp-0xc08]
  40b926:	movabs rcx,0x1
  40b930:	mov    ecx,ecx
  40b932:	xor    eax,eax
  40b934:	call   420ab0 <p111_rt_op>
  40b939:	mov    rdi,rax
  40b93c:	lea    r10,[rbp-0xc08]
  40b943:	mov    r11,QWORD PTR [rbp-0xc28]
  40b94a:	mov    QWORD PTR [r10],r11
  40b94d:	lea    r10,[rbp-0xc08]
  40b954:	mov    r11,rdi
  40b957:	mov    QWORD PTR [r10+0x8],r11
  40b95b:	movd   xmm1,edi
  40b95f:	movd   xmm0,DWORD PTR [rbp-0xc28]
  40b967:	subss  xmm0,xmm1
  40b96b:	movd   edi,xmm0
  40b96f:	mov    r10,rdi
  40b972:	mov    QWORD PTR [rbp-0xc30],r10
  40b979:	movabs r10,0x1
  40b983:	movd   xmm0,r10d
  40b988:	movd   r10d,xmm0
  40b98d:	pxor   xmm0,xmm0
  40b991:	cvtsi2ss xmm0,r10
  40b996:	movd   r10d,xmm0
  40b99b:	movd   xmm2,r10d
  40b9a0:	movaps xmm3,xmm2
  40b9a3:	movabs r10,0x3e8
  40b9ad:	movd   xmm0,r10d
  40b9b2:	movd   r10d,xmm0
  40b9b7:	pxor   xmm0,xmm0
  40b9bb:	cvtsi2ss xmm0,r10
  40b9c0:	movd   r10d,xmm0
  40b9c5:	movd   xmm2,r10d
  40b9ca:	movaps xmm4,xmm3
  40b9cd:	divss  xmm4,xmm2
  40b9d1:	movd   xmm0,DWORD PTR [rbp-0xc30]
  40b9d9:	movaps xmm1,xmm4
  40b9dc:	ucomiss xmm0,xmm1
  40b9df:	setb   r10b
  40b9e3:	setnp  r11b
  40b9e7:	and    r10b,r11b
  40b9ea:	movzx  r10d,r10b
  40b9ee:	mov    QWORD PTR [rbp-0xc58],r10
  40b9f5:	cmp    r10,0x1
  40b9fc:	sete   r10b
  40ba00:	movzx  r10d,r10b
  40ba04:	mov    QWORD PTR [rbp-0xc60],r10
  40ba0b:	test   r10d,r10d
  40ba0e:	je     40ba4c <p113d_FID_36_100_105_114_101_99_116_46_110_101_97_114_101_115_116_46_116_+0x9c9>
  40ba14:	movabs r10,0x3b9aca00
  40ba1e:	movd   xmm0,r10d
  40ba23:	movd   r10d,xmm0
  40ba28:	pxor   xmm0,xmm0
  40ba2c:	cvtsi2ss xmm0,r10
  40ba31:	movd   r10d,xmm0
  40ba36:	movd   xmm2,r10d
  40ba3b:	movd   r10d,xmm2
  40ba40:	mov    QWORD PTR [rbp-0xc70],r10
  40ba47:	jmp    40ba5a <p113d_FID_36_100_105_114_101_99_116_46_110_101_97_114_101_115_116_46_116_+0x9d7>
  40ba4c:	mov    r10,QWORD PTR [rbp-0xc30]
  40ba53:	mov    QWORD PTR [rbp-0xc70],r10
  40ba5a:	mov    r10,QWORD PTR [rbp-0xc70]
  40ba61:	mov    QWORD PTR [rbp-0xc20],r10
  40ba68:	mov    r10,QWORD PTR [rbp-0xc20]
  40ba6f:	mov    QWORD PTR [rbp-0xc78],r10
  40ba76:	movd   xmm0,DWORD PTR [rbp-0xc20]
  40ba7e:	movd   xmm1,DWORD PTR [rbp-0x68]
  40ba83:	ucomiss xmm0,xmm1
  40ba86:	setb   r10b
  40ba8a:	setnp  r11b
  40ba8e:	and    r10b,r11b
  40ba91:	movzx  r10d,r10b
  40ba95:	mov    rsi,r10
  40ba98:	mov    r10,QWORD PTR [rbp-0x68]
  40ba9c:	mov    QWORD PTR [rbp-0x70],r10
  40baa0:	mov    r10,QWORD PTR [rbp-0xc78]
  40baa7:	mov    QWORD PTR [rbp-0x68],r10
  40baab:	jmp    40b0ee <p113d_FID_36_100_105_114_101_99_116_46_110_101_97_114_101_115_116_46_116_+0x6b>
  40bab0:	mov    rdi,r12
  40bab3:	movabs rsi,0x4
  40babd:	mov    esi,esi
  40babf:	xor    eax,eax
  40bac1:	call   420a90 <p111_rt_fail>
  40bac6:	mov    QWORD PTR [rbp-0x948],rax
  40bacd:	movabs rax,0x0
  40bad7:	mov    r12,QWORD PTR [rbp-0x10]
  40badb:	mov    rbx,QWORD PTR [rbp-0x8]
  40badf:	mov    r13,QWORD PTR [rbp-0x18]
  40bae3:	mov    r14,QWORD PTR [rbp-0x20]
  40bae7:	mov    r15,QWORD PTR [rbp-0x28]
  40baeb:	mov    rsp,rbp
  40baee:	pop    rbp
  40baef:	ret    
  40baf0:	mov    rdi,r12
  40baf3:	movabs rsi,0x4
  40bafd:	mov    esi,esi
  40baff:	xor    eax,eax
  40bb01:	call   420a90 <p111_rt_fail>
  40bb06:	mov    QWORD PTR [rbp-0x948],rax
  40bb0d:	movabs rax,0x0
  40bb17:	mov    r12,QWORD PTR [rbp-0x10]
  40bb1b:	mov    rbx,QWORD PTR [rbp-0x8]
  40bb1f:	mov    r13,QWORD PTR [rbp-0x18]
  40bb23:	mov    r14,QWORD PTR [rbp-0x20]
  40bb27:	mov    r15,QWORD PTR [rbp-0x28]
  40bb2b:	mov    rsp,rbp
  40bb2e:	pop    rbp
  40bb2f:	ret    

Disassembly of section .fini:
