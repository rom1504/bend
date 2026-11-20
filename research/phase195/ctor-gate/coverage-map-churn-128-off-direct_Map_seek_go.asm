000000000042fe54 <p111_FID_36_100_105_114_101_99_116_46_77_97_112_46_115_101_101_107_46_103_111_>:
  42fe54:	push   rbp
  42fe55:	mov    rbp,rsp
  42fe58:	sub    rsp,0x43f0
  42fe5f:	mov    QWORD PTR [rbp-0x10],r12
  42fe63:	mov    QWORD PTR [rbp-0x8],rbx
  42fe67:	mov    QWORD PTR [rbp-0x18],r13
  42fe6b:	mov    QWORD PTR [rbp-0x20],r14
  42fe6f:	mov    QWORD PTR [rbp-0x28],r15
  42fe73:	mov    rax,rdi
  42fe76:	mov    r12,rax
  42fe79:	mov    r10,r12
  42fe7c:	mov    r10,QWORD PTR [r10+0x28]
  42fe80:	mov    QWORD PTR [rbp-0x880],r10
  42fe87:	mov    r14,QWORD PTR [r12+0x30]
  42fe8c:	mov    r15,QWORD PTR [rbp-0x880]
  42fe93:	shr    r15,0x28
  42fe97:	and    r15,0xffff
  42fe9e:	movabs r11,0x2d
  42fea8:	mov    r13,r15
  42feab:	cmp    r13,r11
  42feae:	sete   r13b
  42feb2:	movzx  r13d,r13b
  42feb6:	mov    r10,r13
  42feb9:	test   r10d,r10d
  42febc:	je     434d4c <p111_FID_36_100_105_114_101_99_116_46_77_97_112_46_115_101_101_107_46_103_111_+0x4ef8>
  42fec2:	mov    rdi,r12
  42fec5:	mov    rsi,QWORD PTR [rbp-0x880]
  42fecc:	lea    rdx,[rbp-0x830]
  42fed3:	xor    eax,eax
  42fed5:	call   4501e0 <p125_rt_take3>
  42feda:	mov    QWORD PTR [rbp-0x8a0],rax
  42fee1:	lea    r10,[rbp-0x830]
  42fee8:	mov    r10,QWORD PTR [r10]
  42feeb:	mov    QWORD PTR [rbp-0x8a8],r10
  42fef2:	lea    r10,[rbp-0x830]
  42fef9:	mov    r10,QWORD PTR [r10+0x8]
  42fefd:	mov    QWORD PTR [rbp-0x8b0],r10
  42ff04:	lea    r10,[rbp-0x830]
  42ff0b:	mov    r10,QWORD PTR [r10+0x10]
  42ff0f:	mov    QWORD PTR [rbp-0x8b8],r10
  42ff16:	mov    r15,QWORD PTR [rbp-0x8b0]
  42ff1d:	shr    r15,0x28
  42ff21:	and    r15,0xffff
  42ff28:	movabs r11,0x2b
  42ff32:	mov    r13,r15
  42ff35:	cmp    r13,r11
  42ff38:	sete   r13b
  42ff3c:	movzx  r13d,r13b
  42ff40:	mov    r10,r13
  42ff43:	test   r10d,r10d
  42ff46:	je     431648 <p111_FID_36_100_105_114_101_99_116_46_77_97_112_46_115_101_101_107_46_103_111_+0x17f4>
  42ff4c:	mov    r15,QWORD PTR [rbp-0x8b8]
  42ff53:	shr    r15,0x28
  42ff57:	and    r15,0xffff
  42ff5e:	movabs r11,0x2b
  42ff68:	mov    r13,r15
  42ff6b:	cmp    r13,r11
  42ff6e:	sete   r13b
  42ff72:	movzx  r13d,r13b
  42ff76:	mov    r10,r13
  42ff79:	test   r10d,r10d
  42ff7c:	je     4305ba <p111_FID_36_100_105_114_101_99_116_46_77_97_112_46_115_101_101_107_46_103_111_+0x766>
  42ff82:	mov    r15,r14
  42ff85:	shr    r15,0x28
  42ff89:	and    r15,0xffff
  42ff90:	movabs r11,0x8
  42ff9a:	mov    r13,r15
  42ff9d:	cmp    r13,r11
  42ffa0:	sete   r13b
  42ffa4:	movzx  r13d,r13b
  42ffa8:	mov    r10,r13
  42ffab:	test   r10d,r10d
  42ffae:	je     430537 <p111_FID_36_100_105_114_101_99_116_46_77_97_112_46_115_101_101_107_46_103_111_+0x6e3>
  42ffb4:	mov    rdi,r12
  42ffb7:	mov    rsi,r14
  42ffba:	lea    rdx,[rbp-0x830]
  42ffc1:	xor    eax,eax
  42ffc3:	call   44ff80 <p125_rt_take2>
  42ffc8:	mov    QWORD PTR [rbp-0x8a0],rax
  42ffcf:	lea    r10,[rbp-0x830]
  42ffd6:	mov    r10,QWORD PTR [r10]
  42ffd9:	mov    QWORD PTR [rbp-0x8c0],r10
  42ffe0:	lea    r10,[rbp-0x830]
  42ffe7:	mov    r10,QWORD PTR [r10+0x8]
  42ffeb:	mov    QWORD PTR [rbp-0x8c8],r10
  42fff2:	cmp    r10,0x1
  42fff9:	sete   r10b
  42fffd:	movzx  r10d,r10b
  430001:	mov    QWORD PTR [rbp-0x8d0],r10
  430008:	mov    r10,QWORD PTR [rbp-0x8c8]
  43000f:	shr    r10,0x28
  430013:	mov    QWORD PTR [rbp-0x8d8],r10
  43001a:	and    r10,0x7fffff
  430021:	mov    QWORD PTR [rbp-0x8d8],r10
  430028:	movabs r10,0x2
  430032:	or     r10,0x10000
  430039:	mov    QWORD PTR [rbp-0x8e0],r10
  430040:	mov    r10,QWORD PTR [rbp-0x8d8]
  430047:	mov    r11,QWORD PTR [rbp-0x8e0]
  43004e:	cmp    r10,r11
  430051:	sete   r10b
  430055:	movzx  r10d,r10b
  430059:	mov    QWORD PTR [rbp-0x8e8],r10
  430060:	mov    r11,r10
  430063:	mov    r13,QWORD PTR [rbp-0x8d0]
  43006a:	or     r13d,r11d
  43006d:	xor    r13d,0x1
  430074:	mov    r10,r13
  430077:	test   r10d,r10d
  43007a:	je     430240 <p111_FID_36_100_105_114_101_99_116_46_77_97_112_46_115_101_101_107_46_103_111_+0x3ec>
  430080:	movabs rdi,0x1002b0000000000
  43008a:	movabs rsi,0x1002b0000000000
  430094:	lea    r10,[rbp-0x830]
  43009b:	mov    r11,QWORD PTR [rbp-0x8a8]
  4300a2:	mov    QWORD PTR [r10],r11
  4300a5:	lea    r10,[rbp-0x830]
  4300ac:	mov    r11,rdi
  4300af:	mov    QWORD PTR [r10+0x8],r11
  4300b3:	lea    r10,[rbp-0x830]
  4300ba:	mov    r11,rsi
  4300bd:	mov    QWORD PTR [r10+0x10],r11
  4300c1:	mov    rdi,r12
  4300c4:	movabs rsi,0x2d
  4300ce:	mov    esi,esi
  4300d0:	lea    rdx,[rbp-0x830]
  4300d7:	xor    eax,eax
  4300d9:	call   450110 <p125_rt_ctor3>
  4300de:	mov    rbx,rax
  4300e1:	mov    r10,rbx
  4300e4:	mov    QWORD PTR [rbp-0x908],r10
  4300eb:	movabs rdi,0x1000b0000000000
  4300f5:	lea    r10,[rbp-0x830]
  4300fc:	mov    r11,QWORD PTR [rbp-0x8c0]
  430103:	mov    QWORD PTR [r10],r11
  430106:	lea    r10,[rbp-0x830]
  43010d:	mov    r11,rdi
  430110:	mov    QWORD PTR [r10+0x8],r11
  430114:	mov    rdi,r12
  430117:	movabs rsi,0x8
  430121:	mov    esi,esi
  430123:	lea    rdx,[rbp-0x830]
  43012a:	xor    eax,eax
  43012c:	call   44fe90 <p125_rt_ctor2>
  430131:	mov    rbx,rax
  430134:	mov    rdi,rbx
  430137:	lea    r10,[rbp-0x830]
  43013e:	mov    r11,QWORD PTR [rbp-0x908]
  430145:	mov    QWORD PTR [r10],r11
  430148:	lea    r10,[rbp-0x830]
  43014f:	mov    r11,rdi
  430152:	mov    QWORD PTR [r10+0x8],r11
  430156:	mov    rdi,r12
  430159:	movabs rsi,0x8
  430163:	mov    esi,esi
  430165:	lea    rdx,[rbp-0x830]
  43016c:	xor    eax,eax
  43016e:	call   44fe90 <p125_rt_ctor2>
  430173:	mov    rbx,rax
  430176:	lea    r10,[rbp-0x830]
  43017d:	mov    r11,rbx
  430180:	mov    QWORD PTR [r10],r11
  430183:	lea    r10,[rip+0x28a56]        # 458be0 <p111_program>
  43018a:	movabs rdi,0x4
  430194:	and    rdi,QWORD PTR [r10+0x58]
  430198:	mov    r10,rdi
  43019b:	test   r10d,r10d
  43019e:	je     4301fc <p111_FID_36_100_105_114_101_99_116_46_77_97_112_46_115_101_101_107_46_103_111_+0x3a8>
  4301a4:	lea    r10,[rbp-0x830]
  4301ab:	mov    rdi,QWORD PTR [r10]
  4301ae:	mov    QWORD PTR [r12+0x28],rdi
  4301b3:	mov    r10,r12
  4301b6:	movabs r11,0x1
  4301c0:	mov    DWORD PTR [r10+0x1c],r11d
  4301c4:	mov    rdi,QWORD PTR [r12+0x10]
  4301c9:	movabs r11,0xfffffffffffffff8
  4301d3:	mov    rsi,rdi
  4301d6:	add    rsi,r11
  4301d9:	mov    QWORD PTR [r12+0x10],rsi
  4301de:	mov    rdi,QWORD PTR [rsi]
  4301e1:	mov    DWORD PTR [r12+0x20],edi
  4301e6:	movabs r10,0x0
  4301f0:	mov    QWORD PTR [rbp-0x950],r10
  4301f7:	jmp    430220 <p111_FID_36_100_105_114_101_99_116_46_77_97_112_46_115_101_101_107_46_103_111_+0x3cc>
  4301fc:	mov    rdi,r12
  4301ff:	lea    rsi,[rbp-0x830]
  430206:	movabs rdx,0x1
  430210:	mov    edx,edx
  430212:	xor    eax,eax
  430214:	call   44a800 <p111_rt_return>
  430219:	mov    QWORD PTR [rbp-0x950],rax
  430220:	mov    rax,QWORD PTR [rbp-0x950]
  430227:	mov    r12,QWORD PTR [rbp-0x10]
  43022b:	mov    rbx,QWORD PTR [rbp-0x8]
  43022f:	mov    r13,QWORD PTR [rbp-0x18]
  430233:	mov    r14,QWORD PTR [rbp-0x20]
  430237:	mov    r15,QWORD PTR [rbp-0x28]
  43023b:	mov    rsp,rbp
  43023e:	pop    rbp
  43023f:	ret    
  430240:	mov    r10,QWORD PTR [rbp-0x8c8]
  430247:	cmp    r10,0x1
  43024e:	sete   r10b
  430252:	movzx  r10d,r10b
  430256:	mov    QWORD PTR [rbp-0x8d0],r10
  43025d:	mov    r10,QWORD PTR [rbp-0x8c8]
  430264:	shr    r10,0x28
  430268:	mov    QWORD PTR [rbp-0x8d8],r10
  43026f:	and    r10,0x7fffff
  430276:	mov    QWORD PTR [rbp-0x8d8],r10
  43027d:	movabs r10,0x2
  430287:	or     r10,0x10000
  43028e:	mov    QWORD PTR [rbp-0x8e0],r10
  430295:	mov    r10,QWORD PTR [rbp-0x8d8]
  43029c:	mov    r11,QWORD PTR [rbp-0x8e0]
  4302a3:	cmp    r10,r11
  4302a6:	sete   r10b
  4302aa:	movzx  r10d,r10b
  4302ae:	mov    QWORD PTR [rbp-0x8e8],r10
  4302b5:	mov    r11,r10
  4302b8:	mov    r13,QWORD PTR [rbp-0x8d0]
  4302bf:	or     r13d,r11d
  4302c2:	mov    r10,r13
  4302c5:	test   r10d,r10d
  4302c8:	je     43048e <p111_FID_36_100_105_114_101_99_116_46_77_97_112_46_115_101_101_107_46_103_111_+0x63a>
  4302ce:	movabs rdi,0x1002b0000000000
  4302d8:	movabs rsi,0x1002b0000000000
  4302e2:	lea    r10,[rbp-0x830]
  4302e9:	mov    r11,QWORD PTR [rbp-0x8a8]
  4302f0:	mov    QWORD PTR [r10],r11
  4302f3:	lea    r10,[rbp-0x830]
  4302fa:	mov    r11,rdi
  4302fd:	mov    QWORD PTR [r10+0x8],r11
  430301:	lea    r10,[rbp-0x830]
  430308:	mov    r11,rsi
  43030b:	mov    QWORD PTR [r10+0x10],r11
  43030f:	mov    rdi,r12
  430312:	movabs rsi,0x2d
  43031c:	mov    esi,esi
  43031e:	lea    rdx,[rbp-0x830]
  430325:	xor    eax,eax
  430327:	call   450110 <p125_rt_ctor3>
  43032c:	mov    rbx,rax
  43032f:	mov    r10,rbx
  430332:	mov    QWORD PTR [rbp-0x968],r10
  430339:	movabs rdi,0x1000b0000000000
  430343:	lea    r10,[rbp-0x830]
  43034a:	mov    r11,QWORD PTR [rbp-0x8c0]
  430351:	mov    QWORD PTR [r10],r11
  430354:	lea    r10,[rbp-0x830]
  43035b:	mov    r11,rdi
  43035e:	mov    QWORD PTR [r10+0x8],r11
  430362:	mov    rdi,r12
  430365:	movabs rsi,0x8
  43036f:	mov    esi,esi
  430371:	lea    rdx,[rbp-0x830]
  430378:	xor    eax,eax
  43037a:	call   44fe90 <p125_rt_ctor2>
  43037f:	mov    rbx,rax
  430382:	mov    rdi,rbx
  430385:	lea    r10,[rbp-0x830]
  43038c:	mov    r11,QWORD PTR [rbp-0x968]
  430393:	mov    QWORD PTR [r10],r11
  430396:	lea    r10,[rbp-0x830]
  43039d:	mov    r11,rdi
  4303a0:	mov    QWORD PTR [r10+0x8],r11
  4303a4:	mov    rdi,r12
  4303a7:	movabs rsi,0x8
  4303b1:	mov    esi,esi
  4303b3:	lea    rdx,[rbp-0x830]
  4303ba:	xor    eax,eax
  4303bc:	call   44fe90 <p125_rt_ctor2>
  4303c1:	mov    rbx,rax
  4303c4:	lea    r10,[rbp-0x830]
  4303cb:	mov    r11,rbx
  4303ce:	mov    QWORD PTR [r10],r11
  4303d1:	lea    r10,[rip+0x28808]        # 458be0 <p111_program>
  4303d8:	movabs rdi,0x4
  4303e2:	and    rdi,QWORD PTR [r10+0x58]
  4303e6:	mov    r10,rdi
  4303e9:	test   r10d,r10d
  4303ec:	je     43044a <p111_FID_36_100_105_114_101_99_116_46_77_97_112_46_115_101_101_107_46_103_111_+0x5f6>
  4303f2:	lea    r10,[rbp-0x830]
  4303f9:	mov    rdi,QWORD PTR [r10]
  4303fc:	mov    QWORD PTR [r12+0x28],rdi
  430401:	mov    r10,r12
  430404:	movabs r11,0x1
  43040e:	mov    DWORD PTR [r10+0x1c],r11d
  430412:	mov    rdi,QWORD PTR [r12+0x10]
  430417:	movabs r11,0xfffffffffffffff8
  430421:	mov    rsi,rdi
  430424:	add    rsi,r11
  430427:	mov    QWORD PTR [r12+0x10],rsi
  43042c:	mov    rdi,QWORD PTR [rsi]
  43042f:	mov    DWORD PTR [r12+0x20],edi
  430434:	movabs r10,0x0
  43043e:	mov    QWORD PTR [rbp-0x950],r10
  430445:	jmp    43046e <p111_FID_36_100_105_114_101_99_116_46_77_97_112_46_115_101_101_107_46_103_111_+0x61a>
  43044a:	mov    rdi,r12
  43044d:	lea    rsi,[rbp-0x830]
  430454:	movabs rdx,0x1
  43045e:	mov    edx,edx
  430460:	xor    eax,eax
  430462:	call   44a800 <p111_rt_return>
  430467:	mov    QWORD PTR [rbp-0x950],rax
  43046e:	mov    rax,QWORD PTR [rbp-0x950]
  430475:	mov    r12,QWORD PTR [rbp-0x10]
  430479:	mov    rbx,QWORD PTR [rbp-0x8]
  43047d:	mov    r13,QWORD PTR [rbp-0x18]
  430481:	mov    r14,QWORD PTR [rbp-0x20]
  430485:	mov    r15,QWORD PTR [rbp-0x28]
  430489:	mov    rsp,rbp
  43048c:	pop    rbp
  43048d:	ret    
  43048e:	mov    rdi,r12
  430491:	mov    rsi,QWORD PTR [rbp-0x8a8]
  430498:	xor    eax,eax
  43049a:	call   44a1e0 <p111_rt_sink>
  43049f:	mov    QWORD PTR [rbp-0x8a0],rax
  4304a6:	mov    rdi,r12
  4304a9:	mov    rsi,QWORD PTR [rbp-0x8c0]
  4304b0:	xor    eax,eax
  4304b2:	call   44a1e0 <p111_rt_sink>
  4304b7:	mov    QWORD PTR [rbp-0x8a0],rax
  4304be:	lea    r10,[rbp-0x830]
  4304c5:	mov    r11,QWORD PTR [rbp-0x8c8]
  4304cc:	mov    QWORD PTR [r10],r11
  4304cf:	mov    rdi,QWORD PTR [r12+0x10]
  4304d4:	mov    r10,rdi
  4304d7:	mov    r11,QWORD PTR [rbp-0x8c8]
  4304de:	mov    QWORD PTR [r10],r11
  4304e1:	mov    r10,rdi
  4304e4:	movabs r11,0x152
  4304ee:	mov    QWORD PTR [r10+0x8],r11
  4304f2:	mov    rsi,rdi
  4304f5:	add    rsi,0x10
  4304fc:	mov    QWORD PTR [r12+0x10],rsi
  430501:	mov    rdi,r12
  430504:	movabs rsi,0x4
  43050e:	mov    esi,esi
  430510:	xor    eax,eax
  430512:	call   44a970 <p111_rt_fail>
  430517:	mov    QWORD PTR [rbp-0x950],rax
  43051e:	mov    r12,QWORD PTR [rbp-0x10]
  430522:	mov    rbx,QWORD PTR [rbp-0x8]
  430526:	mov    r13,QWORD PTR [rbp-0x18]
  43052a:	mov    r14,QWORD PTR [rbp-0x20]
  43052e:	mov    r15,QWORD PTR [rbp-0x28]
  430532:	mov    rsp,rbp
  430535:	pop    rbp
  430536:	ret    
  430537:	mov    rdi,r12
  43053a:	mov    rsi,QWORD PTR [rbp-0x8a8]
  430541:	xor    eax,eax
  430543:	call   44a1e0 <p111_rt_sink>
  430548:	mov    QWORD PTR [rbp-0x8a0],rax
  43054f:	lea    r10,[rbp-0x830]
  430556:	mov    r11,r14
  430559:	mov    QWORD PTR [r10],r11
  43055c:	mov    rdi,QWORD PTR [r12+0x10]
  430561:	mov    QWORD PTR [rdi],r14
  430564:	mov    r10,rdi
  430567:	movabs r11,0x153
  430571:	mov    QWORD PTR [r10+0x8],r11
  430575:	mov    rsi,rdi
  430578:	add    rsi,0x10
  43057f:	mov    QWORD PTR [r12+0x10],rsi
  430584:	mov    rdi,r12
  430587:	movabs rsi,0x4
  430591:	mov    esi,esi
  430593:	xor    eax,eax
  430595:	call   44a970 <p111_rt_fail>
  43059a:	mov    QWORD PTR [rbp-0x950],rax
  4305a1:	mov    r12,QWORD PTR [rbp-0x10]
  4305a5:	mov    rbx,QWORD PTR [rbp-0x8]
  4305a9:	mov    r13,QWORD PTR [rbp-0x18]
  4305ad:	mov    r14,QWORD PTR [rbp-0x20]
  4305b1:	mov    r15,QWORD PTR [rbp-0x28]
  4305b5:	mov    rsp,rbp
  4305b8:	pop    rbp
  4305b9:	ret    
  4305ba:	mov    r15,QWORD PTR [rbp-0x8b8]
  4305c1:	shr    r15,0x28
  4305c5:	and    r15,0xffff
  4305cc:	movabs r11,0x2c
  4305d6:	mov    r13,r15
  4305d9:	cmp    r13,r11
  4305dc:	sete   r13b
  4305e0:	movzx  r13d,r13b
  4305e4:	mov    r10,r13
  4305e7:	test   r10d,r10d
  4305ea:	je     430d9f <p111_FID_36_100_105_114_101_99_116_46_77_97_112_46_115_101_101_107_46_103_111_+0xf4b>
  4305f0:	mov    rdi,r12
  4305f3:	mov    rsi,QWORD PTR [rbp-0x8b8]
  4305fa:	lea    rdx,[rbp-0x830]
  430601:	xor    eax,eax
  430603:	call   44ff80 <p125_rt_take2>
  430608:	mov    QWORD PTR [rbp-0x8a0],rax
  43060f:	lea    r10,[rbp-0x830]
  430616:	mov    r10,QWORD PTR [r10]
  430619:	mov    QWORD PTR [rbp-0x9d0],r10
  430620:	lea    r10,[rbp-0x830]
  430627:	mov    r10,QWORD PTR [r10+0x8]
  43062b:	mov    QWORD PTR [rbp-0x9d8],r10
  430632:	mov    r15,r14
  430635:	shr    r15,0x28
  430639:	and    r15,0xffff
  430640:	movabs r11,0x8
  43064a:	mov    r13,r15
  43064d:	cmp    r13,r11
  430650:	sete   r13b
  430654:	movzx  r13d,r13b
  430658:	mov    r10,r13
  43065b:	test   r10d,r10d
  43065e:	je     430cec <p111_FID_36_100_105_114_101_99_116_46_77_97_112_46_115_101_101_107_46_103_111_+0xe98>
  430664:	mov    rdi,r12
  430667:	mov    rsi,r14
  43066a:	lea    rdx,[rbp-0x830]
  430671:	xor    eax,eax
  430673:	call   44ff80 <p125_rt_take2>
  430678:	mov    QWORD PTR [rbp-0x8a0],rax
  43067f:	lea    r10,[rbp-0x830]
  430686:	mov    r10,QWORD PTR [r10]
  430689:	mov    QWORD PTR [rbp-0x9e0],r10
  430690:	lea    r10,[rbp-0x830]
  430697:	mov    r10,QWORD PTR [r10+0x8]
  43069b:	mov    QWORD PTR [rbp-0x9e8],r10
  4306a2:	cmp    r10,0x1
  4306a9:	sete   r10b
  4306ad:	movzx  r10d,r10b
  4306b1:	mov    QWORD PTR [rbp-0x8d0],r10
  4306b8:	mov    r10,QWORD PTR [rbp-0x9e8]
  4306bf:	shr    r10,0x28
  4306c3:	mov    QWORD PTR [rbp-0x8d8],r10
  4306ca:	and    r10,0x7fffff
  4306d1:	mov    QWORD PTR [rbp-0x8d8],r10
  4306d8:	movabs r10,0x2
  4306e2:	or     r10,0x10000
  4306e9:	mov    QWORD PTR [rbp-0x8e0],r10
  4306f0:	mov    r10,QWORD PTR [rbp-0x8d8]
  4306f7:	mov    r11,QWORD PTR [rbp-0x8e0]
  4306fe:	cmp    r10,r11
  430701:	sete   r10b
  430705:	movzx  r10d,r10b
  430709:	mov    QWORD PTR [rbp-0x8e8],r10
  430710:	mov    r11,r10
  430713:	mov    r13,QWORD PTR [rbp-0x8d0]
  43071a:	or     r13d,r11d
  43071d:	xor    r13d,0x1
  430724:	mov    r10,r13
  430727:	test   r10d,r10d
  43072a:	je     43093a <p111_FID_36_100_105_114_101_99_116_46_77_97_112_46_115_101_101_107_46_103_111_+0xae6>
  430730:	movabs r10,0x1002b0000000000
  43073a:	mov    QWORD PTR [rbp-0x9f0],r10
  430741:	mov    rdi,QWORD PTR [rbp-0x9d0]
  430748:	lea    r10,[rbp-0x830]
  43074f:	mov    r11,rdi
  430752:	mov    QWORD PTR [r10],r11
  430755:	lea    r10,[rbp-0x830]
  43075c:	mov    r11,QWORD PTR [rbp-0x9d8]
  430763:	mov    QWORD PTR [r10+0x8],r11
  430767:	mov    rdi,r12
  43076a:	movabs rsi,0x2c
  430774:	mov    esi,esi
  430776:	lea    rdx,[rbp-0x830]
  43077d:	xor    eax,eax
  43077f:	call   44fe90 <p125_rt_ctor2>
  430784:	mov    rbx,rax
  430787:	mov    rdi,rbx
  43078a:	lea    r10,[rbp-0x830]
  430791:	mov    r11,QWORD PTR [rbp-0x8a8]
  430798:	mov    QWORD PTR [r10],r11
  43079b:	lea    r10,[rbp-0x830]
  4307a2:	mov    r11,QWORD PTR [rbp-0x9f0]
  4307a9:	mov    QWORD PTR [r10+0x8],r11
  4307ad:	lea    r10,[rbp-0x830]
  4307b4:	mov    r11,rdi
  4307b7:	mov    QWORD PTR [r10+0x10],r11
  4307bb:	mov    rdi,r12
  4307be:	movabs rsi,0x2d
  4307c8:	mov    esi,esi
  4307ca:	lea    rdx,[rbp-0x830]
  4307d1:	xor    eax,eax
  4307d3:	call   450110 <p125_rt_ctor3>
  4307d8:	mov    rbx,rax
  4307db:	mov    r10,rbx
  4307de:	mov    QWORD PTR [rbp-0xa08],r10
  4307e5:	movabs rdi,0x1000b0000000000
  4307ef:	lea    r10,[rbp-0x830]
  4307f6:	mov    r11,QWORD PTR [rbp-0x9e0]
  4307fd:	mov    QWORD PTR [r10],r11
  430800:	lea    r10,[rbp-0x830]
  430807:	mov    r11,rdi
  43080a:	mov    QWORD PTR [r10+0x8],r11
  43080e:	mov    rdi,r12
  430811:	movabs rsi,0x8
  43081b:	mov    esi,esi
  43081d:	lea    rdx,[rbp-0x830]
  430824:	xor    eax,eax
  430826:	call   44fe90 <p125_rt_ctor2>
  43082b:	mov    rbx,rax
  43082e:	mov    rdi,rbx
  430831:	lea    r10,[rbp-0x830]
  430838:	mov    r11,QWORD PTR [rbp-0xa08]
  43083f:	mov    QWORD PTR [r10],r11
  430842:	lea    r10,[rbp-0x830]
  430849:	mov    r11,rdi
  43084c:	mov    QWORD PTR [r10+0x8],r11
  430850:	mov    rdi,r12
  430853:	movabs rsi,0x8
  43085d:	mov    esi,esi
  43085f:	lea    rdx,[rbp-0x830]
  430866:	xor    eax,eax
  430868:	call   44fe90 <p125_rt_ctor2>
  43086d:	mov    rbx,rax
  430870:	lea    r10,[rbp-0x830]
  430877:	mov    r11,rbx
  43087a:	mov    QWORD PTR [r10],r11
  43087d:	lea    r10,[rip+0x2835c]        # 458be0 <p111_program>
  430884:	movabs rdi,0x4
  43088e:	and    rdi,QWORD PTR [r10+0x58]
  430892:	mov    r10,rdi
  430895:	test   r10d,r10d
  430898:	je     4308f6 <p111_FID_36_100_105_114_101_99_116_46_77_97_112_46_115_101_101_107_46_103_111_+0xaa2>
  43089e:	lea    r10,[rbp-0x830]
  4308a5:	mov    rdi,QWORD PTR [r10]
  4308a8:	mov    QWORD PTR [r12+0x28],rdi
  4308ad:	mov    r10,r12
  4308b0:	movabs r11,0x1
  4308ba:	mov    DWORD PTR [r10+0x1c],r11d
  4308be:	mov    rdi,QWORD PTR [r12+0x10]
  4308c3:	movabs r11,0xfffffffffffffff8
  4308cd:	mov    rsi,rdi
  4308d0:	add    rsi,r11
  4308d3:	mov    QWORD PTR [r12+0x10],rsi
  4308d8:	mov    rdi,QWORD PTR [rsi]
  4308db:	mov    DWORD PTR [r12+0x20],edi
  4308e0:	movabs r10,0x0
  4308ea:	mov    QWORD PTR [rbp-0x950],r10
  4308f1:	jmp    43091a <p111_FID_36_100_105_114_101_99_116_46_77_97_112_46_115_101_101_107_46_103_111_+0xac6>
  4308f6:	mov    rdi,r12
  4308f9:	lea    rsi,[rbp-0x830]
  430900:	movabs rdx,0x1
  43090a:	mov    edx,edx
  43090c:	xor    eax,eax
  43090e:	call   44a800 <p111_rt_return>
  430913:	mov    QWORD PTR [rbp-0x950],rax
  43091a:	mov    rax,QWORD PTR [rbp-0x950]
  430921:	mov    r12,QWORD PTR [rbp-0x10]
  430925:	mov    rbx,QWORD PTR [rbp-0x8]
  430929:	mov    r13,QWORD PTR [rbp-0x18]
  43092d:	mov    r14,QWORD PTR [rbp-0x20]
  430931:	mov    r15,QWORD PTR [rbp-0x28]
  430935:	mov    rsp,rbp
  430938:	pop    rbp
  430939:	ret    
  43093a:	mov    r10,QWORD PTR [rbp-0x9e8]
  430941:	cmp    r10,0x1
  430948:	sete   r10b
  43094c:	movzx  r10d,r10b
  430950:	mov    QWORD PTR [rbp-0x8d0],r10
  430957:	mov    r10,QWORD PTR [rbp-0x9e8]
  43095e:	shr    r10,0x28
  430962:	mov    QWORD PTR [rbp-0x8d8],r10
  430969:	and    r10,0x7fffff
  430970:	mov    QWORD PTR [rbp-0x8d8],r10
  430977:	movabs r10,0x2
  430981:	or     r10,0x10000
  430988:	mov    QWORD PTR [rbp-0x8e0],r10
  43098f:	mov    r10,QWORD PTR [rbp-0x8d8]
  430996:	mov    r11,QWORD PTR [rbp-0x8e0]
  43099d:	cmp    r10,r11
  4309a0:	sete   r10b
  4309a4:	movzx  r10d,r10b
  4309a8:	mov    QWORD PTR [rbp-0x8e8],r10
  4309af:	mov    r11,r10
  4309b2:	mov    r13,QWORD PTR [rbp-0x8d0]
  4309b9:	or     r13d,r11d
  4309bc:	mov    r10,r13
  4309bf:	test   r10d,r10d
  4309c2:	je     430c13 <p111_FID_36_100_105_114_101_99_116_46_77_97_112_46_115_101_101_107_46_103_111_+0xdbf>
  4309c8:	movabs r10,0x1002b0000000000
  4309d2:	mov    QWORD PTR [rbp-0xa50],r10
  4309d9:	mov    rdi,r12
  4309dc:	mov    rsi,QWORD PTR [rbp-0x9d0]
  4309e3:	xor    eax,eax
  4309e5:	call   44a150 <p111_rt_keep>
  4309ea:	mov    QWORD PTR [rbp-0x9d0],rax
  4309f1:	mov    rdi,rax
  4309f4:	lea    r10,[rbp-0x830]
  4309fb:	mov    r11,rdi
  4309fe:	mov    QWORD PTR [r10],r11
  430a01:	lea    r10,[rbp-0x830]
  430a08:	mov    r11,QWORD PTR [rbp-0x9d8]
  430a0f:	mov    QWORD PTR [r10+0x8],r11
  430a13:	mov    rdi,r12
  430a16:	movabs rsi,0x2c
  430a20:	mov    esi,esi
  430a22:	lea    rdx,[rbp-0x830]
  430a29:	xor    eax,eax
  430a2b:	call   44fe90 <p125_rt_ctor2>
  430a30:	mov    rbx,rax
  430a33:	mov    rdi,rbx
  430a36:	lea    r10,[rbp-0x830]
  430a3d:	mov    r11,QWORD PTR [rbp-0x8a8]
  430a44:	mov    QWORD PTR [r10],r11
  430a47:	lea    r10,[rbp-0x830]
  430a4e:	mov    r11,QWORD PTR [rbp-0xa50]
  430a55:	mov    QWORD PTR [r10+0x8],r11
  430a59:	lea    r10,[rbp-0x830]
  430a60:	mov    r11,rdi
  430a63:	mov    QWORD PTR [r10+0x10],r11
  430a67:	mov    rdi,r12
  430a6a:	movabs rsi,0x2d
  430a74:	mov    esi,esi
  430a76:	lea    rdx,[rbp-0x830]
  430a7d:	xor    eax,eax
  430a7f:	call   450110 <p125_rt_ctor3>
  430a84:	mov    rbx,rax
  430a87:	mov    r10,rbx
  430a8a:	mov    QWORD PTR [rbp-0xa68],r10
  430a91:	mov    rdi,QWORD PTR [rbp-0x9d0]
  430a98:	lea    r10,[rbp-0x830]
  430a9f:	mov    r11,rdi
  430aa2:	mov    QWORD PTR [r10],r11
  430aa5:	mov    rdi,r12
  430aa8:	movabs rsi,0xc
  430ab2:	mov    esi,esi
  430ab4:	lea    rdx,[rbp-0x830]
  430abb:	xor    eax,eax
  430abd:	call   44fc60 <p125_rt_ctor1>
  430ac2:	mov    rbx,rax
  430ac5:	mov    rdi,rbx
  430ac8:	lea    r10,[rbp-0x830]
  430acf:	mov    r11,QWORD PTR [rbp-0x9e0]
  430ad6:	mov    QWORD PTR [r10],r11
  430ad9:	lea    r10,[rbp-0x830]
  430ae0:	mov    r11,rdi
  430ae3:	mov    QWORD PTR [r10+0x8],r11
  430ae7:	mov    rdi,r12
  430aea:	movabs rsi,0x8
  430af4:	mov    esi,esi
  430af6:	lea    rdx,[rbp-0x830]
  430afd:	xor    eax,eax
  430aff:	call   44fe90 <p125_rt_ctor2>
  430b04:	mov    rbx,rax
  430b07:	mov    rdi,rbx
  430b0a:	lea    r10,[rbp-0x830]
  430b11:	mov    r11,QWORD PTR [rbp-0xa68]
  430b18:	mov    QWORD PTR [r10],r11
  430b1b:	lea    r10,[rbp-0x830]
  430b22:	mov    r11,rdi
  430b25:	mov    QWORD PTR [r10+0x8],r11
  430b29:	mov    rdi,r12
  430b2c:	movabs rsi,0x8
  430b36:	mov    esi,esi
  430b38:	lea    rdx,[rbp-0x830]
  430b3f:	xor    eax,eax
  430b41:	call   44fe90 <p125_rt_ctor2>
  430b46:	mov    rbx,rax
  430b49:	lea    r10,[rbp-0x830]
  430b50:	mov    r11,rbx
  430b53:	mov    QWORD PTR [r10],r11
  430b56:	lea    r10,[rip+0x28083]        # 458be0 <p111_program>
  430b5d:	movabs rdi,0x4
  430b67:	and    rdi,QWORD PTR [r10+0x58]
  430b6b:	mov    r10,rdi
  430b6e:	test   r10d,r10d
  430b71:	je     430bcf <p111_FID_36_100_105_114_101_99_116_46_77_97_112_46_115_101_101_107_46_103_111_+0xd7b>
  430b77:	lea    r10,[rbp-0x830]
  430b7e:	mov    rdi,QWORD PTR [r10]
  430b81:	mov    QWORD PTR [r12+0x28],rdi
  430b86:	mov    r10,r12
  430b89:	movabs r11,0x1
  430b93:	mov    DWORD PTR [r10+0x1c],r11d
  430b97:	mov    rdi,QWORD PTR [r12+0x10]
  430b9c:	movabs r11,0xfffffffffffffff8
  430ba6:	mov    rsi,rdi
  430ba9:	add    rsi,r11
  430bac:	mov    QWORD PTR [r12+0x10],rsi
  430bb1:	mov    rdi,QWORD PTR [rsi]
  430bb4:	mov    DWORD PTR [r12+0x20],edi
  430bb9:	movabs r10,0x0
  430bc3:	mov    QWORD PTR [rbp-0x950],r10
  430bca:	jmp    430bf3 <p111_FID_36_100_105_114_101_99_116_46_77_97_112_46_115_101_101_107_46_103_111_+0xd9f>
  430bcf:	mov    rdi,r12
  430bd2:	lea    rsi,[rbp-0x830]
  430bd9:	movabs rdx,0x1
  430be3:	mov    edx,edx
  430be5:	xor    eax,eax
  430be7:	call   44a800 <p111_rt_return>
  430bec:	mov    QWORD PTR [rbp-0x950],rax
  430bf3:	mov    rax,QWORD PTR [rbp-0x950]
  430bfa:	mov    r12,QWORD PTR [rbp-0x10]
  430bfe:	mov    rbx,QWORD PTR [rbp-0x8]
  430c02:	mov    r13,QWORD PTR [rbp-0x18]
  430c06:	mov    r14,QWORD PTR [rbp-0x20]
  430c0a:	mov    r15,QWORD PTR [rbp-0x28]
  430c0e:	mov    rsp,rbp
  430c11:	pop    rbp
  430c12:	ret    
  430c13:	mov    rdi,r12
  430c16:	mov    rsi,QWORD PTR [rbp-0x8a8]
  430c1d:	xor    eax,eax
  430c1f:	call   44a1e0 <p111_rt_sink>
  430c24:	mov    QWORD PTR [rbp-0x8a0],rax
  430c2b:	mov    rdi,r12
  430c2e:	mov    rsi,QWORD PTR [rbp-0x9d0]
  430c35:	xor    eax,eax
  430c37:	call   44a1e0 <p111_rt_sink>
  430c3c:	mov    QWORD PTR [rbp-0x8a0],rax
  430c43:	mov    rdi,r12
  430c46:	mov    rsi,QWORD PTR [rbp-0x9d8]
  430c4d:	xor    eax,eax
  430c4f:	call   44a1e0 <p111_rt_sink>
  430c54:	mov    QWORD PTR [rbp-0x8a0],rax
  430c5b:	mov    rdi,r12
  430c5e:	mov    rsi,QWORD PTR [rbp-0x9e0]
  430c65:	xor    eax,eax
  430c67:	call   44a1e0 <p111_rt_sink>
  430c6c:	mov    QWORD PTR [rbp-0x8a0],rax
  430c73:	lea    r10,[rbp-0x830]
  430c7a:	mov    r11,QWORD PTR [rbp-0x9e8]
  430c81:	mov    QWORD PTR [r10],r11
  430c84:	mov    rdi,QWORD PTR [r12+0x10]
  430c89:	mov    r10,rdi
  430c8c:	mov    r11,QWORD PTR [rbp-0x9e8]
  430c93:	mov    QWORD PTR [r10],r11
  430c96:	mov    r10,rdi
  430c99:	movabs r11,0x154
  430ca3:	mov    QWORD PTR [r10+0x8],r11
  430ca7:	mov    rsi,rdi
  430caa:	add    rsi,0x10
  430cb1:	mov    QWORD PTR [r12+0x10],rsi
  430cb6:	mov    rdi,r12
  430cb9:	movabs rsi,0x4
  430cc3:	mov    esi,esi
  430cc5:	xor    eax,eax
  430cc7:	call   44a970 <p111_rt_fail>
  430ccc:	mov    QWORD PTR [rbp-0x950],rax
  430cd3:	mov    r12,QWORD PTR [rbp-0x10]
  430cd7:	mov    rbx,QWORD PTR [rbp-0x8]
  430cdb:	mov    r13,QWORD PTR [rbp-0x18]
  430cdf:	mov    r14,QWORD PTR [rbp-0x20]
  430ce3:	mov    r15,QWORD PTR [rbp-0x28]
  430ce7:	mov    rsp,rbp
  430cea:	pop    rbp
  430ceb:	ret    
  430cec:	mov    rdi,r12
  430cef:	mov    rsi,QWORD PTR [rbp-0x8a8]
  430cf6:	xor    eax,eax
  430cf8:	call   44a1e0 <p111_rt_sink>
  430cfd:	mov    QWORD PTR [rbp-0x8a0],rax
  430d04:	mov    rdi,r12
  430d07:	mov    rsi,QWORD PTR [rbp-0x9d0]
  430d0e:	xor    eax,eax
  430d10:	call   44a1e0 <p111_rt_sink>
  430d15:	mov    QWORD PTR [rbp-0x8a0],rax
  430d1c:	mov    rdi,r12
  430d1f:	mov    rsi,QWORD PTR [rbp-0x9d8]
  430d26:	xor    eax,eax
  430d28:	call   44a1e0 <p111_rt_sink>
  430d2d:	mov    QWORD PTR [rbp-0x8a0],rax
  430d34:	lea    r10,[rbp-0x830]
  430d3b:	mov    r11,r14
  430d3e:	mov    QWORD PTR [r10],r11
  430d41:	mov    rdi,QWORD PTR [r12+0x10]
  430d46:	mov    QWORD PTR [rdi],r14
  430d49:	mov    r10,rdi
  430d4c:	movabs r11,0x155
  430d56:	mov    QWORD PTR [r10+0x8],r11
  430d5a:	mov    rsi,rdi
  430d5d:	add    rsi,0x10
  430d64:	mov    QWORD PTR [r12+0x10],rsi
  430d69:	mov    rdi,r12
  430d6c:	movabs rsi,0x4
  430d76:	mov    esi,esi
  430d78:	xor    eax,eax
  430d7a:	call   44a970 <p111_rt_fail>
  430d7f:	mov    QWORD PTR [rbp-0x950],rax
  430d86:	mov    r12,QWORD PTR [rbp-0x10]
  430d8a:	mov    rbx,QWORD PTR [rbp-0x8]
  430d8e:	mov    r13,QWORD PTR [rbp-0x18]
  430d92:	mov    r14,QWORD PTR [rbp-0x20]
  430d96:	mov    r15,QWORD PTR [rbp-0x28]
  430d9a:	mov    rsp,rbp
  430d9d:	pop    rbp
  430d9e:	ret    
  430d9f:	mov    r15,QWORD PTR [rbp-0x8b8]
  430da6:	shr    r15,0x28
  430daa:	and    r15,0xffff
  430db1:	movabs r11,0x2d
  430dbb:	mov    r13,r15
  430dbe:	cmp    r13,r11
  430dc1:	sete   r13b
  430dc5:	movzx  r13d,r13b
  430dc9:	mov    r10,r13
  430dcc:	test   r10d,r10d
  430dcf:	je     431582 <p111_FID_36_100_105_114_101_99_116_46_77_97_112_46_115_101_101_107_46_103_111_+0x172e>
  430dd5:	mov    rdi,r12
  430dd8:	mov    rsi,QWORD PTR [rbp-0x8b8]
  430ddf:	lea    rdx,[rbp-0x830]
  430de6:	xor    eax,eax
  430de8:	call   4501e0 <p125_rt_take3>
  430ded:	mov    QWORD PTR [rbp-0x8a0],rax
  430df4:	lea    r10,[rbp-0x830]
  430dfb:	mov    r10,QWORD PTR [r10]
  430dfe:	mov    QWORD PTR [rbp-0xad8],r10
  430e05:	lea    r10,[rbp-0x830]
  430e0c:	mov    r10,QWORD PTR [r10+0x8]
  430e10:	mov    QWORD PTR [rbp-0xae0],r10
  430e17:	lea    r10,[rbp-0x830]
  430e1e:	mov    r10,QWORD PTR [r10+0x10]
  430e22:	mov    QWORD PTR [rbp-0xae8],r10
  430e29:	mov    r15,r14
  430e2c:	shr    r15,0x28
  430e30:	and    r15,0xffff
  430e37:	movabs r11,0x8
  430e41:	mov    r13,r15
  430e44:	cmp    r13,r11
  430e47:	sete   r13b
  430e4b:	movzx  r13d,r13b
  430e4f:	mov    r10,r13
  430e52:	test   r10d,r10d
  430e55:	je     4314b7 <p111_FID_36_100_105_114_101_99_116_46_77_97_112_46_115_101_101_107_46_103_111_+0x1663>
  430e5b:	mov    rdi,r12
  430e5e:	mov    rsi,r14
  430e61:	lea    rdx,[rbp-0x830]
  430e68:	xor    eax,eax
  430e6a:	call   44ff80 <p125_rt_take2>
  430e6f:	mov    QWORD PTR [rbp-0x8a0],rax
  430e76:	lea    r10,[rbp-0x830]
  430e7d:	mov    r10,QWORD PTR [r10]
  430e80:	mov    QWORD PTR [rbp-0xaf0],r10
  430e87:	lea    r10,[rbp-0x830]
  430e8e:	mov    r10,QWORD PTR [r10+0x8]
  430e92:	mov    QWORD PTR [rbp-0xaf8],r10
  430e99:	cmp    r10,0x1
  430ea0:	sete   r10b
  430ea4:	movzx  r10d,r10b
  430ea8:	mov    QWORD PTR [rbp-0x8d0],r10
  430eaf:	mov    r10,QWORD PTR [rbp-0xaf8]
  430eb6:	shr    r10,0x28
  430eba:	mov    QWORD PTR [rbp-0x8d8],r10
  430ec1:	and    r10,0x7fffff
  430ec8:	mov    QWORD PTR [rbp-0x8d8],r10
  430ecf:	movabs r10,0x2
  430ed9:	or     r10,0x10000
  430ee0:	mov    QWORD PTR [rbp-0x8e0],r10
  430ee7:	mov    r10,QWORD PTR [rbp-0x8d8]
  430eee:	mov    r11,QWORD PTR [rbp-0x8e0]
  430ef5:	cmp    r10,r11
  430ef8:	sete   r10b
  430efc:	movzx  r10d,r10b
  430f00:	mov    QWORD PTR [rbp-0x8e8],r10
  430f07:	mov    r11,r10
  430f0a:	mov    r13,QWORD PTR [rbp-0x8d0]
  430f11:	or     r13d,r11d
  430f14:	xor    r13d,0x1
  430f1b:	mov    r10,r13
  430f1e:	test   r10d,r10d
  430f21:	je     431143 <p111_FID_36_100_105_114_101_99_116_46_77_97_112_46_115_101_101_107_46_103_111_+0x12ef>
  430f27:	movabs r10,0x1002b0000000000
  430f31:	mov    QWORD PTR [rbp-0xb00],r10
  430f38:	mov    rdi,QWORD PTR [rbp-0xad8]
  430f3f:	lea    r10,[rbp-0x830]
  430f46:	mov    r11,rdi
  430f49:	mov    QWORD PTR [r10],r11
  430f4c:	lea    r10,[rbp-0x830]
  430f53:	mov    r11,QWORD PTR [rbp-0xae0]
  430f5a:	mov    QWORD PTR [r10+0x8],r11
  430f5e:	lea    r10,[rbp-0x830]
  430f65:	mov    r11,QWORD PTR [rbp-0xae8]
  430f6c:	mov    QWORD PTR [r10+0x10],r11
  430f70:	mov    rdi,r12
  430f73:	movabs rsi,0x2d
  430f7d:	mov    esi,esi
  430f7f:	lea    rdx,[rbp-0x830]
  430f86:	xor    eax,eax
  430f88:	call   450110 <p125_rt_ctor3>
  430f8d:	mov    rbx,rax
  430f90:	mov    rdi,rbx
  430f93:	lea    r10,[rbp-0x830]
  430f9a:	mov    r11,QWORD PTR [rbp-0x8a8]
  430fa1:	mov    QWORD PTR [r10],r11
  430fa4:	lea    r10,[rbp-0x830]
  430fab:	mov    r11,QWORD PTR [rbp-0xb00]
  430fb2:	mov    QWORD PTR [r10+0x8],r11
  430fb6:	lea    r10,[rbp-0x830]
  430fbd:	mov    r11,rdi
  430fc0:	mov    QWORD PTR [r10+0x10],r11
  430fc4:	mov    rdi,r12
  430fc7:	movabs rsi,0x2d
  430fd1:	mov    esi,esi
  430fd3:	lea    rdx,[rbp-0x830]
  430fda:	xor    eax,eax
  430fdc:	call   450110 <p125_rt_ctor3>
  430fe1:	mov    rbx,rax
  430fe4:	mov    r10,rbx
  430fe7:	mov    QWORD PTR [rbp-0xb18],r10
  430fee:	movabs rdi,0x1000b0000000000
  430ff8:	lea    r10,[rbp-0x830]
  430fff:	mov    r11,QWORD PTR [rbp-0xaf0]
  431006:	mov    QWORD PTR [r10],r11
  431009:	lea    r10,[rbp-0x830]
  431010:	mov    r11,rdi
  431013:	mov    QWORD PTR [r10+0x8],r11
  431017:	mov    rdi,r12
  43101a:	movabs rsi,0x8
  431024:	mov    esi,esi
  431026:	lea    rdx,[rbp-0x830]
  43102d:	xor    eax,eax
  43102f:	call   44fe90 <p125_rt_ctor2>
  431034:	mov    rbx,rax
  431037:	mov    rdi,rbx
  43103a:	lea    r10,[rbp-0x830]
  431041:	mov    r11,QWORD PTR [rbp-0xb18]
  431048:	mov    QWORD PTR [r10],r11
  43104b:	lea    r10,[rbp-0x830]
  431052:	mov    r11,rdi
  431055:	mov    QWORD PTR [r10+0x8],r11
  431059:	mov    rdi,r12
  43105c:	movabs rsi,0x8
  431066:	mov    esi,esi
  431068:	lea    rdx,[rbp-0x830]
  43106f:	xor    eax,eax
  431071:	call   44fe90 <p125_rt_ctor2>
  431076:	mov    rbx,rax
  431079:	lea    r10,[rbp-0x830]
  431080:	mov    r11,rbx
  431083:	mov    QWORD PTR [r10],r11
  431086:	lea    r10,[rip+0x27b53]        # 458be0 <p111_program>
  43108d:	movabs rdi,0x4
  431097:	and    rdi,QWORD PTR [r10+0x58]
  43109b:	mov    r10,rdi
  43109e:	test   r10d,r10d
  4310a1:	je     4310ff <p111_FID_36_100_105_114_101_99_116_46_77_97_112_46_115_101_101_107_46_103_111_+0x12ab>
  4310a7:	lea    r10,[rbp-0x830]
  4310ae:	mov    rdi,QWORD PTR [r10]
  4310b1:	mov    QWORD PTR [r12+0x28],rdi
  4310b6:	mov    r10,r12
  4310b9:	movabs r11,0x1
  4310c3:	mov    DWORD PTR [r10+0x1c],r11d
  4310c7:	mov    rdi,QWORD PTR [r12+0x10]
  4310cc:	movabs r11,0xfffffffffffffff8
  4310d6:	mov    rsi,rdi
  4310d9:	add    rsi,r11
  4310dc:	mov    QWORD PTR [r12+0x10],rsi
  4310e1:	mov    rdi,QWORD PTR [rsi]
  4310e4:	mov    DWORD PTR [r12+0x20],edi
  4310e9:	movabs r10,0x0
  4310f3:	mov    QWORD PTR [rbp-0x950],r10
  4310fa:	jmp    431123 <p111_FID_36_100_105_114_101_99_116_46_77_97_112_46_115_101_101_107_46_103_111_+0x12cf>
  4310ff:	mov    rdi,r12
  431102:	lea    rsi,[rbp-0x830]
  431109:	movabs rdx,0x1
  431113:	mov    edx,edx
  431115:	xor    eax,eax
  431117:	call   44a800 <p111_rt_return>
  43111c:	mov    QWORD PTR [rbp-0x950],rax
  431123:	mov    rax,QWORD PTR [rbp-0x950]
  43112a:	mov    r12,QWORD PTR [rbp-0x10]
  43112e:	mov    rbx,QWORD PTR [rbp-0x8]
  431132:	mov    r13,QWORD PTR [rbp-0x18]
  431136:	mov    r14,QWORD PTR [rbp-0x20]
  43113a:	mov    r15,QWORD PTR [rbp-0x28]
  43113e:	mov    rsp,rbp
  431141:	pop    rbp
  431142:	ret    
  431143:	mov    r10,QWORD PTR [rbp-0xaf8]
  43114a:	cmp    r10,0x1
  431151:	sete   r10b
  431155:	movzx  r10d,r10b
  431159:	mov    QWORD PTR [rbp-0x8d0],r10
  431160:	mov    r10,QWORD PTR [rbp-0xaf8]
  431167:	shr    r10,0x28
  43116b:	mov    QWORD PTR [rbp-0x8d8],r10
  431172:	and    r10,0x7fffff
  431179:	mov    QWORD PTR [rbp-0x8d8],r10
  431180:	movabs r10,0x2
  43118a:	or     r10,0x10000
  431191:	mov    QWORD PTR [rbp-0x8e0],r10
  431198:	mov    r10,QWORD PTR [rbp-0x8d8]
  43119f:	mov    r11,QWORD PTR [rbp-0x8e0]
  4311a6:	cmp    r10,r11
  4311a9:	sete   r10b
  4311ad:	movzx  r10d,r10b
  4311b1:	mov    QWORD PTR [rbp-0x8e8],r10
  4311b8:	mov    r11,r10
  4311bb:	mov    r13,QWORD PTR [rbp-0x8d0]
  4311c2:	or     r13d,r11d
  4311c5:	mov    r10,r13
  4311c8:	test   r10d,r10d
  4311cb:	je     4313c6 <p111_FID_36_100_105_114_101_99_116_46_77_97_112_46_115_101_101_107_46_103_111_+0x1572>
  4311d1:	movabs rdi,0x1002b0000000000
  4311db:	lea    r10,[rbp-0x830]
  4311e2:	mov    r11,QWORD PTR [rbp-0x8a8]
  4311e9:	mov    QWORD PTR [r10],r11
  4311ec:	lea    r10,[rbp-0x830]
  4311f3:	mov    r11,rdi
  4311f6:	mov    QWORD PTR [r10+0x8],r11
  4311fa:	mov    rdi,QWORD PTR [r12+0x10]
  4311ff:	mov    rsi,QWORD PTR [rbp-0x8a8]
  431206:	mov    QWORD PTR [rdi],rsi
  431209:	lea    r10,[rbp-0x830]
  431210:	mov    rsi,QWORD PTR [r10+0x8]
  431214:	mov    QWORD PTR [rdi+0x8],rsi
  431218:	mov    r10,rdi
  43121b:	movabs r11,0x156
  431225:	mov    QWORD PTR [r10+0x10],r11
  431229:	mov    rsi,rdi
  43122c:	add    rsi,0x18
  431233:	mov    QWORD PTR [r12+0x10],rsi
  431238:	mov    rdi,r12
  43123b:	mov    rsi,QWORD PTR [rbp-0xad8]
  431242:	xor    eax,eax
  431244:	call   44a150 <p111_rt_keep>
  431249:	mov    QWORD PTR [rbp-0xad8],rax
  431250:	mov    rdi,rax
  431253:	lea    r10,[rbp-0x830]
  43125a:	mov    r11,rdi
  43125d:	mov    QWORD PTR [r10],r11
  431260:	lea    r10,[rbp-0x830]
  431267:	mov    r11,QWORD PTR [rbp-0xae0]
  43126e:	mov    QWORD PTR [r10+0x8],r11
  431272:	lea    r10,[rbp-0x830]
  431279:	mov    r11,QWORD PTR [rbp-0xae8]
  431280:	mov    QWORD PTR [r10+0x10],r11
  431284:	mov    rdi,r12
  431287:	movabs rsi,0x2d
  431291:	mov    esi,esi
  431293:	lea    rdx,[rbp-0x830]
  43129a:	xor    eax,eax
  43129c:	call   450110 <p125_rt_ctor3>
  4312a1:	mov    rbx,rax
  4312a4:	mov    r10,rbx
  4312a7:	mov    QWORD PTR [rbp-0xb88],r10
  4312ae:	mov    r10,QWORD PTR [rbp-0xad8]
  4312b5:	mov    QWORD PTR [rbp-0xb90],r10
  4312bc:	mov    rdi,r12
  4312bf:	mov    rsi,QWORD PTR [rbp-0xaf0]
  4312c6:	mov    rdx,QWORD PTR [rbp-0xb90]
  4312cd:	xor    eax,eax
  4312cf:	call   40c838 <p112w_FID_36_100_105_114_101_99_116_46_77_97_112_46_98_105_116_>
  4312d4:	mov    QWORD PTR [rbp-0xb98],rax
  4312db:	lea    r10,[rbp-0x1398]
  4312e2:	mov    r11,QWORD PTR [rbp-0xb88]
  4312e9:	mov    QWORD PTR [r10],r11
  4312ec:	lea    r10,[rbp-0x1398]
  4312f3:	mov    r11,QWORD PTR [rbp-0xb98]
  4312fa:	mov    QWORD PTR [r10+0x8],r11
  4312fe:	lea    r10,[rip+0x278db]        # 458be0 <p111_program>
  431305:	movabs rdi,0x4
  43130f:	and    rdi,QWORD PTR [r10+0x58]
  431313:	mov    r10,rdi
  431316:	test   r10d,r10d
  431319:	je     431376 <p111_FID_36_100_105_114_101_99_116_46_77_97_112_46_115_101_101_107_46_103_111_+0x1522>
  43131f:	lea    r10,[rbp-0x1398]
  431326:	mov    rdi,QWORD PTR [r10]
  431329:	lea    r10,[rbp-0x1398]
  431330:	mov    rsi,QWORD PTR [r10+0x8]
  431334:	mov    QWORD PTR [r12+0x28],rdi
  431339:	mov    QWORD PTR [r12+0x30],rsi
  43133e:	mov    r10,r12
  431341:	movabs r11,0x0
  43134b:	mov    DWORD PTR [r10+0x1c],r11d
  43134f:	mov    r10,r12
  431352:	movabs r11,0x151
  43135c:	mov    DWORD PTR [r10+0x20],r11d
  431360:	movabs r10,0x0
  43136a:	mov    QWORD PTR [rbp-0x13c0],r10
  431371:	jmp    4313a6 <p111_FID_36_100_105_114_101_99_116_46_77_97_112_46_115_101_101_107_46_103_111_+0x1552>
  431376:	mov    rdi,r12
  431379:	movabs rsi,0x151
  431383:	mov    esi,esi
  431385:	lea    rdx,[rbp-0x1398]
  43138c:	movabs rcx,0x2
  431396:	mov    ecx,ecx
  431398:	xor    eax,eax
  43139a:	call   44a7a0 <p111_rt_jump>
  43139f:	mov    QWORD PTR [rbp-0x13c0],rax
  4313a6:	mov    rax,QWORD PTR [rbp-0x13c0]
  4313ad:	mov    r12,QWORD PTR [rbp-0x10]
  4313b1:	mov    rbx,QWORD PTR [rbp-0x8]
  4313b5:	mov    r13,QWORD PTR [rbp-0x18]
  4313b9:	mov    r14,QWORD PTR [rbp-0x20]
  4313bd:	mov    r15,QWORD PTR [rbp-0x28]
  4313c1:	mov    rsp,rbp
  4313c4:	pop    rbp
  4313c5:	ret    
  4313c6:	mov    rdi,r12
  4313c9:	mov    rsi,QWORD PTR [rbp-0x8a8]
  4313d0:	xor    eax,eax
  4313d2:	call   44a1e0 <p111_rt_sink>
  4313d7:	mov    QWORD PTR [rbp-0x8a0],rax
  4313de:	mov    rdi,r12
  4313e1:	mov    rsi,QWORD PTR [rbp-0xad8]
  4313e8:	xor    eax,eax
  4313ea:	call   44a1e0 <p111_rt_sink>
  4313ef:	mov    QWORD PTR [rbp-0x8a0],rax
  4313f6:	mov    rdi,r12
  4313f9:	mov    rsi,QWORD PTR [rbp-0xae0]
  431400:	xor    eax,eax
  431402:	call   44a1e0 <p111_rt_sink>
  431407:	mov    QWORD PTR [rbp-0x8a0],rax
  43140e:	mov    rdi,r12
  431411:	mov    rsi,QWORD PTR [rbp-0xae8]
  431418:	xor    eax,eax
  43141a:	call   44a1e0 <p111_rt_sink>
  43141f:	mov    QWORD PTR [rbp-0x8a0],rax
  431426:	mov    rdi,r12
  431429:	mov    rsi,QWORD PTR [rbp-0xaf0]
  431430:	xor    eax,eax
  431432:	call   44a1e0 <p111_rt_sink>
  431437:	mov    QWORD PTR [rbp-0x8a0],rax
  43143e:	lea    r10,[rbp-0x830]
  431445:	mov    r11,QWORD PTR [rbp-0xaf8]
  43144c:	mov    QWORD PTR [r10],r11
  43144f:	mov    rdi,QWORD PTR [r12+0x10]
  431454:	mov    r10,rdi
  431457:	mov    r11,QWORD PTR [rbp-0xaf8]
  43145e:	mov    QWORD PTR [r10],r11
  431461:	mov    r10,rdi
  431464:	movabs r11,0x158
  43146e:	mov    QWORD PTR [r10+0x8],r11
  431472:	mov    rsi,rdi
  431475:	add    rsi,0x10
  43147c:	mov    QWORD PTR [r12+0x10],rsi
  431481:	mov    rdi,r12
  431484:	movabs rsi,0x4
  43148e:	mov    esi,esi
  431490:	xor    eax,eax
  431492:	call   44a970 <p111_rt_fail>
  431497:	mov    QWORD PTR [rbp-0x950],rax
  43149e:	mov    r12,QWORD PTR [rbp-0x10]
  4314a2:	mov    rbx,QWORD PTR [rbp-0x8]
  4314a6:	mov    r13,QWORD PTR [rbp-0x18]
  4314aa:	mov    r14,QWORD PTR [rbp-0x20]
  4314ae:	mov    r15,QWORD PTR [rbp-0x28]
  4314b2:	mov    rsp,rbp
  4314b5:	pop    rbp
  4314b6:	ret    
  4314b7:	mov    rdi,r12
  4314ba:	mov    rsi,QWORD PTR [rbp-0x8a8]
  4314c1:	xor    eax,eax
  4314c3:	call   44a1e0 <p111_rt_sink>
  4314c8:	mov    QWORD PTR [rbp-0x8a0],rax
  4314cf:	mov    rdi,r12
  4314d2:	mov    rsi,QWORD PTR [rbp-0xad8]
  4314d9:	xor    eax,eax
  4314db:	call   44a1e0 <p111_rt_sink>
  4314e0:	mov    QWORD PTR [rbp-0x8a0],rax
  4314e7:	mov    rdi,r12
  4314ea:	mov    rsi,QWORD PTR [rbp-0xae0]
  4314f1:	xor    eax,eax
  4314f3:	call   44a1e0 <p111_rt_sink>
  4314f8:	mov    QWORD PTR [rbp-0x8a0],rax
  4314ff:	mov    rdi,r12
  431502:	mov    rsi,QWORD PTR [rbp-0xae8]
  431509:	xor    eax,eax
  43150b:	call   44a1e0 <p111_rt_sink>
  431510:	mov    QWORD PTR [rbp-0x8a0],rax
  431517:	lea    r10,[rbp-0x830]
  43151e:	mov    r11,r14
  431521:	mov    QWORD PTR [r10],r11
  431524:	mov    rdi,QWORD PTR [r12+0x10]
  431529:	mov    QWORD PTR [rdi],r14
  43152c:	mov    r10,rdi
  43152f:	movabs r11,0x159
  431539:	mov    QWORD PTR [r10+0x8],r11
  43153d:	mov    rsi,rdi
  431540:	add    rsi,0x10
  431547:	mov    QWORD PTR [r12+0x10],rsi
  43154c:	mov    rdi,r12
  43154f:	movabs rsi,0x4
  431559:	mov    esi,esi
  43155b:	xor    eax,eax
  43155d:	call   44a970 <p111_rt_fail>
  431562:	mov    QWORD PTR [rbp-0x950],rax
  431569:	mov    r12,QWORD PTR [rbp-0x10]
  43156d:	mov    rbx,QWORD PTR [rbp-0x8]
  431571:	mov    r13,QWORD PTR [rbp-0x18]
  431575:	mov    r14,QWORD PTR [rbp-0x20]
  431579:	mov    r15,QWORD PTR [rbp-0x28]
  43157d:	mov    rsp,rbp
  431580:	pop    rbp
  431581:	ret    
  431582:	mov    rdi,r12
  431585:	mov    rsi,QWORD PTR [rbp-0x8a8]
  43158c:	xor    eax,eax
  43158e:	call   44a1e0 <p111_rt_sink>
  431593:	mov    QWORD PTR [rbp-0x8a0],rax
  43159a:	lea    r10,[rbp-0x830]
  4315a1:	mov    r11,r14
  4315a4:	mov    QWORD PTR [r10],r11
  4315a7:	mov    rdi,QWORD PTR [r12+0x10]
  4315ac:	mov    QWORD PTR [rdi],r14
  4315af:	mov    r10,rdi
  4315b2:	movabs r11,0x15a
  4315bc:	mov    QWORD PTR [r10+0x8],r11
  4315c0:	mov    rsi,rdi
  4315c3:	add    rsi,0x10
  4315ca:	mov    QWORD PTR [r12+0x10],rsi
  4315cf:	lea    r10,[rbp-0x830]
  4315d6:	mov    r11,QWORD PTR [rbp-0x8b8]
  4315dd:	mov    QWORD PTR [r10],r11
  4315e0:	mov    rdi,QWORD PTR [r12+0x10]
  4315e5:	mov    r10,rdi
  4315e8:	mov    r11,QWORD PTR [rbp-0x8b8]
  4315ef:	mov    QWORD PTR [r10],r11
  4315f2:	mov    r10,rdi
  4315f5:	movabs r11,0x15b
  4315ff:	mov    QWORD PTR [r10+0x8],r11
  431603:	mov    rsi,rdi
  431606:	add    rsi,0x10
  43160d:	mov    QWORD PTR [r12+0x10],rsi
  431612:	mov    rdi,r12
  431615:	movabs rsi,0x4
  43161f:	mov    esi,esi
  431621:	xor    eax,eax
  431623:	call   44a970 <p111_rt_fail>
  431628:	mov    QWORD PTR [rbp-0x950],rax
  43162f:	mov    r12,QWORD PTR [rbp-0x10]
  431633:	mov    rbx,QWORD PTR [rbp-0x8]
  431637:	mov    r13,QWORD PTR [rbp-0x18]
  43163b:	mov    r14,QWORD PTR [rbp-0x20]
  43163f:	mov    r15,QWORD PTR [rbp-0x28]
  431643:	mov    rsp,rbp
  431646:	pop    rbp
  431647:	ret    
  431648:	mov    r15,QWORD PTR [rbp-0x8b0]
  43164f:	shr    r15,0x28
  431653:	and    r15,0xffff
  43165a:	movabs r11,0x2c
  431664:	mov    r13,r15
  431667:	cmp    r13,r11
  43166a:	sete   r13b
  43166e:	movzx  r13d,r13b
  431672:	mov    r10,r13
  431675:	test   r10d,r10d
  431678:	je     433149 <p111_FID_36_100_105_114_101_99_116_46_77_97_112_46_115_101_101_107_46_103_111_+0x32f5>
  43167e:	mov    rdi,r12
  431681:	mov    rsi,QWORD PTR [rbp-0x8b0]
  431688:	lea    rdx,[rbp-0x830]
  43168f:	xor    eax,eax
  431691:	call   44ff80 <p125_rt_take2>
  431696:	mov    QWORD PTR [rbp-0x8a0],rax
  43169d:	lea    r10,[rbp-0x830]
  4316a4:	mov    r10,QWORD PTR [r10]
  4316a7:	mov    QWORD PTR [rbp-0x1408],r10
  4316ae:	lea    r10,[rbp-0x830]
  4316b5:	mov    r10,QWORD PTR [r10+0x8]
  4316b9:	mov    QWORD PTR [rbp-0x1410],r10
  4316c0:	mov    r15,QWORD PTR [rbp-0x8b8]
  4316c7:	shr    r15,0x28
  4316cb:	and    r15,0xffff
  4316d2:	movabs r11,0x2b
  4316dc:	mov    r13,r15
  4316df:	cmp    r13,r11
  4316e2:	sete   r13b
  4316e6:	movzx  r13d,r13b
  4316ea:	mov    r10,r13
  4316ed:	test   r10d,r10d
  4316f0:	je     431e4d <p111_FID_36_100_105_114_101_99_116_46_77_97_112_46_115_101_101_107_46_103_111_+0x1ff9>
  4316f6:	mov    r15,r14
  4316f9:	shr    r15,0x28
  4316fd:	and    r15,0xffff
  431704:	movabs r11,0x8
  43170e:	mov    r13,r15
  431711:	cmp    r13,r11
  431714:	sete   r13b
  431718:	movzx  r13d,r13b
  43171c:	mov    r10,r13
  43171f:	test   r10d,r10d
  431722:	je     431d9a <p111_FID_36_100_105_114_101_99_116_46_77_97_112_46_115_101_101_107_46_103_111_+0x1f46>
  431728:	mov    rdi,r12
  43172b:	mov    rsi,r14
  43172e:	lea    rdx,[rbp-0x830]
  431735:	xor    eax,eax
  431737:	call   44ff80 <p125_rt_take2>
  43173c:	mov    QWORD PTR [rbp-0x8a0],rax
  431743:	lea    r10,[rbp-0x830]
  43174a:	mov    r10,QWORD PTR [r10]
  43174d:	mov    QWORD PTR [rbp-0x1418],r10
  431754:	lea    r10,[rbp-0x830]
  43175b:	mov    r10,QWORD PTR [r10+0x8]
  43175f:	mov    QWORD PTR [rbp-0x1420],r10
  431766:	cmp    r10,0x1
  43176d:	sete   r10b
  431771:	movzx  r10d,r10b
  431775:	mov    QWORD PTR [rbp-0x8d0],r10
  43177c:	mov    r10,QWORD PTR [rbp-0x1420]
  431783:	shr    r10,0x28
  431787:	mov    QWORD PTR [rbp-0x8d8],r10
  43178e:	and    r10,0x7fffff
  431795:	mov    QWORD PTR [rbp-0x8d8],r10
  43179c:	movabs r10,0x2
  4317a6:	or     r10,0x10000
  4317ad:	mov    QWORD PTR [rbp-0x8e0],r10
  4317b4:	mov    r10,QWORD PTR [rbp-0x8d8]
  4317bb:	mov    r11,QWORD PTR [rbp-0x8e0]
  4317c2:	cmp    r10,r11
  4317c5:	sete   r10b
  4317c9:	movzx  r10d,r10b
  4317cd:	mov    QWORD PTR [rbp-0x8e8],r10
  4317d4:	mov    r11,r10
  4317d7:	mov    r13,QWORD PTR [rbp-0x8d0]
  4317de:	or     r13d,r11d
  4317e1:	xor    r13d,0x1
  4317e8:	mov    r10,r13
  4317eb:	test   r10d,r10d
  4317ee:	je     431a34 <p111_FID_36_100_105_114_101_99_116_46_77_97_112_46_115_101_101_107_46_103_111_+0x1be0>
  4317f4:	mov    rdi,r12
  4317f7:	mov    rsi,QWORD PTR [rbp-0x1408]
  4317fe:	xor    eax,eax
  431800:	call   44a150 <p111_rt_keep>
  431805:	mov    QWORD PTR [rbp-0x1408],rax
  43180c:	mov    rdi,rax
  43180f:	lea    r10,[rbp-0x830]
  431816:	mov    r11,rdi
  431819:	mov    QWORD PTR [r10],r11
  43181c:	lea    r10,[rbp-0x830]
  431823:	mov    r11,QWORD PTR [rbp-0x1410]
  43182a:	mov    QWORD PTR [r10+0x8],r11
  43182e:	mov    rdi,r12
  431831:	movabs rsi,0x2c
  43183b:	mov    esi,esi
  43183d:	lea    rdx,[rbp-0x830]
  431844:	xor    eax,eax
  431846:	call   44fe90 <p125_rt_ctor2>
  43184b:	mov    rbx,rax
  43184e:	mov    rdi,rbx
  431851:	movabs rsi,0x1002b0000000000
  43185b:	lea    r10,[rbp-0x830]
  431862:	mov    r11,QWORD PTR [rbp-0x8a8]
  431869:	mov    QWORD PTR [r10],r11
  43186c:	lea    r10,[rbp-0x830]
  431873:	mov    r11,rdi
  431876:	mov    QWORD PTR [r10+0x8],r11
  43187a:	lea    r10,[rbp-0x830]
  431881:	mov    r11,rsi
  431884:	mov    QWORD PTR [r10+0x10],r11
  431888:	mov    rdi,r12
  43188b:	movabs rsi,0x2d
  431895:	mov    esi,esi
  431897:	lea    rdx,[rbp-0x830]
  43189e:	xor    eax,eax
  4318a0:	call   450110 <p125_rt_ctor3>
  4318a5:	mov    rbx,rax
  4318a8:	mov    r10,rbx
  4318ab:	mov    QWORD PTR [rbp-0x1440],r10
  4318b2:	mov    rdi,QWORD PTR [rbp-0x1408]
  4318b9:	lea    r10,[rbp-0x830]
  4318c0:	mov    r11,rdi
  4318c3:	mov    QWORD PTR [r10],r11
  4318c6:	mov    rdi,r12
  4318c9:	movabs rsi,0xc
  4318d3:	mov    esi,esi
  4318d5:	lea    rdx,[rbp-0x830]
  4318dc:	xor    eax,eax
  4318de:	call   44fc60 <p125_rt_ctor1>
  4318e3:	mov    rbx,rax
  4318e6:	mov    rdi,rbx
  4318e9:	lea    r10,[rbp-0x830]
  4318f0:	mov    r11,QWORD PTR [rbp-0x1418]
  4318f7:	mov    QWORD PTR [r10],r11
  4318fa:	lea    r10,[rbp-0x830]
  431901:	mov    r11,rdi
  431904:	mov    QWORD PTR [r10+0x8],r11
  431908:	mov    rdi,r12
  43190b:	movabs rsi,0x8
  431915:	mov    esi,esi
  431917:	lea    rdx,[rbp-0x830]
  43191e:	xor    eax,eax
  431920:	call   44fe90 <p125_rt_ctor2>
  431925:	mov    rbx,rax
  431928:	mov    rdi,rbx
  43192b:	lea    r10,[rbp-0x830]
  431932:	mov    r11,QWORD PTR [rbp-0x1440]
  431939:	mov    QWORD PTR [r10],r11
  43193c:	lea    r10,[rbp-0x830]
  431943:	mov    r11,rdi
  431946:	mov    QWORD PTR [r10+0x8],r11
  43194a:	mov    rdi,r12
  43194d:	movabs rsi,0x8
  431957:	mov    esi,esi
  431959:	lea    rdx,[rbp-0x830]
  431960:	xor    eax,eax
  431962:	call   44fe90 <p125_rt_ctor2>
  431967:	mov    rbx,rax
  43196a:	lea    r10,[rbp-0x830]
  431971:	mov    r11,rbx
  431974:	mov    QWORD PTR [r10],r11
  431977:	lea    r10,[rip+0x27262]        # 458be0 <p111_program>
  43197e:	movabs rdi,0x4
  431988:	and    rdi,QWORD PTR [r10+0x58]
  43198c:	mov    r10,rdi
  43198f:	test   r10d,r10d
  431992:	je     4319f0 <p111_FID_36_100_105_114_101_99_116_46_77_97_112_46_115_101_101_107_46_103_111_+0x1b9c>
  431998:	lea    r10,[rbp-0x830]
  43199f:	mov    rdi,QWORD PTR [r10]
  4319a2:	mov    QWORD PTR [r12+0x28],rdi
  4319a7:	mov    r10,r12
  4319aa:	movabs r11,0x1
  4319b4:	mov    DWORD PTR [r10+0x1c],r11d
  4319b8:	mov    rdi,QWORD PTR [r12+0x10]
  4319bd:	movabs r11,0xfffffffffffffff8
  4319c7:	mov    rsi,rdi
  4319ca:	add    rsi,r11
  4319cd:	mov    QWORD PTR [r12+0x10],rsi
  4319d2:	mov    rdi,QWORD PTR [rsi]
  4319d5:	mov    DWORD PTR [r12+0x20],edi
  4319da:	movabs r10,0x0
  4319e4:	mov    QWORD PTR [rbp-0x950],r10
  4319eb:	jmp    431a14 <p111_FID_36_100_105_114_101_99_116_46_77_97_112_46_115_101_101_107_46_103_111_+0x1bc0>
  4319f0:	mov    rdi,r12
  4319f3:	lea    rsi,[rbp-0x830]
  4319fa:	movabs rdx,0x1
  431a04:	mov    edx,edx
  431a06:	xor    eax,eax
  431a08:	call   44a800 <p111_rt_return>
  431a0d:	mov    QWORD PTR [rbp-0x950],rax
  431a14:	mov    rax,QWORD PTR [rbp-0x950]
  431a1b:	mov    r12,QWORD PTR [rbp-0x10]
  431a1f:	mov    rbx,QWORD PTR [rbp-0x8]
  431a23:	mov    r13,QWORD PTR [rbp-0x18]
  431a27:	mov    r14,QWORD PTR [rbp-0x20]
  431a2b:	mov    r15,QWORD PTR [rbp-0x28]
  431a2f:	mov    rsp,rbp
  431a32:	pop    rbp
  431a33:	ret    
  431a34:	mov    r10,QWORD PTR [rbp-0x1420]
  431a3b:	cmp    r10,0x1
  431a42:	sete   r10b
  431a46:	movzx  r10d,r10b
  431a4a:	mov    QWORD PTR [rbp-0x8d0],r10
  431a51:	mov    r10,QWORD PTR [rbp-0x1420]
  431a58:	shr    r10,0x28
  431a5c:	mov    QWORD PTR [rbp-0x8d8],r10
  431a63:	and    r10,0x7fffff
  431a6a:	mov    QWORD PTR [rbp-0x8d8],r10
  431a71:	movabs r10,0x2
  431a7b:	or     r10,0x10000
  431a82:	mov    QWORD PTR [rbp-0x8e0],r10
  431a89:	mov    r10,QWORD PTR [rbp-0x8d8]
  431a90:	mov    r11,QWORD PTR [rbp-0x8e0]
  431a97:	cmp    r10,r11
  431a9a:	sete   r10b
  431a9e:	movzx  r10d,r10b
  431aa2:	mov    QWORD PTR [rbp-0x8e8],r10
  431aa9:	mov    r11,r10
  431aac:	mov    r13,QWORD PTR [rbp-0x8d0]
  431ab3:	or     r13d,r11d
  431ab6:	mov    r10,r13
  431ab9:	test   r10d,r10d
  431abc:	je     431cc1 <p111_FID_36_100_105_114_101_99_116_46_77_97_112_46_115_101_101_107_46_103_111_+0x1e6d>
  431ac2:	mov    rdi,QWORD PTR [rbp-0x1408]
  431ac9:	lea    r10,[rbp-0x830]
  431ad0:	mov    r11,rdi
  431ad3:	mov    QWORD PTR [r10],r11
  431ad6:	lea    r10,[rbp-0x830]
  431add:	mov    r11,QWORD PTR [rbp-0x1410]
  431ae4:	mov    QWORD PTR [r10+0x8],r11
  431ae8:	mov    rdi,r12
  431aeb:	movabs rsi,0x2c
  431af5:	mov    esi,esi
  431af7:	lea    rdx,[rbp-0x830]
  431afe:	xor    eax,eax
  431b00:	call   44fe90 <p125_rt_ctor2>
  431b05:	mov    rbx,rax
  431b08:	mov    rdi,rbx
  431b0b:	movabs rsi,0x1002b0000000000
  431b15:	lea    r10,[rbp-0x830]
  431b1c:	mov    r11,QWORD PTR [rbp-0x8a8]
  431b23:	mov    QWORD PTR [r10],r11
  431b26:	lea    r10,[rbp-0x830]
  431b2d:	mov    r11,rdi
  431b30:	mov    QWORD PTR [r10+0x8],r11
  431b34:	lea    r10,[rbp-0x830]
  431b3b:	mov    r11,rsi
  431b3e:	mov    QWORD PTR [r10+0x10],r11
  431b42:	mov    rdi,r12
  431b45:	movabs rsi,0x2d
  431b4f:	mov    esi,esi
  431b51:	lea    rdx,[rbp-0x830]
  431b58:	xor    eax,eax
  431b5a:	call   450110 <p125_rt_ctor3>
  431b5f:	mov    rbx,rax
  431b62:	mov    r10,rbx
  431b65:	mov    QWORD PTR [rbp-0x14a8],r10
  431b6c:	movabs rdi,0x1000b0000000000
  431b76:	lea    r10,[rbp-0x830]
  431b7d:	mov    r11,QWORD PTR [rbp-0x1418]
  431b84:	mov    QWORD PTR [r10],r11
  431b87:	lea    r10,[rbp-0x830]
  431b8e:	mov    r11,rdi
  431b91:	mov    QWORD PTR [r10+0x8],r11
  431b95:	mov    rdi,r12
  431b98:	movabs rsi,0x8
  431ba2:	mov    esi,esi
  431ba4:	lea    rdx,[rbp-0x830]
  431bab:	xor    eax,eax
  431bad:	call   44fe90 <p125_rt_ctor2>
  431bb2:	mov    rbx,rax
  431bb5:	mov    rdi,rbx
  431bb8:	lea    r10,[rbp-0x830]
  431bbf:	mov    r11,QWORD PTR [rbp-0x14a8]
  431bc6:	mov    QWORD PTR [r10],r11
  431bc9:	lea    r10,[rbp-0x830]
  431bd0:	mov    r11,rdi
  431bd3:	mov    QWORD PTR [r10+0x8],r11
  431bd7:	mov    rdi,r12
  431bda:	movabs rsi,0x8
  431be4:	mov    esi,esi
  431be6:	lea    rdx,[rbp-0x830]
  431bed:	xor    eax,eax
  431bef:	call   44fe90 <p125_rt_ctor2>
  431bf4:	mov    rbx,rax
  431bf7:	lea    r10,[rbp-0x830]
  431bfe:	mov    r11,rbx
  431c01:	mov    QWORD PTR [r10],r11
  431c04:	lea    r10,[rip+0x26fd5]        # 458be0 <p111_program>
  431c0b:	movabs rdi,0x4
  431c15:	and    rdi,QWORD PTR [r10+0x58]
  431c19:	mov    r10,rdi
  431c1c:	test   r10d,r10d
  431c1f:	je     431c7d <p111_FID_36_100_105_114_101_99_116_46_77_97_112_46_115_101_101_107_46_103_111_+0x1e29>
  431c25:	lea    r10,[rbp-0x830]
  431c2c:	mov    rdi,QWORD PTR [r10]
  431c2f:	mov    QWORD PTR [r12+0x28],rdi
  431c34:	mov    r10,r12
  431c37:	movabs r11,0x1
  431c41:	mov    DWORD PTR [r10+0x1c],r11d
  431c45:	mov    rdi,QWORD PTR [r12+0x10]
  431c4a:	movabs r11,0xfffffffffffffff8
  431c54:	mov    rsi,rdi
  431c57:	add    rsi,r11
  431c5a:	mov    QWORD PTR [r12+0x10],rsi
  431c5f:	mov    rdi,QWORD PTR [rsi]
  431c62:	mov    DWORD PTR [r12+0x20],edi
  431c67:	movabs r10,0x0
  431c71:	mov    QWORD PTR [rbp-0x950],r10
  431c78:	jmp    431ca1 <p111_FID_36_100_105_114_101_99_116_46_77_97_112_46_115_101_101_107_46_103_111_+0x1e4d>
  431c7d:	mov    rdi,r12
  431c80:	lea    rsi,[rbp-0x830]
  431c87:	movabs rdx,0x1
  431c91:	mov    edx,edx
  431c93:	xor    eax,eax
  431c95:	call   44a800 <p111_rt_return>
  431c9a:	mov    QWORD PTR [rbp-0x950],rax
  431ca1:	mov    rax,QWORD PTR [rbp-0x950]
  431ca8:	mov    r12,QWORD PTR [rbp-0x10]
  431cac:	mov    rbx,QWORD PTR [rbp-0x8]
  431cb0:	mov    r13,QWORD PTR [rbp-0x18]
  431cb4:	mov    r14,QWORD PTR [rbp-0x20]
  431cb8:	mov    r15,QWORD PTR [rbp-0x28]
  431cbc:	mov    rsp,rbp
  431cbf:	pop    rbp
  431cc0:	ret    
  431cc1:	mov    rdi,r12
  431cc4:	mov    rsi,QWORD PTR [rbp-0x8a8]
  431ccb:	xor    eax,eax
  431ccd:	call   44a1e0 <p111_rt_sink>
  431cd2:	mov    QWORD PTR [rbp-0x8a0],rax
  431cd9:	mov    rdi,r12
  431cdc:	mov    rsi,QWORD PTR [rbp-0x1408]
  431ce3:	xor    eax,eax
  431ce5:	call   44a1e0 <p111_rt_sink>
  431cea:	mov    QWORD PTR [rbp-0x8a0],rax
  431cf1:	mov    rdi,r12
  431cf4:	mov    rsi,QWORD PTR [rbp-0x1410]
  431cfb:	xor    eax,eax
  431cfd:	call   44a1e0 <p111_rt_sink>
  431d02:	mov    QWORD PTR [rbp-0x8a0],rax
  431d09:	mov    rdi,r12
  431d0c:	mov    rsi,QWORD PTR [rbp-0x1418]
  431d13:	xor    eax,eax
  431d15:	call   44a1e0 <p111_rt_sink>
  431d1a:	mov    QWORD PTR [rbp-0x8a0],rax
  431d21:	lea    r10,[rbp-0x830]
  431d28:	mov    r11,QWORD PTR [rbp-0x1420]
  431d2f:	mov    QWORD PTR [r10],r11
  431d32:	mov    rdi,QWORD PTR [r12+0x10]
  431d37:	mov    r10,rdi
  431d3a:	mov    r11,QWORD PTR [rbp-0x1420]
  431d41:	mov    QWORD PTR [r10],r11
  431d44:	mov    r10,rdi
  431d47:	movabs r11,0x15c
  431d51:	mov    QWORD PTR [r10+0x8],r11
  431d55:	mov    rsi,rdi
  431d58:	add    rsi,0x10
  431d5f:	mov    QWORD PTR [r12+0x10],rsi
  431d64:	mov    rdi,r12
  431d67:	movabs rsi,0x4
  431d71:	mov    esi,esi
  431d73:	xor    eax,eax
  431d75:	call   44a970 <p111_rt_fail>
  431d7a:	mov    QWORD PTR [rbp-0x950],rax
  431d81:	mov    r12,QWORD PTR [rbp-0x10]
  431d85:	mov    rbx,QWORD PTR [rbp-0x8]
  431d89:	mov    r13,QWORD PTR [rbp-0x18]
  431d8d:	mov    r14,QWORD PTR [rbp-0x20]
  431d91:	mov    r15,QWORD PTR [rbp-0x28]
  431d95:	mov    rsp,rbp
  431d98:	pop    rbp
  431d99:	ret    
  431d9a:	mov    rdi,r12
  431d9d:	mov    rsi,QWORD PTR [rbp-0x8a8]
  431da4:	xor    eax,eax
  431da6:	call   44a1e0 <p111_rt_sink>
  431dab:	mov    QWORD PTR [rbp-0x8a0],rax
  431db2:	mov    rdi,r12
  431db5:	mov    rsi,QWORD PTR [rbp-0x1408]
  431dbc:	xor    eax,eax
  431dbe:	call   44a1e0 <p111_rt_sink>
  431dc3:	mov    QWORD PTR [rbp-0x8a0],rax
  431dca:	mov    rdi,r12
  431dcd:	mov    rsi,QWORD PTR [rbp-0x1410]
  431dd4:	xor    eax,eax
  431dd6:	call   44a1e0 <p111_rt_sink>
  431ddb:	mov    QWORD PTR [rbp-0x8a0],rax
  431de2:	lea    r10,[rbp-0x830]
  431de9:	mov    r11,r14
  431dec:	mov    QWORD PTR [r10],r11
  431def:	mov    rdi,QWORD PTR [r12+0x10]
  431df4:	mov    QWORD PTR [rdi],r14
  431df7:	mov    r10,rdi
  431dfa:	movabs r11,0x15d
  431e04:	mov    QWORD PTR [r10+0x8],r11
  431e08:	mov    rsi,rdi
  431e0b:	add    rsi,0x10
  431e12:	mov    QWORD PTR [r12+0x10],rsi
  431e17:	mov    rdi,r12
  431e1a:	movabs rsi,0x4
  431e24:	mov    esi,esi
  431e26:	xor    eax,eax
  431e28:	call   44a970 <p111_rt_fail>
  431e2d:	mov    QWORD PTR [rbp-0x950],rax
  431e34:	mov    r12,QWORD PTR [rbp-0x10]
  431e38:	mov    rbx,QWORD PTR [rbp-0x8]
  431e3c:	mov    r13,QWORD PTR [rbp-0x18]
  431e40:	mov    r14,QWORD PTR [rbp-0x20]
  431e44:	mov    r15,QWORD PTR [rbp-0x28]
  431e48:	mov    rsp,rbp
  431e4b:	pop    rbp
  431e4c:	ret    
  431e4d:	mov    r15,QWORD PTR [rbp-0x8b8]
  431e54:	shr    r15,0x28
  431e58:	and    r15,0xffff
  431e5f:	movabs r11,0x2c
  431e69:	mov    r13,r15
  431e6c:	cmp    r13,r11
  431e6f:	sete   r13b
  431e73:	movzx  r13d,r13b
  431e77:	mov    r10,r13
  431e7a:	test   r10d,r10d
  431e7d:	je     432751 <p111_FID_36_100_105_114_101_99_116_46_77_97_112_46_115_101_101_107_46_103_111_+0x28fd>
  431e83:	mov    rdi,r12
  431e86:	mov    rsi,QWORD PTR [rbp-0x8b8]
  431e8d:	lea    rdx,[rbp-0x830]
  431e94:	xor    eax,eax
  431e96:	call   44ff80 <p125_rt_take2>
  431e9b:	mov    QWORD PTR [rbp-0x8a0],rax
  431ea2:	lea    r10,[rbp-0x830]
  431ea9:	mov    r10,QWORD PTR [r10]
  431eac:	mov    QWORD PTR [rbp-0x1510],r10
  431eb3:	lea    r10,[rbp-0x830]
  431eba:	mov    r10,QWORD PTR [r10+0x8]
  431ebe:	mov    QWORD PTR [rbp-0x1518],r10
  431ec5:	mov    r15,r14
  431ec8:	shr    r15,0x28
  431ecc:	and    r15,0xffff
  431ed3:	movabs r11,0x8
  431edd:	mov    r13,r15
  431ee0:	cmp    r13,r11
  431ee3:	sete   r13b
  431ee7:	movzx  r13d,r13b
  431eeb:	mov    r10,r13
  431eee:	test   r10d,r10d
  431ef1:	je     43266e <p111_FID_36_100_105_114_101_99_116_46_77_97_112_46_115_101_101_107_46_103_111_+0x281a>
  431ef7:	mov    rdi,r12
  431efa:	mov    rsi,r14
  431efd:	lea    rdx,[rbp-0x830]
  431f04:	xor    eax,eax
  431f06:	call   44ff80 <p125_rt_take2>
  431f0b:	mov    QWORD PTR [rbp-0x8a0],rax
  431f12:	lea    r10,[rbp-0x830]
  431f19:	mov    r10,QWORD PTR [r10]
  431f1c:	mov    QWORD PTR [rbp-0x1520],r10
  431f23:	lea    r10,[rbp-0x830]
  431f2a:	mov    r10,QWORD PTR [r10+0x8]
  431f2e:	mov    QWORD PTR [rbp-0x1528],r10
  431f35:	cmp    r10,0x1
  431f3c:	sete   r10b
  431f40:	movzx  r10d,r10b
  431f44:	mov    QWORD PTR [rbp-0x8d0],r10
  431f4b:	mov    r10,QWORD PTR [rbp-0x1528]
  431f52:	shr    r10,0x28
  431f56:	mov    QWORD PTR [rbp-0x8d8],r10
  431f5d:	and    r10,0x7fffff
  431f64:	mov    QWORD PTR [rbp-0x8d8],r10
  431f6b:	movabs r10,0x2
  431f75:	or     r10,0x10000
  431f7c:	mov    QWORD PTR [rbp-0x8e0],r10
  431f83:	mov    r10,QWORD PTR [rbp-0x8d8]
  431f8a:	mov    r11,QWORD PTR [rbp-0x8e0]
  431f91:	cmp    r10,r11
  431f94:	sete   r10b
  431f98:	movzx  r10d,r10b
  431f9c:	mov    QWORD PTR [rbp-0x8e8],r10
  431fa3:	mov    r11,r10
  431fa6:	mov    r13,QWORD PTR [rbp-0x8d0]
  431fad:	or     r13d,r11d
  431fb0:	xor    r13d,0x1
  431fb7:	mov    r10,r13
  431fba:	test   r10d,r10d
  431fbd:	je     43224d <p111_FID_36_100_105_114_101_99_116_46_77_97_112_46_115_101_101_107_46_103_111_+0x23f9>
  431fc3:	mov    rdi,r12
  431fc6:	mov    rsi,QWORD PTR [rbp-0x1408]
  431fcd:	xor    eax,eax
  431fcf:	call   44a150 <p111_rt_keep>
  431fd4:	mov    QWORD PTR [rbp-0x1408],rax
  431fdb:	mov    rdi,rax
  431fde:	lea    r10,[rbp-0x830]
  431fe5:	mov    r11,rdi
  431fe8:	mov    QWORD PTR [r10],r11
  431feb:	lea    r10,[rbp-0x830]
  431ff2:	mov    r11,QWORD PTR [rbp-0x1410]
  431ff9:	mov    QWORD PTR [r10+0x8],r11
  431ffd:	mov    rdi,r12
  432000:	movabs rsi,0x2c
  43200a:	mov    esi,esi
  43200c:	lea    rdx,[rbp-0x830]
  432013:	xor    eax,eax
  432015:	call   44fe90 <p125_rt_ctor2>
  43201a:	mov    rbx,rax
  43201d:	mov    r10,rbx
  432020:	mov    QWORD PTR [rbp-0x1538],r10
  432027:	mov    rdi,QWORD PTR [rbp-0x1510]
  43202e:	lea    r10,[rbp-0x830]
  432035:	mov    r11,rdi
  432038:	mov    QWORD PTR [r10],r11
  43203b:	lea    r10,[rbp-0x830]
  432042:	mov    r11,QWORD PTR [rbp-0x1518]
  432049:	mov    QWORD PTR [r10+0x8],r11
  43204d:	mov    rdi,r12
  432050:	movabs rsi,0x2c
  43205a:	mov    esi,esi
  43205c:	lea    rdx,[rbp-0x830]
  432063:	xor    eax,eax
  432065:	call   44fe90 <p125_rt_ctor2>
  43206a:	mov    rbx,rax
  43206d:	mov    rdi,rbx
  432070:	lea    r10,[rbp-0x830]
  432077:	mov    r11,QWORD PTR [rbp-0x8a8]
  43207e:	mov    QWORD PTR [r10],r11
  432081:	lea    r10,[rbp-0x830]
  432088:	mov    r11,QWORD PTR [rbp-0x1538]
  43208f:	mov    QWORD PTR [r10+0x8],r11
  432093:	lea    r10,[rbp-0x830]
  43209a:	mov    r11,rdi
  43209d:	mov    QWORD PTR [r10+0x10],r11
  4320a1:	mov    rdi,r12
  4320a4:	movabs rsi,0x2d
  4320ae:	mov    esi,esi
  4320b0:	lea    rdx,[rbp-0x830]
  4320b7:	xor    eax,eax
  4320b9:	call   450110 <p125_rt_ctor3>
  4320be:	mov    rbx,rax
  4320c1:	mov    r10,rbx
  4320c4:	mov    QWORD PTR [rbp-0x1550],r10
  4320cb:	mov    rdi,QWORD PTR [rbp-0x1408]
  4320d2:	lea    r10,[rbp-0x830]
  4320d9:	mov    r11,rdi
  4320dc:	mov    QWORD PTR [r10],r11
  4320df:	mov    rdi,r12
  4320e2:	movabs rsi,0xc
  4320ec:	mov    esi,esi
  4320ee:	lea    rdx,[rbp-0x830]
  4320f5:	xor    eax,eax
  4320f7:	call   44fc60 <p125_rt_ctor1>
  4320fc:	mov    rbx,rax
  4320ff:	mov    rdi,rbx
  432102:	lea    r10,[rbp-0x830]
  432109:	mov    r11,QWORD PTR [rbp-0x1520]
  432110:	mov    QWORD PTR [r10],r11
  432113:	lea    r10,[rbp-0x830]
  43211a:	mov    r11,rdi
  43211d:	mov    QWORD PTR [r10+0x8],r11
  432121:	mov    rdi,r12
  432124:	movabs rsi,0x8
  43212e:	mov    esi,esi
  432130:	lea    rdx,[rbp-0x830]
  432137:	xor    eax,eax
  432139:	call   44fe90 <p125_rt_ctor2>
  43213e:	mov    rbx,rax
  432141:	mov    rdi,rbx
  432144:	lea    r10,[rbp-0x830]
  43214b:	mov    r11,QWORD PTR [rbp-0x1550]
  432152:	mov    QWORD PTR [r10],r11
  432155:	lea    r10,[rbp-0x830]
  43215c:	mov    r11,rdi
  43215f:	mov    QWORD PTR [r10+0x8],r11
  432163:	mov    rdi,r12
  432166:	movabs rsi,0x8
  432170:	mov    esi,esi
  432172:	lea    rdx,[rbp-0x830]
  432179:	xor    eax,eax
  43217b:	call   44fe90 <p125_rt_ctor2>
  432180:	mov    rbx,rax
  432183:	lea    r10,[rbp-0x830]
  43218a:	mov    r11,rbx
  43218d:	mov    QWORD PTR [r10],r11
  432190:	lea    r10,[rip+0x26a49]        # 458be0 <p111_program>
  432197:	movabs rdi,0x4
  4321a1:	and    rdi,QWORD PTR [r10+0x58]
  4321a5:	mov    r10,rdi
  4321a8:	test   r10d,r10d
  4321ab:	je     432209 <p111_FID_36_100_105_114_101_99_116_46_77_97_112_46_115_101_101_107_46_103_111_+0x23b5>
  4321b1:	lea    r10,[rbp-0x830]
  4321b8:	mov    rdi,QWORD PTR [r10]
  4321bb:	mov    QWORD PTR [r12+0x28],rdi
  4321c0:	mov    r10,r12
  4321c3:	movabs r11,0x1
  4321cd:	mov    DWORD PTR [r10+0x1c],r11d
  4321d1:	mov    rdi,QWORD PTR [r12+0x10]
  4321d6:	movabs r11,0xfffffffffffffff8
  4321e0:	mov    rsi,rdi
  4321e3:	add    rsi,r11
  4321e6:	mov    QWORD PTR [r12+0x10],rsi
  4321eb:	mov    rdi,QWORD PTR [rsi]
  4321ee:	mov    DWORD PTR [r12+0x20],edi
  4321f3:	movabs r10,0x0
  4321fd:	mov    QWORD PTR [rbp-0x950],r10
  432204:	jmp    43222d <p111_FID_36_100_105_114_101_99_116_46_77_97_112_46_115_101_101_107_46_103_111_+0x23d9>
  432209:	mov    rdi,r12
  43220c:	lea    rsi,[rbp-0x830]
  432213:	movabs rdx,0x1
  43221d:	mov    edx,edx
  43221f:	xor    eax,eax
  432221:	call   44a800 <p111_rt_return>
  432226:	mov    QWORD PTR [rbp-0x950],rax
  43222d:	mov    rax,QWORD PTR [rbp-0x950]
  432234:	mov    r12,QWORD PTR [rbp-0x10]
  432238:	mov    rbx,QWORD PTR [rbp-0x8]
  43223c:	mov    r13,QWORD PTR [rbp-0x18]
  432240:	mov    r14,QWORD PTR [rbp-0x20]
  432244:	mov    r15,QWORD PTR [rbp-0x28]
  432248:	mov    rsp,rbp
  43224b:	pop    rbp
  43224c:	ret    
  43224d:	mov    r10,QWORD PTR [rbp-0x1528]
  432254:	cmp    r10,0x1
  43225b:	sete   r10b
  43225f:	movzx  r10d,r10b
  432263:	mov    QWORD PTR [rbp-0x8d0],r10
  43226a:	mov    r10,QWORD PTR [rbp-0x1528]
  432271:	shr    r10,0x28
  432275:	mov    QWORD PTR [rbp-0x8d8],r10
  43227c:	and    r10,0x7fffff
  432283:	mov    QWORD PTR [rbp-0x8d8],r10
  43228a:	movabs r10,0x2
  432294:	or     r10,0x10000
  43229b:	mov    QWORD PTR [rbp-0x8e0],r10
  4322a2:	mov    r10,QWORD PTR [rbp-0x8d8]
  4322a9:	mov    r11,QWORD PTR [rbp-0x8e0]
  4322b0:	cmp    r10,r11
  4322b3:	sete   r10b
  4322b7:	movzx  r10d,r10b
  4322bb:	mov    QWORD PTR [rbp-0x8e8],r10
  4322c2:	mov    r11,r10
  4322c5:	mov    r13,QWORD PTR [rbp-0x8d0]
  4322cc:	or     r13d,r11d
  4322cf:	mov    r10,r13
  4322d2:	test   r10d,r10d
  4322d5:	je     432565 <p111_FID_36_100_105_114_101_99_116_46_77_97_112_46_115_101_101_107_46_103_111_+0x2711>
  4322db:	mov    rdi,QWORD PTR [rbp-0x1408]
  4322e2:	lea    r10,[rbp-0x830]
  4322e9:	mov    r11,rdi
  4322ec:	mov    QWORD PTR [r10],r11
  4322ef:	lea    r10,[rbp-0x830]
  4322f6:	mov    r11,QWORD PTR [rbp-0x1410]
  4322fd:	mov    QWORD PTR [r10+0x8],r11
  432301:	mov    rdi,r12
  432304:	movabs rsi,0x2c
  43230e:	mov    esi,esi
  432310:	lea    rdx,[rbp-0x830]
  432317:	xor    eax,eax
  432319:	call   44fe90 <p125_rt_ctor2>
  43231e:	mov    rbx,rax
  432321:	mov    r10,rbx
  432324:	mov    QWORD PTR [rbp-0x15a8],r10
  43232b:	mov    rdi,r12
  43232e:	mov    rsi,QWORD PTR [rbp-0x1510]
  432335:	xor    eax,eax
  432337:	call   44a150 <p111_rt_keep>
  43233c:	mov    QWORD PTR [rbp-0x1510],rax
  432343:	mov    rdi,rax
  432346:	lea    r10,[rbp-0x830]
  43234d:	mov    r11,rdi
  432350:	mov    QWORD PTR [r10],r11
  432353:	lea    r10,[rbp-0x830]
  43235a:	mov    r11,QWORD PTR [rbp-0x1518]
  432361:	mov    QWORD PTR [r10+0x8],r11
  432365:	mov    rdi,r12
  432368:	movabs rsi,0x2c
  432372:	mov    esi,esi
  432374:	lea    rdx,[rbp-0x830]
  43237b:	xor    eax,eax
  43237d:	call   44fe90 <p125_rt_ctor2>
  432382:	mov    rbx,rax
  432385:	mov    rdi,rbx
  432388:	lea    r10,[rbp-0x830]
  43238f:	mov    r11,QWORD PTR [rbp-0x8a8]
  432396:	mov    QWORD PTR [r10],r11
  432399:	lea    r10,[rbp-0x830]
  4323a0:	mov    r11,QWORD PTR [rbp-0x15a8]
  4323a7:	mov    QWORD PTR [r10+0x8],r11
  4323ab:	lea    r10,[rbp-0x830]
  4323b2:	mov    r11,rdi
  4323b5:	mov    QWORD PTR [r10+0x10],r11
  4323b9:	mov    rdi,r12
  4323bc:	movabs rsi,0x2d
  4323c6:	mov    esi,esi
  4323c8:	lea    rdx,[rbp-0x830]
  4323cf:	xor    eax,eax
  4323d1:	call   450110 <p125_rt_ctor3>
  4323d6:	mov    rbx,rax
  4323d9:	mov    r10,rbx
  4323dc:	mov    QWORD PTR [rbp-0x15c0],r10
  4323e3:	mov    rdi,QWORD PTR [rbp-0x1510]
  4323ea:	lea    r10,[rbp-0x830]
  4323f1:	mov    r11,rdi
  4323f4:	mov    QWORD PTR [r10],r11
  4323f7:	mov    rdi,r12
  4323fa:	movabs rsi,0xc
  432404:	mov    esi,esi
  432406:	lea    rdx,[rbp-0x830]
  43240d:	xor    eax,eax
  43240f:	call   44fc60 <p125_rt_ctor1>
  432414:	mov    rbx,rax
  432417:	mov    rdi,rbx
  43241a:	lea    r10,[rbp-0x830]
  432421:	mov    r11,QWORD PTR [rbp-0x1520]
  432428:	mov    QWORD PTR [r10],r11
  43242b:	lea    r10,[rbp-0x830]
  432432:	mov    r11,rdi
  432435:	mov    QWORD PTR [r10+0x8],r11
  432439:	mov    rdi,r12
  43243c:	movabs rsi,0x8
  432446:	mov    esi,esi
  432448:	lea    rdx,[rbp-0x830]
  43244f:	xor    eax,eax
  432451:	call   44fe90 <p125_rt_ctor2>
  432456:	mov    rbx,rax
  432459:	mov    rdi,rbx
  43245c:	lea    r10,[rbp-0x830]
  432463:	mov    r11,QWORD PTR [rbp-0x15c0]
  43246a:	mov    QWORD PTR [r10],r11
  43246d:	lea    r10,[rbp-0x830]
  432474:	mov    r11,rdi
  432477:	mov    QWORD PTR [r10+0x8],r11
  43247b:	mov    rdi,r12
  43247e:	movabs rsi,0x8
  432488:	mov    esi,esi
  43248a:	lea    rdx,[rbp-0x830]
  432491:	xor    eax,eax
  432493:	call   44fe90 <p125_rt_ctor2>
  432498:	mov    rbx,rax
  43249b:	lea    r10,[rbp-0x830]
  4324a2:	mov    r11,rbx
  4324a5:	mov    QWORD PTR [r10],r11
  4324a8:	lea    r10,[rip+0x26731]        # 458be0 <p111_program>
  4324af:	movabs rdi,0x4
  4324b9:	and    rdi,QWORD PTR [r10+0x58]
  4324bd:	mov    r10,rdi
  4324c0:	test   r10d,r10d
  4324c3:	je     432521 <p111_FID_36_100_105_114_101_99_116_46_77_97_112_46_115_101_101_107_46_103_111_+0x26cd>
  4324c9:	lea    r10,[rbp-0x830]
  4324d0:	mov    rdi,QWORD PTR [r10]
  4324d3:	mov    QWORD PTR [r12+0x28],rdi
  4324d8:	mov    r10,r12
  4324db:	movabs r11,0x1
  4324e5:	mov    DWORD PTR [r10+0x1c],r11d
  4324e9:	mov    rdi,QWORD PTR [r12+0x10]
  4324ee:	movabs r11,0xfffffffffffffff8
  4324f8:	mov    rsi,rdi
  4324fb:	add    rsi,r11
  4324fe:	mov    QWORD PTR [r12+0x10],rsi
  432503:	mov    rdi,QWORD PTR [rsi]
  432506:	mov    DWORD PTR [r12+0x20],edi
  43250b:	movabs r10,0x0
  432515:	mov    QWORD PTR [rbp-0x950],r10
  43251c:	jmp    432545 <p111_FID_36_100_105_114_101_99_116_46_77_97_112_46_115_101_101_107_46_103_111_+0x26f1>
  432521:	mov    rdi,r12
  432524:	lea    rsi,[rbp-0x830]
  43252b:	movabs rdx,0x1
  432535:	mov    edx,edx
  432537:	xor    eax,eax
  432539:	call   44a800 <p111_rt_return>
  43253e:	mov    QWORD PTR [rbp-0x950],rax
  432545:	mov    rax,QWORD PTR [rbp-0x950]
  43254c:	mov    r12,QWORD PTR [rbp-0x10]
  432550:	mov    rbx,QWORD PTR [rbp-0x8]
  432554:	mov    r13,QWORD PTR [rbp-0x18]
  432558:	mov    r14,QWORD PTR [rbp-0x20]
  43255c:	mov    r15,QWORD PTR [rbp-0x28]
  432560:	mov    rsp,rbp
  432563:	pop    rbp
  432564:	ret    
  432565:	mov    rdi,r12
  432568:	mov    rsi,QWORD PTR [rbp-0x8a8]
  43256f:	xor    eax,eax
  432571:	call   44a1e0 <p111_rt_sink>
  432576:	mov    QWORD PTR [rbp-0x8a0],rax
  43257d:	mov    rdi,r12
  432580:	mov    rsi,QWORD PTR [rbp-0x1408]
  432587:	xor    eax,eax
  432589:	call   44a1e0 <p111_rt_sink>
  43258e:	mov    QWORD PTR [rbp-0x8a0],rax
  432595:	mov    rdi,r12
  432598:	mov    rsi,QWORD PTR [rbp-0x1410]
  43259f:	xor    eax,eax
  4325a1:	call   44a1e0 <p111_rt_sink>
  4325a6:	mov    QWORD PTR [rbp-0x8a0],rax
  4325ad:	mov    rdi,r12
  4325b0:	mov    rsi,QWORD PTR [rbp-0x1510]
  4325b7:	xor    eax,eax
  4325b9:	call   44a1e0 <p111_rt_sink>
  4325be:	mov    QWORD PTR [rbp-0x8a0],rax
  4325c5:	mov    rdi,r12
  4325c8:	mov    rsi,QWORD PTR [rbp-0x1518]
  4325cf:	xor    eax,eax
  4325d1:	call   44a1e0 <p111_rt_sink>
  4325d6:	mov    QWORD PTR [rbp-0x8a0],rax
  4325dd:	mov    rdi,r12
  4325e0:	mov    rsi,QWORD PTR [rbp-0x1520]
  4325e7:	xor    eax,eax
  4325e9:	call   44a1e0 <p111_rt_sink>
  4325ee:	mov    QWORD PTR [rbp-0x8a0],rax
  4325f5:	lea    r10,[rbp-0x830]
  4325fc:	mov    r11,QWORD PTR [rbp-0x1528]
  432603:	mov    QWORD PTR [r10],r11
  432606:	mov    rdi,QWORD PTR [r12+0x10]
  43260b:	mov    r10,rdi
  43260e:	mov    r11,QWORD PTR [rbp-0x1528]
  432615:	mov    QWORD PTR [r10],r11
  432618:	mov    r10,rdi
  43261b:	movabs r11,0x15e
  432625:	mov    QWORD PTR [r10+0x8],r11
  432629:	mov    rsi,rdi
  43262c:	add    rsi,0x10
  432633:	mov    QWORD PTR [r12+0x10],rsi
  432638:	mov    rdi,r12
  43263b:	movabs rsi,0x4
  432645:	mov    esi,esi
  432647:	xor    eax,eax
  432649:	call   44a970 <p111_rt_fail>
  43264e:	mov    QWORD PTR [rbp-0x950],rax
  432655:	mov    r12,QWORD PTR [rbp-0x10]
  432659:	mov    rbx,QWORD PTR [rbp-0x8]
  43265d:	mov    r13,QWORD PTR [rbp-0x18]
  432661:	mov    r14,QWORD PTR [rbp-0x20]
  432665:	mov    r15,QWORD PTR [rbp-0x28]
  432669:	mov    rsp,rbp
  43266c:	pop    rbp
  43266d:	ret    
  43266e:	mov    rdi,r12
  432671:	mov    rsi,QWORD PTR [rbp-0x8a8]
  432678:	xor    eax,eax
  43267a:	call   44a1e0 <p111_rt_sink>
  43267f:	mov    QWORD PTR [rbp-0x8a0],rax
  432686:	mov    rdi,r12
  432689:	mov    rsi,QWORD PTR [rbp-0x1408]
  432690:	xor    eax,eax
  432692:	call   44a1e0 <p111_rt_sink>
  432697:	mov    QWORD PTR [rbp-0x8a0],rax
  43269e:	mov    rdi,r12
  4326a1:	mov    rsi,QWORD PTR [rbp-0x1410]
  4326a8:	xor    eax,eax
  4326aa:	call   44a1e0 <p111_rt_sink>
  4326af:	mov    QWORD PTR [rbp-0x8a0],rax
  4326b6:	mov    rdi,r12
  4326b9:	mov    rsi,QWORD PTR [rbp-0x1510]
  4326c0:	xor    eax,eax
  4326c2:	call   44a1e0 <p111_rt_sink>
  4326c7:	mov    QWORD PTR [rbp-0x8a0],rax
  4326ce:	mov    rdi,r12
  4326d1:	mov    rsi,QWORD PTR [rbp-0x1518]
  4326d8:	xor    eax,eax
  4326da:	call   44a1e0 <p111_rt_sink>
  4326df:	mov    QWORD PTR [rbp-0x8a0],rax
  4326e6:	lea    r10,[rbp-0x830]
  4326ed:	mov    r11,r14
  4326f0:	mov    QWORD PTR [r10],r11
  4326f3:	mov    rdi,QWORD PTR [r12+0x10]
  4326f8:	mov    QWORD PTR [rdi],r14
  4326fb:	mov    r10,rdi
  4326fe:	movabs r11,0x15f
  432708:	mov    QWORD PTR [r10+0x8],r11
  43270c:	mov    rsi,rdi
  43270f:	add    rsi,0x10
  432716:	mov    QWORD PTR [r12+0x10],rsi
  43271b:	mov    rdi,r12
  43271e:	movabs rsi,0x4
  432728:	mov    esi,esi
  43272a:	xor    eax,eax
  43272c:	call   44a970 <p111_rt_fail>
  432731:	mov    QWORD PTR [rbp-0x950],rax
  432738:	mov    r12,QWORD PTR [rbp-0x10]
  43273c:	mov    rbx,QWORD PTR [rbp-0x8]
  432740:	mov    r13,QWORD PTR [rbp-0x18]
  432744:	mov    r14,QWORD PTR [rbp-0x20]
  432748:	mov    r15,QWORD PTR [rbp-0x28]
  43274c:	mov    rsp,rbp
  43274f:	pop    rbp
  432750:	ret    
  432751:	mov    r15,QWORD PTR [rbp-0x8b8]
  432758:	shr    r15,0x28
  43275c:	and    r15,0xffff
  432763:	movabs r11,0x2d
  43276d:	mov    r13,r15
  432770:	cmp    r13,r11
  432773:	sete   r13b
  432777:	movzx  r13d,r13b
  43277b:	mov    r10,r13
  43277e:	test   r10d,r10d
  432781:	je     433053 <p111_FID_36_100_105_114_101_99_116_46_77_97_112_46_115_101_101_107_46_103_111_+0x31ff>
  432787:	mov    rdi,r12
  43278a:	mov    rsi,QWORD PTR [rbp-0x8b8]
  432791:	lea    rdx,[rbp-0x830]
  432798:	xor    eax,eax
  43279a:	call   4501e0 <p125_rt_take3>
  43279f:	mov    QWORD PTR [rbp-0x8a0],rax
  4327a6:	lea    r10,[rbp-0x830]
  4327ad:	mov    r10,QWORD PTR [r10]
  4327b0:	mov    QWORD PTR [rbp-0x1630],r10
  4327b7:	lea    r10,[rbp-0x830]
  4327be:	mov    r10,QWORD PTR [r10+0x8]
  4327c2:	mov    QWORD PTR [rbp-0x1638],r10
  4327c9:	lea    r10,[rbp-0x830]
  4327d0:	mov    r10,QWORD PTR [r10+0x10]
  4327d4:	mov    QWORD PTR [rbp-0x1640],r10
  4327db:	mov    r15,r14
  4327de:	shr    r15,0x28
  4327e2:	and    r15,0xffff
  4327e9:	movabs r11,0x8
  4327f3:	mov    r13,r15
  4327f6:	cmp    r13,r11
  4327f9:	sete   r13b
  4327fd:	movzx  r13d,r13b
  432801:	mov    r10,r13
  432804:	test   r10d,r10d
  432807:	je     432f58 <p111_FID_36_100_105_114_101_99_116_46_77_97_112_46_115_101_101_107_46_103_111_+0x3104>
  43280d:	mov    rdi,r12
  432810:	mov    rsi,r14
  432813:	lea    rdx,[rbp-0x830]
  43281a:	xor    eax,eax
  43281c:	call   44ff80 <p125_rt_take2>
  432821:	mov    QWORD PTR [rbp-0x8a0],rax
  432828:	lea    r10,[rbp-0x830]
  43282f:	mov    r10,QWORD PTR [r10]
  432832:	mov    QWORD PTR [rbp-0x1648],r10
  432839:	lea    r10,[rbp-0x830]
  432840:	mov    r10,QWORD PTR [r10+0x8]
  432844:	mov    QWORD PTR [rbp-0x1650],r10
  43284b:	cmp    r10,0x1
  432852:	sete   r10b
  432856:	movzx  r10d,r10b
  43285a:	mov    QWORD PTR [rbp-0x8d0],r10
  432861:	mov    r10,QWORD PTR [rbp-0x1650]
  432868:	shr    r10,0x28
  43286c:	mov    QWORD PTR [rbp-0x8d8],r10
  432873:	and    r10,0x7fffff
  43287a:	mov    QWORD PTR [rbp-0x8d8],r10
  432881:	movabs r10,0x2
  43288b:	or     r10,0x10000
  432892:	mov    QWORD PTR [rbp-0x8e0],r10
  432899:	mov    r10,QWORD PTR [rbp-0x8d8]
  4328a0:	mov    r11,QWORD PTR [rbp-0x8e0]
  4328a7:	cmp    r10,r11
  4328aa:	sete   r10b
  4328ae:	movzx  r10d,r10b
  4328b2:	mov    QWORD PTR [rbp-0x8e8],r10
  4328b9:	mov    r11,r10
  4328bc:	mov    r13,QWORD PTR [rbp-0x8d0]
  4328c3:	or     r13d,r11d
  4328c6:	xor    r13d,0x1
  4328cd:	mov    r10,r13
  4328d0:	test   r10d,r10d
  4328d3:	je     432b75 <p111_FID_36_100_105_114_101_99_116_46_77_97_112_46_115_101_101_107_46_103_111_+0x2d21>
  4328d9:	mov    rdi,r12
  4328dc:	mov    rsi,QWORD PTR [rbp-0x1408]
  4328e3:	xor    eax,eax
  4328e5:	call   44a150 <p111_rt_keep>
  4328ea:	mov    QWORD PTR [rbp-0x1408],rax
  4328f1:	mov    rdi,rax
  4328f4:	lea    r10,[rbp-0x830]
  4328fb:	mov    r11,rdi
  4328fe:	mov    QWORD PTR [r10],r11
  432901:	lea    r10,[rbp-0x830]
  432908:	mov    r11,QWORD PTR [rbp-0x1410]
  43290f:	mov    QWORD PTR [r10+0x8],r11
  432913:	mov    rdi,r12
  432916:	movabs rsi,0x2c
  432920:	mov    esi,esi
  432922:	lea    rdx,[rbp-0x830]
  432929:	xor    eax,eax
  43292b:	call   44fe90 <p125_rt_ctor2>
  432930:	mov    rbx,rax
  432933:	mov    r10,rbx
  432936:	mov    QWORD PTR [rbp-0x1660],r10
  43293d:	mov    rdi,QWORD PTR [rbp-0x1630]
  432944:	lea    r10,[rbp-0x830]
  43294b:	mov    r11,rdi
  43294e:	mov    QWORD PTR [r10],r11
  432951:	lea    r10,[rbp-0x830]
  432958:	mov    r11,QWORD PTR [rbp-0x1638]
  43295f:	mov    QWORD PTR [r10+0x8],r11
  432963:	lea    r10,[rbp-0x830]
  43296a:	mov    r11,QWORD PTR [rbp-0x1640]
  432971:	mov    QWORD PTR [r10+0x10],r11
  432975:	mov    rdi,r12
  432978:	movabs rsi,0x2d
  432982:	mov    esi,esi
  432984:	lea    rdx,[rbp-0x830]
  43298b:	xor    eax,eax
  43298d:	call   450110 <p125_rt_ctor3>
  432992:	mov    rbx,rax
  432995:	mov    rdi,rbx
  432998:	lea    r10,[rbp-0x830]
  43299f:	mov    r11,QWORD PTR [rbp-0x8a8]
  4329a6:	mov    QWORD PTR [r10],r11
  4329a9:	lea    r10,[rbp-0x830]
  4329b0:	mov    r11,QWORD PTR [rbp-0x1660]
  4329b7:	mov    QWORD PTR [r10+0x8],r11
  4329bb:	lea    r10,[rbp-0x830]
  4329c2:	mov    r11,rdi
  4329c5:	mov    QWORD PTR [r10+0x10],r11
  4329c9:	mov    rdi,r12
  4329cc:	movabs rsi,0x2d
  4329d6:	mov    esi,esi
  4329d8:	lea    rdx,[rbp-0x830]
  4329df:	xor    eax,eax
  4329e1:	call   450110 <p125_rt_ctor3>
  4329e6:	mov    rbx,rax
  4329e9:	mov    r10,rbx
  4329ec:	mov    QWORD PTR [rbp-0x1678],r10
  4329f3:	mov    rdi,QWORD PTR [rbp-0x1408]
  4329fa:	lea    r10,[rbp-0x830]
  432a01:	mov    r11,rdi
  432a04:	mov    QWORD PTR [r10],r11
  432a07:	mov    rdi,r12
  432a0a:	movabs rsi,0xc
  432a14:	mov    esi,esi
  432a16:	lea    rdx,[rbp-0x830]
  432a1d:	xor    eax,eax
  432a1f:	call   44fc60 <p125_rt_ctor1>
  432a24:	mov    rbx,rax
  432a27:	mov    rdi,rbx
  432a2a:	lea    r10,[rbp-0x830]
  432a31:	mov    r11,QWORD PTR [rbp-0x1648]
  432a38:	mov    QWORD PTR [r10],r11
  432a3b:	lea    r10,[rbp-0x830]
  432a42:	mov    r11,rdi
  432a45:	mov    QWORD PTR [r10+0x8],r11
  432a49:	mov    rdi,r12
  432a4c:	movabs rsi,0x8
  432a56:	mov    esi,esi
  432a58:	lea    rdx,[rbp-0x830]
  432a5f:	xor    eax,eax
  432a61:	call   44fe90 <p125_rt_ctor2>
  432a66:	mov    rbx,rax
  432a69:	mov    rdi,rbx
  432a6c:	lea    r10,[rbp-0x830]
  432a73:	mov    r11,QWORD PTR [rbp-0x1678]
  432a7a:	mov    QWORD PTR [r10],r11
  432a7d:	lea    r10,[rbp-0x830]
  432a84:	mov    r11,rdi
  432a87:	mov    QWORD PTR [r10+0x8],r11
  432a8b:	mov    rdi,r12
  432a8e:	movabs rsi,0x8
  432a98:	mov    esi,esi
  432a9a:	lea    rdx,[rbp-0x830]
  432aa1:	xor    eax,eax
  432aa3:	call   44fe90 <p125_rt_ctor2>
  432aa8:	mov    rbx,rax
  432aab:	lea    r10,[rbp-0x830]
  432ab2:	mov    r11,rbx
  432ab5:	mov    QWORD PTR [r10],r11
  432ab8:	lea    r10,[rip+0x26121]        # 458be0 <p111_program>
  432abf:	movabs rdi,0x4
  432ac9:	and    rdi,QWORD PTR [r10+0x58]
  432acd:	mov    r10,rdi
  432ad0:	test   r10d,r10d
  432ad3:	je     432b31 <p111_FID_36_100_105_114_101_99_116_46_77_97_112_46_115_101_101_107_46_103_111_+0x2cdd>
  432ad9:	lea    r10,[rbp-0x830]
  432ae0:	mov    rdi,QWORD PTR [r10]
  432ae3:	mov    QWORD PTR [r12+0x28],rdi
  432ae8:	mov    r10,r12
  432aeb:	movabs r11,0x1
  432af5:	mov    DWORD PTR [r10+0x1c],r11d
  432af9:	mov    rdi,QWORD PTR [r12+0x10]
  432afe:	movabs r11,0xfffffffffffffff8
  432b08:	mov    rsi,rdi
  432b0b:	add    rsi,r11
  432b0e:	mov    QWORD PTR [r12+0x10],rsi
  432b13:	mov    rdi,QWORD PTR [rsi]
  432b16:	mov    DWORD PTR [r12+0x20],edi
  432b1b:	movabs r10,0x0
  432b25:	mov    QWORD PTR [rbp-0x950],r10
  432b2c:	jmp    432b55 <p111_FID_36_100_105_114_101_99_116_46_77_97_112_46_115_101_101_107_46_103_111_+0x2d01>
  432b31:	mov    rdi,r12
  432b34:	lea    rsi,[rbp-0x830]
  432b3b:	movabs rdx,0x1
  432b45:	mov    edx,edx
  432b47:	xor    eax,eax
  432b49:	call   44a800 <p111_rt_return>
  432b4e:	mov    QWORD PTR [rbp-0x950],rax
  432b55:	mov    rax,QWORD PTR [rbp-0x950]
  432b5c:	mov    r12,QWORD PTR [rbp-0x10]
  432b60:	mov    rbx,QWORD PTR [rbp-0x8]
  432b64:	mov    r13,QWORD PTR [rbp-0x18]
  432b68:	mov    r14,QWORD PTR [rbp-0x20]
  432b6c:	mov    r15,QWORD PTR [rbp-0x28]
  432b70:	mov    rsp,rbp
  432b73:	pop    rbp
  432b74:	ret    
  432b75:	mov    r10,QWORD PTR [rbp-0x1650]
  432b7c:	cmp    r10,0x1
  432b83:	sete   r10b
  432b87:	movzx  r10d,r10b
  432b8b:	mov    QWORD PTR [rbp-0x8d0],r10
  432b92:	mov    r10,QWORD PTR [rbp-0x1650]
  432b99:	shr    r10,0x28
  432b9d:	mov    QWORD PTR [rbp-0x8d8],r10
  432ba4:	and    r10,0x7fffff
  432bab:	mov    QWORD PTR [rbp-0x8d8],r10
  432bb2:	movabs r10,0x2
  432bbc:	or     r10,0x10000
  432bc3:	mov    QWORD PTR [rbp-0x8e0],r10
  432bca:	mov    r10,QWORD PTR [rbp-0x8d8]
  432bd1:	mov    r11,QWORD PTR [rbp-0x8e0]
  432bd8:	cmp    r10,r11
  432bdb:	sete   r10b
  432bdf:	movzx  r10d,r10b
  432be3:	mov    QWORD PTR [rbp-0x8e8],r10
  432bea:	mov    r11,r10
  432bed:	mov    r13,QWORD PTR [rbp-0x8d0]
  432bf4:	or     r13d,r11d
  432bf7:	mov    r10,r13
  432bfa:	test   r10d,r10d
  432bfd:	je     432e37 <p111_FID_36_100_105_114_101_99_116_46_77_97_112_46_115_101_101_107_46_103_111_+0x2fe3>
  432c03:	mov    rdi,QWORD PTR [rbp-0x1408]
  432c0a:	lea    r10,[rbp-0x830]
  432c11:	mov    r11,rdi
  432c14:	mov    QWORD PTR [r10],r11
  432c17:	lea    r10,[rbp-0x830]
  432c1e:	mov    r11,QWORD PTR [rbp-0x1410]
  432c25:	mov    QWORD PTR [r10+0x8],r11
  432c29:	mov    rdi,r12
  432c2c:	movabs rsi,0x2c
  432c36:	mov    esi,esi
  432c38:	lea    rdx,[rbp-0x830]
  432c3f:	xor    eax,eax
  432c41:	call   44fe90 <p125_rt_ctor2>
  432c46:	mov    rbx,rax
  432c49:	mov    rdi,rbx
  432c4c:	lea    r10,[rbp-0x830]
  432c53:	mov    r11,QWORD PTR [rbp-0x8a8]
  432c5a:	mov    QWORD PTR [r10],r11
  432c5d:	lea    r10,[rbp-0x830]
  432c64:	mov    r11,rdi
  432c67:	mov    QWORD PTR [r10+0x8],r11
  432c6b:	mov    rdi,QWORD PTR [r12+0x10]
  432c70:	mov    rsi,QWORD PTR [rbp-0x8a8]
  432c77:	mov    QWORD PTR [rdi],rsi
  432c7a:	lea    r10,[rbp-0x830]
  432c81:	mov    rsi,QWORD PTR [r10+0x8]
  432c85:	mov    QWORD PTR [rdi+0x8],rsi
  432c89:	mov    r10,rdi
  432c8c:	movabs r11,0x160
  432c96:	mov    QWORD PTR [r10+0x10],r11
  432c9a:	mov    rsi,rdi
  432c9d:	add    rsi,0x18
  432ca4:	mov    QWORD PTR [r12+0x10],rsi
  432ca9:	mov    rdi,r12
  432cac:	mov    rsi,QWORD PTR [rbp-0x1630]
  432cb3:	xor    eax,eax
  432cb5:	call   44a150 <p111_rt_keep>
  432cba:	mov    QWORD PTR [rbp-0x1630],rax
  432cc1:	mov    rdi,rax
  432cc4:	lea    r10,[rbp-0x830]
  432ccb:	mov    r11,rdi
  432cce:	mov    QWORD PTR [r10],r11
  432cd1:	lea    r10,[rbp-0x830]
  432cd8:	mov    r11,QWORD PTR [rbp-0x1638]
  432cdf:	mov    QWORD PTR [r10+0x8],r11
  432ce3:	lea    r10,[rbp-0x830]
  432cea:	mov    r11,QWORD PTR [rbp-0x1640]
  432cf1:	mov    QWORD PTR [r10+0x10],r11
  432cf5:	mov    rdi,r12
  432cf8:	movabs rsi,0x2d
  432d02:	mov    esi,esi
  432d04:	lea    rdx,[rbp-0x830]
  432d0b:	xor    eax,eax
  432d0d:	call   450110 <p125_rt_ctor3>
  432d12:	mov    rbx,rax
  432d15:	mov    r10,rbx
  432d18:	mov    QWORD PTR [rbp-0x16f8],r10
  432d1f:	mov    r10,QWORD PTR [rbp-0x1630]
  432d26:	mov    QWORD PTR [rbp-0x1700],r10
  432d2d:	mov    rdi,r12
  432d30:	mov    rsi,QWORD PTR [rbp-0x1648]
  432d37:	mov    rdx,QWORD PTR [rbp-0x1700]
  432d3e:	xor    eax,eax
  432d40:	call   40c838 <p112w_FID_36_100_105_114_101_99_116_46_77_97_112_46_98_105_116_>
  432d45:	mov    QWORD PTR [rbp-0x1708],rax
  432d4c:	lea    r10,[rbp-0x1f08]
  432d53:	mov    r11,QWORD PTR [rbp-0x16f8]
  432d5a:	mov    QWORD PTR [r10],r11
  432d5d:	lea    r10,[rbp-0x1f08]
  432d64:	mov    r11,QWORD PTR [rbp-0x1708]
  432d6b:	mov    QWORD PTR [r10+0x8],r11
  432d6f:	lea    r10,[rip+0x25e6a]        # 458be0 <p111_program>
  432d76:	movabs rdi,0x4
  432d80:	and    rdi,QWORD PTR [r10+0x58]
  432d84:	mov    r10,rdi
  432d87:	test   r10d,r10d
  432d8a:	je     432de7 <p111_FID_36_100_105_114_101_99_116_46_77_97_112_46_115_101_101_107_46_103_111_+0x2f93>
  432d90:	lea    r10,[rbp-0x1f08]
  432d97:	mov    rdi,QWORD PTR [r10]
  432d9a:	lea    r10,[rbp-0x1f08]
  432da1:	mov    rsi,QWORD PTR [r10+0x8]
  432da5:	mov    QWORD PTR [r12+0x28],rdi
  432daa:	mov    QWORD PTR [r12+0x30],rsi
  432daf:	mov    r10,r12
  432db2:	movabs r11,0x0
  432dbc:	mov    DWORD PTR [r10+0x1c],r11d
  432dc0:	mov    r10,r12
  432dc3:	movabs r11,0x151
  432dcd:	mov    DWORD PTR [r10+0x20],r11d
  432dd1:	movabs r10,0x0
  432ddb:	mov    QWORD PTR [rbp-0x1f30],r10
  432de2:	jmp    432e17 <p111_FID_36_100_105_114_101_99_116_46_77_97_112_46_115_101_101_107_46_103_111_+0x2fc3>
  432de7:	mov    rdi,r12
  432dea:	movabs rsi,0x151
  432df4:	mov    esi,esi
  432df6:	lea    rdx,[rbp-0x1f08]
  432dfd:	movabs rcx,0x2
  432e07:	mov    ecx,ecx
  432e09:	xor    eax,eax
  432e0b:	call   44a7a0 <p111_rt_jump>
  432e10:	mov    QWORD PTR [rbp-0x1f30],rax
  432e17:	mov    rax,QWORD PTR [rbp-0x1f30]
  432e1e:	mov    r12,QWORD PTR [rbp-0x10]
  432e22:	mov    rbx,QWORD PTR [rbp-0x8]
  432e26:	mov    r13,QWORD PTR [rbp-0x18]
  432e2a:	mov    r14,QWORD PTR [rbp-0x20]
  432e2e:	mov    r15,QWORD PTR [rbp-0x28]
  432e32:	mov    rsp,rbp
  432e35:	pop    rbp
  432e36:	ret    
  432e37:	mov    rdi,r12
  432e3a:	mov    rsi,QWORD PTR [rbp-0x8a8]
  432e41:	xor    eax,eax
  432e43:	call   44a1e0 <p111_rt_sink>
  432e48:	mov    QWORD PTR [rbp-0x8a0],rax
  432e4f:	mov    rdi,r12
  432e52:	mov    rsi,QWORD PTR [rbp-0x1408]
  432e59:	xor    eax,eax
  432e5b:	call   44a1e0 <p111_rt_sink>
  432e60:	mov    QWORD PTR [rbp-0x8a0],rax
  432e67:	mov    rdi,r12
  432e6a:	mov    rsi,QWORD PTR [rbp-0x1410]
  432e71:	xor    eax,eax
  432e73:	call   44a1e0 <p111_rt_sink>
  432e78:	mov    QWORD PTR [rbp-0x8a0],rax
  432e7f:	mov    rdi,r12
  432e82:	mov    rsi,QWORD PTR [rbp-0x1630]
  432e89:	xor    eax,eax
  432e8b:	call   44a1e0 <p111_rt_sink>
  432e90:	mov    QWORD PTR [rbp-0x8a0],rax
  432e97:	mov    rdi,r12
  432e9a:	mov    rsi,QWORD PTR [rbp-0x1638]
  432ea1:	xor    eax,eax
  432ea3:	call   44a1e0 <p111_rt_sink>
  432ea8:	mov    QWORD PTR [rbp-0x8a0],rax
  432eaf:	mov    rdi,r12
  432eb2:	mov    rsi,QWORD PTR [rbp-0x1640]
  432eb9:	xor    eax,eax
  432ebb:	call   44a1e0 <p111_rt_sink>
  432ec0:	mov    QWORD PTR [rbp-0x8a0],rax
  432ec7:	mov    rdi,r12
  432eca:	mov    rsi,QWORD PTR [rbp-0x1648]
  432ed1:	xor    eax,eax
  432ed3:	call   44a1e0 <p111_rt_sink>
  432ed8:	mov    QWORD PTR [rbp-0x8a0],rax
  432edf:	lea    r10,[rbp-0x830]
  432ee6:	mov    r11,QWORD PTR [rbp-0x1650]
  432eed:	mov    QWORD PTR [r10],r11
  432ef0:	mov    rdi,QWORD PTR [r12+0x10]
  432ef5:	mov    r10,rdi
  432ef8:	mov    r11,QWORD PTR [rbp-0x1650]
  432eff:	mov    QWORD PTR [r10],r11
  432f02:	mov    r10,rdi
  432f05:	movabs r11,0x162
  432f0f:	mov    QWORD PTR [r10+0x8],r11
  432f13:	mov    rsi,rdi
  432f16:	add    rsi,0x10
  432f1d:	mov    QWORD PTR [r12+0x10],rsi
  432f22:	mov    rdi,r12
  432f25:	movabs rsi,0x4
  432f2f:	mov    esi,esi
  432f31:	xor    eax,eax
  432f33:	call   44a970 <p111_rt_fail>
  432f38:	mov    QWORD PTR [rbp-0x950],rax
  432f3f:	mov    r12,QWORD PTR [rbp-0x10]
  432f43:	mov    rbx,QWORD PTR [rbp-0x8]
  432f47:	mov    r13,QWORD PTR [rbp-0x18]
  432f4b:	mov    r14,QWORD PTR [rbp-0x20]
  432f4f:	mov    r15,QWORD PTR [rbp-0x28]
  432f53:	mov    rsp,rbp
  432f56:	pop    rbp
  432f57:	ret    
  432f58:	mov    rdi,r12
  432f5b:	mov    rsi,QWORD PTR [rbp-0x8a8]
  432f62:	xor    eax,eax
  432f64:	call   44a1e0 <p111_rt_sink>
  432f69:	mov    QWORD PTR [rbp-0x8a0],rax
  432f70:	mov    rdi,r12
  432f73:	mov    rsi,QWORD PTR [rbp-0x1408]
  432f7a:	xor    eax,eax
  432f7c:	call   44a1e0 <p111_rt_sink>
  432f81:	mov    QWORD PTR [rbp-0x8a0],rax
  432f88:	mov    rdi,r12
  432f8b:	mov    rsi,QWORD PTR [rbp-0x1410]
  432f92:	xor    eax,eax
  432f94:	call   44a1e0 <p111_rt_sink>
  432f99:	mov    QWORD PTR [rbp-0x8a0],rax
  432fa0:	mov    rdi,r12
  432fa3:	mov    rsi,QWORD PTR [rbp-0x1630]
  432faa:	xor    eax,eax
  432fac:	call   44a1e0 <p111_rt_sink>
  432fb1:	mov    QWORD PTR [rbp-0x8a0],rax
  432fb8:	mov    rdi,r12
  432fbb:	mov    rsi,QWORD PTR [rbp-0x1638]
  432fc2:	xor    eax,eax
  432fc4:	call   44a1e0 <p111_rt_sink>
  432fc9:	mov    QWORD PTR [rbp-0x8a0],rax
  432fd0:	mov    rdi,r12
  432fd3:	mov    rsi,QWORD PTR [rbp-0x1640]
  432fda:	xor    eax,eax
  432fdc:	call   44a1e0 <p111_rt_sink>
  432fe1:	mov    QWORD PTR [rbp-0x8a0],rax
  432fe8:	lea    r10,[rbp-0x830]
  432fef:	mov    r11,r14
  432ff2:	mov    QWORD PTR [r10],r11
  432ff5:	mov    rdi,QWORD PTR [r12+0x10]
  432ffa:	mov    QWORD PTR [rdi],r14
  432ffd:	mov    r10,rdi
  433000:	movabs r11,0x163
  43300a:	mov    QWORD PTR [r10+0x8],r11
  43300e:	mov    rsi,rdi
  433011:	add    rsi,0x10
  433018:	mov    QWORD PTR [r12+0x10],rsi
  43301d:	mov    rdi,r12
  433020:	movabs rsi,0x4
  43302a:	mov    esi,esi
  43302c:	xor    eax,eax
  43302e:	call   44a970 <p111_rt_fail>
  433033:	mov    QWORD PTR [rbp-0x950],rax
  43303a:	mov    r12,QWORD PTR [rbp-0x10]
  43303e:	mov    rbx,QWORD PTR [rbp-0x8]
  433042:	mov    r13,QWORD PTR [rbp-0x18]
  433046:	mov    r14,QWORD PTR [rbp-0x20]
  43304a:	mov    r15,QWORD PTR [rbp-0x28]
  43304e:	mov    rsp,rbp
  433051:	pop    rbp
  433052:	ret    
  433053:	mov    rdi,r12
  433056:	mov    rsi,QWORD PTR [rbp-0x8a8]
  43305d:	xor    eax,eax
  43305f:	call   44a1e0 <p111_rt_sink>
  433064:	mov    QWORD PTR [rbp-0x8a0],rax
  43306b:	mov    rdi,r12
  43306e:	mov    rsi,QWORD PTR [rbp-0x1408]
  433075:	xor    eax,eax
  433077:	call   44a1e0 <p111_rt_sink>
  43307c:	mov    QWORD PTR [rbp-0x8a0],rax
  433083:	mov    rdi,r12
  433086:	mov    rsi,QWORD PTR [rbp-0x1410]
  43308d:	xor    eax,eax
  43308f:	call   44a1e0 <p111_rt_sink>
  433094:	mov    QWORD PTR [rbp-0x8a0],rax
  43309b:	lea    r10,[rbp-0x830]
  4330a2:	mov    r11,r14
  4330a5:	mov    QWORD PTR [r10],r11
  4330a8:	mov    rdi,QWORD PTR [r12+0x10]
  4330ad:	mov    QWORD PTR [rdi],r14
  4330b0:	mov    r10,rdi
  4330b3:	movabs r11,0x164
  4330bd:	mov    QWORD PTR [r10+0x8],r11
  4330c1:	mov    rsi,rdi
  4330c4:	add    rsi,0x10
  4330cb:	mov    QWORD PTR [r12+0x10],rsi
  4330d0:	lea    r10,[rbp-0x830]
  4330d7:	mov    r11,QWORD PTR [rbp-0x8b8]
  4330de:	mov    QWORD PTR [r10],r11
  4330e1:	mov    rdi,QWORD PTR [r12+0x10]
  4330e6:	mov    r10,rdi
  4330e9:	mov    r11,QWORD PTR [rbp-0x8b8]
  4330f0:	mov    QWORD PTR [r10],r11
  4330f3:	mov    r10,rdi
  4330f6:	movabs r11,0x165
  433100:	mov    QWORD PTR [r10+0x8],r11
  433104:	mov    rsi,rdi
  433107:	add    rsi,0x10
  43310e:	mov    QWORD PTR [r12+0x10],rsi
  433113:	mov    rdi,r12
  433116:	movabs rsi,0x4
  433120:	mov    esi,esi
  433122:	xor    eax,eax
  433124:	call   44a970 <p111_rt_fail>
  433129:	mov    QWORD PTR [rbp-0x950],rax
  433130:	mov    r12,QWORD PTR [rbp-0x10]
  433134:	mov    rbx,QWORD PTR [rbp-0x8]
  433138:	mov    r13,QWORD PTR [rbp-0x18]
  43313c:	mov    r14,QWORD PTR [rbp-0x20]
  433140:	mov    r15,QWORD PTR [rbp-0x28]
  433144:	mov    rsp,rbp
  433147:	pop    rbp
  433148:	ret    
  433149:	mov    r15,QWORD PTR [rbp-0x8b0]
  433150:	shr    r15,0x28
  433154:	and    r15,0xffff
  43315b:	movabs r11,0x2d
  433165:	mov    r13,r15
  433168:	cmp    r13,r11
  43316b:	sete   r13b
  43316f:	movzx  r13d,r13b
  433173:	mov    r10,r13
  433176:	test   r10d,r10d
  433179:	je     434c43 <p111_FID_36_100_105_114_101_99_116_46_77_97_112_46_115_101_101_107_46_103_111_+0x4def>
  43317f:	mov    rdi,r12
  433182:	mov    rsi,QWORD PTR [rbp-0x8b0]
  433189:	lea    rdx,[rbp-0x830]
  433190:	xor    eax,eax
  433192:	call   4501e0 <p125_rt_take3>
  433197:	mov    QWORD PTR [rbp-0x8a0],rax
  43319e:	lea    r10,[rbp-0x830]
  4331a5:	mov    r10,QWORD PTR [r10]
  4331a8:	mov    QWORD PTR [rbp-0x1f78],r10
  4331af:	lea    r10,[rbp-0x830]
  4331b6:	mov    r10,QWORD PTR [r10+0x8]
  4331ba:	mov    QWORD PTR [rbp-0x1f80],r10
  4331c1:	lea    r10,[rbp-0x830]
  4331c8:	mov    r10,QWORD PTR [r10+0x10]
  4331cc:	mov    QWORD PTR [rbp-0x1f88],r10
  4331d3:	mov    r15,QWORD PTR [rbp-0x8b8]
  4331da:	shr    r15,0x28
  4331de:	and    r15,0xffff
  4331e5:	movabs r11,0x2b
  4331ef:	mov    r13,r15
  4331f2:	cmp    r13,r11
  4331f5:	sete   r13b
  4331f9:	movzx  r13d,r13b
  4331fd:	mov    r10,r13
  433200:	test   r10d,r10d
  433203:	je     433957 <p111_FID_36_100_105_114_101_99_116_46_77_97_112_46_115_101_101_107_46_103_111_+0x3b03>
  433209:	mov    r15,r14
  43320c:	shr    r15,0x28
  433210:	and    r15,0xffff
  433217:	movabs r11,0x8
  433221:	mov    r13,r15
  433224:	cmp    r13,r11
  433227:	sete   r13b
  43322b:	movzx  r13d,r13b
  43322f:	mov    r10,r13
  433232:	test   r10d,r10d
  433235:	je     43388c <p111_FID_36_100_105_114_101_99_116_46_77_97_112_46_115_101_101_107_46_103_111_+0x3a38>
  43323b:	mov    rdi,r12
  43323e:	mov    rsi,r14
  433241:	lea    rdx,[rbp-0x830]
  433248:	xor    eax,eax
  43324a:	call   44ff80 <p125_rt_take2>
  43324f:	mov    QWORD PTR [rbp-0x8a0],rax
  433256:	lea    r10,[rbp-0x830]
  43325d:	mov    r10,QWORD PTR [r10]
  433260:	mov    QWORD PTR [rbp-0x1f90],r10
  433267:	lea    r10,[rbp-0x830]
  43326e:	mov    r10,QWORD PTR [r10+0x8]
  433272:	mov    QWORD PTR [rbp-0x1f98],r10
  433279:	cmp    r10,0x1
  433280:	sete   r10b
  433284:	movzx  r10d,r10b
  433288:	mov    QWORD PTR [rbp-0x8d0],r10
  43328f:	mov    r10,QWORD PTR [rbp-0x1f98]
  433296:	shr    r10,0x28
  43329a:	mov    QWORD PTR [rbp-0x8d8],r10
  4332a1:	and    r10,0x7fffff
  4332a8:	mov    QWORD PTR [rbp-0x8d8],r10
  4332af:	movabs r10,0x2
  4332b9:	or     r10,0x10000
  4332c0:	mov    QWORD PTR [rbp-0x8e0],r10
  4332c7:	mov    r10,QWORD PTR [rbp-0x8d8]
  4332ce:	mov    r11,QWORD PTR [rbp-0x8e0]
  4332d5:	cmp    r10,r11
  4332d8:	sete   r10b
  4332dc:	movzx  r10d,r10b
  4332e0:	mov    QWORD PTR [rbp-0x8e8],r10
  4332e7:	mov    r11,r10
  4332ea:	mov    r13,QWORD PTR [rbp-0x8d0]
  4332f1:	or     r13d,r11d
  4332f4:	xor    r13d,0x1
  4332fb:	mov    r10,r13
  4332fe:	test   r10d,r10d
  433301:	je     4334fc <p111_FID_36_100_105_114_101_99_116_46_77_97_112_46_115_101_101_107_46_103_111_+0x36a8>
  433307:	movabs rdi,0x1002b0000000000
  433311:	lea    r10,[rbp-0x830]
  433318:	mov    r11,QWORD PTR [rbp-0x8a8]
  43331f:	mov    QWORD PTR [r10],r11
  433322:	lea    r10,[rbp-0x830]
  433329:	mov    r11,rdi
  43332c:	mov    QWORD PTR [r10+0x8],r11
  433330:	mov    rdi,QWORD PTR [r12+0x10]
  433335:	mov    rsi,QWORD PTR [rbp-0x8a8]
  43333c:	mov    QWORD PTR [rdi],rsi
  43333f:	lea    r10,[rbp-0x830]
  433346:	mov    rsi,QWORD PTR [r10+0x8]
  43334a:	mov    QWORD PTR [rdi+0x8],rsi
  43334e:	mov    r10,rdi
  433351:	movabs r11,0x166
  43335b:	mov    QWORD PTR [r10+0x10],r11
  43335f:	mov    rsi,rdi
  433362:	add    rsi,0x18
  433369:	mov    QWORD PTR [r12+0x10],rsi
  43336e:	mov    rdi,r12
  433371:	mov    rsi,QWORD PTR [rbp-0x1f78]
  433378:	xor    eax,eax
  43337a:	call   44a150 <p111_rt_keep>
  43337f:	mov    QWORD PTR [rbp-0x1f78],rax
  433386:	mov    rdi,rax
  433389:	lea    r10,[rbp-0x830]
  433390:	mov    r11,rdi
  433393:	mov    QWORD PTR [r10],r11
  433396:	lea    r10,[rbp-0x830]
  43339d:	mov    r11,QWORD PTR [rbp-0x1f80]
  4333a4:	mov    QWORD PTR [r10+0x8],r11
  4333a8:	lea    r10,[rbp-0x830]
  4333af:	mov    r11,QWORD PTR [rbp-0x1f88]
  4333b6:	mov    QWORD PTR [r10+0x10],r11
  4333ba:	mov    rdi,r12
  4333bd:	movabs rsi,0x2d
  4333c7:	mov    esi,esi
  4333c9:	lea    rdx,[rbp-0x830]
  4333d0:	xor    eax,eax
  4333d2:	call   450110 <p125_rt_ctor3>
  4333d7:	mov    rbx,rax
  4333da:	mov    r10,rbx
  4333dd:	mov    QWORD PTR [rbp-0x1fc8],r10
  4333e4:	mov    r10,QWORD PTR [rbp-0x1f78]
  4333eb:	mov    QWORD PTR [rbp-0x1fd0],r10
  4333f2:	mov    rdi,r12
  4333f5:	mov    rsi,QWORD PTR [rbp-0x1f90]
  4333fc:	mov    rdx,QWORD PTR [rbp-0x1fd0]
  433403:	xor    eax,eax
  433405:	call   40c838 <p112w_FID_36_100_105_114_101_99_116_46_77_97_112_46_98_105_116_>
  43340a:	mov    QWORD PTR [rbp-0x1fd8],rax
  433411:	lea    r10,[rbp-0x27d8]
  433418:	mov    r11,QWORD PTR [rbp-0x1fc8]
  43341f:	mov    QWORD PTR [r10],r11
  433422:	lea    r10,[rbp-0x27d8]
  433429:	mov    r11,QWORD PTR [rbp-0x1fd8]
  433430:	mov    QWORD PTR [r10+0x8],r11
  433434:	lea    r10,[rip+0x257a5]        # 458be0 <p111_program>
  43343b:	movabs rdi,0x4
  433445:	and    rdi,QWORD PTR [r10+0x58]
  433449:	mov    r10,rdi
  43344c:	test   r10d,r10d
  43344f:	je     4334ac <p111_FID_36_100_105_114_101_99_116_46_77_97_112_46_115_101_101_107_46_103_111_+0x3658>
  433455:	lea    r10,[rbp-0x27d8]
  43345c:	mov    rdi,QWORD PTR [r10]
  43345f:	lea    r10,[rbp-0x27d8]
  433466:	mov    rsi,QWORD PTR [r10+0x8]
  43346a:	mov    QWORD PTR [r12+0x28],rdi
  43346f:	mov    QWORD PTR [r12+0x30],rsi
  433474:	mov    r10,r12
  433477:	movabs r11,0x0
  433481:	mov    DWORD PTR [r10+0x1c],r11d
  433485:	mov    r10,r12
  433488:	movabs r11,0x151
  433492:	mov    DWORD PTR [r10+0x20],r11d
  433496:	movabs r10,0x0
  4334a0:	mov    QWORD PTR [rbp-0x2800],r10
  4334a7:	jmp    4334dc <p111_FID_36_100_105_114_101_99_116_46_77_97_112_46_115_101_101_107_46_103_111_+0x3688>
  4334ac:	mov    rdi,r12
  4334af:	movabs rsi,0x151
  4334b9:	mov    esi,esi
  4334bb:	lea    rdx,[rbp-0x27d8]
  4334c2:	movabs rcx,0x2
  4334cc:	mov    ecx,ecx
  4334ce:	xor    eax,eax
  4334d0:	call   44a7a0 <p111_rt_jump>
  4334d5:	mov    QWORD PTR [rbp-0x2800],rax
  4334dc:	mov    rax,QWORD PTR [rbp-0x2800]
  4334e3:	mov    r12,QWORD PTR [rbp-0x10]
  4334e7:	mov    rbx,QWORD PTR [rbp-0x8]
  4334eb:	mov    r13,QWORD PTR [rbp-0x18]
  4334ef:	mov    r14,QWORD PTR [rbp-0x20]
  4334f3:	mov    r15,QWORD PTR [rbp-0x28]
  4334f7:	mov    rsp,rbp
  4334fa:	pop    rbp
  4334fb:	ret    
  4334fc:	mov    r10,QWORD PTR [rbp-0x1f98]
  433503:	cmp    r10,0x1
  43350a:	sete   r10b
  43350e:	movzx  r10d,r10b
  433512:	mov    QWORD PTR [rbp-0x8d0],r10
  433519:	mov    r10,QWORD PTR [rbp-0x1f98]
  433520:	shr    r10,0x28
  433524:	mov    QWORD PTR [rbp-0x8d8],r10
  43352b:	and    r10,0x7fffff
  433532:	mov    QWORD PTR [rbp-0x8d8],r10
  433539:	movabs r10,0x2
  433543:	or     r10,0x10000
  43354a:	mov    QWORD PTR [rbp-0x8e0],r10
  433551:	mov    r10,QWORD PTR [rbp-0x8d8]
  433558:	mov    r11,QWORD PTR [rbp-0x8e0]
  43355f:	cmp    r10,r11
  433562:	sete   r10b
  433566:	movzx  r10d,r10b
  43356a:	mov    QWORD PTR [rbp-0x8e8],r10
  433571:	mov    r11,r10
  433574:	mov    r13,QWORD PTR [rbp-0x8d0]
  43357b:	or     r13d,r11d
  43357e:	mov    r10,r13
  433581:	test   r10d,r10d
  433584:	je     43379b <p111_FID_36_100_105_114_101_99_116_46_77_97_112_46_115_101_101_107_46_103_111_+0x3947>
  43358a:	mov    rdi,QWORD PTR [rbp-0x1f78]
  433591:	lea    r10,[rbp-0x830]
  433598:	mov    r11,rdi
  43359b:	mov    QWORD PTR [r10],r11
  43359e:	lea    r10,[rbp-0x830]
  4335a5:	mov    r11,QWORD PTR [rbp-0x1f80]
  4335ac:	mov    QWORD PTR [r10+0x8],r11
  4335b0:	lea    r10,[rbp-0x830]
  4335b7:	mov    r11,QWORD PTR [rbp-0x1f88]
  4335be:	mov    QWORD PTR [r10+0x10],r11
  4335c2:	mov    rdi,r12
  4335c5:	movabs rsi,0x2d
  4335cf:	mov    esi,esi
  4335d1:	lea    rdx,[rbp-0x830]
  4335d8:	xor    eax,eax
  4335da:	call   450110 <p125_rt_ctor3>
  4335df:	mov    rbx,rax
  4335e2:	mov    rdi,rbx
  4335e5:	movabs rsi,0x1002b0000000000
  4335ef:	lea    r10,[rbp-0x830]
  4335f6:	mov    r11,QWORD PTR [rbp-0x8a8]
  4335fd:	mov    QWORD PTR [r10],r11
  433600:	lea    r10,[rbp-0x830]
  433607:	mov    r11,rdi
  43360a:	mov    QWORD PTR [r10+0x8],r11
  43360e:	lea    r10,[rbp-0x830]
  433615:	mov    r11,rsi
  433618:	mov    QWORD PTR [r10+0x10],r11
  43361c:	mov    rdi,r12
  43361f:	movabs rsi,0x2d
  433629:	mov    esi,esi
  43362b:	lea    rdx,[rbp-0x830]
  433632:	xor    eax,eax
  433634:	call   450110 <p125_rt_ctor3>
  433639:	mov    rbx,rax
  43363c:	mov    r10,rbx
  43363f:	mov    QWORD PTR [rbp-0x2820],r10
  433646:	movabs rdi,0x1000b0000000000
  433650:	lea    r10,[rbp-0x830]
  433657:	mov    r11,QWORD PTR [rbp-0x1f90]
  43365e:	mov    QWORD PTR [r10],r11
  433661:	lea    r10,[rbp-0x830]
  433668:	mov    r11,rdi
  43366b:	mov    QWORD PTR [r10+0x8],r11
  43366f:	mov    rdi,r12
  433672:	movabs rsi,0x8
  43367c:	mov    esi,esi
  43367e:	lea    rdx,[rbp-0x830]
  433685:	xor    eax,eax
  433687:	call   44fe90 <p125_rt_ctor2>
  43368c:	mov    rbx,rax
  43368f:	mov    rdi,rbx
  433692:	lea    r10,[rbp-0x830]
  433699:	mov    r11,QWORD PTR [rbp-0x2820]
  4336a0:	mov    QWORD PTR [r10],r11
  4336a3:	lea    r10,[rbp-0x830]
  4336aa:	mov    r11,rdi
  4336ad:	mov    QWORD PTR [r10+0x8],r11
  4336b1:	mov    rdi,r12
  4336b4:	movabs rsi,0x8
  4336be:	mov    esi,esi
  4336c0:	lea    rdx,[rbp-0x830]
  4336c7:	xor    eax,eax
  4336c9:	call   44fe90 <p125_rt_ctor2>
  4336ce:	mov    rbx,rax
  4336d1:	lea    r10,[rbp-0x830]
  4336d8:	mov    r11,rbx
  4336db:	mov    QWORD PTR [r10],r11
  4336de:	lea    r10,[rip+0x254fb]        # 458be0 <p111_program>
  4336e5:	movabs rdi,0x4
  4336ef:	and    rdi,QWORD PTR [r10+0x58]
  4336f3:	mov    r10,rdi
  4336f6:	test   r10d,r10d
  4336f9:	je     433757 <p111_FID_36_100_105_114_101_99_116_46_77_97_112_46_115_101_101_107_46_103_111_+0x3903>
  4336ff:	lea    r10,[rbp-0x830]
  433706:	mov    rdi,QWORD PTR [r10]
  433709:	mov    QWORD PTR [r12+0x28],rdi
  43370e:	mov    r10,r12
  433711:	movabs r11,0x1
  43371b:	mov    DWORD PTR [r10+0x1c],r11d
  43371f:	mov    rdi,QWORD PTR [r12+0x10]
  433724:	movabs r11,0xfffffffffffffff8
  43372e:	mov    rsi,rdi
  433731:	add    rsi,r11
  433734:	mov    QWORD PTR [r12+0x10],rsi
  433739:	mov    rdi,QWORD PTR [rsi]
  43373c:	mov    DWORD PTR [r12+0x20],edi
  433741:	movabs r10,0x0
  43374b:	mov    QWORD PTR [rbp-0x950],r10
  433752:	jmp    43377b <p111_FID_36_100_105_114_101_99_116_46_77_97_112_46_115_101_101_107_46_103_111_+0x3927>
  433757:	mov    rdi,r12
  43375a:	lea    rsi,[rbp-0x830]
  433761:	movabs rdx,0x1
  43376b:	mov    edx,edx
  43376d:	xor    eax,eax
  43376f:	call   44a800 <p111_rt_return>
  433774:	mov    QWORD PTR [rbp-0x950],rax
  43377b:	mov    rax,QWORD PTR [rbp-0x950]
  433782:	mov    r12,QWORD PTR [rbp-0x10]
  433786:	mov    rbx,QWORD PTR [rbp-0x8]
  43378a:	mov    r13,QWORD PTR [rbp-0x18]
  43378e:	mov    r14,QWORD PTR [rbp-0x20]
  433792:	mov    r15,QWORD PTR [rbp-0x28]
  433796:	mov    rsp,rbp
  433799:	pop    rbp
  43379a:	ret    
  43379b:	mov    rdi,r12
  43379e:	mov    rsi,QWORD PTR [rbp-0x8a8]
  4337a5:	xor    eax,eax
  4337a7:	call   44a1e0 <p111_rt_sink>
  4337ac:	mov    QWORD PTR [rbp-0x8a0],rax
  4337b3:	mov    rdi,r12
  4337b6:	mov    rsi,QWORD PTR [rbp-0x1f78]
  4337bd:	xor    eax,eax
  4337bf:	call   44a1e0 <p111_rt_sink>
  4337c4:	mov    QWORD PTR [rbp-0x8a0],rax
  4337cb:	mov    rdi,r12
  4337ce:	mov    rsi,QWORD PTR [rbp-0x1f80]
  4337d5:	xor    eax,eax
  4337d7:	call   44a1e0 <p111_rt_sink>
  4337dc:	mov    QWORD PTR [rbp-0x8a0],rax
  4337e3:	mov    rdi,r12
  4337e6:	mov    rsi,QWORD PTR [rbp-0x1f88]
  4337ed:	xor    eax,eax
  4337ef:	call   44a1e0 <p111_rt_sink>
  4337f4:	mov    QWORD PTR [rbp-0x8a0],rax
  4337fb:	mov    rdi,r12
  4337fe:	mov    rsi,QWORD PTR [rbp-0x1f90]
  433805:	xor    eax,eax
  433807:	call   44a1e0 <p111_rt_sink>
  43380c:	mov    QWORD PTR [rbp-0x8a0],rax
  433813:	lea    r10,[rbp-0x830]
  43381a:	mov    r11,QWORD PTR [rbp-0x1f98]
  433821:	mov    QWORD PTR [r10],r11
  433824:	mov    rdi,QWORD PTR [r12+0x10]
  433829:	mov    r10,rdi
  43382c:	mov    r11,QWORD PTR [rbp-0x1f98]
  433833:	mov    QWORD PTR [r10],r11
  433836:	mov    r10,rdi
  433839:	movabs r11,0x168
  433843:	mov    QWORD PTR [r10+0x8],r11
  433847:	mov    rsi,rdi
  43384a:	add    rsi,0x10
  433851:	mov    QWORD PTR [r12+0x10],rsi
  433856:	mov    rdi,r12
  433859:	movabs rsi,0x4
  433863:	mov    esi,esi
  433865:	xor    eax,eax
  433867:	call   44a970 <p111_rt_fail>
  43386c:	mov    QWORD PTR [rbp-0x950],rax
  433873:	mov    r12,QWORD PTR [rbp-0x10]
  433877:	mov    rbx,QWORD PTR [rbp-0x8]
  43387b:	mov    r13,QWORD PTR [rbp-0x18]
  43387f:	mov    r14,QWORD PTR [rbp-0x20]
  433883:	mov    r15,QWORD PTR [rbp-0x28]
  433887:	mov    rsp,rbp
  43388a:	pop    rbp
  43388b:	ret    
  43388c:	mov    rdi,r12
  43388f:	mov    rsi,QWORD PTR [rbp-0x8a8]
  433896:	xor    eax,eax
  433898:	call   44a1e0 <p111_rt_sink>
  43389d:	mov    QWORD PTR [rbp-0x8a0],rax
  4338a4:	mov    rdi,r12
  4338a7:	mov    rsi,QWORD PTR [rbp-0x1f78]
  4338ae:	xor    eax,eax
  4338b0:	call   44a1e0 <p111_rt_sink>
  4338b5:	mov    QWORD PTR [rbp-0x8a0],rax
  4338bc:	mov    rdi,r12
  4338bf:	mov    rsi,QWORD PTR [rbp-0x1f80]
  4338c6:	xor    eax,eax
  4338c8:	call   44a1e0 <p111_rt_sink>
  4338cd:	mov    QWORD PTR [rbp-0x8a0],rax
  4338d4:	mov    rdi,r12
  4338d7:	mov    rsi,QWORD PTR [rbp-0x1f88]
  4338de:	xor    eax,eax
  4338e0:	call   44a1e0 <p111_rt_sink>
  4338e5:	mov    QWORD PTR [rbp-0x8a0],rax
  4338ec:	lea    r10,[rbp-0x830]
  4338f3:	mov    r11,r14
  4338f6:	mov    QWORD PTR [r10],r11
  4338f9:	mov    rdi,QWORD PTR [r12+0x10]
  4338fe:	mov    QWORD PTR [rdi],r14
  433901:	mov    r10,rdi
  433904:	movabs r11,0x169
  43390e:	mov    QWORD PTR [r10+0x8],r11
  433912:	mov    rsi,rdi
  433915:	add    rsi,0x10
  43391c:	mov    QWORD PTR [r12+0x10],rsi
  433921:	mov    rdi,r12
  433924:	movabs rsi,0x4
  43392e:	mov    esi,esi
  433930:	xor    eax,eax
  433932:	call   44a970 <p111_rt_fail>
  433937:	mov    QWORD PTR [rbp-0x950],rax
  43393e:	mov    r12,QWORD PTR [rbp-0x10]
  433942:	mov    rbx,QWORD PTR [rbp-0x8]
  433946:	mov    r13,QWORD PTR [rbp-0x18]
  43394a:	mov    r14,QWORD PTR [rbp-0x20]
  43394e:	mov    r15,QWORD PTR [rbp-0x28]
  433952:	mov    rsp,rbp
  433955:	pop    rbp
  433956:	ret    
  433957:	mov    r15,QWORD PTR [rbp-0x8b8]
  43395e:	shr    r15,0x28
  433962:	and    r15,0xffff
  433969:	movabs r11,0x2c
  433973:	mov    r13,r15
  433976:	cmp    r13,r11
  433979:	sete   r13b
  43397d:	movzx  r13d,r13b
  433981:	mov    r10,r13
  433984:	test   r10d,r10d
  433987:	je     434247 <p111_FID_36_100_105_114_101_99_116_46_77_97_112_46_115_101_101_107_46_103_111_+0x43f3>
  43398d:	mov    rdi,r12
  433990:	mov    rsi,QWORD PTR [rbp-0x8b8]
  433997:	lea    rdx,[rbp-0x830]
  43399e:	xor    eax,eax
  4339a0:	call   44ff80 <p125_rt_take2>
  4339a5:	mov    QWORD PTR [rbp-0x8a0],rax
  4339ac:	lea    r10,[rbp-0x830]
  4339b3:	mov    r10,QWORD PTR [r10]
  4339b6:	mov    QWORD PTR [rbp-0x2888],r10
  4339bd:	lea    r10,[rbp-0x830]
  4339c4:	mov    r10,QWORD PTR [r10+0x8]
  4339c8:	mov    QWORD PTR [rbp-0x2890],r10
  4339cf:	mov    r15,r14
  4339d2:	shr    r15,0x28
  4339d6:	and    r15,0xffff
  4339dd:	movabs r11,0x8
  4339e7:	mov    r13,r15
  4339ea:	cmp    r13,r11
  4339ed:	sete   r13b
  4339f1:	movzx  r13d,r13b
  4339f5:	mov    r10,r13
  4339f8:	test   r10d,r10d
  4339fb:	je     43414c <p111_FID_36_100_105_114_101_99_116_46_77_97_112_46_115_101_101_107_46_103_111_+0x42f8>
  433a01:	mov    rdi,r12
  433a04:	mov    rsi,r14
  433a07:	lea    rdx,[rbp-0x830]
  433a0e:	xor    eax,eax
  433a10:	call   44ff80 <p125_rt_take2>
  433a15:	mov    QWORD PTR [rbp-0x8a0],rax
  433a1c:	lea    r10,[rbp-0x830]
  433a23:	mov    r10,QWORD PTR [r10]
  433a26:	mov    QWORD PTR [rbp-0x2898],r10
  433a2d:	lea    r10,[rbp-0x830]
  433a34:	mov    r10,QWORD PTR [r10+0x8]
  433a38:	mov    QWORD PTR [rbp-0x28a0],r10
  433a3f:	cmp    r10,0x1
  433a46:	sete   r10b
  433a4a:	movzx  r10d,r10b
  433a4e:	mov    QWORD PTR [rbp-0x8d0],r10
  433a55:	mov    r10,QWORD PTR [rbp-0x28a0]
  433a5c:	shr    r10,0x28
  433a60:	mov    QWORD PTR [rbp-0x8d8],r10
  433a67:	and    r10,0x7fffff
  433a6e:	mov    QWORD PTR [rbp-0x8d8],r10
  433a75:	movabs r10,0x2
  433a7f:	or     r10,0x10000
  433a86:	mov    QWORD PTR [rbp-0x8e0],r10
  433a8d:	mov    r10,QWORD PTR [rbp-0x8d8]
  433a94:	mov    r11,QWORD PTR [rbp-0x8e0]
  433a9b:	cmp    r10,r11
  433a9e:	sete   r10b
  433aa2:	movzx  r10d,r10b
  433aa6:	mov    QWORD PTR [rbp-0x8e8],r10
  433aad:	mov    r11,r10
  433ab0:	mov    r13,QWORD PTR [rbp-0x8d0]
  433ab7:	or     r13d,r11d
  433aba:	xor    r13d,0x1
  433ac1:	mov    r10,r13
  433ac4:	test   r10d,r10d
  433ac7:	je     433d01 <p111_FID_36_100_105_114_101_99_116_46_77_97_112_46_115_101_101_107_46_103_111_+0x3ead>
  433acd:	mov    rdi,QWORD PTR [rbp-0x2888]
  433ad4:	lea    r10,[rbp-0x830]
  433adb:	mov    r11,rdi
  433ade:	mov    QWORD PTR [r10],r11
  433ae1:	lea    r10,[rbp-0x830]
  433ae8:	mov    r11,QWORD PTR [rbp-0x2890]
  433aef:	mov    QWORD PTR [r10+0x8],r11
  433af3:	mov    rdi,r12
  433af6:	movabs rsi,0x2c
  433b00:	mov    esi,esi
  433b02:	lea    rdx,[rbp-0x830]
  433b09:	xor    eax,eax
  433b0b:	call   44fe90 <p125_rt_ctor2>
  433b10:	mov    rbx,rax
  433b13:	mov    rdi,rbx
  433b16:	lea    r10,[rbp-0x830]
  433b1d:	mov    r11,QWORD PTR [rbp-0x8a8]
  433b24:	mov    QWORD PTR [r10],r11
  433b27:	lea    r10,[rbp-0x830]
  433b2e:	mov    r11,rdi
  433b31:	mov    QWORD PTR [r10+0x8],r11
  433b35:	mov    rdi,QWORD PTR [r12+0x10]
  433b3a:	mov    rsi,QWORD PTR [rbp-0x8a8]
  433b41:	mov    QWORD PTR [rdi],rsi
  433b44:	lea    r10,[rbp-0x830]
  433b4b:	mov    rsi,QWORD PTR [r10+0x8]
  433b4f:	mov    QWORD PTR [rdi+0x8],rsi
  433b53:	mov    r10,rdi
  433b56:	movabs r11,0x16a
  433b60:	mov    QWORD PTR [r10+0x10],r11
  433b64:	mov    rsi,rdi
  433b67:	add    rsi,0x18
  433b6e:	mov    QWORD PTR [r12+0x10],rsi
  433b73:	mov    rdi,r12
  433b76:	mov    rsi,QWORD PTR [rbp-0x1f78]
  433b7d:	xor    eax,eax
  433b7f:	call   44a150 <p111_rt_keep>
  433b84:	mov    QWORD PTR [rbp-0x1f78],rax
  433b8b:	mov    rdi,rax
  433b8e:	lea    r10,[rbp-0x830]
  433b95:	mov    r11,rdi
  433b98:	mov    QWORD PTR [r10],r11
  433b9b:	lea    r10,[rbp-0x830]
  433ba2:	mov    r11,QWORD PTR [rbp-0x1f80]
  433ba9:	mov    QWORD PTR [r10+0x8],r11
  433bad:	lea    r10,[rbp-0x830]
  433bb4:	mov    r11,QWORD PTR [rbp-0x1f88]
  433bbb:	mov    QWORD PTR [r10+0x10],r11
  433bbf:	mov    rdi,r12
  433bc2:	movabs rsi,0x2d
  433bcc:	mov    esi,esi
  433bce:	lea    rdx,[rbp-0x830]
  433bd5:	xor    eax,eax
  433bd7:	call   450110 <p125_rt_ctor3>
  433bdc:	mov    rbx,rax
  433bdf:	mov    r10,rbx
  433be2:	mov    QWORD PTR [rbp-0x28d8],r10
  433be9:	mov    r10,QWORD PTR [rbp-0x1f78]
  433bf0:	mov    QWORD PTR [rbp-0x28e0],r10
  433bf7:	mov    rdi,r12
  433bfa:	mov    rsi,QWORD PTR [rbp-0x2898]
  433c01:	mov    rdx,QWORD PTR [rbp-0x28e0]
  433c08:	xor    eax,eax
  433c0a:	call   40c838 <p112w_FID_36_100_105_114_101_99_116_46_77_97_112_46_98_105_116_>
  433c0f:	mov    QWORD PTR [rbp-0x28e8],rax
  433c16:	lea    r10,[rbp-0x30e8]
  433c1d:	mov    r11,QWORD PTR [rbp-0x28d8]
  433c24:	mov    QWORD PTR [r10],r11
  433c27:	lea    r10,[rbp-0x30e8]
  433c2e:	mov    r11,QWORD PTR [rbp-0x28e8]
  433c35:	mov    QWORD PTR [r10+0x8],r11
  433c39:	lea    r10,[rip+0x24fa0]        # 458be0 <p111_program>
  433c40:	movabs rdi,0x4
  433c4a:	and    rdi,QWORD PTR [r10+0x58]
  433c4e:	mov    r10,rdi
  433c51:	test   r10d,r10d
  433c54:	je     433cb1 <p111_FID_36_100_105_114_101_99_116_46_77_97_112_46_115_101_101_107_46_103_111_+0x3e5d>
  433c5a:	lea    r10,[rbp-0x30e8]
  433c61:	mov    rdi,QWORD PTR [r10]
  433c64:	lea    r10,[rbp-0x30e8]
  433c6b:	mov    rsi,QWORD PTR [r10+0x8]
  433c6f:	mov    QWORD PTR [r12+0x28],rdi
  433c74:	mov    QWORD PTR [r12+0x30],rsi
  433c79:	mov    r10,r12
  433c7c:	movabs r11,0x0
  433c86:	mov    DWORD PTR [r10+0x1c],r11d
  433c8a:	mov    r10,r12
  433c8d:	movabs r11,0x151
  433c97:	mov    DWORD PTR [r10+0x20],r11d
  433c9b:	movabs r10,0x0
  433ca5:	mov    QWORD PTR [rbp-0x3110],r10
  433cac:	jmp    433ce1 <p111_FID_36_100_105_114_101_99_116_46_77_97_112_46_115_101_101_107_46_103_111_+0x3e8d>
  433cb1:	mov    rdi,r12
  433cb4:	movabs rsi,0x151
  433cbe:	mov    esi,esi
  433cc0:	lea    rdx,[rbp-0x30e8]
  433cc7:	movabs rcx,0x2
  433cd1:	mov    ecx,ecx
  433cd3:	xor    eax,eax
  433cd5:	call   44a7a0 <p111_rt_jump>
  433cda:	mov    QWORD PTR [rbp-0x3110],rax
  433ce1:	mov    rax,QWORD PTR [rbp-0x3110]
  433ce8:	mov    r12,QWORD PTR [rbp-0x10]
  433cec:	mov    rbx,QWORD PTR [rbp-0x8]
  433cf0:	mov    r13,QWORD PTR [rbp-0x18]
  433cf4:	mov    r14,QWORD PTR [rbp-0x20]
  433cf8:	mov    r15,QWORD PTR [rbp-0x28]
  433cfc:	mov    rsp,rbp
  433cff:	pop    rbp
  433d00:	ret    
  433d01:	mov    r10,QWORD PTR [rbp-0x28a0]
  433d08:	cmp    r10,0x1
  433d0f:	sete   r10b
  433d13:	movzx  r10d,r10b
  433d17:	mov    QWORD PTR [rbp-0x8d0],r10
  433d1e:	mov    r10,QWORD PTR [rbp-0x28a0]
  433d25:	shr    r10,0x28
  433d29:	mov    QWORD PTR [rbp-0x8d8],r10
  433d30:	and    r10,0x7fffff
  433d37:	mov    QWORD PTR [rbp-0x8d8],r10
  433d3e:	movabs r10,0x2
  433d48:	or     r10,0x10000
  433d4f:	mov    QWORD PTR [rbp-0x8e0],r10
  433d56:	mov    r10,QWORD PTR [rbp-0x8d8]
  433d5d:	mov    r11,QWORD PTR [rbp-0x8e0]
  433d64:	cmp    r10,r11
  433d67:	sete   r10b
  433d6b:	movzx  r10d,r10b
  433d6f:	mov    QWORD PTR [rbp-0x8e8],r10
  433d76:	mov    r11,r10
  433d79:	mov    r13,QWORD PTR [rbp-0x8d0]
  433d80:	or     r13d,r11d
  433d83:	mov    r10,r13
  433d86:	test   r10d,r10d
  433d89:	je     43402b <p111_FID_36_100_105_114_101_99_116_46_77_97_112_46_115_101_101_107_46_103_111_+0x41d7>
  433d8f:	mov    rdi,QWORD PTR [rbp-0x1f78]
  433d96:	lea    r10,[rbp-0x830]
  433d9d:	mov    r11,rdi
  433da0:	mov    QWORD PTR [r10],r11
  433da3:	lea    r10,[rbp-0x830]
  433daa:	mov    r11,QWORD PTR [rbp-0x1f80]
  433db1:	mov    QWORD PTR [r10+0x8],r11
  433db5:	lea    r10,[rbp-0x830]
  433dbc:	mov    r11,QWORD PTR [rbp-0x1f88]
  433dc3:	mov    QWORD PTR [r10+0x10],r11
  433dc7:	mov    rdi,r12
  433dca:	movabs rsi,0x2d
  433dd4:	mov    esi,esi
  433dd6:	lea    rdx,[rbp-0x830]
  433ddd:	xor    eax,eax
  433ddf:	call   450110 <p125_rt_ctor3>
  433de4:	mov    rbx,rax
  433de7:	mov    r10,rbx
  433dea:	mov    QWORD PTR [rbp-0x3120],r10
  433df1:	mov    rdi,r12
  433df4:	mov    rsi,QWORD PTR [rbp-0x2888]
  433dfb:	xor    eax,eax
  433dfd:	call   44a150 <p111_rt_keep>
  433e02:	mov    QWORD PTR [rbp-0x2888],rax
  433e09:	mov    rdi,rax
  433e0c:	lea    r10,[rbp-0x830]
  433e13:	mov    r11,rdi
  433e16:	mov    QWORD PTR [r10],r11
  433e19:	lea    r10,[rbp-0x830]
  433e20:	mov    r11,QWORD PTR [rbp-0x2890]
  433e27:	mov    QWORD PTR [r10+0x8],r11
  433e2b:	mov    rdi,r12
  433e2e:	movabs rsi,0x2c
  433e38:	mov    esi,esi
  433e3a:	lea    rdx,[rbp-0x830]
  433e41:	xor    eax,eax
  433e43:	call   44fe90 <p125_rt_ctor2>
  433e48:	mov    rbx,rax
  433e4b:	mov    rdi,rbx
  433e4e:	lea    r10,[rbp-0x830]
  433e55:	mov    r11,QWORD PTR [rbp-0x8a8]
  433e5c:	mov    QWORD PTR [r10],r11
  433e5f:	lea    r10,[rbp-0x830]
  433e66:	mov    r11,QWORD PTR [rbp-0x3120]
  433e6d:	mov    QWORD PTR [r10+0x8],r11
  433e71:	lea    r10,[rbp-0x830]
  433e78:	mov    r11,rdi
  433e7b:	mov    QWORD PTR [r10+0x10],r11
  433e7f:	mov    rdi,r12
  433e82:	movabs rsi,0x2d
  433e8c:	mov    esi,esi
  433e8e:	lea    rdx,[rbp-0x830]
  433e95:	xor    eax,eax
  433e97:	call   450110 <p125_rt_ctor3>
  433e9c:	mov    rbx,rax
  433e9f:	mov    r10,rbx
  433ea2:	mov    QWORD PTR [rbp-0x3138],r10
  433ea9:	mov    rdi,QWORD PTR [rbp-0x2888]
  433eb0:	lea    r10,[rbp-0x830]
  433eb7:	mov    r11,rdi
  433eba:	mov    QWORD PTR [r10],r11
  433ebd:	mov    rdi,r12
  433ec0:	movabs rsi,0xc
  433eca:	mov    esi,esi
  433ecc:	lea    rdx,[rbp-0x830]
  433ed3:	xor    eax,eax
  433ed5:	call   44fc60 <p125_rt_ctor1>
  433eda:	mov    rbx,rax
  433edd:	mov    rdi,rbx
  433ee0:	lea    r10,[rbp-0x830]
  433ee7:	mov    r11,QWORD PTR [rbp-0x2898]
  433eee:	mov    QWORD PTR [r10],r11
  433ef1:	lea    r10,[rbp-0x830]
  433ef8:	mov    r11,rdi
  433efb:	mov    QWORD PTR [r10+0x8],r11
  433eff:	mov    rdi,r12
  433f02:	movabs rsi,0x8
  433f0c:	mov    esi,esi
  433f0e:	lea    rdx,[rbp-0x830]
  433f15:	xor    eax,eax
  433f17:	call   44fe90 <p125_rt_ctor2>
  433f1c:	mov    rbx,rax
  433f1f:	mov    rdi,rbx
  433f22:	lea    r10,[rbp-0x830]
  433f29:	mov    r11,QWORD PTR [rbp-0x3138]
  433f30:	mov    QWORD PTR [r10],r11
  433f33:	lea    r10,[rbp-0x830]
  433f3a:	mov    r11,rdi
  433f3d:	mov    QWORD PTR [r10+0x8],r11
  433f41:	mov    rdi,r12
  433f44:	movabs rsi,0x8
  433f4e:	mov    esi,esi
  433f50:	lea    rdx,[rbp-0x830]
  433f57:	xor    eax,eax
  433f59:	call   44fe90 <p125_rt_ctor2>
  433f5e:	mov    rbx,rax
  433f61:	lea    r10,[rbp-0x830]
  433f68:	mov    r11,rbx
  433f6b:	mov    QWORD PTR [r10],r11
  433f6e:	lea    r10,[rip+0x24c6b]        # 458be0 <p111_program>
  433f75:	movabs rdi,0x4
  433f7f:	and    rdi,QWORD PTR [r10+0x58]
  433f83:	mov    r10,rdi
  433f86:	test   r10d,r10d
  433f89:	je     433fe7 <p111_FID_36_100_105_114_101_99_116_46_77_97_112_46_115_101_101_107_46_103_111_+0x4193>
  433f8f:	lea    r10,[rbp-0x830]
  433f96:	mov    rdi,QWORD PTR [r10]
  433f99:	mov    QWORD PTR [r12+0x28],rdi
  433f9e:	mov    r10,r12
  433fa1:	movabs r11,0x1
  433fab:	mov    DWORD PTR [r10+0x1c],r11d
  433faf:	mov    rdi,QWORD PTR [r12+0x10]
  433fb4:	movabs r11,0xfffffffffffffff8
  433fbe:	mov    rsi,rdi
  433fc1:	add    rsi,r11
  433fc4:	mov    QWORD PTR [r12+0x10],rsi
  433fc9:	mov    rdi,QWORD PTR [rsi]
  433fcc:	mov    DWORD PTR [r12+0x20],edi
  433fd1:	movabs r10,0x0
  433fdb:	mov    QWORD PTR [rbp-0x950],r10
  433fe2:	jmp    43400b <p111_FID_36_100_105_114_101_99_116_46_77_97_112_46_115_101_101_107_46_103_111_+0x41b7>
  433fe7:	mov    rdi,r12
  433fea:	lea    rsi,[rbp-0x830]
  433ff1:	movabs rdx,0x1
  433ffb:	mov    edx,edx
  433ffd:	xor    eax,eax
  433fff:	call   44a800 <p111_rt_return>
  434004:	mov    QWORD PTR [rbp-0x950],rax
  43400b:	mov    rax,QWORD PTR [rbp-0x950]
  434012:	mov    r12,QWORD PTR [rbp-0x10]
  434016:	mov    rbx,QWORD PTR [rbp-0x8]
  43401a:	mov    r13,QWORD PTR [rbp-0x18]
  43401e:	mov    r14,QWORD PTR [rbp-0x20]
  434022:	mov    r15,QWORD PTR [rbp-0x28]
  434026:	mov    rsp,rbp
  434029:	pop    rbp
  43402a:	ret    
  43402b:	mov    rdi,r12
  43402e:	mov    rsi,QWORD PTR [rbp-0x8a8]
  434035:	xor    eax,eax
  434037:	call   44a1e0 <p111_rt_sink>
  43403c:	mov    QWORD PTR [rbp-0x8a0],rax
  434043:	mov    rdi,r12
  434046:	mov    rsi,QWORD PTR [rbp-0x1f78]
  43404d:	xor    eax,eax
  43404f:	call   44a1e0 <p111_rt_sink>
  434054:	mov    QWORD PTR [rbp-0x8a0],rax
  43405b:	mov    rdi,r12
  43405e:	mov    rsi,QWORD PTR [rbp-0x1f80]
  434065:	xor    eax,eax
  434067:	call   44a1e0 <p111_rt_sink>
  43406c:	mov    QWORD PTR [rbp-0x8a0],rax
  434073:	mov    rdi,r12
  434076:	mov    rsi,QWORD PTR [rbp-0x1f88]
  43407d:	xor    eax,eax
  43407f:	call   44a1e0 <p111_rt_sink>
  434084:	mov    QWORD PTR [rbp-0x8a0],rax
  43408b:	mov    rdi,r12
  43408e:	mov    rsi,QWORD PTR [rbp-0x2888]
  434095:	xor    eax,eax
  434097:	call   44a1e0 <p111_rt_sink>
  43409c:	mov    QWORD PTR [rbp-0x8a0],rax
  4340a3:	mov    rdi,r12
  4340a6:	mov    rsi,QWORD PTR [rbp-0x2890]
  4340ad:	xor    eax,eax
  4340af:	call   44a1e0 <p111_rt_sink>
  4340b4:	mov    QWORD PTR [rbp-0x8a0],rax
  4340bb:	mov    rdi,r12
  4340be:	mov    rsi,QWORD PTR [rbp-0x2898]
  4340c5:	xor    eax,eax
  4340c7:	call   44a1e0 <p111_rt_sink>
  4340cc:	mov    QWORD PTR [rbp-0x8a0],rax
  4340d3:	lea    r10,[rbp-0x830]
  4340da:	mov    r11,QWORD PTR [rbp-0x28a0]
  4340e1:	mov    QWORD PTR [r10],r11
  4340e4:	mov    rdi,QWORD PTR [r12+0x10]
  4340e9:	mov    r10,rdi
  4340ec:	mov    r11,QWORD PTR [rbp-0x28a0]
  4340f3:	mov    QWORD PTR [r10],r11
  4340f6:	mov    r10,rdi
  4340f9:	movabs r11,0x16c
  434103:	mov    QWORD PTR [r10+0x8],r11
  434107:	mov    rsi,rdi
  43410a:	add    rsi,0x10
  434111:	mov    QWORD PTR [r12+0x10],rsi
  434116:	mov    rdi,r12
  434119:	movabs rsi,0x4
  434123:	mov    esi,esi
  434125:	xor    eax,eax
  434127:	call   44a970 <p111_rt_fail>
  43412c:	mov    QWORD PTR [rbp-0x950],rax
  434133:	mov    r12,QWORD PTR [rbp-0x10]
  434137:	mov    rbx,QWORD PTR [rbp-0x8]
  43413b:	mov    r13,QWORD PTR [rbp-0x18]
  43413f:	mov    r14,QWORD PTR [rbp-0x20]
  434143:	mov    r15,QWORD PTR [rbp-0x28]
  434147:	mov    rsp,rbp
  43414a:	pop    rbp
  43414b:	ret    
  43414c:	mov    rdi,r12
  43414f:	mov    rsi,QWORD PTR [rbp-0x8a8]
  434156:	xor    eax,eax
  434158:	call   44a1e0 <p111_rt_sink>
  43415d:	mov    QWORD PTR [rbp-0x8a0],rax
  434164:	mov    rdi,r12
  434167:	mov    rsi,QWORD PTR [rbp-0x1f78]
  43416e:	xor    eax,eax
  434170:	call   44a1e0 <p111_rt_sink>
  434175:	mov    QWORD PTR [rbp-0x8a0],rax
  43417c:	mov    rdi,r12
  43417f:	mov    rsi,QWORD PTR [rbp-0x1f80]
  434186:	xor    eax,eax
  434188:	call   44a1e0 <p111_rt_sink>
  43418d:	mov    QWORD PTR [rbp-0x8a0],rax
  434194:	mov    rdi,r12
  434197:	mov    rsi,QWORD PTR [rbp-0x1f88]
  43419e:	xor    eax,eax
  4341a0:	call   44a1e0 <p111_rt_sink>
  4341a5:	mov    QWORD PTR [rbp-0x8a0],rax
  4341ac:	mov    rdi,r12
  4341af:	mov    rsi,QWORD PTR [rbp-0x2888]
  4341b6:	xor    eax,eax
  4341b8:	call   44a1e0 <p111_rt_sink>
  4341bd:	mov    QWORD PTR [rbp-0x8a0],rax
  4341c4:	mov    rdi,r12
  4341c7:	mov    rsi,QWORD PTR [rbp-0x2890]
  4341ce:	xor    eax,eax
  4341d0:	call   44a1e0 <p111_rt_sink>
  4341d5:	mov    QWORD PTR [rbp-0x8a0],rax
  4341dc:	lea    r10,[rbp-0x830]
  4341e3:	mov    r11,r14
  4341e6:	mov    QWORD PTR [r10],r11
  4341e9:	mov    rdi,QWORD PTR [r12+0x10]
  4341ee:	mov    QWORD PTR [rdi],r14
  4341f1:	mov    r10,rdi
  4341f4:	movabs r11,0x16d
  4341fe:	mov    QWORD PTR [r10+0x8],r11
  434202:	mov    rsi,rdi
  434205:	add    rsi,0x10
  43420c:	mov    QWORD PTR [r12+0x10],rsi
  434211:	mov    rdi,r12
  434214:	movabs rsi,0x4
  43421e:	mov    esi,esi
  434220:	xor    eax,eax
  434222:	call   44a970 <p111_rt_fail>
  434227:	mov    QWORD PTR [rbp-0x950],rax
  43422e:	mov    r12,QWORD PTR [rbp-0x10]
  434232:	mov    rbx,QWORD PTR [rbp-0x8]
  434236:	mov    r13,QWORD PTR [rbp-0x18]
  43423a:	mov    r14,QWORD PTR [rbp-0x20]
  43423e:	mov    r15,QWORD PTR [rbp-0x28]
  434242:	mov    rsp,rbp
  434245:	pop    rbp
  434246:	ret    
  434247:	mov    r15,QWORD PTR [rbp-0x8b8]
  43424e:	shr    r15,0x28
  434252:	and    r15,0xffff
  434259:	movabs r11,0x2d
  434263:	mov    r13,r15
  434266:	cmp    r13,r11
  434269:	sete   r13b
  43426d:	movzx  r13d,r13b
  434271:	mov    r10,r13
  434274:	test   r10d,r10d
  434277:	je     434b35 <p111_FID_36_100_105_114_101_99_116_46_77_97_112_46_115_101_101_107_46_103_111_+0x4ce1>
  43427d:	mov    rdi,r12
  434280:	mov    rsi,QWORD PTR [rbp-0x8b8]
  434287:	lea    rdx,[rbp-0x830]
  43428e:	xor    eax,eax
  434290:	call   4501e0 <p125_rt_take3>
  434295:	mov    QWORD PTR [rbp-0x8a0],rax
  43429c:	lea    r10,[rbp-0x830]
  4342a3:	mov    r10,QWORD PTR [r10]
  4342a6:	mov    QWORD PTR [rbp-0x31a8],r10
  4342ad:	lea    r10,[rbp-0x830]
  4342b4:	mov    r10,QWORD PTR [r10+0x8]
  4342b8:	mov    QWORD PTR [rbp-0x31b0],r10
  4342bf:	lea    r10,[rbp-0x830]
  4342c6:	mov    r10,QWORD PTR [r10+0x10]
  4342ca:	mov    QWORD PTR [rbp-0x31b8],r10
  4342d1:	mov    r15,r14
  4342d4:	shr    r15,0x28
  4342d8:	and    r15,0xffff
  4342df:	movabs r11,0x8
  4342e9:	mov    r13,r15
  4342ec:	cmp    r13,r11
  4342ef:	sete   r13b
  4342f3:	movzx  r13d,r13b
  4342f7:	mov    r10,r13
  4342fa:	test   r10d,r10d
  4342fd:	je     434a22 <p111_FID_36_100_105_114_101_99_116_46_77_97_112_46_115_101_101_107_46_103_111_+0x4bce>
  434303:	mov    rdi,r12
  434306:	mov    rsi,r14
  434309:	lea    rdx,[rbp-0x830]
  434310:	xor    eax,eax
  434312:	call   44ff80 <p125_rt_take2>
  434317:	mov    QWORD PTR [rbp-0x8a0],rax
  43431e:	lea    r10,[rbp-0x830]
  434325:	mov    r10,QWORD PTR [r10]
  434328:	mov    QWORD PTR [rbp-0x31c0],r10
  43432f:	lea    r10,[rbp-0x830]
  434336:	mov    r10,QWORD PTR [r10+0x8]
  43433a:	mov    QWORD PTR [rbp-0x31c8],r10
  434341:	cmp    r10,0x1
  434348:	sete   r10b
  43434c:	movzx  r10d,r10b
  434350:	mov    QWORD PTR [rbp-0x8d0],r10
  434357:	mov    r10,QWORD PTR [rbp-0x31c8]
  43435e:	shr    r10,0x28
  434362:	mov    QWORD PTR [rbp-0x8d8],r10
  434369:	and    r10,0x7fffff
  434370:	mov    QWORD PTR [rbp-0x8d8],r10
  434377:	movabs r10,0x2
  434381:	or     r10,0x10000
  434388:	mov    QWORD PTR [rbp-0x8e0],r10
  43438f:	mov    r10,QWORD PTR [rbp-0x8d8]
  434396:	mov    r11,QWORD PTR [rbp-0x8e0]
  43439d:	cmp    r10,r11
  4343a0:	sete   r10b
  4343a4:	movzx  r10d,r10b
  4343a8:	mov    QWORD PTR [rbp-0x8e8],r10
  4343af:	mov    r11,r10
  4343b2:	mov    r13,QWORD PTR [rbp-0x8d0]
  4343b9:	or     r13d,r11d
  4343bc:	xor    r13d,0x1
  4343c3:	mov    r10,r13
  4343c6:	test   r10d,r10d
  4343c9:	je     434615 <p111_FID_36_100_105_114_101_99_116_46_77_97_112_46_115_101_101_107_46_103_111_+0x47c1>
  4343cf:	mov    rdi,QWORD PTR [rbp-0x31a8]
  4343d6:	lea    r10,[rbp-0x830]
  4343dd:	mov    r11,rdi
  4343e0:	mov    QWORD PTR [r10],r11
  4343e3:	lea    r10,[rbp-0x830]
  4343ea:	mov    r11,QWORD PTR [rbp-0x31b0]
  4343f1:	mov    QWORD PTR [r10+0x8],r11
  4343f5:	lea    r10,[rbp-0x830]
  4343fc:	mov    r11,QWORD PTR [rbp-0x31b8]
  434403:	mov    QWORD PTR [r10+0x10],r11
  434407:	mov    rdi,r12
  43440a:	movabs rsi,0x2d
  434414:	mov    esi,esi
  434416:	lea    rdx,[rbp-0x830]
  43441d:	xor    eax,eax
  43441f:	call   450110 <p125_rt_ctor3>
  434424:	mov    rbx,rax
  434427:	mov    rdi,rbx
  43442a:	lea    r10,[rbp-0x830]
  434431:	mov    r11,QWORD PTR [rbp-0x8a8]
  434438:	mov    QWORD PTR [r10],r11
  43443b:	lea    r10,[rbp-0x830]
  434442:	mov    r11,rdi
  434445:	mov    QWORD PTR [r10+0x8],r11
  434449:	mov    rdi,QWORD PTR [r12+0x10]
  43444e:	mov    rsi,QWORD PTR [rbp-0x8a8]
  434455:	mov    QWORD PTR [rdi],rsi
  434458:	lea    r10,[rbp-0x830]
  43445f:	mov    rsi,QWORD PTR [r10+0x8]
  434463:	mov    QWORD PTR [rdi+0x8],rsi
  434467:	mov    r10,rdi
  43446a:	movabs r11,0x16e
  434474:	mov    QWORD PTR [r10+0x10],r11
  434478:	mov    rsi,rdi
  43447b:	add    rsi,0x18
  434482:	mov    QWORD PTR [r12+0x10],rsi
  434487:	mov    rdi,r12
  43448a:	mov    rsi,QWORD PTR [rbp-0x1f78]
  434491:	xor    eax,eax
  434493:	call   44a150 <p111_rt_keep>
  434498:	mov    QWORD PTR [rbp-0x1f78],rax
  43449f:	mov    rdi,rax
  4344a2:	lea    r10,[rbp-0x830]
  4344a9:	mov    r11,rdi
  4344ac:	mov    QWORD PTR [r10],r11
  4344af:	lea    r10,[rbp-0x830]
  4344b6:	mov    r11,QWORD PTR [rbp-0x1f80]
  4344bd:	mov    QWORD PTR [r10+0x8],r11
  4344c1:	lea    r10,[rbp-0x830]
  4344c8:	mov    r11,QWORD PTR [rbp-0x1f88]
  4344cf:	mov    QWORD PTR [r10+0x10],r11
  4344d3:	mov    rdi,r12
  4344d6:	movabs rsi,0x2d
  4344e0:	mov    esi,esi
  4344e2:	lea    rdx,[rbp-0x830]
  4344e9:	xor    eax,eax
  4344eb:	call   450110 <p125_rt_ctor3>
  4344f0:	mov    rbx,rax
  4344f3:	mov    r10,rbx
  4344f6:	mov    QWORD PTR [rbp-0x3200],r10
  4344fd:	mov    r10,QWORD PTR [rbp-0x1f78]
  434504:	mov    QWORD PTR [rbp-0x3208],r10
  43450b:	mov    rdi,r12
  43450e:	mov    rsi,QWORD PTR [rbp-0x31c0]
  434515:	mov    rdx,QWORD PTR [rbp-0x3208]
  43451c:	xor    eax,eax
  43451e:	call   40c838 <p112w_FID_36_100_105_114_101_99_116_46_77_97_112_46_98_105_116_>
  434523:	mov    QWORD PTR [rbp-0x3210],rax
  43452a:	lea    r10,[rbp-0x3a10]
  434531:	mov    r11,QWORD PTR [rbp-0x3200]
  434538:	mov    QWORD PTR [r10],r11
  43453b:	lea    r10,[rbp-0x3a10]
  434542:	mov    r11,QWORD PTR [rbp-0x3210]
  434549:	mov    QWORD PTR [r10+0x8],r11
  43454d:	lea    r10,[rip+0x2468c]        # 458be0 <p111_program>
  434554:	movabs rdi,0x4
  43455e:	and    rdi,QWORD PTR [r10+0x58]
  434562:	mov    r10,rdi
  434565:	test   r10d,r10d
  434568:	je     4345c5 <p111_FID_36_100_105_114_101_99_116_46_77_97_112_46_115_101_101_107_46_103_111_+0x4771>
  43456e:	lea    r10,[rbp-0x3a10]
  434575:	mov    rdi,QWORD PTR [r10]
  434578:	lea    r10,[rbp-0x3a10]
  43457f:	mov    rsi,QWORD PTR [r10+0x8]
  434583:	mov    QWORD PTR [r12+0x28],rdi
  434588:	mov    QWORD PTR [r12+0x30],rsi
  43458d:	mov    r10,r12
  434590:	movabs r11,0x0
  43459a:	mov    DWORD PTR [r10+0x1c],r11d
  43459e:	mov    r10,r12
  4345a1:	movabs r11,0x151
  4345ab:	mov    DWORD PTR [r10+0x20],r11d
  4345af:	movabs r10,0x0
  4345b9:	mov    QWORD PTR [rbp-0x3a38],r10
  4345c0:	jmp    4345f5 <p111_FID_36_100_105_114_101_99_116_46_77_97_112_46_115_101_101_107_46_103_111_+0x47a1>
  4345c5:	mov    rdi,r12
  4345c8:	movabs rsi,0x151
  4345d2:	mov    esi,esi
  4345d4:	lea    rdx,[rbp-0x3a10]
  4345db:	movabs rcx,0x2
  4345e5:	mov    ecx,ecx
  4345e7:	xor    eax,eax
  4345e9:	call   44a7a0 <p111_rt_jump>
  4345ee:	mov    QWORD PTR [rbp-0x3a38],rax
  4345f5:	mov    rax,QWORD PTR [rbp-0x3a38]
  4345fc:	mov    r12,QWORD PTR [rbp-0x10]
  434600:	mov    rbx,QWORD PTR [rbp-0x8]
  434604:	mov    r13,QWORD PTR [rbp-0x18]
  434608:	mov    r14,QWORD PTR [rbp-0x20]
  43460c:	mov    r15,QWORD PTR [rbp-0x28]
  434610:	mov    rsp,rbp
  434613:	pop    rbp
  434614:	ret    
  434615:	mov    r10,QWORD PTR [rbp-0x31c8]
  43461c:	cmp    r10,0x1
  434623:	sete   r10b
  434627:	movzx  r10d,r10b
  43462b:	mov    QWORD PTR [rbp-0x8d0],r10
  434632:	mov    r10,QWORD PTR [rbp-0x31c8]
  434639:	shr    r10,0x28
  43463d:	mov    QWORD PTR [rbp-0x8d8],r10
  434644:	and    r10,0x7fffff
  43464b:	mov    QWORD PTR [rbp-0x8d8],r10
  434652:	movabs r10,0x2
  43465c:	or     r10,0x10000
  434663:	mov    QWORD PTR [rbp-0x8e0],r10
  43466a:	mov    r10,QWORD PTR [rbp-0x8d8]
  434671:	mov    r11,QWORD PTR [rbp-0x8e0]
  434678:	cmp    r10,r11
  43467b:	sete   r10b
  43467f:	movzx  r10d,r10b
  434683:	mov    QWORD PTR [rbp-0x8e8],r10
  43468a:	mov    r11,r10
  43468d:	mov    r13,QWORD PTR [rbp-0x8d0]
  434694:	or     r13d,r11d
  434697:	mov    r10,r13
  43469a:	test   r10d,r10d
  43469d:	je     4348e9 <p111_FID_36_100_105_114_101_99_116_46_77_97_112_46_115_101_101_107_46_103_111_+0x4a95>
  4346a3:	mov    rdi,QWORD PTR [rbp-0x1f78]
  4346aa:	lea    r10,[rbp-0x830]
  4346b1:	mov    r11,rdi
  4346b4:	mov    QWORD PTR [r10],r11
  4346b7:	lea    r10,[rbp-0x830]
  4346be:	mov    r11,QWORD PTR [rbp-0x1f80]
  4346c5:	mov    QWORD PTR [r10+0x8],r11
  4346c9:	lea    r10,[rbp-0x830]
  4346d0:	mov    r11,QWORD PTR [rbp-0x1f88]
  4346d7:	mov    QWORD PTR [r10+0x10],r11
  4346db:	mov    rdi,r12
  4346de:	movabs rsi,0x2d
  4346e8:	mov    esi,esi
  4346ea:	lea    rdx,[rbp-0x830]
  4346f1:	xor    eax,eax
  4346f3:	call   450110 <p125_rt_ctor3>
  4346f8:	mov    rbx,rax
  4346fb:	mov    rdi,rbx
  4346fe:	lea    r10,[rbp-0x830]
  434705:	mov    r11,QWORD PTR [rbp-0x8a8]
  43470c:	mov    QWORD PTR [r10],r11
  43470f:	lea    r10,[rbp-0x830]
  434716:	mov    r11,rdi
  434719:	mov    QWORD PTR [r10+0x8],r11
  43471d:	mov    rdi,QWORD PTR [r12+0x10]
  434722:	mov    rsi,QWORD PTR [rbp-0x8a8]
  434729:	mov    QWORD PTR [rdi],rsi
  43472c:	lea    r10,[rbp-0x830]
  434733:	mov    rsi,QWORD PTR [r10+0x8]
  434737:	mov    QWORD PTR [rdi+0x8],rsi
  43473b:	mov    r10,rdi
  43473e:	movabs r11,0x170
  434748:	mov    QWORD PTR [r10+0x10],r11
  43474c:	mov    rsi,rdi
  43474f:	add    rsi,0x18
  434756:	mov    QWORD PTR [r12+0x10],rsi
  43475b:	mov    rdi,r12
  43475e:	mov    rsi,QWORD PTR [rbp-0x31a8]
  434765:	xor    eax,eax
  434767:	call   44a150 <p111_rt_keep>
  43476c:	mov    QWORD PTR [rbp-0x31a8],rax
  434773:	mov    rdi,rax
  434776:	lea    r10,[rbp-0x830]
  43477d:	mov    r11,rdi
  434780:	mov    QWORD PTR [r10],r11
  434783:	lea    r10,[rbp-0x830]
  43478a:	mov    r11,QWORD PTR [rbp-0x31b0]
  434791:	mov    QWORD PTR [r10+0x8],r11
  434795:	lea    r10,[rbp-0x830]
  43479c:	mov    r11,QWORD PTR [rbp-0x31b8]
  4347a3:	mov    QWORD PTR [r10+0x10],r11
  4347a7:	mov    rdi,r12
  4347aa:	movabs rsi,0x2d
  4347b4:	mov    esi,esi
  4347b6:	lea    rdx,[rbp-0x830]
  4347bd:	xor    eax,eax
  4347bf:	call   450110 <p125_rt_ctor3>
  4347c4:	mov    rbx,rax
  4347c7:	mov    r10,rbx
  4347ca:	mov    QWORD PTR [rbp-0x3a70],r10
  4347d1:	mov    r10,QWORD PTR [rbp-0x31a8]
  4347d8:	mov    QWORD PTR [rbp-0x3a78],r10
  4347df:	mov    rdi,r12
  4347e2:	mov    rsi,QWORD PTR [rbp-0x31c0]
  4347e9:	mov    rdx,QWORD PTR [rbp-0x3a78]
  4347f0:	xor    eax,eax
  4347f2:	call   40c838 <p112w_FID_36_100_105_114_101_99_116_46_77_97_112_46_98_105_116_>
  4347f7:	mov    QWORD PTR [rbp-0x3a80],rax
  4347fe:	lea    r10,[rbp-0x4280]
  434805:	mov    r11,QWORD PTR [rbp-0x3a70]
  43480c:	mov    QWORD PTR [r10],r11
  43480f:	lea    r10,[rbp-0x4280]
  434816:	mov    r11,QWORD PTR [rbp-0x3a80]
  43481d:	mov    QWORD PTR [r10+0x8],r11
  434821:	lea    r10,[rip+0x243b8]        # 458be0 <p111_program>
  434828:	movabs rdi,0x4
  434832:	and    rdi,QWORD PTR [r10+0x58]
  434836:	mov    r10,rdi
  434839:	test   r10d,r10d
  43483c:	je     434899 <p111_FID_36_100_105_114_101_99_116_46_77_97_112_46_115_101_101_107_46_103_111_+0x4a45>
  434842:	lea    r10,[rbp-0x4280]
  434849:	mov    rdi,QWORD PTR [r10]
  43484c:	lea    r10,[rbp-0x4280]
  434853:	mov    rsi,QWORD PTR [r10+0x8]
  434857:	mov    QWORD PTR [r12+0x28],rdi
  43485c:	mov    QWORD PTR [r12+0x30],rsi
  434861:	mov    r10,r12
  434864:	movabs r11,0x0
  43486e:	mov    DWORD PTR [r10+0x1c],r11d
  434872:	mov    r10,r12
  434875:	movabs r11,0x151
  43487f:	mov    DWORD PTR [r10+0x20],r11d
  434883:	movabs r10,0x0
  43488d:	mov    QWORD PTR [rbp-0x42a8],r10
  434894:	jmp    4348c9 <p111_FID_36_100_105_114_101_99_116_46_77_97_112_46_115_101_101_107_46_103_111_+0x4a75>
  434899:	mov    rdi,r12
  43489c:	movabs rsi,0x151
  4348a6:	mov    esi,esi
  4348a8:	lea    rdx,[rbp-0x4280]
  4348af:	movabs rcx,0x2
  4348b9:	mov    ecx,ecx
  4348bb:	xor    eax,eax
  4348bd:	call   44a7a0 <p111_rt_jump>
  4348c2:	mov    QWORD PTR [rbp-0x42a8],rax
  4348c9:	mov    rax,QWORD PTR [rbp-0x42a8]
  4348d0:	mov    r12,QWORD PTR [rbp-0x10]
  4348d4:	mov    rbx,QWORD PTR [rbp-0x8]
  4348d8:	mov    r13,QWORD PTR [rbp-0x18]
  4348dc:	mov    r14,QWORD PTR [rbp-0x20]
  4348e0:	mov    r15,QWORD PTR [rbp-0x28]
  4348e4:	mov    rsp,rbp
  4348e7:	pop    rbp
  4348e8:	ret    
  4348e9:	mov    rdi,r12
  4348ec:	mov    rsi,QWORD PTR [rbp-0x8a8]
  4348f3:	xor    eax,eax
  4348f5:	call   44a1e0 <p111_rt_sink>
  4348fa:	mov    QWORD PTR [rbp-0x8a0],rax
  434901:	mov    rdi,r12
  434904:	mov    rsi,QWORD PTR [rbp-0x1f78]
  43490b:	xor    eax,eax
  43490d:	call   44a1e0 <p111_rt_sink>
  434912:	mov    QWORD PTR [rbp-0x8a0],rax
  434919:	mov    rdi,r12
  43491c:	mov    rsi,QWORD PTR [rbp-0x1f80]
  434923:	xor    eax,eax
  434925:	call   44a1e0 <p111_rt_sink>
  43492a:	mov    QWORD PTR [rbp-0x8a0],rax
  434931:	mov    rdi,r12
  434934:	mov    rsi,QWORD PTR [rbp-0x1f88]
  43493b:	xor    eax,eax
  43493d:	call   44a1e0 <p111_rt_sink>
  434942:	mov    QWORD PTR [rbp-0x8a0],rax
  434949:	mov    rdi,r12
  43494c:	mov    rsi,QWORD PTR [rbp-0x31a8]
  434953:	xor    eax,eax
  434955:	call   44a1e0 <p111_rt_sink>
  43495a:	mov    QWORD PTR [rbp-0x8a0],rax
  434961:	mov    rdi,r12
  434964:	mov    rsi,QWORD PTR [rbp-0x31b0]
  43496b:	xor    eax,eax
  43496d:	call   44a1e0 <p111_rt_sink>
  434972:	mov    QWORD PTR [rbp-0x8a0],rax
  434979:	mov    rdi,r12
  43497c:	mov    rsi,QWORD PTR [rbp-0x31b8]
  434983:	xor    eax,eax
  434985:	call   44a1e0 <p111_rt_sink>
  43498a:	mov    QWORD PTR [rbp-0x8a0],rax
  434991:	mov    rdi,r12
  434994:	mov    rsi,QWORD PTR [rbp-0x31c0]
  43499b:	xor    eax,eax
  43499d:	call   44a1e0 <p111_rt_sink>
  4349a2:	mov    QWORD PTR [rbp-0x8a0],rax
  4349a9:	lea    r10,[rbp-0x830]
  4349b0:	mov    r11,QWORD PTR [rbp-0x31c8]
  4349b7:	mov    QWORD PTR [r10],r11
  4349ba:	mov    rdi,QWORD PTR [r12+0x10]
  4349bf:	mov    r10,rdi
  4349c2:	mov    r11,QWORD PTR [rbp-0x31c8]
  4349c9:	mov    QWORD PTR [r10],r11
  4349cc:	mov    r10,rdi
  4349cf:	movabs r11,0x172
  4349d9:	mov    QWORD PTR [r10+0x8],r11
  4349dd:	mov    rsi,rdi
  4349e0:	add    rsi,0x10
  4349e7:	mov    QWORD PTR [r12+0x10],rsi
  4349ec:	mov    rdi,r12
  4349ef:	movabs rsi,0x4
  4349f9:	mov    esi,esi
  4349fb:	xor    eax,eax
  4349fd:	call   44a970 <p111_rt_fail>
  434a02:	mov    QWORD PTR [rbp-0x950],rax
  434a09:	mov    r12,QWORD PTR [rbp-0x10]
  434a0d:	mov    rbx,QWORD PTR [rbp-0x8]
  434a11:	mov    r13,QWORD PTR [rbp-0x18]
  434a15:	mov    r14,QWORD PTR [rbp-0x20]
  434a19:	mov    r15,QWORD PTR [rbp-0x28]
  434a1d:	mov    rsp,rbp
  434a20:	pop    rbp
  434a21:	ret    
  434a22:	mov    rdi,r12
  434a25:	mov    rsi,QWORD PTR [rbp-0x8a8]
  434a2c:	xor    eax,eax
  434a2e:	call   44a1e0 <p111_rt_sink>
  434a33:	mov    QWORD PTR [rbp-0x8a0],rax
  434a3a:	mov    rdi,r12
  434a3d:	mov    rsi,QWORD PTR [rbp-0x1f78]
  434a44:	xor    eax,eax
  434a46:	call   44a1e0 <p111_rt_sink>
  434a4b:	mov    QWORD PTR [rbp-0x8a0],rax
  434a52:	mov    rdi,r12
  434a55:	mov    rsi,QWORD PTR [rbp-0x1f80]
  434a5c:	xor    eax,eax
  434a5e:	call   44a1e0 <p111_rt_sink>
  434a63:	mov    QWORD PTR [rbp-0x8a0],rax
  434a6a:	mov    rdi,r12
  434a6d:	mov    rsi,QWORD PTR [rbp-0x1f88]
  434a74:	xor    eax,eax
  434a76:	call   44a1e0 <p111_rt_sink>
  434a7b:	mov    QWORD PTR [rbp-0x8a0],rax
  434a82:	mov    rdi,r12
  434a85:	mov    rsi,QWORD PTR [rbp-0x31a8]
  434a8c:	xor    eax,eax
  434a8e:	call   44a1e0 <p111_rt_sink>
  434a93:	mov    QWORD PTR [rbp-0x8a0],rax
  434a9a:	mov    rdi,r12
  434a9d:	mov    rsi,QWORD PTR [rbp-0x31b0]
  434aa4:	xor    eax,eax
  434aa6:	call   44a1e0 <p111_rt_sink>
  434aab:	mov    QWORD PTR [rbp-0x8a0],rax
  434ab2:	mov    rdi,r12
  434ab5:	mov    rsi,QWORD PTR [rbp-0x31b8]
  434abc:	xor    eax,eax
  434abe:	call   44a1e0 <p111_rt_sink>
  434ac3:	mov    QWORD PTR [rbp-0x8a0],rax
  434aca:	lea    r10,[rbp-0x830]
  434ad1:	mov    r11,r14
  434ad4:	mov    QWORD PTR [r10],r11
  434ad7:	mov    rdi,QWORD PTR [r12+0x10]
  434adc:	mov    QWORD PTR [rdi],r14
  434adf:	mov    r10,rdi
  434ae2:	movabs r11,0x173
  434aec:	mov    QWORD PTR [r10+0x8],r11
  434af0:	mov    rsi,rdi
  434af3:	add    rsi,0x10
  434afa:	mov    QWORD PTR [r12+0x10],rsi
  434aff:	mov    rdi,r12
  434b02:	movabs rsi,0x4
  434b0c:	mov    esi,esi
  434b0e:	xor    eax,eax
  434b10:	call   44a970 <p111_rt_fail>
  434b15:	mov    QWORD PTR [rbp-0x950],rax
  434b1c:	mov    r12,QWORD PTR [rbp-0x10]
  434b20:	mov    rbx,QWORD PTR [rbp-0x8]
  434b24:	mov    r13,QWORD PTR [rbp-0x18]
  434b28:	mov    r14,QWORD PTR [rbp-0x20]
  434b2c:	mov    r15,QWORD PTR [rbp-0x28]
  434b30:	mov    rsp,rbp
  434b33:	pop    rbp
  434b34:	ret    
  434b35:	mov    rdi,r12
  434b38:	mov    rsi,QWORD PTR [rbp-0x8a8]
  434b3f:	xor    eax,eax
  434b41:	call   44a1e0 <p111_rt_sink>
  434b46:	mov    QWORD PTR [rbp-0x8a0],rax
  434b4d:	mov    rdi,r12
  434b50:	mov    rsi,QWORD PTR [rbp-0x1f78]
  434b57:	xor    eax,eax
  434b59:	call   44a1e0 <p111_rt_sink>
  434b5e:	mov    QWORD PTR [rbp-0x8a0],rax
  434b65:	mov    rdi,r12
  434b68:	mov    rsi,QWORD PTR [rbp-0x1f80]
  434b6f:	xor    eax,eax
  434b71:	call   44a1e0 <p111_rt_sink>
  434b76:	mov    QWORD PTR [rbp-0x8a0],rax
  434b7d:	mov    rdi,r12
  434b80:	mov    rsi,QWORD PTR [rbp-0x1f88]
  434b87:	xor    eax,eax
  434b89:	call   44a1e0 <p111_rt_sink>
  434b8e:	mov    QWORD PTR [rbp-0x8a0],rax
  434b95:	lea    r10,[rbp-0x830]
  434b9c:	mov    r11,r14
  434b9f:	mov    QWORD PTR [r10],r11
  434ba2:	mov    rdi,QWORD PTR [r12+0x10]
  434ba7:	mov    QWORD PTR [rdi],r14
  434baa:	mov    r10,rdi
  434bad:	movabs r11,0x174
  434bb7:	mov    QWORD PTR [r10+0x8],r11
  434bbb:	mov    rsi,rdi
  434bbe:	add    rsi,0x10
  434bc5:	mov    QWORD PTR [r12+0x10],rsi
  434bca:	lea    r10,[rbp-0x830]
  434bd1:	mov    r11,QWORD PTR [rbp-0x8b8]
  434bd8:	mov    QWORD PTR [r10],r11
  434bdb:	mov    rdi,QWORD PTR [r12+0x10]
  434be0:	mov    r10,rdi
  434be3:	mov    r11,QWORD PTR [rbp-0x8b8]
  434bea:	mov    QWORD PTR [r10],r11
  434bed:	mov    r10,rdi
  434bf0:	movabs r11,0x175
  434bfa:	mov    QWORD PTR [r10+0x8],r11
  434bfe:	mov    rsi,rdi
  434c01:	add    rsi,0x10
  434c08:	mov    QWORD PTR [r12+0x10],rsi
  434c0d:	mov    rdi,r12
  434c10:	movabs rsi,0x4
  434c1a:	mov    esi,esi
  434c1c:	xor    eax,eax
  434c1e:	call   44a970 <p111_rt_fail>
  434c23:	mov    QWORD PTR [rbp-0x950],rax
  434c2a:	mov    r12,QWORD PTR [rbp-0x10]
  434c2e:	mov    rbx,QWORD PTR [rbp-0x8]
  434c32:	mov    r13,QWORD PTR [rbp-0x18]
  434c36:	mov    r14,QWORD PTR [rbp-0x20]
  434c3a:	mov    r15,QWORD PTR [rbp-0x28]
  434c3e:	mov    rsp,rbp
  434c41:	pop    rbp
  434c42:	ret    
  434c43:	mov    rdi,r12
  434c46:	mov    rsi,QWORD PTR [rbp-0x8a8]
  434c4d:	xor    eax,eax
  434c4f:	call   44a1e0 <p111_rt_sink>
  434c54:	mov    QWORD PTR [rbp-0x8a0],rax
  434c5b:	lea    r10,[rbp-0x830]
  434c62:	mov    r11,r14
  434c65:	mov    QWORD PTR [r10],r11
  434c68:	mov    rdi,QWORD PTR [r12+0x10]
  434c6d:	mov    QWORD PTR [rdi],r14
  434c70:	mov    r10,rdi
  434c73:	movabs r11,0x176
  434c7d:	mov    QWORD PTR [r10+0x8],r11
  434c81:	mov    rsi,rdi
  434c84:	add    rsi,0x10
  434c8b:	mov    QWORD PTR [r12+0x10],rsi
  434c90:	lea    r10,[rbp-0x830]
  434c97:	mov    r11,QWORD PTR [rbp-0x8b8]
  434c9e:	mov    QWORD PTR [r10],r11
  434ca1:	mov    rdi,QWORD PTR [r12+0x10]
  434ca6:	mov    r10,rdi
  434ca9:	mov    r11,QWORD PTR [rbp-0x8b8]
  434cb0:	mov    QWORD PTR [r10],r11
  434cb3:	mov    r10,rdi
  434cb6:	movabs r11,0x177
  434cc0:	mov    QWORD PTR [r10+0x8],r11
  434cc4:	mov    rsi,rdi
  434cc7:	add    rsi,0x10
  434cce:	mov    QWORD PTR [r12+0x10],rsi
  434cd3:	lea    r10,[rbp-0x830]
  434cda:	mov    r11,QWORD PTR [rbp-0x8b0]
  434ce1:	mov    QWORD PTR [r10],r11
  434ce4:	mov    rdi,QWORD PTR [r12+0x10]
  434ce9:	mov    r10,rdi
  434cec:	mov    r11,QWORD PTR [rbp-0x8b0]
  434cf3:	mov    QWORD PTR [r10],r11
  434cf6:	mov    r10,rdi
  434cf9:	movabs r11,0x178
  434d03:	mov    QWORD PTR [r10+0x8],r11
  434d07:	mov    rsi,rdi
  434d0a:	add    rsi,0x10
  434d11:	mov    QWORD PTR [r12+0x10],rsi
  434d16:	mov    rdi,r12
  434d19:	movabs rsi,0x4
  434d23:	mov    esi,esi
  434d25:	xor    eax,eax
  434d27:	call   44a970 <p111_rt_fail>
  434d2c:	mov    QWORD PTR [rbp-0x950],rax
  434d33:	mov    r12,QWORD PTR [rbp-0x10]
  434d37:	mov    rbx,QWORD PTR [rbp-0x8]
  434d3b:	mov    r13,QWORD PTR [rbp-0x18]
  434d3f:	mov    r14,QWORD PTR [rbp-0x20]
  434d43:	mov    r15,QWORD PTR [rbp-0x28]
  434d47:	mov    rsp,rbp
  434d4a:	pop    rbp
  434d4b:	ret    
  434d4c:	mov    r15,r14
  434d4f:	shr    r15,0x28
  434d53:	and    r15,0xffff
  434d5a:	movabs r11,0x8
  434d64:	mov    r13,r15
  434d67:	cmp    r13,r11
  434d6a:	sete   r13b
  434d6e:	movzx  r13d,r13b
  434d72:	mov    r10,r13
  434d75:	test   r10d,r10d
  434d78:	je     434f29 <p111_FID_36_100_105_114_101_99_116_46_77_97_112_46_115_101_101_107_46_103_111_+0x50d5>
  434d7e:	mov    rdi,r12
  434d81:	mov    rsi,r14
  434d84:	lea    rdx,[rbp-0x830]
  434d8b:	xor    eax,eax
  434d8d:	call   44ff80 <p125_rt_take2>
  434d92:	mov    QWORD PTR [rbp-0x8a0],rax
  434d99:	lea    r10,[rbp-0x830]
  434da0:	mov    r10,QWORD PTR [r10]
  434da3:	mov    QWORD PTR [rbp-0x4320],r10
  434daa:	lea    r10,[rbp-0x830]
  434db1:	mov    r10,QWORD PTR [r10+0x8]
  434db5:	mov    QWORD PTR [rbp-0x4328],r10
  434dbc:	mov    rdi,r12
  434dbf:	mov    rsi,QWORD PTR [rbp-0x4328]
  434dc6:	xor    eax,eax
  434dc8:	call   44a1e0 <p111_rt_sink>
  434dcd:	mov    QWORD PTR [rbp-0x8a0],rax
  434dd4:	movabs rdi,0x1000b0000000000
  434dde:	lea    r10,[rbp-0x830]
  434de5:	mov    r11,QWORD PTR [rbp-0x4320]
  434dec:	mov    QWORD PTR [r10],r11
  434def:	lea    r10,[rbp-0x830]
  434df6:	mov    r11,rdi
  434df9:	mov    QWORD PTR [r10+0x8],r11
  434dfd:	mov    rdi,r12
  434e00:	movabs rsi,0x8
  434e0a:	mov    esi,esi
  434e0c:	lea    rdx,[rbp-0x830]
  434e13:	xor    eax,eax
  434e15:	call   44fe90 <p125_rt_ctor2>
  434e1a:	mov    rbx,rax
  434e1d:	mov    rdi,rbx
  434e20:	lea    r10,[rbp-0x830]
  434e27:	mov    r11,QWORD PTR [rbp-0x880]
  434e2e:	mov    QWORD PTR [r10],r11
  434e31:	lea    r10,[rbp-0x830]
  434e38:	mov    r11,rdi
  434e3b:	mov    QWORD PTR [r10+0x8],r11
  434e3f:	mov    rdi,r12
  434e42:	movabs rsi,0x8
  434e4c:	mov    esi,esi
  434e4e:	lea    rdx,[rbp-0x830]
  434e55:	xor    eax,eax
  434e57:	call   44fe90 <p125_rt_ctor2>
  434e5c:	mov    rbx,rax
  434e5f:	lea    r10,[rbp-0x830]
  434e66:	mov    r11,rbx
  434e69:	mov    QWORD PTR [r10],r11
  434e6c:	lea    r10,[rip+0x23d6d]        # 458be0 <p111_program>
  434e73:	movabs rdi,0x4
  434e7d:	and    rdi,QWORD PTR [r10+0x58]
  434e81:	mov    r10,rdi
  434e84:	test   r10d,r10d
  434e87:	je     434ee5 <p111_FID_36_100_105_114_101_99_116_46_77_97_112_46_115_101_101_107_46_103_111_+0x5091>
  434e8d:	lea    r10,[rbp-0x830]
  434e94:	mov    rdi,QWORD PTR [r10]
  434e97:	mov    QWORD PTR [r12+0x28],rdi
  434e9c:	mov    r10,r12
  434e9f:	movabs r11,0x1
  434ea9:	mov    DWORD PTR [r10+0x1c],r11d
  434ead:	mov    rdi,QWORD PTR [r12+0x10]
  434eb2:	movabs r11,0xfffffffffffffff8
  434ebc:	mov    rsi,rdi
  434ebf:	add    rsi,r11
  434ec2:	mov    QWORD PTR [r12+0x10],rsi
  434ec7:	mov    rdi,QWORD PTR [rsi]
  434eca:	mov    DWORD PTR [r12+0x20],edi
  434ecf:	movabs r10,0x0
  434ed9:	mov    QWORD PTR [rbp-0x950],r10
  434ee0:	jmp    434f09 <p111_FID_36_100_105_114_101_99_116_46_77_97_112_46_115_101_101_107_46_103_111_+0x50b5>
  434ee5:	mov    rdi,r12
  434ee8:	lea    rsi,[rbp-0x830]
  434eef:	movabs rdx,0x1
  434ef9:	mov    edx,edx
  434efb:	xor    eax,eax
  434efd:	call   44a800 <p111_rt_return>
  434f02:	mov    QWORD PTR [rbp-0x950],rax
  434f09:	mov    rax,QWORD PTR [rbp-0x950]
  434f10:	mov    r12,QWORD PTR [rbp-0x10]
  434f14:	mov    rbx,QWORD PTR [rbp-0x8]
  434f18:	mov    r13,QWORD PTR [rbp-0x18]
  434f1c:	mov    r14,QWORD PTR [rbp-0x20]
  434f20:	mov    r15,QWORD PTR [rbp-0x28]
  434f24:	mov    rsp,rbp
  434f27:	pop    rbp
  434f28:	ret    
  434f29:	mov    rdi,r12
  434f2c:	mov    rsi,QWORD PTR [rbp-0x880]
  434f33:	xor    eax,eax
  434f35:	call   44a1e0 <p111_rt_sink>
  434f3a:	mov    QWORD PTR [rbp-0x8a0],rax
  434f41:	lea    r10,[rbp-0x830]
  434f48:	mov    r11,r14
  434f4b:	mov    QWORD PTR [r10],r11
  434f4e:	mov    rdi,QWORD PTR [r12+0x10]
  434f53:	mov    QWORD PTR [rdi],r14
  434f56:	mov    r10,rdi
  434f59:	movabs r11,0x179
  434f63:	mov    QWORD PTR [r10+0x8],r11
  434f67:	mov    rsi,rdi
  434f6a:	add    rsi,0x10
  434f71:	mov    QWORD PTR [r12+0x10],rsi
  434f76:	mov    rdi,r12
  434f79:	movabs rsi,0x4
  434f83:	mov    esi,esi
  434f85:	xor    eax,eax
  434f87:	call   44a970 <p111_rt_fail>
  434f8c:	mov    QWORD PTR [rbp-0x950],rax
  434f93:	mov    r12,QWORD PTR [rbp-0x10]
  434f97:	mov    rbx,QWORD PTR [rbp-0x8]
  434f9b:	mov    r13,QWORD PTR [rbp-0x18]
  434f9f:	mov    r14,QWORD PTR [rbp-0x20]
  434fa3:	mov    r15,QWORD PTR [rbp-0x28]
  434fa7:	mov    rsp,rbp
  434faa:	pop    rbp
  434fab:	ret    

