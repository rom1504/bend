
/home/ai/bend2/build/publish/bend/selfhost/build/phase111/p114-final-screen01-variation-ray-active-256-2240-build/program:     file format elf64-x86-64


Disassembly of section .init:

Disassembly of section .plt:

Disassembly of section .text:

0000000000405690 <p113d_FID_36_100_105_114_101_99_116_46_105_115_101_99_116_53_>:
  405690:	f3 0f 1e fa          	endbr64 
  405694:	55                   	push   rbp
  405695:	48 89 e5             	mov    rbp,rsp
  405698:	48 81 ec 18 08 00 00 	sub    rsp,0x818
  40569f:	53                   	push   rbx
  4056a0:	41 54                	push   r12
  4056a2:	41 55                	push   r13
  4056a4:	4c 8b 55 30          	mov    r10,QWORD PTR [rbp+0x30]
  4056a8:	4c 8b 5d 28          	mov    r11,QWORD PTR [rbp+0x28]
  4056ac:	48 8b 5d 20          	mov    rbx,QWORD PTR [rbp+0x20]
  4056b0:	4c 8b 65 18          	mov    r12,QWORD PTR [rbp+0x18]
  4056b4:	4c 8b 6d 10          	mov    r13,QWORD PTR [rbp+0x10]
  4056b8:	4c 89 c0             	mov    rax,r8
  4056bb:	4d 89 c8             	mov    r8,r9
  4056be:	4c 89 85 f0 f7 ff ff 	mov    QWORD PTR [rbp-0x810],r8
  4056c5:	48 89 b5 f8 f7 ff ff 	mov    QWORD PTR [rbp-0x808],rsi
  4056cc:	66 49 0f 6e c0       	movq   xmm0,r8
  4056d1:	66 48 0f 6e ce       	movq   xmm1,rsi
  4056d6:	f3 0f 5c c1          	subss  xmm0,xmm1
  4056da:	66 48 0f 7e c6       	movq   rsi,xmm0
  4056df:	41 89 f1             	mov    r9d,esi
  4056e2:	4c 89 ad f0 f7 ff ff 	mov    QWORD PTR [rbp-0x810],r13
  4056e9:	48 89 95 f8 f7 ff ff 	mov    QWORD PTR [rbp-0x808],rdx
  4056f0:	66 49 0f 6e c5       	movq   xmm0,r13
  4056f5:	66 48 0f 6e ca       	movq   xmm1,rdx
  4056fa:	f3 0f 5c c1          	subss  xmm0,xmm1
  4056fe:	66 48 0f 7e c2       	movq   rdx,xmm0
  405703:	41 89 d0             	mov    r8d,edx
  405706:	4c 89 a5 f0 f7 ff ff 	mov    QWORD PTR [rbp-0x810],r12
  40570d:	48 89 8d f8 f7 ff ff 	mov    QWORD PTR [rbp-0x808],rcx
  405714:	66 49 0f 6e c4       	movq   xmm0,r12
  405719:	66 48 0f 6e c9       	movq   xmm1,rcx
  40571e:	f3 0f 5c c1          	subss  xmm0,xmm1
  405722:	66 48 0f 7e c1       	movq   rcx,xmm0
  405727:	89 ce                	mov    esi,ecx
  405729:	4c 89 8d f0 f7 ff ff 	mov    QWORD PTR [rbp-0x810],r9
  405730:	48 89 9d f8 f7 ff ff 	mov    QWORD PTR [rbp-0x808],rbx
  405737:	66 49 0f 6e d9       	movq   xmm3,r9
  40573c:	66 48 0f 6e c3       	movq   xmm0,rbx
  405741:	f3 0f 59 c3          	mulss  xmm0,xmm3
  405745:	66 48 0f 7e c1       	movq   rcx,xmm0
  40574a:	89 ca                	mov    edx,ecx
  40574c:	4c 89 85 f0 f7 ff ff 	mov    QWORD PTR [rbp-0x810],r8
  405753:	4c 89 9d f8 f7 ff ff 	mov    QWORD PTR [rbp-0x808],r11
  40575a:	66 49 0f 6e d0       	movq   xmm2,r8
  40575f:	66 49 0f 6e c3       	movq   xmm0,r11
  405764:	f3 0f 59 c2          	mulss  xmm0,xmm2
  405768:	66 48 0f 7e c1       	movq   rcx,xmm0
  40576d:	89 c9                	mov    ecx,ecx
  40576f:	48 89 95 f0 f7 ff ff 	mov    QWORD PTR [rbp-0x810],rdx
  405776:	48 89 8d f8 f7 ff ff 	mov    QWORD PTR [rbp-0x808],rcx
  40577d:	66 48 0f 6e c2       	movq   xmm0,rdx
  405782:	66 48 0f 6e c9       	movq   xmm1,rcx
  405787:	f3 0f 58 c1          	addss  xmm0,xmm1
  40578b:	66 48 0f 7e c1       	movq   rcx,xmm0
  405790:	89 ca                	mov    edx,ecx
  405792:	48 89 b5 f0 f7 ff ff 	mov    QWORD PTR [rbp-0x810],rsi
  405799:	4c 89 95 f8 f7 ff ff 	mov    QWORD PTR [rbp-0x808],r10
  4057a0:	66 48 0f 6e ce       	movq   xmm1,rsi
  4057a5:	66 49 0f 6e c2       	movq   xmm0,r10
  4057aa:	f3 0f 59 c1          	mulss  xmm0,xmm1
  4057ae:	66 48 0f 7e c1       	movq   rcx,xmm0
  4057b3:	89 c9                	mov    ecx,ecx
  4057b5:	48 89 95 f0 f7 ff ff 	mov    QWORD PTR [rbp-0x810],rdx
  4057bc:	48 89 8d f8 f7 ff ff 	mov    QWORD PTR [rbp-0x808],rcx
  4057c3:	66 48 0f 6e c2       	movq   xmm0,rdx
  4057c8:	66 48 0f 6e e1       	movq   xmm4,rcx
  4057cd:	f3 0f 58 c4          	addss  xmm0,xmm4
  4057d1:	66 48 0f 7e c1       	movq   rcx,xmm0
  4057d6:	89 c9                	mov    ecx,ecx
  4057d8:	48 89 8d f0 f7 ff ff 	mov    QWORD PTR [rbp-0x810],rcx
  4057df:	48 89 8d f8 f7 ff ff 	mov    QWORD PTR [rbp-0x808],rcx
  4057e6:	66 48 0f 6e c1       	movq   xmm0,rcx
  4057eb:	f3 0f 10 e0          	movss  xmm4,xmm0
  4057ef:	f3 0f 59 e0          	mulss  xmm4,xmm0
  4057f3:	66 48 0f 7e e2       	movq   rdx,xmm4
  4057f8:	89 d2                	mov    edx,edx
  4057fa:	4c 89 8d f0 f7 ff ff 	mov    QWORD PTR [rbp-0x810],r9
  405801:	4c 89 8d f8 f7 ff ff 	mov    QWORD PTR [rbp-0x808],r9
  405808:	f3 0f 59 db          	mulss  xmm3,xmm3
  40580c:	66 49 0f 7e d9       	movq   r9,xmm3
  405811:	45 89 c9             	mov    r9d,r9d
  405814:	4c 89 85 f0 f7 ff ff 	mov    QWORD PTR [rbp-0x810],r8
  40581b:	4c 89 85 f8 f7 ff ff 	mov    QWORD PTR [rbp-0x808],r8
  405822:	f3 0f 59 d2          	mulss  xmm2,xmm2
  405826:	66 49 0f 7e d0       	movq   r8,xmm2
  40582b:	45 89 c0             	mov    r8d,r8d
  40582e:	4c 89 8d f0 f7 ff ff 	mov    QWORD PTR [rbp-0x810],r9
  405835:	4c 89 85 f8 f7 ff ff 	mov    QWORD PTR [rbp-0x808],r8
  40583c:	66 49 0f 6e d1       	movq   xmm2,r9
  405841:	66 49 0f 6e d8       	movq   xmm3,r8
  405846:	f3 0f 58 d3          	addss  xmm2,xmm3
  40584a:	66 49 0f 7e d0       	movq   r8,xmm2
  40584f:	45 89 c0             	mov    r8d,r8d
  405852:	48 89 b5 f0 f7 ff ff 	mov    QWORD PTR [rbp-0x810],rsi
  405859:	48 89 b5 f8 f7 ff ff 	mov    QWORD PTR [rbp-0x808],rsi
  405860:	f3 0f 59 c9          	mulss  xmm1,xmm1
  405864:	66 48 0f 7e ce       	movq   rsi,xmm1
  405869:	89 f6                	mov    esi,esi
  40586b:	4c 89 85 f0 f7 ff ff 	mov    QWORD PTR [rbp-0x810],r8
  405872:	48 89 b5 f8 f7 ff ff 	mov    QWORD PTR [rbp-0x808],rsi
  405879:	66 49 0f 6e c8       	movq   xmm1,r8
  40587e:	66 48 0f 6e d6       	movq   xmm2,rsi
  405883:	f3 0f 58 ca          	addss  xmm1,xmm2
  405887:	66 48 0f 7e ce       	movq   rsi,xmm1
  40588c:	89 f6                	mov    esi,esi
  40588e:	48 89 85 f0 f7 ff ff 	mov    QWORD PTR [rbp-0x810],rax
  405895:	48 89 85 f8 f7 ff ff 	mov    QWORD PTR [rbp-0x808],rax
  40589c:	66 48 0f 6e c8       	movq   xmm1,rax
  4058a1:	f3 0f 59 c9          	mulss  xmm1,xmm1
  4058a5:	66 48 0f 7e c8       	movq   rax,xmm1
  4058aa:	89 c0                	mov    eax,eax
  4058ac:	48 89 b5 f0 f7 ff ff 	mov    QWORD PTR [rbp-0x810],rsi
  4058b3:	48 89 85 f8 f7 ff ff 	mov    QWORD PTR [rbp-0x808],rax
  4058ba:	66 48 0f 6e ce       	movq   xmm1,rsi
  4058bf:	66 48 0f 6e d0       	movq   xmm2,rax
  4058c4:	f3 0f 5c ca          	subss  xmm1,xmm2
  4058c8:	66 48 0f 7e c8       	movq   rax,xmm1
  4058cd:	89 c0                	mov    eax,eax
  4058cf:	48 89 95 f0 f7 ff ff 	mov    QWORD PTR [rbp-0x810],rdx
  4058d6:	48 89 85 f8 f7 ff ff 	mov    QWORD PTR [rbp-0x808],rax
  4058dd:	66 48 0f 6e ca       	movq   xmm1,rdx
  4058e2:	66 48 0f 6e d0       	movq   xmm2,rax
  4058e7:	f3 0f 5c ca          	subss  xmm1,xmm2
  4058eb:	66 48 0f 7e c8       	movq   rax,xmm1
  4058f0:	89 c0                	mov    eax,eax
  4058f2:	66 48 0f 6e c8       	movq   xmm1,rax
  4058f7:	f3 0f 10 15 25 a7 02 	movss  xmm2,DWORD PTR [rip+0x2a725]        # 430024 <_IO_stdin_used+0x24>
  4058fe:	00 
  4058ff:	0f 2e d1             	ucomiss xmm2,xmm1
  405902:	0f 97 c2             	seta   dl
  405905:	0f b6 d2             	movzx  edx,dl
  405908:	89 d6                	mov    esi,edx
  40590a:	48 83 fe 01          	cmp    rsi,0x1
  40590e:	0f 94 c2             	sete   dl
  405911:	0f b6 d2             	movzx  edx,dl
  405914:	48 c1 ee 28          	shr    rsi,0x28
  405918:	48 81 e6 ff ff 7f 00 	and    rsi,0x7fffff
  40591f:	48 81 fe 02 00 01 00 	cmp    rsi,0x10002
  405926:	40 0f 94 c6          	sete   sil
  40592a:	40 0f b6 f6          	movzx  esi,sil
  40592e:	09 f2                	or     edx,esi
  405930:	0f 85 d8 00 00 00    	jne    405a0e <p113d_FID_36_100_105_114_101_99_116_46_105_115_101_99_116_53_+0x37e>
  405936:	83 f2 01             	xor    edx,0x1
  405939:	75 14                	jne    40594f <p113d_FID_36_100_105_114_101_99_116_46_105_115_101_99_116_53_+0x2bf>
  40593b:	be 04 00 00 00       	mov    esi,0x4
  405940:	e8 cb 63 02 00       	call   42bd10 <p111_rt_fail>
  405945:	b8 00 00 00 00       	mov    eax,0x0
  40594a:	e9 cc 00 00 00       	jmp    405a1b <p113d_FID_36_100_105_114_101_99_116_46_105_115_101_99_116_53_+0x38b>
  40594f:	48 c7 45 f0 00 00 00 	mov    QWORD PTR [rbp-0x10],0x0
  405956:	00 
  405957:	48 c7 45 f0 00 00 00 	mov    QWORD PTR [rbp-0x10],0x0
  40595e:	00 
  40595f:	48 89 4d f8          	mov    QWORD PTR [rbp-0x8],rcx
  405963:	0f 57 05 a6 a6 02 00 	xorps  xmm0,XMMWORD PTR [rip+0x2a6a6]        # 430010 <_IO_stdin_used+0x10>
  40596a:	f3 0f 58 05 b2 a6 02 	addss  xmm0,DWORD PTR [rip+0x2a6b2]        # 430024 <_IO_stdin_used+0x24>
  405971:	00 
  405972:	66 48 0f 7e c1       	movq   rcx,xmm0
  405977:	89 cb                	mov    ebx,ecx
  405979:	48 89 45 f0          	mov    QWORD PTR [rbp-0x10],rax
  40597d:	b9 01 00 00 00       	mov    ecx,0x1
  405982:	48 8d 55 f0          	lea    rdx,[rbp-0x10]
  405986:	be 24 00 00 00       	mov    esi,0x24
  40598b:	49 89 fc             	mov    r12,rdi
  40598e:	e8 9d 63 02 00       	call   42bd30 <p111_rt_op>
  405993:	4c 89 e7             	mov    rdi,r12
  405996:	48 89 5d f0          	mov    QWORD PTR [rbp-0x10],rbx
  40599a:	48 89 45 f8          	mov    QWORD PTR [rbp-0x8],rax
  40599e:	66 48 0f 6e c3       	movq   xmm0,rbx
  4059a3:	66 48 0f 6e c8       	movq   xmm1,rax
  4059a8:	f3 0f 5c c1          	subss  xmm0,xmm1
  4059ac:	66 48 0f 7e c0       	movq   rax,xmm0
  4059b1:	89 c0                	mov    eax,eax
  4059b3:	66 48 0f 6e c0       	movq   xmm0,rax
  4059b8:	f3 0f 10 0d 68 a6 02 	movss  xmm1,DWORD PTR [rip+0x2a668]        # 430028 <_IO_stdin_used+0x28>
  4059bf:	00 
  4059c0:	0f 2e c8             	ucomiss xmm1,xmm0
  4059c3:	0f 97 c1             	seta   cl
  4059c6:	0f b6 c9             	movzx  ecx,cl
  4059c9:	89 ca                	mov    edx,ecx
  4059cb:	48 83 fa 01          	cmp    rdx,0x1
  4059cf:	0f 94 c1             	sete   cl
  4059d2:	0f b6 c9             	movzx  ecx,cl
  4059d5:	48 c1 ea 28          	shr    rdx,0x28
  4059d9:	48 81 e2 ff ff 7f 00 	and    rdx,0x7fffff
  4059e0:	48 81 fa 02 00 01 00 	cmp    rdx,0x10002
  4059e7:	0f 94 c2             	sete   dl
  4059ea:	0f b6 d2             	movzx  edx,dl
  4059ed:	09 d1                	or     ecx,edx
  4059ef:	75 16                	jne    405a07 <p113d_FID_36_100_105_114_101_99_116_46_105_115_101_99_116_53_+0x377>
  4059f1:	83 f1 01             	xor    ecx,0x1
  4059f4:	75 25                	jne    405a1b <p113d_FID_36_100_105_114_101_99_116_46_105_115_101_99_116_53_+0x38b>
  4059f6:	be 04 00 00 00       	mov    esi,0x4
  4059fb:	e8 10 63 02 00       	call   42bd10 <p111_rt_fail>
  405a00:	b8 00 00 00 00       	mov    eax,0x0
  405a05:	eb 14                	jmp    405a1b <p113d_FID_36_100_105_114_101_99_116_46_105_115_101_99_116_53_+0x38b>
  405a07:	b8 28 6b 6e 4e       	mov    eax,0x4e6e6b28
  405a0c:	eb 0d                	jmp    405a1b <p113d_FID_36_100_105_114_101_99_116_46_105_115_101_99_116_53_+0x38b>
  405a0e:	48 c7 45 f0 00 ca 9a 	mov    QWORD PTR [rbp-0x10],0x3b9aca00
  405a15:	3b 
  405a16:	b8 28 6b 6e 4e       	mov    eax,0x4e6e6b28
  405a1b:	41 5d                	pop    r13
  405a1d:	41 5c                	pop    r12
  405a1f:	5b                   	pop    rbx
  405a20:	c9                   	leave  
  405a21:	c3                   	ret    

Disassembly of section .fini:
