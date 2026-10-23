
/home/ai/bend2/build/publish/bend/selfhost/build/phase111/p131-read-lookup01-identity-candidate-build/program:     file format elf64-x86-64


Disassembly of section .init:

Disassembly of section .plt:

Disassembly of section .text:

0000000000414350 <p111_FID_105_110_100_101_120_95_102_105_110_100_>:
  414350:	f3 0f 1e fa          	endbr64 
  414354:	55                   	push   %rbp
  414355:	48 89 e5             	mov    %rsp,%rbp
  414358:	48 81 ec 08 08 00 00 	sub    $0x808,%rsp
  41435f:	53                   	push   %rbx
  414360:	b9 00 00 00 00       	mov    $0x0,%ecx
  414365:	48 8d 95 00 f8 ff ff 	lea    -0x800(%rbp),%rdx
  41436c:	be f0 00 00 00       	mov    $0xf0,%esi
  414371:	48 89 fb             	mov    %rdi,%rbx
  414374:	e8 77 0e 01 00       	callq  4251f0 <p111_rt_closure>
  414379:	48 89 df             	mov    %rbx,%rdi
  41437c:	48 89 85 00 f8 ff ff 	mov    %rax,-0x800(%rbp)
  414383:	ba 01 00 00 00       	mov    $0x1,%edx
  414388:	48 8d b5 00 f8 ff ff 	lea    -0x800(%rbp),%rsi
  41438f:	e8 6c 10 01 00       	callq  425400 <p111_rt_return>
  414394:	5b                   	pop    %rbx
  414395:	c9                   	leaveq 
  414396:	c3                   	retq   

Disassembly of section .fini:
