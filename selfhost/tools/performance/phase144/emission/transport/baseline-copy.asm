
/home/ai/bend2/build/publish/bend/selfhost/build/phase144/small-transfer02/baseline-compiler:     file format elf64-x86-64


Disassembly of section .init:

Disassembly of section .plt:

Disassembly of section .text:

0000000000f63270 <p111_set_regs>:
  f63270:	push   %r12
  f63272:	push   %rbp
  f63273:	mov    0x208c2f(%rip),%ebp        # 116bea8 <p111_transport_words>
  f63279:	push   %rbx
  f6327a:	mov    %edx,%ebx
  f6327c:	cmp    %ebx,%ebp
  f6327e:	jae    f63290 <p111_set_regs+0x20>
  f63280:	lea    0xa1c1(%rip),%rdi        # f6d448 <_IO_stdin_used+0x448>
  f63287:	callq  f62270 <err_fail>
  f6328c:	nopl   0x0(%rax)
  f63290:	mov    %rdi,%r12
  f63293:	test   %ebx,%ebx
  f63295:	je     f632b0 <p111_set_regs+0x40>
  f63297:	test   %rsi,%rsi
  f6329a:	je     f63280 <p111_set_regs+0x10>
  f6329c:	test   %ebx,%ebx
  f6329e:	je     f632b0 <p111_set_regs+0x40>
  f632a0:	mov    %ebx,%edx
  f632a2:	lea    0x28(%r12),%rdi
  f632a7:	shl    $0x3,%rdx
  f632ab:	callq  402090 <memmove@plt>
  f632b0:	mov    0x208bf9(%rip),%rax        # 116beb0 <p111_program_active>
  f632b7:	testb  $0x4,0x58(%rax)
  f632bb:	je     f632c8 <p111_set_regs+0x58>
  f632bd:	pop    %rbx
  f632be:	pop    %rbp
  f632bf:	pop    %r12
  f632c1:	retq   
  f632c2:	nopw   0x0(%rax,%rax,1)
  f632c8:	sub    %ebx,%ebp
  f632ca:	lea    0x28(%r12,%rbx,8),%rdi
  f632cf:	xor    %esi,%esi
  f632d1:	pop    %rbx
  f632d2:	lea    0x0(,%rbp,8),%rdx
  f632da:	pop    %rbp
  f632db:	pop    %r12
  f632dd:	jmpq   402170 <memset@plt>

Disassembly of section .fini:
