
/home/ai/bend2/build/publish/bend/selfhost/build/phase186/release-native45-acquire01/lexer/phase186-qbe-n2/machine/program:     file format elf64-x86-64


Disassembly of section .init:

Disassembly of section .plt:

Disassembly of section .text:

000000000040c430 <p114r_FID_36_100_105_114_101_99_116_46_103_101_110_>:
  40c430:	endbr64 
  40c434:	push   rbp
  40c435:	mov    rbp,rsp
  40c438:	sub    rsp,0x1800
  40c43f:	push   rbx
  40c440:	push   r12
  40c442:	push   r13
  40c444:	push   r14
  40c446:	mov    r14,rcx
  40c449:	mov    ebx,0x0
  40c44e:	xchg   ax,ax
  40c450:	cs cs cs mov rax,rsi
  40c456:	shr    rax,0x28
  40c45a:	and    rax,0xffff
  40c460:	cmp    rax,0x18
  40c464:	jne    40c475 <p114r_FID_36_100_105_114_101_99_116_46_103_101_110_+0x45>
  40c466:	movabs rax,0x100180000000000
  40c470:	jmp    40c530 <p114r_FID_36_100_105_114_101_99_116_46_103_101_110_+0x100>
  40c475:	cmp    rax,0x19
  40c479:	jne    40c64a <p114r_FID_36_100_105_114_101_99_116_46_103_101_110_+0x21a>
  40c47f:	mov    r13,rdx
  40c482:	lea    rdx,[rbp-0x1800]
  40c489:	mov    r12,rdi
  40c48c:	call   419860 <p125_rt_take2>
  40c491:	mov    rcx,r14
  40c494:	mov    rdx,r13
  40c497:	mov    rdi,r12
  40c49a:	mov    rax,QWORD PTR [rbp-0x1800]
  40c4a1:	mov    rsi,QWORD PTR [rbp-0x17f8]
  40c4a8:	mov    QWORD PTR [rbp-0x1800],rax
  40c4af:	mov    QWORD PTR [rbp-0x1800],rsi
  40c4b6:	mov    QWORD PTR [rbp-0x17f8],rdx
  40c4bd:	mov    QWORD PTR [rbp-0x17f0],rcx
  40c4c4:	mov    QWORD PTR [rbp-0x17e8],rax
  40c4cb:	mov    rax,QWORD PTR [rdi+0x10]
  40c4cf:	mov    QWORD PTR [rax],rsi
  40c4d2:	mov    rsi,QWORD PTR [rbp-0x17f8]
  40c4d9:	mov    QWORD PTR [rax+0x8],rsi
  40c4dd:	mov    rsi,QWORD PTR [rbp-0x17f0]
  40c4e4:	mov    QWORD PTR [rax+0x10],rsi
  40c4e8:	mov    rsi,QWORD PTR [rbp-0x17e8]
  40c4ef:	mov    QWORD PTR [rax+0x18],rsi
  40c4f3:	mov    QWORD PTR [rax+0x20],0x56
  40c4fb:	add    rax,0x28
  40c4ff:	mov    QWORD PTR [rdi+0x10],rax
  40c503:	add    rbx,0x1
  40c507:	mov    QWORD PTR [rbp-0x1800],rdx
  40c50e:	mov    QWORD PTR [rbp-0x17f8],rcx
  40c515:	mov    r12,rdx
  40c518:	mov    rdx,rcx
  40c51b:	mov    rsi,r12
  40c51e:	mov    r12,rdi
  40c521:	call   405360 <p112w_FID_36_100_105_114_101_99_116_46_115_97_108_116_>
  40c526:	mov    rdi,r12
  40c529:	mov    r9,rax
  40c52c:	mov    rax,r9
  40c52f:	nop
  40c530:	cmp    rbx,0x0
  40c534:	je     40c6ae <p114r_FID_36_100_105_114_101_99_116_46_103_101_110_+0x27e>
  40c53a:	mov    rcx,QWORD PTR [rdi+0x10]
  40c53e:	mov    rdx,rcx
  40c541:	add    rdx,0xfffffffffffffff8
  40c545:	mov    QWORD PTR [rdi+0x10],rdx
  40c549:	mov    rsi,QWORD PTR [rcx-0x8]
  40c54d:	cmp    rsi,0x56
  40c551:	sete   r9b
  40c555:	movzx  r9d,r9b
  40c559:	mov    rdx,rcx
  40c55c:	sub    rdx,0x18
  40c560:	mov    r8,rcx
  40c563:	sub    r8,0x10
  40c567:	cmp    r9d,0x0
  40c56b:	jne    40c5c5 <p114r_FID_36_100_105_114_101_99_116_46_103_101_110_+0x195>
  40c56d:	cmp    rsi,0x57
  40c571:	jne    40c5b4 <p114r_FID_36_100_105_114_101_99_116_46_103_101_110_+0x184>
  40c573:	mov    QWORD PTR [rdi+0x10],rdx
  40c577:	mov    rdx,rcx
  40c57a:	sub    rdx,0x18
  40c57e:	mov    rsi,QWORD PTR [rdx]
  40c581:	sub    rcx,0x10
  40c585:	mov    rdx,QWORD PTR [rcx]
  40c588:	mov    QWORD PTR [rbp-0x800],rsi
  40c58f:	mov    QWORD PTR [rbp-0x7f8],rdx
  40c596:	mov    QWORD PTR [rbp-0x7f0],rax
  40c59d:	mov    rcx,rax
  40c5a0:	mov    r12,rdi
  40c5a3:	call   405370 <p112w_FID_36_100_105_114_101_99_116_46_103_101_110_46_97_116_>
  40c5a8:	mov    rdi,r12
  40c5ab:	sub    rbx,0x1
  40c5af:	jmp    40c530 <p114r_FID_36_100_105_114_101_99_116_46_103_101_110_+0x100>
  40c5b4:	cs cs mov esi,0x4
  40c5bb:	call   414250 <p111_rt_fail>
  40c5c0:	jmp    40c6ae <p114r_FID_36_100_105_114_101_99_116_46_103_101_110_+0x27e>
  40c5c5:	mov    r9,rax
  40c5c8:	mov    r12,rcx
  40c5cb:	sub    r12,0x28
  40c5cf:	mov    QWORD PTR [rdi+0x10],r12
  40c5d3:	mov    rsi,QWORD PTR [r12]
  40c5d7:	mov    r10,rcx
  40c5da:	sub    r10,0x20
  40c5de:	mov    rdx,QWORD PTR [r10]
  40c5e1:	mov    rax,rcx
  40c5e4:	sub    rax,0x18
  40c5e8:	mov    rax,QWORD PTR [rax]
  40c5eb:	mov    r11,rcx
  40c5ee:	sub    r11,0x10
  40c5f2:	mov    r11,QWORD PTR [r11]
  40c5f5:	mov    QWORD PTR [rbp-0x1000],r11
  40c5fc:	mov    QWORD PTR [rbp-0xff8],r9
  40c603:	mov    QWORD PTR [r12],r11
  40c607:	mov    QWORD PTR [r10],r9
  40c60a:	sub    rcx,0x18
  40c60e:	mov    QWORD PTR [rcx],0x57
  40c615:	mov    QWORD PTR [rdi+0x10],r8
  40c619:	mov    ecx,0xffffffff
  40c61e:	and    rax,rcx
  40c621:	add    rax,0x1
  40c625:	mov    ecx,0xffffffff
  40c62a:	and    rcx,rax
  40c62d:	mov    QWORD PTR [rbp-0x1000],rsi
  40c634:	mov    QWORD PTR [rbp-0xff8],rdx
  40c63b:	mov    QWORD PTR [rbp-0xff0],rcx
  40c642:	mov    r14,rcx
  40c645:	jmp    40c450 <p114r_FID_36_100_105_114_101_99_116_46_103_101_110_+0x20>
  40c64a:	mov    QWORD PTR [rbp-0x1800],r14
  40c651:	mov    rax,QWORD PTR [rdi+0x10]
  40c655:	mov    QWORD PTR [rax],r14
  40c658:	mov    QWORD PTR [rax+0x8],0x5c
  40c660:	add    rax,0x10
  40c664:	mov    QWORD PTR [rdi+0x10],rax
  40c668:	mov    QWORD PTR [rbp-0x1800],rdx
  40c66f:	mov    rax,QWORD PTR [rdi+0x10]
  40c673:	mov    QWORD PTR [rax],rdx
  40c676:	mov    QWORD PTR [rax+0x8],0x5d
  40c67e:	add    rax,0x10
  40c682:	mov    QWORD PTR [rdi+0x10],rax
  40c686:	mov    QWORD PTR [rbp-0x1800],rsi
  40c68d:	mov    rax,QWORD PTR [rdi+0x10]
  40c691:	mov    QWORD PTR [rax],rsi
  40c694:	mov    QWORD PTR [rax+0x8],0x5e
  40c69c:	add    rax,0x10
  40c6a0:	mov    QWORD PTR [rdi+0x10],rax
  40c6a4:	mov    esi,0x4
  40c6a9:	call   414250 <p111_rt_fail>
  40c6ae:	pop    r14
  40c6b0:	pop    r13
  40c6b2:	pop    r12
  40c6b4:	pop    rbx
  40c6b5:	leave  
  40c6b6:	ret    

Disassembly of section .fini:
