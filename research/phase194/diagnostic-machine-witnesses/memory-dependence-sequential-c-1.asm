
/home/ai/bend2/build/publish/bend/selfhost/build/phase194/diag-references02/memory-dependence-sequential/c/program:     file format elf64-x86-64


Disassembly of section .text:

000000000000a440 <WL_FID_36_100_105_114_101_99_116_46_112_49_57_52_46_114_101_97_100_95_115_116_101_112_>:
    a440:	push   %rax
    a441:	mov    %rdx,%r9
    a444:	movabs $0xffffffff80,%rax
    a44e:	movabs $0xffff0000000000,%rdx
    a458:	and    %rcx,%rdx
    a45b:	movabs $0x80000000000,%rdi
    a465:	cmp    %rdi,%rdx
    a468:	jne    a64b <WL_FID_36_100_105_114_101_99_116_46_112_49_57_52_46_114_101_97_100_95_115_116_101_112_+0x20b>
    a46e:	add    $0x7f,%rax
    a472:	and    %rcx,%rax
    a475:	test   %rcx,%rcx
    a478:	js     a494 <WL_FID_36_100_105_114_101_99_116_46_112_49_57_52_46_114_101_97_100_95_115_116_101_112_+0x54>
    a47a:	mov    (%r12,%rax,8),%rbx
    a47e:	mov    0x8(%r12,%rax,8),%r10
    a483:	mov    %rax,%rcx
    a486:	cmp    $0x3108180,%rcx
    a48d:	jae    a508 <WL_FID_36_100_105_114_101_99_116_46_112_49_57_52_46_114_101_97_100_95_115_116_101_112_+0xc8>
    a48f:	jmpq   a53f <WL_FID_36_100_105_114_101_99_116_46_112_49_57_52_46_114_101_97_100_95_115_116_101_112_+0xff>
    a494:	mov    %rcx,%rdx
    a497:	mov    0x4(%r12,%rax,8),%ecx
    a49c:	mov    (%r12,%rax,8),%edi
    a4a0:	mov    %edi,%ebx
    a4a2:	and    $0xffffff,%ebx
    a4a8:	cmp    $0x1,%ebx
    a4ab:	jne    a5f6 <WL_FID_36_100_105_114_101_99_116_46_112_49_57_52_46_114_101_97_100_95_115_116_101_112_+0x1b6>
    a4b1:	mov    (%r12,%rax,8),%edx
    a4b5:	shl    $0x20,%rcx
    a4b9:	or     %rdi,%rcx
    a4bc:	shr    $0x18,%rcx
    a4c0:	mov    (%r12,%rcx,8),%rbx
    a4c4:	mov    0x8(%r12,%rcx,8),%r10
    a4c9:	mov    0x0(%r13),%rdx
    a4cd:	mov    %rdx,(%r12,%rax,8)
    a4d1:	mov    %rax,0x0(%r13)
    a4d5:	mov    0x100(%r13),%rax
    a4dc:	inc    %rax
    a4df:	mov    %rax,0x100(%r13)
    a4e6:	cmpb   $0x1,0x10b7a3(%rip)        # 115c90 <KEEP_WORDS>
    a4ed:	jne    a626 <WL_FID_36_100_105_114_101_99_116_46_112_49_57_52_46_114_101_97_100_95_115_116_101_112_+0x1e6>
    a4f3:	cmp    $0x8000,%rax
    a4f9:	jae    a626 <WL_FID_36_100_105_114_101_99_116_46_112_49_57_52_46_114_101_97_100_95_115_116_101_112_+0x1e6>
    a4ff:	cmp    $0x3108180,%rcx
    a506:	jb     a53f <WL_FID_36_100_105_114_101_99_116_46_112_49_57_52_46_114_101_97_100_95_115_116_101_112_+0xff>
    a508:	mov    0x8(%r13),%rax
    a50c:	mov    %rax,(%r12,%rcx,8)
    a510:	mov    %rcx,0x8(%r13)
    a514:	mov    0x108(%r13),%rax
    a51b:	add    $0x2,%rax
    a51f:	mov    %rax,0x108(%r13)
    a526:	cmpb   $0x1,0x10b763(%rip)        # 115c90 <KEEP_WORDS>
    a52d:	jne    a5e1 <WL_FID_36_100_105_114_101_99_116_46_112_49_57_52_46_114_101_97_100_95_115_116_101_112_+0x1a1>
    a533:	cmp    $0x8000,%rax
    a539:	jae    a5e1 <WL_FID_36_100_105_114_101_99_116_46_112_49_57_52_46_114_101_97_100_95_115_116_101_112_+0x1a1>
    a53f:	inc    %esi
    a541:	movzbl %sil,%r8d
    a545:	mov    0x8(%r13),%rcx
    a549:	test   %rcx,%rcx
    a54c:	je     a5b7 <WL_FID_36_100_105_114_101_99_116_46_112_49_57_52_46_114_101_97_100_95_115_116_101_112_+0x177>
    a54e:	mov    (%r12,%rcx,8),%rax
    a552:	mov    %rax,0x8(%r13)
    a556:	addq   $0xfffffffffffffffe,0x108(%r13)
    a55e:	mov    %rbx,(%r12,%rcx,8)
    a562:	mov    %r8,0x8(%r12,%rcx,8)
    a567:	mov    0x8(%r13),%rsi
    a56b:	test   %rsi,%rsi
    a56e:	je     a5cc <WL_FID_36_100_105_114_101_99_116_46_112_49_57_52_46_114_101_97_100_95_115_116_101_112_+0x18c>
    a570:	mov    (%r12,%rsi,8),%rax
    a574:	mov    %rax,0x8(%r13)
    a578:	addq   $0xfffffffffffffffe,0x108(%r13)
    a580:	movabs $0x200080000000000,%rax
    a58a:	or     %rax,%rcx
    a58d:	add    %r9d,%r10d
    a590:	mov    %rcx,(%r12,%rsi,8)
    a594:	mov    %r10,0x8(%r12,%rsi,8)
    a599:	or     %rax,%rsi
    a59c:	mov    -0x8(%r14),%eax
    a5a0:	add    $0xfffffffffffffff8,%r14
    a5a4:	lea    0x9e35(%rip),%rcx        # 143e0 <wl_tab>
    a5ab:	mov    (%rcx,%rax,8),%rax
    a5af:	mov    $0x1,%edi
    a5b4:	pop    %rcx
    a5b5:	jmpq   *%rax
    a5b7:	mov    %r12,%rdi
    a5ba:	mov    %r13,%rsi
    a5bd:	mov    $0x1,%edx
    a5c2:	callq  11f78 <heap_alloc_miss>
    a5c7:	mov    %rax,%rcx
    a5ca:	jmp    a55e <WL_FID_36_100_105_114_101_99_116_46_112_49_57_52_46_114_101_97_100_95_115_116_101_112_+0x11e>
    a5cc:	mov    %r12,%rdi
    a5cf:	mov    %r13,%rsi
    a5d2:	mov    $0x1,%edx
    a5d7:	callq  11f78 <heap_alloc_miss>
    a5dc:	mov    %rax,%rsi
    a5df:	jmp    a580 <WL_FID_36_100_105_114_101_99_116_46_112_49_57_52_46_114_101_97_100_95_115_116_101_112_+0x140>
    a5e1:	mov    %r12,%rdi
    a5e4:	mov    %rsi,%rax
    a5e7:	mov    %r13,%rsi
    a5ea:	mov    $0x1,%edx
    a5ef:	callq  11e51 <heap_hand>
    a5f4:	jmp    a61e <WL_FID_36_100_105_114_101_99_116_46_112_49_57_52_46_114_101_97_100_95_115_116_101_112_+0x1de>
    a5f6:	shl    $0x20,%rcx
    a5fa:	or     %rdi,%rcx
    a5fd:	shr    $0x18,%rcx
    a601:	mov    (%r12,%rcx,8),%rbx
    a605:	mov    0x8(%r12,%rcx,8),%r10
    a60a:	mov    %r12,%rdi
    a60d:	mov    %rsi,%rax
    a610:	mov    %r13,%rsi
    a613:	mov    $0x2,%r8d
    a619:	callq  11ee2 <span_fade>
    a61e:	mov    %rax,%rsi
    a621:	jmpq   a53f <WL_FID_36_100_105_114_101_99_116_46_112_49_57_52_46_114_101_97_100_95_115_116_101_112_+0xff>
    a626:	mov    %r12,%rdi
    a629:	mov    %rsi,%rax
    a62c:	mov    %r13,%rsi
    a62f:	xor    %edx,%edx
    a631:	callq  11e51 <heap_hand>
    a636:	mov    %rax,%rsi
    a639:	cmp    $0x3108180,%rcx
    a640:	jae    a508 <WL_FID_36_100_105_114_101_99_116_46_112_49_57_52_46_114_101_97_100_95_115_116_101_112_+0xc8>
    a646:	jmpq   a53f <WL_FID_36_100_105_114_101_99_116_46_112_49_57_52_46_114_101_97_100_95_115_116_101_112_+0xff>
    a64b:	movabs $0x7e00000000000000,%rdx
    a655:	test   %rdx,%rcx
    a658:	sete   %dl
    a65b:	cmp    $0xffffffffffffffff,%rcx
    a65f:	sete   %bl
    a662:	or     %dl,%bl
    a664:	and    %rcx,%rax
    a667:	cmp    $0x3108180,%rax
    a66d:	setb   %al
    a670:	or     %bl,%al
    a672:	jne    a682 <WL_FID_36_100_105_114_101_99_116_46_112_49_57_52_46_114_101_97_100_95_115_116_101_112_+0x242>
    a674:	mov    %rcx,%rdx
    a677:	mov    %r12,%rdi
    a67a:	mov    %r13,%rsi
    a67d:	callq  6ac0 <term_drop>
    a682:	lea    -0x8179(%rip),%rdi        # 2510 <FID_RESW_T+0x310>
    a689:	callq  11df0 <err_fail>

Disassembly of section .init:

Disassembly of section .fini:

Disassembly of section .plt:
