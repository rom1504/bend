
/home/ai/bend2/build/publish/bend/selfhost/build/phase111/p131-read-lookup01-identity-original-build/program:     file format elf64-x86-64


Disassembly of section .init:

Disassembly of section .plt:

Disassembly of section .text:

000000000040cb90 <p112w_FID_105_110_100_101_120_95_105_110_115_101_114_116_>:
  40cb90:	f3 0f 1e fa          	endbr64 
  40cb94:	55                   	push   %rbp
  40cb95:	48 89 e5             	mov    %rsp,%rbp
  40cb98:	48 81 ec 00 08 00 00 	sub    $0x800,%rsp
  40cb9f:	b9 00 00 00 00       	mov    $0x0,%ecx
  40cba4:	48 8d 95 00 f8 ff ff 	lea    -0x800(%rbp),%rdx
  40cbab:	be ea 01 00 00       	mov    $0x1ea,%esi
  40cbb0:	e8 1b 86 01 00       	callq  4251d0 <p111_rt_closure>
  40cbb5:	48 89 85 00 f8 ff ff 	mov    %rax,-0x800(%rbp)
  40cbbc:	c9                   	leaveq 
  40cbbd:	c3                   	retq   

Disassembly of section .fini:
