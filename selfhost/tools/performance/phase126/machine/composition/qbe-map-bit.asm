
selfhost/build/phase111/p125-broad06-coverage-record-aggregation-256-build/program:     file format elf64-x86-64


Disassembly of section .init:

Disassembly of section .plt:

Disassembly of section .text:

0000000000422330 <p111_FID_36_100_105_114_101_99_116_46_77_97_112_46_98_105_116_>:
  422330:	f3 0f 1e fa          	endbr64 
  422334:	55                   	push   %rbp
  422335:	48 89 e5             	mov    %rsp,%rbp
  422338:	48 81 ec 00 08 00 00 	sub    $0x800,%rsp
  42233f:	53                   	push   %rbx
  422340:	41 54                	push   %r12
  422342:	48 8b 5f 28          	mov    0x28(%rdi),%rbx
  422346:	48 8b 47 30          	mov    0x30(%rdi),%rax
  42234a:	48 89 85 00 f8 ff ff 	mov    %rax,-0x800(%rbp)
  422351:	48 c7 85 08 f8 ff ff 	movq   $0x21,-0x7f8(%rbp)
  422358:	21 00 00 00 
  42235c:	b9 02 00 00 00       	mov    $0x2,%ecx
  422361:	48 8d 95 00 f8 ff ff 	lea    -0x800(%rbp),%rdx
  422368:	be 46 00 00 00       	mov    $0x46,%esi
  42236d:	49 89 fc             	mov    %rdi,%r12
  422370:	e8 7b d5 00 00       	callq  42f8f0 <p111_rt_op>
  422375:	4c 89 e7             	mov    %r12,%rdi
  422378:	48 89 9d 00 f8 ff ff 	mov    %rbx,-0x800(%rbp)
  42237f:	48 89 85 08 f8 ff ff 	mov    %rax,-0x7f8(%rbp)
  422386:	b9 02 00 00 00       	mov    $0x2,%ecx
  42238b:	48 8d 95 00 f8 ff ff 	lea    -0x800(%rbp),%rdx
  422392:	be 80 02 00 00       	mov    $0x280,%esi
  422397:	e8 64 d3 00 00       	callq  42f700 <p111_rt_jump>
  42239c:	41 5c                	pop    %r12
  42239e:	5b                   	pop    %rbx
  42239f:	c9                   	leaveq 
  4223a0:	c3                   	retq   

Disassembly of section .fini:
