
/home/ai/bend2/build/publish/bend/selfhost/build/phase111/p131-read-lookup01-identity-original-build/program:     file format elf64-x86-64


Disassembly of section .init:

Disassembly of section .plt:

Disassembly of section .text:

000000000040b1d0 <p112w_FID_105_110_100_101_120_95_98_117_99_107_101_116_>:
  40b1d0:	f3 0f 1e fa          	endbr64 
  40b1d4:	55                   	push   %rbp
  40b1d5:	48 89 e5             	mov    %rsp,%rbp
  40b1d8:	48 81 ec 00 08 00 00 	sub    $0x800,%rsp
  40b1df:	b9 00 00 00 00       	mov    $0x0,%ecx
  40b1e4:	48 8d 95 00 f8 ff ff 	lea    -0x800(%rbp),%rdx
  40b1eb:	be e7 00 00 00       	mov    $0xe7,%esi
  40b1f0:	e8 db 9f 01 00       	callq  4251d0 <p111_rt_closure>
  40b1f5:	48 89 85 00 f8 ff ff 	mov    %rax,-0x800(%rbp)
  40b1fc:	c9                   	leaveq 
  40b1fd:	c3                   	retq   

Disassembly of section .fini:
