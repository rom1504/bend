
/home/ai/bend2/build/publish/bend/selfhost/build/phase111/p131-read-lookup01-identity-original-build/program:     file format elf64-x86-64


Disassembly of section .init:

Disassembly of section .plt:

Disassembly of section .text:

0000000000418e30 <p111_FID_105_110_100_101_120_95_105_110_115_101_114_116_95_108_101_103_97_99_121_>:
  418e30:	f3 0f 1e fa          	endbr64 
  418e34:	55                   	push   %rbp
  418e35:	48 89 e5             	mov    %rsp,%rbp
  418e38:	48 81 ec 08 08 00 00 	sub    $0x808,%rsp
  418e3f:	53                   	push   %rbx
  418e40:	b9 00 00 00 00       	mov    $0x0,%ecx
  418e45:	48 8d 95 00 f8 ff ff 	lea    -0x800(%rbp),%rdx
  418e4c:	be d0 01 00 00       	mov    $0x1d0,%esi
  418e51:	48 89 fb             	mov    %rdi,%rbx
  418e54:	e8 77 c3 00 00       	callq  4251d0 <p111_rt_closure>
  418e59:	48 89 df             	mov    %rbx,%rdi
  418e5c:	48 89 85 00 f8 ff ff 	mov    %rax,-0x800(%rbp)
  418e63:	ba 01 00 00 00       	mov    $0x1,%edx
  418e68:	48 8d b5 00 f8 ff ff 	lea    -0x800(%rbp),%rsi
  418e6f:	e8 6c c5 00 00       	callq  4253e0 <p111_rt_return>
  418e74:	5b                   	pop    %rbx
  418e75:	c9                   	leaveq 
  418e76:	c3                   	retq   

Disassembly of section .fini:
