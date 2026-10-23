
/home/ai/bend2/build/publish/bend/selfhost/build/phase93/broad01/coverage-record-aggregation-256/upstream.program:     file format elf64-x86-64


Disassembly of section .text:

0000000000015130 <WL_FID_MAP_GET>:
   15130:	55                   	push   %rbp
   15131:	48 89 f3             	mov    %rsi,%rbx
   15134:	48 b8 ff ff ff ff ff 	movabs $0xffffffffff,%rax
   1513b:	00 00 00 
   1513e:	48 89 d6             	mov    %rdx,%rsi
   15141:	48 c1 ee 28          	shr    $0x28,%rsi
   15145:	66 83 fe 13          	cmp    $0x13,%si
   15149:	74 66                	je     151b1 <WL_FID_MAP_GET+0x81>
   1514b:	0f b7 f6             	movzwl %si,%esi
   1514e:	83 fe 12             	cmp    $0x12,%esi
   15151:	0f 85 c5 00 00 00    	jne    1521c <WL_FID_MAP_GET+0xec>
   15157:	48 83 f9 ff          	cmp    $0xffffffffffffffff,%rcx
   1515b:	74 2c                	je     15189 <WL_FID_MAP_GET+0x59>
   1515d:	48 ba 00 00 00 00 00 	movabs $0x7e00000000000000,%rdx
   15164:	00 00 7e 
   15167:	48 21 ca             	and    %rcx,%rdx
   1516a:	74 1d                	je     15189 <WL_FID_MAP_GET+0x59>
   1516c:	48 83 c0 81          	add    $0xffffffffffffff81,%rax
   15170:	48 21 c8             	and    %rcx,%rax
   15173:	48 3d 80 82 10 03    	cmp    $0x3108280,%rax
   15179:	72 0e                	jb     15189 <WL_FID_MAP_GET+0x59>
   1517b:	4c 89 e7             	mov    %r12,%rdi
   1517e:	4c 89 ee             	mov    %r13,%rsi
   15181:	48 89 ca             	mov    %rcx,%rdx
   15184:	e8 57 2a ff ff       	callq  7be0 <term_drop>
   15189:	41 8b 46 f8          	mov    -0x8(%r14),%eax
   1518d:	49 83 c6 f8          	add    $0xfffffffffffffff8,%r14
   15191:	48 8d 0d 28 a5 00 00 	lea    0xa528(%rip),%rcx        # 1f6c0 <wl_tab>
   15198:	48 8b 04 c1          	mov    (%rcx,%rax,8),%rax
   1519c:	48 be 00 00 00 00 00 	movabs $0x100120000000000,%rsi
   151a3:	12 00 01 
   151a6:	bf 02 00 00 00       	mov    $0x2,%edi
   151ab:	48 89 da             	mov    %rbx,%rdx
   151ae:	5d                   	pop    %rbp
   151af:	ff e0                	jmpq   *%rax
   151b1:	48 21 c2             	and    %rax,%rdx
   151b4:	48 89 d0             	mov    %rdx,%rax
   151b7:	49 8b 14 d4          	mov    (%r12,%rdx,8),%rdx
   151bb:	4d 8b 44 c4 08       	mov    0x8(%r12,%rax,8),%r8
   151c0:	49 8b 75 08          	mov    0x8(%r13),%rsi
   151c4:	49 89 34 c4          	mov    %rsi,(%r12,%rax,8)
   151c8:	49 89 45 08          	mov    %rax,0x8(%r13)
   151cc:	49 8b 85 08 01 00 00 	mov    0x108(%r13),%rax
   151d3:	48 83 c0 02          	add    $0x2,%rax
   151d7:	49 89 85 08 01 00 00 	mov    %rax,0x108(%r13)
   151de:	80 3d ab bf 00 00 01 	cmpb   $0x1,0xbfab(%rip)        # 21190 <KEEP_WORDS>
   151e5:	0f 85 a9 00 00 00    	jne    15294 <WL_FID_MAP_GET+0x164>
   151eb:	48 3d 00 80 00 00    	cmp    $0x8000,%rax
   151f1:	0f 83 9d 00 00 00    	jae    15294 <WL_FID_MAP_GET+0x164>
   151f7:	45 85 ff             	test   %r15d,%r15d
   151fa:	0f 84 b3 00 00 00    	je     152b3 <WL_FID_MAP_GET+0x183>
   15200:	49 89 1e             	mov    %rbx,(%r14)
   15203:	4d 89 46 08          	mov    %r8,0x8(%r14)
   15207:	49 c7 46 10 53 00 00 	movq   $0x53,0x10(%r14)
   1520e:	00 
   1520f:	49 83 c6 18          	add    $0x18,%r14
   15213:	48 89 ce             	mov    %rcx,%rsi
   15216:	5d                   	pop    %rbp
   15217:	e9 e4 f3 ff ff       	jmpq   14600 <WL_FID_STRING_CMP>
   1521c:	48 21 c2             	and    %rax,%rdx
   1521f:	48 89 d0             	mov    %rdx,%rax
   15222:	49 8b 14 d4          	mov    (%r12,%rdx,8),%rdx
   15226:	4d 8b 4c c4 08       	mov    0x8(%r12,%rax,8),%r9
   1522b:	4d 8b 44 c4 10       	mov    0x10(%r12,%rax,8),%r8
   15230:	49 8b 75 10          	mov    0x10(%r13),%rsi
   15234:	49 89 34 c4          	mov    %rsi,(%r12,%rax,8)
   15238:	49 89 45 10          	mov    %rax,0x10(%r13)
   1523c:	49 8b 85 10 01 00 00 	mov    0x110(%r13),%rax
   15243:	48 83 c0 04          	add    $0x4,%rax
   15247:	49 89 85 10 01 00 00 	mov    %rax,0x110(%r13)
   1524e:	80 3d 3b bf 00 00 01 	cmpb   $0x1,0xbf3b(%rip)        # 21190 <KEEP_WORDS>
   15255:	0f 85 10 01 00 00    	jne    1536b <WL_FID_MAP_GET+0x23b>
   1525b:	48 3d 00 80 00 00    	cmp    $0x8000,%rax
   15261:	0f 83 04 01 00 00    	jae    1536b <WL_FID_MAP_GET+0x23b>
   15267:	45 85 ff             	test   %r15d,%r15d
   1526a:	0f 84 1a 01 00 00    	je     1538a <WL_FID_MAP_GET+0x25a>
   15270:	49 89 1e             	mov    %rbx,(%r14)
   15273:	49 89 56 08          	mov    %rdx,0x8(%r14)
   15277:	4d 89 4e 10          	mov    %r9,0x10(%r14)
   1527b:	4d 89 46 18          	mov    %r8,0x18(%r14)
   1527f:	49 c7 46 20 54 00 00 	movq   $0x54,0x20(%r14)
   15286:	00 
   15287:	49 83 c6 28          	add    $0x28,%r14
   1528b:	48 89 ce             	mov    %rcx,%rsi
   1528e:	5d                   	pop    %rbp
   1528f:	e9 1c ca ff ff       	jmpq   11cb0 <WL_FID_MAP_BIT>
   15294:	4c 89 e7             	mov    %r12,%rdi
   15297:	4c 89 ee             	mov    %r13,%rsi
   1529a:	48 89 d0             	mov    %rdx,%rax
   1529d:	ba 01 00 00 00       	mov    $0x1,%edx
   152a2:	e8 2e 84 00 00       	callq  1d6d5 <heap_hand>
   152a7:	48 89 c2             	mov    %rax,%rdx
   152aa:	45 85 ff             	test   %r15d,%r15d
   152ad:	0f 85 4d ff ff ff    	jne    15200 <WL_FID_MAP_GET+0xd0>
   152b3:	4d 8b 56 e8          	mov    -0x18(%r14),%r10
   152b7:	4d 8b 4e f0          	mov    -0x10(%r14),%r9
   152bb:	49 8b 45 18          	mov    0x18(%r13),%rax
   152bf:	48 85 c0             	test   %rax,%rax
   152c2:	0f 84 7b 01 00 00    	je     15443 <WL_FID_MAP_GET+0x313>
   152c8:	49 8b 34 c4          	mov    (%r12,%rax,8),%rsi
   152cc:	49 89 75 18          	mov    %rsi,0x18(%r13)
   152d0:	49 83 85 18 01 00 00 	addq   $0xfffffffffffffff8,0x118(%r13)
   152d7:	f8 
   152d8:	66 0f 76 c0          	pcmpeqd %xmm0,%xmm0
   152dc:	f3 41 0f 7f 44 c4 10 	movdqu %xmm0,0x10(%r12,%rax,8)
   152e3:	49 c7 44 c4 20 ff ff 	movq   $0xffffffffffffffff,0x20(%r12,%rax,8)
   152ea:	ff ff 
   152ec:	4d 89 54 c4 28       	mov    %r10,0x28(%r12,%rax,8)
   152f1:	49 c1 e1 20          	shl    $0x20,%r9
   152f5:	49 ff c1             	inc    %r9
   152f8:	4d 89 4c c4 30       	mov    %r9,0x30(%r12,%rax,8)
   152fd:	49 89 1c c4          	mov    %rbx,(%r12,%rax,8)
   15301:	4d 89 44 c4 08       	mov    %r8,0x8(%r12,%rax,8)
   15306:	49 b8 00 00 00 00 00 	movabs $0x500530000000000,%r8
   1530d:	53 00 05 
   15310:	49 09 c0             	or     %rax,%r8
   15313:	4d 89 46 e8          	mov    %r8,-0x18(%r14)
   15317:	49 c7 46 f0 02 00 00 	movq   $0x2,-0x10(%r14)
   1531e:	00 
   1531f:	49 8b 45 10          	mov    0x10(%r13),%rax
   15323:	48 85 c0             	test   %rax,%rax
   15326:	0f 84 32 01 00 00    	je     1545e <WL_FID_MAP_GET+0x32e>
   1532c:	49 8b 34 c4          	mov    (%r12,%rax,8),%rsi
   15330:	49 89 75 10          	mov    %rsi,0x10(%r13)
   15334:	49 83 85 10 01 00 00 	addq   $0xfffffffffffffffc,0x110(%r13)
   1533b:	fc 
   1533c:	4d 89 44 c4 10       	mov    %r8,0x10(%r12,%rax,8)
   15341:	48 be 00 00 00 00 02 	movabs $0x200000000,%rsi
   15348:	00 00 00 
   1534b:	49 89 74 c4 18       	mov    %rsi,0x18(%r12,%rax,8)
   15350:	49 89 0c c4          	mov    %rcx,(%r12,%rax,8)
   15354:	49 89 54 c4 08       	mov    %rdx,0x8(%r12,%rax,8)
   15359:	48 b9 00 00 00 00 00 	movabs $0x500500000000000,%rcx
   15360:	50 00 05 
   15363:	48 09 c1             	or     %rax,%rcx
   15366:	48 89 c8             	mov    %rcx,%rax
   15369:	5d                   	pop    %rbp
   1536a:	c3                   	retq   
   1536b:	4c 89 e7             	mov    %r12,%rdi
   1536e:	4c 89 ee             	mov    %r13,%rsi
   15371:	48 89 d0             	mov    %rdx,%rax
   15374:	ba 02 00 00 00       	mov    $0x2,%edx
   15379:	e8 57 83 00 00       	callq  1d6d5 <heap_hand>
   1537e:	48 89 c2             	mov    %rax,%rdx
   15381:	45 85 ff             	test   %r15d,%r15d
   15384:	0f 85 e6 fe ff ff    	jne    15270 <WL_FID_MAP_GET+0x140>
   1538a:	4d 8b 7e e8          	mov    -0x18(%r14),%r15
   1538e:	4d 8b 56 f0          	mov    -0x10(%r14),%r10
   15392:	49 8b 45 18          	mov    0x18(%r13),%rax
   15396:	48 85 c0             	test   %rax,%rax
   15399:	0f 84 da 00 00 00    	je     15479 <WL_FID_MAP_GET+0x349>
   1539f:	49 8b 34 c4          	mov    (%r12,%rax,8),%rsi
   153a3:	49 89 75 18          	mov    %rsi,0x18(%r13)
   153a7:	49 83 85 18 01 00 00 	addq   $0xfffffffffffffff8,0x118(%r13)
   153ae:	f8 
   153af:	66 0f 76 c0          	pcmpeqd %xmm0,%xmm0
   153b3:	f3 41 0f 7f 44 c4 20 	movdqu %xmm0,0x20(%r12,%rax,8)
   153ba:	4d 89 7c c4 30       	mov    %r15,0x30(%r12,%rax,8)
   153bf:	49 c1 e2 20          	shl    $0x20,%r10
   153c3:	49 ff c2             	inc    %r10
   153c6:	4d 89 54 c4 38       	mov    %r10,0x38(%r12,%rax,8)
   153cb:	49 89 1c c4          	mov    %rbx,(%r12,%rax,8)
   153cf:	49 89 54 c4 08       	mov    %rdx,0x8(%r12,%rax,8)
   153d4:	4d 89 4c c4 10       	mov    %r9,0x10(%r12,%rax,8)
   153d9:	4d 89 44 c4 18       	mov    %r8,0x18(%r12,%rax,8)
   153de:	49 b8 00 00 00 00 00 	movabs $0x500540000000000,%r8
   153e5:	54 00 05 
   153e8:	49 09 c0             	or     %rax,%r8
   153eb:	4d 89 46 e8          	mov    %r8,-0x18(%r14)
   153ef:	49 c7 46 f0 04 00 00 	movq   $0x4,-0x10(%r14)
   153f6:	00 
   153f7:	49 8b 45 10          	mov    0x10(%r13),%rax
   153fb:	48 85 c0             	test   %rax,%rax
   153fe:	0f 84 90 00 00 00    	je     15494 <WL_FID_MAP_GET+0x364>
   15404:	49 8b 34 c4          	mov    (%r12,%rax,8),%rsi
   15408:	49 89 75 10          	mov    %rsi,0x10(%r13)
   1540c:	49 83 85 10 01 00 00 	addq   $0xfffffffffffffffc,0x110(%r13)
   15413:	fc 
   15414:	4d 89 44 c4 10       	mov    %r8,0x10(%r12,%rax,8)
   15419:	48 be 00 00 00 00 04 	movabs $0x400000000,%rsi
   15420:	00 00 00 
   15423:	49 89 74 c4 18       	mov    %rsi,0x18(%r12,%rax,8)
   15428:	49 89 0c c4          	mov    %rcx,(%r12,%rax,8)
   1542c:	49 89 54 c4 08       	mov    %rdx,0x8(%r12,%rax,8)
   15431:	48 b9 00 00 00 00 00 	movabs $0x5003c0000000000,%rcx
   15438:	3c 00 05 
   1543b:	48 09 c1             	or     %rax,%rcx
   1543e:	48 89 c8             	mov    %rcx,%rax
   15441:	5d                   	pop    %rbp
   15442:	c3                   	retq   
   15443:	4c 89 e7             	mov    %r12,%rdi
   15446:	4c 89 ee             	mov    %r13,%rsi
   15449:	49 89 d7             	mov    %rdx,%r15
   1544c:	ba 03 00 00 00       	mov    $0x3,%edx
   15451:	e8 d0 7e 00 00       	callq  1d326 <heap_alloc_miss>
   15456:	4c 89 fa             	mov    %r15,%rdx
   15459:	e9 7a fe ff ff       	jmpq   152d8 <WL_FID_MAP_GET+0x1a8>
   1545e:	4c 89 e7             	mov    %r12,%rdi
   15461:	4c 89 ee             	mov    %r13,%rsi
   15464:	49 89 d1             	mov    %rdx,%r9
   15467:	ba 02 00 00 00       	mov    $0x2,%edx
   1546c:	e8 b5 7e 00 00       	callq  1d326 <heap_alloc_miss>
   15471:	4c 89 ca             	mov    %r9,%rdx
   15474:	e9 c3 fe ff ff       	jmpq   1533c <WL_FID_MAP_GET+0x20c>
   15479:	4c 89 e7             	mov    %r12,%rdi
   1547c:	4c 89 ee             	mov    %r13,%rsi
   1547f:	48 89 d5             	mov    %rdx,%rbp
   15482:	ba 03 00 00 00       	mov    $0x3,%edx
   15487:	e8 9a 7e 00 00       	callq  1d326 <heap_alloc_miss>
   1548c:	48 89 ea             	mov    %rbp,%rdx
   1548f:	e9 1b ff ff ff       	jmpq   153af <WL_FID_MAP_GET+0x27f>
   15494:	4c 89 e7             	mov    %r12,%rdi
   15497:	4c 89 ee             	mov    %r13,%rsi
   1549a:	49 89 d1             	mov    %rdx,%r9
   1549d:	ba 02 00 00 00       	mov    $0x2,%edx
   154a2:	e8 7f 7e 00 00       	callq  1d326 <heap_alloc_miss>
   154a7:	4c 89 ca             	mov    %r9,%rdx
   154aa:	e9 65 ff ff ff       	jmpq   15414 <WL_FID_MAP_GET+0x2e4>

Disassembly of section .init:

Disassembly of section .fini:

Disassembly of section .plt:
