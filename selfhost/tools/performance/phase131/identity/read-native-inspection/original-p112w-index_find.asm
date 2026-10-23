
/home/ai/bend2/build/publish/bend/selfhost/build/phase111/p131-read-lookup01-identity-original-build/program:     file format elf64-x86-64


Disassembly of section .init:

Disassembly of section .plt:

Disassembly of section .text:

000000000040b590 <p112w_FID_105_110_100_101_120_95_102_105_110_100_>:
  40b590:	f3 0f 1e fa          	endbr64 
  40b594:	55                   	push   %rbp
  40b595:	48 89 e5             	mov    %rsp,%rbp
  40b598:	48 81 ec 00 08 00 00 	sub    $0x800,%rsp
  40b59f:	b9 00 00 00 00       	mov    $0x0,%ecx
  40b5a4:	48 8d 95 00 f8 ff ff 	lea    -0x800(%rbp),%rdx
  40b5ab:	be 0c 01 00 00       	mov    $0x10c,%esi
  40b5b0:	e8 1b 9c 01 00       	callq  4251d0 <p111_rt_closure>
  40b5b5:	48 89 85 00 f8 ff ff 	mov    %rax,-0x800(%rbp)
  40b5bc:	c9                   	leaveq 
  40b5bd:	c3                   	retq   

Disassembly of section .fini:
