
/home/ai/bend2/build/publish/bend/selfhost/build/phase111/p131-read-lookup01-identity-original-build/program:     file format elf64-x86-64


Disassembly of section .init:

Disassembly of section .plt:

Disassembly of section .text:

0000000000413c90 <p111_FID_105_110_100_101_120_95_102_105_110_100_95_97_98_115_101_110_116_>:
  413c90:	f3 0f 1e fa          	endbr64 
  413c94:	55                   	push   %rbp
  413c95:	48 89 e5             	mov    %rsp,%rbp
  413c98:	48 81 ec 08 08 00 00 	sub    $0x808,%rsp
  413c9f:	53                   	push   %rbx
  413ca0:	b9 00 00 00 00       	mov    $0x0,%ecx
  413ca5:	48 8d 95 00 f8 ff ff 	lea    -0x800(%rbp),%rdx
  413cac:	be 03 01 00 00       	mov    $0x103,%esi
  413cb1:	48 89 fb             	mov    %rdi,%rbx
  413cb4:	e8 17 15 01 00       	callq  4251d0 <p111_rt_closure>
  413cb9:	48 89 df             	mov    %rbx,%rdi
  413cbc:	48 89 85 00 f8 ff ff 	mov    %rax,-0x800(%rbp)
  413cc3:	ba 01 00 00 00       	mov    $0x1,%edx
  413cc8:	48 8d b5 00 f8 ff ff 	lea    -0x800(%rbp),%rsi
  413ccf:	e8 0c 17 01 00       	callq  4253e0 <p111_rt_return>
  413cd4:	5b                   	pop    %rbx
  413cd5:	c9                   	leaveq 
  413cd6:	c3                   	retq   

Disassembly of section .fini:
