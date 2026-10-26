
selfhost/build/phase144/serial-rfc01/serial-rfc-compiler:     file format elf64-x86-64


Disassembly of section .init:

Disassembly of section .plt:

Disassembly of section .text:

00000000004033cf <span_fade>:
  4033cf:	49 ba ff ff ff ff ff 	movabs $0xffffffffff,%r10
  4033d6:	00 00 00 
  4033d9:	55                   	push   %rbp
  4033da:	4c 8d 1c cf          	lea    (%rdi,%rcx,8),%r11
  4033de:	31 c9                	xor    %ecx,%ecx
  4033e0:	53                   	push   %rbx
  4033e1:	41 51                	push   %r9
  4033e3:	48 8b 1d 46 3f d5 00 	mov    0xd53f46(%rip),%rbx        # 1157330 <p111_program_active>
  4033ea:	49 89 d1             	mov    %rdx,%r9
  4033ed:	41 39 c8             	cmp    %ecx,%r8d
  4033f0:	76 60                	jbe    403452 <span_fade+0x83>
  4033f2:	49 8b 04 cb          	mov    (%r11,%rcx,8),%rax
  4033f6:	48 85 c0             	test   %rax,%rax
  4033f9:	79 1f                	jns    40341a <span_fade+0x4b>
  4033fb:	4c 21 d0             	and    %r10,%rax
  4033fe:	48 8d 14 c7          	lea    (%rdi,%rax,8),%rdx
  403402:	8b 02                	mov    (%rdx),%eax
  403404:	8d 68 01             	lea    0x1(%rax),%ebp
  403407:	25 ff ff ff 00       	and    $0xffffff,%eax
  40340c:	89 2a                	mov    %ebp,(%rdx)
  40340e:	3d fd ff ff 00       	cmp    $0xfffffd,%eax
  403413:	76 11                	jbe    403426 <span_fade+0x57>
  403415:	e8 d6 cc b4 00       	callq  f500f0 <rfc_bump.part.0>
  40341a:	48 89 c2             	mov    %rax,%rdx
  40341d:	48 c1 ea 38          	shr    $0x38,%rdx
  403421:	80 e2 7e             	and    $0x7e,%dl
  403424:	75 05                	jne    40342b <span_fade+0x5c>
  403426:	48 ff c1             	inc    %rcx
  403429:	eb c2                	jmp    4033ed <span_fade+0x1e>
  40342b:	48 8b 53 40          	mov    0x40(%rbx),%rdx
  40342f:	4c 21 d0             	and    %r10,%rax
  403432:	48 83 c2 7f          	add    $0x7f,%rdx
  403436:	48 83 e2 80          	and    $0xffffffffffffff80,%rdx
  40343a:	48 81 c2 00 82 10 03 	add    $0x3108200,%rdx
  403441:	48 39 d0             	cmp    %rdx,%rax
  403444:	72 e0                	jb     403426 <span_fade+0x57>
  403446:	48 8d 3d c1 5b b5 00 	lea    0xb55bc1(%rip),%rdi        # f5900e <_IO_stdin_used+0xe>
  40344d:	e8 1e bc b4 00       	callq  f4f070 <err_fail>
  403452:	58                   	pop    %rax
  403453:	4c 89 ca             	mov    %r9,%rdx
  403456:	5b                   	pop    %rbx
  403457:	5d                   	pop    %rbp
  403458:	e9 43 e0 b4 00       	jmpq   f514a0 <term_drop>

Disassembly of section .fini:
