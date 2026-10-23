
/home/ai/bend2/build/publish/bend/selfhost/build/phase111/p126-observer32-coverage-record-aggregation-256-build/program:     file format elf64-x86-64


Disassembly of section .init:

Disassembly of section .plt:

Disassembly of section .text:

0000000000418140 <p111_FID_36_100_105_114_101_99_116_46_77_97_112_46_115_101_101_107_>:
  418140:	f3 0f 1e fa          	endbr64 
  418144:	55                   	push   %rbp
  418145:	48 89 e5             	mov    %rsp,%rbp
  418148:	48 81 ec 00 08 00 00 	sub    $0x800,%rsp
  41814f:	53                   	push   %rbx
  418150:	41 54                	push   %r12
  418152:	41 55                	push   %r13
  418154:	41 56                	push   %r14
  418156:	48 8b 77 28          	mov    0x28(%rdi),%rsi
  41815a:	4c 8b 67 30          	mov    0x30(%rdi),%r12
  41815e:	48 89 f0             	mov    %rsi,%rax
  418161:	48 c1 e8 28          	shr    $0x28,%rax
  418165:	48 25 ff ff 00 00    	and    $0xffff,%rax
  41816b:	48 83 f8 24          	cmp    $0x24,%rax
  41816f:	0f 94 c1             	sete   %cl
  418172:	0f b6 c9             	movzbl %cl,%ecx
  418175:	83 f9 00             	cmp    $0x0,%ecx
  418178:	0f 85 f0 01 00 00    	jne    41836e <p111_FID_36_100_105_114_101_99_116_46_77_97_112_46_115_101_101_107_+0x22e>
  41817e:	66 90                	xchg   %ax,%ax
  418180:	48 83 f8 25          	cmp    $0x25,%rax
  418184:	0f 84 06 01 00 00    	je     418290 <p111_FID_36_100_105_114_101_99_116_46_77_97_112_46_115_101_101_107_+0x150>
  41818a:	48 83 f8 26          	cmp    $0x26,%rax
  41818e:	0f 94 c0             	sete   %al
  418191:	0f b6 c0             	movzbl %al,%eax
  418194:	83 f8 00             	cmp    $0x0,%eax
  418197:	75 4c                	jne    4181e5 <p111_FID_36_100_105_114_101_99_116_46_77_97_112_46_115_101_101_107_+0xa5>
  418199:	2e 4c 89 a5 00 f8 ff 	mov    %r12,%cs:-0x800(%rbp)
  4181a0:	ff 
  4181a1:	48 8b 47 10          	mov    0x10(%rdi),%rax
  4181a5:	4c 89 20             	mov    %r12,(%rax)
  4181a8:	48 c7 40 08 65 01 00 	movq   $0x165,0x8(%rax)
  4181af:	00 
  4181b0:	48 83 c0 10          	add    $0x10,%rax
  4181b4:	48 89 47 10          	mov    %rax,0x10(%rdi)
  4181b8:	48 89 b5 00 f8 ff ff 	mov    %rsi,-0x800(%rbp)
  4181bf:	48 8b 47 10          	mov    0x10(%rdi),%rax
  4181c3:	48 89 30             	mov    %rsi,(%rax)
  4181c6:	48 c7 40 08 66 01 00 	movq   $0x166,0x8(%rax)
  4181cd:	00 
  4181ce:	48 83 c0 10          	add    $0x10,%rax
  4181d2:	48 89 47 10          	mov    %rax,0x10(%rdi)
  4181d6:	be 04 00 00 00       	mov    $0x4,%esi
  4181db:	e8 80 7c 01 00       	callq  42fe60 <p111_rt_fail>
  4181e0:	e9 02 02 00 00       	jmpq   4183e7 <p111_FID_36_100_105_114_101_99_116_46_77_97_112_46_115_101_101_107_+0x2a7>
  4181e5:	48 8d 95 00 f8 ff ff 	lea    -0x800(%rbp),%rdx
  4181ec:	48 89 fb             	mov    %rdi,%rbx
  4181ef:	e8 ec ce 01 00       	callq  4350e0 <p125_rt_take3>
  4181f4:	48 89 df             	mov    %rbx,%rdi
  4181f7:	48 8b b5 00 f8 ff ff 	mov    -0x800(%rbp),%rsi
  4181fe:	4c 8b b5 08 f8 ff ff 	mov    -0x7f8(%rbp),%r14
  418205:	4c 8b ad 10 f8 ff ff 	mov    -0x7f0(%rbp),%r13
  41820c:	48 89 fb             	mov    %rdi,%rbx
  41820f:	e8 2c 74 01 00       	callq  42f640 <p111_rt_keep>
  418214:	48 89 df             	mov    %rbx,%rdi
  418217:	48 89 c3             	mov    %rax,%rbx
  41821a:	48 89 9d 00 f8 ff ff 	mov    %rbx,-0x800(%rbp)
  418221:	4c 89 b5 08 f8 ff ff 	mov    %r14,-0x7f8(%rbp)
  418228:	4c 89 ad 10 f8 ff ff 	mov    %r13,-0x7f0(%rbp)
  41822f:	48 8d 95 00 f8 ff ff 	lea    -0x800(%rbp),%rdx
  418236:	be 26 00 00 00       	mov    $0x26,%esi
  41823b:	49 89 fd             	mov    %rdi,%r13
  41823e:	e8 cd cd 01 00       	callq  435010 <p125_rt_ctor3>
  418243:	4c 89 ef             	mov    %r13,%rdi
  418246:	48 89 c1             	mov    %rax,%rcx
  418249:	48 89 8d 00 f8 ff ff 	mov    %rcx,-0x800(%rbp)
  418250:	48 8b 47 10          	mov    0x10(%rdi),%rax
  418254:	48 89 08             	mov    %rcx,(%rax)
  418257:	48 c7 40 08 64 01 00 	movq   $0x164,0x8(%rax)
  41825e:	00 
  41825f:	48 83 c0 10          	add    $0x10,%rax
  418263:	48 89 47 10          	mov    %rax,0x10(%rdi)
  418267:	4c 89 a5 00 f8 ff ff 	mov    %r12,-0x800(%rbp)
  41826e:	48 89 9d 08 f8 ff ff 	mov    %rbx,-0x7f8(%rbp)
  418275:	b9 02 00 00 00       	mov    $0x2,%ecx
  41827a:	48 8d 95 00 f8 ff ff 	lea    -0x800(%rbp),%rdx
  418281:	be 85 02 00 00       	mov    $0x285,%esi
  418286:	e8 05 7a 01 00       	callq  42fc90 <p111_rt_jump>
  41828b:	e9 57 01 00 00       	jmpq   4183e7 <p111_FID_36_100_105_114_101_99_116_46_77_97_112_46_115_101_101_107_+0x2a7>
  418290:	4c 89 e3             	mov    %r12,%rbx
  418293:	48 8d 95 00 f8 ff ff 	lea    -0x800(%rbp),%rdx
  41829a:	49 89 fc             	mov    %rdi,%r12
  41829d:	e8 de cb 01 00       	callq  434e80 <p125_rt_take2>
  4182a2:	4c 89 e7             	mov    %r12,%rdi
  4182a5:	48 8b b5 00 f8 ff ff 	mov    -0x800(%rbp),%rsi
  4182ac:	49 89 dc             	mov    %rbx,%r12
  4182af:	48 8b 9d 08 f8 ff ff 	mov    -0x7f8(%rbp),%rbx
  4182b6:	49 89 fd             	mov    %rdi,%r13
  4182b9:	e8 82 73 01 00       	callq  42f640 <p111_rt_keep>
  4182be:	4c 89 ef             	mov    %r13,%rdi
  4182c1:	49 89 c5             	mov    %rax,%r13
  4182c4:	4c 89 ad 00 f8 ff ff 	mov    %r13,-0x800(%rbp)
  4182cb:	48 89 9d 08 f8 ff ff 	mov    %rbx,-0x7f8(%rbp)
  4182d2:	48 8d 95 00 f8 ff ff 	lea    -0x800(%rbp),%rdx
  4182d9:	be 25 00 00 00       	mov    $0x25,%esi
  4182de:	48 89 fb             	mov    %rdi,%rbx
  4182e1:	e8 aa ca 01 00       	callq  434d90 <p125_rt_ctor2>
  4182e6:	48 89 df             	mov    %rbx,%rdi
  4182e9:	48 89 c3             	mov    %rax,%rbx
  4182ec:	4c 89 ad 00 f8 ff ff 	mov    %r13,-0x800(%rbp)
  4182f3:	48 8d 95 00 f8 ff ff 	lea    -0x800(%rbp),%rdx
  4182fa:	be 0c 00 00 00       	mov    $0xc,%esi
  4182ff:	49 89 fd             	mov    %rdi,%r13
  418302:	e8 59 c8 01 00       	callq  434b60 <p125_rt_ctor1>
  418307:	4c 89 ef             	mov    %r13,%rdi
  41830a:	4c 89 a5 00 f8 ff ff 	mov    %r12,-0x800(%rbp)
  418311:	48 89 85 08 f8 ff ff 	mov    %rax,-0x7f8(%rbp)
  418318:	48 8d 95 00 f8 ff ff 	lea    -0x800(%rbp),%rdx
  41831f:	be 08 00 00 00       	mov    $0x8,%esi
  418324:	49 89 fc             	mov    %rdi,%r12
  418327:	e8 64 ca 01 00       	callq  434d90 <p125_rt_ctor2>
  41832c:	4c 89 e7             	mov    %r12,%rdi
  41832f:	48 89 9d 00 f8 ff ff 	mov    %rbx,-0x800(%rbp)
  418336:	48 89 85 08 f8 ff ff 	mov    %rax,-0x7f8(%rbp)
  41833d:	48 8d 95 00 f8 ff ff 	lea    -0x800(%rbp),%rdx
  418344:	be 08 00 00 00       	mov    $0x8,%esi
  418349:	48 89 fb             	mov    %rdi,%rbx
  41834c:	e8 3f ca 01 00       	callq  434d90 <p125_rt_ctor2>
  418351:	48 89 df             	mov    %rbx,%rdi
  418354:	48 89 85 00 f8 ff ff 	mov    %rax,-0x800(%rbp)
  41835b:	ba 01 00 00 00       	mov    $0x1,%edx
  418360:	48 8d b5 00 f8 ff ff 	lea    -0x800(%rbp),%rsi
  418367:	e8 84 79 01 00       	callq  42fcf0 <p111_rt_return>
  41836c:	eb 79                	jmp    4183e7 <p111_FID_36_100_105_114_101_99_116_46_77_97_112_46_115_101_101_107_+0x2a7>
  41836e:	4c 89 e3             	mov    %r12,%rbx
  418371:	48 89 9d 00 f8 ff ff 	mov    %rbx,-0x800(%rbp)
  418378:	48 b8 00 00 00 00 00 	movabs $0x1000b0000000000,%rax
  41837f:	0b 00 01 
  418382:	48 89 85 08 f8 ff ff 	mov    %rax,-0x7f8(%rbp)
  418389:	48 8d 95 00 f8 ff ff 	lea    -0x800(%rbp),%rdx
  418390:	be 08 00 00 00       	mov    $0x8,%esi
  418395:	48 89 fb             	mov    %rdi,%rbx
  418398:	e8 f3 c9 01 00       	callq  434d90 <p125_rt_ctor2>
  41839d:	48 89 df             	mov    %rbx,%rdi
  4183a0:	48 b9 00 00 00 00 00 	movabs $0x100240000000000,%rcx
  4183a7:	24 00 01 
  4183aa:	48 89 8d 00 f8 ff ff 	mov    %rcx,-0x800(%rbp)
  4183b1:	48 89 85 08 f8 ff ff 	mov    %rax,-0x7f8(%rbp)
  4183b8:	48 8d 95 00 f8 ff ff 	lea    -0x800(%rbp),%rdx
  4183bf:	be 08 00 00 00       	mov    $0x8,%esi
  4183c4:	48 89 fb             	mov    %rdi,%rbx
  4183c7:	e8 c4 c9 01 00       	callq  434d90 <p125_rt_ctor2>
  4183cc:	48 89 df             	mov    %rbx,%rdi
  4183cf:	48 89 85 00 f8 ff ff 	mov    %rax,-0x800(%rbp)
  4183d6:	ba 01 00 00 00       	mov    $0x1,%edx
  4183db:	48 8d b5 00 f8 ff ff 	lea    -0x800(%rbp),%rsi
  4183e2:	e8 09 79 01 00       	callq  42fcf0 <p111_rt_return>
  4183e7:	41 5e                	pop    %r14
  4183e9:	41 5d                	pop    %r13
  4183eb:	41 5c                	pop    %r12
  4183ed:	5b                   	pop    %rbx
  4183ee:	c9                   	leaveq 
  4183ef:	c3                   	retq   

Disassembly of section .fini:
