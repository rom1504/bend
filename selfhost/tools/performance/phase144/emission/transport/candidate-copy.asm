
/home/ai/bend2/build/publish/bend/selfhost/build/phase144/small-transfer02/candidate-compiler:     file format elf64-x86-64


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
  f63295:	je     f632c0 <p111_set_regs+0x50>
  f63297:	test   %rsi,%rsi
  f6329a:	je     f63280 <p111_set_regs+0x10>
  f6329c:	test   %ebx,%ebx
  f6329e:	je     f632c0 <p111_set_regs+0x50>
  f632a0:	cmp    $0x1,%ebx
  f632a3:	je     f63310 <p111_set_regs+0xa0>
  f632a5:	cmp    $0x2,%ebx
  f632a8:	jne    f632f8 <p111_set_regs+0x88>
  f632aa:	mov    (%rsi),%rdx
  f632ad:	mov    0x8(%rsi),%rax
  f632b1:	mov    %rdx,0x28(%r12)
  f632b6:	mov    %rax,0x30(%r12)
  f632bb:	nopl   0x0(%rax,%rax,1)
  f632c0:	mov    0x208be9(%rip),%rax        # 116beb0 <p111_program_active>
  f632c7:	testb  $0x4,0x58(%rax)
  f632cb:	je     f632d8 <p111_set_regs+0x68>
  f632cd:	pop    %rbx
  f632ce:	pop    %rbp
  f632cf:	pop    %r12
  f632d1:	retq   
  f632d2:	nopw   0x0(%rax,%rax,1)
  f632d8:	sub    %ebx,%ebp
  f632da:	lea    0x28(%r12,%rbx,8),%rdi
  f632df:	xor    %esi,%esi
  f632e1:	pop    %rbx
  f632e2:	lea    0x0(,%rbp,8),%rdx
  f632ea:	pop    %rbp
  f632eb:	pop    %r12
  f632ed:	jmpq   402170 <memset@plt>
  f632f2:	nopw   0x0(%rax,%rax,1)
  f632f8:	mov    %ebx,%edx
  f632fa:	lea    0x28(%r12),%rdi
  f632ff:	shl    $0x3,%rdx
  f63303:	callq  402090 <memmove@plt>
  f63308:	jmp    f632c0 <p111_set_regs+0x50>
  f6330a:	nopw   0x0(%rax,%rax,1)
  f63310:	mov    (%rsi),%rax
  f63313:	mov    %rax,0x28(%r12)
  f63318:	jmp    f632c0 <p111_set_regs+0x50>

Disassembly of section .fini:
