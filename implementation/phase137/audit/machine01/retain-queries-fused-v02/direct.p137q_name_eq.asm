
/home/ai/bend2/build/publish/bend/selfhost/build/phase111/p137-retain-query-builds01-wide-queries-fused-v02/program:     file format elf64-x86-64


Disassembly of section .init:

Disassembly of section .plt:

Disassembly of section .text:

000000000040aa10 <p113d_FID_36_100_105_114_101_99_116_46_112_49_51_55_113_95_110_97_109_101_95_101_113_>:
  40aa10:	endbr64 
  40aa14:	cs cs cs push %rbp
  40aa18:	mov    %rsp,%rbp
  40aa1b:	sub    $0x8,%rsp
  40aa1f:	push   %rbx
  40aa20:	push   %r12
  40aa22:	push   %r13
  40aa24:	mov    %rdx,%r13
  40aa27:	mov    $0x2,%ecx
  40aa2c:	mov    %r13,%rdx
  40aa2f:	mov    %rsi,%r12
  40aa32:	mov    %rdi,%rbx
  40aa35:	callq  437e00 <p118_rt_borrow_scalar_safe>
  40aa3a:	mov    %r12,%rsi
  40aa3d:	mov    %rbx,%rdi
  40aa40:	cmp    $0x0,%rax
  40aa44:	jne    40aa50 <p113d_FID_36_100_105_114_101_99_116_46_112_49_51_55_113_95_110_97_109_101_95_101_113_+0x40>
  40aa46:	mov    %r13,%rdx
  40aa49:	callq  40a2c0 <p113d_FID_36_112_49_50_56_98_111_114_114_111_119_46_111_119_110_101_100_46_112_49_51_55_113_95_110_97_109_101_95_101_113_>
  40aa4e:	jmp    40aa7d <p113d_FID_36_100_105_114_101_99_116_46_112_49_51_55_113_95_110_97_109_101_95_101_113_+0x6d>
  40aa50:	mov    %r13,%rdx
  40aa53:	mov    %rsi,%r12
  40aa56:	mov    %rdi,%rbx
  40aa59:	callq  40a5e0 <p113d_FID_36_112_49_49_56_98_111_114_114_111_119_46_114_101_97_100_46_112_49_51_55_113_95_110_97_109_101_95_101_113_>
  40aa5e:	mov    %r12,%rsi
  40aa61:	mov    %rbx,%rdi
  40aa64:	mov    %rax,%rbx
  40aa67:	mov    %rdi,%r12
  40aa6a:	callq  431fa0 <p111_rt_sink>
  40aa6f:	mov    %r13,%rsi
  40aa72:	mov    %r12,%rdi
  40aa75:	callq  431fa0 <p111_rt_sink>
  40aa7a:	mov    %rbx,%rax
  40aa7d:	pop    %r13
  40aa7f:	pop    %r12
  40aa81:	pop    %rbx
  40aa82:	leaveq 
  40aa83:	retq   

Disassembly of section .fini:
