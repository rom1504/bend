
/home/ai/bend2/build/publish/bend/selfhost/build/phase111/p131-read-lookup01-identity-original-build/program:     file format elf64-x86-64


Disassembly of section .init:

Disassembly of section .plt:

Disassembly of section .text:

0000000000413110 <p111_FID_36_100_105_114_101_99_116_46_105_110_100_101_120_95_98_117_99_107_101_116_>:
  413110:	f3 0f 1e fa          	endbr64 
  413114:	55                   	push   %rbp
  413115:	48 89 e5             	mov    %rsp,%rbp
  413118:	48 83 ec 10          	sub    $0x10,%rsp
  41311c:	53                   	push   %rbx
  41311d:	41 54                	push   %r12
  41311f:	be 00 00 00 00       	mov    $0x0,%esi
  413124:	48 89 fb             	mov    %rdi,%rbx
  413127:	e8 04 24 01 00       	callq  425530 <p111_rt_reg_get>
  41312c:	48 89 df             	mov    %rbx,%rdi
  41312f:	48 89 c6             	mov    %rax,%rsi
  413132:	49 89 f4             	mov    %rsi,%r12
  413135:	be 01 00 00 00       	mov    $0x1,%esi
  41313a:	48 89 fb             	mov    %rdi,%rbx
  41313d:	e8 ee 23 01 00       	callq  425530 <p111_rt_reg_get>
  413142:	4c 89 e6             	mov    %r12,%rsi
  413145:	48 89 df             	mov    %rbx,%rdi
  413148:	48 89 c2             	mov    %rax,%rdx
  41314b:	48 89 fb             	mov    %rdi,%rbx
  41314e:	e8 ed 4b ff ff       	callq  407d40 <p113d_FID_36_100_105_114_101_99_116_46_105_110_100_101_120_95_98_117_99_107_101_116_>
  413153:	48 89 df             	mov    %rbx,%rdi
  413156:	48 89 45 f8          	mov    %rax,-0x8(%rbp)
  41315a:	ba 01 00 00 00       	mov    $0x1,%edx
  41315f:	48 8d 75 f8          	lea    -0x8(%rbp),%rsi
  413163:	e8 78 22 01 00       	callq  4253e0 <p111_rt_return>
  413168:	41 5c                	pop    %r12
  41316a:	5b                   	pop    %rbx
  41316b:	c9                   	leaveq 
  41316c:	c3                   	retq   

Disassembly of section .fini:
