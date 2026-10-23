
/home/ai/bend2/build/publish/bend/selfhost/build/phase111/p131-read-lookup01-identity-candidate-build/program:     file format elf64-x86-64


Disassembly of section .init:

Disassembly of section .plt:

Disassembly of section .text:

000000000041d640 <p111_FID_105_110_100_101_120_95_115_101_116_>:
  41d640:	f3 0f 1e fa          	endbr64 
  41d644:	55                   	push   %rbp
  41d645:	48 89 e5             	mov    %rsp,%rbp
  41d648:	48 81 ec 08 08 00 00 	sub    $0x808,%rsp
  41d64f:	53                   	push   %rbx
  41d650:	b9 00 00 00 00       	mov    $0x0,%ecx
  41d655:	48 8d 95 00 f8 ff ff 	lea    -0x800(%rbp),%rdx
  41d65c:	be 31 02 00 00       	mov    $0x231,%esi
  41d661:	48 89 fb             	mov    %rdi,%rbx
  41d664:	e8 87 7b 00 00       	callq  4251f0 <p111_rt_closure>
  41d669:	48 89 df             	mov    %rbx,%rdi
  41d66c:	48 89 85 00 f8 ff ff 	mov    %rax,-0x800(%rbp)
  41d673:	ba 01 00 00 00       	mov    $0x1,%edx
  41d678:	48 8d b5 00 f8 ff ff 	lea    -0x800(%rbp),%rsi
  41d67f:	e8 7c 7d 00 00       	callq  425400 <p111_rt_return>
  41d684:	5b                   	pop    %rbx
  41d685:	c9                   	leaveq 
  41d686:	c3                   	retq   

Disassembly of section .fini:
