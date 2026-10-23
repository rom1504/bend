
/home/ai/bend2/build/publish/bend/selfhost/build/phase111/p131-read-lookup01-identity-candidate-build/program:     file format elf64-x86-64


Disassembly of section .init:

Disassembly of section .plt:

Disassembly of section .text:

0000000000413f70 <p111_FID_105_110_100_101_120_95_98_117_99_107_101_116_>:
  413f70:	f3 0f 1e fa          	endbr64 
  413f74:	55                   	push   %rbp
  413f75:	48 89 e5             	mov    %rsp,%rbp
  413f78:	48 81 ec 08 08 00 00 	sub    $0x808,%rsp
  413f7f:	53                   	push   %rbx
  413f80:	b9 00 00 00 00       	mov    $0x0,%ecx
  413f85:	48 8d 95 00 f8 ff ff 	lea    -0x800(%rbp),%rdx
  413f8c:	be e7 00 00 00       	mov    $0xe7,%esi
  413f91:	48 89 fb             	mov    %rdi,%rbx
  413f94:	e8 57 12 01 00       	callq  4251f0 <p111_rt_closure>
  413f99:	48 89 df             	mov    %rbx,%rdi
  413f9c:	48 89 85 00 f8 ff ff 	mov    %rax,-0x800(%rbp)
  413fa3:	ba 01 00 00 00       	mov    $0x1,%edx
  413fa8:	48 8d b5 00 f8 ff ff 	lea    -0x800(%rbp),%rsi
  413faf:	e8 4c 14 01 00       	callq  425400 <p111_rt_return>
  413fb4:	5b                   	pop    %rbx
  413fb5:	c9                   	leaveq 
  413fb6:	c3                   	retq   

Disassembly of section .fini:
