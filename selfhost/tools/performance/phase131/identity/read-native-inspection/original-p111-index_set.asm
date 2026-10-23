
/home/ai/bend2/build/publish/bend/selfhost/build/phase111/p131-read-lookup01-identity-original-build/program:     file format elf64-x86-64


Disassembly of section .init:

Disassembly of section .plt:

Disassembly of section .text:

000000000041d620 <p111_FID_105_110_100_101_120_95_115_101_116_>:
  41d620:	f3 0f 1e fa          	endbr64 
  41d624:	55                   	push   %rbp
  41d625:	48 89 e5             	mov    %rsp,%rbp
  41d628:	48 81 ec 08 08 00 00 	sub    $0x808,%rsp
  41d62f:	53                   	push   %rbx
  41d630:	b9 00 00 00 00       	mov    $0x0,%ecx
  41d635:	48 8d 95 00 f8 ff ff 	lea    -0x800(%rbp),%rdx
  41d63c:	be 47 02 00 00       	mov    $0x247,%esi
  41d641:	48 89 fb             	mov    %rdi,%rbx
  41d644:	e8 87 7b 00 00       	callq  4251d0 <p111_rt_closure>
  41d649:	48 89 df             	mov    %rbx,%rdi
  41d64c:	48 89 85 00 f8 ff ff 	mov    %rax,-0x800(%rbp)
  41d653:	ba 01 00 00 00       	mov    $0x1,%edx
  41d658:	48 8d b5 00 f8 ff ff 	lea    -0x800(%rbp),%rsi
  41d65f:	e8 7c 7d 00 00       	callq  4253e0 <p111_rt_return>
  41d664:	5b                   	pop    %rbx
  41d665:	c9                   	leaveq 
  41d666:	c3                   	retq   

Disassembly of section .fini:
