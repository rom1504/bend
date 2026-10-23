
/home/ai/bend2/build/publish/bend/selfhost/build/phase111/p131-read-lookup01-identity-original-build/program:     file format elf64-x86-64


Disassembly of section .init:

Disassembly of section .plt:

Disassembly of section .text:

0000000000413660 <p111_FID_105_110_100_101_120_95_102_105_110_100_95_108_101_97_102_>:
  413660:	f3 0f 1e fa          	endbr64 
  413664:	55                   	push   %rbp
  413665:	48 89 e5             	mov    %rsp,%rbp
  413668:	48 81 ec 08 08 00 00 	sub    $0x808,%rsp
  41366f:	53                   	push   %rbx
  413670:	b9 00 00 00 00       	mov    $0x0,%ecx
  413675:	48 8d 95 00 f8 ff ff 	lea    -0x800(%rbp),%rdx
  41367c:	be f7 00 00 00       	mov    $0xf7,%esi
  413681:	48 89 fb             	mov    %rdi,%rbx
  413684:	e8 47 1b 01 00       	callq  4251d0 <p111_rt_closure>
  413689:	48 89 df             	mov    %rbx,%rdi
  41368c:	48 89 85 00 f8 ff ff 	mov    %rax,-0x800(%rbp)
  413693:	ba 01 00 00 00       	mov    $0x1,%edx
  413698:	48 8d b5 00 f8 ff ff 	lea    -0x800(%rbp),%rsi
  41369f:	e8 3c 1d 01 00       	callq  4253e0 <p111_rt_return>
  4136a4:	5b                   	pop    %rbx
  4136a5:	c9                   	leaveq 
  4136a6:	c3                   	retq   

Disassembly of section .fini:
