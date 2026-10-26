
selfhost/build/phase144/serial-rfc01/serial-rfc-compiler:     file format elf64-x86-64


Disassembly of section .init:

Disassembly of section .plt:

Disassembly of section .text:

0000000000f52d10 <p111_rt_keep>:
  f52d10:	48 89 f0             	mov    %rsi,%rax
  f52d13:	48 8b 77 08          	mov    0x8(%rdi),%rsi
  f52d17:	48 8b 3f             	mov    (%rdi),%rdi
  f52d1a:	48 85 c0             	test   %rax,%rax
  f52d1d:	78 49                	js     f52d68 <p111_rt_keep+0x58>
  f52d1f:	48 89 c2             	mov    %rax,%rdx
  f52d22:	48 c1 ea 38          	shr    $0x38,%rdx
  f52d26:	83 e2 7e             	and    $0x7e,%edx
  f52d29:	75 05                	jne    f52d30 <p111_rt_keep+0x20>
  f52d2b:	c3                   	retq   
  f52d2c:	0f 1f 40 00          	nopl   0x0(%rax)
  f52d30:	48 8b 15 f9 45 20 00 	mov    0x2045f9(%rip),%rdx        # 1157330 <p111_program_active>
  f52d37:	48 b9 ff ff ff ff ff 	movabs $0xffffffffff,%rcx
  f52d3e:	00 00 00 
  f52d41:	48 21 c1             	and    %rax,%rcx
  f52d44:	48 8b 52 40          	mov    0x40(%rdx),%rdx
  f52d48:	48 83 c2 7f          	add    $0x7f,%rdx
  f52d4c:	48 83 e2 80          	and    $0xffffffffffffff80,%rdx
  f52d50:	48 81 c2 00 82 10 03 	add    $0x3108200,%rdx
  f52d57:	48 39 d1             	cmp    %rdx,%rcx
  f52d5a:	0f 83 53 16 4b ff    	jae    4043b3 <p111_rt_keep.cold>
  f52d60:	c3                   	retq   
  f52d61:	0f 1f 80 00 00 00 00 	nopl   0x0(%rax)
  f52d68:	48 ba ff ff ff ff ff 	movabs $0xffffffffff,%rdx
  f52d6f:	00 00 00 
  f52d72:	48 21 c2             	and    %rax,%rdx
  f52d75:	48 8d 0c d7          	lea    (%rdi,%rdx,8),%rcx
  f52d79:	8b 11                	mov    (%rcx),%edx
  f52d7b:	8d 72 01             	lea    0x1(%rdx),%esi
  f52d7e:	81 e2 ff ff ff 00    	and    $0xffffff,%edx
  f52d84:	89 31                	mov    %esi,(%rcx)
  f52d86:	81 fa fd ff ff 00    	cmp    $0xfffffd,%edx
  f52d8c:	76 9d                	jbe    f52d2b <p111_rt_keep+0x1b>
  f52d8e:	50                   	push   %rax
  f52d8f:	e8 5c d3 ff ff       	callq  f500f0 <rfc_bump.part.0>

Disassembly of section .fini:
