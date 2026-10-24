
/home/ai/bend2/build/publish/bend/selfhost/build/phase111/p137-retain-query-builds01-wide-record-fused-v02/program:     file format elf64-x86-64


Disassembly of section .init:

Disassembly of section .plt:

Disassembly of section .text:

0000000000409040 <p113d_FID_36_100_105_114_101_99_116_46_112_49_51_55_113_95_114_101_99_111_114_100_95_113_117_101_114_121_>:
  409040:	endbr64 
  409044:	push   %rbp
  409045:	mov    %rsp,%rbp
  409048:	sub    $0x8,%rsp
  40904c:	push   %rbx
  40904d:	push   %r12
  40904f:	push   %r13
  409051:	mov    %rdx,%r13
  409054:	mov    $0x2,%ecx
  409059:	mov    %r13,%rdx
  40905c:	mov    %rsi,%r12
  40905f:	mov    %rdi,%rbx
  409062:	callq  437120 <p118_rt_borrow_scalar_safe>
  409067:	mov    %r12,%rsi
  40906a:	mov    %rbx,%rdi
  40906d:	cmp    $0x0,%rax
  409071:	jne    40907d <p113d_FID_36_100_105_114_101_99_116_46_112_49_51_55_113_95_114_101_99_111_114_100_95_113_117_101_114_121_+0x3d>
  409073:	mov    %r13,%rdx
  409076:	callq  408dd0 <p113d_FID_36_112_49_50_56_98_111_114_114_111_119_46_111_119_110_101_100_46_112_49_51_55_113_95_114_101_99_111_114_100_95_113_117_101_114_121_>
  40907b:	jmp    4090aa <p113d_FID_36_100_105_114_101_99_116_46_112_49_51_55_113_95_114_101_99_111_114_100_95_113_117_101_114_121_+0x6a>
  40907d:	mov    %r13,%rdx
  409080:	mov    %rsi,%r12
  409083:	mov    %rdi,%rbx
  409086:	callq  408f80 <p113d_FID_36_112_49_49_56_98_111_114_114_111_119_46_114_101_97_100_46_112_49_51_55_113_95_114_101_99_111_114_100_95_113_117_101_114_121_>
  40908b:	mov    %r12,%rsi
  40908e:	mov    %rbx,%rdi
  409091:	mov    %rax,%rbx
  409094:	mov    %rdi,%r12
  409097:	callq  4312c0 <p111_rt_sink>
  40909c:	mov    %r13,%rsi
  40909f:	mov    %r12,%rdi
  4090a2:	callq  4312c0 <p111_rt_sink>
  4090a7:	mov    %rbx,%rax
  4090aa:	pop    %r13
  4090ac:	pop    %r12
  4090ae:	pop    %rbx
  4090af:	leaveq 
  4090b0:	retq   

Disassembly of section .fini:
