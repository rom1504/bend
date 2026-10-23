
/home/ai/bend2/build/publish/bend/selfhost/build/phase111/p130-native01-n1/program:     file format elf64-x86-64


Disassembly of section .init:

Disassembly of section .plt:

Disassembly of section .text:

0000000000dc5e90 <p111_FID_36_100_105_114_101_99_116_46_105_110_100_101_120_95_98_117_99_107_101_116_>:
  dc5e90:	f3 0f 1e fa          	endbr64 
  dc5e94:	55                   	push   %rbp
  dc5e95:	48 89 e5             	mov    %rsp,%rbp
  dc5e98:	48 83 ec 10          	sub    $0x10,%rsp
  dc5e9c:	53                   	push   %rbx
  dc5e9d:	41 54                	push   %r12
  dc5e9f:	be 00 00 00 00       	mov    $0x0,%esi
  dc5ea4:	48 89 fb             	mov    %rdi,%rbx
  dc5ea7:	e8 04 1b 02 00       	callq  de79b0 <p111_rt_reg_get>
  dc5eac:	48 89 df             	mov    %rbx,%rdi
  dc5eaf:	48 89 c6             	mov    %rax,%rsi
  dc5eb2:	49 89 f4             	mov    %rsi,%r12
  dc5eb5:	be 01 00 00 00       	mov    $0x1,%esi
  dc5eba:	48 89 fb             	mov    %rdi,%rbx
  dc5ebd:	e8 ee 1a 02 00       	callq  de79b0 <p111_rt_reg_get>
  dc5ec2:	4c 89 e6             	mov    %r12,%rsi
  dc5ec5:	48 89 df             	mov    %rbx,%rdi
  dc5ec8:	48 89 c2             	mov    %rax,%rdx
  dc5ecb:	48 89 fb             	mov    %rdi,%rbx
  dc5ece:	e8 ad 46 6d ff       	callq  49a580 <p113d_FID_36_100_105_114_101_99_116_46_105_110_100_101_120_95_98_117_99_107_101_116_>
  dc5ed3:	48 89 df             	mov    %rbx,%rdi
  dc5ed6:	48 89 45 f8          	mov    %rax,-0x8(%rbp)
  dc5eda:	ba 01 00 00 00       	mov    $0x1,%edx
  dc5edf:	48 8d 75 f8          	lea    -0x8(%rbp),%rsi
  dc5ee3:	e8 78 19 02 00       	callq  de7860 <p111_rt_return>
  dc5ee8:	41 5c                	pop    %r12
  dc5eea:	5b                   	pop    %rbx
  dc5eeb:	c9                   	leaveq 
  dc5eec:	c3                   	retq   

Disassembly of section .fini:
