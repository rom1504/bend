
/home/ai/bend2/build/publish/bend/selfhost/build/phase194/diag-selected-build02/predicate-flow-mask/machine/program:     file format elf64-x86-64


Disassembly of section .init:

Disassembly of section .plt:

Disassembly of section .text:

000000000040841a <p113d_FID_36_100_105_114_101_99_116_46_112_49_57_52_46_107_101_114_110_101_108_>:
  40841a:	push   %rbp
  40841b:	mov    %rsp,%rbp
  40841e:	sub    $0x970,%rsp
  408425:	mov    %r12,-0x10(%rbp)
  408429:	mov    %rbx,-0x8(%rbp)
  40842d:	mov    %r13,-0x18(%rbp)
  408431:	mov    %rdi,%rax
  408434:	mov    %rax,%r12
  408437:	mov    %rsi,%rax
  40843a:	mov    %rax,%rdi
  40843d:	mov    %rdx,%rax
  408440:	mov    %rax,%rbx
  408443:	mov    %rcx,%rax
  408446:	mov    %rax,%rsi
  408449:	cmp    $0x0,%rdi
  408450:	jne    40846a <p113d_FID_36_100_105_114_101_99_116_46_112_49_57_52_46_107_101_114_110_101_108_+0x50>
  408456:	mov    %rsi,%rax
  408459:	mov    -0x10(%rbp),%r12
  40845d:	mov    -0x8(%rbp),%rbx
  408461:	mov    -0x18(%rbp),%r13
  408465:	mov    %rbp,%rsp
  408468:	pop    %rbp
  408469:	retq   
  40846a:	mov    %rdi,%r9
  40846d:	sub    $0x1,%r9
  408474:	mov    %ebx,%edi
  408476:	mov    %rdi,%r13
  408479:	add    $0x1,%r13d
  408480:	mov    %esi,%edi
  408482:	and    $0x7,%rdi
  408489:	mov    %rdi,%r10
  40848c:	movabs $0x3,%r11
  408496:	cmp    %r11,%r10
  408499:	movabs $0x1,%rax
  4084a3:	movabs $0x0,%r11
  4084ad:	cmovb  %rax,%r11
  4084b1:	mov    %r11,%rdi
  4084b4:	mov    %rdi,%r11
  4084b7:	movabs $0x0,%rdi
  4084c1:	sub    %r11d,%edi
  4084c4:	mov    %rdi,%rdx
  4084c7:	mov    %esi,%edi
  4084c9:	imul   $0x3,%edi,%edi
  4084cf:	add    $0x1,%edi
  4084d5:	mov    %rdi,%r8
  4084d8:	mov    %esi,%edi
  4084da:	mov    %ebx,%ebx
  4084dc:	xor    %rbx,%rdi
  4084df:	mov    %rdi,%rsi
  4084e2:	mov    %r8,%rdi
  4084e5:	and    %rdx,%rdi
  4084e8:	mov    %rdi,%r8
  4084eb:	movabs $0xffffffff,%r11
  4084f5:	mov    %rdx,%rdi
  4084f8:	xor    %r11,%rdi
  4084fb:	mov    %rdi,%r11
  4084fe:	mov    %rsi,%rdi
  408501:	and    %r11,%rdi
  408504:	mov    %rdi,%r11
  408507:	mov    %r8,%rdi
  40850a:	or     %r11,%rdi
  40850d:	mov    %r13,%rbx
  408510:	mov    %rdi,%rsi
  408513:	mov    %r9,%rdi
  408516:	jmpq   408449 <p113d_FID_36_100_105_114_101_99_116_46_112_49_57_52_46_107_101_114_110_101_108_+0x2f>

Disassembly of section .fini:
