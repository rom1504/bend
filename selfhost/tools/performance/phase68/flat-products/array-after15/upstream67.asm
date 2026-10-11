
/home/ai/bend2/build/publish/bend/selfhost/build/phase67/native-baseline02/array-upstream/program:     file format elf64-x86-64


Disassembly of section .text:

0000000000008600 <WL_FID_MAIN_C71>:
    8600:	push   %rbp
    8601:	sub    $0x30,%rsp
    8605:	mov    %rsi,%rbx
    8608:	mov    $0x811c9dc5,%r10d
    860e:	mov    $0x811c9dc5,%esi
    8613:	test   %rdx,%rdx
    8616:	je     88b5 <WL_FID_MAIN_C71+0x2b5>
    861c:	mov    %rdx,%rbp
    861f:	mov    %r15d,0xc(%rsp)
    8624:	mov    %rbx,0x10(%rsp)
    8629:	mov    %r14,0x18(%rsp)
    862e:	xor    %ebx,%ebx
    8630:	mov    $0x811c9dc5,%r15d
    8636:	movabs $0xffffffff80,%r10
    8640:	lea    0x7f(%r10),%rax
    8644:	mov    %rax,0x28(%rsp)
    8649:	jmp    866b <WL_FID_MAIN_C71+0x6b>
    864b:	nopl   0x0(%rax,%rax,1)
    8650:	imul   $0x1000193,%r15d,%eax
    8657:	add    %ebx,%r14d
    865a:	mov    %r14d,%r15d
    865d:	xor    %eax,%r15d
    8660:	inc    %ebx
    8662:	test   %rbp,%rbp
    8665:	je     889d <WL_FID_MAIN_C71+0x29d>
    866b:	mov    0x30(%r13),%rax
    866f:	test   %rax,%rax
    8672:	je     8888 <WL_FID_MAIN_C71+0x288>
    8678:	mov    (%r12,%rax,8),%rcx
    867c:	mov    %rcx,0x30(%r13)
    8680:	addq   $0xffffffffffffffc0,0x130(%r13)
    8688:	dec    %rbp
    868b:	mov    %ebx,%ecx
    868d:	and    $0xf,%ecx
    8690:	add    $0x11,%ecx
    8693:	movd   %ecx,%xmm0
    8697:	pshufd $0x0,%xmm0,%xmm0
    869c:	movdqu %xmm0,(%r12,%rax,8)
    86a2:	movdqu %xmm0,0x10(%r12,%rax,8)
    86a9:	movdqu %xmm0,0x20(%r12,%rax,8)
    86b0:	movdqu %xmm0,0x30(%r12,%rax,8)
    86b7:	movdqu %xmm0,0x40(%r12,%rax,8)
    86be:	movdqu %xmm0,0x50(%r12,%rax,8)
    86c5:	movdqu %xmm0,0x60(%r12,%rax,8)
    86cc:	movdqu %xmm0,0x70(%r12,%rax,8)
    86d3:	movdqu %xmm0,0x80(%r12,%rax,8)
    86dd:	movdqu %xmm0,0x90(%r12,%rax,8)
    86e7:	movdqu %xmm0,0xa0(%r12,%rax,8)
    86f1:	movdqu %xmm0,0xb0(%r12,%rax,8)
    86fb:	movdqu %xmm0,0xc0(%r12,%rax,8)
    8705:	movdqu %xmm0,0xd0(%r12,%rax,8)
    870f:	movdqu %xmm0,0xe0(%r12,%rax,8)
    8719:	movdqu %xmm0,0xf0(%r12,%rax,8)
    8723:	movdqu %xmm0,0x100(%r12,%rax,8)
    872d:	movdqu %xmm0,0x110(%r12,%rax,8)
    8737:	movdqu %xmm0,0x120(%r12,%rax,8)
    8741:	movdqu %xmm0,0x130(%r12,%rax,8)
    874b:	movdqu %xmm0,0x140(%r12,%rax,8)
    8755:	movdqu %xmm0,0x150(%r12,%rax,8)
    875f:	movdqu %xmm0,0x160(%r12,%rax,8)
    8769:	movdqu %xmm0,0x170(%r12,%rax,8)
    8773:	movdqu %xmm0,0x180(%r12,%rax,8)
    877d:	movdqu %xmm0,0x190(%r12,%rax,8)
    8787:	movdqu %xmm0,0x1a0(%r12,%rax,8)
    8791:	movdqu %xmm0,0x1b0(%r12,%rax,8)
    879b:	movdqu %xmm0,0x1c0(%r12,%rax,8)
    87a5:	movdqu %xmm0,0x1d0(%r12,%rax,8)
    87af:	movdqu %xmm0,0x1e0(%r12,%rax,8)
    87b9:	movdqu %xmm0,0x1f0(%r12,%rax,8)
    87c3:	mov    %rax,%rdx
    87c6:	movabs $0x400070000000000,%rcx
    87d0:	or     %rcx,%rdx
    87d3:	mov    %rax,%rdi
    87d6:	and    0x28(%rsp),%rdi
    87db:	mov    %rdx,%rcx
    87de:	shr    $0x28,%rcx
    87e2:	mov    $0xffffffff,%esi
    87e7:	shl    %cl,%esi
    87e9:	not    %esi
    87eb:	lea    (%r12,%rdi,8),%rcx
    87ef:	xor    %r14d,%r14d
    87f2:	xor    %edi,%edi
    87f4:	data16 data16 nopw %cs:0x0(%rax,%rax,1)
    8800:	mov    %edi,%r8d
    8803:	and    %esi,%r8d
    8806:	add    (%rcx,%r8,4),%r14d
    880a:	mov    %r14d,%r9d
    880d:	xor    %edi,%r9d
    8810:	mov    %r9d,(%rcx,%r8,4)
    8814:	lea    0x1(%rdi),%r8d
    8818:	mov    %r8d,%r9d
    881b:	and    %esi,%r9d
    881e:	add    (%rcx,%r9,4),%r14d
    8822:	xor    %r14d,%r8d
    8825:	mov    %r8d,(%rcx,%r9,4)
    8829:	add    $0x2,%rdi
    882d:	cmp    $0x1000,%rdi
    8834:	jne    8800 <WL_FID_MAIN_C71+0x200>
    8836:	test   $0x1,%bl
    8839:	je     8847 <WL_FID_MAIN_C71+0x247>
    883b:	and    %edi,%esi
    883d:	add    (%rcx,%rsi,4),%r14d
    8841:	xor    %r14d,%edi
    8844:	mov    %edi,(%rcx,%rsi,4)
    8847:	cmp    $0xffffffffffffffff,%rdx
    884b:	sete   %cl
    884e:	and    %r10,%rax
    8851:	cmp    $0x3108180,%rax
    8857:	setb   %al
    885a:	or     %cl,%al
    885c:	jne    8650 <WL_FID_MAIN_C71+0x50>
    8862:	mov    %r12,%rdi
    8865:	mov    %r13,%rsi
    8868:	mov    %rbp,0x20(%rsp)
    886d:	mov    %r13,%rbp
    8870:	mov    %r10,%r13
    8873:	callq  4c90 <term_drop>
    8878:	mov    %r13,%r10
    887b:	mov    %rbp,%r13
    887e:	mov    0x20(%rsp),%rbp
    8883:	jmpq   8650 <WL_FID_MAIN_C71+0x50>
    8888:	mov    %r12,%rdi
    888b:	mov    %r13,%rsi
    888e:	mov    $0x6,%edx
    8893:	callq  a736 <heap_alloc_miss>
    8898:	jmpq   8688 <WL_FID_MAIN_C71+0x88>
    889d:	mov    %r15d,%esi
    88a0:	mov    $0x811c9dc5,%r10d
    88a6:	mov    0x18(%rsp),%r14
    88ab:	mov    0x10(%rsp),%rbx
    88b0:	mov    0xc(%rsp),%r15d
    88b5:	test   %r15d,%r15d
    88b8:	je     88d3 <WL_FID_MAIN_C71+0x2d3>
    88ba:	mov    %rbx,(%r14)
    88bd:	movq   $0x21,0x8(%r14)
    88c5:	add    $0x10,%r14
    88c9:	add    $0x30,%rsp
    88cd:	pop    %rbp
    88ce:	jmpq   7770 <WL_FID_U32_SHOW>
    88d3:	mov    -0x18(%r14),%r8
    88d7:	mov    -0x10(%r14),%rcx
    88db:	mov    0x10(%r13),%rax
    88df:	test   %rax,%rax
    88e2:	je     8973 <WL_FID_MAIN_C71+0x373>
    88e8:	mov    (%r12,%rax,8),%rdx
    88ec:	mov    %rdx,0x10(%r13)
    88f0:	addq   $0xfffffffffffffffc,0x110(%r13)
    88f8:	movq   $0xffffffffffffffff,0x8(%r12,%rax,8)
    8901:	mov    %r8,0x10(%r12,%rax,8)
    8906:	shl    $0x20,%rcx
    890a:	inc    %rcx
    890d:	mov    %rcx,0x18(%r12,%rax,8)
    8912:	mov    %rbx,(%r12,%rax,8)
    8916:	movabs $0x500210000000000,%rcx
    8920:	or     %rax,%rcx
    8923:	mov    %rcx,-0x18(%r14)
    8927:	movq   $0x1,-0x10(%r14)
    892f:	mov    0x10(%r13),%rax
    8933:	test   %rax,%rax
    8936:	je     898e <WL_FID_MAIN_C71+0x38e>
    8938:	mov    (%r12,%rax,8),%rdx
    893c:	mov    %rdx,0x10(%r13)
    8940:	addq   $0xfffffffffffffffc,0x110(%r13)
    8948:	mov    %rcx,0x8(%r12,%rax,8)
    894d:	add    $0x7ee3623b,%r10
    8954:	mov    %r10,0x10(%r12,%rax,8)
    8959:	mov    %rsi,(%r12,%rax,8)
    895d:	movabs $0x500130000000000,%rcx
    8967:	or     %rax,%rcx
    896a:	mov    %rcx,%rax
    896d:	add    $0x30,%rsp
    8971:	pop    %rbp
    8972:	retq   
    8973:	mov    %r12,%rdi
    8976:	mov    %rsi,%r9
    8979:	mov    %r13,%rsi
    897c:	mov    $0x2,%edx
    8981:	callq  a736 <heap_alloc_miss>
    8986:	mov    %r9,%rsi
    8989:	jmpq   88f8 <WL_FID_MAIN_C71+0x2f8>
    898e:	mov    %r12,%rdi
    8991:	mov    %rsi,%r8
    8994:	mov    %r13,%rsi
    8997:	mov    $0x2,%edx
    899c:	callq  a736 <heap_alloc_miss>
    89a1:	mov    %r8,%rsi
    89a4:	jmp    8948 <WL_FID_MAIN_C71+0x348>

Disassembly of section .init:

Disassembly of section .fini:

Disassembly of section .plt:
