
/home/ai/bend2/build/publish/bend/selfhost/build/phase111/p137-retain-query-builds01-wide-queries-fused-v02/program:     file format elf64-x86-64


Disassembly of section .init:

Disassembly of section .plt:

Disassembly of section .text:

000000000040b630 <p113d_FID_36_100_105_114_101_99_116_46_112_49_51_55_113_95_107_101_121_95_101_113_>:
  40b630:	endbr64 
  40b634:	cs cs cs push %rbp
  40b638:	mov    %rsp,%rbp
  40b63b:	sub    $0x8,%rsp
  40b63f:	push   %rbx
  40b640:	push   %r12
  40b642:	push   %r13
  40b644:	mov    %rdx,%r13
  40b647:	mov    $0x2,%ecx
  40b64c:	mov    %r13,%rdx
  40b64f:	mov    %rsi,%r12
  40b652:	mov    %rdi,%rbx
  40b655:	callq  437e00 <p118_rt_borrow_scalar_safe>
  40b65a:	mov    %r12,%rsi
  40b65d:	mov    %rbx,%rdi
  40b660:	cmp    $0x0,%rax
  40b664:	jne    40b670 <p113d_FID_36_100_105_114_101_99_116_46_112_49_51_55_113_95_107_101_121_95_101_113_+0x40>
  40b666:	mov    %r13,%rdx
  40b669:	callq  40aef0 <p113d_FID_36_112_49_50_56_98_111_114_114_111_119_46_111_119_110_101_100_46_112_49_51_55_113_95_107_101_121_95_101_113_>
  40b66e:	jmp    40b69d <p113d_FID_36_100_105_114_101_99_116_46_112_49_51_55_113_95_107_101_121_95_101_113_+0x6d>
  40b670:	mov    %r13,%rdx
  40b673:	mov    %rsi,%r12
  40b676:	mov    %rdi,%rbx
  40b679:	callq  40b200 <p113d_FID_36_112_49_49_56_98_111_114_114_111_119_46_114_101_97_100_46_112_49_51_55_113_95_107_101_121_95_101_113_>
  40b67e:	mov    %r12,%rsi
  40b681:	mov    %rbx,%rdi
  40b684:	mov    %rax,%rbx
  40b687:	mov    %rdi,%r12
  40b68a:	callq  431fa0 <p111_rt_sink>
  40b68f:	mov    %r13,%rsi
  40b692:	mov    %r12,%rdi
  40b695:	callq  431fa0 <p111_rt_sink>
  40b69a:	mov    %rbx,%rax
  40b69d:	pop    %r13
  40b69f:	pop    %r12
  40b6a1:	pop    %rbx
  40b6a2:	leaveq 
  40b6a3:	retq   

Disassembly of section .fini:
