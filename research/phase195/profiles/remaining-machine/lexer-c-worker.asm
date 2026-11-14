
/home/ai/bend2/build/publish/bend/selfhost/build/phase184/bend-products01/lexer/bend-c/program:     file format elf64-x86-64


Disassembly of section .text:

0000000000013190 <NF_FID_36_112_114_111_100_117_99_116_46_115_116_101_112_46_97_116_>:
   13190:	push   rbp
   13191:	push   r15
   13193:	push   r14
   13195:	push   r13
   13197:	push   r12
   13199:	push   rbx
   1319a:	push   rax
   1319b:	mov    r10d,DWORD PTR [rsp+0x40]
   131a0:	mov    rax,rcx
   131a3:	shr    rax,0x28
   131a7:	movzx  eax,ax
   131aa:	cmp    eax,0xae
   131af:	je     1325b <NF_FID_36_112_114_111_100_117_99_116_46_115_116_101_112_46_97_116_+0xcb>
   131b5:	cmp    eax,0xad
   131ba:	je     13206 <NF_FID_36_112_114_111_100_117_99_116_46_115_116_101_112_46_97_116_+0x76>
   131bc:	cmp    eax,0xac
   131c1:	jne    13638 <NF_FID_36_112_114_111_100_117_99_116_46_115_116_101_112_46_97_116_+0x4a8>
   131c7:	mov    rax,r8
   131ca:	shr    rax,0x28
   131ce:	movzx  ecx,ax
   131d1:	add    ecx,0xffffff58
   131d7:	cmp    ecx,0x3
   131da:	ja     136b0 <NF_FID_36_112_114_111_100_117_99_116_46_115_116_101_112_46_97_116_+0x520>
   131e0:	movabs rax,0x100ac0000000000
   131ea:	lea    rsi,[rip+0xfffffffffffef11b]        # 230c <_IO_stdin_used+0x13c>
   131f1:	movsxd rcx,DWORD PTR [rsi+rcx*4]
   131f5:	add    rcx,rsi
   131f8:	jmp    rcx
   131fa:	xor    r9d,0x811c9dc5
   13201:	jmp    13589 <NF_FID_36_112_114_111_100_117_99_116_46_115_116_101_112_46_97_116_+0x3f9>
   13206:	movabs rax,0x7f00000000000000
   13210:	and    rax,rcx
   13213:	movabs r11,0x100000000000000
   1321d:	cmp    rax,r11
   13220:	je     1355e <NF_FID_36_112_114_111_100_117_99_116_46_115_116_101_112_46_97_116_+0x3ce>
   13226:	movabs r11,0xffffffff80
   13230:	or     r11,0x7f
   13234:	and    r11,rcx
   13237:	test   rcx,rcx
   1323a:	js     132cf <NF_FID_36_112_114_111_100_117_99_116_46_115_116_101_112_46_97_116_+0x13f>
   13240:	mov    rbx,rsi
   13243:	mov    rcx,QWORD PTR [rdi+r11*8]
   13247:	mov    rax,r11
   1324a:	cmp    rax,0x3108180
   13250:	jae    13340 <NF_FID_36_112_114_111_100_117_99_116_46_115_116_101_112_46_97_116_+0x1b0>
   13256:	jmp    1355b <NF_FID_36_112_114_111_100_117_99_116_46_115_116_101_112_46_97_116_+0x3cb>
   1325b:	movabs rax,0x7f00000000000000
   13265:	and    rax,rcx
   13268:	movabs r11,0x100000000000000
   13272:	cmp    rax,r11
   13275:	je     13423 <NF_FID_36_112_114_111_100_117_99_116_46_115_116_101_112_46_97_116_+0x293>
   1327b:	movabs r11,0xffffffff80
   13285:	or     r11,0x7f
   13289:	and    r11,rcx
   1328c:	test   rcx,rcx
   1328f:	js     13385 <NF_FID_36_112_114_111_100_117_99_116_46_115_116_101_112_46_97_116_+0x1f5>
   13295:	mov    rcx,QWORD PTR [rdi+r11*8]
   13299:	mov    rax,r11
   1329c:	cmp    rax,0x3108180
   132a2:	jae    133ef <NF_FID_36_112_114_111_100_117_99_116_46_115_116_101_112_46_97_116_+0x25f>
   132a8:	jmp    13423 <NF_FID_36_112_114_111_100_117_99_116_46_115_116_101_112_46_97_116_+0x293>
   132ad:	add    r9d,0xffffffd0
   132b1:	movabs rax,0x100ae0000000000
   132bb:	or     rax,r9
   132be:	jmp    135fc <NF_FID_36_112_114_111_100_117_99_116_46_115_116_101_112_46_97_116_+0x46c>
   132c3:	imul   ecx,r10d,0x9e3779b1
   132ca:	jmp    135ca <NF_FID_36_112_114_111_100_117_99_116_46_115_116_101_112_46_97_116_+0x43a>
   132cf:	mov    eax,DWORD PTR [rdi+r11*8+0x4]
   132d4:	mov    ebx,DWORD PTR [rdi+r11*8]
   132d8:	mov    ebp,ebx
   132da:	and    ebp,0xffffff
   132e0:	cmp    ebp,0x1
   132e3:	jne    134da <NF_FID_36_112_114_111_100_117_99_116_46_115_116_101_112_46_97_116_+0x34a>
   132e9:	mov    ecx,DWORD PTR [rdi+r11*8]
   132ed:	shl    rax,0x20
   132f1:	or     rax,rbx
   132f4:	shr    rax,0x18
   132f8:	mov    rcx,QWORD PTR [rdi+rax*8]
   132fc:	mov    rbx,QWORD PTR [rsi]
   132ff:	mov    QWORD PTR [rdi+r11*8],rbx
   13303:	mov    QWORD PTR [rsi],r11
   13306:	mov    r11,QWORD PTR [rsi+0x100]
   1330d:	inc    r11
   13310:	mov    QWORD PTR [rsi+0x100],r11
   13317:	cmp    BYTE PTR [rip+0x105ff2],0x1        # 119310 <KEEP_WORDS>
   1331e:	jne    1353f <NF_FID_36_112_114_111_100_117_99_116_46_115_116_101_112_46_97_116_+0x3af>
   13324:	cmp    r11,0x8000
   1332b:	jae    1353f <NF_FID_36_112_114_111_100_117_99_116_46_115_116_101_112_46_97_116_+0x3af>
   13331:	mov    rbx,rsi
   13334:	cmp    rax,0x3108180
   1333a:	jb     1355b <NF_FID_36_112_114_111_100_117_99_116_46_115_116_101_112_46_97_116_+0x3cb>
   13340:	mov    rsi,rbx
   13343:	mov    r11,QWORD PTR [rbx]
   13346:	mov    QWORD PTR [rdi+rax*8],r11
   1334a:	mov    QWORD PTR [rbx],rax
   1334d:	mov    rax,QWORD PTR [rbx+0x100]
   13354:	inc    rax
   13357:	mov    QWORD PTR [rbx+0x100],rax
   1335e:	cmp    BYTE PTR [rip+0x105fab],0x1        # 119310 <KEEP_WORDS>
   13365:	jne    13373 <NF_FID_36_112_114_111_100_117_99_116_46_115_116_101_112_46_97_116_+0x1e3>
   13367:	cmp    rax,0x8000
   1336d:	jb     1355e <NF_FID_36_112_114_111_100_117_99_116_46_115_116_101_112_46_97_116_+0x3ce>
   13373:	mov    rax,rdx
   13376:	xor    edx,edx
   13378:	call   153a1 <heap_hand>
   1337d:	mov    rdx,rax
   13380:	jmp    1355e <NF_FID_36_112_114_111_100_117_99_116_46_115_116_101_112_46_97_116_+0x3ce>
   13385:	mov    eax,DWORD PTR [rdi+r11*8+0x4]
   1338a:	mov    ebx,DWORD PTR [rdi+r11*8]
   1338e:	mov    ebp,ebx
   13390:	and    ebp,0xffffff
   13396:	cmp    ebp,0x1
   13399:	jne    1350b <NF_FID_36_112_114_111_100_117_99_116_46_115_116_101_112_46_97_116_+0x37b>
   1339f:	mov    ecx,DWORD PTR [rdi+r11*8]
   133a3:	shl    rax,0x20
   133a7:	or     rax,rbx
   133aa:	shr    rax,0x18
   133ae:	mov    rcx,QWORD PTR [rdi+rax*8]
   133b2:	mov    rbx,QWORD PTR [rsi]
   133b5:	mov    QWORD PTR [rdi+r11*8],rbx
   133b9:	mov    QWORD PTR [rsi],r11
   133bc:	mov    r11,QWORD PTR [rsi+0x100]
   133c3:	inc    r11
   133c6:	mov    QWORD PTR [rsi+0x100],r11
   133cd:	cmp    BYTE PTR [rip+0x105f3c],0x1        # 119310 <KEEP_WORDS>
   133d4:	jne    1361a <NF_FID_36_112_114_111_100_117_99_116_46_115_116_101_112_46_97_116_+0x48a>
   133da:	cmp    r11,0x8000
   133e1:	jae    1361a <NF_FID_36_112_114_111_100_117_99_116_46_115_116_101_112_46_97_116_+0x48a>
   133e7:	cmp    rax,0x3108180
   133ed:	jb     13423 <NF_FID_36_112_114_111_100_117_99_116_46_115_116_101_112_46_97_116_+0x293>
   133ef:	mov    r11,QWORD PTR [rsi]
   133f2:	mov    QWORD PTR [rdi+rax*8],r11
   133f6:	mov    QWORD PTR [rsi],rax
   133f9:	mov    rax,QWORD PTR [rsi+0x100]
   13400:	inc    rax
   13403:	mov    QWORD PTR [rsi+0x100],rax
   1340a:	cmp    BYTE PTR [rip+0x105eff],0x1        # 119310 <KEEP_WORDS>
   13411:	jne    134c8 <NF_FID_36_112_114_111_100_117_99_116_46_115_116_101_112_46_97_116_+0x338>
   13417:	cmp    rax,0x8000
   1341d:	jae    134c8 <NF_FID_36_112_114_111_100_117_99_116_46_115_116_101_112_46_97_116_+0x338>
   13423:	mov    rax,r8
   13426:	shr    rax,0x28
   1342a:	movzx  eax,ax
   1342d:	add    eax,0xffffff58
   13432:	cmp    eax,0x3
   13435:	ja     136b0 <NF_FID_36_112_114_111_100_117_99_116_46_115_116_101_112_46_97_116_+0x520>
   1343b:	lea    rsi,[rip+0xfffffffffffeeeaa]        # 22ec <_IO_stdin_used+0x11c>
   13442:	movsxd rax,DWORD PTR [rsi+rax*4]
   13446:	add    rax,rsi
   13449:	jmp    rax
   1344b:	xor    r9d,0x811c9dc5
   13452:	imul   esi,r9d,0x1000193
   13459:	movabs rax,0x100ad0000000000
   13463:	or     rax,rsi
   13466:	jmp    13472 <NF_FID_36_112_114_111_100_117_99_116_46_115_116_101_112_46_97_116_+0x2e2>
   13468:	movabs rax,0x100ac0000000000
   13472:	imul   esi,r10d,0x9e3779b1
   13479:	lea    r10d,[rcx+0x13c6e]
   13480:	xor    r10d,esi
   13483:	jmp    135fc <NF_FID_36_112_114_111_100_117_99_116_46_115_116_101_112_46_97_116_+0x46c>
   13488:	movabs rax,0x100ac0000000000
   13492:	imul   esi,r10d,0x9e3779b1
   13499:	add    ecx,0x13c6e
   1349f:	xor    ecx,esi
   134a1:	imul   ecx,ecx,0x9e3779b1
   134a7:	jmp    135ca <NF_FID_36_112_114_111_100_117_99_116_46_115_116_101_112_46_97_116_+0x43a>
   134ac:	lea    eax,[rcx+rcx*4]
   134af:	lea    ecx,[r9+rax*2]
   134b3:	add    ecx,0xffffffd0
   134b6:	movabs rax,0x100ae0000000000
   134c0:	or     rax,rcx
   134c3:	jmp    135fc <NF_FID_36_112_114_111_100_117_99_116_46_115_116_101_112_46_97_116_+0x46c>
   134c8:	mov    rax,rdx
   134cb:	xor    edx,edx
   134cd:	call   153a1 <heap_hand>
   134d2:	mov    rdx,rax
   134d5:	jmp    13423 <NF_FID_36_112_114_111_100_117_99_116_46_115_116_101_112_46_97_116_+0x293>
   134da:	shl    rax,0x20
   134de:	or     rax,rbx
   134e1:	shr    rax,0x18
   134e5:	mov    r14,QWORD PTR [rdi+rax*8]
   134e9:	mov    rbx,rdx
   134ec:	mov    rdx,rcx
   134ef:	mov    rcx,rax
   134f2:	mov    rax,r8
   134f5:	mov    r8d,0x1
   134fb:	call   15432 <span_fade>
   13500:	mov    r8,rax
   13503:	mov    rdx,rbx
   13506:	mov    rcx,r14
   13509:	jmp    1355e <NF_FID_36_112_114_111_100_117_99_116_46_115_116_101_112_46_97_116_+0x3ce>
   1350b:	shl    rax,0x20
   1350f:	or     rax,rbx
   13512:	shr    rax,0x18
   13516:	mov    r14,QWORD PTR [rdi+rax*8]
   1351a:	mov    rbx,rdx
   1351d:	mov    rdx,rcx
   13520:	mov    rcx,rax
   13523:	mov    rax,r8
   13526:	mov    r8d,0x1
   1352c:	call   15432 <span_fade>
   13531:	mov    r8,rax
   13534:	mov    rdx,rbx
   13537:	mov    rcx,r14
   1353a:	jmp    13423 <NF_FID_36_112_114_111_100_117_99_116_46_115_116_101_112_46_97_116_+0x293>
   1353f:	mov    rbx,rsi
   13542:	mov    r14,rdx
   13545:	xor    edx,edx
   13547:	call   153a1 <heap_hand>
   1354c:	mov    rdx,r14
   1354f:	cmp    rax,0x3108180
   13555:	jae    13340 <NF_FID_36_112_114_111_100_117_99_116_46_115_116_101_112_46_97_116_+0x1b0>
   1355b:	mov    rsi,rbx
   1355e:	mov    rax,r8
   13561:	shr    rax,0x28
   13565:	movzx  eax,ax
   13568:	add    eax,0xffffff58
   1356d:	cmp    eax,0x3
   13570:	ja     136b0 <NF_FID_36_112_114_111_100_117_99_116_46_115_116_101_112_46_97_116_+0x520>
   13576:	lea    rsi,[rip+0xfffffffffffeed7f]        # 22fc <_IO_stdin_used+0x12c>
   1357d:	movsxd rax,DWORD PTR [rsi+rax*4]
   13581:	add    rax,rsi
   13584:	jmp    rax
   13586:	xor    r9d,ecx
   13589:	imul   ecx,r9d,0x1000193
   13590:	movabs rax,0x100ad0000000000
   1359a:	or     rax,rcx
   1359d:	jmp    135fc <NF_FID_36_112_114_111_100_117_99_116_46_115_116_101_112_46_97_116_+0x46c>
   1359f:	movabs rax,0x100ac0000000000
   135a9:	jmp    135ea <NF_FID_36_112_114_111_100_117_99_116_46_115_116_101_112_46_97_116_+0x45a>
   135ab:	movabs rax,0x100ac0000000000
   135b5:	imul   esi,r10d,0x9e3779b1
   135bc:	add    ecx,0x9e37
   135c2:	xor    ecx,esi
   135c4:	imul   ecx,ecx,0x9e3779b1
   135ca:	add    r9d,0x1daa5
   135d1:	xor    r9d,ecx
   135d4:	mov    r10d,r9d
   135d7:	jmp    135fc <NF_FID_36_112_114_111_100_117_99_116_46_115_116_101_112_46_97_116_+0x46c>
   135d9:	add    r9d,0xffffffd0
   135dd:	movabs rax,0x100ae0000000000
   135e7:	or     rax,r9
   135ea:	imul   esi,r10d,0x9e3779b1
   135f1:	add    ecx,0x9e37
   135f7:	xor    ecx,esi
   135f9:	mov    r10d,ecx
   135fc:	mov    ecx,r10d
   135ff:	mov    QWORD PTR [rdx],rax
   13602:	mov    QWORD PTR [rdx+0x8],rcx
   13606:	mov    eax,0x1
   1360b:	add    rsp,0x8
   1360f:	pop    rbx
   13610:	pop    r12
   13612:	pop    r13
   13614:	pop    r14
   13616:	pop    r15
   13618:	pop    rbp
   13619:	ret    
   1361a:	mov    rbx,rdx
   1361d:	xor    edx,edx
   1361f:	call   153a1 <heap_hand>
   13624:	mov    rdx,rbx
   13627:	cmp    rax,0x3108180
   1362d:	jae    133ef <NF_FID_36_112_114_111_100_117_99_116_46_115_116_101_112_46_97_116_+0x25f>
   13633:	jmp    13423 <NF_FID_36_112_114_111_100_117_99_116_46_115_116_101_112_46_97_116_+0x293>
   13638:	mov    r15,rdi
   1363b:	mov    r14,rsi
   1363e:	mov    rbx,r8
   13641:	movabs r13,0x7e00000000000000
   1364b:	movabs r12,0xffffffff80
   13655:	test   rcx,r13
   13658:	sete   al
   1365b:	cmp    rcx,0xffffffffffffffff
   1365f:	sete   dl
   13662:	or     dl,al
   13664:	mov    rax,rcx
   13667:	and    rax,r12
   1366a:	cmp    rax,0x3108180
   13670:	setb   al
   13673:	or     al,dl
   13675:	jne    13685 <NF_FID_36_112_114_111_100_117_99_116_46_115_116_101_112_46_97_116_+0x4f5>
   13677:	mov    rdi,r15
   1367a:	mov    rsi,r14
   1367d:	mov    rdx,rcx
   13680:	call   76f0 <term_drop>
   13685:	test   rbx,r13
   13688:	sete   cl
   1368b:	cmp    rbx,0xffffffffffffffff
   1368f:	sete   dl
   13692:	or     dl,cl
   13694:	and    r12,rbx
   13697:	cmp    r12,0x3108180
   1369e:	setb   al
   136a1:	or     al,dl
   136a3:	jne    136eb <NF_FID_36_112_114_111_100_117_99_116_46_115_116_101_112_46_97_116_+0x55b>
   136a5:	mov    rdi,r15
   136a8:	mov    rsi,r14
   136ab:	mov    rdx,rbx
   136ae:	jmp    136e6 <NF_FID_36_112_114_111_100_117_99_116_46_115_116_101_112_46_97_116_+0x556>
   136b0:	movabs rax,0x7e00000000000000
   136ba:	test   r8,rax
   136bd:	sete   al
   136c0:	cmp    r8,0xffffffffffffffff
   136c4:	sete   cl
   136c7:	or     cl,al
   136c9:	movabs rax,0xffffffff80
   136d3:	and    rax,r8
   136d6:	cmp    rax,0x3108180
   136dc:	setb   al
   136df:	or     al,cl
   136e1:	jne    136eb <NF_FID_36_112_114_111_100_117_99_116_46_115_116_101_112_46_97_116_+0x55b>
   136e3:	mov    rdx,r8
   136e6:	call   76f0 <term_drop>
   136eb:	lea    rdi,[rip+0xfffffffffffef59e]        # 2c90 <FID_RESW_T+0x340>
   136f2:	call   15340 <err_fail>

Disassembly of section .init:

Disassembly of section .fini:

Disassembly of section .plt:
