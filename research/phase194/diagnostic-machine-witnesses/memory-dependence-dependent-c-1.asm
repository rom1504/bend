
/home/ai/bend2/build/publish/bend/selfhost/build/phase194/diag-references02/memory-dependence-dependent/c/program:     file format elf64-x86-64


Disassembly of section .text:

000000000000a420 <WL_FID_36_100_105_114_101_99_116_46_112_49_57_52_46_114_101_97_100_95_115_116_101_112_>:
    a420:	push   %rbp
    a421:	sub    $0x10,%rsp
    a425:	movabs $0xffffffff80,%rbx
    a42f:	movabs $0xffff0000000000,%rax
    a439:	and    %rcx,%rax
    a43c:	movabs $0x80000000000,%rsi
    a446:	cmp    %rsi,%rax
    a449:	jne    a6a2 <WL_FID_36_100_105_114_101_99_116_46_112_49_57_52_46_114_101_97_100_95_115_116_101_112_+0x282>
    a44f:	lea    0x7f(%rbx),%rbp
    a453:	mov    %rcx,%rsi
    a456:	and    %rbp,%rsi
    a459:	test   %rcx,%rcx
    a45c:	js     a478 <WL_FID_36_100_105_114_101_99_116_46_112_49_57_52_46_114_101_97_100_95_115_116_101_112_+0x58>
    a45e:	mov    (%r12,%rsi,8),%r10
    a462:	mov    0x8(%r12,%rsi,8),%r9
    a467:	mov    %rsi,%rcx
    a46a:	cmp    $0x3108180,%rcx
    a471:	jae    a4ef <WL_FID_36_100_105_114_101_99_116_46_112_49_57_52_46_114_101_97_100_95_115_116_101_112_+0xcf>
    a473:	jmpq   a526 <WL_FID_36_100_105_114_101_99_116_46_112_49_57_52_46_114_101_97_100_95_115_116_101_112_+0x106>
    a478:	mov    %rcx,%rax
    a47b:	mov    0x4(%r12,%rsi,8),%ecx
    a480:	mov    (%r12,%rsi,8),%edi
    a484:	mov    %edi,%r8d
    a487:	and    $0xffffff,%r8d
    a48e:	cmp    $0x1,%r8d
    a492:	jne    a646 <WL_FID_36_100_105_114_101_99_116_46_112_49_57_52_46_114_101_97_100_95_115_116_101_112_+0x226>
    a498:	mov    (%r12,%rsi,8),%eax
    a49c:	shl    $0x20,%rcx
    a4a0:	or     %rdi,%rcx
    a4a3:	shr    $0x18,%rcx
    a4a7:	mov    (%r12,%rcx,8),%r10
    a4ab:	mov    0x8(%r12,%rcx,8),%r9
    a4b0:	mov    0x0(%r13),%rax
    a4b4:	mov    %rax,(%r12,%rsi,8)
    a4b8:	mov    %rsi,0x0(%r13)
    a4bc:	mov    0x100(%r13),%rax
    a4c3:	inc    %rax
    a4c6:	mov    %rax,0x100(%r13)
    a4cd:	cmpb   $0x1,0x10b83c(%rip)        # 115d10 <KEEP_WORDS>
    a4d4:	jne    a67d <WL_FID_36_100_105_114_101_99_116_46_112_49_57_52_46_114_101_97_100_95_115_116_101_112_+0x25d>
    a4da:	cmp    $0x8000,%rax
    a4e0:	jae    a67d <WL_FID_36_100_105_114_101_99_116_46_112_49_57_52_46_114_101_97_100_95_115_116_101_112_+0x25d>
    a4e6:	cmp    $0x3108180,%rcx
    a4ed:	jb     a526 <WL_FID_36_100_105_114_101_99_116_46_112_49_57_52_46_114_101_97_100_95_115_116_101_112_+0x106>
    a4ef:	mov    0x8(%r13),%rax
    a4f3:	mov    %rax,(%r12,%rcx,8)
    a4f7:	mov    %rcx,0x8(%r13)
    a4fb:	mov    0x108(%r13),%rax
    a502:	add    $0x2,%rax
    a506:	mov    %rax,0x108(%r13)
    a50d:	cmpb   $0x1,0x10b7fc(%rip)        # 115d10 <KEEP_WORDS>
    a514:	jne    a62b <WL_FID_36_100_105_114_101_99_116_46_112_49_57_52_46_114_101_97_100_95_115_116_101_112_+0x20b>
    a51a:	cmp    $0x8000,%rax
    a520:	jae    a62b <WL_FID_36_100_105_114_101_99_116_46_112_49_57_52_46_114_101_97_100_95_115_116_101_112_+0x20b>
    a526:	test   %r9,%r9
    a529:	js     a564 <WL_FID_36_100_105_114_101_99_116_46_112_49_57_52_46_114_101_97_100_95_115_116_101_112_+0x144>
    a52b:	mov    %r9,%rax
    a52e:	shr    $0x39,%rax
    a532:	sete   %al
    a535:	and    %r9,%rbx
    a538:	cmp    $0x3108180,%rbx
    a53f:	setb   %cl
    a542:	or     %al,%cl
    a544:	jne    a57f <WL_FID_36_100_105_114_101_99_116_46_112_49_57_52_46_114_101_97_100_95_115_116_101_112_+0x15f>
    a546:	mov    %r12,%rdi
    a549:	mov    %r13,%rsi
    a54c:	mov    %rdx,%r8
    a54f:	mov    %r9,%rdx
    a552:	mov    $0x2,%ecx
    a557:	callq  122de <rfc_wrap>
    a55c:	mov    %r8,%rdx
    a55f:	mov    %rax,%r9
    a562:	jmp    a57f <WL_FID_36_100_105_114_101_99_116_46_112_49_57_52_46_114_101_97_100_95_115_116_101_112_+0x15f>
    a564:	and    %r9,%rbp
    a567:	mov    $0x1,%eax
    a56c:	lock xadd %eax,(%r12,%rbp,8)
    a572:	not    %eax
    a574:	test   $0xfffffe,%eax
    a579:	je     a6e9 <WL_FID_36_100_105_114_101_99_116_46_112_49_57_52_46_114_101_97_100_95_115_116_101_112_+0x2c9>
    a57f:	mov    0x8(%r13),%rcx
    a583:	test   %rcx,%rcx
    a586:	je     a5f5 <WL_FID_36_100_105_114_101_99_116_46_112_49_57_52_46_114_101_97_100_95_115_116_101_112_+0x1d5>
    a588:	mov    (%r12,%rcx,8),%rax
    a58c:	mov    %rax,0x8(%r13)
    a590:	addq   $0xfffffffffffffffe,0x108(%r13)
    a598:	mov    %r10,(%r12,%rcx,8)
    a59c:	mov    %r9,0x8(%r12,%rcx,8)
    a5a1:	mov    0x8(%r13),%rsi
    a5a5:	test   %rsi,%rsi
    a5a8:	je     a610 <WL_FID_36_100_105_114_101_99_116_46_112_49_57_52_46_114_101_97_100_95_115_116_101_112_+0x1f0>
    a5aa:	mov    (%r12,%rsi,8),%rax
    a5ae:	mov    %rax,0x8(%r13)
    a5b2:	addq   $0xfffffffffffffffe,0x108(%r13)
    a5ba:	movabs $0x200080000000000,%rax
    a5c4:	or     %rax,%rcx
    a5c7:	add    %edx,%r9d
    a5ca:	mov    %rcx,(%r12,%rsi,8)
    a5ce:	mov    %r9,0x8(%r12,%rsi,8)
    a5d3:	or     %rax,%rsi
    a5d6:	mov    -0x8(%r14),%eax
    a5da:	add    $0xfffffffffffffff8,%r14
    a5de:	lea    0x9e5b(%rip),%rcx        # 14440 <wl_tab>
    a5e5:	mov    (%rcx,%rax,8),%rax
    a5e9:	mov    $0x1,%edi
    a5ee:	add    $0x10,%rsp
    a5f2:	pop    %rbp
    a5f3:	jmpq   *%rax
    a5f5:	mov    %r12,%rdi
    a5f8:	mov    %r13,%rsi
    a5fb:	mov    %rdx,%rcx
    a5fe:	mov    $0x1,%edx
    a603:	callq  11fd8 <heap_alloc_miss>
    a608:	mov    %rcx,%rdx
    a60b:	mov    %rax,%rcx
    a60e:	jmp    a598 <WL_FID_36_100_105_114_101_99_116_46_112_49_57_52_46_114_101_97_100_95_115_116_101_112_+0x178>
    a610:	mov    %r12,%rdi
    a613:	mov    %r13,%rsi
    a616:	mov    %rdx,%r8
    a619:	mov    $0x1,%edx
    a61e:	callq  11fd8 <heap_alloc_miss>
    a623:	mov    %r8,%rdx
    a626:	mov    %rax,%rsi
    a629:	jmp    a5ba <WL_FID_36_100_105_114_101_99_116_46_112_49_57_52_46_114_101_97_100_95_115_116_101_112_+0x19a>
    a62b:	mov    %r12,%rdi
    a62e:	mov    %r13,%rsi
    a631:	mov    %rdx,%rax
    a634:	mov    $0x1,%edx
    a639:	callq  11eb1 <heap_hand>
    a63e:	mov    %rax,%rdx
    a641:	jmpq   a526 <WL_FID_36_100_105_114_101_99_116_46_112_49_57_52_46_114_101_97_100_95_115_116_101_112_+0x106>
    a646:	shl    $0x20,%rcx
    a64a:	or     %rdi,%rcx
    a64d:	shr    $0x18,%rcx
    a651:	mov    (%r12,%rcx,8),%r10
    a655:	mov    0x8(%r12,%rcx,8),%r9
    a65a:	mov    %r12,%rdi
    a65d:	mov    %r13,%rsi
    a660:	mov    %rdx,0x8(%rsp)
    a665:	mov    %rax,%rdx
    a668:	mov    $0x2,%r8d
    a66e:	callq  11f42 <span_fade>
    a673:	mov    0x8(%rsp),%rdx
    a678:	jmpq   a526 <WL_FID_36_100_105_114_101_99_116_46_112_49_57_52_46_114_101_97_100_95_115_116_101_112_+0x106>
    a67d:	mov    %r12,%rdi
    a680:	mov    %r13,%rsi
    a683:	mov    %rdx,%rax
    a686:	xor    %edx,%edx
    a688:	callq  11eb1 <heap_hand>
    a68d:	mov    %rax,%rdx
    a690:	cmp    $0x3108180,%rcx
    a697:	jae    a4ef <WL_FID_36_100_105_114_101_99_116_46_112_49_57_52_46_114_101_97_100_95_115_116_101_112_+0xcf>
    a69d:	jmpq   a526 <WL_FID_36_100_105_114_101_99_116_46_112_49_57_52_46_114_101_97_100_95_115_116_101_112_+0x106>
    a6a2:	movabs $0x7e00000000000000,%rax
    a6ac:	test   %rax,%rcx
    a6af:	sete   %al
    a6b2:	cmp    $0xffffffffffffffff,%rcx
    a6b6:	sete   %sil
    a6ba:	or     %al,%sil
    a6bd:	and    %rcx,%rbx
    a6c0:	cmp    $0x3108180,%rbx
    a6c7:	setb   %al
    a6ca:	or     %sil,%al
    a6cd:	jne    a6dd <WL_FID_36_100_105_114_101_99_116_46_112_49_57_52_46_114_101_97_100_95_115_116_101_112_+0x2bd>
    a6cf:	mov    %rcx,%rdx
    a6d2:	mov    %r12,%rdi
    a6d5:	mov    %r13,%rsi
    a6d8:	callq  6ad0 <term_drop>
    a6dd:	lea    -0x81d4(%rip),%rdi        # 2510 <FID_RESW_T+0x310>
    a6e4:	callq  11e50 <err_fail>
    a6e9:	lea    -0x7c17(%rip),%rdi        # 2ad9 <FID_RESW_T+0x8d9>
    a6f0:	callq  11e50 <err_fail>

Disassembly of section .init:

Disassembly of section .fini:

Disassembly of section .plt:
