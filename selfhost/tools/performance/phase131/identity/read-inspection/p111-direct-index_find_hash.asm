
/home/ai/bend2/build/publish/bend/selfhost/build/phase111/p130-native01-n1/program:     file format elf64-x86-64


Disassembly of section .init:

Disassembly of section .plt:

Disassembly of section .text:

0000000000dc62e0 <p111_FID_36_100_105_114_101_99_116_46_105_110_100_101_120_95_102_105_110_100_95_104_97_115_104_>:
  dc62e0:	f3 0f 1e fa          	endbr64 
  dc62e4:	55                   	push   %rbp
  dc62e5:	48 89 e5             	mov    %rsp,%rbp
  dc62e8:	48 83 ec 18          	sub    $0x18,%rsp
  dc62ec:	53                   	push   %rbx
  dc62ed:	41 54                	push   %r12
  dc62ef:	41 55                	push   %r13
  dc62f1:	be 00 00 00 00       	mov    $0x0,%esi
  dc62f6:	48 89 fb             	mov    %rdi,%rbx
  dc62f9:	e8 b2 16 02 00       	callq  de79b0 <p111_rt_reg_get>
  dc62fe:	48 89 df             	mov    %rbx,%rdi
  dc6301:	48 89 c6             	mov    %rax,%rsi
  dc6304:	49 89 f4             	mov    %rsi,%r12
  dc6307:	be 01 00 00 00       	mov    $0x1,%esi
  dc630c:	48 89 fb             	mov    %rdi,%rbx
  dc630f:	e8 9c 16 02 00       	callq  de79b0 <p111_rt_reg_get>
  dc6314:	4c 89 e6             	mov    %r12,%rsi
  dc6317:	48 89 df             	mov    %rbx,%rdi
  dc631a:	49 89 c5             	mov    %rax,%r13
  dc631d:	49 89 f4             	mov    %rsi,%r12
  dc6320:	be 02 00 00 00       	mov    $0x2,%esi
  dc6325:	48 89 fb             	mov    %rdi,%rbx
  dc6328:	e8 83 16 02 00       	callq  de79b0 <p111_rt_reg_get>
  dc632d:	4c 89 ea             	mov    %r13,%rdx
  dc6330:	4c 89 e6             	mov    %r12,%rsi
  dc6333:	48 89 df             	mov    %rbx,%rdi
  dc6336:	48 89 c1             	mov    %rax,%rcx
  dc6339:	48 89 fb             	mov    %rdi,%rbx
  dc633c:	e8 ef 47 6d ff       	callq  49ab30 <p113d_FID_36_100_105_114_101_99_116_46_105_110_100_101_120_95_102_105_110_100_95_104_97_115_104_>
  dc6341:	48 89 df             	mov    %rbx,%rdi
  dc6344:	48 89 45 f8          	mov    %rax,-0x8(%rbp)
  dc6348:	ba 01 00 00 00       	mov    $0x1,%edx
  dc634d:	48 8d 75 f8          	lea    -0x8(%rbp),%rsi
  dc6351:	e8 0a 15 02 00       	callq  de7860 <p111_rt_return>
  dc6356:	41 5d                	pop    %r13
  dc6358:	41 5c                	pop    %r12
  dc635a:	5b                   	pop    %rbx
  dc635b:	c9                   	leaveq 
  dc635c:	c3                   	retq   

Disassembly of section .fini:
