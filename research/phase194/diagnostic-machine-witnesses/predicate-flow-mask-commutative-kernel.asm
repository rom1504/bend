
/home/ai/bend2/build/publish/bend/selfhost/build/phase194/diag-commutative-build01/predicate-flow-mask/machine/program:     file format elf64-x86-64


Disassembly of section .init:

Disassembly of section .plt:

Disassembly of section .text:

00000000004083ba <p113d_FID_36_100_105_114_101_99_116_46_112_49_57_52_46_107_101_114_110_101_108_>:
  4083ba:	push   %rbp
  4083bb:	mov    %rsp,%rbp
  4083be:	sub    $0x970,%rsp
  4083c5:	mov    %r12,-0x10(%rbp)
  4083c9:	mov    %rbx,-0x8(%rbp)
  4083cd:	mov    %r13,-0x18(%rbp)
  4083d1:	mov    %rdi,%rax
  4083d4:	mov    %rax,%r12
  4083d7:	mov    %rsi,%rax
  4083da:	mov    %rax,%rdi
  4083dd:	mov    %rdx,%rax
  4083e0:	mov    %rax,%rbx
  4083e3:	mov    %rcx,%rax
  4083e6:	mov    %rax,%rsi
  4083e9:	cmp    $0x0,%rdi
  4083f0:	jne    40840a <p113d_FID_36_100_105_114_101_99_116_46_112_49_57_52_46_107_101_114_110_101_108_+0x50>
  4083f6:	mov    %rsi,%rax
  4083f9:	mov    -0x10(%rbp),%r12
  4083fd:	mov    -0x8(%rbp),%rbx
  408401:	mov    -0x18(%rbp),%r13
  408405:	mov    %rbp,%rsp
  408408:	pop    %rbp
  408409:	retq   
  40840a:	mov    %rdi,%r9
  40840d:	sub    $0x1,%r9
  408414:	mov    %ebx,%edi
  408416:	mov    %rdi,%r13
  408419:	add    $0x1,%r13d
  408420:	mov    %esi,%edi
  408422:	and    $0x7,%rdi
  408429:	mov    %rdi,%r10
  40842c:	movabs $0x3,%r11
  408436:	cmp    %r11,%r10
  408439:	movabs $0x1,%rax
  408443:	movabs $0x0,%r11
  40844d:	cmovb  %rax,%r11
  408451:	mov    %r11,%rdi
  408454:	mov    %rdi,%r11
  408457:	movabs $0x0,%rdi
  408461:	sub    %r11d,%edi
  408464:	mov    %rdi,%rdx
  408467:	mov    %esi,%edi
  408469:	imul   $0x3,%edi,%edi
  40846f:	add    $0x1,%edi
  408475:	mov    %rdi,%r8
  408478:	mov    %esi,%edi
  40847a:	mov    %ebx,%ebx
  40847c:	xor    %rbx,%rdi
  40847f:	mov    %rdi,%rsi
  408482:	mov    %r8,%rdi
  408485:	and    %rdx,%rdi
  408488:	mov    %rdi,%r8
  40848b:	movabs $0xffffffff,%r11
  408495:	mov    %rdx,%rdi
  408498:	xor    %r11,%rdi
  40849b:	and    %rsi,%rdi
  40849e:	or     %r8,%rdi
  4084a1:	mov    %r13,%rbx
  4084a4:	mov    %rdi,%rsi
  4084a7:	mov    %r9,%rdi
  4084aa:	jmpq   4083e9 <p113d_FID_36_100_105_114_101_99_116_46_112_49_57_52_46_107_101_114_110_101_108_+0x2f>

Disassembly of section .fini:
