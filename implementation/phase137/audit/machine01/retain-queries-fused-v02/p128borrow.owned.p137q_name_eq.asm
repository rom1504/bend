
/home/ai/bend2/build/publish/bend/selfhost/build/phase111/p137-retain-query-builds01-wide-queries-fused-v02/program:     file format elf64-x86-64


Disassembly of section .init:

Disassembly of section .plt:

Disassembly of section .text:

000000000040a2c0 <p113d_FID_36_112_49_50_56_98_111_114_114_111_119_46_111_119_110_101_100_46_112_49_51_55_113_95_110_97_109_101_95_101_113_>:
  40a2c0:	endbr64 
  40a2c4:	push   %rbp
  40a2c5:	mov    %rsp,%rbp
  40a2c8:	sub    $0x838,%rsp
  40a2cf:	push   %rbx
  40a2d0:	push   %r12
  40a2d2:	push   %r13
  40a2d4:	push   %r14
  40a2d6:	push   %r15
  40a2d8:	mov    %rdx,%rax
  40a2db:	mov    %rax,%rcx
  40a2de:	shr    $0x28,%rcx
  40a2e2:	and    $0xffff,%rcx
  40a2e9:	cmp    $0x99,%rcx
  40a2f0:	sete   %dl
  40a2f3:	movzbl %dl,%edx
  40a2f6:	cmp    $0x0,%edx
  40a2f9:	jne    40a47e <p113d_FID_36_112_49_50_56_98_111_114_114_111_119_46_111_119_110_101_100_46_112_49_51_55_113_95_110_97_109_101_95_101_113_+0x1be>
  40a2ff:	nop
  40a300:	cmp    $0x9a,%rcx
  40a307:	je     40a3e5 <p113d_FID_36_112_49_50_56_98_111_114_114_111_119_46_111_119_110_101_100_46_112_49_51_55_113_95_110_97_109_101_95_101_113_+0x125>
  40a30d:	cmp    $0x9b,%rcx
  40a314:	je     40a338 <p113d_FID_36_112_49_50_56_98_111_114_114_111_119_46_111_119_110_101_100_46_112_49_51_55_113_95_110_97_109_101_95_101_113_+0x78>
  40a316:	mov    %rsi,%r12
  40a319:	mov    %rdi,%rbx
  40a31c:	callq  431fa0 <p111_rt_sink>
  40a321:	mov    %rbx,%rdi
  40a324:	mov    $0x4,%esi
  40a329:	callq  432730 <p111_rt_fail>
  40a32e:	mov    $0x0,%eax
  40a333:	jmpq   40a5c6 <p113d_FID_36_112_49_50_56_98_111_114_114_111_119_46_111_119_110_101_100_46_112_49_51_55_113_95_110_97_109_101_95_101_113_+0x306>
  40a338:	cs cs cs cs mov %rsi,%r12
  40a33f:	cs mov %rax,%rsi
  40a343:	lea    -0x830(%rbp),%rdx
  40a34a:	mov    %rdi,%rbx
  40a34d:	callq  437c20 <p125_rt_take4>
  40a352:	mov    %rbx,%rdi
  40a355:	mov    -0x820(%rbp),%rsi
  40a35c:	mov    -0x818(%rbp),%r13
  40a363:	mov    %rdi,%rbx
  40a366:	callq  431fa0 <p111_rt_sink>
  40a36b:	mov    %r13,%rsi
  40a36e:	mov    %rbx,%rdi
  40a371:	mov    %rdi,%rbx
  40a374:	callq  431fa0 <p111_rt_sink>
  40a379:	mov    %r12,%rsi
  40a37c:	mov    %rbx,%rdi
  40a37f:	mov    %rsi,%r12
  40a382:	movabs $0x100180000000000,%rsi
  40a38c:	mov    %rdi,%rbx
  40a38f:	callq  431f10 <p111_rt_keep>
  40a394:	mov    %r12,%rsi
  40a397:	mov    %rbx,%rdi
  40a39a:	mov    %rax,%r12
  40a39d:	mov    %rdi,%rbx
  40a3a0:	callq  431f10 <p111_rt_keep>
  40a3a5:	mov    %r12,%rsi
  40a3a8:	mov    %rbx,%rdi
  40a3ab:	mov    %rax,%r13
  40a3ae:	mov    $0x1,%ecx
  40a3b3:	mov    %r13,%rdx
  40a3b6:	mov    %rsi,%r12
  40a3b9:	mov    %rdi,%rbx
  40a3bc:	callq  405c00 <p113d_FID_36_100_105_114_101_99_116_46_112_56_56_95_115_116_114_105_110_103_95_101_113_95_103_111_>
  40a3c1:	mov    %r12,%rsi
  40a3c4:	mov    %rbx,%rdi
  40a3c7:	mov    %rax,%rbx
  40a3ca:	mov    %rdi,%r12
  40a3cd:	callq  431fa0 <p111_rt_sink>
  40a3d2:	mov    %r13,%rsi
  40a3d5:	mov    %r12,%rdi
  40a3d8:	callq  431fa0 <p111_rt_sink>
  40a3dd:	mov    %rbx,%rax
  40a3e0:	jmpq   40a5c6 <p113d_FID_36_112_49_50_56_98_111_114_114_111_119_46_111_119_110_101_100_46_112_49_51_55_113_95_110_97_109_101_95_101_113_+0x306>
  40a3e5:	mov    %rsi,%r12
  40a3e8:	mov    %rax,%rsi
  40a3eb:	lea    -0x830(%rbp),%rdx
  40a3f2:	mov    %rdi,%rbx
  40a3f5:	callq  437750 <p125_rt_take2>
  40a3fa:	mov    %r12,%rsi
  40a3fd:	mov    %rbx,%rdi
  40a400:	mov    %rsi,%r12
  40a403:	mov    -0x828(%rbp),%rsi
  40a40a:	mov    %rdi,%rbx
  40a40d:	callq  431fa0 <p111_rt_sink>
  40a412:	mov    %r12,%rsi
  40a415:	mov    %rbx,%rdi
  40a418:	mov    %rsi,%r12
  40a41b:	movabs $0x100180000000000,%rsi
  40a425:	mov    %rdi,%rbx
  40a428:	callq  431f10 <p111_rt_keep>
  40a42d:	mov    %r12,%rsi
  40a430:	mov    %rbx,%rdi
  40a433:	mov    %rax,%r12
  40a436:	mov    %rdi,%rbx
  40a439:	callq  431f10 <p111_rt_keep>
  40a43e:	mov    %r12,%rsi
  40a441:	mov    %rbx,%rdi
  40a444:	mov    %rax,%r13
  40a447:	mov    $0x1,%ecx
  40a44c:	mov    %r13,%rdx
  40a44f:	mov    %rsi,%r12
  40a452:	mov    %rdi,%rbx
  40a455:	callq  405c00 <p113d_FID_36_100_105_114_101_99_116_46_112_56_56_95_115_116_114_105_110_103_95_101_113_95_103_111_>
  40a45a:	mov    %r12,%rsi
  40a45d:	mov    %rbx,%rdi
  40a460:	mov    %rax,%rbx
  40a463:	mov    %rdi,%r12
  40a466:	callq  431fa0 <p111_rt_sink>
  40a46b:	mov    %r13,%rsi
  40a46e:	mov    %r12,%rdi
  40a471:	callq  431fa0 <p111_rt_sink>
  40a476:	mov    %rbx,%rax
  40a479:	jmpq   40a5c6 <p113d_FID_36_112_49_50_56_98_111_114_114_111_119_46_111_119_110_101_100_46_112_49_51_55_113_95_110_97_109_101_95_101_113_+0x306>
  40a47e:	mov    %rsi,%r12
  40a481:	mov    %rax,%rsi
  40a484:	mov    $0x9,%ecx
  40a489:	lea    -0x830(%rbp),%rdx
  40a490:	mov    %rdi,%rbx
  40a493:	callq  432190 <p111_rt_take>
  40a498:	mov    %rbx,%rdi
  40a49b:	mov    -0x830(%rbp),%r13
  40a4a2:	mov    -0x828(%rbp),%rsi
  40a4a9:	mov    -0x820(%rbp),%r14
  40a4b0:	mov    -0x818(%rbp),%r15
  40a4b7:	mov    -0x810(%rbp),%rbx
  40a4be:	mov    %rbx,-0x10(%rbp)
  40a4c2:	mov    -0x808(%rbp),%rbx
  40a4c9:	mov    %rbx,-0x18(%rbp)
  40a4cd:	mov    -0x800(%rbp),%rbx
  40a4d4:	mov    %rbx,-0x20(%rbp)
  40a4d8:	mov    -0x7f8(%rbp),%rbx
  40a4df:	mov    %rbx,-0x28(%rbp)
  40a4e3:	mov    -0x7f0(%rbp),%rbx
  40a4ea:	mov    %rbx,-0x30(%rbp)
  40a4ee:	mov    %rdi,%rbx
  40a4f1:	callq  431fa0 <p111_rt_sink>
  40a4f6:	mov    %r14,%rsi
  40a4f9:	mov    %rbx,%rdi
  40a4fc:	mov    -0x10(%rbp),%r14
  40a500:	mov    %rdi,%rbx
  40a503:	callq  431fa0 <p111_rt_sink>
  40a508:	mov    %r15,%rsi
  40a50b:	mov    %rbx,%rdi
  40a50e:	mov    -0x18(%rbp),%r15
  40a512:	mov    %rdi,%rbx
  40a515:	callq  431fa0 <p111_rt_sink>
  40a51a:	mov    %r14,%rsi
  40a51d:	mov    %rbx,%rdi
  40a520:	mov    -0x20(%rbp),%r14
  40a524:	mov    %rdi,%rbx
  40a527:	callq  431fa0 <p111_rt_sink>
  40a52c:	mov    %r15,%rsi
  40a52f:	mov    %rbx,%rdi
  40a532:	mov    -0x28(%rbp),%r15
  40a536:	mov    %rdi,%rbx
  40a539:	callq  431fa0 <p111_rt_sink>
  40a53e:	mov    %r14,%rsi
  40a541:	mov    %rbx,%rdi
  40a544:	mov    -0x30(%rbp),%r14
  40a548:	mov    %rdi,%rbx
  40a54b:	callq  431fa0 <p111_rt_sink>
  40a550:	mov    %r15,%rsi
  40a553:	mov    %rbx,%rdi
  40a556:	mov    %rdi,%rbx
  40a559:	callq  431fa0 <p111_rt_sink>
  40a55e:	mov    %r14,%rsi
  40a561:	mov    %rbx,%rdi
  40a564:	mov    %rdi,%rbx
  40a567:	callq  431fa0 <p111_rt_sink>
  40a56c:	mov    %r13,%rsi
  40a56f:	mov    %rbx,%rdi
  40a572:	mov    %rdi,%rbx
  40a575:	callq  431f10 <p111_rt_keep>
  40a57a:	mov    %r12,%rsi
  40a57d:	mov    %rbx,%rdi
  40a580:	mov    %rax,%r12
  40a583:	mov    %rdi,%rbx
  40a586:	callq  431f10 <p111_rt_keep>
  40a58b:	mov    %r12,%rsi
  40a58e:	mov    %rbx,%rdi
  40a591:	mov    %rax,%r13
  40a594:	mov    $0x1,%ecx
  40a599:	mov    %r13,%rdx
  40a59c:	mov    %rsi,%r12
  40a59f:	mov    %rdi,%rbx
  40a5a2:	callq  405c00 <p113d_FID_36_100_105_114_101_99_116_46_112_56_56_95_115_116_114_105_110_103_95_101_113_95_103_111_>
  40a5a7:	mov    %r12,%rsi
  40a5aa:	mov    %rbx,%rdi
  40a5ad:	mov    %rax,%rbx
  40a5b0:	mov    %rdi,%r12
  40a5b3:	callq  431fa0 <p111_rt_sink>
  40a5b8:	mov    %r13,%rsi
  40a5bb:	mov    %r12,%rdi
  40a5be:	callq  431fa0 <p111_rt_sink>
  40a5c3:	mov    %rbx,%rax
  40a5c6:	pop    %r15
  40a5c8:	pop    %r14
  40a5ca:	pop    %r13
  40a5cc:	pop    %r12
  40a5ce:	pop    %rbx
  40a5cf:	leaveq 
  40a5d0:	retq   

Disassembly of section .fini:
