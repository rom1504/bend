
/home/ai/bend2/build/publish/bend/selfhost/build/phase111/p131-read-lookup01-identity-candidate-build/program:     file format elf64-x86-64


Disassembly of section .init:

Disassembly of section .plt:

Disassembly of section .text:

000000000040db60 <p112w_FID_105_110_100_101_120_95_105_110_115_101_114_116_>:
  40db60:	f3 0f 1e fa          	endbr64 
  40db64:	55                   	push   %rbp
  40db65:	48 89 e5             	mov    %rsp,%rbp
  40db68:	48 81 ec 00 08 00 00 	sub    $0x800,%rsp
  40db6f:	b9 00 00 00 00       	mov    $0x0,%ecx
  40db74:	48 8d 95 00 f8 ff ff 	lea    -0x800(%rbp),%rdx
  40db7b:	be d4 01 00 00       	mov    $0x1d4,%esi
  40db80:	e8 6b 76 01 00       	callq  4251f0 <p111_rt_closure>
  40db85:	48 89 85 00 f8 ff ff 	mov    %rax,-0x800(%rbp)
  40db8c:	c9                   	leaveq 
  40db8d:	c3                   	retq   

Disassembly of section .fini:
