
/home/ai/bend2/build/publish/bend/selfhost/build/phase194/diag-baseline-build04/value-identity-helpers/machine/program:     file format elf64-x86-64


Disassembly of section .init:

Disassembly of section .plt:

Disassembly of section .text:

0000000000408428 <p113d_FID_36_100_105_114_101_99_116_46_112_49_57_52_46_107_101_114_110_101_108_>:
  408428:	push   %rbp
  408429:	mov    %rsp,%rbp
  40842c:	sub    $0x950,%rsp
  408433:	mov    %r12,-0x10(%rbp)
  408437:	mov    %rbx,-0x8(%rbp)
  40843b:	mov    %rdi,%rax
  40843e:	mov    %rax,%r12
  408441:	mov    %rsi,%rax
  408444:	mov    %rax,%rdi
  408447:	mov    %rdx,%rax
  40844a:	mov    %rax,%rbx
  40844d:	mov    %rcx,%rax
  408450:	mov    %rax,%rsi
  408453:	cmp    $0x0,%rdi
  40845a:	jne    408470 <p113d_FID_36_100_105_114_101_99_116_46_112_49_57_52_46_107_101_114_110_101_108_+0x48>
  408460:	mov    %rsi,%rax
  408463:	mov    -0x10(%rbp),%r12
  408467:	mov    -0x8(%rbp),%rbx
  40846b:	mov    %rbp,%rsp
  40846e:	pop    %rbp
  40846f:	retq   
  408470:	mov    %rdi,%rdx
  408473:	sub    $0x1,%rdx
  40847a:	mov    %ebx,%edi
  40847c:	mov    %rdi,%r8
  40847f:	add    $0x1,%r8d
  408486:	mov    %esi,%edi
  408488:	mov    %ebx,%ebx
  40848a:	add    %ebx,%edi
  40848c:	movabs $0x9e3779b9,%r11
  408496:	xor    %r11,%rdi
  408499:	imul   $0x19660d,%edi,%edi
  40849f:	mov    %esi,%esi
  4084a1:	add    %esi,%edi
  4084a3:	mov    %r8,%rbx
  4084a6:	mov    %rdi,%rsi
  4084a9:	mov    %rdx,%rdi
  4084ac:	jmpq   408453 <p113d_FID_36_100_105_114_101_99_116_46_112_49_57_52_46_107_101_114_110_101_108_+0x2b>

Disassembly of section .fini:
