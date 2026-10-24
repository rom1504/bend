
/home/ai/bend2/build/publish/bend/selfhost/build/phase111/p137-retain-query-builds01-wide-queries-fused-v02/program:     file format elf64-x86-64


Disassembly of section .init:

Disassembly of section .plt:

Disassembly of section .text:

000000000040b200 <p113d_FID_36_112_49_49_56_98_111_114_114_111_119_46_114_101_97_100_46_112_49_51_55_113_95_107_101_121_95_101_113_>:
  40b200:	endbr64 
  40b204:	push   %rbp
  40b205:	mov    %rsp,%rbp
  40b208:	sub    $0x828,%rsp
  40b20f:	push   %rbx
  40b210:	push   %r12
  40b212:	push   %r13
  40b214:	push   %r14
  40b216:	push   %r15
  40b218:	xchg   %rdx,%rsi
  40b21b:	mov    %rsi,%rax
  40b21e:	shr    $0x28,%rax
  40b222:	mov    %rax,%r15
  40b225:	and    $0xffff,%r15
  40b22c:	cmp    $0x99,%r15
  40b233:	je     40b5a2 <p113d_FID_36_112_49_49_56_98_111_114_114_111_119_46_114_101_97_100_46_112_49_51_55_113_95_107_101_121_95_101_113_+0x3a2>
  40b239:	cs cs cmp $0x9a,%r15
  40b242:	sete   %r9b
  40b246:	movzbl %r9b,%r9d
  40b24a:	mov    %r9d,-0x10(%rbp)
  40b24e:	mov    %rsi,%rax
  40b251:	shr    $0x38,%rax
  40b255:	and    $0x7f,%rax
  40b259:	cmp    $0x2,%rax
  40b25d:	sete   %r14b
  40b261:	movzbl %r14b,%r14d
  40b265:	mov    %rsi,%r11
  40b268:	shr    $0x3f,%r11
  40b26c:	movabs $0xffffffffff,%rax
  40b276:	mov    %rsi,%r8
  40b279:	and    %rax,%r8
  40b27c:	mov    %r8,%r10
  40b27f:	shl    $0x3,%r10
  40b283:	mov    %rdx,%rax
  40b286:	shr    $0x38,%rax
  40b28a:	and    $0x7f,%rax
  40b28e:	cmp    $0x2,%rax
  40b292:	sete   %cl
  40b295:	movzbl %cl,%ecx
  40b298:	mov    %ecx,-0x20(%rbp)
  40b29b:	mov    %rdx,%rax
  40b29e:	shr    $0x28,%rax
  40b2a2:	mov    %rax,%r13
  40b2a5:	and    $0xffff,%r13
  40b2ac:	cmp    $0x19,%r13
  40b2b0:	sete   %al
  40b2b3:	movzbl %al,%eax
  40b2b6:	mov    %eax,-0x1c(%rbp)
  40b2b9:	mov    %rdx,%rax
  40b2bc:	shr    $0x3f,%rax
  40b2c0:	mov    %rax,-0x18(%rbp)
  40b2c4:	movabs $0xffffffffff,%rbx
  40b2ce:	and    %rdx,%rbx
  40b2d1:	mov    %rbx,%r12
  40b2d4:	shl    $0x3,%rbx
  40b2d8:	cmp    $0x0,%r9d
  40b2dc:	mov    -0x1c(%rbp),%r9d
  40b2e0:	jne    40b466 <p113d_FID_36_112_49_49_56_98_111_114_114_111_119_46_114_101_97_100_46_112_49_51_55_113_95_107_101_121_95_101_113_+0x266>
  40b2e6:	cmp    $0x9b,%r15
  40b2ed:	sete   %r15b
  40b2f1:	movzbl %r15b,%r15d
  40b2f5:	je     40b30b <p113d_FID_36_112_49_49_56_98_111_114_114_111_119_46_114_101_97_100_46_112_49_51_55_113_95_107_101_121_95_101_113_+0x10b>
  40b2f7:	mov    $0x4,%esi
  40b2fc:	callq  432730 <p111_rt_fail>
  40b301:	mov    $0x0,%eax
  40b306:	jmpq   40b616 <p113d_FID_36_112_49_49_56_98_111_114_114_111_119_46_114_101_97_100_46_112_49_51_55_113_95_107_101_121_95_101_113_+0x416>
  40b30b:	test   %r14d,%r15d
  40b30e:	jne    40b342 <p113d_FID_36_112_49_49_56_98_111_114_114_111_119_46_114_101_97_100_46_112_49_51_55_113_95_107_101_121_95_101_113_+0x142>
  40b310:	mov    $0x4,%r8d
  40b316:	mov    $0x9b,%ecx
  40b31b:	mov    %rdx,%r15
  40b31e:	lea    -0x820(%rbp),%rdx
  40b325:	mov    %rdi,%r14
  40b328:	callq  4369d0 <p118_rt_borrow_fields>
  40b32d:	mov    %r15,%rdx
  40b330:	mov    %r14,%rdi
  40b333:	mov    -0x1c(%rbp),%esi
  40b336:	mov    -0x18(%rbp),%rax
  40b33a:	mov    -0x20(%rbp),%ecx
  40b33d:	mov    %esi,%r9d
  40b340:	jmp    40b3a0 <p113d_FID_36_112_49_49_56_98_111_114_114_111_119_46_114_101_97_100_46_112_49_51_55_113_95_107_101_121_95_101_113_+0x1a0>
  40b342:	mov    %r9d,%esi
  40b345:	mov    %r8,%r9
  40b348:	mov    (%rdi),%r8
  40b34b:	cmp    $0x0,%r11
  40b34f:	jne    40b356 <p113d_FID_36_112_49_49_56_98_111_114_114_111_119_46_114_101_97_100_46_112_49_51_55_113_95_107_101_121_95_101_113_+0x156>
  40b351:	xchg   %rsi,%r9
  40b354:	jmp    40b36d <p113d_FID_36_112_49_49_56_98_111_114_114_111_119_46_114_101_97_100_46_112_49_51_55_113_95_107_101_121_95_101_113_+0x16d>
  40b356:	mov    %esi,%r9d
  40b359:	mov    (%r10,%r8,1),%esi
  40b35d:	mov    0x4(%r10,%r8,1),%r10d
  40b362:	shl    $0x20,%r10
  40b366:	or     %r10,%rsi
  40b369:	shr    $0x18,%rsi
  40b36d:	shl    $0x3,%rsi
  40b371:	mov    (%rsi,%r8,1),%r10
  40b375:	mov    %r10,-0x820(%rbp)
  40b37c:	mov    0x8(%rsi,%r8,1),%r10
  40b381:	mov    %r10,-0x818(%rbp)
  40b388:	mov    0x10(%rsi,%r8,1),%r10
  40b38d:	mov    %r10,-0x810(%rbp)
  40b394:	mov    0x18(%rsi,%r8,1),%rsi
  40b399:	mov    %rsi,-0x808(%rbp)
  40b3a0:	cmp    $0x18,%r13
  40b3a4:	je     40b44b <p113d_FID_36_112_49_49_56_98_111_114_114_111_119_46_114_101_97_100_46_112_49_51_55_113_95_107_101_121_95_101_113_+0x24b>
  40b3aa:	cmp    $0x19,%r13
  40b3ae:	je     40b3c5 <p113d_FID_36_112_49_49_56_98_111_114_114_111_119_46_114_101_97_100_46_112_49_51_55_113_95_107_101_121_95_101_113_+0x1c5>
  40b3b0:	cs mov $0x4,%esi
  40b3b6:	callq  432730 <p111_rt_fail>
  40b3bb:	mov    $0x0,%eax
  40b3c0:	jmpq   40b616 <p113d_FID_36_112_49_49_56_98_111_114_114_111_119_46_114_101_97_100_46_112_49_51_55_113_95_107_101_121_95_101_113_+0x416>
  40b3c5:	test   %ecx,%r9d
  40b3c8:	jne    40b3ef <p113d_FID_36_112_49_49_56_98_111_114_114_111_119_46_114_101_97_100_46_112_49_51_55_113_95_107_101_121_95_101_113_+0x1ef>
  40b3ca:	mov    $0x2,%r8d
  40b3d0:	mov    $0x19,%ecx
  40b3d5:	mov    %rdx,%rbx
  40b3d8:	lea    -0x820(%rbp),%rdx
  40b3df:	mov    %rbx,%rsi
  40b3e2:	mov    %rdi,%rbx
  40b3e5:	callq  4369d0 <p118_rt_borrow_fields>
  40b3ea:	mov    %rbx,%rdi
  40b3ed:	jmp    40b430 <p113d_FID_36_112_49_49_56_98_111_114_114_111_119_46_114_101_97_100_46_112_49_51_55_113_95_107_101_121_95_101_113_+0x230>
  40b3ef:	mov    (%rdi),%rcx
  40b3f2:	cmp    $0x0,%rax
  40b3f6:	jne    40b3fd <p113d_FID_36_112_49_49_56_98_111_114_114_111_119_46_114_101_97_100_46_112_49_51_55_113_95_107_101_121_95_101_113_+0x1fd>
  40b3f8:	mov    %r12,%rbx
  40b3fb:	jmp    40b412 <p113d_FID_36_112_49_49_56_98_111_114_114_111_119_46_114_101_97_100_46_112_49_51_55_113_95_107_101_121_95_101_113_+0x212>
  40b3fd:	mov    (%rbx,%rcx,1),%eax
  40b400:	mov    0x4(%rbx,%rcx,1),%edx
  40b404:	shl    $0x20,%rdx
  40b408:	or     %rdx,%rax
  40b40b:	mov    %rax,%rbx
  40b40e:	shr    $0x18,%rbx
  40b412:	mov    %rbx,%rax
  40b415:	shl    $0x3,%rax
  40b419:	mov    (%rax,%rcx,1),%rdx
  40b41d:	mov    %rdx,-0x820(%rbp)
  40b424:	mov    0x8(%rax,%rcx,1),%rax
  40b429:	mov    %rax,-0x818(%rbp)
  40b430:	mov    $0x0,%ecx
  40b435:	lea    -0x820(%rbp),%rdx
  40b43c:	mov    $0x1,%esi
  40b441:	callq  4338d0 <p111_rt_special_ctor>
  40b446:	jmpq   40b616 <p113d_FID_36_112_49_49_56_98_111_114_114_111_119_46_114_101_97_100_46_112_49_51_55_113_95_107_101_121_95_101_113_+0x416>
  40b44b:	mov    $0x0,%ecx
  40b450:	lea    -0x820(%rbp),%rdx
  40b457:	mov    $0x2,%esi
  40b45c:	callq  4338d0 <p111_rt_special_ctor>
  40b461:	jmpq   40b616 <p113d_FID_36_112_49_49_56_98_111_114_114_111_119_46_114_101_97_100_46_112_49_51_55_113_95_107_101_121_95_101_113_+0x416>
  40b466:	mov    -0x10(%rbp),%r15d
  40b46a:	test   %r14d,%r15d
  40b46d:	jne    40b49e <p113d_FID_36_112_49_49_56_98_111_114_114_111_119_46_114_101_97_100_46_112_49_51_55_113_95_107_101_121_95_101_113_+0x29e>
  40b46f:	mov    $0x2,%r8d
  40b475:	mov    $0x9a,%ecx
  40b47a:	mov    %rdx,%r15
  40b47d:	lea    -0x820(%rbp),%rdx
  40b484:	mov    %rdi,%r14
  40b487:	callq  4369d0 <p118_rt_borrow_fields>
  40b48c:	mov    %r15,%rdx
  40b48f:	mov    %r14,%rdi
  40b492:	mov    -0x1c(%rbp),%esi
  40b495:	mov    -0x18(%rbp),%rax
  40b499:	mov    -0x20(%rbp),%ecx
  40b49c:	jmp    40b4e0 <p113d_FID_36_112_49_49_56_98_111_114_114_111_119_46_114_101_97_100_46_112_49_51_55_113_95_107_101_121_95_101_113_+0x2e0>
  40b49e:	mov    %r9d,%esi
  40b4a1:	mov    (%rdi),%r9
  40b4a4:	cmp    $0x0,%r11
  40b4a8:	je     40b4c5 <p113d_FID_36_112_49_49_56_98_111_114_114_111_119_46_114_101_97_100_46_112_49_51_55_113_95_107_101_121_95_101_113_+0x2c5>
  40b4aa:	cs cs cs mov %cs:(%r10,%r9,1),%r8d
  40b4b2:	cs cs mov %cs:0x4(%r10,%r9,1),%r10d
  40b4ba:	shl    $0x20,%r10
  40b4be:	or     %r10,%r8
  40b4c1:	shr    $0x18,%r8
  40b4c5:	shl    $0x3,%r8
  40b4c9:	mov    (%r8,%r9,1),%r10
  40b4cd:	mov    %r10,-0x820(%rbp)
  40b4d4:	mov    0x8(%r8,%r9,1),%r8
  40b4d9:	mov    %r8,-0x818(%rbp)
  40b4e0:	cmp    $0x18,%r13
  40b4e4:	je     40b58a <p113d_FID_36_112_49_49_56_98_111_114_114_111_119_46_114_101_97_100_46_112_49_51_55_113_95_107_101_121_95_101_113_+0x38a>
  40b4ea:	cmp    $0x19,%r13
  40b4ee:	je     40b505 <p113d_FID_36_112_49_49_56_98_111_114_114_111_119_46_114_101_97_100_46_112_49_51_55_113_95_107_101_121_95_101_113_+0x305>
  40b4f0:	cs mov $0x4,%esi
  40b4f6:	callq  432730 <p111_rt_fail>
  40b4fb:	mov    $0x0,%eax
  40b500:	jmpq   40b616 <p113d_FID_36_112_49_49_56_98_111_114_114_111_119_46_114_101_97_100_46_112_49_51_55_113_95_107_101_121_95_101_113_+0x416>
  40b505:	test   %ecx,%esi
  40b507:	jne    40b52e <p113d_FID_36_112_49_49_56_98_111_114_114_111_119_46_114_101_97_100_46_112_49_51_55_113_95_107_101_121_95_101_113_+0x32e>
  40b509:	mov    $0x2,%r8d
  40b50f:	mov    $0x19,%ecx
  40b514:	mov    %rdx,%rbx
  40b517:	lea    -0x820(%rbp),%rdx
  40b51e:	mov    %rbx,%rsi
  40b521:	mov    %rdi,%rbx
  40b524:	callq  4369d0 <p118_rt_borrow_fields>
  40b529:	mov    %rbx,%rdi
  40b52c:	jmp    40b56f <p113d_FID_36_112_49_49_56_98_111_114_114_111_119_46_114_101_97_100_46_112_49_51_55_113_95_107_101_121_95_101_113_+0x36f>
  40b52e:	mov    (%rdi),%rcx
  40b531:	cmp    $0x0,%rax
  40b535:	jne    40b53c <p113d_FID_36_112_49_49_56_98_111_114_114_111_119_46_114_101_97_100_46_112_49_51_55_113_95_107_101_121_95_101_113_+0x33c>
  40b537:	mov    %r12,%rbx
  40b53a:	jmp    40b551 <p113d_FID_36_112_49_49_56_98_111_114_114_111_119_46_114_101_97_100_46_112_49_51_55_113_95_107_101_121_95_101_113_+0x351>
  40b53c:	mov    (%rbx,%rcx,1),%eax
  40b53f:	mov    0x4(%rbx,%rcx,1),%edx
  40b543:	shl    $0x20,%rdx
  40b547:	or     %rdx,%rax
  40b54a:	mov    %rax,%rbx
  40b54d:	shr    $0x18,%rbx
  40b551:	mov    %rbx,%rax
  40b554:	shl    $0x3,%rax
  40b558:	mov    (%rax,%rcx,1),%rdx
  40b55c:	mov    %rdx,-0x820(%rbp)
  40b563:	mov    0x8(%rax,%rcx,1),%rax
  40b568:	mov    %rax,-0x818(%rbp)
  40b56f:	mov    $0x0,%ecx
  40b574:	lea    -0x820(%rbp),%rdx
  40b57b:	mov    $0x1,%esi
  40b580:	callq  4338d0 <p111_rt_special_ctor>
  40b585:	jmpq   40b616 <p113d_FID_36_112_49_49_56_98_111_114_114_111_119_46_114_101_97_100_46_112_49_51_55_113_95_107_101_121_95_101_113_+0x416>
  40b58a:	mov    $0x0,%ecx
  40b58f:	lea    -0x820(%rbp),%rdx
  40b596:	mov    $0x2,%esi
  40b59b:	callq  4338d0 <p111_rt_special_ctor>
  40b5a0:	jmp    40b616 <p113d_FID_36_112_49_49_56_98_111_114_114_111_119_46_114_101_97_100_46_112_49_51_55_113_95_107_101_121_95_101_113_+0x416>
  40b5a2:	mov    $0x9,%r8d
  40b5a8:	mov    $0x99,%ecx
  40b5ad:	mov    %rdx,%r12
  40b5b0:	lea    -0x820(%rbp),%rdx
  40b5b7:	mov    %rdi,%rbx
  40b5ba:	callq  4369d0 <p118_rt_borrow_fields>
  40b5bf:	mov    %r12,%rdx
  40b5c2:	mov    %rbx,%rdi
  40b5c5:	mov    -0x820(%rbp),%rcx
  40b5cc:	mov    %rcx,%r13
  40b5cf:	mov    $0x0,%ecx
  40b5d4:	mov    %rdx,%r12
  40b5d7:	lea    -0x820(%rbp),%rdx
  40b5de:	mov    $0x2,%esi
  40b5e3:	mov    %rdi,%rbx
  40b5e6:	callq  4338d0 <p111_rt_special_ctor>
  40b5eb:	mov    %r12,%rdx
  40b5ee:	mov    %rbx,%rdi
  40b5f1:	mov    %rax,%rcx
  40b5f4:	mov    %rdx,%r12
  40b5f7:	mov    %r13,%rdx
  40b5fa:	mov    %r12,%rsi
  40b5fd:	mov    %rdi,%rbx
  40b600:	callq  405870 <p113d_FID_36_112_49_49_56_98_111_114_114_111_119_46_114_101_97_100_46_112_56_56_95_115_116_114_105_110_103_95_101_113_95_103_111_>
  40b605:	mov    %r13,%rcx
  40b608:	mov    %r12,%rdx
  40b60b:	mov    %rbx,%rdi
  40b60e:	mov    %rax,%rsi
  40b611:	callq  405cc0 <p113d_FID_36_112_49_49_56_98_111_114_114_111_119_46_114_101_97_100_46_112_57_56_95_101_113_95_102_105_110_105_115_104_>
  40b616:	pop    %r15
  40b618:	pop    %r14
  40b61a:	pop    %r13
  40b61c:	pop    %r12
  40b61e:	pop    %rbx
  40b61f:	leaveq 
  40b620:	retq   

Disassembly of section .fini:
