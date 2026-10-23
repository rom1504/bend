
/home/ai/bend2/build/publish/bend/selfhost/build/phase111/p125-broad06-coverage-record-aggregation-256-build/program:     file format elf64-x86-64


Disassembly of section .init:

Disassembly of section .plt:

Disassembly of section .text:

0000000000422330 <p111_FID_36_100_105_114_101_99_116_46_77_97_112_46_98_105_116_>:
  422330:	endbr64 
  422334:	push   %rbp
  422335:	mov    %rsp,%rbp
  422338:	sub    $0x800,%rsp
  42233f:	push   %rbx
  422340:	push   %r12
  422342:	mov    0x28(%rdi),%rbx
  422346:	mov    0x30(%rdi),%rax
  42234a:	mov    %rax,-0x800(%rbp)
  422351:	movq   $0x21,-0x7f8(%rbp)
  42235c:	mov    $0x2,%ecx
  422361:	lea    -0x800(%rbp),%rdx
  422368:	mov    $0x46,%esi
  42236d:	mov    %rdi,%r12
  422370:	callq  42f8f0 <p111_rt_op>
  422375:	mov    %r12,%rdi
  422378:	mov    %rbx,-0x800(%rbp)
  42237f:	mov    %rax,-0x7f8(%rbp)
  422386:	mov    $0x2,%ecx
  42238b:	lea    -0x800(%rbp),%rdx
  422392:	mov    $0x280,%esi
  422397:	callq  42f700 <p111_rt_jump>
  42239c:	pop    %r12
  42239e:	pop    %rbx
  42239f:	leaveq 
  4223a0:	retq   

Disassembly of section .fini:
