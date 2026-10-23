
/home/ai/bend2/build/publish/bend/selfhost/build/phase111/p130-native01-n1/program:     file format elf64-x86-64


Disassembly of section .init:

Disassembly of section .plt:

Disassembly of section .text:

0000000000dc7aa0 <p111_FID_36_100_105_114_101_99_116_46_112_49_49_49_118_95_103_101_116_>:
  dc7aa0:	f3 0f 1e fa          	endbr64 
  dc7aa4:	55                   	push   %rbp
  dc7aa5:	48 89 e5             	mov    %rsp,%rbp
  dc7aa8:	48 81 ec 08 08 00 00 	sub    $0x808,%rsp
  dc7aaf:	53                   	push   %rbx
  dc7ab0:	41 54                	push   %r12
  dc7ab2:	41 55                	push   %r13
  dc7ab4:	4c 8b 67 28          	mov    0x28(%rdi),%r12
  dc7ab8:	48 8b 77 30          	mov    0x30(%rdi),%rsi
  dc7abc:	48 89 fb             	mov    %rdi,%rbx
  dc7abf:	e8 ec f6 01 00       	callq  de71b0 <p111_rt_keep>
  dc7ac4:	48 89 df             	mov    %rbx,%rdi
  dc7ac7:	48 89 c3             	mov    %rax,%rbx
  dc7aca:	ba c5 9d 1c 81       	mov    $0x811c9dc5,%edx
  dc7acf:	48 89 de             	mov    %rbx,%rsi
  dc7ad2:	49 89 fd             	mov    %rdi,%r13
  dc7ad5:	e8 d6 14 80 ff       	callq  5c8fb0 <p112w_FID_36_100_105_114_101_99_116_46_105_110_100_101_120_95_104_97_115_104_>
  dc7ada:	4c 89 ef             	mov    %r13,%rdi
  dc7add:	4c 89 a5 00 f8 ff ff 	mov    %r12,-0x800(%rbp)
  dc7ae4:	48 89 9d 08 f8 ff ff 	mov    %rbx,-0x7f8(%rbp)
  dc7aeb:	48 89 85 10 f8 ff ff 	mov    %rax,-0x7f0(%rbp)
  dc7af2:	48 c7 85 18 f8 ff ff 	movq   $0x20,-0x7e8(%rbp)
  dc7af9:	20 00 00 00 
  dc7afd:	b9 04 00 00 00       	mov    $0x4,%ecx
  dc7b02:	48 8d 95 00 f8 ff ff 	lea    -0x800(%rbp),%rdx
  dc7b09:	be 81 b9 00 00       	mov    $0xb981,%esi
  dc7b0e:	e8 ed fc 01 00       	callq  de7800 <p111_rt_jump>
  dc7b13:	41 5d                	pop    %r13
  dc7b15:	41 5c                	pop    %r12
  dc7b17:	5b                   	pop    %rbx
  dc7b18:	c9                   	leaveq 
  dc7b19:	c3                   	retq   

Disassembly of section .fini:
