
/home/ai/bend2/build/publish/bend/selfhost/build/phase111/p131-read-lookup01-identity-original-build/program:     file format elf64-x86-64


Disassembly of section .init:

Disassembly of section .plt:

Disassembly of section .text:

0000000000413020 <p111_FID_105_110_100_101_120_95_98_117_99_107_101_116_>:
  413020:	f3 0f 1e fa          	endbr64 
  413024:	55                   	push   %rbp
  413025:	48 89 e5             	mov    %rsp,%rbp
  413028:	48 81 ec 08 08 00 00 	sub    $0x808,%rsp
  41302f:	53                   	push   %rbx
  413030:	b9 00 00 00 00       	mov    $0x0,%ecx
  413035:	48 8d 95 00 f8 ff ff 	lea    -0x800(%rbp),%rdx
  41303c:	be e7 00 00 00       	mov    $0xe7,%esi
  413041:	48 89 fb             	mov    %rdi,%rbx
  413044:	e8 87 21 01 00       	callq  4251d0 <p111_rt_closure>
  413049:	48 89 df             	mov    %rbx,%rdi
  41304c:	48 89 85 00 f8 ff ff 	mov    %rax,-0x800(%rbp)
  413053:	ba 01 00 00 00       	mov    $0x1,%edx
  413058:	48 8d b5 00 f8 ff ff 	lea    -0x800(%rbp),%rsi
  41305f:	e8 7c 23 01 00       	callq  4253e0 <p111_rt_return>
  413064:	5b                   	pop    %rbx
  413065:	c9                   	leaveq 
  413066:	c3                   	retq   

Disassembly of section .fini:
