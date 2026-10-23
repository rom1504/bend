
/home/ai/bend2/build/publish/bend/selfhost/build/phase111/p131-read-lookup01-identity-original-build/program:     file format elf64-x86-64


Disassembly of section .init:

Disassembly of section .plt:

Disassembly of section .text:

000000000040b440 <p112w_FID_105_110_100_101_120_95_102_105_110_100_95_97_98_115_101_110_116_>:
  40b440:	f3 0f 1e fa          	endbr64 
  40b444:	55                   	push   %rbp
  40b445:	48 89 e5             	mov    %rsp,%rbp
  40b448:	48 81 ec 00 08 00 00 	sub    $0x800,%rsp
  40b44f:	b9 00 00 00 00       	mov    $0x0,%ecx
  40b454:	48 8d 95 00 f8 ff ff 	lea    -0x800(%rbp),%rdx
  40b45b:	be 03 01 00 00       	mov    $0x103,%esi
  40b460:	e8 6b 9d 01 00       	callq  4251d0 <p111_rt_closure>
  40b465:	48 89 85 00 f8 ff ff 	mov    %rax,-0x800(%rbp)
  40b46c:	c9                   	leaveq 
  40b46d:	c3                   	retq   

Disassembly of section .fini:
