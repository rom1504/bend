
/home/ai/bend2/build/publish/bend/selfhost/build/phase111/p131-read-lookup01-identity-original-build/program:     file format elf64-x86-64


Disassembly of section .init:

Disassembly of section .plt:

Disassembly of section .text:

0000000000413400 <p111_FID_105_110_100_101_120_95_102_105_110_100_95_104_97_115_104_>:
  413400:	f3 0f 1e fa          	endbr64 
  413404:	55                   	push   %rbp
  413405:	48 89 e5             	mov    %rsp,%rbp
  413408:	48 81 ec 08 08 00 00 	sub    $0x808,%rsp
  41340f:	53                   	push   %rbx
  413410:	b9 00 00 00 00       	mov    $0x0,%ecx
  413415:	48 8d 95 00 f8 ff ff 	lea    -0x800(%rbp),%rdx
  41341c:	be f0 00 00 00       	mov    $0xf0,%esi
  413421:	48 89 fb             	mov    %rdi,%rbx
  413424:	e8 a7 1d 01 00       	callq  4251d0 <p111_rt_closure>
  413429:	48 89 df             	mov    %rbx,%rdi
  41342c:	48 89 85 00 f8 ff ff 	mov    %rax,-0x800(%rbp)
  413433:	ba 01 00 00 00       	mov    $0x1,%edx
  413438:	48 8d b5 00 f8 ff ff 	lea    -0x800(%rbp),%rsi
  41343f:	e8 9c 1f 01 00       	callq  4253e0 <p111_rt_return>
  413444:	5b                   	pop    %rbx
  413445:	c9                   	leaveq 
  413446:	c3                   	retq   

Disassembly of section .fini:
