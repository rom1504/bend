
/home/ai/bend2/build/publish/bend/selfhost/build/phase184/bend-products01/editdist/bend-c/program:     file format elf64-x86-64


Disassembly of section .text:

000000000000a430 <WL_FID_36_100_105_114_101_99_116_46_112_97_105_114_>:
    a430:	push   rbp
    a431:	sub    rsp,0x70
    a435:	mov    rbp,rsi
    a438:	mov    DWORD PTR [rsp+0x28],r15d
    a43d:	mov    QWORD PTR [rsp+0x60],r14
    a442:	inc    ebp
    a444:	mov    rax,QWORD PTR [r13+0x38]
    a448:	test   rax,rax
    a44b:	mov    QWORD PTR [rsp+0x18],r13
    a450:	je     a8dd <WL_FID_36_100_105_114_101_99_116_46_112_97_105_114_+0x4ad>
    a456:	mov    rcx,QWORD PTR [r12+rax*8]
    a45a:	mov    QWORD PTR [r13+0x38],rcx
    a45e:	add    QWORD PTR [r13+0x138],0xffffffffffffff80
    a466:	imul   r14d,ebp,0x9e3779b1
    a46d:	movabs r15,0x400080000000000
    a477:	lea    rdi,[r12+rax*8]
    a47b:	mov    r13,rax
    a47e:	xor    ebx,ebx
    a480:	mov    edx,0x400
    a485:	xor    esi,esi
    a487:	call   15040 <memset@plt>
    a48c:	mov    rcx,r13
    a48f:	or     rcx,r15
    a492:	mov    QWORD PTR [rsp+0x50],rcx
    a497:	shr    rcx,0x28
    a49b:	mov    esi,0xffffffff
    a4a0:	shl    esi,cl
    a4a2:	not    esi
    a4a4:	mov    QWORD PTR [rsp+0x48],r13
    a4a9:	movabs rcx,0xffffffffff
    a4b3:	mov    QWORD PTR [rsp+0x10],rcx
    a4b8:	and    r13,rcx
    a4bb:	lea    rdi,[r12+r13*8]
    a4bf:	nop
    a4c0:	mov    eax,r14d
    a4c3:	shl    eax,0xd
    a4c6:	xor    eax,r14d
    a4c9:	mov    ecx,eax
    a4cb:	shr    ecx,0x11
    a4ce:	xor    ecx,eax
    a4d0:	mov    eax,ecx
    a4d2:	shl    eax,0x5
    a4d5:	xor    eax,ecx
    a4d7:	and    ecx,0x3
    a4da:	mov    edx,ebx
    a4dc:	and    edx,esi
    a4de:	mov    DWORD PTR [rdi+rdx*4],ecx
    a4e1:	mov    ecx,eax
    a4e3:	shl    ecx,0xd
    a4e6:	xor    ecx,eax
    a4e8:	mov    eax,ecx
    a4ea:	shr    eax,0x11
    a4ed:	xor    eax,ecx
    a4ef:	mov    r14d,eax
    a4f2:	shl    r14d,0x5
    a4f6:	xor    r14d,eax
    a4f9:	and    eax,0x3
    a4fc:	lea    ecx,[rbx+0x1]
    a4ff:	and    ecx,esi
    a501:	mov    DWORD PTR [rdi+rcx*4],eax
    a504:	cmp    rbx,0xfe
    a50b:	lea    rbx,[rbx+0x2]
    a50f:	jne    a4c0 <WL_FID_36_100_105_114_101_99_116_46_112_97_105_114_+0x90>
    a511:	mov    QWORD PTR [rsp+0x68],rdi
    a516:	mov    DWORD PTR [rsp+0x2c],esi
    a51a:	mov    rsi,QWORD PTR [rsp+0x18]
    a51f:	mov    r13,QWORD PTR [rsi+0x38]
    a523:	test   r13,r13
    a526:	je     a8f2 <WL_FID_36_100_105_114_101_99_116_46_112_97_105_114_+0x4c2>
    a52c:	mov    rax,QWORD PTR [r12+r13*8]
    a530:	mov    QWORD PTR [rsi+0x38],rax
    a534:	add    QWORD PTR [rsi+0x138],0xffffffffffffff80
    a53c:	mov    QWORD PTR [rsp+0x58],rbp
    a541:	imul   r15d,ebp,0x5d9a1bb9
    a548:	lea    rdi,[r12+r13*8]
    a54c:	xor    r14d,r14d
    a54f:	mov    edx,0x400
    a554:	xor    esi,esi
    a556:	call   15040 <memset@plt>
    a55b:	movabs rdi,0x400080000000000
    a565:	or     rdi,r13
    a568:	mov    rcx,rdi
    a56b:	shr    rcx,0x28
    a56f:	mov    ebx,0xffffffff
    a574:	shl    ebx,cl
    a576:	not    ebx
    a578:	mov    rax,r13
    a57b:	movabs rcx,0xffffffffff
    a585:	and    rax,rcx
    a588:	lea    rbp,[r12+rax*8]
    a58c:	nop    DWORD PTR [rax+0x0]
    a590:	mov    eax,r15d
    a593:	shl    eax,0xd
    a596:	xor    eax,r15d
    a599:	mov    ecx,eax
    a59b:	shr    ecx,0x11
    a59e:	xor    ecx,eax
    a5a0:	mov    eax,ecx
    a5a2:	shl    eax,0x5
    a5a5:	xor    eax,ecx
    a5a7:	and    ecx,0x3
    a5aa:	mov    edx,r14d
    a5ad:	and    edx,ebx
    a5af:	mov    DWORD PTR [rbp+rdx*4+0x0],ecx
    a5b3:	mov    ecx,eax
    a5b5:	shl    ecx,0xd
    a5b8:	xor    ecx,eax
    a5ba:	mov    eax,ecx
    a5bc:	shr    eax,0x11
    a5bf:	xor    eax,ecx
    a5c1:	mov    r15d,eax
    a5c4:	shl    r15d,0x5
    a5c8:	xor    r15d,eax
    a5cb:	and    eax,0x3
    a5ce:	lea    ecx,[r14+0x1]
    a5d2:	and    ecx,ebx
    a5d4:	mov    DWORD PTR [rbp+rcx*4+0x0],eax
    a5d8:	cmp    r14,0xfe
    a5df:	lea    r14,[r14+0x2]
    a5e3:	jne    a590 <WL_FID_36_100_105_114_101_99_116_46_112_97_105_114_+0x160>
    a5e5:	mov    rsi,QWORD PTR [rsp+0x18]
    a5ea:	mov    r15,QWORD PTR [rsi+0x40]
    a5ee:	test   r15,r15
    a5f1:	mov    QWORD PTR [rsp+0x30],rdi
    a5f6:	mov    QWORD PTR [rsp+0x40],r13
    a5fb:	je     a907 <WL_FID_36_100_105_114_101_99_116_46_112_97_105_114_+0x4d7>
    a601:	mov    rax,QWORD PTR [r12+r15*8]
    a605:	mov    QWORD PTR [rsi+0x40],rax
    a609:	add    QWORD PTR [rsi+0x140],0xffffffffffffff00
    a614:	lea    rdi,[r12+r15*8]
    a618:	mov    r13,r12
    a61b:	xor    r12d,r12d
    a61e:	mov    edx,0x800
    a623:	xor    esi,esi
    a625:	call   15040 <memset@plt>
    a62a:	mov    r14,r15
    a62d:	movabs rax,0x400090000000000
    a637:	or     r14,rax
    a63a:	mov    rcx,r14
    a63d:	shr    rcx,0x28
    a641:	mov    eax,0xffffffff
    a646:	shl    eax,cl
    a648:	not    eax
    a64a:	movabs rcx,0xffffffffff
    a654:	and    r15,rcx
    a657:	mov    QWORD PTR [rsp+0x8],r13
    a65c:	lea    rcx,[r15*8+0x0]
    a664:	add    rcx,r13
    a667:	nop    WORD PTR [rax+rax*1+0x0]
    a670:	mov    edx,r12d
    a673:	and    edx,eax
    a675:	mov    DWORD PTR [rcx+rdx*4],r12d
    a679:	cmp    r12,0x100
    a680:	je     a6ac <WL_FID_36_100_105_114_101_99_116_46_112_97_105_114_+0x27c>
    a682:	lea    edx,[r12+0x1]
    a687:	mov    esi,edx
    a689:	and    esi,eax
    a68b:	mov    DWORD PTR [rcx+rsi*4],edx
    a68e:	lea    edx,[r12+0x2]
    a693:	mov    esi,edx
    a695:	and    esi,eax
    a697:	mov    DWORD PTR [rcx+rsi*4],edx
    a69a:	lea    edx,[r12+0x3]
    a69f:	mov    esi,edx
    a6a1:	and    esi,eax
    a6a3:	mov    DWORD PTR [rcx+rsi*4],edx
    a6a6:	add    r12,0x4
    a6aa:	jmp    a670 <WL_FID_36_100_105_114_101_99_116_46_112_97_105_114_+0x240>
    a6ac:	mov    rsi,QWORD PTR [rsp+0x18]
    a6b1:	mov    r15,QWORD PTR [rsi+0x40]
    a6b5:	test   r15,r15
    a6b8:	je     a91c <WL_FID_36_100_105_114_101_99_116_46_112_97_105_114_+0x4ec>
    a6be:	mov    rdi,QWORD PTR [rsp+0x8]
    a6c3:	mov    rax,QWORD PTR [rdi+r15*8]
    a6c7:	mov    QWORD PTR [rsi+0x40],rax
    a6cb:	add    QWORD PTR [rsi+0x140],0xffffffffffffff00
    a6d6:	lea    rdi,[rdi+r15*8]
    a6da:	xor    r12d,r12d
    a6dd:	mov    edx,0x800
    a6e2:	xor    esi,esi
    a6e4:	call   15040 <memset@plt>
    a6e9:	movabs rcx,0x400090000000000
    a6f3:	or     rcx,r15
    a6f6:	mov    eax,0x100
    a6fb:	nop    DWORD PTR [rax+rax*1+0x0]
    a700:	mov    rdi,rcx
    a703:	mov    ecx,r12d
    a706:	lea    r12d,[rcx+0x1]
    a70a:	and    ecx,DWORD PTR [rsp+0x2c]
    a70e:	mov    rdx,QWORD PTR [rsp+0x68]
    a713:	mov    edx,DWORD PTR [rdx+rcx*4]
    a716:	mov    rcx,rdi
    a719:	shr    rcx,0x28
    a71d:	mov    r13d,0xffffffff
    a723:	shl    r13d,cl
    a726:	mov    QWORD PTR [rsp+0x38],rdi
    a72b:	movabs r9,0xffffffffff
    a735:	and    rdi,r9
    a738:	mov    rcx,r14
    a73b:	shr    rcx,0x28
    a73f:	mov    esi,0xffffffff
    a744:	shl    esi,cl
    a746:	mov    r8,QWORD PTR [rsp+0x8]
    a74b:	lea    r15,[r8+rdi*8]
    a74f:	mov    DWORD PTR [r8+rdi*8],r12d
    a753:	not    esi
    a755:	mov    QWORD PTR [rsp+0x20],r14
    a75a:	and    r14,r9
    a75d:	lea    rcx,[r8+r14*8]
    a761:	not    r13d
    a764:	xor    edi,edi
    a766:	nop    WORD PTR cs:[rax+rax*1+0x0]
    a770:	mov    r9d,edi
    a773:	and    r9d,ebx
    a776:	xor    r8d,r8d
    a779:	cmp    DWORD PTR [rbp+r9*4+0x0],edx
    a77e:	setne  r8b
    a782:	mov    r9d,edi
    a785:	and    r9d,esi
    a788:	inc    rdi
    a78b:	mov    r10d,edi
    a78e:	and    r10d,esi
    a791:	mov    r10d,DWORD PTR [rcx+r10*4]
    a795:	lea    r11d,[rdi-0x1]
    a799:	and    r11d,r13d
    a79c:	mov    r11d,DWORD PTR [r15+r11*4]
    a7a0:	inc    r10d
    a7a3:	inc    r11d
    a7a6:	cmp    r10d,r11d
    a7a9:	cmovb  r11d,r10d
    a7ad:	add    r8d,DWORD PTR [rcx+r9*4]
    a7b1:	cmp    r11d,r8d
    a7b4:	cmovb  r8d,r11d
    a7b8:	mov    r9d,edi
    a7bb:	and    r9d,r13d
    a7be:	mov    DWORD PTR [r15+r9*4],r8d
    a7c2:	cmp    rdi,0x100
    a7c9:	jne    a770 <WL_FID_36_100_105_114_101_99_116_46_112_97_105_114_+0x340>
    a7cb:	mov    r14,QWORD PTR [rsp+0x38]
    a7d0:	dec    rax
    a7d3:	mov    rcx,QWORD PTR [rsp+0x20]
    a7d8:	jne    a700 <WL_FID_36_100_105_114_101_99_116_46_112_97_105_114_+0x2d0>
    a7de:	add    QWORD PTR [rsp+0x10],0xffffffffffffff81
    a7e4:	mov    rdx,QWORD PTR [rsp+0x50]
    a7e9:	cmp    rdx,0xffffffffffffffff
    a7ed:	mov    rbp,QWORD PTR [rsp+0x18]
    a7f2:	je     a818 <WL_FID_36_100_105_114_101_99_116_46_112_97_105_114_+0x3e8>
    a7f4:	mov    rax,QWORD PTR [rsp+0x48]
    a7f9:	and    rax,QWORD PTR [rsp+0x10]
    a7fe:	cmp    rax,0x3108180
    a804:	jb     a818 <WL_FID_36_100_105_114_101_99_116_46_112_97_105_114_+0x3e8>
    a806:	mov    rdi,QWORD PTR [rsp+0x8]
    a80b:	mov    rsi,rbp
    a80e:	call   7130 <term_drop>
    a813:	mov    rcx,QWORD PTR [rsp+0x20]
    a818:	cmp    QWORD PTR [rsp+0x30],0xffffffffffffffff
    a81e:	je     a849 <WL_FID_36_100_105_114_101_99_116_46_112_97_105_114_+0x419>
    a820:	mov    rax,QWORD PTR [rsp+0x40]
    a825:	and    rax,QWORD PTR [rsp+0x10]
    a82a:	cmp    rax,0x3108180
    a830:	jb     a849 <WL_FID_36_100_105_114_101_99_116_46_112_97_105_114_+0x419>
    a832:	mov    rdi,QWORD PTR [rsp+0x8]
    a837:	mov    rsi,rbp
    a83a:	mov    rdx,QWORD PTR [rsp+0x30]
    a83f:	call   7130 <term_drop>
    a844:	mov    rcx,QWORD PTR [rsp+0x20]
    a849:	cmp    rcx,0xffffffffffffffff
    a84d:	je     a86f <WL_FID_36_100_105_114_101_99_116_46_112_97_105_114_+0x43f>
    a84f:	mov    rax,rcx
    a852:	and    rax,QWORD PTR [rsp+0x10]
    a857:	cmp    rax,0x3108180
    a85d:	jb     a86f <WL_FID_36_100_105_114_101_99_116_46_112_97_105_114_+0x43f>
    a85f:	mov    rdi,QWORD PTR [rsp+0x8]
    a864:	mov    rsi,rbp
    a867:	mov    rdx,rcx
    a86a:	call   7130 <term_drop>
    a86f:	and    r13d,0x100
    a876:	mov    ebx,DWORD PTR [r15+r13*4]
    a87a:	mov    rdx,QWORD PTR [rsp+0x38]
    a87f:	cmp    rdx,0xffffffffffffffff
    a883:	je     a8a2 <WL_FID_36_100_105_114_101_99_116_46_112_97_105_114_+0x472>
    a885:	mov    rax,QWORD PTR [rsp+0x10]
    a88a:	and    rax,rdx
    a88d:	cmp    rax,0x3108180
    a893:	jb     a8a2 <WL_FID_36_100_105_114_101_99_116_46_112_97_105_114_+0x472>
    a895:	mov    rdi,QWORD PTR [rsp+0x8]
    a89a:	mov    rsi,rbp
    a89d:	call   7130 <term_drop>
    a8a2:	imul   esi,ebx,0x9e3779b1
    a8a8:	xor    esi,DWORD PTR [rsp+0x58]
    a8ac:	mov    r14,QWORD PTR [rsp+0x60]
    a8b1:	mov    eax,DWORD PTR [r14-0x8]
    a8b5:	add    r14,0xfffffffffffffff8
    a8b9:	lea    rcx,[rip+0xb8f0]        # 161b0 <wl_tab>
    a8c0:	mov    rax,QWORD PTR [rcx+rax*8]
    a8c4:	mov    r12,QWORD PTR [rsp+0x8]
    a8c9:	mov    r13,rbp
    a8cc:	mov    r15d,DWORD PTR [rsp+0x28]
    a8d1:	mov    edi,0x1
    a8d6:	add    rsp,0x70
    a8da:	pop    rbp
    a8db:	jmp    rax
    a8dd:	mov    rdi,r12
    a8e0:	mov    rsi,r13
    a8e3:	mov    edx,0x7
    a8e8:	call   13d48 <heap_alloc_miss>
    a8ed:	jmp    a466 <WL_FID_36_100_105_114_101_99_116_46_112_97_105_114_+0x36>
    a8f2:	mov    rdi,r12
    a8f5:	mov    edx,0x7
    a8fa:	call   13d48 <heap_alloc_miss>
    a8ff:	mov    r13,rax
    a902:	jmp    a53c <WL_FID_36_100_105_114_101_99_116_46_112_97_105_114_+0x10c>
    a907:	mov    rdi,r12
    a90a:	mov    edx,0x8
    a90f:	call   13d48 <heap_alloc_miss>
    a914:	mov    r15,rax
    a917:	jmp    a614 <WL_FID_36_100_105_114_101_99_116_46_112_97_105_114_+0x1e4>
    a91c:	mov    rdi,QWORD PTR [rsp+0x8]
    a921:	mov    edx,0x8
    a926:	call   13d48 <heap_alloc_miss>
    a92b:	mov    r15,rax
    a92e:	jmp    a6d6 <WL_FID_36_100_105_114_101_99_116_46_112_97_105_114_+0x2a6>

Disassembly of section .init:

Disassembly of section .fini:

Disassembly of section .plt:
