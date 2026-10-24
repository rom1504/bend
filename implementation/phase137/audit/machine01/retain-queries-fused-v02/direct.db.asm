
/home/ai/bend2/build/publish/bend/selfhost/build/phase111/p137-retain-query-builds01-wide-queries-fused-v02/program:     file format elf64-x86-64


Disassembly of section .init:

Disassembly of section .plt:

Disassembly of section .text:

0000000000407490 <p113d_FID_36_100_105_114_101_99_116_46_100_98_>:
  407490:	endbr64 
  407494:	push   %rbp
  407495:	mov    %rsp,%rbp
  407498:	push   %rbx
  407499:	push   %r12
  40749b:	mov    $0x1,%ecx
  4074a0:	mov    $0x0,%edx
  4074a5:	mov    %rsi,%r12
  4074a8:	mov    %rdi,%rbx
  4074ab:	callq  437e00 <p118_rt_borrow_scalar_safe>
  4074b0:	mov    %r12,%rsi
  4074b3:	mov    %rbx,%rdi
  4074b6:	cmp    $0x0,%rax
  4074ba:	jne    4074c3 <p113d_FID_36_100_105_114_101_99_116_46_100_98_+0x33>
  4074bc:	callq  407110 <p113d_FID_36_112_49_50_56_98_111_114_114_111_119_46_111_119_110_101_100_46_100_98_>
  4074c1:	jmp    4074df <p113d_FID_36_100_105_114_101_99_116_46_100_98_+0x4f>
  4074c3:	mov    %rsi,%r12
  4074c6:	mov    %rdi,%rbx
  4074c9:	callq  4072c0 <p113d_FID_36_112_49_49_56_98_111_114_114_111_119_46_114_101_97_100_46_100_98_>
  4074ce:	mov    %r12,%rsi
  4074d1:	mov    %rbx,%rdi
  4074d4:	mov    %rax,%rbx
  4074d7:	callq  431fa0 <p111_rt_sink>
  4074dc:	mov    %rbx,%rax
  4074df:	pop    %r12
  4074e1:	pop    %rbx
  4074e2:	leaveq 
  4074e3:	retq   

Disassembly of section .fini:
