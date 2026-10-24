
/home/ai/bend2/build/publish/bend/selfhost/build/phase111/p137-retain-query-builds01-wide-queries-fused-v02/program:     file format elf64-x86-64


Disassembly of section .init:

Disassembly of section .plt:

Disassembly of section .text:

000000000040a260 <p113d_FID_36_100_105_114_101_99_116_46_112_49_51_55_113_95_105_115_95_97_100_116_>:
  40a260:	endbr64 
  40a264:	push   %rbp
  40a265:	mov    %rsp,%rbp
  40a268:	push   %rbx
  40a269:	push   %r12
  40a26b:	mov    $0x1,%ecx
  40a270:	mov    $0x0,%edx
  40a275:	mov    %rsi,%r12
  40a278:	mov    %rdi,%rbx
  40a27b:	callq  437e00 <p118_rt_borrow_scalar_safe>
  40a280:	mov    %r12,%rsi
  40a283:	mov    %rbx,%rdi
  40a286:	cmp    $0x0,%rax
  40a28a:	jne    40a293 <p113d_FID_36_100_105_114_101_99_116_46_112_49_51_55_113_95_105_115_95_97_100_116_+0x33>
  40a28c:	callq  4099c0 <p113d_FID_36_112_49_50_56_98_111_114_114_111_119_46_111_119_110_101_100_46_112_49_51_55_113_95_105_115_95_97_100_116_>
  40a291:	jmp    40a2af <p113d_FID_36_100_105_114_101_99_116_46_112_49_51_55_113_95_105_115_95_97_100_116_+0x4f>
  40a293:	mov    %rsi,%r12
  40a296:	mov    %rdi,%rbx
  40a299:	callq  409be0 <p113d_FID_36_112_49_49_56_98_111_114_114_111_119_46_114_101_97_100_46_112_49_51_55_113_95_105_115_95_97_100_116_>
  40a29e:	mov    %r12,%rsi
  40a2a1:	mov    %rbx,%rdi
  40a2a4:	mov    %rax,%rbx
  40a2a7:	callq  431fa0 <p111_rt_sink>
  40a2ac:	mov    %rbx,%rax
  40a2af:	pop    %r12
  40a2b1:	pop    %rbx
  40a2b2:	leaveq 
  40a2b3:	retq   

Disassembly of section .fini:
