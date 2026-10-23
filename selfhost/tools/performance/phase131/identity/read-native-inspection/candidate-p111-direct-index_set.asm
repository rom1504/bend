
/home/ai/bend2/build/publish/bend/selfhost/build/phase111/p131-read-lookup01-identity-candidate-build/program:     file format elf64-x86-64


Disassembly of section .init:

Disassembly of section .plt:

Disassembly of section .text:

000000000041d820 <p111_FID_36_100_105_114_101_99_116_46_105_110_100_101_120_95_115_101_116_>:
  41d820:	f3 0f 1e fa          	endbr64 
  41d824:	55                   	push   %rbp
  41d825:	48 89 e5             	mov    %rsp,%rbp
  41d828:	48 81 ec 08 10 00 00 	sub    $0x1008,%rsp
  41d82f:	53                   	push   %rbx
  41d830:	41 54                	push   %r12
  41d832:	41 55                	push   %r13
  41d834:	48 8b 77 28          	mov    0x28(%rdi),%rsi
  41d838:	4c 8b 67 30          	mov    0x30(%rdi),%r12
  41d83c:	48 8b 5f 38          	mov    0x38(%rdi),%rbx
  41d840:	49 89 fd             	mov    %rdi,%r13
  41d843:	e8 08 75 00 00       	callq  424d50 <p111_rt_keep>
  41d848:	4c 89 ef             	mov    %r13,%rdi
  41d84b:	48 89 c6             	mov    %rax,%rsi
  41d84e:	48 89 b5 00 f0 ff ff 	mov    %rsi,-0x1000(%rbp)
  41d855:	4c 89 a5 08 f0 ff ff 	mov    %r12,-0xff8(%rbp)
  41d85c:	48 89 9d 10 f0 ff ff 	mov    %rbx,-0xff0(%rbp)
  41d863:	48 8b 47 10          	mov    0x10(%rdi),%rax
  41d867:	48 89 30             	mov    %rsi,(%rax)
  41d86a:	4c 89 60 08          	mov    %r12,0x8(%rax)
  41d86e:	48 89 58 10          	mov    %rbx,0x10(%rax)
  41d872:	48 c7 40 18 36 02 00 	movq   $0x236,0x18(%rax)
  41d879:	00 
  41d87a:	48 83 c0 20          	add    $0x20,%rax
  41d87e:	48 89 47 10          	mov    %rax,0x10(%rdi)
  41d882:	48 89 fb             	mov    %rdi,%rbx
  41d885:	e8 66 06 ff ff       	callq  40def0 <p112w_FID_36_100_105_114_101_99_116_46_100_107_>
  41d88a:	48 89 df             	mov    %rbx,%rdi
  41d88d:	48 89 85 00 f8 ff ff 	mov    %rax,-0x800(%rbp)
  41d894:	48 b8 2c 82 10 03 00 	movabs $0x20019000310822c,%rax
  41d89b:	19 00 02 
  41d89e:	48 89 85 08 f8 ff ff 	mov    %rax,-0x7f8(%rbp)
  41d8a5:	b9 02 00 00 00       	mov    $0x2,%ecx
  41d8aa:	48 8d 95 00 f8 ff ff 	lea    -0x800(%rbp),%rdx
  41d8b1:	be 26 02 00 00       	mov    $0x226,%esi
  41d8b6:	e8 e5 7a 00 00       	callq  4253a0 <p111_rt_jump>
  41d8bb:	41 5d                	pop    %r13
  41d8bd:	41 5c                	pop    %r12
  41d8bf:	5b                   	pop    %rbx
  41d8c0:	c9                   	leaveq 
  41d8c1:	c3                   	retq   

Disassembly of section .fini:
