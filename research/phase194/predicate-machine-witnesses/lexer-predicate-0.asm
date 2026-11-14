
/home/ai/bend2/build/publish/bend/selfhost/build/phase194/predicate-dev-build01/lexer/machine/program:     file format elf64-x86-64


Disassembly of section .init:

Disassembly of section .plt:

Disassembly of section .text:

000000000040c351 <p113d_FID_36_112_114_111_100_117_99_116_46_108_101_120_>:
  40c351:	push   %rbp
  40c352:	mov    %rsp,%rbp
  40c355:	sub    $0x9f0,%rsp
  40c35c:	mov    %r12,-0x10(%rbp)
  40c360:	mov    %rbx,-0x8(%rbp)
  40c364:	mov    %r13,-0x18(%rbp)
  40c368:	mov    %r14,-0x20(%rbp)
  40c36c:	mov    %rdi,%rax
  40c36f:	mov    %rax,%r12
  40c372:	mov    %rsi,%rax
  40c375:	mov    %rax,%rsi
  40c378:	mov    %rdx,%rax
  40c37b:	mov    %rax,%rbx
  40c37e:	mov    %rcx,%rax
  40c381:	mov    %rax,%r13
  40c384:	mov    %rsi,%rdi
  40c387:	shr    $0x28,%rdi
  40c38b:	and    $0xffff,%rdi
  40c392:	movabs $0x18,%r11
  40c39c:	cmp    %r11,%rdi
  40c39f:	jne    40c3d0 <p113d_FID_36_112_114_111_100_117_99_116_46_108_101_120_+0x7f>
  40c3a5:	mov    %r12,%rdi
  40c3a8:	mov    %rbx,%rsi
  40c3ab:	mov    %r13,%rdx
  40c3ae:	xor    %eax,%eax
  40c3b0:	callq  409388 <p113d_FID_36_100_105_114_101_99_116_46_102_108_117_115_104_>
  40c3b5:	mov    %rax,%rdi
  40c3b8:	mov    %rdi,%rax
  40c3bb:	mov    -0x10(%rbp),%r12
  40c3bf:	mov    -0x8(%rbp),%rbx
  40c3c3:	mov    -0x18(%rbp),%r13
  40c3c7:	mov    -0x20(%rbp),%r14
  40c3cb:	mov    %rbp,%rsp
  40c3ce:	pop    %rbp
  40c3cf:	retq   
  40c3d0:	mov    %rsi,%rdi
  40c3d3:	shr    $0x28,%rdi
  40c3d7:	and    $0xffff,%rdi
  40c3de:	movabs $0x19,%r11
  40c3e8:	cmp    %r11,%rdi
  40c3eb:	jne    40c665 <p113d_FID_36_112_114_111_100_117_99_116_46_108_101_120_+0x314>
  40c3f1:	mov    %r12,%r10
  40c3f4:	mov    %r10,0x18(%rsp)
  40c3f9:	mov    %rsi,%r10
  40c3fc:	mov    %r10,0x20(%rsp)
  40c401:	lea    -0x840(%rbp),%r10
  40c408:	mov    %r10,0x28(%rsp)
  40c40d:	mov    0x18(%rsp),%rdi
  40c412:	mov    0x20(%rsp),%rsi
  40c417:	mov    0x28(%rsp),%rdx
  40c41c:	xor    %eax,%eax
  40c41e:	callq  421a30 <p125_rt_take2>
  40c423:	mov    %rax,-0x8c0(%rbp)
  40c42a:	lea    -0x840(%rbp),%r10
  40c431:	mov    (%r10),%rdi
  40c434:	lea    -0x840(%rbp),%r10
  40c43b:	mov    0x8(%r10),%r14
  40c43f:	cmp    %rdi,%rdi
  40c442:	jne    40c629 <p113d_FID_36_112_114_111_100_117_99_116_46_108_101_120_+0x2d8>
  40c448:	lea    -0x840(%rbp),%r10
  40c44f:	mov    %rdi,%r11
  40c452:	mov    %r11,(%r10)
  40c455:	mov    %edi,%esi
  40c457:	mov    %rsi,%r11
  40c45a:	movabs $0x61,%rsi
  40c464:	cmp    %r11,%rsi
  40c467:	setbe  %sil
  40c46b:	movzbl %sil,%esi
  40c46f:	mov    %rsi,%rdx
  40c472:	mov    %edi,%esi
  40c474:	cmp    $0x7a,%rsi
  40c47b:	setbe  %sil
  40c47f:	movzbl %sil,%esi
  40c483:	mov    %rsi,%r8
  40c486:	mov    %rdx,%rsi
  40c489:	xor    $0x1,%esi
  40c48f:	mov    %rsi,%rax
  40c492:	movabs $0x0,%r10
  40c49c:	mov    %r8,%r11
  40c49f:	test   %eax,%eax
  40c4a1:	cmovne %r10,%r11
  40c4a5:	mov    %r11,%r8
  40c4a8:	mov    %r8,%r9
  40c4ab:	mov    %edi,%esi
  40c4ad:	mov    %rsi,%r11
  40c4b0:	movabs $0x30,%rsi
  40c4ba:	cmp    %r11,%rsi
  40c4bd:	setbe  %sil
  40c4c1:	movzbl %sil,%esi
  40c4c5:	mov    %rsi,%rdx
  40c4c8:	mov    %edi,%esi
  40c4ca:	cmp    $0x39,%rsi
  40c4d1:	setbe  %sil
  40c4d5:	movzbl %sil,%esi
  40c4d9:	mov    %rsi,%r8
  40c4dc:	mov    %rdx,%rsi
  40c4df:	xor    $0x1,%esi
  40c4e5:	mov    %rsi,%rax
  40c4e8:	movabs $0x0,%r10
  40c4f2:	mov    %r8,%r11
  40c4f5:	test   %eax,%eax
  40c4f7:	cmovne %r10,%r11
  40c4fb:	mov    %r11,%r8
  40c4fe:	mov    %edi,%esi
  40c500:	cmp    $0x20,%rsi
  40c507:	sete   %sil
  40c50b:	movzbl %sil,%esi
  40c50f:	mov    %r9,%rdx
  40c512:	cmp    $0x1,%rdx
  40c519:	sete   %dl
  40c51c:	movzbl %dl,%edx
  40c51f:	mov    %rdx,%r10
  40c522:	test   %r10d,%r10d
  40c525:	je     40c560 <p113d_FID_36_112_114_111_100_117_99_116_46_108_101_120_+0x20f>
  40c52b:	mov    %r8,%rdx
  40c52e:	cmp    $0x1,%rdx
  40c535:	sete   %dl
  40c538:	movzbl %dl,%edx
  40c53b:	mov    %rdx,%rax
  40c53e:	movabs $0x100a80000000000,%r10
  40c548:	movabs $0x100a80000000000,%r11
  40c552:	test   %eax,%eax
  40c554:	cmovne %r10,%r11
  40c558:	mov    %r11,%rsi
  40c55b:	jmpq   40c5ad <p113d_FID_36_112_114_111_100_117_99_116_46_108_101_120_+0x25c>
  40c560:	mov    %r8,%rdx
  40c563:	cmp    $0x1,%rdx
  40c56a:	sete   %dl
  40c56d:	movzbl %dl,%edx
  40c570:	mov    %rdx,%r10
  40c573:	test   %r10d,%r10d
  40c576:	je     40c58b <p113d_FID_36_112_114_111_100_117_99_116_46_108_101_120_+0x23a>
  40c57c:	movabs $0x100a90000000000,%rsi
  40c586:	jmpq   40c5ad <p113d_FID_36_112_114_111_100_117_99_116_46_108_101_120_+0x25c>
  40c58b:	mov    %esi,%edx
  40c58d:	mov    %rdx,%rax
  40c590:	movabs $0x100aa0000000000,%r10
  40c59a:	movabs $0x100ab0000000000,%r11
  40c5a4:	test   %eax,%eax
  40c5a6:	cmovne %r10,%r11
  40c5aa:	mov    %r11,%rsi
  40c5ad:	mov    %r12,%r10
  40c5b0:	mov    %r10,0x30(%rsp)
  40c5b5:	lea    -0x880(%rbp),%r10
  40c5bc:	mov    %r10,0x38(%rsp)
  40c5c1:	mov    %rbx,%r10
  40c5c4:	mov    %r10,0x40(%rsp)
  40c5c9:	mov    %rsi,%r10
  40c5cc:	mov    %r10,0x48(%rsp)
  40c5d1:	mov    %rdi,%r10
  40c5d4:	mov    %r10,0x50(%rsp)
  40c5d9:	mov    %r13,%r10
  40c5dc:	mov    %r10,0x58(%rsp)
  40c5e1:	mov    0x30(%rsp),%rdi
  40c5e6:	mov    0x38(%rsp),%rsi
  40c5eb:	mov    0x40(%rsp),%rdx
  40c5f0:	mov    0x48(%rsp),%rcx
  40c5f5:	mov    0x50(%rsp),%r8
  40c5fa:	mov    0x58(%rsp),%r9
  40c5ff:	xor    %eax,%eax
  40c601:	callq  40b4b3 <p113d_FID_36_112_114_111_100_117_99_116_46_115_116_101_112_46_97_116_>
  40c606:	lea    -0x880(%rbp),%r11
  40c60d:	mov    (%r11),%rax
  40c610:	mov    %rax,%rbx
  40c613:	lea    -0x880(%rbp),%r11
  40c61a:	mov    0x8(%r11),%rax
  40c61e:	mov    %rax,%r13
  40c621:	mov    %r14,%rsi
  40c624:	jmpq   40c384 <p113d_FID_36_112_114_111_100_117_99_116_46_108_101_120_+0x33>
  40c629:	mov    %r12,%rdi
  40c62c:	movabs $0x4,%rsi
  40c636:	mov    %esi,%esi
  40c638:	xor    %eax,%eax
  40c63a:	callq  41c420 <p111_rt_fail>
  40c63f:	mov    %rax,-0x8c0(%rbp)
  40c646:	movabs $0x0,%rax
  40c650:	mov    -0x10(%rbp),%r12
  40c654:	mov    -0x8(%rbp),%rbx
  40c658:	mov    -0x18(%rbp),%r13
  40c65c:	mov    -0x20(%rbp),%r14
  40c660:	mov    %rbp,%rsp
  40c663:	pop    %rbp
  40c664:	retq   
  40c665:	mov    %r12,%rdi
  40c668:	movabs $0x4,%rsi
  40c672:	mov    %esi,%esi
  40c674:	xor    %eax,%eax
  40c676:	callq  41c420 <p111_rt_fail>
  40c67b:	mov    %rax,-0x8c0(%rbp)
  40c682:	movabs $0x0,%rax
  40c68c:	mov    -0x10(%rbp),%r12
  40c690:	mov    -0x8(%rbp),%rbx
  40c694:	mov    -0x18(%rbp),%r13
  40c698:	mov    -0x20(%rbp),%r14
  40c69c:	mov    %rbp,%rsp
  40c69f:	pop    %rbp
  40c6a0:	retq   

Disassembly of section .fini:
