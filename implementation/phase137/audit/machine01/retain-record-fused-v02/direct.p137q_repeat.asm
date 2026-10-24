
/home/ai/bend2/build/publish/bend/selfhost/build/phase111/p137-retain-query-builds01-wide-record-fused-v02/program:     file format elf64-x86-64


Disassembly of section .init:

Disassembly of section .plt:

Disassembly of section .text:

000000000040d320 <p113d_FID_36_100_105_114_101_99_116_46_112_49_51_55_113_95_114_101_112_101_97_116_>:
  40d320:	endbr64 
  40d324:	push   %rbp
  40d325:	mov    %rsp,%rbp
  40d328:	sub    $0x28,%rsp
  40d32c:	push   %rbx
  40d32d:	push   %r12
  40d32f:	push   %r13
  40d331:	push   %r14
  40d333:	push   %r15
  40d335:	mov    %r9,%rax
  40d338:	mov    %r8,%r13
  40d33b:	mov    %rcx,%r12
  40d33e:	mov    %rdx,%rbx
  40d341:	mov    %rbx,%rdx
  40d344:	mov    %r13,%r14
  40d347:	mov    %r12,%r13
  40d34a:	mov    %rax,-0x10(%rbp)
  40d34e:	xchg   %ax,%ax
  40d350:	cmp    $0x0,%rsi
  40d354:	je     40d545 <p113d_FID_36_100_105_114_101_99_116_46_112_49_51_55_113_95_114_101_112_101_97_116_+0x225>
  40d35a:	mov    %rsi,%r12
  40d35d:	mov    %rdx,%rsi
  40d360:	mov    %rdi,%rbx
  40d363:	callq  431230 <p111_rt_keep>
  40d368:	mov    %r13,%rcx
  40d36b:	mov    %r12,%rsi
  40d36e:	mov    %rbx,%rdi
  40d371:	mov    %rax,%r13
  40d374:	mov    %rsi,%r12
  40d377:	mov    %rcx,%rsi
  40d37a:	mov    %rdi,%rbx
  40d37d:	callq  431230 <p111_rt_keep>
  40d382:	mov    %r14,%r8
  40d385:	mov    %r12,%rsi
  40d388:	mov    %rbx,%rdi
  40d38b:	mov    %rax,%r14
  40d38e:	mov    %rsi,%r12
  40d391:	mov    %r8,%rsi
  40d394:	mov    %rdi,%rbx
  40d397:	callq  431230 <p111_rt_keep>
  40d39c:	mov    %r12,%rsi
  40d39f:	mov    %rbx,%rdi
  40d3a2:	mov    %rax,%r15
  40d3a5:	mov    %rsi,%r12
  40d3a8:	mov    %r13,%rsi
  40d3ab:	mov    %rdi,%rbx
  40d3ae:	callq  4312c0 <p111_rt_sink>
  40d3b3:	mov    %r12,%rsi
  40d3b6:	mov    %rbx,%rdi
  40d3b9:	mov    %rsi,%r12
  40d3bc:	mov    %r14,%rsi
  40d3bf:	mov    %rdi,%rbx
  40d3c2:	callq  431230 <p111_rt_keep>
  40d3c7:	mov    %r12,%rsi
  40d3ca:	mov    %rbx,%rdi
  40d3cd:	mov    %rax,%rdx
  40d3d0:	mov    %rdx,-0x8(%rbp)
  40d3d4:	mov    %rsi,%r12
  40d3d7:	mov    %r15,%rsi
  40d3da:	mov    %rdi,%rbx
  40d3dd:	callq  409040 <p113d_FID_36_100_105_114_101_99_116_46_112_49_51_55_113_95_114_101_99_111_114_100_95_113_117_101_114_121_>
  40d3e2:	mov    %r15,%r8
  40d3e5:	mov    %r14,%rcx
  40d3e8:	mov    %r13,%rdx
  40d3eb:	mov    %r12,%rsi
  40d3ee:	mov    %rbx,%rdi
  40d3f1:	mov    %rdx,%r13
  40d3f4:	mov    -0x8(%rbp),%rdx
  40d3f8:	cmp    $0x1,%rax
  40d3fc:	mov    %rcx,%r14
  40d3ff:	sete   %cl
  40d402:	movzbl %cl,%ecx
  40d405:	shr    $0x28,%rax
  40d409:	and    $0x7fffff,%rax
  40d40f:	cmp    $0x10002,%rax
  40d415:	mov    %r8,%r15
  40d418:	sete   %r8b
  40d41c:	movzbl %r8b,%r8d
  40d420:	mov    %ecx,%eax
  40d422:	or     %r8d,%eax
  40d425:	mov    %eax,-0x1c(%rbp)
  40d428:	mov    %eax,%r9d
  40d42b:	xor    $0x1,%r9d
  40d42f:	jne    40d45f <p113d_FID_36_100_105_114_101_99_116_46_112_49_51_55_113_95_114_101_112_101_97_116_+0x13f>
  40d431:	or     %r8d,%ecx
  40d434:	jne    40d459 <p113d_FID_36_100_105_114_101_99_116_46_112_49_51_55_113_95_114_101_112_101_97_116_+0x139>
  40d436:	mov    %rsi,%r12
  40d439:	mov    $0x4,%esi
  40d43e:	mov    %rdi,%rbx
  40d441:	callq  431a50 <p111_rt_fail>
  40d446:	mov    %r13,%rdx
  40d449:	mov    %r12,%rsi
  40d44c:	mov    %rbx,%rdi
  40d44f:	mov    %rdx,%r13
  40d452:	mov    -0x8(%rbp),%rdx
  40d456:	mov    -0x1c(%rbp),%eax
  40d459:	mov    %rax,-0x18(%rbp)
  40d45d:	jmp    40d467 <p113d_FID_36_100_105_114_101_99_116_46_112_49_51_55_113_95_114_101_112_101_97_116_+0x147>
  40d45f:	movq   $0x0,-0x18(%rbp)
  40d467:	mov    %rsi,%r12
  40d46a:	movabs $0x20019000310865a,%rsi
  40d474:	mov    %rdi,%rbx
  40d477:	callq  409040 <p113d_FID_36_100_105_114_101_99_116_46_112_49_51_55_113_95_114_101_99_111_114_100_95_113_117_101_114_121_>
  40d47c:	mov    %r15,%r8
  40d47f:	mov    %r14,%rcx
  40d482:	mov    %r13,%rdx
  40d485:	mov    %r12,%rsi
  40d488:	mov    %rbx,%rdi
  40d48b:	mov    %rax,%r10
  40d48e:	mov    -0x18(%rbp),%rax
  40d492:	mov    -0x10(%rbp),%r9
  40d496:	cmp    $0x1,%r10
  40d49a:	mov    %rcx,%r14
  40d49d:	sete   %cl
  40d4a0:	movzbl %cl,%ecx
  40d4a3:	shr    $0x28,%r10
  40d4a7:	and    $0x7fffff,%r10
  40d4ae:	cmp    $0x10002,%r10
  40d4b5:	mov    %rdx,%r13
  40d4b8:	sete   %dl
  40d4bb:	movzbl %dl,%edx
  40d4be:	mov    %r9,%rbx
  40d4c1:	mov    %ecx,%r9d
  40d4c4:	or     %edx,%r9d
  40d4c7:	mov    %r9d,-0x20(%rbp)
  40d4cb:	mov    %r8,%r15
  40d4ce:	mov    %r9d,%r8d
  40d4d1:	xor    $0x1,%r8d
  40d4d5:	jne    40d516 <p113d_FID_36_100_105_114_101_99_116_46_112_49_51_55_113_95_114_101_112_101_97_116_+0x1f6>
  40d4d7:	or     %edx,%ecx
  40d4d9:	jne    40d50b <p113d_FID_36_100_105_114_101_99_116_46_112_49_51_55_113_95_114_101_112_101_97_116_+0x1eb>
  40d4db:	mov    %rsi,%r12
  40d4de:	mov    $0x4,%esi
  40d4e3:	mov    %rdi,%rbx
  40d4e6:	callq  431a50 <p111_rt_fail>
  40d4eb:	mov    %r15,%r8
  40d4ee:	mov    %r14,%rcx
  40d4f1:	mov    %r13,%rdx
  40d4f4:	mov    %r12,%rsi
  40d4f7:	mov    %rbx,%rdi
  40d4fa:	mov    -0x18(%rbp),%rax
  40d4fe:	mov    -0x10(%rbp),%r9
  40d502:	mov    %r9,%rbx
  40d505:	mov    -0x20(%rbp),%r9d
  40d509:	jmp    40d527 <p113d_FID_36_100_105_114_101_99_116_46_112_49_51_55_113_95_114_101_112_101_97_116_+0x207>
  40d50b:	mov    %r15,%r8
  40d50e:	mov    %r14,%rcx
  40d511:	mov    %r13,%rdx
  40d514:	jmp    40d527 <p113d_FID_36_100_105_114_101_99_116_46_112_49_51_55_113_95_114_101_112_101_97_116_+0x207>
  40d516:	cs cs mov %r15,%r8
  40d51b:	mov    %r14,%rcx
  40d51e:	mov    %r13,%rdx
  40d521:	mov    $0x0,%r9d
  40d527:	add    %rax,%r9
  40d52a:	mov    %ebx,%eax
  40d52c:	add    %r9d,%eax
  40d52f:	mov    %eax,%r9d
  40d532:	sub    $0x1,%rsi
  40d536:	mov    %rcx,%r13
  40d539:	mov    %r8,%r14
  40d53c:	mov    %r9,-0x10(%rbp)
  40d540:	jmpq   40d350 <p113d_FID_36_100_105_114_101_99_116_46_112_49_51_55_113_95_114_101_112_101_97_116_+0x30>
  40d545:	mov    %rdx,%rsi
  40d548:	xchg   %r13,%r14
  40d54b:	mov    -0x10(%rbp),%rbx
  40d54f:	mov    %rdi,%r12
  40d552:	callq  4312c0 <p111_rt_sink>
  40d557:	mov    %r14,%rsi
  40d55a:	mov    %r12,%rdi
  40d55d:	mov    %rdi,%r12
  40d560:	callq  4312c0 <p111_rt_sink>
  40d565:	mov    %r13,%rsi
  40d568:	mov    %r12,%rdi
  40d56b:	callq  4312c0 <p111_rt_sink>
  40d570:	mov    %rbx,%rax
  40d573:	pop    %r15
  40d575:	pop    %r14
  40d577:	pop    %r13
  40d579:	pop    %r12
  40d57b:	pop    %rbx
  40d57c:	leaveq 
  40d57d:	retq   

Disassembly of section .fini:
