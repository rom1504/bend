
/home/ai/bend2/build/publish/bend/selfhost/build/phase194/diag-commutative-build01/value-identity-helpers/machine/program:     file format elf64-x86-64


Disassembly of section .init:

Disassembly of section .plt:

Disassembly of section .text:

00000000004083cd <p113d_FID_36_100_105_114_101_99_116_46_112_49_57_52_46_107_101_114_110_101_108_>:
  4083cd:	push   %rbp
  4083ce:	mov    %rsp,%rbp
  4083d1:	sub    $0x950,%rsp
  4083d8:	mov    %r12,-0x10(%rbp)
  4083dc:	mov    %rbx,-0x8(%rbp)
  4083e0:	mov    %rdi,%rax
  4083e3:	mov    %rax,%r12
  4083e6:	mov    %rsi,%rax
  4083e9:	mov    %rax,%rdi
  4083ec:	mov    %rdx,%rax
  4083ef:	mov    %rax,%rbx
  4083f2:	mov    %rcx,%rax
  4083f5:	mov    %rax,%rsi
  4083f8:	cmp    $0x0,%rdi
  4083ff:	jne    408415 <p113d_FID_36_100_105_114_101_99_116_46_112_49_57_52_46_107_101_114_110_101_108_+0x48>
  408405:	mov    %rsi,%rax
  408408:	mov    -0x10(%rbp),%r12
  40840c:	mov    -0x8(%rbp),%rbx
  408410:	mov    %rbp,%rsp
  408413:	pop    %rbp
  408414:	retq   
  408415:	mov    %rdi,%rdx
  408418:	sub    $0x1,%rdx
  40841f:	mov    %ebx,%edi
  408421:	mov    %rdi,%r8
  408424:	add    $0x1,%r8d
  40842b:	mov    %esi,%edi
  40842d:	mov    %ebx,%ebx
  40842f:	add    %ebx,%edi
  408431:	movabs $0x9e3779b9,%r11
  40843b:	xor    %r11,%rdi
  40843e:	imul   $0x19660d,%edi,%edi
  408444:	mov    %esi,%esi
  408446:	add    %esi,%edi
  408448:	mov    %r8,%rbx
  40844b:	mov    %rdi,%rsi
  40844e:	mov    %rdx,%rdi
  408451:	jmpq   4083f8 <p113d_FID_36_100_105_114_101_99_116_46_112_49_57_52_46_107_101_114_110_101_108_+0x2b>

Disassembly of section .fini:
