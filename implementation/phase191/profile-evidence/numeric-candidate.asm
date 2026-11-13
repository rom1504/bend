
/home/ai/bend2/build/publish/bend/selfhost/build/phase191/native45-01/coverage-numeric-recurrence-1024/machine/program:     file format elf64-x86-64


Disassembly of section .init:

Disassembly of section .plt:

Disassembly of section .text:

00000000004083d6 <p113d_FID_36_100_105_114_101_99_116_46_112_51_55_46_110_117_109_101_114_105_99_>:
  4083d6:	55                                              	push   %rbp
  4083d7:	48 89 e5                                        	mov    %rsp,%rbp
  4083da:	48 81 ec 60 09 00 00                            	sub    $0x960,%rsp
  4083e1:	4c 89 65 f0                                     	mov    %r12,-0x10(%rbp)
  4083e5:	48 89 5d f8                                     	mov    %rbx,-0x8(%rbp)
  4083e9:	4c 89 6d e8                                     	mov    %r13,-0x18(%rbp)
  4083ed:	4c 89 75 e0                                     	mov    %r14,-0x20(%rbp)
  4083f1:	48 89 f8                                        	mov    %rdi,%rax
  4083f4:	49 89 c4                                        	mov    %rax,%r12
  4083f7:	48 89 f0                                        	mov    %rsi,%rax
  4083fa:	48 89 c7                                        	mov    %rax,%rdi
  4083fd:	48 89 d0                                        	mov    %rdx,%rax
  408400:	48 89 c6                                        	mov    %rax,%rsi
  408403:	48 89 c8                                        	mov    %rcx,%rax
  408406:	49 89 c5                                        	mov    %rax,%r13
  408409:	48 89 fa                                        	mov    %rdi,%rdx
  40840c:	48 81 fa 00 00 00 00                            	cmp    $0x0,%rdx
  408413:	0f 94 c2                                        	sete   %dl
  408416:	0f b6 d2                                        	movzbl %dl,%edx
  408419:	49 89 d2                                        	mov    %rdx,%r10
  40841c:	45 85 d2                                        	test   %r10d,%r10d
  40841f:	0f 84 18 00 00 00                               	je     40843d <p113d_FID_36_100_105_114_101_99_116_46_112_51_55_46_110_117_109_101_114_105_99_+0x67>
  408425:	4c 89 e8                                        	mov    %r13,%rax
  408428:	4c 8b 65 f0                                     	mov    -0x10(%rbp),%r12
  40842c:	48 8b 5d f8                                     	mov    -0x8(%rbp),%rbx
  408430:	4c 8b 6d e8                                     	mov    -0x18(%rbp),%r13
  408434:	4c 8b 75 e0                                     	mov    -0x20(%rbp),%r14
  408438:	48 89 ec                                        	mov    %rbp,%rsp
  40843b:	5d                                              	pop    %rbp
  40843c:	c3                                              	retq   
  40843d:	48 89 fa                                        	mov    %rdi,%rdx
  408440:	48 81 fa 00 00 00 00                            	cmp    $0x0,%rdx
  408447:	0f 95 c2                                        	setne  %dl
  40844a:	0f b6 d2                                        	movzbl %dl,%edx
  40844d:	49 89 d2                                        	mov    %rdx,%r10
  408450:	45 85 d2                                        	test   %r10d,%r10d
  408453:	0f 84 53 01 00 00                               	je     4085ac <p113d_FID_36_100_105_114_101_99_116_46_112_51_55_46_110_117_109_101_114_105_99_+0x1d6>
  408459:	49 89 fe                                        	mov    %rdi,%r14
  40845c:	49 81 ee 01 00 00 00                            	sub    $0x1,%r14
  408463:	4c 8d 95 c0 f7 ff ff                            	lea    -0x840(%rbp),%r10
  40846a:	49 bb 00 00 70 40 00 00 00 00                   	movabs $0x40700000,%r11
  408474:	4d 89 1a                                        	mov    %r11,(%r10)
  408477:	4c 8d 95 c0 f7 ff ff                            	lea    -0x840(%rbp),%r10
  40847e:	49 89 f3                                        	mov    %rsi,%r11
  408481:	4d 89 5a 08                                     	mov    %r11,0x8(%r10)
  408485:	66 0f 6e ce                                     	movd   %esi,%xmm1
  408489:	49 ba 00 00 70 40 00 00 00 00                   	movabs $0x40700000,%r10
  408493:	66 41 0f 6e c2                                  	movd   %r10d,%xmm0
  408498:	f3 0f 59 c1                                     	mulss  %xmm1,%xmm0
  40849c:	66 0f 7e c7                                     	movd   %xmm0,%edi
  4084a0:	48 89 fa                                        	mov    %rdi,%rdx
  4084a3:	4c 8d 95 c0 f7 ff ff                            	lea    -0x840(%rbp),%r10
  4084aa:	49 bb 00 00 80 3f 00 00 00 00                   	movabs $0x3f800000,%r11
  4084b4:	4d 89 1a                                        	mov    %r11,(%r10)
  4084b7:	4c 8d 95 c0 f7 ff ff                            	lea    -0x840(%rbp),%r10
  4084be:	49 89 f3                                        	mov    %rsi,%r11
  4084c1:	4d 89 5a 08                                     	mov    %r11,0x8(%r10)
  4084c5:	66 0f 6e ce                                     	movd   %esi,%xmm1
  4084c9:	49 ba 00 00 80 3f 00 00 00 00                   	movabs $0x3f800000,%r10
  4084d3:	66 41 0f 6e c2                                  	movd   %r10d,%xmm0
  4084d8:	f3 0f 5c c1                                     	subss  %xmm1,%xmm0
  4084dc:	66 0f 7e c7                                     	movd   %xmm0,%edi
  4084e0:	4c 8d 95 c0 f7 ff ff                            	lea    -0x840(%rbp),%r10
  4084e7:	49 89 d3                                        	mov    %rdx,%r11
  4084ea:	4d 89 1a                                        	mov    %r11,(%r10)
  4084ed:	4c 8d 95 c0 f7 ff ff                            	lea    -0x840(%rbp),%r10
  4084f4:	49 89 fb                                        	mov    %rdi,%r11
  4084f7:	4d 89 5a 08                                     	mov    %r11,0x8(%r10)
  4084fb:	66 0f 6e cf                                     	movd   %edi,%xmm1
  4084ff:	66 0f 6e c2                                     	movd   %edx,%xmm0
  408503:	f3 0f 59 c1                                     	mulss  %xmm1,%xmm0
  408507:	66 0f 7e c7                                     	movd   %xmm0,%edi
  40850b:	48 89 fb                                        	mov    %rdi,%rbx
  40850e:	45 89 ed                                        	mov    %r13d,%r13d
  408511:	4c 89 ef                                        	mov    %r13,%rdi
  408514:	69 ff 93 01 00 01                               	imul   $0x1000193,%edi,%edi
  40851a:	49 89 fd                                        	mov    %rdi,%r13
  40851d:	4c 8d 95 c0 f7 ff ff                            	lea    -0x840(%rbp),%r10
  408524:	49 89 db                                        	mov    %rbx,%r11
  408527:	4d 89 1a                                        	mov    %r11,(%r10)
  40852a:	4c 8d 95 c0 f7 ff ff                            	lea    -0x840(%rbp),%r10
  408531:	49 bb 00 24 74 49 00 00 00 00                   	movabs $0x49742400,%r11
  40853b:	4d 89 5a 08                                     	mov    %r11,0x8(%r10)
  40853f:	49 ba 00 24 74 49 00 00 00 00                   	movabs $0x49742400,%r10
  408549:	66 41 0f 6e ca                                  	movd   %r10d,%xmm1
  40854e:	66 0f 6e c3                                     	movd   %ebx,%xmm0
  408552:	f3 0f 59 c1                                     	mulss  %xmm1,%xmm0
  408556:	66 0f 7e c7                                     	movd   %xmm0,%edi
  40855a:	4c 8d 95 c0 f7 ff ff                            	lea    -0x840(%rbp),%r10
  408561:	49 89 fb                                        	mov    %rdi,%r11
  408564:	4d 89 1a                                        	mov    %r11,(%r10)
  408567:	4c 89 e7                                        	mov    %r12,%rdi
  40856a:	48 be 3a 00 00 00 00 00 00 00                   	movabs $0x3a,%rsi
  408574:	89 f6                                           	mov    %esi,%esi
  408576:	48 8d 95 c0 f7 ff ff                            	lea    -0x840(%rbp),%rdx
  40857d:	48 b9 01 00 00 00 00 00 00 00                   	movabs $0x1,%rcx
  408587:	89 c9                                           	mov    %ecx,%ecx
  408589:	31 c0                                           	xor    %eax,%eax
  40858b:	e8 50 cd 00 00                                  	callq  4152e0 <p111_rt_op>
  408590:	48 89 c7                                        	mov    %rax,%rdi
  408593:	89 ff                                           	mov    %edi,%edi
  408595:	49 89 fb                                        	mov    %rdi,%r11
  408598:	4c 89 ef                                        	mov    %r13,%rdi
  40859b:	4c 31 df                                        	xor    %r11,%rdi
  40859e:	48 89 de                                        	mov    %rbx,%rsi
  4085a1:	49 89 fd                                        	mov    %rdi,%r13
  4085a4:	4c 89 f7                                        	mov    %r14,%rdi
  4085a7:	e9 5d fe ff ff                                  	jmpq   408409 <p113d_FID_36_100_105_114_101_99_116_46_112_51_55_46_110_117_109_101_114_105_99_+0x33>
  4085ac:	4c 89 e7                                        	mov    %r12,%rdi
  4085af:	48 be 04 00 00 00 00 00 00 00                   	movabs $0x4,%rsi
  4085b9:	89 f6                                           	mov    %esi,%esi
  4085bb:	31 c0                                           	xor    %eax,%eax
  4085bd:	e8 fe cc 00 00                                  	callq  4152c0 <p111_rt_fail>
  4085c2:	48 89 85 18 f7 ff ff                            	mov    %rax,-0x8e8(%rbp)
  4085c9:	48 b8 00 00 00 00 00 00 00 00                   	movabs $0x0,%rax
  4085d3:	4c 8b 65 f0                                     	mov    -0x10(%rbp),%r12
  4085d7:	48 8b 5d f8                                     	mov    -0x8(%rbp),%rbx
  4085db:	4c 8b 6d e8                                     	mov    -0x18(%rbp),%r13
  4085df:	4c 8b 75 e0                                     	mov    -0x20(%rbp),%r14
  4085e3:	48 89 ec                                        	mov    %rbp,%rsp
  4085e6:	5d                                              	pop    %rbp
  4085e7:	c3                                              	retq   

Disassembly of section .fini:
