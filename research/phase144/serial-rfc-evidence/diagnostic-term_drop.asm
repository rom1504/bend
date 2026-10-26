
/home/ai/bend2/build/publish/bend/selfhost/build/phase144/profile01/runtime/program:     file format elf64-x86-64


Disassembly of section .init:

Disassembly of section .plt:

Disassembly of section .text:

0000000000f53140 <term_drop>:
  f53140:	41 57                	push   %r15
  f53142:	49 89 f0             	mov    %rsi,%r8
  f53145:	49 89 d1             	mov    %rdx,%r9
  f53148:	41 56                	push   %r14
  f5314a:	41 55                	push   %r13
  f5314c:	41 54                	push   %r12
  f5314e:	55                   	push   %rbp
  f5314f:	48 89 fd             	mov    %rdi,%rbp
  f53152:	53                   	push   %rbx
  f53153:	48 83 ec 18          	sub    $0x18,%rsp
  f53157:	44 8b 15 2a f6 21 00 	mov    0x21f62a(%rip),%r10d        # 1172788 <bp_counts_enabled>
  f5315e:	45 85 d2             	test   %r10d,%r10d
  f53161:	0f 85 79 03 00 00    	jne    f534e0 <term_drop+0x3a0>
  f53167:	49 bc ff ff ff ff ff 	movabs $0xffffffffff,%r12
  f5316e:	00 00 00 
  f53171:	45 31 db             	xor    %r11d,%r11d
  f53174:	31 db                	xor    %ebx,%ebx
  f53176:	49 bf 00 00 00 00 00 	movabs $0x10000000000,%r15
  f5317d:	01 00 00 
  f53180:	4d 89 de             	mov    %r11,%r14
  f53183:	4c 89 ca             	mov    %r9,%rdx
  f53186:	48 c1 ea 38          	shr    $0x38,%rdx
  f5318a:	f6 c2 7e             	test   $0x7e,%dl
  f5318d:	74 31                	je     f531c0 <term_drop+0x80>
  f5318f:	49 83 f9 ff          	cmp    $0xffffffffffffffff,%r9
  f53193:	74 2b                	je     f531c0 <term_drop+0x80>
  f53195:	48 8b 35 14 72 20 00 	mov    0x207214(%rip),%rsi        # 115a3b0 <p111_program_active>
  f5319c:	4c 89 c9             	mov    %r9,%rcx
  f5319f:	4c 21 e1             	and    %r12,%rcx
  f531a2:	48 8b 46 40          	mov    0x40(%rsi),%rax
  f531a6:	48 83 c0 7f          	add    $0x7f,%rax
  f531aa:	48 83 e0 80          	and    $0xffffffffffffff80,%rax
  f531ae:	48 05 00 82 10 03    	add    $0x3108200,%rax
  f531b4:	48 39 c1             	cmp    %rax,%rcx
  f531b7:	0f 83 e3 00 00 00    	jae    f532a0 <term_drop+0x160>
  f531bd:	0f 1f 00             	nopl   (%rax)
  f531c0:	48 85 db             	test   %rbx,%rbx
  f531c3:	0f 84 c8 00 00 00    	je     f53291 <term_drop+0x151>
  f531c9:	41 bd 01 00 00 00    	mov    $0x1,%r13d
  f531cf:	41 bb 01 00 00 00    	mov    $0x1,%r11d
  f531d5:	0f 1f 00             	nopl   (%rax)
  f531d8:	48 89 de             	mov    %rbx,%rsi
  f531db:	48 89 d9             	mov    %rbx,%rcx
  f531de:	48 89 d8             	mov    %rbx,%rax
  f531e1:	48 c1 ee 28          	shr    $0x28,%rsi
  f531e5:	48 c1 e9 38          	shr    $0x38,%rcx
  f531e9:	4c 21 e0             	and    %r12,%rax
  f531ec:	40 0f b6 f6          	movzbl %sil,%esi
  f531f0:	48 83 f9 3f          	cmp    $0x3f,%rcx
  f531f4:	0f 87 36 01 00 00    	ja     f53330 <term_drop+0x1f0>
  f531fa:	49 89 d9             	mov    %rbx,%r9
  f531fd:	89 f7                	mov    %esi,%edi
  f531ff:	89 ca                	mov    %ecx,%edx
  f53201:	49 c1 e9 30          	shr    $0x30,%r9
  f53205:	45 0f b6 c9          	movzbl %r9b,%r9d
  f53209:	41 39 f9             	cmp    %edi,%r9d
  f5320c:	0f 86 46 01 00 00    	jbe    f53358 <term_drop+0x218>
  f53212:	85 ff                	test   %edi,%edi
  f53214:	0f 84 1e 02 00 00    	je     f53438 <term_drop+0x2f8>
  f5321a:	89 fa                	mov    %edi,%edx
  f5321c:	48 01 c2             	add    %rax,%rdx
  f5321f:	4c 8b 4c d5 00       	mov    0x0(%rbp,%rdx,8),%r9
  f53224:	48 83 f9 3f          	cmp    $0x3f,%rcx
  f53228:	0f 86 e2 01 00 00    	jbe    f53410 <term_drop+0x2d0>
  f5322e:	83 c7 01             	add    $0x1,%edi
  f53231:	48 89 7c c5 08       	mov    %rdi,0x8(%rbp,%rax,8)
  f53236:	83 f9 3f             	cmp    $0x3f,%ecx
  f53239:	0f 86 d1 01 00 00    	jbe    f53410 <term_drop+0x2d0>
  f5323f:	83 fe 01             	cmp    $0x1,%esi
  f53242:	0f 86 c8 01 00 00    	jbe    f53410 <term_drop+0x2d0>
  f53248:	4c 89 c8             	mov    %r9,%rax
  f5324b:	48 c1 e8 38          	shr    $0x38,%rax
  f5324f:	a8 7e                	test   $0x7e,%al
  f53251:	74 85                	je     f531d8 <term_drop+0x98>
  f53253:	49 83 f9 ff          	cmp    $0xffffffffffffffff,%r9
  f53257:	0f 84 7b ff ff ff    	je     f531d8 <term_drop+0x98>
  f5325d:	48 8b 05 4c 71 20 00 	mov    0x20714c(%rip),%rax        # 115a3b0 <p111_program_active>
  f53264:	4c 89 ca             	mov    %r9,%rdx
  f53267:	4c 21 e2             	and    %r12,%rdx
  f5326a:	48 8b 40 40          	mov    0x40(%rax),%rax
  f5326e:	48 83 c0 7f          	add    $0x7f,%rax
  f53272:	48 83 e0 80          	and    $0xffffffffffffff80,%rax
  f53276:	48 05 00 82 10 03    	add    $0x3108200,%rax
  f5327c:	48 39 c2             	cmp    %rax,%rdx
  f5327f:	0f 83 fe fe ff ff    	jae    f53183 <term_drop+0x43>
  f53285:	0f 1f 00             	nopl   (%rax)
  f53288:	48 85 db             	test   %rbx,%rbx
  f5328b:	0f 85 47 ff ff ff    	jne    f531d8 <term_drop+0x98>
  f53291:	48 83 c4 18          	add    $0x18,%rsp
  f53295:	5b                   	pop    %rbx
  f53296:	5d                   	pop    %rbp
  f53297:	41 5c                	pop    %r12
  f53299:	41 5d                	pop    %r13
  f5329b:	41 5e                	pop    %r14
  f5329d:	41 5f                	pop    %r15
  f5329f:	c3                   	retq   
  f532a0:	4d 85 c9             	test   %r9,%r9
  f532a3:	0f 88 97 02 00 00    	js     f53540 <term_drop+0x400>
  f532a9:	83 e2 7f             	and    $0x7f,%edx
  f532ac:	48 83 fa 04          	cmp    $0x4,%rdx
  f532b0:	0f 84 51 03 00 00    	je     f53607 <term_drop+0x4c7>
  f532b6:	49 c1 e9 28          	shr    $0x28,%r9
  f532ba:	45 0f b7 c9          	movzwl %r9w,%r9d
  f532be:	48 83 fa 06          	cmp    $0x6,%rdx
  f532c2:	0f 84 f0 01 00 00    	je     f534b8 <term_drop+0x378>
  f532c8:	48 83 fa 02          	cmp    $0x2,%rdx
  f532cc:	0f 84 50 03 00 00    	je     f53622 <term_drop+0x4e2>
  f532d2:	48 8b 46 10          	mov    0x10(%rsi),%rax
  f532d6:	48 83 fa 03          	cmp    $0x3,%rdx
  f532da:	0f 84 f8 02 00 00    	je     f535d8 <term_drop+0x498>
  f532e0:	41 39 c1             	cmp    %eax,%r9d
  f532e3:	0f 82 63 03 00 00    	jb     f5364c <term_drop+0x50c>
  f532e9:	0f 84 bb 03 00 00    	je     f536aa <term_drop+0x56a>
  f532ef:	83 c0 01             	add    $0x1,%eax
  f532f2:	41 39 c1             	cmp    %eax,%r9d
  f532f5:	0f 84 87 03 00 00    	je     f53682 <term_drop+0x542>
  f532fb:	48 89 c8             	mov    %rcx,%rax
  f532fe:	48 83 fa 05          	cmp    $0x5,%rdx
  f53302:	0f 85 c1 01 00 00    	jne    f534c9 <term_drop+0x389>
  f53308:	31 ff                	xor    %edi,%edi
  f5330a:	be 02 00 00 00       	mov    $0x2,%esi
  f5330f:	90                   	nop
  f53310:	8d 56 ff             	lea    -0x1(%rsi),%edx
  f53313:	b8 20 00 00 00       	mov    $0x20,%eax
  f53318:	0f bd d2             	bsr    %edx,%edx
  f5331b:	83 f2 1f             	xor    $0x1f,%edx
  f5331e:	29 d0                	sub    %edx,%eax
  f53320:	48 c1 e0 38          	shl    $0x38,%rax
  f53324:	48 09 f8             	or     %rdi,%rax
  f53327:	48 09 c8             	or     %rcx,%rax
  f5332a:	e9 9a 01 00 00       	jmpq   f534c9 <term_drop+0x389>
  f5332f:	90                   	nop
  f53330:	89 ca                	mov    %ecx,%edx
  f53332:	45 89 e9             	mov    %r13d,%r9d
  f53335:	89 f7                	mov    %esi,%edi
  f53337:	83 e2 3f             	and    $0x3f,%edx
  f5333a:	41 d3 e1             	shl    %cl,%r9d
  f5333d:	83 fe 02             	cmp    $0x2,%esi
  f53340:	0f 85 c3 fe ff ff    	jne    f53209 <term_drop+0xc9>
  f53346:	8b 7c c5 08          	mov    0x8(%rbp,%rax,8),%edi
  f5334a:	41 39 f9             	cmp    %edi,%r9d
  f5334d:	0f 87 bf fe ff ff    	ja     f53212 <term_drop+0xd2>
  f53353:	0f 1f 44 00 00       	nopl   0x0(%rax,%rax,1)
  f53358:	89 d1                	mov    %edx,%ecx
  f5335a:	4c 89 de             	mov    %r11,%rsi
  f5335d:	48 8d 7c c5 00       	lea    0x0(%rbp,%rax,8),%rdi
  f53362:	44 8b 0d 1f f4 21 00 	mov    0x21f41f(%rip),%r9d        # 1172788 <bp_counts_enabled>
  f53369:	48 d3 e6             	shl    %cl,%rsi
  f5336c:	48 8b 1f             	mov    (%rdi),%rbx
  f5336f:	48 89 f1             	mov    %rsi,%rcx
  f53372:	45 85 c9             	test   %r9d,%r9d
  f53375:	74 69                	je     f533e0 <term_drop+0x2a0>
  f53377:	48 c7 c6 fc ff ff ff 	mov    $0xfffffffffffffffc,%rsi
  f5337e:	64 8b 36             	mov    %fs:(%rsi),%esi
  f53381:	83 fe ff             	cmp    $0xffffffff,%esi
  f53384:	0f 84 f6 00 00 00    	je     f53480 <term_drop+0x340>
  f5338a:	44 8b 15 0f f4 21 00 	mov    0x21f40f(%rip),%r10d        # 11727a0 <bp_rows>
  f53391:	45 8d 4a ff          	lea    -0x1(%r10),%r9d
  f53395:	44 39 ce             	cmp    %r9d,%esi
  f53398:	0f 82 eb 00 00 00    	jb     f53489 <term_drop+0x349>
  f5339e:	f0 48 83 05 09 f4 21 	lock addq $0x1,0x21f409(%rip)        # 11727b0 <bp_bad_contexts>
  f533a5:	00 01 
  f533a7:	8b 35 db f3 21 00    	mov    0x21f3db(%rip),%esi        # 1172788 <bp_counts_enabled>
  f533ad:	85 f6                	test   %esi,%esi
  f533af:	74 2f                	je     f533e0 <term_drop+0x2a0>
  f533b1:	48 c7 c6 fc ff ff ff 	mov    $0xfffffffffffffffc,%rsi
  f533b8:	64 8b 36             	mov    %fs:(%rsi),%esi
  f533bb:	83 fe ff             	cmp    $0xffffffff,%esi
  f533be:	0f 84 7c 00 00 00    	je     f53440 <term_drop+0x300>
  f533c4:	44 8b 15 d5 f3 21 00 	mov    0x21f3d5(%rip),%r10d        # 11727a0 <bp_rows>
  f533cb:	45 8d 4a ff          	lea    -0x1(%r10),%r9d
  f533cf:	44 39 ce             	cmp    %r9d,%esi
  f533d2:	72 75                	jb     f53449 <term_drop+0x309>
  f533d4:	f0 48 83 05 d3 f3 21 	lock addq $0x1,0x21f3d3(%rip)        # 11727b0 <bp_bad_contexts>
  f533db:	00 01 
  f533dd:	0f 1f 00             	nopl   (%rax)
  f533e0:	89 d6                	mov    %edx,%esi
  f533e2:	49 8d 34 f0          	lea    (%r8,%rsi,8),%rsi
  f533e6:	4c 8b 0e             	mov    (%rsi),%r9
  f533e9:	4c 89 0f             	mov    %r9,(%rdi)
  f533ec:	48 89 06             	mov    %rax,(%rsi)
  f533ef:	8d 42 20             	lea    0x20(%rdx),%eax
  f533f2:	49 8d 04 c0          	lea    (%r8,%rax,8),%rax
  f533f6:	48 03 08             	add    (%rax),%rcx
  f533f9:	48 89 08             	mov    %rcx,(%rax)
  f533fc:	8b 05 66 70 20 00    	mov    0x207066(%rip),%eax        # 115a468 <KEEP_WORDS>
  f53402:	48 39 c1             	cmp    %rax,%rcx
  f53405:	0f 82 7d fe ff ff    	jb     f53288 <term_drop+0x148>
  f5340b:	e9 21 fc 4a ff       	jmpq   403031 <term_drop.cold>
  f53410:	4c 89 c8             	mov    %r9,%rax
  f53413:	4c 01 fb             	add    %r15,%rbx
  f53416:	48 c1 e8 38          	shr    $0x38,%rax
  f5341a:	a8 7e                	test   $0x7e,%al
  f5341c:	0f 84 66 fe ff ff    	je     f53288 <term_drop+0x148>
  f53422:	49 83 f9 ff          	cmp    $0xffffffffffffffff,%r9
  f53426:	0f 84 5c fe ff ff    	je     f53288 <term_drop+0x148>
  f5342c:	e9 2c fe ff ff       	jmpq   f5325d <term_drop+0x11d>
  f53431:	0f 1f 80 00 00 00 00 	nopl   0x0(%rax)
  f53438:	4d 89 f1             	mov    %r14,%r9
  f5343b:	e9 f6 fd ff ff       	jmpq   f53236 <term_drop+0xf6>
  f53440:	8b 35 5a f3 21 00    	mov    0x21f35a(%rip),%esi        # 11727a0 <bp_rows>
  f53446:	83 ee 01             	sub    $0x1,%esi
  f53449:	48 c1 e6 04          	shl    $0x4,%rsi
  f5344d:	4c 8b 0d 64 f3 21 00 	mov    0x21f364(%rip),%r9        # 11727b8 <bp_counts>
  f53454:	49 89 ca             	mov    %rcx,%r10
  f53457:	48 83 c6 05          	add    $0x5,%rsi
  f5345b:	f0 4d 0f c1 14 f1    	lock xadd %r10,(%r9,%rsi,8)
  f53461:	48 89 ce             	mov    %rcx,%rsi
  f53464:	48 f7 d6             	not    %rsi
  f53467:	49 39 f2             	cmp    %rsi,%r10
  f5346a:	0f 86 70 ff ff ff    	jbe    f533e0 <term_drop+0x2a0>
  f53470:	c7 05 2e f3 21 00 01 	movl   $0x1,0x21f32e(%rip)        # 11727a8 <bp_overflow>
  f53477:	00 00 00 
  f5347a:	e9 61 ff ff ff       	jmpq   f533e0 <term_drop+0x2a0>
  f5347f:	90                   	nop
  f53480:	8b 35 1a f3 21 00    	mov    0x21f31a(%rip),%esi        # 11727a0 <bp_rows>
  f53486:	83 ee 01             	sub    $0x1,%esi
  f53489:	48 c1 e6 04          	shl    $0x4,%rsi
  f5348d:	4c 8b 0d 24 f3 21 00 	mov    0x21f324(%rip),%r9        # 11727b8 <bp_counts>
  f53494:	48 83 c6 03          	add    $0x3,%rsi
  f53498:	f0 49 83 04 f1 01    	lock addq $0x1,(%r9,%rsi,8)
  f5349e:	0f 85 03 ff ff ff    	jne    f533a7 <term_drop+0x267>
  f534a4:	c7 05 fa f2 21 00 01 	movl   $0x1,0x21f2fa(%rip)        # 11727a8 <bp_overflow>
  f534ab:	00 00 00 
  f534ae:	e9 f4 fe ff ff       	jmpq   f533a7 <term_drop+0x267>
  f534b3:	0f 1f 44 00 00       	nopl   0x0(%rax,%rax,1)
  f534b8:	4c 89 c8             	mov    %r9,%rax
  f534bb:	83 e0 1f             	and    $0x1f,%eax
  f534be:	48 83 c8 40          	or     $0x40,%rax
  f534c2:	48 c1 e0 38          	shl    $0x38,%rax
  f534c6:	48 09 c8             	or     %rcx,%rax
  f534c9:	48 8d 54 cd 00       	lea    0x0(%rbp,%rcx,8),%rdx
  f534ce:	4c 8b 32             	mov    (%rdx),%r14
  f534d1:	48 89 1a             	mov    %rbx,(%rdx)
  f534d4:	48 89 c3             	mov    %rax,%rbx
  f534d7:	e9 e4 fc ff ff       	jmpq   f531c0 <term_drop+0x80>
  f534dc:	0f 1f 40 00          	nopl   0x0(%rax)
  f534e0:	48 c7 c0 fc ff ff ff 	mov    $0xfffffffffffffffc,%rax
  f534e7:	64 8b 00             	mov    %fs:(%rax),%eax
  f534ea:	83 f8 ff             	cmp    $0xffffffff,%eax
  f534ed:	74 1b                	je     f5350a <term_drop+0x3ca>
  f534ef:	8b 1d ab f2 21 00    	mov    0x21f2ab(%rip),%ebx        # 11727a0 <bp_rows>
  f534f5:	8d 53 ff             	lea    -0x1(%rbx),%edx
  f534f8:	39 d0                	cmp    %edx,%eax
  f534fa:	72 17                	jb     f53513 <term_drop+0x3d3>
  f534fc:	f0 48 83 05 ab f2 21 	lock addq $0x1,0x21f2ab(%rip)        # 11727b0 <bp_bad_contexts>
  f53503:	00 01 
  f53505:	e9 5d fc ff ff       	jmpq   f53167 <term_drop+0x27>
  f5350a:	8b 05 90 f2 21 00    	mov    0x21f290(%rip),%eax        # 11727a0 <bp_rows>
  f53510:	83 e8 01             	sub    $0x1,%eax
  f53513:	48 c1 e0 04          	shl    $0x4,%rax
  f53517:	48 8b 15 9a f2 21 00 	mov    0x21f29a(%rip),%rdx        # 11727b8 <bp_counts>
  f5351e:	48 83 c0 08          	add    $0x8,%rax
  f53522:	f0 48 83 04 c2 01    	lock addq $0x1,(%rdx,%rax,8)
  f53528:	0f 85 39 fc ff ff    	jne    f53167 <term_drop+0x27>
  f5352e:	c7 05 70 f2 21 00 01 	movl   $0x1,0x21f270(%rip)        # 11727a8 <bp_overflow>
  f53535:	00 00 00 
  f53538:	e9 2a fc ff ff       	jmpq   f53167 <term_drop+0x27>
  f5353d:	0f 1f 00             	nopl   (%rax)
  f53540:	48 8d 44 cd 00       	lea    0x0(%rbp,%rcx,8),%rax
  f53545:	ba ff ff ff ff       	mov    $0xffffffff,%edx
  f5354a:	f0 0f c1 10          	lock xadd %edx,(%rax)
  f5354e:	81 e2 ff ff ff 00    	and    $0xffffff,%edx
  f53554:	83 fa 01             	cmp    $0x1,%edx
  f53557:	0f 85 63 fc ff ff    	jne    f531c0 <term_drop+0x80>
  f5355d:	8b 10                	mov    (%rax),%edx
  f5355f:	4c 89 c6             	mov    %r8,%rsi
  f53562:	48 89 ef             	mov    %rbp,%rdi
  f53565:	48 ba 00 00 00 00 00 	movabs $0x7fffff0000000000,%rdx
  f5356c:	ff ff 7f 
  f5356f:	49 21 d1             	and    %rdx,%r9
  f53572:	31 d2                	xor    %edx,%edx
  f53574:	4c 89 04 24          	mov    %r8,(%rsp)
  f53578:	48 8b 00             	mov    (%rax),%rax
  f5357b:	48 c1 e8 18          	shr    $0x18,%rax
  f5357f:	49 09 c1             	or     %rax,%r9
  f53582:	4c 89 4c 24 08       	mov    %r9,0x8(%rsp)
  f53587:	e8 24 d7 ff ff       	callq  f50cb0 <heap_free>
  f5358c:	4c 8b 4c 24 08       	mov    0x8(%rsp),%r9
  f53591:	4c 8b 04 24          	mov    (%rsp),%r8
  f53595:	4c 89 ca             	mov    %r9,%rdx
  f53598:	48 c1 ea 38          	shr    $0x38,%rdx
  f5359c:	f6 c2 7e             	test   $0x7e,%dl
  f5359f:	0f 84 1b fc ff ff    	je     f531c0 <term_drop+0x80>
  f535a5:	48 8b 35 04 6e 20 00 	mov    0x206e04(%rip),%rsi        # 115a3b0 <p111_program_active>
  f535ac:	4c 89 c9             	mov    %r9,%rcx
  f535af:	4c 21 e1             	and    %r12,%rcx
  f535b2:	48 8b 46 40          	mov    0x40(%rsi),%rax
  f535b6:	48 83 c0 7f          	add    $0x7f,%rax
  f535ba:	48 83 e0 80          	and    $0xffffffffffffff80,%rax
  f535be:	48 05 00 82 10 03    	add    $0x3108200,%rax
  f535c4:	48 39 c8             	cmp    %rcx,%rax
  f535c7:	0f 86 dc fc ff ff    	jbe    f532a9 <term_drop+0x169>
  f535cd:	e9 ee fb ff ff       	jmpq   f531c0 <term_drop+0x80>
  f535d2:	66 0f 1f 44 00 00    	nopw   0x0(%rax,%rax,1)
  f535d8:	41 39 c1             	cmp    %eax,%r9d
  f535db:	0f 82 8c 00 00 00    	jb     f5366d <term_drop+0x52d>
  f535e1:	0f 84 ee 00 00 00    	je     f536d5 <term_drop+0x595>
  f535e7:	83 c0 01             	add    $0x1,%eax
  f535ea:	41 39 c1             	cmp    %eax,%r9d
  f535ed:	0f 84 e9 00 00 00    	je     f536dc <term_drop+0x59c>
  f535f3:	48 bf 00 00 00 00 00 	movabs $0xffff000000000000,%rdi
  f535fa:	00 ff ff 
  f535fd:	be ff ff ff ff       	mov    $0xffffffff,%esi
  f53602:	e9 09 fd ff ff       	jmpq   f53310 <term_drop+0x1d0>
  f53607:	4c 89 c6             	mov    %r8,%rsi
  f5360a:	4c 89 ca             	mov    %r9,%rdx
  f5360d:	48 89 ef             	mov    %rbp,%rdi
  f53610:	4c 89 04 24          	mov    %r8,(%rsp)
  f53614:	e8 e7 03 00 00       	callq  f53a00 <blk_free>
  f53619:	4c 8b 04 24          	mov    (%rsp),%r8
  f5361d:	e9 9e fb ff ff       	jmpq   f531c0 <term_drop+0x80>
  f53622:	48 8b 86 80 00 00 00 	mov    0x80(%rsi),%rax
  f53629:	42 0f b6 34 08       	movzbl (%rax,%r9,1),%esi
  f5362e:	48 89 f0             	mov    %rsi,%rax
  f53631:	48 c1 e0 30          	shl    $0x30,%rax
  f53635:	48 89 c7             	mov    %rax,%rdi
  f53638:	83 fe 01             	cmp    $0x1,%esi
  f5363b:	0f 87 cf fc ff ff    	ja     f53310 <term_drop+0x1d0>
  f53641:	48 89 f8             	mov    %rdi,%rax
  f53644:	48 09 c8             	or     %rcx,%rax
  f53647:	e9 7d fe ff ff       	jmpq   f534c9 <term_drop+0x389>
  f5364c:	48 8b 46 68          	mov    0x68(%rsi),%rax
  f53650:	42 0f b6 34 08       	movzbl (%rax,%r9,1),%esi
  f53655:	48 89 f0             	mov    %rsi,%rax
  f53658:	48 c1 e0 30          	shl    $0x30,%rax
  f5365c:	48 89 c7             	mov    %rax,%rdi
  f5365f:	48 83 fa 05          	cmp    $0x5,%rdx
  f53663:	75 d3                	jne    f53638 <term_drop+0x4f8>
  f53665:	83 c6 02             	add    $0x2,%esi
  f53668:	e9 a3 fc ff ff       	jmpq   f53310 <term_drop+0x1d0>
  f5366d:	48 8b 46 68          	mov    0x68(%rsi),%rax
  f53671:	42 0f b6 34 08       	movzbl (%rax,%r9,1),%esi
  f53676:	83 ee 01             	sub    $0x1,%esi
  f53679:	48 89 f7             	mov    %rsi,%rdi
  f5367c:	48 c1 e7 30          	shl    $0x30,%rdi
  f53680:	eb b6                	jmp    f53638 <term_drop+0x4f8>
  f53682:	48 b8 00 00 00 00 00 	movabs $0x102000000000000,%rax
  f53689:	00 02 01 
  f5368c:	48 83 fa 05          	cmp    $0x5,%rdx
  f53690:	0f 85 91 fc ff ff    	jne    f53327 <term_drop+0x1e7>
  f53696:	48 bf 00 00 00 00 00 	movabs $0x2000000000000,%rdi
  f5369d:	00 02 00 
  f536a0:	be 04 00 00 00       	mov    $0x4,%esi
  f536a5:	e9 66 fc ff ff       	jmpq   f53310 <term_drop+0x1d0>
  f536aa:	48 b8 00 00 00 00 00 	movabs $0x1000000000000,%rax
  f536b1:	00 01 00 
  f536b4:	48 09 c8             	or     %rcx,%rax
  f536b7:	48 83 fa 05          	cmp    $0x5,%rdx
  f536bb:	0f 85 08 fe ff ff    	jne    f534c9 <term_drop+0x389>
  f536c1:	48 bf 00 00 00 00 00 	movabs $0x1000000000000,%rdi
  f536c8:	00 01 00 
  f536cb:	be 03 00 00 00       	mov    $0x3,%esi
  f536d0:	e9 3b fc ff ff       	jmpq   f53310 <term_drop+0x1d0>
  f536d5:	31 ff                	xor    %edi,%edi
  f536d7:	e9 65 ff ff ff       	jmpq   f53641 <term_drop+0x501>
  f536dc:	48 bf 00 00 00 00 00 	movabs $0x1000000000000,%rdi
  f536e3:	00 01 00 
  f536e6:	e9 56 ff ff ff       	jmpq   f53641 <term_drop+0x501>

Disassembly of section .fini:
