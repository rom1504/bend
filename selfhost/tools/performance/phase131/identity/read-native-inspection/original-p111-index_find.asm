
/home/ai/bend2/build/publish/bend/selfhost/build/phase111/p131-read-lookup01-identity-original-build/program:     file format elf64-x86-64


Disassembly of section .init:

Disassembly of section .plt:

Disassembly of section .text:

0000000000414120 <p111_FID_105_110_100_101_120_95_102_105_110_100_>:
  414120:	f3 0f 1e fa          	endbr64 
  414124:	55                   	push   %rbp
  414125:	48 89 e5             	mov    %rsp,%rbp
  414128:	48 81 ec 08 08 00 00 	sub    $0x808,%rsp
  41412f:	53                   	push   %rbx
  414130:	b9 00 00 00 00       	mov    $0x0,%ecx
  414135:	48 8d 95 00 f8 ff ff 	lea    -0x800(%rbp),%rdx
  41413c:	be 0c 01 00 00       	mov    $0x10c,%esi
  414141:	48 89 fb             	mov    %rdi,%rbx
  414144:	e8 87 10 01 00       	callq  4251d0 <p111_rt_closure>
  414149:	48 89 df             	mov    %rbx,%rdi
  41414c:	48 89 85 00 f8 ff ff 	mov    %rax,-0x800(%rbp)
  414153:	ba 01 00 00 00       	mov    $0x1,%edx
  414158:	48 8d b5 00 f8 ff ff 	lea    -0x800(%rbp),%rsi
  41415f:	e8 7c 12 01 00       	callq  4253e0 <p111_rt_return>
  414164:	5b                   	pop    %rbx
  414165:	c9                   	leaveq 
  414166:	c3                   	retq   

Disassembly of section .fini:
