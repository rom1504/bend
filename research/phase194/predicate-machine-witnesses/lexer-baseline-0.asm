
/home/ai/bend2/build/publish/bend/selfhost/build/phase193/budget-native45-02/lexer/machine/program:     file format elf64-x86-64


Disassembly of section .init:

Disassembly of section .plt:

Disassembly of section .text:

000000000040c341 <p113d_FID_36_112_114_111_100_117_99_116_46_108_101_120_>:
  40c341:	push   %rbp
  40c342:	mov    %rsp,%rbp
  40c345:	sub    $0x9f0,%rsp
  40c34c:	mov    %r12,-0x10(%rbp)
  40c350:	mov    %rbx,-0x8(%rbp)
  40c354:	mov    %r13,-0x18(%rbp)
  40c358:	mov    %r14,-0x20(%rbp)
  40c35c:	mov    %rdi,%rax
  40c35f:	mov    %rax,%r12
  40c362:	mov    %rsi,%rax
  40c365:	mov    %rax,%rsi
  40c368:	mov    %rdx,%rax
  40c36b:	mov    %rax,%rbx
  40c36e:	mov    %rcx,%rax
  40c371:	mov    %rax,%r13
  40c374:	mov    %rsi,%rdi
  40c377:	shr    $0x28,%rdi
  40c37b:	and    $0xffff,%rdi
  40c382:	movabs $0x18,%r11
  40c38c:	cmp    %r11,%rdi
  40c38f:	jne    40c3c0 <p113d_FID_36_112_114_111_100_117_99_116_46_108_101_120_+0x7f>
  40c395:	mov    %r12,%rdi
  40c398:	mov    %rbx,%rsi
  40c39b:	mov    %r13,%rdx
  40c39e:	xor    %eax,%eax
  40c3a0:	callq  409380 <p113d_FID_36_100_105_114_101_99_116_46_102_108_117_115_104_>
  40c3a5:	mov    %rax,%rdi
  40c3a8:	mov    %rdi,%rax
  40c3ab:	mov    -0x10(%rbp),%r12
  40c3af:	mov    -0x8(%rbp),%rbx
  40c3b3:	mov    -0x18(%rbp),%r13
  40c3b7:	mov    -0x20(%rbp),%r14
  40c3bb:	mov    %rbp,%rsp
  40c3be:	pop    %rbp
  40c3bf:	retq   
  40c3c0:	mov    %rsi,%rdi
  40c3c3:	shr    $0x28,%rdi
  40c3c7:	and    $0xffff,%rdi
  40c3ce:	movabs $0x19,%r11
  40c3d8:	cmp    %r11,%rdi
  40c3db:	jne    40c655 <p113d_FID_36_112_114_111_100_117_99_116_46_108_101_120_+0x314>
  40c3e1:	mov    %r12,%r10
  40c3e4:	mov    %r10,0x18(%rsp)
  40c3e9:	mov    %rsi,%r10
  40c3ec:	mov    %r10,0x20(%rsp)
  40c3f1:	lea    -0x840(%rbp),%r10
  40c3f8:	mov    %r10,0x28(%rsp)
  40c3fd:	mov    0x18(%rsp),%rdi
  40c402:	mov    0x20(%rsp),%rsi
  40c407:	mov    0x28(%rsp),%rdx
  40c40c:	xor    %eax,%eax
  40c40e:	callq  421a20 <p125_rt_take2>
  40c413:	mov    %rax,-0x8c0(%rbp)
  40c41a:	lea    -0x840(%rbp),%r10
  40c421:	mov    (%r10),%rdi
  40c424:	lea    -0x840(%rbp),%r10
  40c42b:	mov    0x8(%r10),%r14
  40c42f:	cmp    %rdi,%rdi
  40c432:	jne    40c619 <p113d_FID_36_112_114_111_100_117_99_116_46_108_101_120_+0x2d8>
  40c438:	lea    -0x840(%rbp),%r10
  40c43f:	mov    %rdi,%r11
  40c442:	mov    %r11,(%r10)
  40c445:	mov    %edi,%esi
  40c447:	mov    %rsi,%r11
  40c44a:	movabs $0x61,%rsi
  40c454:	cmp    %r11,%rsi
  40c457:	setbe  %sil
  40c45b:	movzbl %sil,%esi
  40c45f:	mov    %rsi,%rdx
  40c462:	mov    %edi,%esi
  40c464:	cmp    $0x7a,%rsi
  40c46b:	setbe  %sil
  40c46f:	movzbl %sil,%esi
  40c473:	mov    %rsi,%r8
  40c476:	mov    %rdx,%rsi
  40c479:	xor    $0x1,%esi
  40c47f:	mov    %rsi,%rax
  40c482:	movabs $0x0,%r10
  40c48c:	mov    %r8,%r11
  40c48f:	test   %eax,%eax
  40c491:	cmovne %r10,%r11
  40c495:	mov    %r11,%r8
  40c498:	mov    %r8,%r9
  40c49b:	mov    %edi,%esi
  40c49d:	mov    %rsi,%r11
  40c4a0:	movabs $0x30,%rsi
  40c4aa:	cmp    %r11,%rsi
  40c4ad:	setbe  %sil
  40c4b1:	movzbl %sil,%esi
  40c4b5:	mov    %rsi,%rdx
  40c4b8:	mov    %edi,%esi
  40c4ba:	cmp    $0x39,%rsi
  40c4c1:	setbe  %sil
  40c4c5:	movzbl %sil,%esi
  40c4c9:	mov    %rsi,%r8
  40c4cc:	mov    %rdx,%rsi
  40c4cf:	xor    $0x1,%esi
  40c4d5:	mov    %rsi,%rax
  40c4d8:	movabs $0x0,%r10
  40c4e2:	mov    %r8,%r11
  40c4e5:	test   %eax,%eax
  40c4e7:	cmovne %r10,%r11
  40c4eb:	mov    %r11,%r8
  40c4ee:	mov    %edi,%esi
  40c4f0:	cmp    $0x20,%rsi
  40c4f7:	sete   %sil
  40c4fb:	movzbl %sil,%esi
  40c4ff:	mov    %r9,%rdx
  40c502:	cmp    $0x1,%rdx
  40c509:	sete   %dl
  40c50c:	movzbl %dl,%edx
  40c50f:	mov    %rdx,%r10
  40c512:	test   %r10d,%r10d
  40c515:	je     40c550 <p113d_FID_36_112_114_111_100_117_99_116_46_108_101_120_+0x20f>
  40c51b:	mov    %r8,%rdx
  40c51e:	cmp    $0x1,%rdx
  40c525:	sete   %dl
  40c528:	movzbl %dl,%edx
  40c52b:	mov    %rdx,%rax
  40c52e:	movabs $0x100a80000000000,%r10
  40c538:	movabs $0x100a80000000000,%r11
  40c542:	test   %eax,%eax
  40c544:	cmovne %r10,%r11
  40c548:	mov    %r11,%rsi
  40c54b:	jmpq   40c59d <p113d_FID_36_112_114_111_100_117_99_116_46_108_101_120_+0x25c>
  40c550:	mov    %r8,%rdx
  40c553:	cmp    $0x1,%rdx
  40c55a:	sete   %dl
  40c55d:	movzbl %dl,%edx
  40c560:	mov    %rdx,%r10
  40c563:	test   %r10d,%r10d
  40c566:	je     40c57b <p113d_FID_36_112_114_111_100_117_99_116_46_108_101_120_+0x23a>
  40c56c:	movabs $0x100a90000000000,%rsi
  40c576:	jmpq   40c59d <p113d_FID_36_112_114_111_100_117_99_116_46_108_101_120_+0x25c>
  40c57b:	mov    %esi,%edx
  40c57d:	mov    %rdx,%rax
  40c580:	movabs $0x100aa0000000000,%r10
  40c58a:	movabs $0x100ab0000000000,%r11
  40c594:	test   %eax,%eax
  40c596:	cmovne %r10,%r11
  40c59a:	mov    %r11,%rsi
  40c59d:	mov    %r12,%r10
  40c5a0:	mov    %r10,0x30(%rsp)
  40c5a5:	lea    -0x880(%rbp),%r10
  40c5ac:	mov    %r10,0x38(%rsp)
  40c5b1:	mov    %rbx,%r10
  40c5b4:	mov    %r10,0x40(%rsp)
  40c5b9:	mov    %rsi,%r10
  40c5bc:	mov    %r10,0x48(%rsp)
  40c5c1:	mov    %rdi,%r10
  40c5c4:	mov    %r10,0x50(%rsp)
  40c5c9:	mov    %r13,%r10
  40c5cc:	mov    %r10,0x58(%rsp)
  40c5d1:	mov    0x30(%rsp),%rdi
  40c5d6:	mov    0x38(%rsp),%rsi
  40c5db:	mov    0x40(%rsp),%rdx
  40c5e0:	mov    0x48(%rsp),%rcx
  40c5e5:	mov    0x50(%rsp),%r8
  40c5ea:	mov    0x58(%rsp),%r9
  40c5ef:	xor    %eax,%eax
  40c5f1:	callq  40b4a3 <p113d_FID_36_112_114_111_100_117_99_116_46_115_116_101_112_46_97_116_>
  40c5f6:	lea    -0x880(%rbp),%r11
  40c5fd:	mov    (%r11),%rax
  40c600:	mov    %rax,%rbx
  40c603:	lea    -0x880(%rbp),%r11
  40c60a:	mov    0x8(%r11),%rax
  40c60e:	mov    %rax,%r13
  40c611:	mov    %r14,%rsi
  40c614:	jmpq   40c374 <p113d_FID_36_112_114_111_100_117_99_116_46_108_101_120_+0x33>
  40c619:	mov    %r12,%rdi
  40c61c:	movabs $0x4,%rsi
  40c626:	mov    %esi,%esi
  40c628:	xor    %eax,%eax
  40c62a:	callq  41c410 <p111_rt_fail>
  40c62f:	mov    %rax,-0x8c0(%rbp)
  40c636:	movabs $0x0,%rax
  40c640:	mov    -0x10(%rbp),%r12
  40c644:	mov    -0x8(%rbp),%rbx
  40c648:	mov    -0x18(%rbp),%r13
  40c64c:	mov    -0x20(%rbp),%r14
  40c650:	mov    %rbp,%rsp
  40c653:	pop    %rbp
  40c654:	retq   
  40c655:	mov    %r12,%rdi
  40c658:	movabs $0x4,%rsi
  40c662:	mov    %esi,%esi
  40c664:	xor    %eax,%eax
  40c666:	callq  41c410 <p111_rt_fail>
  40c66b:	mov    %rax,-0x8c0(%rbp)
  40c672:	movabs $0x0,%rax
  40c67c:	mov    -0x10(%rbp),%r12
  40c680:	mov    -0x8(%rbp),%rbx
  40c684:	mov    -0x18(%rbp),%r13
  40c688:	mov    -0x20(%rbp),%r14
  40c68c:	mov    %rbp,%rsp
  40c68f:	pop    %rbp
  40c690:	retq   

Disassembly of section .fini:
