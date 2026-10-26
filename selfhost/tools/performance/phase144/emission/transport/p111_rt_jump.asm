
/home/ai/bend2/build/publish/bend/selfhost/build/phase134/p144-final03-n2/program:     file format elf64-x86-64


Disassembly of section .init:

Disassembly of section .plt:

Disassembly of section .text:

0000000000f66560 <p111_rt_jump>:
  f66560:	push   %rbp
  f66561:	mov    %esi,%ebp
  f66563:	push   %rbx
  f66564:	sub    $0x8,%rsp
  f66568:	mov    0x205941(%rip),%rax        # 116beb0 <p111_program_active>
  f6656f:	cmp    0x10(%rax),%esi
  f66572:	jb     f66580 <p111_rt_jump+0x20>
  f66574:	lea    0x7145(%rip),%rdi        # f6d6c0 <_IO_stdin_used+0x6c0>
  f6657b:	callq  f62270 <err_fail>
  f66580:	mov    %rdi,%rbx
  f66583:	mov    0x68(%rax),%rdi
  f66587:	mov    %rdx,%rsi
  f6658a:	mov    %ecx,%edx
  f6658c:	mov    %ebp,%ecx
  f6658e:	movzbl (%rdi,%rcx,1),%eax
  f66592:	cmp    %eax,%edx
  f66594:	jne    f66574 <p111_rt_jump+0x14>
  f66596:	mov    %rbx,%rdi
  f66599:	callq  f63270 <p111_set_regs>
  f6659e:	movl   $0x0,0x1c(%rbx)
  f665a5:	xor    %eax,%eax
  f665a7:	mov    %ebp,0x20(%rbx)
  f665aa:	add    $0x8,%rsp
  f665ae:	pop    %rbx
  f665af:	pop    %rbp
  f665b0:	retq   

Disassembly of section .fini:
