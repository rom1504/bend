
/home/ai/bend2/build/publish/bend/selfhost/build/phase111/p126-observer32-coverage-record-aggregation-256-build/program:     file format elf64-x86-64


Disassembly of section .init:

Disassembly of section .plt:

Disassembly of section .text:

00000000004271a0 <p111_FID_36_100_105_114_101_99_116_46_112_51_55_46_97_103_103_114_101_103_97_116_101_>:
  4271a0:	f3 0f 1e fa          	endbr64 
  4271a4:	55                   	push   %rbp
  4271a5:	48 89 e5             	mov    %rsp,%rbp
  4271a8:	48 81 ec 08 08 00 00 	sub    $0x808,%rsp
  4271af:	53                   	push   %rbx
  4271b0:	41 54                	push   %r12
  4271b2:	41 55                	push   %r13
  4271b4:	48 8b 77 28          	mov    0x28(%rdi),%rsi
  4271b8:	48 8b 5f 30          	mov    0x30(%rdi),%rbx
  4271bc:	48 89 f0             	mov    %rsi,%rax
  4271bf:	48 c1 e8 28          	shr    $0x28,%rax
  4271c3:	48 25 ff ff 00 00    	and    $0xffff,%rax
  4271c9:	48 83 f8 11          	cmp    $0x11,%rax
  4271cd:	0f 84 bc 01 00 00    	je     42738f <p111_FID_36_100_105_114_101_99_116_46_112_51_55_46_97_103_103_114_101_103_97_116_101_+0x1ef>
  4271d3:	2e 2e 2e 48 83 f8 12 	cs cs cs cmp $0x12,%rax
  4271da:	0f 94 c0             	sete   %al
  4271dd:	0f b6 c0             	movzbl %al,%eax
  4271e0:	83 f8 00             	cmp    $0x0,%eax
  4271e3:	75 4b                	jne    427230 <p111_FID_36_100_105_114_101_99_116_46_112_51_55_46_97_103_103_114_101_103_97_116_101_+0x90>
  4271e5:	48 89 9d 00 f8 ff ff 	mov    %rbx,-0x800(%rbp)
  4271ec:	48 8b 47 10          	mov    0x10(%rdi),%rax
  4271f0:	48 89 18             	mov    %rbx,(%rax)
  4271f3:	48 c7 40 08 ef 02 00 	movq   $0x2ef,0x8(%rax)
  4271fa:	00 
  4271fb:	48 83 c0 10          	add    $0x10,%rax
  4271ff:	48 89 47 10          	mov    %rax,0x10(%rdi)
  427203:	48 89 b5 00 f8 ff ff 	mov    %rsi,-0x800(%rbp)
  42720a:	48 8b 47 10          	mov    0x10(%rdi),%rax
  42720e:	48 89 30             	mov    %rsi,(%rax)
  427211:	48 c7 40 08 f0 02 00 	movq   $0x2f0,0x8(%rax)
  427218:	00 
  427219:	48 83 c0 10          	add    $0x10,%rax
  42721d:	48 89 47 10          	mov    %rax,0x10(%rdi)
  427221:	be 04 00 00 00       	mov    $0x4,%esi
  427226:	e8 35 8c 00 00       	callq  42fe60 <p111_rt_fail>
  42722b:	e9 77 01 00 00       	jmpq   4273a7 <p111_FID_36_100_105_114_101_99_116_46_112_51_55_46_97_103_103_114_101_103_97_116_101_+0x207>
  427230:	2e 2e 2e 48 8d 95 00 	cs cs lea %cs:-0x800(%rbp),%rdx
  427237:	f8 ff ff 
  42723a:	49 89 fc             	mov    %rdi,%r12
  42723d:	e8 3e dc 00 00       	callq  434e80 <p125_rt_take2>
  427242:	4c 89 e7             	mov    %r12,%rdi
  427245:	48 8b b5 00 f8 ff ff 	mov    -0x800(%rbp),%rsi
  42724c:	4c 8b ad 08 f8 ff ff 	mov    -0x7f8(%rbp),%r13
  427253:	48 89 f0             	mov    %rsi,%rax
  427256:	48 c1 e8 28          	shr    $0x28,%rax
  42725a:	48 25 ff ff 00 00    	and    $0xffff,%rax
  427260:	48 83 f8 08          	cmp    $0x8,%rax
  427264:	74 69                	je     4272cf <p111_FID_36_100_105_114_101_99_116_46_112_51_55_46_97_103_103_114_101_103_97_116_101_+0x12f>
  427266:	48 89 9d 00 f8 ff ff 	mov    %rbx,-0x800(%rbp)
  42726d:	48 8b 47 10          	mov    0x10(%rdi),%rax
  427271:	48 89 18             	mov    %rbx,(%rax)
  427274:	48 c7 40 08 ec 02 00 	movq   $0x2ec,0x8(%rax)
  42727b:	00 
  42727c:	48 83 c0 10          	add    $0x10,%rax
  427280:	48 89 47 10          	mov    %rax,0x10(%rdi)
  427284:	4c 89 ad 00 f8 ff ff 	mov    %r13,-0x800(%rbp)
  42728b:	48 8b 47 10          	mov    0x10(%rdi),%rax
  42728f:	4c 89 28             	mov    %r13,(%rax)
  427292:	48 c7 40 08 ed 02 00 	movq   $0x2ed,0x8(%rax)
  427299:	00 
  42729a:	48 83 c0 10          	add    $0x10,%rax
  42729e:	48 89 47 10          	mov    %rax,0x10(%rdi)
  4272a2:	48 89 b5 00 f8 ff ff 	mov    %rsi,-0x800(%rbp)
  4272a9:	48 8b 47 10          	mov    0x10(%rdi),%rax
  4272ad:	48 89 30             	mov    %rsi,(%rax)
  4272b0:	48 c7 40 08 ee 02 00 	movq   $0x2ee,0x8(%rax)
  4272b7:	00 
  4272b8:	48 83 c0 10          	add    $0x10,%rax
  4272bc:	48 89 47 10          	mov    %rax,0x10(%rdi)
  4272c0:	be 04 00 00 00       	mov    $0x4,%esi
  4272c5:	e8 96 8b 00 00       	callq  42fe60 <p111_rt_fail>
  4272ca:	e9 d8 00 00 00       	jmpq   4273a7 <p111_FID_36_100_105_114_101_99_116_46_112_51_55_46_97_103_103_114_101_103_97_116_101_+0x207>
  4272cf:	48 8d 95 00 f8 ff ff 	lea    -0x800(%rbp),%rdx
  4272d6:	49 89 fc             	mov    %rdi,%r12
  4272d9:	e8 a2 db 00 00       	callq  434e80 <p125_rt_take2>
  4272de:	4c 89 e7             	mov    %r12,%rdi
  4272e1:	48 8b b5 00 f8 ff ff 	mov    -0x800(%rbp),%rsi
  4272e8:	49 89 dc             	mov    %rbx,%r12
  4272eb:	48 8b 9d 08 f8 ff ff 	mov    -0x7f8(%rbp),%rbx
  4272f2:	4c 89 ad 00 f8 ff ff 	mov    %r13,-0x800(%rbp)
  4272f9:	48 8b 47 10          	mov    0x10(%rdi),%rax
  4272fd:	4c 89 28             	mov    %r13,(%rax)
  427300:	48 c7 40 08 e8 02 00 	movq   $0x2e8,0x8(%rax)
  427307:	00 
  427308:	48 83 c0 10          	add    $0x10,%rax
  42730c:	48 89 47 10          	mov    %rax,0x10(%rdi)
  427310:	49 89 fd             	mov    %rdi,%r13
  427313:	e8 28 83 00 00       	callq  42f640 <p111_rt_keep>
  427318:	4c 89 ef             	mov    %r13,%rdi
  42731b:	4c 89 a5 00 f8 ff ff 	mov    %r12,-0x800(%rbp)
  427322:	48 89 85 08 f8 ff ff 	mov    %rax,-0x7f8(%rbp)
  427329:	48 89 85 10 f8 ff ff 	mov    %rax,-0x7f0(%rbp)
  427330:	48 8b 47 10          	mov    0x10(%rdi),%rax
  427334:	4c 89 20             	mov    %r12,(%rax)
  427337:	48 8b 8d 08 f8 ff ff 	mov    -0x7f8(%rbp),%rcx
  42733e:	48 89 48 08          	mov    %rcx,0x8(%rax)
  427342:	48 8b 8d 10 f8 ff ff 	mov    -0x7f0(%rbp),%rcx
  427349:	48 89 48 10          	mov    %rcx,0x10(%rax)
  42734d:	48 c7 40 18 e9 02 00 	movq   $0x2e9,0x18(%rax)
  427354:	00 
  427355:	48 89 c1             	mov    %rax,%rcx
  427358:	48 83 c1 20          	add    $0x20,%rcx
  42735c:	48 89 4f 10          	mov    %rcx,0x10(%rdi)
  427360:	48 c7 40 20 eb 02 00 	movq   $0x2eb,0x20(%rax)
  427367:	00 
  427368:	48 83 c0 28          	add    $0x28,%rax
  42736c:	48 89 47 10          	mov    %rax,0x10(%rdi)
  427370:	48 89 9d 00 f8 ff ff 	mov    %rbx,-0x800(%rbp)
  427377:	b9 01 00 00 00       	mov    $0x1,%ecx
  42737c:	48 8d 95 00 f8 ff ff 	lea    -0x800(%rbp),%rdx
  427383:	be 22 01 00 00       	mov    $0x122,%esi
  427388:	e8 03 89 00 00       	callq  42fc90 <p111_rt_jump>
  42738d:	eb 18                	jmp    4273a7 <p111_FID_36_100_105_114_101_99_116_46_112_51_55_46_97_103_103_114_101_103_97_116_101_+0x207>
  42738f:	48 89 9d 00 f8 ff ff 	mov    %rbx,-0x800(%rbp)
  427396:	ba 01 00 00 00       	mov    $0x1,%edx
  42739b:	48 8d b5 00 f8 ff ff 	lea    -0x800(%rbp),%rsi
  4273a2:	e8 49 89 00 00       	callq  42fcf0 <p111_rt_return>
  4273a7:	41 5d                	pop    %r13
  4273a9:	41 5c                	pop    %r12
  4273ab:	5b                   	pop    %rbx
  4273ac:	c9                   	leaveq 
  4273ad:	c3                   	retq   

Disassembly of section .fini:
