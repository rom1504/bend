
selfhost/build/phase111/p125-broad06-coverage-record-aggregation-256-build/program:     file format elf64-x86-64


Disassembly of section .init:

Disassembly of section .plt:

Disassembly of section .text:

0000000000422150 <p111_FID_36_100_105_114_101_99_116_46_77_97_112_46_98_105_116_46_97_116_>:
  422150:	f3 0f 1e fa          	endbr64 
  422154:	55                   	push   %rbp
  422155:	48 89 e5             	mov    %rsp,%rbp
  422158:	48 81 ec 00 08 00 00 	sub    $0x800,%rsp
  42215f:	53                   	push   %rbx
  422160:	41 54                	push   %r12
  422162:	48 8b 5f 28          	mov    0x28(%rdi),%rbx
  422166:	48 8b 77 30          	mov    0x30(%rdi),%rsi
  42216a:	48 89 f0             	mov    %rsi,%rax
  42216d:	48 c1 e8 28          	shr    $0x28,%rax
  422171:	48 25 ff ff 00 00    	and    $0xffff,%rax
  422177:	48 83 f8 08          	cmp    $0x8,%rax
  42217b:	74 3e                	je     4221bb <p111_FID_36_100_105_114_101_99_116_46_77_97_112_46_98_105_116_46_97_116_+0x6b>
  42217d:	49 89 f4             	mov    %rsi,%r12
  422180:	48 89 de             	mov    %rbx,%rsi
  422183:	48 89 fb             	mov    %rdi,%rbx
  422186:	e8 b5 cf 00 00       	callq  42f140 <p111_rt_sink>
  42218b:	4c 89 e6             	mov    %r12,%rsi
  42218e:	48 89 df             	mov    %rbx,%rdi
  422191:	48 89 b5 00 f8 ff ff 	mov    %rsi,-0x800(%rbp)
  422198:	48 8b 47 10          	mov    0x10(%rdi),%rax
  42219c:	48 89 30             	mov    %rsi,(%rax)
  42219f:	48 c7 40 08 81 02 00 	movq   $0x281,0x8(%rax)
  4221a6:	00 
  4221a7:	48 83 c0 10          	add    $0x10,%rax
  4221ab:	48 89 47 10          	mov    %rax,0x10(%rdi)
  4221af:	be 04 00 00 00       	mov    $0x4,%esi
  4221b4:	e8 17 d7 00 00       	callq  42f8d0 <p111_rt_fail>
  4221b9:	eb 4b                	jmp    422206 <p111_FID_36_100_105_114_101_99_116_46_77_97_112_46_98_105_116_46_97_116_+0xb6>
  4221bb:	48 8d 95 00 f8 ff ff 	lea    -0x800(%rbp),%rdx
  4221c2:	49 89 fc             	mov    %rdi,%r12
  4221c5:	e8 26 27 01 00       	callq  4348f0 <p125_rt_take2>
  4221ca:	4c 89 e7             	mov    %r12,%rdi
  4221cd:	48 8b 8d 00 f8 ff ff 	mov    -0x800(%rbp),%rcx
  4221d4:	48 8b 85 08 f8 ff ff 	mov    -0x7f8(%rbp),%rax
  4221db:	48 89 9d 00 f8 ff ff 	mov    %rbx,-0x800(%rbp)
  4221e2:	48 89 8d 08 f8 ff ff 	mov    %rcx,-0x7f8(%rbp)
  4221e9:	48 89 85 10 f8 ff ff 	mov    %rax,-0x7f0(%rbp)
  4221f0:	b9 03 00 00 00       	mov    $0x3,%ecx
  4221f5:	48 8d 95 00 f8 ff ff 	lea    -0x800(%rbp),%rdx
  4221fc:	be 75 02 00 00       	mov    $0x275,%esi
  422201:	e8 fa d4 00 00       	callq  42f700 <p111_rt_jump>
  422206:	41 5c                	pop    %r12
  422208:	5b                   	pop    %rbx
  422209:	c9                   	leaveq 
  42220a:	c3                   	retq   

Disassembly of section .fini:
