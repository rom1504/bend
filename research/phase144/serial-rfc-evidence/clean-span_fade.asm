
/home/ai/bend2/build/publish/bend/selfhost/build/phase111/p143-integrated-n2/program:     file format elf64-x86-64


Disassembly of section .init:

Disassembly of section .plt:

Disassembly of section .text:

0000000000402fb9 <span_fade>:
  402fb9:	4c 8d 1c cf          	lea    (%rdi,%rcx,8),%r11
  402fbd:	45 89 c0             	mov    %r8d,%r8d
  402fc0:	31 c9                	xor    %ecx,%ecx
  402fc2:	49 89 d1             	mov    %rdx,%r9
  402fc5:	49 ba ff ff ff ff ff 	movabs $0xffffffffff,%r10
  402fcc:	00 00 00 
  402fcf:	4c 39 c1             	cmp    %r8,%rcx
  402fd2:	75 05                	jne    402fd9 <span_fade+0x20>
  402fd4:	e9 57 e6 b4 00       	jmpq   f51630 <term_drop>
  402fd9:	50                   	push   %rax
  402fda:	49 8b 04 cb          	mov    (%r11,%rcx,8),%rax
  402fde:	48 85 c0             	test   %rax,%rax
  402fe1:	79 20                	jns    403003 <span_fade+0x4a>
  402fe3:	4c 21 d0             	and    %r10,%rax
  402fe6:	ba 01 00 00 00       	mov    $0x1,%edx
  402feb:	f0 0f c1 14 c7       	lock xadd %edx,(%rdi,%rax,8)
  402ff0:	89 d0                	mov    %edx,%eax
  402ff2:	25 ff ff ff 00       	and    $0xffffff,%eax
  402ff7:	3d fd ff ff 00       	cmp    $0xfffffd,%eax
  402ffc:	76 3f                	jbe    40303d <span_fade+0x84>
  402ffe:	e8 2d d0 b4 00       	callq  f50030 <rfc_bump.part.0>
  403003:	48 89 c2             	mov    %rax,%rdx
  403006:	48 c1 ea 38          	shr    $0x38,%rdx
  40300a:	80 e2 7e             	and    $0x7e,%dl
  40300d:	74 2e                	je     40303d <span_fade+0x84>
  40300f:	48 8b 15 1a 53 d5 00 	mov    0xd5531a(%rip),%rdx        # 1158330 <p111_program_active>
  403016:	4c 21 d0             	and    %r10,%rax
  403019:	48 8b 52 40          	mov    0x40(%rdx),%rdx
  40301d:	48 83 c2 7f          	add    $0x7f,%rdx
  403021:	48 83 e2 80          	and    $0xffffffffffffff80,%rdx
  403025:	48 81 c2 00 82 10 03 	add    $0x3108200,%rdx
  40302c:	48 39 d0             	cmp    %rdx,%rax
  40302f:	72 0c                	jb     40303d <span_fade+0x84>
  403031:	48 8d 3d d6 6f b5 00 	lea    0xb56fd6(%rip),%rdi        # f5a00e <_IO_stdin_used+0xe>
  403038:	e8 73 be b4 00       	callq  f4eeb0 <err_fail>
  40303d:	48 ff c1             	inc    %rcx
  403040:	4c 39 c1             	cmp    %r8,%rcx
  403043:	75 95                	jne    402fda <span_fade+0x21>
  403045:	4c 89 ca             	mov    %r9,%rdx
  403048:	59                   	pop    %rcx
  403049:	e9 e2 e5 b4 00       	jmpq   f51630 <term_drop>

Disassembly of section .fini:
