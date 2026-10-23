
/home/ai/bend2/build/publish/bend/selfhost/build/phase111/p126-observer26-coverage-record-aggregation-256-build/program:     file format elf64-x86-64


Disassembly of section .init:

Disassembly of section .plt:

Disassembly of section .text:

0000000000422200 <p111_FID_36_100_105_114_101_99_116_46_77_97_112_46_98_105_116_46_97_116_>:
  422200:	endbr64 
  422204:	push   %rbp
  422205:	mov    %rsp,%rbp
  422208:	sub    $0x10,%rsp
  42220c:	push   %rbx
  42220d:	push   %r12
  42220f:	mov    $0x0,%esi
  422214:	mov    %rdi,%rbx
  422217:	callq  42f890 <p111_rt_reg_get>
  42221c:	mov    %rbx,%rdi
  42221f:	mov    %rax,%rsi
  422222:	mov    %rsi,%r12
  422225:	mov    $0x1,%esi
  42222a:	mov    %rdi,%rbx
  42222d:	callq  42f890 <p111_rt_reg_get>
  422232:	mov    %r12,%rsi
  422235:	mov    %rbx,%rdi
  422238:	mov    %rax,%rdx
  42223b:	mov    %rdi,%rbx
  42223e:	callq  406fb0 <p113d_FID_36_100_105_114_101_99_116_46_77_97_112_46_98_105_116_46_97_116_>
  422243:	mov    %rbx,%rdi
  422246:	mov    %rax,-0x8(%rbp)
  42224a:	mov    $0x1,%edx
  42224f:	lea    -0x8(%rbp),%rsi
  422253:	callq  42f740 <p111_rt_return>
  422258:	pop    %r12
  42225a:	pop    %rbx
  42225b:	leaveq 
  42225c:	retq   

Disassembly of section .fini:
