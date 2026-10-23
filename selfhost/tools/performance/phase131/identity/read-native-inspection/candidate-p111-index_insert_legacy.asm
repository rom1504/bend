
/home/ai/bend2/build/publish/bend/selfhost/build/phase111/p131-read-lookup01-identity-candidate-build/program:     file format elf64-x86-64


Disassembly of section .init:

Disassembly of section .plt:

Disassembly of section .text:

0000000000418e50 <p111_FID_105_110_100_101_120_95_105_110_115_101_114_116_95_108_101_103_97_99_121_>:
  418e50:	f3 0f 1e fa          	endbr64 
  418e54:	55                   	push   %rbp
  418e55:	48 89 e5             	mov    %rsp,%rbp
  418e58:	48 81 ec 08 08 00 00 	sub    $0x808,%rsp
  418e5f:	53                   	push   %rbx
  418e60:	b9 00 00 00 00       	mov    $0x0,%ecx
  418e65:	48 8d 95 00 f8 ff ff 	lea    -0x800(%rbp),%rdx
  418e6c:	be ba 01 00 00       	mov    $0x1ba,%esi
  418e71:	48 89 fb             	mov    %rdi,%rbx
  418e74:	e8 77 c3 00 00       	callq  4251f0 <p111_rt_closure>
  418e79:	48 89 df             	mov    %rbx,%rdi
  418e7c:	48 89 85 00 f8 ff ff 	mov    %rax,-0x800(%rbp)
  418e83:	ba 01 00 00 00       	mov    $0x1,%edx
  418e88:	48 8d b5 00 f8 ff ff 	lea    -0x800(%rbp),%rsi
  418e8f:	e8 6c c5 00 00       	callq  425400 <p111_rt_return>
  418e94:	5b                   	pop    %rbx
  418e95:	c9                   	leaveq 
  418e96:	c3                   	retq   

Disassembly of section .fini:
