
/home/ai/bend2/build/publish/bend/selfhost/build/phase111/p137-query-v02-builds01-wide-queries-fused-v02/program:     file format elf64-x86-64


Disassembly of section .init:

Disassembly of section .plt:

Disassembly of section .text:

0000000000410280 <p113d_FID_36_100_105_114_101_99_116_46_112_49_51_55_113_95_114_101_112_101_97_116_>:
  410280:	endbr64 
  410284:	push   %rbp
  410285:	mov    %rsp,%rbp
  410288:	sub    $0x2f8,%rsp
  41028f:	push   %rbx
  410290:	push   %r12
  410292:	push   %r13
  410294:	push   %r14
  410296:	push   %r15
  410298:	mov    %r9,%rax
  41029b:	mov    %r8,%r13
  41029e:	mov    %rcx,%r12
  4102a1:	mov    %rdx,%rbx
  4102a4:	mov    %rbx,%rdx
  4102a7:	mov    %r13,%r14
  4102aa:	mov    %r12,%r13
  4102ad:	mov    %rax,-0x1a0(%rbp)
  4102b4:	data16 nopw %cs:0x0(%rax,%rax,1)
  4102bf:	nop
  4102c0:	cmp    $0x0,%rsi
  4102c4:	je     411109 <p113d_FID_36_100_105_114_101_99_116_46_112_49_51_55_113_95_114_101_112_101_97_116_+0xe89>
  4102ca:	cs cs mov %rsi,%r12
  4102cf:	mov    %rdx,%rsi
  4102d2:	mov    %rdi,%rbx
  4102d5:	callq  435270 <p111_rt_keep>
  4102da:	mov    %r13,%rcx
  4102dd:	mov    %r12,%rsi
  4102e0:	mov    %rbx,%rdi
  4102e3:	mov    %rax,%r13
  4102e6:	mov    %rsi,%r12
  4102e9:	mov    %rcx,%rsi
  4102ec:	mov    %rdi,%rbx
  4102ef:	callq  435270 <p111_rt_keep>
  4102f4:	mov    %r14,%r8
  4102f7:	mov    %r12,%rsi
  4102fa:	mov    %rbx,%rdi
  4102fd:	mov    %rax,%r14
  410300:	mov    %rsi,%r12
  410303:	mov    %r8,%rsi
  410306:	mov    %rdi,%rbx
  410309:	callq  435270 <p111_rt_keep>
  41030e:	mov    %r12,%rsi
  410311:	mov    %rbx,%rdi
  410314:	mov    %rax,%r15
  410317:	mov    %rsi,%r12
  41031a:	mov    %r14,%rsi
  41031d:	mov    %rdi,%rbx
  410320:	callq  435300 <p111_rt_sink>
  410325:	mov    %r12,%rsi
  410328:	mov    %rbx,%rdi
  41032b:	mov    %rsi,%r12
  41032e:	mov    %r13,%rsi
  410331:	mov    %rdi,%rbx
  410334:	callq  435270 <p111_rt_keep>
  410339:	mov    %r12,%rsi
  41033c:	mov    %rbx,%rdi
  41033f:	mov    %rax,-0x68(%rbp)
  410343:	mov    %rsi,%r12
  410346:	mov    %r15,%rsi
  410349:	mov    %rdi,%rbx
  41034c:	callq  435270 <p111_rt_keep>
  410351:	mov    %r15,%r8
  410354:	mov    %r14,%rcx
  410357:	mov    %r12,%rsi
  41035a:	mov    %rbx,%rdi
  41035d:	mov    %rax,%rdx
  410360:	mov    -0x68(%rbp),%rax
  410364:	mov    %rdx,-0x70(%rbp)
  410368:	mov    $0x0,%r9d
  41036e:	mov    %r8,%r15
  410371:	mov    $0x0,%r8d
  410377:	mov    %rcx,%r14
  41037a:	mov    %rax,%rcx
  41037d:	mov    %rsi,%rbx
  410380:	mov    $0x1,%esi
  410385:	mov    %rdi,%r12
  410388:	callq  40b870 <p113d_FID_36_112_49_50_54_115_99_99_46_53_49_>
  41038d:	mov    %r12,%rdi
  410390:	mov    %rax,%rsi
  410393:	mov    %rsi,%rax
  410396:	shr    $0x28,%rax
  41039a:	and    $0xffff,%rax
  4103a0:	cmp    $0x99,%rax
  4103a6:	je     4104c9 <p113d_FID_36_100_105_114_101_99_116_46_112_49_51_55_113_95_114_101_112_101_97_116_+0x249>
  4103ac:	cmp    $0x9a,%rax
  4103b2:	je     410462 <p113d_FID_36_100_105_114_101_99_116_46_112_49_51_55_113_95_114_101_112_101_97_116_+0x1e2>
  4103b8:	nopl   0x0(%rax,%rax,1)
  4103c0:	cmp    $0x9b,%rax
  4103c6:	je     4103f2 <p113d_FID_36_100_105_114_101_99_116_46_112_49_51_55_113_95_114_101_112_101_97_116_+0x172>
  4103c8:	mov    %rbx,%rsi
  4103cb:	mov    %rsi,%r12
  4103ce:	mov    $0x4,%esi
  4103d3:	mov    %rdi,%rbx
  4103d6:	callq  435a90 <p111_rt_fail>
  4103db:	mov    %r13,%rdx
  4103de:	mov    %r12,%rsi
  4103e1:	mov    %rbx,%rdi
  4103e4:	mov    %rsi,%r12
  4103e7:	mov    -0x68(%rbp),%rsi
  4103eb:	mov    $0x0,%eax
  4103f0:	jmp    41045d <p113d_FID_36_100_105_114_101_99_116_46_112_49_51_55_113_95_114_101_112_101_97_116_+0x1dd>
  4103f2:	cs cs mov %rbx,%r12
  4103f7:	mov    %r13,%rdx
  4103fa:	mov    %rdx,%r13
  4103fd:	lea    -0x2f0(%rbp),%rdx
  410404:	mov    %rdi,%rbx
  410407:	callq  43af80 <p125_rt_take4>
  41040c:	mov    %rbx,%rdi
  41040f:	mov    -0x2f0(%rbp),%rax
  410416:	mov    %rax,-0x18(%rbp)
  41041a:	mov    -0x2e0(%rbp),%rsi
  410421:	mov    -0x2d8(%rbp),%rax
  410428:	mov    %rax,-0x10(%rbp)
  41042c:	mov    %rdi,%rbx
  41042f:	callq  435300 <p111_rt_sink>
  410434:	mov    %r12,%rsi
  410437:	mov    %rbx,%rdi
  41043a:	mov    %rsi,%r12
  41043d:	mov    -0x10(%rbp),%rsi
  410441:	mov    %rdi,%rbx
  410444:	callq  435300 <p111_rt_sink>
  410449:	mov    %r13,%rdx
  41044c:	mov    %r12,%rsi
  41044f:	mov    %rbx,%rdi
  410452:	mov    %rsi,%r12
  410455:	mov    -0x68(%rbp),%rsi
  410459:	mov    -0x18(%rbp),%rax
  41045d:	mov    %r14,%rcx
  410460:	jmp    4104b4 <p113d_FID_36_100_105_114_101_99_116_46_112_49_51_55_113_95_114_101_112_101_97_116_+0x234>
  410462:	mov    %rbx,%r12
  410465:	mov    %r13,%rdx
  410468:	mov    %rdx,%r13
  41046b:	lea    -0x2f0(%rbp),%rdx
  410472:	mov    %rdi,%rbx
  410475:	callq  43aab0 <p125_rt_take2>
  41047a:	mov    %r12,%rsi
  41047d:	mov    %rbx,%rdi
  410480:	mov    -0x2f0(%rbp),%rax
  410487:	mov    %rax,-0x20(%rbp)
  41048b:	mov    %rsi,%r12
  41048e:	mov    -0x2e8(%rbp),%rsi
  410495:	mov    %rdi,%rbx
  410498:	callq  435300 <p111_rt_sink>
  41049d:	mov    %r14,%rcx
  4104a0:	mov    %r13,%rdx
  4104a3:	mov    %r12,%rsi
  4104a6:	mov    %rbx,%rdi
  4104a9:	mov    %rsi,%r12
  4104ac:	mov    -0x68(%rbp),%rsi
  4104b0:	mov    -0x20(%rbp),%rax
  4104b4:	mov    %r12,%rbx
  4104b7:	mov    %rcx,%r14
  4104ba:	mov    %rdx,%r13
  4104bd:	mov    %rax,-0x1c8(%rbp)
  4104c4:	jmpq   410606 <p113d_FID_36_100_105_114_101_99_116_46_112_49_51_55_113_95_114_101_112_101_97_116_+0x386>
  4104c9:	cs cs cs cs mov %rbx,%r12
  4104d0:	cs mov %r14,%rcx
  4104d4:	mov    %r13,%rdx
  4104d7:	mov    %rcx,%r14
  4104da:	mov    $0x9,%ecx
  4104df:	mov    %rdx,%r13
  4104e2:	lea    -0x2f0(%rbp),%rdx
  4104e9:	mov    %rdi,%rbx
  4104ec:	callq  4354f0 <p111_rt_take>
  4104f1:	mov    %rbx,%rdi
  4104f4:	mov    -0x2f0(%rbp),%rsi
  4104fb:	mov    -0x2e8(%rbp),%rax
  410502:	mov    %rax,-0x28(%rbp)
  410506:	mov    -0x2e0(%rbp),%rax
  41050d:	mov    %rax,-0x60(%rbp)
  410511:	mov    -0x2d8(%rbp),%rax
  410518:	mov    %rax,-0x30(%rbp)
  41051c:	mov    -0x2d0(%rbp),%rax
  410523:	mov    %rax,-0x38(%rbp)
  410527:	mov    -0x2c8(%rbp),%rax
  41052e:	mov    %rax,-0x40(%rbp)
  410532:	mov    -0x2c0(%rbp),%rax
  410539:	mov    %rax,-0x48(%rbp)
  41053d:	mov    -0x2b8(%rbp),%rax
  410544:	mov    %rax,-0x50(%rbp)
  410548:	mov    -0x2b0(%rbp),%rax
  41054f:	mov    %rax,-0x58(%rbp)
  410553:	mov    %rdi,%rbx
  410556:	callq  435300 <p111_rt_sink>
  41055b:	mov    %r12,%rsi
  41055e:	mov    %rbx,%rdi
  410561:	mov    %rsi,%r12
  410564:	mov    -0x28(%rbp),%rsi
  410568:	mov    %rdi,%rbx
  41056b:	callq  435300 <p111_rt_sink>
  410570:	mov    %r12,%rsi
  410573:	mov    %rbx,%rdi
  410576:	mov    %rsi,%r12
  410579:	mov    -0x30(%rbp),%rsi
  41057d:	mov    %rdi,%rbx
  410580:	callq  435300 <p111_rt_sink>
  410585:	mov    %r12,%rsi
  410588:	mov    %rbx,%rdi
  41058b:	mov    %rsi,%r12
  41058e:	mov    -0x38(%rbp),%rsi
  410592:	mov    %rdi,%rbx
  410595:	callq  435300 <p111_rt_sink>
  41059a:	mov    %r12,%rsi
  41059d:	mov    %rbx,%rdi
  4105a0:	mov    %rsi,%r12
  4105a3:	mov    -0x40(%rbp),%rsi
  4105a7:	mov    %rdi,%rbx
  4105aa:	callq  435300 <p111_rt_sink>
  4105af:	mov    %r12,%rsi
  4105b2:	mov    %rbx,%rdi
  4105b5:	mov    %rsi,%r12
  4105b8:	mov    -0x48(%rbp),%rsi
  4105bc:	mov    %rdi,%rbx
  4105bf:	callq  435300 <p111_rt_sink>
  4105c4:	mov    %r12,%rsi
  4105c7:	mov    %rbx,%rdi
  4105ca:	mov    %rsi,%r12
  4105cd:	mov    -0x50(%rbp),%rsi
  4105d1:	mov    %rdi,%rbx
  4105d4:	callq  435300 <p111_rt_sink>
  4105d9:	mov    %r12,%rsi
  4105dc:	mov    %rbx,%rdi
  4105df:	mov    %rsi,%r12
  4105e2:	mov    -0x58(%rbp),%rsi
  4105e6:	mov    %rdi,%rbx
  4105e9:	callq  435300 <p111_rt_sink>
  4105ee:	mov    %r12,%rsi
  4105f1:	mov    %rbx,%rdi
  4105f4:	mov    %rsi,%rbx
  4105f7:	mov    -0x68(%rbp),%rsi
  4105fb:	mov    -0x60(%rbp),%rax
  4105ff:	mov    %rax,-0x1c8(%rbp)
  410606:	mov    %rdi,%r12
  410609:	callq  435270 <p111_rt_keep>
  41060e:	mov    %r13,%rdx
  410611:	mov    %r12,%rdi
  410614:	mov    %rax,%rsi
  410617:	mov    %rdx,%r13
  41061a:	mov    -0x70(%rbp),%rdx
  41061e:	mov    %rsi,-0xd0(%rbp)
  410625:	mov    %rdi,%r12
  410628:	callq  40cd80 <p113d_FID_36_100_105_114_101_99_116_46_108_111_111_107_117_112_>
  41062d:	mov    %r12,%rdi
  410630:	mov    %rax,%rsi
  410633:	mov    %rsi,%rax
  410636:	shr    $0x28,%rax
  41063a:	and    $0xffff,%rax
  410640:	cmp    $0x99,%rax
  410646:	je     410774 <p113d_FID_36_100_105_114_101_99_116_46_112_49_51_55_113_95_114_101_112_101_97_116_+0x4f4>
  41064c:	cmp    $0x9a,%rax
  410652:	je     410707 <p113d_FID_36_100_105_114_101_99_116_46_112_49_51_55_113_95_114_101_112_101_97_116_+0x487>
  410658:	nopl   0x0(%rax,%rax,1)
  410660:	cmp    $0x9b,%rax
  410666:	je     410696 <p113d_FID_36_100_105_114_101_99_116_46_112_49_51_55_113_95_114_101_112_101_97_116_+0x416>
  410668:	mov    %rbx,%rsi
  41066b:	mov    %rsi,%r12
  41066e:	mov    $0x4,%esi
  410673:	mov    %rdi,%rbx
  410676:	callq  435a90 <p111_rt_fail>
  41067b:	mov    %r13,%rdx
  41067e:	mov    %r12,%rsi
  410681:	mov    %rbx,%rdi
  410684:	mov    %rsi,%r12
  410687:	mov    -0xd0(%rbp),%rsi
  41068e:	mov    $0x0,%r10d
  410694:	jmp    410702 <p113d_FID_36_100_105_114_101_99_116_46_112_49_51_55_113_95_114_101_112_101_97_116_+0x482>
  410696:	mov    %rbx,%r12
  410699:	mov    %r13,%rdx
  41069c:	mov    %rdx,%r13
  41069f:	lea    -0x2a8(%rbp),%rdx
  4106a6:	mov    %rdi,%rbx
  4106a9:	callq  43af80 <p125_rt_take4>
  4106ae:	mov    %rbx,%rdi
  4106b1:	mov    -0x2a8(%rbp),%r10
  4106b8:	mov    %r10,-0x80(%rbp)
  4106bc:	mov    -0x298(%rbp),%rsi
  4106c3:	mov    -0x290(%rbp),%rax
  4106ca:	mov    %rax,-0x78(%rbp)
  4106ce:	mov    %rdi,%rbx
  4106d1:	callq  435300 <p111_rt_sink>
  4106d6:	mov    %r12,%rsi
  4106d9:	mov    %rbx,%rdi
  4106dc:	mov    %rsi,%r12
  4106df:	mov    -0x78(%rbp),%rsi
  4106e3:	mov    %rdi,%rbx
  4106e6:	callq  435300 <p111_rt_sink>
  4106eb:	mov    %r13,%rdx
  4106ee:	mov    %r12,%rsi
  4106f1:	mov    %rbx,%rdi
  4106f4:	mov    %rsi,%r12
  4106f7:	mov    -0xd0(%rbp),%rsi
  4106fe:	mov    -0x80(%rbp),%r10
  410702:	mov    %r14,%rcx
  410705:	jmp    410762 <p113d_FID_36_100_105_114_101_99_116_46_112_49_51_55_113_95_114_101_112_101_97_116_+0x4e2>
  410707:	mov    %rbx,%r12
  41070a:	mov    %r13,%rdx
  41070d:	mov    %rdx,%r13
  410710:	lea    -0x2a8(%rbp),%rdx
  410717:	mov    %rdi,%rbx
  41071a:	callq  43aab0 <p125_rt_take2>
  41071f:	mov    %r12,%rsi
  410722:	mov    %rbx,%rdi
  410725:	mov    -0x2a8(%rbp),%r10
  41072c:	mov    %r10,-0x88(%rbp)
  410733:	mov    %rsi,%r12
  410736:	mov    -0x2a0(%rbp),%rsi
  41073d:	mov    %rdi,%rbx
  410740:	callq  435300 <p111_rt_sink>
  410745:	mov    %r14,%rcx
  410748:	mov    %r13,%rdx
  41074b:	mov    %r12,%rsi
  41074e:	mov    %rbx,%rdi
  410751:	mov    %rsi,%r12
  410754:	mov    -0xd0(%rbp),%rsi
  41075b:	mov    -0x88(%rbp),%r10
  410762:	mov    %rcx,%r14
  410765:	mov    %rdx,%r13
  410768:	mov    %r10,-0x1c0(%rbp)
  41076f:	jmpq   4108df <p113d_FID_36_100_105_114_101_99_116_46_112_49_51_55_113_95_114_101_112_101_97_116_+0x65f>
  410774:	mov    %rbx,%r12
  410777:	mov    %r14,%rcx
  41077a:	mov    %r13,%rdx
  41077d:	mov    %rcx,%r14
  410780:	mov    $0x9,%ecx
  410785:	mov    %rdx,%r13
  410788:	lea    -0x2a8(%rbp),%rdx
  41078f:	mov    %rdi,%rbx
  410792:	callq  4354f0 <p111_rt_take>
  410797:	mov    %rbx,%rdi
  41079a:	mov    -0x2a8(%rbp),%rsi
  4107a1:	mov    -0x2a0(%rbp),%rax
  4107a8:	mov    %rax,-0x90(%rbp)
  4107af:	mov    -0x298(%rbp),%r10
  4107b6:	mov    %r10,-0xc8(%rbp)
  4107bd:	mov    -0x290(%rbp),%rax
  4107c4:	mov    %rax,-0x98(%rbp)
  4107cb:	mov    -0x288(%rbp),%rax
  4107d2:	mov    %rax,-0xa0(%rbp)
  4107d9:	mov    -0x280(%rbp),%rax
  4107e0:	mov    %rax,-0xa8(%rbp)
  4107e7:	mov    -0x278(%rbp),%rax
  4107ee:	mov    %rax,-0xb0(%rbp)
  4107f5:	mov    -0x270(%rbp),%rax
  4107fc:	mov    %rax,-0xb8(%rbp)
  410803:	mov    -0x268(%rbp),%rax
  41080a:	mov    %rax,-0xc0(%rbp)
  410811:	mov    %rdi,%rbx
  410814:	callq  435300 <p111_rt_sink>
  410819:	mov    %r12,%rsi
  41081c:	mov    %rbx,%rdi
  41081f:	mov    %rsi,%r12
  410822:	mov    -0x90(%rbp),%rsi
  410829:	mov    %rdi,%rbx
  41082c:	callq  435300 <p111_rt_sink>
  410831:	mov    %r12,%rsi
  410834:	mov    %rbx,%rdi
  410837:	mov    %rsi,%r12
  41083a:	mov    -0x98(%rbp),%rsi
  410841:	mov    %rdi,%rbx
  410844:	callq  435300 <p111_rt_sink>
  410849:	mov    %r12,%rsi
  41084c:	mov    %rbx,%rdi
  41084f:	mov    %rsi,%r12
  410852:	mov    -0xa0(%rbp),%rsi
  410859:	mov    %rdi,%rbx
  41085c:	callq  435300 <p111_rt_sink>
  410861:	mov    %r12,%rsi
  410864:	mov    %rbx,%rdi
  410867:	mov    %rsi,%r12
  41086a:	mov    -0xa8(%rbp),%rsi
  410871:	mov    %rdi,%rbx
  410874:	callq  435300 <p111_rt_sink>
  410879:	mov    %r12,%rsi
  41087c:	mov    %rbx,%rdi
  41087f:	mov    %rsi,%r12
  410882:	mov    -0xb0(%rbp),%rsi
  410889:	mov    %rdi,%rbx
  41088c:	callq  435300 <p111_rt_sink>
  410891:	mov    %r12,%rsi
  410894:	mov    %rbx,%rdi
  410897:	mov    %rsi,%r12
  41089a:	mov    -0xb8(%rbp),%rsi
  4108a1:	mov    %rdi,%rbx
  4108a4:	callq  435300 <p111_rt_sink>
  4108a9:	mov    %r12,%rsi
  4108ac:	mov    %rbx,%rdi
  4108af:	mov    %rsi,%r12
  4108b2:	mov    -0xc0(%rbp),%rsi
  4108b9:	mov    %rdi,%rbx
  4108bc:	callq  435300 <p111_rt_sink>
  4108c1:	mov    %r12,%rsi
  4108c4:	mov    %rbx,%rdi
  4108c7:	mov    %rsi,%r12
  4108ca:	mov    -0xd0(%rbp),%rsi
  4108d1:	mov    -0xc8(%rbp),%r10
  4108d8:	mov    %r10,-0x1c0(%rbp)
  4108df:	mov    %rdi,%rbx
  4108e2:	callq  435270 <p111_rt_keep>
  4108e7:	mov    %r13,%rdx
  4108ea:	mov    %rbx,%rdi
  4108ed:	mov    %rax,%rsi
  4108f0:	mov    %rsi,-0xd8(%rbp)
  4108f7:	mov    %rdx,%r13
  4108fa:	movabs $0x200190003108644,%rdx
  410904:	mov    %rsi,%rax
  410907:	mov    %rdi,%rbx
  41090a:	callq  40e1a0 <p113d_FID_36_100_105_114_101_99_116_46_110_99_95_99_116_111_114_95_111_119_110_101_100_>
  41090f:	mov    %r15,%r8
  410912:	mov    %r14,%rcx
  410915:	mov    %r13,%rdx
  410918:	mov    %r12,%rsi
  41091b:	mov    %rbx,%rdi
  41091e:	mov    %rax,%r9
  410921:	mov    -0xd8(%rbp),%rax
  410928:	cmp    $0x1,%r9
  41092c:	mov    %rcx,%r14
  41092f:	sete   %cl
  410932:	movzbl %cl,%ecx
  410935:	shr    $0x28,%r9
  410939:	and    $0x7fffff,%r9
  410940:	cmp    $0x10002,%r9
  410947:	mov    %rdx,%r13
  41094a:	sete   %dl
  41094d:	movzbl %dl,%edx
  410950:	mov    %ecx,%ebx
  410952:	or     %edx,%ebx
  410954:	mov    %ebx,-0x1cc(%rbp)
  41095a:	mov    %r8,%r15
  41095d:	mov    %ebx,%r8d
  410960:	xor    $0x1,%r8d
  410964:	jne    4109a2 <p113d_FID_36_100_105_114_101_99_116_46_112_49_51_55_113_95_114_101_112_101_97_116_+0x722>
  410966:	or     %edx,%ecx
  410968:	jne    410992 <p113d_FID_36_100_105_114_101_99_116_46_112_49_51_55_113_95_114_101_112_101_97_116_+0x712>
  41096a:	mov    %rsi,%r12
  41096d:	mov    $0x4,%esi
  410972:	mov    %rdi,%rbx
  410975:	callq  435a90 <p111_rt_fail>
  41097a:	mov    %r12,%rsi
  41097d:	mov    %rbx,%rdi
  410980:	mov    %rsi,%r12
  410983:	mov    -0xd8(%rbp),%rsi
  41098a:	mov    -0x1cc(%rbp),%ebx
  410990:	jmp    410999 <p113d_FID_36_100_105_114_101_99_116_46_112_49_51_55_113_95_114_101_112_101_97_116_+0x719>
  410992:	cs mov %rsi,%r12
  410996:	mov    %rax,%rsi
  410999:	mov    %rbx,-0x1b8(%rbp)
  4109a0:	jmp    4109bd <p113d_FID_36_100_105_114_101_99_116_46_112_49_51_55_113_95_114_101_112_101_97_116_+0x73d>
  4109a2:	cs cs cs cs mov %rsi,%r12
  4109a9:	cs cs cs cs mov %rax,%rsi
  4109b0:	cs movq $0x0,%cs:-0x1b8(%rbp)
  4109bd:	mov    %rdi,%rbx
  4109c0:	callq  435270 <p111_rt_keep>
  4109c5:	mov    %r15,%r8
  4109c8:	mov    %r14,%rcx
  4109cb:	mov    %r13,%rdx
  4109ce:	mov    %r12,%rsi
  4109d1:	mov    %rbx,%rdi
  4109d4:	mov    %rax,-0x138(%rbp)
  4109db:	mov    $0x0,%r9d
  4109e1:	mov    %r8,%r15
  4109e4:	mov    $0x0,%r8d
  4109ea:	mov    %rcx,%r14
  4109ed:	mov    %rax,%rcx
  4109f0:	mov    %rdx,%r13
  4109f3:	movabs $0x20019000310865a,%rdx
  4109fd:	mov    %rsi,%rbx
  410a00:	mov    $0x1,%esi
  410a05:	mov    %rdi,%r12
  410a08:	callq  40b870 <p113d_FID_36_112_49_50_54_115_99_99_46_53_49_>
  410a0d:	mov    %r12,%rdi
  410a10:	mov    %rax,%rsi
  410a13:	mov    %rsi,%rax
  410a16:	shr    $0x28,%rax
  410a1a:	and    $0xffff,%rax
  410a20:	cmp    $0x99,%rax
  410a26:	je     410b65 <p113d_FID_36_100_105_114_101_99_116_46_112_49_51_55_113_95_114_101_112_101_97_116_+0x8e5>
  410a2c:	cmp    $0x9a,%rax
  410a32:	je     410af3 <p113d_FID_36_100_105_114_101_99_116_46_112_49_51_55_113_95_114_101_112_101_97_116_+0x873>
  410a38:	nopl   0x0(%rax,%rax,1)
  410a40:	cmp    $0x9b,%rax
  410a46:	je     410a76 <p113d_FID_36_100_105_114_101_99_116_46_112_49_51_55_113_95_114_101_112_101_97_116_+0x7f6>
  410a48:	mov    %rbx,%rsi
  410a4b:	mov    %rsi,%r12
  410a4e:	mov    $0x4,%esi
  410a53:	mov    %rdi,%rbx
  410a56:	callq  435a90 <p111_rt_fail>
  410a5b:	mov    %r13,%rdx
  410a5e:	mov    %r12,%rsi
  410a61:	mov    %rbx,%rdi
  410a64:	mov    %rsi,%r12
  410a67:	mov    -0x138(%rbp),%rsi
  410a6e:	mov    $0x0,%r11d
  410a74:	jmp    410aee <p113d_FID_36_100_105_114_101_99_116_46_112_49_51_55_113_95_114_101_112_101_97_116_+0x86e>
  410a76:	mov    %rbx,%r12
  410a79:	mov    %r13,%rdx
  410a7c:	mov    %rdx,%r13
  410a7f:	lea    -0x260(%rbp),%rdx
  410a86:	mov    %rdi,%rbx
  410a89:	callq  43af80 <p125_rt_take4>
  410a8e:	mov    %rbx,%rdi
  410a91:	mov    -0x260(%rbp),%r11
  410a98:	mov    %r11,-0xe8(%rbp)
  410a9f:	mov    -0x250(%rbp),%rsi
  410aa6:	mov    -0x248(%rbp),%rax
  410aad:	mov    %rax,-0xe0(%rbp)
  410ab4:	mov    %rdi,%rbx
  410ab7:	callq  435300 <p111_rt_sink>
  410abc:	mov    %r12,%rsi
  410abf:	mov    %rbx,%rdi
  410ac2:	mov    %rsi,%r12
  410ac5:	mov    -0xe0(%rbp),%rsi
  410acc:	mov    %rdi,%rbx
  410acf:	callq  435300 <p111_rt_sink>
  410ad4:	mov    %r13,%rdx
  410ad7:	mov    %r12,%rsi
  410ada:	mov    %rbx,%rdi
  410add:	mov    %rsi,%r12
  410ae0:	mov    -0x138(%rbp),%rsi
  410ae7:	mov    -0xe8(%rbp),%r11
  410aee:	mov    %r14,%rcx
  410af1:	jmp    410b50 <p113d_FID_36_100_105_114_101_99_116_46_112_49_51_55_113_95_114_101_112_101_97_116_+0x8d0>
  410af3:	cs cs mov %rbx,%r12
  410af8:	mov    %r13,%rdx
  410afb:	mov    %rdx,%r13
  410afe:	lea    -0x260(%rbp),%rdx
  410b05:	mov    %rdi,%rbx
  410b08:	callq  43aab0 <p125_rt_take2>
  410b0d:	mov    %r12,%rsi
  410b10:	mov    %rbx,%rdi
  410b13:	mov    -0x260(%rbp),%r11
  410b1a:	mov    %r11,-0xf0(%rbp)
  410b21:	mov    %rsi,%r12
  410b24:	mov    -0x258(%rbp),%rsi
  410b2b:	mov    %rdi,%rbx
  410b2e:	callq  435300 <p111_rt_sink>
  410b33:	mov    %r14,%rcx
  410b36:	mov    %r13,%rdx
  410b39:	mov    %r12,%rsi
  410b3c:	mov    %rbx,%rdi
  410b3f:	mov    %rsi,%r12
  410b42:	mov    -0x138(%rbp),%rsi
  410b49:	mov    -0xf0(%rbp),%r11
  410b50:	mov    %r12,%rbx
  410b53:	mov    %rcx,%r14
  410b56:	mov    %rdx,%r13
  410b59:	mov    %r11,-0x1b0(%rbp)
  410b60:	jmpq   410cd0 <p113d_FID_36_100_105_114_101_99_116_46_112_49_51_55_113_95_114_101_112_101_97_116_+0xa50>
  410b65:	mov    %rbx,%r12
  410b68:	mov    %r14,%rcx
  410b6b:	mov    %r13,%rdx
  410b6e:	mov    %rcx,%r14
  410b71:	mov    $0x9,%ecx
  410b76:	mov    %rdx,%r13
  410b79:	lea    -0x260(%rbp),%rdx
  410b80:	mov    %rdi,%rbx
  410b83:	callq  4354f0 <p111_rt_take>
  410b88:	mov    %rbx,%rdi
  410b8b:	mov    -0x260(%rbp),%rsi
  410b92:	mov    -0x258(%rbp),%rax
  410b99:	mov    %rax,-0xf8(%rbp)
  410ba0:	mov    -0x250(%rbp),%r11
  410ba7:	mov    %r11,-0x130(%rbp)
  410bae:	mov    -0x248(%rbp),%rax
  410bb5:	mov    %rax,-0x100(%rbp)
  410bbc:	mov    -0x240(%rbp),%rax
  410bc3:	mov    %rax,-0x108(%rbp)
  410bca:	mov    -0x238(%rbp),%rax
  410bd1:	mov    %rax,-0x110(%rbp)
  410bd8:	mov    -0x230(%rbp),%rax
  410bdf:	mov    %rax,-0x118(%rbp)
  410be6:	mov    -0x228(%rbp),%rax
  410bed:	mov    %rax,-0x120(%rbp)
  410bf4:	mov    -0x220(%rbp),%rax
  410bfb:	mov    %rax,-0x128(%rbp)
  410c02:	mov    %rdi,%rbx
  410c05:	callq  435300 <p111_rt_sink>
  410c0a:	mov    %r12,%rsi
  410c0d:	mov    %rbx,%rdi
  410c10:	mov    %rsi,%r12
  410c13:	mov    -0xf8(%rbp),%rsi
  410c1a:	mov    %rdi,%rbx
  410c1d:	callq  435300 <p111_rt_sink>
  410c22:	mov    %r12,%rsi
  410c25:	mov    %rbx,%rdi
  410c28:	mov    %rsi,%r12
  410c2b:	mov    -0x100(%rbp),%rsi
  410c32:	mov    %rdi,%rbx
  410c35:	callq  435300 <p111_rt_sink>
  410c3a:	mov    %r12,%rsi
  410c3d:	mov    %rbx,%rdi
  410c40:	mov    %rsi,%r12
  410c43:	mov    -0x108(%rbp),%rsi
  410c4a:	mov    %rdi,%rbx
  410c4d:	callq  435300 <p111_rt_sink>
  410c52:	mov    %r12,%rsi
  410c55:	mov    %rbx,%rdi
  410c58:	mov    %rsi,%r12
  410c5b:	mov    -0x110(%rbp),%rsi
  410c62:	mov    %rdi,%rbx
  410c65:	callq  435300 <p111_rt_sink>
  410c6a:	mov    %r12,%rsi
  410c6d:	mov    %rbx,%rdi
  410c70:	mov    %rsi,%r12
  410c73:	mov    -0x118(%rbp),%rsi
  410c7a:	mov    %rdi,%rbx
  410c7d:	callq  435300 <p111_rt_sink>
  410c82:	mov    %r12,%rsi
  410c85:	mov    %rbx,%rdi
  410c88:	mov    %rsi,%r12
  410c8b:	mov    -0x120(%rbp),%rsi
  410c92:	mov    %rdi,%rbx
  410c95:	callq  435300 <p111_rt_sink>
  410c9a:	mov    %r12,%rsi
  410c9d:	mov    %rbx,%rdi
  410ca0:	mov    %rsi,%r12
  410ca3:	mov    -0x128(%rbp),%rsi
  410caa:	mov    %rdi,%rbx
  410cad:	callq  435300 <p111_rt_sink>
  410cb2:	mov    %r12,%rsi
  410cb5:	mov    %rbx,%rdi
  410cb8:	mov    %rsi,%rbx
  410cbb:	mov    -0x138(%rbp),%rsi
  410cc2:	mov    -0x130(%rbp),%r11
  410cc9:	mov    %r11,-0x1b0(%rbp)
  410cd0:	mov    %rdi,%r12
  410cd3:	callq  435270 <p111_rt_keep>
  410cd8:	mov    %r13,%rdx
  410cdb:	mov    %r12,%rdi
  410cde:	mov    %rax,%rsi
  410ce1:	mov    %rsi,-0x198(%rbp)
  410ce8:	mov    %rdx,%r13
  410ceb:	movabs $0x20019000310865a,%rdx
  410cf5:	mov    %rdi,%r12
  410cf8:	callq  40cd80 <p113d_FID_36_100_105_114_101_99_116_46_108_111_111_107_117_112_>
  410cfd:	mov    %r12,%rdi
  410d00:	mov    %rax,%rsi
  410d03:	mov    %rsi,%rax
  410d06:	shr    $0x28,%rax
  410d0a:	and    $0xffff,%rax
  410d10:	cmp    $0x99,%rax
  410d16:	je     410e49 <p113d_FID_36_100_105_114_101_99_116_46_112_49_51_55_113_95_114_101_112_101_97_116_+0xbc9>
  410d1c:	nopl   0x0(%rax)
  410d20:	cmp    $0x9a,%rax
  410d26:	je     410ddf <p113d_FID_36_100_105_114_101_99_116_46_112_49_51_55_113_95_114_101_112_101_97_116_+0xb5f>
  410d2c:	cmp    $0x9b,%rax
  410d32:	je     410d62 <p113d_FID_36_100_105_114_101_99_116_46_112_49_51_55_113_95_114_101_112_101_97_116_+0xae2>
  410d34:	cs mov %rbx,%rsi
  410d38:	mov    %rsi,%r12
  410d3b:	mov    $0x4,%esi
  410d40:	mov    %rdi,%rbx
  410d43:	callq  435a90 <p111_rt_fail>
  410d48:	mov    %r13,%rdx
  410d4b:	mov    %r12,%rsi
  410d4e:	mov    %rbx,%rdi
  410d51:	mov    %rsi,%r12
  410d54:	mov    -0x198(%rbp),%rsi
  410d5b:	mov    $0x0,%eax
  410d60:	jmp    410dda <p113d_FID_36_100_105_114_101_99_116_46_112_49_51_55_113_95_114_101_112_101_97_116_+0xb5a>
  410d62:	mov    %rbx,%r12
  410d65:	mov    %r13,%rdx
  410d68:	mov    %rdx,%r13
  410d6b:	lea    -0x218(%rbp),%rdx
  410d72:	mov    %rdi,%rbx
  410d75:	callq  43af80 <p125_rt_take4>
  410d7a:	mov    %rbx,%rdi
  410d7d:	mov    -0x218(%rbp),%rax
  410d84:	mov    %rax,-0x148(%rbp)
  410d8b:	mov    -0x208(%rbp),%rsi
  410d92:	mov    -0x200(%rbp),%rax
  410d99:	mov    %rax,-0x140(%rbp)
  410da0:	mov    %rdi,%rbx
  410da3:	callq  435300 <p111_rt_sink>
  410da8:	mov    %r12,%rsi
  410dab:	mov    %rbx,%rdi
  410dae:	mov    %rsi,%r12
  410db1:	mov    -0x140(%rbp),%rsi
  410db8:	mov    %rdi,%rbx
  410dbb:	callq  435300 <p111_rt_sink>
  410dc0:	mov    %r13,%rdx
  410dc3:	mov    %r12,%rsi
  410dc6:	mov    %rbx,%rdi
  410dc9:	mov    %rsi,%r12
  410dcc:	mov    -0x198(%rbp),%rsi
  410dd3:	mov    -0x148(%rbp),%rax
  410dda:	mov    %r14,%rcx
  410ddd:	jmp    410e3a <p113d_FID_36_100_105_114_101_99_116_46_112_49_51_55_113_95_114_101_112_101_97_116_+0xbba>
  410ddf:	mov    %rbx,%r12
  410de2:	mov    %r13,%rdx
  410de5:	mov    %rdx,%r13
  410de8:	lea    -0x218(%rbp),%rdx
  410def:	mov    %rdi,%rbx
  410df2:	callq  43aab0 <p125_rt_take2>
  410df7:	mov    %r12,%rsi
  410dfa:	mov    %rbx,%rdi
  410dfd:	mov    -0x218(%rbp),%rax
  410e04:	mov    %rax,-0x150(%rbp)
  410e0b:	mov    %rsi,%r12
  410e0e:	mov    -0x210(%rbp),%rsi
  410e15:	mov    %rdi,%rbx
  410e18:	callq  435300 <p111_rt_sink>
  410e1d:	mov    %r14,%rcx
  410e20:	mov    %r13,%rdx
  410e23:	mov    %r12,%rsi
  410e26:	mov    %rbx,%rdi
  410e29:	mov    %rsi,%r12
  410e2c:	mov    -0x198(%rbp),%rsi
  410e33:	mov    -0x150(%rbp),%rax
  410e3a:	mov    %rcx,%r14
  410e3d:	mov    %rax,-0x1a8(%rbp)
  410e44:	jmpq   410fb7 <p113d_FID_36_100_105_114_101_99_116_46_112_49_51_55_113_95_114_101_112_101_97_116_+0xd37>
  410e49:	mov    %rbx,%r12
  410e4c:	mov    %r14,%rcx
  410e4f:	mov    %r13,%rdx
  410e52:	mov    %rcx,%r14
  410e55:	mov    $0x9,%ecx
  410e5a:	mov    %rdx,%r13
  410e5d:	lea    -0x218(%rbp),%rdx
  410e64:	mov    %rdi,%rbx
  410e67:	callq  4354f0 <p111_rt_take>
  410e6c:	mov    %rbx,%rdi
  410e6f:	mov    -0x218(%rbp),%rsi
  410e76:	mov    -0x210(%rbp),%rax
  410e7d:	mov    %rax,-0x158(%rbp)
  410e84:	mov    -0x208(%rbp),%rax
  410e8b:	mov    %rax,-0x190(%rbp)
  410e92:	mov    -0x200(%rbp),%rax
  410e99:	mov    %rax,-0x160(%rbp)
  410ea0:	mov    -0x1f8(%rbp),%rax
  410ea7:	mov    %rax,-0x168(%rbp)
  410eae:	mov    -0x1f0(%rbp),%rax
  410eb5:	mov    %rax,-0x170(%rbp)
  410ebc:	mov    -0x1e8(%rbp),%rax
  410ec3:	mov    %rax,-0x178(%rbp)
  410eca:	mov    -0x1e0(%rbp),%rax
  410ed1:	mov    %rax,-0x180(%rbp)
  410ed8:	mov    -0x1d8(%rbp),%rax
  410edf:	mov    %rax,-0x188(%rbp)
  410ee6:	mov    %rdi,%rbx
  410ee9:	callq  435300 <p111_rt_sink>
  410eee:	mov    %r12,%rsi
  410ef1:	mov    %rbx,%rdi
  410ef4:	mov    %rsi,%r12
  410ef7:	mov    -0x158(%rbp),%rsi
  410efe:	mov    %rdi,%rbx
  410f01:	callq  435300 <p111_rt_sink>
  410f06:	mov    %r12,%rsi
  410f09:	mov    %rbx,%rdi
  410f0c:	mov    %rsi,%r12
  410f0f:	mov    -0x160(%rbp),%rsi
  410f16:	mov    %rdi,%rbx
  410f19:	callq  435300 <p111_rt_sink>
  410f1e:	mov    %r12,%rsi
  410f21:	mov    %rbx,%rdi
  410f24:	mov    %rsi,%r12
  410f27:	mov    -0x168(%rbp),%rsi
  410f2e:	mov    %rdi,%rbx
  410f31:	callq  435300 <p111_rt_sink>
  410f36:	mov    %r12,%rsi
  410f39:	mov    %rbx,%rdi
  410f3c:	mov    %rsi,%r12
  410f3f:	mov    -0x170(%rbp),%rsi
  410f46:	mov    %rdi,%rbx
  410f49:	callq  435300 <p111_rt_sink>
  410f4e:	mov    %r12,%rsi
  410f51:	mov    %rbx,%rdi
  410f54:	mov    %rsi,%r12
  410f57:	mov    -0x178(%rbp),%rsi
  410f5e:	mov    %rdi,%rbx
  410f61:	callq  435300 <p111_rt_sink>
  410f66:	mov    %r12,%rsi
  410f69:	mov    %rbx,%rdi
  410f6c:	mov    %rsi,%r12
  410f6f:	mov    -0x180(%rbp),%rsi
  410f76:	mov    %rdi,%rbx
  410f79:	callq  435300 <p111_rt_sink>
  410f7e:	mov    %r12,%rsi
  410f81:	mov    %rbx,%rdi
  410f84:	mov    %rsi,%r12
  410f87:	mov    -0x188(%rbp),%rsi
  410f8e:	mov    %rdi,%rbx
  410f91:	callq  435300 <p111_rt_sink>
  410f96:	mov    %r13,%rdx
  410f99:	mov    %r12,%rsi
  410f9c:	mov    %rbx,%rdi
  410f9f:	mov    %rsi,%r12
  410fa2:	mov    -0x198(%rbp),%rsi
  410fa9:	mov    -0x190(%rbp),%rax
  410fb0:	mov    %rax,-0x1a8(%rbp)
  410fb7:	mov    %rdx,%r13
  410fba:	movabs $0x20019000310865a,%rdx
  410fc4:	mov    %rdi,%rbx
  410fc7:	callq  40e1a0 <p113d_FID_36_100_105_114_101_99_116_46_110_99_95_99_116_111_114_95_111_119_110_101_100_>
  410fcc:	mov    %r15,%r8
  410fcf:	mov    %r14,%rcx
  410fd2:	mov    %r13,%rdx
  410fd5:	mov    %r12,%rsi
  410fd8:	mov    %rbx,%rdi
  410fdb:	mov    %rax,%r9
  410fde:	mov    -0x1a8(%rbp),%r12
  410fe5:	mov    -0x1b0(%rbp),%r11
  410fec:	mov    -0x1b8(%rbp),%rbx
  410ff3:	mov    -0x1c0(%rbp),%r10
  410ffa:	mov    -0x1c8(%rbp),%rax
  411001:	cmp    $0x1,%r9
  411005:	mov    %rdx,%r13
  411008:	sete   %dl
  41100b:	movzbl %dl,%edx
  41100e:	shr    $0x28,%r9
  411012:	and    $0x7fffff,%r9
  411019:	cmp    $0x10002,%r9
  411020:	mov    %r8,%r15
  411023:	sete   %r8b
  411027:	movzbl %r8b,%r8d
  41102b:	mov    %rcx,%r14
  41102e:	mov    %edx,%ecx
  411030:	or     %r8d,%ecx
  411033:	mov    %ecx,-0x1d0(%rbp)
  411039:	mov    %ecx,%r9d
  41103c:	xor    $0x1,%r9d
  411040:	mov    -0x1a0(%rbp),%r9
  411047:	jne    4110b0 <p113d_FID_36_100_105_114_101_99_116_46_112_49_51_55_113_95_114_101_112_101_97_116_+0xe30>
  411049:	or     %r8d,%edx
  41104c:	jne    4110a2 <p113d_FID_36_100_105_114_101_99_116_46_112_49_51_55_113_95_114_101_112_101_97_116_+0xe22>
  41104e:	cs cs mov %rsi,%r12
  411053:	mov    $0x4,%esi
  411058:	mov    %rdi,%rbx
  41105b:	callq  435a90 <p111_rt_fail>
  411060:	mov    %r15,%r8
  411063:	mov    %r14,%rcx
  411066:	mov    %r13,%rdx
  411069:	mov    %r12,%rsi
  41106c:	mov    %rbx,%rdi
  41106f:	mov    -0x1a8(%rbp),%r12
  411076:	mov    -0x1b0(%rbp),%r11
  41107d:	mov    -0x1b8(%rbp),%rbx
  411084:	mov    -0x1c0(%rbp),%r10
  41108b:	mov    -0x1c8(%rbp),%rax
  411092:	mov    -0x1a0(%rbp),%r9
  411099:	mov    -0x1d0(%rbp),%r13d
  4110a0:	jmp    4110bf <p113d_FID_36_100_105_114_101_99_116_46_112_49_51_55_113_95_114_101_112_101_97_116_+0xe3f>
  4110a2:	mov    %r15,%r8
  4110a5:	mov    %r13,%rdx
  4110a8:	mov    %ecx,%r13d
  4110ab:	mov    %r14,%rcx
  4110ae:	jmp    4110bf <p113d_FID_36_100_105_114_101_99_116_46_112_49_51_55_113_95_114_101_112_101_97_116_+0xe3f>
  4110b0:	mov    %r15,%r8
  4110b3:	mov    %r14,%rcx
  4110b6:	mov    %r13,%rdx
  4110b9:	mov    $0x0,%r13d
  4110bf:	mov    %r12d,%r12d
  4110c2:	add    %r13d,%r12d
  4110c5:	mov    %r12d,%r12d
  4110c8:	mov    %r11d,%r11d
  4110cb:	add    %r12d,%r11d
  4110ce:	mov    %r11d,%r11d
  4110d1:	add    %ebx,%r11d
  4110d4:	mov    %r11d,%r11d
  4110d7:	mov    %r10d,%r10d
  4110da:	add    %r11d,%r10d
  4110dd:	mov    %r10d,%r10d
  4110e0:	mov    %eax,%eax
  4110e2:	add    %r10d,%eax
  4110e5:	mov    %r9,%rbx
  4110e8:	mov    %eax,%r9d
  4110eb:	mov    %ebx,%eax
  4110ed:	add    %r9d,%eax
  4110f0:	mov    %eax,%r9d
  4110f3:	sub    $0x1,%rsi
  4110f7:	mov    %rcx,%r13
  4110fa:	mov    %r8,%r14
  4110fd:	mov    %r9,-0x1a0(%rbp)
  411104:	jmpq   4102c0 <p113d_FID_36_100_105_114_101_99_116_46_112_49_51_55_113_95_114_101_112_101_97_116_+0x40>
  411109:	mov    %rdx,%rsi
  41110c:	xchg   %r13,%r14
  41110f:	mov    -0x1a0(%rbp),%rbx
  411116:	mov    %rdi,%r12
  411119:	callq  435300 <p111_rt_sink>
  41111e:	mov    %r14,%rsi
  411121:	mov    %r12,%rdi
  411124:	mov    %rdi,%r12
  411127:	callq  435300 <p111_rt_sink>
  41112c:	mov    %r13,%rsi
  41112f:	mov    %r12,%rdi
  411132:	callq  435300 <p111_rt_sink>
  411137:	mov    %rbx,%rax
  41113a:	pop    %r15
  41113c:	pop    %r14
  41113e:	pop    %r13
  411140:	pop    %r12
  411142:	pop    %rbx
  411143:	leaveq 
  411144:	retq   

Disassembly of section .fini:
