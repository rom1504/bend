
/home/ai/bend2/build/publish/bend/selfhost/build/phase111/p143-integrated-n2/program:     file format elf64-x86-64


Disassembly of section .init:

Disassembly of section .plt:

Disassembly of section .text:

0000000000f533c0 <p111_rt_keep>:
  f533c0:	48 89 f0             	mov    %rsi,%rax
  f533c3:	48 8b 77 08          	mov    0x8(%rdi),%rsi
  f533c7:	48 8b 3f             	mov    (%rdi),%rdi
  f533ca:	48 85 c0             	test   %rax,%rax
  f533cd:	78 49                	js     f53418 <p111_rt_keep+0x58>
  f533cf:	48 89 c2             	mov    %rax,%rdx
  f533d2:	48 c1 ea 38          	shr    $0x38,%rdx
  f533d6:	83 e2 7e             	and    $0x7e,%edx
  f533d9:	75 05                	jne    f533e0 <p111_rt_keep+0x20>
  f533db:	c3                   	retq   
  f533dc:	0f 1f 40 00          	nopl   0x0(%rax)
  f533e0:	48 8b 15 49 4f 20 00 	mov    0x204f49(%rip),%rdx        # 1158330 <p111_program_active>
  f533e7:	48 b9 ff ff ff ff ff 	movabs $0xffffffffff,%rcx
  f533ee:	00 00 00 
  f533f1:	48 21 c1             	and    %rax,%rcx
  f533f4:	48 8b 52 40          	mov    0x40(%rdx),%rdx
  f533f8:	48 83 c2 7f          	add    $0x7f,%rdx
  f533fc:	48 83 e2 80          	and    $0xffffffffffffff80,%rdx
  f53400:	48 81 c2 00 82 10 03 	add    $0x3108200,%rdx
  f53407:	48 39 d1             	cmp    %rdx,%rcx
  f5340a:	0f 83 19 0e 4b ff    	jae    404229 <p111_rt_keep.cold>
  f53410:	c3                   	retq   
  f53411:	0f 1f 80 00 00 00 00 	nopl   0x0(%rax)
  f53418:	48 ba ff ff ff ff ff 	movabs $0xffffffffff,%rdx
  f5341f:	00 00 00 
  f53422:	b9 01 00 00 00       	mov    $0x1,%ecx
  f53427:	48 21 c2             	and    %rax,%rdx
  f5342a:	f0 0f c1 0c d7       	lock xadd %ecx,(%rdi,%rdx,8)
  f5342f:	81 e1 ff ff ff 00    	and    $0xffffff,%ecx
  f53435:	81 f9 fd ff ff 00    	cmp    $0xfffffd,%ecx
  f5343b:	76 9e                	jbe    f533db <p111_rt_keep+0x1b>
  f5343d:	50                   	push   %rax
  f5343e:	e8 ed cb ff ff       	callq  f50030 <rfc_bump.part.0>

Disassembly of section .fini:
