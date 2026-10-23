
/home/ai/bend2/build/publish/bend/selfhost/build/phase111/p131-read-lookup01-identity-candidate-build/program:     file format elf64-x86-64


Disassembly of section .init:

Disassembly of section .plt:

Disassembly of section .text:

000000000040e2e0 <p112w_FID_105_110_100_101_120_95_115_101_116_>:
  40e2e0:	f3 0f 1e fa          	endbr64 
  40e2e4:	55                   	push   %rbp
  40e2e5:	48 89 e5             	mov    %rsp,%rbp
  40e2e8:	48 81 ec 00 08 00 00 	sub    $0x800,%rsp
  40e2ef:	b9 00 00 00 00       	mov    $0x0,%ecx
  40e2f4:	48 8d 95 00 f8 ff ff 	lea    -0x800(%rbp),%rdx
  40e2fb:	be 31 02 00 00       	mov    $0x231,%esi
  40e300:	e8 eb 6e 01 00       	callq  4251f0 <p111_rt_closure>
  40e305:	48 89 85 00 f8 ff ff 	mov    %rax,-0x800(%rbp)
  40e30c:	c9                   	leaveq 
  40e30d:	c3                   	retq   

Disassembly of section .fini:
