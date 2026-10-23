
/home/ai/bend2/build/publish/bend/selfhost/build/phase111/p131-read-lookup01-identity-original-build/program:     file format elf64-x86-64


Disassembly of section .init:

Disassembly of section .plt:

Disassembly of section .text:

000000000040ca90 <p112w_FID_105_110_100_101_120_95_105_110_115_101_114_116_95_108_101_103_97_99_121_>:
  40ca90:	f3 0f 1e fa          	endbr64 
  40ca94:	55                   	push   %rbp
  40ca95:	48 89 e5             	mov    %rsp,%rbp
  40ca98:	48 81 ec 00 08 00 00 	sub    $0x800,%rsp
  40ca9f:	b9 00 00 00 00       	mov    $0x0,%ecx
  40caa4:	48 8d 95 00 f8 ff ff 	lea    -0x800(%rbp),%rdx
  40caab:	be d0 01 00 00       	mov    $0x1d0,%esi
  40cab0:	e8 1b 87 01 00       	callq  4251d0 <p111_rt_closure>
  40cab5:	48 89 85 00 f8 ff ff 	mov    %rax,-0x800(%rbp)
  40cabc:	c9                   	leaveq 
  40cabd:	c3                   	retq   

Disassembly of section .fini:
