
/home/ai/bend2/build/publish/bend/selfhost/build/phase144/profile01/runtime/program:     file format elf64-x86-64


Disassembly of section .init:

Disassembly of section .plt:

Disassembly of section .text:

000000000040304f <span_fade>:
  40304f:	53                   	push   %rbx
  403050:	49 89 f9             	mov    %rdi,%r9
  403053:	48 8d 1c cf          	lea    (%rdi,%rcx,8),%rbx
  403057:	49 89 d2             	mov    %rdx,%r10
  40305a:	49 bb ff ff ff ff ff 	movabs $0xffffffffff,%r11
  403061:	00 00 00 
  403064:	45 89 c0             	mov    %r8d,%r8d
  403067:	31 c9                	xor    %ecx,%ecx
  403069:	4c 39 c1             	cmp    %r8,%rcx
  40306c:	74 42                	je     4030b0 <span_fade+0x61>
  40306e:	48 8b 3c cb          	mov    (%rbx,%rcx,8),%rdi
  403072:	48 85 ff             	test   %rdi,%rdi
  403075:	79 1f                	jns    403096 <span_fade+0x47>
  403077:	4c 21 df             	and    %r11,%rdi
  40307a:	b8 01 00 00 00       	mov    $0x1,%eax
  40307f:	f0 41 0f c1 04 f9    	lock xadd %eax,(%r9,%rdi,8)
  403085:	25 ff ff ff 00       	and    $0xffffff,%eax
  40308a:	3d fd ff ff 00       	cmp    $0xfffffd,%eax
  40308f:	76 1a                	jbe    4030ab <span_fade+0x5c>
  403091:	e8 6a cd b4 00       	callq  f4fe00 <rfc_bump.part.0>
  403096:	e8 f5 b8 b4 00       	callq  f4e990 <term_triv>
  40309b:	84 c0                	test   %al,%al
  40309d:	75 0c                	jne    4030ab <span_fade+0x5c>
  40309f:	48 8d 3d f6 8f b5 00 	lea    0xb58ff6(%rip),%rdi        # f5c09c <_IO_stdin_used+0x9c>
  4030a6:	e8 d5 bc b4 00       	callq  f4ed80 <err_fail>
  4030ab:	48 ff c1             	inc    %rcx
  4030ae:	eb b9                	jmp    403069 <span_fade+0x1a>
  4030b0:	4c 89 d2             	mov    %r10,%rdx
  4030b3:	4c 89 cf             	mov    %r9,%rdi
  4030b6:	5b                   	pop    %rbx
  4030b7:	e9 84 00 b5 00       	jmpq   f53140 <term_drop>

Disassembly of section .fini:
