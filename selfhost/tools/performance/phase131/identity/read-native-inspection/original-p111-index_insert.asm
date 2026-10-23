
/home/ai/bend2/build/publish/bend/selfhost/build/phase111/p131-read-lookup01-identity-original-build/program:     file format elf64-x86-64


Disassembly of section .init:

Disassembly of section .plt:

Disassembly of section .text:

000000000041aa00 <p111_FID_105_110_100_101_120_95_105_110_115_101_114_116_>:
  41aa00:	f3 0f 1e fa          	endbr64 
  41aa04:	55                   	push   %rbp
  41aa05:	48 89 e5             	mov    %rsp,%rbp
  41aa08:	48 81 ec 08 08 00 00 	sub    $0x808,%rsp
  41aa0f:	53                   	push   %rbx
  41aa10:	b9 00 00 00 00       	mov    $0x0,%ecx
  41aa15:	48 8d 95 00 f8 ff ff 	lea    -0x800(%rbp),%rdx
  41aa1c:	be ea 01 00 00       	mov    $0x1ea,%esi
  41aa21:	48 89 fb             	mov    %rdi,%rbx
  41aa24:	e8 a7 a7 00 00       	callq  4251d0 <p111_rt_closure>
  41aa29:	48 89 df             	mov    %rbx,%rdi
  41aa2c:	48 89 85 00 f8 ff ff 	mov    %rax,-0x800(%rbp)
  41aa33:	ba 01 00 00 00       	mov    $0x1,%edx
  41aa38:	48 8d b5 00 f8 ff ff 	lea    -0x800(%rbp),%rsi
  41aa3f:	e8 9c a9 00 00       	callq  4253e0 <p111_rt_return>
  41aa44:	5b                   	pop    %rbx
  41aa45:	c9                   	leaveq 
  41aa46:	c3                   	retq   

Disassembly of section .fini:
