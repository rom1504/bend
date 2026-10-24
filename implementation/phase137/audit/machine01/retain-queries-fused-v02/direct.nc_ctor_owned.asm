
/home/ai/bend2/build/publish/bend/selfhost/build/phase111/p137-retain-query-builds01-wide-queries-fused-v02/program:     file format elf64-x86-64


Disassembly of section .init:

Disassembly of section .plt:

Disassembly of section .text:

000000000040d220 <p113d_FID_36_100_105_114_101_99_116_46_110_99_95_99_116_111_114_95_111_119_110_101_100_>:
  40d220:	endbr64 
  40d224:	push   %rbp
  40d225:	mov    %rsp,%rbp
  40d228:	sub    $0x800,%rsp
  40d22f:	push   %rbx
  40d230:	push   %r12
  40d232:	push   %r13
  40d234:	push   %r14
  40d236:	mov    %rdx,%rbx
  40d239:	mov    %rbx,%rdx
  40d23c:	nopl   0x0(%rax)
  40d240:	mov    %rsi,%rax
  40d243:	shr    $0x28,%rax
  40d247:	and    $0xffff,%rax
  40d24d:	cmp    $0x11,%rax
  40d251:	je     40d519 <p113d_FID_36_100_105_114_101_99_116_46_110_99_95_99_116_111_114_95_111_119_110_101_100_+0x2f9>
  40d257:	nopw   0x0(%rax,%rax,1)
  40d260:	cmp    $0x12,%rax
  40d264:	jne    40d508 <p113d_FID_36_100_105_114_101_99_116_46_110_99_95_99_116_111_114_95_111_119_110_101_100_+0x2e8>
  40d26a:	mov    %rdx,%r14
  40d26d:	lea    -0x800(%rbp),%rdx
  40d274:	mov    %rdi,%rbx
  40d277:	callq  437750 <p125_rt_take2>
  40d27c:	mov    %rbx,%rdi
  40d27f:	mov    -0x800(%rbp),%rsi
  40d286:	mov    -0x7f8(%rbp),%r13
  40d28d:	mov    %rdi,%rbx
  40d290:	callq  431f10 <p111_rt_keep>
  40d295:	mov    %rbx,%rdi
  40d298:	mov    %rax,%rsi
  40d29b:	mov    %rsi,%r12
  40d29e:	mov    %rdi,%rbx
  40d2a1:	callq  40a260 <p113d_FID_36_100_105_114_101_99_116_46_112_49_51_55_113_95_105_115_95_97_100_116_>
  40d2a6:	mov    %r12,%rsi
  40d2a9:	mov    %rbx,%rdi
  40d2ac:	mov    %rax,%rcx
  40d2af:	cmp    $0x1,%rcx
  40d2b3:	sete   %al
  40d2b6:	movzbl %al,%eax
  40d2b9:	shr    $0x28,%rcx
  40d2bd:	and    $0x7fffff,%rcx
  40d2c4:	cmp    $0x10002,%rcx
  40d2cb:	sete   %cl
  40d2ce:	movzbl %cl,%ecx
  40d2d1:	mov    %eax,%ebx
  40d2d3:	or     %ecx,%ebx
  40d2d5:	jne    40d365 <p113d_FID_36_100_105_114_101_99_116_46_110_99_95_99_116_111_114_95_111_119_110_101_100_+0x145>
  40d2db:	mov    %rdi,%r12
  40d2de:	callq  431fa0 <p111_rt_sink>
  40d2e3:	mov    %r14,%rdx
  40d2e6:	mov    %r13,%rsi
  40d2e9:	mov    %r12,%rdi
  40d2ec:	mov    %ebx,%eax
  40d2ee:	xor    $0x1,%eax
  40d2f1:	je     40d32e <p113d_FID_36_100_105_114_101_99_116_46_110_99_95_99_116_111_114_95_111_119_110_101_100_+0x10e>
  40d2f3:	mov    $0x0,%ecx
  40d2f8:	mov    %rdx,%r12
  40d2fb:	lea    -0x800(%rbp),%rdx
  40d302:	mov    %rsi,%r13
  40d305:	mov    $0x0,%esi
  40d30a:	mov    %rdi,%rbx
  40d30d:	callq  432010 <p111_rt_ctor>
  40d312:	mov    %rbx,%rdi
  40d315:	mov    %rax,%rsi
  40d318:	mov    %rdi,%rbx
  40d31b:	callq  431fa0 <p111_rt_sink>
  40d320:	mov    %r12,%rdx
  40d323:	mov    %rbx,%rdi
  40d326:	mov    %r13,%rsi
  40d329:	jmpq   40d240 <p113d_FID_36_100_105_114_101_99_116_46_110_99_95_99_116_111_114_95_111_119_110_101_100_+0x20>
  40d32e:	cs mov %rsi,%r12
  40d332:	mov    %rdx,%rsi
  40d335:	mov    %rdi,%rbx
  40d338:	callq  431fa0 <p111_rt_sink>
  40d33d:	mov    %r12,%rsi
  40d340:	mov    %rbx,%rdi
  40d343:	mov    %rsi,%r12
  40d346:	mov    %rdi,%rbx
  40d349:	callq  431fa0 <p111_rt_sink>
  40d34e:	mov    %rbx,%rdi
  40d351:	mov    $0x4,%esi
  40d356:	callq  432730 <p111_rt_fail>
  40d35b:	mov    $0x0,%eax
  40d360:	jmpq   40d526 <p113d_FID_36_100_105_114_101_99_116_46_110_99_95_99_116_111_114_95_111_119_110_101_100_+0x306>
  40d365:	cs mov %r14,%rdx
  40d369:	mov    $0x0,%ecx
  40d36e:	mov    %rdx,%r14
  40d371:	lea    -0x800(%rbp),%rdx
  40d378:	mov    %rsi,%r12
  40d37b:	mov    $0x0,%esi
  40d380:	mov    %rdi,%rbx
  40d383:	callq  432010 <p111_rt_ctor>
  40d388:	mov    %rbx,%rdi
  40d38b:	mov    %rax,%rsi
  40d38e:	mov    %rdi,%rbx
  40d391:	callq  431fa0 <p111_rt_sink>
  40d396:	mov    %r14,%rdx
  40d399:	mov    %r12,%rsi
  40d39c:	mov    %rbx,%rdi
  40d39f:	mov    %rsi,%r12
  40d3a2:	mov    %rdx,%rsi
  40d3a5:	mov    %rdi,%rbx
  40d3a8:	callq  431f10 <p111_rt_keep>
  40d3ad:	mov    %r12,%rsi
  40d3b0:	mov    %rbx,%rdi
  40d3b3:	mov    %rax,%r14
  40d3b6:	mov    %rdi,%rbx
  40d3b9:	callq  431f10 <p111_rt_keep>
  40d3be:	mov    %rbx,%rdi
  40d3c1:	mov    %rax,%rsi
  40d3c4:	mov    %rsi,%r12
  40d3c7:	mov    %rdi,%rbx
  40d3ca:	callq  4076f0 <p113d_FID_36_100_105_114_101_99_116_46_100_99_>
  40d3cf:	mov    %r14,%rdx
  40d3d2:	mov    %rbx,%rdi
  40d3d5:	mov    %rax,%rsi
  40d3d8:	mov    %rdx,%r14
  40d3db:	mov    %rdi,%rbx
  40d3de:	callq  40c9e0 <p113d_FID_36_100_105_114_101_99_116_46_108_111_111_107_117_112_>
  40d3e3:	mov    %rbx,%rdi
  40d3e6:	mov    %rax,%rsi
  40d3e9:	mov    %rdi,%rbx
  40d3ec:	callq  409960 <p113d_FID_36_100_105_114_101_99_116_46_112_49_51_55_113_95_105_115_95_99_116_114_>
  40d3f1:	mov    %r12,%rsi
  40d3f4:	mov    %rbx,%rdi
  40d3f7:	mov    %rax,%rcx
  40d3fa:	cmp    $0x1,%rcx
  40d3fe:	sete   %al
  40d401:	movzbl %al,%eax
  40d404:	shr    $0x28,%rcx
  40d408:	and    $0x7fffff,%rcx
  40d40f:	cmp    $0x10002,%rcx
  40d416:	sete   %cl
  40d419:	movzbl %cl,%ecx
  40d41c:	mov    %eax,%ebx
  40d41e:	or     %ecx,%ebx
  40d420:	jne    40d4ac <p113d_FID_36_100_105_114_101_99_116_46_110_99_95_99_116_111_114_95_111_119_110_101_100_+0x28c>
  40d426:	mov    %rdi,%r12
  40d429:	callq  431fa0 <p111_rt_sink>
  40d42e:	mov    %r14,%rdx
  40d431:	mov    %r13,%rsi
  40d434:	mov    %r12,%rdi
  40d437:	mov    %ebx,%eax
  40d439:	xor    $0x1,%eax
  40d43c:	je     40d479 <p113d_FID_36_100_105_114_101_99_116_46_110_99_95_99_116_111_114_95_111_119_110_101_100_+0x259>
  40d43e:	mov    $0x0,%ecx
  40d443:	mov    %rdx,%r13
  40d446:	lea    -0x800(%rbp),%rdx
  40d44d:	mov    %rsi,%r12
  40d450:	mov    $0x0,%esi
  40d455:	mov    %rdi,%rbx
  40d458:	callq  432010 <p111_rt_ctor>
  40d45d:	mov    %rbx,%rdi
  40d460:	mov    %rax,%rsi
  40d463:	mov    %rdi,%rbx
  40d466:	callq  431fa0 <p111_rt_sink>
  40d46b:	mov    %r13,%rdx
  40d46e:	mov    %r12,%rsi
  40d471:	mov    %rbx,%rdi
  40d474:	jmpq   40d240 <p113d_FID_36_100_105_114_101_99_116_46_110_99_95_99_116_111_114_95_111_119_110_101_100_+0x20>
  40d479:	mov    %rsi,%r12
  40d47c:	mov    %rdx,%rsi
  40d47f:	mov    %rdi,%rbx
  40d482:	callq  431fa0 <p111_rt_sink>
  40d487:	mov    %r12,%rsi
  40d48a:	mov    %rbx,%rdi
  40d48d:	mov    %rsi,%r13
  40d490:	mov    %rdi,%rbx
  40d493:	callq  431fa0 <p111_rt_sink>
  40d498:	mov    %rbx,%rdi
  40d49b:	mov    $0x4,%esi
  40d4a0:	callq  432730 <p111_rt_fail>
  40d4a5:	mov    $0x0,%eax
  40d4aa:	jmp    40d526 <p113d_FID_36_100_105_114_101_99_116_46_110_99_95_99_116_111_114_95_111_119_110_101_100_+0x306>
  40d4ac:	mov    %rsi,%r12
  40d4af:	mov    %r14,%rsi
  40d4b2:	mov    %rsi,%r14
  40d4b5:	mov    %rdi,%rbx
  40d4b8:	callq  431fa0 <p111_rt_sink>
  40d4bd:	mov    %r13,%rsi
  40d4c0:	mov    %rbx,%rdi
  40d4c3:	mov    %rdi,%rbx
  40d4c6:	callq  431fa0 <p111_rt_sink>
  40d4cb:	mov    %r12,%rsi
  40d4ce:	mov    %rbx,%rdi
  40d4d1:	mov    $0x0,%ecx
  40d4d6:	lea    -0x800(%rbp),%rdx
  40d4dd:	mov    %rsi,%r12
  40d4e0:	mov    $0x0,%esi
  40d4e5:	mov    %rdi,%rbx
  40d4e8:	callq  432010 <p111_rt_ctor>
  40d4ed:	mov    %rbx,%rdi
  40d4f0:	mov    %rax,%rsi
  40d4f3:	mov    %rdi,%rbx
  40d4f6:	callq  431fa0 <p111_rt_sink>
  40d4fb:	mov    %r12,%rsi
  40d4fe:	mov    %rbx,%rdi
  40d501:	callq  407490 <p113d_FID_36_100_105_114_101_99_116_46_100_98_>
  40d506:	jmp    40d526 <p113d_FID_36_100_105_114_101_99_116_46_110_99_95_99_116_111_114_95_111_119_110_101_100_+0x306>
  40d508:	mov    $0x4,%esi
  40d50d:	callq  432730 <p111_rt_fail>
  40d512:	mov    $0x0,%eax
  40d517:	jmp    40d526 <p113d_FID_36_100_105_114_101_99_116_46_110_99_95_99_116_111_114_95_111_119_110_101_100_+0x306>
  40d519:	mov    %rdx,%rsi
  40d51c:	callq  431fa0 <p111_rt_sink>
  40d521:	mov    $0x0,%eax
  40d526:	pop    %r14
  40d528:	pop    %r13
  40d52a:	pop    %r12
  40d52c:	pop    %rbx
  40d52d:	leaveq 
  40d52e:	retq   

Disassembly of section .fini:
