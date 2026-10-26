
/home/ai/bend2/build/publish/bend/selfhost/build/phase134/p144-final03-n2/program:     file format elf64-x86-64


Disassembly of section .init:

Disassembly of section .plt:

Disassembly of section .text:

0000000000f665c0 <p111_rt_return>:
  f665c0:	push   %rbp
  f665c1:	mov    %edx,%edx
  f665c3:	push   %rbx
  f665c4:	sub    $0x8,%rsp
  f665c8:	mov    0x2058e1(%rip),%rax        # 116beb0 <p111_program_active>
  f665cf:	cmp    0x38(%rax),%rdx
  f665d3:	ja     f665ff <p111_rt_return+0x3f>
  f665d5:	mov    %rdi,%rbx
  f665d8:	mov    %rdx,%rbp
  f665db:	callq  f63270 <p111_set_regs>
  f665e0:	mov    0x10(%rbx),%rax
  f665e4:	mov    %ebp,0x1c(%rbx)
  f665e7:	lea    -0x8(%rax),%rdx
  f665eb:	mov    -0x8(%rax),%rax
  f665ef:	mov    %rdx,0x10(%rbx)
  f665f3:	mov    %eax,0x20(%rbx)
  f665f6:	add    $0x8,%rsp
  f665fa:	xor    %eax,%eax
  f665fc:	pop    %rbx
  f665fd:	pop    %rbp
  f665fe:	retq   
  f665ff:	lea    0x70e2(%rip),%rdi        # f6d6e8 <_IO_stdin_used+0x6e8>
  f66606:	callq  f62270 <err_fail>

Disassembly of section .fini:
