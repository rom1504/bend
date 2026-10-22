0000000000406160 <p113d_FID_36_100_105_114_101_99_116_46_105_115_101_99_116_53_>:
  406160:	f3 0f 1e fa          	endbr64 
  406164:	55                   	push   %rbp
  406165:	48 89 e5             	mov    %rsp,%rbp
  406168:	48 81 ec 18 08 00 00 	sub    $0x818,%rsp
  40616f:	53                   	push   %rbx
  406170:	41 54                	push   %r12
  406172:	41 55                	push   %r13
  406174:	4c 8b 55 30          	mov    0x30(%rbp),%r10
  406178:	4c 8b 5d 28          	mov    0x28(%rbp),%r11
  40617c:	48 8b 5d 20          	mov    0x20(%rbp),%rbx
  406180:	4c 8b 65 18          	mov    0x18(%rbp),%r12
  406184:	4c 8b 6d 10          	mov    0x10(%rbp),%r13
  406188:	4c 89 c0             	mov    %r8,%rax
  40618b:	4d 89 c8             	mov    %r9,%r8
  40618e:	4c 89 85 f0 f7 ff ff 	mov    %r8,-0x810(%rbp)
  406195:	48 89 b5 f8 f7 ff ff 	mov    %rsi,-0x808(%rbp)
  40619c:	66 49 0f 6e c0       	movq   %r8,%xmm0
  4061a1:	66 48 0f 6e ce       	movq   %rsi,%xmm1
  4061a6:	f3 0f 5c c1          	subss  %xmm1,%xmm0
  4061aa:	66 48 0f 7e c6       	movq   %xmm0,%rsi
  4061af:	41 89 f1             	mov    %esi,%r9d
  4061b2:	4c 89 ad f0 f7 ff ff 	mov    %r13,-0x810(%rbp)
  4061b9:	48 89 95 f8 f7 ff ff 	mov    %rdx,-0x808(%rbp)
  4061c0:	66 49 0f 6e c5       	movq   %r13,%xmm0
  4061c5:	66 48 0f 6e ca       	movq   %rdx,%xmm1
  4061ca:	f3 0f 5c c1          	subss  %xmm1,%xmm0
  4061ce:	66 48 0f 7e c2       	movq   %xmm0,%rdx
  4061d3:	41 89 d0             	mov    %edx,%r8d
  4061d6:	4c 89 a5 f0 f7 ff ff 	mov    %r12,-0x810(%rbp)
  4061dd:	48 89 8d f8 f7 ff ff 	mov    %rcx,-0x808(%rbp)
  4061e4:	66 49 0f 6e c4       	movq   %r12,%xmm0
  4061e9:	66 48 0f 6e c9       	movq   %rcx,%xmm1
  4061ee:	f3 0f 5c c1          	subss  %xmm1,%xmm0
  4061f2:	66 48 0f 7e c1       	movq   %xmm0,%rcx
  4061f7:	89 ce                	mov    %ecx,%esi
  4061f9:	4c 89 8d f0 f7 ff ff 	mov    %r9,-0x810(%rbp)
  406200:	48 89 9d f8 f7 ff ff 	mov    %rbx,-0x808(%rbp)
  406207:	66 49 0f 6e d9       	movq   %r9,%xmm3
  40620c:	66 48 0f 6e c3       	movq   %rbx,%xmm0
  406211:	f3 0f 59 c3          	mulss  %xmm3,%xmm0
  406215:	66 48 0f 7e c1       	movq   %xmm0,%rcx
  40621a:	89 ca                	mov    %ecx,%edx
  40621c:	4c 89 85 f0 f7 ff ff 	mov    %r8,-0x810(%rbp)
  406223:	4c 89 9d f8 f7 ff ff 	mov    %r11,-0x808(%rbp)
  40622a:	66 49 0f 6e d0       	movq   %r8,%xmm2
  40622f:	66 49 0f 6e c3       	movq   %r11,%xmm0
  406234:	f3 0f 59 c2          	mulss  %xmm2,%xmm0
  406238:	66 48 0f 7e c1       	movq   %xmm0,%rcx
  40623d:	89 c9                	mov    %ecx,%ecx
  40623f:	48 89 95 f0 f7 ff ff 	mov    %rdx,-0x810(%rbp)
  406246:	48 89 8d f8 f7 ff ff 	mov    %rcx,-0x808(%rbp)
  40624d:	66 48 0f 6e c2       	movq   %rdx,%xmm0
  406252:	66 48 0f 6e c9       	movq   %rcx,%xmm1
  406257:	f3 0f 58 c1          	addss  %xmm1,%xmm0
  40625b:	66 48 0f 7e c1       	movq   %xmm0,%rcx
  406260:	89 ca                	mov    %ecx,%edx
  406262:	48 89 b5 f0 f7 ff ff 	mov    %rsi,-0x810(%rbp)
  406269:	4c 89 95 f8 f7 ff ff 	mov    %r10,-0x808(%rbp)
  406270:	66 48 0f 6e ce       	movq   %rsi,%xmm1
  406275:	66 49 0f 6e c2       	movq   %r10,%xmm0
  40627a:	f3 0f 59 c1          	mulss  %xmm1,%xmm0
  40627e:	66 48 0f 7e c1       	movq   %xmm0,%rcx
  406283:	89 c9                	mov    %ecx,%ecx
  406285:	48 89 95 f0 f7 ff ff 	mov    %rdx,-0x810(%rbp)
  40628c:	48 89 8d f8 f7 ff ff 	mov    %rcx,-0x808(%rbp)
  406293:	66 48 0f 6e c2       	movq   %rdx,%xmm0
  406298:	66 48 0f 6e e1       	movq   %rcx,%xmm4
  40629d:	f3 0f 58 c4          	addss  %xmm4,%xmm0
  4062a1:	66 48 0f 7e c1       	movq   %xmm0,%rcx
  4062a6:	89 c9                	mov    %ecx,%ecx
  4062a8:	48 89 8d f0 f7 ff ff 	mov    %rcx,-0x810(%rbp)
  4062af:	48 89 8d f8 f7 ff ff 	mov    %rcx,-0x808(%rbp)
  4062b6:	66 48 0f 6e c1       	movq   %rcx,%xmm0
  4062bb:	f3 0f 10 e0          	movss  %xmm0,%xmm4
  4062bf:	f3 0f 59 e0          	mulss  %xmm0,%xmm4
  4062c3:	66 48 0f 7e e2       	movq   %xmm4,%rdx
  4062c8:	89 d2                	mov    %edx,%edx
  4062ca:	4c 89 8d f0 f7 ff ff 	mov    %r9,-0x810(%rbp)
  4062d1:	4c 89 8d f8 f7 ff ff 	mov    %r9,-0x808(%rbp)
  4062d8:	f3 0f 59 db          	mulss  %xmm3,%xmm3
  4062dc:	66 49 0f 7e d9       	movq   %xmm3,%r9
  4062e1:	45 89 c9             	mov    %r9d,%r9d
  4062e4:	4c 89 85 f0 f7 ff ff 	mov    %r8,-0x810(%rbp)
  4062eb:	4c 89 85 f8 f7 ff ff 	mov    %r8,-0x808(%rbp)
  4062f2:	f3 0f 59 d2          	mulss  %xmm2,%xmm2
  4062f6:	66 49 0f 7e d0       	movq   %xmm2,%r8
  4062fb:	45 89 c0             	mov    %r8d,%r8d
  4062fe:	4c 89 8d f0 f7 ff ff 	mov    %r9,-0x810(%rbp)
  406305:	4c 89 85 f8 f7 ff ff 	mov    %r8,-0x808(%rbp)
  40630c:	66 49 0f 6e d1       	movq   %r9,%xmm2
  406311:	66 49 0f 6e d8       	movq   %r8,%xmm3
  406316:	f3 0f 58 d3          	addss  %xmm3,%xmm2
  40631a:	66 49 0f 7e d0       	movq   %xmm2,%r8
  40631f:	45 89 c0             	mov    %r8d,%r8d
  406322:	48 89 b5 f0 f7 ff ff 	mov    %rsi,-0x810(%rbp)
  406329:	48 89 b5 f8 f7 ff ff 	mov    %rsi,-0x808(%rbp)
  406330:	f3 0f 59 c9          	mulss  %xmm1,%xmm1
  406334:	66 48 0f 7e ce       	movq   %xmm1,%rsi
  406339:	89 f6                	mov    %esi,%esi
  40633b:	4c 89 85 f0 f7 ff ff 	mov    %r8,-0x810(%rbp)
  406342:	48 89 b5 f8 f7 ff ff 	mov    %rsi,-0x808(%rbp)
  406349:	66 49 0f 6e c8       	movq   %r8,%xmm1
  40634e:	66 48 0f 6e d6       	movq   %rsi,%xmm2
  406353:	f3 0f 58 ca          	addss  %xmm2,%xmm1
  406357:	66 48 0f 7e ce       	movq   %xmm1,%rsi
  40635c:	89 f6                	mov    %esi,%esi
  40635e:	48 89 85 f0 f7 ff ff 	mov    %rax,-0x810(%rbp)
  406365:	48 89 85 f8 f7 ff ff 	mov    %rax,-0x808(%rbp)
  40636c:	66 48 0f 6e c8       	movq   %rax,%xmm1
  406371:	f3 0f 59 c9          	mulss  %xmm1,%xmm1
  406375:	66 48 0f 7e c8       	movq   %xmm1,%rax
  40637a:	89 c0                	mov    %eax,%eax
  40637c:	48 89 b5 f0 f7 ff ff 	mov    %rsi,-0x810(%rbp)
  406383:	48 89 85 f8 f7 ff ff 	mov    %rax,-0x808(%rbp)
  40638a:	66 48 0f 6e ce       	movq   %rsi,%xmm1
  40638f:	66 48 0f 6e d0       	movq   %rax,%xmm2
  406394:	f3 0f 5c ca          	subss  %xmm2,%xmm1
  406398:	66 48 0f 7e c8       	movq   %xmm1,%rax
  40639d:	89 c0                	mov    %eax,%eax
  40639f:	48 89 95 f0 f7 ff ff 	mov    %rdx,-0x810(%rbp)
  4063a6:	48 89 85 f8 f7 ff ff 	mov    %rax,-0x808(%rbp)
  4063ad:	66 48 0f 6e ca       	movq   %rdx,%xmm1
  4063b2:	66 48 0f 6e d0       	movq   %rax,%xmm2
  4063b7:	f3 0f 5c ca          	subss  %xmm2,%xmm1
  4063bb:	66 48 0f 7e c8       	movq   %xmm1,%rax
  4063c0:	89 c0                	mov    %eax,%eax
  4063c2:	66 48 0f 6e c8       	movq   %rax,%xmm1
  4063c7:	f3 0f 10 15 55 bc 02 00 	movss  0x2bc55(%rip),%xmm2        # 432024 <_IO_stdin_used+0x24>
  4063cf:	0f 2e d1             	ucomiss %xmm1,%xmm2
  4063d2:	0f 97 c2             	seta   %dl
  4063d5:	0f b6 d2             	movzbl %dl,%edx
  4063d8:	89 d6                	mov    %edx,%esi
  4063da:	48 83 fe 01          	cmp    $0x1,%rsi
  4063de:	0f 94 c2             	sete   %dl
  4063e1:	0f b6 d2             	movzbl %dl,%edx
  4063e4:	48 c1 ee 28          	shr    $0x28,%rsi
  4063e8:	48 81 e6 ff ff 7f 00 	and    $0x7fffff,%rsi
  4063ef:	48 81 fe 02 00 01 00 	cmp    $0x10002,%rsi
  4063f6:	40 0f 94 c6          	sete   %sil
  4063fa:	40 0f b6 f6          	movzbl %sil,%esi
  4063fe:	09 f2                	or     %esi,%edx
  406400:	0f 85 d9 00 00 00    	jne    4064df <p113d_FID_36_100_105_114_101_99_116_46_105_115_101_99_116_53_+0x37f>
  406406:	83 f2 01             	xor    $0x1,%edx
  406409:	75 14                	jne    40641f <p113d_FID_36_100_105_114_101_99_116_46_105_115_101_99_116_53_+0x2bf>
  40640b:	be 04 00 00 00       	mov    $0x4,%esi
  406410:	e8 8b 64 02 00       	callq  42c8a0 <p111_rt_fail>
  406415:	b8 00 00 00 00       	mov    $0x0,%eax
  40641a:	e9 cd 00 00 00       	jmpq   4064ec <p113d_FID_36_100_105_114_101_99_116_46_105_115_101_99_116_53_+0x38c>
  40641f:	2e 48 c7 45 f0 00 00 00 00 	movq   $0x0,%cs:-0x10(%rbp)
  406428:	48 c7 45 f0 00 00 00 00 	movq   $0x0,-0x10(%rbp)
  406430:	48 89 4d f8          	mov    %rcx,-0x8(%rbp)
  406434:	0f 57 05 d5 bb 02 00 	xorps  0x2bbd5(%rip),%xmm0        # 432010 <_IO_stdin_used+0x10>
  40643b:	f3 0f 58 05 e1 bb 02 00 	addss  0x2bbe1(%rip),%xmm0        # 432024 <_IO_stdin_used+0x24>
  406443:	66 48 0f 7e c1       	movq   %xmm0,%rcx
  406448:	89 cb                	mov    %ecx,%ebx
  40644a:	48 89 45 f0          	mov    %rax,-0x10(%rbp)
  40644e:	b9 01 00 00 00       	mov    $0x1,%ecx
  406453:	48 8d 55 f0          	lea    -0x10(%rbp),%rdx
  406457:	be 24 00 00 00       	mov    $0x24,%esi
  40645c:	49 89 fc             	mov    %rdi,%r12
  40645f:	e8 5c 64 02 00       	callq  42c8c0 <p111_rt_op>
  406464:	4c 89 e7             	mov    %r12,%rdi
  406467:	48 89 5d f0          	mov    %rbx,-0x10(%rbp)
  40646b:	48 89 45 f8          	mov    %rax,-0x8(%rbp)
  40646f:	66 48 0f 6e c3       	movq   %rbx,%xmm0
  406474:	66 48 0f 6e c8       	movq   %rax,%xmm1
  406479:	f3 0f 5c c1          	subss  %xmm1,%xmm0
  40647d:	66 48 0f 7e c0       	movq   %xmm0,%rax
  406482:	89 c0                	mov    %eax,%eax
  406484:	66 48 0f 6e c0       	movq   %rax,%xmm0
  406489:	f3 0f 10 0d 97 bb 02 00 	movss  0x2bb97(%rip),%xmm1        # 432028 <_IO_stdin_used+0x28>
  406491:	0f 2e c8             	ucomiss %xmm0,%xmm1
  406494:	0f 97 c1             	seta   %cl
  406497:	0f b6 c9             	movzbl %cl,%ecx
  40649a:	89 ca                	mov    %ecx,%edx
  40649c:	48 83 fa 01          	cmp    $0x1,%rdx
  4064a0:	0f 94 c1             	sete   %cl
  4064a3:	0f b6 c9             	movzbl %cl,%ecx
  4064a6:	48 c1 ea 28          	shr    $0x28,%rdx
  4064aa:	48 81 e2 ff ff 7f 00 	and    $0x7fffff,%rdx
  4064b1:	48 81 fa 02 00 01 00 	cmp    $0x10002,%rdx
  4064b8:	0f 94 c2             	sete   %dl
  4064bb:	0f b6 d2             	movzbl %dl,%edx
  4064be:	09 d1                	or     %edx,%ecx
  4064c0:	75 16                	jne    4064d8 <p113d_FID_36_100_105_114_101_99_116_46_105_115_101_99_116_53_+0x378>
  4064c2:	83 f1 01             	xor    $0x1,%ecx
  4064c5:	75 25                	jne    4064ec <p113d_FID_36_100_105_114_101_99_116_46_105_115_101_99_116_53_+0x38c>
  4064c7:	be 04 00 00 00       	mov    $0x4,%esi
  4064cc:	e8 cf 63 02 00       	callq  42c8a0 <p111_rt_fail>
  4064d1:	b8 00 00 00 00       	mov    $0x0,%eax
  4064d6:	eb 14                	jmp    4064ec <p113d_FID_36_100_105_114_101_99_116_46_105_115_101_99_116_53_+0x38c>
  4064d8:	b8 28 6b 6e 4e       	mov    $0x4e6e6b28,%eax
  4064dd:	eb 0d                	jmp    4064ec <p113d_FID_36_100_105_114_101_99_116_46_105_115_101_99_116_53_+0x38c>
  4064df:	48 c7 45 f0 00 ca 9a 3b 	movq   $0x3b9aca00,-0x10(%rbp)
  4064e7:	b8 28 6b 6e 4e       	mov    $0x4e6e6b28,%eax
  4064ec:	41 5d                	pop    %r13
  4064ee:	41 5c                	pop    %r12
  4064f0:	5b                   	pop    %rbx
  4064f1:	c9                   	leaveq 
  4064f2:	c3                   	retq   
  4064f3:	66 66 2e 0f 1f 84 00 00 00 00 00 	data16 nopw %cs:0x0(%rax,%rax,1)
  4064fe:	66 90                	xchg   %ax,%ax

