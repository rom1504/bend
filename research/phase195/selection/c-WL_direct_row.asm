
/home/ai/bend2/build/publish/bend/selfhost/build/phase184/bend-products01/editdist/bend-c/program:     file format elf64-x86-64


Disassembly of section .text:

000000000000b500 <WL_FID_36_100_105_114_101_99_116_46_114_111_119_>:
    b500:	push   %rbp
    b501:	sub    $0x40,%rsp
    b505:	mov    %r8,%r9
    b508:	mov    %rcx,%rbx
    b50b:	mov    %rdx,%rcx
    b50e:	mov    %rsi,%rbp
    b511:	mov    %r15d,0xc(%rsp)
    b516:	mov    %r14,0x10(%rsp)
    b51b:	mov    %r13,%r14
    b51e:	lea    0x18(%rsp),%r13
    b523:	data16 data16 data16 nopw %cs:0x0(%rax,%rax,1)
    b530:	sub    $0x1,%rbp
    b534:	jb     b560 <WL_FID_36_100_105_114_101_99_116_46_114_111_119_+0x60>
    b536:	lea    0x1(%rcx),%r15d
    b53a:	mov    %r12,%rdi
    b53d:	mov    %r14,%rsi
    b540:	mov    %r13,%rdx
    b543:	mov    %ebx,%r8d
    b546:	callq  11b00 <NF_FID_99_101_108_108_>
    b54b:	mov    0x18(%rsp),%r9
    b550:	mov    %r15d,%ecx
    b553:	test   %rax,%rax
    b556:	jne    b530 <WL_FID_36_100_105_114_101_99_116_46_114_111_119_+0x30>
    b558:	xor    %eax,%eax
    b55a:	add    $0x40,%rsp
    b55e:	pop    %rbp
    b55f:	retq   
    b560:	movabs $0xffff0000000000,%rax
    b56a:	and    %r9,%rax
    b56d:	movabs $0xa40000000000,%rcx
    b577:	cmp    %rcx,%rax
    b57a:	mov    %r14,%r10
    b57d:	jne    b75a <WL_FID_36_100_105_114_101_99_116_46_114_111_119_+0x25a>
    b583:	movabs $0xffffffff80,%rax
    b58d:	or     $0x7f,%rax
    b591:	and    %r9,%rax
    b594:	test   %r9,%r9
    b597:	js     b5cd <WL_FID_36_100_105_114_101_99_116_46_114_111_119_+0xcd>
    b599:	movups (%r12,%rax,8),%xmm0
    b59e:	movaps %xmm0,0x30(%rsp)
    b5a3:	movups 0x10(%r12,%rax,8),%xmm0
    b5a9:	movaps %xmm0,0x20(%rsp)
    b5ae:	mov    %rax,%rcx
    b5b1:	mov    0xc(%rsp),%r15d
    b5b6:	mov    0x10(%rsp),%r14
    b5bb:	cmp    $0x3108180,%rcx
    b5c2:	jae    b658 <WL_FID_36_100_105_114_101_99_116_46_114_111_119_+0x158>
    b5c8:	jmpq   b687 <WL_FID_36_100_105_114_101_99_116_46_114_111_119_+0x187>
    b5cd:	mov    0x4(%r12,%rax,8),%ecx
    b5d2:	mov    (%r12,%rax,8),%esi
    b5d6:	mov    %esi,%edx
    b5d8:	and    $0xffffff,%edx
    b5de:	cmp    $0x1,%rdx
    b5e2:	jne    b5e8 <WL_FID_36_100_105_114_101_99_116_46_114_111_119_+0xe8>
    b5e4:	mov    (%r12,%rax,8),%edi
    b5e8:	shl    $0x20,%rcx
    b5ec:	or     %rsi,%rcx
    b5ef:	shr    $0x18,%rcx
    b5f3:	movups (%r12,%rcx,8),%xmm0
    b5f8:	movaps %xmm0,0x30(%rsp)
    b5fd:	movups 0x10(%r12,%rcx,8),%xmm0
    b603:	movaps %xmm0,0x20(%rsp)
    b608:	cmp    $0x1,%edx
    b60b:	jne    b70e <WL_FID_36_100_105_114_101_99_116_46_114_111_119_+0x20e>
    b611:	mov    (%r14),%rdx
    b614:	mov    %rdx,(%r12,%rax,8)
    b618:	mov    %rax,(%r14)
    b61b:	mov    0x100(%r14),%rax
    b622:	inc    %rax
    b625:	mov    %rax,0x100(%r14)
    b62c:	cmpb   $0x1,0x10c4dd(%rip)        # 117b10 <KEEP_WORDS>
    b633:	jne    b731 <WL_FID_36_100_105_114_101_99_116_46_114_111_119_+0x231>
    b639:	cmp    $0x8000,%rax
    b63f:	jae    b731 <WL_FID_36_100_105_114_101_99_116_46_114_111_119_+0x231>
    b645:	mov    0xc(%rsp),%r15d
    b64a:	mov    0x10(%rsp),%r14
    b64f:	cmp    $0x3108180,%rcx
    b656:	jb     b687 <WL_FID_36_100_105_114_101_99_116_46_114_111_119_+0x187>
    b658:	mov    0x10(%r10),%rax
    b65c:	mov    %rax,(%r12,%rcx,8)
    b660:	mov    %rcx,0x10(%r10)
    b664:	mov    0x110(%r10),%rax
    b66b:	add    $0x4,%rax
    b66f:	mov    %rax,0x110(%r10)
    b676:	cmpb   $0x1,0x10c493(%rip)        # 117b10 <KEEP_WORDS>
    b67d:	jne    b6f9 <WL_FID_36_100_105_114_101_99_116_46_114_111_119_+0x1f9>
    b67f:	cmp    $0x8000,%rax
    b685:	jae    b6f9 <WL_FID_36_100_105_114_101_99_116_46_114_111_119_+0x1f9>
    b687:	mov    0x10(%r10),%rax
    b68b:	test   %rax,%rax
    b68e:	je     b6e7 <WL_FID_36_100_105_114_101_99_116_46_114_111_119_+0x1e7>
    b690:	mov    (%r12,%rax,8),%rcx
    b694:	mov    %rcx,0x10(%r10)
    b698:	addq   $0xfffffffffffffffc,0x110(%r10)
    b6a0:	movaps 0x30(%rsp),%xmm0
    b6a5:	movups %xmm0,(%r12,%rax,8)
    b6aa:	pshufd $0x4e,0x20(%rsp),%xmm0
    b6b1:	movdqu %xmm0,0x10(%r12,%rax,8)
    b6b8:	movabs $0x200a40000000000,%rsi
    b6c2:	or     %rax,%rsi
    b6c5:	mov    -0x8(%r14),%eax
    b6c9:	add    $0xfffffffffffffff8,%r14
    b6cd:	lea    0xaadc(%rip),%rcx        # 161b0 <wl_tab>
    b6d4:	mov    (%rcx,%rax,8),%rax
    b6d8:	mov    %r10,%r13
    b6db:	mov    $0x1,%edi
    b6e0:	add    $0x40,%rsp
    b6e4:	pop    %rbp
    b6e5:	jmpq   *%rax
    b6e7:	mov    %r12,%rdi
    b6ea:	mov    %r10,%rsi
    b6ed:	mov    $0x2,%edx
    b6f2:	callq  13d48 <heap_alloc_miss>
    b6f7:	jmp    b6a0 <WL_FID_36_100_105_114_101_99_116_46_114_111_119_+0x1a0>
    b6f9:	mov    %r12,%rdi
    b6fc:	mov    %r10,%rsi
    b6ff:	mov    $0x2,%edx
    b704:	callq  13c21 <heap_hand>
    b709:	jmpq   b687 <WL_FID_36_100_105_114_101_99_116_46_114_111_119_+0x187>
    b70e:	mov    %r12,%rdi
    b711:	mov    %r14,%rsi
    b714:	mov    %r9,%rdx
    b717:	mov    $0x4,%r8d
    b71d:	callq  13cb2 <span_fade>
    b722:	mov    0xc(%rsp),%r15d
    b727:	mov    0x10(%rsp),%r14
    b72c:	jmpq   b687 <WL_FID_36_100_105_114_101_99_116_46_114_111_119_+0x187>
    b731:	mov    %r12,%rdi
    b734:	mov    %r14,%rsi
    b737:	xor    %edx,%edx
    b739:	callq  13c21 <heap_hand>
    b73e:	mov    0xc(%rsp),%r15d
    b743:	mov    0x10(%rsp),%r14
    b748:	cmp    $0x3108180,%rcx
    b74f:	jae    b658 <WL_FID_36_100_105_114_101_99_116_46_114_111_119_+0x158>
    b755:	jmpq   b687 <WL_FID_36_100_105_114_101_99_116_46_114_111_119_+0x187>
    b75a:	movabs $0x7e00000000000000,%rax
    b764:	test   %rax,%r9
    b767:	sete   %al
    b76a:	cmp    $0xffffffffffffffff,%r9
    b76e:	sete   %cl
    b771:	or     %al,%cl
    b773:	movabs $0xffffffff80,%rax
    b77d:	and    %r9,%rax
    b780:	cmp    $0x3108180,%rax
    b786:	setb   %al
    b789:	or     %cl,%al
    b78b:	jne    b79b <WL_FID_36_100_105_114_101_99_116_46_114_111_119_+0x29b>
    b78d:	mov    %r12,%rdi
    b790:	mov    %r10,%rsi
    b793:	mov    %r9,%rdx
    b796:	callq  7130 <term_drop>
    b79b:	lea    -0x8f72(%rip),%rdi        # 2830 <FID_RESW_T+0x330>
    b7a2:	callq  13bc0 <err_fail>

Disassembly of section .init:

Disassembly of section .fini:

Disassembly of section .plt:
