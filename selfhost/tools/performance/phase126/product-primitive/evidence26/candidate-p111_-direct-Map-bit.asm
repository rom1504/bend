
/home/ai/bend2/build/publish/bend/selfhost/build/phase111/p126-observer26-coverage-record-aggregation-256-build/program:     file format elf64-x86-64


Disassembly of section .init:

Disassembly of section .plt:

Disassembly of section .text:

0000000000422380 <p111_FID_36_100_105_114_101_99_116_46_77_97_112_46_98_105_116_>:
  422380:	endbr64 
  422384:	push   %rbp
  422385:	mov    %rsp,%rbp
  422388:	sub    $0x10,%rsp
  42238c:	push   %rbx
  42238d:	push   %r12
  42238f:	mov    $0x0,%esi
  422394:	mov    %rdi,%rbx
  422397:	callq  42f890 <p111_rt_reg_get>
  42239c:	mov    %rbx,%rdi
  42239f:	mov    %rax,%rsi
  4223a2:	mov    %rsi,%r12
  4223a5:	mov    $0x1,%esi
  4223aa:	mov    %rdi,%rbx
  4223ad:	callq  42f890 <p111_rt_reg_get>
  4223b2:	mov    %r12,%rsi
  4223b5:	mov    %rbx,%rdi
  4223b8:	mov    %rax,%rdx
  4223bb:	mov    %rdi,%rbx
  4223be:	callq  4070a0 <p113d_FID_36_100_105_114_101_99_116_46_77_97_112_46_98_105_116_>
  4223c3:	mov    %rbx,%rdi
  4223c6:	mov    %rax,-0x8(%rbp)
  4223ca:	mov    $0x1,%edx
  4223cf:	lea    -0x8(%rbp),%rsi
  4223d3:	callq  42f740 <p111_rt_return>
  4223d8:	pop    %r12
  4223da:	pop    %rbx
  4223db:	leaveq 
  4223dc:	retq   

Disassembly of section .fini:
