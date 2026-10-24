
/home/ai/bend2/build/publish/bend/selfhost/build/phase111/p137-query-v02-builds01-wide-queries-fused-v02/program:     file format elf64-x86-64


Disassembly of section .init:

Disassembly of section .plt:

Disassembly of section .text:

000000000040e1a0 <p113d_FID_36_100_105_114_101_99_116_46_110_99_95_99_116_111_114_95_111_119_110_101_100_>:
  40e1a0:	endbr64 
  40e1a4:	push   %rbp
  40e1a5:	mov    %rsp,%rbp
  40e1a8:	sub    $0xa48,%rsp
  40e1af:	push   %rbx
  40e1b0:	push   %r12
  40e1b2:	push   %r13
  40e1b4:	push   %r14
  40e1b6:	push   %r15
  40e1b8:	mov    %rdx,%rbx
  40e1bb:	mov    %rbx,%rdx
  40e1be:	xchg   %ax,%ax
  40e1c0:	mov    %rsi,%rax
  40e1c3:	shr    $0x28,%rax
  40e1c7:	and    $0xffff,%rax
  40e1cd:	cmp    $0x11,%rax
  40e1d1:	je     40edc9 <p113d_FID_36_100_105_114_101_99_116_46_110_99_95_99_116_111_114_95_111_119_110_101_100_+0xc29>
  40e1d7:	nopw   0x0(%rax,%rax,1)
  40e1e0:	cmp    $0x12,%rax
  40e1e4:	jne    40edb8 <p113d_FID_36_100_105_114_101_99_116_46_110_99_95_99_116_111_114_95_111_119_110_101_100_+0xc18>
  40e1ea:	mov    %rdx,%r13
  40e1ed:	lea    -0xa40(%rbp),%rdx
  40e1f4:	mov    %rdi,%rbx
  40e1f7:	callq  43aab0 <p125_rt_take2>
  40e1fc:	mov    %rbx,%rdi
  40e1ff:	mov    -0xa40(%rbp),%rsi
  40e206:	mov    -0xa38(%rbp),%r12
  40e20d:	mov    %rdi,%rbx
  40e210:	callq  435270 <p111_rt_keep>
  40e215:	mov    %r12,%rsi
  40e218:	mov    %rbx,%rdi
  40e21b:	mov    %rax,%r15
  40e21e:	mov    %r15,%rax
  40e221:	shr    $0x28,%rax
  40e225:	and    $0xffff,%rax
  40e22b:	cmp    $0x99,%rax
  40e231:	je     40e2fc <p113d_FID_36_100_105_114_101_99_116_46_110_99_95_99_116_111_114_95_111_119_110_101_100_+0x15c>
  40e237:	cmp    $0x9a,%rax
  40e23d:	je     40e2b3 <p113d_FID_36_100_105_114_101_99_116_46_110_99_95_99_116_111_114_95_111_119_110_101_100_+0x113>
  40e23f:	nop
  40e240:	cmp    $0x9b,%rax
  40e246:	je     40e263 <p113d_FID_36_100_105_114_101_99_116_46_110_99_95_99_116_111_114_95_111_119_110_101_100_+0xc3>
  40e248:	mov    %rsi,%r12
  40e24b:	mov    $0x4,%esi
  40e250:	mov    %rdi,%rbx
  40e253:	callq  435a90 <p111_rt_fail>
  40e258:	mov    %r13,%rdx
  40e25b:	mov    %rbx,%rdi
  40e25e:	mov    %r12,%rsi
  40e261:	jmp    40e2ae <p113d_FID_36_100_105_114_101_99_116_46_110_99_95_99_116_111_114_95_111_119_110_101_100_+0x10e>
  40e263:	mov    %rsi,%r12
  40e266:	mov    %r13,%rdx
  40e269:	mov    %rdx,%r13
  40e26c:	lea    -0x240(%rbp),%rdx
  40e273:	mov    %r15,%rsi
  40e276:	mov    %rdi,%rbx
  40e279:	callq  43af80 <p125_rt_take4>
  40e27e:	mov    %rbx,%rdi
  40e281:	mov    -0x230(%rbp),%rsi
  40e288:	mov    -0x228(%rbp),%r14
  40e28f:	mov    %rdi,%rbx
  40e292:	callq  435300 <p111_rt_sink>
  40e297:	mov    %r14,%rsi
  40e29a:	mov    %rbx,%rdi
  40e29d:	mov    %rdi,%rbx
  40e2a0:	callq  435300 <p111_rt_sink>
  40e2a5:	mov    %r13,%rdx
  40e2a8:	mov    %r12,%rsi
  40e2ab:	mov    %rbx,%rdi
  40e2ae:	mov    %rsi,%r13
  40e2b1:	jmp    40e2ec <p113d_FID_36_100_105_114_101_99_116_46_110_99_95_99_116_111_114_95_111_119_110_101_100_+0x14c>
  40e2b3:	mov    %r13,%rdx
  40e2b6:	mov    %rdx,%r12
  40e2b9:	lea    -0x240(%rbp),%rdx
  40e2c0:	mov    %rsi,%r13
  40e2c3:	mov    %r15,%rsi
  40e2c6:	mov    %rdi,%rbx
  40e2c9:	callq  43aab0 <p125_rt_take2>
  40e2ce:	mov    %r13,%rsi
  40e2d1:	mov    %rbx,%rdi
  40e2d4:	mov    %rsi,%r13
  40e2d7:	mov    -0x238(%rbp),%rsi
  40e2de:	mov    %rdi,%rbx
  40e2e1:	callq  435300 <p111_rt_sink>
  40e2e6:	mov    %r12,%rdx
  40e2e9:	mov    %rbx,%rdi
  40e2ec:	mov    %r15,%rsi
  40e2ef:	mov    %rdx,%r14
  40e2f2:	mov    $0x0,%ebx
  40e2f7:	jmpq   40e497 <p113d_FID_36_100_105_114_101_99_116_46_110_99_95_99_116_111_114_95_111_119_110_101_100_+0x2f7>
  40e2fc:	cs cs cs cs mov %r13,%rdx
  40e303:	cs mov %rsi,%r13
  40e307:	mov    $0x9,%ecx
  40e30c:	mov    %rdx,%r14
  40e30f:	lea    -0x240(%rbp),%rdx
  40e316:	mov    %r15,%rsi
  40e319:	mov    %rdi,%rbx
  40e31c:	callq  4354f0 <p111_rt_take>
  40e321:	mov    %rbx,%rdi
  40e324:	mov    -0x240(%rbp),%rsi
  40e32b:	mov    -0x238(%rbp),%r12
  40e332:	mov    -0x230(%rbp),%rax
  40e339:	mov    %rax,-0x10(%rbp)
  40e33d:	mov    -0x228(%rbp),%rax
  40e344:	mov    %rax,-0x18(%rbp)
  40e348:	mov    -0x220(%rbp),%rax
  40e34f:	mov    %rax,-0x20(%rbp)
  40e353:	mov    -0x218(%rbp),%rax
  40e35a:	mov    %rax,-0x28(%rbp)
  40e35e:	mov    -0x210(%rbp),%rax
  40e365:	mov    %rax,-0x30(%rbp)
  40e369:	mov    -0x208(%rbp),%rax
  40e370:	mov    %rax,-0x38(%rbp)
  40e374:	mov    -0x200(%rbp),%rax
  40e37b:	mov    %rax,-0x40(%rbp)
  40e37f:	mov    %rdi,%rbx
  40e382:	callq  435300 <p111_rt_sink>
  40e387:	mov    %r12,%rsi
  40e38a:	mov    %rbx,%rdi
  40e38d:	mov    %rsi,%r12
  40e390:	mov    -0x10(%rbp),%rsi
  40e394:	mov    %rdi,%rbx
  40e397:	callq  435300 <p111_rt_sink>
  40e39c:	mov    %r12,%rsi
  40e39f:	mov    %rbx,%rdi
  40e3a2:	mov    %rsi,%r12
  40e3a5:	mov    -0x18(%rbp),%rsi
  40e3a9:	mov    %rdi,%rbx
  40e3ac:	callq  435300 <p111_rt_sink>
  40e3b1:	mov    %r12,%rsi
  40e3b4:	mov    %rbx,%rdi
  40e3b7:	mov    %rsi,%r12
  40e3ba:	mov    -0x20(%rbp),%rsi
  40e3be:	mov    %rdi,%rbx
  40e3c1:	callq  435300 <p111_rt_sink>
  40e3c6:	mov    %r12,%rsi
  40e3c9:	mov    %rbx,%rdi
  40e3cc:	mov    %rsi,%r12
  40e3cf:	mov    -0x28(%rbp),%rsi
  40e3d3:	mov    %rdi,%rbx
  40e3d6:	callq  435300 <p111_rt_sink>
  40e3db:	mov    %r12,%rsi
  40e3de:	mov    %rbx,%rdi
  40e3e1:	mov    %rsi,%r12
  40e3e4:	mov    -0x30(%rbp),%rsi
  40e3e8:	mov    %rdi,%rbx
  40e3eb:	callq  435300 <p111_rt_sink>
  40e3f0:	mov    %r12,%rsi
  40e3f3:	mov    %rbx,%rdi
  40e3f6:	mov    %rsi,%r12
  40e3f9:	mov    -0x38(%rbp),%rsi
  40e3fd:	mov    %rdi,%rbx
  40e400:	callq  435300 <p111_rt_sink>
  40e405:	mov    %r12,%rsi
  40e408:	mov    %rbx,%rdi
  40e40b:	mov    %rsi,%r12
  40e40e:	mov    -0x40(%rbp),%rsi
  40e412:	mov    %rdi,%rbx
  40e415:	callq  435300 <p111_rt_sink>
  40e41a:	mov    %r12,%rsi
  40e41d:	mov    %rbx,%rdi
  40e420:	mov    %rdi,%rbx
  40e423:	callq  435270 <p111_rt_keep>
  40e428:	mov    %rbx,%rdi
  40e42b:	mov    %rax,%rsi
  40e42e:	mov    %rsi,%r12
  40e431:	movabs $0x200190003108638,%rsi
  40e43b:	mov    %rdi,%rbx
  40e43e:	callq  435270 <p111_rt_keep>
  40e443:	mov    %r14,%rdx
  40e446:	mov    %r12,%rsi
  40e449:	mov    %rbx,%rdi
  40e44c:	mov    %rax,%r12
  40e44f:	mov    %r12,-0x48(%rbp)
  40e453:	mov    $0x1,%ecx
  40e458:	mov    %rdx,%r14
  40e45b:	mov    %r12,%rdx
  40e45e:	mov    %rsi,%r12
  40e461:	mov    %rdi,%rbx
  40e464:	callq  405c00 <p113d_FID_36_100_105_114_101_99_116_46_112_56_56_95_115_116_114_105_110_103_95_101_113_95_103_111_>
  40e469:	mov    %r12,%rsi
  40e46c:	mov    %rbx,%rdi
  40e46f:	mov    %rax,-0x50(%rbp)
  40e473:	mov    -0x48(%rbp),%r12
  40e477:	mov    %rdi,%rbx
  40e47a:	callq  435300 <p111_rt_sink>
  40e47f:	mov    %r12,%rsi
  40e482:	mov    %rbx,%rdi
  40e485:	mov    -0x50(%rbp),%rbx
  40e489:	mov    %rdi,%r12
  40e48c:	callq  435300 <p111_rt_sink>
  40e491:	mov    %r15,%rsi
  40e494:	mov    %r12,%rdi
  40e497:	cmp    $0x1,%rbx
  40e49b:	sete   %al
  40e49e:	movzbl %al,%eax
  40e4a1:	mov    %rbx,%rcx
  40e4a4:	shr    $0x28,%rcx
  40e4a8:	and    $0x7fffff,%rcx
  40e4af:	cmp    $0x10002,%rcx
  40e4b6:	sete   %cl
  40e4b9:	movzbl %cl,%ecx
  40e4bc:	mov    %eax,%ebx
  40e4be:	or     %ecx,%ebx
  40e4c0:	jne    40e54f <p113d_FID_36_100_105_114_101_99_116_46_110_99_95_99_116_111_114_95_111_119_110_101_100_+0x3af>
  40e4c6:	mov    %rdi,%r12
  40e4c9:	callq  435300 <p111_rt_sink>
  40e4ce:	mov    %r14,%rdx
  40e4d1:	mov    %r13,%rsi
  40e4d4:	mov    %r12,%rdi
  40e4d7:	mov    %ebx,%eax
  40e4d9:	xor    $0x1,%eax
  40e4dc:	je     40e519 <p113d_FID_36_100_105_114_101_99_116_46_110_99_95_99_116_111_114_95_111_119_110_101_100_+0x379>
  40e4de:	mov    $0x0,%ecx
  40e4e3:	mov    %rdx,%r13
  40e4e6:	lea    -0xa40(%rbp),%rdx
  40e4ed:	mov    %rsi,%r12
  40e4f0:	mov    $0x0,%esi
  40e4f5:	mov    %rdi,%rbx
  40e4f8:	callq  435370 <p111_rt_ctor>
  40e4fd:	mov    %rbx,%rdi
  40e500:	mov    %rax,%rsi
  40e503:	mov    %rdi,%rbx
  40e506:	callq  435300 <p111_rt_sink>
  40e50b:	mov    %r13,%rdx
  40e50e:	mov    %rbx,%rdi
  40e511:	mov    %r12,%rsi
  40e514:	jmpq   40e1c0 <p113d_FID_36_100_105_114_101_99_116_46_110_99_95_99_116_111_114_95_111_119_110_101_100_+0x20>
  40e519:	mov    %rsi,%r12
  40e51c:	mov    %rdx,%rsi
  40e51f:	mov    %rdi,%rbx
  40e522:	callq  435300 <p111_rt_sink>
  40e527:	mov    %r12,%rsi
  40e52a:	mov    %rbx,%rdi
  40e52d:	mov    %rsi,%r12
  40e530:	mov    %rdi,%rbx
  40e533:	callq  435300 <p111_rt_sink>
  40e538:	mov    %rbx,%rdi
  40e53b:	mov    $0x4,%esi
  40e540:	callq  435a90 <p111_rt_fail>
  40e545:	mov    $0x0,%eax
  40e54a:	jmpq   40edd6 <p113d_FID_36_100_105_114_101_99_116_46_110_99_95_99_116_111_114_95_111_119_110_101_100_+0xc36>
  40e54f:	mov    %r13,%r12
  40e552:	mov    %r14,%rdx
  40e555:	mov    $0x0,%ecx
  40e55a:	mov    %rdx,%r14
  40e55d:	lea    -0xa40(%rbp),%rdx
  40e564:	mov    %rsi,%r13
  40e567:	mov    $0x0,%esi
  40e56c:	mov    %rdi,%rbx
  40e56f:	callq  435370 <p111_rt_ctor>
  40e574:	mov    %rbx,%rdi
  40e577:	mov    %rax,%rsi
  40e57a:	mov    %rdi,%rbx
  40e57d:	callq  435300 <p111_rt_sink>
  40e582:	mov    %r14,%rdx
  40e585:	mov    %r13,%rsi
  40e588:	mov    %rbx,%rdi
  40e58b:	mov    %rsi,%r13
  40e58e:	mov    %rdx,%rsi
  40e591:	mov    %rdi,%rbx
  40e594:	callq  435270 <p111_rt_keep>
  40e599:	mov    %r13,%rsi
  40e59c:	mov    %rbx,%rdi
  40e59f:	mov    %rax,%r14
  40e5a2:	mov    %rdi,%rbx
  40e5a5:	callq  435270 <p111_rt_keep>
  40e5aa:	mov    %r12,%rsi
  40e5ad:	mov    %rbx,%rdi
  40e5b0:	mov    %rax,%r15
  40e5b3:	mov    %r15,%rax
  40e5b6:	shr    $0x28,%rax
  40e5ba:	mov    %rax,%r12
  40e5bd:	and    $0xffff,%r12
  40e5c4:	cmp    $0x99,%r12
  40e5cb:	sete   %al
  40e5ce:	movzbl %al,%eax
  40e5d1:	cmp    $0x9b,%r12
  40e5d8:	sete   %bl
  40e5db:	movzbl %bl,%ebx
  40e5de:	mov    %ebx,-0xf8(%rbp)
  40e5e4:	cmp    $0x0,%eax
  40e5e7:	jne    40e710 <p113d_FID_36_100_105_114_101_99_116_46_110_99_95_99_116_111_114_95_111_119_110_101_100_+0x570>
  40e5ed:	cmp    $0x9a,%r12
  40e5f4:	je     40e6da <p113d_FID_36_100_105_114_101_99_116_46_110_99_95_99_116_111_114_95_111_119_110_101_100_+0x53a>
  40e5fa:	nopw   0x0(%rax,%rax,1)
  40e600:	cmp    $0x9b,%r12
  40e607:	je     40e62c <p113d_FID_36_100_105_114_101_99_116_46_110_99_95_99_116_111_114_95_111_119_110_101_100_+0x48c>
  40e609:	mov    %rsi,%r13
  40e60c:	mov    $0x4,%esi
  40e611:	mov    %rdi,%rbx
  40e614:	callq  435a90 <p111_rt_fail>
  40e619:	mov    %r14,%rdx
  40e61c:	mov    %r13,%rsi
  40e61f:	mov    %rbx,%rdi
  40e622:	mov    $0x0,%eax
  40e627:	jmpq   40e6d2 <p113d_FID_36_100_105_114_101_99_116_46_110_99_95_99_116_111_114_95_111_119_110_101_100_+0x532>
  40e62c:	mov    %r14,%rdx
  40e62f:	mov    %rdx,%r14
  40e632:	lea    -0x1f8(%rbp),%rdx
  40e639:	mov    %rsi,%r13
  40e63c:	mov    %r15,%rsi
  40e63f:	mov    %rdi,%rbx
  40e642:	callq  43af80 <p125_rt_take4>
  40e647:	mov    %r14,%rdx
  40e64a:	mov    %r13,%rsi
  40e64d:	mov    %rbx,%rdi
  40e650:	mov    -0x1e8(%rbp),%rcx
  40e657:	mov    %rcx,-0x58(%rbp)
  40e65b:	mov    -0x1e0(%rbp),%rax
  40e662:	mov    %rax,-0x1f8(%rbp)
  40e669:	movabs $0x100110000000000,%rax
  40e673:	mov    %rax,-0x1f0(%rbp)
  40e67a:	mov    %rdx,%r14
  40e67d:	lea    -0x1f8(%rbp),%rdx
  40e684:	mov    %rsi,%r13
  40e687:	mov    $0x12,%esi
  40e68c:	mov    %rdi,%rbx
  40e68f:	callq  43a9c0 <p125_rt_ctor2>
  40e694:	mov    %r14,%rdx
  40e697:	mov    %r13,%rsi
  40e69a:	mov    %rbx,%rdi
  40e69d:	mov    -0x58(%rbp),%rcx
  40e6a1:	mov    %rcx,-0x1f8(%rbp)
  40e6a8:	mov    %rax,-0x1f0(%rbp)
  40e6af:	mov    %rdx,%r14
  40e6b2:	lea    -0x1f8(%rbp),%rdx
  40e6b9:	mov    %rsi,%r13
  40e6bc:	mov    $0x12,%esi
  40e6c1:	mov    %rdi,%rbx
  40e6c4:	callq  43a9c0 <p125_rt_ctor2>
  40e6c9:	mov    %r14,%rdx
  40e6cc:	mov    %r13,%rsi
  40e6cf:	mov    %rbx,%rdi
  40e6d2:	mov    %rsi,%r13
  40e6d5:	mov    %rax,%rsi
  40e6d8:	jmp    40e708 <p113d_FID_36_100_105_114_101_99_116_46_110_99_95_99_116_111_114_95_111_119_110_101_100_+0x568>
  40e6da:	mov    %r14,%rdx
  40e6dd:	mov    %rdx,%r14
  40e6e0:	lea    -0x1f8(%rbp),%rdx
  40e6e7:	mov    %rsi,%r13
  40e6ea:	mov    %r15,%rsi
  40e6ed:	mov    %rdi,%rbx
  40e6f0:	callq  43aab0 <p125_rt_take2>
  40e6f5:	mov    %r14,%rdx
  40e6f8:	mov    %r13,%rsi
  40e6fb:	mov    %rbx,%rdi
  40e6fe:	mov    %rsi,%r13
  40e701:	mov    -0x1f0(%rbp),%rsi
  40e708:	mov    %r13,%rbx
  40e70b:	jmpq   40e84f <p113d_FID_36_100_105_114_101_99_116_46_110_99_95_99_116_111_114_95_111_119_110_101_100_+0x6af>
  40e710:	mov    %r14,%rdx
  40e713:	mov    %rsi,%r13
  40e716:	mov    $0x9,%ecx
  40e71b:	mov    %rdx,%r14
  40e71e:	lea    -0x1f8(%rbp),%rdx
  40e725:	mov    %r15,%rsi
  40e728:	mov    %rdi,%rbx
  40e72b:	callq  4354f0 <p111_rt_take>
  40e730:	mov    %rbx,%rdi
  40e733:	mov    -0x1f8(%rbp),%rsi
  40e73a:	mov    -0x1f0(%rbp),%rax
  40e741:	mov    %rax,-0x60(%rbp)
  40e745:	mov    -0x1e8(%rbp),%rax
  40e74c:	mov    %rax,-0x68(%rbp)
  40e750:	mov    -0x1e0(%rbp),%rax
  40e757:	mov    %rax,-0x70(%rbp)
  40e75b:	mov    -0x1d8(%rbp),%rax
  40e762:	mov    %rax,-0x78(%rbp)
  40e766:	mov    -0x1d0(%rbp),%rax
  40e76d:	mov    %rax,-0x80(%rbp)
  40e771:	mov    -0x1c8(%rbp),%rax
  40e778:	mov    %rax,-0x98(%rbp)
  40e77f:	mov    -0x1c0(%rbp),%rax
  40e786:	mov    %rax,-0x88(%rbp)
  40e78d:	mov    -0x1b8(%rbp),%rax
  40e794:	mov    %rax,-0x90(%rbp)
  40e79b:	mov    %rdi,%rbx
  40e79e:	callq  435300 <p111_rt_sink>
  40e7a3:	mov    %r13,%rsi
  40e7a6:	mov    %rbx,%rdi
  40e7a9:	mov    %rsi,%r13
  40e7ac:	mov    -0x60(%rbp),%rsi
  40e7b0:	mov    %rdi,%rbx
  40e7b3:	callq  435300 <p111_rt_sink>
  40e7b8:	mov    %r13,%rsi
  40e7bb:	mov    %rbx,%rdi
  40e7be:	mov    %rsi,%r13
  40e7c1:	mov    -0x68(%rbp),%rsi
  40e7c5:	mov    %rdi,%rbx
  40e7c8:	callq  435300 <p111_rt_sink>
  40e7cd:	mov    %r13,%rsi
  40e7d0:	mov    %rbx,%rdi
  40e7d3:	mov    %rsi,%r13
  40e7d6:	mov    -0x70(%rbp),%rsi
  40e7da:	mov    %rdi,%rbx
  40e7dd:	callq  435300 <p111_rt_sink>
  40e7e2:	mov    %r13,%rsi
  40e7e5:	mov    %rbx,%rdi
  40e7e8:	mov    %rsi,%r13
  40e7eb:	mov    -0x78(%rbp),%rsi
  40e7ef:	mov    %rdi,%rbx
  40e7f2:	callq  435300 <p111_rt_sink>
  40e7f7:	mov    %r13,%rsi
  40e7fa:	mov    %rbx,%rdi
  40e7fd:	mov    %rsi,%r13
  40e800:	mov    -0x80(%rbp),%rsi
  40e804:	mov    %rdi,%rbx
  40e807:	callq  435300 <p111_rt_sink>
  40e80c:	mov    %r13,%rsi
  40e80f:	mov    %rbx,%rdi
  40e812:	mov    %rsi,%r13
  40e815:	mov    -0x88(%rbp),%rsi
  40e81c:	mov    %rdi,%rbx
  40e81f:	callq  435300 <p111_rt_sink>
  40e824:	mov    %r13,%rsi
  40e827:	mov    %rbx,%rdi
  40e82a:	mov    %rsi,%r13
  40e82d:	mov    -0x90(%rbp),%rsi
  40e834:	mov    %rdi,%rbx
  40e837:	callq  435300 <p111_rt_sink>
  40e83c:	mov    %r14,%rdx
  40e83f:	mov    %r13,%rsi
  40e842:	mov    %rbx,%rdi
  40e845:	mov    %rsi,%rbx
  40e848:	mov    -0x98(%rbp),%rsi
  40e84f:	mov    %rdx,%r14
  40e852:	mov    %rdi,%r13
  40e855:	callq  40cd80 <p113d_FID_36_100_105_114_101_99_116_46_108_111_111_107_117_112_>
  40e85a:	mov    %r13,%rdi
  40e85d:	mov    %rax,%rsi
  40e860:	mov    %rsi,%rax
  40e863:	shr    $0x28,%rax
  40e867:	and    $0xffff,%rax
  40e86d:	cmp    $0x99,%rax
  40e873:	je     40e965 <p113d_FID_36_100_105_114_101_99_116_46_110_99_95_99_116_111_114_95_111_119_110_101_100_+0x7c5>
  40e879:	nopl   0x0(%rax)
  40e880:	cmp    $0x9a,%rax
  40e886:	je     40e916 <p113d_FID_36_100_105_114_101_99_116_46_110_99_95_99_116_111_114_95_111_119_110_101_100_+0x776>
  40e88c:	cmp    $0x9b,%rax
  40e892:	je     40e8b8 <p113d_FID_36_100_105_114_101_99_116_46_110_99_95_99_116_111_114_95_111_119_110_101_100_+0x718>
  40e894:	mov    %rbx,%rsi
  40e897:	mov    %rsi,%r13
  40e89a:	mov    $0x4,%esi
  40e89f:	mov    %rdi,%rbx
  40e8a2:	callq  435a90 <p111_rt_fail>
  40e8a7:	mov    %r14,%rdx
  40e8aa:	mov    %rbx,%rdi
  40e8ad:	mov    -0xf8(%rbp),%ebx
  40e8b3:	jmpq   40e952 <p113d_FID_36_100_105_114_101_99_116_46_110_99_95_99_116_111_114_95_111_119_110_101_100_+0x7b2>
  40e8b8:	mov    %r14,%rdx
  40e8bb:	mov    %rbx,%r13
  40e8be:	mov    %rdx,%r14
  40e8c1:	lea    -0x1b0(%rbp),%rdx
  40e8c8:	mov    %rdi,%rbx
  40e8cb:	callq  43af80 <p125_rt_take4>
  40e8d0:	mov    %rbx,%rdi
  40e8d3:	mov    -0x1a0(%rbp),%rsi
  40e8da:	mov    -0x198(%rbp),%rax
  40e8e1:	mov    %rax,-0xa0(%rbp)
  40e8e8:	mov    %rdi,%rbx
  40e8eb:	callq  435300 <p111_rt_sink>
  40e8f0:	mov    %r13,%rsi
  40e8f3:	mov    %rbx,%rdi
  40e8f6:	mov    %rsi,%r13
  40e8f9:	mov    -0xa0(%rbp),%rsi
  40e900:	mov    %rdi,%rbx
  40e903:	callq  435300 <p111_rt_sink>
  40e908:	mov    %r14,%rdx
  40e90b:	mov    %rbx,%rdi
  40e90e:	mov    -0xf8(%rbp),%ebx
  40e914:	jmp    40e952 <p113d_FID_36_100_105_114_101_99_116_46_110_99_95_99_116_111_114_95_111_119_110_101_100_+0x7b2>
  40e916:	mov    %r14,%rdx
  40e919:	mov    %rbx,%r13
  40e91c:	mov    %rdx,%r14
  40e91f:	lea    -0x1b0(%rbp),%rdx
  40e926:	mov    %rdi,%rbx
  40e929:	callq  43aab0 <p125_rt_take2>
  40e92e:	mov    %r13,%rsi
  40e931:	mov    %rbx,%rdi
  40e934:	mov    %rsi,%r13
  40e937:	mov    -0x1a8(%rbp),%rsi
  40e93e:	mov    %rdi,%rbx
  40e941:	callq  435300 <p111_rt_sink>
  40e946:	mov    %r14,%rdx
  40e949:	mov    %rbx,%rdi
  40e94c:	mov    -0xf8(%rbp),%ebx
  40e952:	mov    %r15,%rsi
  40e955:	mov    %rdx,%r14
  40e958:	mov    %ebx,%r15d
  40e95b:	mov    $0x0,%ecx
  40e960:	jmpq   40eb28 <p113d_FID_36_100_105_114_101_99_116_46_110_99_95_99_116_111_114_95_111_119_110_101_100_+0x988>
  40e965:	mov    %r14,%rdx
  40e968:	mov    %rbx,%r13
  40e96b:	mov    $0x9,%ecx
  40e970:	mov    %rdx,%r14
  40e973:	lea    -0x1b0(%rbp),%rdx
  40e97a:	mov    %rdi,%rbx
  40e97d:	callq  4354f0 <p111_rt_take>
  40e982:	mov    %rbx,%rdi
  40e985:	mov    -0x1b0(%rbp),%rsi
  40e98c:	mov    -0x1a8(%rbp),%rax
  40e993:	mov    %rax,-0xe0(%rbp)
  40e99a:	mov    -0x1a0(%rbp),%rax
  40e9a1:	mov    %rax,-0xa8(%rbp)
  40e9a8:	mov    -0x198(%rbp),%rax
  40e9af:	mov    %rax,-0xb0(%rbp)
  40e9b6:	mov    -0x190(%rbp),%rax
  40e9bd:	mov    %rax,-0xb8(%rbp)
  40e9c4:	mov    -0x188(%rbp),%rax
  40e9cb:	mov    %rax,-0xc0(%rbp)
  40e9d2:	mov    -0x180(%rbp),%rax
  40e9d9:	mov    %rax,-0xc8(%rbp)
  40e9e0:	mov    -0x178(%rbp),%rax
  40e9e7:	mov    %rax,-0xd0(%rbp)
  40e9ee:	mov    -0x170(%rbp),%rax
  40e9f5:	mov    %rax,-0xd8(%rbp)
  40e9fc:	mov    %rdi,%rbx
  40e9ff:	callq  435300 <p111_rt_sink>
  40ea04:	mov    %rbx,%rdi
  40ea07:	mov    -0xa8(%rbp),%rsi
  40ea0e:	mov    %rdi,%rbx
  40ea11:	callq  435300 <p111_rt_sink>
  40ea16:	mov    %rbx,%rdi
  40ea19:	mov    -0xb0(%rbp),%rsi
  40ea20:	mov    %rdi,%rbx
  40ea23:	callq  435300 <p111_rt_sink>
  40ea28:	mov    %rbx,%rdi
  40ea2b:	mov    -0xb8(%rbp),%rsi
  40ea32:	mov    %rdi,%rbx
  40ea35:	callq  435300 <p111_rt_sink>
  40ea3a:	mov    %rbx,%rdi
  40ea3d:	mov    -0xc0(%rbp),%rsi
  40ea44:	mov    %rdi,%rbx
  40ea47:	callq  435300 <p111_rt_sink>
  40ea4c:	mov    %rbx,%rdi
  40ea4f:	mov    -0xc8(%rbp),%rsi
  40ea56:	mov    %rdi,%rbx
  40ea59:	callq  435300 <p111_rt_sink>
  40ea5e:	mov    %rbx,%rdi
  40ea61:	mov    -0xd0(%rbp),%rsi
  40ea68:	mov    %rdi,%rbx
  40ea6b:	callq  435300 <p111_rt_sink>
  40ea70:	mov    %rbx,%rdi
  40ea73:	mov    -0xd8(%rbp),%rsi
  40ea7a:	mov    %rdi,%rbx
  40ea7d:	callq  435300 <p111_rt_sink>
  40ea82:	mov    %rbx,%rdi
  40ea85:	mov    -0xe0(%rbp),%rsi
  40ea8c:	mov    %rdi,%rbx
  40ea8f:	callq  435270 <p111_rt_keep>
  40ea94:	mov    %rbx,%rdi
  40ea97:	mov    %rax,-0xe8(%rbp)
  40ea9e:	movabs $0x200190003108648,%rsi
  40eaa8:	mov    %rdi,%rbx
  40eaab:	callq  435270 <p111_rt_keep>
  40eab0:	mov    %r14,%rdx
  40eab3:	mov    %rbx,%rdi
  40eab6:	mov    %rax,%rsi
  40eab9:	mov    %rsi,%rax
  40eabc:	mov    -0xe8(%rbp),%rsi
  40eac3:	mov    %rax,-0xf0(%rbp)
  40eaca:	mov    $0x1,%ecx
  40eacf:	mov    %rdx,%r14
  40ead2:	mov    %rax,%rdx
  40ead5:	mov    %rdi,%rbx
  40ead8:	callq  405c00 <p113d_FID_36_100_105_114_101_99_116_46_112_56_56_95_115_116_114_105_110_103_95_101_113_95_103_111_>
  40eadd:	mov    %r15,%rsi
  40eae0:	mov    %rbx,%rdi
  40eae3:	mov    %rax,-0x100(%rbp)
  40eaea:	mov    %rsi,%r15
  40eaed:	mov    -0xe8(%rbp),%rsi
  40eaf4:	mov    %rdi,%rbx
  40eaf7:	callq  435300 <p111_rt_sink>
  40eafc:	mov    %r15,%rsi
  40eaff:	mov    %rbx,%rdi
  40eb02:	mov    %rsi,%r15
  40eb05:	mov    -0xf0(%rbp),%rsi
  40eb0c:	mov    %rdi,%rbx
  40eb0f:	callq  435300 <p111_rt_sink>
  40eb14:	mov    %r15,%rsi
  40eb17:	mov    %rbx,%rdi
  40eb1a:	mov    -0xf8(%rbp),%r15d
  40eb21:	mov    -0x100(%rbp),%rcx
  40eb28:	cmp    $0x1,%rcx
  40eb2c:	sete   %al
  40eb2f:	movzbl %al,%eax
  40eb32:	shr    $0x28,%rcx
  40eb36:	and    $0x7fffff,%rcx
  40eb3d:	cmp    $0x10002,%rcx
  40eb44:	sete   %cl
  40eb47:	movzbl %cl,%ecx
  40eb4a:	mov    %eax,%ebx
  40eb4c:	or     %ecx,%ebx
  40eb4e:	jne    40ebdd <p113d_FID_36_100_105_114_101_99_116_46_110_99_95_99_116_111_114_95_111_119_110_101_100_+0xa3d>
  40eb54:	mov    %rdi,%r12
  40eb57:	callq  435300 <p111_rt_sink>
  40eb5c:	mov    %r14,%rdx
  40eb5f:	mov    %r13,%rsi
  40eb62:	mov    %r12,%rdi
  40eb65:	mov    %ebx,%eax
  40eb67:	xor    $0x1,%eax
  40eb6a:	je     40eba7 <p113d_FID_36_100_105_114_101_99_116_46_110_99_95_99_116_111_114_95_111_119_110_101_100_+0xa07>
  40eb6c:	mov    $0x0,%ecx
  40eb71:	mov    %rdx,%r13
  40eb74:	lea    -0xa40(%rbp),%rdx
  40eb7b:	mov    %rsi,%r12
  40eb7e:	mov    $0x0,%esi
  40eb83:	mov    %rdi,%rbx
  40eb86:	callq  435370 <p111_rt_ctor>
  40eb8b:	mov    %rbx,%rdi
  40eb8e:	mov    %rax,%rsi
  40eb91:	mov    %rdi,%rbx
  40eb94:	callq  435300 <p111_rt_sink>
  40eb99:	mov    %r13,%rdx
  40eb9c:	mov    %r12,%rsi
  40eb9f:	mov    %rbx,%rdi
  40eba2:	jmpq   40e1c0 <p113d_FID_36_100_105_114_101_99_116_46_110_99_95_99_116_111_114_95_111_119_110_101_100_+0x20>
  40eba7:	mov    %rsi,%r12
  40ebaa:	mov    %rdx,%rsi
  40ebad:	mov    %rdi,%rbx
  40ebb0:	callq  435300 <p111_rt_sink>
  40ebb5:	mov    %r12,%rsi
  40ebb8:	mov    %rbx,%rdi
  40ebbb:	mov    %rsi,%r15
  40ebbe:	mov    %rdi,%rbx
  40ebc1:	callq  435300 <p111_rt_sink>
  40ebc6:	mov    %rbx,%rdi
  40ebc9:	mov    $0x4,%esi
  40ebce:	callq  435a90 <p111_rt_fail>
  40ebd3:	mov    $0x0,%eax
  40ebd8:	jmpq   40edd6 <p113d_FID_36_100_105_114_101_99_116_46_110_99_95_99_116_111_114_95_111_119_110_101_100_+0xc36>
  40ebdd:	xchg   %rsi,%r14
  40ebe0:	mov    %r15d,%ebx
  40ebe3:	mov    %r13,%r15
  40ebe6:	mov    %rdi,%r13
  40ebe9:	callq  435300 <p111_rt_sink>
  40ebee:	mov    %r15,%rsi
  40ebf1:	mov    %r13,%rdi
  40ebf4:	mov    %rdi,%r13
  40ebf7:	callq  435300 <p111_rt_sink>
  40ebfc:	mov    %r14,%rsi
  40ebff:	mov    %r13,%rdi
  40ec02:	mov    $0x0,%ecx
  40ec07:	lea    -0xa40(%rbp),%rdx
  40ec0e:	mov    %rsi,%r14
  40ec11:	mov    $0x0,%esi
  40ec16:	mov    %rdi,%r13
  40ec19:	callq  435370 <p111_rt_ctor>
  40ec1e:	mov    %r13,%rdi
  40ec21:	mov    %rax,%rsi
  40ec24:	mov    %rdi,%r13
  40ec27:	callq  435300 <p111_rt_sink>
  40ec2c:	mov    %r14,%rsi
  40ec2f:	mov    %r13,%rdi
  40ec32:	cmp    $0x99,%r12
  40ec39:	je     40ecbe <p113d_FID_36_100_105_114_101_99_116_46_110_99_95_99_116_111_114_95_111_119_110_101_100_+0xb1e>
  40ec3f:	nop
  40ec40:	cmp    $0x9a,%r12
  40ec47:	je     40ec93 <p113d_FID_36_100_105_114_101_99_116_46_110_99_95_99_116_111_114_95_111_119_110_101_100_+0xaf3>
  40ec49:	cmp    $0x9b,%r12
  40ec50:	je     40ec5e <p113d_FID_36_100_105_114_101_99_116_46_110_99_95_99_116_111_114_95_111_119_110_101_100_+0xabe>
  40ec52:	mov    $0x4,%esi
  40ec57:	callq  435a90 <p111_rt_fail>
  40ec5c:	jmp    40ecb6 <p113d_FID_36_100_105_114_101_99_116_46_110_99_95_99_116_111_114_95_111_119_110_101_100_+0xb16>
  40ec5e:	lea    -0x168(%rbp),%rdx
  40ec65:	mov    %rdi,%r12
  40ec68:	callq  43af80 <p125_rt_take4>
  40ec6d:	mov    %r12,%rdi
  40ec70:	mov    -0x158(%rbp),%rsi
  40ec77:	mov    -0x150(%rbp),%r13
  40ec7e:	mov    %rdi,%r12
  40ec81:	callq  435300 <p111_rt_sink>
  40ec86:	mov    %r13,%rsi
  40ec89:	mov    %r12,%rdi
  40ec8c:	callq  435300 <p111_rt_sink>
  40ec91:	jmp    40ecb6 <p113d_FID_36_100_105_114_101_99_116_46_110_99_95_99_116_111_114_95_111_119_110_101_100_+0xb16>
  40ec93:	lea    -0x168(%rbp),%rdx
  40ec9a:	mov    %rdi,%rbx
  40ec9d:	callq  43aab0 <p125_rt_take2>
  40eca2:	mov    %rbx,%rdi
  40eca5:	mov    -0x160(%rbp),%rsi
  40ecac:	callq  435300 <p111_rt_sink>
  40ecb1:	mov    $0x1,%ebx
  40ecb6:	mov    %rbx,%rax
  40ecb9:	jmpq   40edd6 <p113d_FID_36_100_105_114_101_99_116_46_110_99_95_99_116_111_114_95_111_119_110_101_100_+0xc36>
  40ecbe:	mov    $0x9,%ecx
  40ecc3:	lea    -0x168(%rbp),%rdx
  40ecca:	mov    %rdi,%rbx
  40eccd:	callq  4354f0 <p111_rt_take>
  40ecd2:	mov    %rbx,%rdi
  40ecd5:	mov    -0x168(%rbp),%rsi
  40ecdc:	mov    -0x160(%rbp),%r15
  40ece3:	mov    -0x158(%rbp),%r14
  40ecea:	mov    -0x150(%rbp),%r12
  40ecf1:	mov    -0x148(%rbp),%r13
  40ecf8:	mov    -0x140(%rbp),%rbx
  40ecff:	mov    %rbx,-0x108(%rbp)
  40ed06:	mov    -0x138(%rbp),%rbx
  40ed0d:	mov    %rbx,-0x110(%rbp)
  40ed14:	mov    -0x130(%rbp),%rbx
  40ed1b:	mov    %rbx,-0x118(%rbp)
  40ed22:	mov    -0x128(%rbp),%rbx
  40ed29:	mov    %rbx,-0x120(%rbp)
  40ed30:	mov    %rdi,%rbx
  40ed33:	callq  435300 <p111_rt_sink>
  40ed38:	mov    %r15,%rsi
  40ed3b:	mov    %rbx,%rdi
  40ed3e:	mov    -0x108(%rbp),%r15
  40ed45:	mov    %rdi,%rbx
  40ed48:	callq  435300 <p111_rt_sink>
  40ed4d:	mov    %r14,%rsi
  40ed50:	mov    %rbx,%rdi
  40ed53:	mov    -0x110(%rbp),%r14
  40ed5a:	mov    %rdi,%rbx
  40ed5d:	callq  435300 <p111_rt_sink>
  40ed62:	mov    %r12,%rsi
  40ed65:	mov    %rbx,%rdi
  40ed68:	mov    -0x118(%rbp),%rbx
  40ed6f:	mov    %rdi,%r12
  40ed72:	callq  435300 <p111_rt_sink>
  40ed77:	mov    %r13,%rsi
  40ed7a:	mov    %r12,%rdi
  40ed7d:	mov    -0x120(%rbp),%r13
  40ed84:	mov    %rdi,%r12
  40ed87:	callq  435300 <p111_rt_sink>
  40ed8c:	mov    %r15,%rsi
  40ed8f:	mov    %r12,%rdi
  40ed92:	mov    %rdi,%r12
  40ed95:	callq  435300 <p111_rt_sink>
  40ed9a:	mov    %r14,%rsi
  40ed9d:	mov    %r12,%rdi
  40eda0:	mov    %rdi,%r12
  40eda3:	callq  435300 <p111_rt_sink>
  40eda8:	mov    %r13,%rsi
  40edab:	mov    %r12,%rdi
  40edae:	callq  435300 <p111_rt_sink>
  40edb3:	mov    %rbx,%rax
  40edb6:	jmp    40edd6 <p113d_FID_36_100_105_114_101_99_116_46_110_99_95_99_116_111_114_95_111_119_110_101_100_+0xc36>
  40edb8:	mov    $0x4,%esi
  40edbd:	callq  435a90 <p111_rt_fail>
  40edc2:	mov    $0x0,%eax
  40edc7:	jmp    40edd6 <p113d_FID_36_100_105_114_101_99_116_46_110_99_95_99_116_111_114_95_111_119_110_101_100_+0xc36>
  40edc9:	mov    %rdx,%rsi
  40edcc:	callq  435300 <p111_rt_sink>
  40edd1:	mov    $0x0,%eax
  40edd6:	pop    %r15
  40edd8:	pop    %r14
  40edda:	pop    %r13
  40eddc:	pop    %r12
  40edde:	pop    %rbx
  40eddf:	leaveq 
  40ede0:	retq   

Disassembly of section .fini:
