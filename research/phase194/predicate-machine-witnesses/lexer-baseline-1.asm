
/home/ai/bend2/build/publish/bend/selfhost/build/phase193/budget-native45-02/lexer/machine/program:     file format elf64-x86-64


Disassembly of section .init:

Disassembly of section .plt:

Disassembly of section .text:

000000000040916e <p113d_FID_36_100_105_114_101_99_116_46_99_108_115_>:
  40916e:	push   %rbp
  40916f:	mov    %rsp,%rbp
  409172:	sub    $0x930,%rsp
  409179:	mov    %r12,-0x10(%rbp)
  40917d:	mov    %rdi,%rax
  409180:	mov    %rax,%r12
  409183:	mov    %rsi,%rax
  409186:	mov    %rax,%rsi
  409189:	mov    %esi,%edi
  40918b:	mov    %rdi,%r11
  40918e:	movabs $0x61,%rdi
  409198:	cmp    %r11,%rdi
  40919b:	setbe  %dil
  40919f:	movzbl %dil,%edi
  4091a3:	mov    %rdi,%rdx
  4091a6:	mov    %esi,%edi
  4091a8:	cmp    $0x7a,%rdi
  4091af:	setbe  %dil
  4091b3:	movzbl %dil,%edi
  4091b7:	mov    %rdi,%r8
  4091ba:	mov    %rdx,%rdi
  4091bd:	xor    $0x1,%edi
  4091c3:	mov    %rdi,%rax
  4091c6:	movabs $0x0,%r10
  4091d0:	mov    %r8,%r11
  4091d3:	test   %eax,%eax
  4091d5:	cmovne %r10,%r11
  4091d9:	mov    %r11,%r8
  4091dc:	mov    %r8,%r9
  4091df:	mov    %esi,%edi
  4091e1:	mov    %rdi,%r11
  4091e4:	movabs $0x30,%rdi
  4091ee:	cmp    %r11,%rdi
  4091f1:	setbe  %dil
  4091f5:	movzbl %dil,%edi
  4091f9:	mov    %rdi,%rdx
  4091fc:	mov    %esi,%edi
  4091fe:	cmp    $0x39,%rdi
  409205:	setbe  %dil
  409209:	movzbl %dil,%edi
  40920d:	mov    %rdi,%r8
  409210:	mov    %rdx,%rdi
  409213:	xor    $0x1,%edi
  409219:	mov    %rdi,%rax
  40921c:	movabs $0x0,%r10
  409226:	mov    %r8,%r11
  409229:	test   %eax,%eax
  40922b:	cmovne %r10,%r11
  40922f:	mov    %r11,%rdx
  409232:	mov    %esi,%edi
  409234:	cmp    $0x20,%rdi
  40923b:	sete   %dil
  40923f:	movzbl %dil,%edi
  409243:	mov    %r9,%rsi
  409246:	cmp    $0x1,%rsi
  40924d:	sete   %sil
  409251:	movzbl %sil,%esi
  409255:	mov    %rsi,%r10
  409258:	test   %r10d,%r10d
  40925b:	je     409298 <p113d_FID_36_100_105_114_101_99_116_46_99_108_115_+0x12a>
  409261:	mov    %rdx,%rsi
  409264:	cmp    $0x1,%rsi
  40926b:	sete   %sil
  40926f:	movzbl %sil,%esi
  409273:	mov    %rsi,%rax
  409276:	movabs $0x100a80000000000,%r10
  409280:	movabs $0x100a80000000000,%r11
  40928a:	test   %eax,%eax
  40928c:	cmovne %r10,%r11
  409290:	mov    %r11,%rdi
  409293:	jmpq   4092e7 <p113d_FID_36_100_105_114_101_99_116_46_99_108_115_+0x179>
  409298:	mov    %rdx,%rsi
  40929b:	cmp    $0x1,%rsi
  4092a2:	sete   %sil
  4092a6:	movzbl %sil,%esi
  4092aa:	mov    %rsi,%r10
  4092ad:	test   %r10d,%r10d
  4092b0:	je     4092c5 <p113d_FID_36_100_105_114_101_99_116_46_99_108_115_+0x157>
  4092b6:	movabs $0x100a90000000000,%rdi
  4092c0:	jmpq   4092e7 <p113d_FID_36_100_105_114_101_99_116_46_99_108_115_+0x179>
  4092c5:	mov    %edi,%esi
  4092c7:	mov    %rsi,%rax
  4092ca:	movabs $0x100aa0000000000,%r10
  4092d4:	movabs $0x100ab0000000000,%r11
  4092de:	test   %eax,%eax
  4092e0:	cmovne %r10,%r11
  4092e4:	mov    %r11,%rdi
  4092e7:	mov    %rdi,%rax
  4092ea:	mov    -0x10(%rbp),%r12
  4092ee:	mov    %rbp,%rsp
  4092f1:	pop    %rbp
  4092f2:	retq   

Disassembly of section .fini:
