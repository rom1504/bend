
/home/ai/bend2/build/publish/bend/selfhost/build/phase111/p131-read-lookup01-identity-candidate-build/program:     file format elf64-x86-64


Disassembly of section .init:

Disassembly of section .plt:

Disassembly of section .text:

000000000040da60 <p112w_FID_105_110_100_101_120_95_105_110_115_101_114_116_95_108_101_103_97_99_121_>:
  40da60:	f3 0f 1e fa          	endbr64 
  40da64:	55                   	push   %rbp
  40da65:	48 89 e5             	mov    %rsp,%rbp
  40da68:	48 81 ec 00 08 00 00 	sub    $0x800,%rsp
  40da6f:	b9 00 00 00 00       	mov    $0x0,%ecx
  40da74:	48 8d 95 00 f8 ff ff 	lea    -0x800(%rbp),%rdx
  40da7b:	be ba 01 00 00       	mov    $0x1ba,%esi
  40da80:	e8 6b 77 01 00       	callq  4251f0 <p111_rt_closure>
  40da85:	48 89 85 00 f8 ff ff 	mov    %rax,-0x800(%rbp)
  40da8c:	c9                   	leaveq 
  40da8d:	c3                   	retq   

Disassembly of section .fini:
