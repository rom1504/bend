
/home/ai/bend2/build/publish/bend/selfhost/build/phase111/p125-broad06-coverage-record-aggregation-256-build/program:     file format elf64-x86-64


Disassembly of section .init:

Disassembly of section .plt:

Disassembly of section .text:

0000000000422150 <p111_FID_36_100_105_114_101_99_116_46_77_97_112_46_98_105_116_46_97_116_>:
  422150:	endbr64 
  422154:	push   %rbp
  422155:	mov    %rsp,%rbp
  422158:	sub    $0x800,%rsp
  42215f:	push   %rbx
  422160:	push   %r12
  422162:	mov    0x28(%rdi),%rbx
  422166:	mov    0x30(%rdi),%rsi
  42216a:	mov    %rsi,%rax
  42216d:	shr    $0x28,%rax
  422171:	and    $0xffff,%rax
  422177:	cmp    $0x8,%rax
  42217b:	je     4221bb <p111_FID_36_100_105_114_101_99_116_46_77_97_112_46_98_105_116_46_97_116_+0x6b>
  42217d:	mov    %rsi,%r12
  422180:	mov    %rbx,%rsi
  422183:	mov    %rdi,%rbx
  422186:	callq  42f140 <p111_rt_sink>
  42218b:	mov    %r12,%rsi
  42218e:	mov    %rbx,%rdi
  422191:	mov    %rsi,-0x800(%rbp)
  422198:	mov    0x10(%rdi),%rax
  42219c:	mov    %rsi,(%rax)
  42219f:	movq   $0x281,0x8(%rax)
  4221a7:	add    $0x10,%rax
  4221ab:	mov    %rax,0x10(%rdi)
  4221af:	mov    $0x4,%esi
  4221b4:	callq  42f8d0 <p111_rt_fail>
  4221b9:	jmp    422206 <p111_FID_36_100_105_114_101_99_116_46_77_97_112_46_98_105_116_46_97_116_+0xb6>
  4221bb:	lea    -0x800(%rbp),%rdx
  4221c2:	mov    %rdi,%r12
  4221c5:	callq  4348f0 <p125_rt_take2>
  4221ca:	mov    %r12,%rdi
  4221cd:	mov    -0x800(%rbp),%rcx
  4221d4:	mov    -0x7f8(%rbp),%rax
  4221db:	mov    %rbx,-0x800(%rbp)
  4221e2:	mov    %rcx,-0x7f8(%rbp)
  4221e9:	mov    %rax,-0x7f0(%rbp)
  4221f0:	mov    $0x3,%ecx
  4221f5:	lea    -0x800(%rbp),%rdx
  4221fc:	mov    $0x275,%esi
  422201:	callq  42f700 <p111_rt_jump>
  422206:	pop    %r12
  422208:	pop    %rbx
  422209:	leaveq 
  42220a:	retq   

Disassembly of section .fini:
