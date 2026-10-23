
/home/ai/bend2/build/publish/bend/selfhost/build/phase111/p131-read-lookup01-identity-original-build/program:     file format elf64-x86-64


Disassembly of section .init:

Disassembly of section .plt:

Disassembly of section .text:

000000000040d310 <p112w_FID_105_110_100_101_120_95_115_101_116_>:
  40d310:	f3 0f 1e fa          	endbr64 
  40d314:	55                   	push   %rbp
  40d315:	48 89 e5             	mov    %rsp,%rbp
  40d318:	48 81 ec 00 08 00 00 	sub    $0x800,%rsp
  40d31f:	b9 00 00 00 00       	mov    $0x0,%ecx
  40d324:	48 8d 95 00 f8 ff ff 	lea    -0x800(%rbp),%rdx
  40d32b:	be 47 02 00 00       	mov    $0x247,%esi
  40d330:	e8 9b 7e 01 00       	callq  4251d0 <p111_rt_closure>
  40d335:	48 89 85 00 f8 ff ff 	mov    %rax,-0x800(%rbp)
  40d33c:	c9                   	leaveq 
  40d33d:	c3                   	retq   

Disassembly of section .fini:
