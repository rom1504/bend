
/home/ai/bend2/build/publish/bend/selfhost/build/phase111/p131-read-lookup01-identity-candidate-build/program:     file format elf64-x86-64


Disassembly of section .init:

Disassembly of section .plt:

Disassembly of section .text:

000000000040c560 <p112w_FID_105_110_100_101_120_95_102_105_110_100_>:
  40c560:	f3 0f 1e fa          	endbr64 
  40c564:	55                   	push   %rbp
  40c565:	48 89 e5             	mov    %rsp,%rbp
  40c568:	48 81 ec 00 08 00 00 	sub    $0x800,%rsp
  40c56f:	b9 00 00 00 00       	mov    $0x0,%ecx
  40c574:	48 8d 95 00 f8 ff ff 	lea    -0x800(%rbp),%rdx
  40c57b:	be f0 00 00 00       	mov    $0xf0,%esi
  40c580:	e8 6b 8c 01 00       	callq  4251f0 <p111_rt_closure>
  40c585:	48 89 85 00 f8 ff ff 	mov    %rax,-0x800(%rbp)
  40c58c:	c9                   	leaveq 
  40c58d:	c3                   	retq   

Disassembly of section .fini:
